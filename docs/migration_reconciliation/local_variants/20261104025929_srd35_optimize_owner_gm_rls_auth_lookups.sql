-- Evaluate auth.uid() once per statement in the owner/GM policies.
DROP POLICY IF EXISTS campaign_log_insert_member_chat ON public.campaign_log;
CREATE POLICY campaign_log_insert_member_chat
ON public.campaign_log FOR INSERT TO authenticated
WITH CHECK (
  public.my_role(campaign_id)='GM'
  OR (
    public.my_role(campaign_id) IN ('PLAYER','OBSERVER')
    AND type IN ('texto','sistema','rolagem')
    AND visibilidade='PUBLIC'
    AND data->>'autor_id'=(SELECT auth.uid())::text
  )
);

DROP POLICY IF EXISTS character_talents_owner_or_gm_select ON public.character_talents;
DROP POLICY IF EXISTS character_talents_owner_or_gm_insert ON public.character_talents;
DROP POLICY IF EXISTS character_talents_owner_or_gm_update ON public.character_talents;
DROP POLICY IF EXISTS character_talents_owner_or_gm_delete ON public.character_talents;
CREATE POLICY character_talents_owner_or_gm_select ON public.character_talents FOR SELECT TO authenticated
USING (EXISTS (SELECT 1 FROM public.characters c WHERE c.id=character_talents.character_id AND (c.user_id=(SELECT auth.uid()) OR public.my_role(c.campaign_id)='GM')));
CREATE POLICY character_talents_owner_or_gm_insert ON public.character_talents FOR INSERT TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM public.characters c WHERE c.id=character_talents.character_id AND (c.user_id=(SELECT auth.uid()) OR public.my_role(c.campaign_id)='GM')));
CREATE POLICY character_talents_owner_or_gm_update ON public.character_talents FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM public.characters c WHERE c.id=character_talents.character_id AND (c.user_id=(SELECT auth.uid()) OR public.my_role(c.campaign_id)='GM')))
WITH CHECK (EXISTS (SELECT 1 FROM public.characters c WHERE c.id=character_talents.character_id AND (c.user_id=(SELECT auth.uid()) OR public.my_role(c.campaign_id)='GM')));
CREATE POLICY character_talents_owner_or_gm_delete ON public.character_talents FOR DELETE TO authenticated
USING (EXISTS (SELECT 1 FROM public.characters c WHERE c.id=character_talents.character_id AND (c.user_id=(SELECT auth.uid()) OR public.my_role(c.campaign_id)='GM')));

DROP POLICY IF EXISTS vinculo_character_notes_owner_or_gm_select ON public.vinculo_character_notes;
DROP POLICY IF EXISTS vinculo_character_notes_owner_or_gm_insert ON public.vinculo_character_notes;
DROP POLICY IF EXISTS vinculo_character_notes_owner_or_gm_update ON public.vinculo_character_notes;
DROP POLICY IF EXISTS vinculo_character_notes_owner_or_gm_delete ON public.vinculo_character_notes;
CREATE POLICY vinculo_character_notes_owner_or_gm_select ON public.vinculo_character_notes FOR SELECT TO authenticated
USING (EXISTS (SELECT 1 FROM public.characters c WHERE c.id=vinculo_character_notes.character_id AND (c.user_id=(SELECT auth.uid()) OR public.my_role(c.campaign_id)='GM')));
CREATE POLICY vinculo_character_notes_owner_or_gm_insert ON public.vinculo_character_notes FOR INSERT TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM public.characters c WHERE c.id=vinculo_character_notes.character_id AND (c.user_id=(SELECT auth.uid()) OR public.my_role(c.campaign_id)='GM')));
CREATE POLICY vinculo_character_notes_owner_or_gm_update ON public.vinculo_character_notes FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM public.characters c WHERE c.id=vinculo_character_notes.character_id AND (c.user_id=(SELECT auth.uid()) OR public.my_role(c.campaign_id)='GM')))
WITH CHECK (EXISTS (SELECT 1 FROM public.characters c WHERE c.id=vinculo_character_notes.character_id AND (c.user_id=(SELECT auth.uid()) OR public.my_role(c.campaign_id)='GM')));
CREATE POLICY vinculo_character_notes_owner_or_gm_delete ON public.vinculo_character_notes FOR DELETE TO authenticated
USING (EXISTS (SELECT 1 FROM public.characters c WHERE c.id=vinculo_character_notes.character_id AND (c.user_id=(SELECT auth.uid()) OR public.my_role(c.campaign_id)='GM')));

DROP POLICY IF EXISTS vinculo_inventory_owner_or_gm_select ON public.vinculo_inventory;
DROP POLICY IF EXISTS vinculo_inventory_owner_or_gm_insert ON public.vinculo_inventory;
DROP POLICY IF EXISTS vinculo_inventory_owner_or_gm_update ON public.vinculo_inventory;
CREATE POLICY vinculo_inventory_owner_or_gm_select ON public.vinculo_inventory FOR SELECT TO authenticated
USING (EXISTS (SELECT 1 FROM public.characters c WHERE c.id=vinculo_inventory.character_id AND (c.user_id=(SELECT auth.uid()) OR public.my_role(c.campaign_id)='GM')));
CREATE POLICY vinculo_inventory_owner_or_gm_insert ON public.vinculo_inventory FOR INSERT TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM public.characters c WHERE c.id=vinculo_inventory.character_id AND (c.user_id=(SELECT auth.uid()) OR public.my_role(c.campaign_id)='GM')));
CREATE POLICY vinculo_inventory_owner_or_gm_update ON public.vinculo_inventory FOR UPDATE TO authenticated
USING (EXISTS (SELECT 1 FROM public.characters c WHERE c.id=vinculo_inventory.character_id AND (c.user_id=(SELECT auth.uid()) OR public.my_role(c.campaign_id)='GM')))
WITH CHECK (EXISTS (SELECT 1 FROM public.characters c WHERE c.id=vinculo_inventory.character_id AND (c.user_id=(SELECT auth.uid()) OR public.my_role(c.campaign_id)='GM')));

DROP POLICY IF EXISTS character_spells_owner_or_gm_insert ON public.character_spells;
CREATE POLICY character_spells_owner_or_gm_insert ON public.character_spells FOR INSERT TO authenticated
WITH CHECK (EXISTS (SELECT 1 FROM public.characters c WHERE c.id=character_spells.character_id AND (c.user_id=(SELECT auth.uid()) OR public.my_role(c.campaign_id)='GM')));
