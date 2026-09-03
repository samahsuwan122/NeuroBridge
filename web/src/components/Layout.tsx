import { useEffect, useMemo, useRef, useState } from "react";
import { NavLink, Outlet, useLocation, useNavigate } from "react-router-dom";
import { api } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import { initials, patientName } from "../lib";
import { useI18n } from "../i18n/useI18n";
import { LanguageSwitcher } from "./LanguageSwitcher";
import type { Lang, TranslationKey } from "../i18n/translations";
import type { PatientListResponse, PatientProfile } from "../types";
import { useClinicianPreferences } from "../clinicianPreferences";
import doctorCareIllustration from "../assets/doctor-care.png";
import { ClinicianNotificationCenter } from "./ClinicianNotificationCenter";
import neurobridgeAiMascot from "../assets/neurobridge-ai-mascot.png";
import { familyMemberPhotoCopy } from "../familyMembers";
import { listAccessRequests } from "../api/accessRequests";

const topbarCopy: Record<Lang, { current: string; patients: string; switchPatient: string }> = {
  en: { current: "Current patient", patients: "Assigned patients", switchPatient: "Switch patient" },
  ar: { current: "المريض الحالي", patients: "المرضى المسندون", switchPatient: "تبديل المريض" },
  fr: { current: "Patient actuel", patients: "Patients assignés", switchPatient: "Changer de patient" },
  es: { current: "Paciente actual", patients: "Pacientes asignados", switchPatient: "Cambiar paciente" },
  de: { current: "Aktueller Patient", patients: "Zugewiesene Patienten", switchPatient: "Patient wechseln" },
};

type AdminNavIconName = "overview"|"users"|"patient"|"doctor"|"therapist"|"family"|"approval"|"request"|"roles"|"audit"|"settings";
type NavItem = { to: string; key: TranslationKey; icon: string; end: boolean; adminIcon?: AdminNavIconName };

