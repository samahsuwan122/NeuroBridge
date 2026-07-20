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
    <div className="login">
      <div className="login__panel">
        <div className="login__brand">
          <span className="brand-mark brand-mark--lg" aria-hidden="true">
            NB
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
        </form>

        <p className="login__hint">
          {t("login.demoClinician")} <code>doctor.demo@neurobridge.local</code>
          <br />
          {t("login.demoFamily")} <code>family.demo@neurobridge.local</code> ·{" "}
          <code>Demo12345!</code>
        </p>
      </div>

      <aside className="login__aside">
        <div className="login__aside-inner">
          <span className="eyebrow eyebrow--gold">{t("login.asideEyebrow")}</span>
          <h2>{t("login.asideTitle")}</h2>
          <ul className="ticks">
            <li>{t("login.tick1")}</li>
            <li>{t("login.tick2")}</li>
            <li>{t("login.tick3")}</li>
            <li>{t("login.tick4")}</li>
          </ul>
        </div>
      </aside>
    </div>
  );
}
