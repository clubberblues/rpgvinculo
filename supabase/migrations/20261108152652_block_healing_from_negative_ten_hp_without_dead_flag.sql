
DO $migration$
DECLARE v_def text;v_old text;v_new text;v_count integer;
BEGIN
 v_def:=pg_get_functiondef('public.alterar_pv_token_cba(bigint,text,integer,integer)'::regprocedure);
 v_old:=$old$IF EXISTS (SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token' AND cc.target_id=p_token_id AND cc.condition_id='dead' AND cc.active=true) THEN RAISE EXCEPTION 'Uma criatura morta não pode ser recuperada por ajuste comum de PV.'; END IF;$old$;
 v_new:=$new$IF v_hp<=-10 OR EXISTS (SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='token' AND cc.target_id=p_token_id AND cc.condition_id='dead' AND cc.active=true) THEN RAISE EXCEPTION 'Uma criatura morta não pode ser recuperada por ajuste comum de PV.'; END IF;$new$;
 v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
 IF v_count<>1 THEN RAISE EXCEPTION 'Bloqueio de ressurreição por ajuste de PV não é único: %.',v_count; END IF;
 EXECUTE replace(v_def,v_old,v_new);

 v_def:=pg_get_functiondef('public.usar_habilidade_classe_srd(text,text,text,integer)'::regprocedure);
 v_old:=$old$IF EXISTS (SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=v_character.campaign_id AND cc.target_kind='token' AND cc.target_id IN (v_token->>'id',v_token->>'key') AND cc.condition_id='dead' AND cc.active=true) THEN RAISE EXCEPTION 'Imposição das Mãos não pode recuperar uma criatura morta.'; END IF;$old$;
 v_new:=$new$IF v_hp<=-10 OR EXISTS (SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=v_character.campaign_id AND cc.target_kind='token' AND cc.target_id IN (v_token->>'id',v_token->>'key') AND cc.condition_id='dead' AND cc.active=true) THEN RAISE EXCEPTION 'Imposição das Mãos não pode recuperar uma criatura morta.'; END IF;$new$;
 v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
 IF v_count<>1 THEN RAISE EXCEPTION 'Bloqueio de ressurreição por Imposição das Mãos não é único: %.',v_count; END IF;
 EXECUTE replace(v_def,v_old,v_new);
END;
$migration$;
