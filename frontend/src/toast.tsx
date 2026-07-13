import { createContext, useContext, useState, type ReactNode } from "react";

interface ToastState {
  show: (msg: string, kind?: "ok" | "err") => void;
}
const Ctx = createContext<ToastState>(null as any);
export const useToast = () => useContext(Ctx);

let id = 0;
export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<{ id: number; msg: string; kind: string }[]>([]);
  const show = (msg: string, kind: "ok" | "err" = "ok") => {
    const tid = ++id;
    setToasts((t) => [...t, { id: tid, msg, kind }]);
    setTimeout(() => setToasts((t) => t.filter((x) => x.id !== tid)), 3200);
  };
  return (
    <Ctx.Provider value={{ show }}>
      {children}
      <div>
        {toasts.map((t) => (
          <div key={t.id} className={`mcms-toast ${t.kind === "err" ? "err" : ""}`}>{t.msg}</div>
        ))}
      </div>
    </Ctx.Provider>
  );
}
