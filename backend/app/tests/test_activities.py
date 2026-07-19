"""Module 4 care-team activity builder tests.

Covers permissions (who can assign / view / complete) and the activity
lifecycle (assigned -> completed / skipped), plus medical-safety checks on the
generated content. Reuses the isolated in-memory DB fixtures from conftest.
"""

import pytest
from sqlalchemy import select

from app.models import AuditLog

PASSWORD = "Secret123!"

FORBIDDEN = {"diagnosis", "disease", "dementia", "alzheimer", "treatment",
             "prediction", "risk", "score"}


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


def _create_patient(client, admin_headers, user_factory, email):
    user = user_factory(email=email, roles=("patient",))
    resp = client.post(
        "/api/v1/patients", headers=admin_headers, json={"user_id": str(user.id)}
    )
    assert resp.status_code == 201, resp.text
    return user, resp.json()


def _assign_doctor(client, admin_headers, user_factory, profile_id, email="doc@example.test"):
    doctor = user_factory(email=email, roles=("doctor",))
    resp = client.post(
        f"/api/v1/patients/{profile_id}/assign-clinician",
        headers=admin_headers,
        json={"clinician_user_id": str(doctor.id), "assignment_type": "doctor"},
    )
    assert resp.status_code in (200, 201), resp.text
    return doctor, _login(client, email)


def _link_family(client, admin_headers, user_factory, profile_id, email="fam@example.test"):
    family = user_factory(email=email, roles=("family",))
    resp = client.post(
        f"/api/v1/patients/{profile_id}/link-family",
        headers=admin_headers,
        json={"family_user_id": str(family.id)},
    )
    assert resp.status_code in (200, 201), resp.text
    return family, _login(client, email)


def _assign_activity(client, headers, profile_id, **fields):
    body = {
        "patient_profile_id": profile_id,
        "template_type": "memory_recall",
        "difficulty": "easy",
        "duration_minutes": 10,
        **fields,
    }
    return client.post("/api/v1/activities/assign", headers=headers, json=body)


# --- templates ---------------------------------------------------------------


def test_templates_list_has_six_safe_templates(client, admin_headers):
    resp = client.get("/api/v1/activities/templates", headers=admin_headers)
    assert resp.status_code == 200
    data = resp.json()
    types = {t["template_type"] for t in data["templates"]}
    assert types == {
        "memory_recall", "attention_focus", "reaction_time",
        "sequence_recall", "matching_game", "daily_orientation",
    }
    assert set(data["difficulties"]) == {"easy", "medium", "hard"}


# --- assign: permissions -----------------------------------------------------


def test_assigned_doctor_can_assign_activity(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])

    resp = _assign_activity(client, doc_headers, profile["id"], difficulty="medium")
    assert resp.status_code == 201, resp.text
    data = resp.json()
    assert data["template_type"] == "memory_recall"
    assert data["status"] == "assigned"
    assert data["difficulty"] == "medium"
    # Content is generated from the template.
    assert data["generated_content"]["kind"] == "memory_recall"
    assert data["generated_content"]["items"]
    assert data["title"] == "Memory Recall"


