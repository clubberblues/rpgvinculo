CREATE OR REPLACE FUNCTION public.criar_personagem_srd_completo(
  p_nome text,
  p_raca_id text,
  p_classe_id text,
  p_atributos jsonb,
  p_pericias jsonb,
  p_talentos jsonb
)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_character_id TEXT;
  v_class public.srd_classes%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_pick JSONB;
  v_feat public.srd_feats%ROWTYPE;
  v_skill_points_spent JSONB := '{}'::jsonb;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF p_talentos IS NULL OR jsonb_typeof(p_talentos)<>'array' THEN
    RAISE EXCEPTION 'Os talentos precisam ser enviados como uma lista.';
  END IF;
  SELECT cl.* INTO v_class FROM public.srd_classes cl WHERE cl.id=p_classe_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Classe SRD não encontrada.'; END IF;

  FOR v_pick IN SELECT value FROM jsonb_array_elements(p_talentos) LOOP
    IF jsonb_typeof(v_pick)<>'object' OR NULLIF(BTRIM(v_pick->>'id'),'') IS NULL THEN
      RAISE EXCEPTION 'Cada escolha de talento precisa de um ID válido.';
    END IF;
    SELECT f.* INTO v_feat FROM public.srd_feats f WHERE f.id=v_pick->>'id';
    IF NOT FOUND THEN RAISE EXCEPTION 'Talento não encontrado: %.',v_pick->>'id'; END IF;
    IF COALESCE(v_feat.requisitos->>'type','General')<>'General' THEN
      RAISE EXCEPTION '% não é um talento geral disponível na criação básica.',v_feat.nome;
    END IF;
  END LOOP;

  v_character_id:=public.criar_personagem_srd(p_nome,p_raca_id,p_classe_id,p_atributos);
  PERFORM public.salvar_pericias_srd(v_character_id,p_pericias);
  PERFORM public.salvar_talentos_srd(v_character_id,p_talentos);

  SELECT sh.* INTO v_sheet
    FROM public.srd_character_sheets sh
   WHERE sh.character_id::text=v_character_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'A ficha SRD foi criada, mas não pôde ser relida para registrar sua trilha de classe.'; END IF;

  SELECT COALESCE(
    jsonb_object_agg(
      skill.key,
      to_jsonb(
        (skill.value #>> '{}')::numeric *
        CASE
          WHEN skill.key='srd35_skill_speak_language' OR EXISTS (
            SELECT 1
              FROM jsonb_array_elements_text(COALESCE(v_class.pericias_classe,'[]'::jsonb)) AS class_skill(name)
             WHERE public.srd35_normalizar_parametro_talento(class_skill.name)=public.srd35_normalizar_parametro_talento(sk.nome)
                OR (
                  public.srd35_normalizar_parametro_talento(class_skill.name)='conhecimentoqualquer'
                  AND sk.nome ILIKE 'Conhecimento%'
                )
          ) THEN 1 ELSE 2
        END
      )
    ),
    '{}'::jsonb
  )
    INTO v_skill_points_spent
    FROM jsonb_each(
      CASE WHEN jsonb_typeof(v_sheet.pericias)='object'
           THEN v_sheet.pericias ELSE '{}'::jsonb END
    ) AS skill(key,value)
    JOIN public.srd_skills sk ON sk.id=skill.key
   WHERE jsonb_typeof(skill.value)='number';

  INSERT INTO public.srd_character_class_levels
    (character_id,class_id,class_level,taken_at_character_level,hit_points_gained,skill_points_spent)
  VALUES
    (v_sheet.character_id,v_class.id,GREATEST(1,COALESCE(v_sheet.nivel,1)),1,v_sheet.pv_max,v_skill_points_spent)
  ON CONFLICT (character_id,class_id) DO UPDATE
    SET class_level=EXCLUDED.class_level,
        taken_at_character_level=COALESCE(public.srd_character_class_levels.taken_at_character_level,1),
        hit_points_gained=EXCLUDED.hit_points_gained,
        skill_points_spent=EXCLUDED.skill_points_spent;

  RETURN v_character_id;
END;
$function$;