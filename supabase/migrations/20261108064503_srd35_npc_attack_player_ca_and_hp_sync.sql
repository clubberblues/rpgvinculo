
do $patch$
declare v_def text;
begin
 v_def:=pg_get_functiondef('public.resolver_ataque_iterativo_npc_srd(bigint,uuid)'::regprocedure);
 v_def:=replace(v_def,'  v_end_meta jsonb;',E'  v_end_meta jsonb;\n  v_player_ac jsonb;');
 v_def:=replace(v_def,
 '  v_ca_text := coalesce(v_target->>''ac'',v_target->''monsterStats''->>''ca'');'
 || E'\n  if coalesce(v_ca_text,'''') !~ ''^[0-9]{1,3}$'' then raise exception ''O alvo não possui CA numérica válida.''; end if;'
 || E'\n  v_ca := v_ca_text::integer + v_effect_ac;',
 '  if v_target->>''tipo''=''player'' then'
 || E'\n    v_player_ac:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_seq.target_token_id,''normal'');'
 || E'\n    v_ca:=nullif(v_player_ac->>''final_ac'','''')::integer;'
 || E'\n    if v_ca is null then raise exception ''Não foi possível calcular a CA do personagem alvo.''; end if;'
 || E'\n  else'
 || E'\n    v_ca_text:=coalesce(v_target->>''ac'',v_target->''monsterStats''->>''ca'');'
 || E'\n    if coalesce(v_ca_text,'''') !~ ''^[0-9]{1,3}$'' then raise exception ''O alvo não possui CA numérica válida.''; end if;'
 || E'\n    v_ca:=v_ca_text::integer+v_effect_ac;'
 || E'\n  end if;');
 if position('v_player_ac:=public.srd_calcular_ca_personagem_srd' in v_def)=0 then
  raise exception 'Não foi possível integrar cálculo de CA de personagem no resolvedor NPC.';
 end if;
 execute v_def;

 v_def:=pg_get_functiondef('public.aplicar_dano_ataque_iterativo_npc_srd(bigint,uuid,integer[],uuid,integer[])'::regprocedure);
 v_def:=replace(v_def,
 '  v_final_damage:=priv.srd_adjust_damage(p_campaign_id,''token'',v_seq.target_token_id,v_damage_type,greatest(0,v_raw_damage));',
 '  select t.token into v_target from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->''tokens'')=''array'' then v_campaign.cba_data->''tokens'' else ''[]''::jsonb end) t(token) where t.token->>''id''=v_seq.target_token_id;'
 || E'\n  if v_target is null then raise exception ''Alvo não encontrado na cena.''; end if;'
 || E'\n  v_final_damage:=case when v_target->>''tipo''=''player'''
 || E'\n    then priv.srd_adjust_damage(p_campaign_id,''character'',v_seq.target_token_id,v_damage_type,greatest(0,v_raw_damage))'
 || E'\n    else priv.srd_adjust_damage(p_campaign_id,''token'',v_seq.target_token_id,v_damage_type,greatest(0,v_raw_damage)) end;');

 v_def:=replace(v_def,
 '  if coalesce(v_target->>''maxHp'','''') !~ ''^[1-9][0-9]{0,5}$'' then raise exception ''PV máximo do alvo inválido.''; end if;'
 || E'\n  v_max_hp:=(v_target->>''maxHp'')::integer;'
 || E'\n  v_hp:=case when coalesce(v_target->>''hp'','''') ~ ''^[0-9]{1,6}$'' then (v_target->>''hp'')::integer else v_max_hp end;'
 || E'\n  v_new_hp:=greatest(0,least(v_max_hp,v_hp-v_final_damage));'
 || E'\n  v_target:=v_target||jsonb_build_object(''hp'',v_new_hp,''maxHp'',v_max_hp);',
 '  if v_target->>''tipo''=''player'' then'
 || E'\n    select sh.pv_atual,sh.pv_max into v_hp,v_max_hp from public.srd_character_sheets sh'
 || E'\n      where sh.character_id::text=v_seq.target_token_id for update;'
 || E'\n    if not found or v_max_hp is null or v_max_hp<1 then raise exception ''Ficha do personagem alvo sem PV válidos.''; end if;'
 || E'\n    v_new_hp:=greatest(-10,least(v_max_hp,coalesce(v_hp,v_max_hp)-v_final_damage));'
 || E'\n    perform priv.srd_sync_character_vital_condition(v_seq.target_token_id,v_new_hp,false);'
 || E'\n    update public.srd_character_sheets set pv_atual=v_new_hp where character_id::text=v_seq.target_token_id;'
 || E'\n  else'
 || E'\n    if coalesce(v_target->>''maxHp'','''') !~ ''^[1-9][0-9]{0,5}$'' then raise exception ''PV máximo do alvo inválido.''; end if;'
 || E'\n    v_max_hp:=(v_target->>''maxHp'')::integer;'
 || E'\n    v_hp:=case when coalesce(v_target->>''hp'','''') ~ ''^[0-9]{1,6}$'' then (v_target->>''hp'')::integer else v_max_hp end;'
 || E'\n    v_new_hp:=greatest(0,least(v_max_hp,v_hp-v_final_damage));'
 || E'\n  end if;'
 || E'\n  v_target:=v_target||jsonb_build_object(''hp'',v_new_hp,''maxHp'',v_max_hp);');
 if position('priv.srd_sync_character_vital_condition' in v_def)=0
 or position('''character'',v_seq.target_token_id,v_damage_type' in v_def)=0 then
  raise exception 'Integração de PV de personagem no dano NPC não foi aplicada.';
 end if;
 execute v_def;
end
$patch$;
