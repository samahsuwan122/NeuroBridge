import {
  useEffect,
  useMemo,
  useRef,
  useState,
  type ChangeEvent,
  type KeyboardEvent,
} from "react";
import { resolveMediaUrl as resolveApiMediaUrl } from "../api/client";
import { webAccountApi } from "../api/webAccountClient";
import { useAuth } from "../auth/AuthContext";
import { Card, ErrorState, Spinner } from "../components/ui";
import { formatDateTime, initials } from "../lib";
import type {
  Provider,
  ProviderMessage,
  ProviderMessageThread,
} from "../types";
import { useI18n } from "../i18n/useI18n";
import { FamilyMemberAvatar, useFamilyMembers } from "../familyMembers";
import { useCurrentFamilyPatient } from "../currentFamilyPatient";
import { takeAiProviderDraft } from "../lib/familyAiLocalActions";

type MessageKind = "text" | "photo" | "video" | "file" | "voice";
type SenderKind = "family" | "provider";

interface LocalMessage {
  id: string;
  conversationId: string;
  senderType: SenderKind;
  senderName?: string;
  type: MessageKind;
  text?: string;
  mediaUrl?: string;
  fileName?: string;
  fileSize?: number;
  mimeType?: string;
  duration?: number;
  createdAt: string;
  origin: "local" | "server";
}

type ConversationView = "active" | "archived" | "deleted";
type ConfirmTarget =
  | { kind: "conversation" | "clear" | "permanent"; providerId: string }
  | { kind: "message"; providerId: string; messageId: string };

interface MessagePreferences {
  archived: string[];
  deleted: string[];
  cleared: string[];
  hidden: string[];
}

const MESSAGE_PREFS_KEY = "nb_family_message_preferences";
const patientPreferencesKey=(patientId?:string|null)=>patientId?`${MESSAGE_PREFS_KEY}:${patientId}`:MESSAGE_PREFS_KEY;
const emptyPreferences: MessagePreferences = { archived: [], deleted: [], cleared: [], hidden: [] };

function readMessagePreferences(patientId?:string|null): MessagePreferences {
  try {
    const scopedKey=patientPreferencesKey(patientId);let raw=localStorage.getItem(scopedKey);const migrationKey=`${MESSAGE_PREFS_KEY}:patient-migrated`;if(!raw&&patientId&&!localStorage.getItem(migrationKey)){raw=localStorage.getItem(MESSAGE_PREFS_KEY);if(raw)localStorage.setItem(scopedKey,raw);localStorage.setItem(migrationKey,"1")}
    const saved = JSON.parse(raw || "null") as Partial<MessagePreferences> | null;
    if (!saved) return emptyPreferences;
    const hidden = new Set(Array.isArray(saved.hidden) ? saved.hidden : []);
    const deleted = new Set(
      (Array.isArray(saved.deleted) ? saved.deleted : []).filter((id) => !hidden.has(id)),
    );
    const archived = new Set(
      (Array.isArray(saved.archived) ? saved.archived : []).filter(
        (id) => !hidden.has(id) && !deleted.has(id),
      ),
    );
    const cleared = new Set(
      (Array.isArray(saved.cleared) ? saved.cleared : []).filter((id) => !hidden.has(id)),
    );
    return {
      archived: [...archived],
      deleted: [...deleted],
      cleared: [...cleared],
      hidden: [...hidden],
    };
  } catch { return emptyPreferences; }
}

interface MediaDraft {
  type: Exclude<MessageKind, "text">;
  url: string;
  fileName: string;
  fileSize: number;
  mimeType: string;
  duration?: number;
}

const resolveMediaUrl = (path: string): string | undefined =>
  resolveApiMediaUrl(path) ?? undefined;

const safeFileTypes = [
  ".pdf", ".doc", ".docx", ".txt", ".rtf", ".odt", ".xls", ".xlsx",
];

function formatBytes(value = 0) {
  if (value < 1024) return `${value} B`;
  if (value < 1024 * 1024) return `${(value / 1024).toFixed(1)} KB`;
  return `${(value / 1024 / 1024).toFixed(1)} MB`;
}

function durationLabel(seconds = 0) {
  const value = Math.max(0, Math.round(seconds));
  return `${Math.floor(value / 60)}:${String(value % 60).padStart(2, "0")}`;
}

function localId() {
  return `local-${Date.now()}-${Math.random().toString(36).slice(2)}`;
}

