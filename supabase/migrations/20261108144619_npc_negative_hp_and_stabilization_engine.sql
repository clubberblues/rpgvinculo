
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
  v_round integer; v_state text; v_dead boolean:=false;
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
    INSERT INTO public.srd_campaign_conditions(campaign_id,target_kind,target_id,condition_id,started_round,expires_round,active,notes)
    VALUES(p_campaign_id,'token',v_actual_id,v_state,v_round,NULL,true,
      jsonb_build_object('source','npc_hp_state_engine','pv',v_hp,'stabilized',v_state='stable'));
  END IF;
  RETURN jsonb_build_object('synced',true,'source_character_id',v_source_id,'token_id',v_actual_id,
    'pv_atual',v_hp,'pv_max',v_base_max,'token_max_hp',p_token_max_hp,'condition',v_state,
    'rage_hp_bonus_excluded',GREATEST(0,v_rage_bonus));
END;
$function$;

CREATE OR REPLACE FUNCTION priv.srd_sync_linked_npc_token_vitals(
  p_campaign_id bigint,p_token_id text,p_token_hp integer,p_token_max_hp integer
) RETURNS jsonb LANGUAGE sql SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
  SELECT priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,p_token_hp,p_token_max_hp,false);
$function$;

REVOKE ALL ON FUNCTION priv.srd_sync_linked_npc_token_vitals(bigint,text,integer,integer) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION priv.srd_sync_linked_npc_token_vitals(bigint,text,integer,integer,boolean) FROM PUBLIC,anon,authenticated;

DO $migration$
DECLARE
  v_sig text; v_def text; v_old text; v_new text; v_count integer;
  v_items text[]:=ARRAY[
    'priv.gm_npc_apply_typed_damage_impl(bigint,text,text,integer,text)',
    'priv.npc_aplicar_dano_ataque_iterativo_impl(bigint,uuid,integer[],uuid,integer[])',
    'priv.srd_apply_pending_spell_resolution(uuid)',
    'public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer)',
    'public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer,integer,integer)',
    'public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid)',
    'public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid,integer[])',
    'public.conjurar_missil_magico_srd(text,text,smallint,text,integer)'
  ];
BEGIN
  FOREACH v_sig IN ARRAY v_items LOOP
    v_def:=pg_get_functiondef(v_sig::regprocedure);
    v_def:=replace(v_def,'^[0-9]{1,6}$','^-?[0-9]{1,6}$');
    IF v_sig LIKE 'priv.gm_npc_apply_typed_damage_impl%' THEN
      v_old:='greatest(0,least(v_max_hp,v_hp-v_damage))'; v_new:='greatest(-10,least(v_max_hp,v_hp-v_damage))';
    ELSIF v_sig LIKE 'priv.npc_aplicar_dano_ataque_iterativo_impl%' THEN
      v_old:='greatest(0,least(v_max_hp,v_hp-v_final_damage))'; v_new:='greatest(-10,least(v_max_hp,v_hp-v_final_damage))';
    ELSIF v_sig LIKE 'priv.srd_apply_pending_spell_resolution%' THEN
      v_old:='GREATEST(0,v_hp-v_damage)'; v_new:='GREATEST(-10,v_hp-v_damage)';
    ELSIF v_sig LIKE 'public.aplicar_dano_token_ataque_srd_v2%' THEN
      v_old:='GREATEST(0,LEAST(v_max_hp,v_hp-v_damage_final))'; v_new:='GREATEST(-10,LEAST(v_max_hp,v_hp-v_damage_final))';
    ELSIF v_sig LIKE 'public.aplicar_dano_ataque_iterativo_srd%' THEN
      v_old:='greatest(0,least(v_max_hp,v_hp-v_final_damage))'; v_new:='greatest(-10,least(v_max_hp,v_hp-v_final_damage))';
    ELSE
      v_old:='GREATEST(0,v_hp-v_damage_final)'; v_new:='GREATEST(-10,v_hp-v_damage_final)';
    END IF;
    v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
    IF v_count<>1 THEN RAISE EXCEPTION 'Esperava um único cálculo de PV de token em %, encontrei %.',v_sig,v_count; END IF;
    v_def:=replace(v_def,v_old,v_new);
    EXECUTE v_def;
  END LOOP;
END;
$migration$;

