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
import { Link } from "react-router-dom";
import { MemoryGrid } from "../components/MemoryGrid";
import { MemoryForm } from "../components/MemoryForm";
import {
  formatDate,
  formatDateTime,
  formatDuration,
  patientName,
  pickLinkedPatient,
  scorePercent,
} from "../lib";
import type {
  Encouragement,
  EncouragementListResponse,
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
  const [latestEncouragement, setLatestEncouragement] =
    useState<Encouragement | null>(null);
  const [formOpen, setFormOpen] = useState(false);
  const [banner, setBanner] = useState<
    { tone: "ok" | "warn"; text: string } | null
  >(null);

  // The patient this family member is linked to (used for all create actions).
  const patient = pickLinkedPatient(patients, user?.id);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      // Backend scopes /patients to the family member's linked patient(s).
      const p = await api<PatientListResponse>("/patients?limit=200");
      const linked = pickLinkedPatient(p.patients, user?.id);

      const [g, r, m, e] = await Promise.all([
        api<GameListResponse>("/games"),
        linked
          ? api<GameResultListResponse>(
              `/games/results?patient_profile_id=${linked.id}&limit=200`,
            )
          : Promise.resolve({ results: [] } as unknown as GameResultListResponse),
        api<MemoryListResponse>("/memories?limit=200"),
        linked
          ? api<EncouragementListResponse>(
              `/encouragements?patient_profile_id=${linked.id}&limit=1`,
            )
          : Promise.resolve(
              { encouragements: [] } as unknown as EncouragementListResponse,
            ),
      ]);

      setPatients(p.patients);
      setGames(g.games);
      setResults(r.results);
      setMemories(
        linked
          ? m.memories.filter((x) => x.patient_profile_id === linked.id)
          : [],
      );
      setLatestEncouragement(e.encouragements[0] ?? null);
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

  // Refresh just the album after a contribution (GET /memories, scoped).
  const refreshMemories = async (patientId: string) => {
    try {
      const m = await api<MemoryListResponse>("/memories?limit=200");
      setMemories(m.memories.filter((x) => x.patient_profile_id === patientId));
    } catch {
      // Keep the existing list; the page can be reloaded to retry.
    }
  };

  const handleSaved = async (
    patientId: string,
    info: { imageFailed: boolean },
  ) => {
    setFormOpen(false);
    setBanner(
      info.imageFailed
        ? {
            tone: "warn",
            text: "Memory saved, but the image could not be uploaded. You can add it later.",
          }
        : { tone: "ok", text: "Memory saved and added to the album." },
    );
    await refreshMemories(patientId);
  };

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

          {/* Memory album + contribution */}
          <Card>
            <SectionHeader
              eyebrow="Memory album"
              title="Cherished memories"
              action={
                <button
                  className="btn btn--gold btn--sm"
                  onClick={() => {
                    setBanner(null);
                    setFormOpen((v) => !v);
                  }}
                >
                  {formOpen ? "Close" : "＋ Add memory"}
                </button>
              }
            />

            {banner && (
              <div className={`banner banner--${banner.tone}`}>{banner.text}</div>
            )}

            {formOpen && (
              <MemoryForm
                patientId={patient.id}
                onCancel={() => setFormOpen(false)}
                onSaved={(info) => handleSaved(patient.id, info)}
              />
            )}

            {memories.length === 0 ? (
              <EmptyState message="No memory album entries yet. Add the first supportive memory for family recall." />
            ) : (
              <MemoryGrid memories={memories} />
            )}
          </Card>

          {/* Family encouragement preview (full form lives on /encouragement) */}
          <Card>
            <SectionHeader
              eyebrow="Family encouragement"
              title="Supportive messages"
              action={
                <Link className="btn btn--gold btn--sm" to="/encouragement">
                  Open encouragement
                </Link>
              }
            />
            {latestEncouragement ? (
              <div className="encourage-preview">
                <p>“{latestEncouragement.message}”</p>
                <span className="encourage-preview__date">
                  {formatDateTime(latestEncouragement.created_at)}
                </span>
              </div>
            ) : (
              <EmptyState message="No encouragement messages yet. Open encouragement to send one." />
            )}
          </Card>

          <FamilySafetyNote />
        </>
      )}
    </div>
  );
}
