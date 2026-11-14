ALTER TABLE priv.srd_pending_spell_resolutions ALTER COLUMN save_type DROP NOT NULL;
ALTER TABLE priv.srd_pending_spell_resolutions ALTER COLUMN save_dc DROP NOT NULL;
CREATE OR REPLACE FUNCTION public.conjurar_magia_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text DEFAULT NULL::text, p_roll_results integer[] DEFAULT NULL::integer[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_doc jsonb; v_class text; v_level integer; v_score integer;
  v_state jsonb; v_known jsonb; v_prepared jsonb; v_usos jsonb; v_spell record;
  v_domain_prepared jsonb; v_domain_idx integer; v_domain_circle integer; v_domain_id text;
  v_class_access boolean := false; v_domain_access boolean := false; v_domain_slot_used boolean := false;
  v_circle integer; v_use_count integer; v_capacity integer; v_idx integer; v_new_prepared jsonb;
  v_campaign_id public.characters.campaign_id%TYPE; v_caster_name text;
  v_cba_data jsonb; v_tokens jsonb; v_token jsonb; v_token_index bigint; v_token_count integer;
  v_target_type text; v_target_name text; v_target_key text; v_target_character_id text;
  v_target_hp integer; v_target_max_hp integer; v_healing integer := 0;
  v_roll integer := 0; v_die_count integer; v_die_size integer; v_dice text;
  v_per_level integer := 0; v_max_level integer := 0; v_level_bonus integer;
  v_slot_total integer; v_slots_remaining integer;
  v_effect_target_kind text; v_effect_target_id text; v_effect_target_user_id uuid;
  v_engine_rule jsonb; v_effect_data jsonb; v_pending_id uuid; v_condition_id text; v_save_type text; v_save_dc integer; v_duration_rounds integer; v_effect_instance bigint; v_effect_kind text; v_scale jsonb; v_scaled_value integer;
  v_damage integer:=0; v_damage_expression text; v_damage_scale jsonb; v_damage_dice_count integer; v_damage_flat integer:=0; v_damage_type text; v_sr integer:=0; v_spell_resistance boolean:=false; v_willing_target boolean:=false; v_pending_type text; v_resolution jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  SELECT c.campaign_id,c.nome INTO v_campaign_id,v_caster_name
    FROM public.characters c
   WHERE c.id::text=p_character_id AND c.user_id=auth.uid()
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização'; END IF;
  IF v_campaign_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM public.members m WHERE m.campaign_id=v_campaign_id AND m.user_id=auth.uid()
    UNION ALL SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND c.owner_id=auth.uid()
  ) THEN RAISE EXCEPTION 'O personagem não pertence a uma campanha da qual você participa'; END IF;

  IF priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'no_actions') OR priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'cannot_cast') THEN RAISE EXCEPTION 'A condição atual impede conjurar magias.'; END IF;
  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s
    WHERE s.character_id::text=p_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;
  v_doc:=to_jsonb(v_sheet);
  SELECT public._srd35_class_key(cl.nome) INTO v_class
    FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD da ficha não encontrada ou incompatível'; END IF;
  v_level:=v_sheet.nivel;
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível de classe ausente ou inválido'; END IF;
  v_score:=CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(v_doc,ARRAY['INT','inteligencia','intelligence','int_score','score_inteligencia'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(v_doc,ARRAY['CAR','carisma','charisma','cha','cha_score','score_carisma'])::integer
    ELSE public._srd35_attr(v_doc,ARRAY['SAB','sabedoria','wisdom','wis','wis_score','score_sabedoria'])::integer END;
  v_score:=v_score+priv.srd_effective_modifier(v_campaign_id,'character',p_character_id,CASE v_class WHEN 'wizard' THEN 'intelligence' WHEN 'sorcerer' THEN 'charisma' WHEN 'bard' THEN 'charisma' WHEN 'paladin' THEN 'charisma' ELSE 'wisdom' END);
  IF v_score IS NULL OR v_score < 1 THEN RAISE EXCEPTION 'Atributo-chave ausente ou inválido'; END IF;
  IF p_slot_level IS NULL OR p_slot_level NOT BETWEEN 0 AND 9 THEN RAISE EXCEPTION 'slot_level deve estar entre 0 e 9'; END IF;
  SELECT id,circulo,classes,dados_tecnicos INTO v_spell FROM public.srd_spells WHERE id=p_spell_id;
  IF NOT FOUND OR v_spell.circulo NOT BETWEEN 0 AND 9 THEN
    RAISE EXCEPTION 'Magia inexistente ou nível inválido';
  END IF;
  v_class_access:=public._srd35_spell_class_ok(v_spell.classes,v_class);
  IF v_class='cleric' THEN
    SELECT ds.domain_id,ds.spell_level INTO v_domain_id,v_domain_circle
      FROM public.srd_character_domain_choices choice
      JOIN public.srd_domain_spells ds USING (domain_id)
     WHERE choice.character_id::text=p_character_id AND ds.spell_id=v_spell.id
       AND ds.spell_level=p_slot_level
     ORDER BY choice.domain_slot LIMIT 1;
    v_domain_access:=FOUND;
  END IF;
  IF NOT v_class_access AND NOT v_domain_access THEN
    RAISE EXCEPTION 'Magia inexistente ou não disponível pela classe/domínio escolhido';
  END IF;
  v_circle:=CASE WHEN v_class_access THEN v_spell.circulo ELSE v_domain_circle END;
  IF v_class_access AND
     (coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_spell.circulo)::integer
                  FROM public.srd_spell_progressions WHERE class_key=v_class),0)>0
      AND v_score>=10+v_spell.circulo) THEN
    v_class_access:=true;
  ELSE
    v_class_access:=false;
  END IF;
  IF v_domain_access AND
     (coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_domain_circle)::integer
                  FROM public.srd_spell_progressions WHERE class_key='cleric'),0)>0
      AND v_score>=10+v_domain_circle) THEN
    v_domain_access:=true;
  ELSE
    v_domain_access:=false;
  END IF;
  IF NOT v_class_access AND NOT v_domain_access THEN
    RAISE EXCEPTION 'Nível de magia, espaço de domínio ou atributo insuficiente';
  END IF;
  v_circle:=CASE WHEN v_class_access THEN v_spell.circulo ELSE v_domain_circle END;
  IF v_class='sorcerer' AND p_slot_level<>v_circle THEN RAISE EXCEPTION 'Feiticeiro conjura a magia no próprio círculo'; END IF;
  IF v_class<>'sorcerer' AND p_slot_level<v_circle AND NOT v_domain_access THEN RAISE EXCEPTION 'Espaço menor que o círculo da magia'; END IF;

  v_state:=coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  v_known:=coalesce(v_state->'conhecidas','[]'::jsonb);
  v_prepared:=coalesce(v_state->'preparadas','[]'::jsonb);
  v_usos:=coalesce(v_state->'usos','{}'::jsonb);
  v_domain_prepared:=coalesce(v_state->'dominio_preparadas','[]'::jsonb);
  IF v_class='sorcerer' THEN
    IF NOT (v_known ? p_spell_id) THEN RAISE EXCEPTION 'Feiticeiro só pode conjurar magias conhecidas'; END IF;
    v_capacity:=public._srd35_slots(v_class,v_level,v_score,v_circle);
    v_use_count:=coalesce((v_usos->>v_circle::text)::integer,0);
    IF v_use_count>=v_capacity THEN RAISE EXCEPTION 'Sem usos diários restantes para este círculo'; END IF;
    v_usos:=jsonb_set(v_usos,ARRAY[v_circle::text],to_jsonb(v_use_count+1),true);
    v_slot_total:=v_capacity; v_slots_remaining:=v_capacity-v_use_count-1;
  ELSE
    IF v_class='cleric' AND v_domain_access THEN
      SELECT (ord-1)::integer INTO v_domain_idx
        FROM jsonb_array_elements(v_domain_prepared) WITH ORDINALITY e(value,ord)
       WHERE value->>'spell_id'=p_spell_id AND value->>'domain_id'=v_domain_id
         AND (value->>'slot_level')::integer=p_slot_level
         AND coalesce((value->>'expended')::boolean,false)=false
       ORDER BY ord LIMIT 1;
    END IF;
    IF v_domain_idx IS NOT NULL THEN
      v_domain_prepared:=jsonb_set(v_domain_prepared,ARRAY[v_domain_idx::text,'expended'],'true'::jsonb,true);
      v_domain_slot_used:=true; v_slot_total:=1; v_slots_remaining:=0;
    ELSE
      IF NOT v_class_access THEN RAISE EXCEPTION 'Espaço de domínio não preparado ou já gasto'; END IF;
      SELECT (ord-1)::integer INTO v_idx FROM jsonb_array_elements(v_prepared) WITH ORDINALITY e(value,ord)
        WHERE value->>'spell_id'=p_spell_id AND (value->>'slot_level')::integer=p_slot_level
          AND coalesce((value->>'expended')::boolean,false)=false ORDER BY ord LIMIT 1;
      IF v_idx IS NULL THEN RAISE EXCEPTION 'Nenhum espaço preparado disponível para essa magia e círculo'; END IF;
      v_prepared:=jsonb_set(v_prepared,ARRAY[v_idx::text,'expended'],'true'::jsonb,true);
      v_slot_total:=public._srd35_slots(v_class,v_level,v_score,p_slot_level);
      SELECT count(*)::integer INTO v_slots_remaining FROM jsonb_array_elements(v_prepared) e(value)
        WHERE (value->>'slot_level')::integer=p_slot_level AND coalesce((value->>'expended')::boolean,false)=false;
    END IF;
  END IF;

  v_target_key:=NULLIF(btrim(p_target_token_key),'');
  IF v_target_key IS NOT NULL AND v_campaign_id IS NULL THEN
    RAISE EXCEPTION 'Um alvo por token exige que o conjurador esteja em uma campanha';
  END IF;
  IF v_target_key IS NOT NULL THEN
    IF coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')='cura' THEN
      SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
    ELSE
      SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id;
    END IF;
    IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do conjurador não encontrada'; END IF;
    v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
    SELECT count(*)::integer,min(e.ordinality),min(e.token->>'nome')
      INTO v_token_count,v_token_index,v_target_name
      FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
      WHERE e.token->>'key'=v_target_key;
    IF v_token_count<>1 THEN RAISE EXCEPTION 'Token-alvo não encontrado ou duplicado nesta campanha'; END IF;
    v_token:=v_tokens->(v_token_index::integer-1);
    v_target_type:=v_token->>'tipo';
    IF v_target_type IS NULL OR v_target_type NOT IN ('player','npc','monstro') THEN RAISE EXCEPTION 'Tipo do token-alvo inválido'; END IF;
  ELSIF coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')='cura' THEN
    v_target_type:='player'; v_target_name:=v_caster_name; v_target_character_id:=p_character_id;
    IF v_campaign_id IS NOT NULL THEN
      SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
      IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do conjurador não encontrada'; END IF;
      v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
    END IF;
  END IF;

  IF coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')='cura' THEN
    v_target_character_id:=CASE WHEN v_target_key IS NULL THEN p_character_id ELSE NULL END;
    IF v_target_key IS NOT NULL AND v_target_type='player' THEN
      v_target_character_id:=v_token->>'id';
      IF NOT EXISTS (
        SELECT 1 FROM public.characters ch
        JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER'
        WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
      ) THEN RAISE EXCEPTION 'O token player não corresponde a um personagem jogador desta campanha'; END IF;
    END IF;
    v_dice:=coalesce(v_spell.dados_tecnicos->'cura'->>'dados','');
    IF v_dice ~ '^[0-9]+d[0-9]+([+-][0-9]+)?$' THEN
      v_die_count:=split_part(v_dice,'d',1)::integer;
      v_die_size:=regexp_replace(split_part(v_dice,'d',2),'[+-].*$','')::integer;
      IF v_die_count<1 OR v_die_count>100 OR v_die_size<2 OR v_die_size>100000 THEN RAISE EXCEPTION 'Dados de cura inválidos'; END IF;
      IF p_roll_results IS NULL OR cardinality(p_roll_results)<>v_die_count
         OR EXISTS(SELECT 1 FROM unnest(p_roll_results) value WHERE value<1 OR value>v_die_size) THEN
        RAISE EXCEPTION 'A cura exige exatamente % resultado(s) manual(is) de d%.',v_die_count,v_die_size;
      END IF;
      SELECT coalesce(sum(value),0) INTO v_roll FROM unnest(p_roll_results) value;
      IF substring(v_dice from '([+-][0-9]+)$') IS NOT NULL THEN
        v_roll:=v_roll+substring(v_dice from '([+-][0-9]+)$')::integer;
      END IF;
    ELSIF v_dice ~ '^[0-9]+$' THEN
      IF p_roll_results IS NOT NULL AND cardinality(p_roll_results)>0 THEN RAISE EXCEPTION 'Esta cura não exige dados adicionais.'; END IF;
      v_roll:=v_dice::integer;
    ELSE
      RAISE EXCEPTION 'Expressão de cura inválida na magia';
    END IF;
    IF coalesce(v_spell.dados_tecnicos->'cura'->>'por_nivel','0') !~ '^-?[0-9]+$'
       OR coalesce(v_spell.dados_tecnicos->'cura'->>'max_nivel','0') !~ '^-?[0-9]+$' THEN
      RAISE EXCEPTION 'Parâmetros por_nivel/max_nivel inválidos na cura';
    END IF;
    v_per_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'por_nivel')::integer,0);
    v_max_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'max_nivel')::integer,0);
    IF v_per_level<0 OR v_max_level<0 THEN RAISE EXCEPTION 'Parâmetros de cura não podem ser negativos'; END IF;
    v_level_bonus:=CASE WHEN v_max_level>0 THEN least(v_level,v_max_level) ELSE v_level END;
    v_healing:=greatest(0,v_roll+v_per_level*v_level_bonus);
    IF v_target_character_id IS NOT NULL THEN
      v_healing:=GREATEST(0,v_healing+priv.srd_effective_modifier(v_campaign_id,'character',v_target_character_id,'healing_received'));
    ELSIF v_target_key IS NOT NULL THEN
      v_healing:=GREATEST(0,v_healing+priv.srd_effective_modifier(v_campaign_id,'token',v_target_key,'healing_received'));
    END IF;

    IF v_target_type='player' THEN
      IF v_target_key IS NULL THEN
        v_target_hp:=v_sheet.pv_atual; v_target_max_hp:=v_sheet.pv_max;
        IF v_target_max_hp IS NULL OR v_target_max_hp<0 THEN RAISE EXCEPTION 'PV máximo válido ausente na ficha do conjurador'; END IF;
        IF v_target_character_id IS NOT NULL AND priv.srd_condition_has_flag(v_campaign_id,'character',v_target_character_id,'no_healing') THEN v_healing:=0; END IF;
