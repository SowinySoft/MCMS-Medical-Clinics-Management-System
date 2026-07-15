"""Phase 14 - Department / section coverage tests.

Verifies the national-scale department list is present in mcms_hr.department
as active rows, reusing the existing `kind` vocabulary, with no break to FK
integrity, and that the originally-seeded 26 are untouched (no renames).
"""

import pytest
from django.db import connection

pytestmark = pytest.mark.django_db(transaction=True)

# (code, name) pairs that must exist after Phase 14 seeding
EXPECTED = [
    ("ONC-UNIT", "Oncology Department Unit"),
    ("MED-GIM", "Department of General Internal Medicine"),
    ("NEU-PSY", "Department of Neurology and Psychiatry"),
    ("CARD-DIS", "Department of Cardiology and Cardiovascular Diseases"),
    ("CHEST", "Department of Chest Diseases"),
    ("TROP-MED", "Department of Tropical Medicine"),
    ("DERM-VEN", "Department of Dermatology, Venereology and Andrology"),
    ("GERI", "Department of Geriatrics and Gerontology"),
    ("CLIN-PATH", "Department of Clinical Pathology"),
    ("ONC-NM", "Department of Clinical Oncology and Nuclear Medicine"),
    ("RAD-DX", "Department of Diagnostic Radiology"),
    ("SURG-GEN", "Department of General Surgery"),
    ("SURG-CT", "Department of Cardio-Thoracic Surgery"),
    ("SURG-URO", "Department of Urology"),
    ("SURG-PLAS", "Department of Plastic Burn and Maxillofacial Surgery"),
    ("SURG-PED", "Department of Pediatric Surgery"),
    ("SURG-VASC", "Department of Vascular Surgery"),
    ("OPHTH", "Department of Ophthalmology and Ophthalmic Surgery"),
    ("OBS-GYN", "Department of Obstetrics and Gynecology"),
    ("ANES-ICU", "Department of Anesthesiology, Intensive Care and Pain Management"),
    ("EMED", "Department of Emergency Medicine"),
    ("PHY-REHAB", "Department of Rheumatology, Rehabilitation and Physical Medicine"),
    ("PROSTH", "Department of Prosthetics"),
    ("IND-INST", "Department of Industrial Installations"),
    ("FMED", "Department of Family Medicine"),
    ("GENET", "Department of Medical Genetics"),
]

# originally-seeded rows that must remain (no renames)
ORIGINAL_26 = {
    "CLIN-GEN": "General Outpatient Clinic",
    "CLIN-CARD": "Cardiology Clinic",
    "CLIN-ORTH": "Orthopaedics Clinic",
    "CLIN-OBS": "Obstetrics & Gynaecology",
    "CLIN-PAED": "Paediatrics Clinic",
    "CLIN-ENT": "Otolaryngology (ENT)",
    "OR-GEN": "General Operating Theatre",
    "OR-CARD": "Cardiac Surgery Theatre",
    "OR-ORTHO": "Orthopaedic Surgery Theatre",
    "OR-NEURO": "Neurosurgery Theatre",
    "ED-MAIN": "Emergency Department",
    "ED-TRIAGE": "Triage Area",
    "ICU-GEN": "General ICU",
    "ICU-CCU": "Coronary Care Unit",
    "ICU-NICU": "Neonatal ICU",
    "LAB-CLIN": "Clinical Laboratory",
    "LAB-PATH": "Pathology Lab",
    "RAD-MAIN": "Radiology / Imaging",
    "RX-MAIN": "Inpatient Pharmacy",
    "RX-OUT": "Outpatient Pharmacy",
    "PHY-MAIN": "Physiotherapy Unit",
    "BILL-M": "Billing Office",
    "HR-M": "Human Resources",
    "ADMIN": "Administration",
    "DIAL-GEN": "Dialysis Unit",
    "NURS-GEN": "Nursery / Neonatal Unit",
}

VALID_KINDS = {"hr", "radiology", "clinic", "billing", "administration",
               "pharmacy", "emergency", "lab", "icu", "physio", "surgical"}


def _all():
    with connection.cursor() as cur:
        cur.execute("SELECT department_id, code, name, kind, is_active FROM mcms_hr.department")
        cols = [d[0] for d in cur.description]
        return [dict(zip(cols, r, strict=False)) for r in cur.fetchall()]


def test_all_requested_departments_present():
    rows = {r["code"]: r for r in _all()}
    for code, name in EXPECTED:
        assert code in rows, f"missing department code {code}"
        assert rows[code]["name"] == name, f"name mismatch for {code}"
        assert rows[code]["is_active"] is True


def test_original_26_untouched():
    rows = {r["code"]: r for r in _all()}
    for code, name in ORIGINAL_26.items():
        assert code in rows, f"original dept {code} missing (renamed?)"
        assert rows[code]["name"] == name, f"original dept {code} was renamed"


def test_kind_vocabulary_valid():
    rows = _all()
    for r in rows:
        assert r["kind"] in VALID_KINDS, f"invalid kind {r['kind']} for {r['code']}"


def test_department_fk_integrity():
    """No orphan parent_department_id; every row resolvable."""
    rows = _all()
    ids = {r["department_id"] for r in rows}
    with connection.cursor() as cur:
        cur.execute(
            "SELECT parent_department_id FROM mcms_hr.department "
            "WHERE parent_department_id IS NOT NULL")
        parents = [r[0] for r in cur.fetchall()]
    for pid in parents:
        assert pid in ids, f"orphan parent_department_id {pid}"


def test_total_count():
    rows = _all()
    # 26 original + 26 Phase 14 = 52
    assert len(rows) == 52
