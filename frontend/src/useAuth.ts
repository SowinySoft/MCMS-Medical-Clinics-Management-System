import { createContext, useContext } from "react";

interface AuthState {
  access: string | null;
  refresh: string | null;
  roles: string[];
  perms: string[];
  login: (u: string, p: string) => Promise<void>;
  logout: () => void;
  hasPerm: (p: string) => boolean;
}

export const AuthCtx = createContext<AuthState>(null as any);
export const useAuth = () => useContext(AuthCtx);
