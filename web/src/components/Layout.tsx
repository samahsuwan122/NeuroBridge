import { useState } from "react";
import { NavLink, Outlet, useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import { initials } from "../lib";
import { useI18n } from "../i18n/useI18n";
import { LanguageSwitcher } from "./LanguageSwitcher";
import type { TranslationKey } from "../i18n/translations";
import { useClinicianPreferences } from "../clinicianPreferences";
import doctorCareIllustration from "../assets/doctor-care.png";
import { ClinicianNotificationCenter } from "./ClinicianNotificationCenter";

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
  const { t } = useI18n();
  const navigate = useNavigate();
  const [open, setOpen] = useState(false);
  const [logoFailed, setLogoFailed] = useState(false);
  const isDoctor = roles.includes("doctor");

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
          <div className="topbar__spacer" />
          <LanguageSwitcher />
          {isClinician && user?.id && (
            <ClinicianNotificationCenter providerUserId={user.id} />
          )}
          <div className="topbar__user provider-identity">
            <span className="avatar provider-identity__avatar" aria-hidden="true">
              {initials(user?.full_name)}
            </span>
            <div className="topbar__meta">
              <strong>{user?.full_name ?? t("role.clinician")}</strong>
              <span>{isClinician ? `${clinicianRole} · ${t("provider.careProvider")}` : clinicianRole}</span>
            </div>
            <button className="btn btn--ghost btn--sm" onClick={handleLogout}>
              {t("action.logout")}
            </button>
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
