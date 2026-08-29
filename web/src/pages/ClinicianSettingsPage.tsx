import { useEffect, useMemo, useState } from "react";
import { api,resolveMediaUrl } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import { useClinicianPreferences } from "../clinicianPreferences";
import { ErrorState,Spinner } from "../components/ui";
import { initials } from "../lib";
import { useI18n } from "../i18n/useI18n";
import type { Lang } from "../i18n/translations";
import { useProviderSelf } from "../providerSelf";
import type { Provider,ProviderListResponse } from "../types";
import { useClinicianNotificationPreferences,type ClinicianNotificationCategory } from "../clinicianNotificationPreferences";

const copy:Record<Lang,Record<string,string>>={
 en:{eyebrow:"Account settings",title:"Settings",sub:"Personalize your professional profile and NeuroBridge experience.",language:"Language",textSize:"Text size",appearance:"Appearance",standard:"Standard",larger:"Larger",light:"Light",dark:"Dark",system:"System",profile:"Professional profile",profileHelp:"This information comes from the provider profile used during family appointment selection.",readOnly:"Profile details are read-only because no profile update API is currently available.",doctor:"Doctor",therapist:"Therapist",specialty:"Specialty",organization:"Medical center / organization",location:"Location",bio:"Professional bio",modes:"Appointment modes",inPerson:"In person",online:"Online",notProvided:"Not provided",preview:"Preview profile",previewTitle:"Family booking preview",close:"Close",completeness:"Profile completeness",accessibility:"Appearance & reading",reduceMotion:"Reduce motion",reduceHelp:"Reduce interface movement and animated effects.",assistant:"AI Assistant Preferences",responseStyle:"Response style",short:"Short",balanced:"Balanced",detailed:"Detailed",patientContext:"Use patient context when explicitly available",remember:"Remember local preferences",deviceLocal:"These assistant preferences are stored only on this device.",notifications:"Notifications",notificationsBody:"Review clinician notifications from the bell in the topbar.",privacy:"Privacy",privacyBody:"Professional profile information may appear during booking and care coordination. Private clinician history stays separate, and Family-private memories are not exposed here.",account:"Account & Access",about:"About",aboutBody:"NeuroBridge clinician workspace for coordinated, human-centered care.",accountName:"Account name",role:"Role",email:"Email",unavailable:"Unavailable",loadError:"Professional profile could not be loaded."},
 ar:{eyebrow:"إعدادات الحساب",title:"الإعدادات",sub:"خصص ملفك المهني وتجربة استخدام NeuroBridge.",language:"اللغة",textSize:"حجم النص",appearance:"المظهر",standard:"قياسي",larger:"أكبر",light:"فاتح",dark:"داكن",system:"النظام",profile:"الملف المهني",profileHelp:"تظهر هذه المعلومات للعائلة عند اختيار مقدم الرعاية وحجز الموعد.",readOnly:"يعرض الدور المهني للقراءة فقط.",doctor:"طبيب",therapist:"معالج",specialty:"التخصص",organization:"العيادة / المؤسسة",location:"الموقع",bio:"النبذة المهنية",modes:"أنماط المواعيد",inPerson:"حضوري",online:"عن بُعد",notProvided:"غير متوفر",preview:"معاينة ملف العائلة",previewTitle:"معاينة الملف للعائلة",close:"إغلاق",completeness:"اكتمال الملف",accessibility:"إمكانية الوصول",reduceMotion:"تقليل الحركة",reduceHelp:"تقليل حركة الواجهة والتأثيرات المتحركة.",assistant:"تفضيلات المساعد",responseStyle:"أسلوب الإجابة",short:"قصير",balanced:"متوازن",detailed:"مفصل",patientContext:"استخدام سياق المريض عند توفره بوضوح",remember:"تذكر التفضيلات المحلية",deviceLocal:"تُحفظ تفضيلات المساعد على هذا الجهاز فقط.",privacy:"الخصوصية",privacyBody:"قد تظهر معلومات الملف المهني أثناء الحجز وتنسيق الرعاية. يبقى السجل المهني منفصلًا، ولا تظهر ذكريات العائلة الخاصة هنا.",account:"الحساب وحول التطبيق",accountName:"اسم الحساب",role:"الدور",email:"البريد الإلكتروني",unavailable:"غير متاح",loadError:"تعذر تحميل الملف المهني."},
 fr:{eyebrow:"Paramֳ¨tres du compte",title:"Paramֳ¨tres",sub:"Personnalisez votre profil professionnel et votre expֳ©rience NeuroBridge.",language:"Langue",textSize:"Taille du texte",appearance:"Apparence",standard:"Standard",larger:"Plus grand",light:"Clair",dark:"Sombre",system:"Systֳ¨me",profile:"Profil professionnel",profileHelp:"Ces informations proviennent du profil utilisֳ© lors du choix dג€™un rendez-vous par la famille.",readOnly:"Le profil est en lecture seule, car aucune API de mise ֳ  jour nג€™est disponible.",doctor:"Mֳ©decin",therapist:"Thֳ©rapeute",specialty:"Spֳ©cialitֳ©",organization:"Centre mֳ©dical / organisation",location:"Lieu",bio:"Prֳ©sentation professionnelle",modes:"Modes de rendez-vous",inPerson:"En personne",online:"En ligne",notProvided:"Non renseignֳ©",preview:"Aperֳ§u du profil",previewTitle:"Aperֳ§u pour la rֳ©servation famille",close:"Fermer",completeness:"Complֳ©tude du profil",accessibility:"Accessibilitֳ©",reduceMotion:"Rֳ©duire les animations",reduceHelp:"Rֳ©duire les mouvements et effets animֳ©s.",assistant:"Prֳ©fֳ©rences de lג€™assistant",responseStyle:"Style de rֳ©ponse",short:"Court",balanced:"ֳ‰quilibrֳ©",detailed:"Dֳ©taillֳ©",patientContext:"Utiliser le contexte patient lorsquג€™il est explicitement disponible",remember:"Mֳ©moriser les prֳ©fֳ©rences locales",deviceLocal:"Ces prֳ©fֳ©rences sont stockֳ©es uniquement sur cet appareil.",privacy:"Confidentialitֳ©",privacyBody:"Le profil professionnel peut apparaֳ®tre pendant la rֳ©servation et la coordination. Lג€™historique clinique reste sֳ©parֳ© et les souvenirs privֳ©s des familles ne sont pas exposֳ©s.",account:"Compte et ֳ  propos",accountName:"Nom du compte",role:"Rֳ´le",email:"E-mail",unavailable:"Indisponible",loadError:"Impossible de charger le profil professionnel."},
 es:{eyebrow:"Ajustes de la cuenta",title:"Ajustes",sub:"Personaliza tu perfil profesional y tu experiencia NeuroBridge.",language:"Idioma",textSize:"Tamaֳ±o del texto",appearance:"Apariencia",standard:"Estֳ¡ndar",larger:"Mֳ¡s grande",light:"Claro",dark:"Oscuro",system:"Sistema",profile:"Perfil profesional",profileHelp:"Esta informaciֳ³n procede del perfil utilizado al seleccionar citas familiares.",readOnly:"El perfil es de solo lectura porque no hay una API de actualizaciֳ³n disponible.",doctor:"Mֳ©dico",therapist:"Terapeuta",specialty:"Especialidad",organization:"Centro mֳ©dico / organizaciֳ³n",location:"Ubicaciֳ³n",bio:"Biografֳ­a profesional",modes:"Modalidades de cita",inPerson:"Presencial",online:"En lֳ­nea",notProvided:"No indicado",preview:"Vista previa del perfil",previewTitle:"Vista previa de reserva familiar",close:"Cerrar",completeness:"Perfil completado",accessibility:"Accesibilidad",reduceMotion:"Reducir movimiento",reduceHelp:"Reduce el movimiento y los efectos animados.",assistant:"Preferencias del asistente",responseStyle:"Estilo de respuesta",short:"Breve",balanced:"Equilibrado",detailed:"Detallado",patientContext:"Usar el contexto del paciente cuando estֳ© disponible explֳ­citamente",remember:"Recordar preferencias locales",deviceLocal:"Estas preferencias se guardan solo en este dispositivo.",privacy:"Privacidad",privacyBody:"El perfil profesional puede aparecer durante reservas y coordinaciֳ³n. El historial clֳ­nico permanece separado y los recuerdos privados familiares no se muestran.",account:"Cuenta y acerca de",accountName:"Nombre de cuenta",role:"Rol",email:"Correo",unavailable:"No disponible",loadError:"No se pudo cargar el perfil profesional."},
 de:{eyebrow:"Kontoeinstellungen",title:"Einstellungen",sub:"Passen Sie Ihr Berufsprofil und Ihre NeuroBridge-Erfahrung an.",language:"Sprache",textSize:"Textgrֳ¶ֳe",appearance:"Darstellung",standard:"Standard",larger:"Grֳ¶ֳer",light:"Hell",dark:"Dunkel",system:"System",profile:"Berufsprofil",profileHelp:"Diese Informationen stammen aus dem Profil, das Familien bei der Terminwahl sehen.",readOnly:"Das Profil ist schreibgeschֳ¼tzt, da keine Aktualisierungs-API verfֳ¼gbar ist.",doctor:"Arzt",therapist:"Therapeut",specialty:"Fachgebiet",organization:"Medizinisches Zentrum / Organisation",location:"Standort",bio:"Berufliche Kurzbeschreibung",modes:"Terminarten",inPerson:"Vor Ort",online:"Online",notProvided:"Nicht angegeben",preview:"Profilvorschau",previewTitle:"Vorschau fֳ¼r Familienbuchungen",close:"Schlieֳen",completeness:"Profilvollstֳ₪ndigkeit",accessibility:"Barrierefreiheit",reduceMotion:"Bewegung reduzieren",reduceHelp:"Bewegungen und Animationseffekte reduzieren.",assistant:"Assistenten-Einstellungen",responseStyle:"Antwortstil",short:"Kurz",balanced:"Ausgewogen",detailed:"Detailliert",patientContext:"Patientenkontext bei ausdrֳ¼cklicher Verfֳ¼gbarkeit verwenden",remember:"Lokale Einstellungen merken",deviceLocal:"Diese Einstellungen werden nur auf diesem Gerֳ₪t gespeichert.",privacy:"Datenschutz",privacyBody:"Berufliche Profildaten kֳ¶nnen bei Buchung und Koordination sichtbar sein. Der klinische Verlauf bleibt getrennt; private Familienerinnerungen werden nicht angezeigt.",account:"Konto und Info",accountName:"Kontoname",role:"Rolle",email:"E-Mail",unavailable:"Nicht verfֳ¼gbar",loadError:"Berufsprofil konnte nicht geladen werden."}
};

