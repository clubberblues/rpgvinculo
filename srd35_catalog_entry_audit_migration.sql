BEGIN;
CREATE TABLE IF NOT EXISTS public.srd_catalog_entry_audit (
 catalog_key text NOT NULL,
 entry_id text NOT NULL,
 audit_run_at timestamptz NOT NULL DEFAULT now(),
 checks jsonb NOT NULL,
 audit_status text NOT NULL CHECK (audit_status IN ('ready_for_manual_review','needs_data_fix','manual_verified','not_applicable_or_unspecified')),
 audit_notes text NOT NULL DEFAULT '',
 PRIMARY KEY (catalog_key,entry_id)
);
INSERT INTO public.srd_catalog_entry_audit(catalog_key,entry_id,checks,audit_status,audit_notes)
SELECT 'feats',id,jsonb_build_object('name',nullif(btrim(coalesce(nome,'')),'') is not null,'description',nullif(btrim(coalesce(descricao,'')),'') is not null,'requirements',jsonb_typeof(coalesce(requisitos,'{}'::jsonb))='object','source',nullif(btrim(coalesce(srd_source_url,'')),'') is not null),
CASE WHEN nullif(btrim(coalesce(nome,'')),'') is not null AND nullif(btrim(coalesce(descricao,'')),'') is not null AND jsonb_typeof(coalesce(requisitos,'{}'::jsonb))='object' AND nullif(btrim(coalesce(srd_source_url,'')),'') is not null THEN 'ready_for_manual_review' ELSE 'needs_data_fix' END,'Auditoria estrutural; conferência de pré-requisitos contra o SRD ainda pendente.') FROM public.srd_feats
ON CONFLICT(catalog_key,entry_id) DO UPDATE SET audit_run_at=now(),checks=excluded.checks,audit_status=excluded.audit_status,audit_notes=excluded.audit_notes;
INSERT INTO public.srd_catalog_entry_audit(catalog_key,entry_id,checks,audit_status,audit_notes)
SELECT 'monsters',id,jsonb_build_object('name',nullif(btrim(coalesce(nome,'')),'') is not null,'ca',nullif(btrim(coalesce(ca,'')),'') is not null,'hp',pv is not null,'attacks',nullif(btrim(coalesce(ataques,'')),'') is not null,'source',nullif(btrim(coalesce(srd_source_url,'')),'') is not null),
CASE WHEN nullif(btrim(coalesce(nome,'')),'') is not null AND nullif(btrim(coalesce(ca,'')),'') is not null AND pv is not null AND nullif(btrim(coalesce(ataques,'')),'') is not null AND nullif(btrim(coalesce(srd_source_url,'')),'') is not null THEN 'ready_for_manual_review' ELSE 'needs_data_fix' END,'Auditoria estrutural; habilidades e regras especiais ainda precisam de conferência individual.') FROM public.srd_monsters
ON CONFLICT(catalog_key,entry_id) DO UPDATE SET audit_run_at=now(),checks=excluded.checks,audit_status=excluded.audit_status,audit_notes=excluded.audit_notes;
INSERT INTO public.srd_catalog_entry_audit(catalog_key,entry_id,checks,audit_status,audit_notes)
SELECT 'skills',id,jsonb_build_object('name',nullif(btrim(coalesce(nome,'')),'') is not null,'description',nullif(btrim(coalesce(descricao,'')),'') is not null,'source',nullif(btrim(coalesce(srd_source_url,'')),'') is not null),
CASE WHEN nullif(btrim(coalesce(nome,'')),'') is not null AND nullif(btrim(coalesce(descricao,'')),'') is not null AND nullif(btrim(coalesce(srd_source_url,'')),'') is not null THEN 'ready_for_manual_review' ELSE 'needs_data_fix' END,'Auditoria estrutural; usos, sinergias e regras de treinamento ainda pendentes.') FROM public.srd_skills
ON CONFLICT(catalog_key,entry_id) DO UPDATE SET audit_run_at=now(),checks=excluded.checks,audit_status=excluded.audit_status,audit_notes=excluded.audit_notes;
INSERT INTO public.srd_catalog_entry_audit(catalog_key,entry_id,checks,audit_status,audit_notes)
SELECT 'spells',id,jsonb_build_object('name',nullif(btrim(coalesce(nome,'')),'') is not null,'description',nullif(btrim(coalesce(descricao,'')),'') is not null,'level',nivel is not null,'source',nullif(btrim(coalesce(srd_source_url,'')),'') is not null),
CASE WHEN nullif(btrim(coalesce(nome,'')),'') is not null AND nullif(btrim(coalesce(descricao,'')),'') is not null AND nivel is not null AND nullif(btrim(coalesce(srd_source_url,'')),'') is not null THEN 'ready_for_manual_review' ELSE 'needs_data_fix' END,'Auditoria estrutural; efeitos, resistência, duração e componentes ainda pendentes.') FROM public.srd_spells
ON CONFLICT(catalog_key,entry_id) DO UPDATE SET audit_run_at=now(),checks=excluded.checks,audit_status=excluded.audit_status,audit_notes=excluded.audit_notes;
INSERT INTO public.srd_catalog_entry_audit(catalog_key,entry_id,checks,audit_status,audit_notes)
SELECT 'conditions',condition_id,jsonb_build_object('name',nullif(btrim(coalesce(name,'')),'') is not null,'summary',nullif(btrim(coalesce(summary,'')),'') is not null,'mechanics',jsonb_typeof(coalesce(mechanical_effects,'{}'::jsonb))='object','source',nullif(btrim(coalesce(source_url,'')),'') is not null),
CASE WHEN nullif(btrim(coalesce(name,'')),'') is not null AND nullif(btrim(coalesce(summary,'')),'') is not null AND nullif(btrim(coalesce(source_url,'')),'') is not null THEN 'ready_for_manual_review' ELSE 'needs_data_fix' END,'Auditoria estrutural; efeitos mecânicos ainda pendentes.') FROM public.srd_conditions
ON CONFLICT(catalog_key,entry_id) DO UPDATE SET audit_run_at=now(),checks=excluded.checks,audit_status=excluded.audit_status,audit_notes=excluded.audit_notes;
INSERT INTO public.srd_catalog_entry_audit(catalog_key,entry_id,checks,audit_status,audit_notes)
SELECT 'domains',domain_id,jsonb_build_object('name',nullif(btrim(coalesce(name,'')),'') is not null,'power',nullif(btrim(coalesce(granted_power_summary,'')),'') is not null,'mechanics',jsonb_typeof(coalesce(mechanics,'{}'::jsonb))='object','source',nullif(btrim(coalesce(source_url,'')),'') is not null),
CASE WHEN nullif(btrim(coalesce(name,'')),'') is not null AND nullif(btrim(coalesce(source_url,'')),'') is not null THEN 'ready_for_manual_review' ELSE 'needs_data_fix' END,'Auditoria estrutural; poderes e vínculos de magias ainda pendentes.') FROM public.srd_domains
ON CONFLICT(catalog_key,entry_id) DO UPDATE SET audit_run_at=now(),checks=excluded.checks,audit_status=excluded.audit_status,audit_notes=excluded.audit_notes;
INSERT INTO public.srd_catalog_entry_audit(catalog_key,entry_id,checks,audit_status,audit_notes)
SELECT 'class_features',class_id||':'||class_level||':'||feature_key,jsonb_build_object('name',nullif(btrim(coalesce(name,'')),'') is not null,'summary',nullif(btrim(coalesce(summary,'')),'') is not null,'mechanics',jsonb_typeof(coalesce(mechanics,'{}'::jsonb))='object','source',nullif(btrim(coalesce(source_id,'')),'') is not null),
CASE WHEN nullif(btrim(coalesce(name,'')),'') is not null AND nullif(btrim(coalesce(summary,'')),'') is not null THEN 'ready_for_manual_review' ELSE 'needs_data_fix' END,'Auditoria estrutural; execução mecânica das características ainda pendente.') FROM public.srd_class_level_features
ON CONFLICT(catalog_key,entry_id) DO UPDATE SET audit_run_at=now(),checks=excluded.checks,audit_status=excluded.audit_status,audit_notes=excluded.audit_notes;
COMMIT;