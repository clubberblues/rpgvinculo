CREATE OR REPLACE FUNCTION public.srd35_deslocamento_personagem(p_character_id text, p_base_speed_m numeric)
 RETURNS numeric
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_attrs JSONB;
  v_race_id TEXT;
  v_race_name TEXT;
  v_size TEXT;
  v_barbarian_level INTEGER := 0;
  v_monk_level INTEGER := 0;
  v_gold NUMERIC := 0;
  v_strength INTEGER := 10;
  v_base_speed NUMERIC := COALESCE(p_base_speed_m,9);
  v_speed NUMERIC;
  v_weight_kg NUMERIC := 0;
  v_heavy_armor BOOLEAN := FALSE;
  v_medium_heavy_armor BOOLEAN := FALSE;
  v_any_armor BOOLEAN := FALSE;
  v_is_dwarf BOOLEAN := FALSE;
  v_heavy_table NUMERIC[] := ARRAY[5,10,15,20,25,30,35,40,45,50,57.5,65,75,87.5,100,115,130,150,175,200,230,260,300,350,400,460,520,600,700]::NUMERIC[];
  v_table_strength INTEGER;
  v_decades INTEGER := 0;
  v_heavy_max NUMERIC;
  v_light_max NUMERIC;
  v_medium_max NUMERIC;
  v_size_multiplier NUMERIC := 1;
  v_load TEXT := 'light';
  v_size_normalized TEXT;
