import type { ReactNode } from "react";

// ---- Section header --------------------------------------------------------
export function SectionHeader({
  eyebrow,
  title,
  action,
}: {
  eyebrow?: string;
  title: string;
  action?: ReactNode;
}) {
  return (
    <div className="section-header">
      <div>
        {eyebrow && <span className="eyebrow">{eyebrow}</span>}
        <h2>{title}</h2>
      </div>
      {action}
    </div>
  );
}

// ---- Card ------------------------------------------------------------------
export function Card({
  children,
  className = "",
  as: Tag = "div",
  id,
}: {
  children: ReactNode;
  className?: string;
  as?: "div" | "article" | "section";
  id?: string;
}) {
  return (
    <Tag className={`card ${className}`} id={id}>
      {children}
    </Tag>
  );
}

// ---- Stat card -------------------------------------------------------------
export function StatCard({
  label,
  value,
  hint,
  icon,
}: {
  label: string;
  value: ReactNode;
  hint?: string;
  icon?: string;
}) {
  return (
    <div className="stat">
      {icon && (
        <span className="stat__icon" aria-hidden="true">
          {icon}
        </span>
      )}
      <div>
        <div className="stat__value">{value}</div>
        <div className="stat__label">{label}</div>
        {hint && <div className="stat__hint">{hint}</div>}
      </div>
    </div>
  );
}

// ---- Badge -----------------------------------------------------------------
export function Badge({
  children,
  tone = "neutral",
}: {
  children: ReactNode;
  tone?: "neutral" | "live" | "plan" | "gold";
}) {
  return <span className={`badge badge--${tone}`}>{children}</span>;
}

// ---- Bar list (CSS-only "chart") -------------------------------------------
export function BarList({
  items,
}: {
  items: { label: string; value: number; caption?: string }[];
}) {
  const max = Math.max(1, ...items.map((i) => i.value));
  return (
    <div className="barlist">
      {items.map((item) => (
        <div className="barlist__row" key={item.label}>
          <div className="barlist__head">
            <span>{item.label}</span>
            <strong>{item.caption ?? `${Math.round(item.value)}%`}</strong>
          </div>
          <div className="barlist__track">
            <div
              className="barlist__fill"
              style={{ width: `${Math.min(100, (item.value / max) * 100)}%` }}
            />
          </div>
        </div>
      ))}
    </div>
  );
}

// ---- Safety note (medical review boundary) ---------------------------------
export function SafetyNote({ compact = false }: { compact?: boolean }) {
  return (
    <div className={`safety ${compact ? "safety--compact" : ""}`}>
      <span className="safety__mark" aria-hidden="true">
        ⚕
      </span>
      <p>
        <strong>Supportive review only.</strong> All summaries reflect{" "}
        <strong>cognitive exercise performance only</strong> and are{" "}
        <strong>not a medical diagnosis and not a medical assessment</strong>.
        AI-assisted summaries are based on activity performance and remain{" "}
        <strong>pending doctor/therapist review</strong>. NeuroBridge does not
        diagnose, predict, or treat any condition.
      </p>
    </div>
  );
}

// ---- Family safety note (family boundary) ----------------------------------
export function FamilySafetyNote() {
  return (
    <div className="safety">
      <span className="safety__mark" aria-hidden="true">
        ♥
      </span>
      <p>
        <strong>Supportive view only.</strong> This is a{" "}
        <strong>supportive progress view</strong> showing{" "}
        <strong>activity performance only</strong> and{" "}
        <strong>care and safety information only</strong>. It is{" "}
        <strong>not a medical diagnosis and not a medical assessment</strong>.
        For any medical concerns, please{" "}
        <strong>contact the care team</strong>.
      </p>
    </div>
  );
}

// ---- States ----------------------------------------------------------------
export function Spinner({ label = "Loading…" }: { label?: string }) {
  return (
    <div className="state">
      <div className="spinner" aria-hidden="true" />
      <p>{label}</p>
    </div>
  );
}

export function ErrorState({
  message,
  onRetry,
}: {
  message: string;
  onRetry?: () => void;
}) {
  return (
    <div className="state state--error">
      <p>{message}</p>
      {onRetry && (
        <button className="btn btn--ghost" onClick={onRetry}>
          Retry
        </button>
      )}
    </div>
  );
}

export function EmptyState({ message }: { message: string }) {
  return (
    <div className="state state--empty">
      <p>{message}</p>
    </div>
  );
}
