
UPDATE public.srd_feats
SET mechanics = jsonb_build_object(
  'schema_version', 1,
  'engine_status', 'needs_review',
  'activation', jsonb_build_object('mode','unclassified','action_type','unknown'),
  'requirements', COALESCE(requisitos,'{}'::jsonb),
  'resolution', jsonb_build_object('effects','[]'::jsonb),
  'source', jsonb_build_object('source_id',source_id,'source_status',source_status,'source_url',srd_source_url),
  'source_text', COALESCE(descricao,''),
  'review_reason', 'Texto SRD preservado; classificar modo de ativação e mapear efeitos antes de liberar execução.'
)
WHERE mechanics = '{}'::jsonb;

UPDATE public.monsters
SET mechanics = jsonb_build_object(
  'schema_version', 1,
  'engine_status', 'needs_review',
  'activation', jsonb_build_object('mode','unclassified','action_type','unknown'),
  'target', jsonb_build_object('description',COALESCE(alvo,''),'range',COALESCE(alcance,'')),
  'duration', jsonb_build_object('description',COALESCE(duracao,'')),
  'resolution', jsonb_build_object('effects','[]'::jsonb),
  'source', jsonb_build_object('source_id',id,'source_status','legacy_catalog'),
  'source_text', concat_ws(E'\n',NULLIF(habilidade,''),NULLIF(efeito,''),NULLIF(condicao,''),NULLIF(limitacoes,'')),
  'source_data', jsonb_build_object('habilidade',habilidade,'efeito',efeito,'condicao',condicao,'limitacoes',limitacoes),
  'review_reason', 'Campos legados preservados; converter cada habilidade em efeitos e resolução validados antes da execução.'
)
WHERE mechanics = '{}'::jsonb;

UPDATE public.srd_monsters
SET mechanics = jsonb_build_object(
  'schema_version', 1,
  'engine_status', 'needs_review',
  'activation', jsonb_build_object('mode','unclassified','action_type','unknown'),
  'resolution', jsonb_build_object('effects','[]'::jsonb),
  'source', jsonb_build_object('source_id',source_id,'source_status',source_status,'source_url',srd_source_url),
  'source_text', concat_ws(E'\n',COALESCE(qualidades_especiais::text,''),COALESCE(dados_tecnicos->>'special_attacks',''),COALESCE(dados_tecnicos->>'special_qualities','')),
  'source_data', jsonb_build_object('qualidades_especiais',qualidades_especiais,'dados_tecnicos',dados_tecnicos,'talentos',talentos),
  'review_reason', 'Dados SRD preservados; classificar cada habilidade especial e mapear efeitos/limites antes da execução.'
)
WHERE mechanics = '{}'::jsonb;

SELECT 'srd_feats' AS catalog, count(*) AS total, count(*) FILTER (WHERE mechanics->>'engine_status'='needs_review') AS queued FROM public.srd_feats
UNION ALL SELECT 'monsters',count(*),count(*) FILTER (WHERE mechanics->>'engine_status'='needs_review') FROM public.monsters
UNION ALL SELECT 'srd_monsters',count(*),count(*) FILTER (WHERE mechanics->>'engine_status'='needs_review') FROM public.srd_monsters;
