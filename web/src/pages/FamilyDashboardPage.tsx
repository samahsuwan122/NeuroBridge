import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import {
  Badge,
  BarList,
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
  Provider,
  ProviderListResponse,
  ProviderMessage,
  ProviderMessageListResponse,
} from "../types";
import { useI18n } from "../i18n/useI18n";
import { useFamilyMembers } from "../familyMembers";
import { readDemoAppointments } from "../lib/familyBookingDemo";
import { useCurrentFamilyPatient } from "../currentFamilyPatient";

const dashboardCopy={
 en:{account:"You're using the shared Demo Family account.",next:"Next appointment",viewAppointment:"View appointment",bookAppointment:"Book appointment",noAppointment:"No upcoming appointment",noAppointmentHelp:"You can book a new appointment when needed.",latest:"Latest care-team update",viewMessage:"View message",noMessages:"No new care-team messages",quick:"Quick actions",encouragement:"Send encouragement",memory:"Add memory",book:"Book appointment",message:"Message care team",upcoming:"Upcoming appointment",payment:"Payment pending",newMessage:"New message",doctor:"Doctor",therapist:"Therapist",inPerson:"In person",remote:"Remote",paid:"Paid",pending:"Pending"},
 ar:{account:"أنت الآن تستخدم حساب Demo Family العائلي.",next:"الموعد القادم",viewAppointment:"عرض الموعد",bookAppointment:"حجز موعد",noAppointment:"لا يوجد موعد قادم",noAppointmentHelp:"يمكنك حجز موعد جديد عند الحاجة.",latest:"آخر تحديث من فريق الرعاية",viewMessage:"عرض الرسالة",noMessages:"لا توجد رسائل جديدة",quick:"إجراءات سريعة",encouragement:"إرسال تشجيع",memory:"إضافة ذكرى",book:"حجز موعد",message:"مراسلة مقدم الرعاية",upcoming:"موعد قريب",payment:"دفعة بانتظار الدفع",newMessage:"رسالة جديدة",doctor:"طبيب",therapist:"معالج",inPerson:"في المركز",remote:"عن بُعد",paid:"مدفوع",pending:"معلّق"},
 fr:{account:"Vous utilisez le compte familial partagé Demo Family.",next:"Prochain rendez-vous",viewAppointment:"Voir le rendez-vous",bookAppointment:"Prendre rendez-vous",noAppointment:"Aucun rendez-vous à venir",noAppointmentHelp:"Vous pouvez prendre un nouveau rendez-vous si nécessaire.",latest:"Dernière actualité de l’équipe soignante",viewMessage:"Voir le message",noMessages:"Aucun nouveau message de l’équipe soignante",quick:"Actions rapides",encouragement:"Envoyer un encouragement",memory:"Ajouter un souvenir",book:"Prendre rendez-vous",message:"Écrire à l’équipe soignante",upcoming:"Rendez-vous à venir",payment:"Paiement en attente",newMessage:"Nouveau message",doctor:"Médecin",therapist:"Thérapeute",inPerson:"En personne",remote:"À distance",paid:"Payé",pending:"En attente"},
 es:{account:"Estás usando la cuenta familiar compartida Demo Family.",next:"Próxima cita",viewAppointment:"Ver cita",bookAppointment:"Reservar cita",noAppointment:"No hay próximas citas",noAppointmentHelp:"Puedes reservar una nueva cita cuando sea necesario.",latest:"Última actualización del equipo asistencial",viewMessage:"Ver mensaje",noMessages:"No hay mensajes nuevos del equipo asistencial",quick:"Acciones rápidas",encouragement:"Enviar ánimo",memory:"Añadir recuerdo",book:"Reservar cita",message:"Escribir al equipo asistencial",upcoming:"Próxima cita",payment:"Pago pendiente",newMessage:"Mensaje nuevo",doctor:"Médico",therapist:"Terapeuta",inPerson:"Presencial",remote:"A distancia",paid:"Pagado",pending:"Pendiente"},
 de:{account:"Sie verwenden das gemeinsame Familienkonto Demo Family.",next:"Nächster Termin",viewAppointment:"Termin anzeigen",bookAppointment:"Termin buchen",noAppointment:"Kein bevorstehender Termin",noAppointmentHelp:"Bei Bedarf können Sie einen neuen Termin buchen.",latest:"Neueste Nachricht des Betreuungsteams",viewMessage:"Nachricht anzeigen",noMessages:"Keine neuen Nachrichten des Betreuungsteams",quick:"Schnellaktionen",encouragement:"Ermutigung senden",memory:"Erinnerung hinzufügen",book:"Termin buchen",message:"Betreuungsteam schreiben",upcoming:"Bevorstehender Termin",payment:"Zahlung ausstehend",newMessage:"Neue Nachricht",doctor:"Arzt",therapist:"Therapeut",inPerson:"Vor Ort",remote:"Online",paid:"Bezahlt",pending:"Ausstehend"}
};

