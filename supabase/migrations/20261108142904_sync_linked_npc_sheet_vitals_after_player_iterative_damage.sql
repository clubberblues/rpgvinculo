
DO $migration$
DECLARE
  v_sig text;
  v_def text;
  v_old text:='update public.campaigns set cba_data=v_scene where id=p_campaign_id;';
  v_new text:='update public.campaigns set cba_data=v_scene where id=p_campaign_id;'||
    E'\n  perform priv.srd_sync_linked_npc_token_vitals(p_campaign_id,v_seq.target_token_id,v_new_hp,v_max_hp);';
  v_count integer;
  v_items text[]:=ARRAY[
    'public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid)',
    'public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid,integer[])'
  ];
BEGIN
  FOREACH v_sig IN ARRAY v_items LOOP
    v_def:=pg_get_functiondef(v_sig::regprocedure);
    v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
    IF v_count<>1 THEN
      RAISE EXCEPTION 'Esperava exatamente um ponto de sincronização em %, encontrei %.',v_sig,v_count;
    END IF;
    EXECUTE replace(v_def,v_old,v_new);
  END LOOP;
END;
$migration$;
