import { useTheme } from "../theme";
import { useTranslation } from "react-i18next";

// Theme switcher — cycles the 3 medical palettes (Clinical / Light / Contrast).
export function ThemeSwitcher() {
  const { theme, setTheme, themes } = useTheme();
  const { t } = useTranslation();
  return (
    <select
      className="mcms-select"
      style={{ width: "auto", padding: "4px 8px", fontSize: 12 }}
      value={theme}
      onChange={(e) => setTheme(e.target.value as any)}
      title={t("theme") || "Theme"}
    >
      {themes.map((th) => (
        <option key={th.name} value={th.name}>{th.label.en}</option>
      ))}
    </select>
  );
}
