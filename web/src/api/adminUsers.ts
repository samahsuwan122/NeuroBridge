import { webAccountApi } from "./webAccountClient";

export interface AdminUserSummary {
  id: string;
  full_name: string;
  email?: string | null;
  phone?: string | null;
  preferred_language: string;
  status: string;
  medical_center_id?: string | null;
  roles: string[];
  created_at: string;
  updated_at: string;
}

export interface AdminUserListResponse {
  success: boolean;
  total: number;
  limit: number;
  offset: number;
  users: AdminUserSummary[];
}

export interface AdminRole {
  id: string;
  name: string;
  description?: string | null;
}

export interface AdminUserCreate {
  full_name: string;
  email?: string | null;
  phone?: string | null;
  password: string;
  preferred_language: string;
  status: string;
  medical_center_id?: string | null;
  roles: string[];
}

export type AdminUserUpdate = Partial<
  Pick<
    AdminUserSummary,
    | "full_name"
    | "email"
    | "phone"
    | "preferred_language"
    | "status"
    | "medical_center_id"
    | "roles"
  >
>;

/*
 * جلب صفحة من المستخدمين من PHP الحقيقي.
 */
export function listAdminUsers(
  limit = 200,
  offset = 0,
): Promise<AdminUserListResponse> {
  const query =
    `admin_users.php?action=list` +
    `&limit=${encodeURIComponent(limit)}` +
    `&offset=${encodeURIComponent(offset)}`;

  return webAccountApi<AdminUserListResponse>(
    query,
  );
}

/*
 * جلب جميع المستخدمين مع دعم pagination.
 */
export async function listAllAdminUsers():
Promise<AdminUserSummary[]> {
  const firstPage = await listAdminUsers(
    200,
    0,
  );

  const pages = [firstPage];

  for (
    let offset = firstPage.limit;
    offset < firstPage.total;
    offset += firstPage.limit
  ) {
    const page = await listAdminUsers(
      firstPage.limit,
      offset,
    );

    pages.push(page);
  }

  const uniqueUsers = new Map<
    string,
    AdminUserSummary
  >();

  for (const page of pages) {
    for (const user of page.users) {
      uniqueUsers.set(user.id, user);
    }
  }

  return [...uniqueUsers.values()];
}

/*
 * جلب الأدوار التي يستطيع الأدمن إنشاءها.
 */
export function listAdminRoles():
Promise<AdminRole[]> {
  return webAccountApi<AdminRole[]>(
    "admin_users.php?action=roles",
  );
}

/*
 * إنشاء مستخدم بواسطة الأدمن.
 */
export function createAdminUser(
  payload: AdminUserCreate,
): Promise<AdminUserSummary> {
  return webAccountApi<AdminUserSummary>(
    "admin_users.php?action=create",
    {
      method: "POST",
      body: JSON.stringify(payload),
    },
  );
}

/*
 * تعديل حساب.
 */
export function updateAdminUser(
  id: string,
  payload: AdminUserUpdate,
): Promise<AdminUserSummary> {
  return webAccountApi<AdminUserSummary>(
    `admin_users.php?action=update&id=${encodeURIComponent(id)}`,
    {
      method: "PUT",
      body: JSON.stringify(payload),
    },
  );
}

/*
 * تفعيل أو تعطيل حساب.
 */
export function setAdminUserActive(
  id: string,
  active: boolean,
): Promise<{
  success: boolean;
  message: string;
}> {
  const action = active
    ? "activate"
    : "deactivate";

  return webAccountApi<{
    success: boolean;
    message: string;
  }>(
    `admin_users.php?action=${action}&id=${encodeURIComponent(id)}`,
    {
      method: "POST",
    },
  );
}

/*
 * حذف حساب بواسطة الأدمن.
 */
export function deleteAdminUser(
  id: string,
): Promise<{
  success: boolean;
  message: string;
}> {
  return webAccountApi<{
    success: boolean;
    message: string;
  }>(
    `admin_users.php?action=delete&id=${encodeURIComponent(id)}`,
    {
      method: "DELETE",
    },
  );
}