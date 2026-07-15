"""Deterministic ICD-10 / SNOMED code suggestion from free-text clinical notes.

No external model, no API key -- pure token-overlap scoring against the
curated `mcms_core.lookup` table (namespace 'icd10', 'snomed', ...).

Why deterministic: it is offline, reproducible, and CI-testable against the
real seeded lookup data (the project's 'verify against the real thing, not
faked output' bar). The scoring is intentionally simple and explainable so a
clinician can see *why* a code was suggested (the matched tokens are returned).
"""

import re

from django.db import connection

# Common clinical abbreviations -> canonical tokens, so short notes still match.
_SYNONYMS = {
    "htn": "hypertension",
    "dm": "diabetes",
    "t2dm": "diabetes",
    "mi": "myocardial infarction",
    "uti": "urinary tract infection",
    "copd": "chronic obstructive pulmonary",
    "gerd": "gastro oesophageal reflux",
    "uri": "upper respiratory infection",
    "afib": "atrial fibrillation",
    "chf": "congestive heart failure",
    "lbp": "low back pain",
    "hld": "hypercholesterolaemia",
    "asthma": "asthma",
    "fracture": "fracture",
}

_STOP = {
    "the", "and", "for", "with", "patient", "has", "had", "was", "were",
    "this", "that", "from", "into", "left", "right", "acute", "chronic",
    "reported", "complains", "of", "a", "an", "is", "are", "on", "in",
    "to", "mild", "moderate", "severe", "suspected", "possible",
    "rule", "out", "vs", "due", "x",
}


def _tokenize(text):
    raw = re.findall(r"[a-z0-9]+", (text or "").lower())
    toks = []
    for t in raw:
        if t in _STOP or len(t) < 2:
            continue
        if t in _SYNONYMS:
            toks.extend(_SYNONYMS[t].split())
        else:
            toks.append(t)
    return toks


def _load_rows(namespaces):
    with connection.cursor() as cur:
        cur.execute(
            "SELECT namespace, code, label, label_ar FROM mcms_core.lookup "
            "WHERE namespace = ANY(%s) AND is_active",
            [list(namespaces)],
        )
        return [
            {"namespace": r[0], "code": r[1], "label": r[2], "label_ar": r[3]}
            for r in cur.fetchall()
        ]


def _score(tokens, label):
    """Count how many query tokens are present as words in the label.

    Returns (score, matched_tokens). A full-phrase match is boosted.
    """
    words = set(re.findall(r"[a-z0-9]+", (label or "").lower()))
    joined = (label or "").lower()
    matched = [t for t in tokens if t in words]
    score = len(matched)
    # phrase boost: if two+ adjacent query tokens appear consecutively
    for i in range(len(tokens) - 1):
        bigram = f"{tokens[i]} {tokens[i + 1]}"
        if bigram in joined:
            score += 1
            if tokens[i] not in matched:
                matched.append(tokens[i])
    return score, matched


def suggest_codes(text, namespaces=("icd10",), limit=8):
    """Return ranked code candidates for free-text `text`.

    Each candidate: {namespace, code, label, score, matched}
    ranked by score desc, then label asc. Only codes scoring > 0 are returned.
    """
    tokens = _tokenize(text)
    if not tokens:
        return []
    rows = _load_rows(namespaces)
    scored = []
    for row in rows:
        score, matched = _score(tokens, row["label"])
        if score > 0:
            scored.append({
                "namespace": row["namespace"],
                "code": row["code"],
                "label": row["label"],
                "score": score,
                "matched": sorted(set(matched)),
            })
    scored.sort(key=lambda d: (-d["score"], d["label"]))
    return scored[:limit]
