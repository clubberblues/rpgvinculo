-- Conclui a criação de personagem em uma única transação.
-- Se qualquer etapa falhar, a inserção inicial e todas as escolhas são revertidas.
CREATE OR REPLACE FUNCTION public.finalizar_criacao_personagem_srd(
  p_nome text,
  p_raca_id text,
  p_classe_id text,
  p_atributos jsonb,
  p_pericias jsonb,
  p_talentos jsonb,
  p_identidade jsonb,
  p_idiomas jsonb,
  p_talentos_bonus jsonb,
  p_domain_ids text[],
  p_grimorio jsonb,
  p_equipamento_metodo text,
  p_equipamento_resultados jsonb,
  p_equipamento_itens jsonb
)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_character_id text;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  v_character_id := public.criar_personagem_srd_completo(
    p_nome,p_raca_id,p_classe_id,p_atributos,p_pericias,p_talentos,p_identidade
  );

  PERFORM public.salvar_idiomas_personagem_srd(v_character_id,p_idiomas);
  PERFORM public.salvar_talentos_bonus_classe_inicial_srd(
    v_character_id,COALESCE(p_talentos_bonus,'[]'::jsonb)
  );

  IF COALESCE(array_length(p_domain_ids,1),0)>0 THEN
    PERFORM public.salvar_dominios_personagem_srd(v_character_id,p_domain_ids);
  END IF;

  IF p_grimorio IS NOT NULL THEN
    PERFORM public.salvar_grimorio_srd(v_character_id,p_grimorio);
  END IF;

  PERFORM public.finalizar_equipamento_inicial_srd(
    v_character_id,p_equipamento_metodo,
    COALESCE(p_equipamento_resultados,'[]'::jsonb),
    COALESCE(p_equipamento_itens,'[]'::jsonb)
  );

  RETURN v_character_id;
END;
$function$;

REVOKE ALL ON FUNCTION public.finalizar_criacao_personagem_srd(
  text,text,text,jsonb,jsonb,jsonb,jsonb,jsonb,jsonb,text[],jsonb,text,jsonb,jsonb
) FROM PUBLIC,anon;

GRANT EXECUTE ON FUNCTION public.finalizar_criacao_personagem_srd(
  text,text,text,jsonb,jsonb,jsonb,jsonb,jsonb,jsonb,text[],jsonb,text,jsonb,jsonb
) TO authenticated;
