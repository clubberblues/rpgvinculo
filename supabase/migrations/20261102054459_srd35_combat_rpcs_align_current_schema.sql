CREATE OR REPLACE FUNCTION public.add_monster_to_scene(cid bigint,p_monster text,p_x integer,p_y integer)
RETURNS bigint LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,pg_temp AS $$
DECLARE m public.srd_monsters; mi_id bigint; token_id bigint; n integer;
BEGIN
  PERFORM priv.need_gm(cid);
  SELECT * INTO m FROM public.srd_monsters WHERE id=p_monster;
  IF NOT FOUND THEN RAISE EXCEPTION 'Monstro SRD inexistente.'; END IF;
  IF p_x IS NULL OR p_y IS NULL OR p_x<0 OR p_y<0 THEN RAISE EXCEPTION 'Posição inválida.'; END IF;
  SELECT count(*)+1 INTO n FROM public.monster_instances WHERE campaign_id=cid AND monster_id=p_monster;
  INSERT INTO public.monster_instances(campaign_id,monster_id,rotulo,hp_atual,hp_max,visivel,estado)
  VALUES(cid,p_monster,m.nome||' #'||n,coalesce(m.pv,1),coalesce(m.pv,1),true,'{}'::jsonb)
  RETURNING id INTO mi_id;
  INSERT INTO public.tokens(campaign_id,monster_instance_id,col,row,visivel)
  VALUES(cid,mi_id,p_x,p_y,true) RETURNING id INTO token_id;
  PERFORM priv.log(cid,'MONSTRO_ADICIONADO',jsonb_build_object('token',token_id,'monstro',p_monster,'por',auth.uid()));
  RETURN token_id;
END $$;

CREATE OR REPLACE FUNCTION public.apply_damage(p_alvo bigint,p_qtd integer,p_tipo text DEFAULT 'Impacto')
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,pg_temp AS $$
DECLARE d public.tokens; v_role text; v_now integer; v_max integer; v_kind text;
BEGIN
  IF p_qtd IS NULL OR p_qtd<0 THEN RAISE EXCEPTION 'Dano inválido.'; END IF;
  SELECT * INTO d FROM public.tokens WHERE id=p_alvo FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Alvo inexistente.'; END IF;
  v_role:=public.my_role(d.campaign_id);
  IF v_role IS NULL THEN RAISE EXCEPTION 'Sem permissão.'; END IF;
  IF d.character_id IS NOT NULL THEN
    SELECT pv_atual,pv_max INTO v_now,v_max FROM public.srd_character_sheets WHERE character_id=d.character_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do alvo inexistente.'; END IF;
    v_kind:='character';
    v_now:=greatest(0,v_now-p_qtd);
    UPDATE public.srd_character_sheets SET pv_atual=v_now WHERE character_id=d.character_id;
  ELSIF d.monster_instance_id IS NOT NULL THEN
    SELECT hp_atual,hp_max INTO v_now,v_max FROM public.monster_instances WHERE id=d.monster_instance_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Instância de monstro inexistente.'; END IF;
    v_kind:='monster';
    v_now:=greatest(0,v_now-p_qtd);
    UPDATE public.monster_instances SET hp_atual=v_now WHERE id=d.monster_instance_id;
  ELSE
    RAISE EXCEPTION 'Token sem ficha ou instância.';
  END IF;
  INSERT INTO public.roll_log(campaign_id,tipo,autor_id,alvo_id,expressao,total,resultado,detalhes)
  VALUES(d.campaign_id,'DANO',auth.uid(),d.id,p_tipo,p_qtd,CASE WHEN v_now=0 THEN 'QUEDA' ELSE 'DANO' END,
         jsonb_build_object('pv_apos',v_now,'pv_max',v_max,'alvo_tipo',v_kind));
  RETURN jsonb_build_object('pv',v_now,'pv_max',v_max,'dano',p_qtd,'alvo_tipo',v_kind);
END $$;

