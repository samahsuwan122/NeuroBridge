"""Shared pytest fixtures for the NeuroBridge backend.

Provides an isolated in-memory SQLite database per test, a TestClient with the
`get_db` dependency overridden to that database, and a `user_factory` for
creating users with hashed passwords and roles.

Two test-only guarded routes are registered here so that `require_roles` can be
exercised end-to-end. Because they live in conftest (imported only by pytest),
they never exist in the production app served by `uvicorn app.main:app`.
"""

import pytest
from fastapi import Depends
from fastapi.testclient import TestClient
from sqlalchemy import create_engine, select
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.security import hash_password
from app.db.base import Base
from app.db.session import get_db
from app.main import app
from app.models import Role, User, UserRole  # noqa: F401 (registers metadata)
from app.modules.auth.dependencies import require_roles

# --- test-only guarded routes (pytest-only; not in the production app) -------


@app.get("/api/v1/_test/doctor-only")
def _doctor_only(_user=Depends(require_roles(["doctor", "therapist"]))):
    return {"ok": True}


@app.get("/api/v1/_test/patient-only")
def _patient_only(_user=Depends(require_roles(["patient"]))):
    return {"ok": True}


# --- database / client fixtures ----------------------------------------------


@pytest.fixture()
def engine():
    eng = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(eng)
    try:
        yield eng
    finally:
        eng.dispose()


@pytest.fixture()
def session_factory(engine):
    return sessionmaker(
        bind=engine, autoflush=False, autocommit=False, expire_on_commit=False
    )


@pytest.fixture()
def db_session(session_factory):
    session = session_factory()
    try:
        yield session
    finally:
        session.close()


@pytest.fixture()
def client(session_factory):
    def override_get_db():
        db = session_factory()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    try:
        with TestClient(app) as test_client:
            yield test_client
    finally:
        app.dependency_overrides.pop(get_db, None)


@pytest.fixture()
def user_factory(db_session):
    """Return a function that creates a user (hashed password) with roles."""

    def _create(
        *,
        email=None,
        phone=None,
        password="Secret123!",
        status="active",
        full_name="Test User",
        roles=(),
    ) -> User:
        user = User(
            full_name=full_name,
            email=email,
            phone=phone,
            password_hash=hash_password(password),
            status=status,
            preferred_language="en",
        )
        db_session.add(user)
        db_session.flush()

        for role_name in roles:
            role = db_session.execute(
                select(Role).where(Role.name == role_name)
            ).scalar_one_or_none()
            if role is None:
                role = Role(name=role_name)
                db_session.add(role)
                db_session.flush()
            db_session.add(UserRole(user_id=user.id, role_id=role.id))

        db_session.commit()
        return user

    return _create
