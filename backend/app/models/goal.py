"""Goal model.

Stores care-team goals assigned to a patient profile.

MEDICAL SAFETY: goals are platform follow-up targets only, such as session
completion, activity engagement, or practice consistency. They are not a
diagnosis, treatment recommendation, disease prediction, or risk score.
"""

import uuid
from datetime import date
from typing import Optional

from sqlalchemy import Date, ForeignKey, Integer, String, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import TimestampMixin, UUIDPrimaryKeyMixin


STATUS_ACTIVE = "active"
STATUS_COMPLETED = "completed"
STATUS_PAUSED = "paused"

ALLOWED_GOAL_STATUSES = {
    STATUS_ACTIVE,
    STATUS_COMPLETED,
    STATUS_PAUSED,
}


class Goal(UUIDPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "goals"

    patient_profile_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("patient_profiles.id"), nullable=False, index=True
    )

    created_by_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id"), nullable=False
    )

    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    target_type: Mapped[str] = mapped_column(String(64), nullable=False)
    target_value: Mapped[int] = mapped_column(Integer, nullable=False)
    current_value: Mapped[int] = mapped_column(Integer, default=0, nullable=False)

    status: Mapped[str] = mapped_column(
        String(32), default=STATUS_ACTIVE, nullable=False, index=True
    )

    due_date: Mapped[Optional[date]] = mapped_column(Date, nullable=True)

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return (
            f"<Goal id={self.id!r} patient={self.patient_profile_id!r} "
            f"status={self.status!r}>"
        )