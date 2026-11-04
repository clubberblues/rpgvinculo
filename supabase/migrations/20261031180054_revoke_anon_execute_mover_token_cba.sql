REVOKE ALL ON FUNCTION public.mover_token_player_cba(BIGINT, TEXT, INTEGER, INTEGER) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.mover_token_player_cba(BIGINT, TEXT, INTEGER, INTEGER) FROM anon;
GRANT EXECUTE ON FUNCTION public.mover_token_player_cba(BIGINT, TEXT, INTEGER, INTEGER) TO authenticated;