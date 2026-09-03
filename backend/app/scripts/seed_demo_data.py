"""Seed local demo users and relationships for manual testing.

FOR LOCAL DEVELOPMENT ONLY. Creates non-real demo accounts so the mobile app
can be exercised (login, patient home, games list, Memory Match). Idempotent:
re-running reuses existing records instead of duplicating them.

No real patient data and no medical/diagnostic data are created.

Run from the backend/ folder:

    python -m app.scripts.seed_demo_data
"""

from datetime import date, timedelta
from typing import Dict, Tuple

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.security import hash_password
from app.models import (
    MedicalCenter,
    MemoryEntry,
    PatientAssignment,
    PatientFamilyLink,
    PatientProfile,
    ProviderAvailabilitySlot,
    ProviderProfile,
    Role,
    User,
    UserRole,
)
from app.scripts.seed_games import seed_games
from app.scripts.seed_roles import seed_roles

# Local dev demo password — NOT for production use.
DEMO_PASSWORD = "Demo12345!"
DEMO_CENTER_NAME = "NeuroBridge Demo Center"

# (email, full_name, role)
DEMO_USERS = [
    ("admin.demo@neurobridge.local", "Demo Admin", "admin"),
    ("patient.demo@neurobridge.local", "Demo Patient", "patient"),
    ("family.demo@neurobridge.local", "Demo Family", "family"),
    ("doctor.demo@neurobridge.local", "Demo Doctor", "doctor"),
    ("therapist.demo@neurobridge.local", "Demo Therapist", "therapist"),
]

# Extra bookable demo care providers across governorates (LOCAL DEMO ACCOUNTS
# ONLY — realistic FAKE names for the graduation demo, NOT real clinicians).
# Keyed by email so several providers of the same role/governorate can coexist.
DEMO_EXTRA_PROVIDERS = [
    ("dr.lina.demo@neurobridge.local", "Dr. Lina Haddad", "doctor"),
    ("dr.sara.demo@neurobridge.local", "Dr. Sara Khalil", "doctor"),
    ("therapist.omar.demo@neurobridge.local", "Therapist Omar Naser", "therapist"),
    ("dr.kareem.demo@neurobridge.local", "Dr. Kareem Mansour", "doctor"),
    ("therapist.dana.demo@neurobridge.local", "Therapist Dana Saleh", "therapist"),
    ("dr.hala.demo@neurobridge.local", "Dr. Hala Barghouti", "doctor"),
    ("therapist.yazan.demo@neurobridge.local", "Therapist Yazan Saleh", "therapist"),
]

# The old placeholder demo contact. Kept only so re-seeding can detect and
# replace it with a realistic-looking demo number below. NEVER a real number.
LEGACY_DEMO_PHONE = "+970-000-000-000"

# Realistic-looking demo contact numbers — one per provider. These are FAKE
# local demo numbers for the graduation demo ONLY. They are not real phone
# numbers and must never be dialed or treated as real clinician contacts.
# email -> demo contact number.
DEMO_PROVIDER_PHONES = {
    "doctor.demo@neurobridge.local": "+970-59-410-2301",
    "therapist.demo@neurobridge.local": "+970-56-220-1844",
    "dr.lina.demo@neurobridge.local": "+970-59-730-5022",
    "dr.sara.demo@neurobridge.local": "+970-56-815-7490",
    "therapist.omar.demo@neurobridge.local": "+970-59-284-6617",
    "dr.kareem.demo@neurobridge.local": "+970-56-903-1185",
    "therapist.dana.demo@neurobridge.local": "+970-59-642-3370",
    "dr.hala.demo@neurobridge.local": "+970-56-771-2094",
    "therapist.yazan.demo@neurobridge.local": "+970-59-508-6123",
}

