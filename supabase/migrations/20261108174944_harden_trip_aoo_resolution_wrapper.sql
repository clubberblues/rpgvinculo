
ALTER FUNCTION public.srd_resolver_derrubar_apos_aoo_srd(bigint,uuid,integer,integer,boolean)
  SECURITY DEFINER;
ALTER FUNCTION public.srd_resolver_derrubar_apos_aoo_srd(bigint,uuid,integer,integer,boolean)
  SET search_path = pg_catalog, public, priv, pg_temp;

DO $patch$
DECLARE v_def text;
BEGIN
  v_def:=pg_get_functiondef('public.srd_iniciar_derrubar_com_aoo_srd(bigint,text,text,boolean,boolean)'::regprocedure);
  IF position($needle$'defender_firm_ground',coalesce(p_defender_firm_ground,false)$needle$ in v_def)=0 THEN
    v_def:=replace(
      v_def,
      $old$'maneuver_event','trip','defender_token_id',BTRIM(p_defender_token_id),'distance_ft',v_distance,'reach_ft',v_reach$old$,
      $new$'maneuver_event','trip','defender_token_id',BTRIM(p_defender_token_id),'defender_firm_ground',coalesce(p_defender_firm_ground,false),'distance_ft',v_distance,'reach_ft',v_reach$new$
    );
    IF position($needle$'defender_firm_ground',coalesce(p_defender_firm_ground,false)$needle$ in v_def)=0 THEN
      RAISE EXCEPTION 'Não foi possível preservar a condição de Estabilidade Anã no evento pendente.';
    END IF;
    EXECUTE v_def;
  END IF;
END;
$patch$;

REVOKE ALL ON FUNCTION public.srd_resolver_derrubar_apos_aoo_srd(bigint,uuid,integer,integer,boolean) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_resolver_derrubar_apos_aoo_srd(bigint,uuid,integer,integer,boolean) TO authenticated;
