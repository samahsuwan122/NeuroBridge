import { useEffect, useMemo, useState } from "react";
import {
  createGoal,
  listPatientGoals,
  updateGoal,
} from "../api/goals";
import { useI18n } from "../i18n/useI18n";
import type { Goal, GoalStatus } from "../types";
import {
  Badge,
  EmptyState,
  ErrorState,
  SectionHeader,
  Spinner,
} from "./ui";

interface GoalsPanelProps {
  patientProfileId: string;
}

interface GoalFormState {
  title: string;
  description: string;
  target_type: string;
  target_value: string;
  due_date: string;
}

const emptyForm: GoalFormState = {
  title: "",
  description: "",
  target_type: "sessions",
  target_value: "5",
  due_date: "",
};

const statusOptions: GoalStatus[] = ["active", "completed", "paused"];

function goalProgress(goal: Goal): number {
  if (goal.target_value <= 0) return 0;
  const value = Math.round((goal.current_value / goal.target_value) * 100);
  return Math.min(100, Math.max(0, value));
}

function formatDateValue(value?: string | null): string {
  if (!value) return "—";
  return new Date(value).toLocaleDateString();
}

function statusTone(status: GoalStatus): "neutral" | "live" | "plan" | "gold" {
  if (status === "completed") return "live";
  if (status === "paused") return "gold";
  return "neutral";
}

