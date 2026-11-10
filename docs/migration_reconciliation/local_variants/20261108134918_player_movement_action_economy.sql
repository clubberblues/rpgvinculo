-- Keep player movement synchronized with the SRD action economy.
-- A move must be visible to condition gates (one_move_or_standard) and
-- to full-round action reservation, while still allowing split movement.

DO $patch$
DECLARE
  v_def TEXT;
  v_old TEXT;
  v_new TEXT;
BEGIN
  v_def := pg_get_functiondef('public.mover_token_player_cba(bigint,text,integer,integer)'::regprocedure);
  IF position('v_action_state' in v_def) > 0 AND position('one_move_or_standard' in v_def) > 0 THEN
    RETURN;
  END IF;

  v_old := E'  v_active BOOLEAN;\n  v_new_token JSONB;';
  v_new := E'  v_active BOOLEAN;\n  v_action_state JSONB;\n  v_by_character JSONB;\n  v_character_actions JSONB;\n  v_new_token JSONB;';
  IF strpos(v_def, v_old) = 0 THEN
    RAISE EXCEPTION 'Patch abortado: bloco de declaração não encontrado.';
  END IF;
  v_def := replace(v_def, v_old, v_new);

  v_old := E'  v_new_token := v_entry || jsonb_build_object(\'gridX\', p_grid_x, \'gridY\', p_grid_y);';
  v_new := E'  IF v_active THEN\n' ||
           E'    v_action_state := v_combat->\'action_economy\';\n' ||
           E'    IF jsonb_typeof(v_action_state)=\'object\' AND COALESCE(v_action_state->>\'round\',\'\')=v_round::TEXT AND jsonb_typeof(v_action_state->\'by_character\')=\'object\' THEN\n' ||
           E'      v_by_character := v_action_state->\'by_character\';\n' ||
           E'    ELSE v_by_character := \'{}\'::JSONB; END IF;\n' ||
           E'    v_character_actions := CASE WHEN jsonb_typeof(v_by_character->v_character_id)=\'object\' THEN v_by_character->v_character_id ELSE \'{}\'::JSONB END;\n' ||
           E'    IF COALESCE(v_character_actions->>\'movimento\',\'false\')=\'true\' AND v_used_squares=0 THEN RAISE EXCEPTION \'A ação de movimento deste personagem já foi usada neste turno.\'; END IF;\n' ||
           E'    IF priv.srd_condition_has_flag(p_campaign_id,\'character\',v_character_id,\'one_move_or_standard\') AND COALESCE(v_character_actions->>\'padrao\',\'false\')=\'true\' THEN RAISE EXCEPTION \'A condição permite apenas uma ação padrão ou de movimento por rodada.\'; END IF;\n' ||
           E'    v_character_actions := v_character_actions || jsonb_build_object(\'movimento\',TRUE);\n' ||
           E'    v_by_character := jsonb_set(v_by_character,ARRAY[v_character_id],v_character_actions,TRUE);\n' ||
           E'    v_action_state := jsonb_build_object(\'round\',v_round,\'by_character\',v_by_character);\n' ||
           E'    v_combat := v_combat || jsonb_build_object(\'action_economy\',v_action_state);\n' ||
           E'  END IF;\n\n' ||
           E'  v_new_token := v_entry || jsonb_build_object(\'gridX\', p_grid_x, \'gridY\', p_grid_y);';
  IF strpos(v_def, v_old) = 0 THEN
    RAISE EXCEPTION 'Patch abortado: ponto de gravação da posição não encontrado.';
  END IF;
  v_def := replace(v_def, v_old, v_new);

  EXECUTE v_def;
END
$patch$;
