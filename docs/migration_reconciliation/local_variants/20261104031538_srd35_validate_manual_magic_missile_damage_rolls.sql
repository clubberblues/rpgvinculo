CREATE OR REPLACE FUNCTION public.conjurar_missil_magico_srd_manual(
  p_character_id TEXT,
  p_spell_id TEXT,
  p_slot_level SMALLINT,
  p_target_token_key TEXT,
  p_damage_rolls INTEGER[]
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=pg_catalog,public,priv,pg_temp
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_missiles INTEGER;
  v_damage INTEGER;
  v_result JSONB;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_spell_id IS DISTINCT FROM 'srd35_magic_missile' THEN RAISE EXCEPTION 'Esta resolução aceita somente Míssil Mágico.'; END IF;
  IF NULLIF(BTRIM(p_target_token_key),'') IS NULL THEN RAISE EXCEPTION 'Selecione um alvo.'; END IF;

  SELECT ch.* INTO v_character
  FROM public.characters ch
  WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.user_id=auth.uid()
  FOR UPDATE;
  IF NOT FOUND OR v_character.campaign_id IS NULL THEN RAISE EXCEPTION 'Ficha própria em campanha não encontrada.'; END IF;

  SELECT sh.* INTO v_sheet
  FROM public.srd_character_sheets sh
  WHERE sh.character_id::TEXT=BTRIM(p_character_id)
  FOR UPDATE;
  IF NOT FOUND OR v_sheet.nivel IS NULL OR v_sheet.nivel<1 OR v_sheet.nivel>20 THEN
    RAISE EXCEPTION 'Ficha ou nível de conjurador inválido.';
  END IF;

  v_missiles:=LEAST(5,CEIL(v_sheet.nivel/2.0)::INTEGER);
  IF p_damage_rolls IS NULL OR cardinality(p_damage_rolls)<>v_missiles THEN
    RAISE EXCEPTION 'Míssil Mágico exige um resultado individual de D4 para cada míssil (%).',v_missiles;
  END IF;
  IF EXISTS(SELECT 1 FROM unnest(p_damage_rolls) r(value) WHERE r.value IS NULL OR r.value NOT BETWEEN 1 AND 4) THEN
    RAISE EXCEPTION 'Cada míssil causa 1d4+1; os resultados precisam estar entre 1 e 4.';
  END IF;
  SELECT COALESCE(sum(r.value),0)::INTEGER+v_missiles INTO v_damage
  FROM unnest(p_damage_rolls) r(value);

  v_result:=public.conjurar_missil_magico_srd(
    p_character_id,p_spell_id,p_slot_level,p_target_token_key,v_damage
  );
  RETURN COALESCE(v_result,'{}'::JSONB)||jsonb_build_object(
    'damage_rolls',to_jsonb(p_damage_rolls),
    'damage_formula',v_missiles||'d4+'||v_missiles
  );
END;
$function$;

REVOKE ALL ON FUNCTION public.conjurar_missil_magico_srd(TEXT,TEXT,SMALLINT,TEXT,INTEGER) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.conjurar_missil_magico_srd(TEXT,TEXT,SMALLINT,TEXT,INTEGER) TO service_role;
REVOKE ALL ON FUNCTION public.conjurar_missil_magico_srd_manual(TEXT,TEXT,SMALLINT,TEXT,INTEGER[]) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.conjurar_missil_magico_srd_manual(TEXT,TEXT,SMALLINT,TEXT,INTEGER[]) TO authenticated,service_role;
