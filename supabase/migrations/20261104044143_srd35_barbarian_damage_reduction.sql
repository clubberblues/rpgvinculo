-- Aplica redução de dano passiva do Bárbaro em todos os fluxos que usam srd_adjust_damage.
CREATE OR REPLACE FUNCTION priv.srd_adjust_damage(p_campaign_id bigint, p_target_kind text, p_target_id text, p_damage_type text, p_base_damage integer)
 RETURNS integer
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_type text:=lower(COALESCE(NULLIF(BTRIM(p_damage_type),''),'untyped'));
  v_immune boolean:=false;
  v_vulnerable boolean:=false;
  v_resistance integer:=0;
  v_damage integer;
  v_class_level integer:=0;
  v_class_dr integer:=0;
BEGIN
  IF p_base_damage IS NULL OR p_base_damage<0 OR p_base_damage>100000 THEN
    RAISE EXCEPTION 'Quantidade de dano inválida.';
  END IF;
  IF p_campaign_id IS NULL OR NULLIF(BTRIM(p_target_id),'') IS NULL THEN
    RETURN p_base_damage;
  END IF;
  v_type:=CASE v_type
    WHEN 'cortante' THEN 'slashing'
    WHEN 'perfurante' THEN 'piercing'
    WHEN 'impacto' THEN 'bludgeoning'
    WHEN 'cortante/perfurante' THEN 'physical'
    WHEN 'impacto/perfurante' THEN 'physical'
    ELSE v_type END;

  SELECT
    COALESCE(bool_or(a.value->>'mode'='immunity'),false),
    COALESCE(bool_or(a.value->>'mode'='vulnerability'),false),
    COALESCE(max(CASE WHEN a.value->>'mode'='resistance'
                      AND COALESCE(a.value->>'value','') ~ '^[0-9]{1,4}$'
                      THEN (a.value->>'value')::integer ELSE 0 END),0)
  INTO v_immune,v_vulnerable,v_resistance
  FROM public.srd_campaign_effects e
  CROSS JOIN LATERAL jsonb_array_elements(
    CASE WHEN jsonb_typeof(e.effect_data->'damage_adjustments')='array'
         THEN e.effect_data->'damage_adjustments' ELSE '[]'::jsonb END
  ) a(value)
  WHERE e.campaign_id=p_campaign_id
    AND e.target_kind=p_target_kind
    AND e.target_id=p_target_id
    AND e.active=true
    AND (
      a.value->>'damage_type'='all'
      OR a.value->>'damage_type'=v_type
      OR (a.value->>'damage_type'='physical' AND v_type IN ('slashing','piercing','bludgeoning'))
    );

  IF v_immune THEN RETURN 0; END IF;

  -- D&D 3.5: redução de dano do Bárbaro (1/— no nível 7,
  -- aumentando +1 a cada três níveis; máximo 5/— no nível 19).
  -- Só reduz dano físico; não reduz energia, ácido, fogo, frio etc.
  IF p_target_kind='character' AND v_type IN ('physical','slashing','piercing','bludgeoning') THEN
    SELECT COALESCE(
      MAX(cl.class_level) FILTER (WHERE cl.class_id='barbaro'),
      CASE WHEN sh.classe_id='barbaro' THEN sh.nivel ELSE 0 END
    )
      INTO v_class_level
      FROM public.srd_character_sheets sh
      LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
     WHERE sh.character_id::text=BTRIM(p_target_id)
     GROUP BY sh.character_id,sh.classe_id,sh.nivel;
    IF v_class_level>=7 THEN
      v_class_dr:=LEAST(5,GREATEST(0,FLOOR((v_class_level-4)::numeric/3)::integer));
    END IF;
  END IF;

  v_damage:=GREATEST(0,p_base_damage-v_resistance-v_class_dr);
  IF v_vulnerable THEN v_damage:=FLOOR(v_damage*1.5)::integer; END IF;
  RETURN v_damage;
END;
$function$
;