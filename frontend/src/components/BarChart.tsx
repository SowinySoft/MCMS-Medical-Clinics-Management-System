// Dependency-free SVG bar chart. Renders horizontally for RTL-friendliness.
export function BarChart({ data, color = "var(--accent)" }: { data: { label: string; value: number }[]; color?: string }) {
  if (!data.length) return <div className="mcms-empty">—</div>;
  const max = Math.max(...data.map((d) => Number(d.value) || 0), 1);
  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 6, marginTop: 6 }}>
      {data.map((d, i) => (
        <div key={i} style={{ display: "flex", alignItems: "center", gap: 8, fontSize: 12 }}>
          <div style={{ width: 110, color: "var(--text-dim)", textAlign: "end", flexShrink: 0, overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{d.label}</div>
          <div style={{ flex: 1, background: "var(--panel-2)", borderRadius: 4, height: 16, position: "relative" }}>
            <div style={{ width: `${(Number(d.value) / max) * 100}%`, background: color, height: "100%", borderRadius: 4 }} />
          </div>
          <div style={{ width: 56, color: "var(--text)", flexShrink: 0 }}>{Number(d.value).toLocaleString()}</div>
        </div>
      ))}
    </div>
  );
}
