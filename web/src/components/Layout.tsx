import { useState } from "react";
import { NavLink, Outlet, useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import { initials } from "../lib";
import { useI18n } from "../i18n/useI18n";
import { LanguageSwitcher } from "./LanguageSwitcher";
import type { TranslationKey } from "../i18n/translations";

const NAV: { to: string; key: TranslationKey; icon: string; end: boolean }[] = [
  { to: "/", key: "nav.overview", icon: "▚", end: true },
  { to: "/patients", key: "nav.patients", icon: "☰", end: false },
  { to: "/appointments", key: "nav.appointments", icon: "🗓", end: false },
  { to: "/reports", key: "nav.reports", icon: "📄", end: false },
  { to: "/review-queue", key: "nav.reviewQueue", icon: "✦", end: false },
];

export function Layout() {
  const { user, roles, logout } = useAuth();
  const { t } = useI18n();
  const navigate = useNavigate();
  const [open, setOpen] = useState(false);
  const [logoFailed, setLogoFailed] = useState(false);

  const handleLogout = () => {
    logout();
    navigate("/login", { replace: true });
  };

  const clinicianRole = roles.includes("doctor")
    ? t("role.doctor")
    : roles.includes("therapist")
      ? t("role.therapist")
      : t("role.clinician");

  return (
    <div className="shell">
      <aside className={`sidebar ${open ? "sidebar--open" : ""}`}>
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

        <nav className="sidebar__nav" aria-label="Primary">
          <span className="sidebar__group">{t("app.subtitle")}</span>
          {NAV.map((item) => (
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
      </aside>

      <div className="main">
        <header className="topbar">
          <button
            className="topbar__burger"
            aria-label={t("nav.toggle")}
            onClick={() => setOpen((v) => !v)}
          >
            ☰
          </button>
          <div className="topbar__spacer" />
          <LanguageSwitcher />
          <div className="topbar__user">
            <div className="topbar__meta">
              <strong>{user?.full_name ?? t("role.clinician")}</strong>
              <span>{clinicianRole}</span>
            </div>
            <span className="avatar" aria-hidden="true">
              {initials(user?.full_name)}
            </span>
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
