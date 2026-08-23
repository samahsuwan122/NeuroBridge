import { useState, type FormEvent } from "react";
import { formatDateTime } from "../lib";
import { Badge } from "./ui";
import type { ProviderMessageReply } from "../types";
import { useI18n } from "../i18n/useI18n";

const MAX = 500;

interface Bubble {
  id: string;
  senderId: string;
  senderName: string;
  text: string;
  at: string;
}

/**
 * Two-way provider chat: an optional header, an optional safety strip, the
 * original inquiry followed by chat bubbles, and a reply composer. The current
 * user's messages sit on one side, the other participant's on the other. Reply
 * submission is delegated to `onSend` (which throws on failure).
 *
 * `variant="panel"` fills its container height (log scrolls, composer pinned to
 * the bottom) for the two-panel inbox; the default "inline" caps the log height.
 *
 * Non-urgent care coordination only — not emergency care.
 */
export function ChatThread({
  originalId,
  originalSenderId,
  originalSenderName,
  originalText,
  originalAt,
  replies,
  currentUserId,
  canReply,
  disabledNote,
  onSend,
  variant = "inline",
  title,
  subtitle,
  statusLabel,
  onBack,
  avatarUrl,
  avatarText,
}: {
  originalId: string;
  originalSenderId: string;
  originalSenderName?: string | null;
  originalText: string;
  originalAt: string;
  replies: ProviderMessageReply[];
  currentUserId?: string;
  canReply: boolean;
  disabledNote?: string;
  onSend: (body: string) => Promise<void>;
  variant?: "inline" | "panel";
  title?: string;
  subtitle?: string;
  statusLabel?: string;
  onBack?: () => void;
  avatarUrl?: string;
  avatarText?: string;
}) {
  const { t, dir } = useI18n();
  const [body, setBody] = useState("");
  const [sending, setSending] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [sent, setSent] = useState(false);

  const bubbles: Bubble[] = [
    {
      id: originalId,
      senderId: originalSenderId,
      senderName: originalSenderName || t("family.chatFamily"),
      text: originalText,
      at: originalAt,
    },
    ...replies.map((r) => ({
      id: r.id,
      senderId: r.sender_user_id,
      senderName: r.sender_name || t("family.chatParticipant"),
      text: r.body,
      at: r.created_at,
    })),
  ];

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    const text = body.trim();
    if (!text) return;
    setSending(true);
    setError(null);
    setSent(false);
    try {
      await onSend(text);
      setBody("");
      setSent(true);
    } catch (err) {
      setError(err instanceof Error ? err.message : t("family.replyFailed"));
    } finally {
      setSending(false);
    }
  };

  return (
    <div className={`chat ${variant === "panel" ? "chat--panel" : ""}`}>
      {(title || onBack) && (
        <div className="chat__header">
          {onBack && (
            <button
              type="button"
              className="chat__back"
              onClick={onBack}
              aria-label={t("family.backConversations")}
            >
              {dir === "rtl" ? "›" : "‹"}
            </button>
          )}
          <span className="provider-avatar chat__avatar" aria-hidden="true">{avatarUrl ? <img src={avatarUrl} alt="" /> : avatarText}</span>
          <div className="chat__headmain">
            {title && <strong className="chat__title">{title}</strong>}
            {subtitle && <span className="chat__subtitle">{subtitle}</span>}
          </div>
          {statusLabel && <Badge tone="neutral">{statusLabel}</Badge>}
        </div>
      )}

      <div className="chat__log">
        {bubbles.map((b) => {
          const mine = Boolean(currentUserId) && b.senderId === currentUserId;
          return (
            <div
              key={b.id}
              className={`chat-bubble ${
                mine ? "chat-bubble--me" : "chat-bubble--them"
              }`}
            >
              <div className="chat-bubble__head">
                <span className="chat-bubble__name">
                  {mine ? t("family.chatYou") : b.senderName}
                </span>
                <span className="chat-bubble__time">
                  {formatDateTime(b.at)}
                </span>
              </div>
              <p className="chat-bubble__text">{b.text}</p>
            </div>
          );
        })}
      </div>

      {canReply ? (
        <form className="chat__compose" onSubmit={submit}>
          <textarea
            rows={2}
            maxLength={MAX}
            value={body}
            onChange={(e) => {
              setBody(e.target.value);
              setSent(false);
            }}
            placeholder={t("family.writeMessage")}
          />
          <div className="chat__composerow">
            <span className="chat__hint">{body.length}/{MAX}</span>
            <button
              className="btn btn--gold"
              type="submit"
              disabled={sending || !body.trim()}
            >
              {sending ? t("family.sending") : t("family.sendReply")}
            </button>
          </div>
          {error && <div className="mform__error">{error}</div>}
          {sent && <div className="mform__ok">{t("family.sent")}</div>}
        </form>
      ) : (
        disabledNote && <p className="chat__disabled muted-sub">{disabledNote}</p>
      )}
    </div>
  );
}
