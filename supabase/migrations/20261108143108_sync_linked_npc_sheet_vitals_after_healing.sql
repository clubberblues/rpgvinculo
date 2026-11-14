
DO $migration$
DECLARE
  v_sig text;
  v_def text;
  v_old text;
  v_new text;
  v_count integer;
BEGIN
  v_sig:='public.alterar_pv_token_cba(bigint,text,integer,integer)';
  v_def:=pg_get_functiondef(v_sig::regprocedure);
  v_old:='UPDATE public.campaigns SET cba_data=v_scene WHERE id=p_campaign_id;';
  v_new:=v_old||E'\n  PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_hp,v_max);';
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Ponto de sincronização não único em %: %.',v_sig,v_count; END IF;
  EXECUTE replace(v_def,v_old,v_new);

  v_sig:='public.usar_habilidade_classe_srd(text,text,text,integer)';
  v_def:=pg_get_functiondef(v_sig::regprocedure);
  v_old:='    v_hp:=LEAST(v_max_hp,v_hp+v_healing);';
  v_new:=v_old||E'\n    PERFORM priv.srd_sync_linked_npc_token_vitals(v_character.campaign_id,p_target_token_key,v_hp,v_max_hp);';
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Ponto de sincronização não único em %: %.',v_sig,v_count; END IF;
  EXECUTE replace(v_def,v_old,v_new);
END;
$migration$;