# Provider profile detail. Names/ratings/text/phone are SEEDED DEMO VALUES ONLY —
# they do not represent real clinicians, real phone numbers, or real reviews.
# The phone_number_demo is taken from DEMO_PROVIDER_PHONES (fake demo contacts).
# email -> profile fields.
DEMO_PROVIDER_PROFILES = {
    "doctor.demo@neurobridge.local": {
        "specialty": "Cognitive follow-up",
        "bio_short": "Supportive cognitive follow-up and care coordination.",
        "clinic_name": "NeuroBridge Demo Center",
        "governorate": "Nablus",
        "city": "Nablus",
        "location": "NeuroBridge Demo Center, Room 3",
        "experience_label": "10 years experience",
        "phone_number_demo": DEMO_PROVIDER_PHONES["doctor.demo@neurobridge.local"],
        "rating_average": 4.9,
        "rating_count": 24,
    },
    "therapist.demo@neurobridge.local": {
        "specialty": "Therapy support",
        "bio_short": "Supportive therapy activities and family coordination.",
        "clinic_name": "NeuroBridge Demo Center",
        "governorate": "Ramallah",
        "city": "Ramallah",
        "location": "NeuroBridge Demo Center, Room 5",
        "experience_label": "8 years experience",
        "phone_number_demo": DEMO_PROVIDER_PHONES[
            "therapist.demo@neurobridge.local"
        ],
        "rating_average": 4.8,
        "rating_count": 19,
    },
    "dr.lina.demo@neurobridge.local": {
        "specialty": "Memory and attention support",
        "bio_short": "Focus on memory and attention supportive activities.",
        "clinic_name": "NeuroBridge Demo Center",
        "governorate": "Nablus",
        "city": "Nablus",
        "location": "NeuroBridge Demo Center, Room 2",
        "experience_label": "12 years experience",
        "phone_number_demo": DEMO_PROVIDER_PHONES["dr.lina.demo@neurobridge.local"],
        "rating_average": 4.9,
        "rating_count": 31,
    },
    "dr.sara.demo@neurobridge.local": {
        "specialty": "Cognitive care planning",
        "bio_short": "Care coordination and supportive planning.",
        "clinic_name": "NeuroBridge Demo Center",
        "governorate": "Ramallah",
        "city": "Ramallah",
        "location": "NeuroBridge Demo Center, Room 1",
        "experience_label": "9 years experience",
        "phone_number_demo": DEMO_PROVIDER_PHONES["dr.sara.demo@neurobridge.local"],
        "rating_average": 4.8,
        "rating_count": 22,
    },
    "therapist.omar.demo@neurobridge.local": {
        "specialty": "Daily activity training",
        "bio_short": "Supportive daily-activity training sessions.",
        "clinic_name": "NeuroBridge Demo Center",
        "governorate": "Nablus",
        "city": "Nablus",
        "location": "NeuroBridge Demo Center, Room 6",
        "experience_label": "6 years experience",
        "phone_number_demo": DEMO_PROVIDER_PHONES[
            "therapist.omar.demo@neurobridge.local"
        ],
        "rating_average": 4.7,
        "rating_count": 15,
    },
    "dr.kareem.demo@neurobridge.local": {
        "specialty": "Cognitive follow-up",
        "bio_short": "Supportive cognitive follow-up and family coordination.",
        "clinic_name": "NeuroBridge Demo Center",
        "governorate": "Hebron",
        "city": "Hebron",
        "location": "NeuroBridge Demo Center, Room 4",
        "experience_label": "11 years experience",
        "phone_number_demo": DEMO_PROVIDER_PHONES[
            "dr.kareem.demo@neurobridge.local"
        ],
        "rating_average": 4.8,
        "rating_count": 20,
    },
    "therapist.dana.demo@neurobridge.local": {
        "specialty": "Therapy support",
        "bio_short": "Supportive therapy activities for families.",
        "clinic_name": "NeuroBridge Demo Center",
        "governorate": "Jenin",
        "city": "Jenin",
        "location": "NeuroBridge Demo Center, Room 2",
        "experience_label": "7 years experience",
        "phone_number_demo": DEMO_PROVIDER_PHONES[
            "therapist.dana.demo@neurobridge.local"
        ],
        "rating_average": 4.6,
        "rating_count": 12,
    },
    "dr.hala.demo@neurobridge.local": {
        "specialty": "Memory and attention support",
        "bio_short": "Focus on memory and attention supportive activities.",
        "clinic_name": "NeuroBridge Demo Center",
        "governorate": "Tulkarem",
        "city": "Tulkarem",
        "location": "NeuroBridge Demo Center, Room 3",
        "experience_label": "13 years experience",
        "phone_number_demo": DEMO_PROVIDER_PHONES["dr.hala.demo@neurobridge.local"],
        "rating_average": 4.9,
        "rating_count": 27,
    },
    "therapist.yazan.demo@neurobridge.local": {
        "specialty": "Daily activity training",
        "bio_short": "Supportive daily-routine training sessions.",
        "clinic_name": "NeuroBridge Demo Center",
        "governorate": "Qalqilya",
        "city": "Qalqilya",
        "location": "NeuroBridge Demo Center, Room 1",
        "experience_label": "5 years experience",
        "phone_number_demo": DEMO_PROVIDER_PHONES[
            "therapist.yazan.demo@neurobridge.local"
        ],
        "rating_average": 4.5,
        "rating_count": 9,
    },
}

