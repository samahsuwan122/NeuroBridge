import { useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";
import { ApiError, setToken } from "../api/client";

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
      const roles = await login(emailOrPhone.trim(), password);
      const isClinician = roles.includes("doctor") || roles.includes("therapist");
      if (!isClinician) {
        // Not a doctor/therapist — this portal is clinical only.
        setToken(null);
        setError(
          "This portal is for doctors and therapists. Patients and families use the NeuroBridge mobile app.",
        );
        setBusy(false);
        return;
      }
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
            <span>Clinical Dashboard</span>
          </div>
        </div>
        <h1>Doctor &amp; therapist sign in</h1>
        <p className="login__lead">
          Review assigned patients, cognitive exercise performance, memory album
          entries, and AI-assisted summaries — a supportive, non-diagnostic
          clinical view.
        </p>

        <form className="login__form" onSubmit={onSubmit}>
          <label>
            Email or phone
            <input
              type="text"
              autoComplete="username"
              value={emailOrPhone}
              onChange={(e) => setEmailOrPhone(e.target.value)}
              placeholder="doctor.demo@neurobridge.local"
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
          Demo clinician: <code>doctor.demo@neurobridge.local</code> ·{" "}
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
            <li>Assigned patients only, with role-based access</li>
            <li>Performance-only progress and session history</li>
            <li>Memory album review for supportive recall</li>
            <li>AI-assisted summaries, pending your review</li>
          </ul>
          <p className="login__aside-note">
            Not a diagnostic medical system. Not a medical assessment.
          </p>
        </div>
      </aside>
    </div>
  );
}
