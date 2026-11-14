
ALTER FUNCTION public.concluir_avanco_nivel_personagem_srd(bigint,text,integer,jsonb,jsonb,text) SECURITY DEFINER;
REVOKE ALL ON FUNCTION public.concluir_avanco_nivel_personagem_srd(bigint,text,integer,jsonb,jsonb,text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.concluir_avanco_nivel_personagem_srd(bigint,text,integer,jsonb,jsonb,text) TO authenticated;

ALTER FUNCTION public.concluir_avanco_nivel_personagem_srd_v2(bigint,text,integer,jsonb,jsonb,text,jsonb) SECURITY INVOKER;
ALTER FUNCTION public.concluir_avanco_nivel_personagem_srd_v2(bigint,text,integer,jsonb,jsonb,text,jsonb) SET search_path = pg_catalog, public;
REVOKE ALL ON FUNCTION public.concluir_avanco_nivel_personagem_srd_v2(bigint,text,integer,jsonb,jsonb,text,jsonb) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.concluir_avanco_nivel_personagem_srd_v2(bigint,text,integer,jsonb,jsonb,text,jsonb) TO authenticated;
