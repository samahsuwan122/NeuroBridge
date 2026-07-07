"""PatientProfile model.

Stores patient profile data and links a profile to a user account (the user must
have the `patient` role — enforced at the service level). One profile per user.

MEDICAL SAFETY: this model stores general profile and care-context data only.
It intentionally has NO diagnostic fields (no diagnosis, disease prediction,
dementia score, etc.). `notes` is for general, non-diagnostic profile notes.
"""

import uuid
from datetime import date
from typing import Optional

from sqlalchemy import Date, ForeignKey, String, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import SoftDeleteMixin, TimestampMixin, UUIDPrimaryKeyMixin


class PatientProfile(UUIDPrimaryKeyMixin, TimestampMixin, SoftDeleteMixin, Base):
    __tablename__ = "patient_profiles"

    # One profile per user; the user must have the patient role (service-enforced).
    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id"), unique=True, nullable=False
    )
    medical_center_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid, ForeignKey("medical_centers.id"), nullable=True
    )

    date_of_birth: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    gender: Mapped[Optional[str]] = mapped_column(String(32), nullable=True)
    emergency_contact_name: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    emergency_contact_phone: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    # General, non-diagnostic profile notes only.
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return f"<PatientProfile id={self.id!r} user_id={self.user_id!r}>"
