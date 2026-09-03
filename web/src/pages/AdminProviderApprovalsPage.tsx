import { useCallback, useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { ApiError } from "../api/client";
import { listAccessRequests } from "../api/accessRequests";
import { listAllAdminUsers, setAdminUserActive, type AdminUserSummary } from "../api/adminUsers";
import { useI18n } from "../i18n/useI18n";
import type { AccessRequest } from "../types";

export function AdminProviderApprovalsPage() {
  const { lang } = useI18n();
  const ar = lang === "ar";
  const tx = (a: string, e: string) => ar ? a : e;
  const [providers, setProviders] = useState<AdminUserSummary[]>([]);
  const [requests, setRequests] = useState<AccessRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [busyId, setBusyId] = useState("");
  const [error, setError] = useState("");
  const [query, setQuery] = useState("");
  const [role, setRole] = useState("all");
  const [status, setStatus] = useState("all");

  const load = useCallback(async () => {
    setLoading(true); setError("");
    try {
      const [users, access] = await Promise.all([listAllAdminUsers(), listAccessRequests()]);
      setProviders(users.filter((user) => user.roles.includes("doctor") || user.roles.includes("therapist")));
      setRequests(access.requests.filter((item) => item.requested_role === "doctor" || item.requested_role === "therapist"));
    } catch (err) {
      setError(err instanceof ApiError ? err.message : tx("تعذّر تحميل مقدمي الرعاية.", "Could not load providers."));
    } finally { setLoading(false); }
  }, [ar]);
  useEffect(() => { void load(); }, [load]);

  const requestByEmail = useMemo(() => new Map(requests.map((request) => [request.email.toLowerCase(), request])), [requests]);
  const counts = {
    doctors: providers.filter((item) => item.roles.includes("doctor")).length,
    therapists: providers.filter((item) => item.roles.includes("therapist")).length,
    active: providers.filter((item) => item.status === "active").length,
    pending: requests.filter((item) => item.status === "pending").length,
  };
  const filtered = providers.filter((item) => {
    const matchQuery = !query.trim() || `${item.full_name} ${item.email || ""} ${item.phone || ""}`.toLowerCase().includes(query.trim().toLowerCase());
    const matchRole = role === "all" || item.roles.includes(role);
    const matchStatus = status === "all" || item.status === status;
    return matchQuery && matchRole && matchStatus;
  });

  const toggle = async (provider: AdminUserSummary) => {
    const active = provider.status !== "active";
    setBusyId(provider.id); setError("");
    try { await setAdminUserActive(provider.id, active); await load(); }
    catch (err) { setError(err instanceof ApiError ? err.message : tx("تعذّر تحديث الحساب.", "Could not update account.")); }
    finally { setBusyId(""); }
  };

  const roleLabel = (item: AdminUserSummary) => item.roles.includes("doctor") ? tx("طبيب", "Doctor") : tx("معالج", "Therapist");
  const statusLabel = (value: string) => ({ active: tx("نشط", "Active"), inactive: tx("غير نشط", "Inactive"), suspended: tx("معلّق", "Suspended"), pending: tx("قيد الانتظار", "Pending") }[value] || value);

  return <div className="page admin-page admin-providers-page">
    <header className="admin-module-head"><span className="eyebrow">{tx("إدارة الوصول", "Access management")}</span><h1>{tx("مقدمو الرعاية في NeuroBridge", "NeuroBridge care providers")}</h1><p>{tx("عرض وإدارة جميع الأطباء والمعالجين الذين يصلون إلى المنصة المشتركة.", "View and manage every doctor and therapist accessing the shared platform.")}</p></header>
    {error && <div className="admin-users-notice admin-users-notice--error"><span>{error}</span><button onClick={() => void load()}>{tx("إعادة المحاولة", "Retry")}</button></div>}
    <section className="admin-provider-summary">{[[tx("الأطباء", "Doctors"), counts.doctors, "doctor"], [tx("المعالجون", "Therapists"), counts.therapists, "therapist"], [tx("الحسابات النشطة", "Active accounts"), counts.active, "active"], [tx("بانتظار المراجعة", "Awaiting review"), counts.pending, "pending"]].map(([label, count, tone]) => <article className={`admin-provider-summary__${tone}`} key={String(tone)}><span>{label}</span><strong>{loading ? "…" : count}</strong></article>)}</section>
    <section className="admin-provider-workspace">
      <div className="admin-provider-toolbar"><label><span>{tx("بحث", "Search")}</span><input type="search" value={query} onChange={(event) => setQuery(event.target.value)} placeholder={tx("ابحثي بالاسم أو البريد أو الهاتف", "Search name, email or phone")} /></label><label><span>{tx("الدور", "Role")}</span><select value={role} onChange={(event) => setRole(event.target.value)}><option value="all">{tx("جميع الأدوار", "All roles")}</option><option value="doctor">{tx("الأطباء", "Doctors")}</option><option value="therapist">{tx("المعالجون", "Therapists")}</option></select></label><label><span>{tx("الحالة", "Status")}</span><select value={status} onChange={(event) => setStatus(event.target.value)}><option value="all">{tx("جميع الحالات", "All statuses")}</option><option value="active">{tx("نشط", "Active")}</option><option value="inactive">{tx("غير نشط", "Inactive")}</option><option value="suspended">{tx("معلّق", "Suspended")}</option><option value="pending">{tx("قيد الانتظار", "Pending")}</option></select></label></div>
      {loading ? <div className="admin-module-state">{tx("جارٍ التحميل…", "Loading…")}</div> : filtered.length === 0 ? <div className="admin-module-state">{tx("لا يوجد مقدمو رعاية مطابقون.", "No matching providers.")}</div> : <div className="admin-provider-list">{filtered.map((provider) => { const request = provider.email ? requestByEmail.get(provider.email.toLowerCase()) : undefined; return <article key={provider.id} className="admin-provider-record"><div className="admin-provider-record__identity"><span>{provider.full_name.slice(0, 1).toUpperCase()}</span><div><strong>{provider.full_name}</strong><small>{provider.email || provider.phone || "—"}</small></div></div><div><small>{tx("الدور", "Role")}</small><strong>{roleLabel(provider)}</strong></div><div><small>{tx("حالة الحساب", "Account status")}</small><span className={`admin-provider-state admin-provider-state--${provider.status}`}>{statusLabel(provider.status)}</span></div><div><small>{tx("طلب الوصول", "Access request")}</small><strong>{request ? statusLabel(request.status) : tx("أنشأه الأدمن", "Admin-created")}</strong></div><div className="admin-provider-record__actions">{request?.status === "pending" && <Link className="btn btn--gold btn--sm" to="/admin/access-requests">{tx("مراجعة الطلب", "Review request")}</Link>}<button className="btn btn--ghost btn--sm" disabled={busyId === provider.id || provider.status === "pending"} onClick={() => void toggle(provider)}>{busyId === provider.id ? "…" : provider.status === "active" ? tx("تعطيل", "Deactivate") : tx("تفعيل", "Activate")}</button></div></article>; })}</div>}
    </section>
  </div>;
}