CREATE OR REPLACE FUNCTION public.srd_resolve_npc_dying_round(
  p_campaign_id bigint,p_token_id text,p_d100 integer
) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE; v_tokens jsonb; v_token jsonb; v_index bigint;
  v_count integer; v_actual_id text; v_source_id text; v_hp integer; v_max_hp integer;
  v_round integer; v_condition public.srd_campaign_conditions%ROWTYPE; v_new_hp integer;
  v_state text; v_result jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_d100 IS NULL OR p_d100 NOT BETWEEN 1 AND 100 THEN RAISE EXCEPTION 'A estabilização exige uma rolagem manual de D100 entre 1 e 100.'; END IF;
  IF public.my_role(p_campaign_id) IS DISTINCT FROM 'GM'
     AND NOT EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=p_campaign_id AND c.owner_id=auth.uid()) THEN
    RAISE EXCEPTION 'Somente o Mestre pode resolver a estabilização de um NPC.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
  SELECT count(*)::integer,min(t.ordinality),(array_agg(t.token ORDER BY t.ordinality))[1]
    INTO v_count,v_index,v_token
  FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality)
  WHERE (t.token->>'id'=BTRIM(p_token_id) OR t.token->>'key'=BTRIM(p_token_id)) AND t.token->>'tipo'='npc';
  IF v_count IS DISTINCT FROM 1 THEN RAISE EXCEPTION 'NPC ausente ou duplicado no tabuleiro.'; END IF;
  v_actual_id:=NULLIF(BTRIM(v_token->>'id'),'');
  v_source_id:=NULLIF(BTRIM(v_token->>'sourceCharacterId'),'');
  IF v_source_id IS NULL THEN RAISE EXCEPTION 'A estabilização exige NPC vinculado a uma ficha de origem.'; END IF;
  IF COALESCE(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN RAISE EXCEPTION 'PV máximo do NPC inválido.'; END IF;
  v_max_hp:=(v_token->>'maxHp')::integer;
  IF COALESCE(v_token->>'hp','') !~ '^-?[0-9]{1,6}$' THEN RAISE EXCEPTION 'PV atuais do NPC inválidos.'; END IF;
  v_hp:=(v_token->>'hp')::integer;
  IF v_hp<=-10 THEN RAISE EXCEPTION 'O NPC já está morto.'; END IF;
  IF v_hp NOT BETWEEN -9 AND -1 THEN RAISE EXCEPTION 'O NPC precisa estar entre -1 e -9 PV para estabilização.'; END IF;
  PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_hp,v_max_hp,false);
  SELECT * INTO v_condition FROM public.srd_campaign_conditions cc
  WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token' AND cc.target_id=v_actual_id
    AND cc.condition_id='dying' AND cc.active=true
  ORDER BY cc.condition_instance_id DESC LIMIT 1 FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Condição Morrendo não foi registrada para este NPC.'; END IF;
  v_round:=GREATEST(1,COALESCE(NULLIF(v_campaign.combat_data->>'round','')::integer,1));
  IF COALESCE(NULLIF(v_condition.notes->>'last_resolved_round','')::integer,0)>=v_round THEN
    RAISE EXCEPTION 'A estabilização deste NPC já foi resolvida nesta rodada.';
  END IF;
  IF p_d100<=10 THEN
    v_new_hp:=v_hp; v_state:='stable';
    v_result:=priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_new_hp,v_max_hp,true);
  ELSE
    v_new_hp:=GREATEST(-10,v_hp-1);
    v_state:=CASE WHEN v_new_hp<=-10 THEN 'dead' ELSE 'dying' END;
    v_result:=priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_new_hp,v_max_hp,false);
    IF v_state='dying' THEN
      UPDATE public.srd_campaign_conditions SET notes=COALESCE(notes,'{}'::jsonb)||jsonb_build_object('last_resolved_round',v_round)
      WHERE campaign_id=p_campaign_id AND target_kind='token' AND target_id=v_actual_id AND condition_id='dying' AND active=true;
    END IF;
  END IF;
  INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
  VALUES(p_campaign_id,'ESTABILIZACAO_NPC_RESOLVIDA','PUBLIC',
    jsonb_build_object('token_id',v_actual_id,'source_character_id',v_source_id,'d100',p_d100,'round',v_round,'pv_atual',v_new_hp,'status',v_state));
  RETURN jsonb_build_object('token_id',v_actual_id,'d100',p_d100,'round',v_round,'pv_atual',v_new_hp,
    'condition',v_state,'stabilized',v_state='stable','dead',v_state='dead','sync',v_result);
END;
$function$;

REVOKE ALL ON FUNCTION public.srd_resolve_npc_dying_round(bigint,text,integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.srd_resolve_npc_dying_round(bigint,text,integer) TO authenticated;
