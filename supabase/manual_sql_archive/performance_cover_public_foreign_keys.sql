-- Cover public foreign keys with indexes for predictable join/delete performance.
DO $$
DECLARE
  r record;
  idx_name text;
BEGIN
  FOR r IN
    SELECT n.nspname AS schema_name,
           rel.relname AS table_name,
           string_agg(quote_ident(att.attname), ', ' ORDER BY k.ord) AS columns_sql,
           string_agg(att.attname, '__' ORDER BY k.ord) AS columns_name
    FROM pg_constraint c
    JOIN pg_class rel ON rel.oid=c.conrelid
    JOIN pg_namespace n ON n.oid=rel.relnamespace
    CROSS JOIN LATERAL unnest(c.conkey) WITH ORDINALITY k(attnum,ord)
    JOIN pg_attribute att ON att.attrelid=rel.oid AND att.attnum=k.attnum
    WHERE c.contype='f' AND n.nspname='public'
    GROUP BY n.nspname,rel.relname,c.oid
  LOOP
    idx_name:=left('idx_fk_'||r.table_name||'_'||r.columns_name, 60);
    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS %I ON %I.%I (%s)',
      idx_name,r.schema_name,r.table_name,r.columns_sql
    );
  END LOOP;
END $$;