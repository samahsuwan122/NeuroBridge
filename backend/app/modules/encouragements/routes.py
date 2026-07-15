"""Family encouragement routes.

- Listing: any authenticated active user, scoped by role (admin=all,
  doctor/therapist=assigned, patient=own, family=linked, manager=same center).
- Creating: a linked family member or an admin only.

MEDICAL SAFETY: family support content only — supportive messages, never medical
advice, diagnosis, or assessment.
"""

import uuid
from contextlib import contextmanager
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models import User
from app.modules.auth.dependencies import get_current_active_user
from app.modules.auth.service import get_role_names
from app.modules.encouragements import service
from app.modules.encouragements.schemas import (
    EncouragementCreate,
    EncouragementListResponse,
    EncouragementResponse,
)

router = APIRouter(prefix="/api/v1/encouragements", tags=["encouragements"])


@contextmanager
def _translate_errors():
    try:
        yield
    except service.ProfileNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Patient profile not found.",
        )
    except service.NotAllowedError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not allowed to perform this action.",
        )


def _client_info(request: Request) -> tuple[str | None, str | None]:
    ip_address = request.client.host if request.client else None
    device_info = request.headers.get("user-agent")
    return ip_address, device_info


@router.get("", response_model=EncouragementListResponse)
def list_encouragements(
    patient_profile_id: Optional[uuid.UUID] = Query(default=None),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> EncouragementListResponse:
    roles = get_role_names(db, current_user.id)
    items, total = service.list_encouragements(
        db,
        current_user,
        roles,
        patient_profile_id=patient_profile_id,
        limit=limit,
        offset=offset,
    )
    return EncouragementListResponse(
        total=total,
        limit=limit,
        offset=offset,
        encouragements=[EncouragementResponse.model_validate(i) for i in items],
    )


@router.post(
    "",
    response_model=EncouragementResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_encouragement(
    payload: EncouragementCreate,
    request: Request,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> EncouragementResponse:
    roles = get_role_names(db, current_user.id)
    ip_address, device_info = _client_info(request)
    with _translate_errors():
        encouragement = service.create_encouragement(
            db,
            sender=current_user,
            roles=roles,
            patient_profile_id=payload.patient_profile_id,
            message=payload.message,
            ip_address=ip_address,
            device_info=device_info,
        )
    return EncouragementResponse.model_validate(encouragement)
