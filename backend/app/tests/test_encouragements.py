"""Family encouragement tests.

Reuses the isolated in-memory DB fixtures from conftest. Encouragements are
family support content only — never medical advice, diagnosis, or assessment.
"""

import pytest
from sqlalchemy import select

from app.models import AuditLog
from app.scripts.seed_roles import seed_roles

PASSWORD = "Secret123!"
MESSAGE = "Thinking of you — stay strong!"


@pytest.fixture()
def seeded_roles(db_session):
    seed_roles(db_session)


@pytest.fixture()
def admin_headers(client, db_session, user_factory, seeded_roles):
    user_factory(email="admin@example.test", roles=("admin",))
    return _login(client, "admin@example.test")


def _login(client, email):
    resp = client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": email, "password": PASSWORD},
    )
    assert resp.status_code == 200, resp.text
    return {"Authorization": f"Bearer {resp.json()['access_token']}"}


def _create_patient(client, admin_headers, user_factory, email):
    user = user_factory(email=email, roles=("patient",))
    resp = client.post(
        "/api/v1/patients", headers=admin_headers, json={"user_id": str(user.id)}
    )
    assert resp.status_code == 201, resp.text
    return user, resp.json()


def _link_family(client, admin_headers, user_factory, profile_id, email):
    family = user_factory(email=email, roles=("family",))
    resp = client.post(
        f"/api/v1/patients/{profile_id}/link-family",
        headers=admin_headers,
        json={"family_user_id": str(family.id)},
    )
    assert resp.status_code == 201, resp.text
    return family


def _send(client, headers, patient_profile_id, message=MESSAGE):
    return client.post(
        "/api/v1/encouragements",
        headers=headers,
        json={"patient_profile_id": patient_profile_id, "message": message},
    )


# --- creation / RBAC ---------------------------------------------------------


def test_unauthenticated_blocked(client, seeded_roles):
    assert client.get("/api/v1/encouragements").status_code == 401
    assert (
        client.post(
            "/api/v1/encouragements",
            json={
                "patient_profile_id": "00000000-0000-0000-0000-000000000000",
                "message": "hi",
            },
        ).status_code
        == 401
    )


def test_linked_family_can_create(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    headers = _login(client, "fam@example.test")

    resp = _send(client, headers, profile["id"])
    assert resp.status_code == 201, resp.text
    data = resp.json()
    assert data["message"] == MESSAGE
    assert data["patient_profile_id"] == profile["id"]


def test_unlinked_family_cannot_create(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    user_factory(email="fam@example.test", roles=("family",))
    headers = _login(client, "fam@example.test")

    resp = _send(client, headers, profile["id"])
    assert resp.status_code == 403


def test_patient_cannot_create(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    headers = _login(client, "p@example.test")

    resp = _send(client, headers, profile["id"])
    assert resp.status_code == 403


def test_empty_message_rejected(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    headers = _login(client, "fam@example.test")

    resp = _send(client, headers, profile["id"], message="   ")
    assert resp.status_code == 422


# --- visibility --------------------------------------------------------------


def test_patient_sees_received(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    fam_headers = _login(client, "fam@example.test")
    sent = _send(client, fam_headers, profile["id"]).json()

    patient_headers = _login(client, "p@example.test")
    resp = client.get("/api/v1/encouragements", headers=patient_headers)
    assert resp.status_code == 200
    ids = {e["id"] for e in resp.json()["encouragements"]}
    assert sent["id"] in ids


def test_family_sees_linked(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    fam_headers = _login(client, "fam@example.test")
    sent = _send(client, fam_headers, profile["id"]).json()

    resp = client.get("/api/v1/encouragements", headers=fam_headers)
    assert resp.status_code == 200
    ids = {e["id"] for e in resp.json()["encouragements"]}
    assert sent["id"] in ids


def test_unlinked_family_cannot_see(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    fam_headers = _login(client, "fam@example.test")
    sent = _send(client, fam_headers, profile["id"]).json()

    user_factory(email="fam2@example.test", roles=("family",))
    other_headers = _login(client, "fam2@example.test")
    resp = client.get("/api/v1/encouragements", headers=other_headers)
    assert resp.status_code == 200
    ids = {e["id"] for e in resp.json()["encouragements"]}
    assert sent["id"] not in ids


# --- audit -------------------------------------------------------------------


def test_audit_log_created(client, admin_headers, user_factory, db_session):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    fam_headers = _login(client, "fam@example.test")
    _send(client, fam_headers, profile["id"])

    db_session.rollback()
    actions = db_session.execute(select(AuditLog.action)).scalars().all()
    assert "create_family_encouragement" in actions
