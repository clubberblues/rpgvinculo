
CREATE OR REPLACE FUNCTION public.srd_resolve_dying_round(
  p_campaign_id bigint,
  p_character_id text,
  p_d100 integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, pg_temp
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_round integer;
  v_condition public.srd_campaign_conditions%ROWTYPE;
  v_new_hp integer;
  v_status text;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_d100 IS NULL OR p_d100 NOT BETWEEN 1 AND 100 THEN
    RAISE EXCEPTION 'A rolagem de estabilização exige um resultado manual de 1 a 100.';
  END IF;

  SELECT ch.* INTO v_character
  FROM public.characters ch
  WHERE ch.id::text=BTRIM(p_character_id)
    AND ch.campaign_id=p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado nesta campanha.'; END IF;

  IF v_character.user_id IS DISTINCT FROM auth.uid()
     AND public.my_role(p_campaign_id) IS DISTINCT FROM 'GM'
     AND NOT EXISTS (
       SELECT 1 FROM public.campaigns c
       WHERE c.id=p_campaign_id AND c.owner_id=auth.uid()
     ) THEN
    RAISE EXCEPTION 'Somente o jogador dono da ficha ou o Mestre pode registrar esta rolagem.';
  END IF;

  SELECT sh.* INTO v_sheet
  FROM public.srd_character_sheets sh
  WHERE sh.character_id=v_character.id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do personagem não encontrada.'; END IF;
  IF COALESCE(v_sheet.pv_atual,0) NOT BETWEEN -9 AND -1 THEN
    RAISE EXCEPTION 'O personagem não está na faixa de PV morrendo (-1 a -9).';
  END IF;

  SELECT GREATEST(1,COALESCE(NULLIF(c.combat_data->>'round','')::integer,1))
    INTO v_round
    FROM public.campaigns c
   WHERE c.id=p_campaign_id
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;

  SELECT cc.* INTO v_condition
  FROM public.srd_campaign_conditions cc
  WHERE cc.campaign_id=p_campaign_id
    AND cc.target_kind='character'
    AND cc.target_id=BTRIM(p_character_id)
    AND cc.condition_id='dying'
    AND cc.active=true
  ORDER BY cc.condition_instance_id DESC
  LIMIT 1
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'A condição Morrendo não está ativa.'; END IF;

  IF COALESCE(NULLIF(v_condition.notes->>'last_resolved_round','')::integer,0)>=v_round THEN
    RAISE EXCEPTION 'A rolagem de estabilização desta rodada já foi resolvida.';
  END IF;

  IF p_d100<=10 THEN
    PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),v_sheet.pv_atual,true);
    v_status:='stable';
    v_new_hp:=v_sheet.pv_atual;
  ELSE
    v_new_hp:=GREATEST(-10,COALESCE(v_sheet.pv_atual,0)-1);
    UPDATE public.srd_character_sheets
       SET pv_atual=v_new_hp
     WHERE character_id=v_character.id;
    PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),v_new_hp,false);
    v_status:=CASE WHEN v_new_hp<=-10 THEN 'dead' ELSE 'dying' END;
    IF v_status='dying' THEN
      UPDATE public.srd_campaign_conditions
         SET notes=COALESCE(notes,'{}'::jsonb)||jsonb_build_object('last_resolved_round',v_round)
       WHERE campaign_id=p_campaign_id
         AND target_kind='character'
         AND target_id=BTRIM(p_character_id)
         AND condition_id='dying'
         AND active=true;
    END IF;
  END IF;

  PERFORM priv.log(
    p_campaign_id,
    'ESTABILIZACAO_RESOLVIDA',
    jsonb_build_object(
      'character_id',BTRIM(p_character_id),
      'd100',p_d100,
      'round',v_round,
      'pv_atual',v_new_hp,
      'status',v_status
    )
  );

  RETURN jsonb_build_object(
    'character_id',BTRIM(p_character_id),
    'd100',p_d100,
    'round',v_round,
    'pv_atual',v_new_hp,
    'condition',v_status,
    'stabilized',v_status='stable',
    'dead',v_status='dead'
  );
END;
$function$;

DO $patch_advance_turn_dying_rolls$
DECLARE
  v_definition text;
  v_marker text:='    PERFORM public.srd_expire_campaign_conditions(p_campaign_id);';
  v_add text;
BEGIN
  SELECT pg_get_functiondef('public.avancar_turno(bigint)'::regprocedure)
    INTO v_definition;
  IF position(v_marker IN v_definition)=0 THEN
    RAISE EXCEPTION 'Ponto de expiração da rodada não localizado.';
  END IF;
  IF position('v_dying_ids' IN v_definition)>0 THEN RETURN; END IF;
  v_definition:=replace(v_definition,'  v_next_data JSONB;',
    '  v_next_data JSONB;' || E'\n  v_dying_ids TEXT[]; v_dying_targets JSONB;');

  v_add:=$patch$
    SELECT array_agg(DISTINCT ch.id::text ORDER BY ch.id::text)
      INTO v_dying_ids
      FROM public.srd_campaign_conditions cc
      JOIN public.characters ch
        ON ch.id::text=cc.target_id AND ch.campaign_id=cc.campaign_id
      JOIN public.srd_character_sheets sh
        ON sh.character_id=ch.id
     WHERE cc.campaign_id=p_campaign_id
       AND cc.target_kind='character'
       AND cc.condition_id='dying'
       AND cc.active=true
       AND COALESCE(sh.pv_atual,0) BETWEEN -9 AND -1
       AND COALESCE(NULLIF(cc.notes->>'last_resolved_round','')::integer,0)<v_round;

    IF COALESCE(cardinality(v_dying_ids),0)>0 THEN
      SELECT jsonb_agg(
        jsonb_build_object(
          'character_id',ch.id::text,
          'name',ch.nome,
          'user_id',ch.user_id,
          'pv',sh.pv_atual
        ) ORDER BY ch.id
      )
      INTO v_dying_targets
      FROM public.characters ch
      JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
      WHERE ch.campaign_id=p_campaign_id
        AND ch.id::text=ANY(v_dying_ids);

      INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
      VALUES (
        p_campaign_id,
        'test_request',
        'PUBLIC',
        jsonb_build_object(
          'tipo','Estabilização (D100)',
          'alvos',to_jsonb(v_dying_ids),
          'mestre','Sistema',
          'mestre_id',auth.uid(),
          'request_id',gen_random_uuid()::text,
          'detalhes',COALESCE(v_dying_targets,'[]'::jsonb)
        )
      );
      v_next_data:=v_next_data||jsonb_build_object('dying_saves',COALESCE(v_dying_targets,'[]'::jsonb));
    ELSE
      v_next_data:=v_next_data||jsonb_build_object('dying_saves','[]'::jsonb);
    END IF;
$patch$;

  v_definition:=replace(v_definition,v_marker,v_marker||E'\n'||v_add);
  EXECUTE v_definition;
END;
$patch_advance_turn_dying_rolls$;

REVOKE ALL ON FUNCTION public.srd_resolve_dying_round(bigint,text,integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_resolve_dying_round(bigint,text,integer) TO authenticated;
