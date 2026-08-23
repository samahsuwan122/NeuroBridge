import { useEffect, useState } from "react";

export interface FamilyPreferences {
  textSize: "standard" | "larger";
  reduceMotion: boolean;
  autoplayHero: boolean;
  theme: "light" | "dark" | "system";
}

const KEY = "nb_family_preferences";
const EVENT = "nb-family-preferences";
const defaults: FamilyPreferences = { textSize: "standard", reduceMotion: false, autoplayHero: true, theme: "system" };

function read(): FamilyPreferences {
  try { return { ...defaults, ...JSON.parse(localStorage.getItem(KEY) ?? "{}") }; } catch { return defaults; }
}

export function useFamilyPreferences() {
  const [preferences, setPreferences] = useState<FamilyPreferences>(read);
  useEffect(() => {
    const sync = () => setPreferences(read());
    window.addEventListener(EVENT, sync);
    return () => window.removeEventListener(EVENT, sync);
  }, []);
  useEffect(() => {
    document.documentElement.dataset.familyTextSize = preferences.textSize;
    document.documentElement.dataset.familyReduceMotion = String(preferences.reduceMotion);
    document.documentElement.dataset.familyTheme = preferences.theme;
    const media=window.matchMedia("(prefers-color-scheme: dark)");
    const apply=()=>{document.documentElement.dataset.theme=preferences.theme==="system"?(media.matches?"dark":"light"):preferences.theme};
    apply();media.addEventListener("change",apply);return()=>media.removeEventListener("change",apply);
  }, [preferences]);
  const update = (patch: Partial<FamilyPreferences>) => {
    const next = { ...read(), ...patch };
    localStorage.setItem(KEY, JSON.stringify(next));
    setPreferences(next);
    window.dispatchEvent(new Event(EVENT));
  };
  return { preferences, update };
}
