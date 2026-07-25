import { useEffect, useMemo, useState, type FormEvent } from "react";
import { Link } from "react-router-dom";
import { api, ApiError, resolveMediaUrl } from "../api/client";
import { useAuth } from "../auth/AuthContext";
import {
  Badge,
  Card,
  EmptyState,
  ErrorState,
  SectionHeader,
  Spinner,
} from "../components/ui";
import { formatDate, patientName, pickLinkedPatient } from "../lib";
import type {
  Appointment,
  AppointmentListResponse,
  AvailabilitySlot,
  PatientListResponse,
  PatientProfile,
  Provider,
  ProviderListResponse,
  SlotListResponse,
} from "../types";

function statusTone(status: string): "neutral" | "live" | "plan" | "gold" {
  switch (status) {
    case "approved":
      return "live";
    case "completed":
      return "gold";
    case "cancelled":
      return "neutral";
    default:
      return "plan";
  }
}

const modeLabel = (mode: string) => (mode === "online" ? "Online" : "In-person");
const roleLabel = (role: string) =>
  role === "therapist" ? "Therapist" : "Doctor";
const whereLabel = (mode: string, location?: string | null) =>
  mode === "online" ? "Online session" : location || "In-person";
const ratingText = (p: Provider) =>
  p.rating_average != null ? `${p.rating_average.toFixed(1)} ★` : null;

function dayLabel(dateStr: string): string {
  const d = new Date(`${dateStr}T00:00:00`);
  if (Number.isNaN(d.getTime())) return dateStr;
  return d.toLocaleDateString(undefined, {
    weekday: "long",
    month: "short",
    day: "numeric",
  });
}

function groupByDate(slots: AvailabilitySlot[]) {
  const groups: { date: string; label: string; slots: AvailabilitySlot[] }[] = [];
  const index = new Map<string, number>();
  for (const s of slots) {
    let i = index.get(s.slot_date);
    if (i === undefined) {
      i = groups.length;
      index.set(s.slot_date, i);
      groups.push({ date: s.slot_date, label: dayLabel(s.slot_date), slots: [] });
    }
    groups[i].slots.push(s);
  }
  return groups;
}

function withinNextWeek(dateStr?: string | null): boolean {
  if (!dateStr) return false;
  const d = new Date(`${dateStr}T00:00:00`);
  if (Number.isNaN(d.getTime())) return false;
  const limit = new Date();
  limit.setHours(0, 0, 0, 0);
  limit.setDate(limit.getDate() + 7);
  return d <= limit;
}

function scrollToId(id: string) {
  document
    .getElementById(id)
    ?.scrollIntoView({ behavior: "smooth", block: "start" });
}

const ALL = "all";

const GOVERNORATES = [
  "Nablus",
  "Ramallah",
  "Hebron",
  "Jenin",
  "Tulkarem",
  "Qalqilya",
  "Bethlehem",
  "Jerusalem",
  "Jericho",
  "Tubas",
  "Salfit",
];

/**
 * Family Appointments — a doctor-directory style care-coordination booking page:
 * a search/filter bar, large provider listing cards with ratings and CTAs, a
 * specialties sidebar, inline availability + booking, confirmation, and history.
 * Ratings/provider profiles are seeded demo values. Coordination only — not
 * emergency care.
 */
