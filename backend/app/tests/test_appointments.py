"""Appointment booking tests.

Reuses the isolated in-memory DB fixtures from conftest. Appointments are
coordination content only — never emergency care, diagnosis, or assessment.
"""

import struct
import zlib
from datetime import date, timedelta

import pytest
from sqlalchemy import select

from app.models import AuditLog, ProviderAvailabilitySlot, ProviderProfile
from app.modules.providers import media as provider_media
from app.scripts.seed_roles import seed_roles

PASSWORD = "Secret123!"
SLOT_DATE = (date.today() + timedelta(days=3)).isoformat()


@pytest.fixture()
def seeded_roles(db_session):
    seed_roles(db_session)


@pytest.fixture(autouse=True)
def temp_provider_storage(tmp_path, monkeypatch):
    """Redirect provider photo uploads to a temp dir (keeps real storage clean)."""
    monkeypatch.setattr(provider_media, "storage_root", lambda: tmp_path)
    return tmp_path


def _tiny_png() -> bytes:
    def chunk(tag: bytes, data: bytes) -> bytes:
        return (
            struct.pack(">I", len(data))
            + tag
            + data
            + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)
        )

    sig = b"\x89PNG\r\n\x1a\n"
    ihdr = struct.pack(">IIBBBBB", 1, 1, 8, 2, 0, 0, 0)
    idat = zlib.compress(b"\x00\xff\x00\x00")
    return sig + chunk(b"IHDR", ihdr) + chunk(b"IDAT", idat) + chunk(b"IEND", b"")


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


def _make_slot(db_session, provider, mode="in_person", start="10:00"):
    slot = ProviderAvailabilitySlot(
        provider_user_id=provider.id,
        slot_date=date.today() + timedelta(days=3),
        start_time=start,
        end_time="10:30",
        appointment_mode=mode,
        location="Clinic Room 1" if mode == "in_person" else None,
        meeting_url=None if mode == "in_person" else "https://meet.local/x",
        is_available=True,
    )
    db_session.add(slot)
    db_session.commit()
    return slot


def _provider(user_factory, email, role="doctor"):
    return user_factory(email=email, roles=(role,))


def _profile(
    db_session,
    provider,
    specialty="Memory support",
    rating=4.9,
    count=20,
    governorate="Nablus",
    city="Nablus",
):
    profile = ProviderProfile(
        provider_user_id=provider.id,
        specialty=specialty,
        bio_short="Supportive focus.",
        clinic_name="NeuroBridge Demo Center",
        governorate=governorate,
        city=city,
        location="NeuroBridge Demo Center, Room 2",
        experience_label="12 years experience",
        phone_number_demo="+970-000-000-000",
        rating_average=rating,
        rating_count=count,
    )
    db_session.add(profile)
    db_session.commit()
    return profile


def _upload_photo(client, headers, provider_id, *, content=None, ctype="image/png"):
    content = _tiny_png() if content is None else content
    return client.post(
        f"/api/v1/providers/{provider_id}/photo",
        headers=headers,
        files={"file": ("photo.png", content, ctype)},
    )


def _book(client, headers, profile_id, provider_id, slot_id, reason="Follow-up"):
    return client.post(
        "/api/v1/appointments",
        headers=headers,
        json={
            "patient_profile_id": profile_id,
            "provider_user_id": str(provider_id),
            "availability_slot_id": str(slot_id),
            "reason": reason,
        },
    )


# --- providers / availability ------------------------------------------------


def test_unauthenticated_blocked(client, seeded_roles):
    assert client.get("/api/v1/appointments").status_code == 401
    assert client.get("/api/v1/providers").status_code == 401
    assert client.post("/api/v1/appointments", json={}).status_code == 401


def test_providers_lists_doctor_and_therapist(client, admin_headers, user_factory):
    _provider(user_factory, "doc@example.test", "doctor")
    _provider(user_factory, "th@example.test", "therapist")
    resp = client.get("/api/v1/providers", headers=admin_headers)
    assert resp.status_code == 200
    roles = {p["role"] for p in resp.json()["providers"]}
    assert {"doctor", "therapist"} <= roles


