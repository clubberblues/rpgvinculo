-- Run after 20261112130000_fix_private_cba_storage_access.sql.
DO $$
DECLARE v_oid oid := to_regprocedure('priv.cba_media_campaign_access(text,boolean,boolean)');
BEGIN
  IF v_oid IS NULL THEN RAISE EXCEPTION 'CBA Storage authorization helper is missing.'; END IF;
  IF NOT (SELECT prosecdef AND provolatile='v' FROM pg_proc WHERE oid=v_oid) THEN
    RAISE EXCEPTION 'CBA Storage helper must be VOLATILE SECURITY DEFINER for transaction-scoped row locks.';
  END IF;
  IF (SELECT pg_get_userbyid(proowner) FROM pg_proc WHERE oid=v_oid) <> 'postgres' THEN
    RAISE EXCEPTION 'CBA Storage helper must be owned by postgres.';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc p, unnest(COALESCE(p.proconfig,ARRAY[]::text[])) cfg
    WHERE p.oid=v_oid AND cfg='search_path=public, priv, storage, pg_temp'
  ) THEN RAISE EXCEPTION 'CBA Storage helper search_path is not pinned.'; END IF;
  IF NOT has_function_privilege('authenticated',v_oid,'EXECUTE')
     OR has_function_privilege('anon',v_oid,'EXECUTE') THEN
    RAISE EXCEPTION 'CBA Storage helper has incorrect role grants.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM pg_proc p
    CROSS JOIN LATERAL aclexplode(COALESCE(p.proacl,acldefault('f',p.proowner))) a
    WHERE p.oid=v_oid AND a.grantee=0 AND a.privilege_type='EXECUTE'
  ) THEN RAISE EXCEPTION 'PUBLIC retains EXECUTE on CBA Storage helper.'; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='storage' AND tablename='objects'
      AND policyname='mesa_media_ler'
      AND qual ILIKE '%cba_media_campaign_access%'
  ) OR NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='storage' AND tablename='objects'
      AND policyname='mesa_media_enviar'
      AND with_check ILIKE '%cba_media_campaign_access%'
  ) OR NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname='storage' AND tablename='objects'
      AND policyname='mesa_media_apagar'
      AND qual ILIKE '%cba_media_campaign_access%'
  ) THEN
    RAISE EXCEPTION 'Private CBA Storage policies are not using the new authorization helper.';
  END IF;
END $$;
SELECT 'private CBA Storage policy verification passed' AS result;
