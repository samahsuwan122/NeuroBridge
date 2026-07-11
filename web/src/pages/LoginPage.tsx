import { useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import { ApiError } from "../api/client";

export function LoginPage() {
  const { login } = useAuth();
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
            ? "Invalid email/phone or password."
            : err.message
          : "Something went wrong. Please try again.";
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
            <span>Care Team &amp; Family Portal</span>
          </div>
        </div>
        <h1>Sign in</h1>
        <p className="login__lead">
          For the care team and families. Doctors and therapists open the
          clinical dashboard; families open a supportive view of their linked
          patient&apos;s journey — a non-diagnostic, performance-only experience.
        </p>

        <form className="login__form" onSubmit={onSubmit}>
          <label>
            Email or phone
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
            Password
            <input
              type="password"
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Your password"
              required
            />
          </label>

          {error && <div className="login__error">{error}</div>}

          <button className="btn btn--gold btn--block" disabled={busy}>
            {busy ? "Signing in…" : "Sign in"}
          </button>
        </form>

        <p className="login__hint">
          Demo clinician: <code>doctor.demo@neurobridge.local</code>
          <br />
          Demo family: <code>family.demo@neurobridge.local</code> ·{" "}
          <code>Demo12345!</code>
        </p>
      </div>

      <aside className="login__aside">
        <div className="login__aside-inner">
          <span className="eyebrow eyebrow--gold">
            AI-Powered Cognitive Rehabilitation Ecosystem
          </span>
          <h2>A shared, continuous view of the care journey</h2>
          <ul className="ticks">
            <li>Care team: assigned patients, with role-based access</li>
            <li>Families: your linked patient&apos;s supportive journey</li>
            <li>Performance-only progress and memory album for recall</li>
            <li>Non-diagnostic by design — never a medical assessment</li>
          </ul>
          <p className="login__aside-note">
            Not a diagnostic medical system. Not a medical assessment.
          </p>
        </div>
      </aside>
    </div>
  );
}
