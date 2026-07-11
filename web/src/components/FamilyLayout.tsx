import { useState } from "react";
import { NavLink, Outlet, useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import { initials } from "../lib";

// Family portal navigation. The overview is the single foundation screen;
// roadmap items are shown disabled so nothing is faked.
const NAV_SOON = [
  { label: "Encouragement", icon: "♥" },
  { label: "Appointments", icon: "🗓" },
  { label: "Reports", icon: "📄" },
];

export function FamilyLayout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [open, setOpen] = useState(false);

  const handleLogout = () => {
    logout();
    navigate("/login", { replace: true });
  };

  return (
    <div className="shell">
      <aside className={`sidebar ${open ? "sidebar--open" : ""}`}>
        <div className="sidebar__brand">
          <span className="brand-mark" aria-hidden="true">
            NB
          </span>
          <div>
            <strong>NeuroBridge</strong>
            <span className="sidebar__sub">Family &amp; Caregiver</span>
          </div>
        </div>

        <nav className="sidebar__nav" aria-label="Primary">
          <span className="sidebar__group">Portal</span>
          <NavLink
            to="/"
            end
            className={({ isActive }) =>
              `navitem ${isActive ? "navitem--active" : ""}`
            }
            onClick={() => setOpen(false)}
          >
            <span className="navitem__icon" aria-hidden="true">
              ▚
            </span>
            Overview
          </NavLink>

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
          <p>A supportive view of your family member&apos;s journey.</p>
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
              <strong>{user?.full_name ?? "Family member"}</strong>
              <span>Family / Caregiver</span>
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
