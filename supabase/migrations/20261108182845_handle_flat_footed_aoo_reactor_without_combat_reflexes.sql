
DO $migration$
DECLARE
  v_definition text;
  v_decl_old text := '  v_flat_footed boolean:=false;';
  v_decl_new text := '  v_flat_footed boolean:=false;'||E'\n  v_has_combat_reflexes boolean:=false;';
  v_anchor text := '  v_trigger:=v_reaction->>''trigger_key'';';
  v_insert text := $block$
  IF v_flat_footed THEN
    SELECT EXISTS(
      SELECT 1
      FROM public.srd_character_sheets sh
      CROSS JOIN LATERAL jsonb_array_elements(
        CASE WHEN jsonb_typeof(sh.talentos)='array' THEN sh.talentos ELSE '[]'::jsonb END
      ) feat
      WHERE sh.character_id::text=v_character_id
        AND (
          lower(coalesce(feat->>'id','')) IN ('reflexos_de_combate','combat_reflexes','srd35_feat_combat_reflexes')
          OR lower(coalesce(feat->>'nome','')) IN ('reflexos de combate','combat reflexes')
        )
    ) INTO v_has_combat_reflexes;

    IF NOT v_has_combat_reflexes THEN
      UPDATE priv.srd_aoo_pending_movements
         SET pending_reactions=jsonb_set(
           pending_reactions,
           ARRAY[(v_index-1)::text],
           v_reaction||jsonb_build_object(
             'status','ineligible',
             'reason','flat_footed_without_combat_reflexes'
           ),
           false
         ),
         updated_at=now()
       WHERE pending_id=p_pending_id;
      RETURN jsonb_build_object(
        'reserved',false,
        'ineligible',true,
        'reason','flat_footed_without_combat_reflexes',
        'reactor_token_id',p_reactor_token_id
      );
    END IF;
  END IF;

  v_trigger:=v_reaction->>'trigger_key';
$block$;
BEGIN
  SELECT pg_get_functiondef('public.srd_reservar_reacao_movimento_aoo_srd(bigint,uuid,text)'::regprocedure)
    INTO v_definition;
  IF position(v_decl_old in v_definition)=0 OR position(v_anchor in v_definition)=0 THEN
    RAISE EXCEPTION 'Trechos esperados não encontrados; migration abortada.';
  END IF;
  v_definition:=replace(v_definition,v_decl_old,v_decl_new);
  v_definition:=replace(v_definition,v_anchor,v_insert);
  EXECUTE v_definition;
END;
$migration$;
