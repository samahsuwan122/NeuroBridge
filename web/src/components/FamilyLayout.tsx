import { useEffect, useState } from "react";
import { NavLink, Outlet, useLocation, useNavigate } from "react-router-dom";
import { api } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import { initials } from "../lib";
import type { UnreadCountResponse } from "../types";

// Family portal navigation. Every visible item is a working page.
const NAV = [
  { to: "/", label: "Overview", icon: "▚", end: true },
  { to: "/encouragement", label: "Encouragement", icon: "♥", end: false },
  { to: "/appointments", label: "Appointments", icon: "🗓", end: false },
  { to: "/messages", label: "Messages", icon: "💬", end: false },
  { to: "/reports", label: "Reports", icon: "📄", end: false },
];

// In-app unread poll interval (no browser/push notifications — polling only).
const UNREAD_POLL_MS = 30000;

export function FamilyLayout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [open, setOpen] = useState(false);
  const [unread, setUnread] = useState(0);

  // Poll the in-app unread reply count so the Messages badge stays fresh.
  useEffect(() => {
    let active = true;
    const refresh = async () => {
      try {
        const res = await api<UnreadCountResponse>(
          "/provider-messages/unread-count",
        );
        if (active) setUnread(res.unread_count);
      } catch {
        /* best-effort; leave the last known count */
      }
    };
    void refresh();
    const timer = window.setInterval(refresh, UNREAD_POLL_MS);
    return () => {
      active = false;
      window.clearInterval(timer);
    };
    // Re-check when navigating (e.g. right after opening a thread marks it read).
  }, [location.pathname]);

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
              {item.to === "/messages" && unread > 0 && (
                <span className="navitem__badge" aria-label={`${unread} unread`}>
                  {unread}
                </span>
              )}
            </NavLink>
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
