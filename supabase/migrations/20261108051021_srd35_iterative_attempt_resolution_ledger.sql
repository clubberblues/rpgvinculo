alter table public.srd_attack_sequence_attempts
  add column if not exists resolution_data jsonb not null default '{}'::jsonb,
  add column if not exists attack_total integer,
  add column if not exists target_ac integer,
  add column if not exists critical_confirmation_d20 smallint,
  add column if not exists is_critical boolean not null default false,
  add column if not exists damage_rolls integer[],
  add column if not exists damage_applied integer,
  add column if not exists damage_type text,
  add column if not exists damage_applied_at timestamptz;

alter table public.srd_attack_sequence_attempts
  drop constraint if exists srd_attack_sequence_attempts_critical_confirmation_d20_check;
alter table public.srd_attack_sequence_attempts
  add constraint srd_attack_sequence_attempts_critical_confirmation_d20_check
  check (critical_confirmation_d20 is null or critical_confirmation_d20 between 1 and 20);

alter table public.srd_attack_sequence_attempts
  drop constraint if exists srd_attack_sequence_attempts_attack_total_check;
alter table public.srd_attack_sequence_attempts
  add constraint srd_attack_sequence_attempts_attack_total_check
  check (attack_total is null or attack_total between 0 and 200);

alter table public.srd_attack_sequence_attempts
  drop constraint if exists srd_attack_sequence_attempts_target_ac_check;
alter table public.srd_attack_sequence_attempts
  add constraint srd_attack_sequence_attempts_target_ac_check
  check (target_ac is null or target_ac between 0 and 200);

alter table public.srd_attack_sequence_attempts
  drop constraint if exists srd_attack_sequence_attempts_damage_applied_check;
alter table public.srd_attack_sequence_attempts
  add constraint srd_attack_sequence_attempts_damage_applied_check
  check (damage_applied is null or damage_applied between 0 and 10000);

alter table public.srd_attack_sequence_attempts
  drop constraint if exists srd_attack_sequence_attempts_damage_rolls_check;
alter table public.srd_attack_sequence_attempts
  add constraint srd_attack_sequence_attempts_damage_rolls_check
  check (damage_rolls is null or (cardinality(damage_rolls) between 1 and 30 and array_position(damage_rolls, null) is null and 0 < all(damage_rolls)));

alter table public.srd_attack_sequence_attempts
  drop constraint if exists srd_attack_sequence_attempts_resolution_data_object_check;
alter table public.srd_attack_sequence_attempts
  add constraint srd_attack_sequence_attempts_resolution_data_object_check
  check (jsonb_typeof(resolution_data) = 'object');