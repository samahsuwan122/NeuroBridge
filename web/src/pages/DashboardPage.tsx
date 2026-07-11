import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import {
  Card,
  EmptyState,
  ErrorState,
  SafetyNote,
  SectionHeader,
  Spinner,
  StatCard,
} from "../components/ui";
import { formatDateTime, patientName, scorePercent } from "../lib";
import type {
  GameDefinition,
  GameListResponse,
  GameResult,
  GameResultListResponse,
  PatientListResponse,
  PatientProfile,
} from "../types";

export function DashboardPage() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [patients, setPatients] = useState<PatientProfile[]>([]);
  const [games, setGames] = useState<GameDefinition[]>([]);
  const [results, setResults] = useState<GameResult[]>([]);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const [p, g, r] = await Promise.all([
        api<PatientListResponse>("/patients?limit=200"),
        api<GameListResponse>("/games"),
        api<GameResultListResponse>("/games/results?limit=100"),
      ]);
      setPatients(p.patients);
      setGames(g.games);
      setResults(r.results);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not load dashboard.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  const gameName = useMemo(() => {
    const map = new Map(games.map((g) => [g.id, g.name]));
    return (id: string) => map.get(id) ?? "Exercise";
  }, [games]);

  const patientById = useMemo(() => {
    const map = new Map(patients.map((p) => [p.id, p]));
    return (id: string) => map.get(id);
  }, [patients]);

  const completedCount = results.filter((r) => r.completed).length;
  const completionRate = results.length
    ? Math.round((completedCount / results.length) * 100)
    : 0;
  const recent = [...results]
    .sort((a, b) => +new Date(b.created_at) - +new Date(a.created_at))
    .slice(0, 8);

  if (loading) return <Spinner label="Loading your dashboard…" />;
  if (error) return <ErrorState message={error} onRetry={load} />;

  return (
    <div className="page">
      <div className="page__head">
        <div>
          <span className="eyebrow">Overview</span>
          <h1>Welcome, {user?.full_name?.split(" ")[0] ?? "Doctor"}</h1>
          <p className="page__sub">
            A supportive, performance-only view of your assigned patients.
          </p>
        </div>
      </div>

      <div className="stat-grid">
        <StatCard
          icon="☰"
          label="Assigned patients"
          value={patients.length}
          hint="Role-scoped to you"
        />
        <StatCard
          icon="✦"
          label="Recorded sessions"
          value={results.length}
          hint="Cognitive exercises"
        />
        <StatCard
          icon="✓"
          label="Completion rate"
          value={`${completionRate}%`}
          hint="Game performance only"
        />
        <StatCard
          icon="◆"
          label="Exercises available"
          value={games.length}
          hint="In the patient app"
        />
      </div>

      <div className="grid-2">
        <Card>
          <SectionHeader
            eyebrow="Recent activity"
            title="Latest cognitive sessions"
            action={<Link className="link" to="/patients">All patients →</Link>}
          />
          {recent.length === 0 ? (
            <EmptyState message="No recorded sessions yet for your patients." />
          ) : (
            <ul className="activity">
              {recent.map((r) => {
                const p = patientById(r.patient_profile_id);
                const pct = scorePercent(r);
                return (
                  <li className="activity__row" key={r.id}>
                    <div className="activity__main">
                      <strong>{gameName(r.game_definition_id)}</strong>
                      <span>
                        {p ? (
                          <Link className="link" to={`/patients/${p.id}`}>
                            {patientName(p.user)}
                          </Link>
                        ) : (
                          "Patient"
                        )}
                        {" · "}
                        {formatDateTime(r.created_at)}
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

        <Card>
          <SectionHeader eyebrow="Your patients" title="Quick access" />
          {patients.length === 0 ? (
            <EmptyState message="No patients are assigned to you yet." />
          ) : (
            <ul className="minilist">
              {patients.slice(0, 6).map((p) => (
                <li key={p.id}>
                  <Link className="minilist__item" to={`/patients/${p.id}`}>
                    <span className="avatar avatar--sm" aria-hidden="true">
                      {patientName(p.user).slice(0, 1)}
                    </span>
                    <span>{patientName(p.user)}</span>
                    <span className="minilist__go" aria-hidden="true">
                      →
                    </span>
                  </Link>
                </li>
              ))}
            </ul>
          )}
        </Card>
      </div>

      <SafetyNote />
    </div>
  );
}
