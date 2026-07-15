import { useEffect, useMemo, useState } from "react";
import { api } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import { ChatThread } from "../components/ChatThread";
import {
  Badge,
  Card,
  EmptyState,
  ErrorState,
  SafetyNote,
  SectionHeader,
  Spinner,
} from "../components/ui";
import { formatDate, formatDateTime, patientName } from "../lib";
import type {
  Appointment,
  AppointmentListResponse,
  PatientListResponse,
  PatientProfile,
  ProviderMessage,
  ProviderMessageListResponse,
  ProviderMessageReply,
  ProviderMessageThread,
} from "../types";

function statusTone(status: string): "neutral" | "live" | "plan" | "gold" {
  switch (status) {
    case "approved":
    case "answered":
      return "live";
    case "completed":
      return "gold";
    case "cancelled":
      return "neutral";
    default:
      return "plan";
  }
}

function modeLabel(mode: string): string {
  return mode === "online" ? "Online" : "In-person";
}

/**
 * Doctor/therapist appointment requests + provider inquiry chat. Shows requests
 * where the clinician is the chosen provider or is assigned to the patient, lets
 * them update status, and provides a working two-way inbox for inquiries
 * addressed to them. Coordination only — non-diagnostic, not emergency care.
 */
export function DoctorAppointmentsPage() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [items, setItems] = useState<Appointment[]>([]);
  const [patients, setPatients] = useState<PatientProfile[]>([]);
  const [messages, setMessages] = useState<ProviderMessage[]>([]);
  const [busyId, setBusyId] = useState<string | null>(null);
  const [rowError, setRowError] = useState<string | null>(null);

  // Open chat thread
  const [thread, setThread] = useState<ProviderMessageThread | null>(null);
  const [threadLoading, setThreadLoading] = useState(false);
  const [threadError, setThreadError] = useState<string | null>(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const [a, p, m] = await Promise.all([
        api<AppointmentListResponse>("/appointments?limit=200"),
        api<PatientListResponse>("/patients?limit=200"),
        api<ProviderMessageListResponse>("/provider-messages?limit=200"),
      ]);
      setItems(a.appointments);
      setPatients(p.patients);
      setMessages(m.messages);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not load.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  const nameByProfile = useMemo(() => {
    const map = new Map(patients.map((p) => [p.id, patientName(p.user)]));
    return (id: string) => map.get(id) ?? "Patient";
  }, [patients]);

  const updateStatus = async (id: string, status: string) => {
    setBusyId(id);
    setRowError(null);
    try {
      const updated = await api<Appointment>(`/appointments/${id}/status`, {
        method: "PATCH",
        body: JSON.stringify({ status }),
      });
      setItems((prev) => prev.map((a) => (a.id === id ? updated : a)));
    } catch (err) {
      setRowError(err instanceof Error ? err.message : "Could not update.");
    } finally {
      setBusyId(null);
    }
  };

  const openThread = async (id: string) => {
    setThreadLoading(true);
    setThreadError(null);
    setThread(null);
    try {
      const t = await api<ProviderMessageThread>(`/provider-messages/${id}`);
      setThread(t);
      // Mark incoming replies read, and clear the unread badge locally.
      await api(`/provider-messages/${id}/read`, { method: "PATCH" }).catch(
        () => {},
      );
      setMessages((prev) =>
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
    if (!thread) return;
    const reply = await api<ProviderMessageReply>(
      `/provider-messages/${thread.id}/replies`,
      { method: "POST", body: JSON.stringify({ body }) },
    );
    setThread((prev) =>
      prev ? { ...prev, replies: [...prev.replies, reply], status: "answered" } : prev,
    );
    setMessages((prev) =>
      prev.map((m) =>
        m.id === thread.id
          ? {
              ...m,
              status: "answered",
              latest_reply_preview: reply.body,
              latest_reply_at: reply.created_at,
            }
          : m,
      ),
    );
  };

  return (
    <div className="page">
      <div className="page__head">
        <div>
          <span className="eyebrow">Appointments</span>
          <h1>Appointment requests</h1>
          <p className="page__sub">
            Requests where you are the provider or the assigned clinician. Care
            coordination only.
          </p>
        </div>
      </div>

      {loading ? (
        <Spinner label="Loading appointment requests…" />
      ) : error ? (
        <ErrorState message={error} onRetry={load} />
      ) : (
        <>
          <Card>
            <SectionHeader eyebrow="Requests" title="Manage requests" />
            {rowError && <div className="mform__error">{rowError}</div>}
            {items.length === 0 ? (
              <EmptyState message="No appointment requests yet." />
            ) : (
              <div className="table-card">
                <table className="table">
                  <thead>
                    <tr>
                      <th>Patient</th>
                      <th>Provider</th>
                      <th>Date / time</th>
                      <th>Mode</th>
                      <th>Reason</th>
                      <th>Status</th>
                      <th aria-label="Actions" />
                    </tr>
                  </thead>
                  <tbody>
                    {items.map((a) => (
                      <tr key={a.id}>
                        <td>{nameByProfile(a.patient_profile_id)}</td>
                        <td>{a.provider_name || "—"}</td>
                        <td>
                          {formatDate(a.preferred_date)}
                          {a.preferred_time ? ` · ${a.preferred_time}` : ""}
                        </td>
                        <td>
                          <Badge
                            tone={
                              a.appointment_mode === "online" ? "gold" : "live"
                            }
                          >
                            {modeLabel(a.appointment_mode)}
                          </Badge>
                        </td>
                        <td>{a.reason}</td>
                        <td>
                          <Badge tone={statusTone(a.status)}>{a.status}</Badge>
                        </td>
                        <td className="appt-actions">
                          <button
                            className="btn btn--ghost btn--sm"
                            disabled={busyId === a.id || a.status === "approved"}
                            onClick={() => updateStatus(a.id, "approved")}
                          >
                            Approve
                          </button>
                          <button
                            className="btn btn--ghost btn--sm"
                            disabled={busyId === a.id || a.status === "completed"}
                            onClick={() => updateStatus(a.id, "completed")}
                          >
                            Complete
                          </button>
                          <button
                            className="btn btn--ghost btn--sm"
                            disabled={busyId === a.id || a.status === "cancelled"}
                            onClick={() => updateStatus(a.id, "cancelled")}
                          >
                            Cancel
                          </button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </Card>

          <Card>
            <SectionHeader
              eyebrow="Provider inquiries"
              title="Inbox"
            />
            <p className="page__sub" style={{ marginTop: 0 }}>
              Non-urgent care-coordination inquiries families sent to you. Open a
              thread to reply. For urgent concerns, contact local emergency
              services.
            </p>
            {messages.length === 0 ? (
              <EmptyState message="No inquiries yet." />
            ) : (
              <div className="table-card">
                <table className="table">
                  <thead>
                    <tr>
                      <th>From</th>
                      <th>Patient</th>
                      <th>Provider</th>
                      <th>Latest</th>
                      <th>Updated</th>
                      <th>Status</th>
                      <th aria-label="Open" />
                    </tr>
                  </thead>
                  <tbody>
                    {messages.map((m) => {
                      const unread = m.unread_reply_count ?? 0;
                      const preview = m.latest_reply_preview || m.message;
                      const updated = m.latest_reply_at || m.created_at;
                      const mine = m.provider_user_id === user?.id;
                      return (
                        <tr
                          key={m.id}
                          className={`${unread > 0 ? "row--unread" : ""} ${
                            thread?.id === m.id ? "row--active" : ""
                          }`.trim()}
                        >
                          <td>{m.sender_name || "Family"}</td>
                          <td>{m.patient_name || "Patient"}</td>
                          <td>
                            {m.provider_name || "—"}
                            <span className="cell-sub">
                              {mine ? (
                                <Badge tone="live">Can reply</Badge>
                              ) : (
                                <Badge tone="neutral">View only</Badge>
                              )}
                            </span>
                          </td>
                          <td className="cell-clip">{preview}</td>
                          <td>{formatDateTime(updated)}</td>
                          <td>
                            <Badge tone={statusTone(m.status)}>{m.status}</Badge>
                            {unread > 0 && (
                              <span className="unread-dot" title="Unread replies">
                                {unread}
                              </span>
                            )}
                          </td>
                          <td>
                            <button
                              className="btn btn--ghost btn--sm"
                              onClick={() => openThread(m.id)}
                            >
                              {thread?.id === m.id
                                ? "Reopen"
                                : mine
                                  ? "Open"
                                  : "View"}
                            </button>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </Card>

          {(threadLoading || threadError || thread) && (
            <Card className="chat-card">
              <div className="chat-card__head">
                <SectionHeader
                  eyebrow="Conversation"
                  title={
                    thread
                      ? `${thread.sender_name || "Family"} · ${
                          thread.patient_name || "Patient"
                        }`
                      : "Conversation"
                  }
                />
                {thread && (
                  <button
                    className="btn btn--ghost btn--sm"
                    onClick={() => setThread(null)}
                  >
                    Close
                  </button>
                )}
              </div>
              {thread && (
                <p className="chat-addressed">
                  Addressed to:{" "}
                  <strong>{thread.provider_name || "Provider"}</strong>{" "}
                  {thread.provider_user_id === user?.id ? (
                    <Badge tone="live">Can reply</Badge>
                  ) : (
                    <Badge tone="neutral">View only</Badge>
                  )}
                </p>
              )}
              {threadLoading ? (
                <Spinner label="Opening thread…" />
              ) : threadError ? (
                <ErrorState message={threadError} />
              ) : thread ? (
                <ChatThread
                  showSafety
                  originalId={thread.id}
                  originalSenderId={thread.sender_user_id}
                  originalSenderName={thread.sender_name}
                  originalText={thread.message}
                  originalAt={thread.created_at}
                  replies={thread.replies}
                  currentUserId={user?.id}
                  canReply={thread.provider_user_id === user?.id}
                  disabledNote="View only — this inquiry is addressed to another provider."
                  onSend={sendReply}
                />
              ) : null}
            </Card>
          )}

          <SafetyNote compact />
        </>
      )}
    </div>
  );
}
