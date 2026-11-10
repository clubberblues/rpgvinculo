
CREATE OR REPLACE FUNCTION public.srd_calcular_ca_personagem_srd(
  p_campaign_id bigint,p_character_id text,p_attack_context text,p_attacker_is_giant boolean
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
DECLARE
  v_result jsonb;
  v_race_id text;
  v_final_ac integer;
BEGIN
  v_result:=public.srd_calcular_ca_personagem_srd(p_campaign_id,p_character_id,p_attack_context);
  IF COALESCE(p_attacker_is_giant,false) THEN
    SELECT sh.raca_id::text INTO v_race_id
    FROM public.srd_character_sheets sh
    WHERE sh.character_id::text=BTRIM(p_character_id);
    IF v_race_id IN ('anao','gnomo')
       AND NOT COALESCE((v_result->>'dexterity_lost')::boolean,false) THEN
      v_final_ac:=COALESCE(NULLIF(v_result->>'final_ac','')::integer,10)+4;
      v_result:=v_result||jsonb_build_object('racial_giant_dodge_bonus',4,'final_ac',v_final_ac);
    END IF;
  END IF;
  RETURN v_result;
END;
$function$;

REVOKE ALL ON FUNCTION public.srd_calcular_ca_personagem_srd(bigint,text,text,boolean) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.srd_calcular_ca_personagem_srd(bigint,text,text,boolean) TO authenticated;

DO $migration$
DECLARE v_def text;v_old text;v_new text;v_count integer;
BEGIN
 v_def:=pg_get_functiondef('priv.npc_resolver_ataque_iterativo_impl(bigint,uuid)'::regprocedure);
 v_old:='  v_target_denies_dex boolean := false;';
 v_new:=v_old||E'\n  v_actor_is_giant boolean := false;\n  v_target_race text;\n  v_target_loses_dex boolean := false;';
 v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
 IF v_count<>1 THEN RAISE EXCEPTION 'Declarações de defesa racial contra gigantes não são únicas: %.',v_count; END IF;
 v_def:=replace(v_def,v_old,v_new);

 v_old:='  v_target := v_tokens->(v_target_ord::integer-1);'||E'\n'||'  v_actor := v_tokens->(v_actor_ord::integer-1);';
 v_new:=v_old||E'\n'||'  v_actor_is_giant:=lower(concat_ws('' '',v_actor->>''creature_type'',v_actor->''monsterStats''->>''type'',v_actor->''monsterStats''->>''tipo'',v_actor->''monsterStats''->>''creature_type'',v_actor->''monsterStats''->>''subtype'',v_actor->''monsterStats''->>''subtypes'')) ~ ''(giant|gigante)'';';
 v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
 IF v_count<>1 THEN RAISE EXCEPTION 'Ponto de identificação de atacante gigante não é único: %.',v_count; END IF;
 v_def:=replace(v_def,v_old,v_new);

 v_old:='v_player_ac:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_seq.target_token_id,''normal'');';
 v_new:='v_player_ac:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_seq.target_token_id,''normal'',v_actor_is_giant);';
 v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
 IF v_count<>1 THEN RAISE EXCEPTION 'Cálculo de CA do personagem alvo não é único: %.',v_count; END IF;
 v_def:=replace(v_def,v_old,v_new);

 v_old:=$old$    v_ca:=v_ca_text::integer+v_effect_ac;
  end if;
  v_expected := v_bab + v_ability_mod + v_size_mod + v_focus + v_racial_bonus$old$;
 v_new:=$new$    v_ca:=v_ca_text::integer+v_effect_ac;
  end if;
  IF v_target->>'tipo'<>'player' AND v_actor_is_giant THEN
    SELECT sh.raca_id::text INTO v_target_race
    FROM public.srd_character_sheets sh
    WHERE sh.character_id::text=COALESCE(NULLIF(v_target->>'sourceCharacterId',''),v_seq.target_token_id)
    LIMIT 1;
    v_target_race:=COALESCE(v_target_race,NULLIF(v_target->>'raca_id',''),v_target->'monsterStats'->>'race_id');
    v_target_loses_dex:=priv.srd_condition_has_flag(p_campaign_id,'token',v_seq.target_token_id,'loses_dex_ac')
      OR COALESCE(v_target->>'flat_footed','false')='true'
      OR COALESCE(v_target->'monsterStats'->>'loses_dex_ac','false')='true';
    IF v_target_race IN ('anao','gnomo') AND NOT v_target_loses_dex THEN
      v_ca:=v_ca+4;
    END IF;
  END IF;
  v_expected := v_bab + v_ability_mod + v_size_mod + v_focus + v_racial_bonus$new$;
 v_count:=(length(v_def)-length(replace(v_def,v_old,'')))/length(v_old);
 IF v_count<>1 THEN RAISE EXCEPTION 'Ponto de bônus de esquiva racial contra gigantes não é único: %.',v_count; END IF;
 v_def:=replace(v_def,v_old,v_new);
 EXECUTE v_def;
END;
$migration$;
