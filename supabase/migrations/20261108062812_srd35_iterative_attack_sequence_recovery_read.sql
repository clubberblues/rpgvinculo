
create or replace function public.consultar_sequencia_ataque_iterativo_pendente_srd(
  p_campaign_id bigint,
  p_character_id text
) returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_user uuid := auth.uid();
  v_sequence public.srd_attack_sequences%rowtype;
  v_attempts jsonb;
begin
  if v_user is null then
    raise exception 'É necessário estar autenticado.';
  end if;
  if p_campaign_id is null or coalesce(p_character_id,'') !~ '^[0-9]+$' then
    raise exception 'Campanha ou personagem inválido.';
  end if;

  if not exists (
    select 1
    from public.members m
    join public.characters ch
      on ch.campaign_id = m.campaign_id
     and ch.user_id = m.user_id
    where m.campaign_id = p_campaign_id
      and m.user_id = v_user
      and m.role = 'PLAYER'
      and ch.id::text = p_character_id
  ) then
    raise exception 'O personagem não pertence ao jogador autenticado nesta campanha.';
  end if;

  select s.* into v_sequence
  from public.srd_attack_sequences s
  where s.campaign_id = p_campaign_id
    and s.actor_character_id::text = p_character_id
    and s.created_by = v_user
    and s.status = 'active'
  order by s.created_at desc
  limit 1
  for update;

  if not found then
    return jsonb_build_object('active', false);
  end if;

  select coalesce(jsonb_agg(
    jsonb_build_object(
      'attempt_id', a.id,
      'attempt_index', a.attempt_index,
      'manual_d20', a.manual_d20,
      'iterative_penalty', a.iterative_penalty,
      'status', a.status,
      'resolution_data', a.resolution_data,
      'critical_confirmation_d20', a.critical_confirmation_d20,
      'is_critical', a.is_critical,
      'damage_rolls', a.damage_rolls,
      'damage_applied', a.damage_applied
    ) order by a.attempt_index
  ), '[]'::jsonb)
  into v_attempts
  from public.srd_attack_sequence_attempts a
  where a.sequence_id = v_sequence.id;

  return jsonb_build_object(
    'active', true,
    'sequence_id', v_sequence.id,
    'campaign_id', v_sequence.campaign_id,
    'character_id', v_sequence.actor_character_id,
    'target_token_id', v_sequence.target_token_id,
    'attack_type', v_sequence.attack_type,
    'weapon_instance_id', v_sequence.weapon_instance_id,
    'weapon_hand_slot', v_sequence.weapon_hand_slot,
    'weapon_end', v_sequence.weapon_end,
    'power_attack_penalty', v_sequence.power_attack_penalty,
    'round_number', v_sequence.round_number,
    'turn_index', v_sequence.turn_index,
    'base_attack_bonus', v_sequence.base_attack_bonus,
    'attacks_total', v_sequence.attacks_total,
    'next_attack_index', v_sequence.next_attack_index,
    'status', v_sequence.status,
    'attempts', v_attempts
  );
end;
$function$;

revoke all on function public.consultar_sequencia_ataque_iterativo_pendente_srd(bigint,text) from public, anon;
grant execute on function public.consultar_sequencia_ataque_iterativo_pendente_srd(bigint,text) to authenticated;
