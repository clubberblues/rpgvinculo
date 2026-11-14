DROP POLICY IF EXISTS campaign_deletion_cleanup_deny_all ON priv.campaign_deletion_cleanup;
CREATE POLICY campaign_deletion_cleanup_deny_all
ON priv.campaign_deletion_cleanup
FOR ALL TO public
USING (false)
WITH CHECK (false);