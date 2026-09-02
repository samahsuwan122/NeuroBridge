import { ApiError, getToken } from "./client";

const RAW_BASE =
  (import.meta.env.VITE_WEB_ACCOUNT_API_URL as
    | string
    | undefined) ??
  "https://toyoraljana.com/api_web";

export async function webAccountApi<T>(
  endpoint: string,
  options: RequestInit = {},
): Promise<T> {
  const headers = new Headers(options.headers);
  const token = getToken();

  if (token) {
    headers.set(
      "Authorization",
      `Bearer ${token}`,
    );
  }

  if (
    options.body &&
    !(options.body instanceof FormData) &&
    !headers.has("Content-Type")
  ) {
    headers.set(
      "Content-Type",
      "application/json",
    );
  }

  const baseUrl = RAW_BASE.replace(/\/+$/, "");
  const cleanEndpoint =
    endpoint.replace(/^\/+/, "");

  let response: Response;

  try {
    response = await fetch(
      `${baseUrl}/${cleanEndpoint}`,
      {
        ...options,
        headers,
      },
    );
  } catch {
    throw new ApiError(
      0,
      "تعذر الاتصال بخادم حسابات الويب",
    );
  }

  let data: unknown = null;

  try {
    data = await response.json();
  } catch {
    data = null;
  }

  if (!response.ok) {
    const message =
      data &&
      typeof data === "object" &&
      "message" in data &&
      typeof data.message === "string"
        ? data.message
        : `فشل الطلب (${response.status})`;

    throw new ApiError(
      response.status,
      message,
    );
  }

  return data as T;
}