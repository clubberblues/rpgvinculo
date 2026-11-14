
-- Legacy character records: only the character owner or campaign GM may
-- inspect and change talents, notes, or inventory.
DROP POLICY IF EXISTS "talentos personagem leitura" ON public.character_talents;
DROP POLICY IF EXISTS consolidated_character_talents_insert ON public.character_talents;
DROP POLICY IF EXISTS consolidated_character_talents_update ON public.character_talents;
DROP POLICY IF EXISTS consolidated_character_talents_delete ON public.character_talents;

CREATE POLICY character_talents_owner_or_gm_select
ON public.character_talents FOR SELECT TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.characters c
  WHERE c.id=character_talents.character_id
    AND (c.user_id=auth.uid() OR public.my_role(c.campaign_id)='GM')
));
CREATE POLICY character_talents_owner_or_gm_insert
ON public.character_talents FOR INSERT TO authenticated
WITH CHECK (EXISTS (
  SELECT 1 FROM public.characters c
  WHERE c.id=character_talents.character_id
    AND (c.user_id=auth.uid() OR public.my_role(c.campaign_id)='GM')
));
CREATE POLICY character_talents_owner_or_gm_update
ON public.character_talents FOR UPDATE TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.characters c
  WHERE c.id=character_talents.character_id
    AND (c.user_id=auth.uid() OR public.my_role(c.campaign_id)='GM')
))
WITH CHECK (EXISTS (
  SELECT 1 FROM public.characters c
  WHERE c.id=character_talents.character_id
    AND (c.user_id=auth.uid() OR public.my_role(c.campaign_id)='GM')
));
CREATE POLICY character_talents_owner_or_gm_delete
ON public.character_talents FOR DELETE TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.characters c
  WHERE c.id=character_talents.character_id
    AND (c.user_id=auth.uid() OR public.my_role(c.campaign_id)='GM')
));

DROP POLICY IF EXISTS "notes read" ON public.vinculo_character_notes;
DROP POLICY IF EXISTS consolidated_vinculo_character_notes_insert ON public.vinculo_character_notes;
DROP POLICY IF EXISTS consolidated_vinculo_character_notes_update ON public.vinculo_character_notes;
DROP POLICY IF EXISTS consolidated_vinculo_character_notes_delete ON public.vinculo_character_notes;

CREATE POLICY vinculo_character_notes_owner_or_gm_select
ON public.vinculo_character_notes FOR SELECT TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.characters c
  WHERE c.id=vinculo_character_notes.character_id
    AND (c.user_id=auth.uid() OR public.my_role(c.campaign_id)='GM')
));
CREATE POLICY vinculo_character_notes_owner_or_gm_insert
ON public.vinculo_character_notes FOR INSERT TO authenticated
WITH CHECK (EXISTS (
  SELECT 1 FROM public.characters c
  WHERE c.id=vinculo_character_notes.character_id
    AND (c.user_id=auth.uid() OR public.my_role(c.campaign_id)='GM')
));
CREATE POLICY vinculo_character_notes_owner_or_gm_update
ON public.vinculo_character_notes FOR UPDATE TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.characters c
  WHERE c.id=vinculo_character_notes.character_id
    AND (c.user_id=auth.uid() OR public.my_role(c.campaign_id)='GM')
))
WITH CHECK (EXISTS (
  SELECT 1 FROM public.characters c
  WHERE c.id=vinculo_character_notes.character_id
    AND (c.user_id=auth.uid() OR public.my_role(c.campaign_id)='GM')
));
CREATE POLICY vinculo_character_notes_owner_or_gm_delete
ON public.vinculo_character_notes FOR DELETE TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.characters c
  WHERE c.id=vinculo_character_notes.character_id
    AND (c.user_id=auth.uid() OR public.my_role(c.campaign_id)='GM')
));

DROP POLICY IF EXISTS "inv read" ON public.vinculo_inventory;
DROP POLICY IF EXISTS "inv write" ON public.vinculo_inventory;
DROP POLICY IF EXISTS "inv update" ON public.vinculo_inventory;
DROP POLICY IF EXISTS "inv delete" ON public.vinculo_inventory;

CREATE POLICY vinculo_inventory_owner_or_gm_select
ON public.vinculo_inventory FOR SELECT TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.characters c
  WHERE c.id=vinculo_inventory.character_id
    AND (c.user_id=auth.uid() OR public.my_role(c.campaign_id)='GM')
));
CREATE POLICY vinculo_inventory_owner_or_gm_insert
ON public.vinculo_inventory FOR INSERT TO authenticated
WITH CHECK (EXISTS (
  SELECT 1 FROM public.characters c
  WHERE c.id=vinculo_inventory.character_id
    AND (c.user_id=auth.uid() OR public.my_role(c.campaign_id)='GM')
));
CREATE POLICY vinculo_inventory_owner_or_gm_update
ON public.vinculo_inventory FOR UPDATE TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.characters c
  WHERE c.id=vinculo_inventory.character_id
    AND (c.user_id=auth.uid() OR public.my_role(c.campaign_id)='GM')
))
WITH CHECK (EXISTS (
  SELECT 1 FROM public.characters c
  WHERE c.id=vinculo_inventory.character_id
    AND (c.user_id=auth.uid() OR public.my_role(c.campaign_id)='GM')
));
CREATE POLICY vinculo_inventory_gm_delete
ON public.vinculo_inventory FOR DELETE TO authenticated
USING (EXISTS (
  SELECT 1 FROM public.characters c
  WHERE c.id=vinculo_inventory.character_id
    AND public.my_role(c.campaign_id)='GM'
));

-- These tables are read-only from the browser. Mutations continue through
-- authenticated, ownership-checked SECURITY DEFINER RPCs or service_role.
REVOKE INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON TABLE
  public.character_abilities,
  public.character_spells,
  public.srd_cba_token_equipment,
  public.srd_character_equipment,
  public.srd_character_sheets,
  public.srd_deities,
  public.srd_languages,
  public.srd_starting_packages
FROM PUBLIC, anon, authenticated;

GRANT SELECT ON TABLE
  public.character_abilities,
  public.character_spells,
  public.srd_cba_token_equipment,
  public.srd_character_equipment,
  public.srd_character_sheets,
  public.srd_deities,
  public.srd_languages,
  public.srd_starting_packages
TO authenticated;
GRANT SELECT ON TABLE public.srd_languages TO anon;

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE
  public.character_abilities,
  public.character_spells,
  public.srd_cba_token_equipment,
  public.srd_character_equipment,
  public.srd_character_sheets,
  public.srd_deities,
  public.srd_languages,
  public.srd_starting_packages
TO service_role;

-- Keep chat append-only for clients; profiles remain self-editable but cannot
-- be deleted or written through the anonymous role.
REVOKE UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
ON TABLE public.campaign_log
FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT ON TABLE public.campaign_log TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.campaign_log TO service_role;

REVOKE INSERT, UPDATE, DELETE
ON TABLE public.profiles
FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.profiles TO authenticated;
GRANT SELECT ON TABLE public.profiles TO anon;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.profiles TO service_role;
