"""Phase 8 - Terminology service resolver.

Pure, deterministic, offline lookups against mcms_terminology.concept
(the single canonical source of truth seeded from the domain catalogs).
No external distribution files; everything resolves against real seeded data.

Supported code systems: loinc, snomed, rxnorm, atc, cpt, icd10.
"""

from django.db import connection

KNOWN_SYSTEMS = ("loinc", "snomed", "rxnorm", "atc", "cpt", "icd10")


def _norm_system(system):
    if not system:
        return None
    s = system.strip().lower()
    # tolerate common prefixes / casing
    s = s.replace("icd-10", "icd10").replace("icd10cm", "icd10")
    s = s.replace("snomedct", "snomed").replace("snomed_ct", "snomed")
    return s if s in KNOWN_SYSTEMS else None


def resolve(system, code):
    """Return the concept dict for (system, code), or None if unknown."""
    sysn = _norm_system(system)
    if not sysn or not code:
        return None
    with connection.cursor() as cur:
        cur.execute(
            "SELECT concept_id, code_system, code, display, display_ar, synonyms, source "
            "FROM mcms_terminology.concept WHERE code_system=%s AND code=%s",
            [sysn, str(code).strip()])
        row = cur.fetchone()
    if not row:
        return None
    return {
        "concept_id": row[0], "code_system": row[1], "code": row[2],
        "display": row[3], "display_ar": row[4], "synonyms": row[5],
        "source": row[6],
    }


def search(system=None, q=None, limit=20):
    """Search concepts by system + free-text query over display/synonyms."""
    sysn = _norm_system(system) if system else None
    params, where = [], []
    if sysn:
        where.append("code_system = %s")
        params.append(sysn)
    if q:
        like = f"%{q.strip()}%"
        where.append("(display ILIKE %s OR synonyms ILIKE %s OR code = %s)")
        params.extend([like, like, q.strip()])
    sql = ("SELECT code_system, code, display, display_ar FROM mcms_terminology.concept")
    if where:
        sql += " WHERE " + " AND ".join(where)
    sql += " ORDER BY code_system, display LIMIT %s"
    params.append(limit)
    with connection.cursor() as cur:
        cur.execute(sql, params)
        return [
            {"code_system": r[0], "code": r[1], "display": r[2], "display_ar": r[3]}
            for r in cur.fetchall()
        ]


def validate(system, codes):
    """Batch-validate a list of codes. Returns {code: bool} for known membership."""
    sysn = _norm_system(system)
    if not sysn or not codes:
        return {}
    with connection.cursor() as cur:
        cur.execute(
            "SELECT code FROM mcms_terminology.concept WHERE code_system=%s AND code = ANY(%s)",
            [sysn, list({str(c).strip() for c in codes})])
        known = {r[0] for r in cur.fetchall()}
    return {str(c).strip(): (str(c).strip() in known) for c in codes}
