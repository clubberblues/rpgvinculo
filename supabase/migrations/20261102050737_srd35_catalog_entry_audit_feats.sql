BEGIN;
CREATE TABLE IF NOT EXISTS public.srd_catalog_entry_audit (catalog_key text NOT NULL,entry_id text NOT NULL,audit_run_at timestamptz NOT NULL DEFAULT now(),checks jsonb NOT NULL,audit_status text NOT NULL,audit_notes text NOT NULL DEFAULT '',PRIMARY KEY(catalog_key,entry_id));
INSERT INTO public.srd_catalog_entry_audit(catalog_key,entry_id,checks,audit_status,audit_notes)
SELECT 'feats',f.id,jsonb_build_object('name_ok',nullif(btrim(coalesce(f.nome,'')),'') is not null,'description_ok',nullif(btrim(coalesce(f.descricao,'')),'') is not null),'ready_for_manual_review','Auditoria estrutural; pré-requisitos pendentes'
FROM public.srd_feats f
ON CONFLICT (catalog_key,entry_id) DO UPDATE SET audit_run_at=now(),checks=EXCLUDED.checks,audit_status=EXCLUDED.audit_status,audit_notes=EXCLUDED.audit_notes;
COMMIT;