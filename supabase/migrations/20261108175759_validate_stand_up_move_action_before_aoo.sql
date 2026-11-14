
DO $patch$
DECLARE v_def text;
BEGIN
  v_def:=pg_get_functiondef('priv.srd_iniciar_levantar_caido_srd(bigint,text)'::regprocedure);
  v_def:=replace(v_def,
    '  v_token_id text; v_profile jsonb; v_character_id text;',
    '  v_token_id text; v_profile jsonb; v_character_id text; v_action_state jsonb; v_by jsonb; v_actions jsonb;'
  );
  v_def:=replace(v_def,
    $old$  SELECT coalesce(jsonb_agg(jsonb_build_object(
    'reactor_token_id',coalesce(x->>'token_id',x->>'token_key'),$old$,
    $new$  v_action_state:=v_campaign.combat_data->'action_economy';
  IF jsonb_typeof(v_action_state)='object'
     AND coalesce(v_action_state->>'round','')=v_round::text
     AND jsonb_typeof(v_action_state->'by_character')='object' THEN
    v_by:=v_action_state->'by_character';
  ELSE v_by:='{}'::jsonb; END IF;
  v_actions:=CASE WHEN jsonb_typeof(v_by->btrim(p_token_id))='object'
    THEN v_by->btrim(p_token_id) ELSE '{}'::jsonb END;
  IF coalesce((v_actions->>'movimento')::boolean,false) THEN
    RAISE EXCEPTION 'A ação de movimento já foi usada nesta rodada.';
  END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'one_move_or_standard')
     AND coalesce((v_actions->>'padrao')::boolean,false) THEN
    RAISE EXCEPTION 'As condições não permitem levantar-se depois de uma ação padrão nesta rodada.';
  END IF;

  SELECT coalesce(jsonb_agg(jsonb_build_object(
    'reactor_token_id',coalesce(x->>'token_id',x->>'token_key'),$new$
  );
  IF position('A ação de movimento já foi usada nesta rodada.' in v_def)=0 THEN
    RAISE EXCEPTION 'Não foi possível validar a ação de movimento antes de iniciar as reações.';
  END IF;
  EXECUTE v_def;
END;
$patch$;
