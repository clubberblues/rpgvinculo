do $patch$
declare v_def text; v_old text; v_new text;
begin
  select pg_get_functiondef('public.resolver_ataque_iterativo_srd(bigint,uuid)'::regprocedure) into v_def;
  v_old := '  v_effect_ac integer := 0;';
  v_new := v_old||chr(10)||'  v_rogue_level integer := 0;'||chr(10)||'  v_sneak_dice integer := 0;'||chr(10)||'  v_target_denies_dex boolean := false;';
  if position(v_old in v_def)=0 then
    if position('v_rogue_level integer' in v_def)=0 then raise exception 'Declaração de modificadores não localizada.'; end if;
  else v_def:=replace(v_def,v_old,v_new); end if;

  v_old := '  v_range_penalty := (v_range_increments-1)*2;'||chr(10)||'  end if;'||chr(10)||chr(10)||'  v_effect_attack :=';
  v_new := '  v_range_penalty := (v_range_increments-1)*2;'||chr(10)||'  end if;'||chr(10)||
    '  v_target_denies_dex:=exists(select 1 from public.srd_campaign_conditions cc'||chr(10)||
    '    where cc.campaign_id=p_campaign_id and cc.target_kind=''token'''||chr(10)||
    '      and cc.target_id in (v_seq.target_token_id,coalesce(v_target->>''key'',v_seq.target_token_id))'||chr(10)||
    '      and cc.active is true and cc.condition_id in'||chr(10)||
    '        (''blinded'',''cowering'',''flatfooted'',''helpless'',''paralyzed'',''pinned'',''stunned'',''unconscious'',''dying'',''stable'',''dead''));'||chr(10)||
    '  select coalesce(max(lv.class_level),0) into v_rogue_level'||chr(10)||
    '    from public.srd_character_class_levels lv join public.srd_classes cls on cls.id=lv.class_id'||chr(10)||
    '    where lv.character_id=v_seq.actor_character_id and cls.class_key=''rogue'';'||chr(10)||
    '  if v_rogue_level=0 and not exists(select 1 from public.srd_character_class_levels lv'||chr(10)||
    '      where lv.character_id=v_seq.actor_character_id) and v_sheet.classe_id=''ladino'' then'||chr(10)||
    '    v_rogue_level:=greatest(1,coalesce(v_sheet.nivel,1));'||chr(10)||
    '  end if;'||chr(10)||
    '  if v_target_denies_dex and v_target_type not in (''undead'',''construct'',''ooze'',''plant'',''elemental'',''incorporeal'') then'||chr(10)||
    '    v_sneak_dice:=least(10,floor((v_rogue_level+1)/2.0)::integer);'||chr(10)||
    '    if v_seq.attack_type=''atk-dist'' and v_dist>6 then v_sneak_dice:=0; end if;'||chr(10)||
    '  end if;'||chr(10)||chr(10)||'  v_effect_attack :=';
  if position(v_old in v_def)=0 then
    if position('v_target_denies_dex:=' in v_def)=0 then raise exception 'Ponto de inserção do Ataque Furtivo não localizado.'; end if;
  else v_def:=replace(v_def,v_old,v_new); end if;

  v_old := '''weapon_hand_slot'',v_seq.weapon_hand_slot,''weapon_end'',v_seq.weapon_end';
  v_new := '''weapon_hand_slot'',v_seq.weapon_hand_slot,''weapon_end'',v_seq.weapon_end,''sneak_attack_dice'',v_sneak_dice,''sneak_attack_eligible'',(v_sneak_dice>0)';
  if position(v_old in v_def)=0 and position('v_sneak_dice' in v_def)=0 then raise exception 'Registro de resultado do ataque não localizado.'; end if;
  if position(v_old in v_def)>0 then v_def:=replace(v_def,v_old,v_new); end if;
  execute v_def;
end
$patch$;

