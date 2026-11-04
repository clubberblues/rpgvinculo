CREATE OR REPLACE FUNCTION public.conceder_xp_personagem_srd(p_campaign_id BIGINT,p_character_id TEXT,p_xp INTEGER)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,public AS $$
DECLARE v_xp INTEGER; v_old_level INTEGER; v_target_level INTEGER; v_pending INTEGER; v_srd BOOLEAN:=FALSE;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 IF p_xp IS NULL OR p_xp<1 OR p_xp>1000000 THEN RAISE EXCEPTION 'Quantidade de XP inválida.'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.members m WHERE m.campaign_id=p_campaign_id AND m.user_id=auth.uid() AND m.role='GM') THEN RAISE EXCEPTION 'Somente o Mestre desta campanha pode conceder XP.'; END IF;
 PERFORM 1 FROM public.characters c WHERE c.id::TEXT=BTRIM(p_character_id) AND c.campaign_id=p_campaign_id FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado nesta campanha.'; END IF;
 UPDATE public.characters SET xp=COALESCE(xp,0)+p_xp WHERE id::TEXT=BTRIM(p_character_id) AND campaign_id=p_campaign_id RETURNING xp INTO v_xp;
 SELECT s.nivel INTO v_old_level FROM public.srd_character_sheets s WHERE s.character_id::TEXT=BTRIM(p_character_id) FOR UPDATE;
 IF FOUND THEN
  v_srd:=TRUE; v_old_level:=GREATEST(1,COALESCE(v_old_level,1)); v_target_level:=GREATEST(v_old_level,LEAST(20,public.nivel_de_xp(v_xp)));
  UPDATE public.srd_character_sheets SET xp=v_xp,niveis_pendentes=GREATEST(0,COALESCE(niveis_pendentes,0)+(v_target_level-v_old_level)) WHERE character_id::TEXT=BTRIM(p_character_id) RETURNING niveis_pendentes INTO v_pending;
 END IF;
 RETURN jsonb_build_object('character_id',BTRIM(p_character_id),'xp',v_xp,'nivel',v_old_level,'nivel_disponivel',v_target_level,'niveis_pendentes',v_pending,'ficha_srd',v_srd);
END; $$;
REVOKE ALL ON FUNCTION public.conceder_xp_personagem_srd(BIGINT,TEXT,INTEGER) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.conceder_xp_personagem_srd(BIGINT,TEXT,INTEGER) TO authenticated;
CREATE OR REPLACE FUNCTION public.descanso_longo_personagem_srd(p_campaign_id BIGINT,p_character_id TEXT)
RETURNS JSONB LANGUAGE plpgsql SECURITY DEFINER SET search_path=pg_catalog,public AS $$
DECLARE v_owner UUID; v_campaign BIGINT; v_state TEXT; v_level INTEGER; v_hp INTEGER; v_max INTEGER; v_new_hp INTEGER; v_last_rest TIMESTAMPTZ; v_spell_state JSONB;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 SELECT c.user_id,c.campaign_id INTO v_owner,v_campaign FROM public.characters c WHERE c.id::TEXT=BTRIM(p_character_id) FOR UPDATE;
 IF NOT FOUND OR v_campaign IS DISTINCT FROM p_campaign_id THEN RAISE EXCEPTION 'Personagem não encontrado nesta campanha.'; END IF;
 IF v_owner IS DISTINCT FROM auth.uid() THEN RAISE EXCEPTION 'Somente o dono da ficha pode realizar descanso.'; END IF;
 SELECT state INTO v_state FROM public.campaigns WHERE id=p_campaign_id;
 IF UPPER(COALESCE(v_state,''))='COMBATE' THEN RAISE EXCEPTION 'Não é possível descansar durante um combate.'; END IF;
 SELECT s.nivel,s.pv_atual,s.pv_max,s.magias_descanso_em INTO v_level,v_hp,v_max,v_last_rest FROM public.srd_character_sheets s WHERE s.character_id::TEXT=BTRIM(p_character_id) FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada.'; END IF;
 IF v_last_rest IS NOT NULL AND v_last_rest>clock_timestamp()-INTERVAL '8 hours' THEN RAISE EXCEPTION 'O descanso longo exige 8 horas entre descansos.'; END IF;
 v_level:=GREATEST(1,COALESCE(v_level,1)); IF v_max IS NULL OR v_max<1 THEN RAISE EXCEPTION 'PV máximo inválido.'; END IF;
 v_new_hp:=LEAST(v_max,COALESCE(v_hp,v_max)+v_level);
 PERFORM public.repor_magias_srd(BTRIM(p_character_id));
 UPDATE public.srd_character_sheets SET pv_atual=v_new_hp WHERE character_id::TEXT=BTRIM(p_character_id) RETURNING magias_preparadas INTO v_spell_state;
 RETURN jsonb_build_object('character_id',BTRIM(p_character_id),'pv_atual',v_new_hp,'pv_max',v_max,'cura',v_new_hp-COALESCE(v_hp,v_max),'magias_repostas',TRUE,'descanso_em',clock_timestamp());
END; $$;
REVOKE ALL ON FUNCTION public.descanso_longo_personagem_srd(BIGINT,TEXT) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.descanso_longo_personagem_srd(BIGINT,TEXT) TO authenticated;
NOTIFY pgrst,'reload schema';