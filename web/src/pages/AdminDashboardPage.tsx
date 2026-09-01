import { useCallback, useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { listAccessRequests, type AccessRequestStatus } from "../api/accessRequests";
import { listAdminUsers } from "../api/adminUsers";
import { useAuth } from "../auth/AuthContext";
import { Badge, EmptyState } from "../components/ui";
import { useI18n } from "../i18n/useI18n";
import type { TranslationKey } from "../i18n/translations";
import { formatDateTime } from "../lib";
import type { AccessRequest } from "../types";

type MetricKey = "total" | AccessRequestStatus;
type MetricValues = Record<MetricKey, number | null>;
type AccountRole = "patient" | "doctor" | "therapist" | "family" | "admin";
type AccountValues = Record<"total" | AccountRole, number | null>;
type AccountStatusValues = Record<"active" | "inactive" | "suspended", number>;
type Tone = "neutral" | "live" | "plan" | "gold";
type AdminIconName =
  | "users" | "patient" | "doctor" | "therapist" | "family" | "admin"
  | "requests" | "pending" | "reviewed" | "accepted" | "declined";

const STATUS_KEYS: Record<AccessRequestStatus, TranslationKey> = {
  pending: "admin.pending",
  reviewed: "admin.reviewed",
  accepted: "admin.accepted",
  declined: "admin.declined",
};

const STATUS_TONES: Record<AccessRequestStatus, Tone> = {
  pending: "gold",
  reviewed: "neutral",
  accepted: "live",
  declined: "plan",
};

const METRIC_COPY: Array<{
  key: MetricKey;
  label: TranslationKey;
  hint: TranslationKey;
  icon: AdminIconName;
}> = [
  { key: "total", label: "admin.dashboard.total", hint: "admin.dashboard.totalHelp", icon: "requests" },
  { key: "pending", label: "admin.pending", hint: "admin.dashboard.pendingHelp", icon: "pending" },
  { key: "reviewed", label: "admin.reviewed", hint: "admin.dashboard.reviewedHelp", icon: "reviewed" },
  { key: "accepted", label: "admin.accepted", hint: "admin.dashboard.acceptedHelp", icon: "accepted" },
  { key: "declined", label: "admin.declined", hint: "admin.dashboard.declinedHelp", icon: "declined" },
];

const EMPTY_METRICS: MetricValues = {
  total: null,
  pending: null,
  reviewed: null,
  accepted: null,
  declined: null,
};

const EMPTY_ACCOUNTS: AccountValues = {
  total: null,
  patient: null,
  doctor: null,
  therapist: null,
  family: null,
  admin: null,
};

const ACCOUNT_COPY: Array<{
  key: "total" | AccountRole;
  label: TranslationKey;
  icon: AdminIconName;
}> = [
  { key: "total", label: "admin.accounts.total", icon: "users" },
  { key: "patient", label: "admin.accounts.patients", icon: "patient" },
  { key: "doctor", label: "admin.accounts.doctors", icon: "doctor" },
  { key: "therapist", label: "admin.accounts.therapists", icon: "therapist" },
  { key: "family", label: "admin.accounts.family", icon: "family" },
  { key: "admin", label: "admin.accounts.admins", icon: "admin" },
];

const ACCOUNT_ROLES: AccountRole[] = ["patient", "doctor", "therapist", "family", "admin"];

function AdminIcon({ name }: { name: AdminIconName }) {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
      {name === "users" && <><circle cx="9" cy="8" r="3"/><path d="M3.5 19c.4-4 2.2-6 5.5-6s5.1 2 5.5 6"/><path d="M15 6.2a2.7 2.7 0 0 1 0 5.2M16 13.5c2.6.5 4 2.3 4.3 5.5"/></>}
      {name === "patient" && <><circle cx="12" cy="7" r="3"/><path d="M6.5 20v-2.5a5.5 5.5 0 0 1 11 0V20"/><path d="M12 12v5M9.5 14.5h5"/></>}
      {name === "doctor" && <><path d="M7 5h10a2 2 0 0 1 2 2v12H5V7a2 2 0 0 1 2-2Z"/><path d="M9 5V3h6v2M12 9v6M9 12h6"/></>}
      {name === "therapist" && <><path d="M5 5.5h14v10H9l-4 3v-13Z"/><path d="M9 9h6M9 12h4"/></>}
      {name === "family" && <><circle cx="8" cy="8" r="2.5"/><circle cx="16" cy="8" r="2.5"/><path d="M3.5 19c.2-3.7 1.8-5.5 4.5-5.5s4.3 1.8 4.5 5.5M11.5 19c.2-3.7 1.8-5.5 4.5-5.5s4.3 1.8 4.5 5.5"/></>}
      {name === "admin" && <><path d="M12 3 19 6v5c0 4.5-2.6 7.7-7 10-4.4-2.3-7-5.5-7-10V6l7-3Z"/><path d="m9.3 12 1.8 1.8 3.8-4"/></>}
      {name === "requests" && <><rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 4.5V3h6v1.5M8.5 9h7M8.5 13h7M8.5 17H13"/></>}
      {name === "pending" && <><circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2"/></>}
      {name === "reviewed" && <><path d="M4 5h16v14H4z"/><path d="m8 12 2.3 2.3L16 8.8"/></>}
      {name === "accepted" && <><circle cx="12" cy="12" r="8.5"/><path d="m8 12 2.6 2.6L16.5 9"/></>}
      {name === "declined" && <><circle cx="12" cy="12" r="8.5"/><path d="m9 9 6 6M15 9l-6 6"/></>}
    </svg>
  );
}

export function AdminDashboardPage() {
  const { isAdmin } = useAuth();
  const { t } = useI18n();
  const [metrics, setMetrics] = useState<MetricValues>(EMPTY_METRICS);
  const [recent, setRecent] = useState<AccessRequest[] | null>(null);
  const [recentUnavailable, setRecentUnavailable] = useState(false);
  const [loading, setLoading] = useState(true);
  const [accounts, setAccounts] = useState<AccountValues>(EMPTY_ACCOUNTS);
  const [accountsLoading, setAccountsLoading] = useState(true);
  const [accountRolesUnavailable, setAccountRolesUnavailable] = useState(false);
  const [accountStatuses,setAccountStatuses]=useState<AccountStatusValues>({active:0,inactive:0,suspended:0});

  const load = useCallback(async () => {
    setLoading(true);
    setRecentUnavailable(false);

    const requests = [
      listAccessRequests(),
      listAccessRequests("pending"),
      listAccessRequests("reviewed"),
      listAccessRequests("accepted"),
      listAccessRequests("declined"),
    ] as const;
    const keys: MetricKey[] = ["total", "pending", "reviewed", "accepted", "declined"];
    const results = await Promise.allSettled(requests);
    const next: MetricValues = { ...EMPTY_METRICS };

    results.forEach((result, index) => {
      if (result.status === "fulfilled") next[keys[index]] = result.value.total;
    });

    const allResult = results[0];
    if (allResult.status === "fulfilled") {
      setRecent(
        [...allResult.value.requests]
          .sort((a, b) => +new Date(b.created_at) - +new Date(a.created_at))
          .slice(0, 6),
      );
    } else {
      setRecent(null);
      setRecentUnavailable(true);
    }

    setMetrics(next);
    setLoading(false);
  }, []);

  const loadAccounts = useCallback(async () => {
    setAccountsLoading(true);
    setAccountRolesUnavailable(false);
    setAccounts({ ...EMPTY_ACCOUNTS });

    try {
      const first = await listAdminUsers(200, 0);
      const next: AccountValues = { ...EMPTY_ACCOUNTS, total: first.total };
      const offsets: number[] = [];
      for (let offset = first.limit; offset < first.total; offset += first.limit) {
        offsets.push(offset);
      }

      try {
        const remaining = await Promise.all(
          offsets.map((offset) => listAdminUsers(200, offset)),
        );
        if (remaining.some((page) => page.total !== first.total)) {
          throw new Error("Admin user total changed during pagination");
        }
        const uniqueUsers = new Map(
          [first, ...remaining]
            .flatMap((page) => page.users)
            .map((user) => [user.id, user] as const),
        );

        if (uniqueUsers.size !== first.total) {
          throw new Error("Incomplete Admin user listing");
        }

        ACCOUNT_ROLES.forEach((role) => {
          next[role] = [...uniqueUsers.values()].filter((user) =>
            user.roles.includes(role),
          ).length;
        });
        const allUsers=[...uniqueUsers.values()];
        setAccountStatuses({active:allUsers.filter(user=>user.status==="active").length,inactive:allUsers.filter(user=>user.status==="inactive").length,suspended:allUsers.filter(user=>user.status==="suspended").length});
      } catch {
        setAccountRolesUnavailable(true);
      }

      setAccounts(next);
    } catch {
      setAccounts({ ...EMPTY_ACCOUNTS });
      setAccountRolesUnavailable(true);
    } finally {
      setAccountsLoading(false);
    }
  }, []);

  useEffect(() => {
    if (isAdmin) {
      void load();
      void loadAccounts();
    }
  }, [isAdmin, load, loadAccounts]);

  const distribution = useMemo(
    () =>
      (["pending", "reviewed", "accepted", "declined"] as AccessRequestStatus[]).map(
        (status) => {
          const count = metrics[status];
          const percentage =
            count !== null && metrics.total !== null && metrics.total > 0
              ? Math.min(100, (count / metrics.total) * 100)
              : 0;
          return { status, count, percentage };
        },
      ),
    [metrics],
  );

  if (!isAdmin) {
    return <div className="page"><EmptyState message={t("admin.unauthorized")} /></div>;
  }

  const metricValue = (value: number | null) =>
    loading ? "…" : value === null ? t("admin.dashboard.unavailable") : String(value);
  const accountValue = (value: number | null) =>
    accountsLoading ? "…" : value === null ? t("admin.dashboard.unavailable") : String(value);

  const accountDistribution = ACCOUNT_ROLES.map((role) => ({
    role,
    count: accounts[role],
    percentage:
      accounts[role] !== null && accounts.total !== null && accounts.total > 0
        ? Math.min(100, (accounts[role] / accounts.total) * 100)
        : 0,
  }));
  const donutCircumference = 251.2;
  const accessChartAvailable =
    !loading && metrics.total !== null && distribution.every(({ count }) => count !== null);
  let donutOffset = 0;
  const donutSegments = distribution.map((item) => {
    const length = accessChartAvailable && metrics.total! > 0
      ? donutCircumference * (item.count! / metrics.total!)
      : 0;
    const segment = { ...item, length, offset: donutOffset };
    donutOffset += length;
    return segment;
  });

  return (
    <div className="page admin-page admin-dashboard">
      <header className="admin-dashboard__head">
        <div>
          <span className="eyebrow">{t("admin.eyebrow")}</span>
          <h1>{t("admin.dashboard.title")}</h1>
          <p>{t("admin.dashboard.sub")}</p>
        </div>
        <Link className="btn btn--gold" to="/admin/access-requests">
          {t("admin.dashboard.reviewRequests")}
        </Link>
      </header>

      <section className="admin-accounts admin-accounts--visual" aria-labelledby="admin-accounts-title">
        <header className="admin-domain-head">
          <div>
            <span className="eyebrow">{t("admin.accounts.eyebrow")}</span>
            <h2 id="admin-accounts-title">{t("admin.accounts.title")}</h2>
            <p>{t("admin.accounts.sub")}</p>
          </div>
          {accountRolesUnavailable && !accountsLoading && (
            <button className="btn btn--ghost btn--sm" type="button" onClick={() => void loadAccounts()}>
              {t("common.retry")}
            </button>
          )}
        </header>
        <div className="admin-accounts-visual-grid">
          <div className="admin-account-overview" aria-busy={accountsLoading}>
            <article className="admin-total-users">
              <div className="admin-total-users__copy">
                <span className="admin-visual-icon"><AdminIcon name="users" /></span>
                <div>
                  <small>{t("admin.accounts.totalRegistered")}</small>
                  <strong>{accountValue(accounts.total)}</strong>
                  <p>{t("admin.accounts.totalRegisteredHelp")}</p>
                </div>
              </div>
              <div className="admin-total-users__pattern" aria-hidden="true"><i/><i/><i/><i/><i/></div>
            </article>
            <div className="admin-role-cards">
              {ACCOUNT_COPY.filter((item) => item.key !== "total").map((item) => {
                const value = accounts[item.key];
                const coverage = value !== null && accounts.total !== null && accounts.total > 0
                  ? Math.min(100, (value / accounts.total) * 100)
                  : 0;
                return (
                  <article className={`admin-role-card admin-role-card--${item.key}`} key={item.key}>
                    <span className="admin-visual-icon"><AdminIcon name={item.icon} /></span>
                    <div><small>{t(item.label)}</small><strong>{accountValue(value)}</strong></div>
                    <span className="admin-role-card__track" aria-hidden="true"><i style={{ width: `${coverage}%` }} /></span>
                  </article>
                );
              })}
            </div>
          </div>
          <section className="admin-role-coverage" aria-labelledby="admin-role-coverage-title">
            <header>
              <span className="eyebrow">{t("admin.accounts.distribution")}</span>
              <h3 id="admin-role-coverage-title">{t("admin.accounts.coverage")}</h3>
              <p>{t("admin.accounts.overlapNote")}</p>
            </header>
            <div className="admin-role-coverage__visual">
              <div className="admin-role-rings" aria-hidden="true">
                <svg viewBox="0 0 200 200">
                  {accountDistribution.map(({ role, percentage }, index) => {
                    const radius = 82 - index * 12;
                    const circumference = 2 * Math.PI * radius;
                    return (
                      <g className={`admin-role-ring admin-role-ring--${role}`} key={role}>
                        <circle className="admin-role-ring__base" cx="100" cy="100" r={radius} />
                        <circle
                          className="admin-role-ring__value"
                          cx="100" cy="100" r={radius}
                          strokeDasharray={`${circumference * percentage / 100} ${circumference}`}
                        />
                      </g>
                    );
                  })}
                </svg>
                <div className="admin-role-rings__center">
                  <strong>{accountValue(accounts.total)}</strong>
                  <span>{t("admin.accounts.total")}</span>
                </div>
              </div>
              <div className="admin-role-coverage__legend">
                {accountDistribution.map(({ role, count, percentage }) => (
                  <div className={`admin-coverage-key admin-coverage-key--${role}`} key={role}>
                    <i aria-hidden="true" />
                    <span>{t(ACCOUNT_COPY.find((item) => item.key === role)!.label)}</span>
                    <strong>{accountValue(count)}</strong>
                    <small>{Math.round(percentage)}%</small>
                  </div>
                ))}
              </div>
            </div>
          </section>
        </div>
      </section>

      <section className="admin-account-status" aria-labelledby="admin-account-status-title"><header><span className="eyebrow">{t("admin.accountStatus.eyebrow")}</span><h2 id="admin-account-status-title">{t("admin.accountStatus.title")}</h2><p>{t("admin.accountStatus.help")}</p></header><div className="admin-account-status__visual"><div className="admin-account-status__donut" style={{background:`conic-gradient(#778267 0 ${accounts.total?accountStatuses.active/accounts.total*100:0}%,#b58a60 0 ${accounts.total?(accountStatuses.active+accountStatuses.inactive)/accounts.total*100:0}%,#9a665b 0)`}}><span><strong>{accountValue(accounts.total)}</strong><small>{t("admin.accounts.total")}</small></span></div><div>{(["active","inactive","suspended"] as const).map(status=><article className={`admin-account-status__${status}`} key={status}><i/><span>{t(`admin.users.${status}` as TranslationKey)}</span><strong>{accountsLoading?"…":accountStatuses[status]}</strong></article>)}</div></div></section>

      <div className="admin-domain-divider">
        <span className="eyebrow">{t("admin.accessOperations")}</span>
        <p>{t("admin.accessOperationsHelp")}</p>
      </div>

      <section className="admin-metrics" aria-label={t("admin.dashboard.metrics")} aria-busy={loading}>
        {METRIC_COPY.map((item) => (
          <article className={`admin-metric admin-metric--${item.key}`} key={item.key}>
            <span className="admin-metric__symbol"><AdminIcon name={item.icon} /></span>
            <div>
              <span>{t(item.label)}</span>
              <strong>{metricValue(metrics[item.key])}</strong>
              <small>{t(item.hint)}</small>
            </div>
          </article>
        ))}
      </section>

      <div className="admin-access-visual-row">
        <section className="admin-access-ring" aria-labelledby="admin-access-ring-title">
          <header>
            <span className="eyebrow">{t("admin.dashboard.statusOverview")}</span>
            <h2 id="admin-access-ring-title">{t("admin.dashboard.accessStatus")}</h2>
            <p>{t("admin.dashboard.accessStatusHelp")}</p>
          </header>
          <div className="admin-access-ring__body">
            <div className="admin-donut">
              <svg viewBox="0 0 120 120" role="img" aria-label={t("admin.dashboard.accessStatus")}>
                <circle className="admin-donut__base" cx="60" cy="60" r="40" />
                {donutSegments.map(({ status, length, offset }) => length > 0 && (
                  <circle
                    className={`admin-donut__segment admin-donut__segment--${status}`}
                    cx="60" cy="60" r="40" key={status}
                    strokeDasharray={`${length} ${donutCircumference - length}`}
                    strokeDashoffset={-offset}
                  />
                ))}
              </svg>
              <div className="admin-donut__center">
                <strong>{metricValue(metrics.total)}</strong>
                <span>{t("admin.dashboard.total")}</span>
              </div>
            </div>
            <div className="admin-donut-legend">
              {distribution.map(({ status, count }) => (
                <div className={`admin-donut-legend__item admin-donut-legend__item--${status}`} key={status}>
                  <i aria-hidden="true" />
                  <span>{t(STATUS_KEYS[status])}</span>
                  <strong>{metricValue(count)}</strong>
                </div>
              ))}
              {!loading && metrics.total === 0 && <p>{t("admin.dashboard.noRecent")}</p>}
              {!loading && !accessChartAvailable && metrics.total !== 0 && <p>{t("admin.dashboard.unavailable")}</p>}
            </div>
          </div>
        </section>

        <section className="admin-pending-panel admin-pending-panel--visual">
          <div className="admin-pending-panel__icon">
            <AdminIcon name={metrics.pending === 0 ? "accepted" : "pending"} />
          </div>
          <span className="eyebrow">{t("admin.dashboard.pendingWork")}</span>
          {loading ? (
            <strong>…</strong>
          ) : metrics.pending === null ? (
            <><strong>{t("admin.dashboard.unavailable")}</strong><p>{t("admin.dashboard.pendingUnavailable")}</p></>
          ) : metrics.pending > 0 ? (
            <><strong>{metrics.pending}</strong><h2>{t("admin.dashboard.needsReview")}</h2><p>{t("admin.dashboard.pendingBody")}</p></>
          ) : (
            <><h2>{t("admin.dashboard.allCaughtUp")}</h2><p>{t("admin.dashboard.upToDateHelp")}</p></>
          )}
          {metrics.pending !== 0 && (
            <Link className="btn btn--ghost btn--sm" to="/admin/access-requests">
              {t("admin.dashboard.reviewRequests")}
            </Link>
          )}
        </section>
      </div>

      <section className="admin-recent admin-recent--full" aria-labelledby="admin-recent-title">
        <header className="admin-panel-head">
          <div>
            <span className="eyebrow">{t("admin.dashboard.workspace")}</span>
            <h2 id="admin-recent-title">{t("admin.dashboard.recent")}</h2>
          </div>
          <Link to="/admin/access-requests">{t("admin.dashboard.viewAll")}</Link>
        </header>

        {loading ? (
          <div className="admin-dashboard-state" role="status">{t("common.loading")}</div>
        ) : recentUnavailable ? (
          <div className="admin-dashboard-state admin-dashboard-state--error">
            <strong>{t("admin.dashboard.recentUnavailable")}</strong>
            <button className="btn btn--ghost btn--sm" type="button" onClick={() => void load()}>{t("common.retry")}</button>
          </div>
        ) : recent?.length === 0 ? (
          <div className="admin-dashboard-state admin-dashboard-state--empty">
            <span className="admin-dashboard-state__icon"><AdminIcon name="requests" /></span>
            <strong>{t("admin.dashboard.noRecent")}</strong>
            <span>{t("admin.dashboard.noRecentHelp")}</span>
          </div>
        ) : (
          <div className="admin-recent-table">
            <div className="admin-recent-table__head" aria-hidden="true">
              <span>{t("admin.dashboard.requester")}</span><span>{t("admin.requestedRole")}</span><span>{t("admin.organization")}</span><span>{t("admin.dashboard.submitted")}</span><span>{t("admin.status")}</span>
            </div>
            <ul>
              {recent?.map((request) => {
                const status = request.status as AccessRequestStatus;
                const knownStatus = STATUS_KEYS[status];
                return (
                  <li key={request.id}>
                    <div className="admin-recent__requester"><span aria-hidden="true">{request.full_name.trim().slice(0, 1).toUpperCase() || "?"}</span><div><strong>{request.full_name}</strong><small>{request.email}</small></div></div>
                    <div data-label={t("admin.requestedRole")}><span className="admin-role-badge">{request.requested_role || "—"}</span></div>
                    <div data-label={t("admin.organization")}>{request.organization || "—"}</div>
                    <time data-label={t("admin.dashboard.submitted")} dateTime={request.created_at}>{formatDateTime(request.created_at)}</time>
                    <div data-label={t("admin.status")}><Badge tone={knownStatus ? STATUS_TONES[status] : "neutral"}>{knownStatus ? t(knownStatus) : request.status}</Badge></div>
                  </li>
                );
              })}
            </ul>
          </div>
        )}
      </section>
    </div>
  );
}
