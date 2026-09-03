"""MedicalCenter model.

Note on the circular reference: `users.medical_center_id` -> `medical_centers.id`
and `medical_centers.manager_user_id` -> `users.id` form a cycle. The
`manager_user_id` foreign key is declared with ``use_alter=True`` so table
creation can break the cycle (the constraint is added after both tables exist).
The initial Alembic migration adds this FK via a batch operation, which works on
both SQLite (table rebuild) and PostgreSQL (ALTER TABLE ADD CONSTRAINT).
"""

import uuid
from typing import Optional

from sqlalchemy import ForeignKey, String, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import SoftDeleteMixin, TimestampMixin, UUIDPrimaryKeyMixin


class MedicalCenter(UUIDPrimaryKeyMixin, TimestampMixin, SoftDeleteMixin, Base):
    __tablename__ = "medical_centers"

    name: Mapped[str] = mapped_column(String(255), nullable=False)
    address: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    phone: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    email: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)

    manager_user_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid,
        ForeignKey(
            "users.id",
            use_alter=True,
            name="fk_medical_centers_manager_user_id_users",
        ),
        nullable=True,
    )

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return f"<MedicalCenter id={self.id!r} name={self.name!r}>"
