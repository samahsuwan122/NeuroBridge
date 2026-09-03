import {
  useCallback,
  useEffect,
  useMemo,
  useRef,
  useState,
} from "react";

import { useParams } from "react-router-dom";

import { ApiError } from "../api/client";

import {
  createAdminUser,
  deleteAdminUser,
  listAdminRoles,
  listAdminUsers,
  setAdminUserActive,
  updateAdminUser,
  type AdminRole,
  type AdminUserCreate,
  type AdminUserSummary,
} from "../api/adminUsers";

import { useAuth } from "../auth/AuthContext";
import { useI18n } from "../i18n/useI18n";

import type {
  TranslationKey,
} from "../i18n/translations";

import {
  formatDateTime,
  initials,
} from "../lib";

type Role =
  | "patient"
  | "doctor"
  | "therapist"
  | "family"
  | "admin";

const ROLES: Role[] = [
  "patient",
  "doctor",
  "therapist",
  "family",
  "admin",
];

const ROLE_KEYS: Record<
  string,
  TranslationKey
> = {
  patient: "admin.users.patientRole",
  doctor: "role.doctor",
  therapist: "role.therapist",
  family: "admin.users.familyRole",
  admin: "role.admin",
  manager: "admin.roles.manager",
};

const ROUTE_ROLES: Record<
  string,
  Role
> = {
  patients: "patient",
  doctors: "doctor",
  therapists: "therapist",
  family: "family",
};

const TITLE_KEYS: Record<
  string,
  TranslationKey
> = {
  patients: "admin.users.patientsTitle",
  doctors: "admin.users.doctorsTitle",
  therapists: "admin.users.therapistsTitle",
  family: "admin.users.familyTitle",
};

/*
 * جلب جميع صفحات المستخدمين.
 */
async function loadAllUsers():
Promise<AdminUserSummary[]> {
  const first = await listAdminUsers(
    200,
    0,
  );

  const pages = [first];

  for (
    let offset = first.limit;
    offset < first.total;
    offset += first.limit
  ) {
    pages.push(
      await listAdminUsers(
        first.limit,
        offset,
      ),
    );
  }

  if (
    pages.some(
      (page) =>
        page.total !== first.total,
    )
  ) {
    throw new Error(
      "Admin user total changed during pagination",
    );
  }

  const users = [
    ...new Map(
      pages
        .flatMap((page) => page.users)
        .map((user) => [
          user.id,
          user,
        ]),
    ).values(),
  ];

  if (users.length !== first.total) {
    throw new Error(
      "Incomplete Admin user listing",
    );
  }

  return users;
}

/*
 * مفتاح ترجمة حالة الحساب.
 */
function statusKey(
  status: string,
): TranslationKey {
  if (status === "active") {
    return "admin.users.active";
  }

  if (status === "inactive") {
    return "admin.users.inactive";
  }

  if (status === "pending") {
    return "admin.pending";
  }

  return "admin.users.suspended";
}

