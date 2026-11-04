DO $patch_multitarget_spell_action$
DECLARE v_definition text;v_marker text;v_replacement text;
BEGIN
  SELECT pg_get_functiondef('public.conjurar_magia_efeitos_multialvo(text,text,smallint,text[])'::regprocedure) INTO v_definition;
  IF position('IF EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND UPPER(COALESCE(c.state,'''') )=''COMBATE'')' IN v_definition)>0 THEN RETURN; END IF;
  v_marker:='  PERFORM public.consumir_acao_turno_srd(v_campaign_id,p_character_id,''padrao'');';
  v_replacement:=$action$
  IF EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND UPPER(COALESCE(c.state,''))='COMBATE') THEN
    PERFORM public.consumir_acao_turno_srd(v_campaign_id,p_character_id,'padrao');
  END IF;
$action$;
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Consumo de ação multialvo não localizado.'; END IF;
  v_definition:=replace(v_definition,v_marker,v_replacement);
  EXECUTE v_definition;
END;
$patch_multitarget_spell_action$;