DO $patch_legacy_spell_cast_guards$
DECLARE
  v_definition text;
  v_marker text;
  v_guard text;
BEGIN
  SELECT pg_get_functiondef('public.conjurar_magia_srd(text,text,smallint,text)'::regprocedure) INTO v_definition;
  IF position('A condição atual impede conjurar magias.' IN v_definition)>0 THEN RETURN; END IF;
  v_marker:='  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s';
  v_guard:=$guard$
  IF priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'no_actions')
     OR priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'cannot_cast') THEN
    RAISE EXCEPTION 'A condição atual impede conjurar magias.';
  END IF;

  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s
$guard$;
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Ponto de leitura da ficha não encontrado na conjuração legada.'; END IF;
  v_definition:=replace(v_definition,v_marker,v_guard);
  EXECUTE v_definition;
END;
$patch_legacy_spell_cast_guards$;

UPDATE public.srd_spells
SET dados_tecnicos=jsonb_set(COALESCE(dados_tecnicos,'{}'::jsonb),'{engine_status}',to_jsonb('partial_single_target_spell_resistance'::text),true)
WHERE id='srd35_magic_missile'
  AND COALESCE(dados_tecnicos->>'engine_status','')='needs_implementation';