#!/usr/bin/env python3
"""Lint: every emit_event() subject (4th arg) must resolve to a PARTY id.

Background: emit_event(p_kind, p_severity, p_actor_user_id, p_subject_party_id,
p_source_schema, p_source_table, p_source_id, p_payload). The 4th argument is
p_subject_party_id — a PARTY id, NOT a patient id. Four triggers
(prescription_issued, surgical, radiology, diagnosis) historically passed
NEW.patient_id / a patient_id-derived variable there, which the
event_log_subject_party_id_fkey constraint rejected at runtime. That class of
bug slips past per-incident fixes, so this audit enforces the invariant.

Rule (conservative, low false-positive):
  OK   if the 4th arg contains "party_id", is NULL, or is a variable that was
       assigned FROM a "...party_id..." expression.
  FAIL if the 4th arg references "patient_id" (the exact bug class).
  WARN otherwise (unknown token) — reported but non-fatal, so we don't block
       legitimate new call sites we haven't modeled.

Usage:
  python scripts/audit_emit_event.py            # prints report, exits 1 on FAIL
  from scripts.audit_emit_event import check_sql_files  # returns (violations, warns)
"""
import os
import re
import sys

SQL_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "sql")


def _classify_vars(sql: str):
    """Return (party_safe, patient_derived) variable-name sets.

    A variable is party_safe if the column it is SELECTed/assigned FROM is a
    party_id (e.g. SELECT p.party_id INTO v_party). It is patient_derived if the
    selected column is a patient_id (e.g. SELECT e.patient_id INTO v_pid).

    Only the selected expression (between the nearest SELECT and INTO, or the
    assignment RHS before FROM/WHERE) is inspected, so a WHERE clause like
    "WHERE p.patient_id = NEW.patient_id" does not misclassify a party-safe var.
    """
    party_safe = set()
    patient_derived = set()
    # SELECT <expr> ... INTO <var>   -> inspect <expr> only (SELECT..INTO window)
    for m in re.finditer(r"INTO\s+([A-Za-z_][A-Za-z0-9_]*)\b", sql, re.I):
        seg_start = sql.rfind("SELECT", max(0, m.start() - 400), m.start())
        if seg_start == -1:
            seg_start = max(0, m.start() - 220)
        window = sql[seg_start:m.start()]
        if "party_id" in window and "patient_id" not in window:
            party_safe.add(m.group(1))
        elif "patient_id" in window:
            patient_derived.add(m.group(1))
    # <var> := <rhs>;   -> inspect <rhs> before FROM/WHERE
    for m in re.finditer(r"([A-Za-z_][A-Za-z0-9_]*)\s*:=\s*([^;]*?);", sql, re.I | re.S):
        rhs = re.split(r"\bFROM\b|\bWHERE\b", m.group(2), flags=re.I)[0]
        if "patient_id" in rhs:
            patient_derived.add(m.group(1))
        elif "party_id" in rhs:
            party_safe.add(m.group(1))
    # Ambiguous var (assigned from BOTH party_id and patient_id in this file):
    # default to safe rather than over-firing on shared names like "pid".
    patient_derived -= party_safe
    return party_safe, patient_derived


def _emit_calls(sql: str):
    """Yield (lineno, [arg0, arg1, arg2, arg3, ...]) for each emit_event call.

    Handles the 4th arg being on the same line or the next line (common style:
    emit_event(\n  'kind', 'sev', actor, SUBJECT, ...).
    """
    for m in re.finditer(r"emit_event\s*\(", sql):
        # Skip CREATE FUNCTION ... emit_event(...) type signatures (arg types, not calls)
        pre = sql[max(0, m.start() - 120):m.start()]
        if re.search(r"CREATE\s+(OR\s+REPLACE\s+)?FUNCTION", pre, re.I):
            continue
        depth = 0
        i = m.end() - 1
        buf = []
        while i < len(sql):
            c = sql[i]
            if c == "(":
                depth += 1
            elif c == ")":
                if depth == 0:
                    break
                depth -= 1
            buf.append(c)
            i += 1
        inner = "".join(buf[1:])  # drop the leading '('
        # split top-level commas (ignoring those inside quotes/parens)
        args = []
        cur = []
        d = 0
        q = None
        for ch in inner:
            if q:
                if ch == q:
                    q = None
                cur.append(ch)
            elif ch in ("'", '"'):
                q = ch
                cur.append(ch)
            elif ch == "(":
                d += 1
                cur.append(ch)
            elif ch == ")":
                d -= 1
                cur.append(ch)
            elif ch == "," and d == 0:
                args.append("".join(cur).strip())
                cur = []
            else:
                cur.append(ch)
        if cur:
            args.append("".join(cur).strip())
        # find line number
        lineno = sql.count("\n", 0, m.start()) + 1
        yield lineno, args


def check_sql_files(sql_dir: str = SQL_DIR):
    violations = []  # (file, lineno, detail)
    warns = []       # (file, lineno, detail)
    files = sorted(f for f in os.listdir(sql_dir) if f.endswith(".sql"))
    for fn in files:
        path = os.path.join(sql_dir, fn)
        try:
            sql = open(path, encoding="utf-8").read()
        except Exception as e:  # noqa: BLE001
            warns.append((fn, 0, f"cannot read: {e}"))
            continue
        safe, patient_derived = _classify_vars(sql)
        for lineno, args in _emit_calls(sql):
            if len(args) < 4:
                continue  # malformed call; let the DB catch it
            subj = args[3]
            low = subj.lower()
            if "party_id" in low:
                continue  # explicitly a party id
            if subj.strip().upper() == "NULL":
                continue
            tok = re.sub(r"^(new|old|p)\.", "", low).strip()
            # CREATE FUNCTION ... emit_event(bigint, bigint, ...) type signatures:
            # the 4th arg is a bare SQL type keyword, not a call argument.
            if tok in {
                "bigint", "int", "int2", "int4", "int8", "smallint", "integer",
                "text", "varchar", "char", "uuid", "json", "jsonb", "boolean",
                "bool", "numeric", "decimal", "timestamp", "timestamptz", "date",
            }:
                continue
            if tok in patient_derived:
                violations.append((fn, lineno, f"emit_event subject is patient_id-derived var: {subj}"))
                continue
            if tok in safe:
                continue
            if "patient_id" in low:
                violations.append((fn, lineno, f"emit_event subject is patient_id-derived: {subj}"))
            else:
                warns.append((fn, lineno, f"emit_event subject not modeled as party-safe: {subj}"))
    return violations, warns


def main():
    violations, warns = check_sql_files()
    for fn, ln, d in warns:
        print(f"  WARN  {fn}:{ln} {d}")
    for fn, ln, d in violations:
        print(f"  FAIL  {fn}:{ln} {d}")
    if violations:
        print(f"\nEMIT_EVENT SUBJECT AUDIT: {len(violations)} FAILURE(S), {len(warns)} warning(s)")
        sys.exit(1)
    print(f"EMIT_EVENT SUBJECT AUDIT: CLEAN ({len(warns)} non-fatal warning(s))")
    sys.exit(0)


if __name__ == "__main__":
    main()
