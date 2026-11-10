
ALTER FUNCTION public.aplicar_dano_token_gm_personagem_srd(bigint,text,text,integer)
  SET search_path = pg_catalog, public, pg_temp;
ALTER FUNCTION public.conceder_xp_personagem_srd(bigint,text,integer)
  SET search_path = pg_catalog, public, pg_temp;
ALTER FUNCTION public.conjurar_missil_magico_srd(text,text,smallint,text,integer)
  SET search_path = pg_catalog, public, pg_temp;
ALTER FUNCTION public.descanso_longo_personagem_srd(bigint,text)
  SET search_path = pg_catalog, public, pg_temp;
ALTER FUNCTION public.salvar_idiomas_personagem_srd(text,jsonb)
  SET search_path = pg_catalog, public, auth, pg_temp;
ALTER FUNCTION public.salvar_talentos_bonus_classe_inicial_srd(text,jsonb)
  SET search_path = pg_catalog, public, pg_temp;
