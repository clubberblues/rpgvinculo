-- Encaminha a escola da magia para o cálculo de resistência e implementa
-- Vontade Indomável: +4 contra Encantamento enquanto em Fúria a partir do nível 14.
CREATE OR REPLACE FUNCTION priv.srd_saving_throw_bonus(p_campaign_id bigint, p_target_kind text, p_target_id text, p_save_type text, p_context text DEFAULT NULL::text)
 RETURNS integer
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_save text:=lower(COALESCE(p_save_type,''));
  v_ability text;
  v_score integer;
  v_base integer:=0;
  v_bonus integer:=0;
  v_save_text text;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_token jsonb;
  v_feats jsonb; v_ability_effect text; v_charisma_score integer; v_paladin_level integer:=0; v_barbarian_level integer:=0;
BEGIN
  IF v_save NOT IN ('fortitude','reflex','will') THEN RAISE EXCEPTION 'Tipo de resistência inválido.'; END IF;
  IF p_target_kind='character' THEN
    SELECT sh.* INTO v_sheet
    FROM public.srd_character_sheets sh
    JOIN public.characters ch ON ch.id=sh.character_id
    WHERE ch.id::text=BTRIM(p_target_id) AND ch.campaign_id=p_campaign_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Ficha do alvo não encontrada para calcular resistência.'; END IF;
    v_ability:=CASE v_save WHEN 'fortitude' THEN 'CON' WHEN 'reflex' THEN 'DES' ELSE 'SAB' END;
    v_score:=COALESCE(NULLIF(v_sheet.atributos->>v_ability,'')::integer,10);
    v_ability_effect:=CASE v_save WHEN 'fortitude' THEN 'constitution' WHEN 'reflex' THEN 'dexterity' ELSE 'wisdom' END;
    v_score:=v_score+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_target_id),v_ability_effect);
    v_feats:=COALESCE(v_sheet.talentos,'[]'::jsonb);
    SELECT COALESCE(sum(CASE v_save WHEN 'fortitude' THEN pr.base_fortitude WHEN 'reflex' THEN pr.base_reflex ELSE pr.base_will END),0)::integer
      INTO v_base
      FROM public.srd_character_class_levels cl
      JOIN public.srd_class_level_progressions pr ON pr.class_id=cl.class_id AND pr.class_level=cl.class_level
     WHERE cl.character_id=v_sheet.character_id;
    IF NOT EXISTS(SELECT 1 FROM public.srd_character_class_levels WHERE character_id=v_sheet.character_id) THEN
      SELECT CASE v_save WHEN 'fortitude' THEN pr.base_fortitude WHEN 'reflex' THEN pr.base_reflex ELSE pr.base_will END
        INTO v_base
        FROM public.srd_class_level_progressions pr
       WHERE pr.class_id=v_sheet.classe_id AND pr.class_level=v_sheet.nivel;
      IF v_base IS NULL THEN
        SELECT CASE v_save
          WHEN 'fortitude' THEN CASE WHEN cl.fort_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END
          WHEN 'reflex' THEN CASE WHEN cl.ref_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END
          ELSE CASE WHEN cl.von_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END
        END INTO v_base FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
      END IF;
    END IF;
    v_bonus:=COALESCE(v_base,0)+FLOOR((v_score-10)::numeric/2)::integer;
    IF jsonb_typeof(v_feats)='array' THEN
      IF v_save='fortitude' AND EXISTS(SELECT 1 FROM jsonb_array_elements(v_feats) f WHERE COALESCE(f->>'id',f#>>'{}')='srd35_feat_great_fortitude') THEN v_bonus:=v_bonus+2; END IF;
      IF v_save='reflex' AND EXISTS(SELECT 1 FROM jsonb_array_elements(v_feats) f WHERE COALESCE(f->>'id',f#>>'{}')='srd35_feat_lightning_reflexes') THEN v_bonus:=v_bonus+2; END IF;
      IF v_save='will' AND EXISTS(SELECT 1 FROM jsonb_array_elements(v_feats) f WHERE COALESCE(f->>'id',f#>>'{}')='srd35_feat_iron_will') THEN v_bonus:=v_bonus+2; END IF;
    END IF;
  ELSIF p_target_kind='token' THEN
    SELECT t.value INTO v_token
    FROM public.campaigns c
    CROSS JOIN LATERAL jsonb_array_elements(CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array' THEN c.cba_data->'tokens' ELSE '[]'::jsonb END) t(value)
    WHERE c.id=p_campaign_id AND (t.value->>'id'=BTRIM(p_target_id) OR t.value->>'key'=BTRIM(p_target_id)) LIMIT 1;
    IF v_token IS NULL THEN RAISE EXCEPTION 'Token-alvo não encontrado para calcular resistência.'; END IF;
    v_save_text:=CASE v_save
      WHEN 'fortitude' THEN COALESCE(v_token->'monsterStats'->>'fortitude',v_token->'monsterStats'->>'fort')
      WHEN 'reflex' THEN COALESCE(v_token->'monsterStats'->>'reflexos',v_token->'monsterStats'->>'reflex')
      ELSE COALESCE(v_token->'monsterStats'->>'vontade',v_token->'monsterStats'->>'will') END;
    v_base:=COALESCE(NULLIF(substring(COALESCE(v_save_text,'') FROM '[-+]?[0-9]+'),'')::integer,0);
    v_bonus:=v_base;
  ELSE
    RAISE EXCEPTION 'Tipo de alvo inválido para resistência.';
  END IF;
  -- D&D 3.5: Graça Divina adiciona o modificador positivo de Carisma a todos os testes de resistência a partir do 2º nível de Paladino.
  IF p_target_kind='character' THEN
    SELECT COALESCE(MAX(cl.class_level),0) INTO v_paladin_level
      FROM public.srd_character_class_levels cl
      JOIN public.srd_classes cls ON cls.id=cl.class_id
     WHERE cl.character_id=v_sheet.character_id AND cls.class_key='paladin';
    IF v_paladin_level=0 AND NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels WHERE character_id=v_sheet.character_id)
       AND v_sheet.classe_id='paladino' THEN
      v_paladin_level:=v_sheet.nivel;
    END IF;
    IF v_paladin_level>=2 THEN
      v_charisma_score:=COALESCE(NULLIF(v_sheet.atributos->>'CAR','')::integer,10);
      v_bonus:=v_bonus+GREATEST(0,FLOOR((v_charisma_score-10)::numeric/2)::integer);
    END IF;
  END IF;
  v_bonus:=v_bonus
    +priv.srd_effective_modifier(p_campaign_id,p_target_kind,BTRIM(p_target_id),v_save)
    +priv.srd_effective_modifier(p_campaign_id,p_target_kind,BTRIM(p_target_id),'saving_throw');
  IF lower(COALESCE(p_context,'')) LIKE '%fear%' THEN
    v_bonus:=v_bonus+priv.srd_effective_modifier(p_campaign_id,p_target_kind,BTRIM(p_target_id),'fear_saving_throw');
  END IF;
  -- Indomitable Will (Bárbaro 14): +4 contra magias da escola Encantamento,
  -- enquanto estiver em Fúria. É bônus separado e acumula com o bônus moral da Fúria.
  IF v_save='will' AND lower(COALESCE(p_context,'')) LIKE '%enchantment%'
     AND p_target_kind='character'
     AND priv.srd_effect_has_flag(p_campaign_id,p_target_kind,BTRIM(p_target_id),'rage_active') THEN
    SELECT COALESCE(
      MAX(cl.class_level) FILTER (WHERE cls.class_key='barbarian'),
      CASE WHEN NOT EXISTS (
        SELECT 1 FROM public.srd_character_class_levels any_level
         WHERE any_level.character_id=v_sheet.character_id
      ) AND v_sheet.classe_id='barbaro'
      THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
    )
      INTO v_barbarian_level
      FROM public.srd_character_sheets sh
      LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
      LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
     WHERE sh.character_id=v_sheet.character_id
     GROUP BY sh.character_id,sh.classe_id,sh.nivel;
    IF COALESCE(v_barbarian_level,0)>=14 THEN v_bonus:=v_bonus+4; END IF;
  END IF;
  RETURN v_bonus;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.srd_resolve_pending_spell_save(p_pending_id uuid, p_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE v_pending priv.srd_pending_spell_resolutions%ROWTYPE; v_user_id uuid; v_bonus integer; v_total integer; v_sr integer; v_caster_user uuid; v_round integer; v_school text; v_context text;
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
           CASE WHEN effect_data->>'save_result'='half' THEN
             jsonb_set(effect_data,'{damage}',
               to_jsonb(GREATEST(0,FLOOR(COALESCE(NULLIF(effect_data->>'damage','')::numeric,0)/2)::integer)),true)
           ELSE effect_data END
         )||jsonb_build_object('apply_secondary_condition',false)
       WHERE pending_id=p_pending_id;
      RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)
        ||jsonb_build_object('saved',true,'save_total',v_total,'save_bonus',v_bonus,'save_dc',v_pending.save_dc,'save_result',v_pending.effect_data->>'save_result');
    END IF;
    UPDATE priv.srd_pending_spell_resolutions SET status='saved',resolved_at=now() WHERE pending_id=p_pending_id;
    RETURN jsonb_build_object('pending_id',p_pending_id,'saved',true,'total',v_total,'bonus',v_bonus,'dc',v_pending.save_dc,'status','saved');
  END IF;
  RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)
    || jsonb_build_object('saved',false,'save_total',v_total,'save_bonus',v_bonus,'save_dc',v_pending.save_dc);
END;
$function$
;
