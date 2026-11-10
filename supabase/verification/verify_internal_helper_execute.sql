-- Run after 20261110170000_lock_down_internal_helper_execute.sql.
DO $$
DECLARE
  v_oid oid;
  v_acl aclitem[];
BEGIN
  -- These helpers are only called by SECURITY DEFINER engine code/triggers.
  FOREACH v_oid IN ARRAY ARRAY[
    to_regprocedure('priv.srd_condition_has_flag(bigint,text,text,text)'),
    to_regprocedure('priv.srd_feat_saving_throw_modifier(jsonb,text)'),
    to_regprocedure('priv.srd_parse_natural_attack_list(text)')
  ]::oid[]
  LOOP
    IF v_oid IS NULL THEN RAISE EXCEPTION 'Missing internal helper'; END IF;
    IF has_function_privilege('authenticated',v_oid,'EXECUTE')
       OR has_function_privilege('anon',v_oid,'EXECUTE')
       OR NOT has_function_privilege('service_role',v_oid,'EXECUTE') THEN
      RAISE EXCEPTION 'Unexpected direct EXECUTE grants on internal helper %',v_oid;
    END IF;
    SELECT coalesce(proacl,acldefault('f',proowner)) INTO v_acl
    FROM pg_proc WHERE oid=v_oid;
    IF EXISTS (SELECT 1 FROM aclexplode(v_acl) a
               WHERE a.grantee=0 AND a.privilege_type='EXECUTE') THEN
      RAISE EXCEPTION 'PUBLIC still has EXECUTE on internal helper %',v_oid;
    END IF;
  END LOOP;

  v_oid:=to_regprocedure(
    'priv.iniciar_sequencia_ataque_iterativo_srd_7_impl(bigint,text,text,text,uuid,text,text)'
  );
  IF v_oid IS NULL THEN RAISE EXCEPTION 'Missing 7-argument iterative attack helper'; END IF;
  IF NOT (SELECT prosecdef FROM pg_proc WHERE oid=v_oid) THEN
    RAISE EXCEPTION 'Iterative attack helper must remain SECURITY DEFINER';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc p
    CROSS JOIN LATERAL unnest(p.proconfig) AS u(config)
    WHERE p.oid=v_oid AND u.config='search_path=public, priv, pg_temp'
  ) THEN
    RAISE EXCEPTION 'Iterative attack helper search_path is not pinned';
  END IF;
  IF position('auth.uid()' in (SELECT prosrc FROM pg_proc WHERE oid=v_oid))=0
     OR position('public.members' in (SELECT prosrc FROM pg_proc WHERE oid=v_oid))=0
     OR position('public.characters' in (SELECT prosrc FROM pg_proc WHERE oid=v_oid))=0 THEN
    RAISE EXCEPTION 'Iterative attack helper is missing its pre-read ownership guard';
  END IF;
  IF NOT has_function_privilege('authenticated',v_oid,'EXECUTE')
     OR has_function_privilege('anon',v_oid,'EXECUTE') THEN
    RAISE EXCEPTION 'Unexpected EXECUTE grants on iterative attack helper';
  END IF;
END $$;
SELECT 'internal helper execute assertions passed' AS result;
