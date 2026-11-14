-- A validação de 9m do Ataque Furtivo ocorre após calcular a distância real.
CREATE OR REPLACE FUNCTION public.aplicar_dano_token_ataque_srd_v2(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer, p_sneak_attack_dice integer, p_sneak_attack_damage integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
 v_user UUID:=auth.uid(); v_campaign public.campaigns%ROWTYPE; v_combat JSONB; v_order JSONB; v_actor JSONB; v_scene JSONB; v_tokens JSONB; v_target JSONB;
 v_target_count INTEGER; v_target_index BIGINT; v_ca_text TEXT; v_ca INTEGER; v_max_hp INTEGER; v_hp INTEGER; v_new_hp INTEGER; v_attack_total INTEGER; v_round INTEGER;
 v_sheet public.srd_character_sheets%ROWTYPE; v_weapon public.srd_equipment%ROWTYPE; v_bab_progression TEXT; v_race_size TEXT;
 v_level INTEGER; v_bab INTEGER; v_str_score INTEGER; v_dex_score INTEGER; v_ability_mod INTEGER; v_ability_key TEXT;
 v_size_modifier INTEGER:=0; v_weapon_focus INTEGER:=0; v_power_penalty INTEGER:=0; v_range_penalty INTEGER:=0; v_expected_bonus INTEGER;
 v_has_finesse BOOLEAN:=FALSE; v_has_power_attack BOOLEAN:=FALSE; v_weapon_name TEXT;
 v_effective_attack_modifier INTEGER:=0; v_effective_ac_modifier INTEGER:=0; v_damage_final INTEGER:=0; v_damage_type TEXT;
 v_attacker_count INTEGER; v_attacker_index BIGINT; v_attacker JSONB;
 v_attacker_size INTEGER:=1; v_target_size INTEGER:=1; v_reach_squares INTEGER:=1;
 v_ax INTEGER; v_ay INTEGER; v_bx INTEGER; v_by INTEGER; v_dx INTEGER; v_dy INTEGER; v_distance_squares INTEGER;
 v_range_increment_m NUMERIC; v_range_increments INTEGER; v_max_range_increments INTEGER:=10;
 v_class_weapon_proficiencies JSONB; v_weapon_proficiency_type TEXT; v_weapon_proficiency_penalty INTEGER:=0; v_weapon_focus_name TEXT;
 v_class_has_simple BOOLEAN:=FALSE; v_class_has_simple_martial BOOLEAN:=FALSE; v_class_has_exact_weapon BOOLEAN:=FALSE;
 v_has_simple_feat BOOLEAN:=FALSE; v_has_martial_feat BOOLEAN:=FALSE; v_has_exotic_feat BOOLEAN:=FALSE; v_is_proficient BOOLEAN:=FALSE; v_rogue_level INTEGER:=0; v_expected_sneak_dice INTEGER:=0; v_target_type TEXT;
BEGIN
 IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 IF p_d20 IS NULL OR p_d20<1 OR p_d20>20 THEN RAISE EXCEPTION 'Resultado de ataque inválido.'; END IF;
 IF p_bonus_ataque IS NULL OR p_bonus_ataque < -30 OR p_bonus_ataque > 60 THEN RAISE EXCEPTION 'Bônus de ataque inválido.'; END IF;
 IF p_dano IS NULL OR p_dano<1 OR p_dano>1000 THEN RAISE EXCEPTION 'Dano inválido.'; END IF;
 SELECT c.* INTO v_campaign FROM public.campaigns c WHERE c.id=p_campaign_id FOR UPDATE;
 IF NOT FOUND OR UPPER(COALESCE(v_campaign.state,''))<>'COMBATE' THEN RAISE EXCEPTION 'A campanha não está em combate.'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.characters ch JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER' WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.campaign_id=p_campaign_id AND ch.user_id=v_user) THEN RAISE EXCEPTION 'A ficha atacante não pertence ao jogador nesta campanha.'; END IF;
 v_combat:=COALESCE(v_campaign.combat_data,'{}'::JSONB);
 IF COALESCE(v_combat->>'active','false')<>'true' THEN RAISE EXCEPTION 'A iniciativa não está ativa.'; END IF;
 v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
 IF COALESCE(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN RAISE EXCEPTION 'O turno atual é inválido.'; END IF;
 v_actor:=v_order->(v_combat->>'current_turn')::INTEGER;
 IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_character_id) OR COALESCE(v_actor->>'is_monster','false')='true' THEN RAISE EXCEPTION 'Apenas o personagem ativo pode concluir este ataque.'; END IF;
 v_round:=CASE WHEN COALESCE(v_combat->>'round','') ~ '^[0-9]+$' THEN GREATEST(1,(v_combat->>'round')::INTEGER) ELSE 1 END;
 IF COALESCE(v_combat->'action_economy'->>'round','')<>v_round::TEXT OR COALESCE(v_combat->'action_economy'->'by_character'->BTRIM(p_character_id)->>'padrao','false')<>'true' THEN RAISE EXCEPTION 'A ação padrão do atacante ainda não foi consumida neste turno.'; END IF;
 v_scene:=COALESCE(v_campaign.cba_data,'{}'::JSONB); v_tokens:=CASE WHEN jsonb_typeof(v_scene->'tokens')='array' THEN v_scene->'tokens' ELSE '[]'::JSONB END;
 SELECT count(*)::INTEGER,min(t.ordinality),min(coalesce(t.token->>'ac',t.token->'monsterStats'->>'ca')) INTO v_target_count,v_target_index,v_ca_text FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality) WHERE t.token->>'id'=BTRIM(p_token_id) AND t.token->>'tipo' IN ('npc','monstro');
 IF v_target_count<>1 THEN RAISE EXCEPTION 'O alvo NPC/monstro não foi encontrado ou está duplicado.'; END IF;
 v_target:=v_tokens->(v_target_index::INTEGER-1);
 IF p_attack_type IS NULL OR p_attack_type NOT IN ('atk-corpo','atk-dist') THEN RAISE EXCEPTION 'Tipo de ataque inválido.'; END IF;
 v_power_penalty:=COALESCE(p_power_penalty,0);
 IF v_power_penalty<0 THEN RAISE EXCEPTION 'Penalidade de Ataque Poderoso inválida.'; END IF;
 SELECT sh.* INTO v_sheet
 FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
 WHERE ch.id::TEXT=BTRIM(p_character_id) AND ch.campaign_id=p_campaign_id AND ch.user_id=v_user;
 IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD 3.5 do atacante não encontrada.'; END IF;
 SELECT COALESCE(
   MAX(cl.class_level) FILTER (WHERE cls.class_key='rogue'),
   CASE WHEN NOT EXISTS (SELECT 1 FROM public.srd_character_class_levels any_level WHERE any_level.character_id=v_sheet.character_id)
          AND v_sheet.classe_id='ladino' THEN GREATEST(1,COALESCE(v_sheet.nivel,1)) ELSE 0 END
 ) INTO v_rogue_level
 FROM public.srd_character_sheets sh
 LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
 LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
 WHERE sh.character_id=v_sheet.character_id
 GROUP BY sh.character_id,sh.classe_id,sh.nivel;
 v_expected_sneak_dice:=LEAST(10,FLOOR((COALESCE(v_rogue_level,0)+1)/2.0)::INTEGER);
 v_target_type:=lower(COALESCE(v_target->'monsterStats'->>'creature_type',v_target->'monsterStats'->>'type',v_target->>'creature_type',''));
 IF COALESCE(p_sneak_attack_dice,0)<0 OR COALESCE(p_sneak_attack_damage,0)<0 THEN RAISE EXCEPTION 'Dados de Ataque Furtivo inválidos.'; END IF;
 IF COALESCE(p_sneak_attack_dice,0)>0 THEN
   IF p_sneak_attack_dice<>v_expected_sneak_dice OR p_sneak_attack_damage<p_sneak_attack_dice OR p_sneak_attack_damage>p_sneak_attack_dice*6 THEN
     RAISE EXCEPTION 'Rolagem de Ataque Furtivo não corresponde ao nível do Ladino.';
   END IF;
   IF NOT (priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'loses_dex_ac')
        OR priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'loses_dex_ac_vs_non_grapplers')) THEN
     RAISE EXCEPTION 'Ataque Furtivo exige que o alvo perca seu bônus de Destreza na CA; flanqueamento ainda não foi validado pelo motor.';
   END IF;
   IF v_target_type IN ('undead','construct','ooze','plant','elemental','incorporeal') THEN
     RAISE EXCEPTION 'Este tipo de criatura é imune a Ataque Furtivo.';
   END IF;
 ELSE
   IF COALESCE(p_sneak_attack_damage,0)<>0 THEN RAISE EXCEPTION 'Dano de Ataque Furtivo sem dados declarados.';
   END IF;
 END IF;
 SELECT cl.bab_progression,r.tamanho,cl.dados_tecnicos->'proficiencias'->'armas' INTO v_bab_progression,v_race_size,v_class_weapon_proficiencies
 FROM public.srd_classes cl CROSS JOIN public.srd_races r
 WHERE cl.id=v_sheet.classe_id AND r.id=v_sheet.raca_id;
 IF NOT FOUND THEN RAISE EXCEPTION 'Classe ou raça da ficha não encontrada.'; END IF;
 v_level:=GREATEST(1,COALESCE(v_sheet.nivel,1));
 v_bab:=CASE lower(COALESCE(v_bab_progression,''))
   WHEN 'good' THEN v_level WHEN 'bom' THEN v_level
   WHEN 'average' THEN FLOOR(3*v_level/4)::INTEGER WHEN 'medium' THEN FLOOR(3*v_level/4)::INTEGER WHEN 'medio' THEN FLOOR(3*v_level/4)::INTEGER
   WHEN 'poor' THEN FLOOR(v_level/2)::INTEGER WHEN 'ruim' THEN FLOOR(v_level/2)::INTEGER ELSE 0 END;
 v_str_score:=CASE WHEN COALESCE(v_sheet.atributos->>'FOR','') ~ '^[0-9]+$' THEN (v_sheet.atributos->>'FOR')::INTEGER ELSE 10 END;
 v_dex_score:=CASE WHEN COALESCE(v_sheet.atributos->>'DES','') ~ '^[0-9]+$' THEN (v_sheet.atributos->>'DES')::INTEGER ELSE 10 END;
 v_has_finesse:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_weapon_finesse');
 v_has_power_attack:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='ataque_poderoso');
 IF NULLIF(BTRIM(p_weapon_id),'') IS NOT NULL THEN
   SELECT eq.* INTO v_weapon FROM public.srd_character_equipment ce JOIN public.srd_equipment eq ON eq.id=ce.equipment_id
   WHERE ce.character_id=v_sheet.character_id AND ce.equipment_id=BTRIM(p_weapon_id) AND ce.equipado IS TRUE AND eq.categoria='arma';
   IF NOT FOUND THEN RAISE EXCEPTION 'A arma informada não está equipada nesta ficha.'; END IF;
 END IF;
 v_weapon_name:=COALESCE(v_weapon.detalhes->>'weapon_proficiency_name',v_weapon.nome,'Ataque desarmado'); v_weapon_focus_name:=COALESCE(v_weapon.detalhes->>'weapon_focus_name',v_weapon.nome,'Ataque desarmado');
 v_weapon_proficiency_type:=COALESCE(v_weapon.detalhes->>'weapon_proficiency','');
 IF v_weapon.id IS NOT NULL THEN
   v_class_has_simple:=EXISTS(
     SELECT 1 FROM jsonb_array_elements_text(CASE WHEN jsonb_typeof(v_class_weapon_proficiencies)='array' THEN v_class_weapon_proficiencies ELSE '[]'::JSONB END) p(value)
     WHERE lower(BTRIM(p.value))='armas simples'
   );
   v_class_has_simple_martial:=EXISTS(
     SELECT 1 FROM jsonb_array_elements_text(CASE WHEN jsonb_typeof(v_class_weapon_proficiencies)='array' THEN v_class_weapon_proficiencies ELSE '[]'::JSONB END) p(value)
     WHERE lower(BTRIM(p.value))='todas as armas simples e marciais'
   );
   v_class_has_exact_weapon:=EXISTS(
     SELECT 1 FROM jsonb_array_elements_text(CASE WHEN jsonb_typeof(v_class_weapon_proficiencies)='array' THEN v_class_weapon_proficiencies ELSE '[]'::JSONB END) p(value)
     WHERE lower(BTRIM(p.value))=lower(BTRIM(v_weapon_name))
   );
   v_has_simple_feat:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_simple_weapon_proficiency');
   v_has_martial_feat:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_martial_weapon_proficiency' AND lower(BTRIM(COALESCE(f->>'parametro','')))=lower(BTRIM(v_weapon_name)));
   v_has_exotic_feat:=EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_exotic_weapon_proficiency' AND lower(BTRIM(COALESCE(f->>'parametro','')))=lower(BTRIM(v_weapon_name)));
   v_is_proficient:=CASE
     WHEN v_weapon_proficiency_type='simple' THEN v_class_has_exact_weapon OR v_class_has_simple OR v_class_has_simple_martial OR v_has_simple_feat
     WHEN v_weapon_proficiency_type='martial' THEN v_class_has_exact_weapon OR v_class_has_simple_martial OR v_has_martial_feat
     WHEN v_weapon_proficiency_type='exotic' THEN v_class_has_exact_weapon OR v_has_exotic_feat
     ELSE FALSE END;
   v_weapon_proficiency_penalty:=CASE WHEN v_is_proficient THEN 0 ELSE 4 END;
 END IF;
 IF p_attack_type='atk-dist' THEN
   IF v_weapon.id IS NULL OR COALESCE(v_weapon.detalhes->>'weapon_ranged','false')<>'true' THEN RAISE EXCEPTION 'A arma equipada não permite ataque à distância.'; END IF;
   v_ability_key:='DES';
 ELSE
   IF v_weapon.id IS NOT NULL AND COALESCE(v_weapon.detalhes->>'weapon_melee','true')='false' THEN RAISE EXCEPTION 'A arma equipada não permite ataque corpo a corpo.'; END IF;
   IF v_has_finesse AND (v_weapon.id IS NULL OR COALESCE(v_weapon.detalhes->>'weapon_finesse_eligible','false')='true') THEN v_ability_key:='DES'; ELSE v_ability_key:='FOR'; END IF;
 END IF;
 v_ability_mod:=FLOOR(((CASE WHEN v_ability_key='DES' THEN v_dex_score ELSE v_str_score END)-10)::NUMERIC/2)::INTEGER;
 v_size_modifier:=CASE WHEN lower(COALESCE(v_race_size,'')) IN ('pequeno','small') THEN 1 ELSE 0 END;
 SELECT (CASE WHEN EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='foco_em_arma' AND lower(BTRIM(COALESCE(f->>'parametro','')))=lower(BTRIM(v_weapon_focus_name))) THEN 1 ELSE 0 END)+(CASE WHEN EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_sheet.talentos)='array' THEN v_sheet.talentos ELSE '[]'::JSONB END) f WHERE f->>'id'='srd35_feat_greater_weapon_focus' AND lower(BTRIM(COALESCE(f->>'parametro','')))=lower(BTRIM(v_weapon_focus_name))) THEN 1 ELSE 0 END) INTO v_weapon_focus;
 IF v_power_penalty>0 AND (p_attack_type<>'atk-corpo' OR v_weapon.id IS NULL OR COALESCE(v_weapon.detalhes->>'weapon_light','false')='true' OR NOT v_has_power_attack OR v_power_penalty>v_bab) THEN RAISE EXCEPTION 'Ataque Poderoso inválido para esta ficha ou ataque.'; END IF;
 SELECT count(*)::INTEGER,min(t.ordinality) INTO v_attacker_count,v_attacker_index
 FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS t(token,ordinality)
 WHERE t.token->>'id'=BTRIM(p_character_id) AND t.token->>'tipo'='player';
 IF v_attacker_count<>1 THEN RAISE EXCEPTION 'O token do personagem atacante não foi encontrado ou está duplicado.'; END IF;
 v_attacker:=v_tokens->(v_attacker_index::INTEGER-1);
 v_attacker_size:=CASE
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'large%' OR lower(COALESCE(v_race_size,'')) LIKE 'grande%' THEN 2
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'huge%' OR lower(COALESCE(v_race_size,'')) LIKE 'enorme%' THEN 3
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'gargantuan%' OR lower(COALESCE(v_race_size,'')) LIKE 'imenso%' THEN 4
   WHEN lower(COALESCE(v_race_size,'')) LIKE 'colossal%' THEN 5 ELSE 1 END;
 v_target_size:=CASE
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'large%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'grande%' THEN 2
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'huge%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'enorme%' THEN 3
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'gargantuan%' OR lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'imenso%' THEN 4
   WHEN lower(COALESCE(v_target->'monsterStats'->>'tamanho',v_target->>'tamanho','')) LIKE 'colossal%' THEN 5 ELSE 1 END;
 IF COALESCE(v_attacker->>'gridX','') !~ '^-?[0-9]+$' OR COALESCE(v_attacker->>'gridY','') !~ '^-?[0-9]+$' OR COALESCE(v_target->>'gridX','') !~ '^-?[0-9]+$' OR COALESCE(v_target->>'gridY','') !~ '^-?[0-9]+$' THEN RAISE EXCEPTION 'Posição de token inválida para calcular alcance.'; END IF;
 v_ax:=(v_attacker->>'gridX')::INTEGER; v_ay:=(v_attacker->>'gridY')::INTEGER; v_bx:=(v_target->>'gridX')::INTEGER; v_by:=(v_target->>'gridY')::INTEGER;
 v_dx:=GREATEST(0,v_bx-(v_ax+v_attacker_size-1),v_ax-(v_bx+v_target_size-1));
 v_dy:=GREATEST(0,v_by-(v_ay+v_attacker_size-1),v_ay-(v_by+v_target_size-1));
 v_distance_squares:=GREATEST(v_dx,v_dy)+FLOOR(LEAST(v_dx,v_dy)::NUMERIC/2)::INTEGER;
 IF COALESCE(p_sneak_attack_dice,0)>0 AND p_attack_type='atk-dist' AND v_distance_squares>6 THEN RAISE EXCEPTION 'Ataque Furtivo à distância exige até 9 metros.'; END IF;
 IF p_attack_type='atk-corpo' THEN
   v_reach_squares:=GREATEST(1,v_attacker_size);
   IF v_distance_squares>v_reach_squares THEN RAISE EXCEPTION 'Alvo fora do alcance corpo a corpo.'; END IF;
 ELSE
   v_range_increment_m:=NULLIF(v_weapon.detalhes->>'range_increment_m','')::NUMERIC;
   IF v_range_increment_m IS NULL OR v_range_increment_m<=0 THEN RAISE EXCEPTION 'Incremento de distância da arma não cadastrado.'; END IF;
   v_range_increments:=GREATEST(1,CEIL((v_distance_squares*1.5)/v_range_increment_m)::INTEGER);
   v_max_range_increments:=COALESCE(NULLIF(v_weapon.detalhes->>'max_range_increments','')::INTEGER,10); IF v_range_increments>v_max_range_increments THEN RAISE EXCEPTION 'Alvo fora do alcance máximo de % incrementos da arma.',v_max_range_increments; END IF;
   v_range_penalty:=(v_range_increments-1)*2;
 END IF;
 v_expected_bonus:=v_bab+v_ability_mod+v_size_modifier+v_weapon_focus-v_power_penalty-v_range_penalty-v_weapon_proficiency_penalty;
 IF p_bonus_ataque<>v_expected_bonus THEN RAISE EXCEPTION 'Bônus de ataque não confere com a ficha. Esperado: %, recebido: %.',v_expected_bonus,p_bonus_ataque; END IF;
 IF priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'no_actions') OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'cannot_attack') THEN RAISE EXCEPTION 'A condição atual impede ataques.'; END IF;
 v_effective_attack_modifier:=priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'attack')+CASE WHEN p_attack_type='atk-corpo' THEN priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'attack_melee')+FLOOR((v_str_score+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'strength')-10)::numeric/2)::integer-FLOOR((v_str_score-10)::numeric/2)::integer ELSE priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'attack_ranged')+FLOOR((v_dex_score+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'dexterity')-10)::numeric/2)::integer-FLOOR((v_dex_score-10)::numeric/2)::integer END;
 IF COALESCE(v_ca_text,'') !~ '[0-9]{1,3}' THEN RAISE EXCEPTION 'O token alvo precisa ter uma CA numérica.'; END IF;
 v_effective_ac_modifier:=priv.srd_effective_modifier(p_campaign_id,'token',BTRIM(p_token_id),'ac')+CASE WHEN p_attack_type='atk-corpo' THEN priv.srd_effective_modifier(p_campaign_id,'token',BTRIM(p_token_id),'ac_melee') ELSE priv.srd_effective_modifier(p_campaign_id,'token',BTRIM(p_token_id),'ac_ranged') END;
 v_ca:=substring(v_ca_text from '[0-9]{1,3}')::INTEGER+v_effective_ac_modifier; v_attack_total:=p_d20+v_expected_bonus+v_effective_attack_modifier;
 IF p_d20=1 OR (p_d20<>20 AND v_attack_total<v_ca) THEN RAISE EXCEPTION 'Ataque não atingiu a CA do alvo (%). Nenhum dano foi aplicado.',v_ca; END IF;
 v_target:=v_tokens->(v_target_index::INTEGER-1);
 IF COALESCE(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN RAISE EXCEPTION 'O alvo não possui PV máximo configurado.'; END IF;
 v_max_hp:=(v_target->>'maxHp')::INTEGER; v_hp:=CASE WHEN COALESCE(v_target->>'hp','') ~ '^[0-9]{1,6}$' THEN (v_target->>'hp')::INTEGER ELSE v_max_hp END;
 v_damage_type:=CASE lower(COALESCE(v_weapon.tipo_dano,'bludgeoning')) WHEN 'cortante' THEN 'slashing' WHEN 'perfurante' THEN 'piercing' WHEN 'impacto' THEN 'bludgeoning' WHEN 'cortante/perfurante' THEN 'physical' WHEN 'impacto/perfurante' THEN 'physical' ELSE lower(COALESCE(v_weapon.tipo_dano,'bludgeoning')) END;
 v_damage_final:=priv.srd_adjust_damage(p_campaign_id,'token',BTRIM(p_token_id),v_damage_type,GREATEST(0,p_dano+COALESCE(p_sneak_attack_damage,0)+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'damage')+CASE WHEN p_attack_type='atk-corpo' THEN FLOOR((v_str_score+priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_character_id),'strength')-10)::numeric/2)::integer-FLOOR((v_str_score-10)::numeric/2)::integer ELSE 0 END));
 v_new_hp:=GREATEST(0,LEAST(v_max_hp,v_hp-v_damage_final)); v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
 v_scene:=v_scene||jsonb_build_object('tokens',jsonb_set(v_tokens,ARRAY[(v_target_index-1)::TEXT],v_target,FALSE)); UPDATE public.campaigns SET cba_data=v_scene WHERE id=p_campaign_id;
 RETURN jsonb_build_object('cba_data',v_scene,'hp',v_new_hp,'max_hp',v_max_hp,'ca',v_ca,'attack_total',v_attack_total,'damage',v_damage_final,'damage_roll',p_dano,'attack_effect_modifier',v_effective_attack_modifier,'target_ac_modifier',v_effective_ac_modifier);
END; $function$
;
REVOKE ALL ON FUNCTION public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer,integer,integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.aplicar_dano_token_ataque_srd_v2(bigint,text,text,integer,integer,integer,text,text,integer,integer,integer) TO authenticated;
