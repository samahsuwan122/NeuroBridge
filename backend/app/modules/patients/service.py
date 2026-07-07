"""Patient profile business logic and role-based visibility.

HTTP-free: routes translate the domain exceptions below into HTTP responses.
Role validity (patient/doctor/therapist/family) is enforced here. Sensitive
actions write audit logs in the same transaction.
"""

import uuid
from datetime import date
from typing import Iterable, List, Optional, Sequence, Set, Tuple

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.permissions import (
    CLINICAL_ROLES,
    ROLE_ADMIN,
    ROLE_FAMILY,
    ROLE_MANAGER,
    ROLE_PATIENT,
)
from app.models import (
    PatientAssignment,
    PatientFamilyLink,
    PatientProfile,
    User,
)
from app.modules.audit.service import record_audit
from app.modules.auth.service import get_role_names


# --- domain exceptions -------------------------------------------------------


class PatientError(Exception):
    """Base class for patient-service domain errors."""


class UserNotFoundError(PatientError):
    """A referenced user does not exist."""


class NotPatientRoleError(PatientError):
    """The target user does not have the patient role."""


class DuplicateProfileError(PatientError):
    """The user already has a patient profile."""


class WrongClinicianRoleError(PatientError):
    """The user does not have the required doctor/therapist role."""


class WrongFamilyRoleError(PatientError):
    """The user does not have the family role."""


class RelationshipNotFoundError(PatientError):
    """An assignment or family link was not found for this profile."""


# --- helpers -----------------------------------------------------------------


def _get_active_user(session: Session, user_id: uuid.UUID) -> Optional[User]:
    user = session.get(User, user_id)
    if user is None or user.deleted_at is not None:
        return None
    return user


def _user_has_role(session: Session, user_id: uuid.UUID, role_name: str) -> bool:
    return role_name in get_role_names(session, user_id)


# --- queries -----------------------------------------------------------------


def get_profile(session: Session, profile_id: uuid.UUID) -> Optional[PatientProfile]:
    profile = session.get(PatientProfile, profile_id)
    if profile is None or profile.deleted_at is not None:
        return None
    return profile


def get_assignments(
    session: Session, profile_id: uuid.UUID
) -> List[PatientAssignment]:
    return list(
        session.execute(
            select(PatientAssignment)
            .where(PatientAssignment.patient_profile_id == profile_id)
            .order_by(PatientAssignment.created_at)
        )
        .scalars()
        .all()
    )


def get_family_links(
    session: Session, profile_id: uuid.UUID
) -> List[PatientFamilyLink]:
    return list(
        session.execute(
            select(PatientFamilyLink)
            .where(PatientFamilyLink.patient_profile_id == profile_id)
            .order_by(PatientFamilyLink.created_at)
        )
        .scalars()
        .all()
    )


# --- visibility (RBAC) -------------------------------------------------------


def can_view_profile(
    session: Session,
    viewer: User,
    roles: Iterable[str],
    profile: PatientProfile,
) -> bool:
    """Return True if `viewer` (with `roles`) may view `profile`."""
    role_set = set(roles)

    if ROLE_ADMIN in role_set:
        return True

    if (
        ROLE_MANAGER in role_set
        and viewer.medical_center_id is not None
        and profile.medical_center_id == viewer.medical_center_id
    ):
        return True

    if role_set & CLINICAL_ROLES:
        assigned = session.execute(
            select(PatientAssignment.id).where(
                PatientAssignment.patient_profile_id == profile.id,
                PatientAssignment.clinician_user_id == viewer.id,
                PatientAssignment.active.is_(True),
            )
        ).first()
        if assigned is not None:
            return True

    if ROLE_PATIENT in role_set and profile.user_id == viewer.id:
        return True

    if ROLE_FAMILY in role_set:
        linked = session.execute(
            select(PatientFamilyLink.id).where(
                PatientFamilyLink.patient_profile_id == profile.id,
                PatientFamilyLink.family_user_id == viewer.id,
                PatientFamilyLink.active.is_(True),
            )
        ).first()
        if linked is not None:
            return True

    return False


