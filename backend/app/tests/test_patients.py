"""Phase 6 patient profile tests.

Reuses the isolated in-memory DB fixtures from conftest (client, db_session,
user_factory). Roles are seeded; users are created via user_factory; profiles
and relationships are created through the admin-only API.
"""

import uuid

import pytest
from sqlalchemy import select

from app.models import AuditLog
from app.scripts.seed_roles import seed_roles

PASSWORD = "Secret123!"


@pytest.fixture()
def seeded_roles(db_session):
    seed_roles(db_session)


def _login(client, email):
    resp = client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": email, "password": PASSWORD},
    )
    assert resp.status_code == 200, resp.text
    return {"Authorization": f"Bearer {resp.json()['access_token']}"}


@pytest.fixture()
def admin_headers(client, db_session, user_factory, seeded_roles):
    user_factory(email="admin@example.test", roles=("admin",))
    return _login(client, "admin@example.test")


def _create_profile(client, admin_headers, user_id, **extra):
    body = {"user_id": str(user_id)}
    body.update(extra)
    return client.post("/api/v1/patients", headers=admin_headers, json=body)


# --- create ------------------------------------------------------------------


def test_admin_can_create_patient_profile(client, admin_headers, user_factory):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    resp = _create_profile(client, admin_headers, patient.id, gender="female")
    assert resp.status_code == 201, resp.text
    data = resp.json()
    assert data["user_id"] == str(patient.id)
    assert data["user"]["email"] == "patient@example.test"
    assert "password_hash" not in data["user"]
    assert data["gender"] == "female"


def test_create_requires_patient_role(client, admin_headers, user_factory):
    not_patient = user_factory(email="doc@example.test", roles=("doctor",))
    resp = _create_profile(client, admin_headers, not_patient.id)
    assert resp.status_code == 400


def test_duplicate_profile_rejected(client, admin_headers, user_factory):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    assert _create_profile(client, admin_headers, patient.id).status_code == 201
    assert _create_profile(client, admin_headers, patient.id).status_code == 409


# --- list --------------------------------------------------------------------


def test_admin_can_list_all_profiles(client, admin_headers, user_factory):
    p1 = user_factory(email="p1@example.test", roles=("patient",))
    p2 = user_factory(email="p2@example.test", roles=("patient",))
    _create_profile(client, admin_headers, p1.id)
    _create_profile(client, admin_headers, p2.id)
    resp = client.get("/api/v1/patients", headers=admin_headers)
    assert resp.status_code == 200
    data = resp.json()
    assert data["total"] == 2
    for patient in data["patients"]:
        assert "password_hash" not in patient["user"]


# --- visibility: patient -----------------------------------------------------


def test_patient_can_view_own_profile(client, admin_headers, user_factory):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    profile = _create_profile(client, admin_headers, patient.id).json()
    headers = _login(client, "patient@example.test")
    resp = client.get(f"/api/v1/patients/{profile['id']}", headers=headers)
    assert resp.status_code == 200
    assert resp.json()["id"] == profile["id"]


def test_patient_cannot_view_other_profile(client, admin_headers, user_factory):
    p1 = user_factory(email="p1@example.test", roles=("patient",))
    p2 = user_factory(email="p2@example.test", roles=("patient",))
    _create_profile(client, admin_headers, p1.id)
    other = _create_profile(client, admin_headers, p2.id).json()
    headers = _login(client, "p1@example.test")
    resp = client.get(f"/api/v1/patients/{other['id']}", headers=headers)
    assert resp.status_code == 403


# --- visibility: clinicians --------------------------------------------------


def _assign(client, admin_headers, profile_id, clinician_id, assignment_type):
    return client.post(
        f"/api/v1/patients/{profile_id}/assign-clinician",
        headers=admin_headers,
        json={"clinician_user_id": str(clinician_id), "assignment_type": assignment_type},
    )


def test_doctor_can_view_assigned_patient(client, admin_headers, user_factory):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    doctor = user_factory(email="doc@example.test", roles=("doctor",))
    profile = _create_profile(client, admin_headers, patient.id).json()
    assert _assign(client, admin_headers, profile["id"], doctor.id, "doctor").status_code == 201
    headers = _login(client, "doc@example.test")
    resp = client.get(f"/api/v1/patients/{profile['id']}", headers=headers)
    assert resp.status_code == 200