BEGIN
  SELECT sh.atributos,sh.raca_id,COALESCE(sh.ouro,0),race.nome,race.tamanho
    INTO v_attrs,v_race_id,v_gold,v_race_name,v_size
    FROM public.srd_character_sheets sh
    LEFT JOIN public.srd_races race ON race.id::TEXT=sh.raca_id::TEXT
   WHERE sh.character_id::TEXT=BTRIM(p_character_id);
  IF NOT FOUND THEN RETURN v_base_speed; END IF;

  -- Prefer the normalized per-class ledger. Fall back to the sheet's total
  -- level only for legacy single-class characters that have no ledger rows.
  SELECT
    COALESCE(
      MAX(cl.class_level) FILTER (WHERE class.class_key='barbarian'),
      CASE WHEN NOT EXISTS (
        SELECT 1 FROM public.srd_character_class_levels any_level
         WHERE any_level.character_id=sh.character_id
      ) AND primary_class.class_key='barbarian'
      THEN GREATEST(1,COALESCE(sh.nivel,1)) ELSE 0 END
    ),
    COALESCE(
      MAX(cl.class_level) FILTER (WHERE class.class_key='monk'),
      CASE WHEN NOT EXISTS (
        SELECT 1 FROM public.srd_character_class_levels any_level
         WHERE any_level.character_id=sh.character_id
      ) AND primary_class.class_key='monk'
      THEN GREATEST(1,COALESCE(sh.nivel,1)) ELSE 0 END
    )
    INTO v_barbarian_level,v_monk_level
    FROM public.srd_character_sheets sh
    LEFT JOIN public.srd_classes primary_class ON primary_class.id=sh.classe_id
    LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
    LEFT JOIN public.srd_classes class ON class.id=cl.class_id
   WHERE sh.character_id::TEXT=BTRIM(p_character_id)
   GROUP BY sh.character_id,sh.nivel,primary_class.class_key;

  v_strength:=GREATEST(1,COALESCE((v_attrs->>'FOR')::INTEGER,10));
  v_is_dwarf:=v_race_id='anao' OR public.srd35_normalizar_parametro_talento(COALESCE(v_race_name,''))='anao';
  v_size_normalized:=public.srd35_normalizar_parametro_talento(COALESCE(v_size,'medio'));

  -- Imported SRD weights are pounds; legacy Portuguese entries are kilograms.
  SELECT
    COALESCE(SUM(COALESCE(eq.peso,0)*
      CASE WHEN POSITION('lb' IN LOWER(COALESCE(eq.detalhes->>'weight',''))) > 0
             OR eq.detalhes->>'source_dataset'='olimot/srd-v3.5-md'
           THEN 0.5 ELSE 1 END*GREATEST(1,ce.quantidade)),0),
    COALESCE(BOOL_OR(ce.equipado AND armor.kind LIKE 'heavyarmor%'),FALSE),
    COALESCE(BOOL_OR(ce.equipado AND (armor.kind LIKE 'mediumarmor%' OR armor.kind LIKE 'heavyarmor%')),FALSE),
    COALESCE(BOOL_OR(ce.equipado AND armor.kind IN ('lightarmor','mediumarmor','heavyarmor')),FALSE)
    INTO v_weight_kg,v_heavy_armor,v_medium_heavy_armor,v_any_armor
    FROM public.srd_character_equipment ce
    JOIN public.srd_equipment eq ON eq.id=ce.equipment_id
    CROSS JOIN LATERAL (
      SELECT public.srd35_normalizar_parametro_talento(
        COALESCE(eq.detalhes->>'category',eq.categoria,'')
      ) AS kind
    ) armor
   WHERE ce.character_id=BTRIM(p_character_id);

  -- 500 PO weigh 5 kg.
  v_weight_kg:=v_weight_kg+(v_gold/100.0);

  v_size_multiplier:=CASE
    WHEN v_size_normalized IN ('minusculo','fine') THEN 0.125
    WHEN v_size_normalized IN ('diminuto','diminutive') THEN 0.25
    WHEN v_size_normalized IN ('miudo','tiny') THEN 0.5
    WHEN v_size_normalized IN ('pequeno','small') THEN 0.75
    WHEN v_size_normalized IN ('grande','large') THEN 2
    WHEN v_size_normalized IN ('enorme','huge') THEN 4
    WHEN v_size_normalized IN ('imenso','gargantuan') THEN 8
    WHEN v_size_normalized='colossal' THEN 16
    ELSE 1
  END;

  IF v_strength>=30 THEN
    v_decades:=FLOOR((v_strength-20)/10.0)::INTEGER;
    v_table_strength:=v_strength-(10*v_decades);
  ELSE
    v_table_strength:=v_strength;
  END IF;
  v_table_strength:=GREATEST(1,LEAST(29,v_table_strength));
  v_heavy_max:=v_heavy_table[v_table_strength]*POWER(4::NUMERIC,v_decades)*v_size_multiplier;
  v_light_max:=FLOOR((v_heavy_max/3.0)*2.0)/2.0;
  v_medium_max:=FLOOR((v_heavy_max*2.0/3.0)*2.0)/2.0;

  IF v_weight_kg>v_medium_max THEN
    v_load:='heavy';
  ELSIF v_weight_kg>v_light_max THEN
    v_load:='medium';
  ELSE
    v_load:='light';
  END IF;

  v_speed:=v_base_speed;

  -- Barbarian Fast Movement: +3 m with light/no armor; medium load is
  -- allowed, but medium/heavy armor and heavy load suppress the bonus.
  IF v_barbarian_level>=1 AND NOT v_heavy_armor AND v_load<>'heavy' THEN
    v_speed:=v_speed+3;
  -- Monk Fast Movement: +3 m per three monk levels, unarmored and lightly loaded.
  ELSIF v_monk_level>=3 AND NOT v_any_armor AND v_load='light' THEN
    v_speed:=v_speed+(3*FLOOR(v_monk_level/3.0));
  END IF;

  -- Dwarves ignore speed reductions from medium/heavy armor and loads.
  IF NOT v_is_dwarf AND (v_medium_heavy_armor OR v_load IN ('medium','heavy')) THEN
    IF v_speed>=12 THEN
      v_speed:=9;
    ELSIF v_speed>=9 THEN
      v_speed:=6;
    ELSIF v_speed>=6 THEN
      v_speed:=4.5;
    ELSE
      v_speed:=GREATEST(1.5,FLOOR((v_speed*0.75)/1.5)*1.5);
    END IF;
  END IF;

  RETURN ROUND(v_speed,2);
END;
$function$
;

CREATE OR REPLACE FUNCTION priv.srd_saving_throw_bonus(p_campaign_id bigint, p_target_kind text, p_target_id text, p_save_type text, p_context text DEFAULT NULL::text)
 RETURNS integer
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
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
  v_feats jsonb; v_ability_effect text; v_charisma_score integer; v_paladin_level integer:=0; v_barbarian_level integer:=0; v_rogue_level integer:=0; v_monk_level integer:=0;
