"""Phase 5 admin user-management tests.

Reuses the isolated in-memory DB fixtures from conftest (client, db_session,
user_factory). Roles are seeded per test; an admin is created and logged in to
obtain a Bearer token.
"""

import uuid

import pytest
from sqlalchemy import select

from app.core.security import verify_password
from app.models import AuditLog, User
from app.scripts.seed_roles import DEFAULT_ROLE_NAMES, seed_roles

PASSWORD = "Secret123!"


@pytest.fixture()
def seeded_roles(db_session):
    seed_roles(db_session)


@pytest.fixture()
def admin_headers(client, db_session, user_factory, seeded_roles):
    user_factory(email="admin@example.test", roles=("admin",))
    resp = client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": "admin@example.test", "password": PASSWORD},
    )
    assert resp.status_code == 200
    return {"Authorization": f"Bearer {resp.json()['access_token']}"}


def _create_payload(**overrides):
    payload = {
        "full_name": "New User",
        "email": "new@example.test",
        "password": PASSWORD,
        "roles": ["patient"],
    }
    payload.update(overrides)
    return payload


# --- access control ----------------------------------------------------------


def test_list_users_requires_authentication(client, seeded_roles):
    resp = client.get("/api/v1/admin/users")
    assert resp.status_code == 401


def test_non_admin_forbidden(client, db_session, user_factory, seeded_roles):
    user_factory(email="patient@example.test", roles=("patient",))
    login = client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": "patient@example.test", "password": PASSWORD},
    )
    headers = {"Authorization": f"Bearer {login.json()['access_token']}"}
    resp = client.get("/api/v1/admin/users", headers=headers)
    assert resp.status_code == 403


def test_admin_can_list_users(client, admin_headers):
    resp = client.get("/api/v1/admin/users", headers=admin_headers)
    assert resp.status_code == 200
    data = resp.json()
    assert data["success"] is True
    assert data["total"] >= 1  # the admin itself
    assert "limit" in data and "offset" in data
    for user in data["users"]:
        assert "password_hash" not in user
        assert "roles" in user


# --- create ------------------------------------------------------------------


def test_admin_can_create_user_with_role(client, admin_headers):
    resp = client.post(
        "/api/v1/admin/users", headers=admin_headers, json=_create_payload(roles=["doctor"])
    )
    assert resp.status_code == 201
    data = resp.json()
    assert data["email"] == "new@example.test"
    assert data["roles"] == ["doctor"]
    assert "password_hash" not in data
    assert data["status"] == "active"


def test_created_user_password_is_hashed(client, admin_headers, db_session):
    resp = client.post(
        "/api/v1/admin/users", headers=admin_headers, json=_create_payload()
    )
    assert resp.status_code == 201
    db_session.rollback()  # read the latest committed state (shared connection)
    user = db_session.execute(
        select(User).where(User.email == "new@example.test")
    ).scalar_one()
    assert user.password_hash is not None
    assert user.password_hash != PASSWORD
    assert verify_password(PASSWORD, user.password_hash)


def test_create_requires_email_or_phone(client, admin_headers):
    resp = client.post(
        "/api/v1/admin/users",
        headers=admin_headers,
        json={"full_name": "No Contact", "password": PASSWORD, "roles": []},
    )
    # Rejected by schema validation (422).
    assert resp.status_code == 422


def test_duplicate_email_rejected(client, admin_headers):
    first = client.post(
        "/api/v1/admin/users", headers=admin_headers, json=_create_payload()
    )
    assert first.status_code == 201
    dup = client.post(
        "/api/v1/admin/users", headers=admin_headers, json=_create_payload()
    )
    assert dup.status_code == 409


def test_duplicate_phone_rejected(client, admin_headers):
    p1 = _create_payload(email=None, phone="+1999", roles=[])
    p2 = _create_payload(email=None, phone="+1999", full_name="Other", roles=[])
    assert client.post("/api/v1/admin/users", headers=admin_headers, json=p1).status_code == 201
    assert client.post("/api/v1/admin/users", headers=admin_headers, json=p2).status_code == 409


