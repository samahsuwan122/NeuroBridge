import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { useParams } from "react-router-dom";
import { ApiError } from "../api/client";
import { createAdminUser, listAdminRoles, listAdminUsers, setAdminUserActive, updateAdminUser, type AdminRole, type AdminUserCreate, type AdminUserSummary } from "../api/adminUsers";
import { useAuth } from "../auth/AuthContext";
import { useI18n } from "../i18n/useI18n";
import type { TranslationKey } from "../i18n/translations";
import { formatDateTime, initials } from "../lib";

type Role = "patient" | "doctor" | "therapist" | "family" | "admin";
const ROLES: Role[] = ["patient", "doctor", "therapist", "family", "admin"];
const ROLE_KEYS: Record<string, TranslationKey> = { patient:"admin.users.patientRole", doctor:"role.doctor", therapist:"role.therapist", family:"admin.users.familyRole", admin:"role.admin", manager:"admin.roles.manager" };
const ROUTE_ROLES: Record<string, Role> = { patients:"patient", doctors:"doctor", therapists:"therapist", family:"family" };
const TITLE_KEYS: Record<string, TranslationKey> = { patients:"admin.users.patientsTitle", doctors:"admin.users.doctorsTitle", therapists:"admin.users.therapistsTitle", family:"admin.users.familyTitle" };

async function loadAllUsers() {
  const first = await listAdminUsers(200, 0);
  const pages = [first];
  for (let offset = first.limit; offset < first.total; offset += first.limit) pages.push(await listAdminUsers(200, offset));
  if (pages.some(page => page.total !== first.total)) throw new Error("Admin user total changed during pagination");
  const users = [...new Map(pages.flatMap(page => page.users).map(user => [user.id, user])).values()];
  if (users.length !== first.total) throw new Error("Incomplete Admin user listing");
  return users;
}

function statusKey(status:string):TranslationKey {
  return status === "active" ? "admin.users.active" : status === "inactive" ? "admin.users.inactive" : "admin.users.suspended";
}

