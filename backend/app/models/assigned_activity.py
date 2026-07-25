"""AssignedActivity model.

A cognitive *activity* a care-team member (doctor/therapist) assigns to one of
their patients from a small set of safe, predefined templates. The patient sees
it in the mobile app and can start/complete it.

MEDICAL SAFETY: activities are cognitive **exercises only**. There is NO
diagnosis, treatment recommendation, prediction, or risk/mental-health scoring.
`generated_content` holds safe exercise parameters (e.g. word lists, sequence
length, number of rounds) produced from a fixed template — never free-form or
model-generated medical text.
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import (
    JSON,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Text,
    Uuid,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import UUIDPrimaryKeyMixin, utcnow

# Activity lifecycle statuses.
STATUS_ASSIGNED = "assigned"
STATUS_COMPLETED = "completed"
STATUS_SKIPPED = "skipped"


class AssignedActivity(UUIDPrimaryKeyMixin, Base):
    __tablename__ = "assigned_activities"

    # The patient the activity is for (their profile).
    patient_profile_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("patient_profiles.id"), nullable=False
    )
    # The care-team member (doctor/therapist) who assigned it.
    assigned_by_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id"), nullable=False
    )

    # One of the predefined template types (see modules/activities/templates.py).
    template_type: Mapped[str] = mapped_column(String(64), nullable=False)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    # Plain, supportive, non-diagnostic instructions.
    instructions: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    difficulty: Mapped[str] = mapped_column(String(32), nullable=False)
    duration_minutes: Mapped[int] = mapped_column(Integer, nullable=False)

    # assigned / completed / skipped.
    status: Mapped[str] = mapped_column(
        String(16), default=STATUS_ASSIGNED, nullable=False
    )
    # Safe, template-derived exercise parameters only (no medical content).
    generated_content: Mapped[Optional[dict]] = mapped_column(JSON, nullable=True)

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, nullable=False
    )
    completed_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return (
            f"<AssignedActivity id={self.id!r} template={self.template_type!r} "
            f"patient={self.patient_profile_id!r} status={self.status!r}>"
        )
