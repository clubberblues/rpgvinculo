CREATE OR REPLACE FUNCTION priv.srd_passive_feat_modifier(
  p_character_id bigint,
  p_stat text
)
RETURNS integer
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_bonus integer := 0;
BEGIN
  IF p_character_id IS NULL OR NULLIF(BTRIM(p_stat), '') IS NULL THEN
    RETURN 0;
  END IF;

  SELECT COALESCE(SUM(
    CASE
      WHEN grouped.bonus_type IN ('untyped', 'dodge', 'circumstance')
        THEN grouped.sum_value
      ELSE grouped.max_value
    END
  ), 0)::integer
    INTO v_bonus
    FROM (
      SELECT
        COALESCE(NULLIF(effect.value->>'bonus_type', ''), 'untyped') AS bonus_type,
        SUM((effect.value->>'value')::numeric) AS sum_value,
        MAX((effect.value->>'value')::numeric) AS max_value
      FROM public.srd_character_sheets AS sheet
      CROSS JOIN LATERAL jsonb_array_elements(
        CASE WHEN jsonb_typeof(sheet.talentos)='array'
          THEN sheet.talentos ELSE '[]'::jsonb END
      ) AS chosen(value)
      JOIN public.srd_feats AS feat
        ON feat.id=COALESCE(chosen.value->>'id',chosen.value #>> '{}')
      CROSS JOIN LATERAL jsonb_array_elements(
        CASE WHEN jsonb_typeof(feat.mechanics->'resolution'->'effects')='array'
          THEN feat.mechanics->'resolution'->'effects' ELSE '[]'::jsonb END
      ) AS effect(value)
      WHERE sheet.character_id=p_character_id
        AND feat.mechanics->>'engine_status'='implemented'
        AND feat.mechanics->'activation'->>'mode'='passive'
        AND effect.value->>'kind'='modifier'
        AND lower(effect.value->>'stat')=lower(BTRIM(p_stat))
        AND COALESCE(effect.value->>'value','') ~ '^-?[0-9]+$'
      GROUP BY COALESCE(NULLIF(effect.value->>'bonus_type', ''), 'untyped')
    ) AS grouped;

  RETURN COALESCE(v_bonus,0);
END;
$function$;

REVOKE ALL ON FUNCTION priv.srd_passive_feat_modifier(bigint,text) FROM PUBLIC, anon, authenticated;

COMMENT ON FUNCTION priv.srd_passive_feat_modifier(bigint,text)
IS 'Soma modificadores passivos de talentos com mecânica estruturada e implementada, respeitando empilhamento básico por tipo de bônus.';

UPDATE public.srd_feats
SET mechanics = jsonb_set(mechanics,'{resolution,effects,0,bonus_type}','"untyped"'::jsonb,true)
WHERE id='iniciativa_aprimorada' AND mechanics->>'engine_status'='implemented';

DO $migration$
DECLARE
  v_player_definition text;
  v_gm_definition text;
  v_old_player text := $old$
  IF EXISTS(
    SELECT 1 FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END
    ) f(value)
    WHERE COALESCE(f.value->>'id',f.value #>> '{}')='iniciativa_aprimorada'
  ) THEN v_feat_bonus:=4; END IF;
$old$;
  v_new_player text := $new$
  v_feat_bonus:=priv.srd_passive_feat_modifier(v_sheet.character_id,'initiative');
$new$;
  v_old_gm text := $old$CASE WHEN token.linked_feats::TEXT LIKE '%iniciativa_aprimorada%' THEN 4 END,$old$;
  v_new_gm text := $new$priv.srd_passive_feat_modifier(token.linked_character_id,'initiative'),$new$;
BEGIN
  v_player_definition := pg_get_functiondef('public.registrar_iniciativa_d20(bigint,text,integer)'::regprocedure);
  IF position(v_old_player IN v_player_definition)=0 THEN
    RAISE EXCEPTION 'Não foi possível localizar o cálculo legado do talento no fluxo de iniciativa do jogador.';
  END IF;
  v_player_definition := replace(v_player_definition,v_old_player,v_new_player);
  EXECUTE v_player_definition;

  v_gm_definition := pg_get_functiondef('public.iniciar_iniciativa_com_dados(bigint,text[],text,jsonb)'::regprocedure);
  IF position(v_old_gm IN v_gm_definition)=0 THEN
    RAISE EXCEPTION 'Não foi possível localizar o cálculo legado do talento no fluxo de iniciativa do Mestre.';
  END IF;
  v_gm_definition := replace(v_gm_definition,v_old_gm,v_new_gm);
  EXECUTE v_gm_definition;
END;
$migration$;
