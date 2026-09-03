"""User model.

Phase 3 scope: table structure only. There is NO authentication or password
hashing logic yet. `password_hash` is a nullable placeholder that Phase 4 will
populate; it must never store a plain-text password.
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import DateTime, ForeignKey, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import SoftDeleteMixin, TimestampMixin, UUIDPrimaryKeyMixin


class User(UUIDPrimaryKeyMixin, TimestampMixin, SoftDeleteMixin, Base):
    __tablename__ = "users"

    full_name: Mapped[str] = mapped_column(String(255), nullable=False)
    email: Mapped[Optional[str]] = mapped_column(String(255), unique=True, nullable=True)
    phone: Mapped[Optional[str]] = mapped_column(String(50), unique=True, nullable=True)

    # Placeholder only — populated in Phase 4. Never store plain-text passwords.
    password_hash: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)

    preferred_language: Mapped[str] = mapped_column(String(8), default="en", nullable=False)
    status: Mapped[str] = mapped_column(String(32), default="active", nullable=False)

    medical_center_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid, ForeignKey("medical_centers.id"), nullable=True
    )

    last_login_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return f"<User id={self.id!r} full_name={self.full_name!r}>"
