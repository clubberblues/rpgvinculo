do $patch$
declare
  v_def text;
  v_old text := $old$  v_level := greatest(1,coalesce(v_sheet.nivel,1));
  v_bab := case lower(coalesce(v_class.bab_progression,''))
    when 'good' then v_level when 'bom' then v_level
    when 'average' then floor(3*v_level/4.0)::integer
    when 'medium' then floor(3*v_level/4.0)::integer
    when 'medio' then floor(3*v_level/4.0)::integer
    when 'poor' then floor(v_level/2.0)::integer
    when 'ruim' then floor(v_level/2.0)::integer else 0 end;
  if v_bab <> v_seq.base_attack_bonus then
    raise exception 'O BBA da ficha mudou desde o início da sequência.';
  end if;$old$;
  v_new text := $new$  v_level := greatest(1,coalesce(v_sheet.nivel,1));
  select coalesce(sum(case lower(coalesce(clas.bab_progression,''))
    when 'good' then lv.class_level when 'bom' then lv.class_level
    when 'average' then floor(3*lv.class_level/4.0)::integer
    when 'medium' then floor(3*lv.class_level/4.0)::integer
    when 'medio' then floor(3*lv.class_level/4.0)::integer
    when 'poor' then floor(lv.class_level/2.0)::integer
    when 'ruim' then floor(lv.class_level/2.0)::integer else 0 end),0)::integer
  into v_bab
  from public.srd_character_class_levels lv
  join public.srd_classes clas on clas.id=lv.class_id
  where lv.character_id=v_seq.actor_character_id;
  if not exists(select 1 from public.srd_character_class_levels lv
      where lv.character_id=v_seq.actor_character_id) then
    v_bab := case lower(coalesce(v_class.bab_progression,''))
      when 'good' then v_level when 'bom' then v_level
      when 'average' then floor(3*v_level/4.0)::integer
      when 'medium' then floor(3*v_level/4.0)::integer
      when 'medio' then floor(3*v_level/4.0)::integer
      when 'poor' then floor(v_level/2.0)::integer
      when 'ruim' then floor(v_level/2.0)::integer else 0 end;
  end if;
  if v_bab <> v_seq.base_attack_bonus then
    raise exception 'O BBA da ficha mudou desde o início da sequência.';
  end if;$new$;
begin
  select pg_get_functiondef('public.resolver_ataque_iterativo_srd(bigint,uuid)'::regprocedure) into v_def;
  if position(v_old in v_def)=0 then
    if position(v_new in v_def)>0 then return; end if;
    raise exception 'Bloco BBA esperado não encontrado; alteração cancelada.';
  end if;
  execute replace(v_def,v_old,v_new);
end
$patch$;

do $patch$
declare
  v_def text;
  v_old text := $old$  if not v_proficient and v_weapon_prof='exotic' and v_sheet.raca_id='anao'
     and coalesce(v_weapon.detalhes->'weapon_familiarity_race_ids','[]'::jsonb) ? 'anao' then
    v_proficient := exists (
      select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_class_profs)='array' then v_class_profs else '[]'::jsonb end) p
      where lower(btrim(p.value))='todas as armas simples e marciais'
    );
  end if;$old$;
  v_new text := $new$  if not v_proficient and v_weapon_prof='exotic' and v_sheet.raca_id='anao'
     and coalesce(v_weapon.detalhes->'weapon_familiarity_race_ids','[]'::jsonb) ? 'anao' then
    v_proficient := exists (
      select 1 from jsonb_array_elements_text(case when jsonb_typeof(v_class_profs)='array' then v_class_profs else '[]'::jsonb end) p
      where lower(btrim(p.value))='todas as armas simples e marciais'
    ) or exists (
      select 1 from jsonb_array_elements(case when jsonb_typeof(v_sheet.talentos)='array' then v_sheet.talentos else '[]'::jsonb end) f
      where f->>'id'='srd35_feat_martial_weapon_proficiency'
        and public.srd35_normalizar_parametro_talento(coalesce(f->>'parametro',''))=public.srd35_normalizar_parametro_talento(v_weapon_name)
    );
  end if;$new$;
begin
  select pg_get_functiondef('public.resolver_ataque_iterativo_srd(bigint,uuid)'::regprocedure) into v_def;
  if position(v_old in v_def)>0 then
    execute replace(v_def,v_old,v_new);
  elsif position(v_new in v_def)=0 then
    raise exception 'Bloco de familiaridade racial não encontrado; alteração cancelada.';
  end if;
end
$patch$;