def test_providers_include_rich_fields(
    client, admin_headers, db_session, user_factory
):
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    _profile(db_session, doctor)
    _make_slot(db_session, doctor, mode="in_person")
    resp = client.get("/api/v1/providers", headers=admin_headers)
    assert resp.status_code == 200
    p = next(
        x
        for x in resp.json()["providers"]
        if x["provider_user_id"] == str(doctor.id)
    )
    assert p["specialty"] == "Memory support"
    assert p["rating_average"] == 4.9
    assert p["rating_count"] == 20
    assert p["available_slot_count"] >= 1
    assert p["in_person_available"] is True
    assert p["location"] == "NeuroBridge Demo Center, Room 2"
    assert p["governorate"] == "Nablus"
    assert p["city"] == "Nablus"
    assert p["phone_number_demo"] == "+970-000-000-000"
    assert p["photo_url"] is None
    # Earliest available slot date is derived from real availability.
    assert p["next_available_date"] == SLOT_DATE


def test_filter_by_governorate(client, admin_headers, db_session, user_factory):
    d1 = _provider(user_factory, "nablus@example.test", "doctor")
    _profile(db_session, d1, governorate="Nablus", city="Nablus")
    d2 = _provider(user_factory, "hebron@example.test", "doctor")
    _profile(db_session, d2, governorate="Hebron", city="Hebron")

    resp = client.get("/api/v1/providers?governorate=Nablus", headers=admin_headers)
    assert resp.status_code == 200
    ids = {x["provider_user_id"] for x in resp.json()["providers"]}
    assert str(d1.id) in ids
    assert str(d2.id) not in ids


def test_filter_by_role_and_mode(client, admin_headers, db_session, user_factory):
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    _make_slot(db_session, doctor, mode="online")
    therapist = _provider(user_factory, "th@example.test", "therapist")

    by_role = client.get("/api/v1/providers?role=doctor", headers=admin_headers)
    roles = {x["role"] for x in by_role.json()["providers"]}
    assert roles == {"doctor"}
    assert str(therapist.id) not in {
        x["provider_user_id"] for x in by_role.json()["providers"]
    }

    by_mode = client.get(
        "/api/v1/providers?mode=online", headers=admin_headers
    ).json()["providers"]
    assert str(doctor.id) in {x["provider_user_id"] for x in by_mode}


def test_get_single_provider(client, admin_headers, db_session, user_factory):
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    _profile(db_session, doctor, specialty="Cognitive follow-up")
    resp = client.get(f"/api/v1/providers/{doctor.id}", headers=admin_headers)
    assert resp.status_code == 200
    assert resp.json()["specialty"] == "Cognitive follow-up"


# --- provider photo upload ---------------------------------------------------


def test_admin_can_upload_provider_photo(client, admin_headers, user_factory):
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    resp = _upload_photo(client, admin_headers, doctor.id)
    assert resp.status_code == 200, resp.text
    assert resp.json()["photo_url"].startswith("/media/provider_photos/")


def test_family_cannot_upload_provider_photo(client, admin_headers, user_factory):
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    user_factory(email="fam@example.test", roles=("family",))
    fam = _login(client, "fam@example.test")
    resp = _upload_photo(client, fam, doctor.id)
    assert resp.status_code == 403


def test_upload_invalid_image_rejected(client, admin_headers, user_factory):
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    resp = _upload_photo(
        client, admin_headers, doctor.id, content=b"not-an-image", ctype="text/plain"
    )
    assert resp.status_code == 400


def test_upload_photo_unknown_provider_404(client, admin_headers, user_factory):
    # A patient user is not a provider.
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    patient_user_id = client.get(
        f"/api/v1/patients/{profile['id']}", headers=admin_headers
    ).json()["user_id"]
    resp = _upload_photo(client, admin_headers, patient_user_id)
    assert resp.status_code == 404


