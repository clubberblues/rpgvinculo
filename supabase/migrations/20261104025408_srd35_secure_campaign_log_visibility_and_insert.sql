
DROP POLICY IF EXISTS campaign_log_read ON public.campaign_log;
CREATE POLICY campaign_log_read
ON public.campaign_log
FOR SELECT
TO authenticated
USING (
  public.my_role(campaign_id) = 'GM'
  OR (
    public.my_role(campaign_id) IN ('PLAYER','OBSERVER')
    AND visibilidade = 'PUBLIC'
  )
);

DROP POLICY IF EXISTS "log insert" ON public.campaign_log;
CREATE POLICY campaign_log_insert_member_chat
ON public.campaign_log
FOR INSERT
TO authenticated
WITH CHECK (
  public.my_role(campaign_id) = 'GM'
  OR (
    public.my_role(campaign_id) IN ('PLAYER','OBSERVER')
    AND type IN ('texto','sistema','rolagem')
    AND visibilidade = 'PUBLIC'
    AND data->>'autor_id' = auth.uid()::text
  )
);
