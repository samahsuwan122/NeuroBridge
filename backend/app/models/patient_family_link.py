"""PatientFamilyLink model.

Links a patient profile to a family/caregiver user (a user with the `family`
role — enforced at the service level).
"""

import uuid
from typing import Optional

from sqlalchemy import Boolean, ForeignKey, String, UniqueConstraint, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import TimestampMixin, UUIDPrimaryKeyMixin


class PatientFamilyLink(UUIDPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "patient_family_links"

    patient_profile_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("patient_profiles.id"), nullable=False
    )
    family_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id"), nullable=False
    )
    # e.g. "son", "daughter", "spouse", "caregiver".
    relationship: Mapped[Optional[str]] = mapped_column(String(64), nullable=True)
    active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    __table_args__ = (
        UniqueConstraint(
            "patient_profile_id",
            "family_user_id",
            name="uq_patient_family_links_profile_family",
        ),
    )

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return (
            f"<PatientFamilyLink profile={self.patient_profile_id!r} "
            f"family={self.family_user_id!r}>"
        )
