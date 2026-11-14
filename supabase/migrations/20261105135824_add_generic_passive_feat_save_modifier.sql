CREATE OR REPLACE FUNCTION priv.srd_feat_saving_throw_modifier(p_feats jsonb,p_save text)
RETURNS integer
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
  SELECT COALESCE(SUM(
    CASE WHEN grouped.bonus_type IN ('untyped','dodge','circumstance')
         THEN grouped.total_value ELSE grouped.max_value END
  ),0)::integer
  FROM (
    SELECT COALESCE(NULLIF(eff.elem->>'bonus_type',''),'untyped') AS bonus_type,
           SUM((eff.elem->>'value')::numeric) AS total_value,
           MAX((eff.elem->>'value')::numeric) AS max_value
      FROM jsonb_array_elements(
        CASE WHEN jsonb_typeof(p_feats)='array' THEN p_feats ELSE '[]'::jsonb END
      ) AS selected(value)
      JOIN public.srd_feats feat
        ON feat.id=COALESCE(selected.value->>'id',selected.value #>> '{}')
      CROSS JOIN LATERAL jsonb_array_elements(
        CASE WHEN jsonb_typeof(feat.mechanics #> '{resolution,effects}')='array'
             THEN feat.mechanics #> '{resolution,effects}' ELSE '[]'::jsonb END
      ) AS eff(elem)
     WHERE feat.mechanics->>'engine_status' IN ('ready','implemented')
       AND feat.mechanics #>> '{activation,mode}'='passive'
       AND eff.elem->>'kind'='modifier'
       AND eff.elem->>'stat'=lower(COALESCE(p_save,''))
       AND COALESCE(eff.elem->>'value','') ~ '^-?[0-9]{1,3}$'
     GROUP BY COALESCE(NULLIF(eff.elem->>'bonus_type',''),'untyped')
  ) AS grouped;
$function$;
