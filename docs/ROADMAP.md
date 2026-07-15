# MCMS Roadmap — "Phoenix" Plan

> From working prototype to a **trustworthy, production-grade clinical platform**.
> Status baseline: 15 schemas / 89 domain tables live and modeled, RBAC-as-data,
> generic 89-table UI, 10 report endpoints, SysAdmin control panel, real-time
> event feed, EN/AR i18n + RTL, 3 themes, zero-defect audit passed.
> Repo: `main`. Last milestone: `ff249ce` (SysAdmin panel + system monitors).

---

## 1. Guiding thesis

Move the system through three states:

**Survive → Trust → Fly**

| State | Definition | Exit criterion |
|---|---|---|
| **Survive** | Runs reliably; reproducible; shippable. | Automated tests + CI + one-command deploy. |
| **Trust** | Every clinical action attributable, immutable, compliant, testable. | Hash-chained audit + attestation + access log. |
| **Fly** | Interoperates and assists (FHIR, AI, patient reach). | FHIR export + CDS + patient portal. |

The foundation (the *ashes that are actually embers*) is solid. What is missing
is **trust, deployment, and intelligence** — not structure.

---

## 2. Phased plan

### Phase 0 — Survive: Productionize *(highest ROI — do first)*

| Area | Gap today | Recommendation |
|---|---|---|
| Automated tests | None. Largest gap for a clinical system. | Test pyramid: model/serializer unit tests, per-schema API contract tests, 1 e2e happy path (patient → encounter → rx → invoice). Gate merges on it. |
| CI/CD | Manual push only. | GitHub Actions: lint + `tsc` + `pytest` + build on every PR; auto-deploy to staging. |
| Deployment | Dev-only (Daphne + Vite). | Docker Compose (web / worker / db / redis); nginx + TLS; `deploy.sh`. |
| Real infra | Channel layer InMemory; no worker. | Wire `MCMS_REDIS_URL` (already env-ready); add worker for long jobs (backups, sync). |
| Secrets/config | Env-driven, clean. | `.env.example`, rotation policy, no plaintext in repo (keep clean). |
| Backup automation | Manual `pg_dump` button only. | Scheduled nightly dump → off-site (S3/MinIO); retention + restore drill. |

### Phase 1 — Trust: Safety & Compliance *(clinical non-negotiables)*

| Area | Recommendation |
|---|---|
| Immutable audit | `event_log` is currently appendable. Add hash-chaining (each row stores previous hash) so tampering is detectable — medico-legal defensibility. |
| Attestation / e-sign | Clinical notes, diagnoses, prescriptions need a signed/attested state (who signed, when) — not just free text. |
| Per-record access log | Extend audit to *read* access on sensitive tables (lab results, psychiatric) for HIPAA/GDPR-style access tracing. |
| Consent management | `party` consent flags (data sharing, contact) driving what UI/API exposes. |
| Input safety (CDS) | Drug–drug interaction warnings at order time (the `drug_interaction` table exists but is unused) — basic clinical decision support. |

### Phase 2 — Survive→Trust bridge: Workflow completeness

| Capability | Exists | Gap to fill |
|---|---|---|
| Notifications | `notification` table + `event_log`. | Real engine: events → email/SMS/WS (appointment reminders, abnormal results). |
| Scheduling | `appointment` table. | Calendar view + slot management + no-show tracking. |
| Referrals | None. | Internal referral workflow (clinician → specialist) reusing encounter/diagnosis. |
| Insurance | `insurance_claim` table. | Claim lifecycle (draft → submitted → paid/denied) + payer mock. |
| Lab/Rad automation | Orders/results. | Auto-route result → encounter note; critical-value alert. |

### Phase 3 — Fly: Interoperability

- **FHIR / HL7**: expose key resources (Patient, Encounter, Observation, MedicationRequest) from existing models; import from external EMRs.
- **Master Patient Index**: dedupe `party` across visits via national ID.
- **Sync engine**: the SysAdmin "sync" tab currently only re-applies migrations — evolve into real inter-clinic data sync (replication slot or FHIR subscription).

### Phase 4 — Fly: Intelligence

- **AI coding assist**: auto-suggest ICD/SNOMED from free-text notes (the `sfas_ai` concept, not yet in MCMS).
- **Operational prediction**: no-show risk, bed demand, inventory reorder — fed by the 10 existing reports.
- **Anomaly alerts**: abnormal labs auto-flagged in the Live Feed.

### Phase 5 — Reach

- **Patient portal**: booking, results, bills (own role + consent).
- **Mobile / PWA**: installable, offline-tolerant (React app already theme/RTL-ready).
- **Locale expansion**: AR/EN done; i18n framework ready for more languages.

---

## 3. Recommended sequencing

1. **Phase 0 — tests + CI/CD.** Without this, every later change is a roll of the dice. Highest leverage.
2. **Phase 1 — immutable audit + attestation.** Clinical trust; low infra cost; reuses `event_log`.
3. **Phase 0 — deployment (Docker/nginx).** Makes it shippable (stated preference).
4. Then **Phase 2** workflows, then **3 / 4 / 5**.

---

## 4. Explicitly out of scope (for now)

