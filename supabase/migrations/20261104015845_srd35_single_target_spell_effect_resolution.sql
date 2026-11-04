
CREATE TABLE IF NOT EXISTS priv.srd_pending_spell_resolutions (
  pending_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id bigint NOT NULL REFERENCES public.campaigns(id) ON DELETE CASCADE,
  caster_character_id text NOT NULL,
  target_kind text NOT NULL CHECK (target_kind IN ('character','token')),
  target_id text NOT NULL,
  target_user_id uuid,
  spell_id text NOT NULL REFERENCES public.srd_spells(id),
  save_type text NOT NULL CHECK (save_type IN ('fortitude','reflex','will')),
  save_dc integer NOT NULL CHECK (save_dc BETWEEN 1 AND 60),
  condition_id text REFERENCES public.srd_conditions(condition_id),
  duration_rounds integer,
  effect_data jsonb NOT NULL DEFAULT '{}'::jsonb,
  spell_resistance boolean NOT NULL DEFAULT false,
  caster_level integer NOT NULL CHECK (caster_level BETWEEN 1 AND 40),
  status text NOT NULL DEFAULT 'pending_save' CHECK (status IN ('pending_save','awaiting_spell_resistance','resolved','saved','resisted','expired')),
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL DEFAULT (now()+interval '20 minutes'),
  resolved_at timestamptz
);
ALTER TABLE priv.srd_pending_spell_resolutions ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE priv.srd_pending_spell_resolutions FROM PUBLIC,anon,authenticated;
CREATE INDEX IF NOT EXISTS srd_pending_spell_resolution_campaign_idx ON priv.srd_pending_spell_resolutions(campaign_id,status,expires_at);