CREATE OR REPLACE FUNCTION public.apply_heal(p_alvo bigint,p_qtd integer)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,pg_temp AS $$
DECLARE d public.tokens; v_role text; v_now integer; v_max integer; v_kind text;
BEGIN
  IF p_qtd IS NULL OR p_qtd<0 THEN RAISE EXCEPTION 'Cura inválida.'; END IF;
  SELECT * INTO d FROM public.tokens WHERE id=p_alvo FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Alvo inexistente.'; END IF;
  v_role:=public.my_role(d.campaign_id);
  IF v_role IS NULL THEN RAISE EXCEPTION 'Sem permissão.'; END IF;
  IF d.character_id IS NOT NULL THEN
    SELECT pv_atual,pv_max INTO v_now,v_max FROM public.srd_character_sheets WHERE character_id=d.character_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do alvo inexistente.'; END IF;
    v_kind:='character'; v_now:=least(v_max,v_now+p_qtd);
    UPDATE public.srd_character_sheets SET pv_atual=v_now WHERE character_id=d.character_id;
  ELSIF d.monster_instance_id IS NOT NULL THEN
    SELECT hp_atual,hp_max INTO v_now,v_max FROM public.monster_instances WHERE id=d.monster_instance_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Instância de monstro inexistente.'; END IF;
    v_kind:='monster'; v_now:=least(v_max,v_now+p_qtd);
    UPDATE public.monster_instances SET hp_atual=v_now WHERE id=d.monster_instance_id;
  ELSE
    RAISE EXCEPTION 'Token sem ficha ou instância.';
  END IF;
  INSERT INTO public.roll_log(campaign_id,tipo,autor_id,alvo_id,total,resultado,detalhes)
  VALUES(d.campaign_id,'CURA',auth.uid(),d.id,p_qtd,'CURA',jsonb_build_object('pv_apos',v_now,'pv_max',v_max,'alvo_tipo',v_kind));
  RETURN jsonb_build_object('pv',v_now,'pv_max',v_max,'cura',p_qtd,'alvo_tipo',v_kind);
END $$;

CREATE OR REPLACE FUNCTION public.combat_set_turn(p_token bigint)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,pg_temp AS $$
DECLARE t public.tokens; cs public.combat_state; idx integer;
BEGIN
  SELECT * INTO t FROM public.tokens WHERE id=p_token;
  IF NOT FOUND THEN RAISE EXCEPTION 'Token inexistente.'; END IF;
  PERFORM priv.need_gm(t.campaign_id);
  SELECT * INTO cs FROM public.combat_state WHERE campaign_id=t.campaign_id FOR UPDATE;
  IF NOT FOUND OR cs.ativo IS NOT TRUE THEN RAISE EXCEPTION 'Combate não está ativo.'; END IF;
  SELECT ordinality-1 INTO idx FROM jsonb_array_elements_text(cs.ordem) WITH ORDINALITY WHERE value=p_token::text;
  IF idx IS NULL THEN RAISE EXCEPTION 'Token fora da ordem.'; END IF;
  UPDATE public.combat_state SET turno_index=idx WHERE campaign_id=t.campaign_id;
  PERFORM priv.log(t.campaign_id,'TURNO_DEFINIDO',jsonb_build_object('token',p_token,'por',auth.uid()));
END $$;

CREATE OR REPLACE FUNCTION public.set_turn(cid bigint,p_token bigint)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,pg_temp AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.tokens WHERE id=p_token AND campaign_id=cid) THEN
    RAISE EXCEPTION 'Token inexistente.';
  END IF;
  PERFORM public.combat_set_turn(p_token);
END $$;

CREATE OR REPLACE FUNCTION public.end_combat(cid bigint)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,pg_temp AS $$
BEGIN
  PERFORM priv.need_gm(cid);
  UPDATE public.combat_state SET ativo=false,ordem='[]'::jsonb,iniciado_em=NULL WHERE campaign_id=cid;
  UPDATE public.campaigns SET state='EXPLORACAO' WHERE id=cid;
  PERFORM priv.log(cid,'COMBATE_ENCERRADO',jsonb_build_object('por',auth.uid()));
  RETURN jsonb_build_object('ok',true);
END $$;

CREATE OR REPLACE FUNCTION public.move_token(p_token bigint,p_x integer,p_y integer)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,pg_temp AS $$
DECLARE t public.tokens; r text; owner_id uuid;
BEGIN
  SELECT * INTO t FROM public.tokens WHERE id=p_token FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Token inexistente.'; END IF;
  IF p_x IS NULL OR p_y IS NULL OR p_x<0 OR p_y<0 THEN RAISE EXCEPTION 'Posição inválida.'; END IF;
  r:=public.my_role(t.campaign_id);
  IF r IS NULL THEN RAISE EXCEPTION 'Você não participa desta mesa.'; END IF;
  IF r='PLAYER' THEN
    SELECT c.user_id INTO owner_id FROM public.characters c WHERE c.id=t.character_id;
    IF owner_id IS DISTINCT FROM auth.uid() THEN RAISE EXCEPTION 'Esse token não é seu.'; END IF;
  ELSIF r<>'GM' THEN
    RAISE EXCEPTION 'Observadores não movem tokens.';
  END IF;
  IF EXISTS (SELECT 1 FROM public.tokens x WHERE x.campaign_id=t.campaign_id AND x.col=p_x AND x.row=p_y AND x.id<>t.id) THEN
    RAISE EXCEPTION 'Casa ocupada.';
  END IF;
  UPDATE public.tokens SET col=p_x,row=p_y,updated_at=now() WHERE id=t.id;
END $$;