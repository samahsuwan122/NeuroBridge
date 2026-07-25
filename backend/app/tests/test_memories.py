"""Phase 17 Memory Album tests.

Reuses the isolated in-memory DB fixtures from conftest (client, db_session,
user_factory). Roles are seeded; users/profiles/relationships are created via
the existing APIs.

Memory Album is supportive/family-engagement content only — no diagnosis,
scoring, or medical interpretation.
"""

import pytest
from sqlalchemy import select

from app.models import AuditLog
from app.scripts.seed_roles import seed_roles

PASSWORD = "Secret123!"

SAMPLE_MEMORY = {
    "title": "Family picnic",
    "description": "A sunny afternoon by the lake.",
    "person_name": "Layla",
    "relationship": "daughter",
    "place_name": "City Park",
    "category": "family",
    "media_type": "text",
}


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


def _assign_doctor(client, admin_headers, user_factory, profile_id, email):
    doctor = user_factory(email=email, roles=("doctor",))
    resp = client.post(
        f"/api/v1/patients/{profile_id}/assign-clinician",
        headers=admin_headers,
        json={"clinician_user_id": str(doctor.id), "assignment_type": "doctor"},
    )
    assert resp.status_code == 201, resp.text
    return doctor


def _create_memory(client, headers, patient_profile_id, **overrides):
    body = {"patient_profile_id": patient_profile_id, **SAMPLE_MEMORY, **overrides}
    return client.post("/api/v1/memories", headers=headers, json=body)


# --- creation / access -------------------------------------------------------


def test_unauthenticated_cannot_list_or_create(client, seeded_roles):
    assert client.get("/api/v1/memories").status_code == 401
    assert client.post(
        "/api/v1/memories",
        json={"patient_profile_id": "00000000-0000-0000-0000-000000000000",
              "title": "x"},
    ).status_code == 401


