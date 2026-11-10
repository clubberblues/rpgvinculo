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
  IF v_context='trap' THEN
    v_trap_sense_bonus:=FLOOR(COALESCE(v_barbarian_level,0)/3.0)::integer;
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