export function FamilyDashboardPage() {
  const { t,lang } = useI18n();
  const { user } = useAuth();
  const {active}=useFamilyMembers();
  const {patient,loading:patientLoading,copy:patientCopy,name:currentPatientName,relationship:currentPatientRelationship}=useCurrentFamilyPatient();
  const dc=dashboardCopy[lang];
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [games, setGames] = useState<GameDefinition[]>([]);
  const [results, setResults] = useState<GameResult[]>([]);
  const [providers,setProviders]=useState<Provider[]>([]);
  const [careMessages,setCareMessages]=useState<ProviderMessage[]>([]);
  const appointments=useMemo(()=>readDemoAppointments(),[]);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const [g, r,providerResult,messageResult] = await Promise.all([
        api<GameListResponse>("/games"),
        patient
          ? api<GameResultListResponse>(
              `/games/results?patient_profile_id=${patient.id}&limit=200`,
            )
          : Promise.resolve({ results: [] } as unknown as GameResultListResponse),
        api<ProviderListResponse>("/providers").catch(()=>({success:true,providers:[]})),
        api<ProviderMessageListResponse>("/provider-messages?limit=200").catch(()=>({success:true,total:0,limit:200,offset:0,messages:[]})),
      ]);

      setGames(g.games);
      setResults(r.results);
      setProviders(providerResult.providers);
      setCareMessages(messageResult.messages);
    } catch (err) {
      setError(err instanceof Error ? err.message : t("family.loadError"));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, [patient?.id]);

  const gameName = useMemo(() => {
    const map = new Map(games.map((g) => [g.id, g.name]));
    return (gid: string) => map.get(gid) ?? t("family.exercise");
  }, [games, t]);

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
      .map(([gid, arr]) => {
        const avg = Math.round(arr.reduce((a, b) => a + b, 0) / arr.length);
        return { label: gameName(gid), value: avg, caption: t("family.averageShort", { n: avg }) };
      })
      .sort((a, b) => b.value - a.value);
  }, [results, gameName, t]);

  const recent = useMemo(
    () =>
      [...results]
        .sort((a, b) => +new Date(b.created_at) - +new Date(a.created_at))
        .slice(0, 8),
    [results],
  );

  const nextAppointment=useMemo(()=>appointments.filter(item=>item.patientId===patient?.id&&!["cancelled","completed"].includes(item.appointmentStatus)&&new Date(`${item.date}T${item.time||"00:00"}`)>=new Date()).sort((a,b)=>`${a.date}T${a.time}`.localeCompare(`${b.date}T${b.time}`))[0]||null,[appointments,patient?.id]);
  const latestMessage=useMemo(()=>careMessages.filter(item=>item.patient_profile_id===patient?.id).sort((a,b)=>+(new Date(b.latest_reply_at||b.created_at))-+(new Date(a.latest_reply_at||a.created_at)))[0]||null,[careMessages,patient?.id]);
  const latestProvider=latestMessage?providers.find(provider=>provider.provider_user_id===latestMessage.provider_user_id):undefined;
  const pendingPayment=appointments.some(item=>item.patientId===patient?.id&&item.paymentStatus==="pending");
  const unreadCount=careMessages.filter(item=>item.patient_profile_id===patient?.id).reduce((total,item)=>total+(item.unread_reply_count||0),0);

  const relationship = currentPatientRelationship(patient);

  if (loading||patientLoading) return <Spinner label={t("family.loadView")} />;
  if (error) return <ErrorState message={error} onRetry={load} />;

  return (
    <div className="page family-overview-page">
      <div className="page__head">
        <div>
          <span className="eyebrow">{t("family.overview")}</span>
          <h1>{t("family.welcome", { name: active?.name ?? user?.full_name?.split(" ")[0] ?? t("family.there") })}</h1>
          <p className="page__sub">{active?dc.account:t("family.overviewSub")}</p>
        </div>
      </div>

      {!patient ? (
        <EmptyState message={`${patientCopy.none}. ${patientCopy.noneHelp}`} />
      ) : (
        <>
          <section className="family-welcome-card" aria-label={t("family.heroAria")}>
            <span className="family-welcome-card__mark" aria-hidden="true">♥</span>
            <div>
              <h2>{t("family.heroTitle")}</h2>
              <p>{t("family.heroBody")}</p>
            </div>
          </section>
          {/* Linked patient card */}
          <div className="patient-head">
            <span className="avatar avatar--lg" aria-hidden="true">
              {patientName(patient.user).slice(0, 1)}
            </span>
            <div>
              <h2>{patientName(patient.user)}</h2>
              <p className="patient-head__meta">
                {relationship ? t("family.yourRelationship", { relationship }) : ""}
                {patient.gender ? `${patient.gender} · ` : ""}
                {patient.date_of_birth
                  ? t("family.born", { date: formatDate(patient.date_of_birth) })
                  : t("family.followingJourney")}
              </p>
            </div>
            <div className="patient-head__tags">
              <Badge>{patientCopy.current}: {currentPatientName(patient)}</Badge>
              <Badge tone="gold">{t("family.linkedPatient")}</Badge>
            </div>
          </div>

          {/* Activity summary */}
          <div className="stat-grid">
            <StatCard
              icon="⌁"
              label={t("family.recordedSessions")}
              value={summary.total}
              hint={t("family.cognitiveExercises")}
            />
            <StatCard
              icon="✓"
              label={t("family.completedActivities")}
              value={summary.completed}
              hint={t("family.activityOnly")}
            />
            <StatCard
              icon="☆"
              label={t("family.bestPerformance")}
              value={summary.best != null ? `${summary.best}%` : "—"}
              hint={t("family.performanceOnly")}
            />
            <StatCard
              icon="◷"
              label={t("family.averagePerformance")}
              value={summary.avg != null ? `${summary.avg}%` : "—"}
              hint={t("family.performanceOnly")}
            />
          </div>

          {(nextAppointment||pendingPayment||unreadCount>0)&&<div className="family-dashboard-status" aria-label={dc.quick}>{nextAppointment&&<span>◷ {dc.upcoming}</span>}{pendingPayment&&<span>◉ {dc.payment}</span>}{unreadCount>0&&<span>● {dc.newMessage} <b>{unreadCount}</b></span>}</div>}

          <div className="family-dashboard-highlights">
            <article className="family-dashboard-highlight"><header><span aria-hidden="true">◷</span><h2>{dc.next}</h2></header>{nextAppointment?<><div className="family-dashboard-person"><span className="avatar" aria-hidden="true">{nextAppointment.providerName.slice(0,1)}</span><div><strong>{nextAppointment.providerName}</strong><small>{nextAppointment.providerRole==="therapist"?dc.therapist:dc.doctor}</small></div></div><dl><div><dt>{new Intl.DateTimeFormat(lang,{dateStyle:"medium"}).format(new Date(`${nextAppointment.date}T12:00:00`))}</dt><dd><bdi>{nextAppointment.time}</bdi></dd></div><div><dt>{nextAppointment.type==="remote"?dc.remote:dc.inPerson}</dt><dd>{nextAppointment.paymentStatus==="paid"?dc.paid:dc.pending}</dd></div></dl><Link to="/appointments">{dc.viewAppointment} <span aria-hidden="true">›</span></Link></>:<div className="family-dashboard-empty"><strong>{dc.noAppointment}</strong><p>{dc.noAppointmentHelp}</p><Link to="/appointments">{dc.bookAppointment}</Link></div>}</article>
            <article className="family-dashboard-highlight"><header><span aria-hidden="true">✉</span><h2>{dc.latest}</h2></header>{latestMessage?<><div className="family-dashboard-person"><span className="avatar" aria-hidden="true">{(latestProvider?.full_name||latestMessage.provider_name||"C").slice(0,1)}</span><div><strong>{latestProvider?.full_name||latestMessage.provider_name||dc.latest}</strong><small>{latestProvider?.role==="therapist"?dc.therapist:dc.doctor}</small></div>{(latestMessage.unread_reply_count||0)>0&&<i>{latestMessage.unread_reply_count}</i>}</div><p className="family-dashboard-message">{latestMessage.latest_reply_preview||latestMessage.message}</p><time>{formatDateTime(latestMessage.latest_reply_at||latestMessage.created_at)}</time><Link to="/messages">{dc.viewMessage} <span aria-hidden="true">›</span></Link></>:<div className="family-dashboard-empty"><strong>{dc.noMessages}</strong></div>}</article>
          </div>

          <div className="grid-2">
            {/* Recent activity */}
            <Card>
              <SectionHeader
                eyebrow={t("family.recentActivity")}
                title={t("family.latestSessions")}
              />
              {recent.length === 0 ? (
                <EmptyState message={t("family.noSessions")} />
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
                            {r.completed ? t("common.completed") : t("common.inProgress")}
                          </span>
                        </div>
                      </li>
                    );
                  })}
                </ul>
              )}
            </Card>

            {/* Games performance summary */}
            <Card>
              <SectionHeader eyebrow={t("family.byExercise")} title={t("family.gamesPerformance")} />
              {perGame.length === 0 ? (
                <EmptyState message={t("family.noScored")} />
              ) : (
                <BarList items={perGame} />
              )}
            </Card>
          </div>

          <section className="family-dashboard-quick"><h2>{dc.quick}</h2><div>{[["♥",dc.encouragement,"/encouragement"],["▧",dc.memory,"/memories"],["◷",dc.book,"/appointments"],["✉",dc.message,"/messages"]].map(([icon,label,to])=><Link to={to} key={to}><span aria-hidden="true">{icon}</span><strong>{label}</strong><i aria-hidden="true">›</i></Link>)}</div></section>

        </>
      )}
    </div>
  );
}