export function AdminUsersPage() {
  const { section } = useParams();
  const routeRole = section ? ROUTE_ROLES[section] : undefined;
  const { isAdmin, user: currentUser } = useAuth();
  const { t } = useI18n();
  const [users,setUsers]=useState<AdminUserSummary[]>([]),[roles,setRoles]=useState<AdminRole[]>([]);
  const [loading,setLoading]=useState(true),[error,setError]=useState(""),[query,setQuery]=useState(""),[role,setRole]=useState<Role|"all">(routeRole||"all"),[status,setStatus]=useState("all");
  const [selected,setSelected]=useState<AdminUserSummary|null>(null),[editing,setEditing]=useState(false),[menu,setMenu]=useState<string|null>(null),[busy,setBusy]=useState(false),[notice,setNotice]=useState("");
  const [confirm,setConfirm]=useState<AdminUserSummary|null>(null);
  const [creating,setCreating]=useState(false);
  const menuRef=useRef<HTMLDivElement|null>(null);
  const load=useCallback(async()=>{setLoading(true);setError("");try{const [items,availableRoles]=await Promise.all([loadAllUsers(),listAdminRoles()]);setUsers(items);setRoles(availableRoles)}catch(e){setError(e instanceof ApiError?e.message:t("admin.users.loadError"))}finally{setLoading(false)}},[t]);
  useEffect(()=>{if(isAdmin)void load()},[isAdmin,load]);
  useEffect(()=>{setRole(routeRole||"all")},[routeRole]);
  useEffect(()=>{const close=(event:MouseEvent)=>{if(!menuRef.current?.contains(event.target as Node))setMenu(null)};document.addEventListener("mousedown",close);return()=>document.removeEventListener("mousedown",close)},[]);
  const counts=useMemo(()=>Object.fromEntries(["total",...ROLES].map(key=>[key,key==="total"?users.length:users.filter(user=>user.roles.includes(key)).length])) as Record<"total"|Role,number>,[users]);
  const visible=useMemo(()=>users.filter(user=>(!routeRole||user.roles.includes(routeRole))&&(role==="all"||user.roles.includes(role))&&(status==="all"||user.status===status)&&(!query.trim()||`${user.full_name} ${user.email||""}`.toLocaleLowerCase().includes(query.trim().toLocaleLowerCase()))),[users,routeRole,role,status,query]);
  const mutateStatus=async(user:AdminUserSummary,active:boolean)=>{setBusy(true);setError("");try{await setAdminUserActive(user.id,active);setNotice(t(active?"admin.users.activated":"admin.users.deactivated"));setConfirm(null);setSelected(null);await load()}catch(e){setError(e instanceof ApiError?e.message:t("admin.users.actionError"))}finally{setBusy(false)}};
  if(!isAdmin)return null;
  const title=section&&TITLE_KEYS[section]?t(TITLE_KEYS[section]):t("admin.users.allTitle");
  return <div className="page admin-page admin-users-page">
    <header className="admin-users-head"><div><span className="eyebrow">{t("admin.users.eyebrow")}</span><h1>{title}</h1><p>{t("admin.users.subtitle")}</p></div>{!section&&<button className="btn btn--gold" type="button" onClick={()=>setCreating(true)}>{t("admin.users.createUser")}</button>}</header>
    {notice&&<div className="admin-users-notice" role="status">{notice}<button type="button" onClick={()=>setNotice("")} aria-label={t("common.close")}>×</button></div>}
    {error&&<div className="admin-users-notice admin-users-notice--error" role="alert"><span>{error}</span><button type="button" onClick={()=>void load()}>{t("common.retry")}</button></div>}
    <section className="admin-users-summary" aria-label={t("admin.users.summary")}>{(["total",...ROLES] as const).map(key=><div key={key}><span>{t(key==="total"?"admin.accounts.total":ROLE_KEYS[key])}</span><strong>{loading?"…":counts[key]}</strong></div>)}</section>
    <section className="admin-users-workspace">
      <div className={`admin-users-toolbar ${routeRole ? "admin-users-toolbar--role" : ""}`}>
        <label className="admin-users-search"><span>{t("admin.users.search")}</span><input value={query} onChange={e=>setQuery(e.target.value)} placeholder={t("admin.users.searchPlaceholder")}/></label>
        {!routeRole&&<label><span>{t("admin.users.roleFilter")}</span><select value={role} onChange={e=>setRole(e.target.value as Role|"all")}><option value="all">{t("admin.users.allRoles")}</option>{ROLES.map(item=><option key={item} value={item}>{t(ROLE_KEYS[item])}</option>)}</select></label>}
        <label><span>{t("admin.users.statusFilter")}</span><select value={status} onChange={e=>setStatus(e.target.value)}><option value="all">{t("admin.users.allStatuses")}</option>{["active","inactive","suspended"].map(item=><option key={item} value={item}>{t(statusKey(item))}</option>)}</select></label>
        <span className="admin-users-result-count"><b>{visible.length}</b><span>{t(visible.length === 1 ? "admin.users.result" : "admin.users.results")}</span></span>
      </div>
      {loading?<div className="admin-users-state">{t("common.loading")}</div>:!users.length?<div className="admin-users-state"><strong>{t("admin.users.empty")}</strong></div>:!visible.length?<div className="admin-users-state"><strong>{t("admin.users.noMatches")}</strong><span>{t("admin.users.noMatchesHelp")}</span></div>:
      <div className="admin-users-table"><div className="admin-users-table__head"><span>{t("admin.users.user")}</span><span>{t("admin.users.roles")}</span><span>{t("admin.users.status")}</span><span>{t("admin.users.language")}</span><span>{t("admin.users.joined")}</span><span>{t("admin.users.actions")}</span></div><ul>{visible.map(user=><li key={user.id}>
        <div className="admin-users-person"><i>{initials(user.full_name)}</i><span><strong>{user.full_name}</strong><small>{user.email||user.phone||"—"}</small></span></div>
        <div data-label={t("admin.users.roles")} className="admin-users-roles">{user.roles.map(item=><span key={item}>{t(ROLE_KEYS[item as Role]||"role.clinician")}</span>)}</div>
        <div data-label={t("admin.users.status")}><span className={`admin-user-status admin-user-status--${user.status}`}>{t(statusKey(user.status))}</span></div>
        <div data-label={t("admin.users.language")} className="admin-users-language">{user.preferred_language.toUpperCase()}</div>
        <time data-label={t("admin.users.joined")} dateTime={user.created_at}>{formatDateTime(user.created_at)}</time>
        <div className="admin-user-actions" ref={menu===user.id?menuRef:undefined}><button type="button" onClick={()=>setMenu(menu===user.id?null:user.id)} aria-label={t("admin.users.actions")} aria-expanded={menu===user.id}>•••</button>{menu===user.id&&<div className="admin-user-menu"><button type="button" onClick={()=>{setSelected(user);setEditing(false);setMenu(null)}}>{t("admin.users.viewDetails")}</button><button type="button" onClick={()=>{setSelected(user);setEditing(true);setMenu(null)}}>{t("admin.users.edit")}</button>{user.id!==currentUser?.id&&<button type="button" onClick={()=>{user.status==="active"?setConfirm(user):void mutateStatus(user,true);setMenu(null)}}>{t(user.status==="active"?"admin.users.deactivate":"admin.users.activate")}</button>}</div>}</div>
      </li>)}</ul></div>}
    </section>
    {selected&&<UserDialog user={selected} editing={editing} roles={roles} busy={busy} onClose={()=>setSelected(null)} onEdit={()=>setEditing(true)} onSave={async payload=>{setBusy(true);setError("");try{await updateAdminUser(selected.id,payload);setNotice(t("admin.users.updated"));setSelected(null);await load()}catch(e){setError(e instanceof ApiError?e.message:t("admin.users.actionError"))}finally{setBusy(false)}}}/>}
    {creating&&<CreateUserDialog roles={roles} busy={busy} onClose={()=>setCreating(false)} onCreate={async payload=>{setBusy(true);setError("");try{await createAdminUser(payload);setNotice(t("admin.users.createdSuccess"));setCreating(false);await load()}catch(e){setError(e instanceof ApiError?e.message:t("admin.users.createError"))}finally{setBusy(false)}}}/>}
    {confirm&&<div className="admin-modal-backdrop"><div className="admin-confirm" role="dialog" aria-modal="true"><span className="eyebrow">{t("admin.users.confirmAction")}</span><h2>{t("admin.users.deactivateTitle")}</h2><p>{t("admin.users.deactivateWarning")}</p><div><strong>{confirm.full_name}</strong><small>{confirm.email||confirm.phone}</small><span>{confirm.roles.map(r=>t(ROLE_KEYS[r as Role]||"role.clinician")).join(", ")}</span></div><footer><button className="btn btn--ghost" type="button" disabled={busy} onClick={()=>setConfirm(null)}>{t("common.cancel")}</button><button className="btn admin-danger-btn" type="button" disabled={busy} onClick={()=>void mutateStatus(confirm,false)}>{busy?t("common.loading"):t("admin.users.deactivate")}</button></footer></div></div>}
  </div>;
}

