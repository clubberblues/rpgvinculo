CREATE OR REPLACE FUNCTION priv.srd_resolver_derrubar_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_attacker_d20 integer, p_defender_d20 integer, p_defender_uses_dex boolean DEFAULT false, p_defender_firm_ground boolean DEFAULT false, p_trip_using_weapon boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_combat jsonb;
  v_order jsonb;
  v_actor jsonb;
  v_round integer;
  v_calc jsonb;
  v_attacker_total integer;
  v_defender_total integer;
  v_success boolean;
  v_action_state jsonb;
  v_by_character jsonb;
  v_actions jsonb;
  v_key text;
  v_prone boolean;
  v_condition_instance bigint;
  v_phase text;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode resolver esta manobra.';
  END IF;
  IF p_attacker_d20 NOT BETWEEN 1 AND 20 OR p_defender_d20 NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'Ambas as rolagens precisam ser resultados físicos de D20 entre 1 e 20.';
  END IF;
  IF NULLIF(BTRIM(p_attacker_token_id),'') IS NULL
     OR NULLIF(BTRIM(p_defender_token_id),'') IS NULL
     OR BTRIM(p_attacker_token_id)=BTRIM(p_defender_token_id) THEN
    RAISE EXCEPTION 'Selecione atacante e defensor diferentes.';
  END IF;

  SELECT * INTO v_campaign FROM public.campaigns
   WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE' THEN
    RAISE EXCEPTION 'Derrubar só pode ser resolvido durante o combate.';
  END IF;
  v_combat:=coalesce(v_campaign.combat_data,'{}'::jsonb);
  IF coalesce(v_combat->>'active','false')<>'true' THEN
    RAISE EXCEPTION 'A iniciativa não está ativa.';
  END IF;
  v_phase:=lower(coalesce(v_combat->'surprise'->>'phase','normal'));
  IF v_phase IN ('surprise','surprise_round') THEN
    RAISE EXCEPTION 'Manobras de ação padrão não podem ser usadas na rodada surpresa.';
  END IF;
  IF coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'O turno atual é inválido.';
  END IF;
  v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::jsonb END;
  v_actor:=v_order->(v_combat->>'current_turn')::integer;
  IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_attacker_token_id) THEN
    RAISE EXCEPTION 'O atacante precisa estar no turno ativo.';
  END IF;

  v_calc:=public.srd_consultar_modificadores_manobra_srd(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,'trip',
    coalesce(p_defender_firm_ground,false),coalesce(p_trip_using_weapon,false)
  );
  IF coalesce(v_calc->>'maneuver','')<>'trip' THEN
    RAISE EXCEPTION 'O cálculo retornou uma manobra inválida.';
  END IF;
  IF coalesce(v_calc->>'aoo_status','')='provokes' THEN
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
  END IF;

  v_round:=CASE WHEN coalesce(v_combat->>'round','') ~ '^[0-9]+$'
    THEN greatest(1,(v_combat->>'round')::integer) ELSE 1 END;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_attacker_token_id),'no_actions')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_attacker_token_id),'only_move_action')
     OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_attacker_token_id),'no_actions')
     OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_attacker_token_id),'only_move_action')
     OR (nullif(v_calc->'attacker'->>'character_id','') IS NOT NULL AND (
       priv.srd_condition_has_flag(p_campaign_id,'character',v_calc->'attacker'->>'character_id','no_actions')
       OR priv.srd_condition_has_flag(p_campaign_id,'character',v_calc->'attacker'->>'character_id','only_move_action')
     )) THEN
    RAISE EXCEPTION 'As condições do atacante impedem uma ação padrão.';
  END IF;
  IF EXISTS (
    SELECT 1 FROM public.srd_campaign_conditions
     WHERE campaign_id=p_campaign_id AND target_kind='token'
       AND target_id=BTRIM(p_defender_token_id) AND condition_id='prone' AND active
  ) THEN
    RAISE EXCEPTION 'O alvo já está Caído.';
  END IF;

  v_action_state:=v_combat->'action_economy';
  IF jsonb_typeof(v_action_state)='object'
     AND coalesce(v_action_state->>'round','')=v_round::text
     AND jsonb_typeof(v_action_state->'by_character')='object' THEN
    v_by_character:=v_action_state->'by_character';
  ELSE
    v_by_character:='{}'::jsonb;
  END IF;
  v_key:=BTRIM(p_attacker_token_id);
  v_actions:=CASE WHEN jsonb_typeof(v_by_character->v_key)='object'
    THEN v_by_character->v_key ELSE '{}'::jsonb END;
  IF coalesce((v_actions->>'padrao')::boolean,false) THEN
    RAISE EXCEPTION 'O atacante já gastou sua ação padrão nesta rodada.';
  END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',v_key,'one_move_or_standard')
     AND coalesce((v_actions->>'movimento')::boolean,false) THEN
    RAISE EXCEPTION 'A condição do atacante não permite combinar ação de movimento e ação padrão.';
  END IF;

  v_actions:=v_actions||jsonb_build_object('padrao',true);
  v_by_character:=jsonb_set(v_by_character,ARRAY[v_key],v_actions,true);
  v_action_state:=jsonb_build_object('round',v_round,'by_character',v_by_character);
  v_combat:=v_combat||jsonb_build_object('action_economy',v_action_state);

  v_attacker_total:=p_attacker_d20+(v_calc->>'attacker_modifier')::integer;
  v_defender_total:=p_defender_d20+
    CASE WHEN coalesce(p_defender_uses_dex,false)
      THEN (v_calc->'defender'->>'dexterity_modifier')::integer
      ELSE (v_calc->'defender'->>'strength_modifier')::integer END
    - (v_calc->>'size_difference_modifier')::integer
    + (v_calc->>'dwarf_stability_bonus')::integer;
  v_success:=v_attacker_total>v_defender_total;

  IF v_success THEN
    v_condition_instance:=priv.srd_apply_campaign_condition(
      p_campaign_id,'token',BTRIM(p_defender_token_id),'prone',NULL,
      jsonb_build_object(
        'source','combat_maneuver','maneuver','trip',
        'attacker_token_id',BTRIM(p_attacker_token_id),
        'attacker_d20',p_attacker_d20,'attacker_modifier',(v_calc->>'attacker_modifier')::integer,
        'defender_d20',p_defender_d20,'defender_modifier',
          CASE WHEN coalesce(p_defender_uses_dex,false)
            THEN (v_calc->'defender'->>'dexterity_modifier')::integer
            ELSE (v_calc->'defender'->>'strength_modifier')::integer END,
        'defender_uses_dex',coalesce(p_defender_uses_dex,false),
        'attacker_total',v_attacker_total,'defender_total',v_defender_total
      ),NULL
    );
  END IF;

  UPDATE public.campaigns SET combat_data=v_combat WHERE id=p_campaign_id;
  PERFORM priv.log(p_campaign_id,'COMBAT_MANEUVER',jsonb_build_object(
    'maneuver','trip','attacker_token_id',BTRIM(p_attacker_token_id),
    'defender_token_id',BTRIM(p_defender_token_id),
    'attacker_d20',p_attacker_d20,'attacker_modifier',(v_calc->>'attacker_modifier')::integer,
    'attacker_total',v_attacker_total,'defender_d20',p_defender_d20,
    'defender_modifier',v_defender_total-p_defender_d20,
    'defender_total',v_defender_total,'defender_uses_dex',coalesce(p_defender_uses_dex,false),
    'success',v_success,'condition_instance_id',v_condition_instance,'round',v_round
  ));
  IF NULLIF(current_setting('app.srd_trip_aoo_pending_id',true),'') IS NOT NULL THEN
    UPDATE priv.srd_aoo_pending_movements SET status='committed',committed_at=now(),updated_at=now()
    WHERE pending_id=current_setting('app.srd_trip_aoo_pending_id',true)::uuid
      AND campaign_id=p_campaign_id AND status='waiting_reactions';
  END IF;
  RETURN jsonb_build_object(
    'ok',true,'resolved',true,'maneuver','trip','success',v_success,
    'attacker_d20',p_attacker_d20,'attacker_modifier',(v_calc->>'attacker_modifier')::integer,
    'attacker_total',v_attacker_total,'defender_d20',p_defender_d20,
    'defender_total',v_defender_total,'defender_modifier',v_defender_total-p_defender_d20,
    'defender_uses_dex',coalesce(p_defender_uses_dex,false),
    'condition_applied',v_success,'condition_instance_id',v_condition_instance,
    'action_consumed','padrao','round',v_round,'aoo_status',v_calc->>'aoo_status'
  );
