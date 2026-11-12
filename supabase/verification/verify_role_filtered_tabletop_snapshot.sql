-- Run after 20261112140000 in the target environment.
-- This verifies the new endpoint and explicitly reports whether legacy access
-- remains open; it does not perform the final column/publication cutover.
DO $verify$
BEGIN
  IF to_regprocedure('public.obter_snapshot_seguro_mesa(bigint)') IS NULL THEN
    RAISE EXCEPTION 'Role-filtered tabletop snapshot RPC is missing.';
  END IF;
  IF has_function_privilege('anon','public.obter_snapshot_seguro_mesa(bigint)','EXECUTE') THEN
    RAISE EXCEPTION 'anon can execute the tabletop snapshot RPC.';
  END IF;
  IF NOT has_function_privilege('authenticated','public.obter_snapshot_seguro_mesa(bigint)','EXECUTE') THEN
    RAISE EXCEPTION 'authenticated cannot execute the tabletop snapshot RPC.';
  END IF;
END
$verify$;

SELECT
  has_column_privilege('authenticated','public.campaigns','cba_data','SELECT')
    AS legacy_cba_column_read_still_open,
  has_column_privilege('authenticated','public.campaigns','combat_data','SELECT')
    AS legacy_combat_column_read_still_open,
  EXISTS (
    SELECT 1 FROM pg_publication_tables
     WHERE pubname='supabase_realtime'
       AND schemaname='public'
       AND tablename='campaigns'
  ) AS legacy_campaigns_realtime_still_published,
  'Do not close these legacy paths until every client reader and RPC response has been migrated.'
    AS cutover_warning;
