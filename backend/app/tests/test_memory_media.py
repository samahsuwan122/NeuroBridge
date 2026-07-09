"""Phase 18A Memory Album image-upload tests.

Covers the POST /api/v1/memories/{id}/media endpoint: access control, image
validation, storage/URL behaviour, and audit. Uploads are redirected to a
temporary directory so no real storage files are created by the test run.

Memory Album images are supportive/family-engagement content only — no
diagnosis, scoring, or medical interpretation.
"""

import struct
import zlib

import pytest
from sqlalchemy import select

from app.models import AuditLog
from app.modules.memories import media
from app.scripts.seed_roles import seed_roles

PASSWORD = "Secret123!"


@pytest.fixture()
def seeded_roles(db_session):
    seed_roles(db_session)


@pytest.fixture(autouse=True)
def temp_storage(tmp_path, monkeypatch):
    """Redirect uploads to a temp dir so the real storage folder stays clean."""
    monkeypatch.setattr(media, "storage_root", lambda: tmp_path)
    return tmp_path


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


def _create_memory(client, headers, patient_profile_id, **overrides):
    body = {
        "patient_profile_id": patient_profile_id,
        "title": "Family picnic",
        **overrides,
    }
    return client.post("/api/v1/memories", headers=headers, json=body)


def _tiny_png() -> bytes:
    """A minimal valid 1x1 PNG (no external fixtures needed)."""

    def chunk(tag: bytes, data: bytes) -> bytes:
        return (
            struct.pack(">I", len(data))
            + tag
            + data
            + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
        )

    sig = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", 1, 1, 8, 2, 0, 0, 0)
    raw = b"\x00\xff\x00\x00"  # one red pixel row (filter byte + RGB)
    idat = zlib.compress(raw)
    return sig + chunk(b"IHDR", ihdr) + chunk(b"IDAT", idat) + chunk(b"IEND", b"")


def _upload(client, headers, memory_id, *, content=None, content_type="image/png",
            filename="pic.png"):
    content = _tiny_png() if content is None else content
    return client.post(
        f"/api/v1/memories/{memory_id}/media",
        headers=headers,
        files={"file": (filename, content, content_type)},
    )


def _seed_memory(client, admin_headers, user_factory, email):
    _, profile = _create_patient(client, admin_headers, user_factory, email)
    headers = _login(client, email)
    memory = _create_memory(client, headers, profile["id"]).json()
    return headers, memory


# --- access control ----------------------------------------------------------


def test_creator_can_upload_image(client, admin_headers, user_factory):
    headers, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    resp = _upload(client, headers, memory["id"])
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["media_type"] == "image"
    assert data["media_url"].startswith("/media/memory_uploads/")


def test_admin_can_upload_image(client, admin_headers, user_factory):
    _, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    resp = _upload(client, admin_headers, memory["id"])
    assert resp.status_code == 200, resp.text
    assert resp.json()["media_type"] == "image"


def test_unauthenticated_upload_401(client, admin_headers, user_factory):
    _, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    resp = client.post(
        f"/api/v1/memories/{memory['id']}/media",
        files={"file": ("pic.png", _tiny_png(), "image/png")},
    )
    assert resp.status_code == 401


def test_doctor_cannot_upload(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    p_headers = _login(client, "p@example.test")
    memory = _create_memory(client, p_headers, profile["id"]).json()
    # Assign a doctor to the patient; the doctor still may not upload.
    doctor = user_factory(email="doc@example.test", roles=("doctor",))
    client.post(
        f"/api/v1/patients/{profile['id']}/assign-clinician",
        headers=admin_headers,
        json={"clinician_user_id": str(doctor.id), "assignment_type": "doctor"},
    )
    d_headers = _login(client, "doc@example.test")
    assert _upload(client, d_headers, memory["id"]).status_code == 403


def test_unrelated_user_cannot_upload(client, admin_headers, user_factory):
    _, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    # A different patient (not the creator, not linked) may not upload.
    user_factory(email="other@example.test", roles=("patient",))
    other = _login(client, "other@example.test")
    assert _upload(client, other, memory["id"]).status_code == 403


def test_linked_family_non_creator_cannot_upload(client, admin_headers, user_factory):
    headers, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    # The patient created the memory; a linked family member is not the creator.
    family = user_factory(email="fam@example.test", roles=("family",))
    client.post(
        f"/api/v1/patients/{memory['patient_profile_id']}/link-family",
        headers=admin_headers,
        json={"family_user_id": str(family.id)},
    )
    fam = _login(client, "fam@example.test")
    assert _upload(client, fam, memory["id"]).status_code == 403


# --- validation --------------------------------------------------------------


def test_non_image_rejected(client, admin_headers, user_factory):
    headers, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    resp = _upload(client, headers, memory["id"], content=b"not an image",
                   content_type="text/plain", filename="note.txt")
    assert resp.status_code == 400


def test_empty_file_rejected(client, admin_headers, user_factory):
    headers, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    resp = _upload(client, headers, memory["id"], content=b"",
                   content_type="image/png")
    assert resp.status_code == 400


def test_oversized_upload_rejected(client, admin_headers, user_factory):
    headers, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    big = b"\x89PNG\r\n\x1a\n" + b"0" * (media.MAX_UPLOAD_BYTES + 1)
    resp = _upload(client, headers, memory["id"], content=big,
                   content_type="image/png")
    assert resp.status_code == 413


def test_missing_memory_404(client, admin_headers):
    resp = _upload(
        client, admin_headers, "00000000-0000-0000-0000-000000000000"
    )
    assert resp.status_code == 404


def test_soft_deleted_memory_cannot_upload(client, admin_headers, user_factory):
    headers, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    assert client.post(
        f"/api/v1/memories/{memory['id']}/delete", headers=headers
    ).status_code == 200
    assert _upload(client, headers, memory["id"]).status_code == 404


# --- storage / cleanup / audit ----------------------------------------------


def test_upload_writes_into_controlled_folder(
    client, admin_headers, user_factory, temp_storage
):
    headers, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    resp = _upload(client, headers, memory["id"])
    assert resp.status_code == 200
    files = list((temp_storage / "memory_uploads").glob("*"))
    assert len(files) == 1  # exactly one stored image, safe uuid name


def test_replacing_image_removes_old_local_file(
    client, admin_headers, user_factory, temp_storage
):
    headers, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    _upload(client, headers, memory["id"])
    _upload(client, headers, memory["id"])  # replace
    files = list((temp_storage / "memory_uploads").glob("*"))
    assert len(files) == 1  # old local file removed on replace


def test_audit_log_created_for_upload(
    client, admin_headers, user_factory, db_session
):
    headers, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    _upload(client, headers, memory["id"])
    db_session.rollback()
    actions = db_session.execute(select(AuditLog.action)).scalars().all()
    assert "memory_media_uploaded" in actions


def test_upload_adds_no_diagnostic_fields(client, admin_headers, user_factory):
    headers, memory = _seed_memory(client, admin_headers, user_factory, "p@example.test")
    data = _upload(client, headers, memory["id"]).json()
    forbidden = {"diagnosis", "disease", "dementia", "alzheimer", "interpretation",
                 "score", "treatment"}
    for key in data:
        assert not any(bad in key.lower() for bad in forbidden)
