
DO $patch_potion_no_healing$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('public.usar_pocao_cura_srd_manual(text,text,integer[])'::regprocedure) INTO v_definition;
  v_marker:=' IF COALESCE(v_current_hp,0)<=-10 THEN RAISE EXCEPTION ''Personagens mortos não podem receber cura comum.''; END IF;';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Validação de PV morto na poção não localizada.'; END IF;
  IF position('no_healing' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_marker,
      E' IF priv.srd_condition_has_flag(v_campaign_id,''character'',BTRIM(p_character_id),''no_healing'') THEN RAISE EXCEPTION ''Este alvo não pode receber cura.''; END IF;\n' || v_marker);
  END IF;
  EXECUTE v_definition;
END;
$patch_potion_no_healing$;

DO $patch_spell_no_healing$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('public.conjurar_magia_srd_manual(text,text,smallint,text,integer[])'::regprocedure) INTO v_definition;
  v_marker:='IF COALESCE(v_target_hp,0)<=-10 THEN v_healing:=0; END IF;';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Validação de morte na cura mágica não localizada.'; END IF;
  IF position('no_healing' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,v_marker,
      E'IF v_target_character_id IS NOT NULL AND priv.srd_condition_has_flag(v_campaign_id,''character'',v_target_character_id,''no_healing'') THEN v_healing:=0; END IF;\n' ||
      E'IF v_target_key IS NOT NULL AND v_target_character_id IS NULL AND priv.srd_condition_has_flag(v_campaign_id,''token'',v_target_key,''no_healing'') THEN v_healing:=0; END IF;\n' ||
      v_marker);
  END IF;
  EXECUTE v_definition;
END;
$patch_spell_no_healing$;
