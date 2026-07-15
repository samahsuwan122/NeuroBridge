"""Provider inquiry messaging + seed demo-phone tests.

Reuses the isolated in-memory DB fixtures from conftest. Provider inquiries are
non-urgent care-coordination content only — never emergency care, diagnosis, or
assessment.
"""

import pytest
from sqlalchemy import select

from app.models import AuditLog, ProviderProfile
from app.scripts.seed_demo_data import LEGACY_DEMO_PHONE, seed_demo_data
from app.scripts.seed_roles import seed_roles

PASSWORD = "Secret123!"


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


def _provider(user_factory, email, role="doctor"):
    return user_factory(email=email, roles=(role,))


def _send(client, headers, provider_id, profile_id, message="Hello, quick question"):
    return client.post(
        "/api/v1/provider-messages",
        headers=headers,
        json={
            "provider_user_id": str(provider_id),
            "patient_profile_id": str(profile_id),
            "message": message,
        },
    )


def _reply(client, headers, message_id, body="Thanks for reaching out."):
    return client.post(
        f"/api/v1/provider-messages/{message_id}/replies",
        headers=headers,
        json={"body": body},
    )


def _thread(client, headers, message_id):
    return client.get(
        f"/api/v1/provider-messages/{message_id}", headers=headers
    )


def _mark_read(client, headers, message_id):
    return client.patch(
        f"/api/v1/provider-messages/{message_id}/read", headers=headers
    )


def _unread(client, headers):
    return client.get("/api/v1/provider-messages/unread-count", headers=headers)


def _thread_fixture(client, admin_headers, user_factory):
    """Create a linked family + doctor and an original inquiry thread.

    Returns (profile, doctor, fam_headers, doc_headers, message_id).
    """
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    fam_headers = _login(client, "fam@example.test")
    made = _send(client, fam_headers, doctor.id, profile["id"]).json()
    doc_headers = _login(client, "doc@example.test")
    return profile, doctor, fam_headers, doc_headers, made["id"]


# --- seed demo phone numbers -------------------------------------------------


def test_seed_gives_every_provider_a_realistic_demo_phone(db_session):
    seed_demo_data(db_session)

    profiles = db_session.execute(select(ProviderProfile)).scalars().all()
    assert len(profiles) >= 9
    for p in profiles:
        # Every provider has a non-empty demo phone, and never the placeholder.
        assert p.phone_number_demo and p.phone_number_demo.strip()
        assert p.phone_number_demo != LEGACY_DEMO_PHONE
        # The other required demo fields are present too.
        assert p.experience_label
        assert p.governorate
        assert p.city
        assert p.location
        assert p.specialty
        assert p.rating_average is not None
        assert p.rating_count is not None


def test_seed_backfills_legacy_placeholder_phone(db_session):
    # First seed, then stamp a provider back to the legacy placeholder and
    # re-seed: the idempotent update should replace it with a realistic number.
    seed_demo_data(db_session)
    profile = db_session.execute(select(ProviderProfile)).scalars().first()
    profile.phone_number_demo = LEGACY_DEMO_PHONE
    db_session.add(profile)
    db_session.commit()

    result = seed_demo_data(db_session)
    assert result["provider_profiles_updated"] >= 1

    db_session.refresh(profile)
    assert profile.phone_number_demo != LEGACY_DEMO_PHONE
    assert profile.phone_number_demo


# --- messaging RBAC / validation ---------------------------------------------


def test_unauthenticated_blocked(client, seeded_roles):
    assert client.get("/api/v1/provider-messages").status_code == 401
    assert client.post("/api/v1/provider-messages", json={}).status_code == 401


