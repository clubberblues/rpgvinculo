
CREATE OR REPLACE FUNCTION public.srd_resolver_derrubar_srd(
  p_campaign_id bigint,
  p_attacker_token_id text,
  p_defender_token_id text,
  p_attacker_d20 integer,
  p_defender_d20 integer,
  p_defender_uses_dex boolean DEFAULT false,
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
  IF v_phase='surprise' THEN
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
    RAISE EXCEPTION 'Esta tentativa provoca ataque de oportunidade. Resolva primeiro a reação do defensor; a resolução integrada de AOO para manobras ainda não está disponível.';
  END IF;
  IF coalesce(v_calc->>'aoo_status','') NOT IN ('not_provoked_by_armed_trip','suppressed_by_feat') THEN
    RAISE EXCEPTION 'Não foi possível confirmar que a tentativa não provoca ataque de oportunidade.';
  END IF;

  v_round:=CASE WHEN coalesce(v_combat->>'round','') ~ '^[0-9]+$'
    THEN greatest(1,(v_combat->>'round')::integer) ELSE 1 END;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_attacker_token_id),'no_actions')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_attacker_token_id),'only_move_action') THEN
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
$function$;

REVOKE ALL ON FUNCTION public.srd_resolver_derrubar_srd(bigint,text,text,integer,integer,boolean,boolean,boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_resolver_derrubar_srd(bigint,text,text,integer,integer,boolean,boolean,boolean) TO authenticated;
