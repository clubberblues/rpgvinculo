BEGIN;
CREATE TABLE IF NOT EXISTS public.srd_equipment_audit (
 equipment_id text PRIMARY KEY REFERENCES public.srd_equipment(id) ON DELETE CASCADE,
 audit_run_at timestamptz NOT NULL DEFAULT now(),
 has_name boolean NOT NULL,has_category boolean NOT NULL,has_price boolean NOT NULL,has_weight boolean NOT NULL,has_description boolean NOT NULL,has_source boolean NOT NULL,has_technical_data boolean NOT NULL,
 audit_status text NOT NULL CHECK (audit_status IN ('ready_for_manual_review','needs_data_fix','manual_verified')),
 audit_notes text NOT NULL DEFAULT ''
);
INSERT INTO public.srd_equipment_audit (equipment_id,has_name,has_category,has_price,has_weight,has_description,has_source,has_technical_data,audit_status,audit_notes)
SELECT e.id,
 nullif(btrim(coalesce(e.nome,'')),'') is not null,
 nullif(btrim(coalesce(e.categoria,'')),'') is not null,
 e.preco is not null,e.peso is not null,
 nullif(btrim(coalesce(e.descricao,'')),'') is not null,
 nullif(btrim(coalesce(e.srd_source_url,'')),'') is not null,
 EXISTS (SELECT 1 FROM jsonb_each(coalesce(e.detalhes,'{}'::jsonb))),
 CASE WHEN nullif(btrim(coalesce(e.nome,'')),'') is not null AND nullif(btrim(coalesce(e.categoria,'')),'') is not null AND e.preco is not null AND e.peso is not null AND nullif(btrim(coalesce(e.descricao,'')),'') is not null AND nullif(btrim(coalesce(e.srd_source_url,'')),'') is not null AND EXISTS (SELECT 1 FROM jsonb_each(coalesce(e.detalhes,'{}'::jsonb))) THEN 'ready_for_manual_review' ELSE 'needs_data_fix' END,
 concat_ws('; ',CASE WHEN nullif(btrim(coalesce(e.nome,'')),'') is null THEN 'nome ausente' END,CASE WHEN nullif(btrim(coalesce(e.categoria,'')),'') is null THEN 'categoria ausente' END,CASE WHEN e.preco is null THEN 'preço ausente' END,CASE WHEN e.peso is null THEN 'peso ausente' END,CASE WHEN nullif(btrim(coalesce(e.descricao,'')),'') is null THEN 'descrição ausente' END,CASE WHEN nullif(btrim(coalesce(e.srd_source_url,'')),'') is null THEN 'fonte ausente' END,CASE WHEN NOT EXISTS (SELECT 1 FROM jsonb_each(coalesce(e.detalhes,'{}'::jsonb))) THEN 'dados técnicos ausentes' END)
FROM public.srd_equipment e
ON CONFLICT (equipment_id) DO UPDATE SET audit_run_at=now(),has_name=excluded.has_name,has_category=excluded.has_category,has_price=excluded.has_price,has_weight=excluded.has_weight,has_description=excluded.has_description,has_source=excluded.has_source,has_technical_data=excluded.has_technical_data,audit_status=excluded.audit_status,audit_notes=excluded.audit_notes;
COMMIT;