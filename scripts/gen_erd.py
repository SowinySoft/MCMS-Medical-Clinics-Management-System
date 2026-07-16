#!/usr/bin/env python3
"""Generate MCMS Entity-Relationship diagrams from the live database.

Emits three artifacts into docs/:
  1. erd_per_schema.html   - one Mermaid erDiagram per schema (tabbed), all render
  2. erd_schema_diagram.html - one combined Mermaid erDiagram with zoom/pan controls
  3. erd_schema_cards.html  - a styled card-grid (like SFAS_schema.html reference)

The previous per-schema file broke because raw Postgres column types (custom
enums such as `diagnosis_role`, underscore-prefixed array types like `_int8`)
were emitted as Mermaid `erDiagram` type tokens, which Mermaid rejects. This
generator maps every Postgres type to a Mermaid-safe alias, so all schemas
parse. Relationships are derived from information_schema foreign keys.
"""
import html
import os

import psycopg

DB = dict(
    host=os.environ.get("MCMS_DB_HOST", "127.0.0.1"),
    port=int(os.environ.get("MCMS_DB_PORT", "5432")),
    user=os.environ.get("MCMS_DB_USER", "postgres"),
    password=os.environ.get("MCMS_DB_PASSWORD", os.environ.get("PGPASSWORD", "postgres")),
    dbname=os.environ.get("MCMS_DB_NAME") or os.environ.get("AUDIT_DB", "mcms"),
)
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "docs")

# ---- schema presentation metadata (label / icon / accent) ----
SCHEMA_META = {
    "mcms_core":       ("Core / Event-Store / RBAC", "🧩", "gold"),
    "mcms_emr":        ("EMR", "🩺", "cyan"),
    "mcms_clinic":     ("Clinics & Appointments", "📅", "cyan"),
    "mcms_hr":         ("HR & Payroll", "👥", "green"),
    "mcms_surgical":   ("Surgical", "🔪", "red"),
    "mcms_emergency":  ("Emergency", "🚑", "red"),
    "mcms_rx":         ("Pharmacy", "💊", "green"),
    "mcms_lab":        ("Laboratory", "🧪", "purple"),
    "mcms_rad":        ("Radiology", "🩻", "purple"),
    "mcms_icu":        ("ICU", "🏥", "red"),
    "mcms_physio":     ("Physiotherapy", "🤸", "green"),
    "mcms_dialysis":   ("Dialysis", "💉", "cyan"),
    "mcms_nursery":   ("Nursery / Neonatal", "👶", "orange"),
    "mcms_billing":    ("Billing / Insurance", "💳", "gold"),
    "mcms_erp":        ("ERP / Supply Chain", "📦", "orange"),
    "mcms_telemed":    ("Telemedicine", "📞", "cyan"),
    "mcms_terminology":("Terminology / Coding", "🔤", "purple"),
    "mcms_vital_records":("Vital Records", "📜", "gold"),
}
SCHEMA_ORDER = list(SCHEMA_META.keys())

# ---- Postgres type -> Mermaid-safe type token ----
def safe_type(pg_type: str) -> str:
    t = (pg_type or "").lower().strip()
    t = t.replace("[]", "").split("(")[0].strip()
    mapping = {
        "bigint": "bigint", "int8": "bigint", "integer": "int", "int": "int",
        "int4": "int", "smallint": "int", "int2": "int", "tinyint": "int",
        "serial": "bigint", "bigserial": "bigint",
        "text": "text", "varchar": "varchar", "character varying": "varchar",
        "char": "char", "bpchar": "char", "name": "text",
        "boolean": "bool", "bool": "bool",
        "timestamp": "timestamp", "timestamptz": "timestamp",
        "timestamp without time zone": "timestamp",
        "timestamp with time zone": "timestamp", "date": "date", "time": "time",
        "numeric": "decimal", "decimal": "decimal", "money": "decimal",
        "real": "float", "float4": "float", "double precision": "float",
        "float8": "float", "float": "float",
        "json": "json", "jsonb": "json",
        "uuid": "uuid", "bytea": "blob",
    }
    if t in mapping:
        return mapping[t]
    return "text"


