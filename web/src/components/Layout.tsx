import { useEffect, useMemo, useState } from "react";
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

const topbarCopy: Record<Lang, { current: string; patients: string; switchPatient: string }> = {
  en: { current: "Current patient", patients: "Assigned patients", switchPatient: "Switch patient" },
  ar: { current: "المريض الحالي", patients: "المرضى المسندون", switchPatient: "تبديل المريض" },
  fr: { current: "Patient actuel", patients: "Patients assignés", switchPatient: "Changer de patient" },
  es: { current: "Paciente actual", patients: "Pacientes asignados", switchPatient: "Cambiar paciente" },
  de: { current: "Aktueller Patient", patients: "Zugewiesene Patienten", switchPatient: "Patient wechseln" },
};

type NavItem = { to: string; key: TranslationKey; icon: string; end: boolean };

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
  { to: "/admin/access-requests", key: "nav.accessRequests", icon: "✉", end: false },
];

export function Layout() {
  useClinicianPreferences();
  const { user, roles, isClinician, isAdmin, logout } = useAuth();
  const { t, lang } = useI18n();
  const navigate = useNavigate();
  const location = useLocation();
  const [open, setOpen] = useState(false);
  const [patientOpen, setPatientOpen] = useState(false);
  const [patients, setPatients] = useState<PatientProfile[]>([]);
  const [selectedPatientId, setSelectedPatientId] = useState<string | null>(null);
  const [logoFailed, setLogoFailed] = useState(false);
  const isDoctor = roles.includes("doctor");

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
    ...(isAdmin ? ADMIN_NAV : []),
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
            <span className="sidebar__sub">{t("app.subtitle")}</span>
          </div>
        </div>

        <nav className="sidebar__nav" aria-label={t("provider.primaryNavigation")}>
          <span className="sidebar__group">{isClinician ? t("provider.portal") : t("app.subtitle")}</span>
          {navItems.map((item) => (
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
                {item.icon}
              </span>
              {t(item.key)}
            </NavLink>
          ))}
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
          <div className="clinician-topbar-identities family-topbar-identities">
            <div className="topbar__user family-account-profile clinician-account-profile">
              <span className="avatar" aria-hidden="true">{initials(user?.full_name)}</span>
              <div className="topbar__meta">
                <strong>{user?.full_name ?? t("role.clinician")}</strong>
                <span>{isClinician ? `${clinicianRole} · ${t("provider.careProvider")}` : clinicianRole}</span>
              </div>
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
          <div className="clinician-topbar-utilities family-topbar-utilities">
            {isClinician && (
              <NavLink className="family-header-ai clinician-header-ai" to="/ai-companion" title={familyMemberPhotoCopy[lang].openAi} aria-label={familyMemberPhotoCopy[lang].openAi}>
                <img src={neurobridgeAiMascot} alt="" />
              </NavLink>
            )}
            {isClinician && user?.id && <ClinicianNotificationCenter providerUserId={user.id} />}
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
