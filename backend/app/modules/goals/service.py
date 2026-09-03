"""Patient-goals business logic and role-based access.

HTTP-free: routes translate the domain exceptions below into HTTP responses.
Patient-visibility rules are reused from the patients module so access control
lives in one place.

MEDICAL SAFETY: goals are performance-based follow-up targets for care-team
review only. Nothing here diagnoses, treats, predicts, or scores any condition.
"""

import uuid
from typing import Iterable, List, Optional, Tuple

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.permissions import CLINICAL_ROLES, ROLE_ADMIN
from app.models import Goal, PatientAssignment, PatientProfile, User
from app.modules.audit.service import record_audit
from app.modules.patients.service import can_view_profile, get_profile

# Fields an update may change on a goal.
_UPDATABLE_FIELDS = (
    "title",
    "description",
    "target_type",
    "target_value",
    "current_value",
    "status",
    "due_date",
)


# --- domain exceptions -------------------------------------------------------


class GoalError(Exception):
    """Base class for goals-service domain errors."""


class ProfileNotFoundError(GoalError):
    """The referenced patient profile does not exist."""


class GoalNotFoundError(GoalError):
    """The referenced goal does not exist."""


class NotAllowedError(GoalError):
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


def can_manage_goals(
    session: Session, user: User, roles: Iterable[str], profile: PatientProfile
) -> bool:
    """Who may create/update goals: admin, or a clinician assigned to the patient.

    Patients and family are never allowed to create or update goals (they may
    only view — see the visibility checks in the list endpoint).
    """
    role_set = set(roles)
    if ROLE_ADMIN in role_set:
        return True
    if role_set & CLINICAL_ROLES:
        return _is_assigned_clinician(session, user.id, profile.id)
    return False


# --- queries -----------------------------------------------------------------


def get_goal(session: Session, goal_id: uuid.UUID) -> Optional[Goal]:
    return session.get(Goal, goal_id)


def list_patient_goals(
    session: Session,
    viewer: User,
    roles: Iterable[str],
    *,
    patient_profile_id: uuid.UUID,
    limit: int = 100,
    offset: int = 0,
) -> Tuple[List[Goal], int]:
    profile = get_profile(session, patient_profile_id)
    if profile is None:
        raise ProfileNotFoundError()
    if not can_view_profile(session, viewer, roles, profile):
        raise NotAllowedError()

    total = session.execute(
        select(func.count())
        .select_from(Goal)
        .where(Goal.patient_profile_id == patient_profile_id)
    ).scalar_one()
    rows = (
        session.execute(
            select(Goal)
            .where(Goal.patient_profile_id == patient_profile_id)
            .order_by(Goal.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
        .scalars()
        .all()
    )
    return list(rows), int(total)


# --- mutations ---------------------------------------------------------------


def create_goal(
    session: Session,
    *,
    creator: User,
    roles: Iterable[str],
    patient_profile_id: uuid.UUID,
    title: str,
    target_type: str,
    target_value: int,
    current_value: int = 0,
    description: Optional[str] = None,
    due_date=None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> Goal:
    profile = get_profile(session, patient_profile_id)
    if profile is None:
        raise ProfileNotFoundError()
    if not can_manage_goals(session, creator, roles, profile):
        raise NotAllowedError()

    goal = Goal(
        patient_profile_id=patient_profile_id,
        created_by_user_id=creator.id,
        title=title.strip(),
        description=(description or None),
        target_type=target_type.strip(),
        target_value=target_value,
        current_value=current_value,
        due_date=due_date,
    )
    session.add(goal)
    session.flush()
    record_audit(
        session,
        action="create_goal",
        entity_type="Goal",
        actor_user_id=creator.id,
        entity_id=goal.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={"patient_profile_id": str(patient_profile_id)},
        commit=False,
    )
    session.commit()
    return goal


def update_goal(
    session: Session,
    *,
    actor: User,
    roles: Iterable[str],
    goal: Goal,
    fields: dict,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> Goal:
    profile = get_profile(session, goal.patient_profile_id)
    if profile is None:
        raise ProfileNotFoundError()
    if not can_manage_goals(session, actor, roles, profile):
        raise NotAllowedError()

    for key in _UPDATABLE_FIELDS:
        if key in fields:
            setattr(goal, key, fields[key])
    session.add(goal)
    record_audit(
        session,
        action="update_goal",
        entity_type="Goal",
        actor_user_id=actor.id,
        entity_id=goal.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={"status": goal.status},
        commit=False,
    )
    session.commit()
    return goal
