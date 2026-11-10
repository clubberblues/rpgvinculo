CREATE OR REPLACE FUNCTION public.srd_consultar_modificadores_manobra_srd(
  p_campaign_id bigint,
  p_attacker_token_id text,
  p_defender_token_id text,
  p_maneuver text,
  p_defender_firm_ground boolean,
  p_trip_using_weapon boolean
)
RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_result jsonb;
  v_maneuver text := lower(btrim(coalesce(p_maneuver,'')));
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode consultar os modificadores de manobra.';
  END IF;

  v_result := public.srd_consultar_modificadores_manobra_srd(
    p_campaign_id,p_attacker_token_id,p_defender_token_id,
    p_maneuver,p_defender_firm_ground
  );

  IF v_maneuver='trip' THEN
    IF coalesce(p_trip_using_weapon,false) THEN
      v_result := v_result || jsonb_build_object(
        'aoo_status','not_provoked_by_armed_trip',
        'aoo_source','none',
        'trip_using_weapon',true,
        'note','Tentativa de Derrubar usando arma apropriada: não provoca ataque de oportunidade por estar desarmado.'
      );
    ELSIF coalesce((v_result->>'improved_trip')::boolean,false) THEN
      v_result := v_result || jsonb_build_object(
        'aoo_status','suppressed_by_feat',
        'aoo_source','defender',
        'trip_using_weapon',false,
        'note','Tentativa desarmada: Derrubar Aprimorado concede +4 no teste e impede o ataque de oportunidade.'
      );
    ELSE
      v_result := v_result || jsonb_build_object(
        'aoo_status','provokes',
        'aoo_source','defender',
        'trip_using_weapon',false,
        'note','Tentativa de Derrubar desarmada: o defensor pode realizar ataque de oportunidade antes do teste resistido.'
      );
    END IF;
  END IF;

  RETURN v_result;
END;
$function$;

REVOKE ALL ON FUNCTION public.srd_consultar_modificadores_manobra_srd(bigint,text,text,text,boolean,boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_consultar_modificadores_manobra_srd(bigint,text,text,text,boolean,boolean) TO authenticated;