function AdminNavIcon({name}:{name:AdminNavIconName}) {
  return <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
    {name==="overview"&&<><rect x="4" y="4" width="6" height="6"/><rect x="14" y="4" width="6" height="6"/><rect x="4" y="14" width="6" height="6"/><rect x="14" y="14" width="6" height="6"/></>}
    {name==="users"&&<><circle cx="9" cy="8" r="3"/><path d="M3.5 19c.4-4 2.2-6 5.5-6s5.1 2 5.5 6M15 6.2a2.7 2.7 0 0 1 0 5.2M16 13.5c2.6.5 4 2.3 4.3 5.5"/></>}
    {name==="patient"&&<><circle cx="12" cy="7" r="3"/><path d="M6.5 20v-2.5a5.5 5.5 0 0 1 11 0V20M12 12v5M9.5 14.5h5"/></>}
    {name==="doctor"&&<><path d="M7 5h10a2 2 0 0 1 2 2v12H5V7a2 2 0 0 1 2-2ZM9 5V3h6v2M12 9v6M9 12h6"/></>}
    {name==="therapist"&&<><path d="M5 5.5h14v10H9l-4 3v-13ZM9 9h6M9 12h4"/></>}
    {name==="family"&&<><circle cx="8" cy="8" r="2.5"/><circle cx="16" cy="8" r="2.5"/><path d="M3.5 19c.2-3.7 1.8-5.5 4.5-5.5s4.3 1.8 4.5 5.5M11.5 19c.2-3.7 1.8-5.5 4.5-5.5s4.3 1.8 4.5 5.5"/></>}
    {name==="approval"&&<><path d="M12 3 19 6v5c0 4.5-2.6 7.7-7 10-4.4-2.3-7-5.5-7-10V6l7-3Z"/><path d="m9 12 2 2 4-5"/></>}
    {name==="request"&&<><rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 4.5V3h6v1.5M8.5 9h7M8.5 13h7M8.5 17H13"/></>}
    {name==="roles"&&<><circle cx="8" cy="8" r="3"/><path d="M3 19c.5-4 2-6 5-6s4.5 2 5 6M16 5l4 2v3c0 2.5-1.3 4.4-4 6-2.7-1.6-4-3.5-4-6V7l4-2Z"/></>}
    {name==="audit"&&<><path d="M6 3h12v18H6zM9 8h6M9 12h6M9 16h4"/><path d="m16 17 1.3 1.3L20 15.5"/></>}
    {name==="settings"&&<><circle cx="12" cy="12" r="3"/><path d="M19 13.5v-3l-2-.7-.7-1.7.9-1.9-2.1-2.1-1.9.9-1.7-.7-.7-2h-3l-.7 2-1.7.7-1.9-.9-2.1 2.1.9 1.9-.7 1.7-2 .7v3l2 .7.7 1.7-.9 1.9 2.1 2.1 1.9-.9 1.7.7.7 2h3l.7-2 1.7-.7 1.9.9 2.1-2.1-.9-1.9.7-1.7 2-.7Z"/></>}
  </svg>;
}

const CLINICIAN_NAV: NavItem[] = [
  { to: "/", key: "nav.overview", icon: "▚", end: true },
  { to: "/patients", key: "nav.patients", icon: "☰", end: false },
  { to: "/appointments", key: "nav.appointments", icon: "🗓", end: false },
  { to: "/reports", key: "nav.reports", icon: "📄", end: false },
  { to: "/review-queue", key: "nav.reviewQueue", icon: "✦", end: false },
  { to: "/ai-companion", key: "nav.aiCompanion", icon: "✦", end: false },
  { to: "/messages", key: "nav.messages", icon: "✉", end: false },
  { to: "/settings", key: "nav.settings", icon: "⚙", end: false },
];

const ADMIN_NAV: NavItem[] = [
  { to: "/admin", key: "nav.overview", icon: "", adminIcon:"overview", end: true },
];
const ADMIN_USER_NAV: NavItem[] = [
  { to: "/admin/users", key: "admin.nav.allUsers", icon: "", adminIcon:"users", end: true },
  { to: "/admin/users/patients", key: "admin.nav.patients", icon: "", adminIcon:"patient", end: true },
  { to: "/admin/users/doctors", key: "admin.nav.doctors", icon: "", adminIcon:"doctor", end: true },
  { to: "/admin/users/therapists", key: "admin.nav.therapists", icon: "", adminIcon:"therapist", end: true },
  { to: "/admin/users/family", key: "admin.nav.family", icon: "", adminIcon:"family", end: true },
];
const ADMIN_APPROVAL_NAV: NavItem[] = [
  { to: "/admin/provider-approvals", key: "admin.nav.providerApprovals", icon:"", adminIcon:"approval", end:true },
  { to: "/admin/access-requests", key: "nav.accessRequests", icon: "", adminIcon:"request", end: true },
];
const ADMIN_SYSTEM_NAV:NavItem[]=[
  {to:"/admin/roles",key:"admin.nav.roles",icon:"",adminIcon:"roles",end:true},
  {to:"/admin/audit-log",key:"admin.nav.auditLog",icon:"",adminIcon:"audit",end:true},
];
const ADMIN_PREFERENCE_NAV:NavItem[]=[{to:"/admin/settings",key:"admin.nav.settings",icon:"",adminIcon:"settings",end:true}];

function AdminNotificationCenter({ enabled }: { enabled: boolean }) {
  const { t } = useI18n();
  const [open, setOpen] = useState(false);
  const [pending, setPending] = useState(0);
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (!enabled) { setPending(0); return; }
    let active = true;
    listAccessRequests("pending").then((result) => { if (active) setPending(result.total); }).catch(() => { if (active) setPending(0); });
    return () => { active = false; };
  }, [enabled]);
  useEffect(() => {
    if (!open) return;
    const close = (event: MouseEvent) => { if (ref.current && !ref.current.contains(event.target as Node)) setOpen(false); };
    const key = (event: KeyboardEvent) => { if (event.key === "Escape") setOpen(false); };
    document.addEventListener("mousedown", close); document.addEventListener("keydown", key);
    return () => { document.removeEventListener("mousedown", close); document.removeEventListener("keydown", key); };
  }, [open]);
  return <div className="admin-notifications" ref={ref}><button type="button" className="admin-notifications__bell" aria-label={t("admin.notifications.title")} aria-expanded={open} onClick={() => setOpen((value) => !value)}><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true"><path d="M6 9a6 6 0 0 1 12 0c0 7 2.5 7 2.5 7h-17S6 16 6 9Z"/><path d="M10 20h4"/></svg>{enabled && pending > 0 && <span>{pending > 99 ? "99+" : pending}</span>}</button>{open && <section className="admin-notifications__panel"><header><span>{t("admin.notifications.eyebrow")}</span><h2>{t("admin.notifications.title")}</h2></header>{enabled && pending > 0 ? <div className="admin-notifications__item"><i aria-hidden="true"/><p>{t("admin.notifications.pending", { count: pending })}</p><NavLink to="/admin/access-requests" onClick={() => setOpen(false)}>{t("admin.notifications.review")}</NavLink></div> : <div className="admin-notifications__empty">{t("admin.notifications.empty")}</div>}</section>}</div>;
}

