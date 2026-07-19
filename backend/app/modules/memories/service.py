"""Memory Album business logic and access control.

HTTP-free: routes translate the domain exceptions below into HTTP responses.
Access reuses the patient-profile visibility rules so RBAC lives in one place.

MEDICAL SAFETY: memories are supportive/family-engagement content only. They are
never analyzed, scored, or used to infer any medical condition.

Access model:
- View (list/detail/media): PRIVATE to the patient (own) and their linked
  family, plus admin. Doctors/therapists/managers are intentionally excluded —
  the Memory Album is personal family content, not care-team clinical data.
- Create: patient (own profile), linked family, or admin only.
- Update/delete: creator or admin only.
"""

import uuid
from datetime import datetime, timezone
from typing import Iterable, List, Optional, Tuple

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.permissions import ROLE_ADMIN, ROLE_FAMILY, ROLE_PATIENT
from app.models import MemoryEntry, PatientFamilyLink, PatientProfile, User
from app.modules.audit.service import record_audit
from app.modules.memories import media
from app.modules.patients.service import can_view_profile


# --- domain exceptions -------------------------------------------------------


class MemoryError(Exception):
    """Base class for memory-album domain errors."""


class ProfileNotFoundError(MemoryError):
    """The referenced patient profile does not exist."""


class NotAllowedError(MemoryError):
    """The user is not allowed to perform this action."""


# Only the patient (own profile), a linked family member, or an admin may create
# memories. Doctors/therapists/managers are view-only.
_CREATE_ROLES = frozenset({ROLE_PATIENT, ROLE_FAMILY, ROLE_ADMIN})

# Editable fields other than title (which is required on create).
_FIELDS = (
    "description",
    "person_name",
    "relationship",
    "place_name",
    "memory_date",
    "category",
    "media_type",
    "media_url",
)


# --- queries -----------------------------------------------------------------


def get_memory(session: Session, memory_id: uuid.UUID) -> Optional[MemoryEntry]:
    memory = session.get(MemoryEntry, memory_id)
    if memory is None or memory.deleted_at is not None:
        return None
    return memory


def _memory_visible_profile_ids(session: Session, viewer: User, roles: Iterable[str]):
    """Profile ids whose memories `viewer` may see, or None for admin (all).

    PRIVACY: the Memory Album is private to the patient and their linked family.
    Doctors/therapists/managers are intentionally excluded — memories are
    personal family content, not care-team clinical data. (A future
    `share_with_care_team` flag could widen this; none exists yet.)
    """
    role_set = set(roles)
    if ROLE_ADMIN in role_set:
        return None
    ids = set()
    if ROLE_PATIENT in role_set:
        ids |= set(
            session.execute(
                select(PatientProfile.id).where(
                    PatientProfile.user_id == viewer.id,
                    PatientProfile.deleted_at.is_(None),
                )
            )
            .scalars()
            .all()
        )
    if ROLE_FAMILY in role_set:
        ids |= set(
            session.execute(
                select(PatientFamilyLink.patient_profile_id).where(
                    PatientFamilyLink.family_user_id == viewer.id,
                    PatientFamilyLink.active.is_(True),
                )
            )
            .scalars()
            .all()
        )
    return ids


def can_view_memory(
    session: Session,
    viewer: User,
    roles: Iterable[str],
    memory: MemoryEntry,
) -> bool:
    """Return True if `viewer` may view `memory` (patient/family/admin only)."""
    profile = session.get(PatientProfile, memory.patient_profile_id)
    if profile is None or profile.deleted_at is not None:
        return False
    ids = _memory_visible_profile_ids(session, viewer, roles)
    if ids is None:  # admin
        return True
    return memory.patient_profile_id in ids


def can_modify_memory(editor: User, roles: Iterable[str], memory: MemoryEntry) -> bool:
    """Return True if `editor` may modify `memory` (its creator or an admin)."""
    return (
        ROLE_ADMIN in set(roles) or memory.uploaded_by_user_id == editor.id
    )


