CREATE OR REPLACE FUNCTION public.usar_imposicao_maos_mortos_vivos_srd(
  p_character_id text,
  p_target_token_key text,
  p_d20 integer,
  p_amount integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_campaign public.campaigns%ROWTYPE;
  v_scene jsonb;
  v_tokens jsonb;
  v_target jsonb;
  v_attacker jsonb;
  v_target_index bigint;
  v_target_count integer;
  v_attacker_count integer;
  v_touch_text text;
  v_touch_ac integer;
  v_paladin_level integer:=0;
  v_charisma integer:=10;
  v_charisma_mod integer:=0;
  v_pool integer:=0;
  v_spent integer:=0;
  v_remaining integer:=0;
  v_bab integer:=0;
  v_strength_score integer:=10;
  v_strength_mod integer:=0;
  v_size_modifier integer:=0;
  v_attacker_size integer:=1;
  v_target_size integer:=1;
  v_ax integer; v_ay integer; v_bx integer; v_by integer;
  v_dx integer; v_dy integer; v_distance_squares integer;
  v_attack_bonus integer:=0;
  v_attack_total integer:=0;
  v_hit boolean:=false;
  v_hp integer; v_max_hp integer; v_new_hp integer;
  v_target_name text;
  v_resource public.srd_character_feature_resources%ROWTYPE;
  v_action_result jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF NULLIF(BTRIM(p_character_id),'') IS NULL OR NULLIF(BTRIM(p_target_token_key),'') IS NULL THEN
    RAISE EXCEPTION 'Personagem e alvo são obrigatórios.';
  END IF;
  IF p_d20 IS NULL OR p_d20 NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'O ataque de toque exige um resultado manual de d20 entre 1 e 20.';
  END IF;
  IF p_amount IS NULL OR p_amount<1 OR p_amount>1000 THEN
    RAISE EXCEPTION 'Informe uma quantidade válida de pontos de Imposição das Mãos.';
  END IF;

  SELECT * INTO v_character
    FROM public.characters
   WHERE id::text=BTRIM(p_character_id) AND user_id=auth.uid()
   FOR UPDATE;
  IF NOT FOUND OR v_character.campaign_id IS NULL THEN
    RAISE EXCEPTION 'Personagem não encontrado ou não está em uma campanha.';
  END IF;
  SELECT * INTO v_sheet FROM public.srd_character_sheets
   WHERE character_id=v_character.id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do Paladino não encontrada.'; END IF;

  SELECT COALESCE(
    MAX(cl.class_level) FILTER (WHERE cl.class_id='paladino'),
    CASE WHEN NOT EXISTS (
      SELECT 1 FROM public.srd_character_class_levels any_level
       WHERE any_level.character_id=v_sheet.character_id
    ) AND v_sheet.classe_id='paladino'
    THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
  )
    INTO v_paladin_level
    FROM public.srd_character_class_levels cl
   WHERE cl.character_id=v_sheet.character_id;
  IF COALESCE(v_paladin_level,0)<2 THEN
    RAISE EXCEPTION 'Imposição das Mãos exige pelo menos 2 níveis de Paladino.';
  END IF;

  v_charisma:=COALESCE(NULLIF(v_sheet.atributos->>'CAR','')::integer,10);
  v_charisma_mod:=FLOOR((v_charisma-10)::numeric/2)::integer;
  v_pool:=v_paladin_level*GREATEST(0,v_charisma_mod);
  IF v_pool<=0 THEN RAISE EXCEPTION 'O modificador de Carisma não concede pontos para Imposição das Mãos.'; END IF;

  INSERT INTO public.srd_character_feature_resources(character_id,feature_key)
  VALUES(v_sheet.character_id,'lay_on_hands')
  ON CONFLICT(character_id,feature_key) DO NOTHING;
  SELECT * INTO v_resource FROM public.srd_character_feature_resources
   WHERE character_id=v_sheet.character_id AND feature_key='lay_on_hands'
   FOR UPDATE;
  v_spent:=COALESCE(v_resource.resource_spent,0);
  v_remaining:=GREATEST(0,v_pool-v_spent);
  IF p_amount>v_remaining THEN
    RAISE EXCEPTION 'Você solicitou % pontos, mas restam apenas % na reserva diária.',p_amount,v_remaining;
  END IF;

  SELECT * INTO v_campaign FROM public.campaigns
   WHERE id=v_character.campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do Paladino não encontrada.'; END IF;
  v_scene:=COALESCE(v_campaign.cba_data,'{}'::jsonb);
  v_tokens:=CASE WHEN jsonb_typeof(v_scene->'tokens')='array' THEN v_scene->'tokens' ELSE '[]'::jsonb END;

  SELECT count(*)::integer,min(t.ordinality),(array_agg(t.token ORDER BY t.ordinality))[1]
    INTO v_target_count,v_target_index,v_target
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality)
   WHERE (t.token->>'id'=BTRIM(p_target_token_key) OR t.token->>'key'=BTRIM(p_target_token_key))
     AND t.token->>'tipo' IN ('npc','monstro');
  IF v_target_count<>1 THEN RAISE EXCEPTION 'O alvo deve ser um único token de NPC ou monstro.'; END IF;

  IF lower(COALESCE(v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'type',v_target->>'tipo_criatura',''))
       NOT LIKE '%undead%'
     AND lower(COALESCE(v_target->'monsterStats'->>'tipo',v_target->'monsterStats'->>'type',v_target->>'tipo_criatura',''))
       NOT LIKE '%morto-vivo%' THEN
    RAISE EXCEPTION 'Imposição das Mãos ofensiva só pode atingir criaturas do tipo morto-vivo.';
  END IF;

  v_touch_text:=COALESCE(
    NULLIF(v_target->>'touchAc',''),
    NULLIF(v_target->>'ca_toque',''),
    NULLIF(v_target->'monsterStats'->>'ca_touch',''),
    NULLIF(v_target->'monsterStats'->>'touch_ac',''),
    (regexp_match(COALESCE(v_target->'monsterStats'->>'ca',v_target->>'ca',v_target->>'ac',''),'(?i)touch[[:space:]]+([0-9]{1,3})'))[1]
  );
  IF COALESCE(v_touch_text,'') !~ '^[0-9]{1,3}$' THEN
    RAISE EXCEPTION 'A ficha do morto-vivo não possui CA de toque cadastrada. Atualize a ficha da criatura antes de tentar o ataque.';
  END IF;
  v_touch_ac:=v_touch_text::integer;

  IF COALESCE(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN
    RAISE EXCEPTION 'O alvo não possui PV máximo válido.';
  END IF;
  v_max_hp:=(v_target->>'maxHp')::integer;
  v_hp:=CASE WHEN COALESCE(v_target->>'hp','') ~ '^[0-9]{1,6}$' THEN (v_target->>'hp')::integer ELSE v_max_hp END;
  IF v_hp<=0 THEN RAISE EXCEPTION 'O morto-vivo já está derrotado.'; END IF;

  SELECT count(*)::integer,(array_agg(t.token ORDER BY t.ordinality))[1]
    INTO v_attacker_count,v_attacker
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality)
   WHERE t.token->>'id'=v_character.id::text AND t.token->>'tipo'='player';
  IF v_attacker_count<>1 THEN RAISE EXCEPTION 'O token do Paladino não foi encontrado ou está duplicado no campo de batalha.'; END IF;
  IF COALESCE(v_attacker->>'gridX','') !~ '^-?[0-9]+$'
     OR COALESCE(v_attacker->>'gridY','') !~ '^-?[0-9]+$'
     OR COALESCE(v_target->>'gridX','') !~ '^-?[0-9]+$'
     OR COALESCE(v_target->>'gridY','') !~ '^-?[0-9]+$' THEN
    RAISE EXCEPTION 'Posição dos tokens inválida para confirmar o alcance do toque.';
  END IF;

  SELECT CASE translate(lower(COALESCE(r.tamanho,'medio')),'áéíóúãõâêôç','aeiouaoaeoc')
    WHEN 'minusculo' THEN 8 WHEN 'fine' THEN 8
    WHEN 'diminuto' THEN 4 WHEN 'diminutive' THEN 4
    WHEN 'miudo' THEN 2 WHEN 'tiny' THEN 2
    WHEN 'pequeno' THEN 1 WHEN 'small' THEN 1
    WHEN 'grande' THEN -1 WHEN 'large' THEN -1
    WHEN 'enorme' THEN -2 WHEN 'huge' THEN -2
    WHEN 'imenso' THEN -4 WHEN 'gargantuan' THEN -4
    WHEN 'colossal' THEN -8 ELSE 0 END
    INTO v_size_modifier
    FROM public.srd_races r WHERE r.id=v_sheet.raca_id;
  v_size_modifier:=COALESCE(v_size_modifier,0);
  v_attacker_size:=CASE
    WHEN lower(COALESCE((SELECT tamanho FROM public.srd_races WHERE id=v_sheet.raca_id),'')) LIKE 'large%' OR lower(COALESCE((SELECT tamanho FROM public.srd_races WHERE id=v_sheet.raca_id),'')) LIKE 'grande%' THEN 2
    WHEN lower(COALESCE((SELECT tamanho FROM public.srd_races WHERE id=v_sheet.raca_id),'')) LIKE 'huge%' OR lower(COALESCE((SELECT tamanho FROM public.srd_races WHERE id=v_sheet.raca_id),'')) LIKE 'enorme%' THEN 3
    WHEN lower(COALESCE((SELECT tamanho FROM public.srd_races WHERE id=v_sheet.raca_id),'')) LIKE 'gargantuan%' OR lower(COALESCE((SELECT tamanho FROM public.srd_races WHERE id=v_sheet.raca_id),'')) LIKE 'imenso%' THEN 4
    WHEN lower(COALESCE((SELECT tamanho FROM public.srd_races WHERE id=v_sheet.raca_id),'')) LIKE 'colossal%' THEN 5 ELSE 1 END;
  v_target_size:=CASE
    WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'large%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'grande%' THEN 2
    WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'huge%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'enorme%' THEN 3
    WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'gargantuan%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'imenso%' THEN 4
    WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'colossal%' THEN 5 ELSE 1 END;
  v_ax:=(v_attacker->>'gridX')::integer; v_ay:=(v_attacker->>'gridY')::integer;
  v_bx:=(v_target->>'gridX')::integer; v_by:=(v_target->>'gridY')::integer;
  v_dx:=GREATEST(0,v_bx-(v_ax+v_attacker_size-1),v_ax-(v_bx+v_target_size-1));
  v_dy:=GREATEST(0,v_by-(v_ay+v_attacker_size-1),v_ay-(v_by+v_target_size-1));
  v_distance_squares:=GREATEST(v_dx,v_dy)+FLOOR(LEAST(v_dx,v_dy)::numeric/2)::integer;
  IF v_distance_squares>GREATEST(1,v_attacker_size) THEN
    RAISE EXCEPTION 'O morto-vivo está fora do alcance de toque corpo a corpo.';
  END IF;

  SELECT COALESCE(SUM(x.base_attack_bonus),0)::integer INTO v_bab
    FROM (
      SELECT DISTINCT ON (cl.class_id) pr.base_attack_bonus
        FROM public.srd_character_class_levels cl
        JOIN public.srd_class_level_progressions pr
          ON pr.class_id=cl.class_id AND pr.class_level=cl.class_level
       WHERE cl.character_id=v_sheet.character_id
       ORDER BY cl.class_id,cl.class_level DESC
    ) x;
  IF NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels WHERE character_id=v_sheet.character_id) THEN
    SELECT COALESCE(pr.base_attack_bonus,0)::integer INTO v_bab
      FROM public.srd_class_level_progressions pr
     WHERE pr.class_id=v_sheet.classe_id AND pr.class_level=GREATEST(1,v_sheet.nivel)
     LIMIT 1;
  END IF;
  v_strength_score:=COALESCE(NULLIF(v_sheet.atributos->>'FOR','')::integer,10);
  v_strength_mod:=FLOOR((v_strength_score+priv.srd_effective_modifier(v_character.campaign_id,'character',v_character.id::text,'strength')-10)::numeric/2)::integer;
  v_attack_bonus:=COALESCE(v_bab,0)+v_strength_mod+v_size_modifier
    +priv.srd_effective_modifier(v_character.campaign_id,'character',v_character.id::text,'attack')
    +priv.srd_effective_modifier(v_character.campaign_id,'character',v_character.id::text,'attack_melee');
  IF priv.srd_condition_has_flag(v_character.campaign_id,'character',v_character.id::text,'no_actions')
     OR priv.srd_condition_has_flag(v_character.campaign_id,'character',v_character.id::text,'cannot_attack') THEN
    RAISE EXCEPTION 'A condição atual impede o ataque de toque.';
  END IF;

  IF UPPER(COALESCE(v_campaign.state,''))='COMBATE' THEN
    v_action_result:=public.consumir_acao_turno_srd(v_character.campaign_id,v_character.id::text,'padrao');
  END IF;

  v_attack_total:=p_d20+v_attack_bonus;
  v_hit:=p_d20=20 OR (p_d20<>1 AND v_attack_total>=v_touch_ac);
  IF NOT v_hit THEN
    RETURN jsonb_build_object(
      'feature_key','lay_on_hands','action','harm_undead','hit',false,
      'd20',p_d20,'attack_bonus',v_attack_bonus,'attack_total',v_attack_total,
      'touch_ac',v_touch_ac,'damage',0,'resource_spent',v_spent,
      'resource_remaining',v_remaining,'action_cost','standard','cba_data',v_scene
    );
  END IF;

  v_new_hp:=GREATEST(0,v_hp-p_amount);
  v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
  SELECT min(t.ordinality) INTO v_target_index
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality)
   WHERE (t.token->>'id'=BTRIM(p_target_token_key) OR t.token->>'key'=BTRIM(p_target_token_key))
     AND t.token->>'tipo' IN ('npc','monstro');
  v_tokens:=jsonb_set(v_tokens,ARRAY[(v_target_index-1)::text],v_target,false);
  v_scene:=v_scene||jsonb_build_object('tokens',v_tokens);
  UPDATE public.campaigns SET cba_data=v_scene WHERE id=v_character.campaign_id;

  UPDATE public.srd_character_feature_resources
     SET resource_spent=v_spent+p_amount,last_reset_at=COALESCE(last_reset_at,now())
   WHERE character_id=v_sheet.character_id AND feature_key='lay_on_hands';
  PERFORM priv.log(v_character.campaign_id,'CLASS_FEATURE',jsonb_build_object(
    'feature_key','lay_on_hands','action','harm_undead','character_id',v_character.id::text,
    'character_name',v_character.nome,'target_id',BTRIM(p_target_token_key),
    'target_name',COALESCE(v_target->>'nome',v_target->>'name','Morto-vivo'),
    'd20',p_d20,'attack_bonus',v_attack_bonus,'attack_total',v_attack_total,
    'touch_ac',v_touch_ac,'damage',p_amount,'target_hp',v_new_hp,
    'resource_remaining',v_remaining-p_amount
  ));

  RETURN jsonb_build_object(
    'feature_key','lay_on_hands','action','harm_undead','hit',true,
    'd20',p_d20,'attack_bonus',v_attack_bonus,'attack_total',v_attack_total,
    'touch_ac',v_touch_ac,'damage',p_amount,'hp',v_new_hp,'max_hp',v_max_hp,
    'target_id',BTRIM(p_target_token_key),'target_name',COALESCE(v_target->>'nome',v_target->>'name','Morto-vivo'),
    'resource_spent',v_spent+p_amount,'resource_remaining',v_remaining-p_amount,
    'action_cost','standard','cba_data',v_scene
  );
END;
$function$;

REVOKE ALL ON FUNCTION public.usar_imposicao_maos_mortos_vivos_srd(text,text,integer,integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.usar_imposicao_maos_mortos_vivos_srd(text,text,integer,integer) TO authenticated;