IF v_target_key IS NOT NULL AND v_target_character_id IS NULL AND priv.srd_condition_has_flag(v_campaign_id,'token',v_target_key,'no_healing') THEN v_healing:=0; END IF;
IF COALESCE(v_target_hp,0)<=-10 THEN v_healing:=0; END IF;
v_target_hp:=CASE WHEN COALESCE(v_target_hp,0)<=-10 THEN COALESCE(v_target_hp,0) ELSE LEAST(v_target_max_hp,COALESCE(v_target_hp,0)+v_healing) END;
        UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=p_character_id;
        PERFORM priv.srd_sync_character_vital_condition(p_character_id,v_target_hp,v_healing>0);
      ELSE
        SELECT sh.pv_atual,sh.pv_max,ch.id::text,coalesce(ch.nome,'Aventureiro')
          INTO v_target_hp,v_target_max_hp,v_target_character_id,v_target_name
          FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id::text=ch.id::text
         WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
         FOR UPDATE OF ch,sh;
        IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do alvo player não encontrada nesta campanha'; END IF;
        IF v_target_max_hp IS NULL OR v_target_max_hp<0 THEN RAISE EXCEPTION 'PV máximo válido ausente na ficha do alvo'; END IF;
        IF v_target_character_id IS NOT NULL AND priv.srd_condition_has_flag(v_campaign_id,'character',v_target_character_id,'no_healing') THEN v_healing:=0; END IF;
