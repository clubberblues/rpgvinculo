CREATE OR REPLACE FUNCTION public.conjurar_magia_srd_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id bigint;
  v_spell record;
  v_result jsonb;
  v_targets jsonb := '[]'::jsonb;
  v_cba_data jsonb;
  v_tokens jsonb;
  v_token jsonb;
  v_token_index bigint;
  v_token_count integer;
  v_key text;
  v_target_type text;
  v_target_character_id text;
  v_hp integer;
  v_max_hp integer;
  v_healing integer;
  v_roll integer;
  v_die_count integer;
  v_die_size integer;
  v_dice text;
  v_per_level integer;
  v_max_level integer;
  v_level integer;
  v_idx integer;
  v_is_undead boolean;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  IF p_target_token_keys IS NULL
     OR cardinality(p_target_token_keys) < 1
     OR cardinality(p_target_token_keys) > 20
     OR EXISTS (
       SELECT 1 FROM unnest(p_target_token_keys) k
       WHERE NULLIF(btrim(k), '') IS NULL
     )
  THEN
    RAISE EXCEPTION 'Informe entre 1 e 20 tokens-alvo válidos';
  END IF;
  IF EXISTS (
    SELECT 1 FROM (
      SELECT btrim(k) AS key, count(*) AS n
      FROM unnest(p_target_token_keys) k
      GROUP BY btrim(k)
    ) d WHERE d.n > 1
  ) THEN
    RAISE EXCEPTION 'Cada token-alvo deve aparecer uma única vez';
  END IF;

  SELECT ch.campaign_id INTO v_campaign_id
  FROM public.characters ch
  WHERE ch.id::text=btrim(p_character_id) AND ch.user_id=auth.uid()
  FOR UPDATE;
  IF NOT FOUND OR v_campaign_id IS NULL THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem campanha autorizada';
  END IF;

  SELECT id,circulo,dados_tecnicos INTO v_spell
  FROM public.srd_spells WHERE id=p_spell_id;
  IF NOT FOUND
     OR coalesce(v_spell.dados_tecnicos->>'tipo_efeito','') <> 'cura'
     OR coalesce(v_spell.dados_tecnicos->>'target_mode','') <> 'multiple_targets_pending'
  THEN
    RAISE EXCEPTION 'A magia informada não é uma cura SRD de múltiplos alvos';
  END IF;
  IF p_slot_level IS NULL OR p_slot_level NOT BETWEEN 0 AND 9 THEN
    RAISE EXCEPTION 'slot_level deve estar entre 0 e 9';
  END IF;

  SELECT c.cba_data INTO v_cba_data
  FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array'
                 THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;

  -- Validate the first token before consuming the prepared slot.
  SELECT count(*)::integer,min(e.ordinality),min(e.token->>'tipo'),
         min(e.token->>'id'),bool_or(coalesce(e.token->'monsterStats'->>'tipo','') ILIKE '%undead%')
    INTO v_token_count,v_token_index,v_target_type,v_target_character_id,v_is_undead
  FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
  WHERE e.token->>'key'=btrim(p_target_token_keys[1]);
  IF v_token_count<>1 THEN RAISE EXCEPTION 'Primeiro token-alvo não encontrado ou duplicado'; END IF;
  IF coalesce(v_is_undead,false) THEN
    RAISE EXCEPTION 'Cura em massa contra mortos-vivos ainda requer o resolver de dano por energia positiva';
  END IF;

  v_result:=public.conjurar_magia_srd(
    p_character_id,p_spell_id,p_slot_level,btrim(p_target_token_keys[1])
  );
  v_targets:=v_targets||jsonb_build_array(jsonb_build_object(
    'token_key',btrim(p_target_token_keys[1]),
    'healing',coalesce((v_result->>'healing')::integer,0),
    'pv_atual',v_result->'pv_atual'
  ));

  v_dice:=coalesce(v_spell.dados_tecnicos->'cura'->>'dados','');
  IF v_dice ~ '^[0-9]+d[0-9]+([+-][0-9]+)?$' THEN
    v_die_count:=split_part(v_dice,'d',1)::integer;
    v_die_size:=regexp_replace(split_part(v_dice,'d',2),'[+-].*$','')::integer;
  ELSIF v_dice ~ '^[0-9]+$' THEN
    v_die_count:=0;
    v_die_size:=0;
  ELSE
    RAISE EXCEPTION 'Expressão de cura inválida na magia';
  END IF;
  v_per_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'por_nivel')::integer,0);
  v_max_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'max_nivel')::integer,0);
  SELECT nivel INTO v_level FROM public.srd_character_sheets
  WHERE character_id::text=btrim(p_character_id) FOR UPDATE;

  FOR v_idx IN 2..cardinality(p_target_token_keys) LOOP
    v_key:=btrim(p_target_token_keys[v_idx]);
    SELECT count(*)::integer,min(e.ordinality),min(e.token->>'tipo'),
           min(e.token->>'id'),bool_or(coalesce(e.token->'monsterStats'->>'tipo','') ILIKE '%undead%')
      INTO v_token_count,v_token_index,v_target_type,v_target_character_id,v_is_undead
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
    WHERE e.token->>'key'=v_key;
    SELECT e.token INTO v_token
    FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
    WHERE e.token->>'key'=v_key LIMIT 1;
    IF v_token_count<>1 THEN RAISE EXCEPTION 'Token-alvo não encontrado ou duplicado: %',v_key; END IF;
    IF coalesce(v_is_undead,false) THEN
      RAISE EXCEPTION 'Cura em massa contra mortos-vivos ainda requer o resolver de dano por energia positiva';
    END IF;

    IF v_die_count>0 THEN
      v_roll:=0;
      FOR v_idx IN 1..v_die_count LOOP
        v_roll:=v_roll+floor(random()*v_die_size)::integer+1;
      END LOOP;
      IF substring(v_dice from '([+-][0-9]+)$') IS NOT NULL THEN
        v_roll:=v_roll+substring(v_dice from '([+-][0-9]+)$')::integer;
      END IF;
    ELSE
      v_roll:=v_dice::integer;
    END IF;
    v_healing:=greatest(0,v_roll+v_per_level*CASE WHEN v_max_level>0 THEN least(v_level,v_max_level) ELSE v_level END);

    IF v_target_type='player' THEN
      SELECT sh.pv_atual,sh.pv_max INTO v_hp,v_max_hp
      FROM public.characters ch
      JOIN public.srd_character_sheets sh ON sh.character_id::text=ch.id::text
      WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
      FOR UPDATE OF sh;
      IF NOT FOUND THEN RAISE EXCEPTION 'Ficha do alvo player não encontrada: %',v_key; END IF;
      v_hp:=least(v_max_hp,greatest(0,coalesce(v_hp,0)+v_healing));
      UPDATE public.srd_character_sheets SET pv_atual=v_hp
      WHERE character_id::text=v_target_character_id;
    ELSE
      IF coalesce(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$'
         OR coalesce(v_token->>'hp','') !~ '^[0-9]{1,6}$'
      THEN
        RAISE EXCEPTION 'Token não possui HP válido: %',v_key;
      END IF;
      v_max_hp:=(v_token->>'maxHp')::integer;
      v_hp:=least(v_max_hp,greatest(0,(v_token->>'hp')::integer+v_healing));
    END IF;

    v_token:=v_token||jsonb_build_object('hp',v_hp,'maxHp',v_max_hp);
    v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
    v_targets:=v_targets||jsonb_build_array(jsonb_build_object(
      'token_key',v_key,'healing',v_healing,'pv_atual',v_hp
    ));
  END LOOP;

  v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
  UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;
  RETURN coalesce(v_result,'{}'::jsonb)||jsonb_build_object(
    'targets',v_targets,'target_count',cardinality(p_target_token_keys),
    'multiple_targets',true
  );
END;
$function$