def list_memories(
    session: Session,
    viewer: User,
    roles: Iterable[str],
    *,
    patient_profile_id: Optional[uuid.UUID] = None,
    limit: int = 50,
    offset: int = 0,
) -> Tuple[List[MemoryEntry], int]:
    # Memories are private to patient/family (admin sees all). Clinicians get
    # an empty set here, so they never receive raw memory items from the API.
    visible = _memory_visible_profile_ids(session, viewer, roles)

    conditions = [MemoryEntry.deleted_at.is_(None)]
    if visible is not None:
        if not visible:
            return [], 0
        # A requested profile must be within the visible set.
        if patient_profile_id is not None and patient_profile_id not in visible:
            return [], 0
        conditions.append(MemoryEntry.patient_profile_id.in_(visible))

    if patient_profile_id is not None:
        conditions.append(MemoryEntry.patient_profile_id == patient_profile_id)

    total = session.execute(
        select(func.count()).select_from(MemoryEntry).where(*conditions)
    ).scalar_one()
    rows = (
        session.execute(
            select(MemoryEntry)
            .where(*conditions)
            .order_by(MemoryEntry.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
        .scalars()
        .all()
    )
    return list(rows), int(total)


# --- mutations ---------------------------------------------------------------


def create_memory(
    session: Session,
    *,
    creator: User,
    roles: Iterable[str],
    patient_profile_id: uuid.UUID,
    title: str,
    fields: dict,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> MemoryEntry:
    role_set = set(roles)
    # Doctors/therapists/managers are view-only.
    if not (role_set & _CREATE_ROLES):
        raise NotAllowedError()

    profile = session.get(PatientProfile, patient_profile_id)
    if profile is None or profile.deleted_at is not None:
        raise ProfileNotFoundError()

    # Admins may create for any profile; others must have access to it (a patient
    # to their own profile, a family member to a linked profile).
    if ROLE_ADMIN not in role_set and not can_view_profile(
        session, creator, role_set, profile
    ):
        raise NotAllowedError()

    memory = MemoryEntry(
        patient_profile_id=patient_profile_id,
        uploaded_by_user_id=creator.id,
        title=title,
    )
    for key in _FIELDS:
        if key in fields:
            setattr(memory, key, fields[key])
    session.add(memory)
    session.flush()
    record_audit(
        session,
        action="create_memory_entry",
        entity_type="MemoryEntry",
        actor_user_id=creator.id,
        entity_id=memory.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={"patient_profile_id": str(patient_profile_id)},
        commit=False,
    )
    session.commit()
    return memory


def update_memory(
    session: Session,
    *,
    memory: MemoryEntry,
    editor: User,
    roles: Iterable[str],
    fields: dict,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> MemoryEntry:
    # Only the creator or an admin may edit.
    if ROLE_ADMIN not in set(roles) and memory.uploaded_by_user_id != editor.id:
        raise NotAllowedError()

    if "title" in fields and fields["title"] is not None:
        memory.title = fields["title"]
    for key in _FIELDS:
        if key in fields:
            setattr(memory, key, fields[key])
    session.add(memory)
    record_audit(
        session,
        action="update_memory_entry",
        entity_type="MemoryEntry",
        actor_user_id=editor.id,
        entity_id=memory.id,
        ip_address=ip_address,
        device_info=device_info,
        commit=False,
    )
    session.commit()
    return memory


def delete_memory(
    session: Session,
    *,
    memory: MemoryEntry,
    editor: User,
    roles: Iterable[str],
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> None:
    # Only the creator or an admin may delete (soft delete).
    if ROLE_ADMIN not in set(roles) and memory.uploaded_by_user_id != editor.id:
        raise NotAllowedError()

    memory.deleted_at = datetime.now(timezone.utc)
    session.add(memory)
    record_audit(
        session,
        action="delete_memory_entry",
        entity_type="MemoryEntry",
        actor_user_id=editor.id,
        entity_id=memory.id,
        ip_address=ip_address,
        device_info=device_info,
        commit=False,
    )
    session.commit()


def attach_media(
    session: Session,
    *,
    memory: MemoryEntry,
    uploader: User,
    roles: Iterable[str],
    data: bytes,
    extension: str,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> MemoryEntry:
    """Store an uploaded image for `memory` and point it at the new file.

    Only the creator or an admin may upload (caller should also enforce this).
    Replacing a previously uploaded *local* image removes the old file safely.
    """
    if not can_modify_memory(uploader, roles, memory):
        raise NotAllowedError()

    previous_url = memory.media_url
    filename = media.save_image_bytes(data, extension)

    memory.media_type = "image"
    memory.media_url = media.public_url(filename)
    session.add(memory)
    record_audit(
        session,
        action="memory_media_uploaded",
        entity_type="MemoryEntry",
        actor_user_id=uploader.id,
        entity_id=memory.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={"media_url": memory.media_url},
        commit=False,
    )
    session.commit()

    # Best-effort cleanup of the replaced local file (never external URLs).
    if previous_url and previous_url != memory.media_url:
        media.delete_local_media(previous_url)
    return memory
