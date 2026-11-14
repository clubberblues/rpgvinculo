-- Prevent campaign members from bypassing the role-filtered tabletop snapshot
-- by selecting the raw JSON state columns directly through PostgREST.
-- Safe campaign metadata remains available to authenticated members.
BEGIN;

REVOKE SELECT ON TABLE public.campaigns FROM PUBLIC, anon, authenticated;
GRANT SELECT (
  id,
  name,
  owner_id,
  state,
  active,
  location_id,
  created_at,
  capa_url
) ON TABLE public.campaigns TO authenticated;

-- These two GM-only read functions inspect the private scene JSON. They already
-- enforce auth.uid() and public.my_role(...)=GM before reading campaign state.
-- Run them as their owner so column-level table grants do not weaken the
-- client-facing column boundary.
ALTER FUNCTION public.srd_consultar_modificadores_manobra_srd(
  bigint, text, text, text, boolean, boolean
) SECURITY DEFINER;
ALTER FUNCTION public.srd_consultar_modificadores_manobra_srd(
  bigint, text, text, text, boolean, boolean
) SET search_path TO pg_catalog, public, priv, auth, pg_temp;
REVOKE ALL ON FUNCTION public.srd_consultar_modificadores_manobra_srd(
  bigint, text, text, text, boolean, boolean
) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_consultar_modificadores_manobra_srd(
  bigint, text, text, text, boolean, boolean
) TO authenticated;

ALTER FUNCTION public.srd_listar_ataques_naturais_oportunidade_srd(
  bigint, text
) SECURITY DEFINER;
ALTER FUNCTION public.srd_listar_ataques_naturais_oportunidade_srd(
  bigint, text
) SET search_path TO pg_catalog, public, priv, auth, pg_temp;
REVOKE ALL ON FUNCTION public.srd_listar_ataques_naturais_oportunidade_srd(
  bigint, text
) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_listar_ataques_naturais_oportunidade_srd(
  bigint, text
) TO authenticated;

COMMIT;
