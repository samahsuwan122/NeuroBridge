"""PatientAssignment model.

Links a patient profile to an assigned clinician (a user with the `doctor` or
`therapist` role — enforced at the service level).
"""

import uuid

from sqlalchemy import Boolean, ForeignKey, String, UniqueConstraint, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import TimestampMixin, UUIDPrimaryKeyMixin


class PatientAssignment(UUIDPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "patient_assignments"

    patient_profile_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("patient_profiles.id"), nullable=False
    )
    clinician_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id"), nullable=False
    )
    # "doctor" or "therapist".
    assignment_type: Mapped[str] = mapped_column(String(32), nullable=False)
    active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)

    __table_args__ = (
        UniqueConstraint(
            "patient_profile_id",
            "clinician_user_id",
            "assignment_type",
            name="uq_patient_assignments_profile_clinician_type",
        ),
    )

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return (
            f"<PatientAssignment profile={self.patient_profile_id!r} "
            f"clinician={self.clinician_user_id!r} type={self.assignment_type!r}>"
        )