def test_unassigned_doctor_cannot_assign(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    user_factory(email="doc2@example.test", roles=("doctor",))
    headers = _login(client, "doc2@example.test")

    resp = _assign_activity(client, headers, profile["id"])
    assert resp.status_code == 403


def test_patient_cannot_assign(client, admin_headers, user_factory):
    patient, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    headers = _login(client, "p@example.test")
    resp = _assign_activity(client, headers, profile["id"])
    assert resp.status_code == 403  # role guard: doctor/therapist only


def test_unknown_template_rejected(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    resp = _assign_activity(client, doc_headers, profile["id"], template_type="hack_template")
    assert resp.status_code == 400


def test_invalid_difficulty_rejected(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    resp = _assign_activity(client, doc_headers, profile["id"], difficulty="impossible")
    assert resp.status_code == 400


# --- view: role-scoped -------------------------------------------------------


def test_patient_sees_own_activities_via_my(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    activity = _assign_activity(client, doc_headers, profile["id"]).json()

    headers = _login(client, "p@example.test")
    resp = client.get("/api/v1/activities/my", headers=headers)
    assert resp.status_code == 200
    ids = {a["id"] for a in resp.json()["activities"]}
    assert activity["id"] in ids


def test_assigned_doctor_lists_patient_activities(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    activity = _assign_activity(client, doc_headers, profile["id"]).json()

    resp = client.get(
        f"/api/v1/activities/patient/{profile['id']}", headers=doc_headers
    )
    assert resp.status_code == 200
    ids = {a["id"] for a in resp.json()["activities"]}
    assert activity["id"] in ids


def test_unassigned_doctor_cannot_list_patient_activities(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _assign_doctor(client, admin_headers, user_factory, profile["id"])
    user_factory(email="doc2@example.test", roles=("doctor",))
    headers = _login(client, "doc2@example.test")
    resp = client.get(f"/api/v1/activities/patient/{profile['id']}", headers=headers)
    assert resp.status_code == 403


def test_linked_family_can_view_activities(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    activity = _assign_activity(client, doc_headers, profile["id"]).json()
    _, fam_headers = _link_family(client, admin_headers, user_factory, profile["id"])

    resp = client.get(
        f"/api/v1/activities/patient/{profile['id']}", headers=fam_headers
    )
    assert resp.status_code == 200
    ids = {a["id"] for a in resp.json()["activities"]}
    assert activity["id"] in ids


def test_admin_can_view_patient_activities(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    _assign_activity(client, doc_headers, profile["id"])
    resp = client.get(
        f"/api/v1/activities/patient/{profile['id']}", headers=admin_headers
    )
    assert resp.status_code == 200
    assert resp.json()["total"] >= 1


# --- complete / skip lifecycle -----------------------------------------------


def test_patient_completes_own_activity(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    activity = _assign_activity(client, doc_headers, profile["id"]).json()

    headers = _login(client, "p@example.test")
    resp = client.patch(
        f"/api/v1/activities/{activity['id']}/complete", headers=headers, json={}
    )
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["status"] == "completed"
    assert data["completed_at"] is not None


def test_patient_can_skip_activity(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    activity = _assign_activity(client, doc_headers, profile["id"]).json()

    headers = _login(client, "p@example.test")
    resp = client.patch(
        f"/api/v1/activities/{activity['id']}/complete",
        headers=headers,
        json={"status": "skipped"},
    )
    assert resp.status_code == 200
    assert resp.json()["status"] == "skipped"
    assert resp.json()["completed_at"] is None


def test_family_cannot_complete_activity(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    activity = _assign_activity(client, doc_headers, profile["id"]).json()
    _, fam_headers = _link_family(client, admin_headers, user_factory, profile["id"])

    resp = client.patch(
        f"/api/v1/activities/{activity['id']}/complete", headers=fam_headers, json={}
    )
    assert resp.status_code == 403


def test_assigned_doctor_can_complete_activity(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    activity = _assign_activity(client, doc_headers, profile["id"]).json()

    resp = client.patch(
        f"/api/v1/activities/{activity['id']}/complete", headers=doc_headers, json={}
    )
    assert resp.status_code == 200
    assert resp.json()["status"] == "completed"


# --- safety + audit ----------------------------------------------------------


def test_activity_response_has_no_medical_fields(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    data = _assign_activity(client, doc_headers, profile["id"]).json()

    blob = str(data).lower()
    for bad in FORBIDDEN:
        assert bad not in blob


def test_audit_log_created_for_assign(client, admin_headers, user_factory, db_session):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    _assign_activity(client, doc_headers, profile["id"])

    db_session.rollback()
    actions = db_session.execute(select(AuditLog.action)).scalars().all()
    assert "assign_activity" in actions