export function AdminUsersPage() {
  const { section } = useParams();

  const routeRole =
    section
      ? ROUTE_ROLES[section]
      : undefined;

  const {
    isAdmin,
    user: currentUser,
  } = useAuth();

  const {
    t,
    lang,
  } = useI18n();

  const [
    users,
    setUsers,
  ] = useState<AdminUserSummary[]>([]);

  const [
    roles,
    setRoles,
  ] = useState<AdminRole[]>([]);

  const [
    loading,
    setLoading,
  ] = useState(true);

  const [
    error,
    setError,
  ] = useState("");

  const [
    query,
    setQuery,
  ] = useState("");

  const [
    role,
    setRole,
  ] = useState<Role | "all">(
    routeRole || "all",
  );

  const [
    status,
    setStatus,
  ] = useState("all");

  const [
    selected,
    setSelected,
  ] = useState<AdminUserSummary | null>(
    null,
  );

  const [
    editing,
    setEditing,
  ] = useState(false);

  const [
    menu,
    setMenu,
  ] = useState<string | null>(null);

  const [
    busy,
    setBusy,
  ] = useState(false);

  const [
    notice,
    setNotice,
  ] = useState("");

  const [
    confirm,
    setConfirm,
  ] = useState<AdminUserSummary | null>(
    null,
  );

  const [
    deleteConfirm,
    setDeleteConfirm,
  ] = useState<AdminUserSummary | null>(
    null,
  );

  const [
    creating,
    setCreating,
  ] = useState(false);

  const menuRef =
    useRef<HTMLDivElement | null>(null);

  /*
   * تحميل المستخدمين والأدوار.
   */
  const load = useCallback(
    async () => {
      setLoading(true);
      setError("");

      try {
        const [
          items,
          availableRoles,
        ] = await Promise.all([
          loadAllUsers(),
          listAdminRoles(),
        ]);

        setUsers(items);
        setRoles(availableRoles);
      } catch (exception) {
        setError(
          exception instanceof ApiError
            ? exception.message
            : t("admin.users.loadError"),
        );
      } finally {
        setLoading(false);
      }
    },
    [t],
  );

  useEffect(() => {
    if (isAdmin) {
      void load();
    }
  }, [
    isAdmin,
    load,
  ]);

  useEffect(() => {
    setRole(
      routeRole || "all",
    );
  }, [routeRole]);

  /*
   * إغلاق قائمة الإجراءات عند الضغط خارجها.
   */
  useEffect(() => {
    const closeMenu = (
      event: MouseEvent,
    ) => {
      if (
        !menuRef.current?.contains(
          event.target as Node,
        )
      ) {
        setMenu(null);
      }
    };

    document.addEventListener(
      "mousedown",
      closeMenu,
    );

    return () => {
      document.removeEventListener(
        "mousedown",
        closeMenu,
      );
    };
  }, []);

  /*
   * أعداد المستخدمين حسب الدور.
   */
  const counts = useMemo(() => {
    return Object.fromEntries(
      [
        "total",
        ...ROLES,
      ].map((key) => [
        key,
        key === "total"
          ? users.length
          : users.filter(
              (user) =>
                user.roles.includes(key),
            ).length,
      ]),
    ) as Record<
      "total" | Role,
      number
    >;
  }, [users]);

  /*
   * نتائج البحث والتصفية.
   */
  const visible = useMemo(() => {
    const normalizedQuery =
      query
        .trim()
        .toLocaleLowerCase();

    return users.filter((user) => {
      const matchesRoute =
        !routeRole ||
        user.roles.includes(
          routeRole,
        );

      const matchesRole =
        role === "all" ||
        user.roles.includes(role);

      const matchesStatus =
        status === "all" ||
        user.status === status;

      const searchValue =
        `${user.full_name} ${user.email || ""} ${user.phone || ""}`
          .toLocaleLowerCase();

      const matchesSearch =
        normalizedQuery === "" ||
        searchValue.includes(
          normalizedQuery,
        );

      return (
        matchesRoute &&
        matchesRole &&
        matchesStatus &&
        matchesSearch
      );
    });
  }, [
    users,
    routeRole,
    role,
    status,
    query,
  ]);

  /*
   * تفعيل أو تعطيل الحساب.
   */
  const mutateStatus = async (
    user: AdminUserSummary,
    active: boolean,
  ) => {
    setBusy(true);
    setError("");

    try {
      await setAdminUserActive(
        user.id,
        active,
      );

      setNotice(
        t(
          active
            ? "admin.users.activated"
            : "admin.users.deactivated",
        ),
      );

      setConfirm(null);
      setSelected(null);

      await load();
    } catch (exception) {
      setError(
        exception instanceof ApiError
          ? exception.message
          : t("admin.users.actionError"),
      );
    } finally {
      setBusy(false);
    }
  };

  /*
   * حذف الحساب.
   */
  const removeUser = async (
    user: AdminUserSummary,
  ) => {
    setBusy(true);
    setError("");

    try {
      await deleteAdminUser(user.id);

      setNotice(
        lang === "ar"
          ? "تم حذف الحساب بنجاح."
          : "Account deleted successfully.",
      );

      setDeleteConfirm(null);
      setSelected(null);

      await load();
    } catch (exception) {
      setError(
        exception instanceof ApiError
          ? exception.message
          : t("admin.users.actionError"),
      );
    } finally {
      setBusy(false);
    }
  };

  if (!isAdmin) {
    return null;
  }

  const title =
    section && TITLE_KEYS[section]
      ? t(TITLE_KEYS[section])
      : t("admin.users.allTitle");

  return (
    <div className="page admin-page admin-users-page">
      <header className="admin-users-head">
        <div>
          <span className="eyebrow">
            {t("admin.users.eyebrow")}
          </span>

          <h1>{title}</h1>

          <p>
            {t("admin.users.subtitle")}
          </p>
        </div>

        {!section && (
          <button
            className="btn btn--gold"
            type="button"
            onClick={() =>
              setCreating(true)
            }
          >
            {t("admin.users.createUser")}
          </button>
        )}
      </header>

      {notice && (
        <div
          className="admin-users-notice"
          role="status"
        >
          <span>{notice}</span>

          <button
            type="button"
            onClick={() =>
              setNotice("")
            }
            aria-label={
              t("common.close")
            }
          >
            ×
          </button>
        </div>
      )}

      {error && (
        <div
          className="
            admin-users-notice
            admin-users-notice--error
          "
          role="alert"
        >
          <span>{error}</span>

          <button
            type="button"
            onClick={() =>
              void load()
            }
          >
            {t("common.retry")}
          </button>
        </div>
      )}

      <section
        className="admin-users-summary"
        aria-label={
          t("admin.users.summary")
        }
      >
        {(
          [
            "total",
            ...ROLES,
          ] as const
        ).map((key) => (
          <div key={key}>
            <span>
              {t(
                key === "total"
                  ? "admin.accounts.total"
                  : ROLE_KEYS[key],
              )}
            </span>

            <strong>
              {loading
                ? "…"
                : counts[key]}
            </strong>
          </div>
        ))}
      </section>

      <section className="admin-users-workspace">
        <div
          className={
            `admin-users-toolbar ${
              routeRole
                ? "admin-users-toolbar--role"
                : ""
            }`
          }
        >
          <label className="admin-users-search">
            <span>
              {t("admin.users.search")}
            </span>

            <input
              value={query}
              onChange={(event) =>
                setQuery(
                  event.target.value,
                )
              }
              placeholder={
                t(
                  "admin.users.searchPlaceholder",
                )
              }
            />
          </label>

          {!routeRole && (
            <label>
              <span>
                {t(
                  "admin.users.roleFilter",
                )}
              </span>

              <select
                value={role}
                onChange={(event) =>
                  setRole(
                    event.target.value as
                      | Role
                      | "all",
                  )
                }
              >
                <option value="all">
                  {t(
                    "admin.users.allRoles",
                  )}
                </option>

                {ROLES.map(
                  (roleItem) => (
                    <option
                      key={roleItem}
                      value={roleItem}
                    >
                      {t(
                        ROLE_KEYS[
                          roleItem
                        ],
                      )}
                    </option>
                  ),
                )}
              </select>
            </label>
          )}

          <label>
            <span>
              {t(
                "admin.users.statusFilter",
              )}
            </span>

            <select
              value={status}
              onChange={(event) =>
                setStatus(
                  event.target.value,
                )
              }
            >
              <option value="all">
                {t(
                  "admin.users.allStatuses",
                )}
              </option>

              {[
                "active",
                "inactive",
                "suspended",
              ].map(
                (statusItem) => (
                  <option
                    key={statusItem}
                    value={statusItem}
                  >
                    {t(
                      statusKey(
                        statusItem,
                      ),
                    )}
                  </option>
                ),
              )}
            </select>
          </label>

          <span className="admin-users-result-count">
            <b>{visible.length}</b>

            <span>
              {t(
                visible.length === 1
                  ? "admin.users.result"
                  : "admin.users.results",
              )}
            </span>
          </span>
        </div>

        {loading ? (
          <div className="admin-users-state">
            {t("common.loading")}
          </div>
        ) : users.length === 0 ? (
          <div className="admin-users-state">
            <strong>
              {t("admin.users.empty")}
            </strong>
          </div>
        ) : visible.length === 0 ? (
          <div className="admin-users-state">
            <strong>
              {t(
                "admin.users.noMatches",
              )}
            </strong>

            <span>
              {t(
                "admin.users.noMatchesHelp",
              )}
            </span>
          </div>
        ) : (
          <div className="admin-users-table">
            <div className="admin-users-table__head">
              <span>
                {t("admin.users.user")}
              </span>

              <span>
                {t("admin.users.roles")}
              </span>

              <span>
                {t("admin.users.status")}
              </span>

              <span>
                {t(
                  "admin.users.language",
                )}
              </span>

              <span>
                {t("admin.users.joined")}
              </span>

              <span>
                {t(
                  "admin.users.actions",
                )}
              </span>
            </div>

            <ul>
              {visible.map((user) => (
                <li key={user.id}>
                  <div className="admin-users-person">
                    <i>
                      {initials(
                        user.full_name,
                      )}
                    </i>

                    <span>
                      <strong>
                        {user.full_name}
                      </strong>

                      <small>
                        {user.email ||
                          user.phone ||
                          "—"}
                      </small>
                    </span>
                  </div>

                  <div
                    data-label={
                      t(
                        "admin.users.roles",
                      )
                    }
                    className="admin-users-roles"
                  >
                    {user.roles.map(
                      (roleItem) => (
                        <span
                          key={roleItem}
                        >
                          {t(
                            ROLE_KEYS[
                              roleItem
                            ] ||
                              "role.clinician",
                          )}
                        </span>
                      ),
                    )}
                  </div>

                  <div
                    data-label={
                      t(
                        "admin.users.status",
                      )
                    }
                  >
                    <span
                      className={
                        `admin-user-status admin-user-status--${user.status}`
                      }
                    >
                      {t(
                        statusKey(
                          user.status,
                        ),
                      )}
                    </span>
                  </div>

                  <div
                    data-label={
                      t(
                        "admin.users.language",
                      )
                    }
                    className="admin-users-language"
                  >
                    {user.preferred_language
                      .toUpperCase()}
                  </div>

                  <time
                    data-label={
                      t(
                        "admin.users.joined",
                      )
                    }
                    dateTime={
                      user.created_at
                    }
                  >
                    {formatDateTime(
                      user.created_at,
                    )}
                  </time>

                  <div
                    className="admin-user-actions"
                    ref={
                      menu === user.id
                        ? menuRef
                        : undefined
                    }
                  >
                    <button
                      type="button"
                      onClick={() =>
                        setMenu(
                          menu === user.id
                            ? null
                            : user.id,
                        )
                      }
                      aria-label={
                        t(
                          "admin.users.actions",
                        )
                      }
                      aria-expanded={
                        menu === user.id
                      }
                    >
                      •••
                    </button>

                    {menu === user.id && (
                      <div className="admin-user-menu">
                        <button
                          type="button"
                          onClick={() => {
                            setSelected(user);
                            setEditing(false);
                            setMenu(null);
                          }}
                        >
                          {t(
                            "admin.users.viewDetails",
                          )}
                        </button>

                        <button
                          type="button"
                          onClick={() => {
                            setSelected(user);
                            setEditing(true);
                            setMenu(null);
                          }}
                        >
                          {t(
                            "admin.users.edit",
                          )}
                        </button>

                        {user.id !==
                          currentUser?.id && (
                          <>
                            <button
                              type="button"
                              onClick={() => {
                                if (
                                  user.status ===
                                  "active"
                                ) {
                                  setConfirm(
                                    user,
                                  );
                                } else {
                                  void mutateStatus(
                                    user,
                                    true,
                                  );
                                }

                                setMenu(null);
                              }}
                            >
                              {t(
                                user.status ===
                                  "active"
                                  ? "admin.users.deactivate"
                                  : "admin.users.activate",
                              )}
                            </button>

                            <button
                              className="admin-user-menu__delete"
                              type="button"
                              onClick={() => {
                                setDeleteConfirm(
                                  user,
                                );
                                setMenu(null);
                              }}
                            >
                              {lang === "ar"
                                ? "حذف الحساب"
                                : "Delete account"}
                            </button>
                          </>
                        )}
                      </div>
                    )}
                  </div>
                </li>
              ))}
            </ul>
          </div>
        )}
      </section>

      {selected && (
        <UserDialog
          user={selected}
          editing={editing}
          roles={roles}
          busy={busy}
          onClose={() =>
            setSelected(null)
          }
          onEdit={() =>
            setEditing(true)
          }
          onSave={async (payload) => {
            setBusy(true);
            setError("");

            try {
              await updateAdminUser(
                selected.id,
                payload,
              );

              setNotice(
                t(
                  "admin.users.updated",
                ),
              );

              setSelected(null);

              await load();
            } catch (exception) {
              setError(
                exception instanceof
                  ApiError
                  ? exception.message
                  : t(
                      "admin.users.actionError",
                    ),
              );
            } finally {
              setBusy(false);
            }
          }}
        />
      )}

      {creating && (
        <CreateUserDialog
          roles={roles}
          busy={busy}
          onClose={() =>
            setCreating(false)
          }
          onCreate={async (
            payload,
          ) => {
            setBusy(true);
            setError("");

            try {
              await createAdminUser(
                payload,
              );

              setNotice(
                t(
                  "admin.users.createdSuccess",
                ),
              );

              setCreating(false);

              await load();
            } catch (exception) {
              setError(
                exception instanceof
                  ApiError
                  ? exception.message
                  : t(
                      "admin.users.createError",
                    ),
              );
            } finally {
              setBusy(false);
            }
          }}
        />
      )}

      {confirm && (
        <div className="admin-modal-backdrop">
          <div
            className="admin-confirm"
            role="dialog"
            aria-modal="true"
          >
            <span className="eyebrow">
              {t(
                "admin.users.confirmAction",
              )}
            </span>

            <h2>
              {t(
                "admin.users.deactivateTitle",
              )}
            </h2>

            <p>
              {t(
                "admin.users.deactivateWarning",
              )}
            </p>

            <div>
              <strong>
                {confirm.full_name}
              </strong>

              <small>
                {confirm.email ||
                  confirm.phone}
              </small>

              <span>
                {confirm.roles
                  .map((roleItem) =>
                    t(
                      ROLE_KEYS[
                        roleItem
                      ] ||
                        "role.clinician",
                    ),
                  )
                  .join(", ")}
              </span>
            </div>

            <footer>
              <button
                className="btn btn--ghost"
                type="button"
                disabled={busy}
                onClick={() =>
                  setConfirm(null)
                }
              >
                {t("common.cancel")}
              </button>

              <button
                className="btn admin-danger-btn"
                type="button"
                disabled={busy}
                onClick={() =>
                  void mutateStatus(
                    confirm,
                    false,
                  )
                }
              >
                {busy
                  ? t("common.loading")
                  : t(
                      "admin.users.deactivate",
                    )}
              </button>
            </footer>
          </div>
        </div>
      )}

      {deleteConfirm && (
        <div className="admin-modal-backdrop">
          <div
            className="admin-confirm"
            role="dialog"
            aria-modal="true"
          >
            <span className="eyebrow">
              {lang === "ar"
                ? "إزالة الحساب"
                : "Remove account"}
            </span>

            <h2>
              {lang === "ar"
                ? "هل تريدين حذف هذا الحساب؟"
                : "Delete this account?"}
            </h2>

            <p>
              {lang === "ar"
                ? "الحذف نهائي. إذا كان الحساب مرتبطًا ببيانات طبية سيُمنع الحذف ويمكنك تعطيله بدلًا منه."
                : "Deletion is permanent. If related medical data exists, deletion is blocked and you can deactivate it instead."}
            </p>

            <div>
              <strong>
                {deleteConfirm.full_name}
              </strong>

              <small>
                {deleteConfirm.email ||
                  deleteConfirm.phone}
              </small>

              <span>
                {deleteConfirm.roles
                  .map((roleItem) =>
                    t(
                      ROLE_KEYS[
                        roleItem
                      ] ||
                        "role.clinician",
                    ),
                  )
                  .join(", ")}
              </span>
            </div>

            <footer>
              <button
                className="btn btn--ghost"
                type="button"
                disabled={busy}
                onClick={() =>
                  setDeleteConfirm(null)
                }
              >
                {t("common.cancel")}
              </button>

              <button
                className="btn admin-danger-btn"
                type="button"
                disabled={busy}
                onClick={() =>
                  void removeUser(
                    deleteConfirm,
                  )
                }
              >
                {busy
                  ? t("common.loading")
                  : lang === "ar"
                    ? "حذف الحساب"
                    : "Delete account"}
              </button>
            </footer>
          </div>
        </div>
      )}
    </div>
  );
}

