
-- Legacy condition rows are no longer managed through the client.
-- In particular, a player must not clear a self-affecting condition by RPC.
REVOKE ALL ON FUNCTION public.remove_condition(BIGINT,TEXT) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.remove_condition(BIGINT,TEXT) TO service_role;
