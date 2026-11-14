CREATE OR REPLACE FUNCTION public.registrar_iniciativa_d20(
  p_campaign_id BIGINT,
  p_personagem_id TEXT,
  p_d20 INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, pg_temp
AS $$
DECLARE
  v_role TEXT;
  v_state TEXT;
  v_data JSONB;
  v_order JSONB;
  v_expected JSONB;
  v_name TEXT;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_dex INTEGER;
  v_dex_mod INTEGER;
  v_feat_bonus INTEGER := 0;
  v_effect_bonus INTEGER := 0;
  v_total INTEGER;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_d20 IS NULL OR p_d20 NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'A iniciativa exige o resultado manual de um D20 entre 1 e 20.';
  END IF;

  SELECT role INTO v_role FROM public.members
  WHERE campaign_id=p_campaign_id AND user_id=auth.uid() LIMIT 1;
  IF v_role IS DISTINCT FROM 'PLAYER' THEN RAISE EXCEPTION 'Somente um jogador pode registrar sua iniciativa.'; END IF;

  SELECT nome INTO v_name FROM public.characters
  WHERE id::TEXT=BTRIM(p_personagem_id) AND campaign_id=p_campaign_id AND user_id=auth.uid();
  IF NOT FOUND THEN RAISE EXCEPTION 'A ficha não pertence ao jogador autenticado.'; END IF;

  SELECT state,combat_data INTO v_state,v_data
  FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR UPPER(COALESCE(v_state,''))<>'COMBATE' OR v_data IS NULL THEN
    RAISE EXCEPTION 'Não há solicitação de iniciativa ativa nesta campanha.';
  END IF;
  v_expected:=CASE WHEN jsonb_typeof(v_data->'expected_character_ids')='array' THEN v_data->'expected_character_ids' ELSE '[]'::JSONB END;
  IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements_text(v_expected) e(id) WHERE e.id=BTRIM(p_personagem_id)) THEN
    RAISE EXCEPTION 'Esta ficha não faz parte da solicitação de iniciativa atual.';
  END IF;
  v_order:=CASE WHEN jsonb_typeof(v_data->'turn_order')='array' THEN v_data->'turn_order' ELSE '[]'::JSONB END;
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(v_order) e(value)
    WHERE e.value->>'id'=BTRIM(p_personagem_id)
      AND COALESCE((e.value->>'is_monster')::BOOLEAN,FALSE)=FALSE) THEN
    RETURN v_data;
  END IF;

  SELECT * INTO v_sheet FROM public.srd_character_sheets
  WHERE character_id::TEXT=BTRIM(p_personagem_id) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD necessária para calcular iniciativa.'; END IF;

  v_dex:=COALESCE(
    CASE WHEN COALESCE(v_sheet.atributos->>'DES','') ~ '^-?[0-9]{1,2}$' THEN (v_sheet.atributos->>'DES')::INTEGER END,
    CASE WHEN COALESCE(v_sheet.atributos->>'destreza','') ~ '^-?[0-9]{1,2}$' THEN (v_sheet.atributos->>'destreza')::INTEGER END,
    CASE WHEN COALESCE(v_sheet.atributos->>'dexterity','') ~ '^-?[0-9]{1,2}$' THEN (v_sheet.atributos->>'dexterity')::INTEGER END,
    CASE WHEN COALESCE(v_sheet.atributos->>'DEX','') ~ '^-?[0-9]{1,2}$' THEN (v_sheet.atributos->>'DEX')::INTEGER END
  );
  IF v_dex IS NULL OR v_dex NOT BETWEEN -20 AND 50 THEN RAISE EXCEPTION 'Destreza inválida na ficha.'; END IF;
  v_dex_mod:=CASE WHEN v_dex>=4 THEN FLOOR((v_dex-10)::NUMERIC/2)::INTEGER ELSE v_dex END;

  IF EXISTS(
    SELECT 1 FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END
    ) f(value)
    WHERE COALESCE(f.value->>'id',f.value #>> '{}')='iniciativa_aprimorada'
  ) THEN v_feat_bonus:=4; END IF;

  v_effect_bonus:=COALESCE(priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_personagem_id),'initiative'),0);
  v_total:=p_d20+v_dex_mod+v_feat_bonus+v_effect_bonus;

  RETURN public.registrar_iniciativa(p_campaign_id,p_personagem_id,v_name,v_total);
END;
$$;

REVOKE ALL ON FUNCTION public.registrar_iniciativa(BIGINT,TEXT,TEXT,INTEGER) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.registrar_iniciativa(BIGINT,TEXT,TEXT,INTEGER) TO service_role;
REVOKE ALL ON FUNCTION public.registrar_iniciativa_d20(BIGINT,TEXT,INTEGER) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.registrar_iniciativa_d20(BIGINT,TEXT,INTEGER) TO authenticated,service_role;
