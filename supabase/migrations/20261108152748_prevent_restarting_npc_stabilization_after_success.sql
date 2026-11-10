
DO $migration$
DECLARE v_def text;v_anchor text;v_insert text;v_count integer;
BEGIN
 v_def:=pg_get_functiondef('public.srd_resolve_npc_dying_round(bigint,text,integer)'::regprocedure);
 v_anchor:='  PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_hp,v_max_hp,false);';
 v_insert:=$code$
  IF EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
    WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token'
      AND cc.target_id IN (v_actual_id,COALESCE(NULLIF(v_token->>'key',''),v_actual_id))
      AND cc.condition_id='stable' AND cc.active=true) THEN
    RAISE EXCEPTION 'Este NPC já está estabilizado e não precisa de nova rolagem D100.';
  END IF;
$code$||v_anchor;
 v_count:=(length(v_def)-length(replace(v_def,v_anchor,'')))/length(v_anchor);
 IF v_count<>1 THEN RAISE EXCEPTION 'Ponto de proteção contra nova rolagem de NPC estável não é único: %.',v_count; END IF;
 EXECUTE replace(v_def,v_anchor,v_insert);
END;
$migration$;
