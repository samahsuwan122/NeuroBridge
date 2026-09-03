import {
  useEffect,
  useRef,
  useState,
  type ChangeEvent,
  type FormEvent,
} from "react";
import { useI18n } from "../i18n/useI18n";
import { FamilyMemberAvatar, useFamilyMembers } from "../familyMembers";
import { useCurrentFamilyPatient } from "../currentFamilyPatient";
import { AI_ACTION_EVENT,readAiEncouragements } from "../lib/familyAiLocalActions";

const MESSAGE_MAX = 300;
const CAPTION_MAX = 180;
const PREVIEW_MAX_BYTES = 80 * 1024 * 1024;

type MediaKind = "image" | "video" | "voice";
type ComposerMode = "text" | MediaKind;

interface LocalMedia {
  kind: MediaKind;
  url?: string;
  name?: string;
  duration?: number;
  placeholder?: boolean;
}

interface PreviewItem {
  id: string;
  patientId?:string;
  sender: string;
  timestampKey: "encourage.justNow" | "encourage.today";
  message?: string;
  caption?: string;
  media?: LocalMedia;
}

function formatDuration(seconds: number): string {
  const minutes = Math.floor(seconds / 60);
  return `${String(minutes).padStart(2, "0")}:${String(seconds % 60).padStart(2, "0")}`;
}

