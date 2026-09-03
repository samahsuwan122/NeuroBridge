"""Reusable declarative mixins for NeuroBridge models.

- UUIDPrimaryKeyMixin: portable UUID primary key (native UUID on PostgreSQL,
  stored as CHAR on SQLite via SQLAlchemy's cross-dialect Uuid type).
- TimestampMixin: created_at / updated_at, set in Python (UTC) so behaviour is
  identical on SQLite and PostgreSQL.
- SoftDeleteMixin: nullable deleted_at for soft deletes where useful.
"""

import uuid
from datetime import datetime, timezone
from typing import Optional

from sqlalchemy import DateTime, Uuid
from sqlalchemy.orm import Mapped, mapped_column


def utcnow() -> datetime:
    """Timezone-aware current UTC time (used as a column default)."""
    return datetime.now(timezone.utc)


class UUIDPrimaryKeyMixin:
    """Adds a UUID primary key column named ``id``."""

    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)


class TimestampMixin:
    """Adds ``created_at`` and ``updated_at`` timestamp columns."""

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, onupdate=utcnow, nullable=False
    )


class SoftDeleteMixin:
    """Adds a nullable ``deleted_at`` column for soft deletes."""

    deleted_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
