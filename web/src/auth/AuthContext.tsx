import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from "react";

import {
  getToken,
  setToken,
} from "../api/client";

import { webAccountApi } from "../api/webAccountClient";

import type { UserBasic } from "../types";

interface MeResponse {
  success: boolean;
  user: UserBasic;
  roles: string[];
}

interface LoginResponse {
  success: boolean;
  message?: string;
  access_token: string;
  user: UserBasic;
  roles: string[];
}

interface LogoutResponse {
  success: boolean;
  message?: string;
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

const AuthContext =
  createContext<AuthContextValue | null>(null);

export function AuthProvider({
  children,
}: {
  children: ReactNode;
}) {
  const [user, setUser] =
    useState<UserBasic | null>(null);

  const [roles, setRoles] =
    useState<string[]>([]);

  const [loading, setLoading] =
    useState(true);

  /*
   * عند فتح الموقع والتأكد من وجود Token،
   * نجلب الحساب الحالي من api_web/me.php.
   */
  useEffect(() => {
    let active = true;

    const loadCurrentUser = async () => {
      const token = getToken();

      if (!token) {
        if (active) {
          setUser(null);
          setRoles([]);
          setLoading(false);
        }

        return;
      }

      try {
        const response =
          await webAccountApi<MeResponse>(
            "me.php",
          );

        if (!active) {
          return;
        }

        setUser(response.user);
        setRoles(response.roles);
      } catch {
        /*
         * Token منتهي أو قديم أو غير صحيح.
         */
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
    };

    void loadCurrentUser();

    return () => {
      active = false;
    };
  }, []);

  /*
   * تسجيل الدخول من api_web/login.php.
   */
  const login = useCallback(
    async (
      emailOrPhone: string,
      password: string,
    ): Promise<string[]> => {
      const response =
        await webAccountApi<LoginResponse>(
          "login.php",
          {
            method: "POST",

            body: JSON.stringify({
              email_or_phone:
                emailOrPhone.trim(),

              password,
            }),
          },
        );

      setToken(response.access_token);
      setUser(response.user);
      setRoles(response.roles);

      return response.roles;
    },
    [],
  );

  /*
   * تسجيل الخروج من api_web/logout.php.
   */
  const logout = useCallback(() => {
    webAccountApi<LogoutResponse>(
      "logout.php",
      {
        method: "POST",
      },
    ).catch(() => {
      /*
       * حتى لو فشل اتصال الخروج،
       * نحذف الجلسة من المتصفح.
       */
    });

    setToken(null);
    setUser(null);
    setRoles([]);
  }, []);

  /*
   * الصلاحيات حسب الدور الذي أعاده PHP.
   */
  const isClinician =
    roles.includes("doctor") ||
    roles.includes("therapist");

  const isFamily =
    roles.includes("family");

  const isAdmin =
    roles.includes("admin");

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
  const context =
    useContext(AuthContext);

  if (!context) {
    throw new Error(
      "useAuth must be used within AuthProvider",
    );
  }

  return context;
}