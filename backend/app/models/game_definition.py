"""GameDefinition model.

Defines a cognitive *exercise* (not a medical test). Names/slugs must be neutral
exercise labels (e.g. memory_match, attention_focus, reaction_time,
sequence_order). No diagnostic naming or medical interpretation.
"""

from typing import Optional

from sqlalchemy import Boolean, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import SoftDeleteMixin, TimestampMixin, UUIDPrimaryKeyMixin


class GameDefinition(UUIDPrimaryKeyMixin, TimestampMixin, SoftDeleteMixin, Base):
    __tablename__ = "game_definitions"

    name: Mapped[str] = mapped_column(String(255), nullable=False)
    slug: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    game_type: Mapped[str] = mapped_column(String(64), nullable=False)
    difficulty: Mapped[str] = mapped_column(String(32), default="easy", nullable=False)
    estimated_duration_minutes: Mapped[Optional[int]] = mapped_column(
        Integer, nullable=True
    )
    active: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    instructions: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return f"<GameDefinition id={self.id!r} slug={self.slug!r}>"
