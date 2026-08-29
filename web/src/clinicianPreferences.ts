import { useEffect, useState } from "react";

export interface ClinicianPreferences {
  theme: "light" | "dark" | "system";
  textSize: "standard" | "larger";
  reduceMotion: boolean;
  aiResponseStyle: "short" | "balanced" | "detailed";
  aiUsePatientContext: boolean;
  aiRememberPreferences: boolean;
}

const KEY = "nb_clinician_preferences";
const EVENT = "nb-clinician-preferences";
const defaults: ClinicianPreferences = { theme:"system", textSize:"standard", reduceMotion:false, aiResponseStyle:"balanced", aiUsePatientContext:true, aiRememberPreferences:true };

const preferenceKey=(userId?:string)=>userId?`${KEY}:${userId}`:KEY;
function read(userId?:string,migrateLegacy=false): ClinicianPreferences { try {const key=preferenceKey(userId);let raw=localStorage.getItem(key);const marker=`${key}:migrated`;if(!raw&&migrateLegacy&&userId&&!localStorage.getItem(marker)){raw=localStorage.getItem(KEY);if(raw)localStorage.setItem(key,raw);localStorage.setItem(marker,"1")}return {...defaults,...JSON.parse(raw||"{}")}; } catch { return defaults; } }

export function useClinicianPreferences(userId?:string,migrateLegacy=false) {
  const [preferences,setPreferences]=useState<ClinicianPreferences>(()=>read(userId,migrateLegacy));
  useEffect(()=>{setPreferences(read(userId,migrateLegacy));const sync=()=>setPreferences(read(userId,migrateLegacy));window.addEventListener(EVENT,sync);return()=>window.removeEventListener(EVENT,sync)},[userId,migrateLegacy]);
  useEffect(()=>{document.documentElement.dataset.familyTextSize=preferences.textSize;document.documentElement.dataset.familyReduceMotion=String(preferences.reduceMotion);const media=window.matchMedia("(prefers-color-scheme: dark)");const apply=()=>{document.documentElement.dataset.theme=preferences.theme==="system"?(media.matches?"dark":"light"):preferences.theme};apply();media.addEventListener("change",apply);return()=>media.removeEventListener("change",apply)},[preferences.theme,preferences.textSize,preferences.reduceMotion]);
  const update=(patch:Partial<ClinicianPreferences>)=>{const next={...read(userId,migrateLegacy),...patch};localStorage.setItem(preferenceKey(userId),JSON.stringify(next));setPreferences(next);window.dispatchEvent(new Event(EVENT))};
  return {preferences,update};
}
