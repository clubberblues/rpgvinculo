-- Superseded migration marker.
-- The level-up RPC is installed by later migrations:
-- 20261103080000_srd35_server_authoritative_hit_die_roll.sql
-- 20261103090000_srd35_server_hit_die_cached_client_compatibility.sql
-- The live database already contains the newer implementation, and the manual
-- hit-die contract is maintained by 20261103140000_srd35_manual_hit_die_roll.sql.
-- Keep this historical migration as a no-op so a future db push cannot replace
-- the newer RPC with the older implementation.

DO $migration$
BEGIN
  RAISE NOTICE 'srd35_level_up_assistant superseded; no schema change required.';
END
$migration$;
