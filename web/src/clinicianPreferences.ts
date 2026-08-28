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

function read(): ClinicianPreferences { try { return {...defaults,...JSON.parse(localStorage.getItem(KEY)||"{}")}; } catch { return defaults; } }

export function useClinicianPreferences() {
  const [preferences,setPreferences]=useState<ClinicianPreferences>(read);
  useEffect(()=>{const sync=()=>setPreferences(read());window.addEventListener(EVENT,sync);return()=>window.removeEventListener(EVENT,sync)},[]);
  useEffect(()=>{document.documentElement.dataset.familyTextSize=preferences.textSize;document.documentElement.dataset.familyReduceMotion=String(preferences.reduceMotion);const media=window.matchMedia("(prefers-color-scheme: dark)");const apply=()=>{document.documentElement.dataset.theme=preferences.theme==="system"?(media.matches?"dark":"light"):preferences.theme};apply();media.addEventListener("change",apply);return()=>media.removeEventListener("change",apply)},[preferences.theme,preferences.textSize,preferences.reduceMotion]);
  const update=(patch:Partial<ClinicianPreferences>)=>{const next={...read(),...patch};localStorage.setItem(KEY,JSON.stringify(next));setPreferences(next);window.dispatchEvent(new Event(EVENT))};
  return {preferences,update};
}
