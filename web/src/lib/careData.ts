// Shared, read-only aggregation of care-team data for the Reports list and the
// Care Review Queue. Built entirely from existing endpoints — no new backend.
//
// SAFETY: everything here is performance/engagement data only. Summaries are
// deterministic (rule-based) counts and dates — never diagnosis, prediction,
// risk scoring, or any medical conclusion.

import { api } from "../api/client";
import { patientName } from "../lib";
import type { TranslationKey } from "../i18n/translations";
import type {
  Appointment,
  AppointmentListResponse,
  AssignedActivity,
  AssignedActivityListResponse,
  GameListResponse,
  GameResult,
  GameResultListResponse,
  PatientListResponse,
  PatientProfile,
  ProviderMessage,
  ProviderMessageListResponse,
} from "../types";

export interface PatientAggregate {
  profile: PatientProfile;
  name: string;
  results: GameResult[];
  activities: AssignedActivity[];
  appointments: Appointment[];
  messages: ProviderMessage[];
  completedSessions: number;
  totalSessions: number;
  assignedActivities: number;
  pendingActivities: number;
  completedActivities: number;
  unreadMessages: number;
  lastActivityAt: string | null;
}

export interface CareData {
  patients: PatientAggregate[];
  gameName: (id: string) => string;
}

const RECENT_DAYS = 14;

export function isRecent(iso?: string | null, days = RECENT_DAYS): boolean {
  if (!iso) return false;
  const t = new Date(iso).getTime();
  if (Number.isNaN(t)) return false;
  return Date.now() - t <= days * 24 * 60 * 60 * 1000;
}

function maxDate(dates: (string | null | undefined)[]): string | null {
  let best: number | null = null;
  let bestIso: string | null = null;
  for (const d of dates) {
    if (!d) continue;
    const t = new Date(d).getTime();
    if (Number.isNaN(t)) continue;
    if (best == null || t > best) {
      best = t;
      bestIso = d;
    }
  }
  return bestIso;
}

/** Load and aggregate everything the Reports list + Queue need, per patient. */
export async function loadCareData(): Promise<CareData> {
  const [p, g, r, a, m] = await Promise.all([
    api<PatientListResponse>("/patients?limit=200"),
    api<GameListResponse>("/games"),
    api<GameResultListResponse>("/games/results?limit=200"),
    api<AppointmentListResponse>("/appointments?limit=200"),
    api<ProviderMessageListResponse>("/provider-messages?limit=200"),
  ]);

  const nameMap = new Map(g.games.map((x) => [x.id, x.name]));
  const gameName = (id: string) => nameMap.get(id) ?? "Exercise";

  // Assigned activities have no cross-patient list endpoint, so fetch per
  // patient (small demo cohort). Failures degrade to an empty list.
  const activitiesByPatient = new Map<string, AssignedActivity[]>();
  await Promise.all(
    p.patients.map(async (patient) => {
      try {
        const res = await api<AssignedActivityListResponse>(
          `/activities/patient/${patient.id}?limit=100`,
        );
        activitiesByPatient.set(patient.id, res.activities);
      } catch {
        activitiesByPatient.set(patient.id, []);
      }
    }),
  );

  const resultsByPatient = groupBy(r.results, (x) => x.patient_profile_id);
  const apptByPatient = groupBy(a.appointments, (x) => x.patient_profile_id);
  const msgByPatient = groupBy(m.messages, (x) => x.patient_profile_id);

  const patients: PatientAggregate[] = p.patients.map((profile) => {
    const results = resultsByPatient.get(profile.id) ?? [];
    const activities = activitiesByPatient.get(profile.id) ?? [];
    const appointments = apptByPatient.get(profile.id) ?? [];
    const messages = msgByPatient.get(profile.id) ?? [];

    const pendingActivities = activities.filter(
      (x) => x.status === "assigned",
    ).length;
    const completedActivities = activities.filter(
      (x) => x.status === "completed",
    ).length;
    const unreadMessages = messages.reduce(
      (sum, x) => sum + (x.unread_reply_count ?? 0),
      0,
    );

    const lastActivityAt = maxDate([
      ...results.map((x) => x.created_at),
      ...activities.map((x) => x.completed_at ?? x.created_at),
      ...messages.map((x) => x.latest_reply_at ?? x.created_at),
    ]);

    return {
      profile,
      name: patientName(profile.user),
      results,
      activities,
      appointments,
      messages,
      completedSessions: results.filter((x) => x.completed).length,
      totalSessions: results.length,
      assignedActivities: activities.length,
      pendingActivities,
      completedActivities,
      unreadMessages,
      lastActivityAt,
    };
  });

  return { patients, gameName };
}

function groupBy<T>(items: T[], key: (x: T) => string): Map<string, T[]> {
  const map = new Map<string, T[]>();
  for (const item of items) {
    const k = key(item);
    const arr = map.get(k) ?? [];
    arr.push(item);
    map.set(k, arr);
  }
  return map;
}

// --- safe, rule-based review status -----------------------------------------

export type ReviewStatus = "pending" | "ready" | "idle";

export function reviewStatus(
  p: Pick<PatientAggregate, "pendingActivities" | "lastActivityAt">,
): {
  status: ReviewStatus;
  labelKey: TranslationKey;
  tone: "neutral" | "live" | "plan" | "gold";
} {
  if (p.pendingActivities > 0) {
    return { status: "pending", labelKey: "status.pendingActivity", tone: "plan" };
  }
  if (isRecent(p.lastActivityAt)) {
    return { status: "ready", labelKey: "status.readyForReview", tone: "live" };
  }
  return { status: "idle", labelKey: "status.noRecentActivity", tone: "neutral" };
}
