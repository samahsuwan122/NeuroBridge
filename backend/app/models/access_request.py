"""AccessRequest model.

A public "request access" submission from the marketing website. It stores the
request only — it NEVER creates a user account, password, or any medical record.
An admin reviews requests before any real account is created.

MEDICAL SAFETY: this is a contact/intake record only. No diagnosis, treatment,
prediction, scoring, or medical decision-making is stored or implied.
"""

import uuid
from typing import Optional

from sqlalchemy import String, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import TimestampMixin, UUIDPrimaryKeyMixin

# Roles a member of the public may request.
ALLOWED_ROLES = frozenset({"patient", "family", "doctor", "therapist", "clinic"})

# Review lifecycle.
STATUS_PENDING = "pending"
STATUS_REVIEWED = "reviewed"
STATUS_ACCEPTED = "accepted"
STATUS_DECLINED = "declined"
ALLOWED_STATUSES = frozenset(
    {STATUS_PENDING, STATUS_REVIEWED, STATUS_ACCEPTED, STATUS_DECLINED}
)


class AccessRequest(UUIDPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "access_requests"

    full_name: Mapped[str] = mapped_column(String(255), nullable=False)
    email: Mapped[str] = mapped_column(String(255), nullable=False)
    phone: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    requested_role: Mapped[str] = mapped_column(String(32), nullable=False)
    organization: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    message: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    # pending / reviewed / accepted / declined.
    status: Mapped[str] = mapped_column(
        String(16), default=STATUS_PENDING, nullable=False
    )
    # Optional note added by the reviewing admin (never shown publicly).
    admin_note: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return (
            f"<AccessRequest id={self.id!r} role={self.requested_role!r} "
            f"status={self.status!r}>"
        )
