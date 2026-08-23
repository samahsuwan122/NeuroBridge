import { useEffect, useRef, useState } from "react";
import { useI18n } from "../i18n/useI18n";

export function MemoryVoiceRecorder({ onChange }: { onChange: (file: File | null) => void }) {
  const { t } = useI18n();
  const [recording, setRecording] = useState(false);
  const [elapsed, setElapsed] = useState(0);
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [error, setError] = useState("");
  const recorder = useRef<MediaRecorder | null>(null);
  const stream = useRef<MediaStream | null>(null);
  const chunks = useRef<Blob[]>([]);
  const timer = useRef<number | null>(null);

  const stopResources = () => {
    if (timer.current != null) window.clearInterval(timer.current);
    timer.current = null;
    stream.current?.getTracks().forEach((track) => track.stop());
    stream.current = null;
  };

  useEffect(() => () => {
    if (recorder.current?.state === "recording") recorder.current.stop();
    stopResources();
  }, []);

  useEffect(() => () => {
    if (previewUrl) URL.revokeObjectURL(previewUrl);
  }, [previewUrl]);

  const start = async () => {
    setError("");
    try {
      if (!("MediaRecorder" in window) || !navigator.mediaDevices?.getUserMedia) throw new Error();
      const activeStream = await navigator.mediaDevices.getUserMedia({ audio: true });
      stream.current = activeStream;
      chunks.current = [];
      setElapsed(0);
      const activeRecorder = new MediaRecorder(activeStream);
      recorder.current = activeRecorder;
      activeRecorder.ondataavailable = (event) => { if (event.data.size) chunks.current.push(event.data); };
      activeRecorder.onstop = () => {
        stopResources();
        const type = activeRecorder.mimeType || "audio/webm";
        const blob = new Blob(chunks.current, { type });
        if (blob.size) {
          const extension = type.includes("ogg") ? "ogg" : "webm";
          const file = new File([blob], `voice-memory-${Date.now()}.${extension}`, { type });
          setPreviewUrl(URL.createObjectURL(file));
          onChange(file);
        }
        setRecording(false);
      };
      activeRecorder.start();
      setRecording(true);
      timer.current = window.setInterval(() => setElapsed((value) => value + 1), 1000);
    } catch {
      stopResources();
      setRecording(false);
      setError(t("family.voiceMicUnavailable"));
    }
  };

  const stop = () => {
    if (recorder.current?.state === "recording") recorder.current.stop();
  };

  const remove = () => {
    setPreviewUrl(null);
    setElapsed(0);
    onChange(null);
  };

  const duration = `${String(Math.floor(elapsed / 60)).padStart(2, "0")}:${String(elapsed % 60).padStart(2, "0")}`;

  return (
    <div className="memory-voice-recorder">
      {recording ? (
        <div className="memory-voice-recorder__active" role="status" aria-live="polite">
          <span className="memory-voice-recorder__pulse" aria-hidden="true" />
          <strong>{t("family.voiceRecording")}</strong>
          <time dir="ltr">{duration}</time>
          <button className="btn btn--ghost btn--sm" type="button" onClick={stop}>{t("family.voiceStop")}</button>
        </div>
      ) : previewUrl ? (
        <div className="memory-voice-recorder__preview">
          <span aria-hidden="true">🎙</span>
          <audio src={previewUrl} controls preload="metadata" aria-label={t("family.voicePreview")} />
          <time dir="ltr">{duration}</time>
          <div><button className="btn btn--ghost btn--sm" type="button" onClick={start}>{t("family.voiceRecordAgain")}</button><button className="btn btn--ghost btn--sm" type="button" onClick={remove}>{t("family.voiceRemove")}</button></div>
        </div>
      ) : (
        <button className="btn btn--gold" type="button" onClick={start}>🎙 {t("family.voiceStart")}</button>
      )}
      {error && <p className="mform__error" role="alert">{error}</p>}
    </div>
  );
}