def test_unknown_role_rejected(client, admin_headers):
    resp = client.post(
        "/api/v1/admin/users", headers=admin_headers, json=_create_payload(roles=["wizard"])
    )
    assert resp.status_code == 400


# --- update ------------------------------------------------------------------


def _create_user(client, admin_headers, **overrides):
    resp = client.post(
        "/api/v1/admin/users", headers=admin_headers, json=_create_payload(**overrides)
    )
    assert resp.status_code == 201
    return resp.json()


def test_admin_can_update_user(client, admin_headers):
    created = _create_user(client, admin_headers)
    resp = client.put(
        f"/api/v1/admin/users/{created['id']}",
        headers=admin_headers,
        json={"full_name": "Renamed"},
    )
    assert resp.status_code == 200
    assert resp.json()["full_name"] == "Renamed"
    # Unspecified fields are unchanged.
    assert resp.json()["email"] == "new@example.test"


def test_admin_can_replace_roles(client, admin_headers, db_session):
    created = _create_user(client, admin_headers, roles=["doctor"])
    resp = client.put(
        f"/api/v1/admin/users/{created['id']}",
        headers=admin_headers,
        json={"roles": ["therapist", "manager"]},
    )
    assert resp.status_code == 200
    assert sorted(resp.json()["roles"]) == ["manager", "therapist"]


def test_update_unknown_user_404(client, admin_headers):
    resp = client.put(
        "/api/v1/admin/users/00000000-0000-0000-0000-000000000000",
        headers=admin_headers,
        json={"full_name": "Ghost"},
    )
    assert resp.status_code == 404


# --- activate / deactivate ---------------------------------------------------


def _status_of(db_session, user_id: str) -> str:
    db_session.rollback()  # end any open txn so we read the latest committed state
    return db_session.execute(
        select(User.status).where(User.id == uuid.UUID(user_id))
    ).scalar_one()


def test_admin_can_deactivate_and_activate(client, admin_headers, db_session):
    created = _create_user(client, admin_headers)
    user_id = created["id"]

    deactivate = client.post(
        f"/api/v1/admin/users/{user_id}/deactivate", headers=admin_headers
    )
    assert deactivate.status_code == 200
    assert _status_of(db_session, user_id) == "inactive"

    activate = client.post(
        f"/api/v1/admin/users/{user_id}/activate", headers=admin_headers
    )
    assert activate.status_code == 200
    assert _status_of(db_session, user_id) == "active"


# --- roles -------------------------------------------------------------------


def test_admin_can_list_roles(client, admin_headers):
    resp = client.get("/api/v1/admin/roles", headers=admin_headers)
    assert resp.status_code == 200
    names = {r["name"] for r in resp.json()}
    assert set(DEFAULT_ROLE_NAMES).issubset(names)


# --- audit -------------------------------------------------------------------


def _actions(db_session):
    return [
        a for a in db_session.execute(select(AuditLog.action)).scalars().all()
    ]


def test_audit_logs_created_for_admin_actions(client, admin_headers, db_session):
    created = _create_user(client, admin_headers)
    user_id = created["id"]
    client.put(
        f"/api/v1/admin/users/{user_id}",
        headers=admin_headers,
        json={"full_name": "Renamed"},
    )
    client.post(f"/api/v1/admin/users/{user_id}/deactivate", headers=admin_headers)
    client.post(f"/api/v1/admin/users/{user_id}/activate", headers=admin_headers)

    db_session.rollback()  # read the latest committed state (shared connection)
    actions = _actions(db_session)
    for expected in ("create_user", "update_user", "deactivate_user", "activate_user"):
        assert expected in actions

    # Spot-check the create_user audit references the created user.
    create_log = db_session.execute(
        select(AuditLog).where(AuditLog.action == "create_user")
    ).scalars().first()
    assert create_log is not None
    assert create_log.entity_type == "User"
    assert str(create_log.entity_id) == user_id
    assert create_log.actor_user_id is not None
