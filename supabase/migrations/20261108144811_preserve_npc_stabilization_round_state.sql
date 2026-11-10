
CREATE OR REPLACE FUNCTION priv.srd_sync_linked_npc_token_vitals(
  p_campaign_id bigint,p_token_id text,p_token_hp integer,p_token_max_hp integer,p_stabilize boolean
) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE; v_tokens jsonb; v_token jsonb; v_index bigint;
  v_count integer; v_source_id text; v_actual_id text; v_token_key text;
  v_sheet_id bigint; v_rage_bonus integer:=0; v_base_max integer; v_hp integer;
  v_round integer; v_state text; v_dead boolean:=false; v_last_resolved_round integer;
  v_notes jsonb;
BEGIN
  IF p_campaign_id IS NULL OR NULLIF(BTRIM(p_token_id),'') IS NULL
     OR p_token_hp IS NULL OR p_token_max_hp IS NULL OR p_token_max_hp<1 OR p_token_max_hp>100000 THEN
    RAISE EXCEPTION 'Dados de sincronização de PV do NPC inválidos.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
  SELECT count(*)::integer,min(t.ordinality),(array_agg(t.token ORDER BY t.ordinality))[1]
    INTO v_count,v_index,v_token
  FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality)
  WHERE (t.token->>'id'=BTRIM(p_token_id) OR t.token->>'key'=BTRIM(p_token_id)) AND t.token->>'tipo'='npc';
  IF v_count IS DISTINCT FROM 1 THEN RETURN jsonb_build_object('synced',false,'reason','not_a_unique_npc_token'); END IF;
  v_actual_id:=NULLIF(BTRIM(v_token->>'id'),'');
  v_token_key:=NULLIF(BTRIM(v_token->>'key'),'');
  v_source_id:=NULLIF(BTRIM(v_token->>'sourceCharacterId'),'');
  IF v_actual_id IS NULL OR v_source_id IS NULL OR v_source_id !~ '^[0-9]+$' THEN
    RETURN jsonb_build_object('synced',false,'reason','npc_not_linked_to_source_sheet');
  END IF;
  SELECT sh.character_id INTO v_sheet_id
  FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
  WHERE ch.id::text=v_source_id AND (
    ch.user_id=v_campaign.owner_id OR EXISTS(
      SELECT 1 FROM public.members m WHERE m.campaign_id=p_campaign_id AND m.user_id=ch.user_id AND m.role='GM'
    )
  ) FOR UPDATE OF sh;
  IF NOT FOUND THEN RETURN jsonb_build_object('synced',false,'reason','source_sheet_not_owned_by_campaign_gm'); END IF;
  SELECT EXISTS(
    SELECT 1 FROM public.srd_campaign_conditions cc
    WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token'
      AND cc.target_id IN (v_actual_id,COALESCE(v_token_key,v_actual_id))
      AND cc.condition_id='dead' AND cc.active=true
  ) INTO v_dead;
  SELECT COALESCE(max(NULLIF(e.effect_data->>'rage_hp_bonus','')::integer),0) INTO v_rage_bonus
  FROM public.srd_campaign_effects e
  WHERE e.campaign_id=p_campaign_id AND e.target_kind='token'
    AND e.target_id=v_actual_id AND e.active=true AND e.effect_data->>'source_feature'='barbarian_rage';
  SELECT max(NULLIF(cc.notes->>'last_resolved_round','')::integer)
    INTO v_last_resolved_round
  FROM public.srd_campaign_conditions cc
  WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token'
    AND cc.target_id IN (v_actual_id,COALESCE(v_token_key,v_actual_id))
    AND cc.condition_id IN ('dead','dying','stable','disabled') AND cc.active=true;
  v_base_max:=GREATEST(1,p_token_max_hp-GREATEST(0,v_rage_bonus));
  v_hp:=CASE WHEN v_dead THEN -10 ELSE GREATEST(-10,LEAST(v_base_max,p_token_hp)) END;
  v_token:=v_token||jsonb_build_object('hp',v_hp,'maxHp',p_token_max_hp);
  SELECT COALESCE(jsonb_agg(CASE WHEN t.ordinality=v_index THEN v_token ELSE t.token END ORDER BY t.ordinality),'[]'::jsonb)
    INTO v_tokens FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality);
  UPDATE public.campaigns SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens) WHERE id=p_campaign_id;
  UPDATE public.srd_character_sheets SET pv_max=v_base_max,pv_atual=GREATEST(-10,LEAST(v_base_max,v_hp)) WHERE character_id=v_sheet_id;
  v_state:=CASE WHEN v_hp<=-10 THEN 'dead' WHEN v_hp<0 AND p_stabilize THEN 'stable'
    WHEN v_hp<0 THEN 'dying' WHEN v_hp=0 THEN 'disabled' ELSE NULL END;
  UPDATE public.srd_campaign_conditions SET active=false
  WHERE campaign_id=p_campaign_id AND target_kind='token'
    AND target_id IN (v_actual_id,COALESCE(v_token_key,v_actual_id))
    AND condition_id IN ('dead','dying','stable','disabled') AND active=true;
  IF v_state IS NOT NULL THEN
    v_round:=GREATEST(1,COALESCE(NULLIF(v_campaign.combat_data->>'round','')::integer,1));
    v_notes:=jsonb_build_object('source','npc_hp_state_engine','pv',v_hp,'stabilized',v_state='stable');
    IF v_last_resolved_round IS NOT NULL THEN
      v_notes:=v_notes||jsonb_build_object('last_resolved_round',v_last_resolved_round);
    END IF;
    INSERT INTO public.srd_campaign_conditions(campaign_id,target_kind,target_id,condition_id,started_round,expires_round,active,notes)
    VALUES(p_campaign_id,'token',v_actual_id,v_state,v_round,NULL,true,v_notes);
  END IF;
  RETURN jsonb_build_object('synced',true,'source_character_id',v_source_id,'token_id',v_actual_id,
    'pv_atual',v_hp,'pv_max',v_base_max,'token_max_hp',p_token_max_hp,'condition',v_state,
    'rage_hp_bonus_excluded',GREATEST(0,v_rage_bonus));
