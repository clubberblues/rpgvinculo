-- Run after 20261110160000_revoke_public_feat_saving_throw_helper.sql.
DO $$
DECLARE
  v_oid oid;
  v_acl aclitem[];
BEGIN
  v_oid:=to_regprocedure('priv.srd_feat_saving_throw_modifier(jsonb,text)');
  IF v_oid IS NULL THEN RAISE EXCEPTION 'Missing passive feat save helper'; END IF;
  IF NOT (SELECT prosecdef FROM pg_proc WHERE oid=v_oid) THEN
    RAISE EXCEPTION 'Passive feat save helper must retain SECURITY DEFINER';
  END IF;
  IF NOT ('search_path=pg_catalog, public, priv, pg_temp' = ANY((SELECT proconfig FROM pg_proc WHERE oid=v_oid))) THEN
    RAISE EXCEPTION 'Passive feat save helper search_path changed unexpectedly';
  END IF;
  IF NOT has_function_privilege('authenticated',v_oid,'EXECUTE')
     OR NOT has_function_privilege('service_role',v_oid,'EXECUTE')
     OR has_function_privilege('anon',v_oid,'EXECUTE') THEN
    RAISE EXCEPTION 'Unexpected client EXECUTE grants on passive feat helper';
  END IF;
  SELECT coalesce(proacl,acldefault('f',proowner)) INTO v_acl FROM pg_proc WHERE oid=v_oid;
  IF EXISTS (SELECT 1 FROM aclexplode(v_acl) a WHERE a.grantee=0 AND a.privilege_type='EXECUTE') THEN
    RAISE EXCEPTION 'PUBLIC still has EXECUTE on passive feat helper';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc p
    WHERE p.oid=to_regprocedure('priv.srd_saving_throw_bonus(bigint,text,text,text,text)')
      AND p.prosecdef
      AND pg_get_userbyid(p.proowner)='postgres'
  ) THEN
    RAISE EXCEPTION 'Expected SECURITY DEFINER saving throw engine caller is missing';
  END IF;
END $$;
SELECT 'passive feat helper ACL assertions passed' AS result;
