DO $patch$
DECLARE v_def TEXT; v_old TEXT; v_new TEXT;
BEGIN
  v_def := pg_get_functiondef('public.mover_token_player_cba(bigint,text,integer,integer)'::regprocedure);
  IF position('NOT priv.srd_condition_has_flag(p_campaign_id,''character'',v_character_id,''flee'')' in v_def)=0 THEN
    v_old := E'  IF priv.srd_condition_has_flag(p_campaign_id,\'character\',v_character_id,\'no_move\') THEN RAISE EXCEPTION \'A condição atual impede movimentação.\'; END IF;';
    v_new := E'  IF priv.srd_condition_has_flag(p_campaign_id,\'character\',v_character_id,\'no_move\') OR (priv.srd_condition_has_flag(p_campaign_id,\'character\',v_character_id,\'no_actions\') AND NOT priv.srd_condition_has_flag(p_campaign_id,\'character\',v_character_id,\'flee\')) THEN RAISE EXCEPTION \'A condição atual impede movimentação.\'; END IF;';
    IF strpos(v_def,v_old)=0 THEN RAISE EXCEPTION 'Não foi encontrado o bloqueio de movimento do jogador.'; END IF;
    EXECUTE replace(v_def,v_old,v_new);
  END IF;
  v_def := pg_get_functiondef('public.mover_token_gm_cba_srd(bigint,text,integer,integer)'::regprocedure);
  IF position('NOT priv.srd_condition_has_flag(p_campaign_id,''token'',BTRIM(p_token_id),''flee'')' in v_def)=0 THEN
    v_old := E'IF priv.srd_condition_has_flag(p_campaign_id,\'token\',BTRIM(p_token_id),\'no_move\') THEN';
    v_new := E'IF priv.srd_condition_has_flag(p_campaign_id,\'token\',BTRIM(p_token_id),\'no_move\') OR (priv.srd_condition_has_flag(p_campaign_id,\'token\',BTRIM(p_token_id),\'no_actions\') AND NOT priv.srd_condition_has_flag(p_campaign_id,\'token\',BTRIM(p_token_id),\'flee\')) THEN';
    IF strpos(v_def,v_old)=0 THEN RAISE EXCEPTION 'Não foi encontrado o bloqueio de movimento de token.'; END IF;
    v_def := replace(v_def,v_old,v_new);
  END IF;
  IF position('NOT priv.srd_condition_has_flag(p_campaign_id,''character'',BTRIM(p_token_id),''flee'')' in v_def)=0 THEN
    v_old := E'IF priv.srd_condition_has_flag(p_campaign_id,\'character\',BTRIM(p_token_id),\'no_move\') THEN';
    v_new := E'IF priv.srd_condition_has_flag(p_campaign_id,\'character\',BTRIM(p_token_id),\'no_move\') OR (priv.srd_condition_has_flag(p_campaign_id,\'character\',BTRIM(p_token_id),\'no_actions\') AND NOT priv.srd_condition_has_flag(p_campaign_id,\'character\',BTRIM(p_token_id),\'flee\')) THEN';
    IF strpos(v_def,v_old)=0 THEN RAISE EXCEPTION 'Não foi encontrado o bloqueio de movimento do token de personagem.'; END IF;
    v_def := replace(v_def,v_old,v_new);
  END IF;
  EXECUTE v_def;
END
$patch$;