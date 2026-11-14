CREATE OR REPLACE FUNCTION public.srd_calcular_ca_personagem_srd(p_campaign_id bigint, p_character_id text, p_attack_context text DEFAULT 'normal'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_character public.characters%ROWTYPE;
  v_context text:=lower(COALESCE(NULLIF(BTRIM(p_attack_context),''),'normal'));
  v_barbarian_level integer:=0;
  v_rogue_level integer:=0;
  v_armor_bonus integer:=0;
  v_shield_bonus integer:=0;
  v_max_dex integer:=99;
  v_dex_score integer:=10;
  v_dex_modifier integer:=0;
  v_dex_applied integer:=0;
  v_size_modifier integer:=0;
  v_effect_modifier integer:=0;
  v_trap_sense_bonus integer:=0;
  v_flatfooted boolean:=false;
  v_other_dex_loss boolean:=false;
  v_uncanny_dodge boolean:=false;
  v_improved_uncanny_dodge boolean:=false;
  v_lose_dex boolean:=false;
  v_final_ac integer:=10;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF v_context NOT IN ('normal','flatfooted','invisible','trap') THEN
    RAISE EXCEPTION 'Contexto de ataque inválido.';
  END IF;

  SELECT * INTO v_character
    FROM public.characters
   WHERE id::text=BTRIM(p_character_id)
     AND campaign_id=p_campaign_id
     AND (user_id=auth.uid() OR public.my_role(p_campaign_id)='GM');
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem acesso à campanha.'; END IF;

  SELECT * INTO v_sheet
    FROM public.srd_character_sheets
   WHERE character_id=v_character.id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do personagem não encontrada.'; END IF;

  SELECT COALESCE(
    MAX(cl.class_level) FILTER (WHERE cls.class_key='barbarian'),
    CASE WHEN NOT EXISTS (
      SELECT 1 FROM public.srd_character_class_levels any_level
       WHERE any_level.character_id=v_sheet.character_id
    ) AND v_sheet.classe_id='barbaro'
    THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
  ), COALESCE(
    MAX(cl.class_level) FILTER (WHERE cls.class_key='rogue'),
    CASE WHEN NOT EXISTS (
      SELECT 1 FROM public.srd_character_class_levels any_level
       WHERE any_level.character_id=v_sheet.character_id
    ) AND v_sheet.classe_id='ladino'
    THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
  )
    INTO v_barbarian_level,v_rogue_level
    FROM public.srd_character_sheets sh
    LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
    LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
   WHERE sh.character_id=v_sheet.character_id
   GROUP BY sh.character_id,sh.classe_id,sh.nivel;

  v_uncanny_dodge:=COALESCE(v_barbarian_level,0)>=2 OR COALESCE(v_rogue_level,0)>=4;
  v_improved_uncanny_dodge:=COALESCE(v_barbarian_level,0)>=5 OR COALESCE(v_rogue_level,0)>=8;

  WITH equipped AS (
    SELECT eq.id,
           lower(COALESCE(eq.detalhes->>'category',eq.categoria,'')) AS category,
           lower(COALESCE(eq.tipo,'')) AS item_type,
           lower(COALESCE(eq.nome,'')) AS item_name,
           COALESCE(eq.bonus_max_des,eq.max_des) AS max_dex,
           public.srd35_equipment_ca_bonus(eq.id) AS ca_bonus
      FROM public.srd_character_equipment ce
      JOIN public.srd_equipment eq ON eq.id=ce.equipment_id
     WHERE ce.character_id=v_character.id::text AND ce.equipado=true
  ), classified AS (
    SELECT *,
      CASE
        WHEN category='armor_and_shields' THEN
          CASE WHEN item_name LIKE '%shield%' THEN 'shield' ELSE 'armor' END
        WHEN category LIKE '%shield%' OR category LIKE '%escudo%'
          OR item_type LIKE '%shield%' OR item_type LIKE '%escudo%' THEN 'shield'
        WHEN category LIKE '%armor%' OR category LIKE '%armadura%'
          OR item_type LIKE '%armor%' OR item_type LIKE '%armadura%' THEN 'armor'
        ELSE 'other'
      END AS equipment_kind
    FROM equipped
  )
  SELECT
    COALESCE(SUM(ca_bonus) FILTER (WHERE equipment_kind='armor'),0)::integer,
    COALESCE(SUM(ca_bonus) FILTER (WHERE equipment_kind='shield'),0)::integer,
    COALESCE(MIN(max_dex) FILTER (WHERE equipment_kind='armor' AND max_dex IS NOT NULL),99)::integer
    INTO v_armor_bonus,v_shield_bonus,v_max_dex
    FROM classified;

  v_dex_score:=GREATEST(0,COALESCE(NULLIF(v_sheet.atributos->>'DES','')::integer,10)
    +priv.srd_effective_modifier(p_campaign_id,'character',v_character.id::text,'dexterity'));
  v_dex_modifier:=FLOOR((v_dex_score-10)::numeric/2)::integer;

  SELECT EXISTS (
    SELECT 1 FROM public.srd_campaign_conditions
     WHERE campaign_id=p_campaign_id AND target_kind='character'
       AND target_id=v_character.id::text AND active=true AND condition_id='flatfooted'
  ) INTO v_flatfooted;

  SELECT EXISTS (
    SELECT 1
      FROM public.srd_campaign_conditions cc
      JOIN priv.srd_condition_engine_rules r ON r.condition_id=cc.condition_id AND r.enabled
     WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='character'
       AND cc.target_id=v_character.id::text AND cc.active=true
       AND COALESCE(r.flags->>'loses_dex_ac','false')='true'
       AND cc.condition_id<>'flatfooted'
  ) INTO v_other_dex_loss;

  v_lose_dex:=v_other_dex_loss
    OR ((v_flatfooted OR v_context IN ('flatfooted','invisible')) AND NOT v_uncanny_dodge);
  IF NOT v_lose_dex THEN
    v_dex_applied:=LEAST(v_dex_modifier,v_max_dex);
  END IF;

  SELECT CASE translate(lower(COALESCE(race.tamanho,'medio')),
      'áéíóúãõâêôç','aeiouaoaeoc')
    WHEN 'minusculo' THEN 8 WHEN 'fine' THEN 8
    WHEN 'diminuto' THEN 4 WHEN 'diminutive' THEN 4
    WHEN 'miudo' THEN 2 WHEN 'tiny' THEN 2
    WHEN 'pequeno' THEN 1 WHEN 'small' THEN 1
    WHEN 'grande' THEN -1 WHEN 'large' THEN -1
    WHEN 'enorme' THEN -2 WHEN 'huge' THEN -2
    WHEN 'imenso' THEN -4 WHEN 'gargantuan' THEN -4
    WHEN 'colossal' THEN -8
    ELSE 0 END
    INTO v_size_modifier
    FROM public.srd_races race
   WHERE race.id::text=v_sheet.raca_id::text;
  v_size_modifier:=COALESCE(v_size_modifier,0);

  v_effect_modifier:=priv.srd_effective_modifier(
    p_campaign_id,'character',v_character.id::text,'ac'
  );
  -- Trap Sense é bônus de esquiva: não se aplica quando o personagem está
  -- desprevenido ou perde Destreza na CA por uma condição incapacitante.
  IF v_context='trap' AND NOT v_flatfooted AND NOT v_other_dex_loss THEN
    -- Sentido para Armadilhas de Bárbaro e Ladino não acumula entre si.
    v_trap_sense_bonus:=GREATEST(
      FLOOR(COALESCE(v_barbarian_level,0)/3.0)::integer,
      FLOOR(COALESCE(v_rogue_level,0)/3.0)::integer
    );
  END IF;

  v_final_ac:=GREATEST(1,10+v_armor_bonus+v_shield_bonus+v_dex_applied
    +v_size_modifier+v_effect_modifier+v_trap_sense_bonus);

  RETURN jsonb_build_object(
    'character_id',v_character.id::text,
    'base_ac',10,
    'armor_bonus',v_armor_bonus,
    'shield_bonus',v_shield_bonus,
    'dexterity_modifier',v_dex_modifier,
    'dexterity_applied',v_dex_applied,
    'dexterity_lost',v_lose_dex,
    'max_dexterity_bonus',v_max_dex,
    'size_modifier',v_size_modifier,
    'effect_modifier',v_effect_modifier,
    'trap_sense_bonus',v_trap_sense_bonus,
    'barbarian_level',COALESCE(v_barbarian_level,0),
    'rogue_level',COALESCE(v_rogue_level,0),
    'uncanny_dodge',v_uncanny_dodge,
    'improved_uncanny_dodge',v_improved_uncanny_dodge,
    'flatfooted',v_flatfooted,
    'final_ac',v_final_ac,
    'attack_context',v_context
  );
END;
$function$
;
REVOKE ALL ON FUNCTION public.srd_calcular_ca_personagem_srd(bigint,text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.srd_calcular_ca_personagem_srd(bigint,text,text) TO authenticated;

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

  RETURN v_bonus;
END;
$function$
;