-- Broadcast only a refresh signal; never publish campaign row payloads.
BEGIN;

CREATE OR REPLACE FUNCTION priv.broadcast_campaign_refresh()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, realtime, auth
AS $function$
BEGIN
  PERFORM realtime.send(
    jsonb_build_object('campaign_id', NEW.id),
    'campaign_refresh',
    'campaign:' || NEW.id::text,
    true
  );
  RETURN NEW;
END
$function$;

REVOKE ALL ON FUNCTION priv.broadcast_campaign_refresh() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS campaigns_broadcast_refresh ON public.campaigns;
CREATE TRIGGER campaigns_broadcast_refresh
AFTER UPDATE OF cba_data, combat_data, state ON public.campaigns
FOR EACH ROW
WHEN (
  OLD.cba_data IS DISTINCT FROM NEW.cba_data
  OR OLD.combat_data IS DISTINCT FROM NEW.combat_data
  OR OLD.state IS DISTINCT FROM NEW.state
)
EXECUTE FUNCTION priv.broadcast_campaign_refresh();

DROP POLICY IF EXISTS campaign_members_receive_refresh ON realtime.messages;
CREATE POLICY campaign_members_receive_refresh
ON realtime.messages
FOR SELECT
TO authenticated
USING (
  extension = 'broadcast'
  AND (SELECT realtime.topic()) ~ '^campaign:[0-9]+$'
  AND EXISTS (
    SELECT 1
      FROM public.campaigns c
     WHERE c.id::text = substring((SELECT realtime.topic()) FROM '^campaign:([0-9]+)$')
       AND (
         c.owner_id = (SELECT auth.uid())
         OR public.sou_membro(c.id)
       )
  )
);

GRANT SELECT ON realtime.messages TO authenticated;

COMMIT;
