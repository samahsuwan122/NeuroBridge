import { resolveMediaUrl } from "../api/client";
import { formatDate } from "../lib";
import type { MemoryEntry } from "../types";

// Read-only memory album grid, shared across portals.
export function MemoryGrid({ memories }: { memories: MemoryEntry[] }) {
  return (
    <div className="memory-grid">
      {memories.map((mem) => {
        const src = resolveMediaUrl(mem.media_url);
        return (
          <article className="memory" key={mem.id}>
            <div className="memory__media">
              {src ? (
                <img src={src} alt={mem.title} loading="lazy" />
              ) : (
                <span className="memory__ph" aria-hidden="true">
                  ▤
                </span>
              )}
            </div>
            <div className="memory__body">
              <strong>{mem.title}</strong>
              {mem.person_name && <span>{mem.person_name}</span>}
              {mem.place_name && <span>{mem.place_name}</span>}
              <span className="memory__date">
                {formatDate(mem.memory_date ?? mem.created_at)}
              </span>
            </div>
          </article>
        );
      })}
    </div>
  );
}