const editCopy:Record<Lang,Record<string,string>>={
 en:{edit:"Edit profile",changePhoto:"Change photo",displayName:"Display name",languages:"Languages",save:"Save changes",cancel:"Cancel",saving:"Saving...",saved:"Profile saved.",saveError:"Profile could not be saved.",photoError:"Choose a JPEG, PNG, or WebP image up to 5 MB.",previewTitle:"Family profile preview"},
 ar:{edit:"تعديل الملف",changePhoto:"تغيير الصورة",displayName:"الاسم الظاهر",languages:"اللغات",save:"حفظ التغييرات",cancel:"إلغاء",saving:"جارٍ الحفظ...",saved:"تم حفظ الملف.",saveError:"تعذر حفظ الملف.",photoError:"اختر صورة JPEG أو PNG أو WebP بحجم لا يتجاوز 5 ميجابايت.",previewTitle:"معاينة الملف للعائلة"},
 fr:{edit:"Modifier le profil",changePhoto:"Changer la photo",displayName:"Nom affichֳ©",languages:"Langues",save:"Enregistrer",cancel:"Annuler",saving:"Enregistrement...",saved:"Profil enregistrֳ©.",saveError:"Impossible dג€™enregistrer le profil.",photoError:"Choisissez une image JPEG, PNG ou WebP de 5 Mo maximum.",previewTitle:"Aperֳ§u du profil pour la famille"},
 es:{edit:"Editar perfil",changePhoto:"Cambiar foto",displayName:"Nombre visible",languages:"Idiomas",save:"Guardar cambios",cancel:"Cancelar",saving:"Guardando...",saved:"Perfil guardado.",saveError:"No se pudo guardar el perfil.",photoError:"Elige una imagen JPEG, PNG o WebP de hasta 5 MB.",previewTitle:"Vista previa del perfil familiar"},
 de:{edit:"Profil bearbeiten",changePhoto:"Foto ֳ₪ndern",displayName:"Anzeigename",languages:"Sprachen",save:"ֳ„nderungen speichern",cancel:"Abbrechen",saving:"Speichern...",saved:"Profil gespeichert.",saveError:"Profil konnte nicht gespeichert werden.",photoError:"Wֳ₪hlen Sie ein JPEG-, PNG- oder WebP-Bild bis 5 MB.",previewTitle:"Profilvorschau fֳ¼r Familien"}
};
const layoutCopy:Record<Lang,{reading:string;notifications:string;notificationsBody:string;assistant:string;account:string;about:string;aboutBody:string}>={
 en:{reading:"Appearance & Reading",notifications:"Notifications",notificationsBody:"Review clinician notifications from the bell in the topbar.",assistant:"AI Assistant Preferences",account:"Account & Access",about:"About",aboutBody:"NeuroBridge clinician workspace for coordinated, human-centered care."},
 ar:{reading:"المظهر والقراءة",notifications:"الإشعارات",notificationsBody:"راجع إشعارات مقدم الرعاية من أيقونة الجرس في الشريط العلوي.",assistant:"تفضيلات مساعد الذكاء الاصطناعي",account:"الحساب والوصول",about:"حول",aboutBody:"مساحة NeuroBridge لمقدمي الرعاية من أجل رعاية منسقة تتمحور حول الإنسان."},
 fr:{reading:"Apparence et lecture",notifications:"Notifications",notificationsBody:"Consultez les notifications depuis la cloche de la barre supֳ©rieure.",assistant:"Prֳ©fֳ©rences de lג€™assistant IA",account:"Compte et accֳ¨s",about:"ֳ€ propos",aboutBody:"Lג€™espace clinicien NeuroBridge favorise des soins coordonnֳ©s et centrֳ©s sur lג€™humain."},
 es:{reading:"Apariencia y lectura",notifications:"Notificaciones",notificationsBody:"Consulta las notificaciones desde la campana de la barra superior.",assistant:"Preferencias del asistente de IA",account:"Cuenta y acceso",about:"Acerca de",aboutBody:"El espacio clֳ­nico NeuroBridge facilita una atenciֳ³n coordinada y centrada en las personas."},
 de:{reading:"Darstellung und Lesen",notifications:"Benachrichtigungen",notificationsBody:"Benachrichtigungen kֳ¶nnen ֳ¼ber die Glocke in der oberen Leiste geprֳ¼ft werden.",assistant:"KI-Assistent-Einstellungen",account:"Konto und Zugriff",about:"ֳber NeuroBridge",aboutBody:"Der NeuroBridge-Arbeitsbereich unterstֳ¼tzt koordinierte, menschenzentrierte Versorgung."},
};
const notificationPrefsCopy:Record<Lang,Record<ClinicianNotificationCategory,{title:string;helper:string}>>={
 en:{messages:{title:"Family messages",helper:"Show unread Family message updates."},appointments:{title:"Appointments",helper:"Show upcoming appointment updates."},review:{title:"Review Queue updates",helper:"Show updates from the deterministic review workflow."},activity:{title:"Recorded activity updates",helper:"Show newly recorded patient sessions and activity."}},
 ar:{messages:{title:"رسائل العائلة",helper:"عرض تحديثات رسائل العائلة غير المقروءة."},appointments:{title:"المواعيد",helper:"عرض تحديثات المواعيد القادمة."},review:{title:"تحديثات قائمة المراجعة",helper:"عرض تحديثات سير المراجعة المحدد."},activity:{title:"تحديثات النشاط المسجّل",helper:"عرض جلسات المرضى والأنشطة المسجّلة حديثًا."}},
 fr:{messages:{title:"Messages des familles",helper:"Afficher les nouveaux messages familiaux non lus."},appointments:{title:"Rendez-vous",helper:"Afficher les mises ֳ  jour des rendez-vous ֳ  venir."},review:{title:"Mises ֳ  jour de la liste de rֳ©vision",helper:"Afficher les mises ֳ  jour du processus de rֳ©vision."},activity:{title:"Activitֳ© enregistrֳ©e",helper:"Afficher les nouvelles sessions et activitֳ©s enregistrֳ©es."}},
 es:{messages:{title:"Mensajes familiares",helper:"Mostrar nuevos mensajes familiares no leֳ­dos."},appointments:{title:"Citas",helper:"Mostrar actualizaciones de prֳ³ximas citas."},review:{title:"Actualizaciones de revisiֳ³n",helper:"Mostrar cambios del flujo de revisiֳ³n."},activity:{title:"Actividad registrada",helper:"Mostrar nuevas sesiones y actividades registradas."}},
 de:{messages:{title:"Familiennachrichten",helper:"Ungelesene Familiennachrichten anzeigen."},appointments:{title:"Termine",helper:"Aktualisierungen zu anstehenden Terminen anzeigen."},review:{title:"Prֳ¼flisten-Aktualisierungen",helper:"Aktualisierungen aus dem Prֳ¼fablauf anzeigen."},activity:{title:"Erfasste Aktivitֳ₪ten",helper:"Neu erfasste Sitzungen und Aktivitֳ₪ten anzeigen."}},
};
const profilePolishCopy:Record<Lang,{editTitle:string;roleLabel:string}>={
 en:{editTitle:"Edit professional profile",roleLabel:"Professional role"},
 ar:{editTitle:"تعديل الملف المهني",roleLabel:"الدور المهني"},
 fr:{editTitle:"Modifier le profil professionnel",roleLabel:"Rֳ´le professionnel"},
 es:{editTitle:"Editar perfil profesional",roleLabel:"Rol profesional"},
 de:{editTitle:"Berufsprofil bearbeiten",roleLabel:"Berufliche Rolle"},
};
type ClinicianSettingsTab="profile"|"appearance"|"notifications"|"assistant"|"account";
const settingsTabCopy:Record<Lang,Record<ClinicianSettingsTab,string>>={
 en:{profile:"Professional Profile",appearance:"Appearance",notifications:"Notifications",assistant:"AI Assistant",account:"Account"},
 ar:{profile:"الملف المهني",appearance:"المظهر",notifications:"الإشعارات",assistant:"المساعد الذكي",account:"الحساب"},
 fr:{profile:"Profil professionnel",appearance:"Apparence",notifications:"Notifications",assistant:"Assistant IA",account:"Compte"},
 es:{profile:"Perfil profesional",appearance:"Apariencia",notifications:"Notificaciones",assistant:"Asistente IA",account:"Cuenta"},
 de:{profile:"Berufsprofil",appearance:"Darstellung",notifications:"Benachrichtigungen",assistant:"KI-Assistent",account:"Konto"},
};
const languageNames:Record<Lang,Record<string,string>>={en:{ar:"Arabic",en:"English",fr:"French",es:"Spanish",de:"German"},ar:{ar:"العربية",en:"الإنجليزية",fr:"الفرنسية",es:"الإسبانية",de:"الألمانية"},fr:{ar:"Arabe",en:"Anglais",fr:"Franֳ§ais",es:"Espagnol",de:"Allemand"},es:{ar:"ֳrabe",en:"Inglֳ©s",fr:"Francֳ©s",es:"Espaֳ±ol",de:"Alemֳ¡n"},de:{ar:"Arabisch",en:"Englisch",fr:"Franzֳ¶sisch",es:"Spanisch",de:"Deutsch"}};

