
CREATE OR REPLACE FUNCTION priv.srd_effective_token_speed_m(p_campaign_id bigint,p_token_id text)
RETURNS numeric
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
DECLARE
  v_token jsonb;
  v_count integer;
  v_type text;
  v_character_id text;
  v_base_speed numeric;
  v_speed_text text;
  v_speed_number text;
  v_speed numeric;
  v_target_kind text;
BEGIN
  SELECT count(*)::integer,(array_agg(t))[1]
    INTO v_count,v_token
    FROM jsonb_array_elements(COALESCE((SELECT cba_data->'tokens' FROM public.campaigns WHERE id=p_campaign_id),'[]'::jsonb)) t
   WHERE t->>'id'=btrim(p_token_id) OR t->>'key'=btrim(p_token_id);
  IF v_count<>1 THEN RAISE EXCEPTION 'Token inexistente ou duplicado ao calcular deslocamento.'; END IF;

  v_type:=v_token->>'tipo';
  v_character_id:=COALESCE(NULLIF(btrim(v_token->>'sourceCharacterId'),''),CASE WHEN v_type='player' THEN btrim(p_token_id) END);
  v_target_kind:=CASE WHEN v_type='player' THEN 'character' ELSE 'token' END;

  IF v_character_id IS NOT NULL THEN
    SELECT race.deslocamento::numeric
      INTO v_base_speed
      FROM public.srd_character_sheets sheet
      JOIN public.srd_races race ON race.id::text=sheet.raca_id::text
     WHERE sheet.character_id::text=v_character_id;
    IF v_base_speed IS NOT NULL THEN
      v_speed:=public.srd35_deslocamento_personagem(v_character_id,v_base_speed);
      IF v_type<>'player' THEN
        v_speed:=v_speed*priv.srd_condition_speed_multiplier(p_campaign_id,'token',btrim(p_token_id));
      ELSE
        v_speed:=v_speed*priv.srd_condition_speed_multiplier(p_campaign_id,'character',v_character_id);
      END IF;
      RETURN GREATEST(0,COALESCE(v_speed,0));
    END IF;
  END IF;

  v_speed_text:=COALESCE(
    NULLIF(v_token->>'deslocamento_m',''),
    NULLIF(v_token->'monsterStats'->>'deslocamento',''),
    NULLIF(v_token->'monsterStats'->>'speed',''),
    NULLIF(v_token->>'speed_m','')
  );
  IF v_speed_text IS NULL THEN
    v_speed:=9;
  ELSE
    v_speed_number:=substring(v_speed_text FROM '([0-9]+([.][0-9]+)?)');
    IF v_speed_number IS NULL THEN RAISE EXCEPTION 'Não foi possível interpretar o deslocamento do token %.',p_token_id; END IF;
    v_speed:=v_speed_number::numeric;
    IF lower(v_speed_text) ~ '(ft|feet|foot|p[eé]s|pé)' THEN v_speed:=v_speed*0.3048; END IF;
  END IF;
  v_speed:=v_speed*priv.srd_condition_speed_multiplier(p_campaign_id,'token',btrim(p_token_id));
  RETURN GREATEST(0,COALESCE(v_speed,0));
END;
$function$;

CREATE OR REPLACE FUNCTION priv.srd_resolver_encontrao_srd(
  p_campaign_id bigint,
  p_pending_id uuid,
  p_attacker_d20 integer,
  p_defender_d20 integer,
  p_follow boolean DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
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
     OR priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'only_move_action') THEN
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
                AND NOT priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'flee')) THEN
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
      v_follow_remaining_ft:=least(remaining_push_ft,v_available_move_ft);
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
$function$;

REVOKE ALL ON FUNCTION priv.srd_effective_token_speed_m(bigint,text) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION priv.srd_effective_token_speed_m(bigint,text) TO postgres;
REVOKE ALL ON FUNCTION priv.srd_resolver_encontrao_srd(bigint,uuid,integer,integer,boolean) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION priv.srd_resolver_encontrao_srd(bigint,uuid,integer,integer,boolean) TO authenticated;
