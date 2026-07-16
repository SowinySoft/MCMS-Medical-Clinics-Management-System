// Auth context: holds JWT + RBAC roles/perms, drives route guards & menus.
import { useEffect, useState, type ReactNode } from "react";
import { authApi } from "./api";
import { AuthCtx } from "./useAuth";

export function AuthProvider({ children }: { children: ReactNode }) {
  const [access, setAccess] = useState<string | null>(localStorage.getItem("access"));
  const [refresh, setRefresh] = useState<string | null>(localStorage.getItem("refresh"));
  const [roles, setRoles] = useState<string[]>([]);
  const [perms, setPerms] = useState<string[]>([]);

  useEffect(() => {
    const r = localStorage.getItem("roles");
    const p = localStorage.getItem("perms");
    if (r) setRoles(JSON.parse(r));
    if (p) setPerms(JSON.parse(p));
  }, []);

  const login = async (u: string, p: string) => {
    const { data } = await authApi.login(u, p);
    localStorage.setItem("access", data.access);
    localStorage.setItem("refresh", data.refresh);
    localStorage.setItem("roles", JSON.stringify(data.roles));
    localStorage.setItem("perms", JSON.stringify(data.perms));
    setAccess(data.access); setRefresh(data.refresh);
    setRoles(data.roles); setPerms(data.perms);
  };

  const logout = () => {
    localStorage.clear(); setAccess(null); setRefresh(null); setRoles([]); setPerms([]);
  };

  const hasPerm = (p: string) => perms.includes("admin.all") || perms.includes(p);

  return (
    <AuthCtx.Provider value={{ access, refresh, roles, perms, login, logout, hasPerm }}>
      {children}
    </AuthCtx.Provider>
  );
}
