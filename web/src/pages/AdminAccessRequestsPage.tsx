import { useEffect, useMemo, useState } from "react";
import { useAuth } from "../auth/AuthContext";
import { useI18n } from "../i18n/useI18n";
import { Badge, EmptyState, ErrorState, Spinner } from "../components/ui";
import { formatDateTime } from "../lib";
import { ApiError } from "../api/client";
import {
  listAccessRequests,
  updateAccessRequest,
  type AccessRequestStatus,
} from "../api/accessRequests";
import type { AccessRequest } from "../types";
import type { TranslationKey } from "../i18n/translations";

type Filter = "all" | AccessRequestStatus;
type Tone = "neutral" | "live" | "plan" | "gold";

const FILTERS: Filter[] = ["all", "pending", "reviewed", "accepted", "declined"];

const STATUS_KEY: Record<AccessRequestStatus, TranslationKey> = {
  pending: "admin.pending",
  reviewed: "admin.reviewed",
  accepted: "admin.accepted",
  declined: "admin.declined",
};

const STATUS_TONE: Record<string, Tone> = {
  pending: "gold",
  reviewed: "neutral",
  accepted: "live",
  declined: "plan",
};

const REQUEST_ROLE_LABEL: Record<string, string> = {
  patient: "مريض",
  family: "فرد من العائلة",
  doctor: "طبيب",
  therapist: "معالج",
};

/**
 * Admin-only page to review public access requests submitted from the website
 * Request Access form. It reviews/updates request status only — it never
 * creates user accounts (account creation stays a separate backend action).
 */
