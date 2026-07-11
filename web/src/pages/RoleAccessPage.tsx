import { useNavigate } from "react-router-dom";
import { useAuth } from "../auth/AuthContext";

// Shown when a signed-in user's role has no web portal (e.g. a patient).
export function RoleAccessPage() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate("/login", { replace: true });
  };

  return (
    <div className="login">
      <div className="login__panel">
        <div className="login__brand">
          <span className="brand-mark brand-mark--lg" aria-hidden="true">
            NB
          </span>
          <div>
            <strong>NeuroBridge</strong>
            <span>Care Team &amp; Family Portal</span>
          </div>
        </div>
        <h1>No web access for this account</h1>
        <p className="login__lead">
          {user?.full_name ? `${user.full_name}, your ` : "Your "}
          account role does not have access to the NeuroBridge web portal. The
          web portal is available to the <strong>care team</strong> (doctors and
          therapists) and to <strong>families/caregivers</strong>. Patients use
          the NeuroBridge mobile app.
        </p>
        <button className="btn btn--gold" onClick={handleLogout}>
          Log out
        </button>
        <p className="login__hint">
          If you believe this is a mistake, please contact your administrator.
        </p>
      </div>

      <aside className="login__aside">
        <div className="login__aside-inner">
          <span className="eyebrow eyebrow--gold">NeuroBridge</span>
          <h2>Role-based access keeps data safe</h2>
          <p className="login__aside-note">
            Not a diagnostic medical system. Not a medical assessment.
          </p>
        </div>
      </aside>
    </div>
  );
}