function ProviderProfileAvatar({src,name,variant}:{src?:string;name:string;variant:"settings"|"preview"}){
 const [failed,setFailed]=useState(false);
 useEffect(()=>setFailed(false),[src]);
 return <span className={`clinician-provider-avatar clinician-provider-avatar--${variant}`} aria-label={name}>{src&&!failed?<img src={src} alt="" onError={()=>setFailed(true)}/>:<span aria-hidden="true">{initials(name)}</span>}</span>;
}

export function LegacyClinicianSettingsPage(){
 const {user,roles}=useAuth(),{lang}=useI18n(),c=copy[lang],{preferences,update}=useClinicianPreferences(user?.id,roles.includes("doctor"));
 const [provider,setProvider]=useState<Provider|null>(null),[loading,setLoading]=useState(true),[error,setError]=useState(""),[preview,setPreview]=useState(false);
 useEffect(()=>{let live=true;api<ProviderListResponse>("/providers").then(result=>{if(live)setProvider(result.providers.find(item=>item.provider_user_id===user?.id)||null)}).catch(()=>live&&setError(c.loadError)).finally(()=>live&&setLoading(false));return()=>{live=false}},[user?.id]);
 const role=roles.includes("therapist")?c.therapist:c.doctor;
 const completeness=useMemo(()=>{const values=[provider?.full_name,provider?.photo_url,provider?.specialty,provider?.bio_short,provider?.clinic_name];return Math.round(values.filter(Boolean).length/values.length*100)},[provider]);
 const name=provider?.full_name||user?.full_name||c.unavailable,photo=resolveMediaUrl(provider?.photo_url);
 const profile=<article className="clinician-provider-preview">
<header>{photo?<img src={photo} alt=""/>:<span>{initials(name)}</span>}<div>
<h3>{name}</h3>
<p>{role}{provider?.specialty?` ֲ· ${provider.specialty}`:""}</p>
</div>
</header>{provider?.bio_short&&<p>{provider.bio_short}</p>}<dl>
<div>
<dt>{c.organization}</dt>
<dd>{provider?.clinic_name||c.notProvided}</dd>
</div>
<div>
<dt>{c.location}</dt>
<dd>{provider?.location||[provider?.city,provider?.governorate].filter(Boolean).join(", ")||c.notProvided}</dd>
</div>
<div>
<dt>{c.modes}</dt>
<dd>{[provider?.in_person_available&&c.inPerson,provider?.online_available&&c.online].filter(Boolean).join(" ֲ· ")||c.notProvided}</dd>
</div>
</dl>
</article>;
 return <div className="page page--wide clinician-settings-page">
<header className="page__head clinician-centered-head">
<div>
<span className="eyebrow">{c.eyebrow}</span>
<h1>{c.title}</h1>
<p className="page__sub">{c.sub}</p>
</div>
</header>
<section className="clinician-settings-summary">
<article>
<small>{c.language}</small>
<strong>{lang.toUpperCase()}</strong>
</article>
<article>
<small>{c.textSize}</small>
<strong>{c[preferences.textSize]}</strong>
</article>
<article>
<small>{c.appearance}</small>
<strong>{c[preferences.theme]}</strong>
</article>
</section>{loading?<Spinner label={c.profile}/>:error?<ErrorState message={error}/>:<section className="clinician-settings-card clinician-profile-card">
<header>
<div>
<h2>{c.profile}</h2>
<p>{c.profileHelp}</p>
</div>
<button type="button" className="btn btn--gold" onClick={()=>setPreview(true)}>{c.preview}</button>
</header>
<div className="clinician-profile-identity">{photo?<img src={photo} alt=""/>:<span>{initials(name)}</span>}<div>
<h3>{name}</h3>
<p>{role}{provider?.specialty?` ֲ· ${provider.specialty}`:""}</p>
<small>{c.readOnly}</small>
</div>
<div className="clinician-profile-progress">
<strong>{completeness}%</strong>
<span>{c.completeness}</span>
<i aria-hidden="true"><b style={{width:`${completeness}%`}}/></i>
</div>
</div>
<dl className="clinician-profile-facts">{[[c.specialty,provider?.specialty],[c.bio,provider?.bio_short],[c.organization,provider?.clinic_name],[c.location,provider?.location||[provider?.city,provider?.governorate].filter(Boolean).join(", ")],[c.modes,[provider?.in_person_available&&c.inPerson,provider?.online_available&&c.online].filter(Boolean).join(" ֲ· ")]].map(([key,value])=>
<div key={key}>
<dt>{key}</dt>
<dd>{value||c.notProvided}</dd>
</div>)}</dl>
</section>}<div className="clinician-settings-grid">
<section className="clinician-settings-card">
<h2>{c.appearance}</h2>
<div className="settings-choice-row">
<span>{c.appearance}</span>
<div>{(["light","dark","system"] as const).map(value=>
<button className={preferences.theme===value?"is-active":""} onClick={()=>update({theme:value})} key={value}>{c[value]}</button>)}</div>
</div>
<div className="settings-choice-row">
<span>{c.textSize}</span>
<div>{(["standard","larger"] as const).map(value=>
<button className={preferences.textSize===value?"is-active":""} onClick={()=>update({textSize:value})} key={value}>{c[value]}</button>)}</div>
</div>
<label className="clinician-settings-toggle">
<span>
<strong>{c.reduceMotion}</strong>
<small>{c.reduceHelp}</small>
</span>
<input type="checkbox" checked={preferences.reduceMotion} onChange={event=>update({reduceMotion:event.target.checked})}/>
</label>
</section>
<section className="clinician-settings-card">
<h2>{c.assistant}</h2>
<div className="settings-choice-row">
<span>{c.responseStyle}</span>
<div>{(["short","balanced","detailed"] as const).map(value=>
<button className={preferences.aiResponseStyle===value?"is-active":""} onClick={()=>update({aiResponseStyle:value})} key={value}>{c[value]}</button>)}</div>
</div>
<label className="clinician-settings-toggle">
<span>{c.patientContext}</span>
<input type="checkbox" checked={preferences.aiUsePatientContext} onChange={event=>update({aiUsePatientContext:event.target.checked})}/>
</label>
<label className="clinician-settings-toggle">
<span>{c.remember}</span>
<input type="checkbox" checked={preferences.aiRememberPreferences} onChange={event=>update({aiRememberPreferences:event.target.checked})}/>
</label>
<p className="settings-local-note">{c.deviceLocal}</p>
</section>
<section className="clinician-settings-card">
<h2>{c.privacy}</h2>
<p>{c.privacyBody}</p>
</section>
<section className="clinician-settings-card">
<h2>{c.account}</h2>
<dl>
<div>
<dt>{c.accountName}</dt>
<dd>{user?.full_name||c.unavailable}</dd>
</div>
<div>
<dt>{c.role}</dt>
<dd>{role}</dd>
</div>
<div>
<dt>{c.email}</dt>
<dd>{user?.email||c.unavailable}</dd>
</div>
</dl>
</section>
</div>{preview&&<div className="clinician-preview-backdrop" onMouseDown={event=>event.target===event.currentTarget&&setPreview(false)}>
<section role="dialog" aria-modal="true" aria-label={c.previewTitle}>
<header>
<h2>{c.previewTitle}</h2>
<button type="button" onClick={()=>setPreview(false)} aria-label={c.close}>ֳ—</button>
</header>{profile}<footer>
<button type="button" className="btn btn--gold" onClick={()=>setPreview(false)}>{c.close}</button>
</footer>
</section>
</div>}</div>
}

