DO $patch_magic_missile_shield$
DECLARE
  v_definition text;
  v_marker text;
  v_add text;
BEGIN
  SELECT pg_get_functiondef('public.conjurar_missil_magico_srd(text,text,smallint,text,integer)'::regprocedure) INTO v_definition;
  IF position('negates_magic_missile' IN v_definition)>0 THEN RETURN; END IF;
  v_marker:='  IF v_sr>0 THEN';
  v_add:=$patch$
  IF priv.srd_effect_has_flag(v_character.campaign_id,v_target_kind,v_target_id,'negates_magic_missile') THEN
    RETURN COALESCE(v_cast,'{}'::jsonb)||jsonb_build_object(
      'target_name',COALESCE(v_name,'Alvo'),'missiles',v_missiles,
      'spell_negated_by_shield',true,'damage',0
    );
  END IF;

  IF v_sr>0 THEN
$patch$;
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Ponto de resistência à magia não encontrado em Míssil Mágico.'; END IF;
  v_definition:=replace(v_definition,v_marker,v_add);
  EXECUTE v_definition;
END;
$patch_magic_missile_shield$;

DO $patch_pending_damage_shield$
DECLARE
  v_definition text;
  v_marker text;
  v_add text;
BEGIN
  SELECT pg_get_functiondef('priv.srd_apply_pending_spell_resolution(uuid)'::regprocedure) INTO v_definition;
  IF position('negated_by_shield' IN v_definition)>0 THEN RETURN; END IF;
  v_marker:='    v_damage:=(v_pending.effect_data->>''damage'')::integer;';
  v_add:=v_marker||E'\n    IF priv.srd_effect_has_flag(v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,''negates_magic_missile'') THEN\n      UPDATE priv.srd_pending_spell_resolutions SET status=''resolved'',resolved_at=now() WHERE pending_id=p_pending_id;\n      RETURN jsonb_build_object(''pending_id'',p_pending_id,''status'',''negated_by_shield'',''damage'',0,''spell_negated_by_shield'',true);\n    END IF;';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Ponto de dano pendente não encontrado.'; END IF;
  v_definition:=replace(v_definition,v_marker,v_add);
  EXECUTE v_definition;
END;
$patch_pending_damage_shield$;