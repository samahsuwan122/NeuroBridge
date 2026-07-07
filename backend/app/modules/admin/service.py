"""Admin user-management business logic.

HTTP-free: routes call these with a session and translate the domain exceptions
below into HTTP responses. Passwords are hashed with bcrypt; only the hash is
stored. Sensitive actions write audit logs (committed in the same transaction).
"""

import uuid
from typing import Iterable, List, Optional, Sequence, Tuple

from sqlalchemy import delete, func, select
from sqlalchemy.orm import Session

from app.core.security import hash_password
from app.models import Role, User, UserRole
from app.modules.audit.service import record_audit

ACTIVE_STATUS = "active"
INACTIVE_STATUS = "inactive"


# --- domain exceptions -------------------------------------------------------


class AdminError(Exception):
    """Base class for admin-service domain errors."""


class MissingIdentifierError(AdminError):
    """A user must have at least an email or a phone."""


class DuplicateEmailError(AdminError):
    """Another user already uses this email."""


class DuplicatePhoneError(AdminError):
    """Another user already uses this phone."""


class UnknownRoleError(AdminError):
    """One or more requested role names do not exist."""

    def __init__(self, names: Sequence[str]):
        self.names = list(names)
        super().__init__(f"Unknown role(s): {', '.join(self.names)}")


# --- helpers -----------------------------------------------------------------


def _email_exists(
    session: Session, email: Optional[str], exclude_user_id: Optional[uuid.UUID] = None
) -> bool:
    if not email:
        return False
    stmt = select(User.id).where(User.email == email, User.deleted_at.is_(None))
    if exclude_user_id is not None:
        stmt = stmt.where(User.id != exclude_user_id)
    return session.execute(stmt).first() is not None


def _phone_exists(
    session: Session, phone: Optional[str], exclude_user_id: Optional[uuid.UUID] = None
) -> bool:
    if not phone:
        return False
    stmt = select(User.id).where(User.phone == phone, User.deleted_at.is_(None))
    if exclude_user_id is not None:
        stmt = stmt.where(User.id != exclude_user_id)
    return session.execute(stmt).first() is not None


def _resolve_roles(session: Session, role_names: Iterable[str]) -> List[Role]:
    # De-duplicate while preserving order.
    names = list(dict.fromkeys(role_names))
    if not names:
        return []
    rows = session.execute(select(Role).where(Role.name.in_(names))).scalars().all()
    found = {r.name for r in rows}
    missing = [n for n in names if n not in found]
    if missing:
        raise UnknownRoleError(missing)
    return list(rows)


def _assign_roles(session: Session, user: User, roles: Sequence[Role]) -> None:
    for role in roles:
        session.add(UserRole(user_id=user.id, role_id=role.id))


# --- queries -----------------------------------------------------------------


def list_users(session: Session, limit: int, offset: int) -> Tuple[List[User], int]:
    total = session.execute(
        select(func.count()).select_from(User).where(User.deleted_at.is_(None))
    ).scalar_one()
    users = (
        session.execute(
            select(User)
            .where(User.deleted_at.is_(None))
            .order_by(User.created_at)
            .limit(limit)
            .offset(offset)
        )
        .scalars()
        .all()
    )
    return list(users), int(total)


def get_user(session: Session, user_id: uuid.UUID) -> Optional[User]:
    user = session.get(User, user_id)
    if user is None or user.deleted_at is not None:
        return None
    return user


def list_roles(session: Session) -> List[Role]:
    return list(session.execute(select(Role).order_by(Role.name)).scalars().all())


# --- mutations ---------------------------------------------------------------


def create_user(
    session: Session,
    *,
    full_name: str,
    password: str,
    email: Optional[str] = None,
    phone: Optional[str] = None,
    preferred_language: str = "en",
    status: str = ACTIVE_STATUS,
    medical_center_id: Optional[uuid.UUID] = None,
    role_names: Iterable[str] = (),
    actor_user_id: Optional[uuid.UUID] = None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> User:
    if not email and not phone:
        raise MissingIdentifierError()
    if _email_exists(session, email):
        raise DuplicateEmailError()
    if _phone_exists(session, phone):
        raise DuplicatePhoneError()
    roles = _resolve_roles(session, role_names)

    user = User(
        full_name=full_name,
        email=email,
        phone=phone,
        password_hash=hash_password(password),
        preferred_language=preferred_language,
        status=status,
        medical_center_id=medical_center_id,
    )
    session.add(user)
    session.flush()
    _assign_roles(session, user, roles)

    record_audit(
        session,
        action="create_user",
        entity_type="User",
        actor_user_id=actor_user_id,
        entity_id=user.id,
        ip_address=ip_address,
        device_info=device_info,
        commit=False,
    )
    session.commit()
    return user


def update_user(
    session: Session,
    *,
    user: User,
    fields: dict,
    actor_user_id: Optional[uuid.UUID] = None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> User:
    """Apply only the provided fields (from schema `model_dump(exclude_unset=True)`)."""
    if "email" in fields:
        new_email = fields["email"]
        if new_email and _email_exists(session, new_email, exclude_user_id=user.id):
            raise DuplicateEmailError()
        user.email = new_email
    if "phone" in fields:
        new_phone = fields["phone"]
        if new_phone and _phone_exists(session, new_phone, exclude_user_id=user.id):
            raise DuplicatePhoneError()
        user.phone = new_phone
    if "full_name" in fields:
        user.full_name = fields["full_name"]
    if "preferred_language" in fields:
        user.preferred_language = fields["preferred_language"]
    if "status" in fields:
        user.status = fields["status"]
    if "medical_center_id" in fields:
        user.medical_center_id = fields["medical_center_id"]
    if fields.get("password"):
        user.password_hash = hash_password(fields["password"])
    if "roles" in fields:
        roles = _resolve_roles(session, fields["roles"] or [])
        session.execute(delete(UserRole).where(UserRole.user_id == user.id))
        session.flush()
        _assign_roles(session, user, roles)

    if not user.email and not user.phone:
        raise MissingIdentifierError()

    session.add(user)
    record_audit(
        session,
        action="update_user",
        entity_type="User",
        actor_user_id=actor_user_id,
        entity_id=user.id,
        ip_address=ip_address,
        device_info=device_info,
        commit=False,
    )
    session.commit()
    return user


def set_status(
    session: Session,
    *,
    user: User,
    status: str,
    action: str,
    actor_user_id: Optional[uuid.UUID] = None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> User:
    user.status = status
    session.add(user)
    record_audit(
        session,
        action=action,
        entity_type="User",
        actor_user_id=actor_user_id,
        entity_id=user.id,
        ip_address=ip_address,
        device_info=device_info,
        commit=False,
    )
    session.commit()
    return user
