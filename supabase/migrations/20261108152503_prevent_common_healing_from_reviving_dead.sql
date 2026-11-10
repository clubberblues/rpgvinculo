
DO $migration$
DECLARE
  v_def text; v_old text; v_new text; v_count integer;
BEGIN
  v_def:=pg_get_functiondef('public.conjurar_magia_srd(text,text,smallint,text)'::regprocedure);

  v_old:=$old$IF v_target_max_hp IS NULL OR v_target_max_hp<0 THEN RAISE EXCEPTION 'PV máximo válido ausente na ficha do conjurador'; END IF;
        v_target_hp:=least(v_target_max_hp,greatest(0,coalesce(v_target_hp,0)+v_healing));
        UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=p_character_id;$old$;
  v_new:=$new$IF v_target_max_hp IS NULL OR v_target_max_hp<0 THEN RAISE EXCEPTION 'PV máximo válido ausente na ficha do conjurador'; END IF;
        IF COALESCE(v_target_hp,0)<=-10 OR priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'no_healing') THEN
          RAISE EXCEPTION 'Personagens mortos não podem receber cura comum.';
        END IF;
        v_target_hp:=least(v_target_max_hp,coalesce(v_target_hp,0)+v_healing);
        UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=p_character_id;
        PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),v_target_hp,
          v_target_hp<0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=v_campaign_id AND cc.target_kind='character' AND cc.target_id=BTRIM(p_character_id) AND cc.condition_id='stable' AND cc.active=true));$new$;
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Bloco de cura no próprio personagem não é único: %.',v_count; END IF;
  v_def:=replace(v_def,v_old,v_new);

  v_old:=$old$IF v_target_max_hp IS NULL OR v_target_max_hp<0 THEN RAISE EXCEPTION 'PV máximo válido ausente na ficha do alvo'; END IF;
        v_target_hp:=least(v_target_max_hp,greatest(0,coalesce(v_target_hp,0)+v_healing));
        UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=v_target_character_id;$old$;
  v_new:=$new$IF v_target_max_hp IS NULL OR v_target_max_hp<0 THEN RAISE EXCEPTION 'PV máximo válido ausente na ficha do alvo'; END IF;
        IF COALESCE(v_target_hp,0)<=-10 OR priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(v_target_character_id),'no_healing') THEN
          RAISE EXCEPTION 'Personagens mortos não podem receber cura comum.';
        END IF;
        v_target_hp:=least(v_target_max_hp,coalesce(v_target_hp,0)+v_healing);
        UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=v_target_character_id;
        PERFORM priv.srd_sync_character_vital_condition(BTRIM(v_target_character_id),v_target_hp,
          v_target_hp<0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=v_campaign_id AND cc.target_kind='character' AND cc.target_id=BTRIM(v_target_character_id) AND cc.condition_id='stable' AND cc.active=true));$new$;
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Bloco de cura em alvo jogador não é único: %.',v_count; END IF;
  v_def:=replace(v_def,v_old,v_new);

  v_old:=$old$IF coalesce(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN
        RAISE EXCEPTION 'O token NPC/monstro precisa de maxHp válido para receber cura';
      END IF;
      v_target_max_hp:=(v_token->>'maxHp')::integer;
      IF v_target_max_hp>100000 THEN RAISE EXCEPTION 'maxHp do token excede o limite aceito'; END IF;
      v_target_hp:=CASE WHEN coalesce(v_token->>'hp','') ~ '^[0-9]{1,6}$' THEN (v_token->>'hp')::integer ELSE v_target_max_hp END;
      v_target_hp:=least(v_target_max_hp,greatest(0,v_target_hp+v_healing));
      v_token:=v_token||jsonb_build_object('hp',v_target_hp,'maxHp',v_target_max_hp);
      v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
      v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
      UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;$old$;
  v_new:=$new$IF coalesce(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN
        RAISE EXCEPTION 'O token NPC/monstro precisa de maxHp válido para receber cura';
      END IF;
      v_target_max_hp:=(v_token->>'maxHp')::integer;
      IF v_target_max_hp>100000 THEN RAISE EXCEPTION 'maxHp do token excede o limite aceito'; END IF;
      IF COALESCE(v_token->>'hp','') ~ '^-?[0-9]{1,6}$' AND (v_token->>'hp')::integer<=-10 THEN
        RAISE EXCEPTION 'Criaturas mortas não podem receber cura comum.';
      END IF;
      IF EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
        WHERE cc.campaign_id=v_campaign_id AND cc.target_kind='token'
          AND cc.target_id IN (v_token->>'id',v_target_key)
          AND cc.condition_id='dead' AND cc.active=true) THEN
        RAISE EXCEPTION 'Criaturas mortas não podem receber cura comum.';
      END IF;
      v_target_hp:=CASE WHEN coalesce(v_token->>'hp','') ~ '^-?[0-9]{1,6}$' THEN (v_token->>'hp')::integer ELSE v_target_max_hp END;
      v_target_hp:=least(v_target_max_hp,v_target_hp+v_healing);
      v_token:=v_token||jsonb_build_object('hp',v_target_hp,'maxHp',v_target_max_hp);
      v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
      v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
      UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;
      IF v_target_type='npc' AND NULLIF(v_token->>'sourceCharacterId','') IS NOT NULL THEN
        PERFORM priv.srd_sync_linked_npc_token_vitals(v_campaign_id,COALESCE(NULLIF(v_token->>'id',''),v_target_key),v_target_hp,v_target_max_hp,
          v_target_hp<0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
            WHERE cc.campaign_id=v_campaign_id AND cc.target_kind='token'
              AND cc.target_id IN (v_token->>'id',v_target_key) AND cc.condition_id='stable' AND cc.active=true));
      END IF;$new$;
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Bloco de cura em token NPC/monstro não é único: %.',v_count; END IF;
  v_def:=replace(v_def,v_old,v_new);
  EXECUTE v_def;

  v_def:=pg_get_functiondef('public.usar_pocao_cura_srd(text,text)'::regprocedure);
  v_old:=$old$IF NOT FOUND OR v_max_hp IS NULL THEN RAISE EXCEPTION 'Ficha SRD sem PV máximo.'; END IF;$old$;
  v_new:=$new$IF NOT FOUND OR v_max_hp IS NULL THEN RAISE EXCEPTION 'Ficha SRD sem PV máximo.'; END IF;
  IF COALESCE(v_current_hp,0)<=-10 OR EXISTS(
    SELECT 1 FROM public.characters ch
    JOIN public.srd_campaign_conditions cc ON cc.campaign_id=ch.campaign_id
    WHERE ch.id::text=BTRIM(p_character_id) AND cc.target_kind='character'
      AND cc.target_id=BTRIM(p_character_id) AND cc.condition_id='dead' AND cc.active=true
  ) THEN RAISE EXCEPTION 'Personagens mortos não podem receber cura comum.'; END IF;$new$;
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Validação da poção de cura não é única: %.',v_count; END IF;
  v_def:=replace(v_def,v_old,v_new);
  v_old:=$old$  RETURNING pv_atual INTO v_current_hp;$old$;
  v_new:=$new$  RETURNING pv_atual INTO v_current_hp;
  PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),v_current_hp,
    v_current_hp<0 AND EXISTS(SELECT 1 FROM public.characters ch JOIN public.srd_campaign_conditions cc
      ON cc.campaign_id=ch.campaign_id WHERE ch.id::text=BTRIM(p_character_id)
        AND cc.target_kind='character' AND cc.target_id=BTRIM(p_character_id)
        AND cc.condition_id='stable' AND cc.active=true));$new$;
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Sincronização de estado vital após poção não é única: %.',v_count; END IF;
  v_def:=replace(v_def,v_old,v_new);
  EXECUTE v_def;
END;
$migration$;
