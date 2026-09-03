import { webAccountApi } from "./webAccountClient";
import type {
  AccessRequest,
  AccessRequestListResponse,
} from "../types";

export type AccessRequestStatus =
  | "pending"
  | "reviewed"
  | "accepted"
  | "declined";

export interface AccessRequestUpdate {
  status?: AccessRequestStatus;
  admin_note?: string | null;
}

export function listAccessRequests(
  status?: AccessRequestStatus,
): Promise<AccessRequestListResponse> {
  const query = status
    ? `?status=${encodeURIComponent(status)}`
    : "";

  return webAccountApi<AccessRequestListResponse>(
    `access_requests.php${query}`,
  );
}

export function updateAccessRequest(
  id: string,
  payload: AccessRequestUpdate,
): Promise<AccessRequest> {
  return webAccountApi<AccessRequest>(
    `access_requests.php?id=${encodeURIComponent(id)}`,
    {
      method: "PATCH",
      body: JSON.stringify(payload),
    },
  );
}