def test_doctor_cannot_view_unassigned_patient(client, admin_headers, user_factory):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    doctor = user_factory(email="doc@example.test", roles=("doctor",))
    profile = _create_profile(client, admin_headers, patient.id).json()
    headers = _login(client, "doc@example.test")
    resp = client.get(f"/api/v1/patients/{profile['id']}", headers=headers)
    assert resp.status_code == 403


def test_therapist_can_view_assigned_patient(client, admin_headers, user_factory):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    therapist = user_factory(email="ther@example.test", roles=("therapist",))
    profile = _create_profile(client, admin_headers, patient.id).json()
    assert _assign(client, admin_headers, profile["id"], therapist.id, "therapist").status_code == 201
    headers = _login(client, "ther@example.test")
    resp = client.get(f"/api/v1/patients/{profile['id']}", headers=headers)
    assert resp.status_code == 200


# --- visibility: family ------------------------------------------------------


def _link_family(client, admin_headers, profile_id, family_id, relationship=None):
    body = {"family_user_id": str(family_id)}
    if relationship is not None:
        body["relationship"] = relationship
    return client.post(
        f"/api/v1/patients/{profile_id}/link-family", headers=admin_headers, json=body
    )


def test_family_can_view_linked_patient(client, admin_headers, user_factory):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    family = user_factory(email="fam@example.test", roles=("family",))
    profile = _create_profile(client, admin_headers, patient.id).json()
    assert _link_family(client, admin_headers, profile["id"], family.id, "son").status_code == 201
    headers = _login(client, "fam@example.test")
    resp = client.get(f"/api/v1/patients/{profile['id']}", headers=headers)
    assert resp.status_code == 200


def test_family_cannot_view_unlinked_patient(client, admin_headers, user_factory):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    family = user_factory(email="fam@example.test", roles=("family",))
    profile = _create_profile(client, admin_headers, patient.id).json()
    headers = _login(client, "fam@example.test")
    resp = client.get(f"/api/v1/patients/{profile['id']}", headers=headers)
    assert resp.status_code == 403


# --- update ------------------------------------------------------------------


def test_admin_can_update_profile(client, admin_headers, user_factory):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    profile = _create_profile(client, admin_headers, patient.id).json()
    resp = client.put(
        f"/api/v1/patients/{profile['id']}",
        headers=admin_headers,
        json={"notes": "Prefers morning sessions.", "gender": "male"},
    )
    assert resp.status_code == 200
    assert resp.json()["notes"] == "Prefers morning sessions."
    assert resp.json()["gender"] == "male"


# --- assignment / link happy paths -------------------------------------------


def test_admin_can_assign_doctor_and_therapist_and_link_family(
    client, admin_headers, user_factory
):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    doctor = user_factory(email="doc@example.test", roles=("doctor",))
    therapist = user_factory(email="ther@example.test", roles=("therapist",))
    family = user_factory(email="fam@example.test", roles=("family",))
    profile = _create_profile(client, admin_headers, patient.id).json()

    assert _assign(client, admin_headers, profile["id"], doctor.id, "doctor").status_code == 201
    assert _assign(client, admin_headers, profile["id"], therapist.id, "therapist").status_code == 201
    assert _link_family(client, admin_headers, profile["id"], family.id).status_code == 201

    # The profile now reflects the relationships.
    detail = client.get(f"/api/v1/patients/{profile['id']}", headers=admin_headers).json()
    assert len(detail["assignments"]) == 2
    assert len(detail["family_links"]) == 1


def test_wrong_clinician_role_rejected(client, admin_headers, user_factory):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    fake_doctor = user_factory(email="notdoc@example.test", roles=("patient",))
    profile = _create_profile(client, admin_headers, patient.id).json()
    resp = _assign(client, admin_headers, profile["id"], fake_doctor.id, "doctor")
    assert resp.status_code == 400


def test_wrong_family_role_rejected(client, admin_headers, user_factory):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    fake_family = user_factory(email="notfam@example.test", roles=("doctor",))
    profile = _create_profile(client, admin_headers, patient.id).json()
    resp = _link_family(client, admin_headers, profile["id"], fake_family.id)
    assert resp.status_code == 400


# --- deactivate relationships (optional endpoints) ---------------------------


