
do $$
declare v_def text;
begin
 v_def:=pg_get_functiondef('public.iniciar_ataque_iterativo_npc_srd(bigint,text,text,text,uuid,text,text)'::regprocedure);
 v_def:=replace(v_def,
  'select w into v_weapon'||E'\n from jsonb_array_elements(coalesce(v_profile->''weapons'',''[]''::jsonb)) w'||E'\n where w->>''instance_id''=p_weapon_instance_id::text'||E'\n and w->>''hand_slot''=p_weapon_hand_slot'||E'\n limit 1;',
  'select e.value into v_weapon'||E'\n from jsonb_array_elements(coalesce(v_profile->''weapons'',''[]''::jsonb)) as e(value)'||E'\n where e.value->>''instance_id''=p_weapon_instance_id::text'||E'\n and e.value->>''hand_slot''=p_weapon_hand_slot'||E'\n limit 1;');
 v_def:=replace(v_def,
  'from jsonb_array_elements(v_campaign.cba_data->''tokens'') t(token)',
  'from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->''tokens'')=''array'' then v_campaign.cba_data->''tokens'' else ''[]''::jsonb end) t(token)');
 if position('as e(value)' in v_def)=0 then
  raise exception 'A substituição da seleção da arma não foi aplicada.';
 end if;
 execute v_def;
end $$;