def test_linked_family_can_send(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    headers = _login(client, "fam@example.test")

    resp = _send(client, headers, doctor.id, profile["id"])
    assert resp.status_code == 201, resp.text
    data = resp.json()
    assert data["status"] == "sent"
    assert data["provider_user_id"] == str(doctor.id)
    assert data["provider_name"]
    assert data["sender_name"]
    assert data["patient_name"]


def test_unlinked_family_cannot_send(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    # A family user who is NOT linked to this patient.
    user_factory(email="fam@example.test", roles=("family",))
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    headers = _login(client, "fam@example.test")

    resp = _send(client, headers, doctor.id, profile["id"])
    assert resp.status_code == 403


def test_patient_cannot_send(client, admin_headers, user_factory):
    patient, profile = _create_patient(
        client, admin_headers, user_factory, "p@example.test"
    )
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    headers = _login(client, "p@example.test")

    resp = _send(client, headers, doctor.id, profile["id"])
    assert resp.status_code == 403


def test_message_to_non_provider_rejected(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    # A patient user is not a provider.
    not_provider, _ = _create_patient(
        client, admin_headers, user_factory, "np@example.test"
    )
    headers = _login(client, "fam@example.test")

    resp = _send(client, headers, not_provider.id, profile["id"])
    assert resp.status_code == 400


def test_empty_message_rejected(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    headers = _login(client, "fam@example.test")

    resp = _send(client, headers, doctor.id, profile["id"], message="   ")
    assert resp.status_code == 422


def test_too_long_message_rejected(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    headers = _login(client, "fam@example.test")

    resp = _send(client, headers, doctor.id, profile["id"], message="x" * 501)
    assert resp.status_code == 422


# --- messaging visibility ----------------------------------------------------


def test_doctor_views_messages_addressed_to_them(
    client, admin_headers, user_factory
):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    fam_headers = _login(client, "fam@example.test")
    made = _send(client, fam_headers, doctor.id, profile["id"]).json()

    doc_headers = _login(client, "doc@example.test")
    resp = client.get("/api/v1/provider-messages", headers=doc_headers)
    ids = {m["id"] for m in resp.json()["messages"]}
    assert made["id"] in ids


def test_unrelated_doctor_cannot_view(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    fam_headers = _login(client, "fam@example.test")
    made = _send(client, fam_headers, doctor.id, profile["id"]).json()

    # A different doctor, neither addressed nor assigned to the patient.
    _provider(user_factory, "other@example.test", "doctor")
    other_headers = _login(client, "other@example.test")
    resp = client.get("/api/v1/provider-messages", headers=other_headers)
    ids = {m["id"] for m in resp.json()["messages"]}
    assert made["id"] not in ids


def test_family_sees_their_sent_inquiry(client, admin_headers, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    fam_headers = _login(client, "fam@example.test")
    made = _send(client, fam_headers, doctor.id, profile["id"]).json()

    resp = client.get("/api/v1/provider-messages", headers=fam_headers)
    ids = {m["id"] for m in resp.json()["messages"]}
    assert made["id"] in ids


def test_audit_log_created(client, admin_headers, db_session, user_factory):
    _, profile = _create_patient(client, admin_headers, user_factory, "p@example.test")
    _link_family(client, admin_headers, user_factory, profile["id"], "fam@example.test")
    doctor = _provider(user_factory, "doc@example.test", "doctor")
    headers = _login(client, "fam@example.test")
    _send(client, headers, doctor.id, profile["id"])

    db_session.rollback()
    actions = db_session.execute(select(AuditLog.action)).scalars().all()
    assert "create_provider_message" in actions


# --- chat replies / threads --------------------------------------------------


def test_reply_unauthenticated_blocked(client, seeded_roles):
    fake = "00000000-0000-0000-0000-000000000000"
    assert (
        client.post(
            f"/api/v1/provider-messages/{fake}/replies", json={"body": "hi"}
        ).status_code
        == 401
    )
    assert client.get("/api/v1/provider-messages/unread-count").status_code == 401


def test_doctor_addressed_can_reply(client, admin_headers, user_factory):
    _, _doc, _fam, doc_headers, msg_id = _thread_fixture(
        client, admin_headers, user_factory
    )
    resp = _reply(client, doc_headers, msg_id, body="Happy to help.")
    assert resp.status_code == 201, resp.text
    data = resp.json()
    assert data["body"] == "Happy to help."
    assert data["sender_name"]


def test_unrelated_doctor_cannot_reply(client, admin_headers, user_factory):
    _, _doc, _fam, _doc_headers, msg_id = _thread_fixture(
        client, admin_headers, user_factory
    )
    _provider(user_factory, "other@example.test", "doctor")
    other_headers = _login(client, "other@example.test")
    resp = _reply(client, other_headers, msg_id, body="Let me jump in.")
    assert resp.status_code == 403


def test_family_sender_can_view_thread(client, admin_headers, user_factory):
    _, _doc, fam_headers, doc_headers, msg_id = _thread_fixture(
        client, admin_headers, user_factory
    )
    _reply(client, doc_headers, msg_id, body="Reply from doctor.")
    resp = _thread(client, fam_headers, msg_id)
    assert resp.status_code == 200, resp.text
    data = resp.json()
    assert data["id"] == msg_id
    assert len(data["replies"]) == 1
    assert data["replies"][0]["body"] == "Reply from doctor."


def test_family_sender_can_send_follow_up(client, admin_headers, user_factory):
    _, _doc, fam_headers, doc_headers, msg_id = _thread_fixture(
        client, admin_headers, user_factory
    )
    _reply(client, doc_headers, msg_id, body="How can I help?")
    resp = _reply(client, fam_headers, msg_id, body="One more question.")
    assert resp.status_code == 201, resp.text
    thread = _thread(client, fam_headers, msg_id).json()
    assert len(thread["replies"]) == 2


def test_unrelated_family_cannot_view_thread(client, admin_headers, user_factory):
    _, _doc, _fam, _doc_headers, msg_id = _thread_fixture(
        client, admin_headers, user_factory
    )
    # A family user not linked to this patient and not the sender.
    user_factory(email="fam2@example.test", roles=("family",))
    other_fam = _login(client, "fam2@example.test")
    assert _thread(client, other_fam, msg_id).status_code == 403
    assert _reply(client, other_fam, msg_id).status_code == 403


def test_empty_reply_rejected(client, admin_headers, user_factory):
    _, _doc, _fam, doc_headers, msg_id = _thread_fixture(
        client, admin_headers, user_factory
    )
    resp = _reply(client, doc_headers, msg_id, body="   ")
    assert resp.status_code == 422


def test_too_long_reply_rejected(client, admin_headers, user_factory):
    _, _doc, _fam, doc_headers, msg_id = _thread_fixture(
        client, admin_headers, user_factory
    )
    resp = _reply(client, doc_headers, msg_id, body="x" * 501)
    assert resp.status_code == 422


def test_unread_count_increases_when_doctor_replies(
    client, admin_headers, user_factory
):
    _, _doc, fam_headers, doc_headers, msg_id = _thread_fixture(
        client, admin_headers, user_factory
    )
    assert _unread(client, fam_headers).json()["unread_count"] == 0
    _reply(client, doc_headers, msg_id, body="Doctor reply.")
    assert _unread(client, fam_headers).json()["unread_count"] == 1
    # The doctor's own reply is not unread for the doctor.
    assert _unread(client, doc_headers).json()["unread_count"] == 0
    # The thread list also reflects the unread reply for the family.
    listing = client.get("/api/v1/provider-messages", headers=fam_headers).json()
    thread = next(m for m in listing["messages"] if m["id"] == msg_id)
    assert thread["unread_reply_count"] == 1
    assert thread["latest_reply_preview"] == "Doctor reply."


def test_patch_read_clears_unread_count(client, admin_headers, user_factory):
    _, _doc, fam_headers, doc_headers, msg_id = _thread_fixture(
        client, admin_headers, user_factory
    )
    _reply(client, doc_headers, msg_id, body="Doctor reply.")
    assert _unread(client, fam_headers).json()["unread_count"] == 1

    marked = _mark_read(client, fam_headers, msg_id)
    assert marked.status_code == 200, marked.text
    assert marked.json()["marked_read"] == 1
    assert _unread(client, fam_headers).json()["unread_count"] == 0


def test_reply_audit_log_created(client, admin_headers, db_session, user_factory):
    _, _doc, _fam, doc_headers, msg_id = _thread_fixture(
        client, admin_headers, user_factory
    )
    _reply(client, doc_headers, msg_id, body="Logged reply.")

    db_session.rollback()
    actions = db_session.execute(select(AuditLog.action)).scalars().all()
    assert "create_provider_message_reply" in actions
