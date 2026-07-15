import { useEffect, useMemo, useState } from "react";
import { api } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import {
  BarList,
  Card,
  EmptyState,
  ErrorState,
  FamilySafetyNote,
  SectionHeader,
  Spinner,
  StatCard,
} from "../components/ui";
import {
  formatDate,
  formatDateTime,
  patientName,
  pickLinkedPatient,
  scorePercent,
} from "../lib";
import type {
  Appointment,
  AppointmentListResponse,
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

export function FamilyReportsPage() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [patient, setPatient] = useState<PatientProfile | null>(null);
  const [games, setGames] = useState<GameDefinition[]>([]);
  const [results, setResults] = useState<GameResult[]>([]);
  const [memories, setMemories] = useState<MemoryEntry[]>([]);
  const [encouragements, setEncouragements] = useState<Encouragement[]>([]);
  const [appointments, setAppointments] = useState<Appointment[]>([]);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const p = await api<PatientListResponse>("/patients?limit=50");
      const linked = pickLinkedPatient(p.patients, user?.id);
      setPatient(linked);
      if (!linked) return;

      const id = linked.id;
      const [g, r, m, e, a] = await Promise.all([
        api<GameListResponse>("/games"),
        api<GameResultListResponse>(
          `/games/results?patient_profile_id=${id}&limit=200`,
        ),
        api<MemoryListResponse>("/memories?limit=200"),
        api<EncouragementListResponse>(
          `/encouragements?patient_profile_id=${id}&limit=200`,
        ),
        api<AppointmentListResponse>(
          `/appointments?patient_profile_id=${id}&limit=200`,
        ),
      ]);
      setGames(g.games);
      setResults(r.results);
      setMemories(m.memories.filter((x) => x.patient_profile_id === id));
      setEncouragements(e.encouragements);
      setAppointments(a.appointments);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not load report.");
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
    const dates = results.map((r) => r.created_at).sort();
    const latest = dates.length ? dates[dates.length - 1] : undefined;
    return { total, completed, best, avg, latest };
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
        const a = Math.round(arr.reduce((x, y) => x + y, 0) / arr.length);
        return { label: gameName(gid), value: a, caption: `${a}% avg` };
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

  const apptByStatus = useMemo(() => {
    const map = new Map<string, number>();
    for (const a of appointments) {
      map.set(a.status, (map.get(a.status) ?? 0) + 1);
    }
    return map;
  }, [appointments]);

  if (loading) return <Spinner label="Preparing your report…" />;
  if (error) return <ErrorState message={error} onRetry={load} />;

  return (
    <div className="page">
      <div className="page__head">
        <div>
          <span className="eyebrow">Family reports</span>
          <h1>Family Reports</h1>
          <p className="page__sub">
            A family progress summary for{" "}
            {patient ? patientName(patient.user) : "your family member"} —
            activity performance only.
          </p>
        </div>
        <button className="btn btn--gold" onClick={() => window.print()}>
          Print report
        </button>
      </div>

      <FamilySafetyNote />

      {!patient ? (
        <EmptyState message="No linked patient yet. A report will appear once a patient is linked to your account." />
      ) : (
        <>
          <div className="stat-grid">
            <StatCard label="Total sessions" value={summary.total} />
            <StatCard label="Completed activities" value={summary.completed} />
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
            <StatCard
              label="Latest activity"
              value={summary.latest ? formatDate(summary.latest) : "—"}
            />
            <StatCard label="Memories" value={memories.length} />
            <StatCard label="Encouragements" value={encouragements.length} />
            <StatCard label="Appointment requests" value={appointments.length} />
          </div>

          <div className="grid-2">
            <Card>
              <SectionHeader eyebrow="By exercise" title="Games performance" />
              {perGame.length === 0 ? (
                <EmptyState message="No scored exercises yet." />
              ) : (
                <BarList items={perGame} />
              )}
            </Card>

            <Card>
              <SectionHeader eyebrow="Recent activity" title="Recent sessions" />
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
          </div>

          <div className="grid-2">
            <Card>
              <SectionHeader
                eyebrow="Memory album"
                title="Memory contributions"
              />
              {memories.length === 0 ? (
                <EmptyState message="No memories yet." />
              ) : (
                <ul className="minilist">
                  {memories.slice(0, 6).map((mem) => (
                    <li key={mem.id} className="report-row">
                      <strong>{mem.title}</strong>
                      <span>{formatDate(mem.memory_date ?? mem.created_at)}</span>
                    </li>
                  ))}
                  {memories.length > 6 && (
                    <li className="report-row report-row--more">
                      +{memories.length - 6} more
                    </li>
                  )}
                </ul>
              )}
            </Card>

            <Card>
              <SectionHeader
                eyebrow="Encouragement"
                title="Supportive messages"
              />
              {encouragements.length === 0 ? (
                <EmptyState message="No encouragement messages yet." />
              ) : (
                <ul className="minilist">
                  {encouragements.slice(0, 5).map((e) => (
                    <li key={e.id} className="report-row">
                      <strong>“{e.message}”</strong>
                      <span>{formatDate(e.created_at)}</span>
                    </li>
                  ))}
                </ul>
              )}
            </Card>
          </div>

          <Card>
            <SectionHeader
              eyebrow="Appointments"
              title="Appointment requests"
            />
            {appointments.length === 0 ? (
              <EmptyState message="No appointment requests yet." />
            ) : (
              <div className="report-appts">
                {["pending", "approved", "completed", "cancelled"].map(
                  (status) => (
                    <div className="report-appts__item" key={status}>
                      <strong>{apptByStatus.get(status) ?? 0}</strong>
                      <span>{status}</span>
                    </div>
                  ),
                )}
              </div>
            )}
          </Card>
        </>
      )}
    </div>
  );
}
