"""GameResult model.

Stores the outcome of a single cognitive-exercise session. All values are
**exercise/game performance only** — there is NO diagnosis, disease prediction,
or medical interpretation. `metrics` may hold safe gameplay values such as
attempts, correct_answers, wrong_answers, reaction_time_ms.
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import (
    JSON,
    Boolean,
    DateTime,
    Float,
    ForeignKey,
    Integer,
    Uuid,
)
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import UUIDPrimaryKeyMixin, utcnow


class GameResult(UUIDPrimaryKeyMixin, Base):
    __tablename__ = "game_results"

    game_definition_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("game_definitions.id"), nullable=False
    )
    patient_profile_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("patient_profiles.id"), nullable=False
    )
    # The user who submitted the result (the patient's account).
    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id"), nullable=False
    )

    # Exercise performance only.
    score: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    max_score: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    accuracy_percent: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    duration_seconds: Mapped[Optional[int]] = mapped_column(Integer, nullable=True)
    completed: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    # Safe gameplay values only (no medical interpretation).
    metrics: Mapped[Optional[dict]] = mapped_column(JSON, nullable=True)

    started_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    completed_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=utcnow, nullable=False
    )

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return (
            f"<GameResult id={self.id!r} game={self.game_definition_id!r} "
            f"patient={self.patient_profile_id!r}>"
        )
