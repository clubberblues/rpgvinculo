
create table if not exists public.srd_attack_sequence_attempts (
  id uuid primary key default gen_random_uuid(),
  sequence_id uuid not null references public.srd_attack_sequences(id) on delete cascade,
  attempt_index smallint not null check (attempt_index between 1 and 6),
  manual_d20 smallint not null check (manual_d20 between 1 and 20),
  iterative_penalty smallint not null check (iterative_penalty between 0 and 25),
  idempotency_key uuid not null,
  status text not null default 'pending_resolution'
    check (status in ('pending_resolution','miss','hit_pending_damage','damage_applied','cancelled')),
  created_at timestamptz not null default now(),
  resolved_at timestamptz,
  constraint srd_attack_sequence_attempts_unique_index unique(sequence_id,attempt_index),
  constraint srd_attack_sequence_attempts_unique_idempotency unique(idempotency_key)
);

alter table public.srd_attack_sequence_attempts enable row level security;
revoke all on public.srd_attack_sequence_attempts from public, anon, authenticated;

create or replace function public.registrar_rolagem_ataque_iterativo_srd(
  p_campaign_id bigint,
  p_sequence_id uuid,
  p_manual_d20 integer,
  p_idempotency_key uuid
) returns jsonb
language plpgsql
security definer
set search_path = public, priv, pg_temp
as $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_sequence public.srd_attack_sequences%rowtype;
  v_attempt public.srd_attack_sequence_attempts%rowtype;
  v_combat jsonb;
  v_turn integer;
  v_round integer;
  v_index integer;
  v_penalty integer;
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;
  if p_manual_d20 is null or p_manual_d20 < 1 or p_manual_d20 > 20
     or p_idempotency_key is null then
    raise exception 'A rolagem manual ou a chave de idempotência é inválida.';
  end if;

  select c.* into v_campaign
  from public.campaigns c
  where c.id = p_campaign_id
  for update;
  if not found or upper(coalesce(v_campaign.state,'')) <> 'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  select s.* into v_sequence
  from public.srd_attack_sequences s
  where s.id = p_sequence_id and s.campaign_id = p_campaign_id
  for update;
  if not found then raise exception 'Sequência de ataques não encontrada.'; end if;

  if v_sequence.created_by <> v_user then
    raise exception 'Somente quem iniciou a sequência pode registrar suas rolagens.';
  end if;

  select a.* into v_attempt
  from public.srd_attack_sequence_attempts a
  where a.idempotency_key = p_idempotency_key;
  if found then
    if v_attempt.sequence_id <> p_sequence_id
       or v_attempt.manual_d20 <> p_manual_d20 then
      raise exception 'A chave de idempotência já foi usada para outra rolagem.';
    end if;
    return jsonb_build_object(
      'attempt_id',v_attempt.id,'sequence_id',v_attempt.sequence_id,
      'attempt_index',v_attempt.attempt_index,'manual_d20',v_attempt.manual_d20,
      'iterative_penalty',v_attempt.iterative_penalty,'status',v_attempt.status,
      'replayed',true
    );
  end if;

  if v_sequence.status <> 'active' then
    raise exception 'Esta sequência não está ativa.';
  end if;
  if v_sequence.next_attack_index > v_sequence.attacks_total then
    raise exception 'Todos os ataques desta sequência já receberam rolagem.';
  end if;

  v_combat := coalesce(v_campaign.combat_data,'{}'::jsonb);
  if lower(coalesce(v_combat->>'active','false')) <> 'true'
     or coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$'
     or coalesce(v_combat->>'round','') !~ '^[0-9]+$' then
    raise exception 'A iniciativa não está ativa ou o turno mudou.';
  end if;
  v_turn := (v_combat->>'current_turn')::integer;
  v_round := greatest(1,(v_combat->>'round')::integer);
  if v_turn <> v_sequence.turn_index or v_round <> v_sequence.round_number then
    raise exception 'O turno ou a rodada mudou; a sequência não pode continuar.';
  end if;
  if not exists (
    select 1 from public.members m
    join public.characters ch on ch.campaign_id=m.campaign_id and ch.user_id=m.user_id
    where m.campaign_id=p_campaign_id and m.user_id=v_user and m.role='PLAYER'
      and ch.id=v_sequence.actor_character_id
  ) then
    raise exception 'A ficha da sequência não pertence ao jogador autenticado.';
  end if;

  v_index := v_sequence.next_attack_index;
  v_penalty := (v_index - 1) * 5;

  insert into public.srd_attack_sequence_attempts(
    sequence_id,attempt_index,manual_d20,iterative_penalty,idempotency_key
  ) values (
    p_sequence_id,v_index,p_manual_d20,v_penalty,p_idempotency_key
  ) returning * into v_attempt;

  update public.srd_attack_sequences
  set next_attack_index = v_index + 1
  where id = p_sequence_id;

  return jsonb_build_object(
    'attempt_id',v_attempt.id,'sequence_id',p_sequence_id,
    'attempt_index',v_index,'manual_d20',p_manual_d20,
    'iterative_penalty',v_penalty,'status',v_attempt.status,
    'attacks_total',v_sequence.attacks_total,'replayed',false
  );
end;
$function$;

revoke all on function public.registrar_rolagem_ataque_iterativo_srd(bigint,uuid,integer,uuid) from public, anon;
grant execute on function public.registrar_rolagem_ataque_iterativo_srd(bigint,uuid,integer,uuid) to authenticated;
