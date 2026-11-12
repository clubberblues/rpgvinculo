-- Isolated regression fixture for the proposed internal-schema default ACL hardening.
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
     OR NOT has_function_privilege('authenticated', 'priv_fixture.before_fn()', 'EXECUTE') THEN
    RAISE EXCEPTION 'Fixture precondition failed: authenticated did not receive the simulated broad defaults.';
  END IF;
END
$$;

-- Exact remediation proposed for the production schema priv.
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
     OR has_function_privilege('authenticated', 'priv_fixture.after_fn()', 'EXECUTE') THEN
    RAISE EXCEPTION 'Default ACL hardening failed: authenticated received access to a newly created internal object.';
  END IF;

  IF NOT has_table_privilege('service_role', 'priv_fixture.after_table', 'SELECT')
     OR NOT has_sequence_privilege('service_role', 'priv_fixture.after_seq', 'USAGE')
     OR NOT has_function_privilege('service_role', 'priv_fixture.after_fn()', 'EXECUTE') THEN
    RAISE EXCEPTION 'Default ACL hardening changed service_role privileges unexpectedly.';
  END IF;
END
$$;

ROLLBACK;
