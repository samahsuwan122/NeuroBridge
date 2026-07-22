"""Access-request routes.

- POST   /api/v1/access-requests           PUBLIC — stores a pending request only
- GET    /api/v1/access-requests           admin  — list requests (optional status)
- PATCH  /api/v1/access-requests/{id}      admin  — update status / admin note

The public endpoint NEVER creates a user account or password. Admin review is
required before any real account is created.
"""

import uuid
from contextlib import contextmanager
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session

from app.core.permissions import ROLE_ADMIN
from app.db.session import get_db
from app.models import AccessRequest, User
from app.modules.access_requests import service
from app.modules.access_requests.schemas import (
    AccessRequestCreate,
    AccessRequestCreatedResponse,
    AccessRequestListResponse,
    AccessRequestResponse,
    AccessRequestUpdate,
)
from app.modules.auth.dependencies import require_roles

router = APIRouter(prefix="/api/v1/access-requests", tags=["access-requests"])

admin_required = require_roles([ROLE_ADMIN])


@contextmanager
def _translate_errors():
    try:
        yield
    except service.InvalidRoleError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Please choose a valid role (patient, family, doctor, therapist, or clinic).",
        )
    except service.InvalidStatusError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Status must be one of: pending, reviewed, accepted, declined.",
        )


def _client_info(request: Request) -> tuple[str | None, str | None]:
    ip_address = request.client.host if request.client else None
    device_info = request.headers.get("user-agent")
    return ip_address, device_info


def _response(req: AccessRequest) -> AccessRequestResponse:
    return AccessRequestResponse.model_validate(req)


@router.post(
    "",
    response_model=AccessRequestCreatedResponse,
    status_code=status.HTTP_201_CREATED,
)
def submit_access_request(
    payload: AccessRequestCreate,
    request: Request,
    db: Session = Depends(get_db),
) -> AccessRequestCreatedResponse:
    """PUBLIC: store a pending access request. No account is created."""
    ip_address, device_info = _client_info(request)
    with _translate_errors():
        created = service.create_access_request(
            db,
            full_name=payload.full_name,
            email=payload.email,
            requested_role=payload.requested_role,
            phone=payload.phone,
            organization=payload.organization,
            message=payload.message,
            ip_address=ip_address,
            device_info=device_info,
        )
    return AccessRequestCreatedResponse(
        message=(
            "Your request has been submitted successfully. The team will review "
            "it and contact you. No account is created until a request is approved."
        ),
        id=created.id,
    )


@router.get("", response_model=AccessRequestListResponse)
def list_access_requests(
    status_filter: Optional[str] = Query(default=None, alias="status"),
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    _admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> AccessRequestListResponse:
    requests, total = service.list_access_requests(
        db, status=status_filter, limit=limit, offset=offset
    )
    return AccessRequestListResponse(
        total=total, requests=[_response(r) for r in requests]
    )


@router.patch("/{request_id}", response_model=AccessRequestResponse)
def update_access_request(
    request_id: uuid.UUID,
    payload: AccessRequestUpdate,
    request: Request,
    admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> AccessRequestResponse:
    req = service.get_access_request(db, request_id)
    if req is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Access request not found."
        )
    ip_address, device_info = _client_info(request)
    with _translate_errors():
        req = service.update_access_request(
            db,
            request=req,
            status=payload.status,
            admin_note=payload.admin_note,
            actor_user_id=admin.id,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _response(req)