export function MultimediaEncouragementComposer() {
  const { t } = useI18n();
  const { active, members, label } = useFamilyMembers();
  const {patient,copy:patientCopy,name:patientName}=useCurrentFamilyPatient();
  const demoSender = label(members.find((member) => member.id === "demo-omar") ?? members[0] ?? null) || t("encourage.demoSender");
  const sender = label(active) || demoSender;
  const [message, setMessage] = useState("");
  const [mode, setMode] = useState<ComposerMode>("text");
  const [caption, setCaption] = useState("");
  const [media, setMedia] = useState<LocalMedia | null>(null);
  const [recording, setRecording] = useState(false);
  const [elapsed, setElapsed] = useState(0);
  const [status, setStatus] = useState("");
  const [error, setError] = useState("");
  const [items, setItems] = useState<PreviewItem[]>(() => [
    {
      id: "demo-text",
      patientId:patient?.id,
      sender: demoSender,
      timestampKey: "encourage.today",
      message: "encourage.demoText",
    },
    {
      id: "demo-voice",
      patientId:patient?.id,
      sender: demoSender,
      timestampKey: "encourage.today",
      caption: "encourage.demoVoice",
      media: { kind: "voice", duration: 18, placeholder: true },
    },
    {
      id: "demo-image",
      patientId:patient?.id,
      sender: demoSender,
      timestampKey: "encourage.today",
      caption: "encourage.demoImage",
      media: { kind: "image", placeholder: true },
    },
    {
      id: "demo-video",
      patientId:patient?.id,
      sender: demoSender,
      timestampKey: "encourage.today",
      caption: "encourage.demoVideo",
      media: { kind: "video", placeholder: true },
    },
  ]);

  const imageInput = useRef<HTMLInputElement>(null);
  const videoInput = useRef<HTMLInputElement>(null);
  const messageInput = useRef<HTMLTextAreaElement>(null);
  const recorder = useRef<MediaRecorder | null>(null);
  const stream = useRef<MediaStream | null>(null);
  const chunks = useRef<Blob[]>([]);
  const timer = useRef<number | null>(null);
  const elapsedRef = useRef(0);
  const ownedUrls = useRef(new Set<string>());
  useEffect(()=>{const sync=()=>{const local=readAiEncouragements().filter(item=>item.patientId===patient?.id).map(item=>({id:item.id,patientId:item.patientId,sender:item.sender,timestampKey:"encourage.justNow" as const,message:item.message}));setItems(current=>{const ids=new Set(local.map(item=>item.id));return[...current.filter(item=>!ids.has(item.id)),...local]})};sync();window.addEventListener(AI_ACTION_EVENT,sync);return()=>window.removeEventListener(AI_ACTION_EVENT,sync)},[patient?.id]);

  const stopTracks = () => {
    stream.current?.getTracks().forEach((track) => track.stop());
    stream.current = null;
  };

  const stopTimer = () => {
    if (timer.current != null) window.clearInterval(timer.current);
    timer.current = null;
  };

  const revokeUrl = (url?: string) => {
    if (!url || !ownedUrls.current.has(url)) return;
    URL.revokeObjectURL(url);
    ownedUrls.current.delete(url);
  };

  const removeMedia = () => {
    if (recording) recorder.current?.stop();
    revokeUrl(media?.url);
    setMedia(null);
    setCaption("");
    setError("");
  };

  useEffect(
    () => () => {
      stopTimer();
      stopTracks();
      ownedUrls.current.forEach((url) => URL.revokeObjectURL(url));
      ownedUrls.current.clear();
    },
    [],
  );

  const selectFile = (event: ChangeEvent<HTMLInputElement>, kind: "image" | "video") => {
    const file = event.target.files?.[0];
    event.target.value = "";
    if (!file) return;
    setStatus("");
    setError("");
    if (file.size > PREVIEW_MAX_BYTES) {
      setError(t("encourage.fileTooLarge"));
      return;
    }
    revokeUrl(media?.url);
    const url = URL.createObjectURL(file);
    ownedUrls.current.add(url);
    setMedia({ kind, url, name: file.name });
    setMode(kind);
    setCaption("");
  };

  const startRecording = async () => {
    setStatus("");
    setError("");
    if (!("MediaRecorder" in window) || !navigator.mediaDevices?.getUserMedia) {
      setError(t("encourage.micUnavailable"));
      return;
    }
    try {
      const activeStream = await navigator.mediaDevices.getUserMedia({ audio: true });
      stopTracks();
      stream.current = activeStream;
      const activeRecorder = new MediaRecorder(activeStream);
      recorder.current = activeRecorder;
      chunks.current = [];
      revokeUrl(media?.url);
      setMedia(null);
      setMode("voice");
      setElapsed(0);
      elapsedRef.current = 0;
      activeRecorder.ondataavailable = (event) => {
        if (event.data.size) chunks.current.push(event.data);
      };
      activeRecorder.onstop = () => {
        stopTimer();
        stopTracks();
        const blob = new Blob(chunks.current, {
          type: activeRecorder.mimeType || "audio/webm",
        });
        if (blob.size) {
          const url = URL.createObjectURL(blob);
          ownedUrls.current.add(url);
          setMedia({ kind: "voice", url, duration: Math.max(elapsedRef.current, 1) });
        }
        setRecording(false);
      };
      activeRecorder.start();
      setRecording(true);
      timer.current = window.setInterval(() => {
        elapsedRef.current += 1;
        setElapsed(elapsedRef.current);
      }, 1000);
    } catch {
      stopTracks();
      setRecording(false);
      setError(t("encourage.micUnavailable"));
    }
  };

  const stopRecording = () => {
    if (recorder.current?.state === "recording") recorder.current.stop();
  };

  const chooseMode = (nextMode: ComposerMode) => {
    setMode(nextMode);
    setStatus("");
    setError("");
    if (nextMode === "text") messageInput.current?.focus();
    if (nextMode === "image") imageInput.current?.click();
    if (nextMode === "video") videoInput.current?.click();
    if (nextMode === "voice") void startRecording();
  };

  const submit = (event: FormEvent) => {
    event.preventDefault();
    setError("");
    setStatus("");
    const text = message.trim();
    const mediaCaption = caption.trim();
    if (!text && !media) {
      setError(t("encourage.validation"));
      return;
    }
    setItems((current) => [
      ...current,
      {
        id: crypto.randomUUID?.() ?? `preview-${Date.now()}`,
        patientId:patient?.id,
        sender,
        timestampKey: "encourage.justNow",
        message: text || undefined,
        caption: mediaCaption || undefined,
        media: media || undefined,
      },
    ]);
    setMessage("");
    setCaption("");
    setMedia(null);
    setMode("text");
    setStatus(t("encourage.success"));
  };

  const renderMedia = (itemMedia: LocalMedia, alt = t("encourage.selectedPhotoAlt")) => {
    if (itemMedia.placeholder) {
      const icon = itemMedia.kind === "image" ? "▧" : itemMedia.kind === "video" ? "▷" : "⌁";
      return (
        <div className={`enc-media-placeholder enc-media-placeholder--${itemMedia.kind}`}>
          <span aria-hidden="true">{icon}</span>
          <strong>{itemMedia.kind === "image" ? t("encourage.imageType") : itemMedia.kind === "video" ? t("encourage.videoType") : t("encourage.voiceType")}</strong>
          {itemMedia.duration && <small dir="ltr">{formatDuration(itemMedia.duration)}</small>}
        </div>
      );
    }
    if (itemMedia.kind === "image" && itemMedia.url) {
      return <img className="enc-media-image" src={itemMedia.url} alt={alt} />;
    }
    if (itemMedia.kind === "video" && itemMedia.url) {
      return <video className="enc-media-video" src={itemMedia.url} controls preload="metadata" />;
    }
    if (itemMedia.kind === "voice" && itemMedia.url) {
      return <audio className="enc-media-audio" src={itemMedia.url} controls preload="metadata" />;
    }
    return null;
  };

  const suggestions = [
    t("encourage.suggestionOne"),
    t("encourage.suggestionTwo"),
    t("encourage.suggestionThree"),
    t("encourage.suggestionFour"),
  ];

  const modes: Array<{ id: ComposerMode; icon: string; label: string }> = [
    { id: "text", icon: "≡", label: t("encourage.text") },
    { id: "image", icon: "▧", label: t("encourage.photo") },
    { id: "video", icon: "▷", label: t("encourage.video") },
    { id: "voice", icon: "●", label: t("encourage.voice") },
  ];

  return (
    <div className="encouragement-studio">
      <div className="enc-workspace">
        <form className="enc-composer" id="encouragement-composer" onSubmit={submit}>
          <div className="enc-composer__head">
            <div><h2>{t("encourage.composerTitle")}</h2><p>{t("encourage.composerDescription")}</p>{patient&&<small className="patient-context-line">{patientCopy.forPatient}: {patientName(patient)}</small>}</div>
            <span className="enc-composer__heart" aria-hidden="true">♡</span>
          </div>

          <div className="enc-actions" role="tablist" aria-label={t("encourage.composerTitle")}>
            {modes.map((item) => (
              <button key={item.id} type="button" role="tab" aria-selected={mode === item.id} className={`enc-action ${mode === item.id ? "enc-action--active" : ""} ${item.id === "voice" && recording ? "enc-action--recording" : ""}`} onClick={() => recording && item.id === "voice" ? stopRecording() : chooseMode(item.id)}>
                <span aria-hidden="true">{item.icon}</span>{item.label}
              </button>
            ))}
          </div>

          <label className="enc-field" htmlFor="encouragement-message">
            <span>{t("encourage.messageLabel")}</span>
            <textarea ref={messageInput} id="encouragement-message" rows={5} maxLength={MESSAGE_MAX} value={message} onChange={(event) => setMessage(event.target.value)} placeholder={t("encourage.messagePlaceholder")} />
            <small className="enc-counter" dir="ltr">{message.length}/{MESSAGE_MAX}</small>
          </label>

          <input ref={imageInput} className="sr-only" type="file" accept="image/*" aria-label={t("encourage.photo")} onChange={(event) => selectFile(event, "image")} />
          <input ref={videoInput} className="sr-only" type="file" accept="video/*" aria-label={t("encourage.video")} onChange={(event) => selectFile(event, "video")} />

          {recording && <div className="enc-recording" role="status" aria-live="polite"><span className="enc-recording__pulse" aria-hidden="true" /><strong>{t("encourage.recording")}</strong><time dir="ltr">{formatDuration(elapsed)}</time><button type="button" className="btn btn--ghost btn--sm" onClick={stopRecording}>{t("encourage.stopRecording")}</button></div>}

          {media && !recording && (
            <div className="enc-preview">
              <div className="enc-preview__media">{renderMedia(media)}</div>
              <div className="enc-preview__meta"><strong>{media.kind === "image" ? t("encourage.photo") : media.kind === "video" ? t("encourage.video") : t("encourage.voicePreview")}</strong>{media.name && <span title={media.name}>{media.name}</span>}{media.duration && <span dir="ltr">{formatDuration(media.duration)}</span>}<div className="enc-preview__actions">{media.kind === "voice" && <button type="button" className="btn btn--ghost btn--sm" onClick={startRecording}>{t("encourage.recordAgain")}</button>}<button type="button" className="btn btn--ghost btn--sm" onClick={removeMedia}>{t("encourage.remove")}</button></div></div>
              {(media.kind === "image" || media.kind === "video") && <label className="enc-field enc-field--caption"><span>{t("encourage.captionLabel")}</span><input maxLength={CAPTION_MAX} value={caption} onChange={(event) => setCaption(event.target.value)} placeholder={t("encourage.captionPlaceholder")} /></label>}
            </div>
          )}

          <button className="enc-memory-strip" type="button" onClick={() => imageInput.current?.click()}><span aria-hidden="true">▧</span><strong>{t("encourage.memoryImage")}</strong><i aria-hidden="true">＋</i></button>

          <div className="enc-suggestions"><strong>{t("encourage.quickSuggestions")}</strong><div>{suggestions.map((suggestion) => <button type="button" key={suggestion} onClick={() => { setMessage(suggestion); setMode("text"); messageInput.current?.focus(); }}>{suggestion}</button>)}</div></div>

          <div className="enc-composer__footer"><div className="enc-feedback" aria-live="polite">{error && <p className="enc-feedback__error">{error}</p>}{status && <p className="enc-feedback__success">{status}</p>}</div><button className="btn btn--gold enc-submit" type="submit" disabled={recording}><span aria-hidden="true">↗</span>{t("encourage.sendMessage")}</button></div>
        </form>

        <aside className="enc-live-preview" aria-labelledby="enc-preview-title">
          <div className="enc-live-preview__head"><span aria-hidden="true">◉</span><div><h2 id="enc-preview-title">{t("encourage.previewTitle")}</h2><p>{t("encourage.previewSubtitle")}</p></div></div>
          <div className="enc-phone"><div className="enc-phone__speaker" /><article><header><span className="avatar" aria-hidden="true">♥</span><div><strong>{t("encourage.fromFamily")}</strong><time>{t("encourage.now")}</time></div></header><p className={!message ? "is-placeholder" : ""}>{message || t("encourage.previewFallback")}</p>{media && <div className="enc-phone__media">{renderMedia(media)}</div>}{caption && <small>{caption}</small>}</article></div>
        </aside>
      </div>

      <section className="enc-feed" aria-labelledby="recent-encouragements-title">
        <div className="enc-feed__head"><span className="eyebrow">{t("encourage.recentEyebrow")}</span><h2 id="recent-encouragements-title">{t("encourage.recentMessages")}</h2><p>{t("encourage.recentMessagesSubtitle")}</p></div>
        {items.length === 0 ? (
          <div className="enc-empty"><span aria-hidden="true">♥</span><h3>{t("encourage.noItems")}</h3><p>{t("encourage.noItemsHint")}</p></div>
        ) : (
          <div className="enc-feed__viewport" data-testid="recent-encouragements-viewport">
            <div className="enc-feed__track">
              {items.filter((item)=>item.patientId===patient?.id).map((item) => {const member=members.find((candidate)=>item.sender===candidate.name||item.sender.startsWith(`${candidate.name} ·`))||null;return <article className="enc-card" key={item.id}><header className="enc-card__head"><FamilyMemberAvatar member={member}/><div><strong>{member?label(member):item.sender}</strong><small>{item.media ? t(`encourage.${item.media.kind}Type` as "encourage.imageType" | "encourage.videoType" | "encourage.voiceType") : t("encourage.text")}</small><time>{t(item.timestampKey)}</time></div></header>{item.message && <p className="enc-card__message">{item.message.startsWith("encourage.") ? t(item.message as "encourage.demoText") : item.message}</p>}{item.media && <div className="enc-card__media"><RecentEncouragementMedia media={item.media} title={item.media.kind === "image" ? t("encourage.imageType") : item.media.kind === "video" ? t("encourage.videoType") : t("encourage.voiceType")} /></div>}{item.caption && <p className="enc-card__caption">{item.caption.startsWith("encourage.") ? t(item.caption as "encourage.demoVoice" | "encourage.demoImage" | "encourage.demoVideo") : item.caption}</p>}</article>})}
            </div>
          </div>
        )}
      </section>
    </div>
  );
}