interface CreateUserDialogProps {
  roles: AdminRole[];
  busy: boolean;
  onClose: () => void;
  onCreate: (
    payload: AdminUserCreate,
  ) => Promise<void>;
}

function CreateUserDialog({
  roles,
  busy,
  onClose,
  onCreate,
}: CreateUserDialogProps) {
 const {
  t,
  lang,
} = useI18n();

  const [
    error,
    setError,
  ] = useState("");

  const [
    form,
    setForm,
  ] = useState<AdminUserCreate>({
    full_name: "",
    email: "",
    phone: "",
    password: "",
    preferred_language: "ar",
    status: "active",
    roles: [],
  });

  const set = <
    Key extends keyof AdminUserCreate,
  >(
    key: Key,
    value: AdminUserCreate[Key],
  ) => {
    setForm((current) => ({
      ...current,
      [key]: value,
    }));
  };

  const submit = (
    event: React.FormEvent,
  ) => {
    event.preventDefault();

    setError("");

    if (
      !form.email?.trim() &&
      !form.phone?.trim()
    ) {
      setError(
        t(
          "admin.users.identifierRequired",
        ),
      );

      return;
    }

    if (form.password.length < 8) {
      setError(
        t(
          "admin.users.passwordLength",
        ),
      );

      return;
    }

 if (form.roles.length !== 1) {
  setError(
    lang === "ar"
      ? "يرجى اختيار دور واحد فقط: دكتور أو معالج أو عائلة."
      : "Please choose exactly one role: doctor, therapist, or family.",
  );

  return;
}

    void onCreate({
      ...form,

      full_name:
        form.full_name.trim(),

      email:
        form.email?.trim() ||
        null,

      phone:
        form.phone?.trim() ||
        null,
    });
  };

  return (
    <div
      className="admin-modal-backdrop"
      onMouseDown={(event) => {
        if (
          event.target ===
            event.currentTarget &&
          !busy
        ) {
          onClose();
        }
      }}
    >
      <div
        className="
          admin-user-dialog
          admin-create-user
        "
        role="dialog"
        aria-modal="true"
      >
        <header>
          <div>
            <span className="eyebrow">
              {t(
                "admin.users.createAccount",
              )}
            </span>

            <h2>
              {t(
                "admin.users.createUser",
              )}
            </h2>
          </div>

          <button
            type="button"
            disabled={busy}
            onClick={onClose}
            aria-label={
              t("common.close")
            }
          >
            ×
          </button>
        </header>

        <form onSubmit={submit}>
          {error && (
            <div
              className="admin-create-user__error"
              role="alert"
            >
              {error}
            </div>
          )}

          <label>
            {t(
              "admin.users.fullName",
            )}

            <input
              required
              maxLength={255}
              value={form.full_name}
              onChange={(event) =>
                set(
                  "full_name",
                  event.target.value,
                )
              }
            />
          </label>

          <label>
            {t("admin.users.email")}

            <input
              required
              type="email"
              maxLength={255}
              value={form.email || ""}
              onChange={(event) =>
                set(
                  "email",
                  event.target.value,
                )
              }
            />
          </label>

          <label>
            {t("admin.users.phone")}

            <input
              maxLength={50}
              value={form.phone || ""}
              onChange={(event) =>
                set(
                  "phone",
                  event.target.value,
                )
              }
            />
          </label>

          <label>
            {t(
              "admin.users.password",
            )}

            <input
              required
              type="password"
              minLength={8}
              maxLength={128}
              value={form.password}
              onChange={(event) =>
                set(
                  "password",
                  event.target.value,
                )
              }
            />

            <small>
              {t(
                "admin.users.passwordHelp",
              )}
            </small>
          </label>

          <label>
            {t(
              "admin.users.language",
            )}

            <select
              value={
                form.preferred_language
              }
              onChange={(event) =>
                set(
                  "preferred_language",
                  event.target.value,
                )
              }
            >
              {[
                "ar",
                "en",
                "fr",
                "es",
                "de",
              ].map((language) => (
                <option
                  key={language}
                  value={language}
                >
                  {language.toUpperCase()}
                </option>
              ))}
            </select>
          </label>

          <label>
            {t("admin.users.status")}

            <select
              value={form.status}
              onChange={(event) =>
                set(
                  "status",
                  event.target.value,
                )
              }
            >
              {[
                "active",
                "inactive",
                "suspended",
              ].map((statusItem) => (
                <option
                  key={statusItem}
                  value={statusItem}
                >
                  {t(
                    statusKey(
                      statusItem,
                    ),
                  )}
                </option>
              ))}
            </select>
          </label>

          <fieldset>
            <legend>
              {t("admin.users.roles")}
            </legend>

            {roles.map((roleItem) => (
              <label key={roleItem.id}>
                <input
                  type="radio"
                  name="new-user-role"
                  checked={
                    form.roles[0] ===
                    roleItem.name
                  }
                  onChange={() =>
                    set(
                      "roles",
                      [roleItem.name],
                    )
                  }
                />

                {t(
                  ROLE_KEYS[
                    roleItem.name
                  ] ||
                    "role.clinician",
                )}
              </label>
            ))}
          </fieldset>

          <footer>
            <button
              className="btn btn--ghost"
              type="button"
              disabled={busy}
              onClick={onClose}
            >
              {t("common.cancel")}
            </button>

            <button
              className="btn btn--gold"
              disabled={busy}
            >
              {busy
                ? t("common.loading")
                : t(
                    "admin.users.createAccount",
                  )}
            </button>
          </footer>
        </form>
      </div>
    </div>
  );
}

