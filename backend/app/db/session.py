"""SQLAlchemy engine and session setup for the NeuroBridge backend.

The active database is chosen entirely by `DATABASE_URL` (from settings):
- Local development defaults to SQLite (no server required).
- PostgreSQL is the official database; point `DATABASE_URL` at it to use it.

Credentials are never logged here. The engine connects lazily (creating it does
not open a connection or create any database file).
"""

from collections.abc import Generator

from sqlalchemy import create_engine
from sqlalchemy.engine import Engine
from sqlalchemy.orm import Session, sessionmaker

from app.core.config import get_settings


def _make_engine() -> Engine:
    """Create the SQLAlchemy engine from the configured DATABASE_URL."""
    url = get_settings().database_url
    # SQLite needs check_same_thread=False to be usable from the dev server/tests.
    connect_args = {"check_same_thread": False} if url.startswith("sqlite") else {}
    return create_engine(url, connect_args=connect_args, future=True, echo=False)


# Module-level engine and session factory.
engine: Engine = _make_engine()

SessionLocal = sessionmaker(
    bind=engine,
    autoflush=False,
    autocommit=False,
    expire_on_commit=False,
    class_=Session,
)


def get_db() -> Generator[Session, None, None]:
    """FastAPI-style dependency that yields a database session.

    Not wired into any endpoint yet (no business APIs in Phase 3); provided as
    foundation for later phases.
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
