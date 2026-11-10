
alter table priv.srd_aoo_attacks
  drop constraint if exists srd_aoo_attacks_status_check;
alter table priv.srd_aoo_attacks
  add constraint srd_aoo_attacks_status_check
  check (status = any (array[
    'awaiting_attack_roll'::text,
    'awaiting_critical_confirmation'::text,
    'awaiting_miss_chance'::text,
    'awaiting_damage'::text,
    'miss'::text,
    'damage_applied'::text,
    'cancelled'::text
  ]));
