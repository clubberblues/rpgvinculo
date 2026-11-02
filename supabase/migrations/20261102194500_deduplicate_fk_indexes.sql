-- Keep one btree index for each duplicated foreign-key lookup.
DROP INDEX IF EXISTS public.monster_instances_campaign_idx;
DROP INDEX IF EXISTS public.srd_character_class_levels_class_idx;
DROP INDEX IF EXISTS public.idx_srd_character_equipment_equipment_id;
DROP INDEX IF EXISTS public.tokens_campaign_idx;