function CreateUserDialog({roles,busy,onClose,onCreate}:{roles:AdminRole[];busy:boolean;onClose:()=>void;onCreate:(payload:AdminUserCreate)=>Promise<void>}){
  const {t}=useI18n();
  const [error,setError]=useState("");
  const [form,setForm]=useState<AdminUserCreate>({full_name:"",email:"",phone:"",password:"",preferred_language:"en",status:"active",medical_center_id:"",roles:[]});
  const set=<K extends keyof AdminUserCreate>(key:K,value:AdminUserCreate[K])=>setForm(current=>({...current,[key]:value}));
  const submit=(event:React.FormEvent)=>{event.preventDefault();setError("");if(!form.email?.trim()&&!form.phone?.trim()){setError(t("admin.users.identifierRequired"));return}if(form.password.length<8){setError(t("admin.users.passwordLength"));return}void onCreate({...form,full_name:form.full_name.trim(),email:form.email?.trim()||null,phone:form.phone?.trim()||null,medical_center_id:form.medical_center_id?.trim()||null})};
  return <div className="admin-modal-backdrop" onMouseDown={event=>{if(event.target===event.currentTarget&&!busy)onClose()}}><div className="admin-user-dialog admin-create-user" role="dialog" aria-modal="true"><header><div><span className="eyebrow">{t("admin.users.createAccount")}</span><h2>{t("admin.users.createUser")}</h2></div><button type="button" disabled={busy} onClick={onClose} aria-label={t("common.close")}>×</button></header><form onSubmit={submit}>{error&&<div className="admin-create-user__error" role="alert">{error}</div>}<label>{t("admin.users.fullName")}<input required maxLength={255} value={form.full_name} onChange={e=>set("full_name",e.target.value)}/></label><label>{t("admin.users.email")}<input type="email" maxLength={255} value={form.email||""} onChange={e=>set("email",e.target.value)}/></label><label>{t("admin.users.phone")}<input maxLength={50} value={form.phone||""} onChange={e=>set("phone",e.target.value)}/></label><label>{t("admin.users.password")}<input required type="password" minLength={8} maxLength={128} value={form.password} onChange={e=>set("password",e.target.value)}/><small>{t("admin.users.passwordHelp")}</small></label><label>{t("admin.users.language")}<select value={form.preferred_language} onChange={e=>set("preferred_language",e.target.value)}>{["en","ar","fr","es","de"].map(item=><option key={item} value={item}>{item.toUpperCase()}</option>)}</select></label><label>{t("admin.users.status")}<select value={form.status} onChange={e=>set("status",e.target.value)}>{["active","inactive","suspended"].map(item=><option key={item} value={item}>{t(statusKey(item))}</option>)}</select></label><label className="admin-create-user__center">{t("admin.users.medicalCenter")}<input value={form.medical_center_id||""} onChange={e=>set("medical_center_id",e.target.value)} placeholder={t("admin.users.optionalUuid")}/></label><fieldset><legend>{t("admin.users.roles")}</legend>{roles.map(item=><label key={item.id}><input type="checkbox" checked={form.roles.includes(item.name)} onChange={e=>set("roles",e.target.checked?[...form.roles,item.name]:form.roles.filter(role=>role!==item.name))}/>{t(ROLE_KEYS[item.name as Role]||"role.clinician")}</label>)}</fieldset><footer><button className="btn btn--ghost" type="button" disabled={busy} onClick={onClose}>{t("common.cancel")}</button><button className="btn btn--gold" disabled={busy}>{busy?t("common.loading"):t("admin.users.createAccount")}</button></footer></form></div></div>;
}

