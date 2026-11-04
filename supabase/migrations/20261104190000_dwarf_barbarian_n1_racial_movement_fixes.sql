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

CREATE OR REPLACE FUNCTION public.srd_resolve_pending_spell_save(p_pending_id uuid, p_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE v_pending priv.srd_pending_spell_resolutions%ROWTYPE; v_user_id uuid; v_bonus integer; v_total integer; v_sr integer; v_caster_user uuid; v_round integer; v_school text; v_context text; v_rogue_level integer:=0; v_monk_level integer:=0; v_ranger_level integer:=0; v_evasion boolean:=false; v_improved_evasion boolean:=false; v_medium_or_heavy_armor boolean:=false;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_d20 IS NULL OR p_d20 NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'A resistência exige uma rolagem manual de D20.'; END IF;
  SELECT * INTO v_pending FROM priv.srd_pending_spell_resolutions WHERE pending_id=p_pending_id FOR UPDATE;
  IF NOT FOUND OR v_pending.status<>'pending_save' OR v_pending.expires_at<now() THEN RAISE EXCEPTION 'Pedido de resistência inválido ou expirado.'; END IF;
  IF v_pending.target_kind='character' THEN
    SELECT user_id INTO v_user_id FROM public.characters WHERE id::text=v_pending.target_id AND campaign_id=v_pending.campaign_id;
    IF v_user_id IS DISTINCT FROM auth.uid() AND public.my_role(v_pending.campaign_id) IS DISTINCT FROM 'GM'
       AND NOT EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=v_pending.campaign_id AND c.owner_id=auth.uid()) THEN
      RAISE EXCEPTION 'Somente o jogador-alvo ou o Mestre pode registrar esta resistência.';
    END IF;
  ELSIF public.my_role(v_pending.campaign_id) IS DISTINCT FROM 'GM'
        AND NOT EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=v_pending.campaign_id AND c.owner_id=auth.uid()) THEN
    RAISE EXCEPTION 'Somente o Mestre pode registrar a resistência de um NPC ou monstro.';
  END IF;
  SELECT lower(COALESCE(escola,'')) INTO v_school
    FROM public.srd_spells WHERE id=v_pending.spell_id;
  v_context:=concat_ws(',',
    'spell',
    CASE WHEN v_pending.spell_id='srd35_spell_bane' THEN 'fear' END,
    CASE WHEN COALESCE(v_school,'') LIKE '%enchant%' THEN 'enchantment' END
  );
  v_bonus:=priv.srd_saving_throw_bonus(
    v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,v_pending.save_type,NULLIF(v_context,'')
  );
  v_total:=p_d20+v_bonus;

  IF v_pending.target_kind='character'
     AND v_pending.save_type='reflex'
     AND v_pending.effect_kind='damage'
     AND v_pending.effect_data->>'save_result'='half' THEN
    SELECT COALESCE(MAX(cl.class_level) FILTER (WHERE cls.class_key='rogue'),
             CASE WHEN NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels any_level WHERE any_level.character_id=sh.character_id)
                       AND sh.classe_id='ladino' THEN GREATEST(1,COALESCE(sh.nivel,1)) ELSE 0 END),
           COALESCE(MAX(cl.class_level) FILTER (WHERE cls.class_key='monk'),
             CASE WHEN NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels any_level WHERE any_level.character_id=sh.character_id)
                       AND sh.classe_id='monge' THEN GREATEST(1,COALESCE(sh.nivel,1)) ELSE 0 END),
           COALESCE(MAX(cl.class_level) FILTER (WHERE cls.class_key='ranger'),
             CASE WHEN NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels any_level WHERE any_level.character_id=sh.character_id)
                       AND sh.classe_id='ranger' THEN GREATEST(1,COALESCE(sh.nivel,1)) ELSE 0 END)
      INTO v_rogue_level,v_monk_level,v_ranger_level
      FROM public.srd_character_sheets sh
      LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
      LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
     WHERE sh.character_id::text=v_pending.target_id
     GROUP BY sh.character_id,sh.classe_id,sh.nivel;

    SELECT EXISTS (
      SELECT 1
        FROM public.srd_character_equipment ce
        JOIN public.srd_equipment eq ON eq.id=ce.equipment_id
       WHERE ce.character_id::text=v_pending.target_id
         AND ce.equipado=true
         AND (
           lower(COALESCE(eq.detalhes->>'category',eq.categoria,'')) LIKE '%medium armor%'
           OR lower(COALESCE(eq.detalhes->>'category',eq.categoria,'')) LIKE '%heavy armor%'
           OR lower(COALESCE(eq.categoria,'')) IN ('armadura','armor','armor_and_shields')
              AND lower(COALESCE(eq.nome,'')) NOT LIKE '%shield%'
              AND COALESCE(eq.bonus_max_des,eq.max_des,0)<=3
         )
    ) INTO v_medium_or_heavy_armor;

    v_evasion:=NOT v_medium_or_heavy_armor
      AND (COALESCE(v_rogue_level,0)>=2 OR COALESCE(v_monk_level,0)>=2 OR COALESCE(v_ranger_level,0)>=9);
    v_improved_evasion:=NOT v_medium_or_heavy_armor AND COALESCE(v_monk_level,0)>=9;
  END IF;

  IF v_pending.condition_break THEN
    SELECT GREATEST(1,COALESCE(NULLIF(c.combat_data->>'round','')::integer,1))
      INTO v_round FROM public.campaigns c WHERE c.id=v_pending.campaign_id;
    IF v_total>=v_pending.save_dc THEN
      UPDATE public.srd_campaign_conditions
         SET active=false,
             notes=COALESCE(notes,'{}'::jsonb)||jsonb_build_object('ended_by_save',true,'last_save_round',v_round)
       WHERE condition_instance_id=v_pending.condition_break_instance_id
         AND campaign_id=v_pending.campaign_id AND active=true;
      UPDATE priv.srd_pending_spell_resolutions SET status='saved',resolved_at=now() WHERE pending_id=p_pending_id;
      RETURN jsonb_build_object('pending_id',p_pending_id,'saved',true,'condition_ended',true,
        'total',v_total,'bonus',v_bonus,'dc',v_pending.save_dc,'status','condition_ended');
    ELSE
      UPDATE public.srd_campaign_conditions
         SET notes=COALESCE(notes,'{}'::jsonb)||jsonb_build_object('last_save_round',v_round)
       WHERE condition_instance_id=v_pending.condition_break_instance_id
         AND campaign_id=v_pending.campaign_id AND active=true;
      UPDATE priv.srd_pending_spell_resolutions SET status='resolved',resolved_at=now() WHERE pending_id=p_pending_id;
      RETURN jsonb_build_object('pending_id',p_pending_id,'saved',false,'condition_ended',false,
        'total',v_total,'bonus',v_bonus,'dc',v_pending.save_dc,'status','condition_persists');
    END IF;
  END IF;

  IF v_total>=v_pending.save_dc THEN
    IF v_pending.effect_kind='damage' AND v_pending.effect_data->>'save_result' IN ('half','damage_unaffected') THEN
      UPDATE priv.srd_pending_spell_resolutions
         SET effect_data=(
           CASE
             WHEN effect_data->>'save_result'='half' AND v_evasion THEN
               jsonb_set(effect_data,'{damage}',to_jsonb(0),true)
             WHEN effect_data->>'save_result'='half' THEN
               jsonb_set(effect_data,'{damage}',
                 to_jsonb(GREATEST(0,FLOOR(COALESCE(NULLIF(effect_data->>'damage','')::numeric,0)/2)::integer)),true)
             ELSE effect_data
           END
         )||jsonb_build_object('apply_secondary_condition',false)
       WHERE pending_id=p_pending_id;
      RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)
        ||jsonb_build_object('saved',true,'save_total',v_total,'save_bonus',v_bonus,'save_dc',v_pending.save_dc,
          'save_result',v_pending.effect_data->>'save_result','evasion',v_evasion,
          'improved_evasion',v_improved_evasion,'evasion_armor_blocked',v_medium_or_heavy_armor);
    END IF;
    UPDATE priv.srd_pending_spell_resolutions SET status='saved',resolved_at=now() WHERE pending_id=p_pending_id;
    RETURN jsonb_build_object('pending_id',p_pending_id,'saved',true,'total',v_total,'bonus',v_bonus,'dc',v_pending.save_dc,'status','saved');
  END IF;
  IF v_pending.effect_kind='damage' AND v_pending.effect_data->>'save_result'='half' AND v_improved_evasion THEN
    UPDATE priv.srd_pending_spell_resolutions
       SET effect_data=jsonb_set(effect_data,'{damage}',
         to_jsonb(GREATEST(0,FLOOR(COALESCE(NULLIF(effect_data->>'damage','')::numeric,0)/2)::integer)),true)
     WHERE pending_id=p_pending_id;
    RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)
      || jsonb_build_object('saved',false,'save_total',v_total,'save_bonus',v_bonus,'save_dc',v_pending.save_dc,
        'evasion',true,'improved_evasion',true,'evasion_armor_blocked',false);
  END IF;
  RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)
    || jsonb_build_object('saved',false,'save_total',v_total,'save_bonus',v_bonus,'save_dc',v_pending.save_dc,
      'evasion',v_evasion,'improved_evasion',v_improved_evasion,'evasion_armor_blocked',v_medium_or_heavy_armor);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.srd_resolve_requested_saving_throw_srd(p_campaign_id bigint, p_character_id text, p_request_id text, p_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_request public.campaign_log%ROWTYPE;
  v_save_type text;
  v_context text;
  v_dc integer;
  v_bonus integer;
  v_base_bonus integer;
  v_total integer;
  v_result jsonb;
  v_master uuid;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_d20 IS NULL OR p_d20 NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'Resultado de d20 inválido.';
  END IF;
  IF NULLIF(BTRIM(p_request_id),'') IS NULL THEN
    RAISE EXCEPTION 'Pedido de teste inválido.';
  END IF;

  SELECT * INTO v_character
    FROM public.characters
   WHERE id::text=BTRIM(p_character_id)
     AND campaign_id=p_campaign_id
     AND user_id=auth.uid();
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou não pertence ao jogador.'; END IF;

  SELECT * INTO v_request
    FROM public.campaign_log
   WHERE campaign_id=p_campaign_id
     AND type='test_request'
     AND data->>'request_id'=BTRIM(p_request_id)
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Pedido de resistência não encontrado ou expirado.'; END IF;
  IF v_request.data->>'resolution_type'<>'saving_throw' THEN
    RAISE EXCEPTION 'Este pedido não é um teste de resistência SRD.';
  END IF;
  IF NOT COALESCE(v_request.data->'alvos' @> jsonb_build_array(v_character.id::text),false) THEN
    RAISE EXCEPTION 'Este pedido não foi direcionado ao personagem.';
  END IF;
  IF COALESCE(v_request.data->'results','{}'::jsonb) ? v_character.id::text THEN
    RAISE EXCEPTION 'Este teste já foi respondido por este personagem.';
  END IF;

  v_master:=NULLIF(v_request.data->>'mestre_id','')::uuid;
  IF v_master IS NULL OR NOT EXISTS (
    SELECT 1 FROM public.members m
     WHERE m.campaign_id=p_campaign_id AND m.user_id=v_master AND upper(m.role)='GM'
  ) THEN
    RAISE EXCEPTION 'O pedido não foi emitido por um Mestre autorizado.';
  END IF;

  v_save_type:=lower(COALESCE(v_request.data->>'save_type',''));
  IF v_save_type NOT IN ('fortitude','reflex','will') THEN
    RAISE EXCEPTION 'Tipo de resistência inválido no pedido.';
  END IF;
  v_context:=lower(COALESCE(v_request.data->>'context',''));
  IF v_context NOT IN ('','trap','poison','spell','enchantment','fear','fear,enchantment','spell,enchantment','spell,fear','spell,fear,enchantment') THEN
    RAISE EXCEPTION 'Contexto de resistência inválido no pedido.';
  END IF;
  v_dc:=CASE WHEN COALESCE(v_request.data->>'dc','') ~ '^[0-9]{1,3}$'
             THEN (v_request.data->>'dc')::integer ELSE NULL END;
  IF v_dc IS NOT NULL AND v_dc NOT BETWEEN 1 AND 100 THEN
    RAISE EXCEPTION 'Classe de dificuldade inválida.';
  END IF;

  v_bonus:=priv.srd_saving_throw_bonus(
    p_campaign_id,'character',v_character.id::text,v_save_type,NULLIF(v_context,'')
  );
  v_base_bonus:=priv.srd_saving_throw_bonus(
    p_campaign_id,'character',v_character.id::text,v_save_type,NULL
  );
  v_total:=p_d20+v_bonus;
  v_result:=jsonb_build_object(
    'request_id',p_request_id,
    'character_id',v_character.id::text,
    'character_name',v_character.nome,
    'save_type',v_save_type,
    'context',NULLIF(v_context,''),
    'd20',p_d20,
    'bonus',v_bonus,
    'total',v_total,
    'dc',v_dc,
    'success',CASE WHEN v_dc IS NULL THEN NULL ELSE v_total>=v_dc END,
    'trap_sense_bonus',CASE WHEN v_context='trap' AND v_save_type='reflex' THEN v_bonus-v_base_bonus ELSE 0 END
  );

  UPDATE public.campaign_log
     SET data=jsonb_set(
       jsonb_set(COALESCE(data,'{}'::jsonb),'{results}',COALESCE(data->'results','{}'::jsonb),true),
       ARRAY['results',v_character.id::text],v_result,true
     )
   WHERE id=v_request.id;

  RETURN v_result;
END;
$function$
;
