UPDATE public.srd_spells
SET dados_tecnicos=jsonb_set(COALESCE(dados_tecnicos,'{}'::jsonb),'{engine_status}',to_jsonb('partial_multi_target'::text),true)
WHERE id IN ('srd35_spell_haste','srd35_spell_slow');

DO $patch_partial_multitarget_acceptance$
DECLARE v_definition text;v_old text;v_new text;
BEGIN
  SELECT pg_get_functiondef('public.conjurar_magia_efeitos_multialvo(text,text,smallint,text[])'::regprocedure) INTO v_definition;
  v_old:='OR COALESCE(v_spell.dados_tecnicos->>''engine_status'','''')<>''ready_multi_target'' THEN';
  v_new:='OR COALESCE(v_spell.dados_tecnicos->>''engine_status'','''') NOT IN (''ready_multi_target'',''partial_multi_target'') THEN';
  IF position(v_new IN v_definition)>0 THEN RETURN; END IF;
  IF position(v_old IN v_definition)=0 THEN RAISE EXCEPTION 'Validação de status multialvo não localizada.'; END IF;
  v_definition:=replace(v_definition,v_old,v_new);
  EXECUTE v_definition;
END;
$patch_partial_multitarget_acceptance$;