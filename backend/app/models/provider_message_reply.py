"""ProviderMessageReply model.

A chat reply inside a provider inquiry thread. The originating ProviderMessage is
the thread root (the first inquiry); replies are the follow-up chat messages that
either the addressed provider (doctor/therapist) or the family sender adds.

`read_at` / `read_by_user_id` track when the *other* party read the reply, which
drives the in-app unread badge. A reply is "unread" for a user when they did not
send it and it has no `read_at`.

MEDICAL SAFETY: non-urgent care-coordination content only. This is NEVER
emergency care, medical advice, a diagnosis, a medical assessment, or any
scored/interpreted value. For urgent concerns, users contact local emergency
services.
"""

import uuid
from datetime import datetime
from typing import Optional

from sqlalchemy import DateTime, ForeignKey, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base
from app.db.mixins import SoftDeleteMixin, TimestampMixin, UUIDPrimaryKeyMixin


class ProviderMessageReply(
    UUIDPrimaryKeyMixin, TimestampMixin, SoftDeleteMixin, Base
):
    __tablename__ = "provider_message_replies"

    # The inquiry thread this reply belongs to.
    provider_message_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("provider_messages.id"), nullable=False
    )
    # Who wrote this reply (the addressed provider or the family sender).
    sender_user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id"), nullable=False
    )

    body: Mapped[str] = mapped_column(String(500), nullable=False)

    # Read tracking for the in-app unread badge (marked by the recipient).
    read_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    read_by_user_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        Uuid, ForeignKey("users.id"), nullable=True
    )

    def __repr__(self) -> str:  # pragma: no cover - debug helper
        return (
            f"<ProviderMessageReply id={self.id!r} "
            f"thread={self.provider_message_id!r}>"
        )
