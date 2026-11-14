
DO $migration$
DECLARE v_def text;v_old text;v_new text;v_count integer;
BEGIN
 v_def:=pg_get_functiondef('public.srd_resolve_npc_dying_round(bigint,text,integer)'::regprocedure);
 v_old:=$old$IF COALESCE(NULLIF(v_condition.notes->>'last_resolved_round','')::integer,0)>=v_round THEN
    RAISE EXCEPTION 'A estabilização deste NPC já foi resolvida nesta rodada.';
  END IF;$old$;
 v_new:=$new$IF UPPER(COALESCE(v_campaign.state,''))='COMBATE'
     AND COALESCE(v_campaign.combat_data->>'active','false')='true'
     AND COALESCE(NULLIF(v_condition.notes->>'last_resolved_round','')::integer,0)>=v_round THEN
    RAISE EXCEPTION 'A estabilização deste NPC já foi resolvida nesta rodada.';
  END IF;$new$;
 v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
 IF v_count<>1 THEN RAISE EXCEPTION 'Trava de uma rolagem por rodada não é única: %.',v_count; END IF;
 EXECUTE replace(v_def,v_old,v_new);
END;
$migration$;
