-- The active VTT uses the campaign-scoped SRD damage/healing RPCs.
-- Retire legacy token-table endpoints from authenticated clients.
REVOKE ALL ON FUNCTION public.apply_damage(BIGINT,INTEGER,TEXT) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public.apply_heal(BIGINT,INTEGER) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.apply_damage(BIGINT,INTEGER,TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION public.apply_heal(BIGINT,INTEGER) TO service_role;
