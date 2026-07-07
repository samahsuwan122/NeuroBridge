"""Pydantic schemas for cognitive games.

Game results carry exercise-performance fields only — no diagnosis, disease
prediction, or medical interpretation.
"""

from datetime import datetime
from typing import Any, Dict, List, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class GameDefinitionCreate(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    slug: str = Field(min_length=1, max_length=64)
    game_type: str = Field(min_length=1, max_length=64)
    description: Optional[str] = None
    difficulty: str = Field(default="easy", max_length=32)
    estimated_duration_minutes: Optional[int] = Field(default=None, ge=0)
    instructions: Optional[str] = None
    active: bool = True


class GameDefinitionUpdate(BaseModel):
    name: Optional[str] = Field(default=None, min_length=1, max_length=255)
    slug: Optional[str] = Field(default=None, min_length=1, max_length=64)
    game_type: Optional[str] = Field(default=None, min_length=1, max_length=64)
    description: Optional[str] = None
    difficulty: Optional[str] = Field(default=None, max_length=32)
    estimated_duration_minutes: Optional[int] = Field(default=None, ge=0)
    instructions: Optional[str] = None
    active: Optional[bool] = None


class GameDefinitionResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name: str
    slug: str
    description: Optional[str] = None
    game_type: str
    difficulty: str
    estimated_duration_minutes: Optional[int] = None
    active: bool
    instructions: Optional[str] = None
    created_at: datetime
    updated_at: datetime


class GameListResponse(BaseModel):
    success: bool = True
    total: int
    games: List[GameDefinitionResponse]


class GameResultCreate(BaseModel):
    patient_profile_id: UUID
    score: Optional[int] = None
    max_score: Optional[int] = None
    accuracy_percent: Optional[float] = Field(default=None, ge=0, le=100)
    duration_seconds: Optional[int] = Field(default=None, ge=0)
    completed: bool = True
    metrics: Optional[Dict[str, Any]] = None
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None


class GameResultResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    game_definition_id: UUID
    patient_profile_id: UUID
    user_id: UUID
    score: Optional[int] = None
    max_score: Optional[int] = None
    accuracy_percent: Optional[float] = None
    duration_seconds: Optional[int] = None
    completed: bool
    metrics: Optional[Dict[str, Any]] = None
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    created_at: datetime


class GameResultListResponse(BaseModel):
    success: bool = True
    total: int
    limit: int
    offset: int
    results: List[GameResultResponse]


class MessageResponse(BaseModel):
    success: bool = True
    message: str
