
-- Retire legacy character/sheet/spell RPC entry points superseded by the SRD 3.5 flow.
-- Current ficha/mesa/lobby clients do not call these functions; internal owner calls remain possible.
REVOKE ALL ON FUNCTION public.apply_condition(BIGINT,TEXT,TEXT,TEXT) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public.create_character(BIGINT,TEXT) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public.confirm_sheet(BIGINT) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public.forget_spell(BIGINT,BIGINT) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public.learn_spell(BIGINT,BIGINT) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public.long_rest(BIGINT) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public.short_rest(BIGINT) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public.save_sheet(BIGINT,JSONB,TEXT) FROM PUBLIC,anon,authenticated;

GRANT EXECUTE ON FUNCTION public.apply_condition(BIGINT,TEXT,TEXT,TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION public.create_character(BIGINT,TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION public.confirm_sheet(BIGINT) TO service_role;
GRANT EXECUTE ON FUNCTION public.forget_spell(BIGINT,BIGINT) TO service_role;
GRANT EXECUTE ON FUNCTION public.learn_spell(BIGINT,BIGINT) TO service_role;
GRANT EXECUTE ON FUNCTION public.long_rest(BIGINT) TO service_role;
GRANT EXECUTE ON FUNCTION public.short_rest(BIGINT) TO service_role;
GRANT EXECUTE ON FUNCTION public.save_sheet(BIGINT,JSONB,TEXT) TO service_role;