CREATE OR REPLACE FUNCTION priv.srd_spell_resistance_value(p_campaign_id bigint,p_target_kind text,p_target_id text)
RETURNS integer LANGUAGE plpgsql STABLE SECURITY DEFINER
SET search_path=pg_catalog,public,priv,pg_temp
AS $function$
DECLARE v_text text; v_token jsonb;
BEGIN
  IF p_target_kind='character' THEN
    RETURN GREATEST(0,priv.srd_effective_modifier(p_campaign_id,'character',p_target_id,'spell_resistance'));
  END IF;
  SELECT t.value INTO v_token
  FROM public.campaigns c
  CROSS JOIN LATERAL jsonb_array_elements(CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array' THEN c.cba_data->'tokens' ELSE '[]'::jsonb END) t(value)
  WHERE c.id=p_campaign_id AND (t.value->>'id'=p_target_id OR t.value->>'key'=p_target_id) LIMIT 1;
  v_text:=COALESCE(v_token->'monsterStats'->>'spell_resistance',v_token->'monsterStats'->>'resistencia_magia');
  RETURN GREATEST(0,COALESCE(NULLIF(substring(COALESCE(v_text,'') FROM '[0-9]+'),'')::integer,0));
END;
$function$;

CREATE OR REPLACE FUNCTION priv.srd_apply_pending_spell_resolution(p_pending_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path=pg_catalog,public,priv,pg_temp
AS $function$
DECLARE v_pending priv.srd_pending_spell_resolutions%ROWTYPE; v_instance bigint;
BEGIN
  SELECT * INTO v_pending FROM priv.srd_pending_spell_resolutions WHERE pending_id=p_pending_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Resolução de magia pendente não encontrada.'; END IF;
  IF v_pending.status NOT IN ('pending_save','awaiting_spell_resistance') THEN RAISE EXCEPTION 'Esta resolução de magia já foi concluída.'; END IF;
  IF v_pending.condition_id IS NOT NULL THEN
    v_instance:=priv.srd_apply_campaign_condition(
      v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,v_pending.condition_id,
      v_pending.duration_rounds,
      jsonb_build_object('source_spell_id',v_pending.spell_id,'save_dc',v_pending.save_dc,'save_type',v_pending.save_type,
        'save_each_turn',v_pending.spell_id='srd35_spell_hold_person','caster_level',v_pending.caster_level),
      v_pending.spell_id
    );
  ELSIF v_pending.effect_data<>'{}'::jsonb THEN
    v_instance:=priv.srd_apply_campaign_effect(v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,
      'buff',v_pending.effect_data,v_pending.duration_rounds,v_pending.spell_id,NULL);
  ELSE
    RAISE EXCEPTION 'A magia não possui uma regra de efeito implementada.';
  END IF;
  UPDATE priv.srd_pending_spell_resolutions SET status='resolved',resolved_at=now() WHERE pending_id=p_pending_id;
  RETURN jsonb_build_object('pending_id',p_pending_id,'status','resolved','instance_id',v_instance,'condition_id',v_pending.condition_id);
END;
$function$;

CREATE OR REPLACE FUNCTION public.srd_resolve_pending_spell_save(p_pending_id uuid,p_d20 integer)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path=pg_catalog,public,priv,pg_temp
AS $function$
DECLARE v_pending priv.srd_pending_spell_resolutions%ROWTYPE; v_user_id uuid; v_bonus integer; v_total integer; v_sr integer; v_caster_user uuid;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_d20 IS NULL OR p_d20 NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'A resistência exige uma rolagem manual de D20.'; END IF;
  SELECT * INTO v_pending FROM priv.srd_pending_spell_resolutions WHERE pending_id=p_pending_id FOR UPDATE;
  IF NOT FOUND OR v_pending.status<>'pending_save' OR v_pending.expires_at<now() THEN RAISE EXCEPTION 'Pedido de resistência inválido ou expirado.'; END IF;
  IF v_pending.target_kind='character' THEN
    SELECT user_id INTO v_user_id FROM public.characters WHERE id::text=v_pending.target_id AND campaign_id=v_pending.campaign_id;
    IF v_user_id IS DISTINCT FROM auth.uid() AND public.my_role(v_pending.campaign_id) IS DISTINCT FROM 'GM'
       AND NOT EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=v_pending.campaign_id AND c.owner_id=auth.uid()) THEN
      RAISE EXCEPTION 'Somente o jogador-alvo ou o Mestre pode registrar esta resistência.';
    END IF;
  ELSIF public.my_role(v_pending.campaign_id) IS DISTINCT FROM 'GM'
        AND NOT EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=v_pending.campaign_id AND c.owner_id=auth.uid()) THEN
    RAISE EXCEPTION 'Somente o Mestre pode registrar a resistência de um NPC ou monstro.';
  END IF;
  v_bonus:=priv.srd_saving_throw_bonus(v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,v_pending.save_type,
    CASE WHEN v_pending.spell_id='srd35_spell_bane' THEN 'fear' ELSE NULL END);
  v_total:=p_d20+v_bonus;
  IF v_total>=v_pending.save_dc THEN
    UPDATE priv.srd_pending_spell_resolutions SET status='saved',resolved_at=now() WHERE pending_id=p_pending_id;
    RETURN jsonb_build_object('pending_id',p_pending_id,'saved',true,'total',v_total,'bonus',v_bonus,'dc',v_pending.save_dc,'status','saved');
  END IF;
  v_sr:=CASE WHEN v_pending.spell_resistance THEN priv.srd_spell_resistance_value(v_pending.campaign_id,v_pending.target_kind,v_pending.target_id) ELSE 0 END;
  IF v_sr>0 THEN
    SELECT user_id INTO v_caster_user FROM public.characters WHERE id::text=v_pending.caster_character_id AND campaign_id=v_pending.campaign_id;
    UPDATE priv.srd_pending_spell_resolutions SET status='awaiting_spell_resistance' WHERE pending_id=p_pending_id;
    INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
    VALUES(v_pending.campaign_id,'test_request','PUBLIC',
      jsonb_build_object('tipo','Penetração de Resistência à Magia (D20)','alvos',jsonb_build_array(v_pending.caster_character_id),
        'npc_alvos','[]'::jsonb,'mestre','Sistema','mestre_id',auth.uid(),'request_id',gen_random_uuid()::text,
        'resolution_type','spell_resistance','pending_id',p_pending_id,'spell_id',v_pending.spell_id,
        'spell_resistance',v_sr,'caster_level',v_pending.caster_level));
    RETURN jsonb_build_object('pending_id',p_pending_id,'saved',false,'total',v_total,'bonus',v_bonus,'dc',v_pending.save_dc,
      'requires_spell_resistance',true,'spell_resistance',v_sr,'caster_user_id',v_caster_user);
  END IF;
  RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)
    || jsonb_build_object('saved',false,'save_total',v_total,'save_bonus',v_bonus,'save_dc',v_pending.save_dc);
