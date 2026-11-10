CREATE OR REPLACE FUNCTION public.srd_resolve_pending_spell_save(p_pending_id uuid, p_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE v_pending priv.srd_pending_spell_resolutions%ROWTYPE; v_user_id uuid; v_bonus integer; v_total integer; v_sr integer; v_caster_user uuid; v_round integer; v_school text; v_context text; v_rogue_level integer:=0; v_monk_level integer:=0; v_ranger_level integer:=0; v_evasion boolean:=false; v_improved_evasion boolean:=false; v_medium_or_heavy_armor boolean:=false;
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
  SELECT lower(COALESCE(escola,'')) INTO v_school
    FROM public.srd_spells WHERE id=v_pending.spell_id;
  v_context:=concat_ws(',',
    'spell',
    CASE WHEN v_pending.spell_id='srd35_spell_bane' THEN 'fear' END,
    CASE WHEN COALESCE(v_school,'') LIKE '%enchant%' THEN 'enchantment' END
  );
  v_bonus:=priv.srd_saving_throw_bonus(
    v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,v_pending.save_type,NULLIF(v_context,'')
  );
  v_total:=p_d20+v_bonus;

  IF v_pending.target_kind='character'
     AND v_pending.save_type='reflex'
     AND v_pending.effect_kind='damage'
     AND v_pending.effect_data->>'save_result'='half' THEN
    SELECT COALESCE(MAX(cl.class_level) FILTER (WHERE cls.class_key='rogue'),
             CASE WHEN NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels any_level WHERE any_level.character_id=sh.character_id)
                       AND sh.classe_id='ladino' THEN GREATEST(1,COALESCE(sh.nivel,1)) ELSE 0 END),
           COALESCE(MAX(cl.class_level) FILTER (WHERE cls.class_key='monk'),
             CASE WHEN NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels any_level WHERE any_level.character_id=sh.character_id)
                       AND sh.classe_id='monge' THEN GREATEST(1,COALESCE(sh.nivel,1)) ELSE 0 END),
           COALESCE(MAX(cl.class_level) FILTER (WHERE cls.class_key='ranger'),
             CASE WHEN NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels any_level WHERE any_level.character_id=sh.character_id)
                       AND sh.classe_id='ranger' THEN GREATEST(1,COALESCE(sh.nivel,1)) ELSE 0 END)
      INTO v_rogue_level,v_monk_level,v_ranger_level
      FROM public.srd_character_sheets sh
      LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
      LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
     WHERE sh.character_id::text=v_pending.target_id
     GROUP BY sh.character_id,sh.classe_id,sh.nivel;

    SELECT EXISTS (
      SELECT 1
        FROM public.srd_character_equipment ce
        JOIN public.srd_equipment eq ON eq.id=ce.equipment_id
       WHERE ce.character_id::text=v_pending.target_id
         AND ce.equipado=true
         AND (
           lower(COALESCE(eq.detalhes->>'category',eq.categoria,'')) LIKE '%medium armor%'
           OR lower(COALESCE(eq.detalhes->>'category',eq.categoria,'')) LIKE '%heavy armor%'
           OR lower(COALESCE(eq.categoria,'')) IN ('armadura','armor','armor_and_shields')
              AND lower(COALESCE(eq.nome,'')) NOT LIKE '%shield%'
              AND COALESCE(eq.bonus_max_des,eq.max_des,0)<=3
         )
    ) INTO v_medium_or_heavy_armor;

    v_evasion:=NOT v_medium_or_heavy_armor
      AND (COALESCE(v_rogue_level,0)>=2 OR COALESCE(v_monk_level,0)>=2 OR COALESCE(v_ranger_level,0)>=9);
    v_improved_evasion:=NOT v_medium_or_heavy_armor AND COALESCE(v_monk_level,0)>=9;
  END IF;

  IF v_pending.condition_break THEN
    SELECT GREATEST(1,COALESCE(NULLIF(c.combat_data->>'round','')::integer,1))
      INTO v_round FROM public.campaigns c WHERE c.id=v_pending.campaign_id;
    IF v_total>=v_pending.save_dc THEN
      UPDATE public.srd_campaign_conditions
         SET active=false,
             notes=COALESCE(notes,'{}'::jsonb)||jsonb_build_object('ended_by_save',true,'last_save_round',v_round)
       WHERE condition_instance_id=v_pending.condition_break_instance_id
         AND campaign_id=v_pending.campaign_id AND active=true;
      UPDATE priv.srd_pending_spell_resolutions SET status='saved',resolved_at=now() WHERE pending_id=p_pending_id;
      RETURN jsonb_build_object('pending_id',p_pending_id,'saved',true,'condition_ended',true,
        'total',v_total,'bonus',v_bonus,'dc',v_pending.save_dc,'status','condition_ended');
    ELSE
      UPDATE public.srd_campaign_conditions
         SET notes=COALESCE(notes,'{}'::jsonb)||jsonb_build_object('last_save_round',v_round)
       WHERE condition_instance_id=v_pending.condition_break_instance_id
         AND campaign_id=v_pending.campaign_id AND active=true;
      UPDATE priv.srd_pending_spell_resolutions SET status='resolved',resolved_at=now() WHERE pending_id=p_pending_id;
      RETURN jsonb_build_object('pending_id',p_pending_id,'saved',false,'condition_ended',false,
        'total',v_total,'bonus',v_bonus,'dc',v_pending.save_dc,'status','condition_persists');
    END IF;
  END IF;

  IF v_total>=v_pending.save_dc THEN
    IF v_pending.effect_kind='damage' AND v_pending.effect_data->>'save_result' IN ('half','damage_unaffected') THEN
      UPDATE priv.srd_pending_spell_resolutions
         SET effect_data=(
           CASE
             WHEN effect_data->>'save_result'='half' AND v_evasion THEN
               jsonb_set(effect_data,'{damage}',to_jsonb(0),true)
             WHEN effect_data->>'save_result'='half' THEN
               jsonb_set(effect_data,'{damage}',
                 to_jsonb(GREATEST(0,FLOOR(COALESCE(NULLIF(effect_data->>'damage','')::numeric,0)/2)::integer)),true)
             ELSE effect_data
           END
         )||jsonb_build_object('apply_secondary_condition',false)
       WHERE pending_id=p_pending_id;
      RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)
        ||jsonb_build_object('saved',true,'save_total',v_total,'save_bonus',v_bonus,'save_dc',v_pending.save_dc,
          'save_result',v_pending.effect_data->>'save_result','evasion',v_evasion,
          'improved_evasion',v_improved_evasion,'evasion_armor_blocked',v_medium_or_heavy_armor);
    END IF;
    UPDATE priv.srd_pending_spell_resolutions SET status='saved',resolved_at=now() WHERE pending_id=p_pending_id;
    RETURN jsonb_build_object('pending_id',p_pending_id,'saved',true,'total',v_total,'bonus',v_bonus,'dc',v_pending.save_dc,'status','saved');
  END IF;
  IF v_pending.effect_kind='damage' AND v_pending.effect_data->>'save_result'='half' AND v_improved_evasion THEN
    UPDATE priv.srd_pending_spell_resolutions
       SET effect_data=jsonb_set(effect_data,'{damage}',
         to_jsonb(GREATEST(0,FLOOR(COALESCE(NULLIF(effect_data->>'damage','')::numeric,0)/2)::integer)),true)
     WHERE pending_id=p_pending_id;
    RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)
      || jsonb_build_object('saved',false,'save_total',v_total,'save_bonus',v_bonus,'save_dc',v_pending.save_dc,
        'evasion',true,'improved_evasion',true,'evasion_armor_blocked',false);
  END IF;
  RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)
    || jsonb_build_object('saved',false,'save_total',v_total,'save_bonus',v_bonus,'save_dc',v_pending.save_dc,
      'evasion',v_evasion,'improved_evasion',v_improved_evasion,'evasion_armor_blocked',v_medium_or_heavy_armor);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.srd_resolve_requested_saving_throw_srd(p_campaign_id bigint, p_character_id text, p_request_id text, p_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_request public.campaign_log%ROWTYPE;
  v_save_type text;
  v_context text;
  v_dc integer;
  v_bonus integer;
  v_base_bonus integer;
  v_total integer;
  v_result jsonb;
  v_master uuid;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_d20 IS NULL OR p_d20 NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'Resultado de d20 inválido.';
  END IF;
  IF NULLIF(BTRIM(p_request_id),'') IS NULL THEN
    RAISE EXCEPTION 'Pedido de teste inválido.';
  END IF;

  SELECT * INTO v_character
    FROM public.characters
   WHERE id::text=BTRIM(p_character_id)
     AND campaign_id=p_campaign_id
     AND user_id=auth.uid();
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou não pertence ao jogador.'; END IF;

  SELECT * INTO v_request
    FROM public.campaign_log
   WHERE campaign_id=p_campaign_id
     AND type='test_request'
     AND data->>'request_id'=BTRIM(p_request_id)
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Pedido de resistência não encontrado ou expirado.'; END IF;
  IF v_request.data->>'resolution_type'<>'saving_throw' THEN
    RAISE EXCEPTION 'Este pedido não é um teste de resistência SRD.';
  END IF;
  IF NOT COALESCE(v_request.data->'alvos' @> jsonb_build_array(v_character.id::text),false) THEN
    RAISE EXCEPTION 'Este pedido não foi direcionado ao personagem.';
  END IF;
  IF COALESCE(v_request.data->'results','{}'::jsonb) ? v_character.id::text THEN
    RAISE EXCEPTION 'Este teste já foi respondido por este personagem.';
  END IF;

  v_master:=NULLIF(v_request.data->>'mestre_id','')::uuid;
  IF v_master IS NULL OR NOT EXISTS (
    SELECT 1 FROM public.members m
     WHERE m.campaign_id=p_campaign_id AND m.user_id=v_master AND upper(m.role)='GM'
  ) THEN
    RAISE EXCEPTION 'O pedido não foi emitido por um Mestre autorizado.';
  END IF;

  v_save_type:=lower(COALESCE(v_request.data->>'save_type',''));
  IF v_save_type NOT IN ('fortitude','reflex','will') THEN
    RAISE EXCEPTION 'Tipo de resistência inválido no pedido.';
  END IF;
  v_context:=lower(COALESCE(v_request.data->>'context',''));
  IF v_context NOT IN ('','trap','poison','spell','enchantment','fear','fear,enchantment','spell,enchantment','spell,fear','spell,fear,enchantment') THEN
    RAISE EXCEPTION 'Contexto de resistência inválido no pedido.';
  END IF;
  v_dc:=CASE WHEN COALESCE(v_request.data->>'dc','') ~ '^[0-9]{1,3}$'
             THEN (v_request.data->>'dc')::integer ELSE NULL END;
  IF v_dc IS NOT NULL AND v_dc NOT BETWEEN 1 AND 100 THEN
    RAISE EXCEPTION 'Classe de dificuldade inválida.';
  END IF;

  v_bonus:=priv.srd_saving_throw_bonus(
    p_campaign_id,'character',v_character.id::text,v_save_type,NULLIF(v_context,'')
  );
  v_base_bonus:=priv.srd_saving_throw_bonus(
    p_campaign_id,'character',v_character.id::text,v_save_type,NULL
  );
  v_total:=p_d20+v_bonus;
  v_result:=jsonb_build_object(
    'request_id',p_request_id,
    'character_id',v_character.id::text,
    'character_name',v_character.nome,
    'save_type',v_save_type,
    'context',NULLIF(v_context,''),
    'd20',p_d20,
    'bonus',v_bonus,
    'total',v_total,
    'dc',v_dc,
    'success',CASE WHEN v_dc IS NULL THEN NULL ELSE v_total>=v_dc END,
    'trap_sense_bonus',CASE WHEN v_context='trap' AND v_save_type='reflex' THEN v_bonus-v_base_bonus ELSE 0 END
  );

  UPDATE public.campaign_log
     SET data=jsonb_set(
       jsonb_set(COALESCE(data,'{}'::jsonb),'{results}',COALESCE(data->'results','{}'::jsonb),true),
       ARRAY['results',v_character.id::text],v_result,true
     )
   WHERE id=v_request.id;

  RETURN v_result;
END;
$function$
;