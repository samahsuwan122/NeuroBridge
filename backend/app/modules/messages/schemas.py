"""Pydantic schemas for provider inquiry messages and chat replies.

Non-urgent care-coordination content only — never emergency care, medical
advice, diagnosis, or assessment.
"""

from datetime import datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator


class ProviderMessageCreate(BaseModel):
    provider_user_id: UUID
    patient_profile_id: UUID
    message: str = Field(max_length=500)

    @field_validator("message")
    @classmethod
    def _clean_message(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("message must not be empty")
        return value


class ProviderReplyCreate(BaseModel):
    body: str = Field(max_length=500)

    @field_validator("body")
    @classmethod
    def _clean_body(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("body must not be empty")
        return value


class ProviderReplyResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    provider_message_id: UUID
    sender_user_id: UUID
    sender_name: Optional[str] = None
    body: str
    created_at: datetime
    read_at: Optional[datetime] = None


class ProviderMessageResponse(BaseModel):
    """A thread summary (the original inquiry + reply activity for the viewer)."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    provider_user_id: UUID
    sender_user_id: UUID
    patient_profile_id: UUID
    message: str
    status: str
    created_at: datetime
    # Display helpers filled in by the route (names, not stored on the row).
    provider_name: Optional[str] = None
    sender_name: Optional[str] = None
    patient_name: Optional[str] = None
    # Reply/thread activity (relative to the current viewer).
    latest_reply_preview: Optional[str] = None
    latest_reply_at: Optional[datetime] = None
    unread_reply_count: int = 0


class ProviderMessageThreadResponse(ProviderMessageResponse):
    """A full thread: the original inquiry plus its replies in time order."""

    replies: List[ProviderReplyResponse] = []


class ProviderMessageListResponse(BaseModel):
    success: bool = True
    total: int
    limit: int
    offset: int
    messages: List[ProviderMessageResponse]


class MarkReadResponse(BaseModel):
    success: bool = True
    marked_read: int


class UnreadCountResponse(BaseModel):
    success: bool = True
    unread_count: int
