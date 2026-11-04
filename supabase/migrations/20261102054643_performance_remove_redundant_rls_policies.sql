DO $$
DECLARE r record; v_using text; v_check text; v_base text;
BEGIN
  FOR r IN
    SELECT tablename,policyname,qual,with_check
    FROM pg_policies
    WHERE schemaname='public' AND cmd='ALL' AND roles::text='{authenticated}'
      AND tablename IN ('character_talents','monster_instances','scenes','tokens','vinculo_character_notes')
  LOOP
    v_using := COALESCE(r.qual,'true');
    v_check := COALESCE(r.with_check,r.qual,'true');
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I',r.policyname,r.tablename);
    v_base := 'consolidated_'||r.tablename||'_';
    EXECUTE format('CREATE POLICY %I ON public.%I FOR INSERT TO authenticated WITH CHECK (%s)',v_base||'insert',r.tablename,v_check);
    EXECUTE format('CREATE POLICY %I ON public.%I FOR UPDATE TO authenticated USING (%s) WITH CHECK (%s)',v_base||'update',r.tablename,v_using,v_check);
    EXECUTE format('CREATE POLICY %I ON public.%I FOR DELETE TO authenticated USING (%s)',v_base||'delete',r.tablename,v_using);
  END LOOP;
END $$;

DROP POLICY IF EXISTS p_sel ON public.continents;
DROP POLICY IF EXISTS p_sel ON public.locations;
DROP POLICY IF EXISTS "monsters read" ON public.monsters;
DROP POLICY IF EXISTS p_sel ON public.vinculo_classes;
DROP POLICY IF EXISTS p_sel ON public.vinculo_items;
DROP POLICY IF EXISTS "profiles insert" ON public.profiles;
DROP POLICY IF EXISTS "profiles read" ON public.profiles;
DROP POLICY IF EXISTS "profiles update" ON public.profiles;