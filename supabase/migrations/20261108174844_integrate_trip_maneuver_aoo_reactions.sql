
CREATE OR REPLACE FUNCTION public.srd_iniciar_derrubar_com_aoo_srd(
  p_campaign_id bigint,
  p_attacker_token_id text,
  p_defender_token_id text,
  p_defender_firm_ground boolean DEFAULT false,
  p_trip_using_weapon boolean DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, pg_temp
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_combat jsonb;
  v_order jsonb;
  v_actor jsonb;
  v_calc jsonb;
  v_attacker jsonb;
  v_defender jsonb;
  v_round integer;
  v_turn integer;
  v_pending_id uuid:=gen_random_uuid();
  v_distance integer;
  v_reach integer;
  v_reaction_status text:='waiting';
  v_trigger text;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode preparar a reação de Derrubar.';
  END IF;
  IF NULLIF(BTRIM(p_attacker_token_id),'') IS NULL OR NULLIF(BTRIM(p_defender_token_id),'') IS NULL
     OR BTRIM(p_attacker_token_id)=BTRIM(p_defender_token_id) THEN
    RAISE EXCEPTION 'Atacante e defensor precisam ser tokens diferentes.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE'
     OR coalesce(v_campaign.combat_data->>'active','false')<>'true' THEN
    RAISE EXCEPTION 'A iniciativa precisa estar ativa.';
  END IF;
  v_combat:=v_campaign.combat_data;
  IF coalesce(v_combat->'surprise'->>'phase','normal')='surprise_round' THEN
    RAISE EXCEPTION 'Derrubar não pode ser iniciado durante a rodada surpresa.';
  END IF;
  IF coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'Turno atual inválido.';
  END IF;
  v_turn:=(v_combat->>'current_turn')::integer;
  v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::jsonb END;
  v_actor:=v_order->v_turn;
  IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_attacker_token_id) THEN
    RAISE EXCEPTION 'O atacante precisa estar no turno ativo.';
  END IF;
  IF EXISTS (SELECT 1 FROM priv.srd_aoo_pending_movements
    WHERE campaign_id=p_campaign_id AND status IN ('waiting_reactions','ready_to_commit')) THEN
    RAISE EXCEPTION 'Já existe outra reação de oportunidade pendente nesta campanha.';
  END IF;
  v_calc:=public.srd_consultar_modificadores_manobra_srd(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,'trip',
    coalesce(p_defender_firm_ground,false),coalesce(p_trip_using_weapon,false)
  );
  IF v_calc->>'aoo_status'<>'provokes' THEN
    RAISE EXCEPTION 'Esta tentativa não exige a fila de reação de Derrubar; consulte os modificadores e resolva pelo fluxo normal.';
  END IF;
  SELECT t INTO v_attacker FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
   WHERE t->>'id'=BTRIM(p_attacker_token_id) OR t->>'key'=BTRIM(p_attacker_token_id) LIMIT 1;
  SELECT t INTO v_defender FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
   WHERE t->>'id'=BTRIM(p_defender_token_id) OR t->>'key'=BTRIM(p_defender_token_id) LIMIT 1;
  IF v_attacker IS NULL OR v_defender IS NULL THEN RAISE EXCEPTION 'Atacante ou defensor não está na cena.'; END IF;
  IF coalesce(v_attacker->>'gridX','') !~ '^[0-9]{1,3}$' OR coalesce(v_attacker->>'gridY','') !~ '^[0-9]{1,3}$'
     OR coalesce(v_defender->>'gridX','') !~ '^[0-9]{1,3}$' OR coalesce(v_defender->>'gridY','') !~ '^[0-9]{1,3}$' THEN
    RAISE EXCEPTION 'A posição de um dos tokens não é válida para medir alcance.';
  END IF;
  v_distance:=priv.srd_grid_footprint_distance_ft(
    (v_defender->>'gridX')::integer,(v_defender->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_defender_token_id),
    (v_attacker->>'gridX')::integer,(v_attacker->>'gridY')::integer,
    priv.srd_token_grid_footprint(p_campaign_id,p_attacker_token_id)
  );
  v_reach:=coalesce(nullif(v_defender->>'melee_reach_ft','')::integer,5);
  IF v_distance>v_reach THEN v_reaction_status:='ineligible'; END IF;
  v_round:=greatest(1,coalesce(nullif(v_combat->>'round','')::integer,1));
  v_trigger:='trip:'||v_pending_id::text;
  INSERT INTO priv.srd_aoo_pending_movements(
    pending_id,campaign_id,mover_token_id,movement_controller,destination_x,destination_y,
    origin_x,origin_y,combat_round,current_turn,turn_actor_id,threats,pending_reactions,
    status,created_by
  ) VALUES (
    v_pending_id,p_campaign_id,BTRIM(p_attacker_token_id),'gm',
    (v_attacker->>'gridX')::integer,(v_attacker->>'gridY')::integer,
    (v_attacker->>'gridX')::integer,(v_attacker->>'gridY')::integer,
    v_round,v_turn,BTRIM(p_attacker_token_id),
    jsonb_build_array(jsonb_build_object('maneuver_event','trip','defender_token_id',BTRIM(p_defender_token_id),'distance_ft',v_distance,'reach_ft',v_reach)),
    jsonb_build_array(jsonb_build_object(
      'reactor_token_id',BTRIM(p_defender_token_id),'trigger_key',v_trigger,
      'status',v_reaction_status,'threat',jsonb_build_object('last_threatened_step',0,'maneuver_event','trip')
    )),
    'waiting_reactions',auth.uid()
  );
  RETURN jsonb_build_object('pending',true,'pending_id',v_pending_id,'maneuver','trip',
    'attacker_token_id',BTRIM(p_attacker_token_id),'defender_token_id',BTRIM(p_defender_token_id),
    'reaction_status',v_reaction_status,'distance_ft',v_distance,'reach_ft',v_reach);