END;
$function$
;
CREATE OR REPLACE FUNCTION priv.srd_resolver_encontrao_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_follow boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  p priv.srd_aoo_pending_movements%ROWTYPE;
  c public.campaigns%ROWTYPE;
  calc jsonb;
  tokens jsonb;
  a jsonb;
  d jsonb;
  ax integer; ay integer;
  attx integer; atty integer;
  dx integer; dy integer;
  old_dx integer; old_dy integer;
  sx integer; sy integer;
  nx integer; ny integer;
  candidate_ax integer; candidate_ay integer;
  moved integer:=0;
  blocked boolean:=false;
  follow_blocked boolean:=false;
  follower_active boolean:=true;
  footprint integer;
  af integer;
  total_a integer;
  total_d integer;
  success boolean;
  rnd integer;
  v_combat jsonb;
  state jsonb;
  bychar jsonb;
  actions jsonb;
  vkey text;
  arr jsonb;
  idx integer;
  aidx integer;
  followed boolean:=false;
  remaining_push_ft integer;
  push_step_cost integer;
  diagonal_count integer:=0;
  v_speed_m numeric:=0;
  v_used_squares integer:=0;
  v_used_diagonal_steps integer:=0;
  v_available_move_ft integer:=0;
  v_follow_remaining_ft integer:=0;
  v_follow_step_cost integer;
  v_follow_steps integer:=0;
  v_follow_diagonal_steps integer:=0;
  v_follow_cost_ft integer:=0;
  v_new_moved_squares integer;
  v_new_diagonal_steps integer;
  v_usage jsonb;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode resolver Encontrão.';
  END IF;
  IF p_attacker_d20 NOT BETWEEN 1 AND 20 OR p_defender_d20 NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'Use resultados físicos de D20 entre 1 e 20.';
  END IF;

  SELECT * INTO p
    FROM priv.srd_aoo_pending_movements
   WHERE campaign_id=p_campaign_id AND pending_id=p_pending_id
   FOR UPDATE;
  IF NOT FOUND OR p.status<>'waiting_reactions'
     OR NOT (p.threats @> '[{"maneuver_event":"bull_rush"}]'::jsonb) THEN
    RAISE EXCEPTION 'Encontrão pendente não encontrado.';
  END IF;
  IF EXISTS(
    SELECT 1 FROM jsonb_array_elements(p.pending_reactions) r
     WHERE r->>'status' IN ('waiting','reserved','attack_started','hit_pending_damage')
  ) THEN RAISE EXCEPTION 'Resolva todas as reações antes do teste resistido.'; END IF;

  SELECT * INTO c FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF upper(coalesce(c.state,''))<>'COMBATE'
     OR coalesce(c.combat_data->>'active','false')<>'true'
     OR greatest(1,coalesce(nullif(c.combat_data->>'round','')::integer,0))<>p.combat_round
     OR coalesce(nullif(c.combat_data->>'current_turn','')::integer,-1)<>p.current_turn THEN
    RAISE EXCEPTION 'O turno ou a rodada mudou; manobra cancelada.';
  END IF;

  calc:=public.srd_consultar_modificadores_manobra_srd(
    p_campaign_id,p.mover_token_id,p.threats->0->>'defender_token_id','bull_rush',false
  );
  total_a:=p_attacker_d20+(calc->>'attacker_modifier')::integer;
  total_d:=p_defender_d20+(calc->>'defender_modifier')::integer;
  success:=total_a>total_d;

  rnd:=p.combat_round;
  vkey:=p.mover_token_id;
  v_combat:=coalesce(c.combat_data,'{}'::jsonb);
  state:=coalesce(v_combat->'action_economy','{}'::jsonb);
  IF jsonb_typeof(state)='object' AND coalesce(state->>'round','')=rnd::text THEN
    bychar:=coalesce(state->'by_character','{}'::jsonb);
  ELSE
    bychar:='{}'::jsonb;
  END IF;
  actions:=CASE WHEN jsonb_typeof(bychar->vkey)='object' THEN bychar->vkey ELSE '{}'::jsonb END;
  IF coalesce((actions->>'padrao')::boolean,false) THEN RAISE EXCEPTION 'A ação padrão já foi consumida.'; END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'no_actions')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'only_move_action')
     OR priv.srd_condition_has_flag(p_campaign_id,'character',vkey,'no_actions')
     OR priv.srd_condition_has_flag(p_campaign_id,'character',vkey,'only_move_action')
     OR (nullif(calc->'attacker'->>'character_id','') IS NOT NULL AND (
       priv.srd_condition_has_flag(p_campaign_id,'character',calc->'attacker'->>'character_id','no_actions')
       OR priv.srd_condition_has_flag(p_campaign_id,'character',calc->'attacker'->>'character_id','only_move_action')
     )) THEN
    RAISE EXCEPTION 'As condições impedem Encontrão.';
  END IF;
  actions:=actions||jsonb_build_object('padrao',true);
  bychar:=jsonb_set(bychar,ARRAY[vkey],actions,true);
  v_combat:=v_combat||jsonb_build_object(
    'action_economy',jsonb_build_object('round',rnd,'by_character',bychar)
  );

  IF success THEN
    tokens:=coalesce(c.cba_data->'tokens','[]'::jsonb);
    SELECT t,ordinality INTO d,idx
      FROM jsonb_array_elements(tokens) WITH ORDINALITY t
     WHERE t->>'id'=p.threats->0->>'defender_token_id'
        OR t->>'key'=p.threats->0->>'defender_token_id'
     LIMIT 1;
    SELECT t,ordinality INTO a,aidx
      FROM jsonb_array_elements(tokens) WITH ORDINALITY t
     WHERE t->>'id'=p.mover_token_id OR t->>'key'=p.mover_token_id
     LIMIT 1;
    IF d IS NULL OR a IS NULL THEN RAISE EXCEPTION 'Um dos tokens saiu da cena antes da resolução.'; END IF;
    IF coalesce(a->>'gridX','') !~ '^[0-9]{1,3}$' OR coalesce(a->>'gridY','') !~ '^[0-9]{1,3}$'
       OR coalesce(d->>'gridX','') !~ '^[0-9]{1,3}$' OR coalesce(d->>'gridY','') !~ '^[0-9]{1,3}$' THEN
      RAISE EXCEPTION 'A posição de um dos tokens é inválida.';
    END IF;

    ax:=(a->>'gridX')::integer;
    ay:=(a->>'gridY')::integer;
    attx:=ax; atty:=ay;
    dx:=(d->>'gridX')::integer;
    dy:=(d->>'gridY')::integer;
    old_dx:=dx; old_dy:=dy;
    af:=priv.srd_token_grid_footprint(p_campaign_id,p.mover_token_id);
    footprint:=priv.srd_token_grid_footprint(p_campaign_id,p.threats->0->>'defender_token_id');
    sx:=CASE WHEN dx>ax+af-1 THEN 1 WHEN dx+footprint-1<ax THEN -1 ELSE 0 END;
    sy:=CASE WHEN dy>ay+af-1 THEN 1 WHEN dy+footprint-1<ay THEN -1 ELSE 0 END;

    remaining_push_ft:=5+floor(greatest(0,total_a-total_d)::numeric/5)::integer*5;

    IF p_follow
       AND NOT priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'no_move')
       AND NOT (priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'no_actions')
                AND NOT priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'flee'))
       AND NOT (a->>'tipo'='player' AND priv.srd_condition_has_flag(p_campaign_id,'character',vkey,'no_move'))
       AND NOT (a->>'tipo'='player'
                AND priv.srd_condition_has_flag(p_campaign_id,'character',vkey,'no_actions')
                AND NOT priv.srd_condition_has_flag(p_campaign_id,'character',vkey,'flee')) THEN
      v_speed_m:=priv.srd_effective_token_speed_m(p_campaign_id,vkey);
      v_usage:=coalesce(v_combat->'movement_usage','{}'::jsonb);
      IF v_usage->>'character_id'=vkey
         AND v_usage->>'round'=rnd::text
         AND v_usage->>'current_turn'=p.current_turn::text
         AND coalesce(v_usage->>'moved_squares','') ~ '^[0-9]+$' THEN
        v_used_squares:=(v_usage->>'moved_squares')::integer;
        IF coalesce(v_usage->>'diagonal_steps','') ~ '^[0-9]+$' THEN
          v_used_diagonal_steps:=(v_usage->>'diagonal_steps')::integer;
        END IF;
      END IF;
      v_available_move_ft:=greatest(0,floor(v_speed_m/1.5)::integer*5-v_used_squares*5);
      v_follow_remaining_ft:=v_available_move_ft;
      IF v_speed_m<=0 OR v_available_move_ft<5 THEN
        follower_active:=false;
        follow_blocked:=true;
      END IF;
    ELSE
      follower_active:=false;
      IF p_follow THEN follow_blocked:=true; END IF;
    END IF;

    WHILE remaining_push_ft>=5 AND (sx<>0 OR sy<>0) LOOP
      push_step_cost:=CASE WHEN sx<>0 AND sy<>0 AND mod(diagonal_count,2)=1 THEN 10 ELSE 5 END;
      IF remaining_push_ft<push_step_cost THEN EXIT; END IF;

      nx:=dx+sx;
      ny:=dy+sy;
      IF nx<0 OR ny<0 OR nx+footprint>200 OR ny+footprint>200 THEN
        blocked:=true;
        EXIT;
      END IF;

      IF EXISTS(
        SELECT 1 FROM jsonb_array_elements(tokens) t
         WHERE t->>'id' IS DISTINCT FROM p.threats->0->>'defender_token_id'
           AND t->>'key' IS DISTINCT FROM p.threats->0->>'defender_token_id'
           AND t->>'id' IS DISTINCT FROM p.mover_token_id
           AND t->>'key' IS DISTINCT FROM p.mover_token_id
           AND coalesce(t->>'gridX','') ~ '^[0-9]{1,3}$'
           AND coalesce(t->>'gridY','') ~ '^[0-9]{1,3}$'
           AND nx<(t->>'gridX')::integer+priv.srd_token_grid_footprint(p_campaign_id,coalesce(t->>'id',t->>'key'))
           AND nx+footprint>(t->>'gridX')::integer
           AND ny<(t->>'gridY')::integer+priv.srd_token_grid_footprint(p_campaign_id,coalesce(t->>'id',t->>'key'))
           AND ny+footprint>(t->>'gridY')::integer
      ) THEN
        blocked:=true;
        EXIT;
      END IF;

      IF follower_active THEN
        candidate_ax:=dx;
        candidate_ay:=dy;
        v_follow_step_cost:=CASE
          WHEN sx<>0 AND sy<>0 AND mod(v_used_diagonal_steps+v_follow_diagonal_steps,2)=1 THEN 10
          ELSE 5
        END;
        IF v_follow_remaining_ft<v_follow_step_cost
           OR candidate_ax<0 OR candidate_ay<0
           OR candidate_ax+af>200 OR candidate_ay+af>200
           OR (candidate_ax<nx+footprint AND candidate_ax+af>nx
               AND candidate_ay<ny+footprint AND candidate_ay+af>ny)
           OR EXISTS(
             SELECT 1 FROM jsonb_array_elements(tokens) t
              WHERE t->>'id' IS DISTINCT FROM p.mover_token_id
                AND t->>'key' IS DISTINCT FROM p.mover_token_id
                AND t->>'id' IS DISTINCT FROM p.threats->0->>'defender_token_id'
                AND t->>'key' IS DISTINCT FROM p.threats->0->>'defender_token_id'
                AND coalesce(t->>'gridX','') ~ '^[0-9]{1,3}$'
                AND coalesce(t->>'gridY','') ~ '^[0-9]{1,3}$'
                AND candidate_ax<(t->>'gridX')::integer+priv.srd_token_grid_footprint(p_campaign_id,coalesce(t->>'id',t->>'key'))
                AND candidate_ax+af>(t->>'gridX')::integer
                AND candidate_ay<(t->>'gridY')::integer+priv.srd_token_grid_footprint(p_campaign_id,coalesce(t->>'id',t->>'key'))
                AND candidate_ay+af>(t->>'gridY')::integer
           ) THEN
          follower_active:=false;
          follow_blocked:=true;
        ELSE
          attx:=candidate_ax;
          atty:=candidate_ay;
          v_follow_steps:=v_follow_steps+1;
          v_follow_cost_ft:=v_follow_cost_ft+v_follow_step_cost;
          v_follow_remaining_ft:=v_follow_remaining_ft-v_follow_step_cost;
          IF sx<>0 AND sy<>0 THEN
            v_follow_diagonal_steps:=v_follow_diagonal_steps+1;
          END IF;
          followed:=true;
        END IF;
      END IF;

      dx:=nx;
      dy:=ny;
      moved:=moved+1;
      remaining_push_ft:=remaining_push_ft-push_step_cost;
      IF sx<>0 AND sy<>0 THEN diagonal_count:=diagonal_count+1; END IF;
    END LOOP;

    IF followed THEN
      v_new_diagonal_steps:=v_used_diagonal_steps+v_follow_diagonal_steps;
      v_new_moved_squares:=v_used_squares+v_follow_steps
        +floor(v_new_diagonal_steps/2.0)::integer
        -floor(v_used_diagonal_steps/2.0)::integer;
      v_combat:=v_combat||jsonb_build_object(
        'movement_usage',jsonb_build_object(
          'round',rnd,
          'current_turn',p.current_turn,
          'character_id',vkey,
          'moved_squares',v_new_moved_squares,
          'diagonal_steps',v_new_diagonal_steps
        )
      );
    END IF;

    SELECT jsonb_agg(
      CASE
        WHEN ordinality=idx THEN d||jsonb_build_object('gridX',dx,'gridY',dy)
        WHEN ordinality=aidx AND followed THEN a||jsonb_build_object('gridX',attx,'gridY',atty)
        ELSE value
      END ORDER BY ordinality
    ) INTO arr
    FROM jsonb_array_elements(tokens) WITH ORDINALITY;

    UPDATE public.campaigns
       SET cba_data=coalesce(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',arr),
           combat_data=v_combat
     WHERE id=p_campaign_id;
  ELSE
    UPDATE public.campaigns SET combat_data=v_combat WHERE id=p_campaign_id;
  END IF;

  UPDATE priv.srd_aoo_pending_movements
     SET status='committed',committed_at=now(),updated_at=now()
   WHERE pending_id=p_pending_id;

  PERFORM priv.log(
    p_campaign_id,'COMBAT_MANEUVER',
    jsonb_build_object(
      'maneuver','bull_rush',
      'attacker_token_id',p.mover_token_id,
      'defender_token_id',p.threats->0->>'defender_token_id',
      'attacker_total',total_a,
      'defender_total',total_d,
      'success',success,
      'squares_pushed',moved,
      'remaining_push_ft',remaining_push_ft,
      'blocked',blocked,
      'follow_requested',p_follow,
      'attacker_followed',followed,
      'attacker_follow_squares',v_follow_steps,
      'attacker_follow_ft',v_follow_cost_ft,
      'follow_blocked',follow_blocked,
      'remaining_movement_ft',greatest(0,v_follow_remaining_ft)
    )
  );

  RETURN jsonb_build_object(
    'ok',true,
    'resolved',true,
    'maneuver','bull_rush',
    'success',success,
    'attacker_total',total_a,
    'defender_total',total_d,
    'squares_pushed',moved,
    'remaining_push_ft',remaining_push_ft,
    'blocked',blocked,
    'attacker_followed',followed,
    'attacker_follow_squares',v_follow_steps,
    'attacker_follow_ft',v_follow_cost_ft,
    'follow_blocked',follow_blocked,
    'remaining_movement_ft',greatest(0,v_follow_remaining_ft),
    'action_consumed','padrao'
  );
END;
$function$
;
