"""AI Companion API safety, persistence, and role-scope tests."""

from datetime import datetime, timezone
import uuid

import pytest

from app.models import (
    AIChatMessage,
    AIChatSession,
    PatientAssignment,
    PatientFamilyLink,
    PatientProfile,
)
from app.modules.ai_chat import service


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
    session = db_session.query(AIChatSession).one()
    message = db_session.query(AIChatMessage).one()
    assert session.title is None
    assert session.patient_profile_id is None
    assert session.archived_at is None
    assert session.deleted_at is None
    assert message.session_id == session.id

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


def test_session_accepts_optional_conversation_metadata(db_session, user_factory):
    owner = user_factory(email="metadata-owner@example.test", roles=("family",))
    patient = user_factory(email="metadata-patient@example.test", roles=("patient",))
    profile = PatientProfile(user_id=patient.id)
    db_session.add(profile)
    db_session.flush()
    archived_at = datetime.now(timezone.utc)
    chat = AIChatSession(
        user_id=owner.id,
        role="family",
        title="Supportive planning",
        patient_profile_id=profile.id,
        archived_at=archived_at,
    )
    db_session.add(chat)
    db_session.commit()

    db_session.expire_all()
    stored = db_session.get(AIChatSession, chat.id)
    assert stored is not None
    assert stored.title == "Supportive planning"
    assert stored.patient_profile_id == profile.id
    assert stored.archived_at is not None
    assert stored.deleted_at is None


def _profile(db_session, user_factory, prefix):
    patient = user_factory(email=f"{prefix}-patient@example.test", roles=("patient",))
    profile = PatientProfile(user_id=patient.id)
    db_session.add(profile)
    db_session.commit()
    return patient, profile


def _conversation(db_session, owner, role, profile=None, **fields):
    conversation = AIChatSession(
        user_id=owner.id,
        role=role,
        patient_profile_id=profile.id if profile else None,
        **fields,
    )
    db_session.add(conversation)
    db_session.commit()
    return conversation


def test_conversation_owner_access_allowed(db_session, user_factory):
    owner = user_factory(email="owner-access@example.test", roles=("family",))
    conversation = _conversation(db_session, owner, "family")
    assert service.can_access_conversation(
        db_session, owner, ["family"], conversation
    )


def test_different_user_conversation_is_hidden(db_session, user_factory):
    owner = user_factory(email="hidden-owner@example.test", roles=("family",))
    other = user_factory(email="hidden-other@example.test", roles=("family",))
    conversation = _conversation(db_session, owner, "family")
    assert service.get_accessible_conversation(
        db_session, other, ["family"], conversation.id
    ) is None


def test_cross_role_conversation_denied(db_session, user_factory):
    owner = user_factory(email="cross-role@example.test", roles=("doctor", "family"))
    conversation = _conversation(db_session, owner, "family")
    assert not service.can_access_conversation(
        db_session, owner, ["doctor", "family"], conversation
    )


def test_patient_own_profile_context_allowed(db_session, user_factory):
    patient, profile = _profile(db_session, user_factory, "patient-own")
    conversation = _conversation(db_session, patient, "patient", profile)
    assert service.can_access_conversation(
        db_session, patient, ["patient"], conversation
    )


def test_patient_other_profile_context_denied(db_session, user_factory):
    patient = user_factory(email="patient-other@example.test", roles=("patient",))
    _, profile = _profile(db_session, user_factory, "different")
    conversation = _conversation(db_session, patient, "patient", profile)
    assert not service.can_access_conversation(
        db_session, patient, ["patient"], conversation
    )


def test_linked_family_context_allowed(db_session, user_factory):
    family = user_factory(email="linked-family@example.test", roles=("family",))
    _, profile = _profile(db_session, user_factory, "linked-family")
    db_session.add(
        PatientFamilyLink(patient_profile_id=profile.id, family_user_id=family.id)
    )
    db_session.commit()
    conversation = _conversation(db_session, family, "family", profile)
    assert service.can_access_conversation(
        db_session, family, ["family"], conversation
    )


