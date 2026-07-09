"""Pydantic schemas for the Memory Album.

Memory entries hold supportive, family-engagement content only — no diagnosis,
disease prediction, scoring, or medical interpretation. `media_type`/`media_url`
are placeholders (no real file upload yet).
"""

from datetime import date, datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class MemoryEntryFields(BaseModel):
    """Editable memory fields (shared by create/update)."""

    description: Optional[str] = None
    person_name: Optional[str] = Field(default=None, max_length=255)
    relationship: Optional[str] = Field(default=None, max_length=64)
    place_name: Optional[str] = Field(default=None, max_length=255)
    memory_date: Optional[date] = None
    category: Optional[str] = Field(default=None, max_length=64)
    media_type: Optional[str] = Field(default=None, max_length=32)
    media_url: Optional[str] = Field(default=None, max_length=1024)


class MemoryEntryCreate(MemoryEntryFields):
    patient_profile_id: UUID
    title: str = Field(min_length=1, max_length=255)


class MemoryEntryUpdate(MemoryEntryFields):
    # All fields optional; only provided fields are applied (exclude_unset).
    title: Optional[str] = Field(default=None, min_length=1, max_length=255)


class MemoryEntryResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    patient_profile_id: UUID
    uploaded_by_user_id: UUID
    title: str
    description: Optional[str] = None
    person_name: Optional[str] = None
    relationship: Optional[str] = None
    place_name: Optional[str] = None
    memory_date: Optional[date] = None
    category: Optional[str] = None
    media_type: Optional[str] = None
    media_url: Optional[str] = None
    created_at: datetime
    updated_at: datetime


class MemoryListResponse(BaseModel):
    success: bool = True
    total: int
    limit: int
    offset: int
    memories: List[MemoryEntryResponse]


class MessageResponse(BaseModel):
    success: bool = True
    message: str