IF v_target_key IS NOT NULL AND v_target_character_id IS NULL AND priv.srd_condition_has_flag(v_campaign_id,'token',v_target_key,'no_healing') THEN v_healing:=0; END IF;
IF COALESCE(v_target_hp,0)<=-10 THEN v_healing:=0; END IF;
v_target_hp:=CASE WHEN COALESCE(v_target_hp,0)<=-10 THEN COALESCE(v_target_hp,0) ELSE LEAST(v_target_max_hp,COALESCE(v_target_hp,0)+v_healing) END;
        UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=v_target_character_id;
        PERFORM priv.srd_sync_character_vital_condition(v_target_character_id,v_target_hp,v_healing>0);
      END IF;
      IF v_campaign_id IS NOT NULL THEN
        IF v_tokens IS NULL THEN
          v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
        END IF;
        SELECT count(*)::integer,min(e.ordinality) INTO v_token_count,v_token_index
          FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
         WHERE e.token->>'id'=v_target_character_id AND e.token->>'tipo'='player';
        IF v_target_key IS NOT NULL AND v_token_count<>1 THEN RAISE EXCEPTION 'Token player do alvo ausente ou duplicado na cena'; END IF;
        IF v_token_count>1 THEN RAISE EXCEPTION 'Há tokens player duplicados para o personagem-alvo'; END IF;
        IF v_token_count=1 THEN
          v_token:=v_tokens->(v_token_index::integer-1);
          v_token:=v_token||jsonb_build_object('hp',v_target_hp,'maxHp',v_target_max_hp);
          v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
          v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
          UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;
        END IF;
      END IF;
    ELSE
      IF coalesce(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN
        RAISE EXCEPTION 'O token NPC/monstro precisa de maxHp válido para receber cura';
      END IF;
      v_target_max_hp:=(v_token->>'maxHp')::integer;
      IF v_target_max_hp>100000 THEN RAISE EXCEPTION 'maxHp do token excede o limite aceito'; END IF;
      v_target_hp:=CASE WHEN coalesce(v_token->>'hp','') ~ '^[0-9]{1,6}$' THEN (v_token->>'hp')::integer ELSE v_target_max_hp END;
      v_target_hp:=least(v_target_max_hp,greatest(0,v_target_hp+v_healing));
      v_token:=v_token||jsonb_build_object('hp',v_target_hp,'maxHp',v_target_max_hp);
      v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
      v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
      UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;
    END IF;
  END IF;


  IF v_campaign_id IS NOT NULL AND EXISTS(SELECT 1 FROM public.srd_spell_effects se WHERE se.spell_id=v_spell.id AND se.verification_status='verified_srd' AND se.parameters ? 'engine_rule') THEN
    SELECT se.parameters->'engine_rule' INTO v_engine_rule
    FROM public.srd_spell_effects se
    WHERE se.spell_id=v_spell.id AND se.verification_status='verified_srd'
    ORDER BY se.effect_index LIMIT 1;
    IF v_engine_rule IS NULL THEN RAISE EXCEPTION 'A regra automática desta magia não está validada.'; END IF;
    IF v_engine_rule->>'target_scope'='self_only' AND v_target_key IS NOT NULL THEN
      RAISE EXCEPTION 'Esta magia só pode ser aplicada automaticamente ao próprio conjurador nesta versão.';
    END IF;
    IF v_target_key IS NULL THEN
      v_effect_target_kind:='character'; v_effect_target_id:=p_character_id;
      v_target_character_id:=p_character_id; v_target_type:='player'; v_target_name:=v_caster_name;
    ELSIF v_target_type='player' THEN
      v_effect_target_kind:='character'; v_target_character_id:=v_token->>'id'; v_effect_target_id:=v_target_character_id;
    ELSE
      v_effect_target_kind:='token'; v_effect_target_id:=v_target_key;
    END IF;
    IF v_effect_target_kind='character' THEN
      SELECT ch.user_id INTO v_effect_target_user_id FROM public.characters ch
      WHERE ch.id::text=v_effect_target_id AND ch.campaign_id=v_campaign_id;
      IF NOT FOUND THEN RAISE EXCEPTION 'Personagem-alvo não pertence à campanha.'; END IF;
    END IF;
    v_effect_data:=COALESCE(v_engine_rule->'effect_data','{}'::jsonb);
    v_effect_kind:=COALESCE(v_engine_rule->>'effect_kind',CASE v_engine_rule->>'resolver' WHEN 'debuff' THEN 'debuff' ELSE 'buff' END);
    v_save_type:=NULLIF(v_engine_rule->>'save_type','');
    v_condition_id:=CASE
      WHEN v_spell.id='srd35_spell_blindness_deafness' AND p_roll_results IS NOT NULL AND p_roll_results[1]=2 THEN 'deafened'
      ELSE NULLIF(v_engine_rule->>'condition_id','') END;
    v_duration_rounds:=CASE
      WHEN v_engine_rule ? 'duration_rounds_per_caster_level' THEN v_level*(v_engine_rule->>'duration_rounds_per_caster_level')::integer
      WHEN v_engine_rule ? 'duration_rounds' THEN (v_engine_rule->>'duration_rounds')::integer
      ELSE NULL END;

    v_scale:=v_engine_rule->'level_scale';
    IF v_scale IS NOT NULL AND jsonb_typeof(v_scale)='object' AND jsonb_typeof(v_effect_data->'modifiers')='array' THEN
      v_scaled_value:=COALESCE((v_scale->>'base')::integer,0)
        +GREATEST(0,FLOOR((v_level-COALESCE((v_scale->>'start_level')::integer,1))::numeric/GREATEST(1,COALESCE((v_scale->>'every_levels')::integer,1)))::integer);
      IF v_scale ? 'cap' THEN v_scaled_value:=LEAST(v_scaled_value,(v_scale->>'cap')::integer); END IF;
      v_effect_data:=jsonb_set(v_effect_data,'{modifiers,0,value}',to_jsonb(v_scaled_value),true);
    END IF;

    v_willing_target:=COALESCE((v_engine_rule->>'willing_target')::boolean,false);
    v_spell_resistance:=COALESCE((v_engine_rule->>'spell_resistance')::boolean,false) AND NOT v_willing_target;

    IF v_engine_rule->>'resolver'='damage' THEN
      IF v_target_key IS NULL THEN RAISE EXCEPTION 'Esta magia exige um alvo selecionado.'; END IF;
      IF v_engine_rule->>'target_filter'='plant_creature' THEN
        IF v_target_type NOT IN ('npc','monstro')
           OR lower(COALESCE(v_token->'monsterStats'->>'type',v_token->'monsterStats'->>'tipo','')) NOT LIKE '%plant%' THEN
          RAISE EXCEPTION 'Esta magia só afeta criaturas do tipo Planta; o alvo selecionado não corresponde.';
        END IF;
      END IF;

      v_damage_expression:=COALESCE(v_engine_rule->>'damage_expression',v_effect_data->>'damage_expression');
      IF COALESCE(v_damage_expression,'') !~ '^[0-9]{1,3}d(2|3|4|6|8|10|12|20|100)([+-][0-9]{1,5})?$' THEN
        RAISE EXCEPTION 'Expressão de dano automática inválida para esta magia.';
      END IF;
      v_die_count:=split_part(v_damage_expression,'d',1)::integer;
      v_die_size:=regexp_replace(split_part(v_damage_expression,'d',2),'[+-].*$','')::integer;
      v_damage_flat:=COALESCE(substring(v_damage_expression from '([+-][0-9]+)$')::integer,0);
      v_damage_dice_count:=v_die_count;
      v_damage_scale:=v_engine_rule->'damage_scaling';
      IF v_damage_scale IS NOT NULL AND jsonb_typeof(v_damage_scale)='object' THEN
        v_damage_dice_count:=COALESCE((v_damage_scale->>'base_dice')::integer,v_die_count)
          +GREATEST(0,FLOOR((v_level-COALESCE((v_damage_scale->>'start_level')::integer,1))::numeric
          /GREATEST(1,COALESCE((v_damage_scale->>'every_levels')::integer,1)))::integer)
          *COALESCE((v_damage_scale->>'dice_per_level')::integer,0);
        IF v_damage_scale ? 'cap_dice' THEN v_damage_dice_count:=LEAST(v_damage_dice_count,(v_damage_scale->>'cap_dice')::integer); END IF;
      END IF;
      IF v_damage_dice_count<1 OR v_damage_dice_count>100 THEN RAISE EXCEPTION 'Quantidade de dados de dano fora do limite.'; END IF;
      IF p_roll_results IS NULL OR cardinality(p_roll_results)<>v_damage_dice_count
         OR EXISTS(SELECT 1 FROM unnest(p_roll_results) value WHERE value<1 OR value>v_die_size) THEN
        RAISE EXCEPTION 'Esta magia exige exatamente % resultado(s) manual(is) de d%.',v_damage_dice_count,v_die_size;
      END IF;
      SELECT COALESCE(SUM(value),0) INTO v_roll FROM unnest(p_roll_results) value;
      v_damage:=GREATEST(0,v_roll+v_damage_flat);
      v_damage_type:=COALESCE(NULLIF(v_engine_rule->>'damage_type',''),'untyped');
      IF v_damage_type !~ '^[a-z_]{1,24}$' THEN RAISE EXCEPTION 'Tipo de dano inválido.'; END IF;
      v_effect_data:=v_effect_data||jsonb_build_object(
        'damage',v_damage,'damage_type',v_damage_type,
        'save_result',COALESCE(v_engine_rule->>'save_result','none'),
        'damage_expression',v_damage_dice_count::text||'d'||v_die_size
      );
      v_effect_kind:='damage';
      v_save_type:=NULLIF(v_engine_rule->>'save_type','');
      v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_spell.circulo+FLOOR((v_score-10)::numeric/2)::integer ELSE NULL END;
      v_sr:=CASE WHEN v_spell_resistance THEN priv.srd_spell_resistance_value(v_campaign_id,v_effect_target_kind,v_effect_target_id) ELSE 0 END;

      INSERT INTO priv.srd_pending_spell_resolutions(
        campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
        save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level,status
      ) VALUES (
        v_campaign_id,p_character_id,v_effect_target_kind,v_effect_target_id,v_effect_target_user_id,v_spell.id,
        v_save_type,v_save_dc,NULL,v_duration_rounds,v_effect_data,'damage',v_spell_resistance,v_level,
        CASE WHEN v_sr>0 THEN 'awaiting_spell_resistance' ELSE 'pending_save' END
      ) RETURNING pending_id INTO v_pending_id;

      IF v_sr>0 THEN
        v_pending_type:='spell_resistance';
        INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
        VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
          'tipo','Penetração de Resistência à Magia (D20)',
          'alvos',jsonb_build_array(p_character_id),'npc_alvos','[]'::jsonb,
          'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
          'resolution_type','spell_resistance','pending_id',v_pending_id,'spell_id',v_spell.id,
          'spell_resistance',v_sr,'caster_level',v_level
        ));
      ELSIF v_save_type IS NOT NULL THEN
        v_pending_type:='spell_save';
        INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
        VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
          'tipo','Resistência de '||CASE v_save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
          'alvos',CASE WHEN v_effect_target_kind='character' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'npc_alvos',CASE WHEN v_effect_target_kind='token' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
          'resolution_type','spell_save','pending_id',v_pending_id,'spell_id',v_spell.id,'save_type',v_save_type,'save_dc',v_save_dc
        ));
      ELSE
        v_resolution:=priv.srd_apply_pending_spell_resolution(v_pending_id);
        v_damage:=COALESCE((v_resolution->>'damage')::integer,0);
        v_target_hp:=NULLIF(v_resolution->>'pv_atual','')::integer;
        v_target_max_hp:=NULLIF(v_resolution->>'pv_max','')::integer;
        v_target_name:=COALESCE(v_resolution->>'target_name',v_target_name);
        SELECT cba_data INTO v_cba_data FROM public.campaigns WHERE id=v_campaign_id;
      END IF;
    ELSE
      IF v_willing_target THEN v_save_type:=NULL; END IF;
      v_sr:=CASE WHEN v_spell_resistance THEN priv.srd_spell_resistance_value(v_campaign_id,v_effect_target_kind,v_effect_target_id) ELSE 0 END;
      IF v_sr>0 THEN
        v_pending_type:='spell_resistance';
        v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_spell.circulo+FLOOR((v_score-10)::numeric/2)::integer ELSE NULL END;
        INSERT INTO priv.srd_pending_spell_resolutions(
          campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
          save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level,status
        ) VALUES(
          v_campaign_id,p_character_id,v_effect_target_kind,v_effect_target_id,v_effect_target_user_id,v_spell.id,
          v_save_type,v_save_dc,v_condition_id,v_duration_rounds,v_effect_data,v_effect_kind,true,v_level,'awaiting_spell_resistance'
        ) RETURNING pending_id INTO v_pending_id;
        INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
        VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
          'tipo','Penetração de Resistência à Magia (D20)','alvos',jsonb_build_array(p_character_id),'npc_alvos','[]'::jsonb,
          'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
          'resolution_type','spell_resistance','pending_id',v_pending_id,'spell_id',v_spell.id,
          'spell_resistance',v_sr,'caster_level',v_level
        ));
      ELSIF v_engine_rule->>'resolver'='buff' OR (v_engine_rule->>'resolver'='debuff' AND v_save_type IS NULL) THEN
        v_effect_instance:=priv.srd_apply_campaign_effect(v_campaign_id,v_effect_target_kind,v_effect_target_id,v_effect_kind,
          v_effect_data,v_duration_rounds,v_spell.id,NULL);
      ELSIF v_engine_rule->>'resolver'='condition' AND v_save_type IS NULL THEN
        v_effect_instance:=priv.srd_apply_campaign_condition(v_campaign_id,v_effect_target_kind,v_effect_target_id,
          v_condition_id,v_duration_rounds,jsonb_build_object('source_spell_id',v_spell.id,'caster_character_id',p_character_id),v_spell.id);
      ELSE
        IF v_save_type IS NULL THEN RAISE EXCEPTION 'A regra automática da magia não possui uma resistência válida.'; END IF;
        v_save_dc:=10+v_spell.circulo+FLOOR((v_score-10)::numeric/2)::integer;
        v_pending_type:='spell_save';
        INSERT INTO priv.srd_pending_spell_resolutions(
          campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
          save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level,status
        ) VALUES(
          v_campaign_id,p_character_id,v_effect_target_kind,v_effect_target_id,v_effect_target_user_id,v_spell.id,
          v_save_type,v_save_dc,v_condition_id,v_duration_rounds,v_effect_data,v_effect_kind,false,v_level,'pending_save'
        ) RETURNING pending_id INTO v_pending_id;
        INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
        VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
          'tipo','Resistência de '||CASE v_save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
          'alvos',CASE WHEN v_effect_target_kind='character' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'npc_alvos',CASE WHEN v_effect_target_kind='token' THEN jsonb_build_array(v_effect_target_id) ELSE '[]'::jsonb END,
          'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
          'resolution_type','spell_save','pending_id',v_pending_id,'spell_id',v_spell.id,'save_type',v_save_type,'save_dc',v_save_dc
        ));
      END IF;
    END IF;
  END IF;

  v_state:=jsonb_build_object('version',1,'conhecidas',v_known,'preparadas',v_prepared,'dominio_preparadas',v_domain_prepared,'usos',v_usos);
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state WHERE character_id::text=p_character_id;
  RETURN jsonb_build_object(
    'estado',v_state,'healing',v_healing,'damage',v_damage,'pv_atual',v_target_hp,'pv_max',v_target_max_hp,'cba_data',v_cba_data,
    'target_name',v_target_name,'target_token_key',v_target_key,
    'slot_level',p_slot_level,'slots_remaining',v_slots_remaining,'slots_total',v_slot_total,
    'domain_slot_used',v_domain_slot_used,'domain_id',CASE WHEN v_domain_slot_used THEN v_domain_id ELSE NULL END,'pending_resolution_id',v_pending_id,'pending_resolution_type',v_pending_type,'effect_instance_id',v_effect_instance
  );
