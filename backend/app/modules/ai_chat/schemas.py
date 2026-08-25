from datetime import datetime
from typing import Literal, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator


class AIChatMessageCreate(BaseModel):
    message: str = Field(min_length=1, max_length=2000)

    @field_validator("message")
    @classmethod
    def not_blank(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("message must not be empty")
        return value


class AIChatMessageRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: UUID
    session_id: UUID
    role: str
    message: str
    assistant_response: str
    created_at: datetime


class AIChatHistoryResponse(BaseModel):
    success: bool = True
    messages: list[AIChatMessageRead]


AIConversationRole = Literal["doctor", "therapist", "family", "patient"]


class AIConversationCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    role: AIConversationRole
    patient_profile_id: Optional[UUID] = None
    title: Optional[str] = Field(default=None, max_length=255)

    @field_validator("title")
    @classmethod
    def clean_title(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return None
        return value.strip() or None


class AIConversationRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    title: Optional[str] = None
    role: AIConversationRole
    patient_profile_id: Optional[UUID] = None
    archived_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime


class AIConversationRename(BaseModel):
    model_config = ConfigDict(extra="forbid")

    title: str = Field(min_length=1, max_length=255)

    @field_validator("title")
    @classmethod
    def clean_title(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("title must not be empty")
        return value


class AIConversationListResponse(BaseModel):
    success: bool = True
    total: int
    limit: int
    offset: int
    conversations: list[AIConversationRead]


class AIConversationMessageCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    message: str = Field(min_length=1, max_length=2000)

    @field_validator("message")
    @classmethod
    def clean_message(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("message must not be empty")
        return value


class AIConversationMessagesResponse(BaseModel):
    success: bool = True
    total: int
    limit: int
    offset: int
    messages: list[AIChatMessageRead]
