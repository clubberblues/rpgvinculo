-- Some legacy catalog entries are already metric; convert only imported SRD-pound rows.
CREATE OR REPLACE FUNCTION public.srd35_deslocamento_personagem(p_character_id text, p_base_speed_m numeric)
 RETURNS numeric
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_attrs JSONB; v_race_id TEXT; v_race_name TEXT; v_size TEXT; v_class_key TEXT;
  v_level INTEGER:=1; v_gold NUMERIC:=0; v_strength INTEGER:=10; v_base_speed NUMERIC:=COALESCE(p_base_speed_m,9);
  v_speed NUMERIC; v_weight_kg NUMERIC:=0; v_heavy_armor BOOLEAN:=FALSE;
  v_medium_heavy_armor BOOLEAN:=FALSE; v_any_armor BOOLEAN:=FALSE; v_is_dwarf BOOLEAN:=FALSE;
  v_heavy_table NUMERIC[]:=ARRAY[5,10,15,20,25,30,35,40,45,50,57.5,65,75,87.5,100,115,130,150,175,200,230,260,300,350,400,460,520,600,700]::NUMERIC[];
  v_table_strength INTEGER; v_decades INTEGER:=0; v_heavy_max NUMERIC; v_light_max NUMERIC;
  v_medium_max NUMERIC; v_size_multiplier NUMERIC:=1; v_load TEXT:='light'; v_size_normalized TEXT;
BEGIN
  SELECT sh.atributos,sh.raca_id,sh.nivel,COALESCE(sh.ouro,0),race.nome,race.tamanho,
         COALESCE(class.class_key,class.id)
    INTO v_attrs,v_race_id,v_level,v_gold,v_race_name,v_size,v_class_key
    FROM public.srd_character_sheets sh
    LEFT JOIN public.srd_races race ON race.id::TEXT=sh.raca_id::TEXT
    LEFT JOIN public.srd_classes class ON class.id::TEXT=sh.classe_id::TEXT
   WHERE sh.character_id::TEXT=BTRIM(p_character_id);
  IF NOT FOUND THEN RETURN v_base_speed; END IF;

  v_strength:=GREATEST(1,COALESCE((v_attrs->>'FOR')::INTEGER,10));
  v_is_dwarf:=v_race_id='anao' OR public.srd35_normalizar_parametro_talento(COALESCE(v_race_name,''))='anao';
  v_size_normalized:=public.srd35_normalizar_parametro_talento(COALESCE(v_size,'medio'));

  -- Registros importados do SRD usam libras; registros legados em português já armazenam kg.
  SELECT COALESCE(SUM(COALESCE(eq.peso,0)*CASE WHEN POSITION('lb' IN LOWER(COALESCE(eq.detalhes->>'weight',''))) > 0 OR eq.detalhes->>'source_dataset'='olimot/srd-v3.5-md' THEN 0.5 ELSE 1 END*GREATEST(1,ce.quantidade)),0),
         COALESCE(BOOL_OR(ce.equipado AND armor.kind LIKE 'heavyarmor%'),FALSE),
         COALESCE(BOOL_OR(ce.equipado AND (armor.kind LIKE 'mediumarmor%' OR armor.kind LIKE 'heavyarmor%')),FALSE),
         COALESCE(BOOL_OR(ce.equipado AND armor.kind IN ('lightarmor','mediumarmor','heavyarmor')),FALSE)
    INTO v_weight_kg,v_heavy_armor,v_medium_heavy_armor,v_any_armor
    FROM public.srd_character_equipment ce
    JOIN public.srd_equipment eq ON eq.id=ce.equipment_id
    CROSS JOIN LATERAL (SELECT public.srd35_normalizar_parametro_talento(COALESCE(eq.detalhes->>'category',eq.categoria,'')) AS kind) armor
   WHERE ce.character_id=BTRIM(p_character_id);
  -- 500 PO pesam 5 kg.
  v_weight_kg:=v_weight_kg+(v_gold/100.0);

  v_size_multiplier:=CASE
    WHEN v_size_normalized IN ('minusculo','fine') THEN 0.125
    WHEN v_size_normalized IN ('diminuto','diminutive') THEN 0.25
    WHEN v_size_normalized IN ('miudo','tiny') THEN 0.5
    WHEN v_size_normalized IN ('pequeno','small') THEN 0.75
    WHEN v_size_normalized IN ('grande','large') THEN 2
    WHEN v_size_normalized IN ('enorme','huge') THEN 4
    WHEN v_size_normalized IN ('imenso','gargantuan') THEN 8
    WHEN v_size_normalized='colossal' THEN 16 ELSE 1 END;
  IF v_strength>=30 THEN
    v_decades:=FLOOR((v_strength-20)/10.0)::INTEGER;
    v_table_strength:=v_strength-(10*v_decades);
  ELSE v_table_strength:=v_strength; END IF;
  v_table_strength:=GREATEST(1,LEAST(29,v_table_strength));
  v_heavy_max:=v_heavy_table[v_table_strength]*POWER(4::NUMERIC,v_decades)*v_size_multiplier;
  v_light_max:=FLOOR((v_heavy_max/3.0)*2.0)/2.0;
  v_medium_max:=FLOOR((v_heavy_max*2.0/3.0)*2.0)/2.0;
  IF v_weight_kg>v_medium_max THEN v_load:='heavy';
  ELSIF v_weight_kg>v_light_max THEN v_load:='medium';
  ELSE v_load:='light'; END IF;

  v_speed:=v_base_speed;
  -- Movimento Rápido do Bárbaro: +3 m antes dos ajustes de armadura/carga.
  IF v_class_key='barbarian' AND COALESCE(v_level,1)>=1 AND NOT v_heavy_armor AND v_load<>'heavy' THEN
    v_speed:=v_speed+3;
  ELSIF v_class_key='monk' AND COALESCE(v_level,1)>=3 AND NOT v_any_armor AND v_load='light' THEN
    v_speed:=v_speed+(3*FLOOR(v_level/3.0));
  END IF;
  -- O deslocamento do anão não é reduzido por armadura média/pesada ou carga média/pesada.
  IF NOT v_is_dwarf AND (v_medium_heavy_armor OR v_load IN ('medium','heavy')) THEN
    IF v_speed>=12 THEN v_speed:=9;
    ELSIF v_speed>=9 THEN v_speed:=6;
    ELSIF v_speed>=6 THEN v_speed:=4.5;
    ELSE v_speed:=GREATEST(1.5,FLOOR((v_speed*0.75)/1.5)*1.5); END IF;
  END IF;
  RETURN ROUND(v_speed,2);
END;
$function$
;