export function FamilyMessagesPage() {
  const { t, lang } = useI18n();
  const { user } = useAuth();
  const { active, label } = useFamilyMembers();
  const {patient,copy:patientCopy,name:patientName}=useCurrentFamilyPatient();
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState(false);
  const [providers, setProviders] = useState<Provider[]>([]);
  const [threads, setThreads] = useState<ProviderMessage[]>([]);
  const [messages, setMessages] = useState<Record<string, LocalMessage[]>>({});
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [search, setSearch] = useState("");
  const [body, setBody] = useState("");
  const [familySender, setFamilySender] = useState("");
  const [senderOpen, setSenderOpen] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);
  const [draft, setDraft] = useState<MediaDraft | null>(null);
  const [preview, setPreview] = useState<LocalMessage | null>(null);
  const [recording, setRecording] = useState(false);
  const [recordSeconds, setRecordSeconds] = useState(0);
  const [micError, setMicError] = useState(false);
  const [threadLoading, setThreadLoading] = useState(false);
  const [threadError, setThreadError] = useState(false);
  const initialPreferences = useRef(readMessagePreferences(patient?.id)).current;
  const [conversationView, setConversationView] = useState<ConversationView>("active");
  const [archivedIds, setArchivedIds] = useState<Set<string>>(new Set(initialPreferences.archived));
  const [deletedIds, setDeletedIds] = useState<Set<string>>(new Set(initialPreferences.deleted));
  const [clearedIds, setClearedIds] = useState<Set<string>>(new Set(initialPreferences.cleared));
  const [hiddenIds, setHiddenIds] = useState<Set<string>>(new Set(initialPreferences.hidden));
  const [newConversationOpen, setNewConversationOpen] = useState(false);
  const [providerSearch, setProviderSearch] = useState("");
  const [conversationMenuId, setConversationMenuId] = useState<string | null>(null);
  const [messageMenuId, setMessageMenuId] = useState<string | null>(null);
  const [confirmTarget, setConfirmTarget] = useState<ConfirmTarget | null>(null);

  useEffect(() => { setFamilySender(label(active)); setSenderOpen(false); }, [active, label]);
  useEffect(()=>{const prefs=readMessagePreferences(patient?.id);setArchivedIds(new Set(prefs.archived));setDeletedIds(new Set(prefs.deleted));setClearedIds(new Set(prefs.cleared));setHiddenIds(new Set(prefs.hidden));setMessages({});setSelectedId(null);setConversationView("active")},[patient?.id]);

  const photoInput = useRef<HTMLInputElement>(null);
  const videoInput = useRef<HTMLInputElement>(null);
  const fileInput = useRef<HTMLInputElement>(null);
  const logRef = useRef<HTMLDivElement>(null);
  const mediaRecorder = useRef<MediaRecorder | null>(null);
  const mediaStream = useRef<MediaStream | null>(null);
  const chunks = useRef<Blob[]>([]);
  const timer = useRef<number | null>(null);
  const recordedSeconds = useRef(0);
  const objectUrls = useRef(new Set<string>());
  const loadedThreads = useRef(new Set<string>());
  const loadingThreads = useRef(new Set<string>());

  const providerById = useMemo(
    () => new Map(providers.map((provider) => [provider.provider_user_id, provider])),
    [providers],
  );
  const threadByProvider = useMemo(() => {
    const map = new Map<string, ProviderMessage>();
    for (const thread of threads) {
      const current = map.get(thread.provider_user_id);
      const nextTime = thread.latest_reply_at || thread.created_at;
      const currentTime = current?.latest_reply_at || current?.created_at || "";
      if (!current || nextTime > currentTime) map.set(thread.provider_user_id, thread);
    }
    return map;
  }, [threads]);

  const roleLabel = (role?: string) =>
    role === "therapist"
      ? t("family.therapist")
      : role === "doctor"
        ? t("family.doctor")
        : t("family.careProvider");

  const load = async () => {
    setLoading(true);
    setLoadError(false);
    try {
      if (!patient) return;
      const result = await webAccountApi<{
        success: boolean;
        providers: Provider[];
        messages: ProviderMessage[];
      }>(`family_messages.php?action=list&patient_id=${encodeURIComponent(patient.id)}`);
      const providerResult = { providers: result.providers };
      const threadResult = { messages: result.messages };
      setProviders(providerResult.providers);
      const aiDraft=takeAiProviderDraft();
      if(aiDraft&&aiDraft.patientId===patient?.id&&providerResult.providers.some(item=>item.provider_user_id===aiDraft.providerId)){setSelectedId(aiDraft.providerId);setBody(aiDraft.body)}
      const patientThreads=threadResult.messages.filter(thread=>thread.patient_profile_id===patient?.id);
      setThreads(patientThreads);
      const firstConversation = providerResult.providers.find((provider) =>
        patientThreads.some((thread) => thread.provider_user_id === provider.provider_user_id),
      );
      if (!aiDraft&&window.matchMedia("(min-width: 901px)").matches && firstConversation) {
        setSelectedId(firstConversation.provider_user_id);
      }
    } catch {
      setLoadError(true);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { if(patient)void load();else{setThreads([]);setProviders([]);setLoading(false)} }, [patient?.id]);

  useEffect(() => () => {
    if (timer.current) window.clearInterval(timer.current);
    mediaStream.current?.getTracks().forEach((track) => track.stop());
    objectUrls.current.forEach((url) => URL.revokeObjectURL(url));
    objectUrls.current.clear();
  }, []);

  useEffect(() => {
    try {
      localStorage.setItem(patientPreferencesKey(patient?.id), JSON.stringify({
        archived: [...archivedIds], deleted: [...deletedIds],
        cleared: [...clearedIds], hidden: [...hiddenIds],
      } satisfies MessagePreferences));
    } catch { /* preferences remain session-local when storage is unavailable */ }
  }, [archivedIds, deletedIds, clearedIds, hiddenIds,patient?.id]);

  useEffect(() => {
    if (!newConversationOpen && !confirmTarget) return;
    const closeOnEscape = (event: globalThis.KeyboardEvent) => {
      if (event.key !== "Escape") return;
      if (confirmTarget) setConfirmTarget(null);
      else setNewConversationOpen(false);
    };
    window.addEventListener("keydown", closeOnEscape);
    return () => window.removeEventListener("keydown", closeOnEscape);
  }, [newConversationOpen, confirmTarget]);

  const openProvider = async (providerId: string) => {
    setSelectedId(providerId);
    setMenuOpen(false);
    setThreadError(false);
    const summary = hiddenIds.has(providerId) ? undefined : threadByProvider.get(providerId);
    if (!summary || loadedThreads.current.has(summary.id) || loadingThreads.current.has(summary.id)) return;
    loadingThreads.current.add(summary.id);
    setThreadLoading(true);
    try {
      if (!patient) return;
      const thread = await webAccountApi<ProviderMessageThread>(
        `family_messages.php?action=thread&id=${encodeURIComponent(summary.id)}&patient_id=${encodeURIComponent(patient.id)}`,
      );
      const local: LocalMessage[] = [
        {
          id: thread.id,
          conversationId: providerId,
          senderType: thread.sender_user_id === user?.id ? "family" : "provider",
          senderName: thread.sender_name ?? undefined,
          type: "text",
          text: thread.message,
          createdAt: thread.created_at,
          origin: "server",
        },
        ...thread.replies.map((reply) => ({
          id: reply.id,
          conversationId: providerId,
          senderType: reply.sender_user_id === user?.id ? "family" as const : "provider" as const,
          senderName: reply.sender_name ?? undefined,
          type: "text" as const,
          text: reply.body,
          createdAt: reply.created_at,
          origin: "server" as const,
        })),
      ];
      if (!clearedIds.has(providerId)) setMessages((current) => ({ ...current, [providerId]: local }));
      loadedThreads.current.add(summary.id);
      setThreads((current) => current.map((item) => item.provider_user_id === providerId ? { ...item, unread_reply_count: 0 } : item));
      await webAccountApi("family_messages.php", {
        method: "PATCH",
        body: JSON.stringify({ action: "read", id: summary.id, patient_id: patient.id }),
      }).catch(() => undefined);
    } catch {
      setThreadError(true);
    } finally {
      loadingThreads.current.delete(summary.id);
      setThreadLoading(false);
    }
  };

  useEffect(() => {
    if (selectedId) void openProvider(selectedId);
  }, [selectedId]);

  useEffect(() => {
    const node = logRef.current;
    if (!node) return;
    requestAnimationFrame(() => node.scrollTo({ top: node.scrollHeight, behavior: "smooth" }));
  }, [selectedId, messages]);

  const createUrl = (blob: Blob) => {
    const url = URL.createObjectURL(blob);
    objectUrls.current.add(url);
    return url;
  };

  const clearDraft = (revoke = true) => {
    if (draft && revoke) {
      URL.revokeObjectURL(draft.url);
      objectUrls.current.delete(draft.url);
    }
    setDraft(null);
  };

  const chooseMedia = (event: ChangeEvent<HTMLInputElement>, type: "photo" | "video" | "file") => {
    const file = event.target.files?.[0];
    event.target.value = "";
    if (!file) return;
    if (type === "file" && !safeFileTypes.some((extension) => file.name.toLowerCase().endsWith(extension))) return;
    clearDraft();
    setDraft({ type, url: createUrl(file), fileName: file.name, fileSize: file.size, mimeType: file.type });
    setMenuOpen(false);
  };

  const stopStream = () => {
    mediaStream.current?.getTracks().forEach((track) => track.stop());
    mediaStream.current = null;
    if (timer.current) window.clearInterval(timer.current);
    timer.current = null;
  };

  const startRecording = async () => {
    setMicError(false);
    clearDraft();
    try {
      if (!navigator.mediaDevices?.getUserMedia || typeof MediaRecorder === "undefined") throw new Error("unsupported");
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      mediaStream.current = stream;
      chunks.current = [];
      const recorder = new MediaRecorder(stream);
      mediaRecorder.current = recorder;
      recorder.ondataavailable = (event) => { if (event.data.size) chunks.current.push(event.data); };
      recorder.onstop = () => {
        const blob = new Blob(chunks.current, { type: recorder.mimeType || "audio/webm" });
        setDraft({ type: "voice", url: createUrl(blob), fileName: "voice-message.webm", fileSize: blob.size, mimeType: blob.type, duration: recordedSeconds.current });
        stopStream();
      };
      setRecordSeconds(0);
      recordedSeconds.current = 0;
      setRecording(true);
      recorder.start();
      timer.current = window.setInterval(() => setRecordSeconds((value) => {
        const next = value + 1;
        recordedSeconds.current = next;
        return next;
      }), 1000);
      setMenuOpen(false);
    } catch {
      setMicError(true);
      stopStream();
    }
  };

  const stopRecording = () => {
    setRecording(false);
    mediaRecorder.current?.stop();
  };

  const send = async () => {
    if (!selectedId || !patient || (!body.trim() && !draft)) return;
    const text = body.trim() || (draft ? `📎 ${draft.fileName}` : "");
    const summary = threadByProvider.get(selectedId);
    try {
      if (summary) {
        await webAccountApi("family_messages.php", {
          method: "PATCH",
          body: JSON.stringify({ action: "reply", id: summary.id, patient_id: patient.id, message: text }),
        });
      } else {
        const created = await webAccountApi<ProviderMessage>("family_messages.php", {
          method: "POST",
          body: JSON.stringify({ provider_id: selectedId, patient_id: patient.id, message: text }),
        });
        setThreads((current) => [created, ...current]);
      }
    } catch {
      setThreadError(true);
      return;
    }
    const next: LocalMessage = {
      id: localId(),
      conversationId: selectedId,
      senderType: "family",
      senderName: familySender.trim() || undefined,
      type: draft?.type ?? "text",
      text,
      mediaUrl: draft?.url,
      fileName: draft?.fileName,
      fileSize: draft?.fileSize,
      mimeType: draft?.mimeType,
      duration: draft?.duration,
      createdAt: new Date().toISOString(),
      origin: "local",
    };
    setMessages((current) => ({ ...current, [selectedId]: [...(current[selectedId] ?? []), next] }));
    setClearedIds((current) => { const nextIds = new Set(current); nextIds.delete(selectedId); return nextIds; });
    setHiddenIds((current) => { const nextIds = new Set(current); nextIds.delete(selectedId); return nextIds; });
    setBody("");
    clearDraft(false);
  };

  const onComposerKeyDown = (event: KeyboardEvent<HTMLTextAreaElement>) => {
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault();
      void send();
    }
  };

  const selected = selectedId ? providerById.get(selectedId) : undefined;
  const activeMessages = selectedId && !clearedIds.has(selectedId) ? messages[selectedId] ?? [] : [];
  const hasConversation = (providerId: string) =>
    !hiddenIds.has(providerId) &&
    (threadByProvider.has(providerId) || (messages[providerId]?.length ?? 0) > 0 || clearedIds.has(providerId) || deletedIds.has(providerId));
  const conversationProviders = useMemo(() => providers.filter((provider) => {
    if (!hasConversation(provider.provider_user_id)) return false;
    if (conversationView === "deleted") return deletedIds.has(provider.provider_user_id);
    if (deletedIds.has(provider.provider_user_id)) return false;
    return conversationView === "archived" ? archivedIds.has(provider.provider_user_id) : !archivedIds.has(provider.provider_user_id);
  }), [providers, messages, threadByProvider, hiddenIds, clearedIds, deletedIds, archivedIds, conversationView]);
  const filteredProviders = useMemo(() => {
    const query = search.trim().toLocaleLowerCase();
    if (!query) return conversationProviders;
    return conversationProviders.filter((provider) => {
      const providerMessages = messages[provider.provider_user_id];
      const latest = providerMessages?.[providerMessages.length - 1]?.text || threadByProvider.get(provider.provider_user_id)?.latest_reply_preview || threadByProvider.get(provider.provider_user_id)?.message;
      return [provider.full_name, roleLabel(provider.role), latest].some((value) => value?.toLocaleLowerCase().includes(query));
    });
  }, [conversationProviders, search, messages, threadByProvider]);
  const availableProviders = useMemo(() => {
    const query = search.trim().toLocaleLowerCase();
    if (!query || conversationView !== "active") return [];
    return providers.filter((provider) => !hasConversation(provider.provider_user_id) &&
      [provider.full_name, roleLabel(provider.role)].some((value) => value.toLocaleLowerCase().includes(query)));
  }, [providers, search, messages, threadByProvider, hiddenIds, clearedIds, deletedIds, conversationView]);
  const pickerProviders = useMemo(() => {
    const query = providerSearch.trim().toLocaleLowerCase();
    return providers.filter((provider) => !hasConversation(provider.provider_user_id) &&
      (!query || [provider.full_name, roleLabel(provider.role)].some((value) => value.toLocaleLowerCase().includes(query))));
  }, [providers, providerSearch, messages, threadByProvider, hiddenIds, clearedIds, deletedIds]);

  const archiveConversation = (providerId: string) => {
    setArchivedIds((current) => new Set(current).add(providerId));
    setDeletedIds((current) => { const next = new Set(current); next.delete(providerId); return next; });
    setConversationMenuId(null);
    if (selectedId === providerId) setSelectedId(null);
  };
  const restoreConversation = (providerId: string) => {
    setArchivedIds((current) => { const next = new Set(current); next.delete(providerId); return next; });
    setDeletedIds((current) => { const next = new Set(current); next.delete(providerId); return next; });
    setConversationMenuId(null);
    setConversationView("active");
  };
  const revokeMessageMedia = (message: LocalMessage) => {
    if (message.origin !== "local" || !message.mediaUrl || !objectUrls.current.has(message.mediaUrl)) return;
    URL.revokeObjectURL(message.mediaUrl);
    objectUrls.current.delete(message.mediaUrl);
  };
  const confirmDelete = () => {
    if (!confirmTarget) return;
    if (confirmTarget.kind === "message") {
      setMessages((current) => {
        const target = current[confirmTarget.providerId]?.find((message) => message.id === confirmTarget.messageId);
        if (target) revokeMessageMedia(target);
        return { ...current, [confirmTarget.providerId]: (current[confirmTarget.providerId] ?? []).filter((message) => message.id !== confirmTarget.messageId) };
      });
    } else if (confirmTarget.kind === "clear") {
      const providerId = confirmTarget.providerId;
      const providerMessages = messages[providerId] ?? [];
      providerMessages.filter((message) => message.origin === "local").forEach(revokeMessageMedia);
      setMessages((current) => ({ ...current, [providerId]: [] }));
      setClearedIds((current) => new Set(current).add(providerId));
    } else if (confirmTarget.kind === "conversation") {
      const providerId = confirmTarget.providerId;
      setDeletedIds((current) => new Set(current).add(providerId));
      setArchivedIds((current) => { const next = new Set(current); next.delete(providerId); return next; });
      if (selectedId === providerId) setSelectedId(null);
      setConversationView("deleted");
    } else {
      const providerId = confirmTarget.providerId;
      (messages[providerId] ?? []).filter((message) => message.origin === "local").forEach(revokeMessageMedia);
      setMessages((current) => { const next = { ...current }; delete next[providerId]; return next; });
      setHiddenIds((current) => new Set(current).add(providerId));
      setDeletedIds((current) => { const next = new Set(current); next.delete(providerId); return next; });
      setClearedIds((current) => { const next = new Set(current); next.delete(providerId); return next; });
      setArchivedIds((current) => { const next = new Set(current); next.delete(providerId); return next; });
      if (selectedId === providerId) setSelectedId(null);
    }
    setMessageMenuId(null); setConversationMenuId(null); setConfirmTarget(null);
  };

  const conversationActions = (providerId: string, header = false) => <div className={`conversation-menu ${header ? "conversation-menu--header" : ""}`}>
    {deletedIds.has(providerId) ? <>
      <button type="button" onClick={() => restoreConversation(providerId)}>↩ {t("family.restoreDeletedConversation")}</button>
      <button type="button" className="is-danger" onClick={() => setConfirmTarget({ kind: "permanent", providerId })}>⌫ {t("family.deleteFromDevice")}</button>
    </> : <>
      {archivedIds.has(providerId)
        ? <button type="button" onClick={() => restoreConversation(providerId)}>↩ {t("family.restoreToActive")}</button>
        : <button type="button" onClick={() => archiveConversation(providerId)}>▣ {t("family.archiveConversation")}</button>}
      <button type="button" onClick={() => setConfirmTarget({ kind: "clear", providerId })}>◌ {t("family.clearChat")}</button>
      <button type="button" className="is-danger" onClick={() => setConfirmTarget({ kind: "conversation", providerId })}>⌫ {t("family.deleteConversation")}</button>
    </>}
  </div>;

  const dateLabel = (iso: string) => {
    const date = new Date(iso); const today = new Date();
    const start = new Date(today.getFullYear(), today.getMonth(), today.getDate()).getTime();
    const target = new Date(date.getFullYear(), date.getMonth(), date.getDate()).getTime();
    if (target === start) return t("family.today");
    if (target === start - 86400000) return t("family.yesterday");
    return new Intl.DateTimeFormat(lang, { dateStyle: "medium" }).format(date);
  };

  let previousDate = "";
  return <div className="page page--wide family-messages-page">
    <div className="page__head"><div><span className="eyebrow">{t("family.messagesEyebrow")}</span><h1>{t("family.messagesTitle")}</h1><p className="page__sub">{t("family.messagesSub")}</p>{patient&&<small className="patient-context-line">{patientCopy.current}: {patientName(patient)}</small>}</div></div>
    {loading ? <div className="messages-state"><Spinner label={t("family.loadingMessages")} /></div> : loadError ? <div className="messages-state"><ErrorState message={t("family.messagesLoadFailed")} onRetry={load} /></div> :
      <Card className={`messages-workspace ${selectedId ? "messages-workspace--open" : ""}`}>
        <aside className="msg-list" aria-label={t("family.conversations")}>
          <div className="msg-list__head"><strong>{t("family.conversations")}</strong><div className="conversation-head-actions"><small>{conversationProviders.length}</small><button type="button" className="new-conversation-button" onClick={() => setNewConversationOpen(true)} aria-label={t("family.newConversationAction")} aria-expanded={newConversationOpen}>＋</button></div></div>
          <div className="conversation-tabs" role="tablist" aria-label={t("family.conversationFilter")}><button type="button" role="tab" aria-selected={conversationView === "active"} className={conversationView === "active" ? "is-active" : ""} onClick={() => { setConversationView("active"); setSelectedId(null); }}>{t("family.activeConversations")} <small>{providers.filter((provider) => hasConversation(provider.provider_user_id) && !archivedIds.has(provider.provider_user_id) && !deletedIds.has(provider.provider_user_id)).length}</small></button><button type="button" role="tab" aria-selected={conversationView === "archived"} className={conversationView === "archived" ? "is-active" : ""} onClick={() => { setConversationView("archived"); setSelectedId(null); }}>{t("family.archivedConversations")} <small>{archivedIds.size}</small></button><button type="button" role="tab" aria-selected={conversationView === "deleted"} className={conversationView === "deleted" ? "is-active" : ""} onClick={() => { setConversationView("deleted"); setSelectedId(null); }}>{t("family.deletedConversations")} <small>{deletedIds.size}</small></button></div>
          <label className="msg-search"><span aria-hidden="true">⌕</span><input value={search} onChange={(event) => setSearch(event.target.value)} placeholder={t("family.searchConversationsProviders")} aria-label={t("family.searchConversationsProviders")} /></label>
          <div className="msg-list__scroll">
            {filteredProviders.map((provider) => {
              const summary = threadByProvider.get(provider.provider_user_id);
              const providerMessages = messages[provider.provider_user_id];
              const localLatest = providerMessages?.[providerMessages.length - 1];
              const previewText = clearedIds.has(provider.provider_user_id) ? t("family.noCurrentMessages") : localLatest?.text || localLatest?.fileName || summary?.latest_reply_preview || summary?.message || t("family.noMessagesYet");
              const previewTime = localLatest?.createdAt || summary?.latest_reply_at || summary?.created_at;
              const unread = conversationView === "deleted" ? 0 : summary?.unread_reply_count ?? 0;
              return <div className="conv-shell" key={provider.provider_user_id}><button type="button" className={`conv ${selectedId === provider.provider_user_id ? "conv--active" : ""} ${unread ? "conv--unread" : ""}`} onClick={() => void openProvider(provider.provider_user_id)} aria-label={t("family.openConversationWith", { name: provider.full_name })}>
                <span className="provider-avatar">{provider.photo_url ? <img src={resolveMediaUrl(provider.photo_url)} alt="" /> : initials(provider.full_name)}</span>
                <span className="conv__body"><span className="conv__row"><strong className="conv__name">{provider.full_name}</strong>{previewTime && <time className="conv__time">{formatDateTime(previewTime)}</time>}</span><span className="conv__role">{roleLabel(provider.role)}</span><span className="conv__row"><span className="conv__preview">{previewText}</span>{unread > 0 && <span className="unread-dot">{unread}</span>}</span></span>
              </button><button type="button" className="conversation-menu-button" onClick={() => setConversationMenuId((value) => value === provider.provider_user_id ? null : provider.provider_user_id)} aria-label={t("family.conversationMenu", { name: provider.full_name })} aria-expanded={conversationMenuId === provider.provider_user_id}>⋯</button>{conversationMenuId === provider.provider_user_id && conversationActions(provider.provider_user_id)}</div>;
            })}
            {availableProviders.length > 0 && <div className="new-provider-results"><strong>{t("family.startNewConversation")}</strong>{availableProviders.map((provider) => <button type="button" key={provider.provider_user_id} onClick={() => void openProvider(provider.provider_user_id)}><span className="provider-avatar">{provider.photo_url ? <img src={resolveMediaUrl(provider.photo_url)} alt="" /> : initials(provider.full_name)}</span><span><strong>{provider.full_name}</strong><small>{roleLabel(provider.role)}</small></span></button>)}</div>}
            {!filteredProviders.length && !availableProviders.length && <div className="msg-list__empty"><span aria-hidden="true">{search ? "⌕" : conversationView === "deleted" ? "⌫" : "✉"}</span><strong>{search ? t("family.noSearchResults") : conversationView === "deleted" ? t("family.noDeletedConversations") : conversationView === "archived" ? t("family.noArchivedConversations") : t("family.noActiveConversations")}</strong>{!search && conversationView === "active" && <><p>{t("family.startProviderConversation")}</p><button type="button" className="btn btn--gold" onClick={() => setNewConversationOpen(true)}>＋ {t("family.newConversationAction")}</button></>}</div>}
          </div>
        </aside>
        <section className="msg-panel">
          {!selected ? <div className="chat-empty msg-panel__empty"><span aria-hidden="true">✉</span><h3>{t("family.chooseConversation")}</h3><p>{t("family.chooseConversationHelp")}</p></div> :
            <div className="demo-chat">
              <header className="chat__header"><button type="button" className="chat__back" onClick={() => setSelectedId(null)} aria-label={t("family.backConversations")}>‹</button><span className="provider-avatar chat__avatar">{selected.photo_url ? <img src={resolveMediaUrl(selected.photo_url)} alt="" /> : initials(selected.full_name)}</span><div className="chat__headmain"><strong className="chat__title">{selected.full_name}</strong><span className="chat__subtitle">{roleLabel(selected.role)} · {deletedIds.has(selected.provider_user_id) ? t("family.deleted") : archivedIds.has(selected.provider_user_id) ? t("family.archived") : t("family.careTeam")}</span></div>{hasConversation(selected.provider_user_id) && <div className="chat-conversation-actions"><button type="button" onClick={() => setConversationMenuId((value) => value === selected.provider_user_id ? null : selected.provider_user_id)} aria-label={t("family.conversationMenu", { name: selected.full_name })}>⋯</button>{conversationMenuId === selected.provider_user_id && conversationActions(selected.provider_user_id, true)}</div>}</header>
              {threadLoading ? <Spinner label={t("family.openingChat")} /> : threadError ? <ErrorState message={t("family.conversationLoadFailed")} onRetry={() => void openProvider(selected.provider_user_id)} /> :
                <div className="chat__log" ref={logRef} aria-live="polite">
                  {!activeMessages.length && <div className="chat-empty demo-chat__empty"><span aria-hidden="true">✦</span><h3>{clearedIds.has(selected.provider_user_id) ? t("family.chatCleared") : t("family.startConversationWith", { name: selected.full_name })}</h3><p>{clearedIds.has(selected.provider_user_id) ? t("family.startNewMessage") : t("family.newConversationMediaHelp")}</p></div>}
                  {activeMessages.map((message) => {
                    const group = dateLabel(message.createdAt); const showGroup = group !== previousDate; previousDate = group;
                    return <div className="demo-message-wrap" key={message.id}>{showGroup && <div className="message-date"><span>{group}</span></div>}<article className={`chat-bubble chat-bubble--${message.senderType === "family" ? "me" : "them"}`}>
                      {message.origin === "local" && <div className="message-actions"><button type="button" onClick={() => setMessageMenuId((value) => value === message.id ? null : message.id)} aria-label={t("family.messageMenu")}>⋯</button>{messageMenuId === message.id && <div><button type="button" onClick={() => setConfirmTarget({ kind: "message", providerId: selected.provider_user_id, messageId: message.id })}>{t("family.deleteMessage")}</button></div>}</div>}
                      {message.type === "photo" && <button className="message-media-button" onClick={() => setPreview(message)} aria-label={t("family.openPhotoPreview")}><img className="message-photo" src={message.mediaUrl} alt={message.fileName || t("family.photo")} /></button>}
                      {message.type === "video" && <video className="message-video" src={message.mediaUrl} controls playsInline preload="metadata" />}
                      {message.type === "file" && <a className="message-file" href={message.mediaUrl} download={message.fileName}><span aria-hidden="true">▤</span><span><strong>{message.fileName}</strong><small>{formatBytes(message.fileSize)}</small></span></a>}
                      {message.type === "voice" && <div className="message-voice"><span aria-hidden="true">🎙</span><audio src={message.mediaUrl} controls preload="metadata" /><time>{durationLabel(message.duration)}</time></div>}
                      {message.text && <p className="chat-bubble__text" dir="auto">{message.text}</p>}
                      <footer className="chat-bubble__meta">{message.senderType === "family" && message.senderName && <span>{message.senderName}</span>}<time>{formatDateTime(message.createdAt)}</time></footer>
                    </article></div>;
                  })}
                </div>}
              {deletedIds.has(selected.provider_user_id) ? <div className="archived-composer deleted-composer"><span>{t("family.conversationInDeleted")}</span><button type="button" className="btn btn--gold" onClick={() => restoreConversation(selected.provider_user_id)}>{t("family.restoreDeletedConversation")}</button></div> : archivedIds.has(selected.provider_user_id) ? <div className="archived-composer"><span>{t("family.archivedComposerHelp")}</span><button type="button" className="btn btn--gold" onClick={() => restoreConversation(selected.provider_user_id)}>{t("family.restoreConversation")}</button></div> : <div className="demo-composer">
                {draft && <div className="media-draft">{draft.type === "photo" && <img src={draft.url} alt="" />}{draft.type === "video" && <video src={draft.url} controls playsInline />}{draft.type === "file" && <span className="media-draft__file">▤ <strong>{draft.fileName}</strong> <small>{formatBytes(draft.fileSize)}</small></span>}{draft.type === "voice" && <><audio src={draft.url} controls /><button type="button" className="voice-record-again" onClick={() => void startRecording()}>{t("family.recordAgain")}</button></>}<button type="button" className="media-draft__remove" onClick={() => clearDraft()} aria-label={t("family.removeAttachment")}>×</button></div>}
                {recording && <div className="voice-recording"><span><i /> {t("family.recording")} <strong>{durationLabel(recordSeconds)}</strong></span><button type="button" onClick={stopRecording}>{t("family.stopRecording")}</button></div>}
                {micError && <div className="mform__error">{t("family.microphoneUnavailable")}</div>}
                <div className="sender-control"><button type="button" className="sender-chip sender-chip--member" onClick={() => setSenderOpen((value) => !value)} aria-expanded={senderOpen}><FamilyMemberAvatar member={active}/><span>{familySender ? `${t("family.familySender")}: ${familySender}` : t("family.setSender")}</span></button>{senderOpen && <div className="sender-popover"><label>{t("family.familySender")}<input autoFocus value={familySender} onChange={(event) => setFamilySender(event.target.value)} placeholder={t("family.familySenderExample")} /></label><button type="button" onClick={() => setSenderOpen(false)}>✓</button></div>}</div>
                <div className="composer-main"><div className="attachment-wrap"><button type="button" className="composer-attach" onClick={() => setMenuOpen((value) => !value)} aria-label={t("family.attachMessage")} aria-expanded={menuOpen}>＋</button>{menuOpen && <div className="attachment-menu"><button type="button" onClick={() => photoInput.current?.click()}>{t("family.photo")}</button><button type="button" onClick={() => videoInput.current?.click()}>{t("family.video")}</button><button type="button" onClick={() => fileInput.current?.click()}>{t("family.file")}</button><button type="button" onClick={() => void startRecording()}>{t("family.voiceMessage")}</button></div>}</div><textarea rows={1} value={body} onChange={(event) => setBody(event.target.value)} onKeyDown={onComposerKeyDown} placeholder={t("family.writeMessage")} aria-label={t("family.writeMessage")} /><button type="button" className="btn btn--gold composer-send" onClick={() => void send()} disabled={!body.trim() && !draft} aria-label={t("family.send")}>{t("family.send")}</button></div>
                <input ref={photoInput} hidden type="file" accept="image/*" onChange={(event) => chooseMedia(event, "photo")} /><input ref={videoInput} hidden type="file" accept="video/*" onChange={(event) => chooseMedia(event, "video")} /><input ref={fileInput} hidden type="file" accept=".pdf,.doc,.docx,.txt,.rtf,.odt,.xls,.xlsx" onChange={(event) => chooseMedia(event, "file")} />
              </div>}
            </div>}
        </section>
      </Card>}
    {newConversationOpen && <div className="new-conversation-dialog-backdrop" onMouseDown={(event) => { if (event.target === event.currentTarget) setNewConversationOpen(false); }}><div className="new-conversation-dialog" role="dialog" aria-modal="true" aria-labelledby="new-conversation-title"><header><div><h2 id="new-conversation-title">{t("family.startNewConversation")}</h2><p>{t("family.chooseCareProvider")}</p></div><button type="button" onClick={() => setNewConversationOpen(false)} aria-label={t("family.closeNewConversation")}>×</button></header><label><span aria-hidden="true">⌕</span><input autoFocus value={providerSearch} onChange={(event) => setProviderSearch(event.target.value)} placeholder={t("family.searchCareProviders")} aria-label={t("family.searchCareProviders")} /></label><div className="new-conversation-dialog__results">{pickerProviders.map((provider) => <button type="button" key={provider.provider_user_id} onClick={() => { setNewConversationOpen(false); setProviderSearch(""); void openProvider(provider.provider_user_id); }}><span className="provider-avatar">{provider.photo_url ? <img src={resolveMediaUrl(provider.photo_url)} alt="" /> : initials(provider.full_name)}</span><span><strong>{provider.full_name}</strong><small>{roleLabel(provider.role)}</small></span></button>)}{!pickerProviders.length && <div className="new-conversation-dialog__empty">{t("family.noMatchingProviders")}</div>}</div></div></div>}
    {preview && <div className="media-modal" role="dialog" aria-modal="true" aria-label={t("family.messageMediaPreview")} onClick={() => setPreview(null)}><button type="button" onClick={() => setPreview(null)} aria-label={t("family.closePreview")}>×</button>{preview.type === "photo" ? <img src={preview.mediaUrl} alt={preview.fileName || ""} onClick={(event) => event.stopPropagation()} /> : <video src={preview.mediaUrl} controls playsInline onClick={(event) => event.stopPropagation()} />}</div>}
    {confirmTarget && <div className="confirm-dialog-backdrop" role="presentation"><div className="confirm-dialog" role="alertdialog" aria-modal="true" aria-labelledby="delete-dialog-title"><span aria-hidden="true">{confirmTarget.kind === "clear" ? "◌" : "⌫"}</span><h2 id="delete-dialog-title">{confirmTarget.kind === "message" ? t("family.deleteMessageTitle") : confirmTarget.kind === "clear" ? t("family.clearChatTitle") : confirmTarget.kind === "permanent" ? t("family.permanentDeleteTitle") : t("family.moveToDeletedTitle")}</h2><p>{confirmTarget.kind === "message" ? t("family.deleteMessageDescription") : confirmTarget.kind === "clear" ? t("family.clearChatDescription") : confirmTarget.kind === "permanent" ? t("family.permanentDeleteDescription") : t("family.moveToDeletedDescription")}</p><div><button type="button" className="btn btn--ghost" onClick={() => setConfirmTarget(null)}>{t("common.cancel")}</button><button type="button" className="btn confirm-delete" onClick={confirmDelete}>{confirmTarget.kind === "message" ? t("family.deleteMessage") : confirmTarget.kind === "clear" ? t("family.clearChat") : confirmTarget.kind === "permanent" ? t("family.deletePermanently") : t("family.moveToDeleted")}</button></div></div></div>}
  </div>;
}
