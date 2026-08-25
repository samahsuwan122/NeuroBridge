"""Persistent multimedia encouragement contract tests."""

import re
from uuid import UUID

import pytest
from sqlalchemy import select

from app.models import AuditLog, FamilyEncouragement
from app.modules.encouragements import media, service
from app.scripts.seed_roles import seed_roles

PASSWORD = "Secret123!"


@pytest.fixture()
def seeded_roles(db_session):
    seed_roles(db_session)


@pytest.fixture()
def admin_headers(client, db_session, user_factory, seeded_roles):
    user_factory(email="admin-media@example.test", roles=("admin",))
    return _login(client, "admin-media@example.test")


@pytest.fixture(autouse=True)
def temp_encouragement_storage(tmp_path, monkeypatch):
    monkeypatch.setattr(media, "storage_root", lambda: tmp_path)
    return tmp_path


def _login(client, email):
    response = client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": email, "password": PASSWORD},
    )
    assert response.status_code == 200, response.text
    return {"Authorization": f"Bearer {response.json()['access_token']}"}


def _create_patient(client, admin_headers, user_factory, email):
    user = user_factory(email=email, roles=("patient",))
    response = client.post(
        "/api/v1/patients", headers=admin_headers, json={"user_id": str(user.id)}
    )
    assert response.status_code == 201, response.text
    return user, response.json()


def _linked_family(client, admin_headers, user_factory, profile_id, email):
    family = user_factory(email=email, roles=("family",))
    response = client.post(
        f"/api/v1/patients/{profile_id}/link-family",
        headers=admin_headers,
        json={"family_user_id": str(family.id)},
    )
    assert response.status_code == 201, response.text
    return family, _login(client, email)


def _upload(
    client,
    headers,
    profile_id,
    *,
    content=b"valid-media",
    content_type="image/png",
    filename="support.png",
    **fields,
):
    data = {"patient_profile_id": profile_id, **fields}
    return client.post(
        "/api/v1/encouragements/media",
        headers=headers,
        data=data,
        files={"file": (filename, content, content_type)},
    )


def _family_context(client, admin_headers, user_factory, prefix):
    _, profile = _create_patient(
        client, admin_headers, user_factory, f"{prefix}-patient@example.test"
    )
    family, headers = _linked_family(
        client,
        admin_headers,
        user_factory,
        profile["id"],
        f"{prefix}-family@example.test",
    )
    return profile, family, headers


@pytest.mark.parametrize(
    ("content_type", "filename", "expected_type"),
    [
        ("image/png", "support.png", "image"),
        ("video/mp4", "support.mp4", "video"),
        ("audio/webm;codecs=opus", "support.webm", "voice"),
    ],
)
def test_linked_family_uploads_supported_media(
    client,
    admin_headers,
    user_factory,
    db_session,
    content_type,
    filename,
    expected_type,
):
    profile, family, headers = _family_context(
        client, admin_headers, user_factory, expected_type
    )
    response = _upload(
        client,
        headers,
        profile["id"],
        content_type=content_type,
        filename=filename,
        message="  You are doing wonderfully.  ",
        caption="  From your family  ",
        media_duration_seconds="12",
    )
    assert response.status_code == 201, response.text
    data = response.json()
    assert data["sender_user_id"] == str(family.id)
    assert data["message"] == "You are doing wonderfully."
    assert data["caption"] == "From your family"
    assert data["media_type"] == expected_type
    assert data["media_mime_type"] == content_type.split(";", 1)[0]
    assert data["media_size_bytes"] == len(b"valid-media")
    assert data["media_duration_seconds"] == 12
    assert data["media_url"].startswith("/media/encouragement_uploads/")
    persisted = db_session.execute(
        select(FamilyEncouragement).where(FamilyEncouragement.id == UUID(data["id"]))
    ).scalar_one()
    assert persisted.sender_user_id == family.id
    assert persisted.media_url == data["media_url"]


def test_unlinked_family_media_rejected(client, admin_headers, user_factory):
    _, profile = _create_patient(
        client, admin_headers, user_factory, "unlinked-media-patient@example.test"
    )
    family = user_factory(email="unlinked-media-family@example.test", roles=("family",))
    response = _upload(
        client, _login(client, family.email), profile["id"]
    )
    assert response.status_code == 403


@pytest.mark.parametrize("role", ["patient", "doctor", "therapist"])
def test_non_family_role_cannot_create_media(
    client, admin_headers, user_factory, role
):
    _, profile = _create_patient(
        client, admin_headers, user_factory, f"denied-{role}-patient@example.test"
    )
    actor = user_factory(email=f"denied-{role}@example.test", roles=(role,))
    response = _upload(client, _login(client, actor.email), profile["id"])
    assert response.status_code == 403


