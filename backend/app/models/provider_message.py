"""ProviderMessage model.

A short, non-urgent inquiry a family/caregiver (or admin) sends to a care
provider (a doctor or therapist) about their linked patient, to help coordinate
care. The provider can read inquiries addressed to them.

MEDICAL SAFETY: non-urgent care-coordination content only. This is NEVER
emergency care, medical advice, a diagnosis, a medical assessment, or any
scored/interpreted value. For urgent concerns, users contact local emergency
services.
"""

import uuid

from sqlalchemy import ForeignKey, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import SoftDeleteMixin, TimestampMixin, UUIDPrimaryKeyMixin


class ProviderMessage(
    UUIDPrimaryKeyMixin, TimestampMixin, SoftDeleteMixin, Base
):
    __tablename__ = "provider_messages"

    # The care provider (a doctor/therapist) this inquiry is addressed to.
    provider_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id"), nullable=False
    )
    # The family/caregiver (or admin) who sent the inquiry.
    sender_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id"), nullable=False
    )
    # The patient this inquiry is about.
    patient_profile_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("patient_profiles.id"), nullable=False
    )

    message: Mapped[str] = mapped_column(String(500), nullable=False)
    # Simple lifecycle marker (currently always "sent"); no fake reply flow.
    status: Mapped[str] = mapped_column(
        String(32), nullable=False, default="sent"
    )

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return (
            f"<ProviderMessage id={self.id!r} "
            f"provider={self.provider_user_id!r} status={self.status!r}>"
        )
