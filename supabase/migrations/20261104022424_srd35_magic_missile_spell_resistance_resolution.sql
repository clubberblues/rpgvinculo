DO $patch_pending_damage$
DECLARE
  v_definition text;
  v_marker text;
  v_branch text;
BEGIN
  SELECT pg_get_functiondef('priv.srd_apply_pending_spell_resolution(uuid)'::regprocedure) INTO v_definition;
  IF position('v_pending.effect_kind=''damage''' IN v_definition)>0 THEN RETURN; END IF;

  v_definition:=replace(v_definition,
    'DECLARE v_pending priv.srd_pending_spell_resolutions%ROWTYPE; v_instance bigint;',
    'DECLARE v_pending priv.srd_pending_spell_resolutions%ROWTYPE; v_instance bigint; v_campaign public.campaigns%ROWTYPE; v_hp integer; v_max_hp integer; v_new_hp integer; v_damage integer; v_tokens jsonb; v_token jsonb; v_index bigint; v_count integer; v_name text;');

  v_marker:='  IF v_pending.condition_id IS NOT NULL THEN';
  v_branch:=$branch$
  IF v_pending.effect_kind='damage' THEN
    IF COALESCE(v_pending.effect_data->>'damage','') !~ '^[0-9]{1,6}$'
       OR (v_pending.effect_data->>'damage')::integer NOT BETWEEN 0 AND 100000
       OR COALESCE(v_pending.effect_data->>'damage_type','') !~ '^[a-z_]{1,24}$' THEN
      RAISE EXCEPTION 'Dados de dano pendente inválidos.';
    END IF;
    v_damage:=(v_pending.effect_data->>'damage')::integer;
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
    UPDATE priv.srd_pending_spell_resolutions SET status='resolved',resolved_at=now() WHERE pending_id=p_pending_id;
    RETURN jsonb_build_object('pending_id',p_pending_id,'status','resolved','damage',v_damage,
      'pv_atual',v_new_hp,'pv_max',v_max_hp,'target_name',COALESCE(v_name,'Alvo'),'damage_type',v_pending.effect_data->>'damage_type');
  ELSIF v_pending.condition_id IS NOT NULL THEN
$branch$;

  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Não foi possível localizar o resolvedor de condições.'; END IF;
  v_definition:=replace(v_definition,v_marker,v_branch);
  EXECUTE v_definition;
END;
$patch_pending_damage$;

DO $patch_magic_missile_sr$
DECLARE
  v_definition text;
  v_marker text;
  v_branch text;
BEGIN
  SELECT pg_get_functiondef('public.conjurar_missil_magico_srd(text,text,smallint,text,integer)'::regprocedure) INTO v_definition;
  IF position('spell_resistance_pending_id' IN v_definition)>0 THEN RETURN; END IF;
  v_definition:=replace(v_definition,
    '  v_damage_final INTEGER;',
    '  v_damage_final INTEGER; v_sr INTEGER; v_pending_id UUID; v_target_kind TEXT; v_target_id TEXT;');

  v_marker:='  v_token:=v_tokens->(v_index::INTEGER-1);';
  v_branch:=$branch$
  v_token:=v_tokens->(v_index::INTEGER-1);
  IF v_type='player' THEN
    v_target_kind:='character'; v_target_id:=v_token->>'id';
    v_sr:=priv.srd_spell_resistance_value(v_character.campaign_id,'character',v_target_id);
  ELSIF v_type IN ('npc','monstro') THEN
    v_target_kind:='token'; v_target_id:=COALESCE(v_token->>'key',v_token->>'id',BTRIM(p_target_token_key));
    v_sr:=priv.srd_spell_resistance_value(v_character.campaign_id,'token',v_target_id);
  ELSE
    RAISE EXCEPTION 'Tipo de token incompatível com Míssil Mágico.';
  END IF;

  IF v_sr>0 THEN
    INSERT INTO priv.srd_pending_spell_resolutions(
      campaign_id,caster_character_id,target_kind,target_id,spell_id,save_type,save_dc,
      effect_data,spell_resistance,caster_level,status,effect_kind
    ) VALUES (
      v_character.campaign_id,BTRIM(p_character_id),v_target_kind,v_target_id,p_spell_id,
      'will',1,jsonb_build_object('damage',p_damage,'damage_type','force'),true,v_sheet.nivel,
      'awaiting_spell_resistance','damage'
    ) RETURNING pending_id INTO v_pending_id;

    INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
    VALUES(v_character.campaign_id,'test_request','PUBLIC',
      jsonb_build_object('tipo','Penetração de Resistência à Magia (D20)',
        'alvos',jsonb_build_array(BTRIM(p_character_id)),'npc_alvos','[]'::jsonb,
        'mestre','Sistema','mestre_id',auth.uid(),'request_id',gen_random_uuid()::text,
        'resolution_type','spell_resistance','pending_id',v_pending_id,'spell_id',p_spell_id,
        'spell_resistance',v_sr,'caster_level',v_sheet.nivel));

    RETURN COALESCE(v_cast,'{}'::jsonb)||jsonb_build_object(
      'target_name',COALESCE(v_name,'Alvo'),'missiles',v_missiles,
      'spell_resistance_pending',true,'spell_resistance_pending_id',v_pending_id,
      'spell_resistance',v_sr,'damage_pending',p_damage
    );
  END IF;
$branch$;

  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Não foi possível localizar o ponto de resolução do Míssil Mágico.'; END IF;
  v_definition:=replace(v_definition,v_marker,v_branch);
  EXECUTE v_definition;
END;
$patch_magic_missile_sr$;

REVOKE ALL ON FUNCTION priv.srd_apply_pending_spell_resolution(uuid) FROM PUBLIC,anon,authenticated;