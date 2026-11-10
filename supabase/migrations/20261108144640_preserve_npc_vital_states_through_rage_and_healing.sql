
DO $migration$
DECLARE
  v_sig text; v_def text; v_old text; v_new text; v_count integer;
BEGIN
  v_sig:='priv.srd_end_barbarian_rage_token(bigint,text,boolean)';
  v_def:=pg_get_functiondef(v_sig::regprocedure);
  v_old:='COALESCE(v_token->>''hp'','''') !~ ''^[0-9]{1,6}$''';
  v_new:='COALESCE(v_token->>''hp'','''') !~ ''^-?[0-9]{1,6}$''';
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Validação de PV da Fúria não única: %.',v_count; END IF;
  v_def:=replace(v_def,v_old,v_new);
  v_old:='GREATEST(0,LEAST(v_new_max,v_hp))';
  v_new:='GREATEST(-10,LEAST(v_new_max,v_hp))';
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Cálculo de PV ao encerrar Fúria não único: %.',v_count; END IF;
  v_def:=replace(v_def,v_old,v_new);
  v_old:='UPDATE public.campaigns SET cba_data=COALESCE(cba_data,''{}''::jsonb)||jsonb_build_object(''tokens'',v_tokens) WHERE id=p_campaign_id;';
  v_new:=v_old||E'\n PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_new_hp,v_new_max);';
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Ponto de sincronização ao encerrar Fúria não único: %.',v_count; END IF;
  v_def:=replace(v_def,v_old,v_new);
  EXECUTE v_def;

  v_sig:='public.alterar_pv_token_cba(bigint,text,integer,integer)';
  v_def:=pg_get_functiondef(v_sig::regprocedure);
  v_old:='v_hp := GREATEST(0,LEAST(v_max,v_hp+COALESCE(p_variacao,0)));';
  v_new:='IF EXISTS (SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=p_campaign_id AND cc.target_kind=''token'' AND cc.target_id=p_token_id AND cc.condition_id=''dead'' AND cc.active=true) THEN RAISE EXCEPTION ''Uma criatura morta não pode ser recuperada por ajuste comum de PV.''; END IF;'||
    E'\n  v_hp := GREATEST(-10,LEAST(v_max,v_hp+COALESCE(p_variacao,0)));';
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Cálculo de ajuste manual de PV não único: %.',v_count; END IF;
  EXECUTE replace(v_def,v_old,v_new);

  v_sig:='public.usar_habilidade_classe_srd(text,text,text,integer)';
  v_def:=pg_get_functiondef(v_sig::regprocedure);
  v_old:='v_hp:=CASE WHEN COALESCE(v_token->>''hp'','''') ~ ''^[0-9]{1,6}$'' THEN (v_token->>''hp'')::integer ELSE v_max_hp END;';
  v_new:='v_hp:=CASE WHEN COALESCE(v_token->>''hp'','''') ~ ''^-?[0-9]{1,6}$'' THEN (v_token->>''hp'')::integer ELSE v_max_hp END;'||
    E'\n      IF EXISTS (SELECT 1 FROM public.srd_campaign_conditions cc WHERE cc.campaign_id=v_character.campaign_id AND cc.target_kind=''token'' AND cc.target_id IN (v_token->>''id'',v_token->>''key'') AND cc.condition_id=''dead'' AND cc.active=true) THEN RAISE EXCEPTION ''Imposição das Mãos não pode recuperar uma criatura morta.''; END IF;';
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Leitura de PV para cura de NPC não única: %.',v_count; END IF;
  EXECUTE replace(v_def,v_old,v_new);
END;
$migration$;