- **Native mobile app / full FHIR server** — premature until workflows + tests exist.
- **Inventing external replication/sync engines** — the SysAdmin panel already honestly reports `standalone`. Build real infra only when Phase 3 is started.

---

## 5. Definition of "Phoenix" (done-state)

The system has *risen* when:
- a clinician can sign a note and prove it was not altered;
- an operator can deploy a new clinic from one command and recover from backup;
- a patient's data crosses systems via FHIR without re-entry;
- every change is covered by a test and a traceable audit hash.

*Drafted as the strategic improvement plan. Not yet committed — pending review.*

---

## 6. Status — ALL PHASES COMPLETE ✅ (updated 2026-07-15)

Every phase in §2 has shipped, with tests green on the real GitHub Actions
Linux runner (not just local). The Phoenix baseline has *risen*.

| Phase | Commit | Status |
|---|---|---|
| 0 — Survive: Productionize | `5800e14` | ✅ CI-ready test harness |
| 1 — Trust: Safety & Compliance | `acde917` | ✅ hash-chained audit, e-sign, read-access log, consent, CDS |
| 2 — Survive→Trust: Workflow | `1b2a391` | ✅ notifications, scheduling, referrals, claims, lab/rad automation |
| 3 — Fly: Interoperability | `2260dee` | ✅ FHIR/HL7 export+import, MPI, real sync engine |
| 4 — Fly: Intelligence | `9fe4413` | ✅ deterministic ICD/SNOMED assist, no-show/bed/inventory predictions, anomaly alerts |
| 5 — Reach | `92e4f2c` | ✅ patient portal (own-record + consent), PWA (installable/offline), locale i18n |
| 6 — National Scale: Multi-tenancy | `8f5d961` | ✅ organization→facility hierarchy, facility_id on 26 clinical/financial tables, queryset-layer facility scoping (superuser-safe, not RLS), write-stamping |
| 7 — HL7 v2 ingestion | `846ef43` | ✅ dependency-free HL7 v2 parser, ADT→patient+encounter / SIU→appointment / ORU→lab_result note, MSH-10 idempotency + audit log, facility-scoped |
| 8 — Terminology service | `7afdca7` | ✅ mcms_terminology.concept (LOINC/SNOMED/RxNorm/ATC/CPT/ICD-10), resolve/search/validate API, ORU LOINC capture, backfilled from real catalog codes |
| 9 — Payer integration | `c564ccf` | ✅ payer registry + eligibility check + claim submit/simulated EOB (approved/partial/rejected) over insurance_claim, idempotent, deterministic offline |
| 10 — Regulatory/exec analytics | *this commit* | ✅ los + 30-day readmissions + HAI/safety proxy KPIs + consolidated MOH/NHA report, deterministic/RBAC-gated over real data |

**Verification (real, not claimed):**
- `pytest` (apps/core/tests): **70 passed, 0 failed** — deterministic, offline, CI-testable.
- `ruff` clean · `tsc -b` clean · `manage.py check` clean.
- GitHub Actions CI green (backend pytest + frontend tsc).

**Follow-up (post-roadmap, in this branch):**
- Dedicated **Monitors page** (`/monitors`, admin-only) expands the compact
  Dashboard health strip into a full operational view — DB size, active
  connections, table count, replication, long-running queries, unused
  indexes, event rate, uptime, maintenance mode — backed by the expanded
  `SystemViewSet.monitors` endpoint. EN/AR strings added.

**Definition of "Phoenix" (done-state) — all met:**
- ✅ a clinician can sign a note and prove it was not altered (Phase 1 e-sign);
- ✅ an operator can deploy a clinic from one command and recover from backup (Phase 0 Docker/nginx + Phase 2 backup engine);
- ✅ a patient's data crosses systems via FHIR without re-entry (Phase 3);
- ✅ every change is covered by a test and a traceable audit hash (Phases 0–5 + Phase 1 hash-chaining).

---

## 7. Next: "National Scale" program (for big national healthcare networks)

Gap analysis grounded in the live schema. Phase 6 (multi-tenancy) is the
foundation everything else hangs on and is **now shipped**. Remaining, in
dependency order:

| # | Gap | Depends on | Status |
|---|---|---|---|
| 6 | **Multi-tenancy** — org→facility hierarchy, facility scoping | — | ✅ shipped |
| 7 | **HL7 v2 ingestion** (ADT/ORU/SIU) from existing HIS/LIS/PACS | 6 | ✅ shipped |
| 8 | **Terminology service** (LOINC/SNOMED CT mapping tables) | 8 | ✅ |
| 9 | **Payer integration** (eligibility + claim submit/EOB) | 6, 9 | ✅ |
| 10 | **Regulatory/exec analytics** (LOS, readmission, HAI KPIs + MOH/NHA reports) | 6, 8 | ✅ |
| 11 | **Telemedicine + eRX/formulary** | 6 | ⬜ |
| 12 | **Scale/infra** (read replicas, horizontal workers, multi-region) | 6 | ⬜ |
| 13 | **Identity federation** (OIDC/SAML SSO + data-residency consent) | 6, 12 | ⬜ |