function RecentEncouragementMedia({media,title}:{media:LocalMedia;title:string}){
  if(media.kind==="image"&&media.url)return <img className="enc-media-image" src={media.url} alt={title}/>;
  if(media.kind==="video"&&media.url)return <div className="enc-recent-video"><video className="enc-media-video" src={media.url} controls preload="metadata"/><span aria-hidden="true">▶</span></div>;
  if(media.kind==="voice"&&media.url)return <RecentVoicePlayer media={media} title={title}/>;
  return <div className={`enc-recent-placeholder enc-recent-placeholder--${media.kind}`}><span className="enc-recent-media-icon" aria-hidden="true">{media.kind==="image"?<i className="enc-photo-icon"/>:media.kind==="video"?"▶":"▶"}</span>{media.kind==="voice"&&<span className="enc-recent-wave" aria-hidden="true">{Array.from({length:18},(_,index)=><i key={index}/>)}</span>}<strong>{title}</strong>{media.duration&&<small dir="ltr">{formatDuration(media.duration)}</small>}</div>
}

function RecentVoicePlayer({media,title}:{media:LocalMedia;title:string}){
  const audio=useRef<HTMLAudioElement>(null);const [playing,setPlaying]=useState(false);const [progress,setProgress]=useState(0);
  const toggle=()=>{const player=audio.current;if(!player)return;if(player.paused)void player.play();else player.pause()};
  return <div className="enc-recent-voice"><audio ref={audio} src={media.url} preload="metadata" onPlay={()=>setPlaying(true)} onPause={()=>setPlaying(false)} onEnded={()=>{setPlaying(false);setProgress(0)}} onTimeUpdate={event=>{const player=event.currentTarget;setProgress(player.duration?player.currentTime/player.duration:0)}}/><button type="button" onClick={toggle} aria-label={title} title={title}>{playing?"Ⅱ":"▶"}</button><span className="enc-recent-wave" aria-hidden="true">{Array.from({length:18},(_,index)=><i className={index/18<=progress?"is-progress":""} key={index}/>)}</span><strong>{title}</strong>{media.duration&&<small dir="ltr">{formatDuration(media.duration)}</small>}</div>
}
