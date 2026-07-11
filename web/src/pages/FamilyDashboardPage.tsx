import { useEffect, useMemo, useState } from "react";
import { api } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import {
  Badge,
  BarList,
  Card,
  EmptyState,
  ErrorState,
  FamilySafetyNote,
  SectionHeader,
  Spinner,
  StatCard,
} from "../components/ui";
import { MemoryGrid } from "../components/MemoryGrid";
import {
  formatDate,
  formatDateTime,
  formatDuration,
  patientName,
  scorePercent,
} from "../lib";
import type {
  GameDefinition,
  GameListResponse,
  GameResult,
  GameResultListResponse,
  MemoryEntry,
  MemoryListResponse,
  PatientListResponse,
  PatientProfile,
} from "../types";

export function FamilyDashboardPage() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [patients, setPatients] = useState<PatientProfile[]>([]);
  const [games, setGames] = useState<GameDefinition[]>([]);
  const [results, setResults] = useState<GameResult[]>([]);
  const [memories, setMemories] = useState<MemoryEntry[]>([]);

  // The linked patient (foundation: the first linked patient).
  const patient = patients[0] ?? null;

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      // Backend scopes /patients to the family member's linked patient(s).
      const p = await api<PatientListResponse>("/patients?limit=200");
      const linked = p.patients[0] ?? null;

      const [g, r, m] = await Promise.all([
        api<GameListResponse>("/games"),
        linked
          ? api<GameResultListResponse>(
              `/games/results?patient_profile_id=${linked.id}&limit=200`,
            )
          : Promise.resolve({ results: [] } as unknown as GameResultListResponse),
        api<MemoryListResponse>("/memories?limit=200"),
      ]);

      setPatients(p.patients);
      setGames(g.games);
      setResults(r.results);
      setMemories(
        linked
          ? m.memories.filter((x) => x.patient_profile_id === linked.id)
          : [],
      );
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not load your view.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  const gameName = useMemo(() => {
    const map = new Map(games.map((g) => [g.id, g.name]));
    return (gid: string) => map.get(gid) ?? "Exercise";
  }, [games]);

  const summary = useMemo(() => {
    const total = results.length;
    const completed = results.filter((r) => r.completed).length;
    const pcts = results
      .map(scorePercent)
      .filter((v): v is number => v != null);
    const best = pcts.length ? Math.max(...pcts) : null;
    const avg = pcts.length
      ? Math.round(pcts.reduce((a, b) => a + b, 0) / pcts.length)
      : null;
    return { total, completed, best, avg };
  }, [results]);

  const perGame = useMemo(() => {
    const buckets = new Map<string, number[]>();
    for (const r of results) {
      const pct = scorePercent(r);
      if (pct == null) continue;
      const arr = buckets.get(r.game_definition_id) ?? [];
      arr.push(pct);
      buckets.set(r.game_definition_id, arr);
    }
    return [...buckets.entries()]
      .map(([gid, arr]) => {
        const avg = Math.round(arr.reduce((a, b) => a + b, 0) / arr.length);
        return { label: gameName(gid), value: avg, caption: `${avg}% avg` };
      })
      .sort((a, b) => b.value - a.value);
  }, [results, gameName]);

  const recent = useMemo(
    () =>
      [...results]
        .sort((a, b) => +new Date(b.created_at) - +new Date(a.created_at))
        .slice(0, 8),
    [results],
  );

  const relationship = useMemo(() => {
    if (!patient || !user) return null;
    const link = patient.family_links?.find(
      (l) => l.family_user_id === user.id && l.active,
    );
    return link?.relationship ?? null;
  }, [patient, user]);

  if (loading) return <Spinner label="Loading your family view…" />;
  if (error) return <ErrorState message={error} onRetry={load} />;

  return (
    <div className="page">
      <div className="page__head">
        <div>
          <span className="eyebrow">Family overview</span>
          <h1>Welcome, {user?.full_name?.split(" ")[0] ?? "there"}</h1>
          <p className="page__sub">
            A supportive view of your family member&apos;s daily journey —
            activity performance only.
          </p>
        </div>
      </div>

      {!patient ? (
        <EmptyState message="No linked patient yet. Once a patient is linked to your account, their supportive journey will appear here." />
      ) : (
        <>
          {/* Linked patient card */}
          <div className="patient-head">
            <span className="avatar avatar--lg" aria-hidden="true">
              {patientName(patient.user).slice(0, 1)}
            </span>
            <div>
              <h2>{patientName(patient.user)}</h2>
              <p className="patient-head__meta">
                {relationship ? `Your ${relationship} · ` : ""}
                {patient.gender ? `${patient.gender} · ` : ""}
                {patient.date_of_birth
                  ? `Born ${formatDate(patient.date_of_birth)}`
                  : "Following their supportive journey"}
              </p>
            </div>
            <div className="patient-head__tags">
              <Badge tone="gold">Linked patient</Badge>
            </div>
          </div>

          {/* Activity summary */}
          <div className="stat-grid">
            <StatCard
              label="Recorded sessions"
              value={summary.total}
              hint="Cognitive exercises"
            />
            <StatCard
              label="Completed"
              value={summary.completed}
              hint="Activity only"
            />
            <StatCard
              label="Best performance"
              value={summary.best != null ? `${summary.best}%` : "—"}
              hint="Activity performance only"
            />
            <StatCard
              label="Average performance"
              value={summary.avg != null ? `${summary.avg}%` : "—"}
              hint="Activity performance only"
            />
          </div>

          <div className="grid-2">
            {/* Recent activity */}
            <Card>
              <SectionHeader
                eyebrow="Recent activity"
                title="Latest sessions"
              />
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
                          <span>
                            {formatDateTime(r.created_at)}
                            {" · "}
                            {formatDuration(r.duration_seconds)}
                          </span>
                        </div>
                        <div className="activity__meta">
                          {pct != null && <span className="pill">{pct}%</span>}
                          <span
                            className={`dotlabel ${r.completed ? "dotlabel--ok" : ""}`}
                          >
                            {r.completed ? "Completed" : "In progress"}
                          </span>
                        </div>
                      </li>
                    );
                  })}
                </ul>
              )}
            </Card>

            {/* Games performance summary */}
            <Card>
              <SectionHeader eyebrow="By exercise" title="Games performance" />
              {perGame.length === 0 ? (
                <EmptyState message="No scored exercises yet." />
              ) : (
                <BarList items={perGame} />
              )}
            </Card>
          </div>

          {/* Memory album */}
          <Card>
            <SectionHeader
              eyebrow="Memory album"
              title="Cherished memories"
              action={<Badge tone="gold">Family-contributed</Badge>}
            />
            {memories.length === 0 ? (
              <EmptyState message="No memory album entries yet." />
            ) : (
              <MemoryGrid memories={memories} />
            )}
          </Card>

          {/* Encouragement placeholder */}
          <Card className="ai-card">
            <SectionHeader
              eyebrow="Family encouragement"
              title="Send a supportive message"
              action={<Badge tone="plan">Coming soon</Badge>}
            />
            <div className="ai-placeholder">
              <p>
                A simple way to send <strong>family encouragement</strong> to
                your family member will appear here.
              </p>
              <textarea
                className="encourage__input"
                rows={2}
                placeholder="Encouragement messaging is coming soon…"
                disabled
              />
              <div className="encourage__row">
                <button className="btn btn--gold" disabled>
                  Send encouragement
                </button>
                <span className="ai-placeholder__note">
                  No messaging endpoint exists yet — this is a labeled
                  placeholder, not a live feature.
                </span>
              </div>
            </div>
          </Card>

          <FamilySafetyNote />
        </>
      )}
    </div>
  );
}
