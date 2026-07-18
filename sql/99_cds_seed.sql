-- 99_cds_seed.sql : Phase 1 (Trust) — drug-drug interaction seed for CDS.
-- The drug_interaction table existed but was empty; this populates a handful
-- of real, well-known pairs so order-time interaction checking actually fires.
--
-- NOTE: drug_item ids are assigned by BIGSERIAL in 90_seed.sql (no explicit
-- ids), so we look them up by generic_name here. This makes the seed robust
-- to sequence state and load order (hardcoding ids 1..9 broke on fresh DBs
-- where the assigned ids did not match the assumed mapping).

INSERT INTO mcms_rx.drug_interaction
  (drug_item_id_a, drug_item_id_b, severity, mechanism, clinical_effect, management)
VALUES
  ((SELECT MIN(drug_item_id) FROM mcms_rx.drug_item WHERE generic_name = 'Paracetamol'),
   (SELECT MIN(drug_item_id) FROM mcms_rx.drug_item WHERE generic_name = 'Ibuprofen'),
   'moderate', 'NSAID + paracetamol', 'Increased risk of GI bleeding and renal impairment with combined frequent use', 'Prefer single agent; monitor for GI bleed if combined'),
  ((SELECT MIN(drug_item_id) FROM mcms_rx.drug_item WHERE generic_name = 'Ibuprofen'),
   (SELECT MIN(drug_item_id) FROM mcms_rx.drug_item WHERE generic_name = 'Acetylsalicylic acid'),
   'major', 'NSAID + antiplatelet (ASA)', 'Additive inhibition of platelet aggregation -> major bleeding risk', 'Avoid combination unless specifically indicated; GI prophylaxis if unavoidable'),
  ((SELECT MIN(drug_item_id) FROM mcms_rx.drug_item WHERE generic_name = 'Paracetamol'),
   (SELECT MIN(drug_item_id) FROM mcms_rx.drug_item WHERE generic_name = 'Acetylsalicylic acid'),
   'moderate', 'Paracetamol + ASA', 'Additive analgesic but increased GI/renal risk at high doses', 'Use lowest effective doses; monitor renal function'),
  ((SELECT MIN(drug_item_id) FROM mcms_rx.drug_item WHERE generic_name = 'Acetylsalicylic acid'),
   (SELECT MIN(drug_item_id) FROM mcms_rx.drug_item WHERE generic_name = 'Omeprazole'),
   'major', 'ASA + omeprazole', 'ASA irritates gastric mucosa; PPI reduces ulcer risk', 'Co-prescribe PPI (e.g. omeprazole) with long-term ASA'),
  ((SELECT MIN(drug_item_id) FROM mcms_rx.drug_item WHERE generic_name = 'Metformin'),
   (SELECT MIN(drug_item_id) FROM mcms_rx.drug_item WHERE generic_name = 'Omeprazole'),
   'minor', 'Metformin + omeprazole', 'Omeprazole may marginally raise metformin levels', 'Generally safe; routine monitoring sufficient'),
  ((SELECT MIN(drug_item_id) FROM mcms_rx.drug_item WHERE generic_name = 'Ibuprofen'),
   (SELECT MIN(drug_item_id) FROM mcms_rx.drug_item WHERE generic_name = 'Omeprazole'),
   'minor', 'Ibuprofen + omeprazole', 'NSAID ulcers mitigated by PPI', 'Co-prescribe PPI for patients on chronic NSAIDs')
ON CONFLICT (drug_item_id_a, drug_item_id_b) DO NOTHING;
