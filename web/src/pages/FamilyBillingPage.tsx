import { useMemo, useState } from "react";
import { useI18n } from "../i18n/useI18n";
import { FamilyMemberAvatar, useFamilyMembers, type FamilyRelationship } from "../familyMembers";
import { familyBookingCopy } from "../lib/familyBookingCopy";
import { readDemoAppointments, type DemoFamilyAppointment, type DemoPaymentStatus } from "../lib/familyBookingDemo";
import { ReceiptModal } from "./FamilyAppointmentsPage";
import { useCurrentFamilyPatient } from "../currentFamilyPatient";

export function FamilyBillingPage(){
  const {lang}=useI18n(); const c=familyBookingCopy[lang]; const {copy,members}=useFamilyMembers();
  const {patient,copy:patientCopy,name:patientName}=useCurrentFamilyPatient();
  const [items]=useState(readDemoAppointments); const [filter,setFilter]=useState<"all"|"paid"|"pending"|"refunded">("all"); const [search,setSearch]=useState(""); const [receipt,setReceipt]=useState<DemoFamilyAppointment|null>(null);
  const [patientScope,setPatientScope]=useState<"current"|"all">("current");
  const payments=useMemo(()=>items.filter(i=>i.paymentStatus!=="failed"),[items]);
  const visible=useMemo(()=>{const q=search.trim().toLowerCase();return payments.filter(i=>(patientScope==="all"||i.patientId===patient?.id)&&(filter==="all"||i.paymentStatus===filter)&&(!q||`${i.providerName} ${i.payerName} ${i.bookedByName||""} ${i.receiptReference||""}`.toLowerCase().includes(q)))},[payments,filter,search,patientScope,patient?.id]);
  const summary=(status:DemoPaymentStatus)=>{const list=payments.filter(i=>i.paymentStatus===status);return{count:list.length,total:list.reduce((n,i)=>n+i.amount,0)}};
  const relationship=(value?:string)=>value&&value in copy.relationships?copy.relationships[value as FamilyRelationship]:value||"";
  return <div className="page page--wide billing-page">
    <div className="page__head"><div><span className="eyebrow">{c.billingEyebrow}</span><h1>{c.billingTitle}</h1><p className="page__sub">{c.billingDescription}</p></div></div>
    <section className="billing-summary">{(["paid","pending","refunded"] as DemoPaymentStatus[]).map(s=>{const value=summary(s);return <article key={s}><span>{c[s]}</span><strong>{new Intl.NumberFormat(lang,{style:"currency",currency:"USD"}).format(value.total)}</strong><small>{value.count}</small></article>})}</section>
    <div className="billing-patient-scope"><button className={patientScope==="current"?"is-active":""} onClick={()=>setPatientScope("current")}>{patientCopy.current}{patient?`: ${patientName(patient)}`:""}</button><button className={patientScope==="all"?"is-active":""} onClick={()=>setPatientScope("all")}>{patientCopy.all}</button></div><div className="billing-tools"><div className="family-appt-tabs">{(["all","paid","pending","refunded"] as const).map(s=><button className={filter===s?"is-active":""} onClick={()=>setFilter(s)} key={s}>{c[s]}</button>)}</div><label><span>⌕</span><input value={search} onChange={e=>setSearch(e.target.value)} placeholder={c.searchPayments}/></label></div>
    {visible.length===0?<div className="family-appt-empty"><p>{c.noPayments}</p></div>:<div className="billing-list"><div className="billing-list__head"><span>{c.provider}</span><span>{c.appointment}</span><span>{c.patient}</span><span>{c.payer}</span><span>{c.amount}</span><span>{c.status}</span><span>{c.receipt}</span></div>{visible.map(i=><article key={i.id}>
      <div data-label={c.provider}><strong>{i.providerName}</strong><small>{i.providerRole==="therapist"?c.therapist:c.doctor}</small></div>
      <div data-label={c.appointment}><strong>{new Intl.DateTimeFormat(lang,{dateStyle:"medium"}).format(new Date(`${i.date}T12:00:00`))}</strong><small>{i.time}</small></div>
      <div data-label={c.patient}>{i.patientName}<span className="family-attribution"><FamilyMemberAvatar member={members.find(member=>member.id===i.bookedByMemberId||member.name===(i.bookedByName||"Omar"))||null}/><span><small>{copy.bookedBy}</small><strong>{i.bookedByName||"Omar"}</strong></span></span></div>
      <div data-label={c.payer}>{i.payerType==="patient"?<strong>{c.patient}</strong>:<span className="family-attribution"><FamilyMemberAvatar member={members.find(member=>member.id===i.payerMemberId||member.name===i.payerName)||null}/><span><strong>{i.payerName}</strong><small>{relationship(i.payerRelationship||i.relationship)}</small></span></span>}</div>
      <div data-label={c.amount}><strong>{new Intl.NumberFormat(lang,{style:"currency",currency:i.currency}).format(i.amount)}</strong><small dir="ltr">{i.maskedMethod||c[i.paymentMethod]}</small></div>
      <div data-label={c.status}><span className={`status-pill status-pill--${i.paymentStatus}`}>{c[i.paymentStatus]}</span></div>
      <div data-label={c.receipt}>{i.receiptReference?<button onClick={()=>setReceipt(i)}>{c.viewReceipt}</button>:"—"}</div>
    </article>)}</div>}
    {receipt&&<ReceiptModal item={receipt} c={c} lang={lang} onClose={()=>setReceipt(null)}/>}
  </div>
}
