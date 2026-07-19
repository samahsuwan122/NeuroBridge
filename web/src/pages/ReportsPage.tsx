import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { Badge, EmptyState, ErrorState, Spinner } from "../components/ui";
import { formatDate } from "../lib";
import { loadCareData, reviewStatus, type CareData } from "../lib/careData";

/**
 * Reports — patient-first. Shows the clinician's assigned patients as cards
 * with performance/engagement counts; selecting a patient opens their report
 * at /reports/:patientId. Performance-only, non-diagnostic.
 */
export function ReportsPage() {
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
      setError(err instanceof Error ? err.message : "Could not load reports.");
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

  if (loading) return <Spinner label="Loading reports…" />;
  if (error) return <ErrorState message={error} onRetry={load} />;

  return (
    <div className="page">
      <div className="page__head">
        <div>
          <span className="eyebrow">Reports</span>
          <h1>Reports</h1>
          <p className="page__sub">
            Select a patient to review their performance summary.
          </p>
        </div>
        {data && data.patients.length > 0 && (
          <input
            className="search"
            type="search"
            placeholder="Search patients…"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            aria-label="Search patients"
          />
        )}
      </div>

      {filtered.length === 0 ? (
        <EmptyState
          message={
            data && data.patients.length === 0
              ? "No patients are assigned to you yet."
              : "No patients match your search."
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
                      Last activity: {formatDate(p.lastActivityAt)}
                    </span>
                  </div>
                  <Badge tone={status.tone}>{status.label}</Badge>
                </div>

                <div className="report-card__stats">
                  <div>
                    <strong>{p.completedSessions}</strong>
                    <span>Completed sessions</span>
                  </div>
                  <div>
                    <strong>{p.assignedActivities}</strong>
                    <span>Assigned activities</span>
                  </div>
                  <div>
                    <strong>{p.pendingActivities}</strong>
                    <span>Pending</span>
                  </div>
                </div>

                <span className="report-card__go">View report →</span>
              </Link>
            );
          })}
        </div>
      )}
    </div>
  );
}
