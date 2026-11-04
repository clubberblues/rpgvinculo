-- The following foreign-key helper indexes are fully covered by the
-- leftmost key columns of each table's primary-key index.
DROP INDEX IF EXISTS public.idx_fk_srd_character_class_levels_character_id;
DROP INDEX IF EXISTS public.idx_fk_srd_spell_level_progressions_class_id;
DROP INDEX IF EXISTS public.idx_fk_vinculo_inventory_character_id;
