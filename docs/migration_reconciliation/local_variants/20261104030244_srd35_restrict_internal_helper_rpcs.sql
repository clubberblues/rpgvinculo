-- Internal SRD helpers are not public client endpoints.
REVOKE EXECUTE ON FUNCTION public.salvar_pericias_srd(text,jsonb) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.salvar_talentos_srd(text,jsonb) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.srd_expire_campaign_conditions(bigint) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.salvar_pericias_srd(text,jsonb) TO service_role;
GRANT EXECUTE ON FUNCTION public.salvar_talentos_srd(text,jsonb) TO service_role;
GRANT EXECUTE ON FUNCTION public.srd_expire_campaign_conditions(bigint) TO service_role;
