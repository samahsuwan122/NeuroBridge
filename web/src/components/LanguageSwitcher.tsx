import { useEffect, useRef, useState } from "react";
import { useI18n } from "../i18n/useI18n";
import { LANGS, LANG_NAMES } from "../i18n/translations";

/**
 * Warm cream language switcher for the portal topbar: a pill button with a
 * currentColor globe (no blue emoji) and a small dropdown. Closes on select,
 * Escape, or outside click; persists via the provider (localStorage).
 */
export function LanguageSwitcher() {
  const { lang, setLang, t } = useI18n();
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!open) return;
    const onDown = (e: MouseEvent) => {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    };
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") setOpen(false);
    };
    document.addEventListener("mousedown", onDown);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("mousedown", onDown);
      document.removeEventListener("keydown", onKey);
    };
  }, [open]);

  return (
    <div className="portal-lang" ref={ref}>
      <button
        type="button"
        className="portal-lang__btn"
        aria-haspopup="menu"
        aria-expanded={open}
        aria-label={t("lang.aria")}
        onClick={() => setOpen((v) => !v)}
      >
        <svg
          className="portal-lang__globe"
          viewBox="0 0 24 24"
          width="18"
          height="18"
          fill="none"
          stroke="currentColor"
          strokeWidth="1.7"
          strokeLinecap="round"
          aria-hidden="true"
        >
          <circle cx="12" cy="12" r="9" />
          <path d="M3 12h18" />
          <path d="M12 3c2.6 2.6 3.9 5.8 3.9 9s-1.3 6.4-3.9 9c-2.6-2.6-3.9-5.8-3.9-9S9.4 5.6 12 3z" />
        </svg>
        <span className="portal-lang__code">{lang.toUpperCase()}</span>
        <svg
          className="portal-lang__chev"
          viewBox="0 0 24 24"
          width="12"
          height="12"
          fill="none"
          stroke="currentColor"
          strokeWidth="2.2"
          strokeLinecap="round"
          strokeLinejoin="round"
          aria-hidden="true"
        >
          <path d="M6 9l6 6 6-6" />
        </svg>
      </button>

      {open && (
        <ul className="portal-lang__menu" role="menu">
          {LANGS.map((l) => (
            <li key={l} role="none">
              <button
                type="button"
                role="menuitemradio"
                lang={l}
                aria-checked={l === lang}
                className={`portal-lang__item ${l === lang ? "is-active" : ""}`}
                onClick={() => {
                  setLang(l);
                  setOpen(false);
                }}
              >
                <span>{LANG_NAMES[l]}</span>
                {l === lang && (
                  <span className="portal-lang__check" aria-hidden="true">
                    ✓
                  </span>
                )}
              </button>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
