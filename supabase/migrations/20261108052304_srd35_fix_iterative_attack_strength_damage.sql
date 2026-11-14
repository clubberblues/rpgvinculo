do $patch$
declare
  v_def text;
  v_old text := $old$if v_seq.attack_type='atk-corpo' then
    v_str:=coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10);
    v_str_bonus:=floor((v_str-10)::numeric/2)::integer;
    if v_seq.weapon_hand_slot='off_hand' then
      v_str_bonus:=floor(v_str_bonus/2.0)::integer;
    elsif coalesce((v_weapon.detalhes->>'weapon_two_handed')::boolean,false)
      and not coalesce((v_weapon.detalhes->>'weapon_double')::boolean,false) then
      v_str_bonus:=floor(v_str_bonus*1.5)::integer;
    end if;
  end if;
  v_damage_bonus:=priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'damage')
    + case when v_seq.attack_type='atk-corpo'
      then floor((v_str+priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'strength')-10)::numeric/2)::integer-v_str_bonus
      else 0 end;
  -- v_str_bonus is the weapon-hand contribution; replace it with the final Strength contribution.
  if v_seq.attack_type='atk-corpo' then
    v_damage_bonus:=priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'damage')
      + v_str_bonus
      + floor((v_str+priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'strength')-10)::numeric/2)::integer
      - floor((v_str-10)::numeric/2)::integer;
  end if;$old$;
  v_new text := $new$ v_damage_bonus:=priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'damage');
  if v_seq.attack_type='atk-corpo' then
    v_str:=coalesce(nullif(v_sheet.atributos->>'FOR','')::integer,10);
    v_str_bonus:=floor((v_str+priv.srd_effective_modifier(p_campaign_id,'character',v_seq.actor_character_id::text,'strength')-10)::numeric/2)::integer;
    if v_seq.weapon_hand_slot='off_hand' then
      v_str_bonus:=floor(v_str_bonus/2.0)::integer;
    elsif coalesce((v_weapon.detalhes->>'weapon_two_handed')::boolean,false)
      and not coalesce((v_weapon.detalhes->>'weapon_double')::boolean,false) then
      v_str_bonus:=floor(v_str_bonus*1.5)::integer;
    end if;
    v_damage_bonus:=v_damage_bonus+v_str_bonus;
  end if;$new$;
begin
  select pg_get_functiondef('public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid)'::regprocedure) into v_def;
  if position(v_old in v_def)>0 then
    v_def:=replace(v_def,v_old,v_new);
    execute v_def;
  elsif position(v_new in v_def)=0 then
    raise exception 'Cálculo de Força não está na versão esperada.';
  end if;
end
$patch$;