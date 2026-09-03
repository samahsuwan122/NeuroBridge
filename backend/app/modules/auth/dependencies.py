"""Reusable FastAPI authentication and role-guard dependencies.

- get_current_user: validates the Bearer access token and loads the user.
- get_current_active_user: additionally requires an active account.
- require_roles([...]): factory returning a guard that requires one of the
  given roles (checked against the database, which is authoritative).
"""

import uuid
from typing import List

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.permissions import has_any_role
from app.db.session import get_db
from app.models import User
from app.modules.auth.service import get_role_names
from app.modules.auth.tokens import ACCESS_TOKEN_TYPE, decode_token

# auto_error=False so we can return 401 (not 403) for a missing token.
bearer_scheme = HTTPBearer(auto_error=False)


def _credentials_exception() -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Not authenticated",
        headers={"WWW-Authenticate": "Bearer"},
    )


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: Session = Depends(get_db),
) -> User:
    """Validate the access token and return the corresponding user."""
    if credentials is None or not credentials.credentials:
        raise _credentials_exception()

    try:
        payload = decode_token(credentials.credentials)
    except jwt.PyJWTError:
        raise _credentials_exception()

    if payload.get("type") != ACCESS_TOKEN_TYPE:
        raise _credentials_exception()

    subject = payload.get("sub")
    if not subject:
        raise _credentials_exception()
    try:
        user_id = uuid.UUID(str(subject))
    except ValueError:
        raise _credentials_exception()

    user = db.get(User, user_id)
    if user is None or user.deleted_at is not None:
        raise _credentials_exception()
    return user


def get_current_active_user(
    current_user: User = Depends(get_current_user),
) -> User:
    """Require the authenticated user to have an active account."""
    if current_user.status != "active":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Inactive user"
        )
    return current_user


def require_roles(required_roles: List[str]):
    """Return a dependency that requires the user to hold one of the roles."""

    def dependency(
        current_user: User = Depends(get_current_active_user),
        db: Session = Depends(get_db),
    ) -> User:
        role_names = get_role_names(db, current_user.id)
        if not has_any_role(role_names, required_roles):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient role",
            )
        return current_user

    return dependency
