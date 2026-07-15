import { useEffect, useMemo, useState } from "react";
import { api } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import { ChatThread } from "../components/ChatThread";
import { Card, ErrorState, Spinner } from "../components/ui";
import { formatDateTime } from "../lib";
import type {
  Provider,
  ProviderListResponse,
  ProviderMessage,
  ProviderMessageListResponse,
  ProviderMessageReply,
  ProviderMessageThread,
} from "../types";

const roleLabel = (role?: string) =>
  role === "therapist" ? "Therapist" : role === "doctor" ? "Doctor" : "Care provider";

/**
 * Family Messages — a two-panel inbox for provider inquiry chats. The left panel
 * lists every provider conversation with unread badges; the right panel shows the
 * selected conversation as a chat with a reply composer. Non-urgent care
 * coordination only — not emergency care.
 */
export function FamilyMessagesPage() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [threads, setThreads] = useState<ProviderMessage[]>([]);
  const [roleByProvider, setRoleByProvider] = useState<Map<string, string>>(
    new Map(),
  );

  const [openThread, setOpenThread] = useState<ProviderMessageThread | null>(
    null,
  );
  const [openId, setOpenId] = useState<string | null>(null);
  const [threadLoading, setThreadLoading] = useState(false);
  const [threadError, setThreadError] = useState<string | null>(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const [msgs, provs] = await Promise.all([
        api<ProviderMessageListResponse>("/provider-messages?limit=200"),
        api<ProviderListResponse>("/providers").catch(
          (): ProviderListResponse => ({ success: true, providers: [] }),
        ),
      ]);
      setThreads(msgs.messages);
      setRoleByProvider(
        new Map(provs.providers.map((p: Provider) => [p.provider_user_id, p.role])),
      );
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not load messages.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  const open = async (id: string) => {
    setOpenId(id);
    setThreadLoading(true);
    setThreadError(null);
    setOpenThread(null);
    try {
      const t = await api<ProviderMessageThread>(`/provider-messages/${id}`);
      setOpenThread(t);
      await api(`/provider-messages/${id}/read`, { method: "PATCH" }).catch(
        () => {},
      );
      setThreads((prev) =>
        prev.map((m) => (m.id === id ? { ...m, unread_reply_count: 0 } : m)),
      );
    } catch (err) {
      setThreadError(
        err instanceof Error ? err.message : "Could not open the thread.",
      );
    } finally {
      setThreadLoading(false);
    }
  };

  const close = () => {
    setOpenThread(null);
    setOpenId(null);
  };

  // On desktop, open the first conversation by default so the right panel is
  // never empty when threads exist. On mobile we keep the list visible until the
  // user taps a conversation (auto-opening would hide the inbox behind a chat).
  useEffect(() => {
    if (openId || threads.length === 0) return;
    const isDesktop =
      typeof window !== "undefined" &&
      window.matchMedia("(min-width: 901px)").matches;
    if (isDesktop) void open(threads[0].id);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [threads]);

  const sendReply = async (body: string) => {
    if (!openThread) return;
    const reply = await api<ProviderMessageReply>(
      `/provider-messages/${openThread.id}/replies`,
      { method: "POST", body: JSON.stringify({ body }) },
    );
    setOpenThread((prev) =>
      prev ? { ...prev, replies: [...prev.replies, reply] } : prev,
    );
    setThreads((prev) =>
      prev.map((m) =>
        m.id === openThread.id
          ? {
              ...m,
              latest_reply_preview: reply.body,
              latest_reply_at: reply.created_at,
            }
          : m,
      ),
    );
  };

  const subtitle = useMemo(() => {
    if (!openThread) return "";
    const role = roleLabel(roleByProvider.get(openThread.provider_user_id));
    return openThread.patient_name ? `${role} · ${openThread.patient_name}` : role;
  }, [openThread, roleByProvider]);

  return (
    <div className="page page--wide">
      <div className="page__head">
        <div>
          <span className="eyebrow">Messages</span>
          <h1>Provider messages</h1>
          <p className="page__sub">
            Your non-urgent inquiry conversations with care providers. Select a
            conversation to read replies and follow up.
          </p>
        </div>
      </div>

      {loading ? (
        <Spinner label="Loading messages…" />
      ) : error ? (
        <ErrorState message={error} onRetry={load} />
      ) : threads.length === 0 ? (
        <Card>
          <div className="chat-empty">
            <span className="chat-empty__icon" aria-hidden="true">
              💬
            </span>
            <h3>No conversations yet</h3>
            <p>
              Start one from a provider profile using <strong>Send inquiry</strong>
              . Messages are for non-urgent care coordination only — not emergency
              care.
            </p>
          </div>
        </Card>
      ) : (
        <div className={`msg-layout ${openId ? "msg-layout--open" : ""}`}>
          {/* Left: conversation list */}
          <aside className="msg-list" aria-label="Conversations">
            {threads.map((m) => {
              const unread = m.unread_reply_count ?? 0;
              const preview = m.latest_reply_preview || m.message;
              const updated = m.latest_reply_at || m.created_at;
              const active = openId === m.id;
              return (
                <button
                  type="button"
                  key={m.id}
                  className={`conv ${active ? "conv--active" : ""} ${
                    unread > 0 ? "conv--unread" : ""
                  }`}
                  onClick={() => open(m.id)}
                >
                  <div className="conv__row">
                    <span className="conv__name">
                      {m.provider_name || "Provider"}
                    </span>
                    <span className="conv__time">{formatDateTime(updated)}</span>
                  </div>
                  <div className="conv__row">
                    <span className="conv__preview">{preview}</span>
                    {unread > 0 && (
                      <span className="unread-dot" title="Unread replies">
                        {unread}
                      </span>
                    )}
                  </div>
                  {m.patient_name && (
                    <span className="conv__sub">{m.patient_name}</span>
                  )}
                </button>
              );
            })}
          </aside>

          {/* Right: chat panel */}
          <section className="msg-panel">
            {threadLoading ? (
              <Card className="msg-panel__card">
                <Spinner label="Opening chat…" />
              </Card>
            ) : threadError ? (
              <Card className="msg-panel__card">
                <ErrorState message={threadError} />
              </Card>
            ) : openThread ? (
              <Card className="msg-panel__card">
                <ChatThread
                  variant="panel"
                  title={openThread.provider_name || "Conversation"}
                  subtitle={subtitle}
                  statusLabel={openThread.status}
                  showSafety
                  onBack={close}
                  originalId={openThread.id}
                  originalSenderId={openThread.sender_user_id}
                  originalSenderName={openThread.sender_name}
                  originalText={openThread.message}
                  originalAt={openThread.created_at}
                  replies={openThread.replies}
                  currentUserId={user?.id}
                  canReply={openThread.sender_user_id === user?.id}
                  disabledNote="View only — this conversation was started by another linked family member."
                  onSend={sendReply}
                />
              </Card>
            ) : (
              <Card className="msg-panel__card">
                <div className="chat-empty">
                  <span className="chat-empty__icon" aria-hidden="true">
                    💬
                  </span>
                  <h3>Select a conversation</h3>
                  <p>
                    Choose a conversation on the left to read replies and follow
                    up. Non-urgent care coordination only — not emergency care.
                  </p>
                </div>
              </Card>
            )}
          </section>
        </div>
      )}
    </div>
  );
}
