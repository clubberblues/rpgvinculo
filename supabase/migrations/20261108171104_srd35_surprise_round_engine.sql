
CREATE OR REPLACE FUNCTION priv.srd_validate_surprise_action(
  p_campaign_id bigint, p_actor_id text, p_action text
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $fn$
DECLARE v_combat jsonb; v_surprise jsonb; v_order jsonb; v_idx integer; v_actor jsonb; v_aware jsonb; v_used jsonb;
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
   v_used:=coalesce(v_surprise->'actions_used','{}'::jsonb)->btrim(p_actor_id);
   IF jsonb_typeof(v_used)='object' AND
      (coalesce(v_used->>'padrao','false')='true' OR coalesce(v_used->>'movimento','false')='true') THEN
     RAISE EXCEPTION 'Na rodada surpresa, cada participante consciente pode realizar somente uma ação padrão ou de movimento.';
   END IF;
 END IF;
END;
$fn$;
REVOKE ALL ON FUNCTION priv.srd_validate_surprise_action(bigint,text,text) FROM PUBLIC,anon,authenticated;

CREATE OR REPLACE FUNCTION public.srd_configurar_rodada_surpresa_srd(
 p_campaign_id bigint, p_aware_ids text[]
) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $fn$
DECLARE v_campaign public.campaigns%rowtype; v_order jsonb; v_aware text[]; v_indices jsonb; v_first integer; v_surprise jsonb; v_first_actor jsonb;
BEGIN
 IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
   RAISE EXCEPTION 'Somente o Mestre autenticado pode configurar a rodada surpresa.';
 END IF;
 SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
 IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE' THEN RAISE EXCEPTION 'A campanha não está em combate.'; END IF;
 IF coalesce((v_campaign.combat_data->>'active')::boolean,false) IS NOT TRUE THEN RAISE EXCEPTION 'A iniciativa precisa estar concluída antes de configurar a rodada surpresa.'; END IF;
 IF coalesce(v_campaign.combat_data->'surprise'->>'phase','') NOT IN ('','not_started') THEN RAISE EXCEPTION 'A rodada surpresa já foi configurada.'; END IF;
 v_order:=CASE WHEN jsonb_typeof(v_campaign.combat_data->'turn_order')='array' THEN v_campaign.combat_data->'turn_order' ELSE '[]'::jsonb END;
 IF jsonb_array_length(v_order)=0 THEN RAISE EXCEPTION 'A ordem de iniciativa está vazia.'; END IF;
 SELECT coalesce(array_agg(distinct btrim(x) order by btrim(x)),ARRAY[]::text[]) INTO v_aware
 FROM unnest(coalesce(p_aware_ids,ARRAY[]::text[])) x WHERE nullif(btrim(x),'') IS NOT NULL;
 IF EXISTS(SELECT 1 FROM unnest(v_aware) a(id) WHERE NOT EXISTS(
   SELECT 1 FROM jsonb_array_elements(v_order) e(entry) WHERE e.entry->>'id'=a.id
 )) THEN RAISE EXCEPTION 'A lista de participantes conscientes contém alguém fora da iniciativa.'; END IF;
 SELECT coalesce(jsonb_agg(e.ordinality-1 ORDER BY e.ordinality),'[]'::jsonb)
 INTO v_indices
 FROM jsonb_array_elements(v_order) WITH ORDINALITY e(entry,ordinality)
 WHERE e.entry->>'id'=ANY(v_aware);
 v_first:=CASE WHEN jsonb_array_length(v_indices)>0 THEN (v_indices->>0)::integer ELSE 0 END;
 v_surprise:=jsonb_build_object(
   'phase',CASE WHEN cardinality(v_aware)>0 THEN 'surprise_round' ELSE 'normal' END,
   'aware_ids',to_jsonb(v_aware),
   'order_indices',v_indices,
   'cursor',0,
   'actions_used','{}'::jsonb,
   'configured_by',auth.uid(),
   'configured_at',now()
 );
 IF cardinality(v_aware)>0 THEN
   UPDATE public.campaigns SET combat_data=combat_data||
     jsonb_build_object('surprise',v_surprise,'current_turn',v_first,'round',0)
   WHERE id=p_campaign_id RETURNING combat_data INTO v_campaign.combat_data;
   v_first_actor:=v_order->v_first;
   PERFORM priv.srd_clear_combat_flatfooted_actor(p_campaign_id,v_first_actor);
 ELSE
   -- Sem participantes conscientes, a rodada surpresa é ignorada; todos permanecem desprevenidos.
   v_first_actor:=v_order->0;
   IF NOT EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
     WHERE cc.campaign_id=p_campaign_id AND cc.target_kind=
       CASE WHEN coalesce((v_first_actor->>'is_monster')::boolean,false) THEN 'token' ELSE 'character' END
       AND cc.target_id=v_first_actor->>'id' AND cc.condition_id='flatfooted'
       AND cc.active=true AND cc.notes->>'source_feature'='combat_flatfooted') THEN
     INSERT INTO public.srd_campaign_conditions(campaign_id,target_kind,target_id,condition_id,started_round,active,notes)
     VALUES(p_campaign_id,CASE WHEN coalesce((v_first_actor->>'is_monster')::boolean,false) THEN 'token' ELSE 'character' END,
       v_first_actor->>'id','flatfooted',1,true,jsonb_build_object('source_feature','combat_flatfooted','rule','until_first_turn'));
   END IF;
   UPDATE public.campaigns SET combat_data=combat_data||
     jsonb_build_object('surprise',v_surprise,'current_turn',0,'round',1)
   WHERE id=p_campaign_id RETURNING combat_data INTO v_campaign.combat_data;
 END IF;
 RETURN v_campaign.combat_data;
