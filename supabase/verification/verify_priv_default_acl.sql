-- Run after 20261112100000_harden_priv_default_privileges.sql.
-- Read-only catalog assertions for future objects created by postgres.
DO $$
DECLARE
  v_postgres oid := (SELECT oid FROM pg_roles WHERE rolname='postgres');
  v_priv oid := to_regnamespace('priv');
  v_service oid := (SELECT oid FROM pg_roles WHERE rolname='service_role');
BEGIN
  IF v_postgres IS NULL OR v_priv IS NULL OR v_service IS NULL THEN
    RAISE EXCEPTION 'Required owner/schema/service role is missing.';
  END IF;

  -- PostgreSQL's global default EXECUTE must no longer flow to PUBLIC.
  IF EXISTS (
    SELECT 1
    FROM pg_default_acl d
    CROSS JOIN LATERAL aclexplode(d.defaclacl) a
    WHERE d.defaclrole=v_postgres
      AND d.defaclnamespace=0
      AND d.defaclobjtype='f'
      AND a.grantee=0
      AND a.privilege_type='EXECUTE'
  ) THEN
    RAISE EXCEPTION 'Future postgres-owned functions still grant EXECUTE to PUBLIC.';
  END IF;

  -- Internal schema defaults must not grant direct object access to clients.
  IF EXISTS (
    SELECT 1
    FROM pg_default_acl d
    CROSS JOIN LATERAL aclexplode(d.defaclacl) a
    JOIN pg_roles r ON r.oid=a.grantee
    WHERE d.defaclrole=v_postgres
      AND d.defaclnamespace=v_priv
      AND d.defaclobjtype IN ('r','S','f')
      AND r.rolname IN ('anon','authenticated')
  ) THEN
    RAISE EXCEPTION 'Future priv objects still grant direct access to anon/authenticated.';
  END IF;

  -- Trusted service_role defaults must remain explicit for all internal object types.
  IF NOT EXISTS (
    SELECT 1 FROM pg_default_acl d
    CROSS JOIN LATERAL aclexplode(d.defaclacl) a
    WHERE d.defaclrole=v_postgres AND d.defaclnamespace=v_priv
      AND d.defaclobjtype='r' AND a.grantee=v_service
      AND a.privilege_type='SELECT'
  ) OR NOT EXISTS (
    SELECT 1 FROM pg_default_acl d
    CROSS JOIN LATERAL aclexplode(d.defaclacl) a
    WHERE d.defaclrole=v_postgres AND d.defaclnamespace=v_priv
      AND d.defaclobjtype='S' AND a.grantee=v_service
      AND a.privilege_type='USAGE'
  ) OR NOT EXISTS (
    SELECT 1 FROM pg_default_acl d
    CROSS JOIN LATERAL aclexplode(d.defaclacl) a
    WHERE d.defaclrole=v_postgres AND d.defaclnamespace=v_priv
      AND d.defaclobjtype='f' AND a.grantee=v_service
      AND a.privilege_type='EXECUTE'
  ) THEN
    RAISE EXCEPTION 'service_role default access was not preserved for priv objects.';
  END IF;
END $$;

SELECT 'priv default ACL verification passed' AS result;