function UserDialog({user,editing,roles,busy,onClose,onEdit,onSave}:{user:AdminUserSummary;editing:boolean;roles:AdminRole[];busy:boolean;onClose:()=>void;onEdit:()=>void;onSave:(payload:Parameters<typeof updateAdminUser>[1])=>Promise<void>}){
  const {t}=useI18n();const [form,setForm]=useState({full_name:user.full_name,email:user.email||"",phone:user.phone||"",preferred_language:user.preferred_language,status:user.status,roles:[...user.roles]});
  const set=(key:string,value:string|string[])=>setForm(current=>({...current,[key]:value}));
  return <div className="admin-modal-backdrop" onMouseDown={e=>{if(e.target===e.currentTarget)onClose()}}><div className="admin-user-dialog" role="dialog" aria-modal="true"><header><div><span className="eyebrow">{t(editing?"admin.users.edit":"admin.users.details")}</span><h2>{user.full_name}</h2></div><button type="button" onClick={onClose} aria-label={t("common.close")}>×</button></header>{editing?<form onSubmit={e=>{e.preventDefault();void onSave({...form,email:form.email||null,phone:form.phone||null})}}><label>{t("admin.users.fullName")}<input required value={form.full_name} onChange={e=>set("full_name",e.target.value)}/></label><label>{t("admin.users.email")}<input type="email" value={form.email} onChange={e=>set("email",e.target.value)}/></label><label>{t("admin.users.phone")}<input value={form.phone} onChange={e=>set("phone",e.target.value)}/></label><label>{t("admin.users.language")}<select value={form.preferred_language} onChange={e=>set("preferred_language",e.target.value)}>{["en","ar","fr","es","de"].map(x=><option key={x}>{x}</option>)}</select></label><label>{t("admin.users.status")}<select value={form.status} onChange={e=>set("status",e.target.value)}>{["active","inactive","suspended"].map(x=><option key={x} value={x}>{t(statusKey(x))}</option>)}</select></label><fieldset><legend>{t("admin.users.roles")}</legend>{roles.map(item=><label key={item.id}><input type="checkbox" checked={form.roles.includes(item.name)} onChange={e=>set("roles",e.target.checked?[...form.roles,item.name]:form.roles.filter(x=>x!==item.name))}/>{t(ROLE_KEYS[item.name as Role]||"role.clinician")}</label>)}</fieldset><footer><button className="btn btn--ghost" type="button" onClick={onClose}>{t("common.cancel")}</button><button className="btn btn--gold" disabled={busy}>{busy?t("common.loading"):t("admin.users.save")}</button></footer></form>:<><dl><div><dt>{t("admin.users.email")}</dt><dd>{user.email||"—"}</dd></div><div><dt>{t("admin.users.phone")}</dt><dd>{user.phone||"—"}</dd></div><div><dt>{t("admin.users.roles")}</dt><dd>{user.roles.map(r=>t(ROLE_KEYS[r as Role]||"role.clinician")).join(", ")||"—"}</dd></div><div><dt>{t("admin.users.status")}</dt><dd>{t(statusKey(user.status))}</dd></div><div><dt>{t("admin.users.medicalCenter")}</dt><dd>{user.medical_center_id||"—"}</dd></div><div><dt>{t("admin.users.language")}</dt><dd>{user.preferred_language.toUpperCase()}</dd></div><div><dt>{t("admin.users.created")}</dt><dd>{formatDateTime(user.created_at)}</dd></div><div><dt>{t("admin.users.updatedAt")}</dt><dd>{formatDateTime(user.updated_at)}</dd></div></dl><footer><button className="btn btn--ghost" type="button" onClick={onClose}>{t("common.close")}</button><button className="btn btn--gold" type="button" onClick={onEdit}>{t("admin.users.edit")}</button></footer></>}</div></div>;
}
