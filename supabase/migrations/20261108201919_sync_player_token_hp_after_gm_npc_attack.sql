
DO $$
DECLARE
  v_oid oid;
  v_def text;
  v_old text := $old$  v_new_hp:=greatest(-10,least(v_max_hp,coalesce(v_hp,v_max_hp)-v_damage));
  perform priv.srd_sync_character_vital_condition(btrim(p_target_token_id),v_new_hp,false);
  update public.srd_character_sheets set pv_atual=v_new_hp where character_id::text=btrim(p_target_token_id);
  v_combat:=coalesce(v_campaign.combat_data,'{}'::jsonb); v_by_actor:=coalesce(v_action_state->'by_character','{}'::jsonb);
  v_actor_actions:=v_actor_actions||jsonb_build_object('gm_npc_attack_damage_applied',true); v_by_actor:=jsonb_set(v_by_actor,array[btrim(p_actor_token_id)],v_actor_actions,true);
  v_action_state:=v_action_state||jsonb_build_object('by_character',v_by_actor); v_combat:=v_combat||jsonb_build_object('action_economy',v_action_state);
  update public.campaigns set combat_data=v_combat where id=p_campaign_id;
  return jsonb_build_object('target_kind','character','target_id',p_target_token_id,'damage_raw',p_raw_damage,'damage_applied',v_damage,'damage_type',v_damage_type,'pv_atual',v_new_hp,'pv_max',v_max_hp);$old$;
  v_new text := $new$  v_new_hp:=greatest(-10,least(v_max_hp,coalesce(v_hp,v_max_hp)-v_damage));
  perform priv.srd_sync_character_vital_condition(btrim(p_target_token_id),v_new_hp,false);
  update public.srd_character_sheets set pv_atual=v_new_hp where character_id::text=btrim(p_target_token_id);
  v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
  v_tokens:=jsonb_set(v_tokens,array[(v_index-1)::text],v_target,false);
  v_combat:=coalesce(v_campaign.combat_data,'{}'::jsonb); v_by_actor:=coalesce(v_action_state->'by_character','{}'::jsonb);
  v_actor_actions:=v_actor_actions||jsonb_build_object('gm_npc_attack_damage_applied',true); v_by_actor:=jsonb_set(v_by_actor,array[btrim(p_actor_token_id)],v_actor_actions,true);
  v_action_state:=v_action_state||jsonb_build_object('by_character',v_by_actor); v_combat:=v_combat||jsonb_build_object('action_economy',v_action_state);
  update public.campaigns
     set cba_data=coalesce(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens),
         combat_data=v_combat
   where id=p_campaign_id;
  return jsonb_build_object('target_kind','character','target_id',p_target_token_id,
    'damage_raw',p_raw_damage,'damage_applied',v_damage,'damage_type',v_damage_type,
    'pv_atual',v_new_hp,'pv_max',v_max_hp,
    'cba_data',(select cba_data from public.campaigns where id=p_campaign_id));$new$;
BEGIN
  SELECT p.oid INTO v_oid
  FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
  WHERE n.nspname='priv' AND p.proname='gm_npc_apply_typed_damage_impl'
    AND pg_get_function_identity_arguments(p.oid)='p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_raw_damage integer, p_damage_type text';
  IF v_oid IS NULL THEN RAISE EXCEPTION 'Implementação de dano NPC não encontrada.'; END IF;
  v_def:=pg_get_functiondef(v_oid);
  IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Bloco de sincronização de PV de jogador não encontrado.'; END IF;
  v_def:=replace(v_def,v_old,v_new);
  EXECUTE v_def;
END
$$;
