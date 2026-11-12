-- Isolated regression fixture for internal-schema default ACL hardening.
-- It models PostgreSQL's default PUBLIC EXECUTE on newly created functions.
-- Runs in a disposable PostgreSQL database and rolls back every object/role change.
BEGIN;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') THEN
    CREATE ROLE authenticated NOLOGIN;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'service_role') THEN
    CREATE ROLE service_role NOLOGIN;
  END IF;
END
$$;

CREATE SCHEMA priv_fixture;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv_fixture
  GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv_fixture
  GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv_fixture
  GRANT EXECUTE ON FUNCTIONS TO authenticated;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv_fixture
  GRANT ALL ON TABLES TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv_fixture
  GRANT ALL ON SEQUENCES TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv_fixture
  GRANT EXECUTE ON FUNCTIONS TO service_role;

CREATE TABLE priv_fixture.before_table (id integer);
CREATE SEQUENCE priv_fixture.before_seq;
CREATE FUNCTION priv_fixture.before_fn() RETURNS integer
LANGUAGE sql AS 'SELECT 1';

DO $$
BEGIN
  IF NOT has_table_privilege('authenticated', 'priv_fixture.before_table', 'SELECT')
     OR NOT has_sequence_privilege('authenticated', 'priv_fixture.before_seq', 'USAGE')
     OR NOT has_function_privilege('authenticated', 'priv_fixture.before_fn()', 'EXECUTE')
     OR NOT has_function_privilege('anon', 'priv_fixture.before_fn()', 'EXECUTE') THEN
    RAISE EXCEPTION 'Fixture precondition failed: simulated broad defaults were not present.';
  END IF;
END
$$;

-- The per-schema revokes close table/sequence grants and authenticated's
-- schema-specific function grant. PUBLIC function EXECUTE must be revoked
-- globally because PostgreSQL adds global defaults to schema defaults.
ALTER DEFAULT PRIVILEGES FOR ROLE postgres
  REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv_fixture
  REVOKE ALL ON TABLES FROM authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv_fixture
  REVOKE ALL ON SEQUENCES FROM authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv_fixture
  REVOKE EXECUTE ON FUNCTIONS FROM authenticated;

CREATE TABLE priv_fixture.after_table (id integer);
CREATE SEQUENCE priv_fixture.after_seq;
CREATE FUNCTION priv_fixture.after_fn() RETURNS integer
LANGUAGE sql AS 'SELECT 2';

DO $$
BEGIN
  IF has_table_privilege('authenticated', 'priv_fixture.after_table', 'SELECT')
     OR has_sequence_privilege('authenticated', 'priv_fixture.after_seq', 'USAGE')
     OR has_function_privilege('authenticated', 'priv_fixture.after_fn()', 'EXECUTE')
     OR has_function_privilege('anon', 'priv_fixture.after_fn()', 'EXECUTE') THEN
    RAISE EXCEPTION 'Default ACL hardening failed: a new internal object remained directly accessible.';
  END IF;

  IF NOT has_table_privilege('service_role', 'priv_fixture.after_table', 'SELECT')
     OR NOT has_sequence_privilege('service_role', 'priv_fixture.after_seq', 'USAGE')
     OR NOT has_function_privilege('service_role', 'priv_fixture.after_fn()', 'EXECUTE') THEN
    RAISE EXCEPTION 'Default ACL hardening changed service_role privileges unexpectedly.';
  END IF;

  -- Default-ACL changes do not revoke privileges from existing functions.
  IF NOT has_function_privilege('anon', 'priv_fixture.before_fn()', 'EXECUTE') THEN
    RAISE EXCEPTION 'Changing defaults unexpectedly revoked an existing function grant.';
  END IF;
END
$$;

ROLLBACK;
