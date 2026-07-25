import { useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import { ApiError } from "../api/client";
import { useI18n } from "../i18n/useI18n";

export function LoginPage() {
  const { login } = useAuth();
  const { t } = useI18n();
  const navigate = useNavigate();
  const [emailOrPhone, setEmailOrPhone] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [logoFailed, setLogoFailed] = useState(false);

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    setBusy(true);
    try {
      // Both the clinical (doctor/therapist) and family portals share this
      // sign-in. Role-based routing decides which dashboard to show; an
      // unsupported role lands on a clear access message (see App routing).
      await login(emailOrPhone.trim(), password);
      navigate("/", { replace: true });
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
      <div className="login__center">
        {/* Brand "poster" moment: the wordmark stands alone above a fixed
            Arabic line. The form below still follows the interface language. */}
        <header className="login__hero">
          <h2 className="login__hero-brand">NeuroBridge</h2>
          <span className="login__hero-rule" aria-hidden="true">
            <i />
          </span>
          <p className="login__hero-line" dir="rtl" lang="ar">
            نقرب القلوب والجهود حول المريض، لتصبح المتابعة أكثر وضوحًا ودفئًا
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
              <strong>
                NeuroBridge
              </strong>
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
                onChange={(e) => setEmailOrPhone(e.target.value)}
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
                onChange={(e) => setPassword(e.target.value)}
                placeholder={t("login.passwordPlaceholder")}
                required
              />
            </label>

            {error && <div className="login__error">{error}</div>}

            <button className="btn btn--gold btn--block" disabled={busy}>
              {busy ? t("login.signingIn") : t("login.signIn")}
            </button>

            {/* Placeholder — a full reset flow is not wired up yet. */}
            <button type="button" className="login__forgot">
              {t("login.forgotPassword")}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
