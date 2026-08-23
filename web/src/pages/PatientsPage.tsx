import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../api/client";
import { ErrorState, Spinner } from "../components/ui";
import { formatDate, initials, patientName } from "../lib";
import { useI18n } from "../i18n/useI18n";
import type { TranslationKey } from "../i18n/translations";
import type { PatientListResponse, PatientProfile } from "../types";

type ViewMode = "cards" | "list";
const VIEW_KEY = "nb_provider_patients_view";

export function PatientsPage() {
  const { t } = useI18n();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [patients, setPatients] = useState<PatientProfile[]>([]);
  const [query, setQuery] = useState("");
  const [view, setView] = useState<ViewMode | null>(() => {
    const saved = localStorage.getItem(VIEW_KEY);
    return saved === "cards" || saved === "list" ? saved : null;
  });
  const load = async () => { setLoading(true); setError(null); try { const res = await api<PatientListResponse>("/patients?limit=200"); setPatients(res.patients); } catch (err) { setError(err instanceof Error ? err.message : t("patients.couldNotLoad")); } finally { setLoading(false); } };
  useEffect(() => { void load(); }, []);
  const filtered = useMemo(() => { const q = query.trim().toLocaleLowerCase(); return q ? patients.filter((p) => patientName(p.user).toLocaleLowerCase().includes(q)) : patients; }, [patients, query]);
  const activeView: ViewMode = view ?? (patients.length === 1 ? "list" : "cards");
  const changeView = (next: ViewMode) => { setView(next); localStorage.setItem(VIEW_KEY, next); };
  const assignmentLabel = (value?: string) => {
    const normalized = value?.trim().toLowerCase();
    const key: TranslationKey = normalized === "doctor" ? "patients.assignmentDoctor" : normalized === "therapist" ? "patients.assignmentTherapist" : "patients.assignmentCare";
    return t(key);
  };
  const genderLabel = (value?: string | null) => {
    const normalized = value?.trim().toLowerCase();
    if (normalized === "male") return t("patients.genderMale");
    if (normalized === "female") return t("patients.genderFemale");
    return value ? t("patients.genderOther") : null;
  };

  return <div className="page provider-patients">
    <header className="provider-patients__head"><div><span className="eyebrow">{t("patients.eyebrow")}</span><h1>{t("patients.title")}</h1><p>{t("patients.sub")}</p><div className="provider-patients__summary"><strong>{patients.length}</strong><span>{t("patients.assignedSummary")}</span></div></div></header>
    <div className="provider-patients__tools"><label className="provider-patient-search"><span aria-hidden="true"/><input type="search" placeholder={t("patients.searchByName")} value={query} onChange={(e) => setQuery(e.target.value)}/>{query && <button type="button" onClick={() => setQuery("")} aria-label={t("patients.clearSearch")}>×</button>}</label><div className="provider-view-toggle" aria-label={t("patients.viewMode")}><button className={activeView === "cards" ? "is-active" : ""} onClick={() => changeView("cards")}>{t("patients.cards")}</button><button className={activeView === "list" ? "is-active" : ""} onClick={() => changeView("list")}>{t("patients.list")}</button></div></div>
    {loading ? <div className="provider-patients__state"><Spinner /></div> : error ? <ErrorState message={error} onRetry={load}/> : filtered.length === 0 ? <div className="provider-patients__empty"><span className="provider-patients__empty-icon" aria-hidden="true"/><h2>{patients.length ? t("patients.noMatch") : t("patients.noAssignedTitle")}</h2><p>{patients.length ? t("patients.noMatchHelp") : t("patients.noAssignedHelp")}</p>{query && <button className="btn btn--ghost btn--sm" onClick={() => setQuery("")}>{t("patients.clearSearch")}</button>}</div> : <div className={`provider-patient-grid provider-patient-grid--${activeView}`}>{filtered.map((p) => {
      const name = patientName(p.user); const assignment = p.assignments.find((a) => a.active); const gender = genderLabel(p.gender);
      return <article className="provider-patient-card" key={p.id}><div className="provider-patient-card__identity"><span className="provider-patient-card__avatar" aria-hidden="true">{initials(name)}</span><div><h2>{name}</h2><span className="provider-patient-card__assignment">{assignmentLabel(assignment?.assignment_type)}</span></div></div>{(p.date_of_birth || gender) && <dl>{p.date_of_birth && <div><dt>{t("table.dob")}</dt><dd>{formatDate(p.date_of_birth)}</dd></div>}{gender && <div><dt>{t("table.gender")}</dt><dd>{gender}</dd></div>}</dl>}<Link className="provider-patient-card__open" to={`/patients/${p.id}`}>{t("patients.openPatient")}<span aria-hidden="true">→</span></Link></article>;
    })}</div>}
  </div>;
}
