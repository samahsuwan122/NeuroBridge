"""FamilyEncouragement model.

A short, supportive message sent by a family/caregiver to a linked patient and
shown to the patient as emotional/family support.

MEDICAL SAFETY: family support content only. This is NEVER medical advice, a
diagnosis, a medical assessment, disease prediction, or any scored/interpreted
value. It is never analyzed to infer any condition.
"""

import uuid

from sqlalchemy import ForeignKey, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import SoftDeleteMixin, TimestampMixin, UUIDPrimaryKeyMixin


class FamilyEncouragement(
    UUIDPrimaryKeyMixin, TimestampMixin, SoftDeleteMixin, Base
):
    __tablename__ = "family_encouragements"

    # The patient who receives this supportive message.
    patient_profile_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("patient_profiles.id"), nullable=False
    )
    # The family/caregiver (or admin) who sent it.
    sender_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id"), nullable=False
    )

    message: Mapped[str] = mapped_column(String(300), nullable=False)

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return (
            f"<FamilyEncouragement id={self.id!r} "
            f"patient={self.patient_profile_id!r}>"
        )
