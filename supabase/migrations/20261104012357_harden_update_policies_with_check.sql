ALTER POLICY "Users can update own profile."
ON public.profiles
TO authenticated
USING ((SELECT auth.uid()) = id)
WITH CHECK ((SELECT auth.uid()) = id);

ALTER POLICY p_upd
ON public.roll_requests
TO authenticated
USING (
  to_id = (SELECT auth.uid())
  OR from_id = (SELECT auth.uid())
)
WITH CHECK (
  to_id = (SELECT auth.uid())
  OR from_id = (SELECT auth.uid())
);

ALTER POLICY "inv update"
ON public.vinculo_inventory
TO authenticated
USING (
  character_id IN (
    SELECT c.id
    FROM public.characters c
    WHERE public.sou_membro(c.campaign_id)
  )
)
WITH CHECK (
  character_id IN (
    SELECT c.id
    FROM public.characters c
    WHERE public.sou_membro(c.campaign_id)
  )
);