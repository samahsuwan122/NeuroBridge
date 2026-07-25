"""Access-request business logic.

HTTP-free: routes translate the domain exceptions below into HTTP responses.

MEDICAL SAFETY: this stores an intake/contact record only. It never creates a
user account, password, or medical record, and never performs any medical
decision-making. Admin review is required before any account is created.
"""

import uuid
from typing import Iterable, List, Optional, Tuple

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models import AccessRequest
from app.models.access_request import ALLOWED_ROLES, ALLOWED_STATUSES, STATUS_PENDING
from app.modules.audit.service import record_audit


class AccessRequestError(Exception):
    """Base class for access-request domain errors."""


class InvalidRoleError(AccessRequestError):
    """The requested role is not one of the allowed public roles."""


class InvalidStatusError(AccessRequestError):
    """The status is not one of the allowed review statuses."""


class NotFoundError(AccessRequestError):
    """The referenced access request does not exist."""


def create_access_request(
    session: Session,
    *,
    full_name: str,
    email: str,
    requested_role: str,
    phone: Optional[str] = None,
    organization: Optional[str] = None,
    message: Optional[str] = None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> AccessRequest:
    role = (requested_role or "").strip().lower()
    if role not in ALLOWED_ROLES:
        raise InvalidRoleError()

    request = AccessRequest(
        full_name=full_name.strip(),
        email=email.strip(),
        phone=(phone or "").strip() or None,
        requested_role=role,
        organization=(organization or "").strip() or None,
        message=(message or "").strip() or None,
        status=STATUS_PENDING,
    )
    session.add(request)
    session.flush()
    # Public submission — no actor user. Never store passwords/secrets in audit.
    record_audit(
        session,
        action="create_access_request",
        entity_type="AccessRequest",
        actor_user_id=None,
        entity_id=request.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={"requested_role": role},
        commit=False,
    )
    session.commit()
    return request


def get_access_request(
    session: Session, request_id: uuid.UUID
) -> Optional[AccessRequest]:
    return session.get(AccessRequest, request_id)


def list_access_requests(
    session: Session,
    *,
    status: Optional[str] = None,
    limit: int = 50,
    offset: int = 0,
) -> Tuple[List[AccessRequest], int]:
    conditions = []
    if status is not None:
        conditions.append(AccessRequest.status == status)

    total = session.execute(
        select(func.count()).select_from(AccessRequest).where(*conditions)
    ).scalar_one()
    rows = (
        session.execute(
            select(AccessRequest)
            .where(*conditions)
            .order_by(AccessRequest.created_at.desc())
            .limit(limit)
            .offset(offset)
        )
        .scalars()
        .all()
    )
    return list(rows), int(total)


def update_access_request(
    session: Session,
    *,
    request: AccessRequest,
    status: Optional[str] = None,
    admin_note: Optional[str] = None,
    actor_user_id: Optional[uuid.UUID] = None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
) -> AccessRequest:
    if status is not None:
        if status not in ALLOWED_STATUSES:
            raise InvalidStatusError()
        request.status = status
    if admin_note is not None:
        request.admin_note = admin_note.strip() or None

    session.add(request)
    record_audit(
        session,
        action="update_access_request",
        entity_type="AccessRequest",
        actor_user_id=actor_user_id,
        entity_id=request.id,
        ip_address=ip_address,
        device_info=device_info,
        metadata={"status": request.status},
        commit=False,
    )
    session.commit()
    return request
