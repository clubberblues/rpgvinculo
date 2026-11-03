-- Vínculo · D&D 3.5
-- Economia de ações autoritativa no servidor e conjuração vinculada à ação padrão.
-- Aplicar APÓS cba_iniciativa_migration.sql, vtt_dnd35_final_migration.sql e
-- srd35_spellcasting_migration.sql. Não altera diretamente dados de campanha.

BEGIN;

CREATE OR REPLACE FUNCTION public.consumir_acao_turno_srd(
  p_campaign_id BIGINT,
  p_character_id TEXT,
  p_acao TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_combat JSONB;
  v_order JSONB;
  v_actor JSONB;
  v_current_turn INTEGER;
  v_round INTEGER;
  v_action_state JSONB;
  v_by_character JSONB;
  v_character_actions JSONB;
  v_action TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF NULLIF(BTRIM(p_character_id), '') IS NULL THEN
    RAISE EXCEPTION 'O identificador do personagem é obrigatório.';
  END IF;
  v_action := LOWER(BTRIM(COALESCE(p_acao, '')));
  IF v_action NOT IN ('padrao', 'movimento', 'rapida') THEN
    RAISE EXCEPTION 'Ação inválida. Use padrao, movimento ou rapida.';
  END IF;

  SELECT c.* INTO v_campaign
    FROM public.campaigns AS c
   WHERE c.id = p_campaign_id
   FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF UPPER(COALESCE(v_campaign.state, '')) <> 'COMBATE' THEN
    RAISE EXCEPTION 'A economia de ações só está ativa durante o combate.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
      FROM public.characters AS ch
      JOIN public.members AS m
        ON m.campaign_id = ch.campaign_id
       AND m.user_id = ch.user_id
       AND m.role = 'PLAYER'
     WHERE ch.id::TEXT = BTRIM(p_character_id)
       AND ch.campaign_id = p_campaign_id
       AND ch.user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'A ficha não pertence a este jogador nesta campanha.';
  END IF;

  v_combat := COALESCE(v_campaign.combat_data, '{}'::JSONB);
  IF LOWER(COALESCE(v_combat->>'active', 'false')) <> 'true' THEN
    RAISE EXCEPTION 'Não há iniciativa ativa; o Mestre deve iniciar a ordem de combate.';
  END IF;
  v_order := CASE
    WHEN jsonb_typeof(v_combat->'turn_order') = 'array' THEN v_combat->'turn_order'
    ELSE '[]'::JSONB
  END;
  IF jsonb_array_length(v_order) = 0 THEN
    RAISE EXCEPTION 'A ordem de iniciativa está vazia.';
  END IF;
  IF COALESCE(v_combat->>'current_turn', '') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'O índice do turno atual é inválido.';
  END IF;
  v_current_turn := (v_combat->>'current_turn')::INTEGER;
  IF v_current_turn < 0 OR v_current_turn >= jsonb_array_length(v_order) THEN
    RAISE EXCEPTION 'O índice do turno atual está fora da ordem de iniciativa.';
  END IF;
  v_actor := v_order->v_current_turn;
  IF COALESCE(LOWER(v_actor->>'is_monster'), 'false') = 'true'
     OR v_actor->>'id' IS DISTINCT FROM BTRIM(p_character_id) THEN
    RAISE EXCEPTION 'Apenas o personagem cujo turno está ativo pode gastar esta ação.';
  END IF;

  v_round := CASE
    WHEN COALESCE(v_combat->>'round', '') ~ '^[0-9]+$'
      THEN GREATEST(1, (v_combat->>'round')::INTEGER)
    ELSE 1
  END;
  v_action_state := v_combat->'action_economy';
  IF jsonb_typeof(v_action_state) = 'object'
     AND COALESCE(v_action_state->>'round', '') = v_round::TEXT
     AND jsonb_typeof(v_action_state->'by_character') = 'object' THEN
    v_by_character := v_action_state->'by_character';
  ELSE
    -- A mudança de rodada reinicia o registro sem depender de renderizações no navegador.
    v_by_character := '{}'::JSONB;
  END IF;

  v_character_actions := CASE
    WHEN jsonb_typeof(v_by_character->BTRIM(p_character_id)) = 'object'
      THEN v_by_character->BTRIM(p_character_id)
    ELSE '{}'::JSONB
  END;
  IF LOWER(COALESCE(v_character_actions->>v_action, 'false')) = 'true' THEN
    RAISE EXCEPTION 'A ação % deste personagem já foi usada nesta rodada.', v_action;
  END IF;

  v_character_actions := v_character_actions || jsonb_build_object(v_action, TRUE);
  v_by_character := jsonb_set(
    v_by_character,
    ARRAY[BTRIM(p_character_id)],
    v_character_actions,
    TRUE
  );
  v_action_state := jsonb_build_object(
    'round', v_round,
    'by_character', v_by_character
  );
  v_combat := v_combat || jsonb_build_object('action_economy', v_action_state);

  UPDATE public.campaigns
     SET combat_data = v_combat
   WHERE id = p_campaign_id;

  RETURN jsonb_build_object(
    'combat_data', v_combat,
    'action_economy', v_action_state,
    'round', v_round,
    'character_id', BTRIM(p_character_id),
    'action', v_action
  );
END;
$$;

REVOKE ALL ON FUNCTION public.consumir_acao_turno_srd(BIGINT, TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.consumir_acao_turno_srd(BIGINT, TEXT, TEXT) TO authenticated;

-- O cliente não pode contornar o wrapper chamando diretamente a RPC antiga.
-- O proprietário das funções SECURITY DEFINER ainda pode chamá-la internamente.
REVOKE ALL ON FUNCTION public.conjurar_magia_srd(TEXT, TEXT, SMALLINT, TEXT) FROM PUBLIC, authenticated;

-- Chama o RPC já existente de conjuração na mesma transação. Em combate, a ação
-- padrão só é registrada se também for válida a magia/espaço/alvo; qualquer erro
-- reverte as duas operações. Em exploração, mantém o comportamento anterior.
CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd(
  p_character_id TEXT,
  p_spell_id TEXT,
  p_slot_level SMALLINT,
  p_target_token_key TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_campaign_id BIGINT;
  v_campaign_state TEXT;
  v_combat JSONB;
  v_result JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Autenticação obrigatória.';
  END IF;
  SELECT ch.campaign_id INTO v_campaign_id
    FROM public.characters AS ch
   WHERE ch.id::TEXT = BTRIM(p_character_id)
     AND ch.user_id = auth.uid()
   FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização.';
  END IF;

  IF v_campaign_id IS NOT NULL THEN
    SELECT c.state INTO v_campaign_state
      FROM public.campaigns AS c
     WHERE c.id = v_campaign_id
     FOR UPDATE;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Campanha do personagem não encontrada.';
    END IF;
    IF UPPER(COALESCE(v_campaign_state, '')) = 'COMBATE' THEN
      PERFORM public.consumir_acao_turno_srd(v_campaign_id, p_character_id, 'padrao');
    END IF;
  END IF;

  v_result := public.conjurar_magia_srd(
    p_character_id,
    p_spell_id,
    p_slot_level,
    p_target_token_key
  );

  IF v_campaign_id IS NOT NULL
     AND UPPER(COALESCE(v_campaign_state, '')) = 'COMBATE' THEN
    SELECT c.combat_data INTO v_combat
      FROM public.campaigns AS c
     WHERE c.id = v_campaign_id;
    RETURN COALESCE(v_result, '{}'::JSONB) || jsonb_build_object(
      'combat_data', COALESCE(v_combat, '{}'::JSONB),
      'action_economy', COALESCE(v_combat->'action_economy', '{}'::JSONB)
    );
  END IF;
  RETURN COALESCE(v_result, '{}'::JSONB);
END;
$$;

REVOKE ALL ON FUNCTION public.conjurar_magia_com_acao_srd(TEXT, TEXT, SMALLINT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_com_acao_srd(TEXT, TEXT, SMALLINT, TEXT) TO authenticated;

COMMIT;
