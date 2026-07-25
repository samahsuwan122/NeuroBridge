"""Auth business logic: user lookup, authentication, and role retrieval.

No HTTP concerns here — routes call these functions with a session.
"""

import uuid
from typing import List, Optional

from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app.core.security import verify_password
from app.db.mixins import utcnow
from app.models import Role, User, UserRole


def find_user_by_identifier(session: Session, identifier: str) -> Optional[User]:
    """Find an active (non-deleted) user by email or phone."""
    stmt = (
        select(User)
        .where(or_(User.email == identifier, User.phone == identifier))
        .where(User.deleted_at.is_(None))
    )
    return session.execute(stmt).scalars().first()


def get_role_names(session: Session, user_id: uuid.UUID) -> List[str]:
    """Return the role names assigned to a user."""
    stmt = (
        select(Role.name)
        .join(UserRole, UserRole.role_id == Role.id)
        .where(UserRole.user_id == user_id)
    )
    return list(session.execute(stmt).scalars().all())


def authenticate_user(
    session: Session, identifier: str, password: str
) -> Optional[User]:
    """Return the user if credentials are valid and the account is active.

    Returns None for any failure (unknown user, inactive account, missing hash,
    or wrong password) so callers can return a single generic error.
    """
    user = find_user_by_identifier(session, identifier)
    if user is None:
        return None
    if user.status != "active":
        return None
    if not user.password_hash:
        return None
    if not verify_password(password, user.password_hash):
        return None
    return user


def touch_last_login(user: User) -> None:
    """Update the user's last_login_at timestamp (caller commits)."""
    user.last_login_at = utcnow()