BEGIN
  IF v_save NOT IN ('fortitude','reflex','will') THEN RAISE EXCEPTION 'Tipo de resistência inválido.'; END IF;
  IF p_target_kind='character' THEN
    SELECT sh.* INTO v_sheet
    FROM public.srd_character_sheets sh
    JOIN public.characters ch ON ch.id=sh.character_id
    WHERE ch.id::text=BTRIM(p_target_id) AND ch.campaign_id=p_campaign_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Ficha do alvo não encontrada para calcular resistência.'; END IF;
    v_ability:=CASE v_save WHEN 'fortitude' THEN 'CON' WHEN 'reflex' THEN 'DES' ELSE 'SAB' END;
    v_score:=COALESCE(NULLIF(v_sheet.atributos->>v_ability,'')::integer,10);
    v_ability_effect:=CASE v_save WHEN 'fortitude' THEN 'constitution' WHEN 'reflex' THEN 'dexterity' ELSE 'wisdom' END;
    v_score:=v_score+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_target_id),v_ability_effect);
    v_feats:=COALESCE(v_sheet.talentos,'[]'::jsonb);
    SELECT COALESCE(sum(CASE v_save WHEN 'fortitude' THEN pr.base_fortitude WHEN 'reflex' THEN pr.base_reflex ELSE pr.base_will END),0)::integer
      INTO v_base
      FROM public.srd_character_class_levels cl
      JOIN public.srd_class_level_progressions pr ON pr.class_id=cl.class_id AND pr.class_level=cl.class_level
     WHERE cl.character_id=v_sheet.character_id;
    IF NOT EXISTS(SELECT 1 FROM public.srd_character_class_levels WHERE character_id=v_sheet.character_id) THEN
      SELECT CASE v_save WHEN 'fortitude' THEN pr.base_fortitude WHEN 'reflex' THEN pr.base_reflex ELSE pr.base_will END
        INTO v_base
        FROM public.srd_class_level_progressions pr
       WHERE pr.class_id=v_sheet.classe_id AND pr.class_level=v_sheet.nivel;
      IF v_base IS NULL THEN
        SELECT CASE v_save
          WHEN 'fortitude' THEN CASE WHEN cl.fort_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END
          WHEN 'reflex' THEN CASE WHEN cl.ref_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END
          ELSE CASE WHEN cl.von_bom THEN floor(v_sheet.nivel/2.0)::integer+2 ELSE floor(v_sheet.nivel/3.0)::integer END
        END INTO v_base FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
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
    CROSS JOIN LATERAL jsonb_array_elements(CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array' THEN c.cba_data->'tokens' ELSE '[]'::jsonb END) t(value)
    WHERE c.id=p_campaign_id AND (t.value->>'id'=BTRIM(p_target_id) OR t.value->>'key'=BTRIM(p_target_id)) LIMIT 1;
    IF v_token IS NULL THEN RAISE EXCEPTION 'Token-alvo não encontrado para calcular resistência.'; END IF;
    v_save_text:=CASE v_save
      WHEN 'fortitude' THEN COALESCE(v_token->'monsterStats'->>'fortitude',v_token->'monsterStats'->>'fort')
      WHEN 'reflex' THEN COALESCE(v_token->'monsterStats'->>'reflexos',v_token->'monsterStats'->>'reflex')
      ELSE COALESCE(v_token->'monsterStats'->>'vontade',v_token->'monsterStats'->>'will') END;
    v_base:=COALESCE(NULLIF(substring(COALESCE(v_save_text,'') FROM '[-+]?[0-9]+'),'')::integer,0);
    v_bonus:=v_base;
  ELSE
    RAISE EXCEPTION 'Tipo de alvo inválido para resistência.';
  END IF;
  -- D&D 3.5: Graça Divina adiciona o modificador positivo de Carisma a todos os testes de resistência a partir do 2º nível de Paladino.
  IF p_target_kind='character' THEN
    SELECT COALESCE(MAX(cl.class_level),0) INTO v_paladin_level
      FROM public.srd_character_class_levels cl
      JOIN public.srd_classes cls ON cls.id=cl.class_id
     WHERE cl.character_id=v_sheet.character_id AND cls.class_key='paladin';
    IF v_paladin_level=0 AND NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels WHERE character_id=v_sheet.character_id)
       AND v_sheet.classe_id='paladino' THEN
      v_paladin_level:=v_sheet.nivel;
    END IF;
    IF v_paladin_level>=2 THEN
      v_charisma_score:=COALESCE(NULLIF(v_sheet.atributos->>'CAR','')::integer,10);
      v_bonus:=v_bonus+GREATEST(0,FLOOR((v_charisma_score-10)::numeric/2)::integer);
    END IF;
  END IF;
  v_bonus:=v_bonus
    +priv.srd_effective_modifier(p_campaign_id,p_target_kind,BTRIM(p_target_id),v_save)
    +priv.srd_effective_modifier(p_campaign_id,p_target_kind,BTRIM(p_target_id),'saving_throw');
  IF lower(COALESCE(p_context,'')) LIKE '%fear%' THEN
    v_bonus:=v_bonus+priv.srd_effective_modifier(p_campaign_id,p_target_kind,BTRIM(p_target_id),'fear_saving_throw');
  END IF;
  -- Trap Sense: Bárbaro e Ladino recebem +1 em CA e Reflexos contra armadilhas a cada três níveis; os bônus não se acumulam.
  IF v_save='reflex' AND lower(COALESCE(p_context,'')) LIKE '%trap%'
     AND p_target_kind='character' THEN
    SELECT COALESCE(
      MAX(cl.class_level) FILTER (WHERE cls.class_key='barbarian'),
      CASE WHEN NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels any_level WHERE any_level.character_id=v_sheet.character_id)
        AND v_sheet.classe_id='barbaro' THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
    ),
    COALESCE(
      MAX(cl.class_level) FILTER (WHERE cls.class_key='rogue'),
      CASE WHEN NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels any_level WHERE any_level.character_id=v_sheet.character_id)
        AND v_sheet.classe_id='ladino' THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
    )
      INTO v_barbarian_level,v_rogue_level
      FROM public.srd_character_sheets sh
      LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
      LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
     WHERE sh.character_id=v_sheet.character_id
     GROUP BY sh.character_id,sh.classe_id,sh.nivel;
    v_bonus:=v_bonus+GREATEST(
      FLOOR(COALESCE(v_barbarian_level,0)/3.0)::integer,
      FLOOR(COALESCE(v_rogue_level,0)/3.0)::integer
    );
  END IF;

  -- Indomitable Will (Bárbaro 14): +4 contra magias da escola Encantamento,
  -- enquanto estiver em Fúria. É bônus separado e acumula com o bônus moral da Fúria.
  IF v_save='will' AND lower(COALESCE(p_context,'')) LIKE '%enchantment%'
     AND p_target_kind='character'
     AND priv.srd_effect_has_flag(p_campaign_id,p_target_kind,BTRIM(p_target_id),'rage_active') THEN
    SELECT COALESCE(
      MAX(cl.class_level) FILTER (WHERE cls.class_key='barbarian'),
      CASE WHEN NOT EXISTS (
        SELECT 1 FROM public.srd_character_class_levels any_level
         WHERE any_level.character_id=v_sheet.character_id
      ) AND v_sheet.classe_id='barbaro'
      THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
    )
      INTO v_barbarian_level
      FROM public.srd_character_sheets sh
      LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
      LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
     WHERE sh.character_id=v_sheet.character_id
     GROUP BY sh.character_id,sh.classe_id,sh.nivel;
    IF COALESCE(v_barbarian_level,0)>=14 THEN v_bonus:=v_bonus+4; END IF;
  END IF;
  -- Mente Tranquila (Monge 3): +2 em Vontade contra magias e efeitos de Encantamento.
  IF v_save='will' AND lower(COALESCE(p_context,'')) LIKE '%enchantment%'
     AND p_target_kind='character' THEN
    SELECT COALESCE(
      MAX(cl.class_level) FILTER (WHERE cls.class_key='monk'),
      CASE WHEN NOT EXISTS (
        SELECT 1 FROM public.srd_character_class_levels any_level
         WHERE any_level.character_id=v_sheet.character_id
      ) AND v_sheet.classe_id='monge'
      THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
    )
      INTO v_monk_level
      FROM public.srd_character_sheets sh
      LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
      LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
     WHERE sh.character_id=v_sheet.character_id
     GROUP BY sh.character_id,sh.classe_id,sh.nivel;
    IF COALESCE(v_monk_level,0)>=3 THEN v_bonus:=v_bonus+2; END IF;
  END IF;

  -- Dwarf racial resistance: +2 on saves against poison and spells/spell-like effects.
  IF p_target_kind='character'
     AND v_sheet.raca_id='anao'
     AND (
       lower(COALESCE(p_context,'')) LIKE '%poison%'
       OR lower(COALESCE(p_context,'')) LIKE '%spell%'
     ) THEN
    v_bonus:=v_bonus+2;
  END IF;

  RETURN v_bonus;
END;
$function$
;