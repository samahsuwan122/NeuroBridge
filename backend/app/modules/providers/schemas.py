"""Pydantic schemas for providers and availability slots.

Provider profile text and ratings are seeded demo values for the local demo.
"""

from datetime import date, time
from typing import List, Literal, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator


class ProviderResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    provider_user_id: UUID
    full_name: str
    role: str  # doctor | therapist
    specialty: Optional[str] = None
    bio_short: Optional[str] = None
    languages: List[str] = Field(default_factory=list)
    clinic_name: Optional[str] = None
    governorate: Optional[str] = None
    city: Optional[str] = None
    location: Optional[str] = None
    experience_label: Optional[str] = None
    phone_number_demo: Optional[str] = None
    photo_url: Optional[str] = None
    rating_average: Optional[float] = None
    rating_count: Optional[int] = None
    available_slot_count: int = 0
    in_person_available: bool = False
    online_available: bool = False
    next_available_date: Optional[date] = None


class ProviderListResponse(BaseModel):
    success: bool = True
    providers: List[ProviderResponse]


class ProviderSelfUpdate(BaseModel):
    display_name: Optional[str] = Field(default=None, min_length=2, max_length=255)
    specialty: Optional[str] = Field(default=None, max_length=255)
    bio_short: Optional[str] = Field(default=None, max_length=500)
    languages: Optional[List[str]] = Field(default=None, max_length=5)
    clinic_name: Optional[str] = Field(default=None, max_length=255)
    location: Optional[str] = Field(default=None, max_length=255)

    @field_validator("display_name", "specialty", "bio_short", "clinic_name", "location")
    @classmethod
    def clean_text(cls, value: Optional[str]) -> Optional[str]:
        return value.strip() if value and value.strip() else None

    @field_validator("display_name")
    @classmethod
    def require_display_name(cls, value: Optional[str]) -> str:
        if value is None:
            raise ValueError("Display name cannot be empty.")
        return value

    @field_validator("languages")
    @classmethod
    def validate_languages(cls, value: Optional[List[str]]) -> Optional[List[str]]:
        if value is None:
            return None
        allowed = {"ar", "en", "fr", "es", "de"}
        normalized = list(dict.fromkeys(item.lower().strip() for item in value))
        if any(item not in allowed for item in normalized):
            raise ValueError("Unsupported provider language.")
        return normalized


class SlotResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    provider_user_id: UUID
    slot_date: date
    start_time: str
    end_time: str
    appointment_mode: str  # in_person | online
    location: Optional[str] = None
    meeting_url: Optional[str] = None


class SlotListResponse(BaseModel):
    success: bool = True
    slots: List[SlotResponse]


class ProviderSlotCreate(BaseModel):
    model_config = ConfigDict(extra="forbid")

    slot_date: date
    start_time: time
    end_time: time
    appointment_mode: Literal["in_person", "online"]
    location: Optional[str] = Field(default=None, max_length=255)
    meeting_url: Optional[str] = Field(default=None, max_length=1024)

    @field_validator("location", "meeting_url")
    @classmethod
    def clean_optional_text(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return None
        return value.strip() or None

    @model_validator(mode="after")
    def validate_time_range(self):
        if self.start_time >= self.end_time:
            raise ValueError("start_time must be before end_time")
        return self


class ProviderManagedSlotResponse(SlotResponse):
    is_available: bool


class ProviderManagedSlotListResponse(BaseModel):
    success: bool = True
    slots: List[ProviderManagedSlotResponse]