export function AdminAccessRequestsPage() {
  const { isAdmin } = useAuth();
  const { t } = useI18n();

  const [items, setItems] = useState<AccessRequest[] | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filter, setFilter] = useState<Filter>("all");
  const [search, setSearch] = useState("");
  const [notes, setNotes] = useState<Record<string, string>>({});
  const [busyId, setBusyId] = useState<string | null>(null);
  const [notice, setNotice] = useState<
    { tone: "success" | "error"; text: string } | null
  >(null);

  const load = async (f: Filter) => {
    setLoading(true);
    setError(null);
    try {
      const res = await listAccessRequests(f === "all" ? undefined : f);
      setItems(res.requests);
      // Seed the admin-note inputs from the server values.
      setNotes(
        Object.fromEntries(res.requests.map((r) => [r.id, r.admin_note ?? ""])),
      );
    } catch (err) {
      setError(err instanceof Error ? err.message : t("admin.loadFailed"));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (isAdmin) void load(filter);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [filter, isAdmin]);

  const visible = useMemo(() => {
    if (!items) return [];
    const q = search.trim().toLowerCase();
    if (!q) return items;
    return items.filter(
      (r) =>
        r.full_name.toLowerCase().includes(q) ||
        r.email.toLowerCase().includes(q),
    );
  }, [items, search]);

  const queueCounts = useMemo(
    () => ({
      visible: visible.length,
      pending: visible.filter((request) => request.status === "pending").length,
      reviewed: visible.filter((request) => request.status === "reviewed").length,
    }),
    [visible],
  );

  // Non-admins never mount here via routing, but guard defensively.
  if (!isAdmin) {
    return (
      <div className="page">
        <EmptyState message={t("admin.unauthorized")} />
      </div>
    );
  }

  const applyUpdate = async (
    req: AccessRequest,
    payload: { status?: AccessRequestStatus; admin_note?: string | null },
  ) => {
    setBusyId(req.id);
    setNotice(null);
    try {
      await updateAccessRequest(req.id, payload);
      setNotice({ tone: "success", text: t("admin.updated") });
      await load(filter);
    } catch (err) {
      const text =
        err instanceof ApiError ? err.message : t("admin.updateFailed");
      setNotice({ tone: "error", text });
    } finally {
      setBusyId(null);
    }
  };

  const changeStatus = (req: AccessRequest, status: AccessRequestStatus) => {
    const note = notes[req.id] ?? "";
    const original = req.admin_note ?? "";
    // Persist an edited note alongside the status change; leave it untouched
    // (omitted) when it hasn't changed, so we never clobber an existing note.
    const payload: { status: AccessRequestStatus; admin_note?: string | null } =
      { status };
    if (note.trim() !== original.trim()) payload.admin_note = note.trim() || null;
    void applyUpdate(req, payload);
  };

  const saveNote = (req: AccessRequest) => {
    void applyUpdate(req, { admin_note: (notes[req.id] ?? "").trim() || null });
  };

  return (
    <div className="page admin-page">
      <div className="admin-page__head">
        <div>
          <span className="eyebrow">{t("admin.eyebrow")}</span>
          <h1>{t("admin.title")}</h1>
          <p>{t("admin.sub")}</p>
        </div>
        <span className="admin-page__context">{t("admin.operationalQueue")}</span>
      </div>

      {!loading && !error && (
        <section className="admin-summary" aria-label={t("admin.queueSummary")}>
          <div>
            <span>{t("admin.resultsInView")}</span>
            <strong>{queueCounts.visible}</strong>
          </div>
          <div>
            <span>{t("admin.pendingInView")}</span>
            <strong>{queueCounts.pending}</strong>
          </div>
          <div>
            <span>{t("admin.reviewedInView")}</span>
            <strong>{queueCounts.reviewed}</strong>
          </div>
        </section>
      )}

      <section className="admin-queue" aria-label={t("admin.title")}>
      <div className="admin-toolbar">
        <div className="admin-filters" role="group" aria-label={t("admin.status")}>
          {FILTERS.map((f) => (
            <button
              key={f}
              type="button"
              className={`admin-filter ${filter === f ? "admin-filter--active" : ""}`}
              aria-pressed={filter === f}
              onClick={() => setFilter(f)}
            >
              {f === "all" ? t("admin.all") : t(STATUS_KEY[f])}
            </button>
          ))}
        </div>
        <label className="admin-search">
          <span className="admin-search__icon" aria-hidden="true">
            ⌕
          </span>
          <input
            type="search"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder={t("admin.searchPlaceholder")}
            aria-label={t("admin.search")}
          />
        </label>
      </div>

      {notice && (
        <div
          className={`admin-notice admin-notice--${notice.tone}`}
          role="status"
        >
          {notice.text}
        </div>
      )}

      {loading ? (
        <Spinner label={t("common.loading")} />
      ) : error ? (
        <ErrorState message={error} onRetry={() => load(filter)} />
      ) : visible.length === 0 ? (
        <div className="admin-empty">
          <span className="admin-empty__mark" aria-hidden="true">✓</span>
          <strong>{t("admin.emptyTitle")}</strong>
          <p>{search.trim() ? t("admin.emptySearchHelp") : t("admin.emptyHelp")}</p>
        </div>
      ) : (
        <ul className="admin-list">
          {visible.map((r) => {
            const tone = STATUS_TONE[r.status] ?? "neutral";
            const statusLabel = STATUS_KEY[r.status as AccessRequestStatus]
              ? t(STATUS_KEY[r.status as AccessRequestStatus])
              : r.status;
            const busy = busyId === r.id;
            return (
              <li className="admin-card" key={r.id}>
                <div className="admin-card__head">
                  <div className="admin-card__identity">
                    <span className="admin-card__avatar" aria-hidden="true">
                      {r.full_name.trim().slice(0, 1).toUpperCase() || "?"}
                    </span>
                    <div>
                    <strong className="admin-card__name">{r.full_name}</strong>
                    <a className="admin-card__email" href={`mailto:${r.email}`}>
                      {r.email}
                    </a>
                    </div>
                  </div>
                  <Badge tone={tone}>{statusLabel}</Badge>
                </div>

                <dl className="admin-card__grid">
                  <div>
                    <dt>{t("admin.requestedRole")}</dt>
                    <dd>{REQUEST_ROLE_LABEL[r.requested_role] || r.requested_role || "—"}</dd>
                  </div>
                  <div>
                    <dt>{t("admin.phone")}</dt>
                    <dd>{r.phone || "—"}</dd>
                  </div>
                  <div>
                    <dt>{t("admin.organization")}</dt>
                    <dd>{r.organization || "—"}</dd>
                  </div>
                  <div>
                    <dt>{t("admin.created")}</dt>
                    <dd>{formatDateTime(r.created_at)}</dd>
                  </div>
                  <div>
                    <dt>{t("admin.updatedAt")}</dt>
                    <dd>{formatDateTime(r.updated_at)}</dd>
                  </div>
                </dl>

                {r.message && (
                  <div className="admin-card__message">
                    <dt>{t("admin.message")}</dt>
                    <p>{r.message}</p>
                  </div>
                )}

                <label className="admin-note">
                  <span>
                    <b>{t("admin.adminNote")}</b>
                    <small>{t("admin.noteHelp")}</small>
                  </span>
                  <textarea
                    rows={2}
                    value={notes[r.id] ?? ""}
                    placeholder={t("admin.notePlaceholder")}
                    onChange={(e) =>
                      setNotes((n) => ({ ...n, [r.id]: e.target.value }))
                    }
                  />
                </label>

                <div className="admin-card__actions">
                  <button
                    type="button"
                    className="btn btn--ghost btn--sm"
                    disabled={busy}
                    onClick={() => saveNote(r)}
                  >
                    {t("admin.saveNote")}
                  </button>
                  <div className="admin-card__status-actions">
                    <button
                      type="button"
                      className="btn btn--ghost btn--sm"
                      disabled={busy || r.status === "reviewed"}
                      onClick={() => changeStatus(r, "reviewed")}
                    >
                      {t("admin.markReviewed")}
                    </button>
                    <button
                      type="button"
                      className="btn btn--gold btn--sm"
                      disabled={busy || r.status === "accepted"}
                      onClick={() => changeStatus(r, "accepted")}
                    >
                      {t("admin.accept")}
                    </button>
                    <button
                      type="button"
                      className="btn btn--ghost btn--sm admin-btn-decline"
                      disabled={busy || r.status === "declined"}
                      onClick={() => changeStatus(r, "declined")}
                    >
                      {t("admin.decline")}
                    </button>
                  </div>
                </div>
              </li>
            );
          })}
        </ul>
      )}
      </section>
    </div>
  );
}
