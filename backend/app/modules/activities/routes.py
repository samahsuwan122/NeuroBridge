"""Care-team assigned-activity routes.

- POST   /api/v1/activities/assign            (doctor/therapist -> assigned patient)
- GET    /api/v1/activities/templates         (any authenticated user)
- GET    /api/v1/activities/my                (patient: own activities)
- GET    /api/v1/activities/patient/{id}      (role-scoped to the patient profile)
- PATCH  /api/v1/activities/{id}/complete     (patient owner / assigned clinician / admin)

Activities are cognitive exercises only — no diagnosis, treatment, prediction,
or scoring of any condition.
"""

import uuid
from contextlib import contextmanager

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session

from app.core.permissions import ROLE_DOCTOR, ROLE_PATIENT, ROLE_THERAPIST
from app.db.session import get_db
from app.models import AssignedActivity, User
from app.modules.activities import service, templates
from app.modules.activities.schemas import (
    ActivityAssignRequest,
    ActivityCompleteRequest,
    ActivityTemplateInfo,
    ActivityTemplateListResponse,
    AssignedActivityListResponse,
    AssignedActivityResponse,
)
from app.modules.auth.dependencies import get_current_active_user, require_roles
from app.modules.auth.service import get_role_names

router = APIRouter(prefix="/api/v1/activities", tags=["activities"])

clinician_required = require_roles([ROLE_DOCTOR, ROLE_THERAPIST])
patient_required = require_roles([ROLE_PATIENT])


@contextmanager
def _translate_activity_errors():
    try:
        yield
    except service.TemplateNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unknown activity template.",
        )
    except service.InvalidDifficultyError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Unsupported difficulty.",
        )
    except service.InvalidStatusError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Status must be 'completed' or 'skipped'.",
        )
    except service.ProfileNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found.",
        )
    except service.NotAllowedError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have access to this patient's activities.",
        )


def _client_info(request: Request) -> tuple[str | None, str | None]:
    ip_address = request.client.host if request.client else None
    device_info = request.headers.get("user-agent")
    return ip_address, device_info


def _response(activity: AssignedActivity) -> AssignedActivityResponse:
    return AssignedActivityResponse.model_validate(activity)


@router.get("/templates", response_model=ActivityTemplateListResponse)
def list_templates(
    _current_user: User = Depends(get_current_active_user),
) -> ActivityTemplateListResponse:
    infos = [
        ActivityTemplateInfo(
            template_type=t,
            label=templates.TEMPLATE_DEFAULTS[t]["label"],
            default_title=templates.default_title(t),
            default_instructions=templates.default_instructions(t),
            game_slug=templates.game_slug(t),
            playable=bool(templates.game_slug(t)),
        )
        for t in templates.TEMPLATE_TYPES
    ]
    return ActivityTemplateListResponse(
        difficulties=templates.DIFFICULTIES, templates=infos
    )


@router.post(
    "/assign",
    response_model=AssignedActivityResponse,
    status_code=status.HTTP_201_CREATED,
)
def assign_activity(
    payload: ActivityAssignRequest,
    request: Request,
    clinician: User = Depends(clinician_required),
    db: Session = Depends(get_db),
) -> AssignedActivityResponse:
    roles = get_role_names(db, clinician.id)
    ip_address, device_info = _client_info(request)
    with _translate_activity_errors():
        activity = service.assign_activity(
            db,
            assigner=clinician,
            roles=roles,
            patient_profile_id=payload.patient_profile_id,
            template_type=payload.template_type,
            difficulty=payload.difficulty,
            duration_minutes=payload.duration_minutes,
            title=payload.title,
            instructions=payload.instructions,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _response(activity)


@router.get("/my", response_model=AssignedActivityListResponse)
def list_my_activities(
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(patient_required),
    db: Session = Depends(get_db),
) -> AssignedActivityListResponse:
    activities, total = service.list_my(
        db, current_user, limit=limit, offset=offset
    )
    return AssignedActivityListResponse(
        total=total, activities=[_response(a) for a in activities]
    )


@router.get(
    "/patient/{patient_profile_id}", response_model=AssignedActivityListResponse
)
def list_patient_activities(
    patient_profile_id: uuid.UUID,
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> AssignedActivityListResponse:
    roles = get_role_names(db, current_user.id)
    with _translate_activity_errors():
        activities, total = service.list_for_patient(
            db,
            current_user,
            roles,
            patient_profile_id=patient_profile_id,
            limit=limit,
            offset=offset,
        )
    return AssignedActivityListResponse(
        total=total, activities=[_response(a) for a in activities]
    )


@router.patch("/{activity_id}/complete", response_model=AssignedActivityResponse)
def complete_activity(
    activity_id: uuid.UUID,
    request: Request,
    payload: ActivityCompleteRequest | None = None,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> AssignedActivityResponse:
    activity = service.get_activity(db, activity_id)
    if activity is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Activity not found."
        )
    roles = get_role_names(db, current_user.id)
    ip_address, device_info = _client_info(request)
    new_status = (payload.status if payload else "completed") or "completed"
    with _translate_activity_errors():
        activity = service.set_activity_status(
            db,
            actor=current_user,
            roles=roles,
            activity=activity,
            new_status=new_status,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _response(activity)
