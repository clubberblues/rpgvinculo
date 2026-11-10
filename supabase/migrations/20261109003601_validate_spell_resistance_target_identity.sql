
CREATE OR REPLACE FUNCTION priv.srd_spell_resistance_value(
  p_campaign_id bigint,
  p_target_kind text,
  p_target_id text
)
RETURNS integer
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_text text;
  v_token jsonb;
  v_token_count integer;
  v_qualities text;
  v_match text[];
  v_value integer;
BEGIN
  IF p_campaign_id IS NULL OR NULLIF(BTRIM(p_target_id),'') IS NULL THEN
    RAISE EXCEPTION 'Alvo inválido para resistência à magia.';
  END IF;

  IF p_target_kind='character' THEN
    IF NOT EXISTS (
      SELECT 1 FROM public.characters ch
      WHERE ch.id::text=BTRIM(p_target_id)
        AND ch.campaign_id=p_campaign_id
    ) THEN
      RAISE EXCEPTION 'Personagem-alvo não encontrado na campanha.';
    END IF;
    RETURN GREATEST(0,priv.srd_effective_modifier(
      p_campaign_id,'character',BTRIM(p_target_id),'spell_resistance'
    ));
  ELSIF p_target_kind<>'token' THEN
    RAISE EXCEPTION 'Tipo de alvo inválido para resistência à magia.';
  END IF;

  SELECT count(*)::integer, (array_agg(t.value))[1]
    INTO v_token_count,v_token
  FROM public.campaigns c
  CROSS JOIN LATERAL jsonb_array_elements(
    CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array'
      THEN c.cba_data->'tokens' ELSE '[]'::jsonb END
  ) t(value)
  WHERE c.id=p_campaign_id
    AND (t.value->>'id'=BTRIM(p_target_id) OR t.value->>'key'=BTRIM(p_target_id));

  IF v_token_count<>1 THEN
    RAISE EXCEPTION 'Token-alvo ausente ou duplicado ao verificar resistência à magia.';
  END IF;

  v_text:=COALESCE(
    v_token->'monsterStats'->>'spell_resistance',
    v_token->'monsterStats'->>'resistencia_magia'
  );
  v_value:=COALESCE(
    NULLIF(substring(COALESCE(v_text,'') FROM '[0-9]+'),'')::integer,
    0
  );
  v_qualities:=lower(COALESCE(
    v_token->'monsterStats'->'qualidades_especiais'->>'special_qualities',
    v_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'special_qualities',
    v_token->'monsterStats'->>'special_qualities',
    ''
  ));

  IF v_value=0 THEN
    v_match:=regexp_match(v_qualities,'spell resistance[[:space:]]+([0-9]+)');
    IF v_match IS NOT NULL THEN
      v_value:=v_match[1]::integer;
    END IF;
  END IF;

  RETURN GREATEST(0,COALESCE(v_value,0));
END;
$function$;
