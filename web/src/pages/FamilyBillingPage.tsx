import { useEffect, useMemo, useState } from "react";
import { webAccountApi } from "../api/webAccountClient";
import { useI18n } from "../i18n/useI18n";
import { FamilyMemberAvatar, useFamilyMembers, type FamilyRelationship } from "../familyMembers";
import { familyBookingCopy } from "../lib/familyBookingCopy";
import type { DemoFamilyAppointment, DemoPaymentStatus } from "../lib/familyBookingDemo";
import type { Provider } from "../types";
import { ReceiptModal } from "./FamilyAppointmentsPage";
import { useCurrentFamilyPatient } from "../currentFamilyPatient";

interface BillingResponse {
  success: boolean;
  providers: Provider[];
  appointments: DemoFamilyAppointment[];
}

export function FamilyBillingPage() {
  const { lang } = useI18n();
  const c = familyBookingCopy[lang];
  const { copy, members } = useFamilyMembers();
  const { patient, loading: patientLoading, copy: patientCopy, name: patientName } = useCurrentFamilyPatient();
  const [items, setItems] = useState<DemoFamilyAppointment[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<"all" | "paid" | "pending" | "refunded">("all");
  const [search, setSearch] = useState("");
  const [receipt, setReceipt] = useState<DemoFamilyAppointment | null>(null);
  const [patientScope, setPatientScope] = useState<"current" | "all">("current");

  const loadPayments = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await webAccountApi<BillingResponse>("family_appointments.php");
      setItems(response.appointments);
    } catch (reason) {
      setItems([]);
      setError(reason instanceof Error ? reason.message : "تعذر تحميل المدفوعات من الخادم");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { void loadPayments(); }, []);
  useEffect(() => {
    const refresh = () => { if (document.visibilityState === "visible") void loadPayments(); };
    window.addEventListener("focus", refresh);
    document.addEventListener("visibilitychange", refresh);
    return () => {
      window.removeEventListener("focus", refresh);
      document.removeEventListener("visibilitychange", refresh);
    };
  }, []);

  const scopedPayments = useMemo(() => items.filter((item) =>
    item.paymentStatus !== "failed" &&
    (patientScope === "all" || item.patientId === patient?.id)
  ), [items, patientScope, patient?.id]);

  const visible = useMemo(() => {
    const query = search.trim().toLocaleLowerCase();
    return scopedPayments.filter((item) =>
      (filter === "all" || item.paymentStatus === filter) &&
      (!query || `${item.providerName} ${item.patientName} ${item.payerName} ${item.bookedByName ?? ""} ${item.receiptReference ?? ""}`
        .toLocaleLowerCase().includes(query))
    );
  }, [scopedPayments, filter, search]);

  const summary = (status: DemoPaymentStatus) => {
    const list = scopedPayments.filter((item) => item.paymentStatus === status);
    return { count: list.length, total: list.reduce((sum, item) => sum + Number(item.amount || 0), 0) };
  };
  const relationship = (value?: string) => value && value in copy.relationships
    ? copy.relationships[value as FamilyRelationship] : value || "";
  const currency = (amount: number, code = "USD") =>
    new Intl.NumberFormat(lang, { style: "currency", currency: code }).format(amount);

  return <div className="page page--wide billing-page">
    <div className="page__head">
      <div><span className="eyebrow">{c.billingEyebrow}</span><h1>{c.billingTitle}</h1><p className="page__sub">{c.billingDescription}</p></div>
      <button className="btn btn--ghost" type="button" onClick={() => void loadPayments()} disabled={loading}>↻ تحديث</button>
    </div>
    {error && <div className="banner banner--warn"><span>{error}</span><button type="button" onClick={() => void loadPayments()}>إعادة المحاولة</button></div>}
    <section className="billing-summary">
      {(["paid", "pending", "refunded"] as DemoPaymentStatus[]).map((status) => {
        const value = summary(status);
        return <article key={status}><span>{c[status]}</span><strong>{currency(value.total)}</strong><small>{value.count}</small></article>;
      })}
    </section>
    <div className="billing-patient-scope">
      <button className={patientScope === "current" ? "is-active" : ""} onClick={() => setPatientScope("current")}>{patientCopy.current}{patient ? `: ${patientName(patient)}` : ""}</button>
      <button className={patientScope === "all" ? "is-active" : ""} onClick={() => setPatientScope("all")}>{patientCopy.all}</button>
    </div>
    <div className="billing-tools">
      <div className="family-appt-tabs">{(["all", "paid", "pending", "refunded"] as const).map((status) =>
        <button className={filter === status ? "is-active" : ""} onClick={() => setFilter(status)} key={status}>{c[status]}</button>
      )}</div>
      <label><span>⌕</span><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder={c.searchPayments}/></label>
    </div>
    {loading || patientLoading
      ? <div className="family-appt-empty"><span>◷</span><p>جاري تحميل المدفوعات…</p></div>
      : visible.length === 0
        ? <div className="family-appt-empty"><p>{c.noPayments}</p></div>
        : <div className="billing-list">
          <div className="billing-list__head"><span>{c.provider}</span><span>{c.appointment}</span><span>{c.patient}</span><span>{c.payer}</span><span>{c.amount}</span><span>{c.status}</span><span>{c.receipt}</span></div>
          {visible.map((item) => <article key={item.id}>
            <div data-label={c.provider}><strong>{item.providerName}</strong><small>{item.providerRole === "therapist" ? c.therapist : c.doctor}</small></div>
            <div data-label={c.appointment}><strong>{new Intl.DateTimeFormat(lang, { dateStyle: "medium" }).format(new Date(`${item.date}T12:00:00`))}</strong><small>{item.time}</small></div>
            <div data-label={c.patient}>{item.patientName}<span className="family-attribution">
              <FamilyMemberAvatar member={members.find((member) => member.id === item.bookedByMemberId || member.name === item.bookedByName) ?? null}/>
              <span><small>{copy.bookedBy}</small><strong>{item.bookedByName || "العائلة"}</strong></span>
            </span></div>
            <div data-label={c.payer}>{item.payerType === "patient" ? <strong>{item.patientName}</strong> : <span className="family-attribution">
              <FamilyMemberAvatar member={members.find((member) => member.id === item.payerMemberId || member.name === item.payerName) ?? null}/>
              <span><strong>{item.payerName || "العائلة"}</strong><small>{relationship(item.payerRelationship || item.relationship)}</small></span>
            </span>}</div>
            <div data-label={c.amount}><strong>{currency(item.amount, item.currency)}</strong><small dir="ltr">{item.maskedMethod || c[item.paymentMethod]}</small></div>
            <div data-label={c.status}><span className={`status-pill status-pill--${item.paymentStatus}`}>{c[item.paymentStatus]}</span></div>
            <div data-label={c.receipt}>{item.receiptReference ? <button type="button" onClick={() => setReceipt(item)}>{c.viewReceipt}</button> : "—"}</div>
          </article>)}
        </div>}
    {receipt && <ReceiptModal item={receipt} c={c} lang={lang} onClose={() => setReceipt(null)}/>}
  </div>;
}
