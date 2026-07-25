"""Authentication routes: login, current user, refresh, logout.

Security notes:
- Invalid login returns a single generic 401 (no distinction between unknown
  user, wrong password, or inactive account).
- Passwords and tokens are never logged.
- JWT logout is stateless: the client discards the token. No server-side token
  invalidation is claimed or implemented.
"""

import uuid

import jwt
from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models import User
from app.modules.audit.service import record_audit
from app.modules.auth import service
from app.modules.auth.dependencies import get_current_active_user, get_current_user
from app.modules.auth.schemas import (
    CurrentUserResponse,
    LoginRequest,
    LoginResponse,
    LogoutResponse,
    RefreshRequest,
    RefreshResponse,
    UserBasic,
)
from app.modules.auth.tokens import (
    REFRESH_TOKEN_TYPE,
    create_access_token,
    create_refresh_token,
    decode_token,
)

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])


def _invalid_credentials() -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid email/phone or password",
        headers={"WWW-Authenticate": "Bearer"},
    )


def _client_info(request: Request) -> tuple[str | None, str | None]:
    ip_address = request.client.host if request.client else None
    device_info = request.headers.get("user-agent")
    return ip_address, device_info


@router.post("/login", response_model=LoginResponse)
def login(
    payload: LoginRequest,
    request: Request,
    db: Session = Depends(get_db),
) -> LoginResponse:
    user = service.authenticate_user(db, payload.email_or_phone, payload.password)
    if user is None:
        raise _invalid_credentials()

    roles = service.get_role_names(db, user.id)
    access_token = create_access_token(str(user.id), roles=roles)
    refresh_token = create_refresh_token(str(user.id))

    # Update last login and write the login audit log in one transaction.
    service.touch_last_login(user)
    db.add(user)
    ip_address, device_info = _client_info(request)
    record_audit(
        db,
        action="login",
        entity_type="User",
        actor_user_id=user.id,
        entity_id=user.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={"method": "password"},
        commit=False,
    )
    db.commit()

    return LoginResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user=UserBasic.model_validate(user),
        roles=roles,
    )


@router.get("/me", response_model=CurrentUserResponse)
def read_current_user(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> CurrentUserResponse:
    roles = service.get_role_names(db, current_user.id)
    return CurrentUserResponse(user=UserBasic.model_validate(current_user), roles=roles)


@router.post("/refresh", response_model=RefreshResponse)
def refresh_access_token(
    payload: RefreshRequest,
    db: Session = Depends(get_db),
) -> RefreshResponse:
    """Issue a new access token from a valid refresh token (stateless)."""
    invalid = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token"
    )
    try:
        data = decode_token(payload.refresh_token)
    except jwt.PyJWTError:
        raise invalid

    if data.get("type") != REFRESH_TOKEN_TYPE:
        raise invalid

    subject = data.get("sub")
    if not subject:
        raise invalid
    try:
        user_id = uuid.UUID(str(subject))
    except ValueError:
        raise invalid

    user = db.get(User, user_id)
    if user is None or user.deleted_at is not None or user.status != "active":
        raise invalid

    roles = service.get_role_names(db, user.id)
    access_token = create_access_token(str(user.id), roles=roles)
    return RefreshResponse(access_token=access_token)


@router.post("/logout", response_model=LogoutResponse)
def logout(
    request: Request,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> LogoutResponse:
    """Record a logout audit entry. JWTs are stateless; the client must discard
    the access token. No server-side invalidation is performed."""
    ip_address, device_info = _client_info(request)
    record_audit(
        db,
        action="logout",
        entity_type="User",
        actor_user_id=current_user.id,
        entity_id=current_user.id,
        ip_address=ip_address,
        device_info=device_info,
    )
    return LogoutResponse(
        message=(
            "Logged out. Discard the access token on the client; JWTs are "
            "stateless and are not invalidated server-side."
        )
    )
