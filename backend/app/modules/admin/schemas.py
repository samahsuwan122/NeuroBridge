"""Pydantic schemas for admin user management.

`AdminUserResponse` never includes `password_hash`. `AdminUserUpdate` uses
optional fields; routes apply only the fields the client actually sent
(`model_dump(exclude_unset=True)`), so omitting a field leaves it unchanged.
"""

from datetime import datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, model_validator

# Allowed account statuses (kept in sync with activate/deactivate behavior).
UserStatus = str  # constrained via Literal below where used

ALLOWED_STATUSES = ("active", "inactive", "suspended")


class AdminUserCreate(BaseModel):
    full_name: str = Field(min_length=1, max_length=255)
    email: Optional[str] = Field(default=None, max_length=255)
    phone: Optional[str] = Field(default=None, max_length=50)
    password: str = Field(min_length=8, max_length=128)
    preferred_language: str = Field(default="en", max_length=8)
    status: str = Field(default="active")
    medical_center_id: Optional[UUID] = None
    roles: List[str] = Field(default_factory=list)

    @model_validator(mode="after")
    def _check(self) -> "AdminUserCreate":
        if not self.email and not self.phone:
            raise ValueError("At least one of email or phone is required.")
        if self.status not in ALLOWED_STATUSES:
            raise ValueError(f"status must be one of {ALLOWED_STATUSES}")
        return self


class AdminUserUpdate(BaseModel):
    full_name: Optional[str] = Field(default=None, min_length=1, max_length=255)
    email: Optional[str] = Field(default=None, max_length=255)
    phone: Optional[str] = Field(default=None, max_length=50)
    preferred_language: Optional[str] = Field(default=None, max_length=8)
    status: Optional[str] = None
    medical_center_id: Optional[UUID] = None
    roles: Optional[List[str]] = None
    password: Optional[str] = Field(default=None, min_length=8, max_length=128)

    @model_validator(mode="after")
    def _check_status(self) -> "AdminUserUpdate":
        if self.status is not None and self.status not in ALLOWED_STATUSES:
            raise ValueError(f"status must be one of {ALLOWED_STATUSES}")
        return self


class AdminUserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    full_name: str
    email: Optional[str] = None
    phone: Optional[str] = None
    preferred_language: str
    status: str
    medical_center_id: Optional[UUID] = None
    roles: List[str] = Field(default_factory=list)
    created_at: datetime
    updated_at: datetime


class AdminUserListResponse(BaseModel):
    success: bool = True
    total: int
    limit: int
    offset: int
    users: List[AdminUserResponse]


class RoleResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    name: str
    description: Optional[str] = None


class MessageResponse(BaseModel):
    success: bool = True
    message: str
