import { useEffect, useState, type FormEvent } from "react";
import { ApiError } from "../api/client";
import { webAccountApi } from "../api/webAccountClient";
import type { MemoryEntry } from "../types";
import { useI18n } from "../i18n/useI18n";
import { MemoryVoiceRecorder } from "./MemoryVoiceRecorder";

export type MemoryMediaKind = "image" | "video" | "audio";

const MAX_IMAGE_BYTES = 5 * 1024 * 1024;
const MAX_VIDEO_BYTES = 50 * 1024 * 1024;
const ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/png", "image/webp"];
const ALLOWED_VIDEO_TYPES = ["video/mp4", "video/webm", "video/quicktime"];

interface Props {
  patientId: string;
  initialContributor?: { name: string; relationship: string };
  onCancel: () => void;
  onSaved: (info: { mediaFailed: boolean; created: MemoryEntry; localMedia?: File; mediaKind: MemoryMediaKind }) => void;
}

/**
 * Family memory contribution form. Creates a memory for the linked patient via
 * POST /memories, then (if media was chosen) uploads it via
 * POST /memories/{id}/media. If the media upload fails, the memory is kept and
 * the caller is told so it can show a clear, non-blocking message.
 */
export function MemoryForm({ patientId, initialContributor, onCancel, onSaved }: Props) {
  const { t } = useI18n();
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [personName, setPersonName] = useState(initialContributor?.name ?? "");
  const [relationship, setRelationship] = useState(initialContributor?.relationship ?? "");
  const [place, setPlace] = useState("");
  const [memoryDate, setMemoryDate] = useState("");
  const [category, setCategory] = useState("");
  const [mediaKind, setMediaKind] = useState<MemoryMediaKind>("image");
  const [media, setMedia] = useState<File | null>(null);
  const [mediaPreview, setMediaPreview] = useState<string | null>(null);
  const [mediaError, setMediaError] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => () => {
    if (mediaPreview) URL.revokeObjectURL(mediaPreview);
  }, [mediaPreview]);

  const onPickMedia = (file: File | null) => {
    setMediaError(null);
    if (!file) {
      setMedia(null);
      setMediaPreview(null);
      return;
    }
    const allowed = mediaKind === "image" ? ALLOWED_IMAGE_TYPES : ALLOWED_VIDEO_TYPES;
    const maxBytes = mediaKind === "image" ? MAX_IMAGE_BYTES : MAX_VIDEO_BYTES;
    if (!allowed.includes(file.type)) {
      setMedia(null);
      setMediaPreview(null);
      setMediaError(t(mediaKind === "image" ? "family.unsupportedImage" : "family.unsupportedVideo"));
      return;
    }
    if (file.size > maxBytes) {
      setMedia(null);
      setMediaPreview(null);
      setMediaError(t(mediaKind === "image" ? "family.imageTooLarge" : "family.videoTooLarge"));
      return;
    }
    setMedia(file);
    setMediaPreview(URL.createObjectURL(file));
  };

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    if (!title.trim()) {
      setError(t("family.enterTitle"));
      return;
    }
    if (!personName.trim()) {
      setError(t("family.enterContributor"));
      return;
    }
    if (mediaKind === "audio" && !media) {
      setError(t("family.voiceRequired"));
      return;
    }
    setSubmitting(true);
    try {
      const body = new FormData();
      body.append("patient_id", patientId);
      body.append("title", title.trim());
      body.append("description", description.trim());
      body.append("person_name", personName.trim());
      body.append("relationship", relationship.trim());
      body.append("place_name", place.trim());
      body.append("memory_date", memoryDate);
      body.append("category", category.trim());
      body.append("media_kind", mediaKind);
      if (media) body.append("media", media);

      const response = await webAccountApi<{ success: boolean; memory: MemoryEntry }>("family_memories.php", {
        method: "POST",
        body,
      });
      onSaved({ mediaFailed: false, created: response.memory, mediaKind });
    } catch (err) {
      const message =
        err instanceof ApiError
          ? err.message
          : t("family.saveMemoryFailed");
      setError(message);
      setSubmitting(false);
    }
  };

  return (
    <form className="mform" onSubmit={onSubmit}>
      <div className="mform__grid">
        <label className="mform__full">
          {t("family.title")} <span className="mform__req">*</span>
          <input
            type="text"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            maxLength={255}
            required
          />
        </label>
        <label className="mform__full">
          {t("family.description")}
          <textarea
            rows={2}
            value={description}
            onChange={(e) => setDescription(e.target.value)}
          />
        </label>
        <label>
          {t("family.contributorName")} <span className="mform__req">*</span>
          <input
            type="text"
            value={personName}
            onChange={(e) => setPersonName(e.target.value)}
            maxLength={255}
            placeholder={t("family.contributorPlaceholder")}
            required
          />
          <span className="mform__hint">{t("family.contributorHelper")}</span>
        </label>
        <label>
          {t("family.relationshipOptional")}
          <input
            type="text"
            value={relationship}
            onChange={(e) => setRelationship(e.target.value)}
            maxLength={64}
            placeholder={t("family.relationshipPlaceholder")}
          />
        </label>
        <label>
          {t("family.place")}
          <input
            type="text"
            value={place}
            onChange={(e) => setPlace(e.target.value)}
            maxLength={255}
          />
        </label>
        <label>
          {t("family.memoryDate")}
          <input
            type="date"
            value={memoryDate}
            onChange={(e) => setMemoryDate(e.target.value)}
          />
        </label>
        <label>
          {t("family.category")}
          <input
            type="text"
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            maxLength={64}
            placeholder={t("family.categoryPlaceholder")}
          />
        </label>
        <div className="mform__media mform__full">
          <span>{t("family.mediaType")}</span>
          <div className="mform__media-tabs" role="group" aria-label={t("family.mediaType")}>
            {(["image", "video", "audio"] as const).map((kind) => (
              <button
                key={kind}
                className={mediaKind === kind ? "is-active" : ""}
                type="button"
                onClick={() => {
                  setMediaKind(kind);
                  setMedia(null);
                  setMediaPreview(null);
                  setMediaError(null);
                }}
              >
                {t(kind === "image" ? "family.photo" : kind === "video" ? "family.video" : "family.voiceRecordingType")}
              </button>
            ))}
          </div>
        </div>
        {mediaKind !== "audio" && <label className="mform__full">
          {t(mediaKind === "image" ? "family.image" : "family.video")} <span className="mform__hint">{t(mediaKind === "image" ? "family.imageHint" : "family.videoHint")}</span>
          <input
            type="file"
            accept={mediaKind === "image" ? "image/*" : "video/*"}
            onChange={(e) => onPickMedia(e.target.files?.[0] ?? null)}
          />
        </label>}
        {mediaKind === "audio" && <div className="mform__full"><MemoryVoiceRecorder onChange={(file) => setMedia(file)} /></div>}
        {mediaPreview && mediaKind !== "audio" && (
          <div className="mform__media-preview mform__full">
            {mediaKind === "image" ? <img src={mediaPreview} alt={t("family.mediaPreview")} /> : <video src={mediaPreview} controls preload="metadata" />}
          </div>
        )}
      </div>

      {mediaError && <div className="mform__error">{mediaError}</div>}
      {error && <div className="mform__error">{error}</div>}

      <div className="mform__actions">
        <button className="btn btn--gold" type="submit" disabled={submitting}>
          {submitting ? t("family.saving") : t("family.saveMemory")}
        </button>
        <button
          className="btn btn--ghost"
          type="button"
          onClick={onCancel}
          disabled={submitting}
        >
          {t("common.cancel")}
        </button>
      </div>
    </form>
  );
}
