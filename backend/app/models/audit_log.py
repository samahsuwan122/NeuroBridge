"""AuditLog model for sensitive-action logging.

Append-only by design (records are written, not updated/deleted). Full
append-only enforcement is intentionally NOT implemented yet.

The Python attribute is `event_metadata` but it maps to the database column
`metadata`, because SQLAlchemy reserves the `.metadata` attribute name on
declarative models.
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import JSON, DateTime, ForeignKey, String, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import UUIDPrimaryKeyMixin, utcnow


class AuditLog(UUIDPrimaryKeyMixin, Base):
    __tablename__ = "audit_logs"

    actor_user_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid, ForeignKey("users.id"), nullable=True
    )
    action: Mapped[str] = mapped_column(String(128), nullable=False)
    entity_type: Mapped[str] = mapped_column(String(64), nullable=False)
    entity_id: Mapped[Optional[uuid.UUID]] = mapped_column(Uuid, nullable=True)
    ip_address: Mapped[Optional[str]] = mapped_column(String(64), nullable=True)
    device_info: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    # Maps to DB column "metadata" (attribute renamed to avoid clashing with
    # SQLAlchemy's reserved `.metadata`).
    event_metadata: Mapped[Optional[dict]] = mapped_column(
        "metadata", JSON, nullable=True
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, nullable=False
    )

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return f"<AuditLog id={self.id!r} action={self.action!r}>"
