const RAW_BASE =
  (import.meta.env.VITE_API_BASE_URL as string | undefined) ??
  "https://toyoraljana.com/api_doctor";

export const API_ORIGIN =
  RAW_BASE.replace(/\/+$/, "");

const TOKEN_KEY = "nb_dashboard_token";

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

export function setToken(
  token: string | null,
): void {
  if (token) {
    localStorage.setItem(TOKEN_KEY, token);
  } else {
    localStorage.removeItem(TOKEN_KEY);
  }
}

export class ApiError extends Error {
  status: number;

  constructor(
    status: number,
    message: string,
  ) {
    super(message);
    this.name = "ApiError";
    this.status = status;
  }
}

function buildApiUrl(path: string): string {
  const cleanPath = path.startsWith("/")
    ? path
    : `/${path}`;

  /*
   * إذا كان المسار ملف PHP نرسله مباشرة.
   */
  if (cleanPath.endsWith(".php")) {
    return `${API_ORIGIN}${cleanPath}`;
  }

  /*
   * دعم المسارات القديمة الخاصة بـ /api/v1.
   */
  return `${API_ORIGIN}/api/v1${cleanPath}`;
}

export async function api<T>(
  path: string,
  options: RequestInit = {},
): Promise<T> {
  const headers =
    new Headers(options.headers);

  const token = getToken();

  if (token) {
    headers.set(
      "Authorization",
      `Bearer ${token}`,
    );
  }

  headers.set("Accept", "application/json");

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

  const url = buildApiUrl(path);

  let response: Response;

  try {
    response = await fetch(url, {
      ...options,
      headers,
    });
  } catch {
    throw new ApiError(
      0,
      `تعذر الاتصال بالخادم: ${url}`,
    );
  }

  const responseText =
    await response.text();

  let data: unknown = null;

  if (responseText.trim() !== "") {
    try {
      data = JSON.parse(responseText);
    } catch {
      throw new ApiError(
        response.status,
        `الخادم لم يُرجع JSON صحيحًا. الرابط: ${url}`,
      );
    }
  }

  if (!response.ok) {
    let message =
      `فشل الطلب (${response.status})`;

    if (
      data &&
      typeof data === "object"
    ) {
      const record =
        data as Record<string, unknown>;

      if (
        typeof record.message === "string"
      ) {
        message = record.message;
      } else if (
        typeof record.detail === "string"
      ) {
        message = record.detail;
      }
    }

    if (
      response.status === 401 ||
      response.status === 403
    ) {
      setToken(null);
    }

    throw new ApiError(
      response.status,
      message,
    );
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return data as T;
}

export function resolveMediaUrl(
  url?: string | null,
): string | null {
  if (!url) {
    return null;
  }

  if (
    /^(?:https?:\/\/|blob:|data:)/i.test(url)
  ) {
    return url;
  }

  return `${API_ORIGIN}${
    url.startsWith("/") ? "" : "/"
  }${url}`;
}