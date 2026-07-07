"""Role constants and framework-agnostic RBAC helpers.

This module has no FastAPI dependencies — it only defines the canonical role
names and pure helpers. The FastAPI guard dependencies live in
`app.modules.auth.dependencies`.
"""

from typing import Iterable

# Canonical role names (must match the seeded roles in app.scripts.seed_roles).
ROLE_PATIENT = "patient"
ROLE_FAMILY = "family"
ROLE_DOCTOR = "doctor"
ROLE_THERAPIST = "therapist"
ROLE_ADMIN = "admin"
ROLE_MANAGER = "manager"

ALL_ROLES = frozenset(
    {
        ROLE_PATIENT,
        ROLE_FAMILY,
        ROLE_DOCTOR,
        ROLE_THERAPIST,
        ROLE_ADMIN,
        ROLE_MANAGER,
    }
)

# Convenience groupings for common guard combinations used in later phases.
CLINICAL_ROLES = frozenset({ROLE_DOCTOR, ROLE_THERAPIST})


def has_any_role(user_roles: Iterable[str], required_roles: Iterable[str]) -> bool:
    """Return True if the user has at least one of the required roles."""
    return bool(set(user_roles) & set(required_roles))
