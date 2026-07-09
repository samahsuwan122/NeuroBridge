"""Seed local demo users and relationships for manual testing.

FOR LOCAL DEVELOPMENT ONLY. Creates non-real demo accounts so the mobile app
can be exercised (login, patient home, games list, Memory Match). Idempotent:
re-running reuses existing records instead of duplicating them.

No real patient data and no medical/diagnostic data are created.

Run from the backend/ folder:

    python -m app.scripts.seed_demo_data
"""

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
