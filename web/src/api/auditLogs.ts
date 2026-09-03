import { webAccountApi } from "./webAccountClient";

export interface AuditLog {
  id: string;
  admin_account_id: string;
  admin_name: string;
  action: string;
  target_type?: string | null;
  target_id?: string | null;
  target_name?: string | null;
  details?: Record<string, unknown> | null;
  ip_address?: string | null;
  created_at: string;
}

export interface AuditLogResponse {
  success: boolean;
  total: number;
  limit: number;
  offset: number;
  logs: AuditLog[];
  actions: string[];
  admins: { id: string; name: string }[];
}

export interface AuditLogFilters {
  search?: string;
  action?: string;
  adminId?: string;
  from?: string;
  to?: string;
  limit?: number;
  offset?: number;
}

export function listAuditLogs(filters: AuditLogFilters = {}): Promise<AuditLogResponse> {
  const query = new URLSearchParams();
  if (filters.search) query.set("search", filters.search);
  if (filters.action) query.set("action", filters.action);
  if (filters.adminId) query.set("admin_id", filters.adminId);
  if (filters.from) query.set("from", filters.from);
  if (filters.to) query.set("to", filters.to);
  query.set("limit", String(filters.limit ?? 20));
  query.set("offset", String(filters.offset ?? 0));
  return webAccountApi<AuditLogResponse>(`audit_logs.php?${query.toString()}`);
}