# Fields every demo provider profile must have. Used for idempotent backfill so
# re-seeding an older DB fills in any missing values (and swaps the legacy
# placeholder phone for a realistic demo contact number).
_REQUIRED_PROFILE_FIELDS = (
    "specialty",
    "experience_label",
    "governorate",
    "city",
    "location",
    "phone_number_demo",
    "rating_average",
    "rating_count",
)

# email -> list of (day_offset, start, end, mode, room). Rooms are demo-only.
DEMO_PROVIDER_SLOTS = {
    "doctor.demo@neurobridge.local": [
        (2, "10:00", "10:30", "in_person", "Room 3"),
        (2, "11:00", "11:30", "online", None),
        (4, "09:30", "10:00", "in_person", "Room 3"),
    ],
    "therapist.demo@neurobridge.local": [
        (3, "14:00", "14:45", "online", None),
        (3, "15:00", "15:45", "in_person", "Room 5"),
        (5, "13:00", "13:45", "in_person", "Room 5"),
    ],
    "dr.lina.demo@neurobridge.local": [
        (2, "09:00", "09:30", "in_person", "Room 2"),
        (3, "10:30", "11:00", "online", None),
        (5, "09:00", "09:30", "in_person", "Room 2"),
    ],
    "dr.sara.demo@neurobridge.local": [
        (3, "11:30", "12:00", "in_person", "Room 1"),
        (4, "12:30", "13:00", "online", None),
        (6, "10:00", "10:30", "in_person", "Room 1"),
    ],
    "therapist.omar.demo@neurobridge.local": [
        (2, "16:00", "16:45", "online", None),
        (4, "14:00", "14:45", "in_person", "Room 6"),
    ],
    "dr.kareem.demo@neurobridge.local": [
        (2, "08:30", "09:00", "in_person", "Room 4"),
        (3, "09:30", "10:00", "online", None),
    ],
    "therapist.dana.demo@neurobridge.local": [
        (3, "13:00", "13:45", "in_person", "Room 2"),
        (5, "14:00", "14:45", "online", None),
    ],
    "dr.hala.demo@neurobridge.local": [
        (2, "10:00", "10:30", "in_person", "Room 3"),
        (4, "11:00", "11:30", "online", None),
    ],
    "therapist.yazan.demo@neurobridge.local": [
        (3, "15:30", "16:15", "in_person", "Room 1"),
        (6, "12:00", "12:45", "online", None),
    ],
}

MEETING_URLS = {
    "doctor.demo@neurobridge.local": "https://meet.neurobridge.local/demo-doctor",
    "therapist.demo@neurobridge.local": "https://meet.neurobridge.local/demo-therapist",
    "dr.lina.demo@neurobridge.local": "https://meet.neurobridge.local/demo-lina",
    "dr.sara.demo@neurobridge.local": "https://meet.neurobridge.local/demo-sara",
    "therapist.omar.demo@neurobridge.local": "https://meet.neurobridge.local/demo-omar",
    "dr.kareem.demo@neurobridge.local": "https://meet.neurobridge.local/demo-kareem",
    "therapist.dana.demo@neurobridge.local": "https://meet.neurobridge.local/demo-dana",
    "dr.hala.demo@neurobridge.local": "https://meet.neurobridge.local/demo-hala",
    "therapist.yazan.demo@neurobridge.local": "https://meet.neurobridge.local/demo-yazan",
}

