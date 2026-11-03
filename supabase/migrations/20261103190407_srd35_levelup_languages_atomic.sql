CREATE OR REPLACE FUNCTION public.concluir_avanco_nivel_personagem_srd_v2(
  p_campaign_id BIGINT,
  p_character_id TEXT,
  p_hit_die_roll INTEGER,
  p_skill_ranks JSONB DEFAULT '{}'::JSONB,
  p_feats JSONB DEFAULT '[]'::JSONB,
  p_attribute TEXT DEFAULT NULL::TEXT,
  p_idiomas JSONB DEFAULT NULL::JSONB
) RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog','public'
AS $function$
DECLARE
  v_result JSONB;
BEGIN
  v_result:=public.concluir_avanco_nivel_personagem_srd(
    p_campaign_id,p_character_id,p_hit_die_roll,p_skill_ranks,p_feats,p_attribute
  );
  IF p_idiomas IS NOT NULL THEN
    PERFORM public.salvar_idiomas_personagem_srd(p_character_id,p_idiomas);
  END IF;
  RETURN v_result;
END;
$function$;

REVOKE ALL ON FUNCTION public.concluir_avanco_nivel_personagem_srd_v2(BIGINT,TEXT,INTEGER,JSONB,JSONB,TEXT,JSONB) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.concluir_avanco_nivel_personagem_srd_v2(BIGINT,TEXT,INTEGER,JSONB,JSONB,TEXT,JSONB) TO authenticated,service_role;