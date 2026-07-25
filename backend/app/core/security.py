"""Security primitives for the NeuroBridge backend.

Phase 4: password hashing only. Passwords are hashed with bcrypt and only the
hash is ever stored (in `users.password_hash`). Plain-text passwords are never
stored or logged.

bcrypt is used directly (rather than via passlib) because passlib 1.7.x
mis-detects the bcrypt >= 4.1 backend version on Python 3.12 and emits noisy
errors. bcrypt's API is small and stable.

Note: bcrypt hashes at most the first 72 bytes of a password.
"""

import bcrypt


def hash_password(password: str) -> str:
    """Return a salted bcrypt hash for the given plain-text password."""
    hashed = bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt())
    return hashed.decode("utf-8")


def verify_password(password: str, password_hash: str) -> bool:
    """Return True if the plain-text password matches the stored bcrypt hash.

    Returns False (never raises) for malformed/empty hashes so callers can treat
    any failure as an authentication failure.
    """
    if not password_hash:
        return False
    try:
        return bcrypt.checkpw(password.encode("utf-8"), password_hash.encode("utf-8"))
    except (ValueError, TypeError):
        return False