def sanitize_ident(name: str) -> str:
    s = "".join(ch if ch.isalnum() or ch == "_" else "_" for ch in name)
    if not s or not s[0].isalpha():
        s = "c_" + s
    return s


# ---- queries ----
COLUMNS_SQL = """
SELECT table_schema, table_name, column_name, data_type, udt_name,
       is_nullable, column_default
FROM information_schema.columns
WHERE table_schema LIKE 'mcms_%' AND table_schema <> 'mcms_audit'
ORDER BY table_schema, table_name, ordinal_position
"""
PK_SQL = """
SELECT tc.table_schema, tc.table_name, kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON kcu.constraint_name = tc.constraint_name
 AND kcu.table_schema = tc.table_schema AND kcu.table_name = tc.table_name
WHERE tc.constraint_type = 'PRIMARY KEY'
  AND tc.table_schema LIKE 'mcms_%' AND tc.table_schema <> 'mcms_audit'
ORDER BY tc.table_schema, tc.table_name, kcu.ordinal_position
"""
FK_SQL = """
SELECT kcu.table_schema, kcu.table_name, kcu.column_name,
       ccu.table_schema AS fk_schema, ccu.table_name AS fk_table,
       tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON kcu.constraint_name = tc.constraint_name
 AND kcu.table_schema = tc.table_schema AND kcu.table_name = tc.table_name
JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name
 AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema LIKE 'mcms_%' AND tc.table_schema <> 'mcms_audit'
  AND ccu.table_schema LIKE 'mcms_%' AND ccu.table_schema <> 'mcms_audit'
ORDER BY kcu.table_schema, kcu.table_name, kcu.ordinal_position
"""


def load(conn):
    cols = {}
    with conn.cursor() as cur:
        cur.execute(COLUMNS_SQL)
        for sch, tbl, col, dtype, udt, nullable, default in cur.fetchall():
            cols.setdefault((sch, tbl), []).append((col, dtype, udt, nullable))
        cur.execute(PK_SQL)
        pks = {}
        for sch, tbl, col in cur.fetchall():
            pks.setdefault((sch, tbl), set()).add(col)
        cur.execute(FK_SQL)
        fks = []
        for rs, rt, rc, fs, ft, cname in cur.fetchall():
            fks.append((rs, rt, rc, fs, ft))
    return cols, pks, fks


def entity_name(sch, tbl):
    return sanitize_ident(f"{sch.replace('mcms_', '')}__{tbl}")


def build_entities(cols, pks):
    out = {}
    for (sch, tbl), col_list in cols.items():
        ent = entity_name(sch, tbl)
        pk_set = pks.get((sch, tbl), set())
        rows = []
        for col, dtype, udt, nullable in col_list:
            raw = udt if (udt and "[" not in udt and udt.isidentifier()) else dtype
            tok = safe_type(raw)
            rows.append((col, tok, col in pk_set))
        out.setdefault(sch, {})[ent] = (tbl, rows)
    return out


def build_rels(fks):
    seen = set()
    edges = []
    for rs, rt, rc, fs, ft in fks:
        fe = entity_name(rs, rt)
        te = entity_name(fs, ft)
        if fe == te:
            card, lbl = "||--o|", "self"
        else:
            card, lbl = "||--o{", rc
        key = (fe, te, lbl)
        if key in seen:
            continue
        seen.add(key)
        edges.append((fe, te, card, lbl))
    # Deterministic output: sort by (from, to, label) so generated docs are
    # byte-stable regardless of the DB's FK-row iteration order (which is not
    # fully controlled by ORDER BY on constraint_column_usage for multi-col /
    # self/join FKs).
    edges.sort(key=lambda e: (e[0], e[1], str(e[3])))
    return edges


