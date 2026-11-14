do $patch$
declare
  v_def text;
  v_old text;
  v_new text;
begin
  select pg_get_functiondef('public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid)'::regprocedure) into v_def;

  v_old := '  v_damage_bonus integer := 0;';
  v_new := '  v_damage_bonus integer := 0;'||chr(10)||
           '  v_weapon_specialization_bonus integer := 0;';
  if position(v_old in v_def)=0 then
    if position('v_weapon_specialization_bonus integer' in v_def)>0 then
      v_old := null;
    else
      raise exception 'Declaração de bônus de dano não localizada.';
    end if;
  end if;
  if v_old is not null then v_def:=replace(v_def,v_old,v_new); end if;

  v_old := '  if not found then raise exception ''Arma não encontrada.''; end if;'||chr(10)||chr(10)||
           '  v_end_meta:=case when v_seq.weapon_end=';
  v_new := '  if not found then raise exception ''Arma não encontrada.''; end if;'||chr(10)||
           '  select coalesce(sum(case f->>''id'''||chr(10)||
           '    when ''srd35_feat_weapon_specialization'' then 2'||chr(10)||
           '    when ''srd35_feat_greater_weapon_specialization'' then 2'||chr(10)||
           '    else 0 end),0)::integer into v_weapon_specialization_bonus'||chr(10)||
           '  from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)=''array'' then v_sheet.talentos else ''[]''::jsonb end) f'||chr(10)||
           '  where f->>''id'' in (''srd35_feat_weapon_specialization'',''srd35_feat_greater_weapon_specialization'')'||chr(10)||
           '    and public.srd35_normalizar_parametro_talento(coalesce(f->>''parametro'',''''))'||chr(10)||
           '      = public.srd35_normalizar_parametro_talento(v_weapon.nome);'||chr(10)||chr(10)||
           '  v_end_meta:=case when v_seq.weapon_end=';
  if position(v_old in v_def)=0 then
    if position('v_weapon_specialization_bonus' in v_def)=0 then
      raise exception 'Ponto de inserção da especialização não localizado.';
    end if;
  else
    v_def:=replace(v_def,v_old,v_new);
  end if;

  v_old := '    v_damage_bonus:=v_damage_bonus+v_str_bonus;'||chr(10)||'  end if;';
  v_new := '    v_damage_bonus:=v_damage_bonus+v_str_bonus;'||chr(10)||'  end if;'||chr(10)||
           '  v_damage_bonus:=v_damage_bonus+v_weapon_specialization_bonus;';
  if position(v_old in v_def)=0 and position('v_damage_bonus:=v_damage_bonus+v_weapon_specialization_bonus' in v_def)=0 then
    raise exception 'Ponto de aplicação da especialização não localizado.';
  end if;
  if position(v_old in v_def)>0 then v_def:=replace(v_def,v_old,v_new); end if;

  execute v_def;
end
$patch$;