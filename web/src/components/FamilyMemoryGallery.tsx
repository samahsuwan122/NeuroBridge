import { useEffect, useState } from "react";
import { resolveMediaUrl } from "../api/client";
import { useI18n } from "../i18n/useI18n";
import { formatDate } from "../lib";
import type { MemoryEntry } from "../types";
import { MemoryVoiceRecorder } from "./MemoryVoiceRecorder";
import { FamilyMemberAvatar, localizeFamilyRelationship, useFamilyMembers } from "../familyMembers";

interface Props {
  memories: MemoryEntry[];
  creatorName: (memory: MemoryEntry, index: number) => string;
  onEdit: (memory: MemoryEntry, replacementAudio?: File, removeMedia?: boolean) => void;
  onDelete: (memory: MemoryEntry) => void;
}

function isVideoMemory(memory: MemoryEntry) {
  return memory.media_type?.toLowerCase().startsWith("video") ?? false;
}
function isAudioMemory(memory: MemoryEntry) {
  return memory.media_type?.toLowerCase().startsWith("audio") ?? false;
}

function MemoryMedia({ memory, detail = false, title }: { memory: MemoryEntry; detail?: boolean; title?:string }) {
  const { t } = useI18n();
  const [failed, setFailed] = useState(false);
  const src = resolveMediaUrl(memory.media_url);
  const video = isVideoMemory(memory);
  const audio = isAudioMemory(memory);

  if (!src || failed) {
    return (
      <div className={`family-memory-media__fallback ${video ? "is-video" : ""}`}>
        <span aria-hidden="true">{audio ? "🎙" : video ? "▶" : "▧"}</span>
        <small>{t(audio ? "family.voiceUnavailable" : video ? "family.videoUnavailable" : "family.noMedia")}</small>
      </div>
    );
  }

  if (video) {
    return (
      <video
        src={src}
        controls={detail}
        preload="metadata"
        playsInline
        onError={() => setFailed(true)}
      />
    );
  }
  if (audio) {
    return <div className="family-memory-audio"><span aria-hidden="true">🎙</span><strong>{t("family.voiceRecordingType")}</strong><audio src={src} controls preload="metadata" aria-label={t("family.voicePlayback")} onError={() => setFailed(true)} /></div>;
  }

  return <img src={src} alt={title||memory.title} loading="lazy" onError={() => setFailed(true)} />;
}

