"""Pydantic schemas for care-team assigned activities.

Activities carry cognitive-exercise parameters only — no diagnosis, treatment,
prediction, or scoring of any condition.
"""

from datetime import datetime
from typing import Any, Dict, List, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class ActivityAssignRequest(BaseModel):
    patient_profile_id: UUID
    template_type: str = Field(min_length=1, max_length=64)
    difficulty: str = Field(default="easy", max_length=32)
    duration_minutes: int = Field(default=10, ge=1, le=60)
    # Optional overrides; blank/omitted falls back to the template defaults.
    title: Optional[str] = Field(default=None, max_length=255)
    instructions: Optional[str] = None


class ActivityCompleteRequest(BaseModel):
    # Either mark completed (default) or skipped.
    status: str = Field(default="completed", max_length=16)


class AssignedActivityResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    patient_profile_id: UUID
    assigned_by_user_id: UUID
    template_type: str
    title: str
    instructions: Optional[str] = None
    difficulty: str
    duration_minutes: int
    status: str
    generated_content: Optional[Dict[str, Any]] = None
    created_at: datetime
    completed_at: Optional[datetime] = None


class AssignedActivityListResponse(BaseModel):
    success: bool = True
    total: int
    activities: List[AssignedActivityResponse]


class ActivityTemplateInfo(BaseModel):
    template_type: str
    label: str
    default_title: str
    default_instructions: str
    game_slug: str
    playable: bool


class ActivityTemplateListResponse(BaseModel):
    success: bool = True
    difficulties: List[str]
    templates: List[ActivityTemplateInfo]
