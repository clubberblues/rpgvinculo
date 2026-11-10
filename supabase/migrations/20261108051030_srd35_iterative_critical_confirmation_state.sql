alter table public.srd_attack_sequence_attempts
  drop constraint if exists srd_attack_sequence_attempts_status_check;

alter table public.srd_attack_sequence_attempts
  add constraint srd_attack_sequence_attempts_status_check
  check (status = any (array[
    'pending_resolution',
    'miss',
    'critical_confirmation_pending',
    'hit_pending_damage',
    'damage_applied',
    'cancelled'
  ]::text[]));