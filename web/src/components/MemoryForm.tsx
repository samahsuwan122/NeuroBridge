import { useState, type FormEvent } from "react";
import { api, ApiError } from "../api/client";
import type { MemoryEntry } from "../types";

const MAX_IMAGE_BYTES = 5 * 1024 * 1024;
const ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/png", "image/webp"];

interface Props {
  patientId: string;
  onCancel: () => void;
  onSaved: (info: { imageFailed: boolean }) => void;
}

/**
 * Family memory contribution form. Creates a memory for the linked patient via
 * POST /memories, then (if an image was chosen) uploads it via
 * POST /memories/{id}/media. If the image upload fails, the memory is kept and
 * the caller is told so it can show a clear, non-blocking message.
 */
export function MemoryForm({ patientId, onCancel, onSaved }: Props) {
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [personName, setPersonName] = useState("");
  const [relationship, setRelationship] = useState("");
  const [place, setPlace] = useState("");
  const [memoryDate, setMemoryDate] = useState("");
  const [category, setCategory] = useState("");
  const [image, setImage] = useState<File | null>(null);
  const [imageError, setImageError] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  const onPickImage = (file: File | null) => {
    setImageError(null);
    if (!file) {
      setImage(null);
      return;
    }
    if (!ALLOWED_IMAGE_TYPES.includes(file.type)) {
      setImage(null);
      setImageError("Unsupported image type. Use JPEG, PNG, or WebP.");
      return;
    }
    if (file.size > MAX_IMAGE_BYTES) {
      setImage(null);
      setImageError("The image is too large (maximum 5 MB).");
      return;
    }
    setImage(file);
  };

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    if (!title.trim()) {
      setError("Please enter a title.");
      return;
    }
    setSubmitting(true);
    try {
      // 1) Create the memory (JSON).
      const created = await api<MemoryEntry>("/memories", {
        method: "POST",
        body: JSON.stringify({
          patient_profile_id: patientId,
          title: title.trim(),
          description: description.trim() || undefined,
          person_name: personName.trim() || undefined,
          relationship: relationship.trim() || undefined,
          place_name: place.trim() || undefined,
          memory_date: memoryDate || undefined,
          category: category.trim() || undefined,
        }),
      });

      // 2) Optionally attach an image (multipart). Non-blocking on failure.
      let imageFailed = false;
      if (image) {
        try {
          const fd = new FormData();
          fd.append("file", image);
          await api<MemoryEntry>(`/memories/${created.id}/media`, {
            method: "POST",
            body: fd,
          });
        } catch {
          imageFailed = true;
        }
      }

      onSaved({ imageFailed });
    } catch (err) {
      const message =
        err instanceof ApiError
          ? err.message
          : "Could not save the memory. Please try again.";
      setError(message);
      setSubmitting(false);
    }
  };

  return (
    <form className="mform" onSubmit={onSubmit}>
      <p className="mform__note">
        Supportive memory contribution for <strong>family recall support</strong>{" "}
        only — not a medical diagnosis and not a medical assessment.
      </p>

      <div className="mform__grid">
        <label className="mform__full">
          Title <span className="mform__req">*</span>
          <input
            type="text"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            maxLength={255}
            required
          />
        </label>
        <label className="mform__full">
          Description
          <textarea
            rows={2}
            value={description}
            onChange={(e) => setDescription(e.target.value)}
          />
        </label>
        <label>
          Person name
          <input
            type="text"
            value={personName}
            onChange={(e) => setPersonName(e.target.value)}
            maxLength={255}
          />
        </label>
        <label>
          Relationship
          <input
            type="text"
            value={relationship}
            onChange={(e) => setRelationship(e.target.value)}
            maxLength={64}
            placeholder="e.g. daughter"
          />
        </label>
        <label>
          Place
          <input
            type="text"
            value={place}
            onChange={(e) => setPlace(e.target.value)}
            maxLength={255}
          />
        </label>
        <label>
          Memory date
          <input
            type="date"
            value={memoryDate}
            onChange={(e) => setMemoryDate(e.target.value)}
          />
        </label>
        <label>
          Category
          <input
            type="text"
            value={category}
            onChange={(e) => setCategory(e.target.value)}
            maxLength={64}
            placeholder="e.g. family"
          />
        </label>
        <label>
          Image <span className="mform__hint">(optional · JPEG/PNG/WebP ≤ 5 MB)</span>
          <input
            type="file"
            accept="image/jpeg,image/png,image/webp"
            onChange={(e) => onPickImage(e.target.files?.[0] ?? null)}
          />
        </label>
      </div>

      {imageError && <div className="mform__error">{imageError}</div>}
      {error && <div className="mform__error">{error}</div>}

      <div className="mform__actions">
        <button className="btn btn--gold" type="submit" disabled={submitting}>
          {submitting ? "Saving…" : "Save memory"}
        </button>
        <button
          className="btn btn--ghost"
          type="button"
          onClick={onCancel}
          disabled={submitting}
        >
          Cancel
        </button>
      </div>
    </form>
  );
}