END
$function$
;
CREATE OR REPLACE FUNCTION public.srd_resolve_pending_spell_save(p_pending_id uuid, p_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE v_pending priv.srd_pending_spell_resolutions%ROWTYPE; v_user_id uuid; v_bonus integer; v_total integer; v_sr integer; v_caster_user uuid; v_round integer;
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
  v_bonus:=priv.srd_saving_throw_bonus(v_pending.campaign_id,v_pending.target_kind,v_pending.target_id,v_pending.save_type,
    CASE WHEN v_pending.spell_id='srd35_spell_bane' THEN 'fear' ELSE NULL END);
  v_total:=p_d20+v_bonus;

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
    IF v_pending.effect_kind='damage' AND v_pending.effect_data->>'save_result'='half' THEN
      UPDATE priv.srd_pending_spell_resolutions
         SET effect_data=jsonb_set(effect_data,'{damage}',
           to_jsonb(GREATEST(0,FLOOR(COALESCE(NULLIF(effect_data->>'damage','')::numeric,0)/2)::integer)),true)
       WHERE pending_id=p_pending_id;
      RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)
        ||jsonb_build_object('saved',true,'save_total',v_total,'save_bonus',v_bonus,'save_dc',v_pending.save_dc,'save_result','half');
    END IF;
    UPDATE priv.srd_pending_spell_resolutions SET status='saved',resolved_at=now() WHERE pending_id=p_pending_id;
    RETURN jsonb_build_object('pending_id',p_pending_id,'saved',true,'total',v_total,'bonus',v_bonus,'dc',v_pending.save_dc,'status','saved');
  END IF;
  RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)
    || jsonb_build_object('saved',false,'save_total',v_total,'save_bonus',v_bonus,'save_dc',v_pending.save_dc);
