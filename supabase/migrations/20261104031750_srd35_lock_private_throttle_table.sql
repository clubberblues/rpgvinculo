
-- The throttle table is an internal anti-bruteforce store used only by
-- SECURITY DEFINER helpers in schema priv. Clients must never read or mutate it.
REVOKE ALL ON TABLE priv.throttle FROM PUBLIC,anon,authenticated;
GRANT SELECT,INSERT,UPDATE,DELETE ON TABLE priv.throttle TO service_role;
