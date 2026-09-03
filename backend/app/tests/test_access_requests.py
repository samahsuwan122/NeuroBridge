"""Public access-request tests.

Covers the public submit endpoint (no auth, stores a pending request only, never
creates an account) and the admin-only list/update endpoints. Reuses the
isolated in-memory DB fixtures from conftest.
"""

import pytest
from sqlalchemy import func, select

from app.models import AccessRequest, AuditLog, User

PASSWORD = "Secret123!"

VALID = {
    "full_name": "Sara Ali",
    "email": "sara@example.test",
    "phone": "0590000000",
    "requested_role": "doctor",
    "organization": "An-Najah",
    "message": "I would like to review the doctor portal.",
}


@pytest.fixture()
def admin_headers(client, db_session, user_factory):
    user_factory(email="admin@example.test", roles=("admin",))
    return _login(client, "admin@example.test")


def _login(client, email):
    resp = client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": email, "password": PASSWORD},
    )
    assert resp.status_code == 200, resp.text
    return {"Authorization": f"Bearer {resp.json()['access_token']}"}


def _submit(client, **overrides):
    body = {**VALID, **overrides}
    return client.post("/api/v1/access-requests", json=body)


# --- public submit -----------------------------------------------------------


def test_public_can_submit_without_auth(client):
    resp = _submit(client)
    assert resp.status_code == 201, resp.text
    data = resp.json()
    assert data["success"] is True
    assert "review" in data["message"].lower()
    assert data["id"]
    # No password/token leaked back to the public caller.
    blob = str(data).lower()
    assert "password" not in blob and "token" not in blob


def test_public_submit_stores_pending_no_account(client, db_session):
    _submit(client, email="newperson@example.test")
    db_session.rollback()
    req = db_session.execute(
        select(AccessRequest).where(AccessRequest.email == "newperson@example.test")
    ).scalar_one()
    assert req.status == "pending"
    assert req.requested_role == "doctor"
    # Crucially: NO user account was created from the public submission.
    users = db_session.execute(
        select(func.count()).select_from(User).where(User.email == "newperson@example.test")
    ).scalar_one()
    assert users == 0


def test_invalid_role_rejected(client):
    assert _submit(client, requested_role="superuser").status_code == 400


def test_missing_name_or_bad_email_rejected(client):
    assert _submit(client, full_name="").status_code == 422
    assert _submit(client, email="not-an-email").status_code == 422


def test_role_is_normalized(client, db_session):
    _submit(client, email="caps@example.test", requested_role="Family")
    db_session.rollback()
    req = db_session.execute(
        select(AccessRequest).where(AccessRequest.email == "caps@example.test")
    ).scalar_one()
    assert req.requested_role == "family"


def test_audit_log_created_for_submit(client, db_session):
    _submit(client)
    db_session.rollback()
    actions = db_session.execute(select(AuditLog.action)).scalars().all()
    assert "create_access_request" in actions


# --- admin list / update -----------------------------------------------------


def test_list_requires_admin(client, db_session, user_factory):
    _submit(client)
    assert client.get("/api/v1/access-requests").status_code == 401
    user_factory(email="patient@example.test", roles=("patient",))
    patient_headers = _login(client, "patient@example.test")
    assert client.get("/api/v1/access-requests", headers=patient_headers).status_code == 403


def test_admin_can_list_and_filter(client, admin_headers):
    _submit(client, email="a@example.test", requested_role="doctor")
    _submit(client, email="b@example.test", requested_role="family")
    resp = client.get("/api/v1/access-requests", headers=admin_headers)
    assert resp.status_code == 200
    assert resp.json()["total"] >= 2
    # Filter by status.
    resp = client.get("/api/v1/access-requests?status=pending", headers=admin_headers)
    assert resp.status_code == 200
    assert all(r["status"] == "pending" for r in resp.json()["requests"])


def test_admin_updates_status_and_note(client, admin_headers):
    created = _submit(client, email="review@example.test").json()
    resp = client.patch(
        f"/api/v1/access-requests/{created['id']}",
        headers=admin_headers,
        json={"status": "accepted", "admin_note": "Verified; onboarding."},
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["status"] == "accepted"
    assert resp.json()["admin_note"] == "Verified; onboarding."


def test_invalid_status_rejected(client, admin_headers):
    created = _submit(client, email="review2@example.test").json()
    resp = client.patch(
        f"/api/v1/access-requests/{created['id']}",
        headers=admin_headers,
        json={"status": "approved-maybe"},
    )
    assert resp.status_code == 400


def test_non_admin_cannot_update(client, admin_headers, user_factory):
    created = _submit(client, email="review3@example.test").json()
    user_factory(email="fam@example.test", roles=("family",))
    fam_headers = _login(client, "fam@example.test")
    resp = client.patch(
        f"/api/v1/access-requests/{created['id']}",
        headers=fam_headers,
        json={"status": "accepted"},
    )
    assert resp.status_code == 403