def test_unlinked_family_context_denied(db_session, user_factory):
    family = user_factory(email="unlinked-family@example.test", roles=("family",))
    _, profile = _profile(db_session, user_factory, "unlinked-family")
    conversation = _conversation(db_session, family, "family", profile)
    assert not service.can_access_conversation(
        db_session, family, ["family"], conversation
    )


def _clinician_context(db_session, user_factory, role, prefix, assigned):
    clinician = user_factory(email=f"{prefix}@example.test", roles=(role,))
    _, profile = _profile(db_session, user_factory, prefix)
    if assigned:
        db_session.add(
            PatientAssignment(
                patient_profile_id=profile.id,
                clinician_user_id=clinician.id,
                assignment_type=role,
                active=True,
            )
        )
        db_session.commit()
    conversation = _conversation(db_session, clinician, role, profile)
    return clinician, conversation


def test_assigned_doctor_context_allowed(db_session, user_factory):
    doctor, conversation = _clinician_context(
        db_session, user_factory, "doctor", "assigned-doctor", True
    )
    assert service.can_access_conversation(
        db_session, doctor, ["doctor"], conversation
    )


def test_unrelated_doctor_context_denied(db_session, user_factory):
    doctor, conversation = _clinician_context(
        db_session, user_factory, "doctor", "unrelated-doctor", False
    )
    assert not service.can_access_conversation(
        db_session, doctor, ["doctor"], conversation
    )


def test_assigned_therapist_context_allowed(db_session, user_factory):
    therapist, conversation = _clinician_context(
        db_session, user_factory, "therapist", "assigned-therapist", True
    )
    assert service.can_access_conversation(
        db_session, therapist, ["therapist"], conversation
    )


def test_unrelated_therapist_context_denied(db_session, user_factory):
    therapist, conversation = _clinician_context(
        db_session, user_factory, "therapist", "unrelated-therapist", False
    )
    assert not service.can_access_conversation(
        db_session, therapist, ["therapist"], conversation
    )


def test_deleted_conversation_denied(db_session, user_factory):
    owner = user_factory(email="deleted-chat@example.test", roles=("family",))
    conversation = _conversation(
        db_session, owner, "family", deleted_at=datetime.now(timezone.utc)
    )
    assert service.get_accessible_conversation(
        db_session, owner, ["family"], conversation.id
    ) is None


def test_archived_conversation_remains_readable(db_session, user_factory):
    owner = user_factory(email="archived-chat@example.test", roles=("family",))
    conversation = _conversation(
        db_session, owner, "family", archived_at=datetime.now(timezone.utc)
    )
    assert service.get_accessible_conversation(
        db_session, owner, ["family"], conversation.id
    ) == conversation


def test_admin_only_user_remains_denied(db_session, user_factory):
    admin = user_factory(email="admin-chat-helper@example.test", roles=("admin",))
    conversation = _conversation(db_session, admin, "admin")
    assert not service.can_access_conversation(
        db_session, admin, ["admin"], conversation
    )


def _create_api_conversation(client, headers, role, **fields):
    return client.post(
        "/api/v1/ai-chat/conversations",
        headers=headers,
        json={"role": role, **fields},
    )


@pytest.mark.parametrize("role", ["family", "doctor", "therapist", "patient"])
def test_supported_role_creates_independent_conversation(
    client, user_factory, role
):
    user = user_factory(email=f"core-{role}@example.test", roles=(role,))
    response = _create_api_conversation(
        client, _login(client, user.email), role, title="  Planning chat  "
    )
    assert response.status_code == 201, response.text
    assert response.json()["role"] == role
    assert response.json()["title"] == "Planning chat"


def test_admin_cannot_create_ai_conversation(client, user_factory):
    admin = user_factory(email="core-admin@example.test", roles=("admin",))
    response = _create_api_conversation(
        client, _login(client, admin.email), "family"
    )
    assert response.status_code == 403


def test_new_chats_receive_distinct_ids(client, user_factory):
    family = user_factory(email="distinct-chats@example.test", roles=("family",))
    headers = _login(client, family.email)
    first = _create_api_conversation(client, headers, "family").json()
    second = _create_api_conversation(client, headers, "family").json()
    assert first["id"] != second["id"]


