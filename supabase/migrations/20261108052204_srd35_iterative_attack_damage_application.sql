alter table public.srd_attack_sequence_attempts
  add column if not exists damage_idempotency_key uuid;
create unique index if not exists srd_attack_sequence_attempts_damage_idempotency_uidx
  on public.srd_attack_sequence_attempts(damage_idempotency_key)
  where damage_idempotency_key is not null;

create or replace function public.aplicar_dano_ataque_iterativo_srd(
  p_campaign_id bigint,
  p_attempt_id uuid,
  p_damage_rolls integer[],
  p_idempotency_key uuid
) returns jsonb
language plpgsql
security definer
set search_path = public, priv, pg_temp
as $$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_attempt public.srd_attack_sequence_attempts%rowtype;
  v_seq public.srd_attack_sequences%rowtype;
  v_sheet public.srd_character_sheets%rowtype;
  v_race public.srd_races%rowtype;
  v_weapon public.srd_equipment%rowtype;
  v_scene jsonb;
  v_tokens jsonb;
  v_target jsonb;
  v_target_ord bigint;
  v_target_count integer;
  v_expr text;
  v_dice integer;
  v_faces integer;
  v_mult integer := 1;
  v_roll_sum integer := 0;
  v_str integer := 0;
  v_str_bonus integer := 0;
  v_damage_bonus integer := 0;
  v_raw_damage integer := 0;
  v_final_damage integer := 0;
  v_damage_type text;
  v_max_hp integer;
  v_hp integer;
  v_new_hp integer;
  v_end_meta jsonb;
  v_existing public.srd_attack_sequence_attempts%rowtype;
  v_round integer;
  v_turn integer;
  i integer;
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;
  if p_idempotency_key is null or p_damage_rolls is null
     or cardinality(p_damage_rolls)<1 or cardinality(p_damage_rolls)>30
     or array_position(p_damage_rolls,null) is not null
     or exists(select 1 from unnest(p_damage_rolls) x where x<1 or x>1000) then
    raise exception 'Rolagens de dano inválidas.';
  end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  select * into v_existing from public.srd_attack_sequence_attempts
    where damage_idempotency_key=p_idempotency_key;
  if found then
    if v_existing.id<>p_attempt_id then raise exception 'Chave de dano já utilizada em outra tentativa.'; end if;
    return jsonb_build_object('attempt_id',v_existing.id,'status',v_existing.status,
      'damage_applied',v_existing.damage_applied,'damage_rolls',v_existing.damage_rolls,
      'replayed',true);
  end if;

  select * into v_attempt from public.srd_attack_sequence_attempts where id=p_attempt_id for update;
  if not found then raise exception 'Tentativa de ataque não encontrada.'; end if;
  select * into v_seq from public.srd_attack_sequences
    where id=v_attempt.sequence_id and campaign_id=p_campaign_id for update;
  if not found then raise exception 'Sequência não encontrada.'; end if;
  if v_seq.created_by<>v_user then raise exception 'Somente quem iniciou a sequência pode registrar o dano.'; end if;
  if v_attempt.status<>'hit_pending_damage' then raise exception 'A tentativa ainda não está pronta para receber dano.'; end if;
  if not exists (
    select 1 from public.characters ch join public.members m
      on m.campaign_id=ch.campaign_id and m.user_id=ch.user_id
    where ch.id=v_seq.actor_character_id and ch.campaign_id=p_campaign_id
      and ch.user_id=v_user and m.role='PLAYER'
  ) then raise exception 'Personagem não pertence ao jogador autenticado.'; end if;

  v_turn:=case when coalesce(v_campaign.combat_data->>'current_turn','') ~ '^[0-9]+$'
    then (v_campaign.combat_data->>'current_turn')::integer else -1 end;
  v_round:=case when coalesce(v_campaign.combat_data->>'round','') ~ '^[0-9]+$'
    then greatest(1,(v_campaign.combat_data->>'round')::integer) else -1 end;
  if lower(coalesce(v_campaign.combat_data->>'active','false'))<>'true'
    or v_turn<>v_seq.turn_index or v_round<>v_seq.round_number then
    raise exception 'Turno ou rodada mudou antes da aplicação do dano.';
  end if;

  select sh.* into v_sheet from public.srd_character_sheets sh where sh.character_id=v_seq.actor_character_id;
  select r.* into v_race from public.srd_races r where r.id=v_sheet.raca_id;
  if not exists (
    select 1 from public.srd_character_weapon_instances wi
    where wi.instance_id=v_seq.weapon_instance_id and wi.character_id=v_seq.actor_character_id::text
      and wi.equipado is true and wi.hand_slot=v_seq.weapon_hand_slot
  ) then raise exception 'A arma não está mais equipada na mão vinculada.'; end if;
  select eq.* into v_weapon from public.srd_character_weapon_instances wi
    join public.srd_equipment eq on eq.id=wi.equipment_id
    where wi.instance_id=v_seq.weapon_instance_id;
  if not found then raise exception 'Arma não encontrada.'; end if;

  v_end_meta:=case when v_seq.weapon_end='off' then coalesce(v_weapon.detalhes->'weapon_end_off','{}'::jsonb)
    when v_seq.weapon_end='main' then coalesce(v_weapon.detalhes->'weapon_end_main','{}'::jsonb)
    else '{}'::jsonb end;
  v_expr:=coalesce(
    case when lower(coalesce(v_race.tamanho,'')) in ('pequeno','small')
      then v_end_meta->>'damage_small' else v_end_meta->>'damage_medium' end,
    case when lower(coalesce(v_race.tamanho,'')) in ('pequeno','small')
      then v_weapon.detalhes->>'damage_small' else v_weapon.detalhes->>'damage_medium' end,
    v_weapon.dano
  );
  if v_expr !~ '^[0-9]+d[0-9]+$' then
    raise exception 'Expressão de dano da arma não está normalizada: %.',coalesce(v_expr,'(vazia)');
  end if;
  v_dice:=split_part(v_expr,'d',1)::integer;
  v_faces:=split_part(v_expr,'d',2)::integer;
  if v_dice<1 or v_dice>10 or v_faces<2 or v_faces>100 then
    raise exception 'Expressão de dano da arma fora dos limites suportados.';
  end if;
  v_mult:=case when v_attempt.is_critical then
    coalesce(nullif(v_attempt.resolution_data->>'critical_multiplier','')::integer,2)
    else 1 end;
  if v_mult<2 or v_mult>5 then
    if v_attempt.is_critical then raise exception 'Multiplicador crítico inválido.'; else v_mult:=1; end if;
  end if;
  if cardinality(p_damage_rolls)<>v_dice*v_mult then
    raise exception 'A arma exige % resultados de dado de dano (% dados x multiplicador %).',
      v_dice*v_mult,v_dice,v_mult;
  end if;
  for i in 1..cardinality(p_damage_rolls) loop
    if p_damage_rolls[i]>v_faces then
      raise exception 'Resultado % excede o dado d%.',p_damage_rolls[i],v_faces;
    end if;
    v_roll_sum:=v_roll_sum+p_damage_rolls[i];
  end loop;

  if v_seq.attack_type='atk-corpo' then
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
  end if;
  v_raw_damage:=v_roll_sum+v_damage_bonus;
  v_damage_type:=lower(coalesce(v_end_meta->>'damage_type',v_weapon.tipo_dano,'bludgeoning'));
  v_damage_type:=case v_damage_type
    when 'cortante' then 'slashing' when 'perfurante' then 'piercing'
    when 'impacto' then 'bludgeoning' when 'cortante/perfurante' then 'physical'
    when 'impacto/perfurante' then 'physical' else v_damage_type end;
  v_final_damage:=priv.srd_adjust_damage(p_campaign_id,'token',v_seq.target_token_id,v_damage_type,greatest(0,v_raw_damage));

  v_scene:=coalesce(v_campaign.cba_data,'{}'::jsonb);
  v_tokens:=case when jsonb_typeof(v_scene->'tokens')='array' then v_scene->'tokens' else '[]'::jsonb end;
  select count(*)::integer,min(t.ordinality) into v_target_count,v_target_ord
    from jsonb_array_elements(v_tokens) with ordinality t(token,ordinality)
    where t.token->>'id'=v_seq.target_token_id and t.token->>'tipo' in ('npc','monstro');
  if v_target_count<>1 then raise exception 'Alvo ausente ou duplicado na cena.'; end if;
  v_target:=v_tokens->(v_target_ord::integer-1);
  if coalesce(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' then raise exception 'PV máximo do alvo inválido.'; end if;
  v_max_hp:=(v_target->>'maxHp')::integer;
  v_hp:=case when coalesce(v_target->>'hp','') ~ '^[0-9]{1,6}$' then (v_target->>'hp')::integer else v_max_hp end;
  v_new_hp:=greatest(0,least(v_max_hp,v_hp-v_final_damage));
  v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
  v_scene:=v_scene||jsonb_build_object('tokens',jsonb_set(v_tokens,array[(v_target_ord-1)::text],v_target,false));
  update public.campaigns set cba_data=v_scene where id=p_campaign_id;

  update public.srd_attack_sequence_attempts
    set status='damage_applied',damage_rolls=p_damage_rolls,damage_applied=v_final_damage,
      damage_type=v_damage_type,damage_applied_at=now(),damage_idempotency_key=p_idempotency_key,
      resolution_data=resolution_data||jsonb_build_object('damage_expression',v_expr,
        'damage_roll_sum',v_roll_sum,'damage_bonus',v_damage_bonus,'damage_raw',v_raw_damage,
        'damage_final',v_final_damage,'critical_multiplier_applied',v_mult)
    where id=p_attempt_id returning * into v_attempt;

  if v_attempt.attempt_index=v_seq.attacks_total then
    update public.srd_attack_sequences set status='completed',completed_at=now() where id=v_seq.id;
  end if;
  return jsonb_build_object('attempt_id',v_attempt.id,'status',v_attempt.status,
    'damage_applied',v_final_damage,'damage_rolls',p_damage_rolls,'damage_type',v_damage_type,
    'target_hp',v_new_hp,'target_max_hp',v_max_hp,'critical',v_attempt.is_critical,
    'critical_multiplier',v_mult,'replayed',false);
end;
$$;
revoke all on function public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid) from public, anon;
grant execute on function public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid) to authenticated;