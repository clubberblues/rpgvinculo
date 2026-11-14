
DO $patch$
DECLARE v_def text;
BEGIN
  v_def:=pg_get_functiondef('priv.srd_iniciar_levantar_caido_srd(bigint,text)'::regprocedure);
  v_def:=replace(v_def,'  v_token_id text;','  v_token_id text; v_profile jsonb; v_character_id text;');
  v_def:=replace(v_def,
    $old$  v_faction:=lower(coalesce(v_token->>'combat_faction',''));
  IF v_faction NOT IN ('ally','hostile') THEN
    RAISE EXCEPTION 'Configure primeiro a facção do token para identificar inimigos que ameacem seu espaço.';
  END IF;$old$,
    $new$  v_faction:=lower(coalesce(v_token->>'combat_faction',''));
  IF v_faction NOT IN ('ally','hostile') THEN
    RAISE EXCEPTION 'Configure primeiro a facção do token para identificar inimigos que ameacem seu espaço.';
  END IF;
  IF EXISTS(
    SELECT 1 FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
    WHERE t->>'id' IS DISTINCT FROM btrim(p_token_id)
      AND t->>'key' IS DISTINCT FROM btrim(p_token_id)
      AND coalesce(t->>'tipo','') IN ('player','npc','monstro')
      AND lower(coalesce(t->>'combat_faction','')) NOT IN ('ally','hostile','neutral')
  ) THEN
    RAISE EXCEPTION 'Há combatentes sem facção configurada. Defina ally, hostile ou neutral para que nenhum inimigo ameaçador seja ignorado.';
  END IF;
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_token_id));
  v_character_id:=v_profile->>'character_id';
  IF v_character_id IS NOT NULL AND (
    priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_actions')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_move')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'helpless')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'unconscious')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dying')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'stable')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dead')
  ) THEN
    RAISE EXCEPTION 'A condição da ficha impede levantar-se.';
  END IF;$new$
  );
  IF position('v_character_id:=v_profile->>' in v_def)=0 THEN
    RAISE EXCEPTION 'Não foi possível adicionar as verificações de condição do personagem.';
  END IF;
  EXECUTE v_def;
END;
$patch$;

DO $patch$
DECLARE v_def text;
BEGIN
  v_def:=pg_get_functiondef('priv.srd_resolver_levantar_caido_apos_aoo_srd(bigint,uuid)'::regprocedure);
  v_def:=replace(v_def,'  v_key text; v_condition_count integer;','  v_key text; v_condition_count integer; v_profile jsonb; v_character_id text;');
  v_def:=replace(v_def,
    $old$  IF priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'no_actions')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'no_move')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'dying')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'stable')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'dead')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'unconscious') THEN
    RAISE EXCEPTION 'O alvo não pode levantar-se após as reações.';
  END IF;$old$,
    $new$  IF priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'no_actions')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'no_move')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'dying')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'stable')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'dead')
     OR priv.srd_condition_has_flag(p_campaign_id,'token',v_pending.mover_token_id,'unconscious') THEN
    RAISE EXCEPTION 'O alvo não pode levantar-se após as reações.';
  END IF;
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,v_pending.mover_token_id);
  v_character_id:=v_profile->>'character_id';
  IF v_character_id IS NOT NULL AND (
    priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_actions')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_move')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dying')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'stable')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dead')
    OR priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'unconscious')
  ) THEN
    RAISE EXCEPTION 'A ficha do personagem não permite levantar-se.';
  END IF;$new$
  );
  IF position('v_character_id:=v_profile->>' in v_def)=0 THEN
    RAISE EXCEPTION 'Não foi possível adicionar as verificações de condição após as reações.';
  END IF;
  EXECUTE v_def;
END;
$patch$;
