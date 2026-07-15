"""ProviderProfile model.

Extra display/booking details for a care provider (a doctor or therapist),
shown on the Family Appointments booking page: focus/specialty, a short focus
blurb, clinic name, default location, an experience label, and demo rating
values.

DEMO / GRADUATION USE: ratings and profile text are seeded demo values for the
local demonstration only — they do not represent real clinicians.

MEDICAL SAFETY: scheduling/coordination content only — never emergency care,
diagnosis, assessment, or treatment.
"""

import uuid

from sqlalchemy import Float, ForeignKey, Integer, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import SoftDeleteMixin, TimestampMixin, UUIDPrimaryKeyMixin


class ProviderProfile(
    UUIDPrimaryKeyMixin, TimestampMixin, SoftDeleteMixin, Base
):
    __tablename__ = "provider_profiles"

    provider_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id"), nullable=False, unique=True
    )
    specialty: Mapped[str | None] = mapped_column(String(255), nullable=True)
    bio_short: Mapped[str | None] = mapped_column(String(500), nullable=True)
    clinic_name: Mapped[str | None] = mapped_column(String(255), nullable=True)
    governorate: Mapped[str | None] = mapped_column(String(64), nullable=True)
    city: Mapped[str | None] = mapped_column(String(64), nullable=True)
    location: Mapped[str | None] = mapped_column(String(255), nullable=True)
    experience_label: Mapped[str | None] = mapped_column(
        String(64), nullable=True
    )
    # Demo contact only — never a real phone number.
    phone_number_demo: Mapped[str | None] = mapped_column(
        String(32), nullable=True
    )
    # Public URL of an uploaded demo photo (or None for initials avatar).
    photo_url: Mapped[str | None] = mapped_column(String(1024), nullable=True)
    # Seeded demo values only.
    rating_average: Mapped[float | None] = mapped_column(Float, nullable=True)
    rating_count: Mapped[int | None] = mapped_column(
        Integer, nullable=True, default=0
    )

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return (
            f"<ProviderProfile provider={self.provider_user_id!r} "
            f"specialty={self.specialty!r}>"
        )
