import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { Badge, EmptyState, ErrorState, Spinner } from "../components/ui";
import { formatDate } from "../lib";
import { useI18n } from "../i18n/useI18n";
import { loadCareData, reviewStatus, type CareData } from "../lib/careData";

/**
 * Reports — patient-first. Shows the clinician's assigned patients as cards
 * with performance/engagement counts; selecting a patient opens their report
 * at /reports/:patientId. Performance-only, non-diagnostic.
 */
export function ReportsPage() {
  const { t } = useI18n();
  const [data, setData] = useState<CareData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [query, setQuery] = useState("");

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      setData(await loadCareData());
    } catch (err) {
      setError(err instanceof Error ? err.message : t("reports.couldNotLoad"));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  const filtered = useMemo(() => {
    if (!data) return [];
    const q = query.trim().toLowerCase();
    const list = q
      ? data.patients.filter((p) => p.name.toLowerCase().includes(q))
      : data.patients;
    // Surface patients needing attention first (pending, then recent).
    const rank = (s: string) => (s === "pending" ? 0 : s === "ready" ? 1 : 2);
    return [...list].sort(
      (a, b) => rank(reviewStatus(a).status) - rank(reviewStatus(b).status),
    );
  }, [data, query]);

  if (loading) return <Spinner label={t("reports.loading")} />;
  if (error) return <ErrorState message={error} onRetry={load} />;

  return (
    <div className="page">
      <div className="page__head">
        <div>
          <span className="eyebrow">{t("reports.eyebrow")}</span>
          <h1>{t("reports.title")}</h1>
          <p className="page__sub">{t("reports.sub")}</p>
        </div>
        {data && data.patients.length > 0 && (
          <input
            className="search"
            type="search"
            placeholder={t("reports.searchPatients")}
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            aria-label={t("reports.searchAria")}
          />
        )}
      </div>

      {filtered.length === 0 ? (
        <EmptyState
          message={
            data && data.patients.length === 0
              ? t("dash.noPatients")
              : t("reports.noMatch")
          }
        />
      ) : (
        <div className="report-grid">
          {filtered.map((p) => {
            const status = reviewStatus(p);
            return (
              <Link className="report-card" to={`/reports/${p.profile.id}`} key={p.profile.id}>
                <div className="report-card__head">
                  <span className="avatar" aria-hidden="true">
                    {p.name.slice(0, 1)}
                  </span>
                  <div className="report-card__id">
                    <strong>{p.name}</strong>
                    <span className="report-card__last">
                      {t("reports.lastActivity", { date: formatDate(p.lastActivityAt) })}
                    </span>
                  </div>
                  <Badge tone={status.tone}>{t(status.labelKey)}</Badge>
                </div>

                <div className="report-card__stats">
                  <div>
                    <strong>{p.completedSessions}</strong>
                    <span>{t("reports.completedSessions")}</span>
                  </div>
                  <div>
                    <strong>{p.assignedActivities}</strong>
                    <span>{t("reports.assignedActivities")}</span>
                  </div>
                  <div>
                    <strong>{p.pendingActivities}</strong>
                    <span>{t("reports.pending")}</span>
                  </div>
                </div>

                <span className="report-card__go">{t("reports.viewReport")}</span>
              </Link>
            );
          })}
        </div>
      )}
    </div>
  );
}
