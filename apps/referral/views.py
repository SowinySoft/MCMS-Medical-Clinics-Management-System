"""Phase 15/16 - Systematic referral / linkage recommendations.

Deterministic, offline recommendation surface over the linkage rule table
(mcms_emr.referral_linkage_rule). Given a clinical context (source department
and/or diagnosis code) it returns the ranked target departments (and
facilities, for cross-facility referrals) to refer/link to. A `learned` mode
additionally aggregates accepted/completed historical referrals to rank
targets by real acceptance frequency. It does NOT perform the referral write
(that stays mcms_emr.referral).
"""

from django.db import connection
from rest_framework import permissions, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from apps.core.permissions import HasRolePermission

# read-only surface
_REQUIRED = {"linkage_rules": "emr.read", "recommend": "emr.read"}


def _guard(request):
    # reuse core auth guard pattern
    from apps.core.admin_panel import _guard as _core_guard  # local import to avoid cycle
    return _core_guard(request)


def _rule_rows():
    with connection.cursor() as cur:
        cur.execute(
            "SELECT rule_id, from_department_id, diagnosis_code, code_system, "
            "to_department_id, to_facility_id, priority, rationale, is_active "
            "FROM mcms_emr.referral_linkage_rule WHERE is_active "
            "ORDER BY priority, rule_id")
        cols = [d[0] for d in cur.description]
        return [dict(zip(cols, r, strict=False)) for r in cur.fetchall()]


def _dept_name(dept_id):
    if dept_id is None:
        return None
    with connection.cursor() as cur:
        cur.execute("SELECT name FROM mcms_hr.department WHERE department_id=%s", [dept_id])
        row = cur.fetchone()
        return row[0] if row else None


def _facility_name(fac_id):
    if fac_id is None:
        return None
    with connection.cursor() as cur:
        cur.execute("SELECT name_en FROM mcms_core.facility WHERE facility_id=%s", [fac_id])
        row = cur.fetchone()
        return row[0] if row else None


def _learned_targets(from_dept=None, dx_code=None, code_system="icd10"):
    """Rank target (department, facility) pairs by acceptance frequency from
    historical referrals that were accepted or completed."""
    clauses = ["status IN ('accepted', 'completed')"]
    params: list = []
    if dx_code:
        clauses.append("diagnosis_id IS NOT NULL")
        # join diagnosis to terminology concept by code when possible
    if from_dept:
        try:
            from_dept_i = int(from_dept)
        except (TypeError, ValueError):
            from_dept_i = None
        if from_dept_i is not None:
            clauses.append("from_encounter_id IN ("
                           "SELECT encounter_id FROM mcms_emr.encounter "
                           "WHERE department_id=%s)")
            params.append(from_dept_i)
    where = " AND ".join(clauses)
    with connection.cursor() as cur:
        cur.execute(
            "SELECT to_department_id, facility_id, count(*) AS n "
            "FROM mcms_emr.referral "
            f"WHERE {where} "
            "GROUP BY to_department_id, facility_id "
            "ORDER BY n DESC, to_department_id",
            params)
        return cur.fetchall()


class ReferralViewSet(viewsets.ViewSet):
    """Systematic linkage recommendations (read-only)."""

    permission_classes = [permissions.IsAuthenticated, HasRolePermission]
    required_perms = _REQUIRED

    # --------------------------------------------------- linkage rule map
    @action(detail=False, methods=["get"])
    def linkage_rules(self, request):
        if (d := _guard(request)):
            return d
        rules = _rule_rows()
        out = []
        for r in rules:
            out.append({
                "rule_id": r["rule_id"],
                "from_department_id": r["from_department_id"],
                "from_department": _dept_name(r["from_department_id"]),
                "diagnosis_code": r["diagnosis_code"],
                "code_system": r["code_system"],
                "to_department_id": r["to_department_id"],
                "to_department": _dept_name(r["to_department_id"]),
                "to_facility_id": r["to_facility_id"],
                "to_facility": _facility_name(r["to_facility_id"]),
                "priority": r["priority"],
                "rationale": r["rationale"],
            })
        return Response({"count": len(out), "rules": out})

    # --------------------------------------------------- recommendation
    @action(detail=False, methods=["get"])
    def recommend(self, request):
        if (d := _guard(request)):
            return d
        from_dept = request.query_params.get("from_department_id")
        dx_code = request.query_params.get("diagnosis_code")
        code_system = request.query_params.get("code_system", "icd10")
        learned = request.query_params.get("learned", "false").lower() in ("1", "true", "yes")

        if not from_dept and not dx_code:
            return Response(
                {"detail": "provide from_department_id and/or diagnosis_code"},
                status=400)

        clauses = []
        params: list = []
        if dx_code:
            clauses.append("(diagnosis_code=%s AND code_system=%s)")
            params += [dx_code, code_system]
        if from_dept:
            try:
                from_dept_i = int(from_dept)
            except (TypeError, ValueError):
                return Response({"detail": "from_department_id must be int"}, status=400)
            clauses.append("from_department_id=%s")
            params.append(from_dept_i)

        where = " OR ".join(clauses)
        with connection.cursor() as cur:
            cur.execute(
                "SELECT r.to_department_id, d.name, r.priority, r.rationale, "
                "r.to_facility_id "
                "FROM mcms_emr.referral_linkage_rule r "
                "JOIN mcms_hr.department d ON d.department_id = r.to_department_id "
                f"WHERE r.is_active AND ({where}) "
                "ORDER BY r.priority, r.to_department_id",
                params)
            raw = cur.fetchall()

        seen = {}
        for to_id, name, prio, rationale, fac_id in raw:
            if to_id not in seen:
                seen[to_id] = {"department_id": to_id, "department": name,
                               "priority": prio, "rationale": rationale,
                               "to_facility_id": fac_id,
                               "to_facility": _facility_name(fac_id)}

        if learned:
            hist = _learned_targets(from_dept=from_dept, dx_code=dx_code,
                                    code_system=code_system)
            learned_map = {row[0]: row[2] for row in hist}  # dept_id -> count
            # historical targets that are NOT covered by any rule still surface,
            # ranked by acceptance frequency (the "learned" part of the feature).
            for to_dept, fac_id, _n in hist:
                if to_dept not in seen:
                    seen[to_dept] = {
                        "department_id": to_dept,
                        "department": _dept_name(to_dept),
                        "priority": 999,
                        "rationale": "learned from accepted referrals",
                        "to_facility_id": fac_id,
                        "to_facility": _facility_name(fac_id),
                    }
                seen[to_dept]["learned_acceptances"] = learned_map.get(to_dept, 0)
            recs = sorted(seen.values(),
                          key=lambda x: (-x.get("learned_acceptances", 0), x["priority"]))
        else:
            recs = sorted(seen.values(), key=lambda x: x["priority"])

        return Response({"count": len(recs),
                         "learned": learned,
                         "recommendations": recs})