def test_provider_default_focus_without_profile(
    client, admin_headers, user_factory
):
    therapist = _provider(user_factory, "th@example.test", "therapist")
    resp = client.get("/api/v1/providers", headers=admin_headers)
    p = next(
        x
        for x in resp.json()["providers"]
        if x["provider_user_id"] == str(therapist.id)
    )
    assert p["specialty"] == "Therapy support"
    assert p["rating_average"] is None


def test_availability_lists_available_slots(
    client, admin_headers, db_session, user_factory
):
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    slot = _make_slot(db_session, doctor, mode="online")
    resp = client.get(
        f"/api/v1/providers/{doctor.id}/availability", headers=admin_headers
    )
    assert resp.status_code == 200
    slots = resp.json()["slots"]
    assert any(s["id"] == str(slot.id) for s in slots)
    assert slots[0]["appointment_mode"] == "online"
    assert slots[0]["meeting_url"]


# --- booking / RBAC ----------------------------------------------------------


def test_linked_family_can_book(client, admin_headers, db_session, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    slot = _make_slot(db_session, doctor, mode="in_person")
    headers = _login(client, "fam@example.test")

    resp = _book(client, headers, profile["id"], doctor.id, slot.id)
    assert resp.status_code == 201, resp.text
    data = resp.json()
    assert data["status"] == "pending"
    assert data["provider_user_id"] == str(doctor.id)
    assert data["appointment_mode"] == "in_person"
    assert data["location"] == "Clinic Room 1"
    assert data["preferred_date"] == SLOT_DATE
    assert data["preferred_time"] == "10:00"


def test_unlinked_family_cannot_book(client, admin_headers, db_session, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _provider(user_factory, "doc@example.test", "doctor")
    user_factory(email="fam@example.test", roles=("family",))
    doctor = _provider(user_factory, "doc2@example.test", "doctor")
    slot = _make_slot(db_session, doctor)
    headers = _login(client, "fam@example.test")

    resp = _book(client, headers, profile["id"], doctor.id, slot.id)
    assert resp.status_code == 403


def test_patient_cannot_book(client, admin_headers, db_session, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    slot = _make_slot(db_session, doctor)
    headers = _login(client, "p@example.test")

    resp = _book(client, headers, profile["id"], doctor.id, slot.id)
    assert resp.status_code == 403


def test_invalid_provider_blocked(client, admin_headers, db_session, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    # A non-provider (patient) user id as "provider".
    not_provider, _ = _create_patient(client, admin_headers, user_factory, "np@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    slot = _make_slot(db_session, doctor)
    headers = _login(client, "fam@example.test")

    resp = _book(client, headers, profile["id"], not_provider.id, slot.id)
    assert resp.status_code == 400


def test_invalid_slot_blocked(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    headers = _login(client, "fam@example.test")

    resp = _book(
        client, headers, profile["id"], doctor.id,
        "00000000-0000-0000-0000-000000000000",
    )
    assert resp.status_code == 400


def test_slot_consumed_after_booking(
    client, admin_headers, db_session, user_factory
):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    slot = _make_slot(db_session, doctor)
    headers = _login(client, "fam@example.test")

    assert _book(client, headers, profile["id"], doctor.id, slot.id).status_code == 201
    # The slot no longer appears as available, and cannot be booked again.
    avail = client.get(
        f"/api/v1/providers/{doctor.id}/availability", headers=headers
    ).json()["slots"]
    assert all(s["id"] != str(slot.id) for s in avail)
    assert _book(client, headers, profile["id"], doctor.id, slot.id).status_code == 400


def test_empty_reason_rejected(client, admin_headers, db_session, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    slot = _make_slot(db_session, doctor)
    headers = _login(client, "fam@example.test")

    resp = _book(client, headers, profile["id"], doctor.id, slot.id, reason="   ")
    assert resp.status_code == 422


def test_missing_provider_rejected(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    headers = _login(client, "fam@example.test")

    resp = client.post(
        "/api/v1/appointments",
        headers=headers,
        json={"patient_profile_id": profile["id"], "reason": "Hi"},
    )
    assert resp.status_code == 422


def test_family_cannot_set_status(client, admin_headers, db_session, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    slot = _make_slot(db_session, doctor)
    headers = _login(client, "fam@example.test")

    resp = client.post(
        "/api/v1/appointments",
        headers=headers,
        json={
            "patient_profile_id": profile["id"],
            "provider_user_id": str(doctor.id),
            "availability_slot_id": str(slot.id),
            "reason": "Follow-up",
            "status": "approved",
        },
    )
    assert resp.status_code == 201
    assert resp.json()["status"] == "pending"


# --- visibility --------------------------------------------------------------


def test_family_sees_linked(client, admin_headers, db_session, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    slot = _make_slot(db_session, doctor)
    headers = _login(client, "fam@example.test")
    made = _book(client, headers, profile["id"], doctor.id, slot.id).json()

    resp = client.get("/api/v1/appointments", headers=headers)
    ids = {a["id"] for a in resp.json()["appointments"]}
    assert made["id"] in ids


def test_patient_sees_own(client, admin_headers, db_session, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    slot = _make_slot(db_session, doctor)
    fam_headers = _login(client, "fam@example.test")
    made = _book(client, fam_headers, profile["id"], doctor.id, slot.id).json()

    patient_headers = _login(client, "p@example.test")
    resp = client.get("/api/v1/appointments", headers=patient_headers)
    ids = {a["id"] for a in resp.json()["appointments"]}
    assert made["id"] in ids


def test_provider_doctor_sees_appointment(
    client, admin_headers, db_session, user_factory
):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    slot = _make_slot(db_session, doctor)
    fam_headers = _login(client, "fam@example.test")
    made = _book(client, fam_headers, profile["id"], doctor.id, slot.id).json()

    doc_headers = _login(client, "doc@example.test")
    resp = client.get("/api/v1/appointments", headers=doc_headers)
    ids = {a["id"] for a in resp.json()["appointments"]}
    assert made["id"] in ids


# --- status update -----------------------------------------------------------


def test_provider_doctor_can_update_status(
    client, admin_headers, db_session, user_factory
):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    slot = _make_slot(db_session, doctor)
    fam_headers = _login(client, "fam@example.test")
    made = _book(client, fam_headers, profile["id"], doctor.id, slot.id).json()

    doc_headers = _login(client, "doc@example.test")
    resp = client.patch(
        f"/api/v1/appointments/{made['id']}/status",
        headers=doc_headers,
        json={"status": "approved"},
    )
    assert resp.status_code == 200, resp.text
    assert resp.json()["status"] == "approved"


def test_unrelated_doctor_cannot_update_status(
    client, admin_headers, db_session, user_factory
):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    slot = _make_slot(db_session, doctor)
    fam_headers = _login(client, "fam@example.test")
    made = _book(client, fam_headers, profile["id"], doctor.id, slot.id).json()

    _provider(user_factory, "other@example.test", "doctor")
    other_headers = _login(client, "other@example.test")
    resp = client.patch(
        f"/api/v1/appointments/{made['id']}/status",
        headers=other_headers,
        json={"status": "approved"},
    )
    assert resp.status_code == 403


def test_cancel_reopens_slot(client, admin_headers, db_session, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    slot = _make_slot(db_session, doctor)
    fam_headers = _login(client, "fam@example.test")
    made = _book(client, fam_headers, profile["id"], doctor.id, slot.id).json()

    doc_headers = _login(client, "doc@example.test")
    client.patch(
        f"/api/v1/appointments/{made['id']}/status",
        headers=doc_headers,
        json={"status": "cancelled"},
    )
    avail = client.get(
        f"/api/v1/providers/{doctor.id}/availability", headers=fam_headers
    ).json()["slots"]
    assert any(s["id"] == str(slot.id) for s in avail)


def test_audit_log_created(client, admin_headers, db_session, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    slot = _make_slot(db_session, doctor)
    fam_headers = _login(client, "fam@example.test")
    _book(client, fam_headers, profile["id"], doctor.id, slot.id)

    db_session.rollback()
    actions = db_session.execute(select(AuditLog.action)).scalars().all()
    assert "create_appointment_request" in actions
