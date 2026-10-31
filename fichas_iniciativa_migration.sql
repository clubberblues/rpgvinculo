-- Vínculo: escolha/exclusão segura de fichas e início atômico da iniciativa.
-- Execute no SQL Editor do Supabase depois de cba_iniciativa_migration.sql.
-- Não altera nem apaga dados existentes até que o usuário solicite a exclusão de uma ficha.

-- Inicia a ordem e grava o pedido de rolagem na mesma transação. Se a gravação
-- do pedido falhar, o estado combat_data escrito pela RPC original é revertido.
CREATE OR REPLACE FUNCTION public.iniciar_iniciativa_com_pedido(
  p_campaign_id BIGINT,
  p_expected_character_ids TEXT[],
  p_request_id TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_expected TEXT[];
  v_combat JSONB;
  v_mestre TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT COALESCE(array_agg(DISTINCT BTRIM(requested.character_id) ORDER BY BTRIM(requested.character_id)), ARRAY[]::TEXT[])
  INTO v_expected
  FROM unnest(COALESCE(p_expected_character_ids, ARRAY[]::TEXT[])) AS requested(character_id)
  WHERE NULLIF(BTRIM(requested.character_id), '') IS NOT NULL;

  IF cardinality(v_expected) > 0 AND NULLIF(BTRIM(p_request_id), '') IS NULL THEN
    RAISE EXCEPTION 'O identificador do pedido de iniciativa é obrigatório.';
  END IF;

  -- Esta função valida o papel GM, a campanha, o estado COMBATE e as fichas.
  v_combat := public.iniciar_iniciativa(p_campaign_id, v_expected);

  IF cardinality(v_expected) > 0 THEN
    SELECT COALESCE(NULLIF(BTRIM(p.username), ''), 'Mestre')
    INTO v_mestre
    FROM public.profiles AS p
    WHERE p.id = auth.uid();
    v_mestre := COALESCE(v_mestre, 'Mestre');

    INSERT INTO public.campaign_log (campaign_id, type, visibilidade, data)
    VALUES (
      p_campaign_id,
      'test_request',
      'PUBLIC',
      jsonb_build_object(
        'tipo', 'Iniciativa (DES)',
        'alvos', to_jsonb(v_expected),
        'mestre', v_mestre,
        'mestre_id', auth.uid(),
        'request_id', BTRIM(p_request_id)
      )
    );
  END IF;

  RETURN v_combat;
END;
$$;

REVOKE ALL ON FUNCTION public.iniciar_iniciativa_com_pedido(BIGINT, TEXT[], TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.iniciar_iniciativa_com_pedido(BIGINT, TEXT[], TEXT) TO authenticated;

-- Apaga apenas fichas cujo characters.user_id corresponde ao usuário autenticado.
-- Dependências conhecidas são removidas na mesma transação e a ficha é retirada
-- da ordem de iniciativa, se estiver vinculada a uma campanha.
CREATE OR REPLACE FUNCTION public.excluir_ficha_propria(p_character_id TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_character_id public.characters.id%TYPE;
  v_campaign_id public.characters.campaign_id%TYPE;
  v_combat JSONB;
  v_order JSONB := '[]'::JSONB;
  v_expected JSONB := '[]'::JSONB;
  v_order_novo JSONB := '[]'::JSONB;
  v_expected_novo JSONB := '[]'::JSONB;
  v_current_id TEXT;
  v_old_turn INTEGER := 0;
  v_new_turn INTEGER := 0;
  v_active BOOLEAN := FALSE;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT c.id, c.campaign_id
  INTO v_character_id, v_campaign_id
  FROM public.characters AS c
  WHERE c.id::TEXT = BTRIM(p_character_id)
    AND c.user_id = auth.uid()
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Ficha não encontrada ou não pertence à sua conta.';
  END IF;

  IF v_campaign_id IS NOT NULL THEN
    SELECT c.combat_data
    INTO v_combat
    FROM public.campaigns AS c
    WHERE c.id = v_campaign_id
    FOR UPDATE;

    IF FOUND AND v_combat IS NOT NULL THEN
      v_order := CASE WHEN jsonb_typeof(v_combat->'turn_order') = 'array'
                      THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
      v_expected := CASE WHEN jsonb_typeof(v_combat->'expected_character_ids') = 'array'
                         THEN v_combat->'expected_character_ids' ELSE '[]'::JSONB END;
      v_old_turn := GREATEST(0, COALESCE((v_combat->>'current_turn')::INTEGER, 0));

      SELECT current_entry.entry->>'id'
      INTO v_current_id
      FROM jsonb_array_elements(v_order) WITH ORDINALITY AS current_entry(entry, ordinality)
      WHERE current_entry.ordinality = v_old_turn + 1
      LIMIT 1;

      SELECT COALESCE(jsonb_agg(entry.entry ORDER BY entry.ordinality), '[]'::JSONB)
      INTO v_order_novo
      FROM jsonb_array_elements(v_order) WITH ORDINALITY AS entry(entry, ordinality)
      WHERE entry.entry->>'id' IS DISTINCT FROM v_character_id::TEXT;

      SELECT COALESCE(jsonb_agg(expected.character_id ORDER BY expected.ordinality), '[]'::JSONB)
      INTO v_expected_novo
      FROM jsonb_array_elements_text(v_expected) WITH ORDINALITY AS expected(character_id, ordinality)
      WHERE expected.character_id IS DISTINCT FROM v_character_id::TEXT;

      SELECT jsonb_array_length(v_order_novo) > 0
         AND NOT EXISTS (
           SELECT 1
           FROM jsonb_array_elements_text(v_expected_novo) AS expected(character_id)
           WHERE NOT EXISTS (
             SELECT 1
             FROM jsonb_array_elements(v_order_novo) AS ordered(entry)
             WHERE ordered.entry->>'id' = expected.character_id
           )
         )
      INTO v_active;

      IF v_active THEN
        SELECT ordered.ordinality - 1
        INTO v_new_turn
        FROM jsonb_array_elements(v_order_novo) WITH ORDINALITY AS ordered(entry, ordinality)
        WHERE ordered.entry->>'id' = v_current_id
        LIMIT 1;
        IF v_new_turn IS NULL THEN
          v_new_turn := LEAST(v_old_turn, GREATEST(jsonb_array_length(v_order_novo) - 1, 0));
        END IF;
      END IF;

      UPDATE public.campaigns
      SET combat_data = v_combat || jsonb_build_object(
        'turn_order', v_order_novo,
        'expected_character_ids', v_expected_novo,
        'active', v_active,
        'current_turn', v_new_turn
      )
      WHERE id = v_campaign_id;
    END IF;
  END IF;

  DELETE FROM public.character_spells WHERE character_id::TEXT = v_character_id::TEXT;
  DELETE FROM public.character_talents WHERE character_id::TEXT = v_character_id::TEXT;
  DELETE FROM public.character_notes WHERE character_id::TEXT = v_character_id::TEXT;
  DELETE FROM public.inventory WHERE character_id::TEXT = v_character_id::TEXT;
  DELETE FROM public.srd_character_sheets WHERE character_id::TEXT = v_character_id::TEXT;
  DELETE FROM public.vinculo_character_sheets WHERE character_id::TEXT = v_character_id::TEXT;
  DELETE FROM public.characters
  WHERE id = v_character_id AND user_id = auth.uid();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Não foi possível excluir a ficha.';
  END IF;

  RETURN jsonb_build_object('deleted', TRUE, 'character_id', v_character_id::TEXT);
END;
$$;

REVOKE ALL ON FUNCTION public.excluir_ficha_propria(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.excluir_ficha_propria(TEXT) TO authenticated;
