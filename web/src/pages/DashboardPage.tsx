import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import { ErrorState, Spinner } from "../components/ui";
import { loadCareData, reviewStatus, type CareData } from "../lib/careData";
import { formatDateTime, scorePercent } from "../lib";
import { useI18n } from "../i18n/useI18n";

const KPI_ICONS = ["◉", "◷", "✓", "✦"];

export function DashboardPage() {
  const { user } = useAuth();
  const { t } = useI18n();
  const [data, setData] = useState<CareData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const load = async () => { setLoading(true); setError(null); try { setData(await loadCareData()); } catch (e) { setError(e instanceof Error ? e.message : t("dash.couldNotLoad")); } finally { setLoading(false); } };
  useEffect(() => { void load(); }, []);
  const results = useMemo(() => (data?.patients.flatMap((p) => p.results.map((r) => ({ r, p }))) ?? []).sort((a,b) => +new Date(b.r.created_at) - +new Date(a.r.created_at)), [data]);
  const appointments = useMemo(() => (data?.patients.flatMap((p) => p.appointments.map((a) => ({ a, p }))) ?? []).filter(({a}) => +new Date(`${a.preferred_date}T${a.preferred_time || "23:59"}`) >= Date.now()).sort((x,y) => x.a.preferred_date.localeCompare(y.a.preferred_date)), [data]);
  if (loading) return <Spinner />;
  if (error || !data) return <ErrorState message={error ?? t("dash.couldNotLoad")} onRetry={load} />;
  const sessions = data.patients.reduce((n,p) => n + p.totalSessions, 0);
  const completed = data.patients.reduce((n,p) => n + p.completedActivities, 0);
  const reviews = data.patients.reduce((c,p) => { c[reviewStatus(p).status]++; return c; }, { pending: 0, ready: 0, idle: 0 });
  const metrics = [
    [t("dash.stat.assignedPatients"), data.patients.length, t("dash.stat.assignedPatientsHint")],
    [t("dash.stat.recordedSessions"), sessions, t("dash.stat.recordedSessionsHint")],
    [t("dash.stat.completedActivities"), completed, t("dash.stat.completedActivitiesHint")],
    [t("dash.stat.availableActivities"), data.availableActivities, t("dash.stat.availableActivitiesHint")],
  ];
  const focusPatient = data.patients[0] ?? null;
  const focusStatus = focusPatient ? reviewStatus(focusPatient) : null;

  return <div className="page provider-overview doctor-dashboard">
    <div className="page__head doctor-dashboard-intro"><div><span className="eyebrow">{t("dash.eyebrow")}</span><h1>{t("dash.welcomeBack", {name:user?.full_name ?? t("role.doctor")})}</h1><p className="page__sub">{t("dash.sub")}</p></div></div>
    <section className="doctor-dashboard-hero" aria-label={t("dash.carePerspective")}><div className="doctor-dashboard-hero__content"><span className="eyebrow">{t("dash.carePerspective")}</span><h2>{t("dash.careTitle")}</h2><p>{t("dash.careBody")}</p><Link className="btn btn--primary doctor-dashboard-hero__cta" to="/patients">{t("dash.viewPatients")}</Link></div><div className="doctor-dashboard-hero__mark" aria-hidden="true"><span>✚</span></div></section>
    {focusPatient ? <section className="doctor-dashboard-patient" aria-labelledby="doctor-focus-title"><div className="doctor-dashboard-patient__label"><span className="eyebrow">{t("dash.yourPatients")}</span><h2 id="doctor-focus-title">{t("dash.patientFocus")}</h2></div><div className="doctor-dashboard-patient__identity"><span className="doctor-dashboard-patient__avatar" aria-hidden="true">{focusPatient.name.slice(0,1)}</span><div><strong>{focusPatient.name}</strong><small>{t("dash.assignedCare")}</small></div></div>{focusStatus && <span className={`provider-status provider-status--${focusStatus.tone}`}>{t(focusStatus.labelKey)}</span>}<Link className="doctor-dashboard-patient__link" to={`/patients/${focusPatient.profile.id}`}>{t("dash.viewPatientDetails")}</Link></section> : null}
    <section className="doctor-dashboard-kpis">{metrics.map(([label,value,hint], index) => <article className="doctor-dashboard-kpi" key={String(label)}><span className="doctor-dashboard-kpi__icon" aria-hidden="true">{KPI_ICONS[index]}</span><div><strong>{value}</strong><span>{label}</span><small>{hint}</small></div></article>)}</section>
    <div className="doctor-dashboard-sections">
      <section className="doctor-dashboard-section doctor-dashboard-section--activity"><header><div><span className="eyebrow">{t("dash.recentActivity")}</span><h2>{t("dash.latestSessions")}</h2></div><Link className="link" to="/patients">{t("dash.allPatients")}</Link></header>{results.length===0?<div className="doctor-dashboard-empty"><span className="provider-empty__icon provider-empty__icon--history" aria-hidden="true"/><strong>{t("dash.noSessions")}</strong><p>{t("dash.noSessionsHelp")}</p></div>:<ul className="provider-activity-list">{results.slice(0,6).map(({r,p})=>{const pct=scorePercent(r);return <li key={r.id}><span className="provider-patient-avatar">{p.name.slice(0,1)}</span><div><Link to={`/patients/${p.profile.id}`}>{p.name}</Link><span>{data.gameName(r.game_definition_id)} · {formatDateTime(r.created_at)}</span></div><strong>{pct==null?t("dash.recorded"):`${pct}%`}</strong></li>})}</ul>}</section>
      <section className="doctor-dashboard-section doctor-dashboard-section--followup"><header><div><span className="eyebrow">{t("dash.yourPatients")}</span><h2>{t("dash.followUp")}</h2></div></header>{data.patients.length===0?<div className="doctor-dashboard-empty"><span className="doctor-dashboard-empty__patient" aria-hidden="true">◯</span><strong>{t("dash.noPatients")}</strong></div>:<ul className="provider-patient-list">{data.patients.slice(0,5).map(p=>{const s=reviewStatus(p);return <li key={p.profile.id}><Link to={`/patients/${p.profile.id}`}><span className="provider-patient-avatar">{p.name.slice(0,1)}</span><span><strong>{p.name}</strong><small>{p.lastActivityAt?formatDateTime(p.lastActivityAt):t("status.noRecentActivity")}</small></span><span className={`provider-status provider-status--${s.tone}`}>{t(s.labelKey)}</span></Link></li>})}</ul>}</section>
      <section className="doctor-dashboard-section doctor-dashboard-section--appointments"><header><div><span className="eyebrow">{t("nav.appointments")}</span><h2>{t("dash.upcomingAppointments")}</h2></div><Link className="link" to="/appointments">{t("dash.viewAll")}</Link></header>{appointments.length===0?<div className="doctor-dashboard-empty doctor-dashboard-empty--compact"><span className="provider-empty__icon provider-empty__icon--calendar" aria-hidden="true"/><strong>{t("dash.noAppointments")}</strong><p>{t("dash.noAppointmentsHelp")}</p><Link className="link" to="/appointments">{t("nav.appointments")}</Link></div>:<ul className="provider-appointment-list">{appointments.slice(0,4).map(({a,p})=><li key={a.id}><div><strong>{p.name}</strong><span>{a.preferred_date} · {a.preferred_time||"—"}</span></div><small>{a.appointment_mode} · {a.status}</small></li>)}</ul>}</section>
      <section className="doctor-dashboard-section doctor-dashboard-review"><header><div><span className="eyebrow">{t("nav.reviewQueue")}</span><h2>{t("dash.reviewSummary")}</h2></div><span className="doctor-dashboard-section__icon" aria-hidden="true">✓</span></header><div className="provider-review-counts"><span><strong>{reviews.pending}</strong>{t("status.pendingActivity")}</span><span><strong>{reviews.ready}</strong>{t("status.readyForReview")}</span><span><strong>{reviews.idle}</strong>{t("status.noRecentActivity")}</span></div><Link className="btn btn--ghost" to="/review-queue">{t("dash.openReviewQueue")}</Link></section>
    </div>
    <nav className="doctor-dashboard-quick" aria-label={t("dash.quickActions")}><h2>{t("dash.quickActions")}</h2><div><Link to="/patients"><i>◉</i><b>{t("nav.patients")}</b></Link><Link to="/appointments"><i>◷</i><b>{t("nav.appointments")}</b></Link><Link to="/reports"><i>▤</i><b>{t("nav.reports")}</b></Link><Link to="/review-queue"><i>✓</i><b>{t("nav.reviewQueue")}</b></Link></div></nav>
  </div>;
}
