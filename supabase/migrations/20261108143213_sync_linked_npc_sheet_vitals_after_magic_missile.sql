
DO $migration$
DECLARE
  v_sig text:='public.conjurar_missil_magico_srd(text,text,smallint,text,integer)';
  v_def text:=pg_get_functiondef(v_sig::regprocedure);
  v_old text:='  UPDATE public.campaigns SET cba_data=v_scene WHERE id=v_character.campaign_id;';
  v_new text:='  UPDATE public.campaigns SET cba_data=v_scene WHERE id=v_character.campaign_id;'||
    E'\n  PERFORM priv.srd_sync_linked_npc_token_vitals(v_character.campaign_id,p_target_token_key,v_new_hp,v_max_hp);';
  v_count integer;
BEGIN
  v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
  IF v_count<>1 THEN RAISE EXCEPTION 'Ponto de sincronização não único em %: %.',v_sig,v_count; END IF;
  EXECUTE replace(v_def,v_old,v_new);
END;
$migration$;
