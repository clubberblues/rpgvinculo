-- Run after 20261110170000_lock_down_internal_helper_execute.sql.
DO $$
DECLARE
  v_oid oid;
  v_acl aclitem[];
  v_def text;
  v_path text[];
BEGIN
  -- Internal helpers are reachable only by trusted engine owners/service role.
  FOREACH v_oid IN ARRAY ARRAY[
    to_regprocedure('priv.srd_condition_has_flag(bigint,text,text,text)'),
    to_regprocedure('priv.srd_feat_saving_throw_modifier(jsonb,text)'),
    to_regprocedure('priv.srd_parse_natural_attack_list(text)'),
    to_regprocedure('priv.iniciar_sequencia_ataque_iterativo_srd_7_impl(bigint,text,text,text,uuid,text,text)'),
    to_regprocedure('priv.iniciar_sequencia_ataque_iterativo_srd_8_impl(bigint,text,text,text,uuid,text,text,integer)')
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
  IF position('auth.uid()' in (SELECT prosrc FROM pg_proc WHERE oid=v_oid))=0
     OR position('public.members' in (SELECT prosrc FROM pg_proc WHERE oid=v_oid))=0
     OR position('public.characters' in (SELECT prosrc FROM pg_proc WHERE oid=v_oid))=0
     OR position('FROM public.characters' in (SELECT prosrc FROM pg_proc WHERE oid=v_oid))=0
     OR position('FROM public.members' in (SELECT prosrc FROM pg_proc WHERE oid=v_oid))=0
     OR position('FROM public.characters' in (SELECT prosrc FROM pg_proc WHERE oid=v_oid))>position('FROM public.srd_character_weapon_instances' in (SELECT prosrc FROM pg_proc WHERE oid=v_oid)) THEN
    RAISE EXCEPTION 'Private 7-argument helper lost its defense-in-depth ownership guard';
  END IF;

  -- No SECURITY INVOKER caller may depend on the helpers whose direct
  -- authenticated EXECUTE was removed above.
  IF EXISTS (
    SELECT 1
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE NOT p.prosecdef
      AND NOT (
        n.nspname='priv'
        AND p.proname IN (
          'srd_condition_has_flag',
          'srd_feat_saving_throw_modifier',
          'srd_parse_natural_attack_list',
          'iniciar_sequencia_ataque_iterativo_srd_7_impl',
          'iniciar_sequencia_ataque_iterativo_srd_8_impl'
        )
      )
      AND (
        p.prosrc ILIKE '%priv.srd_condition_has_flag%'
        OR p.prosrc ILIKE '%priv.srd_feat_saving_throw_modifier%'
        OR p.prosrc ILIKE '%priv.srd_parse_natural_attack_list%'
        OR p.prosrc ILIKE '%priv.iniciar_sequencia_ataque_iterativo_srd_7_impl%'
        OR p.prosrc ILIKE '%priv.iniciar_sequencia_ataque_iterativo_srd_8_impl%'
      )
  ) THEN
    RAISE EXCEPTION 'A SECURITY INVOKER caller still depends on a restricted internal helper';
  END IF;

  -- Both public entry points are SECURITY DEFINER only after checking the
  -- authenticated player's character ownership and campaign membership.
  FOREACH v_oid IN ARRAY ARRAY[
    to_regprocedure('public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid,text,text)'),
    to_regprocedure('public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid,text,text,integer)')
  ]::oid[]
  LOOP
    IF v_oid IS NULL THEN RAISE EXCEPTION 'Missing iterative attack public wrapper'; END IF;
    SELECT p.prosrc,p.proconfig INTO v_def,v_path FROM pg_proc p WHERE p.oid=v_oid;
    IF NOT (SELECT prosecdef FROM pg_proc WHERE oid=v_oid)
       OR pg_get_userbyid((SELECT proowner FROM pg_proc WHERE oid=v_oid))<>'postgres' THEN
      RAISE EXCEPTION 'Iterative attack public wrapper must be SECURITY DEFINER owned by postgres';
    END IF;
    IF NOT ('search_path=pg_catalog, public, priv, pg_temp'=ANY(v_path)) THEN
      RAISE EXCEPTION 'Iterative attack public wrapper search_path is not pinned';
    END IF;
    IF position('auth.uid()' in v_def)=0
       OR position('public.members' in v_def)=0
       OR position('public.characters' in v_def)=0
       OR position('auth.uid()' in v_def)>position('public.members' in v_def)
       OR position('public.members' in v_def)>position('priv.iniciar_sequencia_ataque_iterativo' in v_def) THEN
      RAISE EXCEPTION 'Iterative attack public wrapper is missing pre-helper ownership authorization';
    END IF;
    IF NOT has_function_privilege('authenticated',v_oid,'EXECUTE')
       OR NOT has_function_privilege('service_role',v_oid,'EXECUTE')
       OR has_function_privilege('anon',v_oid,'EXECUTE') THEN
      RAISE EXCEPTION 'Unexpected public wrapper EXECUTE grants';
    END IF;
    SELECT coalesce(proacl,acldefault('f',proowner)) INTO v_acl FROM pg_proc WHERE oid=v_oid;
    IF EXISTS (SELECT 1 FROM aclexplode(v_acl) a
               WHERE a.grantee=0 AND a.privilege_type='EXECUTE') THEN
      RAISE EXCEPTION 'PUBLIC still has EXECUTE on iterative attack wrapper';
    END IF;
  END LOOP;
END $$;
SELECT 'internal helper execute assertions passed' AS result;