END;
$function$;

CREATE OR REPLACE FUNCTION public.srd_resolve_pending_spell_resistance(p_pending_id uuid,p_d20 integer)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path=pg_catalog,public,priv,pg_temp
AS $function$
DECLARE v_pending priv.srd_pending_spell_resolutions%ROWTYPE; v_user uuid; v_sr integer; v_total integer;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_d20 IS NULL OR p_d20 NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'A penetração exige uma rolagem manual de D20.'; END IF;
  SELECT * INTO v_pending FROM priv.srd_pending_spell_resolutions WHERE pending_id=p_pending_id FOR UPDATE;
  IF NOT FOUND OR v_pending.status<>'awaiting_spell_resistance' OR v_pending.expires_at<now() THEN RAISE EXCEPTION 'Pedido de resistência à magia inválido ou expirado.'; END IF;
  SELECT user_id INTO v_user FROM public.characters WHERE id::text=v_pending.caster_character_id AND campaign_id=v_pending.campaign_id;
  IF v_user IS DISTINCT FROM auth.uid() AND public.my_role(v_pending.campaign_id) IS DISTINCT FROM 'GM'
     AND NOT EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=v_pending.campaign_id AND c.owner_id=auth.uid()) THEN
    RAISE EXCEPTION 'Somente o conjurador ou o Mestre pode registrar a penetração.';
  END IF;
  v_sr:=priv.srd_spell_resistance_value(v_pending.campaign_id,v_pending.target_kind,v_pending.target_id);
  v_total:=p_d20+v_pending.caster_level;
  IF v_total<v_sr THEN
    UPDATE priv.srd_pending_spell_resolutions SET status='resisted',resolved_at=now() WHERE pending_id=p_pending_id;
    RETURN jsonb_build_object('pending_id',p_pending_id,'status','resisted','total',v_total,'spell_resistance',v_sr);
  END IF;
  RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)||jsonb_build_object('status','penetrated','total',v_total,'spell_resistance',v_sr);
END;
$function$;

DO $patch_spell_catalog_rules$
BEGIN
  UPDATE public.srd_spell_effects
     SET parameters=jsonb_set(parameters,'{engine_rule}',
       '{"resolver":"buff","effect_data":{"modifiers":[{"stat":"strength","value":4,"bonus_type":"enhancement"}],"stacking_key":"bull_s_strength","stacking_policy":"replace"},"duration_rounds_per_caster_level":10,"willing_target":true,"spell_resistance":true}'::jsonb,true),
         verification_status='verified_srd'
   WHERE spell_id='srd35_spell_bull_s_strength' AND effect_index=1;
  UPDATE public.srd_spell_effects
     SET parameters=jsonb_set(parameters,'{engine_rule}',
       '{"resolver":"condition","condition_id":"paralyzed","save_type":"will","save_result":"negates","duration_rounds_per_caster_level":1,"spell_resistance":true,"target_filter":"humanoid","save_each_turn":true}'::jsonb,true),
         verification_status='verified_srd'
   WHERE spell_id='srd35_spell_hold_person' AND effect_index=1;
  UPDATE public.srd_spell_effects
     SET parameters=jsonb_set(parameters,'{engine_rule}',
       '{"resolver":"condition","condition_id":"blinded","alternate_condition_id":"deafened","save_type":"fortitude","save_result":"negates","duration_rounds":null,"spell_resistance":true,"target_filter":"living"}'::jsonb,true),
         verification_status='verified_srd'
   WHERE spell_id='srd35_spell_blindness_deafness' AND effect_index=1;
  UPDATE public.srd_spells
     SET dados_tecnicos=jsonb_set(COALESCE(dados_tecnicos,'{}'::jsonb),'{engine_status}',to_jsonb('ready_single_target'::text),true)
   WHERE id IN ('srd35_spell_bull_s_strength','srd35_spell_hold_person','srd35_spell_blindness_deafness');
