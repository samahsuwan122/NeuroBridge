import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import { ErrorState, Spinner } from "../components/ui";
import { loadCareData, reviewStatus, type CareData } from "../lib/careData";
import { formatDateTime, scorePercent } from "../lib";
import { useI18n } from "../i18n/useI18n";

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

  return <div className="page provider-overview">
    <div className="page__head provider-overview__intro"><div><span className="eyebrow">{t("dash.eyebrow")}</span><h1>{t("dash.welcomeBack", {name:user?.full_name?.split(" ")[0] ?? t("role.doctor")})}</h1><p className="page__sub">{t("dash.sub")}</p></div></div>
    <section className="provider-hero"><div className="provider-hero__content"><span className="eyebrow">{t("dash.carePerspective")}</span><h2>{t("dash.careTitle")}</h2><p>{t("dash.careBody")}</p><Link className="btn btn--primary provider-hero__cta" to="/patients">{t("dash.viewPatients")}</Link></div></section>
    <section className="provider-kpis">{metrics.map(([label,value,hint]) => <article className="provider-kpi" key={String(label)}><span>{label}</span><strong>{value}</strong><small>{hint}</small></article>)}</section>
    <div className="provider-workspace">
      <section className="provider-panel provider-panel--activity"><header><div><span className="eyebrow">{t("dash.recentActivity")}</span><h2>{t("dash.latestSessions")}</h2></div><Link className="link" to="/patients">{t("dash.allPatients")}</Link></header>{results.length===0?<div className="provider-empty"><span className="provider-empty__icon provider-empty__icon--history" aria-hidden="true"/><strong>{t("dash.noSessions")}</strong><p>{t("dash.noSessionsHelp")}</p></div>:<ul className="provider-activity-list">{results.slice(0,6).map(({r,p})=>{const pct=scorePercent(r);return <li key={r.id}><span className="provider-patient-avatar">{p.name.slice(0,1)}</span><div><Link to={`/patients/${p.profile.id}`}>{p.name}</Link><span>{data.gameName(r.game_definition_id)} · {formatDateTime(r.created_at)}</span></div><strong>{pct==null?t("dash.recorded"):`${pct}%`}</strong></li>})}</ul>}</section>
      <section className="provider-panel provider-panel--followup"><header><div><span className="eyebrow">{t("dash.yourPatients")}</span><h2>{t("dash.followUp")}</h2></div></header>{data.patients.length===0?<div className="provider-empty"><span aria-hidden="true">◎</span><strong>{t("dash.noPatients")}</strong></div>:<ul className="provider-patient-list">{data.patients.slice(0,5).map(p=>{const s=reviewStatus(p);return <li key={p.profile.id}><Link to={`/patients/${p.profile.id}`}><span className="provider-patient-avatar">{p.name.slice(0,1)}</span><span><strong>{p.name}</strong><small>{p.lastActivityAt?formatDateTime(p.lastActivityAt):t("status.noRecentActivity")}</small></span><span className={`provider-status provider-status--${s.tone}`}>{t(s.labelKey)}</span><i aria-hidden="true">→</i></Link></li>})}</ul>}</section>
      <section className="provider-panel provider-panel--appointments"><header><div><span className="eyebrow">{t("nav.appointments")}</span><h2>{t("dash.upcomingAppointments")}</h2></div><Link className="link" to="/appointments">{t("dash.viewAll")}</Link></header>{appointments.length===0?<div className="provider-empty provider-empty--compact"><span className="provider-empty__icon provider-empty__icon--calendar" aria-hidden="true"/><strong>{t("dash.noAppointments")}</strong><p>{t("dash.noAppointmentsHelp")}</p><Link className="link" to="/appointments">{t("nav.appointments")}</Link></div>:<ul className="provider-appointment-list">{appointments.slice(0,4).map(({a,p})=><li key={a.id}><div><strong>{p.name}</strong><span>{a.preferred_date} · {a.preferred_time||"—"}</span></div><small>{a.appointment_mode} · {a.status}</small></li>)}</ul>}</section>
      <section className="provider-panel provider-review-summary"><header><div><span className="eyebrow">{t("nav.reviewQueue")}</span><h2>{t("dash.reviewSummary")}</h2></div><span className="provider-panel__icon" aria-hidden="true">✓</span></header><div className="provider-review-counts"><span><strong>{reviews.pending}</strong>{t("status.pendingActivity")}</span><span><strong>{reviews.ready}</strong>{t("status.readyForReview")}</span><span><strong>{reviews.idle}</strong>{t("status.noRecentActivity")}</span></div><Link className="btn btn--ghost" to="/review-queue">{t("dash.openReviewQueue")}</Link></section>
    </div>
    <nav className="provider-quick-actions" aria-label={t("dash.quickActions")}><strong>{t("dash.quickActions")}</strong><Link to="/patients"><i>◎</i><b>{t("nav.patients")}</b><span>→</span></Link><Link to="/appointments"><i>□</i><b>{t("nav.appointments")}</b><span>→</span></Link><Link to="/reports"><i>▤</i><b>{t("nav.reports")}</b><span>→</span></Link><Link to="/review-queue"><i>✓</i><b>{t("nav.reviewQueue")}</b><span>→</span></Link></nav>
  </div>;
}
