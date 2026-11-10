
DO $patch$
DECLARE v_def text;
BEGIN
  v_def:=pg_get_functiondef('priv.srd_resolver_levantar_caido_apos_aoo_srd(bigint,uuid)'::regprocedure);
  v_def:=replace(v_def,
    $old$     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'unconscious') THEN$old$,
    $new$     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'unconscious')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'helpless') THEN$new$
  );
  v_def:=replace(v_def,
    $old$    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'unconscious')
  ) THEN$old$,
    $new$    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'unconscious')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'helpless')
  ) THEN$new$
  );
  IF position('priv.srd_condition_has_flag(p_campaign_id,'||quote_literal('token')||',v_pending.mover_token_id,'||quote_literal('helpless')||')' in v_def)=0 THEN
    RAISE EXCEPTION 'Falha ao incluir indefeso na validação final.';
  END IF;
  EXECUTE v_def;
END;
$patch$;
