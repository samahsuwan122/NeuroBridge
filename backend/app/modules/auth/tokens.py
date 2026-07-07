"""JWT access/refresh token creation and decoding (PyJWT).

Secret, algorithm, and expiry are read from application settings (JWT_* env
vars). Tokens are never logged.
"""

from datetime import datetime, timedelta, timezone
from typing import Iterable, Optional

import jwt

from app.core.config import get_settings

ACCESS_TOKEN_TYPE = "access"
REFRESH_TOKEN_TYPE = "refresh"


def _create_token(
    subject: str,
    token_type: str,
    expires_delta: timedelta,
    extra_claims: Optional[dict] = None,
) -> str:
    settings = get_settings()
    now = datetime.now(timezone.utc)
    payload = {
        "sub": subject,
        "type": token_type,
        "iat": int(now.timestamp()),
        "exp": int((now + expires_delta).timestamp()),
    }
    if extra_claims:
        payload.update(extra_claims)
    return jwt.encode(payload, settings.jwt_secret_key, algorithm=settings.jwt_algorithm)


def create_access_token(
    subject: str,
    roles: Optional[Iterable[str]] = None,
    expires_delta: Optional[timedelta] = None,
) -> str:
    """Create a short-lived access token for the given subject (user id)."""
    settings = get_settings()
    if expires_delta is None:
        expires_delta = timedelta(minutes=settings.jwt_access_token_expire_minutes)
    return _create_token(
        subject,
        ACCESS_TOKEN_TYPE,
        expires_delta,
        {"roles": list(roles or [])},
    )


def create_refresh_token(
    subject: str,
    expires_delta: Optional[timedelta] = None,
) -> str:
    """Create a longer-lived refresh token for the given subject (user id)."""
    settings = get_settings()
    if expires_delta is None:
        expires_delta = timedelta(days=settings.jwt_refresh_token_expire_days)
    return _create_token(subject, REFRESH_TOKEN_TYPE, expires_delta)


def decode_token(token: str) -> dict:
    """Decode and verify a token. Raises jwt.PyJWTError on invalid/expired."""
    settings = get_settings()
    return jwt.decode(
        token,
        settings.jwt_secret_key,
        algorithms=[settings.jwt_algorithm],
    )
