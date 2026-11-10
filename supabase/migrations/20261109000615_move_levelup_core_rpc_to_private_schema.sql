
ALTER FUNCTION public.concluir_avanco_nivel_personagem_srd(bigint,text,integer,jsonb,jsonb,text)
  SET SCHEMA priv;
ALTER FUNCTION priv.concluir_avanco_nivel_personagem_srd(bigint,text,integer,jsonb,jsonb,text)
  SET search_path = pg_catalog, public, priv;
REVOKE ALL ON FUNCTION priv.concluir_avanco_nivel_personagem_srd(bigint,text,integer,jsonb,jsonb,text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION priv.concluir_avanco_nivel_personagem_srd(bigint,text,integer,jsonb,jsonb,text) TO authenticated;
CREATE OR REPLACE FUNCTION public.concluir_avanco_nivel_personagem_srd_v2(p_campaign_id bigint, p_character_id text, p_hit_die_roll integer, p_skill_ranks jsonb DEFAULT '{}'::jsonb, p_feats jsonb DEFAULT '[]'::jsonb, p_attribute text DEFAULT NULL::text, p_idiomas jsonb DEFAULT NULL::jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'public'
AS $function$
DECLARE
  v_result JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  v_result:=priv.concluir_avanco_nivel_personagem_srd(
    p_campaign_id,p_character_id,p_hit_die_roll,p_skill_ranks,p_feats,p_attribute
  );
  IF p_idiomas IS NOT NULL THEN
    PERFORM public.salvar_idiomas_personagem_srd(p_character_id,p_idiomas);
  END IF;
  RETURN v_result;
END;
$function$

