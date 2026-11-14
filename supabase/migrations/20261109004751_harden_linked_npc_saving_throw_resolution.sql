
DO $migration$
DECLARE
  v_definition text;
  v_updated text;
  v_old_decl text := $a$ v_token jsonb;
  v_feats jsonb; v_ability_effect text; v_charisma_score integer; v_paladin_level integer:=0; v_barbarian_level integer:=0; v_rogue_level integer:=0; v_monk_level integer:=0;$a$;
  v_new_decl text := $b$ v_token jsonb; v_token_count integer;
  v_feats jsonb; v_ability_effect text; v_charisma_score integer; v_paladin_level integer:=0; v_barbarian_level integer:=0; v_rogue_level integer:=0; v_monk_level integer:=0;$b$;
  v_old_token text := $c$    SELECT t.value INTO v_token
    FROM public.campaigns c
    CROSS JOIN LATERAL jsonb_array_elements(CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array' THEN c.cba_data->'tokens' ELSE '[]'::jsonb END) t(value)
    WHERE c.id=p_campaign_id AND (t.value->>'id'=BTRIM(p_target_id) OR t.value->>'key'=BTRIM(p_target_id)) LIMIT 1;
    IF v_token IS NULL THEN RAISE EXCEPTION 'Token-alvo não encontrado para calcular resistência.'; END IF;$c$;
  v_new_token text := $d$    SELECT count(*)::integer,(array_agg(t.value))[1] INTO v_token_count,v_token
    FROM public.campaigns c
    CROSS JOIN LATERAL jsonb_array_elements(CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array' THEN c.cba_data->'tokens' ELSE '[]'::jsonb END) t(value)
    WHERE c.id=p_campaign_id AND (t.value->>'id'=BTRIM(p_target_id) OR t.value->>'key'=BTRIM(p_target_id));
    IF v_token_count<>1 THEN RAISE EXCEPTION 'Token-alvo ausente ou duplicado para calcular resistência.'; END IF;$d$;
  v_old_link text := $e$      SELECT sh.* INTO v_sheet FROM public.srd_character_sheets sh
      JOIN public.characters ch ON ch.id=sh.character_id
      WHERE ch.id::text=NULLIF(v_token->>'sourceCharacterId','');$e$;
  v_new_link text := $f$      SELECT sh.* INTO v_sheet FROM public.srd_character_sheets sh
      JOIN public.characters ch ON ch.id=sh.character_id
      WHERE ch.id::text=NULLIF(v_token->>'sourceCharacterId','')
        AND ch.campaign_id=p_campaign_id;$f$;
  v_old_cha text := $g$      v_charisma_score:=COALESCE(NULLIF(v_sheet.atributos->>'CAR','')::integer,10);$g$;
  v_new_cha text := $h$      v_charisma_score:=COALESCE(NULLIF(v_sheet.atributos->>'CAR','')::integer,10)
        +priv.srd_effective_modifier(p_campaign_id,p_target_kind,BTRIM(p_target_id),'charisma');$h$;
BEGIN
  SELECT pg_get_functiondef('priv.srd_saving_throw_bonus(bigint,text,text,text,text)'::regprocedure)
    INTO v_definition;
  IF position(v_old_decl IN v_definition)=0 OR position(v_old_token IN v_definition)=0
     OR position(v_old_link IN v_definition)=0 OR position(v_old_cha IN v_definition)=0 THEN
    RAISE EXCEPTION 'Trechos esperados da resistência não encontrados; migração cancelada.';
  END IF;
  IF position(v_old_decl IN substring(v_definition FROM position(v_old_decl IN v_definition)+length(v_old_decl)))>0
     OR position(v_old_token IN substring(v_definition FROM position(v_old_token IN v_definition)+length(v_old_token)))>0
     OR position(v_old_link IN substring(v_definition FROM position(v_old_link IN v_definition)+length(v_old_link)))>0
     OR position(v_old_cha IN substring(v_definition FROM position(v_old_cha IN v_definition)+length(v_old_cha)))>0 THEN
    RAISE EXCEPTION 'Trecho esperado aparece mais de uma vez; migração cancelada.';
  END IF;
  v_updated:=replace(v_definition,v_old_decl,v_new_decl);
  v_updated:=replace(v_updated,v_old_token,v_new_token);
  v_updated:=replace(v_updated,v_old_link,v_new_link);
  v_updated:=replace(v_updated,v_old_cha,v_new_cha);
  EXECUTE v_updated;
END
$migration$;
