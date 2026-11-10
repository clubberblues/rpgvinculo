DO $migration$
DECLARE
  v_oid oid;
  v_definition text;
  v_revised text;
  v_needle text := $needle$+CASE WHEN p_attack_type='atk-corpo' THEN FLOOR((v_str_score+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'strength')-10)::numeric/2)::integer-FLOOR((v_str_score-10)::numeric/2)::integer ELSE 0 END$needle$;
  v_args text;
  v_count integer;
BEGIN
  FOR v_oid IN
    SELECT p.oid
    FROM pg_proc p
    JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public'
      AND p.proname='aplicar_dano_token_ataque_srd_v2'
      AND pg_get_function_identity_arguments(p.oid) IN (
        'p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer',
        'p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer, p_sneak_attack_dice integer, p_sneak_attack_damage integer'
      )
  LOOP
    v_definition := pg_get_functiondef(v_oid);
    v_count := (length(v_definition)-length(replace(v_definition,v_needle,''))) / length(v_needle);
    IF v_count <> 1 THEN
      RAISE EXCEPTION 'Esperava exatamente uma ocorrência do modificador de Força duplicado; encontrei % na função %.',v_count,v_oid::regprocedure;
    END IF;
    v_revised := replace(v_definition,v_needle,'');
    EXECUTE v_revised;
  END LOOP;
END;
$migration$;