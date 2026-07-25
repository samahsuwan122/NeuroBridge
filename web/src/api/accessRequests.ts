// Admin API helpers for public access requests.
// Reuses the shared typed `api()` client (bearer token + /api/v1 prefix).
// These endpoints are admin-only on the backend (403 for other roles).

import { api } from "./client";
import type { AccessRequest, AccessRequestListResponse } from "../types";

export type AccessRequestStatus =
  | "pending"
  | "reviewed"
  | "accepted"
  | "declined";

export interface AccessRequestUpdate {
  status?: AccessRequestStatus;
  admin_note?: string | null;
}

/** GET /access-requests — optionally filtered by status (server-side). */
export function listAccessRequests(
  status?: AccessRequestStatus,
): Promise<AccessRequestListResponse> {
  const query = status ? `?status=${encodeURIComponent(status)}` : "";
  return api<AccessRequestListResponse>(`/access-requests${query}`);
}

/** PATCH /access-requests/{id} — update status and/or admin note. */
export function updateAccessRequest(
  id: string,
  payload: AccessRequestUpdate,
): Promise<AccessRequest> {
  return api<AccessRequest>(`/access-requests/${id}`, {
    method: "PATCH",
    body: JSON.stringify(payload),
  });
}
