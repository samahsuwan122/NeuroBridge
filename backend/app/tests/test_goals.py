"""Patient goals module tests.

Covers permissions (who can create / view / update) and validation on the
follow-up goal fields. Reuses the isolated in-memory DB fixtures from conftest.

Goals are performance-based follow-up targets for care-team review only — no
diagnosis, treatment, prediction, or scoring of any condition.
"""

import pytest

PASSWORD = "Secret123!"


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


def _assign_clinician(
    client, admin_headers, user_factory, profile_id, *, role, email
):
    clinician = user_factory(email=email, roles=(role,))
    resp = client.post(
        f"/api/v1/patients/{profile_id}/assign-clinician",
        headers=admin_headers,
        json={"clinician_user_id": str(clinician.id), "assignment_type": role},
    )
    assert resp.status_code in (200, 201), resp.text
    return clinician, _login(client, email)


def _assign_doctor(client, admin_headers, user_factory, profile_id, email="doc@example.test"):
    return _assign_clinician(
        client, admin_headers, user_factory, profile_id, role="doctor", email=email
    )


def _assign_therapist(client, admin_headers, user_factory, profile_id, email="ther@example.test"):
    return _assign_clinician(
        client, admin_headers, user_factory, profile_id, role="therapist", email=email
    )


def _link_family(client, admin_headers, user_factory, profile_id, email="fam@example.test"):
    family = user_factory(email=email, roles=("family",))
    resp = client.post(
        f"/api/v1/patients/{profile_id}/link-family",
        headers=admin_headers,
        json={"family_user_id": str(family.id)},
    )
    assert resp.status_code in (200, 201), resp.text
    return family, _login(client, email)


def _create_goal(client, headers, profile_id, **fields):
    body = {
        "patient_profile_id": profile_id,
        "title": "Complete weekly practice sessions",
        "target_type": "sessions",
        "target_value": 5,
        **fields,
    }
    return client.post("/api/v1/goals", headers=headers, json=body)


# --- create: permissions -----------------------------------------------------


def test_assigned_doctor_can_create_goal(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])

    resp = _create_goal(client, doc_headers, profile["id"])
    assert resp.status_code == 201, resp.text
    data = resp.json()
    assert data["title"] == "Complete weekly practice sessions"
    assert data["target_type"] == "sessions"
    assert data["target_value"] == 5
    assert data["current_value"] == 0
    assert data["status"] == "active"


