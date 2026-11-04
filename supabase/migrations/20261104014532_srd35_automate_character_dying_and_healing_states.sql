
CREATE OR REPLACE FUNCTION priv.srd_sync_character_vital_condition(
  p_character_id text,
  p_pv integer,
  p_stabilize boolean DEFAULT false
)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, pg_temp
AS $function$
DECLARE
  v_campaign_id bigint;
  v_round integer;
  v_condition text;
BEGIN
  SELECT campaign_id INTO v_campaign_id
  FROM public.characters
  WHERE id::text=BTRIM(p_character_id);
  IF NOT FOUND OR v_campaign_id IS NULL THEN RETURN NULL; END IF;

  v_condition:=CASE
    WHEN p_pv<=-10 THEN 'dead'
    WHEN p_pv<0 AND p_stabilize THEN 'stable'
    WHEN p_pv<0 THEN 'dying'
    WHEN p_pv=0 THEN 'disabled'
    ELSE NULL END;

  UPDATE public.srd_campaign_conditions
     SET active=false
   WHERE campaign_id=v_campaign_id
     AND target_kind='character'
     AND target_id=BTRIM(p_character_id)
     AND condition_id IN ('dead','dying','disabled','stable')
     AND active=true;

  IF v_condition IS NULL THEN RETURN NULL; END IF;

  SELECT GREATEST(1,COALESCE(NULLIF(combat_data->>'round','')::integer,1))
    INTO v_round
    FROM public.campaigns WHERE id=v_campaign_id;

  INSERT INTO public.srd_campaign_conditions(
    campaign_id,target_kind,target_id,condition_id,started_round,expires_round,active,notes
  ) VALUES (
    v_campaign_id,'character',BTRIM(p_character_id),v_condition,
    COALESCE(v_round,1),NULL,true,
    jsonb_build_object('source','hp_state_engine','pv',p_pv,'stabilized',p_stabilize)
  );
  RETURN v_condition;
END;
$function$;

DO $patch_magic_missile_hp$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('public.conjurar_missil_magico_srd(text,text,smallint,text,integer)'::regprocedure)
    INTO v_definition;
  v_marker:='    v_new_hp:=GREATEST(0,COALESCE(v_hp,v_max_hp)-v_damage_final);';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Trecho de PV do alvo jogador em Míssil Mágico não localizado.'; END IF;
  IF position('srd_sync_character_vital_condition' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_marker,
      '    v_new_hp:=GREATEST(-10,COALESCE(v_hp,v_max_hp)-v_damage_final);' || E'\n' ||
      '    PERFORM priv.srd_sync_character_vital_condition(v_token->>''id'',v_new_hp,false);');
  END IF;
  EXECUTE v_definition;
END;
$patch_magic_missile_hp$;

DO $patch_gm_damage_hp$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('public.aplicar_dano_token_gm_personagem_srd(bigint,text,text,integer)'::regprocedure)
    INTO v_definition;
  v_marker:='  v_new_hp INTEGER;';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Declaração de PV do dano do Mestre não localizada.'; END IF;
  IF position('v_damage_final' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_marker,v_marker || E'\n  v_damage_final INTEGER;');
  END IF;
  v_marker:='  v_new_hp:=GREATEST(0,LEAST(v_max_hp,COALESCE(v_hp,v_max_hp)-p_dano));';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Cálculo de dano do Mestre não localizado.'; END IF;
  v_definition:=replace(v_definition,v_marker,
    '  v_damage_final:=priv.srd_adjust_damage(p_campaign_id,''character'',BTRIM(p_character_id),''untyped'',p_dano);' || E'\n' ||
    '  v_new_hp:=GREATEST(-10,LEAST(v_max_hp,COALESCE(v_hp,v_max_hp)-v_damage_final));' || E'\n' ||
    '  PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),v_new_hp,false);');
  v_marker:='''dano'',p_dano';
  IF position(v_marker IN v_definition)>0 THEN
    v_definition:=replace(v_definition,v_marker,'''dano'',v_damage_final,''dano_bruto'',p_dano');
  END IF;
  EXECUTE v_definition;
END;
$patch_gm_damage_hp$;

DO $patch_potion_hp$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('public.usar_pocao_cura_srd_manual(text,text,integer[])'::regprocedure)
    INTO v_definition;
  v_marker:=' UPDATE public.srd_character_sheets SET pv_atual=LEAST(v_max_hp,COALESCE(v_current_hp,0)+v_healing) WHERE character_id::TEXT=BTRIM(p_character_id) RETURNING pv_atual INTO v_current_hp;';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Atualização de PV da poção não localizada.'; END IF;
  IF position('srd_sync_character_vital_condition' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,
      ' IF v_count=1 THEN DELETE FROM public.srd_character_equipment',
      ' IF COALESCE(v_current_hp,0)<=-10 THEN RAISE EXCEPTION ''Personagens mortos não podem receber cura comum.''; END IF;' || E'\n' ||
      ' IF v_count=1 THEN DELETE FROM public.srd_character_equipment');
    v_definition:=replace(v_definition,v_marker,
      ' UPDATE public.srd_character_sheets SET pv_atual=LEAST(v_max_hp,COALESCE(v_current_hp,0)+v_healing) WHERE character_id::TEXT=BTRIM(p_character_id) RETURNING pv_atual INTO v_current_hp;' || E'\n' ||
      ' PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),v_current_hp,v_healing>0);');
  END IF;
  EXECUTE v_definition;
END;
$patch_potion_hp$;

DO $patch_spell_hp$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('public.conjurar_magia_srd_manual(text,text,smallint,text,integer[])'::regprocedure)
    INTO v_definition;
  v_marker:='v_target_hp:=least(v_target_max_hp,greatest(0,coalesce(v_target_hp,0)+v_healing));';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Cálculo de PV da cura mágica não localizado.'; END IF;
  IF position('srd_sync_character_vital_condition' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,
      v_marker,
      'v_target_hp:=CASE WHEN COALESCE(v_target_hp,0)<=-10 THEN COALESCE(v_target_hp,0) ELSE LEAST(v_target_max_hp,COALESCE(v_target_hp,0)+v_healing) END;');
    v_marker:='UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=p_character_id;';
    v_definition:=replace(v_definition,v_marker,
      v_marker || E'\n        PERFORM priv.srd_sync_character_vital_condition(p_character_id,v_target_hp,v_healing>0);');
    v_marker:='UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=v_target_character_id;';
    v_definition:=replace(v_definition,v_marker,
      v_marker || E'\n        PERFORM priv.srd_sync_character_vital_condition(v_target_character_id,v_target_hp,v_healing>0);');
  END IF;
  EXECUTE v_definition;
END;
$patch_spell_hp$;

REVOKE ALL ON FUNCTION priv.srd_sync_character_vital_condition(text,integer,boolean) FROM PUBLIC, anon, authenticated;
