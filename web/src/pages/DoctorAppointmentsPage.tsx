import { useEffect, useMemo, useState } from "react";
import { api } from "../api/client";
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
import { formatDate, formatDateTime, patientName } from "../lib";
import { useI18n } from "../i18n/useI18n";
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

/**
 * Doctor/therapist appointment requests + provider inquiry chat. Shows requests
 * where the clinician is the chosen provider or is assigned to the patient, lets
 * them update status, and provides a working two-way inbox for inquiries
 * addressed to them. Coordination only — non-diagnostic, not emergency care.
 */
export function DoctorAppointmentsPage() {
  const { user } = useAuth();
  const { t } = useI18n();
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
      setError(err instanceof Error ? err.message : t("appt.couldNotLoad"));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  const nameByProfile = useMemo(() => {
    const map = new Map(patients.map((p) => [p.id, patientName(p.user)]));
    return (id: string) => map.get(id) ?? t("common.patient");
  }, [patients, t]);

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
      setRowError(err instanceof Error ? err.message : t("appt.couldNotUpdate"));
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
        err instanceof Error ? err.message : t("appt.couldNotOpenThread"),
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
          <span className="eyebrow">{t("appt.eyebrow")}</span>
          <h1>{t("appt.title")}</h1>
          <p className="page__sub">{t("appt.sub")}</p>
        </div>
      </div>

      {loading ? (
        <Spinner label={t("appt.loading")} />
      ) : error ? (
        <ErrorState message={error} onRetry={load} />
      ) : (
        <>
          <Card>
            <SectionHeader eyebrow={t("appt.requests")} title={t("appt.manage")} />
            {rowError && <div className="mform__error">{rowError}</div>}
            {items.length === 0 ? (
              <EmptyState message={t("appt.none")} />
            ) : (
              <div className="table-card">
                <table className="table">
                  <thead>
                    <tr>
                      <th>{t("table.patient")}</th>
                      <th>{t("appt.provider")}</th>
                      <th>{t("appt.dateTime")}</th>
                      <th>{t("appt.mode")}</th>
                      <th>{t("appt.reason")}</th>
                      <th>{t("appt.status")}</th>
                      <th aria-label={t("appt.status")} />
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
                            {a.appointment_mode === "online"
                              ? t("appt.online")
                              : t("appt.inPerson")}
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
                            {t("appt.approve")}
                          </button>
                          <button
                            className="btn btn--ghost btn--sm"
                            disabled={busyId === a.id || a.status === "completed"}
                            onClick={() => updateStatus(a.id, "completed")}
                          >
                            {t("appt.complete")}
                          </button>
                          <button
                            className="btn btn--ghost btn--sm"
                            disabled={busyId === a.id || a.status === "cancelled"}
                            onClick={() => updateStatus(a.id, "cancelled")}
                          >
                            {t("appt.cancel")}
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
              eyebrow={t("appt.inquiriesEyebrow")}
              title={t("appt.inbox")}
            />
            <p className="page__sub" style={{ marginTop: 0 }}>
              {t("appt.inboxSub")}
            </p>
            {messages.length === 0 ? (
              <EmptyState message={t("appt.noInquiries")} />
            ) : (
              <div className="table-card">
                <table className="table">
                  <thead>
                    <tr>
                      <th>{t("appt.from")}</th>
                      <th>{t("table.patient")}</th>
                      <th>{t("appt.provider")}</th>
                      <th>{t("appt.latest")}</th>
                      <th>{t("appt.updated")}</th>
                      <th>{t("appt.status")}</th>
                      <th aria-label={t("appt.open")} />
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
                          <td>{m.sender_name || t("appt.family")}</td>
                          <td>{m.patient_name || t("common.patient")}</td>
                          <td>
                            {m.provider_name || "—"}
                            <span className="cell-sub">
                              {mine ? (
                                <Badge tone="live">{t("appt.canReply")}</Badge>
                              ) : (
                                <Badge tone="neutral">{t("appt.viewOnly")}</Badge>
                              )}
                            </span>
                          </td>
                          <td className="cell-clip">{preview}</td>
                          <td>{formatDateTime(updated)}</td>
                          <td>
                            <Badge tone={statusTone(m.status)}>{m.status}</Badge>
                            {unread > 0 && (
                              <span className="unread-dot" title={t("appt.unreadReplies")}>
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
                                ? t("appt.reopen")
                                : mine
                                  ? t("appt.open")
                                  : t("appt.viewBtn")}
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
                  eyebrow={t("appt.conversation")}
                  title={
                    thread
                      ? `${thread.sender_name || t("appt.family")} · ${
                          thread.patient_name || t("common.patient")
                        }`
                      : t("appt.conversation")
                  }
                />
                {thread && (
                  <button
                    className="btn btn--ghost btn--sm"
                    onClick={() => setThread(null)}
                  >
                    {t("appt.close")}
                  </button>
                )}
              </div>
              {thread && (
                <p className="chat-addressed">
                  {t("appt.addressedTo")}{" "}
                  <strong>{thread.provider_name || t("appt.provider")}</strong>{" "}
                  {thread.provider_user_id === user?.id ? (
                    <Badge tone="live">{t("appt.canReply")}</Badge>
                  ) : (
                    <Badge tone="neutral">{t("appt.viewOnly")}</Badge>
                  )}
                </p>
              )}
              {threadLoading ? (
                <Spinner label={t("appt.openingThread")} />
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
                  disabledNote={t("appt.viewOnlyNote")}
                  onSend={sendReply}
                />
              ) : null}
            </Card>
          )}
        </>
      )}
    </div>
  );
}