# LOCAL DEV ONLY fake care/safety details for the demo patient. These are
# non-diagnostic care details only — never analyzed, scored, or interpreted.
DEMO_CARE = {
    "allergies": "Penicillin",
    "current_medications": "Not provided",
    "blood_type": "O+",
    "mobility_needs": "Needs walking support",
    "vision_hearing_needs": "Uses reading glasses",
    "preferred_communication": "Speak slowly and clearly",
    "caregiver_notes": "Prefers morning activities",
}


# LOCAL DEV ONLY fake Memory Album entries for the demo patient. These are
# supportive/family-engagement memories only — never analyzed or interpreted.
# Uploaded by the demo family member. media_url is left empty (placeholder).
DEMO_MEMORIES = [
    {
        "title": "Family picnic at the park",
        "description": "A sunny afternoon by the lake with the whole family.",
        "person_name": "Layla",
        "relationship": "daughter",
        "place_name": "Al-Nafoura Park",
        "category": "family",
        "media_type": "text",
        "media_url": None,
    },
    {
        "title": "Wedding day photo",
        "description": "A treasured photo from the wedding celebration.",
        "person_name": "Omar",
        "relationship": "son",
        "place_name": "Home",
        "category": "milestone",
        "media_type": "text",
        "media_url": None,
    },
]


def _backfill_care(profile) -> bool:
    """Set demo care fields only where currently missing/empty."""
    changed = False
    for key, value in DEMO_CARE.items():
        current = getattr(profile, key, None)
        if current is None or (isinstance(current, str) and not current.strip()):
            setattr(profile, key, value)
            changed = True
    return changed


def _get_or_create_center(session: Session) -> Tuple[MedicalCenter, bool]:
    existing = session.execute(
        select(MedicalCenter).where(
            MedicalCenter.name == DEMO_CENTER_NAME,
            MedicalCenter.deleted_at.is_(None),
        )
    ).scalar_one_or_none()
    if existing is not None:
        return existing, False
    center = MedicalCenter(
        name=DEMO_CENTER_NAME,
        address="Local demo — not a real facility.",
    )
    session.add(center)
    session.flush()
    return center, True


def _get_or_create_user(
    session: Session, *, email: str, full_name: str, center_id
) -> Tuple[User, bool]:
    existing = session.execute(
        select(User).where(User.email == email, User.deleted_at.is_(None))
    ).scalar_one_or_none()
    if existing is not None:
        return existing, False
    user = User(
        full_name=full_name,
        email=email,
        password_hash=hash_password(DEMO_PASSWORD),
        preferred_language="en",
        status="active",
        medical_center_id=center_id,
    )
    session.add(user)
    session.flush()
    return user, True


def _ensure_role(session: Session, user: User, role_name: str) -> None:
    role = session.execute(
        select(Role).where(Role.name == role_name)
    ).scalar_one()
    existing = session.execute(
        select(UserRole).where(
            UserRole.user_id == user.id, UserRole.role_id == role.id
        )
    ).scalar_one_or_none()
    if existing is None:
        session.add(UserRole(user_id=user.id, role_id=role.id))


def _get_or_create_profile(
    session: Session, user: User, center_id
) -> Tuple[PatientProfile, bool]:
    existing = session.execute(
        select(PatientProfile).where(
            PatientProfile.user_id == user.id,
            PatientProfile.deleted_at.is_(None),
        )
    ).scalar_one_or_none()
    if existing is not None:
        return existing, False
    profile = PatientProfile(user_id=user.id, medical_center_id=center_id)
    session.add(profile)
    session.flush()
    return profile, True


def _ensure_family_link(
    session: Session, profile: PatientProfile, family_user: User
) -> bool:
    existing = session.execute(
        select(PatientFamilyLink).where(
            PatientFamilyLink.patient_profile_id == profile.id,
            PatientFamilyLink.family_user_id == family_user.id,
        )
    ).scalar_one_or_none()
    if existing is not None:
        return False
    session.add(
        PatientFamilyLink(
            patient_profile_id=profile.id,
            family_user_id=family_user.id,
            relationship="caregiver",
            active=True,
        )
    )
    return True


