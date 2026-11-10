
create table if not exists public.srd_npc_attack_sequences (
  id uuid primary key default gen_random_uuid(),
  campaign_id bigint not null references public.campaigns(id) on delete cascade,
  actor_token_id text not null,
  actor_character_id bigint not null references public.characters(id) on delete restrict,
  target_token_id text not null,
  attack_type text not null check (attack_type in ('atk-corpo','atk-dist')),
  weapon_instance_id uuid not null,
  weapon_hand_slot text not null check (weapon_hand_slot in ('main_hand','off_hand')),
  weapon_end text,
  base_attack_bonus integer not null check (base_attack_bonus >= 6),
  attacks_total smallint not null check (attacks_total between 2 and 6),
  next_attack_index smallint not null default 1,
  round_number integer not null,
  turn_index integer not null,
  status text not null default 'active' check (status in ('active','completed','cancelled')),
  created_by uuid not null,
  created_at timestamptz not null default now(),
  completed_at timestamptz,
  unique (id,campaign_id)
);
create unique index if not exists srd_npc_attack_one_active_per_actor
  on public.srd_npc_attack_sequences(campaign_id,actor_token_id)
  where status='active';

create table if not exists public.srd_npc_attack_attempts (
  id uuid primary key default gen_random_uuid(),
  sequence_id uuid not null references public.srd_npc_attack_sequences(id) on delete cascade,
  attempt_index smallint not null,
  manual_d20 smallint not null check (manual_d20 between 1 and 20),
  iterative_penalty smallint not null,
  idempotency_key uuid not null,
  status text not null default 'pending_resolution'
    check (status in ('pending_resolution','critical_confirmation_pending','hit_pending_damage','miss','damage_applied')),
  attack_total integer,
  target_ac integer,
  resolution_data jsonb not null default '{}'::jsonb,
  critical_confirmation_d20 smallint check (critical_confirmation_d20 between 1 and 20),
  is_critical boolean not null default false,
  damage_rolls integer[],
  damage_applied integer,
  damage_idempotency_key uuid,
  created_at timestamptz not null default now(),
  resolved_at timestamptz,
  unique(sequence_id,attempt_index),
  unique(sequence_id,idempotency_key),
  unique(sequence_id,damage_idempotency_key)
);
alter table public.srd_npc_attack_sequences enable row level security;
alter table public.srd_npc_attack_attempts enable row level security;
revoke all on public.srd_npc_attack_sequences,public.srd_npc_attack_attempts from anon,authenticated;
