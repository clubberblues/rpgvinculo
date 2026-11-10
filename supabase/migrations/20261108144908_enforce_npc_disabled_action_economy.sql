
DO $migration$
DECLARE
  v_sig text; v_def text; v_old text; v_new text; v_count integer;
BEGIN
  v_sig:='public.consumir_acao_token_gm_srd(bigint,text,text)';
  v_def:=pg_get_functiondef(v_sig::regprocedure);
  v_old:=' v_round integer;';
  v_new:=' v_round integer; v_tokens jsonb; v_token jsonb; v_token_index bigint; v_token_count integer; v_hp integer; v_max_hp integer;';
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Declarações da economia de ações do token não únicas: %.',v_count; END IF;
  v_def:=replace(v_def,v_old,v_new);
  v_old:=' UPDATE public.campaigns SET combat_data=v_combat WHERE id=p_campaign_id;';
  v_new:=E' IF v_action=''padrao'' AND priv.srd_condition_has_flag(p_campaign_id,''token'',btrim(p_token_id),''strenuous_action_cost_1hp'') THEN\n'||
    E'  v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->''tokens'')=''array'' THEN v_campaign.cba_data->''tokens'' ELSE ''[]''::jsonb END;\n'||
    E'  SELECT count(*)::integer,min(t.ordinality),(array_agg(t.token ORDER BY t.ordinality))[1]\n'||
    E'    INTO v_token_count,v_token_index,v_token FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality)\n'||
    E'   WHERE t.token->>''id''=btrim(p_token_id) AND t.token->>''tipo''=''npc'';\n'||
    E'  IF v_token_count=1 AND COALESCE(v_token->>''hp'','''') ~ ''^[0-9]{1,6}$'' AND (v_token->>''hp'')::integer=0 THEN\n'||
    E'   v_hp:=-1; v_max_hp:=NULLIF(v_token->>''maxHp'','''')::integer;\n'||
    E'   v_token:=v_token||jsonb_build_object(''hp'',v_hp);\n'||
    E'   SELECT COALESCE(jsonb_agg(CASE WHEN t.ordinality=v_token_index THEN v_token ELSE t.token END ORDER BY t.ordinality),''[]''::jsonb) INTO v_tokens\n'||
    E'     FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality);\n'||
    E'   UPDATE public.campaigns SET cba_data=COALESCE(cba_data,''{}''::jsonb)||jsonb_build_object(''tokens'',v_tokens) WHERE id=p_campaign_id;\n'||
    E'   IF v_max_hp IS NOT NULL AND v_max_hp>0 AND NULLIF(BTRIM(v_token->>''sourceCharacterId''),'''') IS NOT NULL THEN\n'||
    E'    PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_hp,v_max_hp,false);\n'||
    E'   END IF;\n'||
    E'  END IF;\n'||
    E' END IF;\n'||
    v_old;
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Ponto de custo por ação extenuante não único: %.',v_count; END IF;
  v_def:=replace(v_def,v_old,v_new);
  EXECUTE v_def;

  v_sig:='public.mover_token_gm_cba_srd(bigint,text,integer,integer)';
  v_def:=pg_get_functiondef(v_sig::regprocedure);
  v_old:='  IF COALESCE(v_token_actions->>''movimento'', ''false'') = ''true'' AND v_used_squares=0 THEN';
  v_new:='  IF priv.srd_condition_has_flag(p_campaign_id,''token'',BTRIM(p_token_id),''one_move_or_standard'') AND COALESCE(v_token_actions->>''padrao'',''false'')=''true'' THEN RAISE EXCEPTION ''A condição permite apenas uma ação padrão ou de movimento por rodada.''; END IF;'||
    E'\n'||v_old;
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Ponto de validação de movimento limitado não único: %.',v_count; END IF;
  EXECUTE replace(v_def,v_old,v_new);
END;
$migration$;
