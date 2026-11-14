
do $patch$
declare v_def text; v_old text; v_new text;
begin
 v_def:=replace(pg_get_functiondef('public.iniciar_iniciativa_com_dados(bigint,text[],text,jsonb)'::regprocedure),chr(13)||chr(10),chr(10));
 v_old:=$old$  WHERE id = p_campaign_id;

  IF cardinality(v_expected) > 0 THEN$old$;
 v_new:=$new$  WHERE id = p_campaign_id;
  IF cardinality(v_expected) = 0 THEN
    PERFORM priv.srd_start_combat_flatfooted(p_campaign_id,v_order,0);
  END IF;

  IF cardinality(v_expected) > 0 THEN$new$;
 if strpos(v_def,v_old)=0 then raise exception 'Âncora iniciar_iniciativa_com_dados não encontrada'; end if;
 execute replace(v_def,v_old,v_new);

 v_def:=replace(pg_get_functiondef('public.avancar_turno(bigint)'::regprocedure),chr(13)||chr(10),chr(10));
 v_old:=$old$  v_actor_kind:=CASE WHEN COALESCE((v_current_actor->>'is_monster')::boolean,false) THEN 'token' ELSE 'character' END;$old$;
 v_new:=$new$  v_actor_kind:=CASE WHEN COALESCE((v_current_actor->>'is_monster')::boolean,false) THEN 'token' ELSE 'character' END;
  PERFORM priv.srd_clear_combat_flatfooted_actor(p_campaign_id,v_current_actor);$new$;
 if strpos(v_def,v_old)=0 then raise exception 'Âncora avancar_turno não encontrada'; end if;
 execute replace(v_def,v_old,v_new);

 v_def:=replace(pg_get_functiondef('public.alternar_estado_campanha(bigint,text)'::regprocedure),chr(13)||chr(10),chr(10));
 v_old:=$old$  UPDATE public.campaigns SET state=v_novo_estado,combat_data=v_combat WHERE id=p_campaign_id;$old$;
 v_new:=$new$  IF v_estado_atual='COMBATE' AND v_novo_estado='EXPLORACAO' THEN
    PERFORM priv.srd_clear_combat_flatfooted_all(p_campaign_id);
  END IF;
  UPDATE public.campaigns SET state=v_novo_estado,combat_data=v_combat WHERE id=p_campaign_id;$new$;
 if strpos(v_def,v_old)=0 then raise exception 'Âncora alternar_estado_campanha não encontrada'; end if;
 execute replace(v_def,v_old,v_new);

 v_def:=replace(pg_get_functiondef('public.end_combat(bigint)'::regprocedure),chr(13)||chr(10),chr(10));
 v_old:=$old$  UPDATE public.combat_state SET ativo=false,ordem='[]'::jsonb,iniciado_em=NULL WHERE campaign_id=cid;$old$;
 v_new:=$new$  PERFORM priv.srd_clear_combat_flatfooted_all(cid);
  UPDATE public.combat_state SET ativo=false,ordem='[]'::jsonb,iniciado_em=NULL WHERE campaign_id=cid;$new$;
 if strpos(v_def,v_old)=0 then raise exception 'Âncora end_combat não encontrada'; end if;
 execute replace(v_def,v_old,v_new);
end;
$patch$;
