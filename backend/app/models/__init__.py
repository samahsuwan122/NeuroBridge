"""ORM models package.

Importing this package imports every model, which registers all tables on
`Base.metadata`. Alembic's env.py and the database tests import this package so
that metadata is complete.
"""

from app.db.base import Base
from app.models.appointment import Appointment
from app.models.assigned_activity import AssignedActivity
from app.models.audit_log import AuditLog
from app.models.provider_availability_slot import ProviderAvailabilitySlot
from app.models.family_encouragement import FamilyEncouragement
from app.models.game_definition import GameDefinition
from app.models.game_result import GameResult
from app.models.medical_center import MedicalCenter
from app.models.memory_entry import MemoryEntry
from app.models.patient_assignment import PatientAssignment
from app.models.patient_family_link import PatientFamilyLink
from app.models.patient_profile import PatientProfile
from app.models.provider_message import ProviderMessage
from app.models.provider_message_reply import ProviderMessageReply
from app.models.provider_profile import ProviderProfile
from app.models.role import Role
from app.models.user import User
from app.models.user_role import UserRole

__all__ = [
    "Base",
    "User",
    "Role",
    "UserRole",
    "MedicalCenter",
    "AuditLog",
    "PatientProfile",
    "PatientAssignment",
    "PatientFamilyLink",
    "GameDefinition",
    "GameResult",
    "AssignedActivity",
    "MemoryEntry",
    "FamilyEncouragement",
    "Appointment",
    "ProviderAvailabilitySlot",
    "ProviderProfile",
    "ProviderMessage",
    "ProviderMessageReply",
]
