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
REVOKE ALL ON FUNCTION public.srd_resolve_pending_spell_save(uuid,integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.srd_resolve_pending_spell_save(uuid,integer) TO authenticated;