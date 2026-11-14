-- Harden objects created by the postgres migration owner in the internal schema.
-- Existing object ACLs are intentionally unchanged; use explicit per-object
-- grants for the small set of public RPCs that need to call these helpers.
BEGIN;

-- PostgreSQL grants EXECUTE on newly-created functions to PUBLIC by default.
-- Revoke that global default so anon cannot inherit access to future priv helpers.
ALTER DEFAULT PRIVILEGES FOR ROLE postgres
  REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

-- Keep authenticated clients out of future internal tables, sequences and
-- functions. SECURITY DEFINER entry points owned by postgres remain able to
-- use these objects; service_role retains explicit default access for trusted
-- operational workflows.
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  REVOKE ALL ON TABLES FROM authenticated, anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  REVOKE ALL ON SEQUENCES FROM authenticated, anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  REVOKE EXECUTE ON FUNCTIONS FROM authenticated, anon;

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  GRANT ALL ON TABLES TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  GRANT ALL ON SEQUENCES TO service_role;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  GRANT EXECUTE ON FUNCTIONS TO service_role;

COMMIT;
