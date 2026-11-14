CREATE OR REPLACE FUNCTION public.alternar_estado_campanha(p_campaign_id bigint, p_novo_estado text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_role text;
  v_estado_atual text;
  v_novo_estado text;
  v_rage record;
  v_rage_token record;
  v_combat jsonb:=jsonb_build_object(
    'turn_order','[]'::jsonb,'current_turn',0,'active',false,'round',1,
    'expected_character_ids','[]'::jsonb
  );
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  SELECT m.role INTO v_role FROM public.members m
   WHERE m.campaign_id=p_campaign_id AND m.user_id=auth.uid() LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre da campanha pode alternar o estado.';
  END IF;
  v_novo_estado:=UPPER(BTRIM(COALESCE(p_novo_estado,'')));
  IF v_novo_estado NOT IN ('EXPLORACAO','COMBATE') THEN
    RAISE EXCEPTION 'Estado inválido; use EXPLORACAO ou COMBATE.';
  END IF;
  SELECT UPPER(COALESCE(NULLIF(BTRIM(state),''),'EXPLORACAO'))
    INTO v_estado_atual FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  IF v_estado_atual=v_novo_estado THEN
    RAISE EXCEPTION 'A mesa já está em %.',v_novo_estado;
  END IF;

  IF v_estado_atual='COMBATE' AND v_novo_estado='EXPLORACAO' THEN
    FOR v_rage IN
      SELECT target_id FROM public.srd_campaign_effects
       WHERE campaign_id=p_campaign_id AND target_kind='character'
         AND active=true AND effect_data->>'source_feature'='barbarian_rage'
       FOR UPDATE
    LOOP
      PERFORM priv.srd_end_barbarian_rage(p_campaign_id,v_rage.target_id,false);
    END LOOP;

    -- NPCs linked to source sheets store rage on their scene token, not on a character target.
    FOR v_rage_token IN
      SELECT target_id FROM public.srd_campaign_effects
       WHERE campaign_id=p_campaign_id AND target_kind='token'
         AND active=true AND effect_data->>'source_feature'='barbarian_rage'
       FOR UPDATE
    LOOP
      PERFORM priv.srd_end_barbarian_rage_token(p_campaign_id,v_rage_token.target_id,false);
    END LOOP;

    UPDATE public.srd_campaign_conditions
       SET active=false
     WHERE campaign_id=p_campaign_id AND active=true
       AND notes->>'source_feature'='barbarian_rage'
       AND condition_id IN ('fatigued','exhausted');
  END IF;

  UPDATE public.campaigns SET state=v_novo_estado,combat_data=v_combat WHERE id=p_campaign_id;
  RETURN jsonb_build_object('state',v_novo_estado,'combat_data',v_combat);
END;
$function$;

CREATE OR REPLACE FUNCTION public.end_combat(cid bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_rage record;
  v_rage_token record;
BEGIN
  PERFORM priv.need_gm(cid);
  FOR v_rage IN
    SELECT target_id FROM public.srd_campaign_effects
     WHERE campaign_id=cid AND target_kind='character'
       AND active=true AND effect_data->>'source_feature'='barbarian_rage'
     FOR UPDATE
  LOOP
    PERFORM priv.srd_end_barbarian_rage(cid,v_rage.target_id,false);
  END LOOP;

  -- End token-based NPC rage as well, restoring its pre-rage PV before leaving combat.
  FOR v_rage_token IN
    SELECT target_id FROM public.srd_campaign_effects
     WHERE campaign_id=cid AND target_kind='token'
       AND active=true AND effect_data->>'source_feature'='barbarian_rage'
     FOR UPDATE
  LOOP
    PERFORM priv.srd_end_barbarian_rage_token(cid,v_rage_token.target_id,false);
  END LOOP;

  UPDATE public.srd_campaign_conditions
     SET active=false
   WHERE campaign_id=cid AND active=true
     AND notes->>'source_feature'='barbarian_rage'
     AND condition_id IN ('fatigued','exhausted');
  UPDATE public.combat_state SET ativo=false,ordem='[]'::jsonb,iniciado_em=NULL WHERE campaign_id=cid;
  UPDATE public.campaigns SET state='EXPLORACAO' WHERE id=cid;
  PERFORM priv.log(cid,'COMBATE_ENCERRADO',jsonb_build_object('por',auth.uid()));
  RETURN jsonb_build_object('ok',true);
END;
$function$;