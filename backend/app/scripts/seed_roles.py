"""Seed the six default NeuroBridge roles.

Idempotent: running it multiple times will not create duplicate roles. The core
logic lives in ``seed_roles(session)`` so it can be unit-tested against any
session; ``main()`` opens a real session from the configured database and prints
a summary.

Run from the backend/ folder:

    python -m app.scripts.seed_roles
"""

from typing import Dict, List

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.role import Role

# (name, description) — descriptions are neutral, non-diagnostic labels.
DEFAULT_ROLES: List[tuple[str, str]] = [
    ("patient", "Patient using the mobile app."),
    ("family", "Family member or caregiver linked to a patient."),
    ("doctor", "Doctor responsible for assigned patients."),
    ("therapist", "Therapist responsible for assigned patients."),
    ("admin", "System administrator."),
    ("manager", "Medical center manager."),
]

DEFAULT_ROLE_NAMES: List[str] = [name for name, _ in DEFAULT_ROLES]


def seed_roles(session: Session) -> Dict[str, List[str]]:
    """Create any missing default roles. Returns created/skipped role names."""
    created: List[str] = []
    skipped: List[str] = []

    for name, description in DEFAULT_ROLES:
        existing = session.execute(
            select(Role).where(Role.name == name)
        ).scalar_one_or_none()
        if existing is not None:
            skipped.append(name)
            continue
        session.add(Role(name=name, description=description))
        created.append(name)

    session.commit()
    return {"created": created, "skipped": skipped}


def main() -> None:
    """Seed roles against the configured database and print a summary."""
    from app.db.session import SessionLocal

    session = SessionLocal()
    try:
        result = seed_roles(session)
    finally:
        session.close()

    if result["created"]:
        print(f"Created roles: {', '.join(result['created'])}")
    else:
        print("Created roles: (none)")

    if result["skipped"]:
        print(f"Skipped (already present): {', '.join(result['skipped'])}")
    else:
        print("Skipped (already present): (none)")


if __name__ == "__main__":
    main()