export function ClinicianSettingsPage(){
 const {user,roles}=useAuth(),{lang}=useI18n(),c=copy[lang],e=editCopy[lang],l=layoutCopy[lang],p=profilePolishCopy[lang],{preferences,update:savePreference}=useClinicianPreferences(user?.id,roles.includes("doctor"));
 const {preferences:notificationPreferences,update:saveNotificationPreference}=useClinicianNotificationPreferences(user?.id||"");
 const {provider,loading,error,update,uploadPhoto,editingAvailable}=useProviderSelf();
 const [editing,setEditing]=useState(false),[preview,setPreview]=useState(false),[saving,setSaving]=useState(false),[notice,setNotice]=useState("");
 const [settingsTab,setSettingsTab]=useState<ClinicianSettingsTab>("profile");
 const [form,setForm]=useState({display_name:"",specialty:"",bio_short:"",languages:[] as string[],clinic_name:"",location:""});
 useEffect(()=>{if(provider)setForm({display_name:provider.full_name||"",specialty:provider.specialty||"",bio_short:provider.bio_short||"",languages:provider.languages||[],clinic_name:provider.clinic_name||"",location:provider.location||""})},[provider]);
 const role=roles.includes("therapist")?c.therapist:c.doctor,name=provider?.full_name||user?.full_name||c.unavailable,photo=resolveMediaUrl(provider?.photo_url)||undefined;
 const completeness=useMemo(()=>Math.round([name,photo,provider?.specialty,provider?.bio_short,provider?.languages?.length].filter(Boolean).length/5*100),[name,photo,provider]);
 const submit=async(event:React.FormEvent)=>{event.preventDefault();setSaving(true);setNotice("");try{await update(form);setEditing(false);setNotice(e.saved)}catch{setNotice(e.saveError)}finally{setSaving(false)}};
 const pickPhoto=async(event:React.ChangeEvent<HTMLInputElement>)=>{const file=event.target.files?.[0];event.target.value="";if(!file)return;if(!["image/jpeg","image/png","image/webp"].includes(file.type)||file.size>5*1024*1024){setNotice(e.photoError);return}setSaving(true);try{await uploadPhoto(file);setNotice(e.saved)}catch{setNotice(e.saveError)}finally{setSaving(false)}};
  const profile=<article className="clinician-provider-preview clinician-family-profile-preview">
<div className="clinician-family-profile-preview__identity">
<ProviderProfileAvatar src={photo} name={name} variant="preview"/>
<h3>{name}</h3>
<p>{role}{provider?.specialty?` ֲ· ${provider.specialty}`:""}</p>
</div>
<p className="clinician-family-profile-preview__bio">{provider?.bio_short||c.notProvided}</p><dl>
<div>
<dt>{e.languages}</dt>
<dd>{provider?.languages?.map(code=>languageNames[lang][code]||code).join(" ֲ· ")||c.notProvided}</dd>
</div>
<div>
<dt>{c.organization}</dt>
<dd>{provider?.clinic_name||c.notProvided}</dd>
</div>
<div>
<dt>{c.location}</dt>
<dd>{provider?.location||c.notProvided}</dd>
</div>
</dl>
</article>;
 return <div className="page page--wide clinician-settings-page">
  <header className="page__head clinician-centered-head">
<div>
<span className="eyebrow">{c.eyebrow}</span>
<h1>{c.title}</h1>
<p className="page__sub">{c.sub}</p>
</div>
</header>
  <section className="clinician-settings-summary">
<article>
<small>{c.language}</small>
<strong>{lang.toUpperCase()}</strong>
</article>
<article>
<small>{c.textSize}</small>
<strong>{c[preferences.textSize]}</strong>
</article>
<article>
<small>{c.appearance}</small>
<strong>{c[preferences.theme]}</strong>
</article>
</section>
  {loading?<Spinner label={c.profile}/>:error?<ErrorState message={error}/>:<section className="clinician-settings-card clinician-profile-card">
<header>
<div>
<h2>{c.profile}</h2>
<p>{c.profileHelp}</p>
</div>
</header>{notice&&<p className="settings-local-note" role="status">{notice}</p>}<div className="clinician-profile-layout">
<aside className="clinician-profile-identity">
<div className="clinician-profile-photo-wrap">
<ProviderProfileAvatar src={photo} name={name} variant="settings"/>
<label className="clinician-profile-camera" title={c.readOnly} aria-label={c.readOnly} aria-disabled={!editingAvailable}>
<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
<path d="M4 7h4l1.5-2h5L16 7h4v12H4z"/>
<circle cx="12" cy="13" r="3.5"/>
</svg>
<input hidden type="file" disabled={!editingAvailable} accept="image/jpeg,image/png,image/webp" onChange={pickPhoto}/>
</label>
</div>
<div className="clinician-profile-card-copy">
<h3>{name}</h3>
<p>{role}</p>
<strong>{provider?.specialty||c.notProvided}</strong>
<small>{provider?.clinic_name||c.notProvided}</small>
</div>
<div className="clinician-profile-progress">
<strong>{completeness}%</strong>
<span>{c.completeness}</span>
</div>
<button type="button" className="btn clinician-profile-family-preview" onClick={()=>setPreview(true)}>{c.preview}</button>
</aside>
<div className="clinician-profile-workspace">
<nav className="clinician-settings-tabs" aria-label={c.title}>{(["profile","appearance","notifications","assistant","account"] as ClinicianSettingsTab[]).map(tab=>
<button type="button" key={tab} className={settingsTab===tab?"is-active":""} onClick={()=>setSettingsTab(tab)}>{settingsTabCopy[lang][tab]}</button>)}</nav>
<div className="clinician-settings-pane">{settingsTab==="profile"&&<form className="clinician-profile-tab-form" onSubmit={submit}>
<p className="settings-local-note clinician-profile-unavailable" role="note">{c.readOnly}</p>
<div className="clinician-profile-tab-grid">
<label>{e.displayName}<input disabled={!editingAvailable} required minLength={2} maxLength={255} value={form.display_name} onChange={event=>setForm({...form,display_name:event.target.value})}/></label>
<label>{c.specialty}<input disabled={!editingAvailable} maxLength={255} value={form.specialty} onChange={event=>setForm({...form,specialty:event.target.value})}/></label>
<label>{c.organization}<input disabled={!editingAvailable} maxLength={255} value={form.clinic_name} onChange={event=>setForm({...form,clinic_name:event.target.value})}/></label>
<label>{c.location}<input disabled={!editingAvailable} maxLength={255} value={form.location} onChange={event=>setForm({...form,location:event.target.value})}/></label>
<fieldset disabled={!editingAvailable}><legend>{e.languages}</legend><div>{["ar","en","fr","es","de"].map(code=><label key={code}><input type="checkbox" checked={form.languages.includes(code)} onChange={event=>setForm({...form,languages:event.target.checked?[...form.languages,code]:form.languages.filter(item=>item!==code)})}/>{languageNames[lang][code]}</label>)}</div></fieldset>
<label>{p.roleLabel}<input value={role} readOnly aria-readonly="true"/></label>
<label className="is-wide">{c.bio}<textarea disabled={!editingAvailable} maxLength={500} value={form.bio_short} onChange={event=>setForm({...form,bio_short:event.target.value})}/></label>
</div>
<dl className="clinician-profile-details">{[[c.specialty,provider?.specialty],[c.bio,provider?.bio_short],[e.languages,provider?.languages?.map(code=>languageNames[lang][code]||code).join(" ֲ· ")],[c.organization,provider?.clinic_name],[c.location,provider?.location]].map(([key,value],index)=>
<div className={index===1?"is-wide":""} key={key}>
<dt>{key}</dt>
<dd>{value||c.notProvided}</dd>
</div>)}</dl>
<footer><button type="submit" className="btn btn--gold" disabled={!editingAvailable||saving}>{saving?e.saving:e.save}</button></footer>
</form>}{settingsTab==="appearance"&&<section className="clinician-settings-tab-section">
<h2>{l.reading}</h2>
<div className="settings-choice-row">
<span>{c.appearance}</span>
<div>{(["light","dark","system"] as const).map(value=>
<button className={preferences.theme===value?"is-active":""} onClick={()=>savePreference({theme:value})} key={value}>{c[value]}</button>)}</div>
</div>
<div className="settings-choice-row">
<span>{c.textSize}</span>
<div>{(["standard","larger"] as const).map(value=>
<button className={preferences.textSize===value?"is-active":""} onClick={()=>savePreference({textSize:value})} key={value}>{c[value]}</button>)}</div>
</div>
<label className="clinician-settings-toggle">
<span>
<strong>{c.reduceMotion}</strong>
<small>{c.reduceHelp}</small>
</span>
<input type="checkbox" checked={preferences.reduceMotion} onChange={event=>savePreference({reduceMotion:event.target.checked})}/>
</label>
</section>}{settingsTab==="notifications"&&<section className="clinician-settings-tab-section clinician-notification-settings">
<h2>{l.notifications}</h2>
<p>{l.notificationsBody}</p>
<div className="clinician-notification-preferences">{(["messages","appointments","review","activity"] as ClinicianNotificationCategory[]).map(category=>
<label className="clinician-settings-toggle" key={category}>
<span>
<strong>{notificationPrefsCopy[lang][category].title}</strong>
<small>{notificationPrefsCopy[lang][category].helper}</small>
</span>
<input type="checkbox" checked={notificationPreferences[category]} onChange={event=>saveNotificationPreference(category,event.target.checked)}/>
</label>)}</div>
</section>}{settingsTab==="assistant"&&<section className="clinician-settings-tab-section">
<h2>{l.assistant}</h2>
<div className="settings-choice-row">
<span>{c.responseStyle}</span>
<div>{(["short","balanced","detailed"] as const).map(value=>
<button className={preferences.aiResponseStyle===value?"is-active":""} onClick={()=>savePreference({aiResponseStyle:value})} key={value}>{c[value]}</button>)}</div>
</div>
<label className="clinician-settings-toggle">
<span>{c.patientContext}</span>
<input type="checkbox" checked={preferences.aiUsePatientContext} onChange={event=>savePreference({aiUsePatientContext:event.target.checked})}/>
</label>
<label className="clinician-settings-toggle">
<span>{c.remember}</span>
<input type="checkbox" checked={preferences.aiRememberPreferences} onChange={event=>savePreference({aiRememberPreferences:event.target.checked})}/>
</label>
<p className="settings-local-note">{c.deviceLocal}</p>
</section>}{settingsTab==="account"&&<div className="clinician-account-pane">
<section>
<h2>{l.account}</h2>
<dl>
<div>
<dt>{c.accountName}</dt>
<dd>{name}</dd>
</div>
<div>
<dt>{c.role}</dt>
<dd>{role}</dd>
</div>
<div>
<dt>{c.email}</dt>
<dd>{user?.email||c.unavailable}</dd>
</div>
</dl>
</section>
<section>
<h2>{c.privacy}</h2>
<p>{c.privacyBody}</p>
</section>
<section className="clinician-settings-about">
<span aria-hidden="true">NB</span>
<div>
<h2>{l.about}</h2>
<strong>NeuroBridge</strong>
<p>{l.aboutBody}</p>
</div>
</section>
</div>}</div>
</div>
</div>
</section>}
  {editing&&<div className="clinician-preview-backdrop" onMouseDown={x=>x.target===x.currentTarget&&setEditing(false)}>
<form className="clinician-profile-edit" onSubmit={submit}>
<header>
<div>
<span className="eyebrow">{c.profile}</span>
<h2>{p.editTitle}</h2>
</div>
</header>
<div className="clinician-profile-edit__role">
<span>{p.roleLabel}</span>
<strong>{role}</strong>
</div>
<div className="clinician-profile-edit__fields">
<label>{e.displayName}<input required minLength={2} maxLength={255} value={form.display_name} onChange={x=>setForm({...form,display_name:x.target.value})}/>
</label>
<label>{c.specialty}<input maxLength={255} value={form.specialty} onChange={x=>setForm({...form,specialty:x.target.value})}/>
</label>
<label className="is-wide">{c.bio}<textarea maxLength={500} value={form.bio_short} onChange={x=>setForm({...form,bio_short:x.target.value})}/>
</label>
<fieldset className="is-wide">
<legend>{e.languages}</legend>{["ar","en","fr","es","de"].map(code=>
<label key={code}>
<input type="checkbox" checked={form.languages.includes(code)} onChange={x=>setForm({...form,languages:x.target.checked?[...form.languages,code]:form.languages.filter(item=>item!==code)})}/>{languageNames[lang][code]}</label>)}</fieldset>
<label>{c.organization}<input maxLength={255} value={form.clinic_name} onChange={x=>setForm({...form,clinic_name:x.target.value})}/>
</label>
<label>{c.location}<input maxLength={255} value={form.location} onChange={x=>setForm({...form,location:x.target.value})}/>
</label>
</div>
<footer>
<button type="button" className="btn" onClick={()=>setEditing(false)}>{e.cancel}</button>
<button className="btn btn--gold" disabled={saving}>{saving?e.saving:e.save}</button>
</footer>
</form>
</div>}
  {preview&&<div className="clinician-preview-backdrop" onMouseDown={x=>x.target===x.currentTarget&&setPreview(false)}>
<section className="clinician-profile-preview-dialog" role="dialog" aria-modal="true" aria-label={e.previewTitle}>
<header>
<div>
<span className="eyebrow">NeuroBridge</span>
<h2>{e.previewTitle}</h2>
</div>
<button type="button" onClick={()=>setPreview(false)} aria-label={c.close}>ֳ—</button>
</header>{profile}<footer>
<button type="button" className="btn btn--gold" onClick={()=>setPreview(false)}>{c.close}</button>
</footer>
</section>
</div>}
 </div>
}