def mermaid_block(entities_dict, edges):
    L = ["erDiagram"]
    for ent, (tbl, rows) in entities_dict.items():
        L.append(f"  {ent} {{")
        for col, tok, is_pk in rows:
            suffix = " PK" if is_pk else ""
            L.append(f"    {tok} {col}{suffix}")
        L.append("  }")
    for fe, te, card, lbl in edges:
        L.append(f"  {fe} {card} {te} : \"{lbl}\"")
    return "\n".join(L)


def emit_per_schema(cols, pks, fks, path):
    entities_by_schema = build_entities(cols, pks)
    rels = build_rels(fks)
    tabs, secs = [], []
    schemas = [s for s in SCHEMA_ORDER if s in entities_by_schema]
    for s in sorted(entities_by_schema):
        if s not in schemas:
            schemas.append(s)
    first = True
    for sch in schemas:
        label, icon, accent = SCHEMA_META.get(sch, (sch, "🗂️", "cyan"))
        disp = "block" if first else "none"
        first = False
        tabs.append('<button onclick="show(\'%s\')">%s %s</button>' % (sch, icon, html.escape(label)))
        block = mermaid_block(
            entities_by_schema[sch],
            [e for e in rels if e[0] in entities_by_schema[sch] and e[1] in entities_by_schema[sch]],
        )
        secs.append(
            '<div class="sec" id="sec_%s" style="display:%s">'
            '<h2>%s %s — %s <span class="cnt">(%d tables)</span></h2>'
            '<pre class="mermaid">\n%s\n</pre></div>'
            % (sch, disp, icon, html.escape(sch), html.escape(label),
               len(entities_by_schema[sch]), block)
        )
    doc = (
        '<!doctype html><html lang="en"><head><meta charset="utf-8">\n'
        '<title>MCMS — Per-Schema Entity Diagrams</title>\n'
        '<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>\n'
        '<style>\n'
        'body{font-family:system-ui,Segoe UI,Arial;margin:0;background:#0d1117;color:#e6edf3}\n'
        'header{padding:16px 24px;background:#161b22;border-bottom:1px solid #30363d}\n'
        'h1{margin:0;font-size:20px} .sub{color:#8b949e;font-size:13px;margin-top:4px}\n'
        '.tabs{padding:12px 24px;background:#161b22;border-bottom:1px solid #30363d;position:sticky;top:0;z-index:5;display:flex;flex-wrap:wrap}\n'
        'button{background:#21262d;color:#e6edf3;border:1px solid #30363d;border-radius:6px;padding:6px 10px;margin:3px;cursor:pointer;font-size:12px}\n'
        'button:hover{background:#30363d} .wrap{padding:24px}\n'
        '.mermaid{background:#fff;border-radius:8px;padding:16px;overflow:auto} h2{font-size:16px}\n'
        '.cnt{color:#8b949e;font-weight:400;font-size:13px}\n'
        '</style></head><body>\n'
        '<header><h1>MCMS — Per-Schema Entity Diagrams</h1>\n'
        '<div class="sub">%d focused ERDs · click a schema to view · foreign keys shown as edges</div></header>\n'
        '<div class="tabs">%s</div>\n'
        '<div class="wrap">%s</div>\n'
        '<script>\n'
        'mermaid.initialize({startOnLoad:true,theme:\'default\',maxTextSize:4000000,securityLevel:\'loose\'});\n'
        'function show(s){document.querySelectorAll(\'.sec\').forEach(e=>e.style.display=\'none\');document.getElementById(\'sec_\'+s).style.display=\'block\';}\n'
        '</script>\n</body></html>'
    ) % (len(schemas), "".join(tabs), "".join(secs))
    with open(path, "w", encoding="utf-8") as f:
        f.write(doc)


