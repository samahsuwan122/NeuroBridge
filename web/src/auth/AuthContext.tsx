import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from "react";
import { ApiError, getToken, setToken } from "../api/client";
import type { UserBasic } from "../types";

interface MeResponse {
  user: UserBasic;
  roles: string[];
}

interface LoginResponse {
  access_token: string;
  user: UserBasic;
  roles: string[];
}

interface AuthContextValue {
  user: UserBasic | null;
  roles: string[];
  loading: boolean;
  isClinician: boolean;
  isFamily: boolean;
  isAdmin: boolean;
  login: (
    emailOrPhone: string,
    password: string,
  ) => Promise<string[]>;
  logout: () => void;
}

const WEB_API_BASE =
  (import.meta.env.VITE_WEB_API_BASE_URL as string | undefined) ??
  "https://toyoraljana.com/api_web";

async function webAuthApi<T>(
  endpoint: string,
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
    response = await fetch(
      `${WEB_API_BASE.replace(/\/+$/, "")}/${endpoint.replace(/^\/+/, "")}`,
      {
        ...options,
        headers,
      },
    );
  } catch {
    throw new ApiError(
      0,
      "Cannot reach the server. Is the backend running?",
    );
  }

  let data: unknown = null;

  try {
    data = await response.json();
  } catch {
    // The server returned an empty or non-JSON response.
  }

  if (!response.ok) {
    const message =
      data &&
      typeof data === "object" &&
      "message" in data &&
      typeof data.message === "string"
        ? data.message
        : `Request failed (${response.status}).`;

    throw new ApiError(response.status, message);
  }

  return data as T;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({
  children,
}: {
  children: ReactNode;
}) {
  const [user, setUser] = useState<UserBasic | null>(null);
  const [roles, setRoles] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let active = true;

    void (async () => {
      if (!getToken()) {
        setLoading(false);
        return;
      }

      try {
        const result = await webAuthApi<MeResponse>("me.php");

        if (active) {
          setUser(result.user);
          setRoles(result.roles);
        }
      } catch {
        setToken(null);

        if (active) {
          setUser(null);
          setRoles([]);
        }
      } finally {
        if (active) {
          setLoading(false);
        }
      }
    })();

    return () => {
      active = false;
    };
  }, []);

  const login = useCallback(
    async (
      emailOrPhone: string,
      password: string,
    ) => {
      const result = await webAuthApi<LoginResponse>(
        "login.php",
        {
          method: "POST",
          body: JSON.stringify({
            email_or_phone: emailOrPhone,
            password,
            remember_me: true,
          }),
        },
      );

      setToken(result.access_token);
      setUser(result.user);
      setRoles(result.roles);

      return result.roles;
    },
    [],
  );

  const logout = useCallback(() => {
    void webAuthApi("logout.php", {
      method: "POST",
    }).catch(() => {
      // تسجيل الخروج محليًا حتى لو تعذر الوصول للخادم.
    });

    setToken(null);
    setUser(null);
    setRoles([]);
  }, []);

  const isClinician =
    roles.includes("doctor") ||
    roles.includes("therapist");

  const isFamily = roles.includes("family");
  const isAdmin = roles.includes("admin");

  return (
    <AuthContext.Provider
      value={{
        user,
        roles,
        loading,
        isClinician,
        isFamily,
        isAdmin,
        login,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthContextValue {
  const context = useContext(AuthContext);

  if (!context) {
    throw new Error(
      "useAuth must be used within AuthProvider",
    );
  }

  return context;
}