def test_conversation_list_is_owner_scoped_and_filters_state(
    client, user_factory, db_session
):
    owner = user_factory(email="list-owner@example.test", roles=("family",))
    other = user_factory(email="list-other@example.test", roles=("family",))
    active = _conversation(db_session, owner, "family", title="Active")
    archived = _conversation(
        db_session, owner, "family", title="Archived",
        archived_at=datetime.now(timezone.utc),
    )
    _conversation(db_session, other, "family", title="Foreign")
    headers = _login(client, owner.email)

    active_response = client.get(
        "/api/v1/ai-chat/conversations", headers=headers
    ).json()
    archived_response = client.get(
        "/api/v1/ai-chat/conversations?state=archived", headers=headers
    ).json()
    assert active_response["total"] == 1
    assert [item["id"] for item in active_response["conversations"]] == [str(active.id)]
    assert archived_response["total"] == 1
    assert [item["id"] for item in archived_response["conversations"]] == [str(archived.id)]


def test_cross_user_conversation_endpoint_returns_not_found(
    client, user_factory, db_session
):
    owner = user_factory(email="endpoint-owner@example.test", roles=("family",))
    other = user_factory(email="endpoint-other@example.test", roles=("family",))
    conversation = _conversation(db_session, owner, "family")
    response = client.get(
        f"/api/v1/ai-chat/conversations/{conversation.id}/messages",
        headers=_login(client, other.email),
    )
    assert response.status_code == 404


def test_authorized_and_unauthorized_patient_context_creation(
    client, user_factory, db_session
):
    family = user_factory(email="context-family@example.test", roles=("family",))
    _, linked = _profile(db_session, user_factory, "context-linked")
    _, unlinked = _profile(db_session, user_factory, "context-unlinked")
    db_session.add(
        PatientFamilyLink(patient_profile_id=linked.id, family_user_id=family.id)
    )
    db_session.commit()
    headers = _login(client, family.email)
    allowed = _create_api_conversation(
        client, headers, "family", patient_profile_id=str(linked.id)
    )
    denied = _create_api_conversation(
        client, headers, "family", patient_profile_id=str(unlinked.id)
    )
    assert allowed.status_code == 201
    assert allowed.json()["patient_profile_id"] == str(linked.id)
    assert denied.status_code == 403


def test_messages_are_conversation_scoped_ordered_and_recent_paginated(
    client, user_factory
):
    family = user_factory(email="message-pages@example.test", roles=("family",))
    headers = _login(client, family.email)
    first = _create_api_conversation(client, headers, "family").json()
    second = _create_api_conversation(client, headers, "family").json()
    for value in ("first", "second", "third"):
        response = client.post(
            f"/api/v1/ai-chat/conversations/{first['id']}/messages",
            headers=headers,
            json={"message": value},
        )
        assert response.status_code == 201, response.text
    client.post(
        f"/api/v1/ai-chat/conversations/{second['id']}/messages",
        headers=headers,
        json={"message": "other conversation"},
    )
    page = client.get(
        f"/api/v1/ai-chat/conversations/{first['id']}/messages?limit=2",
        headers=headers,
    ).json()
    assert page["total"] == 3
    assert [item["message"] for item in page["messages"]] == ["second", "third"]


def test_send_uses_stored_role_and_rejects_forged_context(
    client, user_factory, db_session
):
    doctor = user_factory(email="authoritative-role@example.test", roles=("doctor",))
    headers = _login(client, doctor.email)
    conversation = _create_api_conversation(client, headers, "doctor").json()
    sent = client.post(
        f"/api/v1/ai-chat/conversations/{conversation['id']}/messages",
        headers=headers,
        json={"message": "Summarize recorded follow-up"},
    )
    forged = client.post(
        f"/api/v1/ai-chat/conversations/{conversation['id']}/messages",
        headers=headers,
        json={"message": "hello", "role": "family", "patient_profile_id": str(uuid.uuid4())},
    )
    assert sent.status_code == 201, sent.text
    assert sent.json()["role"] == "doctor"
    stored = db_session.get(AIChatMessage, uuid.UUID(sent.json()["id"]))
    assert stored is not None and stored.session_id == uuid.UUID(conversation["id"])
    assert forged.status_code == 422


