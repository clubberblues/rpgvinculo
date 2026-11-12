-- Regression fixture for the exact internal-schema default ACL migration.
-- Runs only in a disposable PostgreSQL CI database. The included migration commits;
-- the whole database is discarded with the CI service container.
\\set ON_ERROR_STOP on

DO $roles$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='authenticated') THEN CREATE ROLE authenticated NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='anon') THEN CREATE ROLE anon NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='service_role') THEN CREATE ROLE service_role NOLOGIN; END IF;
END
$roles$;

CREATE SCHEMA IF NOT EXISTS priv;
GRANT USAGE ON SCHEMA priv TO authenticated, anon, service_role;

-- Reproduce the overly broad defaults that existed before the migration.
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  GRANT EXECUTE ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  GRANT ALL ON TABLES TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  GRANT ALL ON SEQUENCES TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  GRANT EXECUTE ON FUNCTIONS TO service_role;

CREATE TABLE priv.before_table (id integer);
CREATE SEQUENCE priv.before_seq;
CREATE FUNCTION priv.before_fn() RETURNS integer LANGUAGE sql AS 'SELECT 1';

DO $pre$
BEGIN
  IF NOT has_table_privilege('authenticated','priv.before_table','SELECT')
     OR NOT has_sequence_privilege('authenticated','priv.before_seq','USAGE')
     OR NOT has_function_privilege('authenticated','priv.before_fn()','EXECUTE')
     OR NOT has_function_privilege('anon','priv.before_fn()','EXECUTE') THEN
    RAISE EXCEPTION 'Fixture precondition failed: broad default ACLs were not reproduced.';
  END IF;
END
$pre$;

-- Apply the exact migration shipped to production.
\\i supabase/migrations/20261112100000_harden_priv_default_privileges.sql
\\i supabase/verification/verify_priv_default_acl.sql

CREATE TABLE priv.after_table (id integer);
CREATE SEQUENCE priv.after_seq;
CREATE FUNCTION priv.after_fn() RETURNS integer LANGUAGE sql AS 'SELECT 2';

DO $post$
BEGIN
  IF has_table_privilege('authenticated','priv.after_table','SELECT')
     OR has_sequence_privilege('authenticated','priv.after_seq','USAGE')
     OR has_function_privilege('authenticated','priv.after_fn()','EXECUTE')
     OR has_function_privilege('anon','priv.after_fn()','EXECUTE') THEN
    RAISE EXCEPTION 'New internal object remained directly accessible to anon/authenticated.';
  END IF;

  IF NOT has_table_privilege('service_role','priv.after_table','SELECT')
     OR NOT has_sequence_privilege('service_role','priv.after_seq','USAGE')
     OR NOT has_function_privilege('service_role','priv.after_fn()','EXECUTE') THEN
    RAISE EXCEPTION 'Migration failed to preserve trusted service_role defaults.';
  END IF;

  -- ALTER DEFAULT PRIVILEGES must not revoke ACLs from existing objects.
  IF NOT has_table_privilege('authenticated','priv.before_table','SELECT')
     OR NOT has_sequence_privilege('authenticated','priv.before_seq','USAGE')
     OR NOT has_function_privilege('authenticated','priv.before_fn()','EXECUTE') THEN
    RAISE EXCEPTION 'Migration unexpectedly changed privileges on existing objects.';
  END IF;
END
$post$;

SELECT 'priv default ACL migration fixture passed' AS result;
