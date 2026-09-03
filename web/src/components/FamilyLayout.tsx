import { useEffect, useState } from "react";
import { NavLink, Outlet, useLocation, useNavigate } from "react-router-dom";
import { api } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import { initials } from "../lib";
import type { UnreadCountResponse } from "../types";
import { LanguageSwitcher } from "./LanguageSwitcher";
import { useI18n } from "../i18n/useI18n";
import type { TranslationKey } from "../i18n/translations";
import familySupportLine from "../assets/family-support-line-transparent.png";
import neurobridgeAiMascot from "../assets/neurobridge-ai-mascot.png";
import { FamilyMemberAvatar, familyMemberPhotoCopy, useFamilyMembers } from "../familyMembers";
import { LinkPatientDialog,PatientAvatar, useCurrentFamilyPatient } from "../currentFamilyPatient";

// Family portal navigation. Every visible item is a working page.
const NAV = [
  { to: "/", key: "nav.overview", icon: "▚", end: true },
  { to: "/encouragement", key: "family.nav.encouragement", icon: "♥", end: false },
  { to: "/memories", key: "family.nav.memories", icon: "▧", end: false },
  { to: "/appointments", key: "nav.appointments", icon: "🗓", end: false },
  { to: "/messages", key: "family.nav.messages", icon: "💬", end: false },
  { to: "/reports", key: "nav.reports", icon: "📄", end: false },
  { to: "/ai-companion", key: "nav.aiCompanion", icon: "✦", end: false },
  { to: "/settings", key: "family.nav.settings", icon: "⚙", end: false },
] satisfies { to: string; key: TranslationKey; icon: string; end: boolean }[];
const FAMILY_NAV = [...NAV.slice(0, 4), { to: "/billing", key: "family.nav.payments" as TranslationKey, icon: "$", end: false }, ...NAV.slice(4)];

// In-app unread poll interval (no browser/push notifications — polling only).
const UNREAD_POLL_MS = 30000;

export function FamilyLayout() {
  const { t, lang } = useI18n();
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [open, setOpen] = useState(false);
  const [unread, setUnread] = useState(0);
  const [memberOpen, setMemberOpen] = useState(false);
  const [patientOpen,setPatientOpen]=useState(false);
  const [linkPatientOpen,setLinkPatientOpen]=useState(false);
  const { members, active, setActive, copy } = useFamilyMembers();
  const {patients,patient,setPatient,name:patientName,relationship:patientRelationship,copy:patientCopy}=useCurrentFamilyPatient();

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
            <span className="sidebar__sub">{t("family.portal")}</span>
          </div>
        </div>

        <nav className="sidebar__nav" aria-label={t("family.portalGroup")}>
          <span className="sidebar__group">{t("family.portalGroup")}</span>
          {FAMILY_NAV.map((item) => (
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
              {item.to === "/messages" && unread > 0 && (
                <span className="navitem__badge" aria-label={t("family.unread", { n: unread })}>
                  {unread}
                </span>
              )}
            </NavLink>
          ))}
        </nav>

        <div className="sidebar__family-support">
          <div className="sidebar__family-support-art" aria-hidden="true">
            <img src={familySupportLine} alt="" />
          </div>
          <div className="sidebar__family-support-copy">
            <p>{t("family.encouragementSidebarNote")}</p>
          </div>
        </div>
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
          <div className="family-topbar-identities">
          <div className="topbar__user family-account-profile">
            <span className="avatar" aria-hidden="true">{initials(user?.full_name)}</span>
            <div className="topbar__meta">
              <strong>{user?.full_name ?? t("family.member")}</strong>
              <span>{t("family.role")}</span>
            </div>
          </div>
          <div className="family-member-switcher">
            <button className="family-member-chip" type="button" onClick={() => setMemberOpen((value) => !value)} aria-expanded={memberOpen}>
              <FamilyMemberAvatar member={active}/><span><strong>{active?.name ?? copy.who}</strong>{active&&<small>{copy.relationships[active.relationship]}</small>}</span><i aria-hidden="true">⌄</i>
            </button>
            {memberOpen && <div className="family-member-popover"><strong>{copy.who}</strong>{members.map((member) => <button key={member.id} className={active?.id === member.id ? "is-active" : ""} onClick={() => { setActive(member.id); setMemberOpen(false); }}><FamilyMemberAvatar member={member}/><span>{member.name}<small>{copy.relationships[member.relationship]}</small></span>{active?.id === member.id && <b>✓</b>}</button>)}<NavLink to="/settings" onClick={() => setMemberOpen(false)}>+ {copy.add}</NavLink></div>}
          </div>
          <div className="family-patient-switcher">
            <button className="family-patient-chip" type="button" onClick={()=>setPatientOpen(value=>!value)} aria-expanded={patientOpen} aria-label={patientCopy.switchPatient}><PatientAvatar patient={patient}/><span><strong>{patient?patientName(patient):patientCopy.current}</strong>{patient&&<small>{patientRelationship(patient)||patientCopy.current}</small>}</span><i aria-hidden="true">⌄</i></button>
            {patientOpen&&<div className="family-patient-popover"><strong>{patientCopy.supporting}</strong>{patients.map(item=><button key={item.id} className={patient?.id===item.id?"is-active":""} onClick={()=>{setPatient(item.id);setPatientOpen(false)}}><PatientAvatar patient={item}/><span><b>{patientName(item)}</b><small>{patientRelationship(item)||patientCopy.patient}</small></span>{patient?.id===item.id&&<em>✓</em>}</button>)}<button className="family-patient-link" onClick={()=>{setPatientOpen(false);setLinkPatientOpen(true)}}>+ {patientCopy.link}</button></div>}
          </div>
          </div>
          <div className="topbar__spacer" />
          <div className="family-topbar-utilities">
            <NavLink className="family-header-ai" to="/ai-companion" title={familyMemberPhotoCopy[lang].openAi} aria-label={familyMemberPhotoCopy[lang].openAi}><img src={neurobridgeAiMascot} alt="" /></NavLink>
            <LanguageSwitcher />
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
      <LinkPatientDialog open={linkPatientOpen} onClose={()=>setLinkPatientOpen(false)}/>
    </div>
  );
}
