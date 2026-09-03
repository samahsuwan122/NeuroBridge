"""Appointment model.

A family/caregiver appointment *request* for a linked patient: a preferred date,
an optional preferred time, and a reason, to help coordinate care. The status is
controlled by the backend and defaults to "pending".

MEDICAL SAFETY: coordination content only — this is NOT emergency care and NOT a
diagnosis, assessment, or treatment. For urgent concerns, users contact the care
team or local emergency services.
"""

import uuid
from datetime import date
from typing import Optional

from sqlalchemy import Date, ForeignKey, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import SoftDeleteMixin, TimestampMixin, UUIDPrimaryKeyMixin


class Appointment(UUIDPrimaryKeyMixin, TimestampMixin, SoftDeleteMixin, Base):
    __tablename__ = "appointments"

    # The patient this appointment request is for.
    patient_profile_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("patient_profiles.id"), nullable=False
    )
    # The family/caregiver (or admin) who requested it.
    requester_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id"), nullable=False
    )

    # The chosen care provider (a doctor/therapist) and the booked slot.
    provider_user_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid, ForeignKey("users.id"), nullable=True
    )
    availability_slot_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid, ForeignKey("provider_availability_slots.id"), nullable=True
    )

    preferred_date: Mapped[date] = mapped_column(Date, nullable=False)
    preferred_time: Mapped[Optional[str]] = mapped_column(
        String(32), nullable=True
    )
    # in_person | online (copied from the booked slot).
    appointment_mode: Mapped[str] = mapped_column(
        String(32), nullable=False, default="in_person"
    )
    location: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    meeting_url: Mapped[Optional[str]] = mapped_column(
        String(1024), nullable=True
    )
    reason: Mapped[str] = mapped_column(String(500), nullable=False)
    # Backend-controlled: pending | approved | cancelled | completed.
    status: Mapped[str] = mapped_column(
        String(32), nullable=False, default="pending"
    )

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return (
            f"<Appointment id={self.id!r} "
            f"patient={self.patient_profile_id!r} status={self.status!r}>"
        )
