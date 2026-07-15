import { useEffect, useRef, useState, type FormEvent } from "react";
import { Link, useParams } from "react-router-dom";
import { api, ApiError, resolveMediaUrl } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import { ChatThread } from "../components/ChatThread";
import {
  Badge,
  Card,
  EmptyState,
  ErrorState,
  SectionHeader,
  Spinner,
} from "../components/ui";
import { formatDateTime, pickLinkedPatient } from "../lib";
import type {
  AvailabilitySlot,
  PatientListResponse,
  PatientProfile,
  Provider,
  ProviderMessage,
  ProviderMessageListResponse,
  ProviderMessageReply,
  ProviderMessageThread,
  SlotListResponse,
} from "../types";

const modeLabel = (mode: string) => (mode === "online" ? "Online" : "In-person");
const roleLabel = (role: string) =>
  role === "therapist" ? "Therapist" : "Doctor";
const whereLabel = (mode: string, location?: string | null) =>
  mode === "online" ? "Online session" : location || "In-person";

const INQUIRY_MAX = 500;

function dayLabel(dateStr: string): string {
  const d = new Date(`${dateStr}T00:00:00`);
  if (Number.isNaN(d.getTime())) return dateStr;
  return d.toLocaleDateString(undefined, {
    weekday: "long",
    month: "short",
    day: "numeric",
  });
}

function groupByDate(slots: AvailabilitySlot[]) {
  const groups: { date: string; label: string; slots: AvailabilitySlot[] }[] = [];
  const index = new Map<string, number>();
  for (const s of slots) {
    let i = index.get(s.slot_date);
    if (i === undefined) {
      i = groups.length;
      index.set(s.slot_date, i);
      groups.push({ date: s.slot_date, label: dayLabel(s.slot_date), slots: [] });
    }
    groups[i].slots.push(s);
  }
  return groups;
}

/**
 * Provider profile / detail page. Shows a local demo provider's profile,
 * availability, and a working two-way inquiry chat for the linked patient.
 * Ratings/contact/photo are seeded demo values — not a real clinician.
 * Coordination only — not emergency care.
 */
