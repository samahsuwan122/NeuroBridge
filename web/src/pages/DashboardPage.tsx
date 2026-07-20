import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import {
  Card,
  EmptyState,
  ErrorState,
  SectionHeader,
  Spinner,
  StatCard,
} from "../components/ui";
import { formatDateTime, patientName, scorePercent } from "../lib";
import { useI18n } from "../i18n/useI18n";
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
  const { t } = useI18n();
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

  if (loading) return <Spinner />;
  if (error) return <ErrorState message={error} onRetry={load} />;

  return (
    <div className="page">
      <div className="page__head">
        <div>
          <span className="eyebrow">{t("dash.eyebrow")}</span>
          <h1>
            {t("dash.welcomeBack", {
              name: user?.full_name?.split(" ")[0] ?? t("role.doctor"),
            })}
          </h1>
          <p className="page__sub">{t("dash.sub")}</p>
        </div>
      </div>

      <section className="welcome-card" aria-label="A note for the care team">
        <span className="welcome-card__label" dir="rtl" lang="ar">
          رسالة لفريق الرعاية
        </span>
        <blockquote className="welcome-card__quote" dir="rtl" lang="ar">
          <p className="welcome-card__lead">
            خلف كل ملاحظة تقدّم هناك إنسان يستحق الصبر، الرعاية، والمتابعة الواعية
          </p>
          <span className="welcome-card__cta-ar">هيا بنا لنتابع</span>
        </blockquote>
      </section>

      <div className="stat-grid">
        <StatCard
          icon="☰"
          label={t("dash.stat.assignedPatients")}
          value={patients.length}
          hint={t("dash.stat.assignedPatientsHint")}
        />
        <StatCard
          icon="✦"
          label={t("dash.stat.recordedSessions")}
          value={results.length}
          hint={t("dash.stat.recordedSessionsHint")}
        />
        <StatCard
          icon="✓"
          label={t("dash.stat.completionRate")}
          value={`${completionRate}%`}
          hint={t("common.acrossSessions")}
        />
        <StatCard
          icon="◆"
          label={t("dash.stat.exercisesAvailable")}
          value={games.length}
          hint={t("dash.stat.exercisesAvailableHint")}
        />
      </div>

      <div className="grid-2">
        <Card>
          <SectionHeader
            eyebrow={t("dash.recentActivity")}
            title={t("dash.latestSessions")}
            action={<Link className="link" to="/patients">{t("dash.allPatients")}</Link>}
          />
          {recent.length === 0 ? (
            <EmptyState message={t("dash.noSessions")} />
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
                          t("common.patient")
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
                        {r.completed ? t("common.completed") : t("common.inProgress")}
                      </span>
                    </div>
                  </li>
                );
              })}
            </ul>
          )}
        </Card>

        <Card>
          <SectionHeader eyebrow={t("dash.yourPatients")} title={t("dash.quickAccess")} />
          {patients.length === 0 ? (
            <EmptyState message={t("dash.noPatients")} />
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
    </div>
  );
}
