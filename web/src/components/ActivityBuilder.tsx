import { useEffect, useMemo, useState } from "react";
import { api } from "../api/client";
import { Badge, EmptyState } from "./ui";
import { formatDate } from "../lib";
import { useI18n } from "../i18n/useI18n";
import type { TranslationKey } from "../i18n/translations";
import type {
  ActivityTemplate,
  ActivityTemplateListResponse,
  AssignedActivity,
  AssignedActivityListResponse,
} from "../types";

const DIFFICULTY_FALLBACK = ["easy", "medium", "hard"];
const KNOWN_DIFFICULTIES = ["easy", "medium", "hard"];
const KNOWN_STATUSES = ["assigned", "completed", "skipped"];

function statusTone(status: string): "neutral" | "live" | "plan" | "gold" {
  if (status === "completed") return "live";
  if (status === "skipped") return "gold";
  return "plan";
}

/**
 * Care-team activity builder: pick a safe predefined template, customize a few
 * parameters, preview, and assign to the patient. Shows the patient's assigned
 * activities with their status. All content is cognitive-exercise only.
 */
export function ActivityBuilder({
  patientProfileId,
}: {
  patientProfileId: string;
}) {
  const { t } = useI18n();
  const difficultyLabel = (d: string) =>
    KNOWN_DIFFICULTIES.includes(d) ? t(`difficulty.${d}` as TranslationKey) : d;
  const statusLabel = (s: string) =>
    KNOWN_STATUSES.includes(s) ? t(`activityStatus.${s}` as TranslationKey) : s;

  const [templates, setTemplates] = useState<ActivityTemplate[]>([]);
  const [difficulties, setDifficulties] = useState<string[]>(DIFFICULTY_FALLBACK);
  const [activities, setActivities] = useState<AssignedActivity[]>([]);
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [ok, setOk] = useState<string | null>(null);

  // Form state.
  const [templateType, setTemplateType] = useState("memory_recall");
  const [difficulty, setDifficulty] = useState("easy");
  const [duration, setDuration] = useState(10);
  const [title, setTitle] = useState("");
  const [instructions, setInstructions] = useState("");

  const selected = useMemo(
    () => templates.find((t) => t.template_type === templateType),
    [templates, templateType],
  );

  const loadActivities = async () => {
    try {
      const res = await api<AssignedActivityListResponse>(
        `/activities/patient/${patientProfileId}?limit=100`,
      );
      setActivities(res.activities);
    } catch (err) {
      setError(err instanceof Error ? err.message : t("ab.couldNotLoad"));
    }
  };

  useEffect(() => {
    let alive = true;
    void (async () => {
      try {
        const t = await api<ActivityTemplateListResponse>("/activities/templates");
        if (!alive) return;
        setTemplates(t.templates);
        setDifficulties(t.difficulties.length ? t.difficulties : DIFFICULTY_FALLBACK);
      } catch {
        /* templates are optional chrome; ignore load failure */
      }
      await loadActivities();
    })();
    return () => {
      alive = false;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [patientProfileId]);

  // When the template changes, prefill title/instructions from its defaults.
  const applyTemplate = (type: string) => {
    setTemplateType(type);
    const tpl = templates.find((t) => t.template_type === type);
    setTitle(tpl?.default_title ?? "");
    setInstructions(tpl?.default_instructions ?? "");
  };

  const startBuilder = () => {
    setError(null);
    setOk(null);
    const first = templates[0]?.template_type ?? "memory_recall";
    applyTemplate(first);
    setDifficulty(difficulties[0] ?? "easy");
    setDuration(10);
    setOpen(true);
  };

  const assign = async () => {
    setBusy(true);
    setError(null);
    setOk(null);
    try {
      const created = await api<AssignedActivity>("/activities/assign", {
        method: "POST",
        body: JSON.stringify({
          patient_profile_id: patientProfileId,
          template_type: templateType,
          difficulty,
          duration_minutes: duration,
          title: title.trim() || undefined,
          instructions: instructions.trim() || undefined,
        }),
      });
      setActivities((prev) => [created, ...prev]);
      setOk(t("ab.assigned"));
      setOpen(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : t("ab.couldNotAssign"));
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="activity-builder">
      <div className="section-header">
        <div>
          <span className="eyebrow">{t("ab.eyebrow")}</span>
          <h2>{t("ab.title")}</h2>
        </div>
        {!open && (
          <button className="btn btn--gold btn--sm" onClick={startBuilder}>
            {t("ab.create")}
          </button>
        )}
      </div>

      <p className="muted-sub">{t("ab.help")}</p>

      {ok && <div className="banner banner--ok">{ok}</div>}
      {error && <div className="banner banner--warn">{error}</div>}

      {open && (
        <div className="activity-form">
          <div className="activity-form__grid">
            <label>
              {t("ab.template")}
              <select
                value={templateType}
                onChange={(e) => applyTemplate(e.target.value)}
              >
                {templates.map((tpl) => (
                  <option key={tpl.template_type} value={tpl.template_type}>
                    {tpl.label}
                  </option>
                ))}
              </select>
            </label>
            <label>
              {t("ab.difficulty")}
              <select
                value={difficulty}
                onChange={(e) => setDifficulty(e.target.value)}
              >
                {difficulties.map((d) => (
                  <option key={d} value={d}>
                    {difficultyLabel(d)}
                  </option>
                ))}
              </select>
            </label>
            <label>
              {t("ab.duration")}
              <input
                type="number"
                min={1}
                max={60}
                value={duration}
                onChange={(e) =>
                  setDuration(Math.max(1, Math.min(60, Number(e.target.value) || 1)))
                }
              />
            </label>
            <label className="activity-form__full">
              {t("ab.titleField")}
              <input
                type="text"
                value={title}
                maxLength={255}
                onChange={(e) => setTitle(e.target.value)}
                placeholder={t("ab.titlePlaceholder")}
              />
            </label>
            <label className="activity-form__full">
              {t("ab.instructions")}
              <textarea
                rows={3}
                value={instructions}
                onChange={(e) => setInstructions(e.target.value)}
                placeholder={t("ab.instructionsPlaceholder")}
              />
            </label>
          </div>

          {/* Preview of what the patient will receive */}
          <div className="activity-preview">
            <span className="activity-preview__label">{t("ab.preview")}</span>
            <strong className="activity-preview__title">
              {title.trim() || selected?.default_title || t("word.activity")}
            </strong>
            <div className="activity-preview__meta">
              <span className="pill">{selected?.label ?? templateType}</span>
              <span className="pill">{difficultyLabel(difficulty)}</span>
              <span className="pill">
                {duration} {t("ab.minutes")}
              </span>
              <span className="pill">
                {selected?.playable ? t("ab.playable") : t("ab.guidedPreview")}
              </span>
            </div>
            {(instructions.trim() || selected?.default_instructions) && (
              <p className="activity-preview__text">
                {instructions.trim() || selected?.default_instructions}
              </p>
            )}
          </div>

          <div className="activity-form__actions">
            <button className="btn btn--gold" disabled={busy} onClick={assign}>
              {busy ? t("ab.assigning") : t("ab.assign")}
            </button>
            <button
              className="btn btn--ghost"
              disabled={busy}
              onClick={() => setOpen(false)}
            >
              {t("common.cancel")}
            </button>
          </div>
        </div>
      )}

      <div className="activity-list">
        {activities.length === 0 ? (
          <EmptyState message={t("ab.noneAssigned")} />
        ) : (
          <ul className="activity-list__items">
            {activities.map((a) => (
              <li className="activity-item" key={a.id}>
                <div className="activity-item__main">
                  <strong>{a.title}</strong>
                  <span className="activity-item__sub">
                    {difficultyLabel(a.difficulty)} · {a.duration_minutes}{" "}
                    {t("ab.minutes")} · {t("ab.assignedOn", { date: formatDate(a.created_at) })}
                    {a.completed_at
                      ? ` · ${t("ab.completedOn", { date: formatDate(a.completed_at) })}`
                      : ""}
                  </span>
                </div>
                <Badge tone={statusTone(a.status)}>{statusLabel(a.status)}</Badge>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}
