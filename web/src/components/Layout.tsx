import { useState } from "react";
import { NavLink, Outlet, useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import { initials } from "../lib";

const NAV = [
  { to: "/", label: "Overview", icon: "▚", end: true },
  { to: "/patients", label: "Patients", icon: "☰", end: false },
  { to: "/appointments", label: "Appointments", icon: "🗓", end: false },
];

// Roadmap items are shown but disabled.
const NAV_SOON = [
  { label: "Reports", icon: "📄" },
  { label: "AI review queue", icon: "✦" },
];

export function Layout() {
  const { user, roles, logout } = useAuth();
  const navigate = useNavigate();
  const [open, setOpen] = useState(false);

  const handleLogout = () => {
    logout();
    navigate("/login", { replace: true });
  };

  const clinicianRole = roles.includes("doctor")
    ? "Doctor"
    : roles.includes("therapist")
      ? "Therapist"
      : "Clinician";

  return (
    <div className="shell">
      <aside className={`sidebar ${open ? "sidebar--open" : ""}`}>
        <div className="sidebar__brand">
          <span className="brand-mark" aria-hidden="true">
            NB
          </span>
          <div>
            <strong>
              NeuroBridge
            </strong>
            <span className="sidebar__sub">Clinical Dashboard</span>
          </div>
        </div>

        <nav className="sidebar__nav" aria-label="Primary">
          <span className="sidebar__group">Portal</span>
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
              {item.label}
            </NavLink>
          ))}

          <span className="sidebar__group">Coming next</span>
          {NAV_SOON.map((item) => (
            <span className="navitem navitem--soon" key={item.label}>
              <span className="navitem__icon" aria-hidden="true">
                {item.icon}
              </span>
              {item.label}
              <span className="navitem__tag">Soon</span>
            </span>
          ))}
        </nav>

        <div className="sidebar__foot">
          <p>Supportive, non-diagnostic clinical review.</p>
        </div>
      </aside>

      <div className="main">
        <header className="topbar">
          <button
            className="topbar__burger"
            aria-label="Toggle navigation"
            onClick={() => setOpen((v) => !v)}
          >
            ☰
          </button>
          <div className="topbar__spacer" />
          <div className="topbar__user">
            <div className="topbar__meta">
              <strong>{user?.full_name ?? "Clinician"}</strong>
              <span>{clinicianRole}</span>
            </div>
            <span className="avatar" aria-hidden="true">
              {initials(user?.full_name)}
            </span>
            <button className="btn btn--ghost btn--sm" onClick={handleLogout}>
              Log out
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
          aria-label="Close navigation"
          onClick={() => setOpen(false)}
        />
      )}
    </div>
  );
}