def test_archived_is_readable_but_cannot_receive_messages(
    client, user_factory, db_session
):
    family = user_factory(email="archived-endpoint@example.test", roles=("family",))
    conversation = _conversation(
        db_session, family, "family", archived_at=datetime.now(timezone.utc)
    )
    headers = _login(client, family.email)
    readable = client.get(
        f"/api/v1/ai-chat/conversations/{conversation.id}/messages", headers=headers
    )
    blocked = client.post(
        f"/api/v1/ai-chat/conversations/{conversation.id}/messages",
        headers=headers,
        json={"message": "new message"},
    )
    assert readable.status_code == 200
    assert blocked.status_code == 409


def test_deleted_conversation_endpoint_is_inaccessible(
    client, user_factory, db_session
):
    family = user_factory(email="deleted-endpoint@example.test", roles=("family",))
    conversation = _conversation(
        db_session, family, "family", deleted_at=datetime.now(timezone.utc)
    )
    response = client.get(
        f"/api/v1/ai-chat/conversations/{conversation.id}/messages",
        headers=_login(client, family.email),
    )
    assert response.status_code == 404


def test_conversation_message_rejects_blank_and_preserves_safety_boundary(
    client, user_factory
):
    patient = user_factory(email="core-safety@example.test", roles=("patient",))
    headers = _login(client, patient.email)
    conversation = _create_api_conversation(client, headers, "patient").json()
    blank = client.post(
        f"/api/v1/ai-chat/conversations/{conversation['id']}/messages",
        headers=headers,
        json={"message": "   "},
    )
    boundary = client.post(
        f"/api/v1/ai-chat/conversations/{conversation['id']}/messages",
        headers=headers,
        json={"message": "Should I change my medication dose?"},
    )
    assert blank.status_code == 422
    assert boundary.status_code == 201
    assert "care team" in boundary.json()["assistant_response"]


def test_rename_active_and_archived_conversations(client, user_factory, db_session):
    family = user_factory(email="rename-lifecycle@example.test", roles=("family",))
    active = _conversation(db_session, family, "family", title="Old active")
    archived = _conversation(
        db_session, family, "family", title="Old archived",
        archived_at=datetime.now(timezone.utc),
    )
    headers = _login(client, family.email)

    active_response = client.patch(
        f"/api/v1/ai-chat/conversations/{active.id}",
        headers=headers,
        json={"title": "  Renamed active  "},
    )
    archived_response = client.patch(
        f"/api/v1/ai-chat/conversations/{archived.id}",
        headers=headers,
        json={"title": "Renamed archived"},
    )
    assert active_response.status_code == 200
    assert active_response.json()["title"] == "Renamed active"
    assert archived_response.status_code == 200
    assert archived_response.json()["title"] == "Renamed archived"


@pytest.mark.parametrize(
    "payload",
    [
        {"title": "   "},
        {"title": "x" * 256},
        {"title": "Valid", "role": "doctor"},
        {"title": "Valid", "patient_profile_id": str(uuid.uuid4())},
        {"title": "Valid", "user_id": str(uuid.uuid4())},
    ],
)
def test_rename_rejects_invalid_or_privileged_fields(
    client, user_factory, db_session, payload
):
    family = user_factory(
        email=f"rename-invalid-{uuid.uuid4()}@example.test", roles=("family",)
    )
    conversation = _conversation(db_session, family, "family", title="Original")
    response = client.patch(
        f"/api/v1/ai-chat/conversations/{conversation.id}",
        headers=_login(client, family.email),
        json=payload,
    )
    assert response.status_code == 422
    db_session.refresh(conversation)
    assert conversation.title == "Original"
    assert conversation.role == "family"
    assert conversation.patient_profile_id is None
    assert conversation.user_id == family.id