def _visible_profile_ids(
    session: Session, viewer: User, roles: Iterable[str]
) -> Set[uuid.UUID]:
    role_set = set(roles)
    ids: Set[uuid.UUID] = set()

    if ROLE_MANAGER in role_set and viewer.medical_center_id is not None:
        ids |= set(
            session.execute(
                select(PatientProfile.id).where(
                    PatientProfile.medical_center_id == viewer.medical_center_id,
                    PatientProfile.deleted_at.is_(None),
                )
            )
            .scalars()
            .all()
        )

    if role_set & CLINICAL_ROLES:
        ids |= set(
            session.execute(
                select(PatientAssignment.patient_profile_id).where(
                    PatientAssignment.clinician_user_id == viewer.id,
                    PatientAssignment.active.is_(True),
                )
            )
            .scalars()
            .all()
        )

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


def list_profiles(
    session: Session,
    viewer: User,
    roles: Iterable[str],
    limit: int,
    offset: int,
) -> Tuple[List[PatientProfile], int]:
    role_set = set(roles)

    if ROLE_ADMIN in role_set:
        total = session.execute(
            select(func.count())
            .select_from(PatientProfile)
            .where(PatientProfile.deleted_at.is_(None))
        ).scalar_one()
        rows = (
            session.execute(
                select(PatientProfile)
                .where(PatientProfile.deleted_at.is_(None))
                .order_by(PatientProfile.created_at)
                .limit(limit)
                .offset(offset)
            )
            .scalars()
            .all()
        )
        return list(rows), int(total)

    ids = _visible_profile_ids(session, viewer, role_set)
    if not ids:
        return [], 0
    rows = (
        session.execute(
            select(PatientProfile)
            .where(PatientProfile.id.in_(ids), PatientProfile.deleted_at.is_(None))
            .order_by(PatientProfile.created_at)
            .limit(limit)
            .offset(offset)
        )
        .scalars()
        .all()
    )
    return list(rows), len(ids)


def visible_patient_profile_ids(
    session: Session, viewer: User, roles: Iterable[str]
) -> Optional[Set[uuid.UUID]]:
    """Profile ids the viewer may access, or None for admin (meaning "all").

    Reused by other modules (e.g. games) so patient-visibility rules live in one
    place.
    """
    if ROLE_ADMIN in set(roles):
        return None
    return _visible_profile_ids(session, viewer, roles)


# --- mutations ---------------------------------------------------------------


