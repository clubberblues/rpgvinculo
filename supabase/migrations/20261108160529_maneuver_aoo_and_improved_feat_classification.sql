
CREATE OR REPLACE FUNCTION public.srd_consultar_modificadores_manobra_srd(
  p_campaign_id bigint,
  p_attacker_token_id text,
  p_defender_token_id text,
  p_maneuver text,
  p_defender_firm_ground boolean DEFAULT false
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_attacker jsonb;
  v_defender jsonb;
  v_maneuver text:=lower(btrim(coalesce(p_maneuver,'')));
  v_size_difference integer;
  v_stability integer:=0;
  v_attacker_modifier integer;
  v_defender_modifier integer;
  v_attacker_feats jsonb:='[]'::jsonb;
  v_defender_feats jsonb:='[]'::jsonb;
  v_improved_trip boolean:=false;
  v_improved_bull_rush boolean:=false;
  v_feat_bonus integer:=0;
  v_aoo_status text;
  v_aoo_source text;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode consultar os modificadores de manobra.';
  END IF;
  IF v_maneuver NOT IN ('bull_rush','trip') THEN
    RAISE EXCEPTION 'Manobra não suportada nesta etapa. Use bull_rush ou trip.';
  END IF;
  IF p_attacker_token_id IS NULL OR p_defender_token_id IS NULL
     OR p_attacker_token_id=p_defender_token_id THEN
    RAISE EXCEPTION 'Selecione dois tokens diferentes.';
  END IF;

  v_attacker:=priv.srd35_maneuver_profile(p_campaign_id,p_attacker_token_id);
  v_defender:=priv.srd35_maneuver_profile(p_campaign_id,p_defender_token_id);
  v_size_difference:=4*((v_attacker->>'size_rank')::integer-(v_defender->>'size_rank')::integer);

  IF v_maneuver IN ('bull_rush','trip')
     AND v_defender->>'race_id'='anao'
     AND coalesce(p_defender_firm_ground,false) THEN
    v_stability:=4;
  END IF;

  IF v_attacker->>'character_id' IS NOT NULL THEN
    SELECT coalesce(talentos,'[]'::jsonb) INTO v_attacker_feats
    FROM public.srd_character_sheets
    WHERE character_id=(v_attacker->>'character_id')::bigint;
  END IF;
  IF v_defender->>'character_id' IS NOT NULL THEN
    SELECT coalesce(talentos,'[]'::jsonb) INTO v_defender_feats
    FROM public.srd_character_sheets
    WHERE character_id=(v_defender->>'character_id')::bigint;
  END IF;

  v_improved_trip:=EXISTS(
    SELECT 1 FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_attacker_feats)='array' THEN v_attacker_feats ELSE '[]'::jsonb END
    ) f
    WHERE lower(coalesce(f->>'id','')) IN ('srd35_feat_improved_trip','improved_trip','derrubar_aprimorado')
  );
  v_improved_bull_rush:=EXISTS(
    SELECT 1 FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_attacker_feats)='array' THEN v_attacker_feats ELSE '[]'::jsonb END
    ) f
    WHERE lower(coalesce(f->>'id','')) IN ('srd35_feat_improved_bull_rush','improved_bull_rush','encontrao_aprimorado')
  );

  v_attacker_modifier:=(v_attacker->>'strength_modifier')::integer+v_size_difference;
  v_defender_modifier:=CASE WHEN v_maneuver='trip'
    THEN greatest((v_defender->>'strength_modifier')::integer,
                  (v_defender->>'dexterity_modifier')::integer)
    ELSE (v_defender->>'strength_modifier')::integer END
    -v_size_difference+v_stability;

  IF v_maneuver='trip' THEN
    v_feat_bonus:=CASE WHEN v_improved_trip THEN 4 ELSE 0 END;
    v_attacker_modifier:=v_attacker_modifier+v_feat_bonus;
    v_aoo_status:='requires_weapon_context';
    v_aoo_source:='defender';
  ELSE
    v_feat_bonus:=CASE WHEN v_improved_bull_rush THEN 4 ELSE 0 END;
    v_attacker_modifier:=v_attacker_modifier+v_feat_bonus;
    v_aoo_status:=CASE WHEN v_improved_bull_rush THEN 'suppressed_by_feat' ELSE 'provokes' END;
    v_aoo_source:='defender';
  END IF;

  RETURN jsonb_build_object(
    'maneuver',v_maneuver,
    'attacker',v_attacker,
    'defender',v_defender,
    'attacker_check','strength',
    'defender_check',CASE WHEN v_maneuver='trip' THEN 'strength_or_dexterity' ELSE 'strength' END,
    'attacker_modifier',v_attacker_modifier,
    'defender_modifier',v_defender_modifier,
    'dwarf_stability_bonus',v_stability,
    'dwarf_stability_applied',v_stability=4,
    'size_difference_modifier',v_size_difference,
    'attacker_feat_bonus',v_feat_bonus,
    'improved_trip',v_improved_trip,
    'improved_bull_rush',v_improved_bull_rush,
    'aoo_status',v_aoo_status,
    'aoo_source',v_aoo_source,
    'aoo_requires_weapon_context',v_maneuver='trip',
    'resolved',false,
    'note',CASE WHEN v_maneuver='trip'
      THEN 'Derrubar: confirmar se o atacante está desarmado ou usa arma apropriada antes de decidir o ataque de oportunidade. Derrubar Aprimorado só suprime o ataque quando a tentativa é desarmada.'
      WHEN v_improved_bull_rush
      THEN 'Encontrão Aprimorado concede +4 no teste e impede o ataque de oportunidade do defensor.'
      ELSE 'Encontrão provoca ataque de oportunidade do defensor antes da resolução; este retorno não executa o ataque nem consome ações.'
    END
  );
END;
$function$;

REVOKE ALL ON FUNCTION public.srd_consultar_modificadores_manobra_srd(bigint,text,text,text,boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_consultar_modificadores_manobra_srd(bigint,text,text,text,boolean) TO authenticated;
