alter table public.srd_attack_sequences
  add column if not exists power_attack_penalty smallint not null default 0;
do $$
begin
  if not exists(select 1 from pg_constraint where conrelid='public.srd_attack_sequences'::regclass and conname='srd_attack_sequences_power_attack_penalty_check') then
    alter table public.srd_attack_sequences add constraint srd_attack_sequences_power_attack_penalty_check check(power_attack_penalty between 0 and 30);
  end if;
end $$;

create or replace function public.iniciar_sequencia_ataque_iterativo_srd(
  p_campaign_id bigint,
  p_character_id text,
  p_target_token_id text,
  p_attack_type text,
  p_weapon_instance_id uuid,
  p_weapon_hand_slot text,
  p_weapon_end text,
  p_power_attack_penalty integer
) returns jsonb
language plpgsql
security definer
set search_path=public,priv,pg_temp
as $$
declare
  v_sheet public.srd_character_sheets%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_result jsonb;
  v_penalty integer:=coalesce(p_power_attack_penalty,0);
  v_bab integer;
  v_level integer;
begin
  if auth.uid() is null then raise exception 'É necessário estar autenticado.'; end if;
  if v_penalty<0 or v_penalty>30 then raise exception 'Penalidade de Ataque Poderoso inválida.'; end if;
  select sh.* into v_sheet from public.srd_character_sheets sh
  where sh.character_id::text=btrim(p_character_id);
  if not found then raise exception 'Ficha SRD não encontrada.'; end if;
  if v_penalty>0 then
    if p_attack_type<>'atk-corpo' then raise exception 'Ataque Poderoso só se aplica a ataques corpo a corpo.'; end if;
    if not exists(select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f where f->>'id'='ataque_poderoso') then
      raise exception 'A ficha não possui o talento Ataque Poderoso.';
    end if;
    select eq.* into v_weapon from public.srd_character_weapon_instances wi
      join public.srd_equipment eq on eq.id=wi.equipment_id
      where wi.instance_id=p_weapon_instance_id and wi.character_id=btrim(p_character_id)
        and wi.equipado is true and wi.hand_slot=p_weapon_hand_slot;
    if not found then raise exception 'Arma não está equipada na mão selecionada.'; end if;
    if coalesce((v_weapon.detalhes->>'weapon_light')::boolean,false) then
      raise exception 'Ataque Poderoso não pode ser usado com arma leve.';
    end if;
    select coalesce(sum(case lower(coalesce(cl.bab_progression,''))
      when 'good' then lv.class_level when 'bom' then lv.class_level
      when 'average' then floor(3*lv.class_level/4.0)::integer
      when 'medium' then floor(3*lv.class_level/4.0)::integer
      when 'medio' then floor(3*lv.class_level/4.0)::integer
      when 'poor' then floor(lv.class_level/2.0)::integer
      when 'ruim' then floor(lv.class_level/2.0)::integer else 0 end),0)::integer
      into v_bab from public.srd_character_class_levels lv
      join public.srd_classes cl on cl.id=lv.class_id
      where lv.character_id=v_sheet.character_id;
    if not exists(select 1 from public.srd_character_class_levels lv where lv.character_id=v_sheet.character_id) then
      select greatest(1,coalesce(v_sheet.nivel,1)) into v_level;
      select case lower(coalesce(cl.bab_progression,''))
        when 'good' then v_level when 'bom' then v_level
        when 'average' then floor(3*v_level/4.0)::integer
        when 'medium' then floor(3*v_level/4.0)::integer
        when 'medio' then floor(3*v_level/4.0)::integer
        when 'poor' then floor(v_level/2.0)::integer
        when 'ruim' then floor(v_level/2.0)::integer else 0 end
      into v_bab from public.srd_classes cl where cl.id=v_sheet.classe_id;
    end if;
    if v_penalty>coalesce(v_bab,0) then raise exception 'Penalidade excede o BBA atual.'; end if;
  end if;
  v_result:=public.iniciar_sequencia_ataque_iterativo_srd(
    p_campaign_id,p_character_id,p_target_token_id,p_attack_type,
    p_weapon_instance_id,p_weapon_hand_slot,p_weapon_end
  );
  update public.srd_attack_sequences set power_attack_penalty=v_penalty
    where id=(v_result->>'sequence_id')::uuid;
  return v_result||jsonb_build_object('power_attack_penalty',v_penalty);
end;
$$;
revoke all on function public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid,text,text,integer) from public,anon;
grant execute on function public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid,text,text,integer) to authenticated;

do $patch$
declare v_def text; v_old text; v_new text;
begin
  select pg_get_functiondef('public.resolver_ataque_iterativo_srd(bigint,uuid)'::regprocedure) into v_def;
  v_old:='  v_expected := v_bab + v_ability_mod + v_size_mod + v_focus + v_racial_bonus'||chr(10)||
    '    - v_proficiency_penalty - v_range_penalty - v_attempt.iterative_penalty;';
  v_new:='  v_expected := v_bab + v_ability_mod + v_size_mod + v_focus + v_racial_bonus'||chr(10)||
    '    - v_proficiency_penalty - v_range_penalty - v_attempt.iterative_penalty - v_seq.power_attack_penalty;';
  if position(v_old in v_def)=0 and position(v_new in v_def)=0 then raise exception 'Cálculo do bônus de ataque não localizado.'; end if;
  if position(v_old in v_def)>0 then v_def:=replace(v_def,v_old,v_new); end if;
  v_old:='''iterative_penalty'',v_attempt.iterative_penalty,''effect_attack_modifier'',v_effect_attack,';
  v_new:='''iterative_penalty'',v_attempt.iterative_penalty,''power_attack_penalty'',v_seq.power_attack_penalty,''effect_attack_modifier'',v_effect_attack,';
  if position(v_old in v_def)=0 and position(v_new in v_def)=0 then raise exception 'Registro de modificadores não localizado.'; end if;
  if position(v_old in v_def)>0 then v_def:=replace(v_def,v_old,v_new); end if;
  execute v_def;
end
$patch$;

do $patch$
declare v_def text; v_old text; v_new text;
begin
  select pg_get_functiondef('public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid)'::regprocedure) into v_def;
  v_old:='    v_damage_bonus:=v_damage_bonus+v_str_bonus;'||chr(10)||'  end if;';
  v_new:='    v_damage_bonus:=v_damage_bonus+v_str_bonus;'||chr(10)||'  end if;'||chr(10)||
    '  if v_seq.attack_type=''atk-corpo'' and v_seq.power_attack_penalty>0 then'||chr(10)||
    '    v_damage_bonus:=v_damage_bonus+v_seq.power_attack_penalty * case when coalesce((v_weapon.detalhes->>''weapon_two_handed'')::boolean,false) then 2 else 1 end;'||chr(10)||
    '  end if;';
  if position(v_old in v_def)=0 and position('v_seq.power_attack_penalty>0' in v_def)=0 then raise exception 'Cálculo de dano não localizado.'; end if;
  if position(v_old in v_def)>0 then v_def:=replace(v_def,v_old,v_new); end if;
  execute v_def;
end
$patch$;