do $patch$
declare v_def text; v_old text; v_new text;
begin
  select pg_get_functiondef('public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid)'::regprocedure) into v_def;
  v_def:=replace(v_def,'public.aplicar_dano_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)','public.aplicar_dano_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[])');
  if position('p_sneak_damage_rolls integer[]' in v_def)=0 then raise exception 'Não foi possível derivar overload de dano com Ataque Furtivo.'; end if;
  v_old := '  v_roll_sum integer := 0;';
  v_new := v_old||chr(10)||'  v_sneak_roll_sum integer := 0;'||chr(10)||'  v_sneak_dice_expected integer := 0;';
  if position(v_old in v_def)=0 then raise exception 'Acumulador de dano não localizado.'; end if;
  v_def:=replace(v_def,v_old,v_new);
  v_old := '  for i in 1..cardinality(p_damage_rolls) loop';
  v_new := '  v_sneak_dice_expected:=greatest(0,coalesce(nullif(v_attempt.resolution_data->>''sneak_attack_dice'','''')::integer,0));'||chr(10)||
    '  if v_sneak_dice_expected=0 then'||chr(10)||
    '    if coalesce(cardinality(p_sneak_damage_rolls),0)<>0 then raise exception ''Esta tentativa não possui Ataque Furtivo elegível.''; end if;'||chr(10)||
    '  else'||chr(10)||
    '    if p_sneak_damage_rolls is null or cardinality(p_sneak_damage_rolls)<>v_sneak_dice_expected'||chr(10)||
    '       or array_position(p_sneak_damage_rolls,null) is not null'||chr(10)||
    '       or exists(select 1 from unnest(p_sneak_damage_rolls) x where x<1 or x>6) then'||chr(10)||
    '      raise exception ''Ataque Furtivo exige exatamente % resultados de d6 manuais.'',v_sneak_dice_expected;'||chr(10)||
    '    end if;'||chr(10)||
    '    select coalesce(sum(x),0)::integer into v_sneak_roll_sum from unnest(p_sneak_damage_rolls) x;'||chr(10)||
    '  end if;'||chr(10)||v_old;
  if position(v_old in v_def)=0 then raise exception 'Loop de validação dos dados não localizado.'; end if;
  v_def:=replace(v_def,v_old,v_new);
  v_old := '  v_raw_damage:=v_roll_sum+v_damage_bonus+(v_critical_static_bonus*greatest(0,v_mult-1));';
  v_new := '  v_raw_damage:=v_roll_sum+v_damage_bonus+(v_critical_static_bonus*greatest(0,v_mult-1))+v_sneak_roll_sum;';
  if position(v_old in v_def)=0 then raise exception 'Cálculo final de dano não localizado.'; end if;
  v_def:=replace(v_def,v_old,v_new);
  v_old := '''damage_roll_sum'',v_roll_sum,''damage_bonus'',v_damage_bonus,''damage_raw'',v_raw_damage,';
  v_new := '''damage_roll_sum'',v_roll_sum,''sneak_attack_roll_sum'',v_sneak_roll_sum,''sneak_attack_dice'',v_sneak_dice_expected,''damage_bonus'',v_damage_bonus,''damage_raw'',v_raw_damage,';
  if position(v_old in v_def)=0 then raise exception 'Metadados de dano não localizados.'; end if;
  v_def:=replace(v_def,v_old,v_new);
  v_old := '''damage_applied'',v_final_damage,''damage_rolls'',p_damage_rolls,''damage_type'',v_damage_type,';
  v_new := '''damage_applied'',v_final_damage,''damage_rolls'',p_damage_rolls,''sneak_damage_rolls'',coalesce(p_sneak_damage_rolls,''{}''::integer[]),''damage_type'',v_damage_type,';
  if position(v_old in v_def)=0 then raise exception 'Retorno de dano não localizado.'; end if;
  v_def:=replace(v_def,v_old,v_new);
  execute v_def;
  execute 'revoke all on function public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid,integer[]) from public,anon';
  execute 'grant execute on function public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid,integer[]) to authenticated';
end
$patch$;