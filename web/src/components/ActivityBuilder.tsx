import { useEffect, useState } from "react";
import { api } from "../api/client";
import { Badge, EmptyState } from "./ui";
import { formatDate } from "../lib";
import { useI18n } from "../i18n/useI18n";
import type { TranslationKey } from "../i18n/translations";
import type {
  AssignedActivity,
  AssignedActivityListResponse,
  PatientListResponse,
  PatientProfile,
} from "../types";

type AiQuestion = {
  prompt: string;
  options: string[];
  answer: string;
  explanation: string;
};

type GeneratedContent = {
  source: "ai";
  description: string;
  questions: AiQuestion[];
};

type AiGeneratedActivity = {
  title: string;
  instructions: string;
  template_type: string;
  difficulty: string;
  duration_minutes: number;
  generated_content: GeneratedContent;
};

type AiGenerateResponse = {
  success: boolean;
  activity: AiGeneratedActivity;
};

const DIFFICULTIES = ["easy", "medium", "hard"];
const KNOWN_STATUSES = ["assigned", "completed", "skipped"];

function statusTone(status: string): "neutral" | "live" | "plan" | "gold" {
  if (status === "completed") return "live";
  if (status === "skipped") return "gold";
  return "plan";
}

export function ActivityBuilder({
  patientProfileId,
}: {
  patientProfileId: string;
}) {
  const { t } = useI18n();

  const [activities, setActivities] = useState<AssignedActivity[]>([]);
  const [patients, setPatients] = useState<PatientProfile[]>([]);
  const [targetPatientId, setTargetPatientId] = useState(patientProfileId);
  const [loadingPatients, setLoadingPatients] = useState(true);
  const [open, setOpen] = useState(false);
  const [generating, setGenerating] = useState(false);
  const [assigning, setAssigning] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [ok, setOk] = useState<string | null>(null);

  const [description, setDescription] = useState("");
  const [difficulty, setDifficulty] = useState("easy");
  const [duration, setDuration] = useState(10);
  const [generated, setGenerated] = useState<AiGeneratedActivity | null>(null);

  const difficultyLabel = (value: string) =>
    DIFFICULTIES.includes(value)
      ? t(`difficulty.${value}` as TranslationKey)
      : value;

  const statusLabel = (value: string) =>
    KNOWN_STATUSES.includes(value)
      ? t(`activityStatus.${value}` as TranslationKey)
      : value;

  const loadActivities = async (patientId = targetPatientId) => {
    try {
      const response = await api<AssignedActivityListResponse>(
        `/activities/patient/${patientId}?limit=100`,
      );
      setActivities(response.activities);
    } catch (reason) {
      setError(
        reason instanceof Error ? reason.message : "تعذر تحميل الأنشطة.",
      );
    }
  };

  useEffect(() => {
    setTargetPatientId(patientProfileId);
  }, [patientProfileId]);

  useEffect(() => {
    void loadActivities(targetPatientId);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [targetPatientId]);

  useEffect(() => {
    const loadPatients = async () => {
      setLoadingPatients(true);
      try {
        const response = await api<PatientListResponse>("/patients?limit=200");
        setPatients(response.patients);
      } catch (reason) {
        setError(
          reason instanceof Error ? reason.message : "تعذر تحميل قائمة المرضى.",
        );
      } finally {
        setLoadingPatients(false);
      }
    };

    void loadPatients();
  }, []);

  const startBuilder = () => {
    setDescription("");
    setDifficulty("easy");
    setDuration(10);
    setGenerated(null);
    setError(null);
    setOk(null);
    setOpen(true);
  };

  const generateWithAi = async () => {
    const cleanDescription = description.trim();

    if (cleanDescription.length < 10) {
      setError("اكتبي وصفًا أوضح للنشاط، على الأقل 10 أحرف.");
      return;
    }

    setGenerating(true);
    setError(null);
    setOk(null);
    setGenerated(null);

    try {
      const response = await api<AiGenerateResponse>(
        "/activities/generate-ai",
        {
          method: "POST",
          body: JSON.stringify({
            patient_profile_id: targetPatientId,
            prompt: cleanDescription,
            difficulty,
            duration_minutes: duration,
          }),
        },
      );

      setGenerated(response.activity);
      setOk("تم إنشاء النشاط. راجعيه ثم اضغطي تعيين للمريض.");
    } catch (reason) {
      setError(
        reason instanceof Error
          ? reason.message
          : "تعذر إنشاء النشاط بالذكاء الاصطناعي.",
      );
    } finally {
      setGenerating(false);
    }
  };

  const assign = async () => {
    if (!generated) return;

    setAssigning(true);
    setError(null);
    setOk(null);

    try {
      const created = await api<AssignedActivity>("/activities/assign", {
        method: "POST",
        body: JSON.stringify({
          patient_profile_id: targetPatientId,
          template_type: generated.template_type,
          difficulty: generated.difficulty,
          duration_minutes: generated.duration_minutes,
          title: generated.title,
          instructions: generated.instructions,
          generated_content: generated.generated_content,
        }),
      });

      setActivities((current) => [created, ...current]);
      setOpen(false);
      setGenerated(null);
      setOk("تم تعيين النشاط للمريض بنجاح.");
    } catch (reason) {
      setError(
        reason instanceof Error ? reason.message : "تعذر تعيين النشاط.",
      );
    } finally {
      setAssigning(false);
    }
  };

  return (
    <div className="activity-builder">
      <div className="section-header">
        <div>
          <span className="eyebrow">منشئ الأنشطة بالذكاء الاصطناعي</span>
          <h2>أنشطة مخصصة</h2>
        </div>

        {!open && (
          <button className="btn btn--gold btn--sm" onClick={startBuilder}>
            + إنشاء نشاط بالـAI
          </button>
        )}
      </div>

      <p className="muted-sub">
        اكتبي وصف النشاط الذي تريدينه وسيقوم الذكاء الاصطناعي بإنشاء الأسئلة
        والخيارات والإجابات، ثم راجعي النشاط قبل إرساله للمريض.
      </p>

      {ok && <div className="banner banner--ok">{ok}</div>}
      {error && <div className="banner banner--warn">{error}</div>}

      {open && (
        <div className="activity-form ai-activity-form">
          <div className="activity-form__grid">
            <label className="activity-form__full">
              تعيين النشاط إلى المريض
              <select
                value={targetPatientId}
                disabled={loadingPatients || generating || assigning}
                onChange={(event) => {
                  setTargetPatientId(event.target.value);
                  setGenerated(null);
                  setOk(null);
                  setError(null);
                }}
              >
                {loadingPatients && <option value={targetPatientId}>جاري تحميل المرضى...</option>}
                {!loadingPatients && patients.length === 0 && (
                  <option value={targetPatientId}>لا يوجد مرضى معيّنون لك</option>
                )}
                {patients.map((patient) => (
                  <option key={patient.id} value={patient.id}>
                    {patient.user?.full_name ?? `المريض رقم ${patient.id}`}
                  </option>
                ))}
              </select>
            </label>

            <label className="activity-form__full">
              صفي النشاط المطلوب للذكاء الاصطناعي
              <textarea
                rows={5}
                maxLength={1500}
                value={description}
                disabled={generating || assigning}
                onChange={(event) => {
                  setDescription(event.target.value);
                  setGenerated(null);
                }}
                placeholder="مثال: أنشئ نشاط ذاكرة سهلًا عن أسماء أفراد العائلة، يتكون من 5 أسئلة اختيار من متعدد، وبعبارات عربية بسيطة."
              />
              <small>{description.length}/1500</small>
            </label>

            <label>
              مستوى الصعوبة
              <select
                value={difficulty}
                disabled={generating || assigning}
                onChange={(event) => {
                  setDifficulty(event.target.value);
                  setGenerated(null);
                }}
              >
                {DIFFICULTIES.map((value) => (
                  <option key={value} value={value}>
                    {difficultyLabel(value)}
                  </option>
                ))}
              </select>
            </label>

            <label>
              المدة بالدقائق
              <input
                type="number"
                min={1}
                max={60}
                value={duration}
                disabled={generating || assigning}
                onChange={(event) => {
                  setDuration(
                    Math.max(1, Math.min(60, Number(event.target.value) || 1)),
                  );
                  setGenerated(null);
                }}
              />
            </label>
          </div>

          <div className="activity-form__actions">
            <button
              className="btn btn--gold"
              disabled={generating || assigning || description.trim().length < 10}
              onClick={generateWithAi}
            >
              {generating ? "جاري إنشاء النشاط..." : "✨ إنشاء النشاط بالـAI"}
            </button>

            <button
              className="btn btn--ghost"
              disabled={generating || assigning}
              onClick={() => {
                setOpen(false);
                setGenerated(null);
              }}
            >
              {t("common.cancel")}
            </button>
          </div>

          {generated && (
            <div className="activity-preview ai-activity-preview">
              <span className="activity-preview__label">معاينة النشاط</span>
              <h3>{generated.title}</h3>
              <p>{generated.instructions}</p>

              <div className="activity-preview__meta">
                <span className="pill">{generated.template_type}</span>
                <span className="pill">
                  {difficultyLabel(generated.difficulty)}
                </span>
                <span className="pill">
                  {generated.duration_minutes} دقيقة
                </span>
                <span className="pill">
                  {generated.generated_content.questions.length} أسئلة
                </span>
              </div>

              <div className="ai-question-list">
                {generated.generated_content.questions.map((question, index) => (
                  <article className="ai-question-card" key={`${index}-${question.prompt}`}>
                    <strong>
                      {index + 1}. {question.prompt}
                    </strong>

                    <ul>
                      {question.options.map((option) => (
                        <li
                          key={option}
                          className={option === question.answer ? "is-correct" : ""}
                        >
                          {option}
                        </li>
                      ))}
                    </ul>

                    <small>
                      الإجابة: {question.answer} — {question.explanation}
                    </small>
                  </article>
                ))}
              </div>

              <div className="activity-form__actions">
                <button
                  className="btn btn--gold"
                  disabled={assigning || generating || !targetPatientId}
                  onClick={assign}
                >
                  {assigning ? "جاري التعيين..." : "تعيين النشاط للمريض"}
                </button>

                <button
                  className="btn btn--ghost"
                  disabled={assigning || generating}
                  onClick={generateWithAi}
                >
                  إعادة الإنشاء
                </button>
              </div>
            </div>
          )}
        </div>
      )}

      <div className="activity-list">
        {activities.length === 0 ? (
          <EmptyState message="لا توجد أنشطة مسندة لهذا المريض بعد." icon="activities" />
        ) : (
          <ul className="activity-list__items">
            {activities.map((activity) => (
              <li className="activity-item" key={activity.id}>
                <div className="activity-item__main">
                  <strong>{activity.title}</strong>
                  <span className="activity-item__sub">
                    {difficultyLabel(activity.difficulty)} ·{" "}
                    {activity.duration_minutes} دقيقة ·{" "}
                    {t("ab.assignedOn", {
                      date: formatDate(activity.created_at),
                    })}
                  </span>
                </div>

                <Badge tone={statusTone(activity.status)}>
                  {statusLabel(activity.status)}
                </Badge>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}