interface UserDialogProps {
  user: AdminUserSummary;
  editing: boolean;
  roles: AdminRole[];
  busy: boolean;
  onClose: () => void;
  onEdit: () => void;
  onSave: (
    payload: Parameters<
      typeof updateAdminUser
    >[1],
  ) => Promise<void>;
}

function UserDialog({
  user,
  editing,
  roles,
  busy,
  onClose,
  onEdit,
  onSave,
}: UserDialogProps) {
  const { t } = useI18n();

  const [
    form,
    setForm,
  ] = useState({
    full_name: user.full_name,
    email: user.email || "",
    phone: user.phone || "",
    preferred_language:
      user.preferred_language,
    status: user.status,
    roles: [...user.roles],
  });

  const set = (
    key: string,
    value: string | string[],
  ) => {
    setForm((current) => ({
      ...current,
      [key]: value,
    }));
  };

  return (
    <div
      className="admin-modal-backdrop"
      onMouseDown={(event) => {
        if (
          event.target ===
          event.currentTarget
        ) {
          onClose();
        }
      }}
    >
      <div
        className="admin-user-dialog"
        role="dialog"
        aria-modal="true"
      >
        <header>
          <div>
            <span className="eyebrow">
              {t(
                editing
                  ? "admin.users.edit"
                  : "admin.users.details",
              )}
            </span>

            <h2>{user.full_name}</h2>
          </div>

          <button
            type="button"
            onClick={onClose}
            aria-label={
              t("common.close")
            }
          >
            ×
          </button>
        </header>

        {editing ? (
          <form
            onSubmit={(event) => {
              event.preventDefault();

              void onSave({
                ...form,

                email:
                  form.email || null,

                phone:
                  form.phone || null,
              });
            }}
          >
            <label>
              {t(
                "admin.users.fullName",
              )}

              <input
                required
                value={form.full_name}
                onChange={(event) =>
                  set(
                    "full_name",
                    event.target.value,
                  )
                }
              />
            </label>

            <label>
              {t(
                "admin.users.email",
              )}

              <input
                type="email"
                value={form.email}
                onChange={(event) =>
                  set(
                    "email",
                    event.target.value,
                  )
                }
              />
            </label>

            <label>
              {t(
                "admin.users.phone",
              )}

              <input
                value={form.phone}
                onChange={(event) =>
                  set(
                    "phone",
                    event.target.value,
                  )
                }
              />
            </label>

            <label>
              {t(
                "admin.users.language",
              )}

              <select
                value={
                  form.preferred_language
                }
                onChange={(event) =>
                  set(
                    "preferred_language",
                    event.target.value,
                  )
                }
              >
                {[
                  "ar",
                  "en",
                  "fr",
                  "es",
                  "de",
                ].map((language) => (
                  <option
                    key={language}
                    value={language}
                  >
                    {language.toUpperCase()}
                  </option>
                ))}
              </select>
            </label>

            <label>
              {t(
                "admin.users.status",
              )}

              <select
                value={form.status}
                onChange={(event) =>
                  set(
                    "status",
                    event.target.value,
                  )
                }
              >
                {[
                  "active",
                  "inactive",
                  "suspended",
                ].map((statusItem) => (
                  <option
                    key={statusItem}
                    value={statusItem}
                  >
                    {t(
                      statusKey(
                        statusItem,
                      ),
                    )}
                  </option>
                ))}
              </select>
            </label>

            <fieldset>
              <legend>
                {t(
                  "admin.users.roles",
                )}
              </legend>

              {roles.map((roleItem) => (
                <label key={roleItem.id}>
                  <input
                    type="checkbox"
                    checked={
                      form.roles.includes(
                        roleItem.name,
                      )
                    }
                    onChange={(event) =>
                      set(
                        "roles",
                        event.target
                          .checked
                          ? [
                              ...form.roles,
                              roleItem.name,
                            ]
                          : form.roles.filter(
                              (item) =>
                                item !==
                                roleItem.name,
                            ),
                      )
                    }
                  />

                  {t(
                    ROLE_KEYS[
                      roleItem.name
                    ] ||
                      "role.clinician",
                  )}
                </label>
              ))}
            </fieldset>

            <footer>
              <button
                className="btn btn--ghost"
                type="button"
                onClick={onClose}
              >
                {t("common.cancel")}
              </button>

              <button
                className="btn btn--gold"
                disabled={busy}
              >
                {busy
                  ? t("common.loading")
                  : t(
                      "admin.users.save",
                    )}
              </button>
            </footer>
          </form>
        ) : (
          <>
            <dl>
              <div>
                <dt>
                  {t(
                    "admin.users.email",
                  )}
                </dt>

                <dd>
                  {user.email || "—"}
                </dd>
              </div>

              <div>
                <dt>
                  {t(
                    "admin.users.phone",
                  )}
                </dt>

                <dd>
                  {user.phone || "—"}
                </dd>
              </div>

              <div>
                <dt>
                  {t(
                    "admin.users.roles",
                  )}
                </dt>

                <dd>
                  {user.roles
                    .map((roleItem) =>
                      t(
                        ROLE_KEYS[
                          roleItem
                        ] ||
                          "role.clinician",
                      ),
                    )
                    .join(", ") ||
                    "—"}
                </dd>
              </div>

              <div>
                <dt>
                  {t(
                    "admin.users.status",
                  )}
                </dt>

                <dd>
                  {t(
                    statusKey(
                      user.status,
                    ),
                  )}
                </dd>
              </div>

              <div>
                <dt>
                  {t(
                    "admin.users.language",
                  )}
                </dt>

                <dd>
                  {user.preferred_language
                    .toUpperCase()}
                </dd>
              </div>

              <div>
                <dt>
                  {t(
                    "admin.users.created",
                  )}
                </dt>

                <dd>
                  {formatDateTime(
                    user.created_at,
                  )}
                </dd>
              </div>

              <div>
                <dt>
                  {t(
                    "admin.users.updatedAt",
                  )}
                </dt>

                <dd>
                  {formatDateTime(
                    user.updated_at,
                  )}
                </dd>
              </div>
            </dl>

            <footer>
              <button
                className="btn btn--ghost"
                type="button"
                onClick={onClose}
              >
                {t("common.close")}
              </button>

              <button
                className="btn btn--gold"
                type="button"
                onClick={onEdit}
              >
                {t("admin.users.edit")}
              </button>
            </footer>
          </>
        )}
      </div>
    </div>
  );
}