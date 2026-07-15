"""Pydantic schemas for appointments.

Coordination content only — appointment requests, never emergency care,
diagnosis, assessment, or treatment. Provider, date/time, mode, and location are
derived from the booked availability slot; status is backend-controlled.
"""

from datetime import date, datetime
from typing import List, Literal, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator

APPOINTMENT_STATUSES = ("pending", "approved", "cancelled", "completed")


class AppointmentCreate(BaseModel):
    patient_profile_id: UUID
    provider_user_id: UUID
    availability_slot_id: UUID
    reason: str = Field(max_length=500)

    @field_validator("reason")
    @classmethod
    def _clean_reason(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("reason must not be empty")
        return value


class AppointmentStatusUpdate(BaseModel):
    status: Literal["pending", "approved", "cancelled", "completed"]


class AppointmentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    patient_profile_id: UUID
    requester_user_id: UUID
    provider_user_id: Optional[UUID] = None
    provider_name: Optional[str] = None
    preferred_date: date
    preferred_time: Optional[str] = None
    appointment_mode: str
    location: Optional[str] = None
    meeting_url: Optional[str] = None
    reason: str
    status: str
    created_at: datetime
    updated_at: datetime


class AppointmentListResponse(BaseModel):
    success: bool = True
    total: int
    limit: int
    offset: int
    appointments: List[AppointmentResponse]
