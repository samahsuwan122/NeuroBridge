import { useEffect, useState, type FormEvent } from "react";
import { api, ApiError } from "../api/client";
import { formatDateTime } from "../lib";
import { EmptyState, Spinner } from "./ui";
import type { Encouragement, EncouragementListResponse } from "../types";

const MAX_LEN = 300;

/**
 * Family encouragement: send a short supportive message to the linked patient
 * (POST /encouragements) and show recent sent messages (GET /encouragements).
 * Family support only — never medical advice.
 */
export function EncouragementPanel({ patientId }: { patientId: string }) {
  const [items, setItems] = useState<Encouragement[]>([]);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState("");
  const [sending, setSending] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const load = async () => {
    setLoading(true);
    try {
      const res = await api<EncouragementListResponse>(
        `/encouragements?patient_profile_id=${patientId}&limit=50`,
      );
      setItems(res.encouragements);
    } catch {
      // Non-fatal: show the empty state; sending still works.
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [patientId]);

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);
    const text = message.trim();
    if (!text) {
      setError("Please write a short message.");
      return;
    }
    setSending(true);
    try {
      const created = await api<Encouragement>("/encouragements", {
        method: "POST",
        body: JSON.stringify({ patient_profile_id: patientId, message: text }),
      });
      setItems((prev) => [created, ...prev]);
      setMessage("");
      setSuccess("Encouragement sent.");
    } catch (err) {
      setError(
        err instanceof ApiError
          ? err.status === 403
            ? "This account isn't linked to this patient, so it can't send encouragement."
            : err.message
          : "Could not send the message. Please try again.",
      );
    } finally {
      setSending(false);
    }
  };

  return (
    <div className="encourage">
      <p className="mform__note">
        A supportive message for <strong>family encouragement</strong> and
        emotional support — <strong>not medical advice</strong>. For medical
        concerns, please contact the care team.
      </p>

      <form className="encourage__form" onSubmit={onSubmit}>
        <textarea
          className="encourage__input"
          rows={2}
          maxLength={MAX_LEN}
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          placeholder="Write a short, supportive message…"
        />
        <div className="encourage__row">
          <button className="btn btn--gold" type="submit" disabled={sending}>
            {sending ? "Sending…" : "Send encouragement"}
          </button>
          <span className="encourage__count">
            {message.trim().length}/{MAX_LEN}
          </span>
          {success && <span className="encourage__ok">{success}</span>}
          {error && <span className="encourage__err">{error}</span>}
        </div>
      </form>

      <div className="encourage__list">
        {loading ? (
          <Spinner label="Loading messages…" />
        ) : items.length === 0 ? (
          <EmptyState message="No encouragement messages yet." />
        ) : (
          <ul className="activity">
            {items.map((m) => (
              <li className="activity__row" key={m.id}>
                <div className="activity__main">
                  <strong>{m.message}</strong>
                  <span>{formatDateTime(m.created_at)}</span>
                </div>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}
