
CREATE OR REPLACE FUNCTION priv.srd_restore_surprised_flatfooted(
 p_campaign_id bigint,p_turn_order jsonb,p_aware_ids text[]
) RETURNS integer
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $fn$
DECLARE v_entry jsonb;v_id text;v_kind text;v_count integer:=0;
BEGIN
 FOR v_entry IN SELECT value FROM jsonb_array_elements(coalesce(p_turn_order,'[]'::jsonb)) q(value)
 LOOP
  v_id:=nullif(btrim(v_entry->>'id'),'');
  IF v_id IS NULL OR v_id=ANY(coalesce(p_aware_ids,ARRAY[]::text[])) THEN CONTINUE; END IF;
  v_kind:=CASE WHEN coalesce((v_entry->>'is_monster')::boolean,false) THEN 'token' ELSE 'character' END;
  IF NOT EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=p_campaign_id
    AND cc.target_kind=v_kind AND cc.target_id=v_id AND cc.condition_id='flatfooted'
    AND cc.active=true AND cc.notes->>'source_feature'='combat_flatfooted') THEN
   INSERT INTO public.srd_campaign_conditions(campaign_id,target_kind,target_id,condition_id,source_actor_id,started_round,active,notes)
   VALUES(p_campaign_id,v_kind,v_id,'flatfooted',null,1,true,
    jsonb_build_object('source_feature','combat_flatfooted','rule','until_first_normal_turn','surprise_round',true));
   v_count:=v_count+1;
  END IF;
 END LOOP;
 RETURN v_count;
END;
$fn$;
REVOKE ALL ON FUNCTION priv.srd_restore_surprised_flatfooted(bigint,jsonb,text[]) FROM PUBLIC,anon,authenticated;

DO $patch$
DECLARE v_def text;v_marker text;v_new text;
BEGIN
 SELECT pg_get_functiondef('public.srd_configurar_rodada_surpresa_srd(bigint,text[])'::regprocedure) INTO v_def;
 v_marker:=' v_first:=CASE WHEN jsonb_array_length(v_indices)>0 THEN (v_indices->>0)::integer ELSE 0 END;'||E'\n';
 IF position(v_marker in v_def)=0 THEN RAISE EXCEPTION 'Ponto para restaurar Desprevenido não encontrado.'; END IF;
 v_new:=replace(v_def,v_marker,' PERFORM priv.srd_restore_surprised_flatfooted(p_campaign_id,v_order,v_aware);'||E'\n'||v_marker);
 EXECUTE v_new;
END;
$patch$;

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
 IF p_action NOT IN ('padrao','movimento') THEN
  RAISE EXCEPTION 'Na rodada surpresa, somente uma ação padrão ou uma ação de movimento é permitida.';
 END IF;
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
END;
$fn$;
REVOKE ALL ON FUNCTION priv.srd_validate_surprise_action(bigint,text,text) FROM PUBLIC,anon,authenticated;
