"""Pydantic schemas for the auth module."""

from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class LoginRequest(BaseModel):
    email_or_phone: str
    password: str


class UserBasic(BaseModel):
    """Non-sensitive user fields returned to clients (never includes the hash)."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    full_name: str
    email: Optional[str] = None
    phone: Optional[str] = None
    preferred_language: str
    status: str


class LoginResponse(BaseModel):
    success: bool = True
    access_token: str
    token_type: str = "bearer"
    refresh_token: Optional[str] = None
    user: UserBasic
    roles: List[str]


class CurrentUserResponse(BaseModel):
    success: bool = True
    user: UserBasic
    roles: List[str]


class RefreshRequest(BaseModel):
    refresh_token: str


class RefreshResponse(BaseModel):
    success: bool = True
    access_token: str
    token_type: str = "bearer"


class LogoutResponse(BaseModel):
    success: bool = True
    message: str
