ALTER TABLE public.monster_instances
  DROP CONSTRAINT IF EXISTS monster_instances_monster_id_fkey;
ALTER TABLE public.monster_instances
  ADD CONSTRAINT monster_instances_monster_id_fkey
  FOREIGN KEY (monster_id) REFERENCES public.srd_monsters(id);