-- The GM-only public wrappers call internal helpers in schema priv.
-- They must execute with their controlled owner privileges; the wrappers
-- retain explicit auth.uid() + GM checks before reading campaign/token data.
BEGIN;

ALTER FUNCTION public.srd_consultar_modificadores_manobra_srd(
  bigint, text, text, text, boolean, boolean
) SECURITY DEFINER;
ALTER FUNCTION public.srd_consultar_modificadores_manobra_srd(
  bigint, text, text, text, boolean, boolean
) SET search_path TO pg_catalog, public, priv, pg_temp;
REVOKE ALL ON FUNCTION public.srd_consultar_modificadores_manobra_srd(
  bigint, text, text, text, boolean, boolean
) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_consultar_modificadores_manobra_srd(
  bigint, text, text, text, boolean, boolean
) TO authenticated, service_role;

ALTER FUNCTION public.srd_listar_ataques_naturais_oportunidade_srd(
  bigint, text
) SECURITY DEFINER;
ALTER FUNCTION public.srd_listar_ataques_naturais_oportunidade_srd(
  bigint, text
) SET search_path TO pg_catalog, public, priv, pg_temp;
REVOKE ALL ON FUNCTION public.srd_listar_ataques_naturais_oportunidade_srd(
  bigint, text
) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_listar_ataques_naturais_oportunidade_srd(
  bigint, text
) TO authenticated, service_role;

COMMIT;
