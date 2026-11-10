-- Restrict HP damage and healing to the campaign GM.
-- Players must not be able to modify another participant's HP through legacy RPCs.
CREATE OR REPLACE FUNCTION public.apply_damage(p_alvo bigint,p_qtd integer,p_tipo text DEFAULT 'Impacto')
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path=public,pg_temp AS $$
DECLARE d public.tokens; v_role text; v_now integer; v_max integer; v_kind text;
BEGIN
  IF p_qtd IS NULL OR p_qtd<0 THEN RAISE EXCEPTION 'Dano inválido.'; END IF;
  SELECT * INTO d FROM public.tokens WHERE id=p_alvo FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Alvo inexistente.'; END IF;
  PERFORM priv.need_gm(d.campaign_id);
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
  PERFORM priv.need_gm(d.campaign_id);
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