def _ensure_demo_memories(
    session: Session, profile: PatientProfile, uploader: User
) -> int:
    """Create demo Memory Album entries that don't already exist. Returns count."""
    created = 0
    for data in DEMO_MEMORIES:
        existing = session.execute(
            select(MemoryEntry).where(
                MemoryEntry.patient_profile_id == profile.id,
                MemoryEntry.title == data["title"],
                MemoryEntry.deleted_at.is_(None),
            )
        ).scalar_one_or_none()
        if existing is not None:
            continue
        session.add(
            MemoryEntry(
                patient_profile_id=profile.id,
                uploaded_by_user_id=uploader.id,
                **data,
            )
        )
        created += 1
    return created


def _ensure_provider_profiles(
    session: Session, providers_by_email: Dict[str, User]
) -> Tuple[int, int]:
    """Create/refresh demo provider profiles (idempotent by provider).

    New providers get a full demo profile. Existing profiles are left as-is
    except that any missing required field is backfilled and the old placeholder
    demo phone (+970-000-000-000) is replaced with a realistic demo contact
    number, so every provider always has a non-empty demo phone.

    Returns (created, updated).
    """
    created = 0
    updated = 0
    for email, fields in DEMO_PROVIDER_PROFILES.items():
        provider = providers_by_email.get(email)
        if provider is None:
            continue
        existing = session.execute(
            select(ProviderProfile).where(
                ProviderProfile.provider_user_id == provider.id
            )
        ).scalar_one_or_none()
        if existing is None:
            session.add(ProviderProfile(provider_user_id=provider.id, **fields))
            created += 1
            continue

        changed = False
        for key in _REQUIRED_PROFILE_FIELDS:
            desired = fields.get(key)
            if desired is None:
                continue
            current = getattr(existing, key, None)
            is_empty = current is None or (
                isinstance(current, str) and not current.strip()
            )
            is_legacy_phone = (
                key == "phone_number_demo" and current == LEGACY_DEMO_PHONE
            )
            if is_empty or is_legacy_phone:
                setattr(existing, key, desired)
                changed = True
        if changed:
            session.add(existing)
            updated += 1
    return created, updated


def _ensure_availability_slots(
    session: Session, providers_by_email: Dict[str, User]
) -> int:
    """Create clean demo booking slots for each demo provider.

    Dates are relative (next few days) so slots are always in the future.
    Idempotent by (provider, slot_date, start_time). Returns count created.
    """
    created = 0
    for email, plans in DEMO_PROVIDER_SLOTS.items():
        provider = providers_by_email.get(email)
        if provider is None:
            continue
        for day_offset, start, end, mode, room in plans:
            slot_date = date.today() + timedelta(days=day_offset)
            existing = session.execute(
                select(ProviderAvailabilitySlot).where(
                    ProviderAvailabilitySlot.provider_user_id == provider.id,
                    ProviderAvailabilitySlot.slot_date == slot_date,
                    ProviderAvailabilitySlot.start_time == start,
                )
            ).scalar_one_or_none()
            if existing is not None:
                continue
            location = f"NeuroBridge Demo Center, {room}" if room else None
            meeting_url = MEETING_URLS.get(email) if mode == "online" else None
            session.add(
                ProviderAvailabilitySlot(
                    provider_user_id=provider.id,
                    slot_date=slot_date,
                    start_time=start,
                    end_time=end,
                    appointment_mode=mode,
                    location=location,
                    meeting_url=meeting_url,
                    is_available=True,
                )
            )
            created += 1
    return created


def _ensure_assignment(
    session: Session,
    profile: PatientProfile,
    clinician: User,
    assignment_type: str,
) -> bool:
    existing = session.execute(
        select(PatientAssignment).where(
            PatientAssignment.patient_profile_id == profile.id,
            PatientAssignment.clinician_user_id == clinician.id,
            PatientAssignment.assignment_type == assignment_type,
        )
    ).scalar_one_or_none()
    if existing is not None:
        return False
    session.add(
        PatientAssignment(
            patient_profile_id=profile.id,
            clinician_user_id=clinician.id,
            assignment_type=assignment_type,
            active=True,
        )
    )
    return True


