"""Patient-goals routes.

- POST   /api/v1/goals                       (doctor/therapist/admin -> assigned patient)
- GET    /api/v1/goals/patient/{id}          (role-scoped to the patient profile)
- PATCH  /api/v1/goals/{id}                  (doctor/therapist/admin)

Goals are performance-based follow-up targets for care-team review only — no
diagnosis, treatment, prediction, or scoring of any condition.
"""

import uuid
from contextlib import contextmanager

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session

from app.core.permissions import ROLE_ADMIN, ROLE_DOCTOR, ROLE_THERAPIST
from app.db.session import get_db
from app.models import Goal, User
from app.modules.auth.dependencies import get_current_active_user, require_roles
from app.modules.auth.service import get_role_names
from app.modules.goals import service
from app.modules.goals.schemas import (
    GoalCreate,
    GoalListResponse,
    GoalRead,
    GoalUpdate,
)

router = APIRouter(prefix="/api/v1/goals", tags=["goals"])

manage_required = require_roles([ROLE_DOCTOR, ROLE_THERAPIST, ROLE_ADMIN])


@contextmanager
def _translate_goal_errors():
    try:
        yield
    except service.ProfileNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found.",
        )
    except service.GoalNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Goal not found.",
        )
    except service.NotAllowedError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have access to this patient's goals.",
        )


def _client_info(request: Request) -> tuple[str | None, str | None]:
    ip_address = request.client.host if request.client else None
    device_info = request.headers.get("user-agent")
    return ip_address, device_info


def _response(goal: Goal) -> GoalRead:
    return GoalRead.model_validate(goal)


@router.post("", response_model=GoalRead, status_code=status.HTTP_201_CREATED)
def create_goal(
    payload: GoalCreate,
    request: Request,
    clinician: User = Depends(manage_required),
    db: Session = Depends(get_db),
) -> GoalRead:
    roles = get_role_names(db, clinician.id)
    ip_address, device_info = _client_info(request)
    with _translate_goal_errors():
        goal = service.create_goal(
            db,
            creator=clinician,
            roles=roles,
            patient_profile_id=payload.patient_profile_id,
            title=payload.title,
            description=payload.description,
            target_type=payload.target_type,
            target_value=payload.target_value,
            current_value=payload.current_value,
            due_date=payload.due_date,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _response(goal)


@router.get("/patient/{patient_profile_id}", response_model=GoalListResponse)
def list_patient_goals(
    patient_profile_id: uuid.UUID,
    limit: int = Query(default=100, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> GoalListResponse:
    roles = get_role_names(db, current_user.id)
    with _translate_goal_errors():
        goals, total = service.list_patient_goals(
            db,
            current_user,
            roles,
            patient_profile_id=patient_profile_id,
            limit=limit,
            offset=offset,
        )
    return GoalListResponse(total=total, goals=[_response(g) for g in goals])


@router.patch("/{goal_id}", response_model=GoalRead)
def update_goal(
    goal_id: uuid.UUID,
    payload: GoalUpdate,
    request: Request,
    clinician: User = Depends(manage_required),
    db: Session = Depends(get_db),
) -> GoalRead:
    goal = service.get_goal(db, goal_id)
    if goal is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Goal not found."
        )
    roles = get_role_names(db, clinician.id)
    ip_address, device_info = _client_info(request)
    fields = payload.model_dump(exclude_unset=True)
    with _translate_goal_errors():
        goal = service.update_goal(
            db,
            actor=clinician,
            roles=roles,
            goal=goal,
            fields=fields,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _response(goal)