END;
$patch_spell_catalog_rules$;

DO $patch_spell_cast$
DECLARE v_definition text; v_marker text; v_add text;
BEGIN
  SELECT pg_get_functiondef('public.conjurar_magia_srd_manual(text,text,smallint,text,integer[])'::regprocedure) INTO v_definition;
  v_marker:='  v_state:=jsonb_build_object(''version'',1,''conhecidas'',v_known,''preparadas'',v_prepared,''dominio_preparadas'',v_domain_prepared,''usos'',v_usos);';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Ponto final de consumo de magia não localizado.'; END IF;
  IF position('srd_pending_spell_resolutions' IN v_definition)>0 THEN RETURN; END IF;
  v_definition:=replace(v_definition,'  v_slot_total integer; v_slots_remaining integer;',
    '  v_slot_total integer; v_slots_remaining integer;' || E'\n  v_effect_target_kind text; v_effect_target_id text; v_effect_target_user_id uuid;\n  v_engine_rule jsonb; v_effect_data jsonb; v_pending_id uuid; v_condition_id text; v_save_type text; v_save_dc integer; v_duration_rounds integer; v_effect_instance bigint;');
  v_add:=$patch$
  IF v_campaign_id IS NOT NULL AND v_spell.id IN ('srd35_spell_bull_s_strength','srd35_spell_hold_person','srd35_spell_blindness_deafness') THEN
    SELECT se.parameters->'engine_rule' INTO v_engine_rule
    FROM public.srd_spell_effects se
    WHERE se.spell_id=v_spell.id AND se.verification_status='verified_srd'
    ORDER BY se.effect_index LIMIT 1;
    IF v_engine_rule IS NULL THEN RAISE EXCEPTION 'A regra automática desta magia não está validada.'; END IF;
    IF v_target_key IS NULL THEN
      v_effect_target_kind:='character'; v_effect_target_id:=p_character_id;
      v_target_character_id:=p_character_id; v_target_type:='player'; v_target_name:=v_caster_name;
    ELSIF v_target_type='player' THEN
      v_effect_target_kind:='character'; v_target_character_id:=v_token->>'id'; v_effect_target_id:=v_target_character_id;
    ELSE
      v_effect_target_kind:='token'; v_effect_target_id:=v_target_key;
    END IF;
    IF v_effect_target_kind='character' THEN
      SELECT ch.user_id INTO v_effect_target_user_id FROM public.characters ch
      WHERE ch.id::text=v_effect_target_id AND ch.campaign_id=v_campaign_id;
      IF NOT FOUND THEN RAISE EXCEPTION 'Personagem-alvo não pertence à campanha.'; END IF;
    END IF;
    IF v_spell.id='srd35_spell_bull_s_strength' THEN
      v_effect_data:=v_engine_rule->'effect_data';
      v_duration_rounds:=v_level*COALESCE((v_engine_rule->>'duration_rounds_per_caster_level')::integer,10);
      v_effect_instance:=priv.srd_apply_campaign_effect(v_campaign_id,v_effect_target_kind,v_effect_target_id,'buff',v_effect_data,v_duration_rounds,v_spell.id,NULL);
    ELSE
      v_condition_id:=CASE WHEN v_spell.id='srd35_spell_blindness_deafness' AND p_roll_results IS NOT NULL AND p_roll_results[1]=2 THEN 'deafened' ELSE v_engine_rule->>'condition_id' END;
      v_save_type:=v_engine_rule->>'save_type';
      v_save_dc:=10+v_spell.circulo+FLOOR((v_score-10)::numeric/2)::integer;
      v_duration_rounds:=CASE WHEN v_engine_rule ? 'duration_rounds_per_caster_level'
        THEN v_level*(v_engine_rule->>'duration_rounds_per_caster_level')::integer ELSE NULL END;
      INSERT INTO priv.srd_pending_spell_resolutions(
        campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
        save_type,save_dc,condition_id,duration_rounds,effect_data,spell_resistance,caster_level
      ) VALUES (
        v_campaign_id,p_character_id,v_effect_target_kind,v_effect_target_id,v_effect_target_user_id,v_spell.id,
        v_save_type,v_save_dc,v_condition_id,v_duration_rounds,'{}'::jsonb,
        COALESCE((v_engine_rule->>'spell_resistance')::boolean,false),v_level
      ) RETURNING pending_id INTO v_pending_id;
      INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
      VALUES (
        v_campaign_id,'test_request','PUBLIC',
        jsonb_build_object(
          'tipo','Resistência de '||CASE v_save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
          'alvos',CASE WHEN v_effect_target_kind='character' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'npc_alvos',CASE WHEN v_effect_target_kind='token' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
          'resolution_type','spell_save','pending_id',v_pending_id,'spell_id',v_spell.id,'save_type',v_save_type,'save_dc',v_save_dc
        )
      );
    END IF;
  END IF;
