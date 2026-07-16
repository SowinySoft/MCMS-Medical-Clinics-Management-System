import { useState, type ReactNode } from "react";
import { ToastCtx } from "./useToast";

let id = 0;
export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<{ id: number; msg: string; kind: string }[]>([]);
  const show = (msg: string, kind: "ok" | "err" = "ok") => {
    const tid = ++id;
    setToasts((t) => [...t, { id: tid, msg, kind }]);
    setTimeout(() => setToasts((t) => t.filter((x) => x.id !== tid)), 3200);
  };
  return (
    <ToastCtx.Provider value={{ show }}>
      {children}
      <div>
        {toasts.map((t) => (
          <div key={t.id} className={`mcms-toast ${t.kind === "err" ? "err" : ""}`}>{t.msg}</div>
        ))}
      </div>
    </ToastCtx.Provider>
  );
}
