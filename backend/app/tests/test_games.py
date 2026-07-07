"""Phase 9 cognitive-games tests.

Reuses the isolated in-memory DB fixtures from conftest (client, db_session,
user_factory). Roles are seeded; users/profiles/relationships are created via
the existing APIs.
"""

import pytest
from sqlalchemy import select

from app.models import AuditLog, GameDefinition
from app.scripts.seed_games import DEFAULT_GAME_SLUGS, seed_games
from app.scripts.seed_roles import seed_roles

PASSWORD = "Secret123!"

SAMPLE_RESULT = {
    "score": 8,
    "max_score": 10,
    "accuracy_percent": 80.0,
    "duration_seconds": 45,
    "completed": True,
    "metrics": {
        "attempts": 10,
        "correct_answers": 8,
        "wrong_answers": 2,
        "reaction_time_ms": 650,
    },
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


def _create_game(client, admin_headers, *, slug="memory_match", name="Memory Match",
                 game_type="memory", active=True):
    return client.post(
        "/api/v1/games",
        headers=admin_headers,
        json={
            "name": name,
            "slug": slug,
            "game_type": game_type,
            "difficulty": "easy",
            "active": active,
        },
    )


def _create_patient(client, admin_headers, user_factory, email):
    user = user_factory(email=email, roles=("patient",))
    resp = client.post(
        "/api/v1/patients", headers=admin_headers, json={"user_id": str(user.id)}
    )
    assert resp.status_code == 201, resp.text
    return user, resp.json()


def _submit(client, headers, game_id, patient_profile_id, **fields):
    body = {"patient_profile_id": patient_profile_id, **SAMPLE_RESULT, **fields}
    return client.post(
        f"/api/v1/games/{game_id}/results", headers=headers, json=body
    )


# --- game definitions: listing / access -------------------------------------


def test_authenticated_user_lists_active_games(client, admin_headers, user_factory):
    _create_game(client, admin_headers, slug="memory_match")
    _create_game(client, admin_headers, slug="inactive_game", name="Inactive",
                 game_type="memory", active=False)
    user_factory(email="patient@example.test", roles=("patient",))
    headers = _login(client, "patient@example.test")

    resp = client.get("/api/v1/games", headers=headers)
    assert resp.status_code == 200
    slugs = {g["slug"] for g in resp.json()["games"]}
    assert "memory_match" in slugs
    assert "inactive_game" not in slugs


def test_unauthenticated_list_games_401(client, seeded_roles):
    assert client.get("/api/v1/games").status_code == 401


def test_admin_can_create_game(client, admin_headers):
    resp = _create_game(client, admin_headers, slug="memory_match")
    assert resp.status_code == 201
    assert resp.json()["slug"] == "memory_match"


def test_duplicate_slug_rejected(client, admin_headers):
    assert _create_game(client, admin_headers, slug="memory_match").status_code == 201
    assert _create_game(client, admin_headers, slug="memory_match").status_code == 409


def test_admin_can_update_game(client, admin_headers):
    created = _create_game(client, admin_headers, slug="memory_match").json()
    resp = client.put(
        f"/api/v1/games/{created['id']}",
        headers=admin_headers,
        json={"name": "Memory Match Pro", "difficulty": "medium"},
    )
    assert resp.status_code == 200
    assert resp.json()["name"] == "Memory Match Pro"
    assert resp.json()["difficulty"] == "medium"


def test_non_admin_cannot_create_or_update(client, admin_headers, user_factory):
    created = _create_game(client, admin_headers, slug="memory_match").json()
    user_factory(email="patient@example.test", roles=("patient",))
    headers = _login(client, "patient@example.test")
    assert client.post(
        "/api/v1/games",
        headers=headers,
        json={"name": "X", "slug": "x", "game_type": "memory"},
    ).status_code == 403
    assert client.put(
        f"/api/v1/games/{created['id']}", headers=headers, json={"name": "Y"}
    ).status_code == 403


def test_seed_games_is_idempotent(db_session):
    first = seed_games(db_session)
    assert set(first["created"]) == set(DEFAULT_GAME_SLUGS)
    assert first["skipped"] == []
    second = seed_games(db_session)
    assert second["created"] == []
    assert set(second["skipped"]) == set(DEFAULT_GAME_SLUGS)
    count = len(db_session.execute(select(GameDefinition)).scalars().all())
    assert count == len(DEFAULT_GAME_SLUGS)


# --- results: submission -----------------------------------------------------


def test_patient_submits_result_for_own_profile(client, admin_headers, user_factory):
    game = _create_game(client, admin_headers, slug="memory_match").json()
    patient, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    headers = _login(client, "p@example.test")

    resp = _submit(client, headers, game["id"], profile["id"])
    assert resp.status_code == 201, resp.text
    data = resp.json()
    assert data["score"] == 8
    assert data["user_id"] == str(patient.id)
    assert data["metrics"]["correct_answers"] == 8


def test_patient_cannot_submit_for_another_profile(client, admin_headers, user_factory):
    game = _create_game(client, admin_headers, slug="memory_match").json()
    _create_patient(client, admin_headers, user_factory, "a@example.test")
    _, other = _create_patient(client, admin_headers, user_factory, "b@example.test")
    headers = _login(client, "a@example.test")

    resp = _submit(client, headers, game["id"], other["id"])
    assert resp.status_code == 403


def test_submit_to_inactive_game_rejected(client, admin_headers, user_factory):
    game = _create_game(client, admin_headers, slug="off", name="Off",
                        game_type="memory", active=False).json()
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    headers = _login(client, "p@example.test")

    resp = _submit(client, headers, game["id"], profile["id"])
    assert resp.status_code == 400


# --- results: visibility -----------------------------------------------------


def _seed_result(client, admin_headers, user_factory, email):
    game = _create_game(client, admin_headers, slug="memory_match").json()
    _, profile = _create_patient(client, admin_headers, user_factory, email)
    headers = _login(client, email)
    result = _submit(client, headers, game["id"], profile["id"]).json()
    return profile, result


def test_admin_can_list_all_results(client, admin_headers, user_factory):
    _seed_result(client, admin_headers, user_factory, "p@example.test")
    resp = client.get("/api/v1/games/results", headers=admin_headers)
    assert resp.status_code == 200
    assert resp.json()["total"] >= 1


def test_patient_sees_own_results(client, admin_headers, user_factory):
    profile, result = _seed_result(client, admin_headers, user_factory, "p@example.test")
    headers = _login(client, "p@example.test")
    resp = client.get("/api/v1/games/results", headers=headers)
    assert resp.status_code == 200
    ids = {r["id"] for r in resp.json()["results"]}
    assert result["id"] in ids


def test_doctor_sees_assigned_patient_results(client, admin_headers, user_factory):
    profile, result = _seed_result(client, admin_headers, user_factory, "p@example.test")
    doctor = user_factory(email="doc@example.test", roles=("doctor",))
    client.post(
        f"/api/v1/patients/{profile['id']}/assign-clinician",
        headers=admin_headers,
        json={"clinician_user_id": str(doctor.id), "assignment_type": "doctor"},
    )
    headers = _login(client, "doc@example.test")
    resp = client.get(
        f"/api/v1/games/results?patient_profile_id={profile['id']}", headers=headers
    )
    assert resp.status_code == 200
    ids = {r["id"] for r in resp.json()["results"]}
    assert result["id"] in ids


def test_doctor_cannot_see_unassigned_results(client, admin_headers, user_factory):
    profile, result = _seed_result(client, admin_headers, user_factory, "p@example.test")
    user_factory(email="doc@example.test", roles=("doctor",))
    headers = _login(client, "doc@example.test")
    resp = client.get("/api/v1/games/results", headers=headers)
    assert resp.status_code == 200
    ids = {r["id"] for r in resp.json()["results"]}
    assert result["id"] not in ids


def test_family_sees_linked_patient_results(client, admin_headers, user_factory):
    profile, result = _seed_result(client, admin_headers, user_factory, "p@example.test")
    family = user_factory(email="fam@example.test", roles=("family",))
    client.post(
        f"/api/v1/patients/{profile['id']}/link-family",
        headers=admin_headers,
        json={"family_user_id": str(family.id)},
    )
    headers = _login(client, "fam@example.test")
    resp = client.get("/api/v1/games/results", headers=headers)
    assert resp.status_code == 200
    ids = {r["id"] for r in resp.json()["results"]}
    assert result["id"] in ids


def test_family_cannot_see_unlinked_results(client, admin_headers, user_factory):
    profile, result = _seed_result(client, admin_headers, user_factory, "p@example.test")
    user_factory(email="fam@example.test", roles=("family",))
    headers = _login(client, "fam@example.test")
    resp = client.get("/api/v1/games/results", headers=headers)
    assert resp.status_code == 200
    ids = {r["id"] for r in resp.json()["results"]}
    assert result["id"] not in ids


# --- medical safety + audit + health ----------------------------------------


def test_result_response_has_performance_fields_only(client, admin_headers, user_factory):
    game = _create_game(client, admin_headers, slug="memory_match").json()
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    headers = _login(client, "p@example.test")
    data = _submit(client, headers, game["id"], profile["id"]).json()

    assert "score" in data and "metrics" in data and "accuracy_percent" in data
    forbidden = {"diagnosis", "disease", "dementia", "alzheimer", "interpretation"}
    for key in data:
        assert not any(bad in key.lower() for bad in forbidden)


def test_audit_log_created_for_submit(client, admin_headers, user_factory, db_session):
    game = _create_game(client, admin_headers, slug="memory_match").json()
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    headers = _login(client, "p@example.test")
    _submit(client, headers, game["id"], profile["id"])

    db_session.rollback()
    actions = db_session.execute(select(AuditLog.action)).scalars().all()
    assert "submit_game_result" in actions


def test_health_still_works(client):
    resp = client.get("/api/v1/health")
    assert resp.status_code == 200
    assert resp.json()["status"] == "healthy"
