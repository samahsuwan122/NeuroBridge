"""AI Companion API safety, persistence, and role-scope tests."""

from app.models import AIChatMessage, AIChatSession


def _login(client, email: str) -> dict[str, str]:
    response = client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": email, "password": "Secret123!"},
    )
    assert response.status_code == 200
    return {"Authorization": f"Bearer {response.json()['access_token']}"}


def test_family_chat_persists_safe_mock_exchange(client, user_factory, db_session):
    user_factory(email="family-ai@example.test", roles=("family",))
    headers = _login(client, "family-ai@example.test")

    response = client.post(
        "/api/v1/ai-chat/message",
        headers=headers,
        json={"message": "Suggest a supportive message"},
    )
    assert response.status_code == 201
    body = response.json()
    assert body["role"] == "family"
    assert "Every small step" in body["assistant_response"]
    assert db_session.query(AIChatSession).count() == 1
    assert db_session.query(AIChatMessage).count() == 1

    history = client.get("/api/v1/ai-chat/history", headers=headers)
    assert history.status_code == 200
    assert len(history.json()["messages"]) == 1


def test_care_question_gets_non_medical_boundary(client, user_factory):
    user_factory(email="patient-ai@example.test", roles=("patient",))
    headers = _login(client, "patient-ai@example.test")
    response = client.post(
        "/api/v1/ai-chat/message",
        headers=headers,
        json={"message": "Should I change my medication dose?"},
    )
    assert response.status_code == 201
    answer = response.json()["assistant_response"]
    assert "can’t provide" in answer
    assert "care team" in answer


def test_admin_only_role_cannot_use_companion(client, user_factory):
    user_factory(email="admin-ai@example.test", roles=("admin",))
    headers = _login(client, "admin-ai@example.test")
    assert client.get("/api/v1/ai-chat/history", headers=headers).status_code == 403


def test_chat_requires_authentication(client):
    assert client.get("/api/v1/ai-chat/history").status_code == 401
