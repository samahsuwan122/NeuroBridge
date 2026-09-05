import { useEffect, useRef, useState } from "react";
import { webAccountApi } from "../api/webAccountClient";
import { MemoryForm } from "../components/MemoryForm";
import type { MemoryMediaKind } from "../components/MemoryForm";
import { FamilyMemoryGallery } from "../components/FamilyMemoryGallery";
import { Card, EmptyState, ErrorState, Spinner } from "../components/ui";
import { useI18n } from "../i18n/useI18n";
import familyMemoriesHero from "../assets/family-memories-hero.mp4";
import type {
  MemoryEntry,
  MemoryListResponse,
} from "../types";
import { useFamilyPreferences } from "../familyPreferences";
import { useFamilyMembers } from "../familyMembers";
import { useCurrentFamilyPatient } from "../currentFamilyPatient";
import { AI_ACTION_EVENT,readAiMemories } from "../lib/familyAiLocalActions";

export function FamilyMemoriesPage() {
  const { t } = useI18n();
  const {patient,loading:patientLoading,copy:patientCopy,name:patientName}=useCurrentFamilyPatient();
  const { preferences } = useFamilyPreferences();
  const { active, copy, label } = useFamilyMembers();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [memories, setMemories] = useState<MemoryEntry[]>([]);
  const [formOpen, setFormOpen] = useState(false);
  const [reducedMotion, setReducedMotion] = useState(() =>
    window.matchMedia("(prefers-reduced-motion: reduce)").matches,
  );
  const [videoPlaying, setVideoPlaying] = useState(() =>
    !window.matchMedia("(prefers-reduced-motion: reduce)").matches,
  );
  const videoRef = useRef<HTMLVideoElement>(null);
  const localMediaUrls = useRef(new Set<string>());
  const [banner, setBanner] = useState<
    { tone: "ok" | "warn"; text: string } | null
  >(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      if (!patient) {
        setMemories([]);
        return;
      }

      const response = await webAccountApi<MemoryListResponse>(`family_memories.php?patient_id=${encodeURIComponent(patient.id)}`);
      setMemories(
        [...readAiMemories(),...response.memories].filter(
          (memory) => memory.patient_profile_id === patient.id,
        ),
      );
    } catch (err) {
      setError(err instanceof Error ? err.message : t("family.memoriesLoadError"));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, [patient?.id]);
  useEffect(()=>{const sync=()=>setMemories(current=>{const local=readAiMemories().filter(item=>item.patient_profile_id===patient?.id),ids=new Set(local.map(item=>item.id));return[...local,...current.filter(item=>!ids.has(item.id))]});window.addEventListener(AI_ACTION_EVENT,sync);return()=>window.removeEventListener(AI_ACTION_EVENT,sync)},[patient?.id]);

  useEffect(() => () => {
    localMediaUrls.current.forEach((url) => URL.revokeObjectURL(url));
    localMediaUrls.current.clear();
  }, []);

  useEffect(() => {
    const mediaQuery = window.matchMedia("(prefers-reduced-motion: reduce)");
    const syncMotionPreference = () => {
      setReducedMotion(mediaQuery.matches);
      if (mediaQuery.matches || preferences.reduceMotion || !preferences.autoplayHero) {
        videoRef.current?.pause();
        setVideoPlaying(false);
      } else {
        void videoRef.current?.play().then(() => setVideoPlaying(true)).catch(() => {
          setVideoPlaying(false);
        });
      }
    };

    syncMotionPreference();
    mediaQuery.addEventListener("change", syncMotionPreference);
    return () => mediaQuery.removeEventListener("change", syncMotionPreference);
  }, [preferences.reduceMotion, preferences.autoplayHero]);

  const toggleVideo = () => {
    const video = videoRef.current;
    if (!video) return;
    if (video.paused) {
      void video.play().then(() => setVideoPlaying(true)).catch(() => {
        setVideoPlaying(false);
      });
    } else {
      video.pause();
      setVideoPlaying(false);
    }
  };

  const refreshMemories = async (patientId: string) => {
    const response = await webAccountApi<MemoryListResponse>(`family_memories.php?patient_id=${encodeURIComponent(patientId)}`);
    const refreshed = [...readAiMemories(),...response.memories].filter(
        (memory) => memory.patient_profile_id === patientId,
      );
    setMemories(refreshed);
    return refreshed;
  };

  const handleSaved = async (
    patientId: string,
    info: { mediaFailed: boolean; created: MemoryEntry; localMedia?: File; mediaKind: MemoryMediaKind },
  ) => {
    setFormOpen(false);
    setBanner(
      info.mediaFailed
        ? { tone: "warn", text: t("family.memoryMediaFailed") }
        : { tone: "ok", text: t("family.memorySaved") },
    );
    try {
      await refreshMemories(patientId);
    } catch {
      // The saved memory remains available; a page retry can refresh the album.
    }
    if (info.mediaKind === "audio" && info.localMedia) {
      const url = URL.createObjectURL(info.localMedia);
      localMediaUrls.current.add(url);
      const localVoiceMemory: MemoryEntry = {
        ...info.created,
        media_type: info.localMedia.type || "audio/webm",
        media_url: url,
      };
      setMemories((current) => [localVoiceMemory, ...current.filter((memory) => memory.id !== localVoiceMemory.id)]);
      setBanner({ tone: "warn", text: t("family.voiceSessionOnly") });
    }
  };

  if (loading||patientLoading) return <Spinner label={t("family.memoriesLoading")} />;
  if (error) return <ErrorState message={error} onRetry={load} />;

  // Frontend-only attribution for legacy seeded entries that predate the
  // required contributor field. New memories persist person_name normally.
  const seededContributorNames = [
    t("family.demoContributorOmar"),
    t("family.demoContributorLayla"),
    t("family.demoContributorOmar"),
  ];

  return (
    <div className="page page--wide memories-page">
      <section className="memories-hero" aria-labelledby="memories-page-title">
        <div className="memories-hero__content">
          <span className="eyebrow">{t("family.memoriesEyebrow")}</span>
          <h1 id="memories-page-title">{t("family.memoriesTitle")}</h1>
          <p className="memories-hero__phrase">{t("family.memoriesPhrase")}</p>
          <p className="memories-hero__description">{t("family.memoriesDescription")}</p>
          {patient&&<small className="patient-context-line">{patientCopy.forPatient}: {patientName(patient)}</small>}
          {patient && (
            <button
              className="btn btn--gold memories-hero__cta"
              type="button"
              onClick={() => {
                setBanner(null);
                setFormOpen((current) => !current);
              }}
            >
              {formOpen ? t("family.close") : t("family.addMemory")}
            </button>
          )}
        </div>
        <div className="memories-hero__visual">
          <div className="memories-hero__video-frame">
            <video
              ref={videoRef}
              src={familyMemoriesHero}
              autoPlay={!reducedMotion && !preferences.reduceMotion && preferences.autoplayHero}
              loop
              muted
              playsInline
              preload="metadata"
              aria-label={t("family.memoriesVideoLabel")}
              onPlay={() => setVideoPlaying(true)}
              onPause={() => setVideoPlaying(false)}
            />
            <span className="memories-hero__video-badge">
              {t("family.memoriesVideoBadge")}
            </span>
            <button
              className="memories-hero__video-toggle"
              type="button"
              onClick={toggleVideo}
              aria-label={t(videoPlaying ? "family.memoriesPauseVideo" : "family.memoriesPlayVideo")}
            >
              <span aria-hidden="true">{videoPlaying ? "Ⅱ" : "▶"}</span>
            </button>
          </div>
          <span className="memories-hero__heart" aria-hidden="true">♡</span>
        </div>
      </section>

      {!patient ? (
        <EmptyState message={t("family.noLinked")} />
      ) : (
        <>
          {banner && (
            <div className={`banner banner--${banner.tone}`}>{banner.text}</div>
          )}

          {formOpen && (
            <Card className="memories-page__form">
              <MemoryForm
                patientId={patient.id}
                initialContributor={active ? { name: active.name, relationship: copy.relationships[active.relationship] } : undefined}
                onCancel={() => setFormOpen(false)}
                onSaved={(info) => handleSaved(patient.id, info)}
              />
            </Card>
          )}

          <section className="memories-page__collection" aria-labelledby="memories-collection-title">
            <div className="memories-page__toolbar">
              <div>
                <span className="eyebrow">{t("family.memoriesEyebrow")}</span>
                <h2 id="memories-collection-title">{t("family.memoriesCollectionTitle")}</h2>
                <p>{t("family.memoriesCollectionSubtitle")}</p>
              </div>
              <div className="memories-page__toolbar-actions">
                <span>{t("family.memoriesCount", { n: memories.length })}</span>
                <button className="btn btn--gold btn--sm" type="button" onClick={() => { setBanner(null); setFormOpen(true); }}>
                  {t("family.addMemory")}
                </button>
              </div>
            </div>
          <Card className="memories-page__album">
            {memories.length === 0 ? (
              <div className="memories-page__empty">
                <EmptyState message={t("family.memoriesEmptyTitle")} />
                <p>{t("family.memoriesEmptyDescription")}</p>
                <button className="btn btn--gold" type="button" onClick={() => setFormOpen(true)}>{t("family.addMemory")}</button>
              </div>
            ) : (
              <FamilyMemoryGallery
                memories={memories}
                creatorName={(memory, index) => memory.person_name?.trim() || (active ? label(active) : seededContributorNames[Math.max(index, 0) % seededContributorNames.length])}
                onEdit={(updated, replacementAudio, removeMedia) => {
                  let next = updated;
                  if (removeMedia && updated.media_url?.startsWith("blob:") && localMediaUrls.current.has(updated.media_url)) {
                    URL.revokeObjectURL(updated.media_url);
                    localMediaUrls.current.delete(updated.media_url);
                    next = { ...updated, media_type: null, media_url: null };
                  }
                  if (replacementAudio) {
                    if (next.media_url?.startsWith("blob:") && localMediaUrls.current.has(next.media_url)) {
                      URL.revokeObjectURL(next.media_url);
                      localMediaUrls.current.delete(next.media_url);
                    }
                    const url = URL.createObjectURL(replacementAudio);
                    localMediaUrls.current.add(url);
                    next = { ...updated, media_type: replacementAudio.type || "audio/webm", media_url: url };
                  }
                  setMemories((current) => current.map((memory) => memory.id === next.id ? next : memory));
                }}
                onDelete={(deleted) => {
                  if (deleted.media_url?.startsWith("blob:") && localMediaUrls.current.has(deleted.media_url)) {
                    URL.revokeObjectURL(deleted.media_url);
                    localMediaUrls.current.delete(deleted.media_url);
                  }
                  setMemories((current) => current.filter((memory) => memory.id !== deleted.id));
                }}
              />
            )}
          </Card>
          </section>
        </>
      )}
    </div>
  );
}