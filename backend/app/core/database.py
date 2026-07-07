"""Database access helpers for the NeuroBridge backend.

Phase 3: the SQLAlchemy engine, session factory, and `get_db` dependency live in
`app.db.session` and are re-exported here for convenience/backwards
compatibility. This module also exposes small, credential-safe helpers used for
logging/diagnostics.

The active database is chosen entirely by `DATABASE_URL`:
- Local development defaults to SQLite (no server required).
- PostgreSQL is the official database.
"""

from urllib.parse import urlparse

from app.core.config import get_settings
from app.db.session import SessionLocal, engine, get_db  # noqa: F401  (re-export)


def get_database_url() -> str:
    """Return the configured database URL from settings."""
    return get_settings().database_url


def describe_configured_database() -> str:
    """Return the configured database backend name only (no credentials).

    Examples: "sqlite", "postgresql". For a URL like
    "postgresql+psycopg2://..." the base backend ("postgresql") is returned.
    """
    scheme = urlparse(get_database_url()).scheme or "unknown"
    return scheme.split("+", 1)[0]


__all__ = [
    "engine",
    "SessionLocal",
    "get_db",
    "get_database_url",
    "describe_configured_database",
]