def test_archive_is_idempotent_readable_and_read_only(
    client, user_factory, db_session
):
    family = user_factory(email="archive-lifecycle@example.test", roles=("family",))
    conversation = _conversation(db_session, family, "family")
    headers = _login(client, family.email)
    url = f"/api/v1/ai-chat/conversations/{conversation.id}"

    first = client.post(f"{url}/archive", headers=headers)
    archived_at = first.json()["archived_at"]
    second = client.post(f"{url}/archive", headers=headers)
    readable = client.get(f"{url}/messages", headers=headers)
    blocked = client.post(
        f"{url}/messages", headers=headers, json={"message": "blocked"}
    )
    assert first.status_code == second.status_code == 200
    assert second.json()["archived_at"] == archived_at
    assert readable.status_code == 200
    assert blocked.status_code == 409


def test_restore_is_idempotent_and_allows_messages(
    client, user_factory, db_session
):
    family = user_factory(email="restore-lifecycle@example.test", roles=("family",))
    conversation = _conversation(
        db_session, family, "family", archived_at=datetime.now(timezone.utc)
    )
    headers = _login(client, family.email)
    url = f"/api/v1/ai-chat/conversations/{conversation.id}"

    first = client.post(f"{url}/restore", headers=headers)
    second = client.post(f"{url}/restore", headers=headers)
    sent = client.post(
        f"{url}/messages", headers=headers, json={"message": "after restore"}
    )
    assert first.status_code == second.status_code == 200
    assert first.json()["archived_at"] is None
    assert second.json()["archived_at"] is None
    assert sent.status_code == 201


def test_soft_delete_preserves_rows_and_hides_conversation(
    client, user_factory, db_session
):
    family = user_factory(email="delete-lifecycle@example.test", roles=("family",))
    headers = _login(client, family.email)
    created = _create_api_conversation(client, headers, "family").json()
    sent = client.post(
        f"/api/v1/ai-chat/conversations/{created['id']}/messages",
        headers=headers,
        json={"message": "preserve me"},
    ).json()
    url = f"/api/v1/ai-chat/conversations/{created['id']}"

    deleted = client.delete(url, headers=headers)
    listed = client.get("/api/v1/ai-chat/conversations", headers=headers).json()
    loaded = client.get(f"{url}/messages", headers=headers)
    restored = client.post(f"{url}/restore", headers=headers)
    repeated = client.delete(url, headers=headers)
    assert deleted.status_code == 204
    assert created["id"] not in {item["id"] for item in listed["conversations"]}
    assert loaded.status_code == restored.status_code == repeated.status_code == 404
    stored_session = db_session.get(AIChatSession, uuid.UUID(created["id"]))
    stored_message = db_session.get(AIChatMessage, uuid.UUID(sent["id"]))
    assert stored_session is not None and stored_session.deleted_at is not None
    assert stored_message is not None and stored_message.session_id == stored_session.id


@pytest.mark.parametrize("action,method", [
    ("", "patch"),
    ("/archive", "post"),
    ("/restore", "post"),
    ("", "delete"),
])
def test_cross_user_lifecycle_actions_are_non_enumerating(
    client, user_factory, db_session, action, method
):
    owner = user_factory(
        email=f"lifecycle-owner-{uuid.uuid4()}@example.test", roles=("family",)
    )
    other = user_factory(
        email=f"lifecycle-other-{uuid.uuid4()}@example.test", roles=("family",)
    )
    conversation = _conversation(db_session, owner, "family")
    kwargs = {"json": {"title": "Stolen"}} if method == "patch" else {}
    response = getattr(client, method)(
        f"/api/v1/ai-chat/conversations/{conversation.id}{action}",
        headers=_login(client, other.email),
        **kwargs,
    )
    assert response.status_code == 404


def test_role_isolation_applies_to_lifecycle_routes(client, user_factory, db_session):
    family = user_factory(email="lifecycle-role@example.test", roles=("family",))
    mismatched = _conversation(db_session, family, "doctor", title="Doctor chat")
    response = client.post(
        f"/api/v1/ai-chat/conversations/{mismatched.id}/archive",
        headers=_login(client, family.email),
    )
    assert response.status_code == 404
