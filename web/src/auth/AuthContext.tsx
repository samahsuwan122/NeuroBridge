import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from "react";
import { api, getToken, setToken } from "../api/client";
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
  login: (emailOrPhone: string, password: string) => Promise<string[]>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<UserBasic | null>(null);
  const [roles, setRoles] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let active = true;
    (async () => {
      if (!getToken()) {
        setLoading(false);
        return;
      }
      try {
        const me = await api<MeResponse>("/auth/me");
        if (active) {
          setUser(me.user);
          setRoles(me.roles);
        }
      } catch {
        setToken(null);
      } finally {
        if (active) setLoading(false);
      }
    })();
    return () => {
      active = false;
    };
  }, []);

  const login = useCallback(async (emailOrPhone: string, password: string) => {
    const res = await api<LoginResponse>("/auth/login", {
      method: "POST",
      body: JSON.stringify({ email_or_phone: emailOrPhone, password }),
    });
    setToken(res.access_token);
    setUser(res.user);
    setRoles(res.roles);
    return res.roles;
  }, []);

  const logout = useCallback(() => {
    api("/auth/logout", { method: "POST" }).catch(() => {
      /* best-effort */
    });
    setToken(null);
    setUser(null);
    setRoles([]);
  }, []);

  const isClinician = roles.includes("doctor") || roles.includes("therapist");

  return (
    <AuthContext.Provider
      value={{ user, roles, loading, isClinician, login, logout }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}
