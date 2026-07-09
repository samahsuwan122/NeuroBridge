"""Memory Album business logic and access control.

HTTP-free: routes translate the domain exceptions below into HTTP responses.
Access reuses the patient-profile visibility rules so RBAC lives in one place.

MEDICAL SAFETY: memories are supportive/family-engagement content only. They are
never analyzed, scored, or used to infer any medical condition.

Access model:
- View (list/detail): admin=all, doctor/therapist=assigned, patient=own,
  family=linked, manager=same center (via visible_patient_profile_ids).
- Create: patient (own profile), linked family, or admin only. Doctor/therapist/
  manager are view-only.
- Update/delete: creator or admin only.
"""

import uuid
from datetime import datetime, timezone
from typing import Iterable, List, Optional, Tuple

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.permissions import ROLE_ADMIN, ROLE_FAMILY, ROLE_PATIENT
from app.models import MemoryEntry, PatientProfile, User
from app.modules.audit.service import record_audit
from app.modules.patients.service import (
    can_view_profile,
    visible_patient_profile_ids,
)


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


def can_view_memory(
    session: Session,
    viewer: User,
    roles: Iterable[str],
    memory: MemoryEntry,
) -> bool:
    """Return True if `viewer` may view `memory` (via its patient profile)."""
    profile = session.get(PatientProfile, memory.patient_profile_id)
    if profile is None or profile.deleted_at is not None:
        return False
    return can_view_profile(session, viewer, set(roles), profile)


def list_memories(
    session: Session,
    viewer: User,
    roles: Iterable[str],
    *,
    patient_profile_id: Optional[uuid.UUID] = None,
    limit: int = 50,
    offset: int = 0,
) -> Tuple[List[MemoryEntry], int]:
    # Which patient profiles the viewer may see (None == all/admin).
    visible = visible_patient_profile_ids(session, viewer, roles)

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
