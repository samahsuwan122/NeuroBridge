"""Pydantic schemas for patient goals.

Goals carry simple, performance-based follow-up fields only — no diagnosis,
treatment, prediction, or scoring of any condition.
"""

from datetime import date, datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.models.goal import ALLOWED_GOAL_STATUSES


class GoalCreate(BaseModel):
    patient_profile_id: UUID
    title: str = Field(min_length=1, max_length=255)
    description: Optional[str] = None
    target_type: str = Field(min_length=1, max_length=64)
    target_value: int = Field(ge=1)
    current_value: int = Field(default=0, ge=0)
    due_date: Optional[date] = None

    @field_validator("title", "target_type")
    @classmethod
    def _not_blank(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("must not be empty")
        return v


class GoalUpdate(BaseModel):
    title: Optional[str] = Field(default=None, min_length=1, max_length=255)
    description: Optional[str] = None
    target_type: Optional[str] = Field(default=None, min_length=1, max_length=64)
    target_value: Optional[int] = Field(default=None, ge=1)
    current_value: Optional[int] = Field(default=None, ge=0)
    status: Optional[str] = Field(default=None, max_length=32)
    due_date: Optional[date] = None

    @field_validator("status")
    @classmethod
    def _valid_status(cls, v: Optional[str]) -> Optional[str]:
        if v is not None and v not in ALLOWED_GOAL_STATUSES:
            raise ValueError("status must be one of: active, completed, paused")
        return v

    @field_validator("title", "target_type")
    @classmethod
    def _not_blank(cls, v: Optional[str]) -> Optional[str]:
        if v is not None and not v.strip():
            raise ValueError("must not be empty")
        return v.strip() if v is not None else v


class GoalRead(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    patient_profile_id: UUID
    created_by_user_id: UUID
    title: str
    description: Optional[str] = None
    target_type: str
    target_value: int
    current_value: int
    status: str
    due_date: Optional[date] = None
    created_at: datetime
    updated_at: datetime


class GoalListResponse(BaseModel):
    success: bool = True
    total: int
    goals: List[GoalRead]
