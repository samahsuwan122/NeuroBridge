import { useEffect, useMemo, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { api } from "../api/client";
import {
  Badge,
  Card,
  EmptyState,
  ErrorState,
  SectionHeader,
  Spinner,
  StatCard,
} from "../components/ui";
import { formatDate, formatDateTime, patientName, scorePercent } from "../lib";
import { reviewStatus, ruleBasedSummary } from "../lib/careData";
import type {
  Appointment,
  AppointmentListResponse,
  AssignedActivity,
  AssignedActivityListResponse,
  GameListResponse,
  GameResult,
  GameResultListResponse,
  PatientProfile,
  ProviderMessage,
  ProviderMessageListResponse,
} from "../types";

type TimelineItem = {
  at: string;
  kind: "session" | "activity" | "appointment" | "message";
  text: string;
};

function activityTone(status: string): "neutral" | "live" | "plan" | "gold" {
  if (status === "completed") return "live";
  if (status === "skipped") return "gold";
  return "plan";
}

/**
 * Patient-specific report. Fetches this patient's data by id (refresh-safe),
 * then renders performance/engagement sections. Performance-only and
 * non-diagnostic — no medical assessment, risk, or conclusions.
 */
export function PatientReportPage() {
  const { patientId = "" } = useParams();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [patient, setPatient] = useState<PatientProfile | null>(null);
  const [results, setResults] = useState<GameResult[]>([]);
  const [activities, setActivities] = useState<AssignedActivity[]>([]);
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [messages, setMessages] = useState<ProviderMessage[]>([]);
  const [gameNames, setGameNames] = useState<Map<string, string>>(new Map());
  const [copied, setCopied] = useState(false);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const [p, g, r, act, a, m] = await Promise.all([
        api<PatientProfile>(`/patients/${patientId}`),
        api<GameListResponse>("/games"),
        api<GameResultListResponse>(
          `/games/results?patient_profile_id=${patientId}&limit=200`,
        ),
        api<AssignedActivityListResponse>(
          `/activities/patient/${patientId}?limit=100`,
        ),
        api<AppointmentListResponse>("/appointments?limit=200"),
        api<ProviderMessageListResponse>("/provider-messages?limit=200"),
      ]);
      setPatient(p);
      setGameNames(new Map(g.games.map((x) => [x.id, x.name])));
      setResults(r.results);
      setActivities(act.activities);
      setAppointments(
        a.appointments.filter((x) => x.patient_profile_id === patientId),
      );
      setMessages(m.messages.filter((x) => x.patient_profile_id === patientId));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not load report.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [patientId]);

  const gameName = (id: string) => gameNames.get(id) ?? "Exercise";

  const stats = useMemo(() => {
    const completedSessions = results.filter((r) => r.completed).length;
    const pcts = results
      .map(scorePercent)
      .filter((v): v is number => v != null);
    const best = pcts.length ? Math.max(...pcts) : null;
    const avg = pcts.length
      ? Math.round(pcts.reduce((a, b) => a + b, 0) / pcts.length)
      : null;
    const pendingActivities = activities.filter(
      (x) => x.status === "assigned",
    ).length;
    const completedActivities = activities.filter(
      (x) => x.status === "completed",
    ).length;
    return {
      completedSessions,
      best,
      avg,
      pendingActivities,
      completedActivities,
    };
  }, [results, activities]);

  const timeline = useMemo<TimelineItem[]>(() => {
    const items: TimelineItem[] = [];
    for (const r of results) {
      const pct = scorePercent(r);
      items.push({
        at: r.created_at,
        kind: "session",
        text: `${gameName(r.game_definition_id)}${pct != null ? ` · ${pct}%` : ""}`,
      });
    }
    for (const a of activities) {
      items.push({
        at: a.completed_at ?? a.created_at,
        kind: "activity",
        text: `${a.title} · ${a.status}`,
      });
    }
    for (const ap of appointments) {
      items.push({
        at: ap.preferred_date,
        kind: "appointment",
        text: `${ap.provider_name ?? "Appointment"} · ${ap.status}`,
      });
    }
    for (const m of messages) {
      items.push({
        at: m.latest_reply_at ?? m.created_at,
        kind: "message",
        text: `Message with ${m.provider_name ?? "provider"}`,
      });
    }
    return items
      .filter((x) => x.at)
      .sort((a, b) => +new Date(b.at) - +new Date(a.at))
      .slice(0, 12);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [results, activities, appointments, messages, gameNames]);

  if (loading) return <Spinner label="Loading report…" />;
  if (error) return <ErrorState message={error} onRetry={load} />;
  if (!patient) return <EmptyState message="Patient not found." />;

  const name = patientName(patient.user);
  const status = reviewStatus({
    pendingActivities: stats.pendingActivities,
    lastActivityAt: results[0]?.created_at ?? null,
  });
  const summary = ruleBasedSummary({
    name,
    completedSessions: stats.completedSessions,
    pendingActivities: stats.pendingActivities,
  });
  const recent = [...results]
    .sort((a, b) => +new Date(b.created_at) - +new Date(a.created_at))
    .slice(0, 10);
  const notes = (patient.notes ?? "").trim();
  const caregiverNotes = (patient.caregiver_notes ?? "").trim();

  const copySummary = async () => {
    try {
      await navigator.clipboard.writeText(`${name} — ${summary}`);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      /* clipboard unavailable; ignore */
    }
  };

  return (
    <div className="page">
      <div className="crumbs">
        <Link className="link" to="/reports">
          ← Back to patients
        </Link>
      </div>

      <div className="page__head">
        <div>
          <span className="eyebrow">Performance report</span>
          <h1>{name}</h1>
          <p className="page__sub">Recent period · last activity {formatDate(results[0]?.created_at)}</p>
        </div>
        <div className="report-actions">
          <Badge tone={status.tone}>{status.label}</Badge>
          <Link className="btn btn--ghost btn--sm" to={`/patients/${patient.id}`}>
            Open profile
          </Link>
          <button className="btn btn--ghost btn--sm" onClick={copySummary}>
            {copied ? "Copied ✓" : "Copy summary"}
          </button>
          <button className="btn btn--gold btn--sm" onClick={() => window.print()}>
            Print view
          </button>
        </div>
      </div>

      {/* Deterministic, non-diagnostic summary */}
      <div className="report-summary">
        <p>{summary}</p>
        <span className="report-summary__note">
          AI-assisted summaries organize activity data for care-team review only.
        </span>
      </div>

      {/* Performance summary */}
      <SectionHeader eyebrow="Performance summary" title="Cognitive sessions" />
      <div className="stat-grid">
        <StatCard label="Completed sessions" value={stats.completedSessions} />
        <StatCard
          label="Best performance"
          value={stats.best != null ? `${stats.best}%` : "—"}
          hint="Across recorded sessions"
        />
        <StatCard
          label="Average performance"
          value={stats.avg != null ? `${stats.avg}%` : "—"}
          hint="Across recorded sessions"
        />
        <StatCard label="Assigned activities" value={activities.length} />
      </div>

      <div className="grid-2">
        {/* Activity engagement */}
        <Card>
          <SectionHeader eyebrow="Activity engagement" title="Assigned activities" />
          {activities.length === 0 ? (
            <EmptyState message="No activities assigned to this patient yet." />
          ) : (
            <>
              <div className="report-engage">
                <span className="pill">{stats.completedActivities} completed</span>
                <span className="pill">{stats.pendingActivities} pending</span>
              </div>
              <ul className="activity-list__items">
                {activities.slice(0, 8).map((a) => (
                  <li className="activity-item" key={a.id}>
                    <div className="activity-item__main">
                      <strong>{a.title}</strong>
                      <span className="activity-item__sub">
                        {a.difficulty} · {a.duration_minutes} min · assigned{" "}
                        {formatDate(a.created_at)}
                      </span>
                    </div>
                    <Badge tone={activityTone(a.status)}>{a.status}</Badge>
                  </li>
                ))}
              </ul>
            </>
          )}
        </Card>

        {/* Recent sessions */}
        <Card>
          <SectionHeader eyebrow="Recent sessions" title="Latest cognitive sessions" />
          {recent.length === 0 ? (
            <EmptyState message="No recorded sessions yet." />
          ) : (
            <ul className="activity">
              {recent.map((r) => {
                const pct = scorePercent(r);
                return (
                  <li className="activity__row" key={r.id}>
                    <div className="activity__main">
                      <strong>{gameName(r.game_definition_id)}</strong>
                      <span>{formatDateTime(r.created_at)}</span>
                    </div>
                    <div className="activity__meta">
                      {pct != null && <span className="pill">{pct}%</span>}
                      <span className={`dotlabel ${r.completed ? "dotlabel--ok" : ""}`}>
                        {r.completed ? "Completed" : "In progress"}
                      </span>
                    </div>
                  </li>
                );
              })}
            </ul>
          )}
        </Card>
      </div>

      <div className="grid-2">
        {/* Appointments */}
        <Card>
          <SectionHeader eyebrow="Appointments" title="Appointment history" />
          {appointments.length === 0 ? (
            <EmptyState message="No appointments for this patient." />
          ) : (
            <ul className="activity">
              {[...appointments]
                .sort((a, b) => +new Date(b.preferred_date) - +new Date(a.preferred_date))
                .slice(0, 8)
                .map((ap) => (
                  <li className="activity__row" key={ap.id}>
                    <div className="activity__main">
                      <strong>{ap.provider_name ?? "Appointment"}</strong>
                      <span>
                        {formatDate(ap.preferred_date)}
                        {ap.preferred_time ? ` · ${ap.preferred_time}` : ""} ·{" "}
                        {ap.appointment_mode}
                      </span>
                    </div>
                    <Badge tone="neutral">{ap.status}</Badge>
                  </li>
                ))}
            </ul>
          )}
        </Card>

        {/* Family messages / interactions */}
        <Card>
          <SectionHeader eyebrow="Interactions" title="Family & provider messages" />
          {messages.length === 0 ? (
            <EmptyState message="No messages for this patient." />
          ) : (
            <ul className="activity">
              {messages.slice(0, 8).map((m) => (
                <li className="activity__row" key={m.id}>
                  <div className="activity__main">
                    <strong>{m.provider_name ?? "Provider"}</strong>
                    <span>
                      {m.latest_reply_preview ?? m.message}
                      {" · "}
                      {formatDateTime(m.latest_reply_at ?? m.created_at)}
                    </span>
                  </div>
                  {(m.unread_reply_count ?? 0) > 0 ? (
                    <Badge tone="plan">{m.unread_reply_count} unread</Badge>
                  ) : (
                    <Badge tone="neutral">{m.status}</Badge>
                  )}
                </li>
              ))}
            </ul>
          )}
        </Card>
      </div>

      {/* Care-team review notes (read-only, non-diagnostic) */}
      <Card>
        <SectionHeader eyebrow="Care-team review notes" title="Notes" />
        {notes || caregiverNotes ? (
          <div className="report-notes">
            {notes && <p>{notes}</p>}
            {caregiverNotes && (
              <p className="report-notes__caregiver">
                <strong>Caregiver notes:</strong> {caregiverNotes}
              </p>
            )}
          </div>
        ) : (
          <EmptyState message="No care-team notes recorded yet." />
        )}
      </Card>

      {/* Recent activity timeline */}
      <Card>
        <SectionHeader eyebrow="Timeline" title="Recent activity" />
        {timeline.length === 0 ? (
          <EmptyState message="No recent activity to show." />
        ) : (
          <ul className="timeline">
            {timeline.map((t, i) => (
              <li className="timeline__row" key={`${t.kind}-${i}`}>
                <span className={`timeline__dot timeline__dot--${t.kind}`} aria-hidden="true" />
                <div className="timeline__main">
                  <strong>{t.text}</strong>
                  <span>{formatDateTime(t.at)}</span>
                </div>
              </li>
            ))}
          </ul>
        )}
      </Card>
    </div>
  );
}
