CREATE OR REPLACE FUNCTION public.attack(p_atk bigint, p_alvo bigint, p_tipo text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  a public.tokens;
  d public.tokens;
  a_char public.characters;
  d_char public.characters;
  a_sheet public.srd_character_sheets;
  d_sheet public.srd_character_sheets;
  a_monster public.monster_instances;
  d_monster public.monster_instances;
  a_monster_def public.srd_monsters;
  d_monster_def public.srd_monsters;
  v_mod integer := 0;
  v_d20 integer;
  v_total integer;
  v_defense integer;
  v_defense_type text := 'CA';
  v_target_rm integer;
  v_crit boolean;
  v_fumble boolean;
  v_hit boolean;
  v_result text;
  v_score integer;
  v_damage_dice text;
BEGIN
  IF p_tipo NOT IN ('corporal','precisao','magico') THEN
    RAISE EXCEPTION 'Tipo inválido.';
  END IF;

  SELECT * INTO a FROM public.tokens WHERE id = p_atk;
  IF NOT FOUND THEN RAISE EXCEPTION 'Atacante inexistente.'; END IF;

  SELECT * INTO d FROM public.tokens WHERE id = p_alvo;
  IF NOT FOUND THEN RAISE EXCEPTION 'Alvo inexistente.'; END IF;

  IF a.campaign_id <> d.campaign_id THEN
    RAISE EXCEPTION 'Tokens de mesas diferentes.';
  END IF;

  IF public.my_role(a.campaign_id) IS NULL THEN
    RAISE EXCEPTION 'Você não participa desta mesa.';
  END IF;

  IF public.my_role(a.campaign_id) = 'PLAYER' THEN
    IF a.character_id IS NULL THEN
      RAISE EXCEPTION 'Jogador só pode atacar com token de personagem.';
    END IF;
    SELECT * INTO a_char FROM public.characters WHERE id = a.character_id;
    IF a_char.user_id IS DISTINCT FROM auth.uid() THEN
      RAISE EXCEPTION 'Você só ataca com o seu token.';
    END IF;
    IF NOT priv.is_my_turn(a.campaign_id, a.id) THEN
      RAISE EXCEPTION 'Não é o seu turno.';
    END IF;
  END IF;

  IF p_tipo = 'corporal' AND public.hex_dist(a.col, a.row, d.col, d.row) > 1 THEN
    RAISE EXCEPTION 'Alvo fora de alcance corpo a corpo.';
  END IF;

  IF a.character_id IS NOT NULL THEN
    SELECT * INTO a_sheet FROM public.srd_character_sheets
    WHERE character_id = a.character_id;
    v_score := NULLIF(public._srd35_attr(
      a_sheet.atributos,
      CASE WHEN p_tipo = 'corporal' THEN ARRAY['FOR','STR']::text[]
           WHEN p_tipo = 'precisao' THEN ARRAY['DES','DEX']::text[]
           ELSE ARRAY['INT']::text[] END
    ), '')::integer;
    v_mod := floor((COALESCE(v_score,10)-10)::numeric / 2)::integer;

    SELECT e.dano INTO v_damage_dice
    FROM public.srd_character_equipment ce
    JOIN public.srd_equipment e ON e.id = ce.equipment_id
    WHERE ce.character_id = a.character_id
      AND ce.equipado
      AND public.srd35_equipment_slot(e.categoria,e.nome) = 'arma'
    ORDER BY ce.criado_em
    LIMIT 1;
  ELSE
    SELECT * INTO a_monster FROM public.monster_instances
    WHERE id = a.monster_instance_id;
    IF a_monster.monster_id IS NOT NULL THEN
      SELECT * INTO a_monster_def FROM public.srd_monsters
      WHERE id = a_monster.monster_id;
      v_mod := COALESCE((regexp_match(a_monster_def.base_attack_grapple, '[-+]?[0-9]+'))[1]::integer, 0);
    END IF;
  END IF;

  IF d.character_id IS NOT NULL THEN
    SELECT * INTO d_sheet FROM public.srd_character_sheets
    WHERE character_id = d.character_id;
    v_score := NULLIF(public._srd35_attr(d_sheet.atributos, ARRAY['DES','DEX']::text[]), '')::integer;
    v_defense := 10 + floor((COALESCE(v_score,10)-10)::numeric / 2)::integer;
    SELECT v_defense + COALESCE(sum(public.srd35_equipment_ca_bonus(equipment_id)),0)
      INTO v_defense
    FROM public.srd_character_equipment
    WHERE character_id = d.character_id AND equipado;
  ELSE
    SELECT * INTO d_monster FROM public.monster_instances
    WHERE id = d.monster_instance_id;
    IF d_monster.monster_id IS NOT NULL THEN
      SELECT * INTO d_monster_def FROM public.srd_monsters
      WHERE id = d_monster.monster_id;
      v_defense := COALESCE((regexp_match(d_monster_def.ca, '([0-9]+)'))[1]::integer, 10);
      v_target_rm := NULLIF((regexp_match(COALESCE(d_monster_def.dados_tecnicos->>'resistencia_magia',''), '([0-9]+)'))[1], '')::integer;
    ELSE
      v_defense := 10;
    END IF;
  END IF;

  IF p_tipo = 'magico' THEN
    IF v_target_rm IS NULL THEN
      RAISE EXCEPTION 'Resistência à magia do alvo não está disponível para resolução automática.';
    END IF;
    v_defense := v_target_rm;
    v_defense_type := 'RM';
  END IF;

  v_d20 := priv.d20();
  v_total := v_d20 + v_mod;
  v_crit := v_d20 = 20;
  v_fumble := v_d20 = 1;
  v_hit := v_crit OR (NOT v_fumble AND v_total >= v_defense);

  IF v_crit THEN v_result := 'CRITICO';
  ELSIF v_fumble THEN v_result := 'FALHA_AUTO';
  ELSIF v_hit THEN v_result := 'ACERTO';
  ELSE v_result := 'ERRO';
  END IF;

  INSERT INTO public.roll_log(campaign_id,tipo,autor_id,alvo_id,expressao,d20,total,resultado,detalhes)
  VALUES (
    a.campaign_id,'ATAQUE',auth.uid(),d.id,p_tipo,v_d20,v_total,v_result,
    jsonb_build_object(
      'mod',v_mod,'defesa',v_defense,'defesa_tipo',v_defense_type,
      'dano_dice',v_damage_dice,'dano_pendente',v_hit AND v_damage_dice IS NULL,
      'fonte_esquema','tokens.col/row + SRD character/monster data'
    )
  );

  RETURN jsonb_build_object(
    'acertou',v_hit,'critico',v_crit,'falha',v_fumble,
    'd20',v_d20,'mod',v_mod,'total',v_total,
    'defesa',v_defense,'defesa_tipo',v_defense_type,
    'dano_dice',v_damage_dice,
    'dano_pendente',v_hit AND v_damage_dice IS NULL
  );
END;
$function$;