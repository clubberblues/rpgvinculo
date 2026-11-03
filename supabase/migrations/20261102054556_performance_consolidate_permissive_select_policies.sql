DROP POLICY IF EXISTS "log read" ON public.campaign_log;
DROP POLICY IF EXISTS p_sel ON public.campaign_log;
CREATE POLICY campaign_log_read
  ON public.campaign_log
  FOR SELECT TO authenticated
  USING (
    public.sou_membro(campaign_id)
    OR (
      public.my_role(campaign_id) IS NOT NULL
      AND visibilidade = 'PUBLIC'
    )
  );

DROP POLICY IF EXISTS srd_character_equipment_campaign_gm_select ON public.srd_character_equipment;
DROP POLICY IF EXISTS srd_character_equipment_owner_select ON public.srd_character_equipment;
CREATE POLICY srd_character_equipment_select
  ON public.srd_character_equipment
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.characters ch
      JOIN public.members member ON member.campaign_id=ch.campaign_id
      WHERE ch.id::text=srd_character_equipment.character_id
        AND member.user_id=(select auth.uid())
        AND member.role='GM'
    )
    OR EXISTS (
      SELECT 1
      FROM public.characters ch
      WHERE ch.id::text=srd_character_equipment.character_id
        AND ch.user_id=(select auth.uid())
    )
  );