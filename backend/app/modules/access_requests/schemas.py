"""Pydantic schemas for public access requests.

Intake/contact fields only — no medical, diagnostic, or account data.
"""

import re
from datetime import datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator

# Simple, permissive email shape check (kept local so no extra dependency is
# required). Real validation/verification happens during admin review.
_EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


class AccessRequestCreate(BaseModel):
    full_name: str = Field(min_length=1, max_length=255)
    email: str = Field(min_length=3, max_length=255)
    phone: Optional[str] = Field(default=None, max_length=50)
    requested_role: str = Field(min_length=1, max_length=32)
    organization: Optional[str] = Field(default=None, max_length=255)
    message: Optional[str] = None

    @field_validator("full_name")
    @classmethod
    def _name_not_blank(cls, v: str) -> str:
        v = v.strip()
        if not v:
            raise ValueError("full_name is required")
        return v

    @field_validator("email")
    @classmethod
    def _email_shape(cls, v: str) -> str:
        v = v.strip()
        if not _EMAIL_RE.match(v):
            raise ValueError("A valid email is required")
        return v


class AccessRequestUpdate(BaseModel):
    status: Optional[str] = Field(default=None, max_length=16)
    admin_note: Optional[str] = None


class AccessRequestResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    full_name: str
    email: str
    phone: Optional[str] = None
    requested_role: str
    organization: Optional[str] = None
    message: Optional[str] = None
    status: str
    admin_note: Optional[str] = None
    created_at: datetime
    updated_at: datetime


class AccessRequestListResponse(BaseModel):
    success: bool = True
    total: int
    requests: List[AccessRequestResponse]


class AccessRequestCreatedResponse(BaseModel):
    """Safe response for the public create endpoint (no data echoed back)."""

    success: bool = True
    message: str
    id: UUID
