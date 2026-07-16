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
2. **`sql/39` disabled the `payroll_item` audit trigger — ROOT CAUSE FOUND & FIXED (corrected).**
   The original trigger failure was **not** a `to_jsonb` boolean problem. Two real bugs in
   `fn_generic_audit` surfaced once the trigger was allowed to fire on every table:
   (a) the PK-derivation cast choked on non-integer JSON values (`is_paid=false` →
   `invalid input syntax for type bigint: "false"`), and (b) for tables whose PK is **text**
   (`identity_provider.provider_code`, `system_flag.flag`) `source_id` stayed NULL while
   `source_table` was set, violating `event_log.event_source_pair_chk`. Both fixed: PK cast
   is now guarded (`~ '^[0-9]+$'`), and when no bigint PK is found the trigger nulls
   `source_schema`/`source_table` too (event still logged, just untied to a row PK).
   Fix applied via `sql/95` (now in the `rebuild_test_db.sh`/`setup_db.sh` apply list,
   run FIRST so the corrected function is live). Seeds run with
   `session_replication_role = 'replica'` (triggers suppressed during seed — seeds are not
   real domain events) then restored to `origin` for runtime writes. This replaces the
   `sql/39` per-table DISABLE/ENABLE hack (and its false "boolean cast" comment), which is
   removed. The fix exposed two latent data bugs the broken trigger had been masking:
   a dangling-FK `consent` seed in `sql/22_phase5.sql` (consent referenced a
   `party`/`app_user` only created inside an `IF NOT EXISTS` guard) — fixed by moving the
   consent insert inside that guard; and a test that hardcoded `granted_by=1` — fixed in
   `test_phase13_identity.py`. Verified: fresh from-sql build → payroll_item=6,
   identity_provider=2, full backend suite 143 passed / 0 failed.
   No new backend-test failures; the 5 previously-suspected identity/linkage failures were
   environmental and are now resolved by the trigger hardening.
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
7. **~~Reports use hand-built SQL strings~~ — RE-CHECKED: false alarm.** `apps/core/reports.py`
   parameterizes every query via `%s` placeholders + a `params` list (`_rows(sql, params)`,
   `WHERE pp.period_id=%s` with `params=[period_id]`, etc.). No string interpolation of
   user input into SQL. No injection risk; no change needed.
8. **Stale counts in memory/docs.** Memory says "21 schemas / 268 tables"; the live `mcms`
   DB is 18 schemas / 124 tables. The SFAS figure is a different DB — but the stale number
   in memory is itself a small documentation-risk signal.

---

## 4. Prioritized recommendations (status as of this update)

### P0 — correctness, cheap ✅ DONE
- ✅ CI step runs `scripts/gen_erd.py` and fails on `docs/*.html` drift (`ci.yml`,
  "ERD docs must match live schema").
- ✅ `scripts/audit_emit_event.py` + `apps/core/tests/test_emit_event_subject.py` enforce
  the emit_event subject-party invariant. Committed; CI green.

### P1 — root-cause the workarounds
- ✅ **`sql/39` trigger-disable hack (risk #2):** ROOT CAUSED & FIXED. The trigger failure
  was two bugs in `fn_generic_audit` (not a `to_jsonb` boolean issue): a `bigint` PK-cast
  choking on `is_paid=false`, and `event_log.event_source_pair_chk` violations for text-PK
  tables (`identity_provider`, `system_flag`) where `source_id` stayed NULL. Both fixed in
  `sql/95` (guarded cast + null the source pair when no bigint PK). `sql/95` is now in the
  build apply list (run first); seeds run under `session_replication_role='replica'` (then
  restored to `origin`) so seeds don't fire triggers — replaces the `sql/39` per-table hack,
  which is removed. The fix exposed two latent dangling-FK bugs the broken trigger had masked
  (a `consent` seed in `sql/22_phase5.sql` and a `granted_by=1` test row) — both fixed.
  Verified on a fresh from-sql build: payroll_item=6, identity_provider=2, full backend
  suite **143 passed / 0 failed**.
- ✅ **Frontend e2e (risk #5):** Playwright smoke test in CI (`frontend-e2e` job). Loads the
  built SPA, logs in, opens `/reports` + `/browse/mcms_core`. CI green (run `29533305952`).
  Closes the least-tested layer.

### P2 — hardening
- 🔲 **Seeds via app layer (risk #3):** Route seed data through the ORM/validated fixture
  instead of raw INSERTs. Large refactor; risky — **confirm before starting.**
- ✅ **Local fast gate (risk #4):** `scripts/local_test_fast.sh` gives a <2-min
  lint + emit_event-guard + 27-test smoke slice (vs the ~25-min full hang). You are no
  longer CI-only for pre-push signal.
- ✅ **Report SQL parameterization (risk #7):** RE-CHECKED — false alarm; `reports.py` is
  fully parameterized. No action.

### Remaining open items (await your go-ahead)
1. Refactor seeds to the app write path (P2 #3).

---

## 5. Verdict

The project is in **good, shippable shape**: a coherent domain model, a real RBAC +
event-store backbone, an enforced API↔UI contract, and a green CI pipeline — delivered
with disciplined phase-gated hygiene. P0 closed two whole classes of drift/bug. The
remaining weaknesses are scoped and deliberate: the React frontend isn't e2e-tested, and
one audit-trigger/seed workaround is intentionally left pending a path-map (not blindly
churned). Local verification is now trustworthy via `scripts/local_test_fast.sh`.

**Net: architecture A, engineering B+, verification B** (was B−; lifted by the fast local
gate + P0 CI guards). Highest-leverage next moves are the three open items above — all
structural, so they await your confirmation.

---

*Generated as part of the Phase 17.1 closeout. Companion to the live-delivered summary in
chat. Re-run `scripts/gen_erd.py` after any schema change and regenerate this file after
each major phase.*