END;
$function$;

DO $migration$
DECLARE
  v_sig text; v_def text; v_old text; v_new text; v_count integer;
BEGIN
  v_sig:='priv.srd_end_barbarian_rage_token(bigint,text,boolean)';
  v_def:=pg_get_functiondef(v_sig::regprocedure);
  v_old:='PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_new_hp,v_new_max);';
  v_new:='PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_new_hp,v_new_max,EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=p_campaign_id AND cc.target_kind=''token'' AND cc.target_id=p_token_id AND cc.condition_id=''stable'' AND cc.active=true));';
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Preservação de estabilização ao encerrar Fúria não única: %.',v_count; END IF;
  EXECUTE replace(v_def,v_old,v_new);

  v_sig:='public.alterar_pv_token_cba(bigint,text,integer,integer)';
  v_def:=pg_get_functiondef(v_sig::regprocedure);
  v_old:='PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_hp,v_max);';
  v_new:='PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_hp,v_max,(p_variacao>0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=p_campaign_id AND cc.target_kind=''token'' AND cc.target_id=p_token_id AND cc.condition_id=''stable'' AND cc.active=true)));';
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Preservação de estabilização no ajuste de PV não única: %.',v_count; END IF;
  EXECUTE replace(v_def,v_old,v_new);

  v_sig:='public.usar_habilidade_classe_srd(text,text,text,integer)';
  v_def:=pg_get_functiondef(v_sig::regprocedure);
  v_old:='PERFORM priv.srd_sync_linked_npc_token_vitals(v_character.campaign_id,p_target_token_key,v_hp,v_max_hp);';
  v_new:='PERFORM priv.srd_sync_linked_npc_token_vitals(v_character.campaign_id,p_target_token_key,v_hp,v_max_hp,(v_hp<0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=v_character.campaign_id AND cc.target_kind=''token'' AND cc.target_id IN (v_token->>''id'',v_token->>''key'') AND cc.condition_id=''stable'' AND cc.active=true)));';
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Preservação de estabilização na cura não única: %.',v_count; END IF;
  EXECUTE replace(v_def,v_old,v_new);
END;
$migration$;
