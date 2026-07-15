-- ============================================================
-- Phase 13: Identity federation (OIDC / SAML SSO bridge)
--   * mcms_core.identity_provider  - registered external IdPs
--   * mcms_core.federated_identity  - external subject -> local app_user link
--   * consent_type enum extended with identity_federation + data_residency
-- (Live OIDC discovery / SAML metadata exchange is a separate, deploy-time
--  transport step; this delivers the deterministic federation machinery.)
-- ============================================================

-- ---- Extend consent_type enum ----
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum e
        JOIN pg_type t ON t.oid = e.enumtypid
        WHERE t.typname = 'consent_type' AND e.enumlabel = 'identity_federation'
    ) THEN
        ALTER TYPE mcms_core.consent_type ADD VALUE 'identity_federation';
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum e
        JOIN pg_type t ON t.oid = e.enumtypid
        WHERE t.typname = 'consent_type' AND e.enumlabel = 'data_residency'
    ) THEN
        ALTER TYPE mcms_core.consent_type ADD VALUE 'data_residency';
    END IF;
END $$;

-- ---- Identity provider registry ----
CREATE TABLE IF NOT EXISTS mcms_core.identity_provider (
    provider_code   text PRIMARY KEY,
    name            text NOT NULL,
    protocol        text NOT NULL CHECK (protocol IN ('oidc','saml')),
    client_id       text,
    config          jsonb NOT NULL DEFAULT '{}'::jsonb,
    enabled         boolean NOT NULL DEFAULT false,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);

-- ---- Federated identity link (external subject -> local user) ----
CREATE TABLE IF NOT EXISTS mcms_core.federated_identity (
    fed_id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    provider_code   text NOT NULL REFERENCES mcms_core.identity_provider (provider_code),
    external_subject text NOT NULL,
    user_id         bigint NOT NULL REFERENCES mcms_core.app_user (user_id),
    linked_at       timestamptz NOT NULL DEFAULT now(),
    last_seen_at    timestamptz NOT NULL DEFAULT now(),
    UNIQUE (provider_code, external_subject)
);
CREATE INDEX IF NOT EXISTS ix_fed_identity_user ON mcms_core.federated_identity (user_id);

-- ---- Seed sample IdPs (disabled: no live IdP in this environment) ----
INSERT INTO mcms_core.identity_provider (provider_code, name, protocol, client_id, config, enabled)
VALUES
    ('moh_oidc', 'Ministry of Health OIDC', 'oidc', 'mcms-sp',
     '{"issuer": "https://id.moh.gov.example", "jwks_uri": "https://id.moh.gov.example/.well-known/jwks.json"}'::jsonb, false),
    ('nhif_saml', 'NHIF SAML IdP', 'saml', 'mcms-sp',
     '{"entity_id": "https://id.nhif.gov.example", "sso_url": "https://id.nhif.gov.example/sso"}'::jsonb, false)
ON CONFLICT (provider_code) DO NOTHING;
