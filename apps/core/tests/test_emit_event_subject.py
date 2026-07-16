"""Regression guard for the emit_event() subject-party invariant.

Mirrors the deep-integrity audit pattern: a pure static lint over sql/*.sql that
fails CI if any emit_event() call passes a patient_id (or a variable derived from
patient_id) as its 4th argument (p_subject_party_id). That class of bug broke
four triggers (prescription_issued, surgical, radiology, diagnosis) and was only
caught at runtime by the event_log_subject_party_id_fkey constraint. Static
enforcement prevents a recurrence without needing a DB connection.

Runs in CI's `pytest` step (no DB required).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scripts.audit_emit_event import SQL_DIR, check_sql_files  # noqa: E402


def test_emit_event_subject_is_party():
    violations, warns = check_sql_files(SQL_DIR)
    assert not violations, (
        f"{len(violations)} emit_event() call(s) pass a patient_id-derived value as "
        f"the subject (p_subject_party_id). First: {violations[0]}"
    )