def emit_combined(cols, pks, fks, path):
    entities_by_schema = build_entities(cols, pks)
    all_entities = {}
    for sch, d in entities_by_schema.items():
        all_entities.update(d)
    edges = build_rels(fks)
    block = mermaid_block(all_entities, edges)
    doc = (
        '<!doctype html><html lang="en"><head><meta charset="utf-8">\n'
        '<title>MCMS — Full Entity-Relationship Diagram</title>\n'
        '<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>\n'
        '<style>\n'
        'body{font-family:system-ui,Segoe UI,Arial;margin:0;background:#0d1117;color:#e6edf3}\n'
        'header{padding:16px 24px;background:#161b22;border-bottom:1px solid #30363d;position:sticky;top:0;z-index:10}\n'
        'h1{margin:0;font-size:20px} .sub{color:#8b949e;font-size:13px;margin-top:4px}\n'
        '.toolbar{padding:10px 24px;background:#161b22;border-bottom:1px solid #30363d;position:sticky;top:64px;z-index:9}\n'
        '.toolbar button{background:#21262d;color:#e6edf3;border:1px solid #30363d;border-radius:6px;padding:6px 12px;margin:3px;cursor:pointer;font-size:13px}\n'
        '.toolbar button:hover{background:#30363d} .zoom{color:#8b949e;font-size:13px;margin-left:8px}\n'
        '.viewport{overflow:auto;padding:16px;height:calc(100vh - 140px)}\n'
        '#stage{transform-origin:0 0;transition:transform .08s ease-out}\n'
        '.mermaid{background:#fff;border-radius:8px;padding:12px;width:max-content}\n'
        '</style></head><body>\n'
        '<header><h1>MCMS — Full Entity-Relationship Diagram</h1>\n'
        '<div class="sub">%d tables · %d foreign-key edges · scroll to pan, use zoom to fit</div></header>\n'
        '<div class="toolbar">\n'
        '  <button onclick="zoom(0.8)">− Zoom out</button>\n'
        '  <button onclick="zoom(1.25)">+ Zoom in</button>\n'
        '  <button onclick="zoom(0)">Reset</button>\n'
        '  <button onclick="fit()">Fit</button>\n'
        '  <span class="zoom" id="zlabel">100%%</span>\n'
        '</div>\n'
        '<div class="viewport" id="vp">\n'
        '  <div id="stage"><pre class="mermaid">\n%s\n</pre></div>\n'
        '</div>\n'
        '<script>\n'
        'mermaid.initialize({startOnLoad:true,theme:\'default\',maxTextSize:4000000,securityLevel:\'loose\'});\n'
        'let scale=1;\n'
        'function zoom(f){ if(f===0){scale=1;} else {scale=Math.min(4,Math.max(0.1,scale*f));}\n'
        '  document.getElementById(\'stage\').style.transform=\'scale(\'+scale+\')\';\n'
        '  document.getElementById(\'zlabel\').textContent=Math.round(scale*100)+\'%%\'; }\n'
        'function fit(){ const vp=document.getElementById(\'vp\'), st=document.getElementById(\'stage\');\n'
        '  const sc=Math.min(vp.clientWidth/st.scrollWidth, vp.clientHeight/st.scrollHeight, 1);\n'
        '  scale=Math.max(0.1,sc); st.style.transform=\'scale(\'+scale+\')\';\n'
        '  document.getElementById(\'zlabel\').textContent=Math.round(scale*100)+\'%%\'; }\n'
        'window.addEventListener(\'load\',()=>setTimeout(fit,300));\n'
        '</script>\n</body></html>'
    ) % (len(all_entities), len(edges), block)
    with open(path, "w", encoding="utf-8") as f:
        f.write(doc)


