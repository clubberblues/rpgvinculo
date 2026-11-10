
CREATE POLICY character_spells_owner_or_gm_insert
ON public.character_spells
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.characters c
    WHERE c.id=character_spells.character_id
      AND (c.user_id=auth.uid() OR public.my_role(c.campaign_id)='GM')
  )
);

GRANT INSERT ON TABLE public.character_spells TO authenticated;
