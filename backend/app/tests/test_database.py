"""Phase 3 database foundation tests.

These tests do NOT touch the real dev database. The seed test runs against a
fresh in-memory SQLite database so it is fast and isolated.
"""

import pytest
from sqlalchemy import create_engine, select
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.config import get_settings
from app.core.database import get_database_url
from app.db.base import Base

# Importing the models package registers every table on Base.metadata.
import app.models  # noqa: F401
from app.models import AuditLog, MedicalCenter, Role, User, UserRole
from app.scripts.seed_roles import DEFAULT_ROLE_NAMES, seed_roles

EXPECTED_TABLES = {"users", "roles", "user_roles", "medical_centers", "audit_logs"}


def test_all_models_import():
    """Every model imports and exposes the expected table name."""
    assert User.__tablename__ == "users"
    assert Role.__tablename__ == "roles"
    assert UserRole.__tablename__ == "user_roles"
    assert MedicalCenter.__tablename__ == "medical_centers"
    assert AuditLog.__tablename__ == "audit_logs"


def test_metadata_contains_expected_tables():
    """Base.metadata includes all five foundation tables."""
    assert EXPECTED_TABLES.issubset(set(Base.metadata.tables.keys()))


def test_audit_log_metadata_column_name():
    """The event_metadata attribute maps to the DB column named 'metadata'."""
    assert "metadata" in AuditLog.__table__.columns
    assert AuditLog.event_metadata.property.columns[0].name == "metadata"


def test_database_url_read_from_settings():
    """The database URL is sourced from settings and is non-empty."""
    url = get_database_url()
    assert url
    assert url == get_settings().database_url


@pytest.fixture()
def db_session():
    """Isolated in-memory SQLite session with all tables created."""
    test_engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(test_engine)
    TestingSession = sessionmaker(
        bind=test_engine, autoflush=False, autocommit=False, expire_on_commit=False
    )
    session = TestingSession()
    try:
        yield session
    finally:
        session.close()
        test_engine.dispose()


def test_create_all_builds_foundation_tables(db_session):
    """create_all succeeds despite the users<->medical_centers circular FK."""
    table_names = set(Base.metadata.tables.keys())
    assert EXPECTED_TABLES.issubset(table_names)


def test_seed_roles_is_idempotent(db_session):
    """Seeding twice creates the six roles once and never duplicates them."""
    first = seed_roles(db_session)
    assert set(first["created"]) == set(DEFAULT_ROLE_NAMES)
    assert first["skipped"] == []

    roles_after_first = db_session.scalars(select(Role)).all()
    assert len(roles_after_first) == len(DEFAULT_ROLE_NAMES)

    second = seed_roles(db_session)
    assert second["created"] == []
    assert set(second["skipped"]) == set(DEFAULT_ROLE_NAMES)

    roles_after_second = db_session.scalars(select(Role)).all()
    assert len(roles_after_second) == len(DEFAULT_ROLE_NAMES)
