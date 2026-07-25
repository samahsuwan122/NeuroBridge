"""Pydantic schemas for providers and availability slots.

Provider profile text and ratings are seeded demo values for the local demo.
"""

from datetime import date
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class ProviderResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    provider_user_id: UUID
    full_name: str
    role: str  # doctor | therapist
    specialty: Optional[str] = None
    bio_short: Optional[str] = None
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
