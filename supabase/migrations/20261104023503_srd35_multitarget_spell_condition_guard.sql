DO $patch_multitarget_spell_condition_guard$
DECLARE v_definition text;v_marker text;v_replacement text;
BEGIN
  SELECT pg_get_functiondef('public.conjurar_magia_efeitos_multialvo(text,text,smallint,text[])'::regprocedure) INTO v_definition;
  IF position('A condição atual impede conjurar magias.' IN v_definition)>0 THEN RETURN; END IF;
  v_marker:=$marker$
  IF NOT EXISTS(SELECT 1 FROM public.members m WHERE m.campaign_id=v_campaign_id AND m.user_id=auth.uid()
    UNION ALL SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND c.owner_id=auth.uid()) THEN
    RAISE EXCEPTION 'O personagem não pertence a uma campanha da qual você participa.';
  END IF;
$marker$;
  v_replacement:=v_marker||E'\n  IF priv.srd_condition_has_flag(v_campaign_id,''character'',BTRIM(p_character_id),''no_actions'')\n     OR priv.srd_condition_has_flag(v_campaign_id,''character'',BTRIM(p_character_id),''cannot_cast'') THEN\n    RAISE EXCEPTION ''A condição atual impede conjurar magias.'';\n  END IF;';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Bloco completo de membership não localizado no conjurador multialvo.'; END IF;
  v_definition:=replace(v_definition,v_marker,v_replacement);
  EXECUTE v_definition;
END;
$patch_multitarget_spell_condition_guard$;