END;
$function$
;
CREATE OR REPLACE FUNCTION public.srd_resolve_pending_spell_resistance(p_pending_id uuid, p_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE v_pending priv.srd_pending_spell_resolutions%ROWTYPE; v_user uuid; v_sr integer; v_total integer;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_d20 IS NULL OR p_d20 NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'A penetração exige uma rolagem manual de D20.'; END IF;
  SELECT * INTO v_pending FROM priv.srd_pending_spell_resolutions WHERE pending_id=p_pending_id FOR UPDATE;
  IF NOT FOUND OR v_pending.status<>'awaiting_spell_resistance' OR v_pending.expires_at<now() THEN RAISE EXCEPTION 'Pedido de resistência à magia inválido ou expirado.'; END IF;
  SELECT user_id INTO v_user FROM public.characters WHERE id::text=v_pending.caster_character_id AND campaign_id=v_pending.campaign_id;
  IF v_user IS DISTINCT FROM auth.uid() AND public.my_role(v_pending.campaign_id) IS DISTINCT FROM 'GM'
     AND NOT EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=v_pending.campaign_id AND c.owner_id=auth.uid()) THEN
    RAISE EXCEPTION 'Somente o conjurador ou o Mestre pode registrar a penetração.';
  END IF;
  v_sr:=priv.srd_spell_resistance_value(v_pending.campaign_id,v_pending.target_kind,v_pending.target_id);
  v_total:=p_d20+v_pending.caster_level;
  IF v_total<v_sr THEN
    UPDATE priv.srd_pending_spell_resolutions SET status='resisted',resolved_at=now() WHERE pending_id=p_pending_id;
    RETURN jsonb_build_object('pending_id',p_pending_id,'status','resisted','total',v_total,'spell_resistance',v_sr);
  END IF;
  IF v_pending.save_type IS NOT NULL THEN
    UPDATE priv.srd_pending_spell_resolutions SET status='pending_save' WHERE pending_id=p_pending_id;
    INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
    VALUES(v_pending.campaign_id,'test_request','PUBLIC',jsonb_build_object(
      'tipo','Resistência de '||CASE v_pending.save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
      'alvos',CASE WHEN v_pending.target_kind='character' THEN jsonb_build_array(v_pending.target_id) ELSE '[]'::jsonb END,
      'npc_alvos',CASE WHEN v_pending.target_kind='token' THEN jsonb_build_array(v_pending.target_id) ELSE '[]'::jsonb END,
      'mestre','Sistema','mestre_id',auth.uid(),'request_id',p_pending_id::text,
      'resolution_type','spell_save','pending_id',p_pending_id,'spell_id',v_pending.spell_id,
      'save_type',v_pending.save_type,'save_dc',v_pending.save_dc
    ));
    RETURN jsonb_build_object('pending_id',p_pending_id,'status','penetrated','requires_save',true,
      'total',v_total,'spell_resistance',v_sr,'save_type',v_pending.save_type,'save_dc',v_pending.save_dc);
  END IF;
  RETURN priv.srd_apply_pending_spell_resolution(p_pending_id)||jsonb_build_object('status','penetrated','total',v_total,'spell_resistance',v_sr);
END;
$function$
;
