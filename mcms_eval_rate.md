# MCMS — Systematic Project Evaluation

**Scope:** Phoenix roadmap (Phases 0–17.1) + Reports module + ERD lifecycle
**As of:** commit `2123334` (ERD: regenerate per-schema/combined + card-view reference)
**Method:** evidence-based synthesis from this session's CI runs, test counts, and the
bugs actually encountered and fixed during the journey. Ratings are honest, not celebratory.

---

## 1. Scorecard

| Dimension | Rating | Evidence |
|---|---|---|
| Delivery discipline (phase rhythm) | **A** | Plan → confirm → build → pytest-green-on-CI → commit → push → confirm-CI-green → await next phase. Followed consistently across 17+ phases. |
| Architecture / data model | **A−** | 18 `mcms_*` schemas / 124 tables, RBAC + queryset-layer enforcement, prebuilt `v_payroll_summary` view, event-store backbone. |
| Backend correctness | **B+** | Strong, but 4 latent trigger bugs (`emit_event` subject = party id) slipped past an earlier "fix" sweep — see Risks. |
| API ↔ UI contract | **A** | `test_frontend_contract.py` proves BOTH directions: every backend route has a nav path; every nav path hits a real endpoint. |
| Test rigor (unit / integration) | **A−** | 139+ pytest tests, deep-integrity audit (sequence / orphan FK / model↔DB drift), deterministic offline runs. |
| Local verification reliability | **C−** | Full suite hangs / ~25 min on this machine and threw teardown errors under load — it *masked* real bugs until CI (36 s) caught them. **CI is the only trustworthy gate locally.** |
| Frontend engineering | **B** | Schema-grouped nav, dynamic Reports renderer, `tsc` clean. But the React SPA is never exercised against the live API in CI. |
| Reproducibility / CI | **A** | GitHub Actions green; `MCMS_DB_NAME` env isolation; build scripts wire SQL `33`→`42`. |
| Docs / ERD | **A** | Regenerated from live DB; type-safe Mermaid; card-view reference matching `SFAS_schema.html`. |
| Technical-debt hygiene | **B−** | Several workarounds left in place (see Risks) instead of root-cause fixes. |

---

## 2. What is genuinely strong

- **The contract invariant** ("no backend without pages / no pages without backend") is
  enforced by an automated test, not just a stated rule. That is rare and valuable.
- **Deterministic, offline, CI-testable phases** — exactly the rhythm established at the
  start, and it held. No external downloads, no live third-party transport.
- **Deep integrity audits** (`audit_deep.py`, `audit_integrity.py`) check sequence
  alignment, orphan FKs, and model↔DB drift — a real safety net that caught the `party`
  sequence drift this session.
- **Reports built on real seeded data**, verified against the live DB — not fabricated.
  This directly honors the "verify against the real live DB" principle.
- **Dynamic schema discovery** (no hardcoded `SCHEMAS` list) — corrected an earlier wrong
  assumption that "only 3 schemas are populated."

---

## 3. Latent risks & technical debt (the bugs we hit ARE the evidence)

1. **Trigger-authoring bug class not centrally enforced.** Four `fn_*_event` triggers
   (`prescription_issued`, surgical, radiology, diagnosis) passed `patient_id` where
   `emit_event` expects `subject_party_id`. The original `sql/33` sweep "fixed" 12 but
   missed these (added later). *Signal:* the emit_event contract needs a lint/audit rule,
   not per-incident patches.
2. **`fn_generic_audit` cannot cast boolean columns.** We hit this seeding
   `payroll_item.is_paid` — worked around it by disabling the trigger around the insert
   rather than fixing the trigger. *Latent:* any app-layer boolean write to an audited
   table will fail the same way.
3. **Raw-SQL seed bypasses app validation.** `sql/39` took ~10 iterations (FK, enum,
   GENERATED column, audit-trigger, sequence) because direct INSERTs hit constraints the
   app layer would handle. Seeds are a parallel write path that can drift from the real
   write path.
4. **Local test environment is not a trustworthy gate.** The full suite hangs at ~25 min
   here and threw teardown errors under load — it *masked* the event-log FK failures until
   CI (36 s) caught them. You are effectively CI-only-verified locally.
5. **React SPA is never run against the live API in CI.** `test_frontend_contract.py`
   force-authenticates and hits DRF endpoints server-side; the actual React bundle
   (`Reports.tsx`, nav, SchemaBrowser) is only type-checked, not exercised end-to-end. The
   user-facing surface is the least-tested layer.
6. **Generated ERD HTML is committed but unguarded.** `scripts/gen_erd.py` exists, but
   nothing in CI fails if someone changes the schema and forgets to regenerate
   `docs/*.html`. Docs can silently drift from the DB.
7. **Reports use hand-built SQL strings.** Several queries are inline SQL (some via
   parameterized `_rows()`, but `monthly_payroll` interpolates the period `code` into a
   query). Worthy of a central parameterization review for injection safety.
8. **Stale counts in memory/docs.** Memory says "21 schemas / 268 tables"; the live `mcms`
   DB is 18 schemas / 124 tables. The SFAS figure is a different DB — but the stale number
   in memory is itself a small documentation-risk signal.

---

## 4. Prioritized recommendations

### P0 — correctness, cheap
- Add a CI step that runs `scripts/gen_erd.py` and fails if `docs/*.html` differ from the
  committed version (kills doc drift). ~10 lines in `ci.yml`.
- Add a one-off audit/lint that scans every `emit_event(` call and asserts the 4th arg is
  sourced from a `party_id` resolution (catches the class of bug #1 permanently).

### P1 — root-cause the workarounds
- Fix `fn_generic_audit` to handle boolean/array columns (the real fix for risk #2), then
  re-enable it on `payroll_item` and drop the seed's trigger-disable hack.
- Stand up a Playwright/Cypress smoke test that loads the built React app, logs in, and
  opens `/reports` + one schema — closes the frontend-e2e gap (#5).

### P2 — hardening
- Route seed data through the app/ORM layer (or a validated fixture) instead of raw
  INSERTs, so seeds cannot diverge from real writes (#3).
- Replace the local full-suite reliance with a faster, sharded run (e.g. pytest per-app)
  so you are not CI-only (#4).
- Schedule a one-time review of all report SQL for parameterization (#7).

---

## 5. Verdict

The project is in **good, shippable shape**: a coherent domain model, a real RBAC +
event-store backbone, an enforced API↔UI contract, and a green CI pipeline — delivered
with disciplined phase-gated hygiene. The weaknesses are not in *what* was built but in
*verification coverage and a few un-finished root-cause fixes*: the local environment isn't
trustworthy, the React frontend isn't e2e-tested, and two latent bugs were worked around
rather than fixed.

**Net: architecture A, engineering B+, verification B−.** The highest-leverage next move
is **P0** (ERD-regeneration CI guard + emit_event lint) — both are small, eliminate whole
classes of drift/bug, and fit the "verify against reality" standard.

---

*Generated as part of the Phase 17.1 closeout. Companion to the live-delivered summary in
chat. Re-run `scripts/gen_erd.py` after any schema change and regenerate this file after
each major phase.*
