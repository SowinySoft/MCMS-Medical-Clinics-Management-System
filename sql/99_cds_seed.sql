-- 99_cds_seed.sql : Phase 1 (Trust) — drug-drug interaction seed for CDS.
-- The drug_interaction table existed but was empty; this populates a handful
-- of real, well-known pairs so order-time interaction checking actually fires.
-- drug_item ids: 1 Paracetamol, 2 Ibuprofen, 3 Acetylsalicylic acid (ASA),
-- 4 Amoxicillin, 6 Metformin, 9 Omeprazole (see mcms_rx.drug_item).

INSERT INTO mcms_rx.drug_interaction
  (drug_item_id_a, drug_item_id_b, severity, mechanism, clinical_effect, management)
VALUES
  (1, 2, 'moderate', 'NSAID + paracetamol', 'Increased risk of GI bleeding and renal impairment with combined frequent use', 'Prefer single agent; monitor for GI bleed if combined'),
  (2, 3, 'major', 'NSAID + antiplatelet (ASA)', 'Additive inhibition of platelet aggregation -> major bleeding risk', 'Avoid combination unless specifically indicated; GI prophylaxis if unavoidable'),
  (1, 3, 'moderate', 'Paracetamol + ASA', 'Additive analgesic but increased GI/renal risk at high doses', 'Use lowest effective doses; monitor renal function'),
  (3, 9, 'major', 'ASA + omeprazole', 'ASA irritates gastric mucosa; PPI reduces ulcer risk', 'Co-prescribe PPI (e.g. omeprazole) with long-term ASA'),
  (6, 9, 'minor', 'Metformin + omeprazole', 'Omeprazole may marginally raise metformin levels', 'Generally safe; routine monitoring sufficient'),
  (2, 9, 'minor', 'Ibuprofen + omeprazole', 'NSAID ulcers mitigated by PPI', 'Co-prescribe PPI for patients on chronic NSAIDs')
ON CONFLICT (drug_item_id_a, drug_item_id_b) DO NOTHING;
