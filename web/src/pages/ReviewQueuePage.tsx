import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { Badge, EmptyState, ErrorState, Spinner } from "../components/ui";
import { formatDate, formatDateTime } from "../lib";
import { useI18n } from "../i18n/useI18n";
import type { TranslationKey } from "../i18n/translations";
import { isRecent, loadCareData, type CareData, type PatientAggregate } from "../lib/careData";

type Tone = "neutral" | "live" | "plan" | "gold";
type T = (key: TranslationKey, params?: Record<string, string | number>) => string;

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

function buildQueue(data: CareData, t: T): QueueItem[] {
  const items: QueueItem[] = [];
  const today = startOfToday();
  const word = (n: number, one: TranslationKey, many: TranslationKey) =>
    t(n === 1 ? one : many);

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
    const openPatient = { label: t("queue.action.openPatient"), to: patientTo };
    const viewReport = { label: t("queue.action.viewReport"), to: reportTo };

    // Pending assigned activities → follow-up.
    if (p.pendingActivities > 0) {
      const latest = [...p.activities]
        .filter((a) => a.status === "assigned")
        .sort((a, b) => +new Date(b.created_at) - +new Date(a.created_at))[0];
      push(p, {
        type: t("queue.type.pendingActivity"),
        detail: t("queue.detail.pending", {
          n: p.pendingActivities,
          activities: word(p.pendingActivities, "word.activity", "word.activities"),
        }),
        at: latest?.created_at ?? null,
        statusLabel: t("queue.status.pendingFollowUp"),
        tone: "plan",
        priority: 1,
        actions: [openPatient, viewReport],
      });
    }

    // Unread family/provider messages → needs review.
    if (p.unreadMessages > 0) {
      push(p, {
        type: t("queue.type.unreadMessages"),
        detail: t("queue.detail.unread", {
          n: p.unreadMessages,
          replies: word(p.unreadMessages, "word.reply", "word.replies"),
        }),
        at:
          [...p.messages]
            .map((m) => m.latest_reply_at ?? m.created_at)
            .sort((a, b) => +new Date(b) - +new Date(a))[0] ?? null,
        statusLabel: t("queue.status.needsReview"),
        tone: "plan",
        priority: 1,
        actions: [{ label: t("queue.action.viewMessages"), to: "/appointments" }],
      });
    }

    // Recently completed activities → ready for review.
    const recentDoneActs = p.activities.filter(
      (a) => a.status === "completed" && isRecent(a.completed_at),
    );
    if (recentDoneActs.length > 0) {
      push(p, {
        type: t("queue.type.activityCompleted"),
        detail: t("queue.detail.doneRecently", { n: recentDoneActs.length }),
        at:
          [...recentDoneActs]
            .map((a) => a.completed_at ?? a.created_at)
            .sort((a, b) => +new Date(b) - +new Date(a))[0] ?? null,
        statusLabel: t("queue.status.readyForReview"),
        tone: "live",
        priority: 2,
        actions: [viewReport],
      });
    }

    // Recently completed cognitive sessions → ready for review.
    const recentSessions = p.results.filter(
      (r) => r.completed && isRecent(r.created_at),
    );
    if (recentSessions.length > 0) {
      push(p, {
        type: t("queue.type.sessionsCompleted"),
        detail: t("queue.detail.sessionsRecent", {
          n: recentSessions.length,
          sessions: word(recentSessions.length, "word.session", "word.sessions"),
        }),
        at:
          [...recentSessions]
            .map((r) => r.created_at)
            .sort((a, b) => +new Date(b) - +new Date(a))[0] ?? null,
        statusLabel: t("queue.status.readyForReview"),
        tone: "live",
        priority: 2,
        actions: [viewReport],
      });
    }

    // Upcoming appointments.
    const upcoming = p.appointments.filter((ap) => {
      const time = new Date(ap.preferred_date).getTime();
      return (
        !Number.isNaN(time) &&
        time >= today &&
        ["pending", "approved", "requested"].includes(ap.status)
      );
    });
    if (upcoming.length > 0) {
      const next = [...upcoming].sort(
        (a, b) => +new Date(a.preferred_date) - +new Date(b.preferred_date),
      )[0];
      push(p, {
        type: t("queue.type.upcomingAppt"),
        detail: `${next.provider_name ?? t("pr.appointments")} · ${formatDate(next.preferred_date)}`,
        at: next.preferred_date,
        statusLabel: t("queue.status.upcoming"),
        tone: "gold",
        priority: 3,
        actions: [{ label: t("queue.action.viewAppointment"), to: "/appointments" }],
      });
    }

    // No recent activity.
    if (!isRecent(p.lastActivityAt) && p.pendingActivities === 0) {
      push(p, {
        type: t("queue.type.noRecentActivity"),
        detail: p.lastActivityAt
          ? t("queue.detail.lastActivity", { date: formatDate(p.lastActivityAt) })
          : t("queue.detail.noActivityYet"),
        at: p.lastActivityAt,
        statusLabel: t("queue.status.noRecentActivity"),
        tone: "neutral",
        priority: 4,
        actions: [openPatient],
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
  const { t } = useI18n();
  const [data, setData] = useState<CareData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      setData(await loadCareData());
    } catch (err) {
      setError(err instanceof Error ? err.message : t("queue.couldNotLoad"));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  const queue = useMemo(() => (data ? buildQueue(data, t) : []), [data, t]);

  if (loading) return <Spinner label={t("queue.loading")} />;
  if (error) return <ErrorState message={error} onRetry={load} />;

  return (
    <div className="page">
      <div className="page__head">
        <div>
          <span className="eyebrow">{t("queue.eyebrow")}</span>
          <h1>{t("queue.title")}</h1>
          <p className="page__sub">{t("queue.sub")}</p>
        </div>
      </div>

      <p className="queue-note">{t("queue.note")}</p>

      {queue.length === 0 ? (
        <EmptyState message={t("queue.empty")} />
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
