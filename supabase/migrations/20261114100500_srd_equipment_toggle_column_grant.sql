-- Least-privilege fix for SRD armor/shield/accessory equip toggles.
-- The existing RLS UPDATE policy already limits rows to the character owner or campaign GM.
-- Grant only the one column changed by equipar_item_srd; never grant inventory quantity writes.

begin;

grant update (equipado)
  on table public.srd_character_equipment
  to authenticated;

commit;
