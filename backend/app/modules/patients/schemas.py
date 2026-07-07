"""Pydantic schemas for the patient profile module.

Responses reuse `UserBasic` (which never includes password_hash). Profiles carry
no diagnostic fields.
"""

from datetime import date, datetime
from typing import List, Literal, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.modules.auth.schemas import UserBasic


class PatientProfileCreate(BaseModel):
    user_id: UUID
    medical_center_id: Optional[UUID] = None
    date_of_birth: Optional[date] = None
    gender: Optional[str] = Field(default=None, max_length=32)
    emergency_contact_name: Optional[str] = Field(default=None, max_length=255)
    emergency_contact_phone: Optional[str] = Field(default=None, max_length=50)
    notes: Optional[str] = None


class PatientProfileUpdate(BaseModel):
    medical_center_id: Optional[UUID] = None
    date_of_birth: Optional[date] = None
    gender: Optional[str] = Field(default=None, max_length=32)
    emergency_contact_name: Optional[str] = Field(default=None, max_length=255)
    emergency_contact_phone: Optional[str] = Field(default=None, max_length=50)
    notes: Optional[str] = None


class PatientAssignmentResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    patient_profile_id: UUID
    clinician_user_id: UUID
    assignment_type: str
    active: bool
    created_at: datetime
    updated_at: datetime


class PatientFamilyLinkResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    patient_profile_id: UUID
    family_user_id: UUID
    relationship: Optional[str] = None
    active: bool
    created_at: datetime
    updated_at: datetime


class PatientProfileResponse(BaseModel):
    id: UUID
    user_id: UUID
    user: Optional[UserBasic] = None
    medical_center_id: Optional[UUID] = None
    date_of_birth: Optional[date] = None
    gender: Optional[str] = None
    emergency_contact_name: Optional[str] = None
    emergency_contact_phone: Optional[str] = None
    notes: Optional[str] = None
    assignments: List[PatientAssignmentResponse] = Field(default_factory=list)
    family_links: List[PatientFamilyLinkResponse] = Field(default_factory=list)
    created_at: datetime
    updated_at: datetime


class PatientProfileListResponse(BaseModel):
    success: bool = True
    total: int
    limit: int
    offset: int
    patients: List[PatientProfileResponse]


class AssignClinicianRequest(BaseModel):
    clinician_user_id: UUID
    assignment_type: Literal["doctor", "therapist"]


class LinkFamilyRequest(BaseModel):
    family_user_id: UUID
    relationship: Optional[str] = Field(default=None, max_length=64)


class MessageResponse(BaseModel):
    success: bool = True
    message: str