def test_linked_family_can_create_memory(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    headers = _login(client, "fam@example.test")

    resp = _create_memory(client, headers, profile["id"])
    assert resp.status_code == 201, resp.text
    data = resp.json()
    assert data["title"] == "Family picnic"
    assert data["patient_profile_id"] == profile["id"]


def test_patient_can_create_own_memory(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    headers = _login(client, "p@example.test")

    resp = _create_memory(client, headers, profile["id"], title="My trip")
    assert resp.status_code == 201, resp.text
    assert resp.json()["title"] == "My trip"


def test_admin_can_create_memory(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    resp = _create_memory(client, admin_headers, profile["id"])
    assert resp.status_code == 201, resp.text


def test_unlinked_family_cannot_create(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    user_factory(email="fam@example.test", roles=("family",))
    headers = _login(client, "fam@example.test")

    resp = _create_memory(client, headers, profile["id"])
    assert resp.status_code == 403


def test_doctor_cannot_create_even_when_assigned(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _assign_doctor(client, admin_headers, user_factory, profile["id"], "doc@example.test")
    headers = _login(client, "doc@example.test")

    resp = _create_memory(client, headers, profile["id"])
    assert resp.status_code == 403


# --- visibility --------------------------------------------------------------


def _seed_memory(client, admin_headers, user_factory, email):
    _, profile = _create_patient(client, admin_headers, user_factory, email)
    headers = _login(client, email)
    memory = _create_memory(client, headers, profile["id"]).json()
    return profile, memory


def test_patient_sees_own_memories(client, admin_headers, user_factory):
    profile, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    headers = _login(client, "p@example.test")
    resp = client.get("/api/v1/memories", headers=headers)
    assert resp.status_code == 200
    ids = {m["id"] for m in resp.json()["memories"]}
    assert memory["id"] in ids


def test_admin_sees_all_memories(client, admin_headers, user_factory):
    _, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    resp = client.get("/api/v1/memories", headers=admin_headers)
    assert resp.status_code == 200
    assert resp.json()["total"] >= 1


def test_family_sees_linked_memories(client, admin_headers, user_factory):
    profile, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    headers = _login(client, "fam@example.test")
    resp = client.get("/api/v1/memories", headers=headers)
    assert resp.status_code == 200
    ids = {m["id"] for m in resp.json()["memories"]}
    assert memory["id"] in ids


def test_assigned_doctor_cannot_see_memories(client, admin_headers, user_factory):
    # PRIVACY (Module 5): the Memory Album is private to patient/family. Even a
    # doctor assigned to the patient must not receive raw memory items — via the
    # list or a direct detail fetch.
    profile, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    _assign_doctor(client, admin_headers, user_factory, profile["id"], "doc@example.test")
    headers = _login(client, "doc@example.test")
    resp = client.get("/api/v1/memories", headers=headers)
    assert resp.status_code == 200
    assert memory["id"] not in {m["id"] for m in resp.json()["memories"]}
    assert (
        client.get(f"/api/v1/memories/{memory['id']}", headers=headers).status_code
        == 403
    )


def test_doctor_cannot_see_unassigned_memories(client, admin_headers, user_factory):
    _, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    user_factory(email="doc@example.test", roles=("doctor",))
    headers = _login(client, "doc@example.test")
    resp = client.get("/api/v1/memories", headers=headers)
    assert resp.status_code == 200
    ids = {m["id"] for m in resp.json()["memories"]}
    assert memory["id"] not in ids


def test_unlinked_family_cannot_view_detail(client, admin_headers, user_factory):
    _, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    user_factory(email="fam@example.test", roles=("family",))
    headers = _login(client, "fam@example.test")
    resp = client.get(f"/api/v1/memories/{memory['id']}", headers=headers)
    assert resp.status_code == 403


def test_get_missing_memory_404(client, admin_headers):
    resp = client.get(
        "/api/v1/memories/00000000-0000-0000-0000-000000000000",
        headers=admin_headers,
    )
    assert resp.status_code == 404


# --- update / delete ---------------------------------------------------------


def test_creator_can_update_memory(client, admin_headers, user_factory):
    profile, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    headers = _login(client, "p@example.test")
    resp = client.put(
        f"/api/v1/memories/{memory['id']}",
        headers=headers,
        json={"title": "Updated title", "place_name": "Beach"},
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["title"] == "Updated title"
    assert resp.json()["place_name"] == "Beach"


def test_non_creator_cannot_update(client, admin_headers, user_factory):
    profile, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    # A linked family member (not the creator) may view but not edit.
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    headers = _login(client, "fam@example.test")
    resp = client.put(
        f"/api/v1/memories/{memory['id']}",
        headers=headers,
        json={"title": "Hacked"},
    )
    assert resp.status_code == 403


def test_admin_can_update_any_memory(client, admin_headers, user_factory):
    _, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    resp = client.put(
        f"/api/v1/memories/{memory['id']}",
        headers=admin_headers,
        json={"title": "Admin edit"},
    )
    assert resp.status_code == 200
    assert resp.json()["title"] == "Admin edit"


def test_creator_can_soft_delete(client, admin_headers, user_factory):
    profile, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    headers = _login(client, "p@example.test")
    resp = client.post(f"/api/v1/memories/{memory['id']}/delete", headers=headers)
    assert resp.status_code == 200
    # It no longer appears in listings.
    listed = client.get("/api/v1/memories", headers=headers)
    ids = {m["id"] for m in listed.json()["memories"]}
    assert memory["id"] not in ids


def test_non_creator_cannot_delete(client, admin_headers, user_factory):
    profile, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    headers = _login(client, "fam@example.test")
    resp = client.post(f"/api/v1/memories/{memory['id']}/delete", headers=headers)
    assert resp.status_code == 403


# --- medical safety + audit --------------------------------------------------


def test_memory_response_has_no_diagnostic_fields(client, admin_headers, user_factory):
    _, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    forbidden = {"diagnosis", "disease", "dementia", "alzheimer", "interpretation",
                 "score", "treatment"}
    for key in memory:
        assert not any(bad in key.lower() for bad in forbidden)


def test_audit_log_created_for_memory(client, admin_headers, user_factory, db_session):
    _seed_memory(client, admin_headers, user_factory, "p@example.test")
    db_session.rollback()
    actions = db_session.execute(select(AuditLog.action)).scalars().all()
    assert "create_memory_entry" in actions
