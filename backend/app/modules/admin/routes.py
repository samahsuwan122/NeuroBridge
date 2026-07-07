"""Admin user-management routes (admin role required for every endpoint).

Security: unauthenticated -> 401, non-admin -> 403 (via require_roles). User
responses never include password_hash; passwords/tokens are never logged.
"""

import uuid
from contextlib import contextmanager
from typing import List

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session

from app.core.permissions import ROLE_ADMIN
from app.db.session import get_db
from app.models import User
from app.modules.admin import service
from app.modules.admin.schemas import (
    AdminUserCreate,
    AdminUserListResponse,
    AdminUserResponse,
    AdminUserUpdate,
    MessageResponse,
    RoleResponse,
)
from app.modules.auth.dependencies import require_roles
from app.modules.auth.service import get_role_names

router = APIRouter(prefix="/api/v1/admin", tags=["admin"])

# Every route in this module requires an authenticated, active admin.
admin_required = require_roles([ROLE_ADMIN])


@contextmanager
def _translate_admin_errors():
    """Map admin domain errors to HTTP responses."""
    try:
        yield
    except service.MissingIdentifierError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user must have at least an email or a phone.",
        )
    except service.DuplicateEmailError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A user with this email already exists.",
        )
    except service.DuplicatePhoneError:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A user with this phone already exists.",
        )
    except service.UnknownRoleError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unknown role(s): {', '.join(exc.names)}",
        )


def _client_info(request: Request) -> tuple[str | None, str | None]:
    ip_address = request.client.host if request.client else None
    device_info = request.headers.get("user-agent")
    return ip_address, device_info


def _user_response(db: Session, user: User) -> AdminUserResponse:
    return AdminUserResponse(
        id=user.id,
        full_name=user.full_name,
        email=user.email,
        phone=user.phone,
        preferred_language=user.preferred_language,
        status=user.status,
        medical_center_id=user.medical_center_id,
        roles=get_role_names(db, user.id),
        created_at=user.created_at,
        updated_at=user.updated_at,
    )


def _require_user(db: Session, user_id: uuid.UUID) -> User:
    user = service.get_user(db, user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="User not found"
        )
    return user


@router.get("/users", response_model=AdminUserListResponse)
def list_users(
    limit: int = Query(default=50, ge=1, le=200),
    offset: int = Query(default=0, ge=0),
    _admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> AdminUserListResponse:
    users, total = service.list_users(db, limit=limit, offset=offset)
    return AdminUserListResponse(
        total=total,
        limit=limit,
        offset=offset,
        users=[_user_response(db, u) for u in users],
    )


@router.post(
    "/users", response_model=AdminUserResponse, status_code=status.HTTP_201_CREATED
)
def create_user(
    payload: AdminUserCreate,
    request: Request,
    admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> AdminUserResponse:
    ip_address, device_info = _client_info(request)
    with _translate_admin_errors():
        user = service.create_user(
            db,
            full_name=payload.full_name,
            password=payload.password,
            email=payload.email,
            phone=payload.phone,
            preferred_language=payload.preferred_language,
            status=payload.status,
            medical_center_id=payload.medical_center_id,
            role_names=payload.roles,
            actor_user_id=admin.id,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _user_response(db, user)


@router.put("/users/{user_id}", response_model=AdminUserResponse)
def update_user(
    user_id: uuid.UUID,
    payload: AdminUserUpdate,
    request: Request,
    admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> AdminUserResponse:
    user = _require_user(db, user_id)
    fields = payload.model_dump(exclude_unset=True)
    ip_address, device_info = _client_info(request)
    with _translate_admin_errors():
        user = service.update_user(
            db,
            user=user,
            fields=fields,
            actor_user_id=admin.id,
            ip_address=ip_address,
            device_info=device_info,
        )
    return _user_response(db, user)


@router.post("/users/{user_id}/deactivate", response_model=MessageResponse)
def deactivate_user(
    user_id: uuid.UUID,
    request: Request,
    admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> MessageResponse:
    user = _require_user(db, user_id)
    ip_address, device_info = _client_info(request)
    service.set_status(
        db,
        user=user,
        status=service.INACTIVE_STATUS,
        action="deactivate_user",
        actor_user_id=admin.id,
        ip_address=ip_address,
        device_info=device_info,
    )
    return MessageResponse(message="User deactivated.")


@router.post("/users/{user_id}/activate", response_model=MessageResponse)
def activate_user(
    user_id: uuid.UUID,
    request: Request,
    admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> MessageResponse:
    user = _require_user(db, user_id)
    ip_address, device_info = _client_info(request)
    service.set_status(
        db,
        user=user,
        status=service.ACTIVE_STATUS,
        action="activate_user",
        actor_user_id=admin.id,
        ip_address=ip_address,
        device_info=device_info,
    )
    return MessageResponse(message="User activated.")


@router.get("/roles", response_model=List[RoleResponse])
def list_roles(
    _admin: User = Depends(admin_required),
    db: Session = Depends(get_db),
) -> List[RoleResponse]:
    return [RoleResponse.model_validate(role) for role in service.list_roles(db)]