def emit_cards(cols, pks, fks, path):
    entities_by_schema = build_entities(cols, pks)
    fk_cols = {}
    for rs, rt, rc, fs, ft in fks:
        fk_cols.setdefault((rs, rt), set()).add(rc)
    groups = []
    schemas = [s for s in SCHEMA_ORDER if s in entities_by_schema]
    for s in sorted(entities_by_schema):
        if s not in schemas:
            schemas.append(s)
    for sch in schemas:
        label, icon, accent = SCHEMA_META.get(sch, (sch, "🗂️", "cyan"))
        cards = []
        for ent, (tbl, rows) in sorted(entities_by_schema[sch].items()):
            fkset = fk_cols.get((sch, tbl), set())
            field_rows = []
            for col, tok, is_pk in rows:
                if is_pk:
                    dot = "pk-dot"
                elif col in fkset:
                    dot = "fk-dot"
                else:
                    dot = "reg-dot"
                field_rows.append(
                    '<div class="field-row"><div class="%s"></div>'
                    '<span class="field-name">%s</span>'
                    '<span class="field-type">%s</span></div>'
                    % (dot, html.escape(col), html.escape(tok.upper()))
                )
            cards.append(
                '<div class="schema-table highlight-%s">'
                '<div class="table-header"><div class="table-icon">%s</div>'
                '<div class="table-name">%s</div>'
                '<div class="table-tag tag-%s">%s</div>'
                '</div><div class="field-list">%s</div></div>'
                % (accent, icon, html.escape(tbl), accent, html.escape(sch.replace("mcms_", "").upper()),
                   "".join(field_rows))
            )
        groups.append(
            '<section class="schema-group"><h2 class="group-title">'
            '<span class="gt-icon">%s</span> %s '
            '<span class="gt-count">%d tables</span></h2>'
            '<div class="schema-grid">%s</div></section>'
            % (icon, html.escape(label), len(entities_by_schema[sch]), "".join(cards))
        )
    table_count = sum(len(d) for d in entities_by_schema.values())
    doc = (
        '<!doctype html><html lang="en"><head><meta charset="utf-8">\n'
        '<meta name="viewport" content="width=device-width, initial-scale=1.0">\n'
        '<title>MCMS — Schema Reference (Card View)</title>\n'
        '<style>\n'
        ':root{\n'
        '  --void:#04080f; --deep:#080e1a; --panel:#0d1525; --card:#111c30; --border:#1a2d4a;\n'
        '  --accent-gold:#f0a500; --accent-cyan:#00d4ff; --accent-green:#00e676;\n'
        '  --accent-red:#ff3d57; --accent-purple:#9c6cff; --accent-orange:#ff6b2b;\n'
        '  --text-primary:#e8f0fe; --text-secondary:#7a9cc8; --text-dim:#3a5070;\n'
        '}\n'
        '*{margin:0;padding:0;box-sizing:border-box}\n'
        'body{background:var(--void);color:var(--text-primary);font-family:\'IBM Plex Mono\',ui-monospace,SFMono-Regular,Menlo,monospace;min-height:100vh}\n'
        'body::before{content:\'\';position:fixed;inset:0;\n'
        '  background-image:linear-gradient(rgba(0,212,255,0.03) 1px,transparent 1px),\n'
        '    linear-gradient(90deg,rgba(0,212,255,0.03) 1px,transparent 1px);\n'
        '  background-size:40px 40px;pointer-events:none;z-index:0}\n'
        'header{position:relative;z-index:1;padding:28px 32px 18px;border-bottom:1px solid var(--border);\n'
        '  background:linear-gradient(180deg,rgba(13,21,37,.9),rgba(4,8,15,.6))}\n'
        'h1{font-size:26px;letter-spacing:1px;background:linear-gradient(90deg,var(--accent-cyan),var(--accent-gold));\n'
        '  -webkit-background-clip:text;background-clip:text;color:transparent}\n'
        '.sub{color:var(--text-secondary);font-size:13px;margin-top:6px}\n'
        '.schema-group{position:relative;z-index:1;padding:24px 32px}\n'
        '.group-title{font-size:17px;color:var(--accent-cyan);margin-bottom:14px;display:flex;align-items:center;gap:8px;\n'
        '  border-bottom:1px solid var(--border);padding-bottom:8px}\n'
        '.gt-icon{font-size:20px} .gt-count{color:var(--text-dim);font-size:12px;font-weight:400}\n'
        '.schema-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(280px,1fr));gap:16px}\n'
        '.schema-table{background:var(--card);border:1px solid var(--border);border-radius:10px;overflow:hidden;\n'
        '  box-shadow:0 4px 18px rgba(0,0,0,.35);transition:transform .15s ease,box-shadow .15s ease}\n'
        '.schema-table:hover{transform:translateY(-3px)}\n'
        '.highlight-gold{border-top:3px solid var(--accent-gold);box-shadow:0 0 18px rgba(240,165,0,.12)}\n'
        '.highlight-cyan{border-top:3px solid var(--accent-cyan);box-shadow:0 0 18px rgba(0,212,255,.12)}\n'
        '.highlight-green{border-top:3px solid var(--accent-green);box-shadow:0 0 18px rgba(0,230,118,.12)}\n'
        '.highlight-red{border-top:3px solid var(--accent-red);box-shadow:0 0 18px rgba(255,61,87,.12)}\n'
        '.highlight-purple{border-top:3px solid var(--accent-purple);box-shadow:0 0 18px rgba(156,108,255,.12)}\n'
        '.highlight-orange{border-top:3px solid var(--accent-orange);box-shadow:0 0 18px rgba(255,107,43,.12)}\n'
        '.table-header{display:flex;align-items:center;gap:8px;padding:10px 12px;background:rgba(255,255,255,.03);border-bottom:1px solid var(--border)}\n'
        '.table-icon{font-size:16px}\n'
        '.table-name{font-weight:600;font-size:14px;color:var(--text-primary);flex:1}\n'
        '.table-tag{font-size:9px;font-weight:700;letter-spacing:.5px;padding:2px 6px;border-radius:4px;color:#04080f}\n'
        '.tag-gold{background:var(--accent-gold)} .tag-cyan{background:var(--accent-cyan)}\n'
        '.tag-green{background:var(--accent-green)} .tag-red{background:var(--accent-red)}\n'
        '.tag-purple{background:var(--accent-purple)} .tag-orange{background:var(--accent-orange)}\n'
        '.field-list{padding:6px 0}\n'
        '.field-row{display:flex;align-items:center;gap:8px;padding:4px 12px;font-size:12px}\n'
        '.field-row:hover{background:rgba(255,255,255,.03)}\n'
        '.field-name{flex:1;color:var(--text-secondary)}\n'
        '.field-type{color:var(--text-dim);font-size:10px;font-weight:600}\n'
        '.pk-dot{width:8px;height:8px;border-radius:50%%;background:var(--accent-gold);box-shadow:0 0 6px var(--accent-gold)}\n'
        '.fk-dot{width:8px;height:8px;border-radius:50%%;background:var(--accent-cyan);box-shadow:0 0 6px var(--accent-cyan)}\n'
        '.reg-dot{width:8px;height:8px;border-radius:50%%;background:var(--text-dim)}\n'
        '</style></head><body>\n'
        '<header><h1>MCMS — Schema Reference</h1>\n'
        '<div class="sub">%d schemas · %d tables · generated from the live database · PK 🟡 · FK 🔵</div></header>\n'
        '%s\n'
        '<footer style="position:relative;z-index:1;padding:20px 32px;color:var(--text-dim);font-size:11px;border-top:1px solid var(--border)">\n'
        'Generated by scripts/gen_erd.py from information_schema.\n'
        '</footer>\n</body></html>'
    ) % (len(schemas), table_count, "".join(groups))
    with open(path, "w", encoding="utf-8") as f:
        f.write(doc)



def main():
    conn = psycopg.connect(**DB)
    cols, pks, fks = load(conn)
    conn.close()
    os.makedirs(OUT_DIR, exist_ok=True)
    emit_per_schema(cols, pks, fks, os.path.join(OUT_DIR, "erd_per_schema.html"))
    emit_combined(cols, pks, fks, os.path.join(OUT_DIR, "erd_schema_diagram.html"))
    emit_cards(cols, pks, fks, os.path.join(OUT_DIR, "erd_schema_cards.html"))
    n_tables = sum(len(d) for d in build_entities(cols, pks).values())
    print(f"OK: wrote 3 ERD docs ({len(set(s for s, _ in cols))} schemas, {n_tables} tables)")


if __name__ == "__main__":
    main()
