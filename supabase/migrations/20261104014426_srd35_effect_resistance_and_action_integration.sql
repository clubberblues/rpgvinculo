
CREATE OR REPLACE FUNCTION priv.srd_adjust_damage(
  p_campaign_id bigint,
  p_target_kind text,
  p_target_id text,
  p_damage_type text,
  p_base_damage integer
)
RETURNS integer
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, pg_temp
AS $function$
DECLARE
  v_type text:=lower(COALESCE(NULLIF(BTRIM(p_damage_type),''),'untyped'));
  v_immune boolean:=false;
  v_vulnerable boolean:=false;
  v_resistance integer:=0;
  v_damage integer;
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
  v_damage:=GREATEST(0,p_base_damage-v_resistance);
  IF v_vulnerable THEN v_damage:=FLOOR(v_damage*1.5)::integer; END IF;
  RETURN v_damage;
END;
$function$;

DO $patch_effect_validation$
DECLARE
  v_definition text;
  v_marker text:='  v_stack_key:=NULLIF(BTRIM(p_effect_data->>''stacking_key''),'''');';
  v_validation text:=$validation$
  IF p_effect_data ? 'damage_adjustments' THEN
    IF jsonb_typeof(p_effect_data->'damage_adjustments')<>'array' THEN
      RAISE EXCEPTION 'damage_adjustments deve ser uma lista.';
    END IF;
    FOR v_modifier IN SELECT value FROM jsonb_array_elements(p_effect_data->'damage_adjustments')
    LOOP
      IF jsonb_typeof(v_modifier)<>'object'
         OR COALESCE(v_modifier->>'damage_type','') !~ '^(all|physical|slashing|piercing|bludgeoning|acid|cold|electricity|fire|sonic|force|positive|negative|untyped)$'
         OR COALESCE(v_modifier->>'mode','') NOT IN ('immunity','resistance','vulnerability') THEN
        RAISE EXCEPTION 'Regra de resistência ou imunidade inválida.';
      END IF;
      IF v_modifier->>'mode'='resistance'
         AND (COALESCE(v_modifier->>'value','') !~ '^[0-9]{1,4}$'
              OR (v_modifier->>'value')::integer NOT BETWEEN 1 AND 10000) THEN
        RAISE EXCEPTION 'Valor de resistência inválido.';
      END IF;
    END LOOP;
  END IF;

$validation$;
BEGIN
  SELECT pg_get_functiondef('priv.srd_apply_campaign_effect(bigint,text,text,text,jsonb,integer,text,text)'::regprocedure)
    INTO v_definition;
  IF position(v_marker IN v_definition)=0 THEN
    RAISE EXCEPTION 'Não foi possível localizar a validação do motor de efeitos.';
  END IF;
  IF position('damage_adjustments' IN v_definition)>0 THEN RETURN; END IF;
  v_definition:=replace(v_definition,v_marker,v_validation||v_marker);
  EXECUTE v_definition;
END;
$patch_effect_validation$;

DO $patch_attack$
DECLARE
  v_definition text;
  v_marker text;
  v_replacement text;
BEGIN
  SELECT pg_get_functiondef('public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer)'::regprocedure)
    INTO v_definition;

  v_marker:=' v_weapon_name TEXT;';
  IF position(v_marker IN v_definition)=0 THEN
    RAISE EXCEPTION 'Não foi possível localizar as variáveis do resolvedor de ataque.';
  END IF;
  v_definition:=replace(v_definition,v_marker,
    v_marker || E'\n v_effective_attack_modifier INTEGER:=0; v_effective_ac_modifier INTEGER:=0; v_damage_final INTEGER:=0; v_damage_type TEXT;');

  v_marker:=' IF p_bonus_ataque<>v_expected_bonus THEN RAISE EXCEPTION ''Bônus de ataque não confere com a ficha. Esperado: %, recebido: %.'',v_expected_bonus,p_bonus_ataque; END IF;';
  IF position(v_marker IN v_definition)=0 THEN
    RAISE EXCEPTION 'Não foi possível localizar a validação do bônus de ataque.';
  END IF;
  v_definition:=replace(v_definition,v_marker,
    v_marker || E'\n v_effective_attack_modifier:=priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''attack'');');

  v_marker:=' v_ca:=substring(v_ca_text from ''[0-9]{1,3}'')::INTEGER; v_attack_total:=p_d20+v_expected_bonus;';
  IF position(v_marker IN v_definition)=0 THEN
    RAISE EXCEPTION 'Não foi possível localizar o cálculo da CA e ataque.';
  END IF;
  v_definition:=replace(v_definition,v_marker,
    ' v_effective_ac_modifier:=priv.srd_effective_modifier(p_campaign_id,''token'',BTRIM(p_token_id),''ac'');' || E'\n' ||
    ' v_ca:=substring(v_ca_text from ''[0-9]{1,3}'')::INTEGER+v_effective_ac_modifier; v_attack_total:=p_d20+v_expected_bonus+v_effective_attack_modifier;');

  v_marker:=' v_new_hp:=GREATEST(0,LEAST(v_max_hp,v_hp-p_dano));';
  IF position(v_marker IN v_definition)=0 THEN
    RAISE EXCEPTION 'Não foi possível localizar a aplicação do dano do ataque.';
  END IF;
  v_replacement:=E' v_damage_type:=CASE lower(COALESCE(v_weapon.tipo_dano,''bludgeoning'')) WHEN ''cortante'' THEN ''slashing'' WHEN ''perfurante'' THEN ''piercing'' WHEN ''impacto'' THEN ''bludgeoning'' WHEN ''cortante/perfurante'' THEN ''physical'' WHEN ''impacto/perfurante'' THEN ''physical'' ELSE lower(COALESCE(v_weapon.tipo_dano,''bludgeoning'')) END;\n' ||
    ' v_damage_final:=priv.srd_adjust_damage(p_campaign_id,''token'',BTRIM(p_token_id),v_damage_type,GREATEST(0,p_dano+priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''damage'')));' || E'\n' ||
    ' v_new_hp:=GREATEST(0,LEAST(v_max_hp,v_hp-v_damage_final));';
  v_definition:=replace(v_definition,v_marker,v_replacement);

  v_marker:='''damage'',p_dano';
  IF position(v_marker IN v_definition)>0 THEN
    v_definition:=replace(v_definition,v_marker,'''damage'',v_damage_final,''damage_roll'',p_dano,''attack_effect_modifier'',v_effective_attack_modifier,''target_ac_modifier'',v_effective_ac_modifier');
  END IF;
  EXECUTE v_definition;
END;
$patch_attack$;

DO $patch_magic_missile$
DECLARE
  v_definition text;
  v_marker text;
BEGIN
  SELECT pg_get_functiondef('public.conjurar_missil_magico_srd(text,text,smallint,text,integer)'::regprocedure)
    INTO v_definition;
  v_marker:='  v_new_hp INTEGER;';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Declaração de PV do Míssil Mágico não localizada.'; END IF;
  IF position('v_damage_final' IN v_definition)>0 THEN RETURN; END IF;
  v_definition:=replace(v_definition,v_marker,v_marker || E'\n  v_damage_final INTEGER;');

  v_marker:='    v_new_hp:=GREATEST(0,COALESCE(v_hp,v_max_hp)-p_damage);';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Cálculo de dano do alvo jogador não localizado.'; END IF;
  v_definition:=replace(v_definition,v_marker,
    E'    v_damage_final:=priv.srd_adjust_damage(v_character.campaign_id,''character'',v_token->>''id'',''force'',p_damage);\n' ||
    '    v_new_hp:=GREATEST(0,COALESCE(v_hp,v_max_hp)-v_damage_final);');

  v_marker:='    v_new_hp:=GREATEST(0,v_hp-p_damage);';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Cálculo de dano do alvo NPC/monstro não localizado.'; END IF;
  v_definition:=replace(v_definition,v_marker,
    E'    v_damage_final:=priv.srd_adjust_damage(v_character.campaign_id,''token'',BTRIM(p_target_token_key),''force'',p_damage);\n' ||
    '    v_new_hp:=GREATEST(0,v_hp-v_damage_final);');

  EXECUTE v_definition;
END;
$patch_magic_missile$;

DO $patch_potion_healing$
DECLARE
  v_definition text;
  v_marker text:=' SELECT v_flat+sum(value) INTO v_healing FROM unnest(p_roll_results) value;';
BEGIN
  SELECT pg_get_functiondef('public.usar_pocao_cura_srd_manual(text,text,integer[])'::regprocedure)
    INTO v_definition;
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Cálculo da cura da poção não localizado.'; END IF;
  IF position('healing_received' IN v_definition)>0 THEN RETURN; END IF;
  v_definition:=replace(v_definition,v_marker,
    v_marker || E'\n v_healing:=GREATEST(0,v_healing+priv.srd_effective_modifier(v_campaign_id,''character'',BTRIM(p_character_id),''healing_received''));');
  EXECUTE v_definition;
END;
$patch_potion_healing$;

DO $patch_spell_healing$
DECLARE
  v_definition text;
  v_marker text:='    v_healing:=greatest(0,v_roll+v_per_level*v_level_bonus);';
BEGIN
  SELECT pg_get_functiondef('public.conjurar_magia_srd_manual(text,text,smallint,text,integer[])'::regprocedure)
    INTO v_definition;
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Cálculo da cura mágica não localizado.'; END IF;
  IF position('healing_received' IN v_definition)>0 THEN RETURN; END IF;
  v_definition:=replace(v_definition,v_marker,
    v_marker || E'\n    IF v_target_character_id IS NOT NULL THEN\n      v_healing:=GREATEST(0,v_healing+priv.srd_effective_modifier(v_campaign_id,''character'',v_target_character_id,''healing_received''));\n    ELSIF v_target_key IS NOT NULL THEN\n      v_healing:=GREATEST(0,v_healing+priv.srd_effective_modifier(v_campaign_id,''token'',v_target_key,''healing_received''));\n    END IF;');
  EXECUTE v_definition;
END;
$patch_spell_healing$;

REVOKE ALL ON FUNCTION priv.srd_adjust_damage(bigint,text,text,text,integer) FROM PUBLIC, anon, authenticated;
