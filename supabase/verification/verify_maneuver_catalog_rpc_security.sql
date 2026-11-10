-- Run after 20261110150000_fix_invoker_maneuver_catalog_helper_permissions.sql.
-- Read-only catalog assertions; no application data is touched.
DO $$
DECLARE
  v_oid oid;
  v_def text;
  v_path text[];
BEGIN
  SELECT p.oid, p.prosrc, p.proconfig
    INTO v_oid, v_def, v_path
  FROM pg_proc p
  WHERE p.oid = to_regprocedure(
    'public.srd_consultar_modificadores_manobra_srd(bigint,text,text,text,boolean,boolean)'
  );
  IF v_oid IS NULL THEN
    RAISE EXCEPTION 'Missing GM maneuver wrapper';
  END IF;
  IF NOT (SELECT prosecdef FROM pg_proc WHERE oid=v_oid) THEN
    RAISE EXCEPTION 'GM maneuver wrapper must be SECURITY DEFINER';
  END IF;
  IF NOT ('search_path=pg_catalog, public, priv, pg_temp' = ANY(v_path)) THEN
    RAISE EXCEPTION 'GM maneuver wrapper search_path is not pinned';
  END IF;
  IF position('auth.uid()' in v_def)=0 OR position('public.my_role' in v_def)=0 THEN
    RAISE EXCEPTION 'GM maneuver wrapper lost explicit authentication/GM authorization';
  END IF;
  IF NOT has_function_privilege('authenticated',v_oid,'EXECUTE')
     OR NOT has_function_privilege('service_role',v_oid,'EXECUTE')
     OR has_function_privilege('anon',v_oid,'EXECUTE')
     OR EXISTS (SELECT 1 FROM aclexplode(coalesce((SELECT proacl FROM pg_proc WHERE oid=v_oid),acldefault('f',(SELECT proowner FROM pg_proc WHERE oid=v_oid)))) a WHERE a.grantee=0 AND a.privilege_type='EXECUTE') THEN
    RAISE EXCEPTION 'Unexpected EXECUTE grants on GM maneuver wrapper';
  END IF;

  SELECT p.oid, p.prosrc, p.proconfig
    INTO v_oid, v_def, v_path
  FROM pg_proc p
  WHERE p.oid = to_regprocedure(
    'public.srd_listar_ataques_naturais_oportunidade_srd(bigint,text)'
  );
  IF v_oid IS NULL THEN
    RAISE EXCEPTION 'Missing GM natural attack catalog wrapper';
  END IF;
  IF NOT (SELECT prosecdef FROM pg_proc WHERE oid=v_oid) THEN
    RAISE EXCEPTION 'GM natural attack catalog wrapper must be SECURITY DEFINER';
  END IF;
  IF NOT ('search_path=pg_catalog, public, priv, pg_temp' = ANY(v_path)) THEN
    RAISE EXCEPTION 'GM natural attack catalog wrapper search_path is not pinned';
  END IF;
  IF position('auth.uid()' in v_def)=0 OR position('public.my_role' in v_def)=0 THEN
    RAISE EXCEPTION 'GM natural attack wrapper lost explicit authentication/GM authorization';
  END IF;
  IF NOT has_function_privilege('authenticated',v_oid,'EXECUTE')
     OR NOT has_function_privilege('service_role',v_oid,'EXECUTE')
     OR has_function_privilege('anon',v_oid,'EXECUTE')
     OR EXISTS (SELECT 1 FROM aclexplode(coalesce((SELECT proacl FROM pg_proc WHERE oid=v_oid),acldefault('f',(SELECT proowner FROM pg_proc WHERE oid=v_oid)))) a WHERE a.grantee=0 AND a.privilege_type='EXECUTE') THEN
    RAISE EXCEPTION 'Unexpected EXECUTE grants on GM natural attack wrapper';
  END IF;
END $$;

SELECT 'maneuver catalog RPC security assertions passed' AS result;