END;
$function$;

REVOKE ALL ON FUNCTION public.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean) TO authenticated;

DO $patch$
DECLARE
  v_def text;
  v_old text;
  v_new text;
BEGIN
  v_def:=pg_get_functiondef('priv.srd_resolver_derrubar_srd(bigint,text,text,integer,integer,boolean,boolean,boolean)'::regprocedure);
  v_old:= $old$  IF coalesce(v_calc->>'aoo_status','')='provokes' THEN
    RAISE EXCEPTION 'Esta tentativa provoca ataque de oportunidade. Resolva primeiro a reação do defensor; a resolução integrada de AOO para manobras ainda não está disponível.';
  END IF;
  IF coalesce(v_calc->>'aoo_status','') NOT IN ('not_provoked_by_armed_trip','suppressed_by_feat') THEN
    RAISE EXCEPTION 'Não foi possível confirmar que a tentativa não provoca ataque de oportunidade.';
  END IF;$old$;
  v_new:= $new$  IF coalesce(v_calc->>'aoo_status','')='provokes' THEN
    IF NULLIF(current_setting('app.srd_trip_aoo_pending_id',true),'') IS NULL THEN
      RAISE EXCEPTION 'Esta tentativa provoca ataque de oportunidade; resolva a reação do defensor primeiro.';
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM priv.srd_aoo_pending_movements p
      WHERE p.pending_id=current_setting('app.srd_trip_aoo_pending_id',true)::uuid
        AND p.campaign_id=p_campaign_id AND p.mover_token_id=BTRIM(p_attacker_token_id)
        AND p.status='waiting_reactions'
        AND p.threats @> jsonb_build_array(jsonb_build_object('maneuver_event','trip','defender_token_id',BTRIM(p_defender_token_id)))
        AND NOT EXISTS (
          SELECT 1 FROM jsonb_array_elements(p.pending_reactions) r
          WHERE r->>'status' IN ('waiting','reserved','attack_started','hit_pending_damage')
        )
    ) THEN
      RAISE EXCEPTION 'A reação de oportunidade ainda não foi concluída ou não corresponde a esta manobra.';
    END IF;
  END IF;
  IF coalesce(v_calc->>'aoo_status','') NOT IN ('not_provoked_by_armed_trip','suppressed_by_feat','provokes') THEN
    RAISE EXCEPTION 'Não foi possível confirmar a situação do ataque de oportunidade.';
  END IF;$new$;
  IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Não foi possível localizar a validação AOO original para atualizar.'; END IF;
  v_def:=replace(v_def,v_old,v_new);
  v_old:=$old$  RETURN jsonb_build_object(
    'ok',true,'resolved',true,'maneuver','trip','success',v_success,$old$;
  v_new:=$new$  IF NULLIF(current_setting('app.srd_trip_aoo_pending_id',true),'') IS NOT NULL THEN
    UPDATE priv.srd_aoo_pending_movements SET status='committed',committed_at=now(),updated_at=now()
    WHERE pending_id=current_setting('app.srd_trip_aoo_pending_id',true)::uuid
      AND campaign_id=p_campaign_id AND status='waiting_reactions';
  END IF;
  RETURN jsonb_build_object(
    'ok',true,'resolved',true,'maneuver','trip','success',v_success,$new$;
  IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Não foi possível localizar o retorno final para marcar a reação concluída.'; END IF;
  v_def:=replace(v_def,v_old,v_new);
  EXECUTE v_def;
END;
$patch$;

CREATE OR REPLACE FUNCTION public.srd_resolver_derrubar_apos_aoo_srd(
  p_campaign_id bigint,
  p_pending_id uuid,
  p_attacker_d20 integer,
  p_defender_d20 integer,
  p_defender_firm_ground boolean DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY INVOKER
SET search_path = public, pg_temp
AS $function$
DECLARE v_pending priv.srd_aoo_pending_movements%ROWTYPE; v_defender text; v_result jsonb;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode concluir Derrubar após a reação.';
  END IF;
  SELECT * INTO v_pending FROM priv.srd_aoo_pending_movements
   WHERE campaign_id=p_campaign_id AND pending_id=p_pending_id FOR UPDATE;
  IF NOT FOUND OR v_pending.status<>'waiting_reactions'
     OR NOT (v_pending.threats @> jsonb_build_array(jsonb_build_object('maneuver_event','trip'))) THEN
    RAISE EXCEPTION 'Evento de Derrubar aguardando reação não encontrado.';
  END IF;
  IF EXISTS (SELECT 1 FROM jsonb_array_elements(v_pending.pending_reactions) r
    WHERE r->>'status' IN ('waiting','reserved','attack_started','hit_pending_damage')) THEN
    RAISE EXCEPTION 'Ainda existem reações de oportunidade não resolvidas.';
  END IF;
  v_defender:=v_pending.pending_reactions->0->>'reactor_token_id';
  PERFORM set_config('app.srd_trip_aoo_pending_id',p_pending_id::text,true);
  v_result:=public.srd_resolver_derrubar_srd(
    p_campaign_id,v_pending.mover_token_id,v_defender,p_attacker_d20,p_defender_d20,
    false,p_defender_firm_ground,false
  );
  PERFORM set_config('app.srd_trip_aoo_pending_id','',true);
  RETURN v_result;
EXCEPTION WHEN OTHERS THEN
  PERFORM set_config('app.srd_trip_aoo_pending_id','',true);
  RAISE;
END;
$function$;

REVOKE ALL ON FUNCTION public.srd_resolver_derrubar_apos_aoo_srd(bigint,uuid,integer,integer,boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_resolver_derrubar_apos_aoo_srd(bigint,uuid,integer,integer,boolean) TO authenticated;
