-- Aplica condições secundárias somente quando o teste de resistência falha.
CREATE OR REPLACE FUNCTION priv.srd_apply_pending_spell_resolution(p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE v_pending priv.srd_pending_spell_resolutions%ROWTYPE; v_instance bigint; v_campaign public.campaigns%ROWTYPE; v_hp integer; v_max_hp integer; v_new_hp integer; v_damage integer; v_tokens jsonb; v_token jsonb; v_index bigint; v_count integer; v_name text; v_condition_id text;
BEGIN
  SELECT * INTO v_pending FROM priv.srd_pending_spell_resolutions WHERE pending_id=p_pending_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Resolução de magia pendente não encontrada.'; END IF;
  IF v_pending.status NOT IN ('pending_save','awaiting_spell_resistance') THEN RAISE EXCEPTION 'Esta resolução de magia já foi concluída.'; END IF;

  IF v_pending.effect_kind='damage' THEN
    IF COALESCE(v_pending.effect_data->>'damage','') !~ '^[0-9]{1,6}$'
       OR (v_pending.effect_data->>'damage')::integer NOT BETWEEN 0 AND 100000
       OR COALESCE(v_pending.effect_data->>'damage_type','') !~ '^[a-z_]{1,24}$' THEN
      RAISE EXCEPTION 'Dados de dano pendente inválidos.';
    END IF;
    v_damage:=(v_pending.effect_data->>'damage')::integer;
    IF priv.srd_effect_has_flag(v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,'negates_magic_missile') THEN
      UPDATE priv.srd_pending_spell_resolutions SET status='resolved',resolved_at=now() WHERE pending_id=p_pending_id;
      RETURN jsonb_build_object('pending_id',p_pending_id,'status','negated_by_shield','damage',0,'spell_negated_by_shield',true);
    END IF;
    SELECT * INTO v_campaign FROM public.campaigns WHERE id=v_pending.campaign_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do efeito de dano não encontrada.'; END IF;

    IF v_pending.target_kind='character' THEN
      SELECT sh.pv_atual,sh.pv_max INTO v_hp,v_max_hp
      FROM public.characters ch
      JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
      WHERE ch.id::text=v_pending.target_id AND ch.campaign_id=v_pending.campaign_id
      FOR UPDATE OF sh;
      IF NOT FOUND OR v_max_hp IS NULL OR v_max_hp<1 THEN RAISE EXCEPTION 'Ficha do alvo de dano inválida.'; END IF;
      v_damage:=priv.srd_adjust_damage(v_pending.campaign_id,'character',v_pending.target_id,
        v_pending.effect_data->>'damage_type',v_damage);
      v_new_hp:=GREATEST(-10,COALESCE(v_hp,v_max_hp)-v_damage);
      PERFORM priv.srd_sync_character_vital_condition(v_pending.target_id,v_new_hp,false);
      UPDATE public.srd_character_sheets SET pv_atual=v_new_hp WHERE character_id::text=v_pending.target_id;
      v_name:=(SELECT nome FROM public.characters WHERE id::text=v_pending.target_id);
    ELSIF v_pending.target_kind='token' THEN
      v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
      SELECT count(*)::integer,min(e.ordinality),min(e.token->>'nome')
        INTO v_count,v_index,v_name
      FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
      WHERE e.token->>'key'=v_pending.target_id OR e.token->>'id'=v_pending.target_id;
      IF v_count<>1 THEN RAISE EXCEPTION 'Token-alvo de dano ausente ou duplicado.'; END IF;
      v_token:=v_tokens->(v_index::integer-1);
      IF COALESCE(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN RAISE EXCEPTION 'Token-alvo sem PV máximo válido.'; END IF;
      v_max_hp:=(v_token->>'maxHp')::integer;
      IF v_max_hp>100000 THEN RAISE EXCEPTION 'PV máximo do token excede o limite.'; END IF;
      v_hp:=CASE WHEN COALESCE(v_token->>'hp','') ~ '^[0-9]{1,6}$' THEN (v_token->>'hp')::integer ELSE v_max_hp END;
      v_damage:=priv.srd_adjust_damage(v_pending.campaign_id,'token',v_pending.target_id,
        v_pending.effect_data->>'damage_type',v_damage);
      v_new_hp:=GREATEST(0,v_hp-v_damage);
      v_tokens:=jsonb_set(v_tokens,ARRAY[(v_index-1)::text],v_token||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp),false);
      UPDATE public.campaigns SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens)
      WHERE id=v_pending.campaign_id;
    ELSE
      RAISE EXCEPTION 'Tipo de alvo incompatível com dano pendente.';
    END IF;
    v_condition_id:=NULLIF(v_pending.effect_data->>'secondary_condition_id','');
    IF v_condition_id IS NOT NULL AND COALESCE((v_pending.effect_data->>'apply_secondary_condition')::boolean,true) THEN
      v_instance:=priv.srd_apply_campaign_condition(
        v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,v_condition_id,
        v_pending.duration_rounds,
        jsonb_build_object('source_spell_id',v_pending.spell_id,'caster_character_id',v_pending.caster_character_id,
          'save_dc',v_pending.save_dc,'save_type',v_pending.save_type,'caster_level',v_pending.caster_level),
        v_pending.spell_id
      );
    END IF;
    UPDATE priv.srd_pending_spell_resolutions SET status='resolved',resolved_at=now() WHERE pending_id=p_pending_id;
    RETURN jsonb_build_object('pending_id',p_pending_id,'status','resolved','damage',v_damage,
      'pv_atual',v_new_hp,'pv_max',v_max_hp,'target_name',COALESCE(v_name,'Alvo'),
      'damage_type',v_pending.effect_data->>'damage_type','condition_id',v_condition_id,'condition_instance_id',v_instance);
  ELSIF v_pending.condition_id IS NOT NULL THEN

    v_instance:=priv.srd_apply_campaign_condition(
      v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,v_pending.condition_id,
      v_pending.duration_rounds,
      jsonb_build_object('source_spell_id',v_pending.spell_id,'caster_character_id',v_pending.caster_character_id,'save_dc',v_pending.save_dc,'save_type',v_pending.save_type,
        'save_each_turn',v_pending.spell_id='srd35_spell_hold_person','caster_level',v_pending.caster_level),
      v_pending.spell_id
    );
  ELSIF v_pending.effect_data<>'{}'::jsonb THEN
    v_instance:=priv.srd_apply_campaign_effect(v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,
      v_pending.effect_kind,v_pending.effect_data,v_pending.duration_rounds,v_pending.spell_id,NULL);
  ELSE
    RAISE EXCEPTION 'A magia não possui uma regra de efeito implementada.';
  END IF;
  UPDATE priv.srd_pending_spell_resolutions SET status='resolved',resolved_at=now() WHERE pending_id=p_pending_id;
  RETURN jsonb_build_object('pending_id',p_pending_id,'status','resolved','instance_id',v_instance,'condition_id',v_pending.condition_id);
END;
$function$
;