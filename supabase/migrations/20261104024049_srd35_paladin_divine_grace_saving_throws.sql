DO $patch_divine_grace$
DECLARE
  v_definition text;
  v_marker text := '  v_bonus:=v_bonus' || E'\n    +priv.srd_effective_modifier';
  v_add text := E'  -- D&D 3.5: Graça Divina adiciona o modificador positivo de Carisma a todos os testes de resistência a partir do 2º nível de Paladino.\n  IF p_target_kind=''character'' THEN\n    SELECT COALESCE(MAX(cl.class_level),0) INTO v_paladin_level\n      FROM public.srd_character_class_levels cl\n      JOIN public.srd_classes cls ON cls.id=cl.class_id\n     WHERE cl.character_id=v_sheet.character_id AND cls.class_key=''paladin'';\n    IF v_paladin_level=0 AND NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels WHERE character_id=v_sheet.character_id)\n       AND v_sheet.classe_id=''paladino'' THEN\n      v_paladin_level:=v_sheet.nivel;\n    END IF;\n    IF v_paladin_level>=2 THEN\n      v_charisma_score:=COALESCE(NULLIF(v_sheet.atributos->>''CAR'','''')::integer,10);\n      v_bonus:=v_bonus+GREATEST(0,FLOOR((v_charisma_score-10)::numeric/2)::integer);\n    END IF;\n  END IF;\n';
BEGIN
  SELECT pg_get_functiondef('priv.srd_saving_throw_bonus(bigint,text,text,text,text)'::regprocedure)
    INTO v_definition;
  IF position('v_paladin_level' IN v_definition)>0 THEN RETURN; END IF;
  IF position('v_feats jsonb; v_ability_effect text;' IN v_definition)=0 THEN
    RAISE EXCEPTION 'Declaração esperada do resolvedor de resistência não encontrada.';
  END IF;
  v_definition:=replace(v_definition,'v_feats jsonb; v_ability_effect text;',
    'v_feats jsonb; v_ability_effect text; v_charisma_score integer; v_paladin_level integer:=0;');
  IF position(v_marker IN v_definition)=0 THEN
    RAISE EXCEPTION 'Ponto de integração de Graça Divina não encontrado.';
  END IF;
  v_definition:=replace(v_definition,v_marker,v_add||v_marker);
  EXECUTE v_definition;
END;
$patch_divine_grace$;

UPDATE public.srd_class_level_features
SET mechanics = jsonb_set(
  jsonb_set(
    jsonb_set(COALESCE(mechanics,'{}'::jsonb),'{engine_status}','"partial"'::jsonb,true),
    '{implemented_features}','["divine_grace"]'::jsonb,true
  ),
  '{pending_features}','["lay_on_hands"]'::jsonb,true
)
WHERE class_id='paladino' AND class_level=2 AND feature_key='features'
  AND mechanics->>'engine_status' IS DISTINCT FROM 'partial';