def seed_demo_data(session: Session) -> Dict[str, object]:
    """Create/reuse demo roles, games, users, and relationships."""
    seed_roles(session)
    games_result = seed_games(session)

    center, center_created = _get_or_create_center(session)

    users: Dict[str, User] = {}
    user_status: Dict[str, str] = {}
    for email, full_name, role in DEMO_USERS:
        user, created = _get_or_create_user(
            session, email=email, full_name=full_name, center_id=center.id
        )
        users[role] = user
        user_status[email] = "created" if created else "reused"

    for email, _full_name, role in DEMO_USERS:
        _ensure_role(session, users[role], role)

    profile, profile_created = _get_or_create_profile(
        session, users["patient"], center.id
    )
    care_backfilled = _backfill_care(profile)
    if care_backfilled:
        session.add(profile)
    family_created = _ensure_family_link(session, profile, users["family"])
    doctor_created = _ensure_assignment(session, profile, users["doctor"], "doctor")
    therapist_created = _ensure_assignment(
        session, profile, users["therapist"], "therapist"
    )
    memories_created = _ensure_demo_memories(session, profile, users["family"])

    # Bookable demo providers: the core doctor/therapist plus extra demo
    # providers (local demo accounts only), keyed by email.
    providers_by_email: Dict[str, User] = {
        "doctor.demo@neurobridge.local": users["doctor"],
        "therapist.demo@neurobridge.local": users["therapist"],
    }
    for email, full_name, role in DEMO_EXTRA_PROVIDERS:
        provider_user, created = _get_or_create_user(
            session, email=email, full_name=full_name, center_id=center.id
        )
        user_status[email] = "created" if created else "reused"
        _ensure_role(session, provider_user, role)
        providers_by_email[email] = provider_user

    profiles_created, profiles_updated = _ensure_provider_profiles(
        session, providers_by_email
    )
    slots_created = _ensure_availability_slots(session, providers_by_email)

    session.commit()

    return {
        "center": "created" if center_created else "reused",
        "users": user_status,
        "profile": "created" if profile_created else "reused",
        "care_info": "backfilled" if care_backfilled else "already set",
        "family_link": "created" if family_created else "reused",
        "doctor_assignment": "created" if doctor_created else "reused",
        "therapist_assignment": "created" if therapist_created else "reused",
        "memories": memories_created,
        "provider_profiles": profiles_created,
        "provider_profiles_updated": profiles_updated,
        "availability_slots": slots_created,
        "games": games_result,
    }


def main() -> None:
    from app.db.session import SessionLocal

    session = SessionLocal()
    try:
        result = seed_demo_data(session)
    finally:
        session.close()

    print("Medical center: " + str(result["center"]))
    print("Users:")
    for email, status in result["users"].items():  # type: ignore[union-attr]
        print(f"  {email}: {status}")
    print("Patient profile: " + str(result["profile"]))
    print("Care & safety demo info: " + str(result["care_info"]))
    print("Family link (patient.demo <- family.demo): " + str(result["family_link"]))
    print("Doctor assignment: " + str(result["doctor_assignment"]))
    print("Therapist assignment: " + str(result["therapist_assignment"]))
    print("Memory Album demo entries created: " + str(result["memories"]))
    print("Provider profiles created: " + str(result["provider_profiles"]))
    print(
        "Provider profiles updated (backfill/phone): "
        + str(result["provider_profiles_updated"])
    )
    print("Provider availability slots created: " + str(result["availability_slots"]))
    games = result["games"]
    print(
        "Games created: "
        + (", ".join(games["created"]) if games["created"] else "(none)")  # type: ignore[index]
    )

    print()
    print("=" * 64)
    print(" LOCAL DEVELOPMENT DEMO CREDENTIALS - do NOT use in production")
    print("=" * 64)
    print(f" Password for ALL demo users: {DEMO_PASSWORD}")
    for email, _full_name, role in DEMO_USERS:
        print(f"  {email:<34} ({role})")
    print("=" * 64)
    print(" These are fake local test accounts. No real patient data.")


if __name__ == "__main__":
    main()
