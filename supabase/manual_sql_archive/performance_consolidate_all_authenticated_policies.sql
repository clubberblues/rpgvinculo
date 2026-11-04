DO $$
DECLARE r record; p text; v_name text; v_using text; v_check text; v_stmt text;
BEGIN
  FOR r IN
    SELECT tablename,cmd,roles,
      array_agg(policyname ORDER BY policyname) AS policy_names,
      string_agg(CASE WHEN qual IS NULL THEN 'true' ELSE '('||qual||')' END,' OR ' ORDER BY policyname) AS using_expr,
      string_agg(CASE WHEN with_check IS NULL THEN 'true' ELSE '('||with_check||')' END,' OR ' ORDER BY policyname) AS check_expr,
      count(*) AS policy_count
    FROM pg_policies
    WHERE schemaname='public'
      AND roles::text='{authenticated}'
      AND cmd IN ('SELECT','INSERT','UPDATE','DELETE')
    GROUP BY tablename,cmd,roles
    HAVING count(*)>1
  LOOP
    v_name := 'consolidated_'||lower(r.tablename)||'_'||lower(r.cmd);
    FOREACH p IN ARRAY r.policy_names LOOP
      EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I',p,r.tablename);
    END LOOP;
    v_stmt := format('CREATE POLICY %I ON public.%I FOR %s TO authenticated',v_name,r.tablename,r.cmd);
    IF r.cmd IN ('SELECT','UPDATE','DELETE') THEN
      v_stmt := v_stmt || format(' USING (%s)',r.using_expr);
    END IF;
    IF r.cmd IN ('INSERT','UPDATE') THEN
      v_stmt := v_stmt || format(' WITH CHECK (%s)',r.check_expr);
    END IF;
    EXECUTE v_stmt;
  END LOOP;
END $$;