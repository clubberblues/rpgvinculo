
CREATE OR REPLACE FUNCTION priv.srd_saving_throw_bonus(
  p_campaign_id bigint,
  p_target_kind text,
  p_target_id text,
  p_save_type text,
  p_context text DEFAULT NULL
)
RETURNS integer
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path=pg_catalog,public,priv,pg_temp
AS $function$
DECLARE
  v_save text:=lower(COALESCE(p_save_type,''));
  v_ability text;
  v_score integer;
  v_base integer:=0;
  v_bonus integer:=0;
  v_save_text text;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_token jsonb;
  v_feats jsonb;
BEGIN
  IF v_save NOT IN ('fortitude','reflex','will') THEN
    RAISE EXCEPTION 'Tipo de resistência inválido.';
  END IF;

  IF p_target_kind='character' THEN
    SELECT sh.* INTO v_sheet
    FROM public.srd_character_sheets sh
    JOIN public.characters ch ON ch.id=sh.character_id
    WHERE ch.id::text=BTRIM(p_target_id) AND ch.campaign_id=p_campaign_id
    FOR SHARE OF sh;
    IF NOT FOUND THEN RAISE EXCEPTION 'Ficha do alvo não encontrada para calcular resistência.'; END IF;

    v_ability:=CASE v_save WHEN 'fortitude' THEN 'CON' WHEN 'reflex' THEN 'DES' ELSE 'SAB' END;
    v_score:=COALESCE(NULLIF(v_sheet.atributos->>v_ability,'')::integer,10);
    v_feats:=COALESCE(v_sheet.talentos,'[]'::jsonb);

    SELECT COALESCE(sum(
      CASE v_save
        WHEN 'fortitude' THEN pr.base_fortitude
        WHEN 'reflex' THEN pr.base_reflex
        ELSE pr.base_will
      END
    ),0)::integer
    INTO v_base
    FROM public.srd_character_class_levels cl
    JOIN public.srd_class_level_progressions pr
      ON pr.class_id=cl.class_id AND pr.class_level=cl.class_level
    WHERE cl.character_id=v_sheet.character_id;

    IF NOT FOUND OR NOT EXISTS(
      SELECT 1 FROM public.srd_character_class_levels WHERE character_id=v_sheet.character_id
    ) THEN
      SELECT CASE v_save
        WHEN 'fortitude' THEN pr.base_fortitude
        WHEN 'reflex' THEN pr.base_reflex
        ELSE pr.base_will
      END
      INTO v_base
      FROM public.srd_class_level_progressions pr
      WHERE pr.class_id=v_sheet.classe_id AND pr.class_level=v_sheet.nivel;
      IF v_base IS NULL THEN
        SELECT CASE v_save
          WHEN 'fortitude' THEN CASE WHEN cl.fort_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END
          WHEN 'reflex' THEN CASE WHEN cl.ref_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END
          ELSE CASE WHEN cl.von_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END
        END
        INTO v_base
        FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
      END IF;
    END IF;

    v_bonus:=COALESCE(v_base,0)+FLOOR((v_score-10)::numeric/2)::integer;
    IF jsonb_typeof(v_feats)='array' THEN
      IF v_save='fortitude' AND EXISTS(SELECT 1 FROM jsonb_array_elements(v_feats) f WHERE COALESCE(f->>'id',f#>>'{}')='srd35_feat_great_fortitude') THEN v_bonus:=v_bonus+2; END IF;
      IF v_save='reflex' AND EXISTS(SELECT 1 FROM jsonb_array_elements(v_feats) f WHERE COALESCE(f->>'id',f#>>'{}')='srd35_feat_lightning_reflexes') THEN v_bonus:=v_bonus+2; END IF;
      IF v_save='will' AND EXISTS(SELECT 1 FROM jsonb_array_elements(v_feats) f WHERE COALESCE(f->>'id',f#>>'{}')='srd35_feat_iron_will') THEN v_bonus:=v_bonus+2; END IF;
    END IF;
  ELSIF p_target_kind='token' THEN
    SELECT t.value INTO v_token
    FROM public.campaigns c
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array' THEN c.cba_data->'tokens' ELSE '[]'::jsonb END
    ) t(value)
    WHERE c.id=p_campaign_id AND (t.value->>'id'=BTRIM(p_target_id) OR t.value->>'key'=BTRIM(p_target_id))
    LIMIT 1;
    IF v_token IS NULL THEN RAISE EXCEPTION 'Token-alvo não encontrado para calcular resistência.'; END IF;
    v_save_text:=CASE v_save
      WHEN 'fortitude' THEN COALESCE(v_token->'monsterStats'->>'fortitude',v_token->'monsterStats'->>'fort')
      WHEN 'reflex' THEN COALESCE(v_token->'monsterStats'->>'reflexos',v_token->'monsterStats'->>'reflex')
      ELSE COALESCE(v_token->'monsterStats'->>'vontade',v_token->'monsterStats'->>'will')
    END;
    v_base:=COALESCE(NULLIF(substring(COALESCE(v_save_text,'') FROM '[-+]?[0-9]+'),'')::integer,0);
    v_bonus:=v_base;
  ELSE
    RAISE EXCEPTION 'Tipo de alvo inválido para resistência.';
  END IF;

  v_bonus:=v_bonus
    +priv.srd_effective_modifier(p_campaign_id,p_target_kind,BTRIM(p_target_id),v_save)
    +priv.srd_effective_modifier(p_campaign_id,p_target_kind,BTRIM(p_target_id),'saving_throw');
  IF lower(COALESCE(p_context,''))='fear' THEN
    v_bonus:=v_bonus+priv.srd_effective_modifier(p_campaign_id,p_target_kind,BTRIM(p_target_id),'fear_saving_throw');
  END IF;
  RETURN v_bonus;
END;
$function$;

REVOKE ALL ON FUNCTION priv.srd_saving_throw_bonus(bigint,text,text,text,text) FROM PUBLIC,anon,authenticated;
