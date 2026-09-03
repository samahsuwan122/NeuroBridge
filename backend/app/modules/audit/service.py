"""Audit logging service.

`record_audit` appends a row to `audit_logs`. Audit logs are append-only by
design (never updated or deleted). Never pass secrets (passwords, tokens) as
metadata.
"""

import uuid
from typing import Optional

from sqlalchemy.orm import Session

from app.models import AuditLog


def record_audit(
    session: Session,
    *,
    action: str,
    entity_type: str,
    actor_user_id: Optional[uuid.UUID] = None,
    entity_id: Optional[uuid.UUID] = None,
    ip_address: Optional[str] = None,
    device_info: Optional[str] = None,
    metadata: Optional[dict] = None,
    commit: bool = True,
) -> AuditLog:
    """Create an audit log entry.

    Set commit=False to include the log in the caller's transaction (the caller
    is then responsible for committing).
    """
    log = AuditLog(
        actor_user_id=actor_user_id,
        action=action,
        entity_type=entity_type,
        entity_id=entity_id,
        ip_address=ip_address,
        device_info=device_info,
        event_metadata=metadata,
    )
    session.add(log)
    if commit:
        session.commit()
    else:
        session.flush()
    return log
