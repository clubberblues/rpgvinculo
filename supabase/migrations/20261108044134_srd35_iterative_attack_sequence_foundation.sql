
create table if not exists public.srd_attack_sequences (
  id uuid primary key default gen_random_uuid(),
  campaign_id bigint not null references public.campaigns(id) on delete cascade,
  actor_character_id bigint not null references public.characters(id) on delete cascade,
  target_token_id text not null,
  attack_type text not null check (attack_type in ('atk-corpo','atk-dist')),
  weapon_instance_id uuid,
  round_number integer not null check (round_number > 0),
  turn_index integer not null check (turn_index >= 0),
  base_attack_bonus integer not null check (base_attack_bonus >= 1),
  attacks_total smallint not null check (attacks_total between 2 and 6),
  next_attack_index smallint not null default 1 check (next_attack_index between 1 and 7),
  status text not null default 'active' check (status in ('active','completed','abandoned','invalidated')),
  created_by uuid not null,
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  constraint srd_attack_sequences_progress_check check (next_attack_index <= attacks_total + 1)
);

create unique index if not exists srd_attack_sequences_one_active_turn
  on public.srd_attack_sequences(campaign_id, actor_character_id, round_number, turn_index)
  where status = 'active';

create index if not exists srd_attack_sequences_campaign_actor
  on public.srd_attack_sequences(campaign_id, actor_character_id, created_at desc);

alter table public.srd_attack_sequences enable row level security;
revoke all on public.srd_attack_sequences from anon, authenticated;
revoke all on public.srd_attack_sequences from public;

create or replace function public.iniciar_sequencia_ataque_iterativo_srd(
  p_campaign_id bigint,
  p_character_id text,
  p_target_token_id text,
  p_attack_type text,
  p_weapon_instance_id uuid default null
) returns jsonb
language plpgsql
security definer
set search_path = public, priv, pg_temp
as $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_combat jsonb;
  v_turn integer;
  v_round integer;
  v_bab integer;
  v_attacks integer;
  v_action jsonb;
  v_sequence public.srd_attack_sequences%rowtype;
begin
  if v_user is null then
    raise exception 'É necessário estar autenticado.';
  end if;
  if nullif(btrim(p_character_id), '') is null
     or nullif(btrim(p_target_token_id), '') is null
     or p_attack_type not in ('atk-corpo','atk-dist') then
    raise exception 'Dados da sequência de ataque inválidos.';
  end if;

  select c.* into v_campaign
  from public.campaigns c
  where c.id = p_campaign_id
  for update;
  if not found or upper(coalesce(v_campaign.state,'')) <> 'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  if not exists (
    select 1
    from public.characters ch
    join public.members m on m.campaign_id = ch.campaign_id
      and m.user_id = ch.user_id and m.role = 'PLAYER'
    where ch.id::text = btrim(p_character_id)
      and ch.campaign_id = p_campaign_id
      and ch.user_id = v_user
  ) then
    raise exception 'A ficha atacante não pertence ao jogador nesta campanha.';
  end if;

  select coalesce(sum(
    case lower(coalesce(c.bab_progression,''))
      when 'good' then cl.class_level
      when 'bom' then cl.class_level
      when 'average' then floor(3 * cl.class_level / 4.0)::integer
      when 'medium' then floor(3 * cl.class_level / 4.0)::integer
      when 'medio' then floor(3 * cl.class_level / 4.0)::integer
      when 'poor' then floor(cl.class_level / 2.0)::integer
      when 'ruim' then floor(cl.class_level / 2.0)::integer
      else 0
    end
  ),0)::integer
  into v_bab
  from public.srd_character_class_levels cl
  join public.srd_classes c on c.id = cl.class_id
  where cl.character_id::text = btrim(p_character_id);

  if v_bab < 6 then
    raise exception 'Esta ficha ainda não possui BBA +6 para ataques iterativos.';
  end if;

  v_attacks := least(6, floor((v_bab - 1) / 5.0)::integer + 1);
  v_combat := coalesce(v_campaign.combat_data,'{}'::jsonb);
  if lower(coalesce(v_combat->>'active','false')) <> 'true'
     or coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' then
    raise exception 'A iniciativa não está ativa ou o turno atual é inválido.';
  end if;
  v_turn := (v_combat->>'current_turn')::integer;
  v_round := case when coalesce(v_combat->>'round','') ~ '^[0-9]+$'
    then greatest(1,(v_combat->>'round')::integer) else 1 end;

  if exists (
    select 1 from public.srd_attack_sequences s
    where s.campaign_id = p_campaign_id
      and s.actor_character_id::text = btrim(p_character_id)
      and s.round_number = v_round and s.turn_index = v_turn
      and s.status = 'active'
  ) then
    raise exception 'Já existe uma sequência de ataques ativa para este turno.';
  end if;

  v_action := public.consumir_acao_rodada_completa_srd(
    p_campaign_id, btrim(p_character_id), 'character'
  );

  insert into public.srd_attack_sequences(
    campaign_id, actor_character_id, target_token_id, attack_type,
    weapon_instance_id, round_number, turn_index, base_attack_bonus,
    attacks_total, created_by
  ) values (
    p_campaign_id, btrim(p_character_id)::bigint, btrim(p_target_token_id), p_attack_type,
    p_weapon_instance_id, v_round, v_turn, v_bab, v_attacks, v_user
  )
  returning * into v_sequence;

  return jsonb_build_object(
    'sequence_id', v_sequence.id,
    'campaign_id', v_sequence.campaign_id,
    'actor_character_id', v_sequence.actor_character_id,
    'target_token_id', v_sequence.target_token_id,
    'attack_type', v_sequence.attack_type,
    'round', v_sequence.round_number,
    'turn_index', v_sequence.turn_index,
    'base_attack_bonus', v_sequence.base_attack_bonus,
    'attacks_total', v_sequence.attacks_total,
    'next_attack_index', v_sequence.next_attack_index,
    'action_economy', v_action->'action_economy'
  );
end;
$function$;

revoke all on function public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid) from public, anon;
grant execute on function public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid) to authenticated;
