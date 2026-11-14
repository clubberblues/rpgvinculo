
-- These helper RPCs are invoked internally by guarded creation/turn functions.
-- They are not client endpoints and should not be callable directly.
REVOKE EXECUTE ON FUNCTION public.salvar_pericias_srd(text,jsonb)
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.salvar_talentos_srd(text,jsonb)
FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.srd_expire_campaign_conditions(bigint)
FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.salvar_pericias_srd(text,jsonb) TO service_role;
GRANT EXECUTE ON FUNCTION public.salvar_talentos_srd(text,jsonb) TO service_role;
GRANT EXECUTE ON FUNCTION public.srd_expire_campaign_conditions(bigint) TO service_role;