export function Layout() {
  const { user, roles, isClinician, isAdmin, logout } = useAuth();
  const { preferences } = useClinicianPreferences(user?.id, roles.includes("doctor"));
  const { t, lang } = useI18n();
  const navigate = useNavigate();
  const location = useLocation();
  const [open, setOpen] = useState(false);
  const [patientOpen, setPatientOpen] = useState(false);
  const [patients, setPatients] = useState<PatientProfile[]>([]);
  const [selectedPatientId, setSelectedPatientId] = useState<string | null>(null);
  const [logoFailed, setLogoFailed] = useState(false);
  const [adminUsersOpen,setAdminUsersOpen]=useState(location.pathname.startsWith("/admin/users"));
  const [adminApprovalsOpen,setAdminApprovalsOpen]=useState(ADMIN_APPROVAL_NAV.some(item=>location.pathname===item.to));
  const [adminSystemOpen,setAdminSystemOpen]=useState(ADMIN_SYSTEM_NAV.some(item=>location.pathname===item.to));
  const isDoctor = roles.includes("doctor");
  const isPureAdmin = isAdmin && !isClinician;
  useEffect(() => {
    if (location.pathname.startsWith("/admin/users")) setAdminUsersOpen(true);
    if (ADMIN_APPROVAL_NAV.some((item) => location.pathname === item.to)) setAdminApprovalsOpen(true);
    if (ADMIN_SYSTEM_NAV.some((item) => location.pathname === item.to)) setAdminSystemOpen(true);
  }, [location.pathname]);

  useEffect(() => {
    if (!isClinician) return;
    let active = true;
    api<PatientListResponse>("/patients?limit=200")
      .then((result) => { if (active) setPatients(result.patients); })
      .catch(() => { if (active) setPatients([]); });
    return () => { active = false; };
  }, [isClinician]);

  const routePatientId = /^\/patients\/([^/]+)/.exec(location.pathname)?.[1];
  const selectedPatient = useMemo(
    () => patients.find((patient) => patient.id === routePatientId) ?? patients.find((patient) => patient.id === selectedPatientId) ?? patients[0],
    [patients, routePatientId, selectedPatientId],
  );
  const choosePatient = (patient: PatientProfile) => {
    setSelectedPatientId(patient.id);
    setPatientOpen(false);
    navigate(`/patients/${patient.id}`);
  };

  const handleLogout = () => {
    logout();
    navigate("/login", { replace: true });
  };

  // Show clinician items only to clinicians and the admin item only to admins,
  // so a pure admin sees just Access Requests.
  const navItems: NavItem[] = [
    ...(isClinician ? CLINICIAN_NAV : []),
    ...(isAdmin ? [...ADMIN_NAV, ...ADMIN_APPROVAL_NAV] : []),
  ];

  const clinicianRole = roles.includes("doctor")
    ? t("role.doctor")
    : roles.includes("therapist")
      ? t("role.therapist")
      : isAdmin
        ? t("role.admin")
        : t("role.clinician");

  return (
    <div className={`shell provider-shell ${isClinician ? "provider-shell--clinician" : "provider-shell--admin"}`}>
      <aside className={`sidebar provider-sidebar ${open ? "sidebar--open" : ""}`}>
        <div className="sidebar__brand">
          <span
            className={`brand-mark brand-mark--logo ${logoFailed ? "brand-mark--fallback" : ""}`}
            aria-hidden="true"
          >
            {logoFailed ? (
              "NB"
            ) : (
              <img
                className="brand-mark__img"
                src="/neurobridge-logo-mark.png"
                alt=""
                onError={() => setLogoFailed(true)}
              />
            )}
          </span>
          <div>
            <strong>
              NeuroBridge
            </strong>
            <span className="sidebar__sub">
              {isPureAdmin ? t("admin.portal") : t("app.subtitle")}
            </span>
          </div>
        </div>

        <nav
          className="sidebar__nav"
          aria-label={
            isPureAdmin ? t("admin.primaryNavigation") : t("provider.primaryNavigation")
          }
        >
          {!isPureAdmin && <span className="sidebar__group">{t("provider.portal")}</span>}
          {(isPureAdmin ? ADMIN_NAV : navItems).map((item) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.end}
              className={({ isActive }) =>
                `navitem ${isActive ? "navitem--active" : ""}`
              }
              onClick={() => setOpen(false)}
            >
              <span className="navitem__icon" aria-hidden="true">
                {isPureAdmin && item.adminIcon ? <AdminNavIcon name={item.adminIcon}/> : item.icon}
              </span>
              {t(item.key)}
            </NavLink>
          ))}
          {isPureAdmin && <>
            <button className={`admin-nav-group-toggle ${adminUsersOpen ? "is-current" : ""}`} type="button" aria-expanded={adminUsersOpen} onClick={()=>setAdminUsersOpen(value=>!value)}>
              <span className="navitem__icon" aria-hidden="true"><AdminNavIcon name="users"/></span>
              <span>{t("admin.nav.users")}</span>
              <svg className="admin-nav-chevron" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.7" aria-hidden="true"><path d="m3.5 5.5 4.5 4.5 4.5-4.5"/></svg>
            </button>
            <div className={`admin-nav-children ${adminUsersOpen?"is-open":""}`} hidden={!adminUsersOpen}>
              {ADMIN_USER_NAV.map(item=><NavLink key={item.to} to={item.to} end={item.end} className={({isActive})=>`navitem ${isActive?"navitem--active":""}`} onClick={()=>setOpen(false)}><span className="navitem__icon" aria-hidden="true"><AdminNavIcon name={item.adminIcon!}/></span>{t(item.key)}</NavLink>)}
            </div>
            <button className={`admin-nav-group-toggle ${adminApprovalsOpen ? "is-current" : ""}`} type="button" aria-expanded={adminApprovalsOpen} onClick={()=>setAdminApprovalsOpen(value=>!value)}>
              <span className="navitem__icon" aria-hidden="true"><AdminNavIcon name="approval"/></span>
              <span>{t("admin.approvals")}</span>
              <svg className="admin-nav-chevron" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.7" aria-hidden="true"><path d="m3.5 5.5 4.5 4.5 4.5-4.5"/></svg>
            </button>
            <div className={`admin-nav-children ${adminApprovalsOpen?"is-open":""}`} hidden={!adminApprovalsOpen}>
              {ADMIN_APPROVAL_NAV.map(item=><NavLink key={item.to} to={item.to} end={item.end} className={({isActive})=>`navitem ${isActive?"navitem--active":""}`} onClick={()=>setOpen(false)}><span className="navitem__icon" aria-hidden="true"><AdminNavIcon name={item.adminIcon!}/></span>{t(item.key)}</NavLink>)}
            </div>
            <button className={`admin-nav-group-toggle ${adminSystemOpen ? "is-current" : ""}`} type="button" aria-expanded={adminSystemOpen} onClick={()=>setAdminSystemOpen(value=>!value)}>
              <span className="navitem__icon" aria-hidden="true"><AdminNavIcon name="roles"/></span>
              <span>{t("admin.nav.system")}</span>
              <svg className="admin-nav-chevron" viewBox="0 0 16 16" fill="none" stroke="currentColor" strokeWidth="1.7" aria-hidden="true"><path d="m3.5 5.5 4.5 4.5 4.5-4.5"/></svg>
            </button>
            <div className={`admin-nav-children ${adminSystemOpen?"is-open":""}`} hidden={!adminSystemOpen}>
              {ADMIN_SYSTEM_NAV.map(item=><NavLink key={item.to} to={item.to} end={item.end} className={({isActive})=>`navitem ${isActive?"navitem--active":""}`} onClick={()=>setOpen(false)}><span className="navitem__icon" aria-hidden="true"><AdminNavIcon name={item.adminIcon!}/></span>{t(item.key)}</NavLink>)}
            </div>
            {ADMIN_PREFERENCE_NAV.map(item=><NavLink key={item.to} to={item.to} end={item.end} className={({isActive})=>`navitem admin-nav-settings ${isActive?"navitem--active":""}`} onClick={()=>setOpen(false)}><span className="navitem__icon" aria-hidden="true"><AdminNavIcon name={item.adminIcon!}/></span>{t(item.key)}</NavLink>)}
          </>}
        </nav>

        {isDoctor && (
          <div className="doctor-sidebar-care-block">
            <img
              className="doctor-sidebar-care-illustration"
              src={doctorCareIllustration}
              alt=""
              aria-hidden="true"
            />
            <div className="doctor-sidebar-care-divider" aria-hidden="true" />
            <p className="doctor-sidebar-care-message">{t("doctor.sidebarCareMessage")}</p>
          </div>
        )}
      </aside>

      <div className="main">
        <header className="topbar provider-topbar">
          <button
            className="topbar__burger"
            aria-label={t("nav.toggle")}
            onClick={() => setOpen((v) => !v)}
          >
            ☰
          </button>
          <div
            className={
              isPureAdmin
                ? "admin-topbar-identities"
                : "clinician-topbar-identities family-topbar-identities"
            }
          >
            <div
              className={
                isPureAdmin
                  ? "topbar__user admin-account-profile"
                  : "topbar__user family-account-profile clinician-account-profile"
              }
            >
              <span className="avatar" aria-hidden="true">{isPureAdmin && user?.full_name === "Demo Admin" ? "A" : initials(user?.full_name)}</span>
              <div className="topbar__meta">
                <strong>{isPureAdmin && user?.full_name === "Demo Admin" ? "Admin" : user?.full_name ?? t("role.clinician")}</strong>
                <span>{isClinician ? `${clinicianRole} · ${t("provider.careProvider")}` : t("admin.platformAdministrator")}</span>
              </div>
              {isPureAdmin && <svg className="admin-account-profile__shield" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" aria-hidden="true"><path d="M12 3 19 6v5c0 4.5-2.6 7.7-7 10-4.4-2.3-7-5.5-7-10V6l7-3Z"/><path d="m9 12 2 2 4-5"/></svg>}
            </div>
            {isClinician && selectedPatient && (
              <div className="family-patient-switcher clinician-patient-switcher">
                <button className="family-patient-chip" type="button" onClick={() => setPatientOpen((value) => !value)} aria-expanded={patientOpen} aria-label={topbarCopy[lang].switchPatient}>
                  <span className="patient-context-avatar" aria-hidden="true">{initials(patientName(selectedPatient.user))}</span>
                  <span><strong>{patientName(selectedPatient.user)}</strong><small>{topbarCopy[lang].current}</small></span>
                  <i aria-hidden="true">⌄</i>
                </button>
                {patientOpen && (
                  <div className="family-patient-popover clinician-patient-popover">
                    <strong>{topbarCopy[lang].patients}</strong>
                    {patients.map((patient) => (
                      <button type="button" key={patient.id} className={selectedPatient.id === patient.id ? "is-active" : ""} onClick={() => choosePatient(patient)}>
                        <span className="patient-context-avatar" aria-hidden="true">{initials(patientName(patient.user))}</span>
                        <span><b>{patientName(patient.user)}</b><small>{topbarCopy[lang].current}</small></span>
                        {selectedPatient.id === patient.id && <em>✓</em>}
                      </button>
                    ))}
                  </div>
                )}
              </div>
            )}
          </div>
          <div className="topbar__spacer" />
          <div
            className={
              isPureAdmin
                ? "admin-topbar-utilities"
                : "clinician-topbar-utilities family-topbar-utilities"
            }
          >
            {isClinician && (
              <NavLink className="family-header-ai clinician-header-ai" to="/ai-companion" title={familyMemberPhotoCopy[lang].openAi} aria-label={familyMemberPhotoCopy[lang].openAi}>
                <img src={neurobridgeAiMascot} alt="" />
              </NavLink>
            )}
            {isClinician && user?.id && <ClinicianNotificationCenter providerUserId={user.id} />}
            {isPureAdmin && <AdminNotificationCenter enabled={preferences.accessRequestNotifications} />}
            <LanguageSwitcher />
            <button className="btn btn--ghost btn--sm" onClick={handleLogout}>{t("action.logout")}</button>
          </div>
        </header>

        <main className="content">
          <Outlet />
        </main>
      </div>

      {open && (
        <button
          className="scrim"
          aria-label={t("nav.close")}
          onClick={() => setOpen(false)}
        />
      )}
    </div>
  );
}
