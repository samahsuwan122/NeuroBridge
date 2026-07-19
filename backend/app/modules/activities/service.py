"""Assigned-activity business logic and role-based access.

HTTP-free: routes translate the domain exceptions below into HTTP responses.
Patient-visibility rules are reused from the patients module so access control
lives in one place.

MEDICAL SAFETY: content is built only from fixed templates
(`app.modules.activities.templates`). Nothing here diagnoses, treats, predicts,
or scores any condition.
"""

import uuid
from datetime import datetime, timezone
from typing import Iterable, List, Optional, Tuple

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.permissions import CLINICAL_ROLES, ROLE_ADMIN, ROLE_PATIENT
from app.models import AssignedActivity, PatientAssignment, PatientProfile, User
from app.models.assigned_activity import (
    STATUS_ASSIGNED,
    STATUS_COMPLETED,
    STATUS_SKIPPED,
)
from app.modules.activities import templates
from app.modules.audit.service import record_audit
from app.modules.patients.service import can_view_profile, get_profile


# --- domain exceptions -------------------------------------------------------


class ActivityError(Exception):
    """Base class for activity-service domain errors."""


class TemplateNotFoundError(ActivityError):
    """The requested template type is not one of the safe predefined ones."""


class InvalidDifficultyError(ActivityError):
    """The requested difficulty is not supported."""


class InvalidStatusError(ActivityError):
    """The requested status transition is not allowed."""


class ProfileNotFoundError(ActivityError):
    """The referenced patient profile does not exist."""


class ActivityNotFoundError(ActivityError):
    """The referenced activity does not exist."""


class NotAllowedError(ActivityError):
    """The actor is not permitted to perform this action."""


# --- permission helpers ------------------------------------------------------


def _is_assigned_clinician(
    session: Session, user_id: uuid.UUID, profile_id: uuid.UUID
) -> bool:
    row = session.execute(
        select(PatientAssignment.id).where(
            PatientAssignment.patient_profile_id == profile_id,
            PatientAssignment.clinician_user_id == user_id,
            PatientAssignment.active.is_(True),
        )
    ).first()
    return row is not None


def can_assign_activity(
    session: Session, user: User, roles: Iterable[str], profile: PatientProfile
) -> bool:
    """Doctors/therapists may assign only to their assigned patients (admin: any)."""
    role_set = set(roles)
    if ROLE_ADMIN in role_set:
        return True
    if role_set & CLINICAL_ROLES:
        return _is_assigned_clinician(session, user.id, profile.id)
    return False


def _can_modify_activity(
    session: Session,
    actor: User,
    roles: Iterable[str],
    activity: AssignedActivity,
    profile: PatientProfile,
) -> bool:
    """Who may complete/skip: the owning patient, an assigned clinician, or admin.

    Family members are read-only (they can view but not change status).
    """
    role_set = set(roles)
    if ROLE_ADMIN in role_set:
        return True
    if ROLE_PATIENT in role_set and profile.user_id == actor.id:
        return True
    if role_set & CLINICAL_ROLES:
        return _is_assigned_clinician(session, actor.id, profile.id)
    return False


# --- queries -----------------------------------------------------------------


def get_activity(
    session: Session, activity_id: uuid.UUID
) -> Optional[AssignedActivity]:
    return session.get(AssignedActivity, activity_id)


def list_for_patient(
    session: Session,
    viewer: User,
    roles: Iterable[str],
    *,
    patient_profile_id: uuid.UUID,
    limit: int = 50,
    offset: int = 0,
) -> Tuple[List[AssignedActivity], int]:
    profile = get_profile(session, patient_profile_id)
    if profile is None:
        raise ProfileNotFoundError()
    if not can_view_profile(session, viewer, roles, profile):
        raise NotAllowedError()
    return _list_for_profile_ids(session, [patient_profile_id], limit, offset)


def list_my(
    session: Session,
    patient: User,
    *,
    limit: int = 50,
    offset: int = 0,
) -> Tuple[List[AssignedActivity], int]:
    """Activities assigned to the current patient's own profile(s)."""
    profile_ids = list(
        session.execute(
            select(PatientProfile.id).where(
                PatientProfile.user_id == patient.id,
                PatientProfile.deleted_at.is_(None),
            )
        )
        .scalars()
        .all()
    )
    if not profile_ids:
        return [], 0
    return _list_for_profile_ids(session, profile_ids, limit, offset)


def _list_for_profile_ids(
    session: Session,
    profile_ids: List[uuid.UUID],
    limit: int,
    offset: int,
) -> Tuple[List[AssignedActivity], int]:
    total = session.execute(
        select(func.count())
        .select_from(AssignedActivity)
        .where(AssignedActivity.patient_profile_id.in_(profile_ids))
    ).scalar_one()
    rows = (
        session.execute(
            select(AssignedActivity)
            .where(AssignedActivity.patient_profile_id.in_(profile_ids))
            .order_by(AssignedActivity.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
        .scalars()
        .all()
    )
    return list(rows), int(total)


# --- mutations ---------------------------------------------------------------


def assign_activity(
    session: Session,
    *,
    assigner: User,
    roles: Iterable[str],
    patient_profile_id: uuid.UUID,
    template_type: str,
    difficulty: str,
    duration_minutes: int,
    title: Optional[str] = None,
    instructions: Optional[str] = None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> AssignedActivity:
    if not templates.is_valid_template(template_type):
        raise TemplateNotFoundError()
    if not templates.is_valid_difficulty(difficulty):
        raise InvalidDifficultyError()

    profile = get_profile(session, patient_profile_id)
    if profile is None:
        raise ProfileNotFoundError()
    if not can_assign_activity(session, assigner, roles, profile):
        raise NotAllowedError()

    final_title = (title or "").strip() or templates.default_title(template_type)
    final_instructions = (
        instructions if instructions is not None else None
    )
    if not (final_instructions or "").strip():
        final_instructions = templates.default_instructions(template_type)

    content = templates.build_activity_content(template_type, difficulty)

    activity = AssignedActivity(
        patient_profile_id=patient_profile_id,
        assigned_by_user_id=assigner.id,
        template_type=template_type,
        title=final_title,
        instructions=final_instructions,
        difficulty=difficulty,
        duration_minutes=duration_minutes,
        status=STATUS_ASSIGNED,
        generated_content=content,
    )
    session.add(activity)
    session.flush()
    record_audit(
        session,
        action="assign_activity",
        entity_type="AssignedActivity",
        actor_user_id=assigner.id,
        entity_id=activity.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={
            "patient_profile_id": str(patient_profile_id),
            "template_type": template_type,
            "difficulty": difficulty,
        },
        commit=False,
    )
    session.commit()
    return activity


def set_activity_status(
    session: Session,
    *,
    actor: User,
    roles: Iterable[str],
    activity: AssignedActivity,
    new_status: str,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> AssignedActivity:
    if new_status not in (STATUS_COMPLETED, STATUS_SKIPPED):
        raise InvalidStatusError()

    profile = get_profile(session, activity.patient_profile_id)
    if profile is None:
        raise ProfileNotFoundError()
    if not _can_modify_activity(session, actor, roles, activity, profile):
        raise NotAllowedError()

    activity.status = new_status
    activity.completed_at = (
        datetime.now(timezone.utc) if new_status == STATUS_COMPLETED else None
    )
    session.add(activity)
    record_audit(
        session,
        action="update_activity_status",
        entity_type="AssignedActivity",
        actor_user_id=actor.id,
        entity_id=activity.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={"status": new_status},
        commit=False,
    )
    session.commit()
    return activity
