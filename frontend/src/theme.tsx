// Theme system: 3 palettes applied as CSS custom properties on :root.
// Themes are medical-oriented (Dark/Clinical default, Light, High-Contrast).
// RTL is handled separately by i18n (document.dir); themes are direction-agnostic.
import { useEffect, useState, type ReactNode } from "react";
import { Ctx, THEMES, type ThemeName } from "./useTheme";

function apply(theme: ThemeName) {
  const v = THEMES[theme].vars;
  const root = document.documentElement;
  for (const [k, val] of Object.entries(v)) root.style.setProperty(k, val);
  root.setAttribute("data-theme", theme);
}

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setThemeState] = useState<ThemeName>(
    (localStorage.getItem("theme") as ThemeName) || "clinical"
  );
  useEffect(() => { apply(theme); localStorage.setItem("theme", theme); }, [theme]);
  return (
    <Ctx.Provider value={{ theme, setTheme: setThemeState, themes: Object.values(THEMES) }}>
      {children}
    </Ctx.Provider>
  );
}
