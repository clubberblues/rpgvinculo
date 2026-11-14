
CREATE OR REPLACE FUNCTION priv.srd_feat_saving_throw_modifier(p_feats jsonb, p_save text)
RETURNS integer
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  WITH selected_feats AS (
    SELECT DISTINCT feat.id, feat.mechanics
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(p_feats)='array' THEN p_feats ELSE '[]'::jsonb END
    ) AS selected(value)
    JOIN public.srd_feats feat
      ON feat.id=COALESCE(selected.value->>'id',selected.value #>> '{}')
    WHERE feat.mechanics->>'engine_status' IN ('ready','implemented')
      AND feat.mechanics #>> '{activation,mode}'='passive'
  ),
  feat_modifiers AS (
    SELECT selected_feats.id AS feat_id,
           COALESCE(NULLIF(eff.elem->>'bonus_type',''),'untyped') AS bonus_type,
           MAX((eff.elem->>'value')::numeric) AS feat_value
    FROM selected_feats
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(selected_feats.mechanics #> '{resolution,effects}')='array'
           THEN selected_feats.mechanics #> '{resolution,effects}' ELSE '[]'::jsonb END
    ) AS eff(elem)
    WHERE eff.elem->>'kind'='modifier'
      AND eff.elem->>'stat'=lower(COALESCE(p_save,''))
      AND COALESCE(eff.elem->>'value','') ~ '^-?[0-9]{1,3}$'
    GROUP BY selected_feats.id,COALESCE(NULLIF(eff.elem->>'bonus_type',''),'untyped')
  ),
  grouped AS (
    SELECT bonus_type,
           CASE WHEN bonus_type IN ('untyped','dodge','circumstance')
                THEN SUM(feat_value) ELSE MAX(feat_value) END AS total_value
    FROM feat_modifiers
    GROUP BY bonus_type
  )
  SELECT COALESCE(SUM(total_value),0)::integer
  FROM grouped;
$function$;
