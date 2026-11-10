
DO $migration$
DECLARE v_def text;v_old text;v_new text;v_count integer;
BEGIN
 v_def:=pg_get_functiondef('public.conjurar_magia_srd_manual(text,text,smallint,text,integer[])'::regprocedure);
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
 IF v_count<>1 THEN RAISE EXCEPTION 'Bloco de cura manual de token não é único: %.',v_count; END IF;
 EXECUTE replace(v_def,v_old,v_new);
END;
$migration$;
