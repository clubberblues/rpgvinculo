
CREATE OR REPLACE FUNCTION priv.srd_validate_surprise_action(
 p_campaign_id bigint,p_actor_id text,p_action text
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $fn$
DECLARE
 v_combat jsonb;v_surprise jsonb;v_order jsonb;v_idx integer;v_actor jsonb;v_aware jsonb;
 v_used jsonb;v_economy jsonb;v_by_actor jsonb;v_movement jsonb;
BEGIN
 SELECT combat_data INTO v_combat FROM public.campaigns WHERE id=p_campaign_id;
 v_surprise:=coalesce(v_combat->'surprise','{}'::jsonb);
 IF coalesce(v_surprise->>'phase','')<>'surprise_round' THEN RETURN; END IF;
 v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::jsonb END;
 IF coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN RAISE EXCEPTION 'Turno da rodada surpresa inválido.'; END IF;
 v_idx:=(v_combat->>'current_turn')::integer;
 IF v_idx<0 OR v_idx>=jsonb_array_length(v_order) THEN RAISE EXCEPTION 'Índice do turno inválido na rodada surpresa.'; END IF;
 v_actor:=v_order->v_idx;
 IF v_actor->>'id' IS DISTINCT FROM btrim(p_actor_id) THEN RAISE EXCEPTION 'Somente o participante ativo pode agir na rodada surpresa.'; END IF;
 v_aware:=CASE WHEN jsonb_typeof(v_surprise->'aware_ids')='array' THEN v_surprise->'aware_ids' ELSE '[]'::jsonb END;
 IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements_text(v_aware) x(id) WHERE x.id=btrim(p_actor_id)) THEN
  RAISE EXCEPTION 'Este participante foi surpreendido e não pode agir na rodada surpresa.';
 END IF;
 IF p_action='rodada_completa' THEN RAISE EXCEPTION 'A rodada surpresa não permite ações de rodada completa.'; END IF;
 IF p_action IN ('padrao','movimento') THEN
  v_economy:=v_combat->'action_economy';
  v_by_actor:=CASE WHEN jsonb_typeof(v_economy->'by_character')='object' THEN v_economy->'by_character' ELSE '{}'::jsonb END;
  v_used:=v_by_actor->btrim(p_actor_id);
  IF jsonb_typeof(v_used)='object' AND
    (coalesce(v_used->>'padrao','false')='true' OR coalesce(v_used->>'movimento','false')='true') THEN
    RAISE EXCEPTION 'Na rodada surpresa, cada participante consciente pode realizar somente uma ação padrão ou de movimento.';
  END IF;
  v_movement:=v_combat->'movement_usage';
  IF p_action='padrao' AND jsonb_typeof(v_movement)='object'
    AND v_movement->>'character_id'=btrim(p_actor_id)
    AND coalesce(v_movement->>'moved_squares','0') ~ '^[0-9]+$'
    AND (v_movement->>'moved_squares')::integer>0 THEN
    RAISE EXCEPTION 'O participante já utilizou sua ação de movimento na rodada surpresa.';
  END IF;
 END IF;
END;
$fn$;
REVOKE ALL ON FUNCTION priv.srd_validate_surprise_action(bigint,text,text) FROM PUBLIC,anon,authenticated;

DO $patch$
DECLARE v_sig regprocedure;v_def text;v_marker text;v_new text;
BEGIN
 FOREACH v_sig IN ARRAY ARRAY[
  'public.mover_token_player_cba(bigint,text,integer,integer)'::regprocedure,
  'public.mover_token_gm_cba_srd(bigint,text,integer,integer)'::regprocedure
 ] LOOP
  SELECT pg_get_functiondef(v_sig) INTO v_def;
  IF v_sig::text LIKE '%mover_token_player_cba%' THEN
   v_marker:='    v_entry := v_order->v_current_turn;'||E'\n';
   IF position(v_marker in v_def)=0 THEN RAISE EXCEPTION 'Ponto de integração ausente em %',v_sig; END IF;
   v_new:=replace(v_def,v_marker,v_marker||E'    PERFORM priv.srd_validate_surprise_action(p_campaign_id,BTRIM(p_character_id),''movimento'');\n');
  ELSE
   v_marker:='  v_actor := v_order->v_current_turn;'||E'\n';
   IF position(v_marker in v_def)=0 THEN RAISE EXCEPTION 'Ponto de integração ausente em %',v_sig; END IF;
   v_new:=replace(v_def,v_marker,v_marker||E'  PERFORM priv.srd_validate_surprise_action(p_campaign_id,BTRIM(p_token_id),''movimento'');\n');
  END IF;
  EXECUTE v_new;
 END LOOP;
END;
$patch$;
