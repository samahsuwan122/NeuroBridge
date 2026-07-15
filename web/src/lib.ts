import type { GameResult, PatientProfile } from "./types";

/**
 * Pick the patient the family member is actually linked to.
 *
 * The backend scopes create actions (memory / encouragement / appointment) to a
 * patient the family is *linked* to. Selecting the profile whose active
 * `family_links` includes the current user — instead of blindly `patients[0]` —
 * ensures create requests always target a viewable patient (avoiding a 403 if
 * the account can ever see more than one patient). Falls back to the first
 * patient when no explicit link match is available.
 */
export function pickLinkedPatient(
  patients: PatientProfile[],
  userId?: string,
): PatientProfile | null {
  if (patients.length === 0) return null;
  if (userId) {
    const linked = patients.find((p) =>
      (p.family_links ?? []).some(
        (l) => l.active && l.family_user_id === userId,
      ),
    );
    if (linked) return linked;
  }
  return patients[0];
}

export function formatDate(iso?: string | null): string {
  if (!iso) return "—";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "—";
  return d.toLocaleDateString(undefined, {
    year: "numeric",
    month: "short",
    day: "numeric",
  });
}

export function formatDateTime(iso?: string | null): string {
  if (!iso) return "—";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "—";
  return d.toLocaleString(undefined, {
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

export function formatDuration(seconds?: number | null): string {
  if (seconds == null) return "—";
  if (seconds < 60) return `${seconds}s`;
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return s ? `${m}m ${s}s` : `${m}m`;
}

/**
 * Performance-only score percentage for a game result.
 * Prefers score/max_score, falls back to accuracy_percent. Returns null when
 * neither is available. This is a game-performance metric, not a medical score.
 */
export function scorePercent(r: GameResult): number | null {
  if (r.score != null && r.max_score != null && r.max_score > 0) {
    return Math.round((r.score / r.max_score) * 100);
  }
  if (r.accuracy_percent != null) return Math.round(r.accuracy_percent);
  return null;
}

export function initials(name?: string | null): string {
  if (!name) return "?";
  const parts = name.trim().split(/\s+/);
  return (parts[0]?.[0] ?? "") + (parts[1]?.[0] ?? "");
}

export function patientName(user?: { full_name?: string } | null): string {
  return user?.full_name?.trim() || "Unnamed patient";
}
