"""Family encouragement business logic and access control.

HTTP-free: routes translate the domain exceptions below into HTTP responses.
Access reuses the patient-profile visibility rules so RBAC lives in one place.

MEDICAL SAFETY: family support content only. Messages are never analyzed,
scored, or used to infer any medical condition.

Access model:
- View (list): admin=all, doctor/therapist=assigned, patient=own, family=linked,
  manager=same center (via visible_patient_profile_ids).
- Create: a linked family member or an admin only.
"""

import uuid
from typing import Iterable, List, Optional, Tuple

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.permissions import ROLE_ADMIN, ROLE_FAMILY
from app.models import FamilyEncouragement, PatientProfile, User
from app.modules.audit.service import record_audit
from app.modules.patients.service import (
    can_view_profile,
    visible_patient_profile_ids,
)


# --- domain exceptions -------------------------------------------------------


class EncouragementError(Exception):
    """Base class for family-encouragement domain errors."""


class ProfileNotFoundError(EncouragementError):
    """The referenced patient profile does not exist."""


class NotAllowedError(EncouragementError):
    """The user is not allowed to perform this action."""


# Only a linked family member or an admin may create encouragements. Patients
# receive them; doctors/therapists/managers are view-only.
_CREATE_ROLES = frozenset({ROLE_FAMILY, ROLE_ADMIN})


# --- queries -----------------------------------------------------------------


def list_encouragements(
    session: Session,
    viewer: User,
    roles: Iterable[str],
    *,
    patient_profile_id: Optional[uuid.UUID] = None,
    limit: int = 50,
    offset: int = 0,
) -> Tuple[List[FamilyEncouragement], int]:
    # Which patient profiles the viewer may see (None == all/admin).
    visible = visible_patient_profile_ids(session, viewer, roles)

    conditions = [FamilyEncouragement.deleted_at.is_(None)]
    if visible is not None:
        if not visible:
            return [], 0
        # A requested profile must be within the visible set.
        if patient_profile_id is not None and patient_profile_id not in visible:
            return [], 0
        conditions.append(FamilyEncouragement.patient_profile_id.in_(visible))

    if patient_profile_id is not None:
        conditions.append(
            FamilyEncouragement.patient_profile_id == patient_profile_id
        )

    total = session.execute(
        select(func.count()).select_from(FamilyEncouragement).where(*conditions)
    ).scalar_one()
    rows = (
        session.execute(
            select(FamilyEncouragement)
            .where(*conditions)
            .order_by(FamilyEncouragement.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
        .scalars()
        .all()
    )
    return list(rows), int(total)


# --- mutations ---------------------------------------------------------------


def create_encouragement(
    session: Session,
    *,
    sender: User,
    roles: Iterable[str],
    patient_profile_id: uuid.UUID,
    message: str,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> FamilyEncouragement:
    role_set = set(roles)
    # Only a linked family member or an admin may send.
    if not (role_set & _CREATE_ROLES):
        raise NotAllowedError()

    profile = session.get(PatientProfile, patient_profile_id)
    if profile is None or profile.deleted_at is not None:
        raise ProfileNotFoundError()

    # Admins may send for any profile; a family member must be linked to it.
    if ROLE_ADMIN not in role_set and not can_view_profile(
        session, sender, role_set, profile
    ):
        raise NotAllowedError()

    encouragement = FamilyEncouragement(
        patient_profile_id=patient_profile_id,
        sender_user_id=sender.id,
        message=message,
    )
    session.add(encouragement)
    session.flush()
    record_audit(
        session,
        action="create_family_encouragement",
        entity_type="FamilyEncouragement",
        actor_user_id=sender.id,
        entity_id=encouragement.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={"patient_profile_id": str(patient_profile_id)},
        commit=False,
    )
    session.commit()
    return encouragement