$patch$;
  v_definition:=replace(v_definition,v_marker,v_add||E'\n'||v_marker);
  v_definition:=replace(v_definition,
    '''domain_id'',CASE WHEN v_domain_slot_used THEN v_domain_id ELSE NULL END',
    '''domain_id'',CASE WHEN v_domain_slot_used THEN v_domain_id ELSE NULL END,''pending_resolution_id'',v_pending_id,''effect_instance_id'',v_effect_instance');
  EXECUTE v_definition;
END;
$patch_spell_cast$;

DO $patch_strength_attack$
DECLARE v_definition text; v_marker text;
BEGIN
  SELECT pg_get_functiondef('public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer)'::regprocedure) INTO v_definition;
  v_marker:='v_effective_attack_modifier:=priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''attack'')+CASE WHEN p_attack_type=''atk-corpo'' THEN priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''attack_melee'') ELSE priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''attack_ranged'') END;';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Cálculo de bônus de ataque não localizado para força dinâmica.'; END IF;
  v_definition:=replace(v_definition,v_marker,
    'v_effective_attack_modifier:=priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''attack'')+CASE WHEN p_attack_type=''atk-corpo'' THEN priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''attack_melee'')+FLOOR((v_str_score+priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''strength'')-10)::numeric/2)::integer-FLOOR((v_str_score-10)::numeric/2)::integer ELSE priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''attack_ranged'')+FLOOR((v_dex_score+priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''dexterity'')-10)::numeric/2)::integer-FLOOR((v_dex_score-10)::numeric/2)::integer END;');
  v_marker:='v_damage_final:=priv.srd_adjust_damage(p_campaign_id,''token'',BTRIM(p_token_id),v_damage_type,GREATEST(0,p_dano+priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''damage'')));';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Cálculo de dano não localizado para força dinâmica.'; END IF;
  v_definition:=replace(v_definition,v_marker,
    'v_damage_final:=priv.srd_adjust_damage(p_campaign_id,''token'',BTRIM(p_token_id),v_damage_type,GREATEST(0,p_dano+priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''damage'')+CASE WHEN p_attack_type=''atk-corpo'' THEN FLOOR((v_str_score+priv.srd_effective_modifier(p_campaign_id,''character'',BTRIM(p_character_id),''strength'')-10)::numeric/2)::integer-FLOOR((v_str_score-10)::numeric/2)::integer ELSE 0 END));');
  EXECUTE v_definition;
END;
$patch_strength_attack$;

REVOKE ALL ON FUNCTION priv.srd_spell_resistance_value(bigint,text,text) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION priv.srd_apply_pending_spell_resolution(uuid) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION public.srd_resolve_pending_spell_save(uuid,integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.srd_resolve_pending_spell_save(uuid,integer) TO authenticated;
REVOKE ALL ON FUNCTION public.srd_resolve_pending_spell_resistance(uuid,integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.srd_resolve_pending_spell_resistance(uuid,integer) TO authenticated;
