import { LANG_NAMES } from "../i18n/translations";
import { useI18n } from "../i18n/useI18n";
import { useFamilyPreferences } from "../familyPreferences";
import { useEffect, useState } from "react";
import { FamilyMemberAvatar, familyMemberPhotoCopy, familyRelationshipOptions, resizeFamilyMemberAvatar, useFamilyMembers, type FamilyMember, type FamilyRelationship } from "../familyMembers";
import { LinkPatientDialog,PatientAvatar,resizePatientAvatar,useCurrentFamilyPatient } from "../currentFamilyPatient";
import { useFamilyAiPreferences, type AnswerStyle } from "../familyAiPreferences";

const assistantMemoryCopy = {
  en:{title:"Assistant memory",description:"Choose how NeuroBridge AI adapts to the current family member.",remember:"Remember my preferences",rememberHelp:"Keep response style and helpful-topic signals on this device.",context:"Use current-patient context",contextHelp:"Use existing patient and appointment information when it is relevant.",personalize:"Personalize suggestions",personalizeHelp:"Rank prompts from usage and feedback while keeping variety.",style:"Response style",styleHelp:"Choose the usual amount of detail.",short:"Short",balanced:"Balanced",detailed:"Detailed",remembered:"What the assistant remembers",none:"No topic preferences learned yet.",clear:"Clear assistant memory",confirm:"Clear learned topics and response style? Your conversations will not be deleted.",privacy:"Stored only in this browser. Nothing is uploaded or shared with an external AI.",topics:"Preferred topics"},
  ar:{title:"ذاكرة المساعد",description:"اختر كيف يتكيف NeuroBridge AI مع فرد العائلة الحالي.",remember:"تذكّر تفضيلاتي",rememberHelp:"حفظ أسلوب الرد وإشارات المواضيع المفيدة على هذا الجهاز.",context:"استخدام سياق المريض الحالي",contextHelp:"استخدام معلومات المريض والمواعيد الموجودة عندما تكون ذات صلة.",personalize:"تخصيص الاقتراحات",personalizeHelp:"ترتيب الاقتراحات حسب الاستخدام والتقييم مع الحفاظ على التنوع.",style:"أسلوب الرد",styleHelp:"اختر مقدار التفاصيل المعتاد.",short:"مختصر",balanced:"متوازن",detailed:"مفصل",remembered:"ما يتذكره المساعد",none:"لم يتم تعلم تفضيلات للمواضيع بعد.",clear:"مسح ذاكرة المساعد",confirm:"هل تريد مسح المواضيع المتعلمة وأسلوب الرد؟ لن تُحذف محادثاتك.",privacy:"تُحفظ على هذا المتصفح فقط. لا يتم رفعها أو مشاركتها مع ذكاء اصطناعي خارجي.",topics:"المواضيع المفضلة"},
  fr:{title:"Mémoire de l’assistant",description:"Choisissez comment NeuroBridge AI s’adapte au membre actuel de la famille.",remember:"Mémoriser mes préférences",rememberHelp:"Conserver sur cet appareil le style de réponse et les thèmes utiles.",context:"Utiliser le contexte du patient actuel",contextHelp:"Utiliser les informations existantes du patient et des rendez-vous lorsqu’elles sont pertinentes.",personalize:"Personnaliser les suggestions",personalizeHelp:"Classer les suggestions selon l’usage et les avis tout en gardant de la variété.",style:"Style de réponse",styleHelp:"Choisissez le niveau de détail habituel.",short:"Court",balanced:"Équilibré",detailed:"Détaillé",remembered:"Ce que l’assistant retient",none:"Aucune préférence de thème apprise pour le moment.",clear:"Effacer la mémoire de l’assistant",confirm:"Effacer les thèmes appris et le style de réponse ? Vos conversations ne seront pas supprimées.",privacy:"Stocké uniquement dans ce navigateur. Rien n’est envoyé ni partagé avec une IA externe.",topics:"Thèmes préférés"},
  es:{title:"Memoria del asistente",description:"Elige cómo NeuroBridge AI se adapta al familiar actual.",remember:"Recordar mis preferencias",rememberHelp:"Guardar en este dispositivo el estilo de respuesta y las señales de temas útiles.",context:"Usar el contexto del paciente actual",contextHelp:"Usar la información existente del paciente y las citas cuando sea relevante.",personalize:"Personalizar sugerencias",personalizeHelp:"Ordenar sugerencias según el uso y las valoraciones, manteniendo variedad.",style:"Estilo de respuesta",styleHelp:"Elige el nivel de detalle habitual.",short:"Breve",balanced:"Equilibrado",detailed:"Detallado",remembered:"Lo que recuerda el asistente",none:"Todavía no se han aprendido preferencias de temas.",clear:"Borrar memoria del asistente",confirm:"¿Borrar los temas aprendidos y el estilo de respuesta? Tus conversaciones no se eliminarán.",privacy:"Se guarda solo en este navegador. Nada se carga ni comparte con una IA externa.",topics:"Temas preferidos"},
  de:{title:"Assistentengedächtnis",description:"Legen Sie fest, wie sich NeuroBridge AI an das aktuelle Familienmitglied anpasst.",remember:"Meine Präferenzen merken",rememberHelp:"Antwortstil und hilfreiche Themenhinweise auf diesem Gerät speichern.",context:"Kontext des aktuellen Patienten nutzen",contextHelp:"Vorhandene Patienten- und Termininformationen verwenden, wenn sie relevant sind.",personalize:"Vorschläge personalisieren",personalizeHelp:"Vorschläge nach Nutzung und Feedback ordnen und dabei Abwechslung erhalten.",style:"Antwortstil",styleHelp:"Wählen Sie den üblichen Detailgrad.",short:"Kurz",balanced:"Ausgewogen",detailed:"Detailliert",remembered:"Was der Assistent speichert",none:"Noch keine Themenpräferenzen gelernt.",clear:"Assistentengedächtnis löschen",confirm:"Gelernte Themen und Antwortstil löschen? Ihre Unterhaltungen werden nicht gelöscht.",privacy:"Nur in diesem Browser gespeichert. Nichts wird hochgeladen oder mit einer externen KI geteilt.",topics:"Bevorzugte Themen"}
} as const;
const appearanceCopy={
  en:{title:"Appearance",help:"Choose the color theme used across the Family portal.",light:"Light",dark:"Dark",system:"System"},
  ar:{title:"المظهر",help:"اختر سمة الألوان المستخدمة في بوابة العائلة.",light:"فاتح",dark:"داكن",system:"حسب الجهاز"},
  fr:{title:"Apparence",help:"Choisissez le thème de couleurs du portail Famille.",light:"Clair",dark:"Sombre",system:"Système"},
  es:{title:"Apariencia",help:"Elige el tema de color del portal familiar.",light:"Claro",dark:"Oscuro",system:"Sistema"},
  de:{title:"Darstellung",help:"Wählen Sie das Farbschema für das Familienportal.",light:"Hell",dark:"Dunkel",system:"System"}
} as const;
const managementCopy={
  en:{moreMember:"More member actions",morePatient:"More patient actions",editMember:"Edit member",changeMemberPhoto:"Change member photo",changePatientPhoto:"Change patient photo",confirmRemove:(name:string)=>`Remove ${name} from the family account?`},
  ar:{moreMember:"المزيد من إجراءات الفرد",morePatient:"المزيد من إجراءات المريض",editMember:"تعديل الفرد",changeMemberPhoto:"تغيير صورة الفرد",changePatientPhoto:"تغيير صورة المريض",confirmRemove:(name:string)=>`هل تريد حذف ${name} من حساب العائلة؟`},
  fr:{moreMember:"Plus d’actions sur le membre",morePatient:"Plus d’actions sur le patient",editMember:"Modifier le membre",changeMemberPhoto:"Changer la photo du membre",changePatientPhoto:"Changer la photo du patient",confirmRemove:(name:string)=>`Supprimer ${name} du compte familial ?`},
  es:{moreMember:"Más acciones del familiar",morePatient:"Más acciones del paciente",editMember:"Editar familiar",changeMemberPhoto:"Cambiar foto del familiar",changePatientPhoto:"Cambiar foto del paciente",confirmRemove:(name:string)=>`¿Eliminar a ${name} de la cuenta familiar?`},
  de:{moreMember:"Weitere Mitgliederaktionen",morePatient:"Weitere Patientenaktionen",editMember:"Familienmitglied bearbeiten",changeMemberPhoto:"Mitgliederfoto ändern",changePatientPhoto:"Patientenfoto ändern",confirmRemove:(name:string)=>`${name} aus dem Familienkonto entfernen?`}
} as const;

