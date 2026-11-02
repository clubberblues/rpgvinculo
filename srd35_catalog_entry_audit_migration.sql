BEGIN;

CREATE TABLE IF NOT EXISTS public.srd_catalog_entry_audit (
  catalog_key text NOT NULL,
  entry_id text NOT NULL,
  audit_run_at timestamptz NOT NULL DEFAULT now(),
  checks jsonb NOT NULL,
  audit_status text NOT NULL CHECK (audit_status IN ('ready_for_manual_review','needs_data_fix','manual_verified','not_applicable_or_unspecified')),
  audit_notes text NOT NULL DEFAULT '',
  PRIMARY KEY (catalog_key, entry_id)
);

INSERT INTO public.srd_catalog_entry_audit (catalog_key, entry_id, checks, audit_status, audit_notes)
SELECT 'feats', f.id,
       jsonb_build_object('name_ok', nullif(btrim(coalesce(f.nome, '')), '') IS NOT NULL,
                          'description_ok', nullif(btrim(coalesce(f.descricao, '')), '') IS NOT NULL),
       'ready_for_manual_review',
       'Auditoria estrutural; pré-requisitos ainda precisam de conferência contra o SRD.'
FROM public.srd_feats AS f
ON CONFLICT (catalog_key, entry_id) DO UPDATE
SET audit_run_at = now(), checks = EXCLUDED.checks, audit_status = EXCLUDED.audit_status, audit_notes = EXCLUDED.audit_notes;

INSERT INTO public.srd_catalog_entry_audit (catalog_key, entry_id, checks, audit_status, audit_notes)
SELECT 'monsters', m.id,
       jsonb_build_object('name_ok', nullif(btrim(coalesce(m.nome, '')), '') IS NOT NULL,
                          'ca_ok', nullif(btrim(coalesce(m.ca, '')), '') IS NOT NULL),
       'ready_for_manual_review',
       'Auditoria estrutural; habilidades especiais ainda precisam de conferência individual.'
FROM public.srd_monsters AS m
ON CONFLICT (catalog_key, entry_id) DO UPDATE
SET audit_run_at = now(), checks = EXCLUDED.checks, audit_status = EXCLUDED.audit_status, audit_notes = EXCLUDED.audit_notes;

INSERT INTO public.srd_catalog_entry_audit (catalog_key, entry_id, checks, audit_status, audit_notes)
SELECT 'skills', s.id,
       jsonb_build_object('name_ok', nullif(btrim(coalesce(s.nome, '')), '') IS NOT NULL,
                          'description_ok', nullif(btrim(coalesce(s.descricao, '')), '') IS NOT NULL),
       'ready_for_manual_review',
       'Auditoria estrutural; usos, sinergias e treinamento ainda pendentes.'
FROM public.srd_skills AS s
ON CONFLICT (catalog_key, entry_id) DO UPDATE
SET audit_run_at = now(), checks = EXCLUDED.checks, audit_status = EXCLUDED.audit_status, audit_notes = EXCLUDED.audit_notes;

INSERT INTO public.srd_catalog_entry_audit (catalog_key, entry_id, checks, audit_status, audit_notes)
SELECT 'spells', s.id,
       jsonb_build_object('name_ok', nullif(btrim(coalesce(s.nome, '')), '') IS NOT NULL,
                          'description_ok', nullif(btrim(coalesce(s.descricao, '')), '') IS NOT NULL),
       'ready_for_manual_review',
       'Auditoria estrutural; efeitos, resistência e componentes ainda pendentes.'
FROM public.srd_spells AS s
ON CONFLICT (catalog_key, entry_id) DO UPDATE
SET audit_run_at = now(), checks = EXCLUDED.checks, audit_status = EXCLUDED.audit_status, audit_notes = EXCLUDED.audit_notes;

INSERT INTO public.srd_catalog_entry_audit (catalog_key, entry_id, checks, audit_status, audit_notes)
SELECT 'conditions', c.condition_id,
       jsonb_build_object('name_ok', nullif(btrim(coalesce(c.name, '')), '') IS NOT NULL,
                          'summary_ok', nullif(btrim(coalesce(c.summary, '')), '') IS NOT NULL),
       'ready_for_manual_review',
       'Auditoria estrutural; efeitos mecânicos ainda pendentes.'
FROM public.srd_conditions AS c
ON CONFLICT (catalog_key, entry_id) DO UPDATE
SET audit_run_at = now(), checks = EXCLUDED.checks, audit_status = EXCLUDED.audit_status, audit_notes = EXCLUDED.audit_notes;

INSERT INTO public.srd_catalog_entry_audit (catalog_key, entry_id, checks, audit_status, audit_notes)
SELECT 'domains', d.domain_id,
       jsonb_build_object('name_ok', nullif(btrim(coalesce(d.name, '')), '') IS NOT NULL,
                          'power_ok', nullif(btrim(coalesce(d.granted_power_summary, '')), '') IS NOT NULL),
       'ready_for_manual_review',
       'Auditoria estrutural; poderes e vínculos de magias ainda pendentes.'
FROM public.srd_domains AS d
ON CONFLICT (catalog_key, entry_id) DO UPDATE
SET audit_run_at = now(), checks = EXCLUDED.checks, audit_status = EXCLUDED.audit_status, audit_notes = EXCLUDED.audit_notes;

INSERT INTO public.srd_catalog_entry_audit (catalog_key, entry_id, checks, audit_status, audit_notes)
SELECT 'class_features', f.class_id || ':' || f.class_level || ':' || f.feature_key,
       jsonb_build_object('name_ok', nullif(btrim(coalesce(f.name, '')), '') IS NOT NULL,
                          'summary_ok', nullif(btrim(coalesce(f.summary, '')), '') IS NOT NULL),
       'ready_for_manual_review',
       'Auditoria estrutural; execução mecânica ainda pendente.'
FROM public.srd_class_level_features AS f
ON CONFLICT (catalog_key, entry_id) DO UPDATE
SET audit_run_at = now(), checks = EXCLUDED.checks, audit_status = EXCLUDED.audit_status, audit_notes = EXCLUDED.audit_notes;

COMMIT;