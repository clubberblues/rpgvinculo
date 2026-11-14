-- Run after 20261112110000_revoke_legacy_character_creation_rpc.sql.
-- Read-only catalog assertions; no application data is touched.
DO $$
DECLARE
  v_legacy oid := to_regprocedure(
    'public.criar_personagem_srd_completo(text,text,text,jsonb,jsonb,jsonb)'
  );
  v_current oid := to_regprocedure(
    'public.criar_personagem_srd_completo(text,text,text,jsonb,jsonb,jsonb,jsonb)'
  );
  v_acl aclitem[];
BEGIN
  IF v_legacy IS NULL OR v_current IS NULL THEN
    RAISE EXCEPTION 'Expected legacy and current character creation overloads.';
  END IF;

  IF has_function_privilege('authenticated',v_legacy,'EXECUTE')
     OR has_function_privilege('anon',v_legacy,'EXECUTE') THEN
    RAISE EXCEPTION 'Legacy six-argument character creator remains callable by clients.';
  END IF;

  SELECT COALESCE(proacl,acldefault('f',proowner)) INTO v_acl
    FROM pg_proc WHERE oid=v_legacy;
  IF EXISTS (
    SELECT 1 FROM aclexplode(v_acl)
    WHERE grantee=0 AND privilege_type='EXECUTE'
  ) THEN
    RAISE EXCEPTION 'PUBLIC still has EXECUTE on the legacy character creator.';
  END IF;

  IF NOT has_function_privilege('authenticated',v_current,'EXECUTE')
     OR has_function_privilege('anon',v_current,'EXECUTE') THEN
    RAISE EXCEPTION 'Validated seven-argument character creator has unexpected client grants.';
  END IF;
END $$;

SELECT 'legacy character creation RPC ACL assertions passed' AS result;