END;
$fn$;
REVOKE ALL ON FUNCTION public.srd_configurar_rodada_surpresa_srd(bigint,text[]) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.srd_configurar_rodada_surpresa_srd(bigint,text[]) TO authenticated;

DO $patch$
DECLARE v_def text; v_new text; v_marker text;
BEGIN
 SELECT pg_get_functiondef('public.avancar_turno(bigint)'::regprocedure) INTO v_def;
 v_marker:='  v_entry := v_order->v_current;'||E'\n';
 IF position(v_marker in v_def)=0 THEN RAISE EXCEPTION 'Não foi possível localizar ponto seguro para integrar rodada surpresa em avancar_turno.'; END IF;
 v_new:=replace(v_def,v_marker,v_marker||E'
  -- Rodada surpresa: somente participantes conscientes recebem turno nesta fase.
  IF coalesce(v_data->''surprise''->>''phase'','''')=''surprise_round'' THEN
    DECLARE v_indices jsonb; v_cursor integer; v_next_index integer; v_surprise jsonb; v_actor jsonb;
    BEGIN
      v_surprise:=v_data->''surprise'';
      v_indices:=CASE WHEN jsonb_typeof(v_surprise->''order_indices'')=''array'' THEN v_surprise->''order_indices'' ELSE ''[]''::jsonb END;
      v_cursor:=coalesce(nullif(v_surprise->>''cursor'','''')::integer,0)+1;
      IF v_cursor<jsonb_array_length(v_indices) THEN
        v_next_index:=(v_indices->>v_cursor)::integer;
        v_actor:=v_order->v_next_index;
        v_surprise:=v_surprise||jsonb_build_object(''cursor'',v_cursor);
        v_next_data:=v_data||jsonb_build_object(''surprise'',v_surprise,''current_turn'',v_next_index,''round'',0,''active'',true);
        UPDATE public.campaigns SET combat_data=v_next_data WHERE id=p_campaign_id;
        PERFORM priv.srd_clear_combat_flatfooted_actor(p_campaign_id,v_actor);
        RETURN v_next_data;
      ELSE
        v_surprise:=v_surprise||jsonb_build_object(''phase'',''normal'',''completed_at'',now());
        v_next_data:=v_data||jsonb_build_object(''surprise'',v_surprise,''current_turn'',0,''round'',1,''active'',true);
        UPDATE public.campaigns SET combat_data=v_next_data WHERE id=p_campaign_id;
        v_actor:=v_order->0;
        PERFORM priv.srd_clear_combat_flatfooted_actor(p_campaign_id,v_actor);
        RETURN v_next_data;
      END IF;
    END;
  END IF;
');
 EXECUTE v_new;
END;
$patch$;

DO $patch$
DECLARE v_sig regprocedure; v_def text; v_marker text; v_new text;
BEGIN
 FOREACH v_sig IN ARRAY ARRAY[
  'public.consumir_acao_turno_srd(bigint,text,text)'::regprocedure,
  'public.consumir_acao_token_gm_srd(bigint,text,text)'::regprocedure
 ] LOOP
  SELECT pg_get_functiondef(v_sig) INTO v_def;
  IF v_sig::text LIKE '%consumir_acao_turno_srd%' THEN
    v_marker:='  v_actor := v_order->v_current_turn;'||E'\n';
    IF position(v_marker in v_def)=0 THEN RAISE EXCEPTION 'Ponto de integração ausente em %',v_sig; END IF;
    v_new:=replace(v_def,v_marker,v_marker||E'  PERFORM priv.srd_validate_surprise_action(p_campaign_id,BTRIM(p_character_id),v_action);\n');
  ELSE
    v_marker:=' v_actor:=v_order->(v_combat->>''current_turn'')::integer;'||E'\n';
    IF position(v_marker in v_def)=0 THEN RAISE EXCEPTION 'Ponto de integração ausente em %',v_sig; END IF;
    v_new:=replace(v_def,v_marker,v_marker||E' PERFORM priv.srd_validate_surprise_action(p_campaign_id,btrim(p_token_id),v_action);\n');
  END IF;
  EXECUTE v_new;
 END LOOP;
END;
$patch$;

DO $patch$
DECLARE v_def text; v_marker text; v_new text;
BEGIN
 SELECT pg_get_functiondef('public.consumir_acao_rodada_completa_srd(bigint,text,text)'::regprocedure) INTO v_def;
 v_marker:='  v_actor := v_order->v_current_turn;'||E'\n';
 IF position(v_marker in v_def)=0 THEN RAISE EXCEPTION 'Ponto de integração ausente para ação de rodada completa.'; END IF;
 v_new:=replace(v_def,v_marker,v_marker||E'  PERFORM priv.srd_validate_surprise_action(p_campaign_id,BTRIM(p_actor_id),''rodada_completa'');\n');
 EXECUTE v_new;
END;
$patch$;
