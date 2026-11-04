-- Remove only non-constraint indexes whose exact key is already covered
-- by a primary-key or unique index on the same table.
DROP INDEX IF EXISTS public.idx_fk_campaign_codes_campaign_id;
DROP INDEX IF EXISTS public.idx_fk_combat_state_campaign_id;
DROP INDEX IF EXISTS public.idx_fk_profiles_id;
DROP INDEX IF EXISTS public.idx_fk_scenes_campaign_id;
DROP INDEX IF EXISTS public.idx_fk_srd_character_sheets_character_id;
DROP INDEX IF EXISTS public.idx_fk_srd_equipment_audit_equipment_id;
DROP INDEX IF EXISTS public.srd_npc_archetypes_race_class_idx;
DROP INDEX IF EXISTS public.idx_fk_srd_starting_packages_class_id;
DROP INDEX IF EXISTS public.idx_fk_vinculo_character_sheets_character_id;
