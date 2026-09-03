import { useEffect, useState, type FormEvent } from "react";
import { api, ApiError } from "../api/client";
import { formatDateTime } from "../lib";
import { EmptyState, Spinner } from "./ui";
import type { Encouragement, EncouragementListResponse } from "../types";
import { useI18n } from "../i18n/useI18n";

const MAX_LEN = 300;

/**
 * Family encouragement: send a short supportive message to the linked patient
 * (POST /encouragements) and show recent sent messages (GET /encouragements).
 * Family support only — never medical advice.
 */
export function EncouragementPanel({ patientId }: { patientId: string }) {
  const { t } = useI18n();
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
      setError(t("family.writeShortMessage"));
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
      setSuccess(t("family.encouragementSent"));
    } catch (err) {
      setError(
        err instanceof ApiError
          ? err.status === 403
            ? t("family.notLinkedSend")
            : err.message
          : t("family.sendFailed"),
      );
    } finally {
      setSending(false);
    }
  };

  return (
    <div className="encourage">
      <form className="encourage__form" onSubmit={onSubmit}>
        <textarea
          className="encourage__input"
          rows={2}
          maxLength={MAX_LEN}
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          placeholder={t("family.writeEncouragement")}
        />
        <div className="encourage__row">
          <button className="btn btn--gold" type="submit" disabled={sending}>
            {sending ? t("family.sending") : t("family.sendEncouragement")}
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
          <Spinner label={t("family.loading")} />
        ) : items.length === 0 ? (
          <EmptyState message={t("family.noEncouragement")} />
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
