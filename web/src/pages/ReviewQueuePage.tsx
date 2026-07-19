import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { Badge, EmptyState, ErrorState, Spinner } from "../components/ui";
import { formatDate, formatDateTime } from "../lib";
import { isRecent, loadCareData, type CareData, type PatientAggregate } from "../lib/careData";

type Tone = "neutral" | "live" | "plan" | "gold";

interface QueueItem {
  key: string;
  patientId: string;
  patientName: string;
  type: string;
  detail: string;
  at: string | null;
  statusLabel: string;
  tone: Tone;
  priority: number; // lower = more attention
  actions: { label: string; to: string }[];
}

function startOfToday(): number {
  const d = new Date();
  d.setHours(0, 0, 0, 0);
  return d.getTime();
}

function buildQueue(data: CareData): QueueItem[] {
  const items: QueueItem[] = [];
  const today = startOfToday();

  const push = (
    p: PatientAggregate,
    part: Omit<QueueItem, "key" | "patientId" | "patientName">,
  ) => {
    items.push({
      key: `${p.profile.id}-${part.type}`,
      patientId: p.profile.id,
      patientName: p.name,
      ...part,
    });
  };

  for (const p of data.patients) {
    const reportTo = `/reports/${p.profile.id}`;
    const patientTo = `/patients/${p.profile.id}`;

    // Pending assigned activities → follow-up.
    if (p.pendingActivities > 0) {
      const latest = [...p.activities]
        .filter((a) => a.status === "assigned")
        .sort((a, b) => +new Date(b.created_at) - +new Date(a.created_at))[0];
      push(p, {
        type: "Pending activity",
        detail: `${p.pendingActivities} assigned ${p.pendingActivities === 1 ? "activity" : "activities"} not started`,
        at: latest?.created_at ?? null,
        statusLabel: "Pending follow-up",
        tone: "plan",
        priority: 1,
        actions: [
          { label: "Open patient", to: patientTo },
          { label: "View report", to: reportTo },
        ],
      });
    }

    // Unread family/provider messages → needs review.
    if (p.unreadMessages > 0) {
      push(p, {
        type: "Unread messages",
        detail: `${p.unreadMessages} unread ${p.unreadMessages === 1 ? "reply" : "replies"}`,
        at:
          [...p.messages]
            .map((m) => m.latest_reply_at ?? m.created_at)
            .sort((a, b) => +new Date(b) - +new Date(a))[0] ?? null,
        statusLabel: "Needs review",
        tone: "plan",
        priority: 1,
        actions: [{ label: "View messages", to: "/appointments" }],
      });
    }

    // Recently completed activities → ready for review.
    const recentDoneActs = p.activities.filter(
      (a) => a.status === "completed" && isRecent(a.completed_at),
    );
    if (recentDoneActs.length > 0) {
      push(p, {
        type: "Activity completed",
        detail: `${recentDoneActs.length} recently completed`,
        at:
          [...recentDoneActs]
            .map((a) => a.completed_at ?? a.created_at)
            .sort((a, b) => +new Date(b) - +new Date(a))[0] ?? null,
        statusLabel: "Ready for review",
        tone: "live",
        priority: 2,
        actions: [{ label: "View report", to: reportTo }],
      });
    }

    // Recently completed cognitive sessions → ready for review.
    const recentSessions = p.results.filter(
      (r) => r.completed && isRecent(r.created_at),
    );
    if (recentSessions.length > 0) {
      push(p, {
        type: "Sessions completed",
        detail: `${recentSessions.length} recent cognitive ${recentSessions.length === 1 ? "session" : "sessions"}`,
        at:
          [...recentSessions]
            .map((r) => r.created_at)
            .sort((a, b) => +new Date(b) - +new Date(a))[0] ?? null,
        statusLabel: "Ready for review",
        tone: "live",
        priority: 2,
        actions: [{ label: "View report", to: reportTo }],
      });
    }

    // Upcoming appointments.
    const upcoming = p.appointments.filter((ap) => {
      const t = new Date(ap.preferred_date).getTime();
      return (
        !Number.isNaN(t) &&
        t >= today &&
        ["pending", "approved", "requested"].includes(ap.status)
      );
    });
    if (upcoming.length > 0) {
      const next = [...upcoming].sort(
        (a, b) => +new Date(a.preferred_date) - +new Date(b.preferred_date),
      )[0];
      push(p, {
        type: "Upcoming appointment",
        detail: `${next.provider_name ?? "Appointment"} · ${formatDate(next.preferred_date)}`,
        at: next.preferred_date,
        statusLabel: "Upcoming",
        tone: "gold",
        priority: 3,
        actions: [{ label: "View appointment", to: "/appointments" }],
      });
    }

    // No recent activity.
    if (!isRecent(p.lastActivityAt) && p.pendingActivities === 0) {
      push(p, {
        type: "No recent activity",
        detail: p.lastActivityAt
          ? `Last activity ${formatDate(p.lastActivityAt)}`
          : "No activity recorded yet",
        at: p.lastActivityAt,
        statusLabel: "No recent activity",
        tone: "neutral",
        priority: 4,
        actions: [{ label: "Open patient", to: patientTo }],
      });
    }
  }

  return items.sort((a, b) => {
    if (a.priority !== b.priority) return a.priority - b.priority;
    const ta = a.at ? new Date(a.at).getTime() : 0;
    const tb = b.at ? new Date(b.at).getTime() : 0;
    return tb - ta;
  });
}

/**
 * Care Review Queue — a deterministic, performance-only worklist that helps the
 * care team see what to look at next. No risk scores, alerts, or medical
 * conclusions; only counts, dates, and engagement states.
 */
export function ReviewQueuePage() {
  const [data, setData] = useState<CareData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      setData(await loadCareData());
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not load the queue.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  const queue = useMemo(() => (data ? buildQueue(data) : []), [data]);

  if (loading) return <Spinner label="Loading review queue…" />;
  if (error) return <ErrorState message={error} onRetry={load} />;

  return (
    <div className="page">
      <div className="page__head">
        <div>
          <span className="eyebrow">Care Review Queue</span>
          <h1>Care Review Queue</h1>
          <p className="page__sub">
            What needs your attention across your patients.
          </p>
        </div>
      </div>

      <p className="queue-note">
        AI-assisted summaries organize activity data for care-team review only —
        performance-based, not a medical assessment.
      </p>

      {queue.length === 0 ? (
        <EmptyState message="Nothing needs review right now. You're all caught up." />
      ) : (
        <ul className="queue">
          {queue.map((item) => (
            <li className="queue-item" key={item.key}>
              <div className="queue-item__body">
                <div className="queue-item__top">
                  <strong className="queue-item__name">{item.patientName}</strong>
                  <Badge tone={item.tone}>{item.statusLabel}</Badge>
                </div>
                <span className="queue-item__type">{item.type}</span>
                <span className="queue-item__detail">{item.detail}</span>
                <span className="queue-item__time">{formatDateTime(item.at)}</span>
              </div>
              <div className="queue-item__actions">
                {item.actions.map((a) => (
                  <Link className="btn btn--ghost btn--sm" to={a.to} key={a.label}>
                    {a.label}
                  </Link>
                ))}
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
