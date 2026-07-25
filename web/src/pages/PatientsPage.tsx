import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../api/client";
import { Badge, EmptyState, ErrorState, Spinner } from "../components/ui";
import { formatDate, patientName } from "../lib";
import { useI18n } from "../i18n/useI18n";
import type { PatientListResponse, PatientProfile } from "../types";

export function PatientsPage() {
  const { t } = useI18n();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [patients, setPatients] = useState<PatientProfile[]>([]);
  const [query, setQuery] = useState("");

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await api<PatientListResponse>("/patients?limit=200");
      setPatients(res.patients);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not load patients.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return patients;
    return patients.filter((p) =>
      patientName(p.user).toLowerCase().includes(q),
    );
  }, [patients, query]);

  return (
    <div className="page">
      <div className="page__head">
        <div>
          <span className="eyebrow">{t("patients.eyebrow")}</span>
          <h1>{t("patients.title")}</h1>
          <p className="page__sub">{t("patients.sub")}</p>
        </div>
        <input
          className="search"
          type="search"
          placeholder={t("patients.searchByName")}
          value={query}
          onChange={(e) => setQuery(e.target.value)}
        />
      </div>

      {loading ? (
        <Spinner />
      ) : error ? (
        <ErrorState message={error} onRetry={load} />
      ) : filtered.length === 0 ? (
        <EmptyState
          message={
            patients.length === 0
              ? t("dash.noPatients")
              : t("patients.noMatch")
          }
        />
      ) : (
        <div className="table-card">
          <table className="table">
            <thead>
              <tr>
                <th>{t("table.patient")}</th>
                <th>{t("table.dob")}</th>
                <th>{t("table.gender")}</th>
                <th>{t("table.assignment")}</th>
                <th aria-label={t("common.view")} />
              </tr>
            </thead>
            <tbody>
              {filtered.map((p) => {
                const mine = p.assignments.find((a) => a.active);
                return (
                  <tr key={p.id}>
                    <td>
                      <Link className="cell-name" to={`/patients/${p.id}`}>
                        <span className="avatar avatar--sm" aria-hidden="true">
                          {patientName(p.user).slice(0, 1)}
                        </span>
                        {patientName(p.user)}
                      </Link>
                    </td>
                    <td>{formatDate(p.date_of_birth)}</td>
                    <td>{p.gender ?? "—"}</td>
                    <td>
                      {mine ? (
                        <Badge tone="live">{mine.assignment_type}</Badge>
                      ) : (
                        <Badge>—</Badge>
                      )}
                    </td>
                    <td className="table__go">
                      <Link className="link" to={`/patients/${p.id}`}>
                        {t("common.view")}
                      </Link>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