@pytest.mark.parametrize(
    ("content_type", "filename"),
    [("application/pdf", "bad.pdf"), ("image/gif", "bad.gif")],
)
def test_unsupported_media_mime_rejected(
    client, admin_headers, user_factory, content_type, filename
):
    profile, _, headers = _family_context(
        client, admin_headers, user_factory, filename.replace(".", "-")
    )
    response = _upload(
        client, headers, profile["id"], content_type=content_type, filename=filename
    )
    assert response.status_code == 400


def test_empty_media_rejected(client, admin_headers, user_factory):
    profile, _, headers = _family_context(
        client, admin_headers, user_factory, "empty-media"
    )
    assert _upload(client, headers, profile["id"], content=b"").status_code == 400


@pytest.mark.parametrize(
    ("content_type", "filename"),
    [
        ("image/png", "large.png"),
        ("video/mp4", "large.mp4"),
        ("audio/ogg", "large.ogg"),
    ],
)
def test_media_size_limit_enforced(
    client, admin_headers, user_factory, monkeypatch, content_type, filename
):
    profile, _, headers = _family_context(
        client, admin_headers, user_factory, filename.replace(".", "-")
    )
    kind, extension, _ = media.MEDIA_RULES[content_type]
    monkeypatch.setitem(media.MEDIA_RULES, content_type, (kind, extension, 8))
    response = _upload(
        client, headers, profile["id"], content=b"123456789", content_type=content_type,
        filename=filename,
    )
    assert response.status_code == 413


@pytest.mark.parametrize("field", ["message", "caption"])
def test_whitespace_optional_text_rejected(
    client, admin_headers, user_factory, field
):
    profile, _, headers = _family_context(
        client, admin_headers, user_factory, f"whitespace-{field}"
    )
    response = _upload(client, headers, profile["id"], **{field: "   "})
    assert response.status_code == 422


def test_text_endpoint_requires_message_or_media(
    client, admin_headers, user_factory
):
    profile, _, headers = _family_context(
        client, admin_headers, user_factory, "invariant"
    )
    response = client.post(
        "/api/v1/encouragements",
        headers=headers,
        json={"patient_profile_id": profile["id"]},
    )
    assert response.status_code == 422


def test_safe_uuid_filename_ignores_original_name(
    client, admin_headers, user_factory, temp_encouragement_storage
):
    profile, _, headers = _family_context(
        client, admin_headers, user_factory, "safe-name"
    )
    response = _upload(client, headers, profile["id"], filename="family photo.png")
    assert response.status_code == 201
    stored = list((temp_encouragement_storage / "encouragement_uploads").iterdir())
    assert len(stored) == 1
    assert re.fullmatch(r"[0-9a-f]{32}\.png", stored[0].name)
    assert "family photo" not in response.json()["media_url"]


def test_path_traversal_filename_rejected(
    client, admin_headers, user_factory, temp_encouragement_storage
):
    profile, _, headers = _family_context(
        client, admin_headers, user_factory, "unsafe-name"
    )
    response = _upload(client, headers, profile["id"], filename="../escape.png")
    assert response.status_code == 400
    assert not (temp_encouragement_storage / "encouragement_uploads").exists()


def test_failed_database_creation_removes_uploaded_file(
    client, admin_headers, user_factory, temp_encouragement_storage, monkeypatch
):
    profile, _, headers = _family_context(
        client, admin_headers, user_factory, "atomic-cleanup"
    )

    def fail_audit(*args, **kwargs):
        raise RuntimeError("forced database failure")

    monkeypatch.setattr(service, "record_audit", fail_audit)
    with pytest.raises(RuntimeError, match="forced database failure"):
        _upload(client, headers, profile["id"])
    upload_dir = temp_encouragement_storage / "encouragement_uploads"
    assert not upload_dir.exists() or list(upload_dir.iterdir()) == []


def test_media_creation_writes_audit_without_clinical_fields(
    client, admin_headers, user_factory, db_session
):
    profile, _, headers = _family_context(
        client, admin_headers, user_factory, "audit-media"
    )
    response = _upload(client, headers, profile["id"])
    assert response.status_code == 201
    db_session.rollback()
    actions = db_session.execute(select(AuditLog.action)).scalars().all()
    assert "create_family_encouragement_media" in actions
    forbidden = {"diagnosis", "score", "urgency", "treatment", "interpretation"}
    assert forbidden.isdisjoint(response.json().keys())


def test_media_creation_rejects_extra_multipart_field(
    client, admin_headers, user_factory
):
    profile, _, headers = _family_context(
        client, admin_headers, user_factory, "extra-field"
    )
    response = _upload(client, headers, profile["id"], forged_status="urgent")
    assert response.status_code == 422
