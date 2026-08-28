import { useEffect,useState } from "react";

export type ClinicianNotificationCategory="messages"|"appointments"|"review"|"activity";
export type ClinicianNotificationPreferences=Record<ClinicianNotificationCategory,boolean>;
const defaults:ClinicianNotificationPreferences={messages:true,appointments:true,review:true,activity:true};
const EVENT="nb-clinician-notification-preferences";
export const clinicianNotificationPreferenceKey=(providerUserId:string)=>`nb_clinician_notification_preferences:${providerUserId}`;

function read(providerUserId:string):ClinicianNotificationPreferences{
 try{return{...defaults,...JSON.parse(localStorage.getItem(clinicianNotificationPreferenceKey(providerUserId))||"{}")}}
 catch{return defaults}
}

export function useClinicianNotificationPreferences(providerUserId:string){
 const [preferences,setPreferences]=useState(()=>read(providerUserId));
 useEffect(()=>{setPreferences(read(providerUserId));const sync=()=>setPreferences(read(providerUserId));window.addEventListener(EVENT,sync);return()=>window.removeEventListener(EVENT,sync)},[providerUserId]);
 const update=(category:ClinicianNotificationCategory,enabled:boolean)=>{const next={...read(providerUserId),[category]:enabled};localStorage.setItem(clinicianNotificationPreferenceKey(providerUserId),JSON.stringify(next));setPreferences(next);window.dispatchEvent(new Event(EVENT))};
 return{preferences,update};
}
