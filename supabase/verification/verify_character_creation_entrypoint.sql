-- Run after 20261112120000_lock_down_character_creation_entrypoint.sql.
DO $$
DECLARE
  v_final oid := to_regprocedure(
    'public.finalizar_criacao_personagem_srd(text,text,text,jsonb,jsonb,jsonb,jsonb,jsonb,jsonb,text[],jsonb,text,jsonb,jsonb)'
  );
  v_old oid := to_regprocedure(
    'public.criar_personagem_srd_completo(text,text,text,jsonb,jsonb,jsonb)'
  );
  v_new oid := to_regprocedure(
    'public.criar_personagem_srd_completo(text,text,text,jsonb,jsonb,jsonb,jsonb)'
  );
BEGIN
  IF v_final IS NULL OR v_old IS NULL OR v_new IS NULL THEN
    RAISE EXCEPTION 'Character creation entrypoint overloads are missing.';
  END IF;
  IF NOT (SELECT prosecdef FROM pg_proc WHERE oid=v_final) THEN
    RAISE EXCEPTION 'Validated finalizer must execute as SECURITY DEFINER.';
  END IF;
  IF NOT has_function_privilege('authenticated',v_final,'EXECUTE')
     OR has_function_privilege('anon',v_final,'EXECUTE') THEN
    RAISE EXCEPTION 'Validated finalizer has incorrect client grants.';
  END IF;
  IF has_function_privilege('authenticated',v_old,'EXECUTE')
     OR has_function_privilege('anon',v_old,'EXECUTE')
     OR has_function_privilege('authenticated',v_new,'EXECUTE')
     OR has_function_privilege('anon',v_new,'EXECUTE') THEN
    RAISE EXCEPTION 'Internal creation overload remains client-callable.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM pg_proc p
    CROSS JOIN LATERAL aclexplode(COALESCE(p.proacl,acldefault('f',p.proowner))) a
    WHERE p.oid IN (v_old,v_new)
      AND a.grantee=0 AND a.privilege_type='EXECUTE'
  ) THEN
    RAISE EXCEPTION 'PUBLIC retains EXECUTE on an internal creation overload.';
  END IF;
END $$;
SELECT 'character creation entrypoint verification passed' AS result;
