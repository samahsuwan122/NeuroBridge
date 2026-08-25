"""Dedicated tests for the provider self-profile API."""

import pytest

from app.modules.providers import media as provider_media
from app.scripts.seed_roles import seed_roles


PASSWORD = "Secret123!"


@pytest.fixture()
def seeded_roles(db_session):
    seed_roles(db_session)


@pytest.fixture(autouse=True)
def temp_provider_storage(tmp_path, monkeypatch):
    monkeypatch.setattr(provider_media, "storage_root", lambda: tmp_path)
    return tmp_path


def _login(client, email: str) -> dict[str, str]:
    response = client.post(
        "/api/v1/auth/login",
        json={"email_or_phone": email, "password": PASSWORD},
    )
    assert response.status_code == 200, response.text
    return {"Authorization": f"Bearer {response.json()['access_token']}"}


def _provider(client, user_factory, role: str, email: str):
    user = user_factory(
        email=email,
        full_name=f"Test {role.title()}",
        roles=(role,),
    )
    return user, _login(client, email)


def test_doctor_can_get_self_profile(client, user_factory, seeded_roles):
    doctor, headers = _provider(
        client, user_factory, "doctor", "self-doctor@example.test"
    )

    response = client.get("/api/v1/providers/me", headers=headers)

    assert response.status_code == 200, response.text
    assert response.json()["provider_user_id"] == str(doctor.id)
    assert response.json()["role"] == "doctor"


def test_therapist_can_get_self_profile(client, user_factory, seeded_roles):
    therapist, headers = _provider(
        client, user_factory, "therapist", "self-therapist@example.test"
    )

    response = client.get("/api/v1/providers/me", headers=headers)

    assert response.status_code == 200, response.text
    assert response.json()["provider_user_id"] == str(therapist.id)
    assert response.json()["role"] == "therapist"


@pytest.mark.parametrize("role", ["family", "patient", "admin"])
def test_non_provider_roles_cannot_access_self_profile(
    client, user_factory, seeded_roles, role
):
    user = user_factory(email=f"self-{role}@example.test", roles=(role,))
    headers = _login(client, user.email)

    assert client.get("/api/v1/providers/me", headers=headers).status_code == 403
    assert (
        client.patch(
            "/api/v1/providers/me",
            headers=headers,
            json={"specialty": "Not allowed"},
        ).status_code
        == 403
    )
    assert (
        client.post(
            "/api/v1/providers/me/photo",
            headers=headers,
            files={"file": ("photo.jpg", b"jpeg", "image/jpeg")},
        ).status_code
        == 403
    )


def test_provider_can_patch_all_supported_self_fields(
    client, user_factory, seeded_roles
):
    provider, headers = _provider(
        client, user_factory, "doctor", "patch-provider@example.test"
    )
    payload = {
        "display_name": "Dr. Samira Khalil",
        "specialty": "Cognitive follow-up",
        "bio_short": "Supports patients and families through follow-up.",
        "languages": ["ar", "en", "fr"],
        "clinic_name": "NeuroBridge Clinic",
        "location": "Nablus, Room 4",
    }

    response = client.patch(
        "/api/v1/providers/me", headers=headers, json=payload
    )

    assert response.status_code == 200, response.text
    data = response.json()
    assert data["provider_user_id"] == str(provider.id)
    assert data["full_name"] == payload["display_name"]
    assert data["specialty"] == payload["specialty"]
    assert data["bio_short"] == payload["bio_short"]
    assert data["languages"] == payload["languages"]
    assert data["clinic_name"] == payload["clinic_name"]
    assert data["location"] == payload["location"]


def test_role_cannot_be_changed_through_self_profile(
    client, user_factory, seeded_roles
):
    _, headers = _provider(
        client, user_factory, "doctor", "immutable-role@example.test"
    )

    response = client.patch(
        "/api/v1/providers/me",
        headers=headers,
        json={"role": "therapist", "specialty": "Updated safely"},
    )

    assert response.status_code == 200, response.text
    assert response.json()["role"] == "doctor"
    assert response.json()["specialty"] == "Updated safely"
    assert client.get("/api/v1/providers/me", headers=headers).json()["role"] == "doctor"


@pytest.mark.parametrize(
    "languages",
    [["xx"], ["ar", "EN-us"], ["ar", "en", "fr", "es", "de", "ar"]],
)
def test_invalid_language_values_are_rejected(
    client, user_factory, seeded_roles, languages
):
    _, headers = _provider(
        client,
        user_factory,
        "therapist",
        f"invalid-language-{len(languages)}-{languages[-1]}@example.test",
    )

    response = client.patch(
        "/api/v1/providers/me",
        headers=headers,
        json={"languages": languages},
    )

    assert response.status_code == 422


