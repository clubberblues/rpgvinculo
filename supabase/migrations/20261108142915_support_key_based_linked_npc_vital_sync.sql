
CREATE OR REPLACE FUNCTION priv.srd_sync_linked_npc_token_vitals(
  p_campaign_id bigint,
  p_token_id text,
  p_token_hp integer,
  p_token_max_hp integer
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
DECLARE
  v_owner uuid;
  v_source_id text;
  v_actual_token_id text;
  v_count integer;
  v_rage_bonus integer:=0;
  v_base_max integer;
  v_sheet_id bigint;
  v_hp integer;
BEGIN
  IF p_campaign_id IS NULL OR NULLIF(BTRIM(p_token_id),'') IS NULL
     OR p_token_hp IS NULL OR p_token_max_hp IS NULL OR p_token_max_hp<1 THEN
    RAISE EXCEPTION 'Dados de sincronização de PV do NPC inválidos.';
  END IF;

  SELECT c.owner_id,count(*)::integer,
         min(NULLIF(BTRIM(t.token->>'sourceCharacterId'),'')),
         min(t.token->>'id')
    INTO v_owner,v_count,v_source_id,v_actual_token_id
  FROM public.campaigns c
  CROSS JOIN LATERAL jsonb_array_elements(
    CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array'
      THEN c.cba_data->'tokens' ELSE '[]'::jsonb END
  ) t(token)
  WHERE c.id=p_campaign_id
    AND (t.token->>'id'=BTRIM(p_token_id) OR t.token->>'key'=BTRIM(p_token_id))
    AND t.token->>'tipo'='npc'
  GROUP BY c.owner_id;

  IF v_count IS NULL OR v_count<>1 OR v_source_id IS NULL OR v_actual_token_id IS NULL THEN
    RETURN jsonb_build_object('synced',false,'reason','not_a_unique_linked_npc');
  END IF;

  SELECT sh.character_id
    INTO v_sheet_id
  FROM public.characters ch
  JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
  WHERE ch.id::text=v_source_id
    AND ch.user_id=v_owner
  FOR UPDATE OF sh;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('synced',false,'reason','source_sheet_not_owned_by_campaign_gm');
  END IF;

  SELECT COALESCE(max(NULLIF(e.effect_data->>'rage_hp_bonus','')::integer),0)
    INTO v_rage_bonus
  FROM public.srd_campaign_effects e
  WHERE e.campaign_id=p_campaign_id
    AND e.target_kind='token'
    AND e.target_id=v_actual_token_id
    AND e.active=true
    AND e.effect_data->>'source_feature'='barbarian_rage';

  v_base_max:=GREATEST(1,p_token_max_hp-GREATEST(0,v_rage_bonus));
  v_hp:=GREATEST(0,LEAST(v_base_max,p_token_hp));

  UPDATE public.srd_character_sheets
     SET pv_max=v_base_max,pv_atual=v_hp
   WHERE character_id=v_sheet_id;

  RETURN jsonb_build_object(
    'synced',true,'source_character_id',v_source_id,
    'pv_atual',v_hp,'pv_max',v_base_max,
    'rage_hp_bonus_excluded',GREATEST(0,v_rage_bonus)
  );
END;
$function$;

REVOKE ALL ON FUNCTION priv.srd_sync_linked_npc_token_vitals(bigint,text,integer,integer) FROM PUBLIC, anon, authenticated;
