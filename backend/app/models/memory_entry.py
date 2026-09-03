"""MemoryEntry model.

Stores a single Memory Album entry for a patient: a supportive, real-life
memory (family photo reference, a person's name, a relationship, a place, a
short story, a memory date, a category). Family/caregivers create entries for a
linked patient and the patient can view them, to support reminiscence-based
family engagement.

MEDICAL SAFETY: this is supportive/family-engagement content only. It has NO
diagnostic fields and is NEVER analyzed, scored, or used to infer any medical
condition (no diagnosis, disease prediction, dementia/Alzheimer score, or
medical interpretation).

`media_type` + `media_url` are placeholders for now (e.g. media_type="text" or a
URL/path string). Real file upload is a later phase.
"""

import uuid
from datetime import date
from typing import Optional

from sqlalchemy import Date, ForeignKey, String, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import SoftDeleteMixin, TimestampMixin, UUIDPrimaryKeyMixin


class MemoryEntry(UUIDPrimaryKeyMixin, TimestampMixin, SoftDeleteMixin, Base):
    __tablename__ = "memory_entries"

    # The patient this memory belongs to.
    patient_profile_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("patient_profiles.id"), nullable=False
    )
    # The user who created the memory (patient, linked family member, or admin).
    uploaded_by_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id"), nullable=False
    )

    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    person_name: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    relationship: Mapped[Optional[str]] = mapped_column(String(64), nullable=True)
    place_name: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    memory_date: Mapped[Optional[date]] = mapped_column(Date, nullable=True)
    category: Mapped[Optional[str]] = mapped_column(String(64), nullable=True)

    # Media placeholders only (no real file upload yet).
    media_type: Mapped[Optional[str]] = mapped_column(String(32), nullable=True)
    media_url: Mapped[Optional[str]] = mapped_column(String(1024), nullable=True)

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return (
            f"<MemoryEntry id={self.id!r} patient={self.patient_profile_id!r} "
            f"title={self.title!r}>"
        )
