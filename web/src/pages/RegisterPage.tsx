import {
  useState,
  type FormEvent,
} from "react";
import { Link } from "react-router-dom";

type RegistrationRole =
  | "doctor"
  | "therapist"
  | "family";

interface RegisterResponse {
  success: boolean;
  message: string;
}

const API_URL =
  (
    import.meta.env
      .VITE_WEB_ACCOUNT_API_URL as
      | string
      | undefined
  ) ??
  "https://toyoraljana.com/api_web";

export function RegisterPage() {
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [phone, setPhone] = useState("");
  const [password, setPassword] =
    useState("");
  const [
    confirmPassword,
    setConfirmPassword,
  ] = useState("");
  const [role, setRole] =
    useState<RegistrationRole | "">("");
  const [
    preferredLanguage,
    setPreferredLanguage,
  ] = useState("ar");

  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] =
    useState("");

  const submit = async (
    event: FormEvent,
  ) => {
    event.preventDefault();

    setError("");
    setSuccess("");

    if (!role) {
      setError(
        "يرجى اختيار دكتور أو معالج أو عائلة",
      );
      return;
    }

    if (password.length < 8) {
      setError(
        "كلمة المرور يجب أن تكون 8 خانات على الأقل",
      );
      return;
    }

    if (password !== confirmPassword) {
      setError(
        "كلمتا المرور غير متطابقتين",
      );
      return;
    }

    setBusy(true);

    try {
      const response = await fetch(
        `${API_URL.replace(/\/+$/, "")}/register.php`,
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            full_name: fullName.trim(),
            email: email.trim(),
            phone: phone.trim(),
            password,
            confirm_password: confirmPassword,
            role,
            preferred_language: preferredLanguage,
          }),
        },
      );

      const data =
        (await response.json()) as RegisterResponse;

      if (!response.ok) {
        throw new Error(
          data.message ||
            "تعذر إنشاء الحساب",
        );
      }

      setSuccess(data.message);
      setFullName("");
      setEmail("");
      setPhone("");
      setPassword("");
      setConfirmPassword("");
      setRole("");
    } catch (reason) {
      setError(
        reason instanceof Error
          ? reason.message
          : "تعذر إنشاء الحساب",
      );
    } finally {
      setBusy(false);
    }
  };

  if (success) {
    return (
      <div className="register-page">
        <section className="register-card">
          <div className="register-success">
            <span className="register-logo">
              NB
            </span>

            <h1>تم استلام طلبك</h1>
            <p>{success}</p>

            <Link
              className="btn btn--gold"
              to="/login"
            >
              العودة إلى تسجيل الدخول
            </Link>
          </div>
        </section>
      </div>
    );
  }

  return (
    <div
      className="register-page"
      dir="rtl"
    >
      <section className="register-card">
        <header className="register-head">
          <span className="register-logo">
            NB
          </span>

          <div>
            <span className="eyebrow">
              NeuroBridge
            </span>
            <h1>إنشاء حساب جديد</h1>
            <p>
              أدخل معلوماتك واختر نوع الحساب
              الذي يناسبك.
            </p>
          </div>
        </header>

        <form
          className="register-form"
          onSubmit={submit}
        >
          {error && (
            <div
              className="login__error"
              role="alert"
            >
              {error}
            </div>
          )}

          <div className="register-grid">
            <label>
              الاسم الكامل

              <input
                type="text"
                required
                maxLength={150}
                value={fullName}
                onChange={(event) =>
                  setFullName(
                    event.target.value,
                  )
                }
              />
            </label>

            <label>
              البريد الإلكتروني

              <input
                type="email"
                required
                maxLength={190}
                value={email}
                onChange={(event) =>
                  setEmail(
                    event.target.value,
                  )
                }
              />
            </label>

            <label>
              رقم الهاتف

              <input
                type="tel"
                maxLength={30}
                value={phone}
                onChange={(event) =>
                  setPhone(
                    event.target.value,
                  )
                }
              />
            </label>

            <label>
              اللغة المفضلة

              <select
                value={preferredLanguage}
                onChange={(event) =>
                  setPreferredLanguage(
                    event.target.value,
                  )
                }
              >
                <option value="ar">
                  العربية
                </option>
                <option value="en">
                  English
                </option>
                <option value="fr">
                  Français
                </option>
                <option value="es">
                  Español
                </option>
                <option value="de">
                  Deutsch
                </option>
              </select>
            </label>

            <label>
              كلمة المرور

              <input
                type="password"
                required
                minLength={8}
                maxLength={128}
                value={password}
                onChange={(event) =>
                  setPassword(
                    event.target.value,
                  )
                }
              />
            </label>

            <label>
              تأكيد كلمة المرور

              <input
                type="password"
                required
                minLength={8}
                maxLength={128}
                value={confirmPassword}
                onChange={(event) =>
                  setConfirmPassword(
                    event.target.value,
                  )
                }
              />
            </label>
          </div>

          <fieldset className="register-roles">
            <legend>
              اختر نوع الحساب
            </legend>

            <label
              className={
                role === "doctor"
                  ? "is-selected"
                  : ""
              }
            >
              <input
                type="radio"
                name="role"
                value="doctor"
                checked={role === "doctor"}
                onChange={() =>
                  setRole("doctor")
                }
              />

              <span>
                <strong>دكتور</strong>
                <small>
                  بوابة الطبيب على الويب
                </small>
              </span>
            </label>

            <label
              className={
                role === "therapist"
                  ? "is-selected"
                  : ""
              }
            >
              <input
                type="radio"
                name="role"
                value="therapist"
                checked={
                  role === "therapist"
                }
                onChange={() =>
                  setRole("therapist")
                }
              />

              <span>
                <strong>معالج</strong>
                <small>
                  بوابة المعالج على الويب
                </small>
              </span>
            </label>

            <label
              className={
                role === "family"
                  ? "is-selected"
                  : ""
              }
            >
              <input
                type="radio"
                name="role"
                value="family"
                checked={role === "family"}
                onChange={() =>
                  setRole("family")
                }
              />

              <span>
                <strong>عائلة</strong>
                <small>
                  دخول التطبيق والويب
                </small>
              </span>
            </label>
          </fieldset>

          <p className="register-note">
            يصبح الحساب متاحًا بعد موافقة
            الأدمن.
          </p>

          <button
            className="btn btn--gold btn--block"
            disabled={busy}
          >
            {busy
              ? "جارٍ إنشاء الحساب..."
              : "إنشاء الحساب"}
          </button>

          <p className="register-login">
            لديك حساب بالفعل؟{" "}

            <Link to="/login">
              تسجيل الدخول
            </Link>
          </p>
        </form>
      </section>
    </div>
  );
}