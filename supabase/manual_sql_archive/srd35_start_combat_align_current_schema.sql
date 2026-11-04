CREATE OR REPLACE FUNCTION public.start_combat(cid bigint)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  ordem jsonb;
BEGIN
  PERFORM priv.need_gm(cid);

  IF (SELECT coalesce(ativo,false) FROM public.combat_state WHERE campaign_id=cid) THEN
    RAISE EXCEPTION 'Combate já está ativo.';
  END IF;

  WITH ordenado AS (
    SELECT t.id,
      CASE
        WHEN t.character_id IS NOT NULL THEN
          10 + floor((coalesce(NULLIF(public._srd35_attr(cs.atributos,ARRAY['DES','DEX']::text[]),'')::integer,10)-10)::numeric/2)::integer
        ELSE coalesce((regexp_match(sm.iniciativa,'[-+]?[0-9]+'))[1]::integer,0)
      END AS ini
    FROM public.tokens t
    LEFT JOIN public.srd_character_sheets cs ON cs.character_id=t.character_id
    LEFT JOIN public.monster_instances mi ON mi.id=t.monster_instance_id
    LEFT JOIN public.srd_monsters sm ON sm.id=mi.monster_id
    WHERE t.campaign_id=cid
      AND (
        (t.character_id IS NOT NULL AND coalesce(cs.pv_atual,0)>0)
        OR
        (t.monster_instance_id IS NOT NULL AND coalesce(mi.hp_atual,0)>0)
      )
    ORDER BY ini DESC,t.id ASC
  )
  SELECT coalesce(jsonb_agg(id),'[]'::jsonb) INTO ordem FROM ordenado;

  IF jsonb_array_length(ordem)=0 THEN
    RAISE EXCEPTION 'Nenhum token vivo com ficha SRD ou instância de monstro.';
  END IF;

  INSERT INTO public.combat_state(campaign_id,ativo,rodada,turno_index,ordem,iniciado_em)
  VALUES (cid,true,1,0,ordem,now())
  ON CONFLICT (campaign_id) DO UPDATE SET
    ativo=true,rodada=1,turno_index=0,ordem=excluded.ordem,iniciado_em=now();

  UPDATE public.campaigns SET state='COMBATE' WHERE id=cid;
  PERFORM priv.log(cid,'COMBATE_INICIADO',jsonb_build_object('ordem',ordem,'por',auth.uid()));

  RETURN jsonb_build_object('ok',true,'ordem',ordem);
END;
$function$;