export function GoalsPanel({ patientProfileId }: GoalsPanelProps) {
  const { t } = useI18n();

  const [goals, setGoals] = useState<Goal[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [form, setForm] = useState<GoalFormState>(emptyForm);
  const [draftValues, setDraftValues] = useState<Record<string, string>>({});
  const [createOpen, setCreateOpen] = useState(false);

  const sortedGoals = useMemo(
    () =>
      [...goals].sort(
        (a, b) => +new Date(b.created_at) - +new Date(a.created_at),
      ),
    [goals],
  );

  const statusLabel = (status: GoalStatus): string => {
    if (status === "completed") return t("goals.status.completed");
    if (status === "paused") return t("goals.status.paused");
    return t("goals.status.active");
  };
  const targetTypeLabel = (value: string) => value === "sessions" ? t("goals.targetSessions") : value;

  const loadGoals = async () => {
    setLoading(true);
    setError(null);
    try {
      const data = await listPatientGoals(patientProfileId);
      setGoals(data.goals);
      setDraftValues(
        Object.fromEntries(
          data.goals.map((goal) => [goal.id, String(goal.current_value)]),
        ),
      );
    } catch (err) {
      setError(err instanceof Error ? err.message : t("goals.failedLoad"));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void loadGoals();
  }, [patientProfileId]);

  const handleCreate = async (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();

    const title = form.title.trim();
    const targetType = form.target_type.trim();
    const targetValue = Number(form.target_value);

    if (!title || !targetType || !Number.isFinite(targetValue) || targetValue < 1) {
      setError(t("goals.invalidCreate"));
      return;
    }

    setSaving(true);
    setError(null);
    setMessage(null);

    try {
      await createGoal({
        patient_profile_id: patientProfileId,
        title,
        description: form.description.trim() || null,
        target_type: targetType,
        target_value: targetValue,
        current_value: 0,
        due_date: form.due_date || null,
      });

      setForm(emptyForm);
      setMessage(t("goals.createdSuccess"));
      await loadGoals();
    } catch (err) {
      setError(err instanceof Error ? err.message : t("goals.failedSave"));
    } finally {
      setSaving(false);
    }
  };

  const handleProgressUpdate = async (goal: Goal) => {
    const value = Number(draftValues[goal.id]);

    if (!Number.isFinite(value) || value < 0) {
      setError(t("goals.invalidCurrent"));
      return;
    }

    setSaving(true);
    setError(null);
    setMessage(null);

    try {
      await updateGoal(goal.id, { current_value: value });
      setMessage(t("goals.updatedSuccess"));
      await loadGoals();
    } catch (err) {
      setError(err instanceof Error ? err.message : t("goals.failedUpdate"));
    } finally {
      setSaving(false);
    }
  };

  const handleStatusUpdate = async (goal: Goal, status: GoalStatus) => {
    setSaving(true);
    setError(null);
    setMessage(null);

    try {
      await updateGoal(goal.id, { status });
      setMessage(t("goals.updatedSuccess"));
      await loadGoals();
    } catch (err) {
      setError(err instanceof Error ? err.message : t("goals.failedUpdate"));
    } finally {
      setSaving(false);
    }
  };

  return (
    <section className="goals-panel">
      <SectionHeader eyebrow={t("goals.eyebrow")} title={t("goals.title")} />

      {message && <div className="success-banner">{message}</div>}
      {error && <ErrorState message={error} onRetry={loadGoals} />}

      <div className="goals-panel__create-toggle">
        <button className="btn btn--gold btn--sm" type="button" onClick={() => setCreateOpen((open) => !open)} aria-expanded={createOpen}>
          {createOpen ? t("common.cancel") : t("goals.create")}
        </button>
      </div>

      {createOpen && <form className="goals-form" onSubmit={handleCreate}>
        <div className="form-grid">
          <label>
            <span>{t("goals.goalTitle")}</span>
            <input
              value={form.title}
              onChange={(event) =>
                setForm((current) => ({ ...current, title: event.target.value }))
              }
              placeholder={t("goals.goalTitlePlaceholder")}
            />
          </label>

          <label>
            <span>{t("goals.targetType")}</span>
            <input
              value={form.target_type}
              onChange={(event) =>
                setForm((current) => ({
                  ...current,
                  target_type: event.target.value,
                }))
              }
              placeholder={t("goals.targetTypePlaceholder")}
            />
          </label>

          <label>
            <span>{t("goals.targetValue")}</span>
            <input
              type="number"
              min="1"
              value={form.target_value}
              onChange={(event) =>
                setForm((current) => ({
                  ...current,
                  target_value: event.target.value,
                }))
              }
            />
          </label>

          <label>
            <span>{t("goals.dueDate")}</span>
            <input
              type="date"
              value={form.due_date}
              onChange={(event) =>
                setForm((current) => ({
                  ...current,
                  due_date: event.target.value,
                }))
              }
            />
          </label>
        </div>

        <label className="field-wide">
          <span>{t("goals.description")}</span>
          <textarea
            value={form.description}
            onChange={(event) =>
              setForm((current) => ({
                ...current,
                description: event.target.value,
              }))
            }
            placeholder={t("goals.descriptionPlaceholder")}
          />
        </label>

        <button className="btn" type="submit" disabled={saving}>
          {saving ? t("goals.saving") : t("goals.save")}
        </button>
      </form>}

      {loading ? (
        <Spinner />
      ) : sortedGoals.length === 0 ? (
        <EmptyState message={t("goals.noGoals")} icon="goal" />
      ) : (
        <div className="goals-list">
          {sortedGoals.map((goal) => {
            const progress = goalProgress(goal);

            return (
              <article className="goal-card" key={goal.id}>
                <div className="goal-card__header">
                  <div>
                    <h3>{goal.title}</h3>
                    <p>{goal.description || t("goals.noDescription")}</p>
                  </div>
                  <Badge tone={statusTone(goal.status)}>
                    {statusLabel(goal.status)}
                  </Badge>
                </div>

                <div className="goal-progress">
                  <div className="goal-progress__top">
                    <span>{t("goals.progress")}</span>
                    <strong>{progress}%</strong>
                  </div>
                  <div className="goal-progress__bar">
                    <span style={{ width: `${progress}%` }} />
                  </div>
                </div>

                <div className="goal-meta">
                  <span>
                    {t("goals.targetType")}: {targetTypeLabel(goal.target_type)}
                  </span>
                  <span>
                    {t("goals.value")}: {goal.current_value} / {goal.target_value}
                  </span>
                  <span>
                    {t("goals.due")}: {formatDateValue(goal.due_date)}
                  </span>
                  <span>
                    {t("goals.created")}: {formatDateValue(goal.created_at)}
                  </span>
                </div>

                <div className="goal-actions">
                  <label>
                    <span>{t("goals.currentValue")}</span>
                    <input
                      type="number"
                      min="0"
                      value={draftValues[goal.id] ?? String(goal.current_value)}
                      onChange={(event) =>
                        setDraftValues((current) => ({
                          ...current,
                          [goal.id]: event.target.value,
                        }))
                      }
                    />
                  </label>

                  <button
                    className="btn btn--ghost"
                    type="button"
                    disabled={saving}
                    onClick={() => void handleProgressUpdate(goal)}
                  >
                    {t("goals.update")}
                  </button>

                  <select
                    value={goal.status}
                    disabled={saving}
                    onChange={(event) =>
                      void handleStatusUpdate(goal, event.target.value as GoalStatus)
                    }
                  >
                    {statusOptions.map((status) => (
                      <option key={status} value={status}>
                        {statusLabel(status)}
                      </option>
                    ))}
                  </select>
                </div>
              </article>
            );
          })}
        </div>
      )}
    </section>
  );
}
