DO $$
DECLARE r record; v_using text; v_check text; v_stmt text;
BEGIN
  FOR r IN
    SELECT schemaname,tablename,policyname,qual,with_check
    FROM pg_policies
    WHERE schemaname='public'
      AND (coalesce(qual,'') LIKE '%auth.uid()%' OR coalesce(with_check,'') LIKE '%auth.uid()%')
  LOOP
    v_using := replace(r.qual,'auth.uid()','(select auth.uid())');
    v_check := replace(r.with_check,'auth.uid()','(select auth.uid())');
    v_stmt := format('ALTER POLICY %I ON %I.%I',r.policyname,r.schemaname,r.tablename);
    IF v_using IS NOT NULL THEN v_stmt := v_stmt || format(' USING (%s)',v_using); END IF;
    IF v_check IS NOT NULL THEN v_stmt := v_stmt || format(' WITH CHECK (%s)',v_check); END IF;
    EXECUTE v_stmt;
  END LOOP;
END $$;