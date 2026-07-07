"""Phase 4 authentication and RBAC tests."""

from sqlalchemy import select

from app.core.security import hash_password, verify_password
from app.models import AuditLog
from app.modules.auth.tokens import create_access_token

VALID_PASSWORD = "Secret123!"


# --- password hashing --------------------------------------------------------


def test_password_hashing_and_verification():
    hashed = hash_password(VALID_PASSWORD)
    assert hashed != VALID_PASSWORD  # never stored in plain text
    assert hashed.startswith("$2")  # bcrypt hash marker
    assert verify_password(VALID_PASSWORD, hashed) is True
    assert verify_password("wrong-password", hashed) is False
    assert verify_password(VALID_PASSWORD, "") is False


# --- login -------------------------------------------------------------------


def test_login_success(client, user_factory):
    user = user_factory(email="patient@example.test", roles=("patient",))

    resp = client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": "patient@example.test", "password": VALID_PASSWORD},
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data["success"] is True
    assert data["token_type"] == "bearer"
    assert data["access_token"]
    assert data["user"]["id"] == str(user.id)
    assert data["user"]["email"] == "patient@example.test"
    assert "password_hash" not in data["user"]
    assert data["roles"] == ["patient"]


def test_login_with_phone_identifier(client, user_factory):
    user_factory(phone="+100000000", roles=("patient",))
    resp = client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": "+100000000", "password": VALID_PASSWORD},
    )
    assert resp.status_code == 200


def test_login_wrong_password(client, user_factory):
    user_factory(email="patient@example.test", roles=("patient",))
    resp = client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": "patient@example.test", "password": "not-it"},
    )
    assert resp.status_code == 401


def test_login_inactive_user(client, user_factory):
    user_factory(email="suspended@example.test", status="suspended", roles=("patient",))
    resp = client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": "suspended@example.test", "password": VALID_PASSWORD},
    )
    assert resp.status_code == 401


def test_login_unknown_user(client):
    resp = client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": "nobody@example.test", "password": VALID_PASSWORD},
    )
    assert resp.status_code == 401


# --- current user (/me) ------------------------------------------------------


def test_me_requires_token(client):
    resp = client.get("/api/v1/auth/me")
    assert resp.status_code == 401


def test_me_with_valid_token(client, user_factory):
    user_factory(email="patient@example.test", roles=("patient",))
    login = client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": "patient@example.test", "password": VALID_PASSWORD},
    )
    token = login.json()["access_token"]

    resp = client.get(
        "/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"}
    )
    assert resp.status_code == 200
    data = resp.json()
    assert data["user"]["email"] == "patient@example.test"
    assert data["roles"] == ["patient"]


def test_me_rejects_garbage_token(client):
    resp = client.get(
        "/api/v1/auth/me", headers={"Authorization": "Bearer not-a-jwt"}
    )
    assert resp.status_code == 401


# --- role guards -------------------------------------------------------------


def _login_token(client, identifier):
    resp = client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": identifier, "password": VALID_PASSWORD},
    )
    assert resp.status_code == 200
    return resp.json()["access_token"]


def test_role_guard_allows_matching_role(client, user_factory):
    user_factory(email="doc@example.test", roles=("doctor",))
    token = _login_token(client, "doc@example.test")
    resp = client.get(
        "/api/v1/_test/doctor-only", headers={"Authorization": f"Bearer {token}"}
    )
    assert resp.status_code == 200
    assert resp.json() == {"ok": True}


def test_role_guard_rejects_wrong_role(client, user_factory):
    user_factory(email="patient@example.test", roles=("patient",))
    token = _login_token(client, "patient@example.test")
    resp = client.get(
        "/api/v1/_test/doctor-only", headers={"Authorization": f"Bearer {token}"}
    )
    assert resp.status_code == 403


# --- refresh -----------------------------------------------------------------


def test_refresh_issues_new_access_token(client, user_factory):
    user_factory(email="patient@example.test", roles=("patient",))
    login = client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": "patient@example.test", "password": VALID_PASSWORD},
    ).json()
    refresh_token = login["refresh_token"]

    resp = client.post("/api/v1/auth/refresh", json={"refresh_token": refresh_token})
    assert resp.status_code == 200
    new_access = resp.json()["access_token"]

    me = client.get(
        "/api/v1/auth/me", headers={"Authorization": f"Bearer {new_access}"}
    )
    assert me.status_code == 200


def test_refresh_rejects_access_token(client, user_factory):
    user = user_factory(email="patient@example.test", roles=("patient",))
    # An access token must not be accepted by the refresh endpoint.
    access = create_access_token(str(user.id), roles=["patient"])
    resp = client.post("/api/v1/auth/refresh", json={"refresh_token": access})
    assert resp.status_code == 401


# --- logout + audit ----------------------------------------------------------


def test_logout_records_audit(client, user_factory, db_session):
    user_factory(email="patient@example.test", roles=("patient",))
    token = _login_token(client, "patient@example.test")
    resp = client.post(
        "/api/v1/auth/logout", headers={"Authorization": f"Bearer {token}"}
    )
    assert resp.status_code == 200
    assert resp.json()["success"] is True

    logout_logs = db_session.execute(
        select(AuditLog).where(AuditLog.action == "logout")
    ).scalars().all()
    assert len(logout_logs) == 1


def test_login_creates_audit_log(client, user_factory, db_session):
    user = user_factory(email="patient@example.test", roles=("patient",))
    client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": "patient@example.test", "password": VALID_PASSWORD},
    )

    logs = db_session.execute(
        select(AuditLog).where(AuditLog.action == "login")
    ).scalars().all()
    assert len(logs) == 1
    log = logs[0]
    assert log.actor_user_id == user.id
    assert log.entity_type == "User"
    assert log.entity_id == user.id
