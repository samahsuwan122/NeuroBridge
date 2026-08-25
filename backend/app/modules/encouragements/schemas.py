"""Pydantic schemas for family encouragements.

Family support content only — supportive messages, never medical advice,
diagnosis, or assessment.
"""

from datetime import datetime
from typing import List, Literal, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator


class EncouragementCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    patient_profile_id: UUID
    message: str = Field(max_length=300)

    @field_validator("message")
    @classmethod
    def _clean_message(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("message must not be empty")
        return value


class EncouragementResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    patient_profile_id: UUID
    sender_user_id: UUID
    message: Optional[str] = None
    caption: Optional[str] = None
    media_type: Optional[Literal["image", "video", "voice"]] = None
    media_url: Optional[str] = None
    media_mime_type: Optional[str] = None
    media_size_bytes: Optional[int] = None
    media_duration_seconds: Optional[int] = None
    created_at: datetime


class EncouragementListResponse(BaseModel):
    success: bool = True
    total: int
    limit: int
    offset: int
    encouragements: List[EncouragementResponse]
