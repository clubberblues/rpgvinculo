-- Trata damage_components ausente/nulo como dano de componente único.
CREATE OR REPLACE FUNCTION priv.srd_adjust_damage_components(p_campaign_id bigint, p_target_kind text, p_target_id text, p_effect_data jsonb)
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_base integer:=GREATEST(0,COALESCE(NULLIF(p_effect_data->>'damage','')::integer,0));
  v_components jsonb:=p_effect_data->'damage_components';
  v_component jsonb;
  v_component_type text;
  v_component_ratio numeric;
  v_component_amount integer;
  v_component_count integer;
  v_allocated integer:=0;
  v_total integer:=0;
  v_ratio_sum numeric:=0;
  v_ord integer; v_explicit_amount integer; v_component_has_amount boolean:=false;
BEGIN
  IF COALESCE(jsonb_typeof(v_components),'null')<>'array' THEN
    RETURN priv.srd_adjust_damage(p_campaign_id,p_target_kind,p_target_id,
      COALESCE(NULLIF(p_effect_data->>'damage_type',''),'untyped'),v_base);
  END IF;
  v_component_count:=jsonb_array_length(v_components);
  IF v_component_count<1 OR v_component_count>8 THEN RAISE EXCEPTION 'Componentes de dano inválidos.'; END IF;
  v_component_has_amount:=COALESCE((v_components->0) ? 'amount',false);
  IF NOT v_component_has_amount THEN
    SELECT COALESCE(SUM((value->>'ratio')::numeric),0)
      INTO v_ratio_sum FROM jsonb_array_elements(v_components);
    IF ABS(v_ratio_sum-1.0)>0.001 THEN RAISE EXCEPTION 'As proporções dos componentes de dano devem somar 1.'; END IF;
  END IF;
  FOR v_component,v_ord IN
    SELECT value,ordinality::integer
    FROM jsonb_array_elements(v_components) WITH ORDINALITY
  LOOP
    v_component_type:=COALESCE(NULLIF(v_component->>'damage_type',''),'untyped');
    IF v_component_type='mixed' THEN RAISE EXCEPTION 'Tipo de componente de dano inválido.'; END IF;
    IF v_component_type='' THEN RAISE EXCEPTION 'Tipo de componente de dano inválido.'; END IF;
    IF v_component_has_amount THEN
      v_explicit_amount:=COALESCE(NULLIF(v_component->>'amount','')::integer,0);
      IF v_explicit_amount<0 THEN RAISE EXCEPTION 'Quantidade de dano por componente inválida.'; END IF;
      v_component_amount:=v_explicit_amount;
    ELSE
      v_component_ratio:=COALESCE((v_component->>'ratio')::numeric,0);
      IF v_component_ratio<0 OR v_component_ratio>1 THEN RAISE EXCEPTION 'Proporção de dano inválida.'; END IF;
      IF v_ord=v_component_count THEN
        v_component_amount:=v_base-v_allocated;
      ELSE
        v_component_amount:=FLOOR(v_base*v_component_ratio)::integer;
      END IF;
    END IF;
    v_allocated:=v_allocated+v_component_amount;
    v_total:=v_total+priv.srd_adjust_damage(p_campaign_id,p_target_kind,p_target_id,v_component_type,v_component_amount);
  END LOOP;
  IF v_component_has_amount AND v_allocated<>v_base THEN
    RAISE EXCEPTION 'A soma dos componentes (%) não corresponde ao dano total (%).',v_allocated,v_base;
  END IF;
  RETURN GREATEST(0,v_total);
END;
$function$
;
