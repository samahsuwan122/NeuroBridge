import { api } from "./client";

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

export function listAdminUsers(
  limit = 200,
  offset = 0,
): Promise<AdminUserListResponse> {
  return api<AdminUserListResponse>(`/admin/users?limit=${limit}&offset=${offset}`);
}

export async function listAllAdminUsers(): Promise<AdminUserSummary[]> {
  const first = await listAdminUsers(200, 0);
  const pages = [first];
  for (let offset = first.limit; offset < first.total; offset += first.limit) {
    pages.push(await listAdminUsers(200, offset));
  }
  const users = [...new Map(pages.flatMap((page) => page.users).map((user) => [user.id, user])).values()];
  if (users.length !== first.total) throw new Error("Incomplete Admin user listing");
  return users;
}

export type AdminUserUpdate = Partial<Pick<AdminUserSummary,
  "full_name" | "email" | "phone" | "preferred_language" | "status" | "medical_center_id" | "roles"
>>;

export interface AdminRole { id: string; name: string; description?: string | null; }

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

export function createAdminUser(payload: AdminUserCreate): Promise<AdminUserSummary> {
  return api<AdminUserSummary>("/admin/users", { method: "POST", body: JSON.stringify(payload) });
}

export function updateAdminUser(id: string, payload: AdminUserUpdate): Promise<AdminUserSummary> {
  return api<AdminUserSummary>(`/admin/users/${id}`, { method: "PUT", body: JSON.stringify(payload) });
}

export function setAdminUserActive(id: string, active: boolean): Promise<{ success: boolean; message: string }> {
  return api(`/admin/users/${id}/${active ? "activate" : "deactivate"}`, { method: "POST" });
}

export function listAdminRoles(): Promise<AdminRole[]> {
  return api<AdminRole[]>("/admin/roles");
}
