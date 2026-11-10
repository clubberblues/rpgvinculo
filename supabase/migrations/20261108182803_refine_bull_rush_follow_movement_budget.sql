
DO $migration$
DECLARE
  v_definition text;
  v_old text := 'v_follow_remaining_ft:=least(remaining_push_ft,v_available_move_ft);';
  v_new text := 'v_follow_remaining_ft:=v_available_move_ft;';
  v_old_guard text := $old$IF p_follow
       AND NOT priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'no_move')
       AND NOT (priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'no_actions')
                AND NOT priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'flee')) THEN$old$;
  v_new_guard text := $new$IF p_follow
       AND NOT priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'no_move')
       AND NOT (priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'no_actions')
                AND NOT priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'flee'))
       AND NOT (a->>'tipo'='player' AND priv.srd_condition_has_flag(p_campaign_id,'character',vkey,'no_move'))
       AND NOT (a->>'tipo'='player'
                AND priv.srd_condition_has_flag(p_campaign_id,'character',vkey,'no_actions')
                AND NOT priv.srd_condition_has_flag(p_campaign_id,'character',vkey,'flee')) THEN$new$;
BEGIN
  SELECT pg_get_functiondef('priv.srd_resolver_encontrao_srd(bigint,uuid,integer,integer,boolean)'::regprocedure)
    INTO v_definition;
  IF position(v_old in v_definition)=0 OR position(v_old_guard in v_definition)=0 THEN
    RAISE EXCEPTION 'Trecho esperado não encontrado; migration abortada sem alteração.';
  END IF;
  v_definition:=replace(v_definition,v_old,v_new);
  v_definition:=replace(v_definition,v_old_guard,v_new_guard);
  EXECUTE v_definition;
END;
$migration$;
