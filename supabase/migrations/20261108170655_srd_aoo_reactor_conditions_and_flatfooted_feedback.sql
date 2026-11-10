
do $patch$
declare v_def text; v_old text; v_new text;
begin
 v_def:=replace(pg_get_functiondef('public.srd_reservar_reacao_movimento_aoo_srd(bigint,uuid,text)'::regprocedure),chr(13)||chr(10),chr(10));
 v_old:=$old$or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dead');$old$;
 v_new:=$new$or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dead')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_threaten_squares');$new$;
 if strpos(v_def,v_old)=0 then raise exception 'Âncora de condições do token reator não encontrada'; end if;
 v_def:=replace(v_def,v_old,v_new);
 v_old:=$old$or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dead');$old$;
 v_new:=$new$or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dead')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_threaten_squares');$new$;
 if strpos(v_def,v_old)=0 then raise exception 'Âncora de condições da ficha reatora não encontrada'; end if;
 v_def:=replace(v_def,v_old,v_new);
 v_old:=$old$v_reservation:=public.srd_reservar_ataque_oportunidade_srd(
    p_campaign_id,btrim(p_reactor_token_id),v_trigger,v_flat_footed
  );$old$;
 v_new:=$new$BEGIN
    v_reservation:=public.srd_reservar_ataque_oportunidade_srd(
      p_campaign_id,btrim(p_reactor_token_id),v_trigger,v_flat_footed
    );
  EXCEPTION WHEN raise_exception THEN
    IF position('desprevenido' in lower(SQLERRM))>0 THEN
      UPDATE priv.srd_aoo_pending_movements
      SET pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
        v_reaction||jsonb_build_object('status','ineligible','reason','flat_footed_without_combat_reflexes'),false),
        updated_at=now()
      WHERE pending_id=p_pending_id;
      RETURN jsonb_build_object('reserved',false,'ineligible',true,
        'reason','flat_footed_without_combat_reflexes','reactor_token_id',p_reactor_token_id);
    END IF;
    RAISE;
  END;$new$;
 if strpos(v_def,v_old)=0 then raise exception 'Âncora de reserva da reação não encontrada'; end if;
 execute v_def;
end;
$patch$;