export function FamilyAppointmentsPage() {
  const { user } = useAuth();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [patient, setPatient] = useState<PatientProfile | null>(null);
  const [providers, setProviders] = useState<Provider[]>([]);
  const [slotsByProvider, setSlotsByProvider] = useState<
    Record<string, AvailabilitySlot[]>
  >({});
  const [slotsLoadingId, setSlotsLoadingId] = useState<string | null>(null);
  const [history, setHistory] = useState<Appointment[]>([]);

  // Filters
  const [search, setSearch] = useState("");
  const [roleFilter, setRoleFilter] = useState(ALL);
  const [modeFilter, setModeFilter] = useState(ALL);
  const [availFilter, setAvailFilter] = useState(ALL);
  const [specialtyFilter, setSpecialtyFilter] = useState(ALL);
  const [govFilter, setGovFilter] = useState(ALL);

  // Booking
  const [selectedProviderId, setSelectedProviderId] = useState<string | null>(
    null,
  );
  const [selectedSlotId, setSelectedSlotId] = useState<string | null>(null);
  const [reason, setReason] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);
  const [lastBooked, setLastBooked] = useState<Appointment | null>(null);

  const fetchAvailability = async (id: string): Promise<AvailabilitySlot[]> => {
    setSlotsLoadingId(id);
    try {
      const res = await api<SlotListResponse>(`/providers/${id}/availability`);
      setSlotsByProvider((prev) => ({ ...prev, [id]: res.slots }));
      return res.slots;
    } catch {
      setSlotsByProvider((prev) => ({ ...prev, [id]: [] }));
      return [];
    } finally {
      setSlotsLoadingId(null);
    }
  };

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const p = await api<PatientListResponse>("/patients?limit=50");
      const linked = pickLinkedPatient(p.patients, user?.id);
      setPatient(linked);

      const prov = await api<ProviderListResponse>("/providers");
      setProviders(prov.providers);

      if (linked) {
        const a = await api<AppointmentListResponse>(
          `/appointments?patient_profile_id=${linked.id}&limit=200`,
        );
        setHistory(a.appointments);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not load.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  // Scroll to the booking panel whenever a slot becomes selected.
  useEffect(() => {
    if (selectedSlotId) scrollToId("booking-panel");
  }, [selectedSlotId]);

  const providerById = useMemo(
    () => new Map(providers.map((p) => [p.provider_user_id, p])),
    [providers],
  );

  const specialties = useMemo(
    () =>
      Array.from(
        new Set(
          providers
            .map((p) => p.specialty)
            .filter((s): s is string => Boolean(s)),
        ),
      ).sort(),
    [providers],
  );

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    return providers.filter((p) => {
      if (
        q &&
        !`${p.full_name} ${p.specialty ?? ""}`.toLowerCase().includes(q)
      )
        return false;
      if (roleFilter !== ALL && p.role !== roleFilter) return false;
      if (govFilter !== ALL && (p.governorate ?? "") !== govFilter) return false;
      if (modeFilter === "in_person" && !p.in_person_available) return false;
      if (modeFilter === "online" && !p.online_available) return false;
      if (availFilter === "week" && !withinNextWeek(p.next_available_date))
        return false;
      if (specialtyFilter !== ALL && (p.specialty ?? "") !== specialtyFilter)
        return false;
      return true;
    });
  }, [
    providers,
    search,
    roleFilter,
    govFilter,
    modeFilter,
    availFilter,
    specialtyFilter,
  ]);

  const selectedProvider = selectedProviderId
    ? (providerById.get(selectedProviderId) ?? null)
    : null;
  const selectedSlots = selectedProviderId
    ? (slotsByProvider[selectedProviderId] ?? [])
    : [];
  const selectedSlot =
    selectedSlots.find((s) => s.id === selectedSlotId) ?? null;

  const providerModes = (p: Provider): string[] => {
    const parts: string[] = [];
    if (p.in_person_available) parts.push("In-person");
    if (p.online_available) parts.push("Online");
    return parts;
  };

  const viewTimes = async (id: string) => {
    setSelectedProviderId(id);
    setSelectedSlotId(null);
    setFormError(null);
    if (!(id in slotsByProvider)) await fetchAvailability(id);
    scrollToId(`prov-${id}`);
  };

  const bookAppointment = (id: string) => void viewTimes(id);

  const quickBooking = async (id: string) => {
    setSelectedProviderId(id);
    setSelectedSlotId(null);
    setFormError(null);
    const slots = slotsByProvider[id] ?? (await fetchAvailability(id));
    if (slots.length > 0) {
      setSelectedSlotId(slots[0].id);
    } else {
      scrollToId(`prov-${id}`);
    }
  };

  const resetBooking = () => {
    setLastBooked(null);
    setSelectedProviderId(null);
    setSelectedSlotId(null);
    setReason("");
    setFormError(null);
  };

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setFormError(null);
    if (!patient || !selectedProvider || !selectedSlot) return;
    const r = reason.trim();
    if (!r) {
      setFormError("Please enter a reason.");
      return;
    }
    setSubmitting(true);
    try {
      const created = await api<Appointment>("/appointments", {
        method: "POST",
        body: JSON.stringify({
          patient_profile_id: patient.id,
          provider_user_id: selectedProvider.provider_user_id,
          availability_slot_id: selectedSlot.id,
          reason: r,
        }),
      });
      setHistory((prev) => [created, ...prev]);
      setSlotsByProvider((prev) => ({
        ...prev,
        [selectedProvider.provider_user_id]: (
          prev[selectedProvider.provider_user_id] ?? []
        ).filter((s) => s.id !== selectedSlot.id),
      }));
      setLastBooked(created);
    } catch (err) {
      setFormError(
        err instanceof ApiError
          ? err.status === 403
            ? "This account isn't linked to this patient, so it can't request an appointment."
            : err.message
          : "Could not send the request. Please try again.",
      );
    } finally {
      setSubmitting(false);
    }
  };

  const renderExpansion = (p: Provider) => {
    const slots = slotsByProvider[p.provider_user_id] ?? [];
    return (
      <div className="doc-card__expand">
        <div className="expand-times">
          <h4>Available times</h4>
          {slotsLoadingId === p.provider_user_id ? (
            <Spinner label="Loading available times…" />
          ) : slots.length === 0 ? (
            <EmptyState message="No available slots right now." />
          ) : (
            <div className="slot-days">
              {groupByDate(slots).map((group) => (
                <div className="slot-day" key={group.date}>
                  <div className="slot-day__label">{group.label}</div>
                  <div className="slot-grid">
                    {group.slots.map((slot) => {
                      const active = selectedSlotId === slot.id;
                      return (
                        <button
                          type="button"
                          key={slot.id}
                          className={`slot-chip ${active ? "slot-chip--active" : ""}`}
                          onClick={() => setSelectedSlotId(slot.id)}
                        >
                          <span className="slot-chip__time">
                            {slot.start_time}–{slot.end_time}
                          </span>
                          <span className="slot-chip__meta">
                            <Badge
                              tone={
                                slot.appointment_mode === "online"
                                  ? "gold"
                                  : "live"
                              }
                            >
                              {modeLabel(slot.appointment_mode)}
                            </Badge>
                            <span className="slot-chip__loc">
                              {whereLabel(slot.appointment_mode, slot.location)}
                            </span>
                          </span>
                          <span className="slot-chip__cta">
                            {active ? "Selected" : "Choose"}
                          </span>
                        </button>
                      );
                    })}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {selectedSlot && (
          <div id="booking-panel" className="expand-book">
            <h4>Confirm appointment request</h4>
            <div className="booking-summary">
              <div>
                <span className="booking-summary__k">Provider</span>
                <span className="booking-summary__v">
                  {p.full_name} · {roleLabel(p.role)}
                </span>
              </div>
              <div>
                <span className="booking-summary__k">Date &amp; time</span>
                <span className="booking-summary__v">
                  {formatDate(selectedSlot.slot_date)} · {selectedSlot.start_time}
                  –{selectedSlot.end_time}
                </span>
              </div>
              <div>
                <span className="booking-summary__k">Session</span>
                <span className="booking-summary__v">
                  <Badge
                    tone={
                      selectedSlot.appointment_mode === "online"
                        ? "gold"
                        : "live"
                    }
                  >
                    {modeLabel(selectedSlot.appointment_mode)}
                  </Badge>{" "}
                  {whereLabel(selectedSlot.appointment_mode, selectedSlot.location)}
                </span>
              </div>
            </div>
            <form className="mform" onSubmit={onSubmit}>
              <label className="mform__full">
                Reason <span className="mform__req">*</span>
                <textarea
                  rows={2}
                  maxLength={500}
                  value={reason}
                  onChange={(e) => setReason(e.target.value)}
                  placeholder="e.g. routine follow-up visit"
                />
              </label>
              {formError && <div className="mform__error">{formError}</div>}
              <div className="mform__actions">
                <button
                  className="btn btn--gold"
                  type="submit"
                  disabled={submitting || !reason.trim()}
                >
                  {submitting ? "Sending…" : "Request appointment"}
                </button>
              </div>
            </form>
          </div>
        )}
      </div>
    );
  };

  const renderHistory = () =>
    patient && (
      <Card>
        <SectionHeader eyebrow="History" title="Appointment requests" />
        {history.length === 0 ? (
          <EmptyState message="No appointment requests yet." />
        ) : (
          <div className="table-card">
            <table className="table">
              <thead>
                <tr>
                  <th>Provider</th>
                  <th>Date / time</th>
                  <th>Mode</th>
                  <th>Where</th>
                  <th>Reason</th>
                  <th>Status</th>
                  <th>Requested</th>
                </tr>
              </thead>
              <tbody>
                {history.map((a) => {
                  const prov = a.provider_user_id
                    ? providerById.get(a.provider_user_id)
                    : undefined;
                  return (
                    <tr key={a.id}>
                      <td>
                        {a.provider_name || "—"}
                        {prov && (
                          <span className="cell-sub">{roleLabel(prov.role)}</span>
                        )}
                      </td>
                      <td>
                        {formatDate(a.preferred_date)}
                        {a.preferred_time ? ` · ${a.preferred_time}` : ""}
                      </td>
                      <td>
                        <Badge
                          tone={a.appointment_mode === "online" ? "gold" : "live"}
                        >
                          {modeLabel(a.appointment_mode)}
                        </Badge>
                      </td>
                      <td>{whereLabel(a.appointment_mode, a.location)}</td>
                      <td>{a.reason}</td>
                      <td>
                        <Badge tone={statusTone(a.status)}>{a.status}</Badge>
                      </td>
                      <td>{formatDate(a.created_at)}</td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </Card>
    );

  return (
    <div className="page page--wide">
      <div className="page__head">
        <div>
          <span className="eyebrow">Family appointments</span>
          <h1>Family Appointments</h1>
          <p className="page__sub">
            Book care coordination for{" "}
            <strong>
              {patient ? patientName(patient.user) : "your family member"}
            </strong>{" "}
            — find a provider and request an in-person or online session.
          </p>
        </div>
      </div>

      <div className="safety">
        <span className="safety__mark" aria-hidden="true">
          ⚕
        </span>
        <p>
          <strong>Appointment requests are for care coordination only</strong>{" "}
          and are <strong>not emergency care</strong>. For medical concerns,
          contact the care team; for urgent concerns, contact your local
          emergency services.
        </p>
      </div>

      {loading ? (
        <Spinner label="Loading appointments…" />
      ) : error ? (
        <ErrorState message={error} onRetry={load} />
      ) : !patient ? (
        <EmptyState message="No linked patient yet. Once a patient is linked to your account, you can request appointments here." />
      ) : lastBooked ? (
        <Card className="confirm-card">
          <div className="confirm">
            <span className="confirm__check" aria-hidden="true">
              ✓
            </span>
            <div className="confirm__body">
              <h2>Appointment request sent</h2>
              <dl className="confirm__grid">
                <div>
                  <dt>Provider</dt>
                  <dd>{lastBooked.provider_name || "—"}</dd>
                </div>
                <div>
                  <dt>Date &amp; time</dt>
                  <dd>
                    {formatDate(lastBooked.preferred_date)}
                    {lastBooked.preferred_time
                      ? ` · ${lastBooked.preferred_time}`
                      : ""}
                  </dd>
                </div>
                <div>
                  <dt>Mode</dt>
                  <dd>
                    <Badge
                      tone={
                        lastBooked.appointment_mode === "online"
                          ? "gold"
                          : "live"
                      }
                    >
                      {modeLabel(lastBooked.appointment_mode)}
                    </Badge>{" "}
                    {whereLabel(lastBooked.appointment_mode, lastBooked.location)}
                  </dd>
                </div>
                <div>
                  <dt>Status</dt>
                  <dd>
                    <Badge tone="plan">Pending</Badge>
                  </dd>
                </div>
              </dl>
              <p className="confirm__note">
                The care team will review the request.
              </p>
              <button className="btn btn--gold" onClick={resetBooking}>
                Book another appointment
              </button>
            </div>
          </div>
        </Card>
      ) : (
        <>
          {/* A) Search and filter bar */}
          <form
            className="dir-filters"
            onSubmit={(e) => {
              e.preventDefault();
              scrollToId("dir-results");
            }}
          >
            <input
              className="dir-search"
              type="search"
              placeholder="Search by provider name or specialty"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
            <select
              className="dir-select"
              value={roleFilter}
              onChange={(e) => setRoleFilter(e.target.value)}
              aria-label="Role"
            >
              <option value={ALL}>All roles</option>
              <option value="doctor">Doctor</option>
              <option value="therapist">Therapist</option>
            </select>
            <select
              className="dir-select"
              value={govFilter}
              onChange={(e) => setGovFilter(e.target.value)}
              aria-label="Governorate"
            >
              <option value={ALL}>All governorates</option>
              {GOVERNORATES.map((g) => (
                <option key={g} value={g}>
                  {g}
                </option>
              ))}
            </select>
            <select
              className="dir-select"
              value={modeFilter}
              onChange={(e) => setModeFilter(e.target.value)}
              aria-label="Visit mode"
            >
              <option value={ALL}>All modes</option>
              <option value="in_person">In-person</option>
              <option value="online">Online</option>
            </select>
            <select
              className="dir-select"
              value={availFilter}
              onChange={(e) => setAvailFilter(e.target.value)}
              aria-label="Availability"
            >
              <option value={ALL}>Any availability</option>
              <option value="week">Available this week</option>
            </select>
            <button className="btn btn--gold" type="submit">
              Search
            </button>
          </form>

          <div className="dir-layout">
            {/* B) Provider listing */}
            <div className="dir-main" id="dir-results">
              {filtered.length === 0 ? (
                <EmptyState message="No providers match your filters." />
              ) : (
                filtered.map((p) => {
                  const active = selectedProviderId === p.provider_user_id;
                  const rating = ratingText(p);
                  return (
                    <article
                      id={`prov-${p.provider_user_id}`}
                      key={p.provider_user_id}
                      className={`doc-card ${active ? "doc-card--active" : ""}`}
                    >
                      <div className="doc-card__row">
                        <div className="doc-card__ratewrap">
                          {p.photo_url ? (
                            <img
                              className="doc-card__photo"
                              src={resolveMediaUrl(p.photo_url) ?? ""}
                              alt={p.full_name}
                              loading="lazy"
                            />
                          ) : (
                            <span
                              className="doc-card__avatar"
                              aria-hidden="true"
                            >
                              {p.full_name.slice(0, 1)}
                            </span>
                          )}
                          {rating && (
                            <span className="doc-card__rating">
                              <strong>{rating}</strong>
                              <small>{p.rating_count} demo ratings</small>
                            </span>
                          )}
                        </div>

                        <div className="doc-card__body">
                          <div className="doc-card__headline">
                            <h3>{p.full_name}</h3>
                            <Badge tone="neutral">{roleLabel(p.role)}</Badge>
                          </div>
                          <p className="doc-card__specialty">
                            {p.specialty ?? "Care coordination"}
                          </p>
                          {(p.governorate || p.city || p.location) && (
                            <p className="doc-card__loc">
                              {[
                                [p.city, p.governorate]
                                  .filter(Boolean)
                                  .join(", "),
                                p.location,
                              ]
                                .filter(Boolean)
                                .join(" · ")}
                            </p>
                          )}
                          {p.experience_label && (
                            <p className="doc-card__extra">
                              {p.experience_label}
                            </p>
                          )}
                          <p className="doc-card__contact">
                            Demo contact:{" "}
                            <span>
                              {p.phone_number_demo ||
                                "Demo contact not provided"}
                            </span>
                          </p>
                          {p.bio_short && (
                            <p className="doc-card__bio">{p.bio_short}</p>
                          )}
                          <div className="doc-card__meta">
                            {providerModes(p).map((m) => (
                              <Badge
                                key={m}
                                tone={m === "Online" ? "gold" : "live"}
                              >
                                {m}
                              </Badge>
                            ))}
                            <span className="doc-card__stat">
                              {p.available_slot_count} available{" "}
                              {p.available_slot_count === 1 ? "time" : "times"}
                            </span>
                            {p.next_available_date && (
                              <span className="doc-card__stat">
                                Next: {formatDate(p.next_available_date)}
                              </span>
                            )}
                          </div>
                        </div>

                        <div className="doc-card__actions">
                          <button
                            className="btn btn--gold"
                            onClick={() =>
                              bookAppointment(p.provider_user_id)
                            }
                          >
                            Book appointment
                          </button>
                          <button
                            className="btn btn--ghost"
                            onClick={() => quickBooking(p.provider_user_id)}
                          >
                            Quick booking
                          </button>
                          <button
                            className="btn btn--ghost"
                            onClick={() => viewTimes(p.provider_user_id)}
                          >
                            {active ? "Hide times" : "View times"}
                          </button>
                          <Link
                            className="btn btn--ghost"
                            to={`/providers/${p.provider_user_id}`}
                          >
                            View profile
                          </Link>
                          <Link
                            className="btn btn--ghost"
                            to={`/providers/${p.provider_user_id}#inquiry`}
                          >
                            Send inquiry
                          </Link>
                        </div>
                      </div>

                      {active && renderExpansion(p)}
                    </article>
                  );
                })
              )}
            </div>

            {/* C) Specialties sidebar */}
            <aside className="dir-side">
              <div className="cat-card">
                <h3>Specialties</h3>
                <p className="cat-card__lead">Filter providers by focus area.</p>
                <ul className="cat-list">
                  <li>
                    <button
                      type="button"
                      className={`cat-item ${specialtyFilter === ALL ? "cat-item--active" : ""}`}
                      onClick={() => setSpecialtyFilter(ALL)}
                    >
                      All specialties
                    </button>
                  </li>
                  {specialties.map((s) => (
                    <li key={s}>
                      <button
                        type="button"
                        className={`cat-item ${specialtyFilter === s ? "cat-item--active" : ""}`}
                        onClick={() => setSpecialtyFilter(s)}
                      >
                        {s}
                      </button>
                    </li>
                  ))}
                </ul>
                <p className="cat-card__note">
                  Care coordination only. For urgent concerns, contact local
                  emergency services.
                </p>
              </div>
            </aside>
          </div>
        </>
      )}

      {!loading && !error && renderHistory()}
    </div>
  );
}
