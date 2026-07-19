import { useEffect, useMemo, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { api } from "../api/client";
import { ActivityBuilder } from "../components/ActivityBuilder";
import {
  BarList,
  Badge,
  Card,
  EmptyState,
  ErrorState,
  SectionHeader,
  Spinner,
  StatCard,
} from "../components/ui";
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
  PatientProfile,
} from "../types";

export function PatientDetailPage() {
  const { id = "" } = useParams();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [patient, setPatient] = useState<PatientProfile | null>(null);
  const [games, setGames] = useState<GameDefinition[]>([]);
  const [results, setResults] = useState<GameResult[]>([]);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      // Memory Album is intentionally NOT fetched here: personal family
      // memories are private to the patient and their linked family, not the
      // care team (backend enforces this too).
      const [p, g, r] = await Promise.all([
        api<PatientProfile>(`/patients/${id}`),
        api<GameListResponse>("/games"),
        api<GameResultListResponse>(
          `/games/results?patient_profile_id=${id}&limit=200`,
        ),
      ]);
      setPatient(p);
      setGames(g.games);
      setResults(r.results);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not load patient.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, [id]);

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
      .map(([gid, arr]) => ({
        label: gameName(gid),
        value: Math.round(arr.reduce((a, b) => a + b, 0) / arr.length),
        caption: `${Math.round(arr.reduce((a, b) => a + b, 0) / arr.length)}% avg · ${arr.length}`,
      }))
      .sort((a, b) => b.value - a.value);
  }, [results, gameName]);

  const recent = useMemo(
    () =>
      [...results]
        .sort((a, b) => +new Date(b.created_at) - +new Date(a.created_at))
        .slice(0, 10),
    [results],
  );

  if (loading) return <Spinner label="Loading patient…" />;
  if (error) return <ErrorState message={error} onRetry={load} />;
  if (!patient) return <EmptyState message="Patient not found." />;

  const care: { label: string; value?: string | null }[] = [
    { label: "Allergies", value: patient.allergies },
    { label: "Current medications", value: patient.current_medications },
    { label: "Blood type", value: patient.blood_type },
    { label: "Mobility needs", value: patient.mobility_needs },
    { label: "Vision / hearing", value: patient.vision_hearing_needs },
    { label: "Preferred communication", value: patient.preferred_communication },
    { label: "Emergency contact", value: patient.emergency_contact_name },
    { label: "Caregiver notes", value: patient.caregiver_notes },
  ];

  return (
    <div className="page">
      <div className="crumbs">
        <Link className="link" to="/patients">
          Patients
        </Link>
        <span aria-hidden="true"> / </span>
        <span>{patientName(patient.user)}</span>
      </div>

      <div className="patient-head">
        <span className="avatar avatar--lg" aria-hidden="true">
          {patientName(patient.user).slice(0, 1)}
        </span>
        <div>
          <h1>{patientName(patient.user)}</h1>
          <p className="patient-head__meta">
            {patient.gender ? `${patient.gender} · ` : ""}
            {patient.date_of_birth
              ? `Born ${formatDate(patient.date_of_birth)}`
              : "Date of birth not provided"}
          </p>
        </div>
        <div className="patient-head__tags">
          {patient.assignments
            .filter((a) => a.active)
            .map((a) => (
              <Badge tone="live" key={a.id}>
                {a.assignment_type}
              </Badge>
            ))}
        </div>
      </div>

      {/* Progress summary */}
      <SectionHeader
        eyebrow="Progress summary"
        title="Cognitive exercise performance"
      />
      <div className="stat-grid">
        <StatCard label="Total exercises" value={summary.total} />
        <StatCard label="Completed" value={summary.completed} />
        <StatCard
          label="Best performance"
          value={summary.best != null ? `${summary.best}%` : "—"}
          hint="Across recorded sessions"
        />
        <StatCard
          label="Average performance"
          value={summary.avg != null ? `${summary.avg}%` : "—"}
          hint="Across recorded sessions"
        />
      </div>

      <div className="grid-2">
        {/* Cognitive games performance */}
        <Card>
          <SectionHeader eyebrow="By exercise" title="Games performance" />
          {perGame.length === 0 ? (
            <EmptyState message="No scored exercises yet." />
          ) : (
            <BarList items={perGame} />
          )}
        </Card>

        {/* Recent activity / sessions */}
        <Card>
          <SectionHeader eyebrow="Recent activity" title="Sessions" />
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
      </div>

      {/* Care-team activity builder */}
      <Card>
        <ActivityBuilder patientProfileId={id} />
      </Card>

      {/* Memory album — private to patient & family (not shown to care team) */}
      <Card className="privacy-card">
        <SectionHeader eyebrow="Private family space" title="Memory album" />
        <div className="privacy-note">
          <span className="privacy-note__icon" aria-hidden="true">🔒</span>
          <p>
            Private family memories are managed in the patient and family space.
            Photos and personal captions aren&apos;t shown to the care team.
          </p>
        </div>
      </Card>

      {/* Care information */}
      <Card>
        <SectionHeader eyebrow="Care information" title="Care details" />
        <div className="care-grid">
          {care.map((row) => (
            <div className="care-row" key={row.label}>
              <span className="care-row__label">{row.label}</span>
              <span className="care-row__value">{row.value?.trim() || "—"}</span>
            </div>
          ))}
        </div>
      </Card>
    </div>
  );
}