export function ProviderDetailPage() {
  const { providerId = "" } = useParams();
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [provider, setProvider] = useState<Provider | null>(null);
  const [slots, setSlots] = useState<AvailabilitySlot[]>([]);
  const [patient, setPatient] = useState<PatientProfile | null>(null);
  const [threads, setThreads] = useState<ProviderMessage[]>([]);

  // New inquiry form
  const [newBody, setNewBody] = useState("");
  const [creating, setCreating] = useState(false);
  const [createError, setCreateError] = useState<string | null>(null);
  const [createdOk, setCreatedOk] = useState(false);
  const inquiryRef = useRef<HTMLDivElement | null>(null);

  // Open chat thread
  const [openThread, setOpenThread] = useState<ProviderMessageThread | null>(
    null,
  );
  const [threadLoading, setThreadLoading] = useState(false);
  const [threadError, setThreadError] = useState<string | null>(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const [p, s, pats, msgs] = await Promise.all([
        api<Provider>(`/providers/${providerId}`),
        api<SlotListResponse>(`/providers/${providerId}/availability`).catch(
          (): SlotListResponse => ({ success: true, slots: [] }),
        ),
        api<PatientListResponse>("/patients?limit=50").catch(
          (): PatientListResponse => ({
            success: true,
            total: 0,
            patients: [],
          }),
        ),
        api<ProviderMessageListResponse>(
          `/provider-messages?provider_user_id=${providerId}&limit=50`,
        ).catch(
          (): ProviderMessageListResponse => ({
            success: true,
            total: 0,
            limit: 50,
            offset: 0,
            messages: [],
          }),
        ),
      ]);
      setProvider(p);
      setSlots(s.slots);
      setPatient(pickLinkedPatient(pats.patients, user?.id));
      setThreads(msgs.messages);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not load provider.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, [providerId]);

  // Scroll to the inquiry section when linked via /providers/:id#inquiry.
  useEffect(() => {
    if (!loading && window.location.hash === "#inquiry") {
      inquiryRef.current?.scrollIntoView({ behavior: "smooth", block: "start" });
    }
  }, [loading]);

  const createInquiry = async (e: FormEvent) => {
    e.preventDefault();
    setCreateError(null);
    setCreatedOk(false);
    if (!patient || !provider) return;
    const text = newBody.trim();
    if (!text) {
      setCreateError("Please enter a message.");
      return;
    }
    setCreating(true);
    try {
      const created = await api<ProviderMessage>("/provider-messages", {
        method: "POST",
        body: JSON.stringify({
          provider_user_id: provider.provider_user_id,
          patient_profile_id: patient.id,
          message: text,
        }),
      });
      setThreads((prev) => [created, ...prev]);
      setNewBody("");
      setCreatedOk(true);
      // Open the freshly created thread so it reads like a conversation.
      setOpenThread({ ...created, replies: [] });
    } catch (err) {
      setCreateError(
        err instanceof ApiError
          ? err.status === 403
            ? "This account isn't linked to this patient, so it can't send an inquiry."
            : err.message
          : "Could not send the inquiry. Please try again.",
      );
    } finally {
      setCreating(false);
    }
  };

  const open = async (id: string) => {
    setThreadLoading(true);
    setThreadError(null);
    setOpenThread(null);
    try {
      const t = await api<ProviderMessageThread>(`/provider-messages/${id}`);
      setOpenThread(t);
      await api(`/provider-messages/${id}/read`, { method: "PATCH" }).catch(
        () => {},
      );
      setThreads((prev) =>
        prev.map((m) =>
          m.id === id ? { ...m, unread_reply_count: 0 } : m,
        ),
      );
    } catch (err) {
      setThreadError(
        err instanceof Error ? err.message : "Could not open the thread.",
      );
    } finally {
      setThreadLoading(false);
    }
  };

  const sendReply = async (body: string) => {
    if (!openThread) return;
    const reply = await api<ProviderMessageReply>(
      `/provider-messages/${openThread.id}/replies`,
      { method: "POST", body: JSON.stringify({ body }) },
    );
    setOpenThread((prev) =>
      prev ? { ...prev, replies: [...prev.replies, reply] } : prev,
    );
    setThreads((prev) =>
      prev.map((m) =>
        m.id === openThread.id
          ? {
              ...m,
              latest_reply_preview: reply.body,
              latest_reply_at: reply.created_at,
            }
          : m,
      ),
    );
  };

  if (loading) return <Spinner label="Loading provider…" />;
  if (error) return <ErrorState message={error} onRetry={load} />;
  if (!provider) return <EmptyState message="Provider not found." />;

  const photo = resolveMediaUrl(provider.photo_url);
  const place = [provider.city, provider.governorate].filter(Boolean).join(", ");

  return (
    <div className="page page--wide">
      <div className="crumbs">
        <Link className="link" to="/appointments">
          Appointments
        </Link>
        <span aria-hidden="true"> / </span>
        <span>{provider.full_name}</span>
      </div>

      {/* Profile hero */}
      <div className="prov-hero">
        {photo ? (
          <img className="prov-hero__photo" src={photo} alt={provider.full_name} />
        ) : (
          <span className="prov-hero__avatar" aria-hidden="true">
            {provider.full_name.slice(0, 1)}
          </span>
        )}
        <div className="prov-hero__body">
          <div className="prov-hero__headline">
            <h1>{provider.full_name}</h1>
            <Badge tone="neutral">{roleLabel(provider.role)}</Badge>
          </div>
          <p className="prov-hero__specialty">
            {provider.specialty ?? "Care coordination"}
          </p>
          <div className="prov-hero__facts">
            {place && (
              <span>
                <strong>Location</strong> {place}
                {provider.location ? ` · ${provider.location}` : ""}
              </span>
            )}
            {provider.experience_label && (
              <span>
                <strong>Experience</strong> {provider.experience_label}
              </span>
            )}
            {provider.rating_average != null && (
              <span>
                <strong>Rating (demo)</strong>{" "}
                {provider.rating_average.toFixed(1)} ★ · {provider.rating_count}{" "}
                demo ratings
              </span>
            )}
          </div>
          <div className="prov-hero__modes">
            {provider.in_person_available && (
              <Badge tone="live">In-person</Badge>
            )}
            {provider.online_available && <Badge tone="gold">Online</Badge>}
          </div>
          <div className="prov-hero__cta">
            <Link className="btn btn--gold" to="/appointments">
              Book appointment
            </Link>
            <a className="btn btn--ghost" href="#inquiry">
              Send inquiry
            </a>
          </div>
        </div>
      </div>

      {/* Contact (demo) */}
      <Card>
        <SectionHeader eyebrow="Contact (demo)" title="Provider contact" />
        <div className="care-grid">
          <div className="care-row">
            <span className="care-row__label">Demo contact</span>
            <span className="care-row__value">
              {provider.phone_number_demo ?? "—"}
            </span>
          </div>
          <div className="care-row">
            <span className="care-row__label">Clinic</span>
            <span className="care-row__value">
              {provider.clinic_name ?? "—"}
            </span>
          </div>
          <div className="care-row">
            <span className="care-row__label">City / governorate</span>
            <span className="care-row__value">{place || "—"}</span>
          </div>
          <div className="care-row">
            <span className="care-row__label">Location</span>
            <span className="care-row__value">{provider.location ?? "—"}</span>
          </div>
          <div className="care-row">
            <span className="care-row__label">Visit modes</span>
            <span className="care-row__value">
              {provider.in_person_available && (
                <Badge tone="live">In-person</Badge>
              )}{" "}
              {provider.online_available && <Badge tone="gold">Online</Badge>}
              {!provider.in_person_available &&
                !provider.online_available &&
                "—"}
            </span>
          </div>
        </div>
        <p className="muted-sub" style={{ marginTop: "0.8rem", marginBottom: 0 }}>
          Demo contact only — not emergency care. For urgent concerns, contact
          local emergency services.
        </p>
      </Card>

      {/* Send inquiry / chat */}
      <Card id="inquiry" className="inquiry-card">
        <div ref={inquiryRef} />
        <SectionHeader eyebrow="Message provider" title="Send inquiry" />
        <p className="muted-sub" style={{ marginTop: 0 }}>
          Non-urgent care coordination message only. Not emergency care. For
          urgent concerns, contact local emergency services.
        </p>
        {!patient ? (
          <EmptyState message="No linked patient yet. Once a patient is linked to your account, you can send an inquiry here." />
        ) : (
          <form className="mform" onSubmit={createInquiry}>
            <label className="mform__full">
              New inquiry <span className="mform__req">*</span>
              <textarea
                rows={3}
                maxLength={INQUIRY_MAX}
                value={newBody}
                onChange={(e) => {
                  setNewBody(e.target.value);
                  setCreatedOk(false);
                }}
                placeholder="e.g. Could we confirm the next available in-person time?"
              />
            </label>
            <div className="mform__hint">
              {newBody.length}/{INQUIRY_MAX}
            </div>
            {createError && <div className="mform__error">{createError}</div>}
            {createdOk && <div className="mform__ok">Inquiry sent.</div>}
            <div className="mform__actions">
              <button
                className="btn btn--gold"
                type="submit"
                disabled={creating || !newBody.trim()}
              >
                {creating ? "Sending…" : "Send inquiry"}
              </button>
            </div>
          </form>
        )}

        {threads.length > 0 && (
          <div className="inquiry-recent">
            <h4>Your conversations with {provider.full_name}</h4>
            <ul className="inquiry-list">
              {threads.map((m) => {
                const unread = m.unread_reply_count ?? 0;
                const preview = m.latest_reply_preview || m.message;
                const updated = m.latest_reply_at || m.created_at;
                const isOpen = openThread?.id === m.id;
                return (
                  <li
                    className={`inquiry-item ${
                      isOpen ? "inquiry-item--active" : ""
                    }`}
                    key={m.id}
                  >
                    <p className="inquiry-item__msg">{preview}</p>
                    <div className="inquiry-item__meta">
                      <Badge tone="neutral">{m.status}</Badge>
                      <span>{formatDateTime(updated)}</span>
                      {unread > 0 && (
                        <span className="unread-dot" title="Unread replies">
                          {unread}
                        </span>
                      )}
                      <button
                        className="btn btn--ghost btn--sm"
                        onClick={() => open(m.id)}
                      >
                        {isOpen ? "Reopen" : "Open chat"}
                      </button>
                    </div>
                  </li>
                );
              })}
            </ul>
          </div>
        )}

        {(threadLoading || threadError || openThread) && (
          <div className="chat-card" style={{ marginTop: "1.2rem" }}>
            <div className="chat-card__head">
              <h4 style={{ margin: 0 }}>Conversation</h4>
              {openThread && (
                <button
                  className="btn btn--ghost btn--sm"
                  onClick={() => setOpenThread(null)}
                >
                  Close
                </button>
              )}
            </div>
            {threadLoading ? (
              <Spinner label="Opening chat…" />
            ) : threadError ? (
              <ErrorState message={threadError} />
            ) : openThread ? (
              <ChatThread
                showSafety
                originalId={openThread.id}
                originalSenderId={openThread.sender_user_id}
                originalSenderName={openThread.sender_name}
                originalText={openThread.message}
                originalAt={openThread.created_at}
                replies={openThread.replies}
                currentUserId={user?.id}
                canReply={openThread.sender_user_id === user?.id}
                disabledNote="View only."
                onSend={sendReply}
              />
            ) : null}
          </div>
        )}
      </Card>

      {provider.bio_short && (
        <Card>
          <SectionHeader eyebrow="About" title="Focus" />
          <p>{provider.bio_short}</p>
        </Card>
      )}

      <Card>
        <SectionHeader eyebrow="Availability" title="Available times" />
        {slots.length === 0 ? (
          <EmptyState message="No available slots right now." />
        ) : (
          <div className="slot-days">
            {groupByDate(slots).map((group) => (
              <div className="slot-day" key={group.date}>
                <div className="slot-day__label">{group.label}</div>
                <div className="slot-grid">
                  {group.slots.map((slot) => (
                    <div className="slot-chip slot-chip--static" key={slot.id}>
                      <span className="slot-chip__time">
                        {slot.start_time}–{slot.end_time}
                      </span>
                      <span className="slot-chip__meta">
                        <Badge
                          tone={
                            slot.appointment_mode === "online" ? "gold" : "live"
                          }
                        >
                          {modeLabel(slot.appointment_mode)}
                        </Badge>
                        <span className="slot-chip__loc">
                          {whereLabel(slot.appointment_mode, slot.location)}
                        </span>
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}
        <p className="muted-sub" style={{ marginTop: "1rem", marginBottom: 0 }}>
          To request one of these times, use{" "}
          <Link className="link" to="/appointments">
            Book appointment
          </Link>
          .
        </p>
      </Card>

      <div className="safety">
        <span className="safety__mark" aria-hidden="true">
          ⚕
        </span>
        <p>
          <strong>Appointment requests are for care coordination only</strong>{" "}
          and are <strong>not emergency care</strong>. For medical concerns,
          contact the care team; for urgent concerns, contact local emergency
          services.
        </p>
      </div>
    </div>
  );
}