@pytest.mark.parametrize(
    ("field", "value"),
    [
        ("display_name", "x"),
        ("display_name", "x" * 256),
        ("specialty", "x" * 256),
        ("bio_short", "x" * 501),
        ("clinic_name", "x" * 256),
        ("location", "x" * 256),
    ],
)
def test_invalid_or_oversized_profile_fields_are_rejected(
    client, user_factory, seeded_roles, field, value
):
    _, headers = _provider(
        client,
        user_factory,
        "doctor",
        f"invalid-{field}-{len(value)}@example.test",
    )

    response = client.patch(
        "/api/v1/providers/me", headers=headers, json={field: value}
    )

    assert response.status_code == 422


@pytest.mark.parametrize(
    ("filename", "content_type", "content"),
    [
        ("profile.jpg", "image/jpeg", b"jpeg-profile-data"),
        ("profile.png", "image/png", b"png-profile-data"),
        ("profile.webp", "image/webp", b"webp-profile-data"),
    ],
)
def test_supported_photo_types_are_accepted(
    client, user_factory, seeded_roles, filename, content_type, content
):
    _, headers = _provider(
        client,
        user_factory,
        "doctor",
        f"photo-{filename.replace('.', '-')}@example.test",
    )

    response = client.post(
        "/api/v1/providers/me/photo",
        headers=headers,
        files={"file": (filename, content, content_type)},
    )

    assert response.status_code == 200, response.text
    assert response.json()["photo_url"].endswith(filename[filename.rfind(".") :])


def test_invalid_photo_mime_is_rejected(client, user_factory, seeded_roles):
    _, headers = _provider(
        client, user_factory, "doctor", "invalid-photo@example.test"
    )

    response = client.post(
        "/api/v1/providers/me/photo",
        headers=headers,
        files={"file": ("profile.gif", b"gif-data", "image/gif")},
    )

    assert response.status_code == 400


def test_oversized_photo_is_rejected(client, user_factory, seeded_roles):
    _, headers = _provider(
        client, user_factory, "therapist", "large-photo@example.test"
    )

    response = client.post(
        "/api/v1/providers/me/photo",
        headers=headers,
        files={
            "file": (
                "profile.webp",
                b"x" * (provider_media.MAX_UPLOAD_BYTES + 1),
                "image/webp",
            )
        },
    )

    assert response.status_code == 413


def test_self_profile_update_cannot_modify_another_provider(
    client, user_factory, seeded_roles
):
    first, first_headers = _provider(
        client, user_factory, "doctor", "first-provider@example.test"
    )
    second, second_headers = _provider(
        client, user_factory, "therapist", "second-provider@example.test"
    )

    response = client.patch(
        "/api/v1/providers/me",
        headers=first_headers,
        json={"display_name": "First Provider Updated"},
    )

    assert response.status_code == 200, response.text
    assert response.json()["provider_user_id"] == str(first.id)
    second_profile = client.get(
        "/api/v1/providers/me", headers=second_headers
    ).json()
    assert second_profile["provider_user_id"] == str(second.id)
    assert second_profile["full_name"] == "Test Therapist"


def test_saved_self_profile_reloads(client, user_factory, seeded_roles):
    provider, headers = _provider(
        client, user_factory, "therapist", "reload-provider@example.test"
    )
    payload = {
        "display_name": "Therapist Reloaded",
        "specialty": "Daily living support",
        "bio_short": "A persisted provider biography.",
        "languages": ["de", "es"],
        "clinic_name": "Reload Clinic",
        "location": "Hebron",
    }
    updated = client.patch(
        "/api/v1/providers/me", headers=headers, json=payload
    )
    assert updated.status_code == 200, updated.text

    reloaded = client.get("/api/v1/providers/me", headers=headers)

    assert reloaded.status_code == 200, reloaded.text
    data = reloaded.json()
    assert data["provider_user_id"] == str(provider.id)
    assert data["full_name"] == payload["display_name"]
    assert data["specialty"] == payload["specialty"]
    assert data["bio_short"] == payload["bio_short"]
    assert data["languages"] == payload["languages"]
    assert data["clinic_name"] == payload["clinic_name"]
    assert data["location"] == payload["location"]
