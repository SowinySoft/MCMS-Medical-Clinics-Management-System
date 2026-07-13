-- ============================================================
-- MCMS · Master install script
-- Loads every schema module in dependency order: schemas → core →
-- hr → emr → clinic → surgical → emergency → rx → lab → rad →
-- icu → physio → billing → erp → cross-schema FK patches → seed.
--
-- Run with:   psql -U postgres -h 127.0.0.1 -d mcms -f install.sql
-- Or via \i from inside psql.
--
-- Safe to re-run only the seed file.  Module files drop and recreate
-- types/triggers; the model file (this one) is re-runnable in a clean
-- database drop-on-rebuild manner.
-- ============================================================
\set ON_ERROR_STOP on
\i sql/00_schemas.sql
\i sql/01_core.sql
\i sql/03_hr.sql
\i sql/02_emr.sql
\i sql/04_clinic.sql
\i sql/05_surgical.sql
\i sql/06_emergency.sql
\i sql/07_rx.sql
\i sql/08_lab.sql
\i sql/09_rad.sql
\i sql/10_icu.sql
\i sql/11_physio.sql
\i sql/12_billing.sql
\i sql/13_erp.sql
\i sql/14_views.sql
\i sql/15_merge.sql
\i sql/16_merge_tables.sql
\i sql/99_links.sql
\i sql/90_seed.sql
\i sql/91_merge_seed.sql