export function FamilyMemoryGallery({ memories, creatorName, onEdit, onDelete }: Props) {
  const { t, lang } = useI18n();
  const { members } = useFamilyMembers();
  const [details, setDetails] = useState<MemoryEntry | null>(null);
  const [editing, setEditing] = useState<MemoryEntry | null>(null);
  const [deleting, setDeleting] = useState<MemoryEntry | null>(null);
  const [filter, setFilter] = useState<"all" | "image" | "video" | "audio">("all");
  const [favoritesOnly, setFavoritesOnly] = useState(false);
  const [query, setQuery] = useState("");
  const [favorites, setFavorites] = useState<Set<string>>(() => {
    try { return new Set<string>(JSON.parse(localStorage.getItem("nb_family_memory_favorites") ?? "[]")); } catch { return new Set(); }
  });
  const [replacementAudio, setReplacementAudio] = useState<File | null>(null);
  const [removeCurrentAudio, setRemoveCurrentAudio] = useState(false);
  const [draft, setDraft] = useState({ title: "", description: "", place_name: "", memory_date: "", person_name: "", relationship: "" });
  const memoryDisplay=(memory:MemoryEntry)=>{
    if(memory.title==="Family picnic at the park"&&memory.description==="A sunny afternoon by the lake with the whole family.")return{title:t("family.demoPicnicTitle"),description:t("family.demoPicnicDescription")};
    if(memory.title==="Wedding day photo"&&memory.description==="A treasured photo from the wedding celebration.")return{title:t("family.demoWeddingTitle"),description:t("family.demoWeddingDescription")};
    return{title:memory.title,description:memory.description};
  };

  useEffect(() => {
    if (!editing) return;
    setDraft({
      title: editing.title,
      description: editing.description ?? "",
      place_name: editing.place_name ?? "",
      memory_date: editing.memory_date?.slice(0, 10) ?? "",
      person_name: editing.person_name ?? "",
      relationship: editing.relationship ?? "",
    });
  }, [editing]);

  const toggleFavorite = (id: string) => {
    setFavorites((current) => {
      const next = new Set(current);
      if (next.has(id)) next.delete(id); else next.add(id);
      localStorage.setItem("nb_family_memory_favorites", JSON.stringify([...next]));
      return next;
    });
  };

  const normalizedQuery = query.trim().toLocaleLowerCase();
  const visibleMemories = memories.filter((memory, index) => {
    const matchesType = filter === "all" || (filter === "audio" ? isAudioMemory(memory) : filter === "video" ? isVideoMemory(memory) : !isAudioMemory(memory) && !isVideoMemory(memory));
    const matchesFavorite = !favoritesOnly || favorites.has(memory.id);
    const creator = creatorName(memory, index);
    const display=memoryDisplay(memory);
    const haystack = [display.title, display.description, memory.place_name, creator].filter(Boolean).join(" ").toLocaleLowerCase();
    return matchesType && matchesFavorite && (!normalizedQuery || haystack.includes(normalizedQuery));
  });

  return (
    <>
      <div className="family-memory-tools">
        <label className="family-memory-search"><span aria-hidden="true">⌕</span><input value={query} onChange={(event) => setQuery(event.target.value)} placeholder={t("family.memorySearchPlaceholder")} aria-label={t("family.memorySearchLabel")} />{query && <button type="button" onClick={() => setQuery("")} aria-label={t("family.clearMemorySearch")}>×</button>}</label>
      </div>
      <div className="family-memory-filters" role="group" aria-label={t("family.memoryFilters")}>
        {(["all", "image", "video", "audio"] as const).map((kind) => <button key={kind} className={filter === kind ? "is-active" : ""} type="button" onClick={() => setFilter(kind)}>{t(kind === "all" ? "family.filterAll" : kind === "image" ? "family.filterPhotos" : kind === "video" ? "family.filterVideos" : "family.filterVoice")}</button>)}
        <button className={favoritesOnly ? "is-active" : ""} type="button" onClick={() => setFavoritesOnly((value) => !value)}>♡ {t("family.filterFavorites")}</button>
      </div>
      <div className="family-memory-grid">
        {visibleMemories.map((memory) => {
          const index = memories.findIndex((item) => item.id === memory.id);
          const video = isVideoMemory(memory);
          const audio = isAudioMemory(memory);
          const creator = creatorName(memory, index);
          const display=memoryDisplay(memory);
          return (
            <article className="family-memory-card" key={memory.id}>
              <div className={`family-memory-card__media ${audio ? "is-audio" : ""}`}>
                <MemoryMedia memory={memory} title={display.title} />
                <span className="family-memory-card__badge">{t(audio ? "family.voiceBadge" : video ? "family.video" : "family.photo")}</span>
                {video && <span className="family-memory-card__play" aria-hidden="true">▶</span>}
                {!audio && <button className="family-memory-card__open" type="button" onClick={() => setDetails(memory)} aria-label={t("family.openMemory", { title: display.title })} />}
                {audio && <button className="family-memory-card__audio-details" type="button" onClick={() => setDetails(memory)} aria-label={t("family.openMemory", { title: display.title })}>↗</button>}
                <button className={`family-memory-card__favorite ${favorites.has(memory.id) ? "is-favorite" : ""}`} type="button" onClick={() => toggleFavorite(memory.id)} aria-label={t(favorites.has(memory.id) ? "family.removeFavorite" : "family.addFavorite")}>{favorites.has(memory.id) ? "♥" : "♡"}</button>
              </div>
              <div className="family-memory-card__body">
                <div className="family-memory-card__title-row">
                  <h3>{display.title}</h3>
                  <details className="family-memory-card__menu">
                    <summary aria-label={t("family.memoryActions")}>⋯</summary>
                    <div>
                      <button type="button" onClick={() => { setReplacementAudio(null); setRemoveCurrentAudio(false); setEditing({ ...memory, person_name: creator }); }}>{t("family.edit")}</button>
                      <button type="button" className="is-danger" onClick={() => setDeleting(memory)}>{t("family.delete")}</button>
                    </div>
                  </details>
                </div>
                {display.description && <p className="family-memory-card__description">{display.description}</p>}
                <div className="family-memory-card__meta">
                  {memory.place_name && <span>⌖ {memory.place_name}</span>}
                  <time>{formatDate(memory.memory_date ?? memory.created_at)}</time>
                </div>
                <div className="family-memory-card__creator">
                  <FamilyMemberAvatar member={members.find((member)=>creator.startsWith(member.name))||null}/>
                  <span><small>{t("family.sharedBy", { name: creator })}</small>{memory.relationship && <em>{localizeFamilyRelationship(memory.relationship,lang)}</em>}</span>
                </div>
              </div>
            </article>
          );
        })}
      </div>
      {visibleMemories.length === 0 && <div className="memories-page__no-results"><strong>{t("family.noMatchingMemories")}</strong><p>{t("family.noMatchingMemoriesHelp")}</p></div>}

      {details && (
        <div className="memory-dialog" role="dialog" aria-modal="true" aria-labelledby="memory-details-title">
          <button className="memory-dialog__backdrop" type="button" onClick={() => setDetails(null)} aria-label={t("common.cancel")} />
          <article className="memory-dialog__panel memory-dialog__panel--details">
            <button className="memory-dialog__close" type="button" onClick={() => setDetails(null)} aria-label={t("common.cancel")}>×</button>
            <div className="memory-dialog__media"><MemoryMedia memory={details} detail title={memoryDisplay(details).title} /></div>
            <div className="memory-dialog__content">
              <h2 id="memory-details-title">{memoryDisplay(details).title}</h2>
              {memoryDisplay(details).description && <p>{memoryDisplay(details).description}</p>}
              {details.place_name && <span>⌖ {details.place_name}</span>}
              <time>{formatDate(details.memory_date ?? details.created_at)}</time>
              <small>{t("family.sharedBy", { name: creatorName(details, memories.findIndex((memory) => memory.id === details.id)) })}{details.relationship ? ` · ${localizeFamilyRelationship(details.relationship,lang)}` : ""}</small>
            </div>
          </article>
        </div>
      )}

      {editing && (
        <div className="memory-dialog" role="dialog" aria-modal="true" aria-labelledby="memory-edit-title">
          <button className="memory-dialog__backdrop" type="button" onClick={() => setEditing(null)} aria-label={t("common.cancel")} />
          <form className="memory-dialog__panel memory-dialog__form" onSubmit={(event) => {
            event.preventDefault();
            onEdit({ ...editing, title: draft.title.trim() || editing.title, description: draft.description.trim() || null, place_name: draft.place_name.trim() || null, memory_date: draft.memory_date || null, person_name: draft.person_name.trim(), relationship: draft.relationship.trim() || null, updated_at: new Date().toISOString() }, replacementAudio ?? undefined, removeCurrentAudio);
            setEditing(null);
          }}>
            <h2 id="memory-edit-title">{t("family.editMemory")}</h2>
            <label>{t("family.title")}<input required value={draft.title} onChange={(event) => setDraft({ ...draft, title: event.target.value })} /></label>
            <label>{t("family.description")}<textarea rows={3} value={draft.description} onChange={(event) => setDraft({ ...draft, description: event.target.value })} /></label>
            <label>{t("family.place")}<input value={draft.place_name} onChange={(event) => setDraft({ ...draft, place_name: event.target.value })} /></label>
            <label>{t("family.memoryDate")}<input type="date" value={draft.memory_date} onChange={(event) => setDraft({ ...draft, memory_date: event.target.value })} /></label>
            <label>{t("family.contributorName")}<input required value={draft.person_name} placeholder={t("family.contributorPlaceholder")} onChange={(event) => setDraft({ ...draft, person_name: event.target.value })} /></label>
            <label>{t("family.relationshipOptional")}<input value={draft.relationship} placeholder={t("family.relationshipPlaceholder")} onChange={(event) => setDraft({ ...draft, relationship: event.target.value })} /></label>
            {isAudioMemory(editing) && <div className="memory-dialog__voice-edit"><span>{t("family.currentRecording")}</span>{!removeCurrentAudio && <MemoryMedia memory={editing} detail />}<button className="btn btn--ghost btn--sm" type="button" onClick={() => { setRemoveCurrentAudio(true); setReplacementAudio(null); }}>{t("family.voiceRemove")}</button><MemoryVoiceRecorder onChange={(file) => { setReplacementAudio(file); if (file) setRemoveCurrentAudio(false); }} /></div>}
            <p className="memory-dialog__note">{t("family.editSessionNote")}</p>
            <div className="memory-dialog__actions"><button className="btn btn--gold" type="submit">{t("family.saveChanges")}</button><button className="btn btn--ghost" type="button" onClick={() => setEditing(null)}>{t("common.cancel")}</button></div>
          </form>
        </div>
      )}

      {deleting && (
        <div className="memory-dialog" role="alertdialog" aria-modal="true" aria-labelledby="memory-delete-title" aria-describedby="memory-delete-description">
          <button className="memory-dialog__backdrop" type="button" onClick={() => setDeleting(null)} aria-label={t("common.cancel")} />
          <div className="memory-dialog__panel memory-dialog__confirm">
            <h2 id="memory-delete-title">{t("family.deleteMemoryTitle")}</h2>
            <p id="memory-delete-description">{t("family.deleteMemoryDescription")}</p>
            <p className="memory-dialog__note">{t("family.deleteSessionNote")}</p>
            <div className="memory-dialog__actions"><button className="btn btn--danger" type="button" onClick={() => { onDelete(deleting); setDeleting(null); }}>{t("family.deleteMemory")}</button><button className="btn btn--ghost" type="button" onClick={() => setDeleting(null)}>{t("common.cancel")}</button></div>
          </div>
        </div>
      )}
    </>
  );
}
