
do $patch$
declare v_def text; nl text:=chr(10);
begin
 v_def:=pg_get_functiondef('priv.gm_npc_apply_typed_damage_impl(bigint,text,text,integer,text)'::regprocedure);
 v_def:=replace(v_def,
 'v_damage_type text; v_damage integer; v_hp integer; v_max_hp integer; v_new_hp integer;',
 'v_damage_type text; v_damage integer; v_hp integer; v_max_hp integer; v_new_hp integer; v_round integer; v_action_state jsonb; v_by_actor jsonb; v_actor_actions jsonb; v_combat jsonb;');
 v_def:=replace(v_def,
 ' if v_actor->>''id'' is distinct from btrim(p_actor_token_id) or coalesce(v_actor->>''is_monster'',''false'')<>''true'' then raise exception ''O token atacante não pertence ao turno atual do Mestre.''; end if;',
 ' if v_actor->>''id'' is distinct from btrim(p_actor_token_id) or coalesce(v_actor->>''is_monster'',''false'')<>''true'' then raise exception ''O token atacante não pertence ao turno atual do Mestre.''; end if;'||nl||
 ' v_round:=case when coalesce(v_campaign.combat_data->>''round'','''') ~ ''^[0-9]+$'' then greatest(1,(v_campaign.combat_data->>''round'')::integer) else 1 end;'||nl||
 ' v_action_state:=coalesce(v_campaign.combat_data->''action_economy'',''{}''::jsonb);'||nl||
 ' if coalesce(v_action_state->>''round'','''')<>v_round::text or coalesce(v_action_state->''by_character''->btrim(p_actor_token_id)->>''padrao'',''false'')<>''true'' then raise exception ''A ação padrão do NPC ainda não foi consumida neste turno.''; end if;'||nl||
 ' v_actor_actions:=coalesce(v_action_state->''by_character''->btrim(p_actor_token_id),''{}''::jsonb);'||nl||
 ' if coalesce(v_actor_actions->>''gm_npc_attack_damage_applied'',''false'')=''true'' then raise exception ''Este NPC já aplicou dano de ataque normal nesta rodada.''; end if;');
 v_def:=replace(v_def,
 '  update public.srd_character_sheets set pv_atual=v_new_hp where character_id::text=btrim(p_target_token_id);',
 '  update public.srd_character_sheets set pv_atual=v_new_hp where character_id::text=btrim(p_target_token_id);'||nl||
 '  v_combat:=coalesce(v_campaign.combat_data,''{}''::jsonb); v_by_actor:=coalesce(v_action_state->''by_character'',''{}''::jsonb);'||nl||
 '  v_actor_actions:=v_actor_actions||jsonb_build_object(''gm_npc_attack_damage_applied'',true); v_by_actor:=jsonb_set(v_by_actor,array[btrim(p_actor_token_id)],v_actor_actions,true);'||nl||
 '  v_action_state:=v_action_state||jsonb_build_object(''by_character'',v_by_actor); v_combat:=v_combat||jsonb_build_object(''action_economy'',v_action_state);'||nl||
 '  update public.campaigns set combat_data=v_combat where id=p_campaign_id;');
 v_def:=replace(v_def,
 ' update public.campaigns set cba_data=coalesce(cba_data,''{}''::jsonb)||jsonb_build_object(''tokens'',v_tokens) where id=p_campaign_id;',
 ' update public.campaigns set cba_data=coalesce(cba_data,''{}''::jsonb)||jsonb_build_object(''tokens'',v_tokens) where id=p_campaign_id;'||nl||
 ' v_combat:=coalesce(v_campaign.combat_data,''{}''::jsonb); v_by_actor:=coalesce(v_action_state->''by_character'',''{}''::jsonb);'||nl||
 ' v_actor_actions:=v_actor_actions||jsonb_build_object(''gm_npc_attack_damage_applied'',true); v_by_actor:=jsonb_set(v_by_actor,array[btrim(p_actor_token_id)],v_actor_actions,true);'||nl||
 ' v_action_state:=v_action_state||jsonb_build_object(''by_character'',v_by_actor); v_combat:=v_combat||jsonb_build_object(''action_economy'',v_action_state);'||nl||
 ' update public.campaigns set combat_data=v_combat where id=p_campaign_id;');
 if position('gm_npc_attack_damage_applied' in v_def)=0 or position('A ação padrão do NPC' in v_def)=0 then
  raise exception 'Não foi possível aplicar a proteção de ação/dano único ao NPC.';
 end if;
 execute v_def;
end
$patch$;
