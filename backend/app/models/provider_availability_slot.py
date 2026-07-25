"""ProviderAvailabilitySlot model.

A bookable time slot offered by a care provider (a doctor or therapist). Family
members book one of these when requesting an appointment for a linked patient.

MEDICAL SAFETY: scheduling/coordination content only — never emergency care,
diagnosis, assessment, or treatment.
"""

import uuid
from datetime import date

from sqlalchemy import Boolean, Date, ForeignKey, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import SoftDeleteMixin, TimestampMixin, UUIDPrimaryKeyMixin


class ProviderAvailabilitySlot(
    UUIDPrimaryKeyMixin, TimestampMixin, SoftDeleteMixin, Base
):
    __tablename__ = "provider_availability_slots"

    provider_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id"), nullable=False
    )
    slot_date: Mapped[date] = mapped_column(Date, nullable=False)
    start_time: Mapped[str] = mapped_column(String(16), nullable=False)
    end_time: Mapped[str] = mapped_column(String(16), nullable=False)
    # in_person | online
    appointment_mode: Mapped[str] = mapped_column(String(32), nullable=False)
    location: Mapped[str | None] = mapped_column(String(255), nullable=True)
    meeting_url: Mapped[str | None] = mapped_column(String(1024), nullable=True)
    is_available: Mapped[bool] = mapped_column(
        Boolean, nullable=False, default=True
    )

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return (
            f"<ProviderAvailabilitySlot id={self.id!r} "
            f"provider={self.provider_user_id!r} date={self.slot_date!r}>"
        )
