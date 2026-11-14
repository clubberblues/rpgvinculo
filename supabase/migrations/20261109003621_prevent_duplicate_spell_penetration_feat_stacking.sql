
CREATE OR REPLACE FUNCTION priv.srd_spell_penetration_feat_bonus(p_character_id text)
RETURNS integer
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  SELECT COALESCE(SUM(per_feat.value),0)::integer
  FROM (
    SELECT feat.id, MAX((effect.value->>'value')::integer) AS value
    FROM public.srd_character_sheets AS sheet
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(sheet.talentos)='array'
        THEN sheet.talentos ELSE '[]'::jsonb END
    ) AS chosen(value)
    JOIN public.srd_feats AS feat
      ON feat.id=COALESCE(chosen.value->>'id',chosen.value #>> '{}')
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(feat.mechanics#>'{resolution,effects}')='array'
        THEN feat.mechanics#>'{resolution,effects}' ELSE '[]'::jsonb END
    ) AS effect(value)
    WHERE sheet.character_id::text=BTRIM(p_character_id)
      AND feat.mechanics->>'engine_status' IN ('ready','implemented')
      AND feat.mechanics->'activation'->>'mode'='passive'
      AND effect.value->>'kind'='modifier'
      AND effect.value->>'stat'='spell_penetration'
      AND COALESCE(effect.value->>'value','') ~ '^[0-9]+$'
    GROUP BY feat.id
  ) AS per_feat;
$function$;
