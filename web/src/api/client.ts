// استبدلي محتوى: web/src/api/client.ts بهذا الملف.
// لا يحتاج إلى .htaccess ولا إلى /api/v1.

const RAW_BASE =
  (import.meta.env.VITE_API_BASE_URL as string | undefined) ??
  "https://toyoraljana.com/api_doctor";

export const API_ORIGIN = RAW_BASE.replace(/\/+$/, "");

const TOKEN_KEY = "nb_dashboard_token";

export function getToken(): string | null {
  return localStorage.getItem(TOKEN_KEY);
}

export function setToken(token: string | null): void {
  if (token) {
    localStorage.setItem(TOKEN_KEY, token);
  } else {
    localStorage.removeItem(TOKEN_KEY);
  }
}

export class ApiError extends Error {
  status: number;

  constructor(status: number, message: string) {
    super(message);
    this.name = "ApiError";
    this.status = status;
  }
}

function buildApiUrl(path: string): string {
  const separatorIndex = path.indexOf("?");

  const route =
    separatorIndex >= 0
      ? path.slice(0, separatorIndex)
      : path;

  const query =
    separatorIndex >= 0
      ? path.slice(separatorIndex + 1)
      : "";

  const parameters = new URLSearchParams(query);
  let file = "";

  let match = route.match(/^\/patients\/(\d+)$/);
  if (match) {
    file = "patients.php";
    parameters.set("id", match[1]);
  } else if ((match = route.match(/^\/patients\/(\d+)\/checkin$/))) {
    file = "patient_checkin.php";
    parameters.set("patient_id", match[1]);
  } else if (route === "/patients") {
    file = "patients.php";
  } else if (route === "/games/results") {
    file = "game_results.php";
  } else if (route === "/games") {
    file = "games.php";
  } else if ((match = route.match(/^\/appointments\/(\d+)\/status$/))) {
    file = "appointments.php";
    parameters.set("id", match[1]);
    parameters.set("action", "status");
  } else if (route === "/appointments") {
    file = "appointments.php";
  } else if (route === "/activities/templates") {
    file = "activities.php";
    parameters.set("action", "templates");
  } else if ((match = route.match(/^\/activities\/patient\/(\d+)$/))) {
    file = "activities.php";
    parameters.set("action", "list");
    parameters.set("patient_id", match[1]);
  } else if (route === "/activities/assign") {
    file = "activities.php";
    parameters.set("action", "assign");
  } else if (route === "/activities/generate-ai") {
    file = "ai_activity.php";
  } else if (route === "/ai-chat/history") {
    file = "ai_chat.php";
    parameters.set("action", "history");
  } else if (route === "/ai-chat/message") {
    file = "ai_chat.php";
    parameters.set("action", "message");
  } else if ((match = route.match(/^\/goals\/patient\/(\d+)$/))) {
    file = "goals.php";
    parameters.set("action", "list");
    parameters.set("patient_id", match[1]);
  } else if ((match = route.match(/^\/goals\/(\d+)$/))) {
    file = "goals.php";
    parameters.set("action", "update");
    parameters.set("id", match[1]);
  } else if (route === "/goals") {
    file = "goals.php";
    parameters.set("action", "create");
  } else if ((match = route.match(/^\/providers\/(\d+)\/availability$/))) {
    file = "provider_availability.php";
    parameters.set("provider_id", match[1]);
  } else if ((match = route.match(/^\/providers\/(\d+)$/))) {
    file = "providers.php";
    parameters.set("id", match[1]);
  } else if (route === "/providers") {
    file = "providers.php";
  } else if ((match = route.match(/^\/provider-messages\/(\d+)\/read$/))) {
    file = "provider_messages.php";
    parameters.set("id", match[1]);
    parameters.set("action", "read");
  } else if ((match = route.match(/^\/provider-messages\/(\d+)\/replies$/))) {
    file = "provider_messages.php";
    parameters.set("id", match[1]);
    parameters.set("action", "reply");
  } else if ((match = route.match(/^\/provider-messages\/(\d+)$/))) {
    file = "provider_messages.php";
    parameters.set("id", match[1]);
  } else if (route === "/provider-messages") {
    file = "provider_messages.php";
  } else if (route === "/memories") {
    file = "memories.php";
  } else if (route === "/encouragements") {
    file = "encouragements.php";
  } else {
    throw new ApiError(0, `لا يوجد ملف API للمسار: ${route}`);
  }

  const queryString = parameters.toString();
  return `${API_ORIGIN}/${file}${queryString ? `?${queryString}` : ""}`;
}

export async function api<T>(
  path: string,
  options: RequestInit = {},
): Promise<T> {
  const headers = new Headers(options.headers);
  const token = getToken();

  if (token) {
    headers.set("Authorization", `Bearer ${token}`);
  }

  if (
    options.body &&
    !(options.body instanceof FormData) &&
    !headers.has("Content-Type")
  ) {
    headers.set("Content-Type", "application/json");
  }

  let response: Response;

  try {
    response = await fetch(buildApiUrl(path), {
      ...options,
      headers,
    });
  } catch {
    throw new ApiError(
      0,
      "تعذر الاتصال بالخادم. تحققي من رابط API والإنترنت.",
    );
  }

  if (!response.ok) {
    let message = `فشل الطلب (${response.status}).`;

    try {
      const data = await response.json();

      if (typeof data?.detail === "string") {
        message = data.detail;
      } else if (typeof data?.message === "string") {
        message = data.message;
      }
    } catch {
      // الاستجابة ليست JSON.
    }

    throw new ApiError(response.status, message);
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return (await response.json()) as T;
}

export function resolveMediaUrl(
  url?: string | null,
): string | null {
  if (!url) return null;

  if (/^(?:https?:\/\/|blob:|data:)/i.test(url)) {
    return url;
  }

  return `${API_ORIGIN}${url.startsWith("/") ? "" : "/"}${url}`;
}