const helpKeys = ["memories", "encouragement", "appointments", "messages", "reports", "ai", "shared", "privacy"] as const;
const helpIcons: Record<(typeof helpKeys)[number], string> = {
  memories: "M",
  encouragement: "E",
  appointments: "A",
  messages: "C",
  reports: "R",
  ai: "AI",
  shared: "F",
  privacy: "P",
};

export function FamilySettingsPage() {
  const { lang, t } = useI18n();
  const { preferences, update } = useFamilyPreferences();
  const { members, active, setActive, add, update: updateMember, remove, copy } = useFamilyMembers();
  const {patients,patient,setPatient:selectPatient,copy:patientCopy,name:patientName,relationship:patientRelationship,avatar:patientAvatar,setAvatar:savePatientAvatar,removeAvatar:removePatientAvatar}=useCurrentFamilyPatient();
  const [editing, setEditing] = useState<FamilyMember | "new" | null>(null);
  const [memberName, setMemberName] = useState("");
  const [memberRelationship, setMemberRelationship] = useState<FamilyRelationship>("son");
  const [memberAvatar,setMemberAvatar]=useState<string|undefined>();
  const [patientPhoto,setPatientPhoto]=useState<{id:string;preview:string}|null>(null);
  const [linkPatientOpen,setLinkPatientOpen]=useState(false);
  const [memberMenuId,setMemberMenuId]=useState<string|null>(null);
  const [patientMenuId,setPatientMenuId]=useState<string|null>(null);
  const photoCopy=familyMemberPhotoCopy[lang];
  const aiCopy=assistantMemoryCopy[lang];
  const themeCopy=appearanceCopy[lang];
  const menuCopy=managementCopy[lang];
  const {profile:aiProfile,global:aiGlobal,setStyle:setAiStyle,setGlobal:setAiGlobal,clear:clearAiMemory}=useFamilyAiPreferences();
  const learnedTopics=Object.entries(aiProfile.suggestionUsage).concat(Object.entries(aiProfile.feedbackScores)).reduce<Record<string,number>>((scores,[topic,value])=>({...scores,[topic]:(scores[topic]||0)+(value||0)}),{});
  const topTopics=Object.entries(learnedTopics).filter(([,score])=>score>0).sort((a,b)=>b[1]-a[1]).slice(0,3).map(([topic])=>topic);
  const editMember = (member?: FamilyMember) => { setEditing(member ?? "new"); setMemberName(member?.name ?? ""); setMemberRelationship(member?.relationship ?? "son"); setMemberAvatar(member?.avatar); };
  const saveMember = () => { const name = memberName.trim(); if (!name) return; if (editing === "new") add({ name, relationship: memberRelationship,avatar:memberAvatar }); else if (editing) updateMember({ ...editing, name, relationship: memberRelationship,avatar:memberAvatar }); setEditing(null); };
  const readAvatar=async(file?:File)=>{if(file)setMemberAvatar(await resizeFamilyMemberAvatar(file));};
  const replaceAvatar=async(member:FamilyMember,file?:File)=>{if(file)updateMember({...member,avatar:await resizeFamilyMemberAvatar(file)});};
  const previewPatientPhoto=async(id:string,file?:File)=>{if(file)setPatientPhoto({id,preview:await resizePatientAvatar(file)})};
  useEffect(()=>{const close=(event:PointerEvent)=>{if(!(event.target instanceof Element)||!event.target.closest(".settings-management-menu-wrap")){setMemberMenuId(null);setPatientMenuId(null)}};const escape=(event:KeyboardEvent)=>{if(event.key==="Escape"){setMemberMenuId(null);setPatientMenuId(null)}};document.addEventListener("pointerdown",close);document.addEventListener("keydown",escape);return()=>{document.removeEventListener("pointerdown",close);document.removeEventListener("keydown",escape)}},[]);

  return <div className="page page--wide family-settings">
    <section className="family-settings__hero" aria-labelledby="family-settings-title">
      <span className="eyebrow">{t("family.settingsEyebrow")}</span>
      <h1 id="family-settings-title">{t("family.settingsTitle")}</h1>
      <p>{t("family.settingsDescription")}</p>
    </section>

    <section className="family-settings__summary" aria-label={t("family.settingsGeneral")}>
      <article><span className="family-settings__summary-icon" aria-hidden="true">GL</span><div><small>{t("family.settingsCurrentLanguage")}</small><strong>{LANG_NAMES[lang]}</strong></div></article>
      <article><span className="family-settings__summary-icon family-settings__summary-icon--text" aria-hidden="true">Aa</span><div><small>{t("family.settingsTextSize")}</small><strong>{t(preferences.textSize === "standard" ? "family.settingsTextStandard" : "family.settingsTextLarger")}</strong></div></article>
      <article><span className="family-settings__summary-icon" aria-hidden="true">◐</span><div><small>{themeCopy.title}</small><strong>{themeCopy[preferences.theme]}</strong></div></article>
    </section>

    <section className="settings-card family-members-settings family-settings__full">
        <header><span aria-hidden="true">FM</span><div><h2>{copy.members}</h2><p>{copy.membersHelp}</p></div><button className="btn btn--gold btn--sm" onClick={() => editMember()}>+ {copy.add}</button></header>
        <p className="family-members-guidance">{copy.guidance}</p>
        <div className="family-members-list">{members.map((member) => <article className={active?.id === member.id ? "is-active" : ""} key={member.id}>
          <button className="family-member-select" onClick={() => setActive(member.id)}><FamilyMemberAvatar member={member}/><span><strong>{member.name}</strong><small>{copy.relationships[member.relationship]}</small></span>{active?.id === member.id && <b>✓</b>}</button>
          <div className="settings-card-actions">
            <button type="button" onClick={() => editMember(member)} aria-label={menuCopy.editMember} title={menuCopy.editMember}><span aria-hidden="true">✎</span>{copy.edit}</button>
            <label className="family-member-inline-photo" aria-label={menuCopy.changeMemberPhoto} title={menuCopy.changeMemberPhoto}><span aria-hidden="true">▣</span>{member.avatar?photoCopy.changePhoto:photoCopy.addPhoto}<input type="file" accept="image/*" onChange={(event)=>void replaceAvatar(member,event.target.files?.[0])}/></label>
            <div className="settings-management-menu-wrap"><button type="button" className="settings-more-action" aria-label={menuCopy.moreMember} title={menuCopy.moreMember} aria-expanded={memberMenuId===member.id} onClick={()=>{setPatientMenuId(null);setMemberMenuId(value=>value===member.id?null:member.id)}}>•••</button>{memberMenuId===member.id&&<div className="settings-management-menu">
              {member.avatar&&<button type="button" onClick={()=>{updateMember({...member,avatar:undefined});setMemberMenuId(null)}}>{photoCopy.removePhoto}</button>}
              <button type="button" className="is-danger" onClick={()=>{if(window.confirm(menuCopy.confirmRemove(member.name)))remove(member.id);setMemberMenuId(null)}}>{photoCopy.removeMember}</button>
            </div>}</div>
          </div>
        </article>)}</div>
        {editing && <div className="family-member-editor"><div className="family-member-photo-editor"><FamilyMemberAvatar member={{id:"preview",name:memberName||"Family",relationship:memberRelationship,avatar:memberAvatar}}/><label className="family-member-photo-button">{memberAvatar?photoCopy.changePhoto:photoCopy.addPhoto}<input type="file" accept="image/*" onChange={(event)=>void readAvatar(event.target.files?.[0])}/></label>{memberAvatar&&<button type="button" onClick={()=>setMemberAvatar(undefined)}>{photoCopy.removePhoto}</button>}</div><label>{copy.name}<input autoFocus value={memberName} onChange={(event) => setMemberName(event.target.value)} /></label><label>{copy.relationship}<select value={memberRelationship} onChange={(event) => setMemberRelationship(event.target.value as FamilyRelationship)}>{familyRelationshipOptions.map((relationship) => <option key={relationship} value={relationship}>{copy.relationships[relationship]}</option>)}</select></label><div><button onClick={() => setEditing(null)}>{copy.cancel}</button><button className="btn btn--gold btn--sm" disabled={!memberName.trim()} onClick={saveMember}>{copy.save}</button></div></div>}
    </section>
    <section className="settings-card linked-patients-settings family-settings__full">
        <header><span aria-hidden="true">PT</span><div><h2>{patientCopy.linked}</h2><p>{patientCopy.linkedHelp}</p></div><button className="btn btn--gold btn--sm" onClick={()=>setLinkPatientOpen(true)}>+ {patientCopy.link}</button></header>
        {patients.length?<div className="linked-patients-list">{patients.map(item=>{const preview=patientPhoto?.id===item.id?patientPhoto.preview:undefined,hasPhoto=Boolean(patientAvatar(item.id));return <article className={patient?.id===item.id?"is-active":""} key={item.id}><PatientAvatar patient={item} src={preview}/><div className="linked-patient-details"><strong>{patientName(item)}</strong><small>{patientRelationship(item)||patientCopy.patient}</small>{patient?.id===item.id&&<b>{patientCopy.current}</b>}</div><div className="linked-patient-actions settings-card-actions">
          {patient?.id!==item.id&&<button type="button" onClick={()=>selectPatient(item.id)}>{patientCopy.setCurrent}</button>}
          <label aria-label={menuCopy.changePatientPhoto} title={menuCopy.changePatientPhoto}><span aria-hidden="true">▣</span>{hasPhoto?patientCopy.changePhoto:patientCopy.addPhoto}<input type="file" accept="image/*" onChange={event=>void previewPatientPhoto(item.id,event.target.files?.[0])}/></label>
          {patientPhoto?.id===item.id&&<><button className="is-primary" onClick={()=>{savePatientAvatar(item.id,patientPhoto.preview);setPatientPhoto(null)}}>{patientCopy.save}</button><button onClick={()=>setPatientPhoto(null)}>{patientCopy.cancel}</button></>}
          {hasPhoto&&patientPhoto?.id!==item.id&&<div className="settings-management-menu-wrap"><button type="button" className="settings-more-action" aria-label={menuCopy.morePatient} title={menuCopy.morePatient} aria-expanded={patientMenuId===item.id} onClick={()=>{setMemberMenuId(null);setPatientMenuId(value=>value===item.id?null:item.id)}}>•••</button>{patientMenuId===item.id&&<div className="settings-management-menu"><button type="button" onClick={()=>{removePatientAvatar(item.id);setPatientMenuId(null)}}>{patientCopy.removePhoto}</button></div>}</div>}
        </div></article>})}</div>:<div className="linked-patients-empty"><strong>{patientCopy.none}</strong><p>{patientCopy.noneHelp}</p></div>}
    </section>

    <div className="family-settings__paired-row">
      <section className="settings-card general-settings">
        <header><span aria-hidden="true">GE</span><div><h2>{t("family.settingsGeneral")}</h2><p>{t("family.settingsGeneralHelp")}</p></div></header>
        <div className="settings-row settings-language-display"><span><strong>{t("family.settingsCurrentLanguage")}</strong><small>{t("family.settingsLanguageHelp")}</small></span><b>{LANG_NAMES[lang]}</b></div>
        <div className="settings-row settings-card__choice"><span><strong>{t("family.settingsTextSize")}</strong><small>{t("family.settingsTextSizeHelp")}</small></span><div>{(["standard", "larger"] as const).map((size) => <button className={preferences.textSize === size ? "is-active" : ""} type="button" key={size} onClick={() => update({ textSize: size })}>{t(size === "standard" ? "family.settingsTextStandard" : "family.settingsTextLarger")}</button>)}</div></div>
      </section>
      <section className="settings-card appearance-settings">
        <header><span aria-hidden="true">◐</span><div><h2>{themeCopy.title}</h2><p>{themeCopy.help}</p></div></header>
        <div className="settings-row settings-card__choice"><span><strong>{themeCopy.title}</strong><small>{themeCopy.help}</small></span><div>{(["light","dark","system"] as const).map(theme=><button type="button" className={preferences.theme===theme?"is-active":""} key={theme} onClick={()=>update({theme})}>{themeCopy[theme]}</button>)}</div></div>
      </section>
    </div>

      <section className="settings-card comfort-settings family-settings__full">
        <header><span aria-hidden="true">AC</span><div><h2>{t("family.settingsComfort")}</h2><p>{t("family.settingsComfortHelp")}</p></div></header>
        <div className="family-settings__ease-grid">
        <label className="settings-toggle settings-row"><span><strong>{t("family.settingsReduceMotion")}</strong><small>{t("family.settingsReduceMotionHelp")}</small></span><input type="checkbox" checked={preferences.reduceMotion} onChange={(event) => update({ reduceMotion: event.target.checked })} /></label>
        <label className="settings-toggle settings-row"><span><strong>{t("family.settingsAutoplay")}</strong><small>{t("family.settingsAutoplayHelp")}</small></span><input type="checkbox" checked={preferences.autoplayHero} onChange={(event) => update({ autoplayHero: event.target.checked })} /></label>
        </div>
      </section>
      <section className="settings-card privacy-settings family-settings__full"><header><span aria-hidden="true">PR</span><div><h2>{t("family.settingsPrivacy")}</h2><p>{t("family.settingsPrivacyBody")}</p></div></header></section>

      <section className="settings-card assistant-memory-settings family-settings__full">
        <header><span aria-hidden="true">AI</span><div><h2>{aiCopy.title}</h2><p>{aiCopy.description}</p></div></header>
        <label className="settings-toggle settings-row"><span><strong>{aiCopy.remember}</strong><small>{aiCopy.rememberHelp}</small></span><input type="checkbox" checked={aiGlobal.rememberPreferences} onChange={event=>setAiGlobal({rememberPreferences:event.target.checked})}/></label>
        <label className="settings-toggle settings-row"><span><strong>{aiCopy.context}</strong><small>{aiCopy.contextHelp}</small></span><input type="checkbox" checked={aiGlobal.usePatientContext} onChange={event=>setAiGlobal({usePatientContext:event.target.checked})}/></label>
        <label className="settings-toggle settings-row"><span><strong>{aiCopy.personalize}</strong><small>{aiCopy.personalizeHelp}</small></span><input type="checkbox" checked={aiGlobal.personalizeSuggestions} onChange={event=>setAiGlobal({personalizeSuggestions:event.target.checked})}/></label>
        <div className="settings-row settings-card__choice assistant-memory-style"><span><strong>{aiCopy.style}</strong><small>{aiCopy.styleHelp}</small></span><div>{(["short","balanced","detailed"] as AnswerStyle[]).map(style=><button type="button" className={aiProfile.responseStyle===style?"is-active":""} key={style} onClick={()=>setAiStyle(style)}>{aiCopy[style]}</button>)}</div></div>
        <div className="assistant-memory-summary"><strong>{aiCopy.remembered}</strong><p>{topTopics.length?`${aiCopy.topics}: ${topTopics.join(", ")}`:aiCopy.none}</p></div>
        <p className="assistant-memory-privacy">{aiCopy.privacy}</p>
        <button type="button" className="assistant-memory-clear" onClick={()=>{if(window.confirm(aiCopy.confirm))clearAiMemory()}}>{aiCopy.clear}</button>
      </section>
    <section className="settings-card family-settings__about family-settings__full"><header><span aria-hidden="true">NB</span><div><h2>{t("family.settingsAbout")}</h2><strong>NeuroBridge</strong><p>{t("family.settingsAboutBody")}</p></div></header></section>
    <section className="settings-card family-settings__guidance family-settings__guidance--full"><header><span aria-hidden="true">?</span><div><h2>{t("family.settingsGuidance")}</h2><p>{t("family.settingsGuidanceHelp")}</p></div></header><div>{helpKeys.map((key) => <details key={key}><summary><span className="settings-help-icon" aria-hidden="true">{helpIcons[key]}</span><strong>{t(`family.help.${key}Title` as Parameters<typeof t>[0])}</strong><i aria-hidden="true">+</i></summary><p>{t(`family.help.${key}Body` as Parameters<typeof t>[0])}</p></details>)}</div></section>
    <LinkPatientDialog open={linkPatientOpen} onClose={()=>setLinkPatientOpen(false)}/>
  </div>;
}
