import type { PatientProfile,Provider } from "../types";

export type FamilyAiActionStatus="pending"|"confirmed"|"completed"|"cancelled"|"failed";
export type FamilyAiAction=
 |{type:"change_patient_avatar";patientId:string;attachmentUrl:string;status:FamilyAiActionStatus}
 |{type:"add_memory";patientId:string;attachmentUrl?:string;title:string;status:FamilyAiActionStatus}
 |{type:"create_encouragement";patientId:string;text:string;status:FamilyAiActionStatus}
 |{type:"open_provider_chat";patientId:string;providerId?:string;providerName?:string;draftMessage?:string;status:FamilyAiActionStatus}
 |{type:"navigate";route:string;status:FamilyAiActionStatus}
 |{type:"switch_patient";patientId:string;status:FamilyAiActionStatus};

export type ParseResult={action?:FamilyAiAction;missing?:"image"|"patient"|"provider";medical?:boolean;payment?:boolean};
const normalize=(value:string)=>value.toLowerCase().normalize("NFKD").replace(/[أإآ]/g,"ا").replace(/[ًٌٍَُِّْـ]/g,"").replace(/[^\p{L}\p{N}\s]/gu," ").replace(/\s+/g," ").trim();
const includesAny=(value:string,words:string[])=>words.some(word=>value.includes(normalize(word)));
const patientMatch=(raw:string,patients:PatientProfile[],current:PatientProfile|null)=>{const n=normalize(raw),explicit=patients.filter(item=>{const name=normalize(item.user?.full_name||"");return name&&n.includes(name)});if(explicit.length===1)return explicit[0];if(explicit.length>1)return null;if(includesAny(n,["current patient","this patient","المريض الحالي","له","الها","patient actuel","paciente actual","aktueller patient"]))return current;return current};
const providerMatch=(raw:string,providers:Provider[])=>{const n=normalize(raw),matches=providers.filter(item=>n.includes(normalize(item.full_name))||n.includes(normalize(item.full_name.replace(/^(dr\.?|doctor)\s+/i,""))));if(matches.length===1)return matches[0];const role=includesAny(n,["therapist","المعالج","المعالجـ","thérapeute","terapeuta"])?"therapist":includesAny(n,["doctor","dr","الدكتور","الطبيب","médecin","arzt"])?"doctor":"";const byRole=role?providers.filter(item=>item.role===role):[];return byRole.length===1?byRole[0]:null};
const routes:[string,string[]][]=[
 ["/memories",["افتح الذكريات","روح للذكريات","open memories","ouvrir les souvenirs","abrir recuerdos","erinnerungen öffnen"]],
 ["/appointments",["افتح المواعيد","روح عالمواعيد","open appointments","ouvrir les rendez-vous","abrir citas","termine öffnen"]],
 ["/reports",["افتح التقارير","open reports","ouvrir les rapports","abrir informes","berichte öffnen"]],
 ["/billing",["افتح المدفوعات","وديني على المدفوعات","open billing","open payments","ouvrir la facturation","abrir pagos","zahlungen öffnen"]],
 ["/messages",["افتح الرسائل","open messages","ouvrir les messages","abrir mensajes","nachrichten öffnen"]],
 ["/settings",["افتح الاعدادات","open settings","ouvrir les paramètres","abrir ajustes","einstellungen öffnen"]],
 ["/encouragement",["افتح التشجيع","open encouragement","ouvrir les encouragements","abrir ánimo","ermutigungen öffnen"]],
 ["/",["افتح النظره العامه","open overview","ouvrir l aperçu","abrir resumen","übersicht öffnen"]]
];

export function parseFamilyAiAction(raw:string,patients:PatientProfile[],current:PatientProfile|null,providers:Provider[],imageUrl?:string):ParseResult{
 const n=normalize(raw);if(includesAny(n,["دواء","علاج","تشخيص","medication","medicine","treatment","diagnose","médicament","traitement","medicamento","medikament","behandlung"]))return{medical:true};
 if(includesAny(n,["ادفع","pay appointment","make payment","payer","pagar","bezahlen"]))return{payment:true};
 const patient=patientMatch(raw,patients,current);
 const avatar=includesAny(n,["صوره شخصيه","صورة شخصية","صوره المريض","صورة المريض","حط هاي صوره","خلي هاي صوره","profile picture","patient avatar","use this as","set this photo","photo de profil","foto de perfil","profilbild"]);
 const memory=includesAny(n,["ذكرى","ذكريات","memory","memories","souvenir","recuerdo","erinnerung"]);
 if(avatar&&!memory){if(!imageUrl)return{missing:"image"};if(!patient)return{missing:"patient"};return{action:{type:"change_patient_avatar",patientId:patient.id,attachmentUrl:imageUrl,status:"pending"}}}
 if(memory&&includesAny(n,["ضيف","اضف","خليها","اعمل منها","add","save","ajouter","guardar","speichern"])){if(!patient)return{missing:"patient"};if(!imageUrl)return{missing:"image"};const title=(raw.match(/(?:اسمها|title(?:d)?|named)\s+(.+)$/i)?.[1]||"").trim();return{action:{type:"add_memory",patientId:patient.id,attachmentUrl:imageUrl,title:title||"",status:"pending"}}}
 if(includesAny(n,["تشجيع","انا فخور","رساله لطيفه","encourag","supportive message","proud of you","message de soutien","mensaje de ánimo","ermutigung"])){if(!patient)return{missing:"patient"};const exact=raw.match(/(?:ابعتله|قل له|saying|say)\s+(.+)$/i)?.[1]?.trim();return{action:{type:"create_encouragement",patientId:patient.id,text:exact||"",status:"pending"}}}
 if(includesAny(n,["بدل","غير المريض","اتابع","switch patient","change patient","changer de patient","cambiar paciente","patient wechseln"])){const explicit=patients.filter(item=>n.includes(normalize(item.user?.full_name||"")));if(explicit.length!==1)return{missing:"patient"};return{action:{type:"switch_patient",patientId:explicit[0].id,status:"completed"}}}
 if(includesAny(n,["محادثه مع","اكتب للدكتور","اكتب للمعالج","احكي مع","provider chat","open dr","prepare a message","écrire au","mensaje al","nachricht an"])){if(!patient)return{missing:"patient"};const provider=providerMatch(raw,providers);if(!provider)return{missing:"provider"};const wantsDraft=includesAny(n,["اكتب","جهز","prepare","write","écrire","redactar","schreib"]);return{action:{type:"open_provider_chat",patientId:patient.id,providerId:provider.provider_user_id,providerName:provider.full_name,draftMessage:wantsDraft?raw:undefined,status:wantsDraft?"pending":"completed"}}}
 for(const[route,triggers]of routes)if(includesAny(n,triggers))return{action:{type:"navigate",route,status:"completed"}};
 return{};
}