def create_patient_profile(
    session: Session,
    *,
    user_id: uuid.UUID,
    medical_center_id: Optional[uuid.UUID] = None,
    date_of_birth: Optional[date] = None,
    gender: Optional[str] = None,
    emergency_contact_name: Optional[str] = None,
    emergency_contact_phone: Optional[str] = None,
    notes: Optional[str] = None,
    actor_user_id: Optional[uuid.UUID] = None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> PatientProfile:
    user = _get_active_user(session, user_id)
    if user is None:
        raise UserNotFoundError()
    if not _user_has_role(session, user_id, ROLE_PATIENT):
        raise NotPatientRoleError()
    existing = session.execute(
        select(PatientProfile.id).where(
            PatientProfile.user_id == user_id, PatientProfile.deleted_at.is_(None)
        )
    ).first()
    if existing is not None:
        raise DuplicateProfileError()

    profile = PatientProfile(
        user_id=user_id,
        medical_center_id=medical_center_id,
        date_of_birth=date_of_birth,
        gender=gender,
        emergency_contact_name=emergency_contact_name,
        emergency_contact_phone=emergency_contact_phone,
        notes=notes,
    )
    session.add(profile)
    session.flush()
    record_audit(
        session,
        action="create_patient_profile",
        entity_type="PatientProfile",
        actor_user_id=actor_user_id,
        entity_id=profile.id,
        ip_address=ip_address,
        device_info=device_info,
        commit=False,
    )
    session.commit()
    return profile


_UPDATABLE_FIELDS = (
    "medical_center_id",
    "date_of_birth",
    "gender",
    "emergency_contact_name",
    "emergency_contact_phone",
    "notes",
)


def update_patient_profile(
    session: Session,
    *,
    profile: PatientProfile,
    fields: dict,
    actor_user_id: Optional[uuid.UUID] = None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> PatientProfile:
    for key in _UPDATABLE_FIELDS:
        if key in fields:
            setattr(profile, key, fields[key])
    session.add(profile)
    record_audit(
        session,
        action="update_patient_profile",
        entity_type="PatientProfile",
        actor_user_id=actor_user_id,
        entity_id=profile.id,
        ip_address=ip_address,
        device_info=device_info,
        commit=False,
    )
    session.commit()
    return profile


def assign_clinician(
    session: Session,
    *,
    profile: PatientProfile,
    clinician_user_id: uuid.UUID,
    assignment_type: str,
    actor_user_id: Optional[uuid.UUID] = None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> PatientAssignment:
    clinician = _get_active_user(session, clinician_user_id)
    if clinician is None:
        raise UserNotFoundError()
    # assignment_type is "doctor" or "therapist"; the clinician must hold it.
    if not _user_has_role(session, clinician_user_id, assignment_type):
        raise WrongClinicianRoleError()

    existing = session.execute(
        select(PatientAssignment).where(
            PatientAssignment.patient_profile_id == profile.id,
            PatientAssignment.clinician_user_id == clinician_user_id,
            PatientAssignment.assignment_type == assignment_type,
        )
    ).scalar_one_or_none()

    if existing is not None:
        assignment = existing
        if not assignment.active:
            assignment.active = True
            session.add(assignment)
    else:
        assignment = PatientAssignment(
            patient_profile_id=profile.id,
            clinician_user_id=clinician_user_id,
            assignment_type=assignment_type,
            active=True,
        )
        session.add(assignment)
        session.flush()

    record_audit(
        session,
        action="assign_clinician",
        entity_type="PatientAssignment",
        actor_user_id=actor_user_id,
        entity_id=assignment.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={
            "patient_profile_id": str(profile.id),
            "clinician_user_id": str(clinician_user_id),
            "assignment_type": assignment_type,
        },
        commit=False,
    )
    session.commit()
    return assignment


def link_family(
    session: Session,
    *,
    profile: PatientProfile,
    family_user_id: uuid.UUID,
    relationship: Optional[str] = None,
    actor_user_id: Optional[uuid.UUID] = None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> PatientFamilyLink:
    family = _get_active_user(session, family_user_id)
    if family is None:
        raise UserNotFoundError()
    if not _user_has_role(session, family_user_id, ROLE_FAMILY):
        raise WrongFamilyRoleError()

    existing = session.execute(
        select(PatientFamilyLink).where(
            PatientFamilyLink.patient_profile_id == profile.id,
            PatientFamilyLink.family_user_id == family_user_id,
        )
    ).scalar_one_or_none()

    if existing is not None:
        link = existing
        link.active = True
        if relationship is not None:
            link.relationship = relationship
        session.add(link)
    else:
        link = PatientFamilyLink(
            patient_profile_id=profile.id,
            family_user_id=family_user_id,
            relationship=relationship,
            active=True,
        )
        session.add(link)
        session.flush()

    record_audit(
        session,
        action="link_family",
        entity_type="PatientFamilyLink",
        actor_user_id=actor_user_id,
        entity_id=link.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={
            "patient_profile_id": str(profile.id),
            "family_user_id": str(family_user_id),
        },
        commit=False,
    )
    session.commit()
    return link


def deactivate_assignment(
    session: Session,
    *,
    profile: PatientProfile,
    assignment_id: uuid.UUID,
    actor_user_id: Optional[uuid.UUID] = None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> PatientAssignment:
    assignment = session.get(PatientAssignment, assignment_id)
    if assignment is None or assignment.patient_profile_id != profile.id:
        raise RelationshipNotFoundError()
    assignment.active = False
    session.add(assignment)
    record_audit(
        session,
        action="deactivate_assignment",
        entity_type="PatientAssignment",
        actor_user_id=actor_user_id,
        entity_id=assignment.id,
        ip_address=ip_address,
        device_info=device_info,
        commit=False,
    )
    session.commit()
    return assignment


def deactivate_family_link(
    session: Session,
    *,
    profile: PatientProfile,
    link_id: uuid.UUID,
    actor_user_id: Optional[uuid.UUID] = None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> PatientFamilyLink:
    link = session.get(PatientFamilyLink, link_id)
    if link is None or link.patient_profile_id != profile.id:
        raise RelationshipNotFoundError()
    link.active = False
    session.add(link)
    record_audit(
        session,
        action="deactivate_family_link",
        entity_type="PatientFamilyLink",
        actor_user_id=actor_user_id,
        entity_id=link.id,
        ip_address=ip_address,
        device_info=device_info,
        commit=False,
    )
    session.commit()
    return link
