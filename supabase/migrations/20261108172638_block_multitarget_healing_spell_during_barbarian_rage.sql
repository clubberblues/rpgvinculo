CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(
  p_character_id text,
  p_spell_id text,
  p_slot_level smallint,
  p_target_token_keys text[],
  p_roll_results integer[]
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id bigint;
  v_state text;
  v_result jsonb;
  v_combat jsonb;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Autenticação obrigatória';
  END IF;

  SELECT ch.campaign_id
    INTO v_campaign_id
    FROM public.characters ch
   WHERE ch.id::text = btrim(p_character_id)
     AND ch.user_id = auth.uid()
   FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização';
  END IF;

  IF priv.srd_condition_has_flag(
       v_campaign_id, 'character', btrim(p_character_id), 'no_actions'
     )
     OR priv.srd_condition_has_flag(
       v_campaign_id, 'character', btrim(p_character_id), 'cannot_cast'
     ) THEN
    RAISE EXCEPTION 'A condição atual impede conjurar magias.';
  END IF;

  SELECT c.state
    INTO v_state
    FROM public.campaigns c
   WHERE c.id = v_campaign_id
   FOR UPDATE;

  IF upper(coalesce(v_state, '')) = 'COMBATE' THEN
    PERFORM public.consumir_acao_turno_srd(
      v_campaign_id, p_character_id, 'padrao'
    );
  END IF;

  v_result := public.conjurar_magia_srd_multialvo_v3(
    p_character_id, p_spell_id, p_slot_level,
    p_target_token_keys, p_roll_results
  );

  IF upper(coalesce(v_state, '')) = 'COMBATE' THEN
    SELECT combat_data
      INTO v_combat
      FROM public.campaigns
     WHERE id = v_campaign_id;

    RETURN v_result || jsonb_build_object(
      'combat_data', coalesce(v_combat, '{}'::jsonb)
    );
  END IF;

  RETURN v_result;
END;
$function$;

REVOKE ALL ON FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(text,text,smallint,text[],integer[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(text,text,smallint,text[],integer[]) TO authenticated;