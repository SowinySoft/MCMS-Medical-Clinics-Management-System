import { createContext, useContext } from "react";

export type ThemeName = "clinical" | "light" | "contrast";

interface ThemeDef {
  name: ThemeName;
  label: { en: string; ar: string };
  vars: Record<string, string>;
}

export const THEMES: Record<ThemeName, ThemeDef> = {
  clinical: {
    name: "clinical", label: { en: "Dark / Clinical", ar: "داكن / سريري" },
    vars: {
      "--bg": "#010409", "--bg-elev": "#0d1117", "--panel": "#161b22",
      "--panel-2": "#1c2230", "--border": "#30363d", "--text": "#e6edf3",
      "--text-dim": "#8b949e", "--accent": "#1f6feb", "--accent-2": "#3fb950",
      "--warn": "#d29922", "--danger": "#f85149", "--row-hover": "#1c2230",
    },
  },
  light: {
    name: "light", label: { en: "Light", ar: "فاتح" },
    vars: {
      "--bg": "#f4f6fb", "--bg-elev": "#ffffff", "--panel": "#ffffff",
      "--panel-2": "#f0f3f9", "--border": "#d6dce5", "--text": "#1b1f27",
      "--text-dim": "#5b6472", "--accent": "#1668e0", "--accent-2": "#1a7f37",
      "--warn": "#9a6700", "--danger": "#c4261d", "--row-hover": "#eef2f9",
    },
  },
  contrast: {
    name: "contrast", label: { en: "High Contrast", ar: "تباين عالي" },
    vars: {
      "--bg": "#000000", "--bg-elev": "#000000", "--panel": "#0a0a0a",
      "--panel-2": "#141414", "--border": "#ffd400", "--text": "#ffffff",
      "--text-dim": "#ffe680", "--accent": "#ffd400", "--accent-2": "#00e676",
      "--warn": "#ffab00", "--danger": "#ff5252", "--row-hover": "#1a1a1a",
    },
  },
};

export const Ctx = createContext<{ theme: ThemeName; setTheme: (t: ThemeName) => void; themes: ThemeDef[] }>(null as any);
export const useTheme = () => useContext(Ctx);
