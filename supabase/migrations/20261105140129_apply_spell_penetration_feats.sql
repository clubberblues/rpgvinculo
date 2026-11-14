BEGIN;
UPDATE public.srd_feats
SET mechanics = jsonb_set(
  jsonb_set(
    jsonb_set(mechanics,'{activation}','{"mode":"passive","action_type":"no_action","trigger":null}'::jsonb,true),
    '{resolution}',
    CASE id
      WHEN 'srd35_feat_spell_penetration' THEN '{"attack":null,"effects":[{"kind":"modifier","stat":"spell_penetration","value":2,"bonus_type":"untyped"}],"saving_throw":null}'::jsonb
      WHEN 'srd35_feat_greater_spell_penetration' THEN '{"attack":null,"effects":[{"kind":"modifier","stat":"spell_penetration","value":2,"bonus_type":"untyped"}],"saving_throw":null}'::jsonb
    END,
    true
  ),
  '{engine_status}','"ready"'::jsonb,true
) || jsonb_build_object('review_reason','Bônus passivo de +2 em testes de nível de conjurador para superar Resistência à Magia; o bônus de Penetração de Magia Maior acumula com Penetração Mágica. O resolvedor do servidor soma os efeitos estruturados da ficha.')
WHERE id IN ('srd35_feat_spell_penetration','srd35_feat_greater_spell_penetration')
  AND mechanics->>'engine_status'='needs_review';
CREATE OR REPLACE FUNCTION priv.srd_spell_penetration_feat_bonus(p_character_id text)
RETURNS integer
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
  SELECT COALESCE(SUM((effect.value->>'value')::integer),0)::integer
    FROM public.srd_character_sheets AS sheet
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(sheet.talentos)='array' THEN sheet.talentos ELSE '[]'::jsonb END
    ) AS chosen(value)
    JOIN public.srd_feats AS feat
      ON feat.id=COALESCE(chosen.value->>'id',chosen.value #>> '{}')
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(feat.mechanics#>'{resolution,effects}')='array'
        THEN feat.mechanics#>'{resolution,effects}' ELSE '[]'::jsonb END
    ) AS effect(value)
   WHERE sheet.character_id::text=BTRIM(p_character_id)
     AND feat.mechanics->>'engine_status' IN ('ready','implemented')
     AND feat.mechanics->'activation'->>'mode'='passive'
     AND effect.value->>'kind'='modifier'
     AND effect.value->>'stat'='spell_penetration'
     AND COALESCE(effect.value->>'value','') ~ '^[0-9]+$';
$function$;
REVOKE ALL ON FUNCTION priv.srd_spell_penetration_feat_bonus(text) FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.srd_resolve_pending_spell_resistance(p_pending_id uuid, p_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE v_pending priv.srd_pending_spell_resolutions%ROWTYPE; v_user uuid; v_sr integer; v_total integer; v_feat_bonus integer:=0;
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
  v_feat_bonus:=priv.srd_spell_penetration_feat_bonus(v_pending.caster_character_id);
  v_total:=p_d20+v_pending.caster_level+v_feat_bonus;
  IF v_total<v_sr THEN
    UPDATE priv.srd_pending_spell_resolutions SET status='resisted',resolved_at=now() WHERE pending_id=p_pending_id;
    RETURN jsonb_build_object('pending_id',p_pending_id,'status','resisted','total',v_total,'spell_resistance',v_sr,'caster_level',v_pending.caster_level,'feat_bonus',v_feat_bonus);
  END IF;
  IF v_pending.save_type IS NOT NULL THEN
    UPDATE priv.srd_pending_spell_resolutions SET status='pending_save' WHERE pending_id=p_pending_id;
    INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
    VALUES(v_pending.campaign_id,'test_request','PUBLIC',jsonb_build_object(
      'tipo','Resistência de '||CASE v_pending.save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
      'alvos',CASE WHEN v_pending.target_kind='character' THEN jsonb_build_array(v_pending.target_id) ELSE '[]'::jsonb END,
      'npc_alvos',CASE WHEN v_pending.target_kind='token' THEN jsonb_build_array(v_pending.target_id) ELSE '[]'::jsonb END,
      'mestre','Sistema','mestre_id',auth.uid(),'request_id',p_pending_id::text,
      'resolution_type','spell_save','pending_id',p_pending_id,'spell_id',v_pending.spell_id,
      'save_type',v_pending.save_type,'save_dc',v_pending.save_dc
    ));
    RETURN jsonb_build_object('pending_id',p_pending_id,'status','penetrated','requires_save',true,
      'total',v_total,'spell_resistance',v_sr,'save_type',v_pending.save_type,'save_dc',v_pending.save_dc);
  END IF;
  RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)||jsonb_build_object('status','penetrated','total',v_total,'spell_resistance',v_sr,'caster_level',v_pending.caster_level,'feat_bonus',v_feat_bonus);
END;
$function$
;
COMMIT;