def test_assigned_therapist_can_create_goal(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, ther_headers = _assign_therapist(client, admin_headers, user_factory, profile["id"])

    resp = _create_goal(client, ther_headers, profile["id"], target_type="activities")
    assert resp.status_code == 201, resp.text
    assert resp.json()["target_type"] == "activities"


def test_unassigned_doctor_cannot_create_goal(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    user_factory(email="doc2@example.test", roles=("doctor",))
    headers = _login(client, "doc2@example.test")

    resp = _create_goal(client, headers, profile["id"])
    assert resp.status_code == 403


def test_patient_cannot_create_goal(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    headers = _login(client, "p@example.test")

    resp = _create_goal(client, headers, profile["id"])
    assert resp.status_code == 403  # role guard: doctor/therapist/admin only


def test_family_cannot_create_goal(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, fam_headers = _link_family(client, admin_headers, user_factory, profile["id"])

    resp = _create_goal(client, fam_headers, profile["id"])
    assert resp.status_code == 403


# --- view: role-scoped -------------------------------------------------------


def test_patient_can_view_own_goals(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    goal = _create_goal(client, doc_headers, profile["id"]).json()

    headers = _login(client, "p@example.test")
    resp = client.get(f"/api/v1/goals/patient/{profile['id']}", headers=headers)
    assert resp.status_code == 200
    ids = {g["id"] for g in resp.json()["goals"]}
    assert goal["id"] in ids


def test_linked_family_can_view_goals(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    goal = _create_goal(client, doc_headers, profile["id"]).json()
    _, fam_headers = _link_family(client, admin_headers, user_factory, profile["id"])

    resp = client.get(f"/api/v1/goals/patient/{profile['id']}", headers=fam_headers)
    assert resp.status_code == 200
    ids = {g["id"] for g in resp.json()["goals"]}
    assert goal["id"] in ids


def test_unrelated_family_cannot_view_goals(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _assign_doctor(client, admin_headers, user_factory, profile["id"])
    # A family member linked to a *different* patient.
    _, other_profile = _create_patient(client, admin_headers, user_factory, "p2@example.test")
    _, fam_headers = _link_family(
        client, admin_headers, user_factory, other_profile["id"], email="fam2@example.test"
    )

    resp = client.get(f"/api/v1/goals/patient/{profile['id']}", headers=fam_headers)
    assert resp.status_code == 403


def test_assigned_doctor_lists_patient_goals(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    goal = _create_goal(client, doc_headers, profile["id"]).json()

    resp = client.get(f"/api/v1/goals/patient/{profile['id']}", headers=doc_headers)
    assert resp.status_code == 200
    data = resp.json()
    assert data["total"] >= 1
    ids = {g["id"] for g in data["goals"]}
    assert goal["id"] in ids


# --- update lifecycle --------------------------------------------------------


def test_doctor_updates_goal_active_to_completed(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    goal = _create_goal(client, doc_headers, profile["id"]).json()

    resp = client.patch(
        f"/api/v1/goals/{goal['id']}",
        headers=doc_headers,
        json={"status": "completed", "current_value": 5},
    )
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["status"] == "completed"
    assert data["current_value"] == 5


@pytest.mark.parametrize("status_value", ["active", "paused", "completed"])
def test_all_supported_goal_statuses_are_accepted(
    client, admin_headers, user_factory, status_value
):
    _, profile = _create_patient(
        client, admin_headers, user_factory, f"status-{status_value}@example.test"
    )
    _, doc_headers = _assign_doctor(
        client,
        admin_headers,
        user_factory,
        profile["id"],
        email=f"status-doc-{status_value}@example.test",
    )
    goal = _create_goal(client, doc_headers, profile["id"]).json()

    resp = client.patch(
        f"/api/v1/goals/{goal['id']}",
        headers=doc_headers,
        json={"status": status_value},
    )

    assert resp.status_code == 200, resp.text
    assert resp.json()["status"] == status_value


def test_unassigned_doctor_cannot_update_goal(client, admin_headers, user_factory):
    _, profile = _create_patient(
        client, admin_headers, user_factory, "protected-goal@example.test"
    )
    _, assigned_headers = _assign_doctor(
        client, admin_headers, user_factory, profile["id"]
    )
    goal = _create_goal(client, assigned_headers, profile["id"]).json()
    user_factory(email="unassigned-goal-doc@example.test", roles=("doctor",))
    unassigned_headers = _login(client, "unassigned-goal-doc@example.test")

    resp = client.patch(
        f"/api/v1/goals/{goal['id']}",
        headers=unassigned_headers,
        json={"current_value": 1},
    )

    assert resp.status_code == 403


# --- validation --------------------------------------------------------------


def test_invalid_status_rejected(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    goal = _create_goal(client, doc_headers, profile["id"]).json()

    resp = client.patch(
        f"/api/v1/goals/{goal['id']}", headers=doc_headers, json={"status": "archived"}
    )
    assert resp.status_code == 422


def test_target_value_below_one_rejected(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])

    resp = _create_goal(client, doc_headers, profile["id"], target_value=0)
    assert resp.status_code == 422


def test_current_value_negative_rejected(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])

    resp = _create_goal(client, doc_headers, profile["id"], current_value=-1)
    assert resp.status_code == 422


@pytest.mark.parametrize("field", ["title", "target_type"])
def test_required_goal_text_is_trimmed_and_rejects_whitespace(
    client, admin_headers, user_factory, field
):
    _, profile = _create_patient(
        client, admin_headers, user_factory, f"blank-{field}@example.test"
    )
    _, doc_headers = _assign_doctor(
        client,
        admin_headers,
        user_factory,
        profile["id"],
        email=f"blank-{field}-doc@example.test",
    )

    rejected = _create_goal(client, doc_headers, profile["id"], **{field: "   "})
    assert rejected.status_code == 422

    accepted = _create_goal(
        client, doc_headers, profile["id"], **{field: "  meaningful value  "}
    )
    assert accepted.status_code == 201, accepted.text
    assert accepted.json()[field] == "meaningful value"


@pytest.mark.parametrize(
    ("payload", "expected_status"),
    [
        ({"target_value": 0}, 422),
        ({"current_value": -1}, 422),
        ({"title": None}, 422),
        ({"status": None}, 422),
        ({"unexpected": "value"}, 422),
    ],
)
def test_invalid_goal_updates_are_rejected(
    client, admin_headers, user_factory, payload, expected_status
):
    _, profile = _create_patient(
        client,
        admin_headers,
        user_factory,
        f"invalid-update-{len(str(payload))}@example.test",
    )
    _, doc_headers = _assign_doctor(
        client,
        admin_headers,
        user_factory,
        profile["id"],
        email=f"invalid-update-doc-{len(str(payload))}@example.test",
    )
    goal = _create_goal(client, doc_headers, profile["id"]).json()

    resp = client.patch(
        f"/api/v1/goals/{goal['id']}", headers=doc_headers, json=payload
    )

    assert resp.status_code == expected_status


def test_goal_creation_rejects_unexpected_fields(
    client, admin_headers, user_factory
):
    _, profile = _create_patient(
        client, admin_headers, user_factory, "extra-goal@example.test"
    )
    _, doc_headers = _assign_doctor(
        client, admin_headers, user_factory, profile["id"]
    )

    resp = _create_goal(client, doc_headers, profile["id"], status="completed")

    assert resp.status_code == 422


# --- admin -------------------------------------------------------------------


def test_admin_can_list_and_update_any_goal(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _, doc_headers = _assign_doctor(client, admin_headers, user_factory, profile["id"])
    goal = _create_goal(client, doc_headers, profile["id"]).json()

    # Admin is not assigned to the patient but may still list...
    resp = client.get(f"/api/v1/goals/patient/{profile['id']}", headers=admin_headers)
    assert resp.status_code == 200
    assert resp.json()["total"] >= 1

    # ...and update any goal.
    resp = client.patch(
        f"/api/v1/goals/{goal['id']}", headers=admin_headers, json={"status": "paused"}
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["status"] == "paused"
