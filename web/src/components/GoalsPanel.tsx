import { useEffect, useMemo, useState } from "react";
import {
  createGoal,
  listPatientGoals,
  updateGoal,
} from "../api/goals";
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
  const [goals, setGoals] = useState<Goal[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [form, setForm] = useState<GoalFormState>(emptyForm);
  const [draftValues, setDraftValues] = useState<Record<string, string>>({});

  const sortedGoals = useMemo(
    () =>
      [...goals].sort(
        (a, b) => +new Date(b.created_at) - +new Date(a.created_at),
      ),
    [goals],
  );

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
      setError(err instanceof Error ? err.message : "Failed to load goals.");
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
      setError("Please enter a title, target type, and valid target value.");
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
      setMessage("Goal created successfully.");
      await loadGoals();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to save goal.");
    } finally {
      setSaving(false);
    }
  };

  const handleProgressUpdate = async (goal: Goal) => {
    const value = Number(draftValues[goal.id]);

    if (!Number.isFinite(value) || value < 0) {
      setError("Current value must be zero or greater.");
      return;
    }

    setSaving(true);
    setError(null);
    setMessage(null);

    try {
      await updateGoal(goal.id, { current_value: value });
      setMessage("Goal updated successfully.");
      await loadGoals();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to update goal.");
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
      setMessage("Goal updated successfully.");
      await loadGoals();
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to update goal.");
    } finally {
      setSaving(false);
    }
  };

  return (
    <section className="goals-panel">
      <SectionHeader eyebrow="Care plan" title="Goals" />

      {message && <div className="success-banner">{message}</div>}
      {error && <ErrorState message={error} onRetry={loadGoals} />}

      <form className="goals-form" onSubmit={handleCreate}>
        <div className="form-grid">
          <label>
            <span>Goal title</span>
            <input
              value={form.title}
              onChange={(event) =>
                setForm((current) => ({ ...current, title: event.target.value }))
              }
              placeholder="Example: Complete weekly exercises"
            />
          </label>

          <label>
            <span>Target type</span>
            <input
              value={form.target_type}
              onChange={(event) =>
                setForm((current) => ({
                  ...current,
                  target_type: event.target.value,
                }))
              }
              placeholder="sessions"
            />
          </label>

          <label>
            <span>Target value</span>
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
            <span>Due date</span>
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
          <span>Description</span>
          <textarea
            value={form.description}
            onChange={(event) =>
              setForm((current) => ({
                ...current,
                description: event.target.value,
              }))
            }
            placeholder="Short follow-up note for this goal"
          />
        </label>

        <button className="btn" type="submit" disabled={saving}>
          {saving ? "Saving..." : "Save goal"}
        </button>
      </form>

      {loading ? (
        <Spinner />
      ) : sortedGoals.length === 0 ? (
        <EmptyState message="No goals yet." />
      ) : (
        <div className="goals-list">
          {sortedGoals.map((goal) => {
            const progress = goalProgress(goal);

            return (
              <article className="goal-card" key={goal.id}>
                <div className="goal-card__header">
                  <div>
                    <h3>{goal.title}</h3>
                    <p>{goal.description || "No description provided."}</p>
                  </div>
                  <Badge tone={statusTone(goal.status)}>{goal.status}</Badge>
                </div>

                <div className="goal-progress">
                  <div className="goal-progress__top">
                    <span>Progress</span>
                    <strong>{progress}%</strong>
                  </div>
                  <div className="goal-progress__bar">
                    <span style={{ width: `${progress}%` }} />
                  </div>
                </div>

                <div className="goal-meta">
                  <span>Target type: {goal.target_type}</span>
                  <span>
                    Value: {goal.current_value} / {goal.target_value}
                  </span>
                  <span>Due: {formatDateValue(goal.due_date)}</span>
                  <span>Created: {formatDateValue(goal.created_at)}</span>
                </div>

                <div className="goal-actions">
                  <label>
                    <span>Current value</span>
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
                    Update goal
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
                        {status}
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