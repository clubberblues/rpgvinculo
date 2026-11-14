
DO $migration$
DECLARE v_def text;v_old text;v_new text;v_count integer;v_anchor text;v_insert text;
BEGIN
 v_def:=pg_get_functiondef('public.conjurar_magia_srd_multialvo_v3(text,text,smallint,text[],integer[])'::regprocedure);
 v_old:=$old$IF v_is_undead THEN RAISE EXCEPTION 'Personagem jogador não pode ser classificado como morto-vivo'; END IF;
      SELECT sh.pv_atual,sh.pv_max INTO v_hp,v_max_hp
      FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id::text=ch.id::text
      WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
      FOR UPDATE OF sh;
      IF NOT FOUND THEN RAISE EXCEPTION 'Ficha do alvo não encontrada: %',v_key; END IF;
      v_hp:=least(v_max_hp,greatest(0,coalesce(v_hp,0)+v_healing));
      UPDATE public.srd_character_sheets SET pv_atual=v_hp WHERE character_id::text=v_target_character_id;$old$;
 v_new:=$new$IF v_is_undead THEN RAISE EXCEPTION 'Personagem jogador não pode ser classificado como morto-vivo'; END IF;
      SELECT sh.pv_atual,sh.pv_max INTO v_hp,v_max_hp
      FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id::text=ch.id::text
      WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
      FOR UPDATE OF sh;
      IF NOT FOUND THEN RAISE EXCEPTION 'Ficha do alvo não encontrada: %',v_key; END IF;
      IF COALESCE(v_hp,0)<=-10 OR priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(v_target_character_id),'no_healing') THEN
        RAISE EXCEPTION 'Personagens mortos não podem receber cura comum.';
      END IF;
      v_hp:=LEAST(v_max_hp,COALESCE(v_hp,0)+v_healing);
      UPDATE public.srd_character_sheets SET pv_atual=v_hp WHERE character_id::text=v_target_character_id;
      PERFORM priv.srd_sync_character_vital_condition(BTRIM(v_target_character_id),v_hp,
        v_hp<0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc
          WHERE cc.campaign_id=v_campaign_id AND cc.target_kind='character'
            AND cc.target_id=BTRIM(v_target_character_id) AND cc.condition_id='stable' AND cc.active=true));$new$;
 v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
 IF v_count<>1 THEN RAISE EXCEPTION 'Bloco de cura em massa para jogador não é único: %.',v_count; END IF;
 v_def:=replace(v_def,v_old,v_new);

 v_old:=$old$IF coalesce(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$'
         OR coalesce(v_token->>'hp','') !~ '^[0-9]{1,6}$'
      THEN RAISE EXCEPTION 'Token sem HP válido: %',v_key; END IF;
      v_max_hp:=(v_token->>'maxHp')::integer;
      v_hp:=CASE WHEN v_is_undead
                 THEN greatest(0,(v_token->>'hp')::integer-v_healing)
                 ELSE least(v_max_hp,greatest(0,(v_token->>'hp')::integer+v_healing)) END;$old$;
 v_new:=$new$IF coalesce(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$'
         OR coalesce(v_token->>'hp','') !~ '^-?[0-9]{1,6}$'
      THEN RAISE EXCEPTION 'Token sem HP válido: %',v_key; END IF;
      v_max_hp:=(v_token->>'maxHp')::integer;
      IF NOT v_is_undead AND ((v_token->>'hp')::integer<=-10 OR EXISTS(
        SELECT 1 FROM public.srd_campaign_conditions cc
        WHERE cc.campaign_id=v_campaign_id AND cc.target_kind='token'
          AND cc.target_id IN (v_token->>'id',v_key)
          AND cc.condition_id='dead' AND cc.active=true
      )) THEN RAISE EXCEPTION 'Criaturas mortas não podem receber cura comum.'; END IF;
      v_hp:=CASE
        WHEN v_is_undead THEN CASE WHEN (v_token->>'hp')::integer<=-10 THEN -10 ELSE GREATEST(-10,(v_token->>'hp')::integer-v_healing) END
        ELSE LEAST(v_max_hp,(v_token->>'hp')::integer+v_healing)
      END;$new$;
 v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
 IF v_count<>1 THEN RAISE EXCEPTION 'Bloco de cura em massa para tokens não é único: %.',v_count; END IF;
 v_def:=replace(v_def,v_old,v_new);

 v_anchor:='  UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;';
 v_insert:=v_anchor||E'\n  FOREACH v_key IN ARRAY p_target_token_keys LOOP\n'||
   E'    SELECT e.token INTO v_token FROM jsonb_array_elements(v_tokens) e(token) WHERE e.token->>''key''=BTRIM(v_key) LIMIT 1;\n'||
   E'    IF v_token->>''tipo''=''npc'' AND NULLIF(v_token->>''sourceCharacterId'','''') IS NOT NULL THEN\n'||
   E'      PERFORM priv.srd_sync_linked_npc_token_vitals(v_campaign_id,COALESCE(NULLIF(v_token->>''id'',''''),BTRIM(v_key)),(v_token->>''hp'')::integer,(v_token->>''maxHp'')::integer,\n'||
   E'        (v_token->>''hp'')::integer<0 AND EXISTS(SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=v_campaign_id AND cc.target_kind=''token'' AND cc.target_id IN (v_token->>''id'',BTRIM(v_key)) AND cc.condition_id=''stable'' AND cc.active=true));\n'||
   E'    END IF;\n'||
   E'  END LOOP;';
 v_count:=(length(v_def)-length(replace(v_def,v_anchor,'')))/length(v_anchor);
 IF v_count<>1 THEN RAISE EXCEPTION 'Ponto de sincronização de cura em massa não é único: %.',v_count; END IF;
 v_def:=replace(v_def,v_anchor,v_insert);
 EXECUTE v_def;
END;
$migration$;
