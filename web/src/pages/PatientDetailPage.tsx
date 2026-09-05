import { useEffect, useMemo, useState } from "react";
import { Link, useParams, useSearchParams } from "react-router-dom";
import { api } from "../api/client";
import { listPatientGoals } from "../api/goals";
import { ActivityBuilder } from "../components/ActivityBuilder";
import { GoalsPanel } from "../components/GoalsPanel";
import { BarList, Badge, Card, EmptyState, ErrorState, SectionHeader, Spinner, StatCard } from "../components/ui";
import { formatDate, formatDateTime, formatDuration, initials, patientName, scorePercent } from "../lib";
import { useI18n } from "../i18n/useI18n";
import type { TranslationKey } from "../i18n/translations";
import type { AssignedActivity, AssignedActivityListResponse, GameDefinition, GameListResponse, GameResult, GameResultListResponse, Goal, PatientProfile } from "../types";

const TABS = ["overview", "sessions", "activities", "goals", "care"] as const;
type WorkspaceTab = (typeof TABS)[number];

export function PatientDetailPage() {
  const { t } = useI18n();
  const { id = "" } = useParams();
  const [params, setParams] = useSearchParams();
  const requested = params.get("tab");
  const activeTab: WorkspaceTab = TABS.includes(requested as WorkspaceTab) ? requested as WorkspaceTab : "overview";
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [patient, setPatient] = useState<PatientProfile | null>(null);
  const [games, setGames] = useState<GameDefinition[]>([]);
  const [results, setResults] = useState<GameResult[]>([]);
  const [overviewGoals, setOverviewGoals] = useState<Goal[]>([]);
  const [overviewActivities, setOverviewActivities] = useState<AssignedActivity[]>([]);
  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      // بيانات المريض هي الطلب الأساسي. فشل الألعاب أو النتائج لا يجب أن
      // يمنع الطبيب من فتح ملف المريض كاملًا.
      const patientData = await api<PatientProfile>(`/patients/${id}`);
      setPatient(patientData);

      const [gamesRequest, resultsRequest] = await Promise.allSettled([
        api<GameListResponse>("/games"),
        api<GameResultListResponse>(`/games/results?patient_profile_id=${id}&limit=200`),
      ]);

      setGames(gamesRequest.status === "fulfilled" ? gamesRequest.value.games : []);
      setResults(resultsRequest.status === "fulfilled" ? resultsRequest.value.results : []);
    } catch (requestError) {
      setError(
        requestError instanceof Error && requestError.message.trim()
          ? requestError.message
          : t("pd.couldNotLoad"),
      );
    } finally {
      setLoading(false);
    }
  };
  useEffect(() => { void load(); }, [id]);
  useEffect(() => { if (activeTab !== "overview") return; void Promise.all([listPatientGoals(id),api<AssignedActivityListResponse>(`/activities/patient/${id}?limit=3`)]).then(([goals,activities])=>{setOverviewGoals(goals.goals.filter((goal)=>goal.status==="active").slice(0,3));setOverviewActivities(activities.activities.slice(0,3));}).catch(()=>{setOverviewGoals([]);setOverviewActivities([]);}); }, [activeTab,id]);
  const gameName = useMemo(() => { const map = new Map(games.map((g) => [g.id,g.name])); return (gid:string) => map.get(gid) ?? t("word.activity"); }, [games,t]);
  const summary = useMemo(() => { const pcts=results.map(scorePercent).filter((v):v is number=>v!=null); return {total:results.length,completed:results.filter((r)=>r.completed).length,best:pcts.length?Math.max(...pcts):null,avg:pcts.length?Math.round(pcts.reduce((a,b)=>a+b,0)/pcts.length):null}; },[results]);
  const recent = useMemo(() => [...results].sort((a,b)=>+new Date(b.created_at)-+new Date(a.created_at)),[results]);
  const perGame = useMemo(() => { const buckets=new Map<string,number[]>(); results.forEach((r)=>{const pct=scorePercent(r);if(pct==null)return;const values=buckets.get(r.game_definition_id)??[];values.push(pct);buckets.set(r.game_definition_id,values)});return [...buckets].map(([gid,values])=>{const value=Math.round(values.reduce((a,b)=>a+b,0)/values.length);return{label:gameName(gid),value,caption:`${value}% · ${values.length}`}}).sort((a,b)=>b.value-a.value);},[results,gameName]);
  const selectTab = (tab: WorkspaceTab) => setParams({tab});
  const onTabKeyDown = (event: React.KeyboardEvent<HTMLButtonElement>, index:number) => { if(!["ArrowLeft","ArrowRight","Home","End"].includes(event.key))return;event.preventDefault();let next=event.key==="Home"?0:event.key==="End"?TABS.length-1:(index+(event.key==="ArrowRight"?1:-1)+TABS.length)%TABS.length;selectTab(TABS[next]);document.getElementById(`patient-tab-${TABS[next]}`)?.focus(); };
  if (loading) return <Spinner/>;
  if (error) return <ErrorState message={error} onRetry={load}/>;
  if (!patient) return <EmptyState message={t("pd.notFound")}/>;
  const name=patientName(patient.user);
  const assignment=patient.assignments.find((a)=>a.active)?.assignment_type?.toLowerCase();
  const assignmentLabel=assignment==="doctor"?t("patients.assignmentDoctor"):assignment==="therapist"?t("patients.assignmentTherapist"):t("patients.assignmentCare");
  const gender=patient.gender?.toLowerCase()==="male"?t("patients.genderMale"):patient.gender?.toLowerCase()==="female"?t("patients.genderFemale"):patient.gender?t("patients.genderOther"):null;
  const careGroups = [
    {title:t("pd.careMedical"),rows:[["care.allergies",patient.allergies],["care.medications",patient.current_medications],["care.bloodType",patient.blood_type]]},
    {title:t("pd.careSupport"),rows:[["care.mobility",patient.mobility_needs],["care.visionHearing",patient.vision_hearing_needs]]},
    {title:t("pd.careCommunication"),rows:[["care.preferredComm",patient.preferred_communication],["care.caregiverNotes",patient.caregiver_notes]]},
    {title:t("pd.careEmergency"),rows:[["care.emergencyContact",patient.emergency_contact_name]]},
  ].map((group)=>({...group,rows:group.rows.filter(([,value])=>value?.trim())})).filter((group)=>group.rows.length);
  const stats = <div className="patient-workspace__stats"><StatCard label={t("pd.stat.total")} value={summary.total}/><StatCard label={t("common.completed")} value={summary.completed}/><StatCard label={t("pd.stat.best")} value={summary.best!=null?`${summary.best}%`:"—"} hint={t("common.acrossSessions")}/><StatCard label={t("pd.stat.avg")} value={summary.avg!=null?`${summary.avg}%`:"—"} hint={t("common.acrossSessions")}/></div>;

  return <div className="page patient-workspace">
    <nav className="patient-workspace__breadcrumb" aria-label={t("pd.backToPatients")}><Link className="patient-workspace__back" to="/patients">{t("patients.title")}</Link><span aria-hidden="true">/</span><strong>{name}</strong></nav>
    <div className="patient-workspace__sticky"><header className="patient-context"><span className="patient-context__avatar" aria-hidden="true">{initials(name)}</span><div className="patient-context__identity"><h1>{name}</h1><span className="patient-context__assignment">{assignmentLabel}</span><p>{patient.date_of_birth&&t("pd.born",{date:formatDate(patient.date_of_birth)})}{patient.date_of_birth&&gender?" · ":""}{gender}</p></div></header><div className="patient-workspace__tabs" role="tablist" aria-label={t("pd.workspaceNavigation")}>{TABS.map((tab,index)=><button id={`patient-tab-${tab}`} key={tab} role="tab" aria-selected={activeTab===tab} aria-controls={`patient-panel-${tab}`} tabIndex={activeTab===tab?0:-1} onClick={()=>selectTab(tab)} onKeyDown={(event)=>onTabKeyDown(event,index)}>{t(`pd.tab.${tab}` as TranslationKey)}</button>)}</div></div>
    <main id={`patient-panel-${activeTab}`} className="patient-workspace__panel" role="tabpanel" aria-labelledby={`patient-tab-${activeTab}`}>
      {activeTab==="overview"&&<><SectionHeader eyebrow={t("pd.progressSummary")} title={t("pd.overviewTitle")}/>{stats}<div className="patient-overview-grid"><Card><SectionHeader eyebrow={t("dash.recentActivity")} title={t("pd.latestRecorded")}/>{recent[0]?<SessionRow result={recent[0]} gameName={gameName} t={t}/>:<EmptyState message={t("pd.noSessions")} icon="session"/>}</Card><Card><SectionHeader eyebrow={t("pd.overviewActivities")} title={t("pd.activitiesTitle")}/>{overviewActivities.length?<ul className="patient-overview-list">{overviewActivities.map((activity)=><li key={activity.id}><strong>{activity.title}</strong><Badge tone={activity.status==="completed"?"live":"plan"}>{t(`activityStatus.${activity.status}` as TranslationKey)}</Badge></li>)}</ul>:<p className="muted-sub">{t("pd.activitiesSummaryHelp")}</p>}<button className="link patient-workspace__switch" onClick={()=>selectTab("activities")}>{t("pd.viewActivities")}</button></Card><Card><SectionHeader eyebrow={t("pd.overviewGoals")} title={t("pd.goalsTitle")}/>{overviewGoals.length?<ul className="patient-overview-list">{overviewGoals.map((goal)=><li key={goal.id}><strong>{goal.title}</strong><span>{goal.current_value} / {goal.target_value}</span></li>)}</ul>:<p className="muted-sub">{t("pd.goalsSummaryHelp")}</p>}<button className="link patient-workspace__switch" onClick={()=>selectTab("goals")}>{t("pd.viewGoals")}</button></Card>{careGroups.length>0&&<Card><SectionHeader eyebrow={t("pd.careInfo")} title={t("pd.careSnapshot")}/><div className="patient-care-snapshot">{careGroups.flatMap((g)=>g.rows).slice(0,3).map(([key,value])=><div key={key}><span>{t(key as TranslationKey)}</span><strong>{value}</strong></div>)}</div><button className="link patient-workspace__switch" onClick={()=>selectTab("care")}>{t("pd.viewCare")}</button></Card>}</div></>}
      {activeTab==="sessions"&&<><SectionHeader eyebrow={t("pd.progressSummary")} title={t("pd.sessionsPerformance")}/>{stats}<div className="patient-session-grid"><Card><SectionHeader eyebrow={t("pd.byExercise")} title={t("pd.gamesPerformance")}/>{perGame.length?<BarList items={perGame}/>:<EmptyState message={t("pd.noScored")} icon="performance"/>}</Card><Card><SectionHeader eyebrow={t("pd.sessionHistory")} title={t("pd.sessions")}/>{recent.length?<ul className="activity patient-session-history">{recent.map((r)=><SessionRow key={r.id} result={r} gameName={gameName} t={t}/>)}</ul>:<EmptyState message={t("pd.noSessions")} icon="session"/>}</Card></div></>}
      {activeTab==="activities"&&<Card className="patient-workspace__management"><ActivityBuilder patientProfileId={id}/></Card>}
      {activeTab==="goals"&&<Card className="patient-workspace__management"><GoalsPanel patientProfileId={id}/></Card>}
      {activeTab==="care"&&<><SectionHeader eyebrow={t("pd.careInfo")} title={t("pd.careDetails")}/><div className="patient-care-groups">{careGroups.map((group)=><Card key={group.title}><h2>{group.title}</h2><div className="care-grid">{group.rows.map(([key,value])=><div className="care-row" key={key}><span className="care-row__label">{t(key as TranslationKey)}</span><span className="care-row__value">{value}</span></div>)}</div></Card>)}</div></>}
    </main>
  </div>;
}

function SessionRow({result,gameName,t}:{result:GameResult;gameName:(id:string)=>string;t:(key:TranslationKey,vars?:Record<string,string|number>)=>string}) { const pct=scorePercent(result);return <li className="activity__row"><div className="activity__main"><strong>{gameName(result.game_definition_id)}</strong><span>{formatDateTime(result.created_at)} · {formatDuration(result.duration_seconds)}</span></div><div className="activity__meta">{pct!=null&&<span className="pill">{pct}%</span>}<Badge tone={result.completed?"live":"neutral"}>{result.completed?t("common.completed"):t("common.inProgress")}</Badge></div></li>; }
