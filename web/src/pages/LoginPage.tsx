import { useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";

import { ApiError } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import { LanguageSwitcher } from "../components/LanguageSwitcher";
import { useI18n } from "../i18n/useI18n";
import type { Lang } from "../i18n/translations";

const HERO_TEXT: Record<Lang, string> = {
  ar: "نقرّب القلوب والجهود حول المريض، لتصبح المتابعة أكثر وضوحًا ودفئًا",
  en: "Bringing hearts and care teams closer around every patient.",
  fr: "Rapprocher les familles et les équipes de soins autour de chaque patient.",
  es: "Acercamos a las familias y a los equipos de atención alrededor de cada paciente.",
  de: "Wir bringen Familien und Betreuungsteams rund um jeden Patienten zusammen.",
};

export function LoginPage() {
  const { login } = useAuth();
  const { t, lang } = useI18n();
  const navigate = useNavigate();

  const [emailOrPhone, setEmailOrPhone] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [logoFailed, setLogoFailed] = useState(false);

  const onSubmit = async (event: FormEvent) => {
    event.preventDefault();

    setError(null);
    setBusy(true);

    try {
      await login(emailOrPhone.trim(), password);

      navigate("/", {
        replace: true,
      });
    } catch (err) {
      const message =
        err instanceof ApiError
          ? err.status === 401
            ? t("login.invalid")
            : err.message
          : t("login.genericError");

      setError(message);
      setBusy(false);
    }
  };

  return (
    <div className="login login--hero">
      {/* زر تغيير اللغة */}
      <div className="login__language">
        <LanguageSwitcher />
      </div>

      <div className="login__center">
        <header className="login__hero">
          <h2 className="login__hero-brand">NeuroBridge</h2>

          <span className="login__hero-rule" aria-hidden="true">
            <i />
          </span>

          <p className="login__hero-line" lang={lang}>
            {HERO_TEXT[lang]}
          </p>
        </header>

        <div className="login__card">
          <div className="login__brand">
            <span
              className={`brand-mark brand-mark--lg brand-mark--logo ${
                logoFailed ? "brand-mark--fallback" : ""
              }`}
              aria-hidden="true"
            >
              {logoFailed ? (
                "NB"
              ) : (
                <img
                  className="brand-mark__img"
                  src="/neurobridge-logo-mark.png"
                  alt=""
                  onError={() => setLogoFailed(true)}
                />
              )}
            </span>

            <div>
              <strong>NeuroBridge</strong>
              <span>{t("login.brandSub")}</span>
            </div>
          </div>

          <h1>{t("login.signIn")}</h1>

          <p className="login__lead">{t("login.lead")}</p>

          <form className="login__form" onSubmit={onSubmit}>
            <label>
              {t("login.emailOrPhone")}

              <input
                type="text"
                autoComplete="username"
                value={emailOrPhone}
                onChange={(event) => {
                  setEmailOrPhone(event.target.value);
                }}
                placeholder="you@neurobridge.local"
                required
              />
            </label>

            <label>
              {t("login.password")}

              <input
                type="password"
                autoComplete="current-password"
                value={password}
                onChange={(event) => {
                  setPassword(event.target.value);
                }}
                placeholder={t("login.passwordPlaceholder")}
                required
              />
            </label>

            {error && (
              <div className="login__error" role="alert">
                {error}
              </div>
            )}

            <button
              type="submit"
              className="btn btn--gold btn--block"
              disabled={busy}
            >
              {busy ? t("login.signingIn") : t("login.signIn")}
            </button>

            <button type="button" className="login__forgot">
              {t("login.forgotPassword")}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}