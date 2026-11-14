do $patch$
declare v_def text; v_old text; v_new text;
begin
  select pg_get_functiondef('public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid)'::regprocedure) into v_def;
  v_old:='  v_weapon_specialization_bonus integer := 0;';
  v_new:=v_old||chr(10)||'  v_critical_static_bonus integer := 0;';
  if position(v_old in v_def)=0 then
    if position('v_critical_static_bonus integer' in v_def)=0 then raise exception 'Declaração de bônus crítico não localizada.'; end if;
  else v_def:=replace(v_def,v_old,v_new); end if;

  v_old:='    v_damage_bonus:=v_damage_bonus+v_str_bonus;';
  v_new:=v_old||chr(10)||'    v_critical_static_bonus:=v_critical_static_bonus+v_str_bonus;';
  if position(v_old in v_def)=0 and position('v_critical_static_bonus:=v_critical_static_bonus+v_str_bonus' in v_def)=0 then
    raise exception 'Bônus de Força não localizado.';
  end if;
  if position(v_old in v_def)>0 then v_def:=replace(v_def,v_old,v_new); end if;

  v_old:='    v_damage_bonus:=v_damage_bonus+v_seq.power_attack_penalty * case when coalesce((v_weapon.detalhes->>''weapon_two_handed'')::boolean,false) then 2 else 1 end;';
  v_new:=v_old||chr(10)||'    v_critical_static_bonus:=v_critical_static_bonus+v_seq.power_attack_penalty * case when coalesce((v_weapon.detalhes->>''weapon_two_handed'')::boolean,false) then 2 else 1 end;';
  if position(v_old in v_def)=0 and position('v_critical_static_bonus:=v_critical_static_bonus+v_seq.power_attack_penalty' in v_def)=0 then
    raise exception 'Bônus de Ataque Poderoso não localizado.';
  end if;
  if position(v_old in v_def)>0 then v_def:=replace(v_def,v_old,v_new); end if;

  v_old:='  v_damage_bonus:=v_damage_bonus+v_weapon_specialization_bonus;';
  v_new:=v_old||chr(10)||'  v_critical_static_bonus:=v_critical_static_bonus+v_weapon_specialization_bonus;';
  if position(v_old in v_def)=0 and position('v_critical_static_bonus:=v_critical_static_bonus+v_weapon_specialization_bonus' in v_def)=0 then
    raise exception 'Bônus de Especialização não localizado.';
  end if;
  if position(v_old in v_def)>0 then v_def:=replace(v_def,v_old,v_new); end if;

  v_old:='  v_raw_damage:=v_roll_sum+v_damage_bonus;';
  v_new:='  v_raw_damage:=v_roll_sum+v_damage_bonus+(v_critical_static_bonus*greatest(0,v_mult-1));';
  if position(v_old in v_def)=0 and position(v_new in v_def)=0 then raise exception 'Cálculo final de dano não localizado.'; end if;
  if position(v_old in v_def)>0 then v_def:=replace(v_def,v_old,v_new); end if;
  execute v_def;
end
$patch$;