def test_deactivate_assignment_revokes_access(client, admin_headers, user_factory):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    doctor = user_factory(email="doc@example.test", roles=("doctor",))
    profile = _create_profile(client, admin_headers, patient.id).json()
    assignment = _assign(client, admin_headers, profile["id"], doctor.id, "doctor").json()
    doc_headers = _login(client, "doc@example.test")
    assert client.get(f"/api/v1/patients/{profile['id']}", headers=doc_headers).status_code == 200

    deact = client.post(
        f"/api/v1/patients/{profile['id']}/assignments/{assignment['id']}/deactivate",
        headers=admin_headers,
    )
    assert deact.status_code == 200
    assert client.get(f"/api/v1/patients/{profile['id']}", headers=doc_headers).status_code == 403


# --- auth / authorization ----------------------------------------------------


def test_unauthenticated_returns_401(client, seeded_roles):
    assert client.get("/api/v1/patients").status_code == 401
    assert client.post("/api/v1/patients", json={"user_id": str(uuid.uuid4())}).status_code == 401


def test_non_admin_mutations_forbidden(client, admin_headers, user_factory):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    profile = _create_profile(client, admin_headers, patient.id).json()
    headers = _login(client, "patient@example.test")

    assert client.post(
        "/api/v1/patients", headers=headers, json={"user_id": str(patient.id)}
    ).status_code == 403
    assert client.put(
        f"/api/v1/patients/{profile['id']}", headers=headers, json={"notes": "x"}
    ).status_code == 403
    assert client.post(
        f"/api/v1/patients/{profile['id']}/assign-clinician",
        headers=headers,
        json={"clinician_user_id": str(patient.id), "assignment_type": "doctor"},
    ).status_code == 403
    assert client.post(
        f"/api/v1/patients/{profile['id']}/link-family",
        headers=headers,
        json={"family_user_id": str(patient.id)},
    ).status_code == 403


def test_missing_profile_returns_404(client, admin_headers):
    missing = "00000000-0000-0000-0000-000000000000"
    assert client.get(f"/api/v1/patients/{missing}", headers=admin_headers).status_code == 404


# --- audit -------------------------------------------------------------------


def test_audit_logs_created_for_patient_actions(client, admin_headers, user_factory, db_session):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    doctor = user_factory(email="doc@example.test", roles=("doctor",))
    family = user_factory(email="fam@example.test", roles=("family",))
    profile = _create_profile(client, admin_headers, patient.id).json()
    client.put(
        f"/api/v1/patients/{profile['id']}", headers=admin_headers, json={"notes": "hi"}
    )
    _assign(client, admin_headers, profile["id"], doctor.id, "doctor")
    _link_family(client, admin_headers, profile["id"], family.id)

    db_session.rollback()  # read latest committed state (shared connection)
    actions = db_session.execute(select(AuditLog.action)).scalars().all()
    for expected in (
        "create_patient_profile",
        "update_patient_profile",
        "assign_clinician",
        "link_family",
    ):
        assert expected in actions


# --- care & safety information (Phase 15) -------------------------------------

_CARE = {
    "allergies": "Penicillin",
    "current_medications": "None",
    "blood_type": "O+",
    "mobility_needs": "Needs a cane",
    "vision_hearing_needs": "Reading glasses",
    "preferred_communication": "Speak slowly",
    "caregiver_notes": "Prefers mornings",
}


def test_create_patient_profile_with_care_fields(client, admin_headers, user_factory):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    resp = _create_profile(
        client, admin_headers, patient.id, allergies="Peanuts", blood_type="A-"
    )
    assert resp.status_code == 201
    data = resp.json()
    assert data["allergies"] == "Peanuts"
    assert data["blood_type"] == "A-"


def test_update_and_get_care_fields(client, admin_headers, user_factory):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    profile = _create_profile(client, admin_headers, patient.id).json()

    put = client.put(
        f"/api/v1/patients/{profile['id']}", headers=admin_headers, json=_CARE
    )
    assert put.status_code == 200
    for key, value in _CARE.items():
        assert put.json()[key] == value

    got = client.get(
        f"/api/v1/patients/{profile['id']}", headers=admin_headers
    ).json()
    for key, value in _CARE.items():
        assert got[key] == value


def test_care_response_has_no_diagnostic_fields(client, admin_headers, user_factory):
    patient = user_factory(email="patient@example.test", roles=("patient",))
    profile = _create_profile(client, admin_headers, patient.id).json()
    forbidden = ("diagnosis", "disease", "dementia", "alzheimer", "interpretation")
    for key in profile:
        assert not any(bad in key.lower() for bad in forbidden)
