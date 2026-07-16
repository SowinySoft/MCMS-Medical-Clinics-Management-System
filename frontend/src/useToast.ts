import { createContext, useContext } from "react";

interface ToastState {
  show: (msg: string, kind?: "ok" | "err") => void;
}

export const ToastCtx = createContext<ToastState>(null as any);
export const useToast = () => useContext(ToastCtx);
