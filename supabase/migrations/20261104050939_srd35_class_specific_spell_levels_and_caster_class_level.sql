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
  v_circle integer; v_spell_level integer; v_use_count integer; v_capacity integer; v_idx integer; v_new_prepared jsonb;
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
  v_level:=public._srd35_character_class_level(p_character_id,v_class,v_sheet.classe_id,v_sheet.nivel);
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível de conjurador ausente ou inválido para a classe.'; END IF;
  v_score:=CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(v_doc,ARRAY['INT','inteligencia','intelligence','int_score','score_inteligencia'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(v_doc,ARRAY['CAR','carisma','charisma','cha','cha_score','score_carisma'])::integer
    ELSE public._srd35_attr(v_doc,ARRAY['SAB','sabedoria','wisdom','wis','wis_score','score_sabedoria'])::integer END;
  v_score:=v_score+priv.srd_effective_modifier(v_campaign_id,'character',p_character_id,CASE v_class WHEN 'wizard' THEN 'intelligence' WHEN 'sorcerer' THEN 'charisma' WHEN 'bard' THEN 'charisma' WHEN 'paladin' THEN 'charisma' ELSE 'wisdom' END);
  IF v_score IS NULL OR v_score < 1 THEN RAISE EXCEPTION 'Atributo-chave ausente ou inválido'; END IF;
  IF p_slot_level IS NULL OR p_slot_level NOT BETWEEN 0 AND 9 THEN RAISE EXCEPTION 'slot_level deve estar entre 0 e 9'; END IF;
  SELECT id,circulo,classes,dados_tecnicos,nivel INTO v_spell FROM public.srd_spells WHERE id=p_spell_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Magia inexistente ou nível inválido'; END IF;
  v_spell_level:=public._srd35_spell_level_for_class(v_spell.nivel,v_class,v_spell_level);
  IF v_spell_level NOT BETWEEN 0 AND 9 THEN RAISE EXCEPTION 'Nível da magia incompatível com a classe.'; END IF;
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
  v_circle:=CASE WHEN v_class_access THEN v_spell_level ELSE v_domain_circle END;
  IF v_class_access AND
     (coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_spell_level)::integer
                  FROM public.srd_spell_progressions WHERE class_key=v_class),0)>0
      AND v_score>=10+v_circle) THEN
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
  v_circle:=CASE WHEN v_class_access THEN v_spell_level ELSE v_domain_circle END;
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
      v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_circle+FLOOR((v_score-10)::numeric/2)::integer ELSE NULL END;
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
        v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_circle+FLOOR((v_score-10)::numeric/2)::integer ELSE NULL END;
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
        v_save_dc:=10+v_circle+FLOOR((v_score-10)::numeric/2)::integer;
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
CREATE OR REPLACE FUNCTION public.conjurar_magia_efeitos_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id bigint; v_sheet public.srd_character_sheets%ROWTYPE; v_spell record;
  v_class text; v_level integer; v_spell_level integer; v_score integer; v_state jsonb; v_prepared jsonb;
  v_prepared_idx integer; v_slots_remaining integer; v_slot_total integer;
  v_cba_data jsonb; v_tokens jsonb; v_key text; v_token jsonb; v_target_type text;
  v_target_kind text; v_target_id text; v_target_user_id uuid; v_target_name text;
  v_engine_rule jsonb; v_effect_data jsonb; v_effect_kind text; v_save_type text;
  v_save_dc integer; v_condition_id text; v_duration_rounds integer; v_scale jsonb;
  v_scaled_value integer; v_pending_id uuid; v_effect_instance bigint;
  v_pending_ids jsonb:='[]'::jsonb; v_effect_ids jsonb:='[]'::jsonb; v_targets jsonb:='[]'::jsonb;
  v_willing_target boolean:=false; v_spell_resistance boolean:=false; v_sr integer:=0;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_target_token_keys IS NULL OR cardinality(p_target_token_keys) NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Selecione entre 1 e 20 alvos.'; END IF;
  IF EXISTS(SELECT 1 FROM (SELECT btrim(k) k,count(*) n FROM unnest(p_target_token_keys) k GROUP BY btrim(k)) x WHERE x.n>1 OR NULLIF(x.k,'') IS NULL) THEN
    RAISE EXCEPTION 'A lista de alvos contém identificadores vazios ou repetidos.';
  END IF;
  SELECT ch.campaign_id INTO v_campaign_id FROM public.characters ch
  WHERE ch.id::text=btrim(p_character_id) AND ch.user_id=auth.uid() FOR UPDATE;
  IF NOT FOUND OR v_campaign_id IS NULL THEN RAISE EXCEPTION 'Personagem não encontrado ou sem campanha autorizada.'; END IF;
  IF NOT EXISTS(SELECT 1 FROM public.members m WHERE m.campaign_id=v_campaign_id AND m.user_id=auth.uid()
    UNION ALL SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND c.owner_id=auth.uid()) THEN
    RAISE EXCEPTION 'O personagem não pertence a uma campanha da qual você participa.';
  END IF;

  IF priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'no_actions')
     OR priv.srd_condition_has_flag(v_campaign_id,'character',BTRIM(p_character_id),'cannot_cast') THEN
    RAISE EXCEPTION 'A condição atual impede conjurar magias.';
  END IF;  SELECT sh.* INTO v_sheet FROM public.srd_character_sheets sh WHERE sh.character_id::text=btrim(p_character_id) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada.'; END IF;
  SELECT public._srd35_class_key(cl.nome) INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD incompatível.'; END IF;
  v_level:=public._srd35_character_class_level(p_character_id,v_class,v_sheet.classe_id,v_sheet.nivel);
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível de conjurador inválido para a classe.'; END IF;
  v_score:=CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['INT','inteligencia','intelligence'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['CAR','carisma','charisma','cha'])::integer
    WHEN 'bard' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['CAR','carisma','charisma','cha'])::integer
    WHEN 'paladin' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['CAR','carisma','charisma','cha'])::integer
    ELSE public._srd35_attr(to_jsonb(v_sheet),ARRAY['SAB','sabedoria','wisdom','wis'])::integer END;
  IF v_score IS NULL OR v_score<1 THEN RAISE EXCEPTION 'Atributo-chave inválido.'; END IF;
  v_score:=v_score+priv.srd_effective_modifier(v_campaign_id,'character',p_character_id,
    CASE v_class WHEN 'wizard' THEN 'intelligence' WHEN 'sorcerer' THEN 'charisma' WHEN 'bard' THEN 'charisma' WHEN 'paladin' THEN 'charisma' ELSE 'wisdom' END);
  SELECT sp.* INTO v_spell FROM public.srd_spells sp WHERE sp.id=p_spell_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Magia não encontrada.'; END IF;
  v_spell_level:=public._srd35_spell_level_for_class(v_spell.nivel,v_class,v_spell_level);
  IF COALESCE(v_spell.dados_tecnicos->>'target_mode','')<>'multiple_targets_pending'
     OR COALESCE(v_spell.dados_tecnicos->>'engine_status','') NOT IN ('ready_multi_target','partial_multi_target') THEN
    RAISE EXCEPTION 'A magia ainda não possui resolução automática de múltiplos alvos.';
  END IF;
  IF p_slot_level IS NULL OR p_slot_level<>v_spell_level THEN RAISE EXCEPTION 'O espaço deve corresponder ao círculo da magia.'; END IF;
  IF NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN RAISE EXCEPTION 'Magia não disponível para esta classe.'; END IF;
  IF COALESCE((SELECT (slots_by_level->(v_level-1)->>v_spell_level)::integer FROM public.srd_spell_progressions WHERE class_key=v_class),0)<=0
     OR v_score<10+v_spell_level THEN RAISE EXCEPTION 'Nível de magia, espaço ou atributo insuficiente.'; END IF;
  IF p_spell_id IN ('srd35_spell_haste','srd35_spell_slow') AND cardinality(p_target_token_keys)>v_level THEN
    RAISE EXCEPTION 'Esta magia pode afetar no máximo % alvo(s) no seu nível de conjurador.',v_level;
  END IF;
  SELECT se.parameters->'engine_rule' INTO v_engine_rule FROM public.srd_spell_effects se
  WHERE se.spell_id=p_spell_id AND se.verification_status='verified_srd' ORDER BY se.effect_index LIMIT 1;
  IF v_engine_rule IS NULL THEN RAISE EXCEPTION 'Regra automática de efeito não validada.'; END IF;
  v_state:=COALESCE(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  v_prepared:=COALESCE(v_state->'preparadas','[]'::jsonb);
  SELECT (e.ord-1)::integer INTO v_prepared_idx
  FROM jsonb_array_elements(v_prepared) WITH ORDINALITY e(value,ord)
  WHERE e.value->>'spell_id'=p_spell_id AND (e.value->>'slot_level')::integer=p_slot_level
    AND COALESCE((e.value->>'expended')::boolean,false)=false ORDER BY e.ord LIMIT 1;
  IF v_prepared_idx IS NULL THEN RAISE EXCEPTION 'Nenhum espaço preparado disponível.'; END IF;
  v_prepared:=jsonb_set(v_prepared,ARRAY[v_prepared_idx::text,'expended'],'true'::jsonb,true);
  SELECT count(*)::integer INTO v_slots_remaining FROM jsonb_array_elements(v_prepared) e(value)
  WHERE (e.value->>'slot_level')::integer=p_slot_level AND COALESCE((e.value->>'expended')::boolean,false)=false;
  v_slot_total:=public._srd35_slots(v_class,v_level,v_score,p_slot_level);

  IF EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND UPPER(COALESCE(c.state,''))='COMBATE') THEN
    PERFORM public.consumir_acao_turno_srd(v_campaign_id,p_character_id,'padrao');
  END IF;

  SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
  v_effect_data:=COALESCE(v_engine_rule->'effect_data','{}'::jsonb);
  v_effect_kind:=COALESCE(v_engine_rule->>'effect_kind',CASE v_engine_rule->>'resolver' WHEN 'debuff' THEN 'debuff' ELSE 'buff' END);
  v_save_type:=NULLIF(v_engine_rule->>'save_type','');
  v_condition_id:=NULLIF(v_engine_rule->>'condition_id','');
  v_duration_rounds:=CASE WHEN v_engine_rule ? 'duration_rounds_per_caster_level' THEN v_level*(v_engine_rule->>'duration_rounds_per_caster_level')::integer
    WHEN v_engine_rule ? 'duration_rounds' THEN (v_engine_rule->>'duration_rounds')::integer ELSE NULL END;
  v_scale:=v_engine_rule->'level_scale';
  IF v_scale IS NOT NULL AND jsonb_typeof(v_scale)='object' AND jsonb_typeof(v_effect_data->'modifiers')='array' THEN
    v_scaled_value:=COALESCE((v_scale->>'base')::integer,0)
      +GREATEST(0,FLOOR((v_level-COALESCE((v_scale->>'start_level')::integer,1))::numeric/GREATEST(1,COALESCE((v_scale->>'every_levels')::integer,1)))::integer);
    IF v_scale ? 'cap' THEN v_scaled_value:=LEAST(v_scaled_value,(v_scale->>'cap')::integer); END IF;
    v_effect_data:=jsonb_set(v_effect_data,'{modifiers,0,value}',to_jsonb(v_scaled_value),true);
  END IF;
  IF v_save_type IS NOT NULL THEN v_save_dc:=10+v_spell_level+FLOOR((v_score-10)::numeric/2)::integer; END IF;

  FOREACH v_key IN ARRAY p_target_token_keys LOOP
    SELECT t.value INTO v_token FROM jsonb_array_elements(v_tokens) t(value) WHERE t.value->>'key'=btrim(v_key) LIMIT 1;
    IF NOT FOUND THEN RAISE EXCEPTION 'Token-alvo não encontrado: %',v_key; END IF;
    v_target_type:=COALESCE(v_token->>'tipo','');
    IF v_target_type='player' THEN
      v_target_kind:='character'; v_target_id:=v_token->>'id';
      SELECT ch.user_id INTO v_target_user_id FROM public.characters ch WHERE ch.id::text=v_target_id AND ch.campaign_id=v_campaign_id;
      IF NOT FOUND THEN RAISE EXCEPTION 'Ficha do alvo não pertence à campanha: %',v_key; END IF;
    ELSE
      v_target_kind:='token'; v_target_id:=btrim(v_key); v_target_user_id:=NULL;
    END IF;
    v_target_name:=COALESCE(v_token->>'nome',v_token->>'name','Alvo');
    v_willing_target:=COALESCE((v_engine_rule->>'willing_target')::boolean,false);
    IF v_willing_target THEN v_save_type:=NULL; END IF;
    v_spell_resistance:=COALESCE((v_engine_rule->>'spell_resistance')::boolean,false) AND NOT v_willing_target;
    v_sr:=CASE WHEN v_spell_resistance THEN priv.srd_spell_resistance_value(v_campaign_id,v_target_kind,v_target_id) ELSE 0 END;
    IF v_sr>0 THEN
      v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_spell_level+FLOOR((v_score-10)::numeric/2)::integer ELSE NULL END;
      INSERT INTO priv.srd_pending_spell_resolutions(campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
        save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level,status)
      VALUES(v_campaign_id,p_character_id,v_target_kind,v_target_id,v_target_user_id,p_spell_id,v_save_type,v_save_dc,v_condition_id,
        v_duration_rounds,v_effect_data,v_effect_kind,true,v_level,'awaiting_spell_resistance')
      RETURNING pending_id INTO v_pending_id;
      v_pending_ids:=v_pending_ids||jsonb_build_array(v_pending_id);
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','awaiting_spell_resistance','pending_id',v_pending_id));
      INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
      VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
        'tipo','Penetração de Resistência à Magia (D20)','alvos',jsonb_build_array(p_character_id),'npc_alvos','[]'::jsonb,
        'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
        'resolution_type','spell_resistance','pending_id',v_pending_id,'spell_id',p_spell_id,
        'spell_resistance',v_sr,'caster_level',v_level
      ));
    ELSIF v_engine_rule->>'resolver'='buff' OR (v_engine_rule->>'resolver'='debuff' AND v_save_type IS NULL) THEN
      v_effect_instance:=priv.srd_apply_campaign_effect(v_campaign_id,v_target_kind,v_target_id,v_effect_kind,v_effect_data,v_duration_rounds,p_spell_id,NULL);
      v_effect_ids:=v_effect_ids||jsonb_build_array(v_effect_instance);
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','applied','effect_instance_id',v_effect_instance));
    ELSIF v_engine_rule->>'resolver'='condition' AND v_save_type IS NULL THEN
      v_effect_instance:=priv.srd_apply_campaign_condition(v_campaign_id,v_target_kind,v_target_id,v_condition_id,v_duration_rounds,
        jsonb_build_object('source_spell_id',p_spell_id,'caster_character_id',p_character_id),p_spell_id);
      v_effect_ids:=v_effect_ids||jsonb_build_array(v_effect_instance);
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','applied','condition_instance_id',v_effect_instance));
    ELSE
      IF v_save_type IS NULL THEN RAISE EXCEPTION 'Regra multialvo sem tipo de resistência.'; END IF;
      INSERT INTO priv.srd_pending_spell_resolutions(campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
        save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level)
      VALUES(v_campaign_id,p_character_id,v_target_kind,v_target_id,v_target_user_id,p_spell_id,v_save_type,v_save_dc,v_condition_id,
        v_duration_rounds,v_effect_data,v_effect_kind,COALESCE((v_engine_rule->>'spell_resistance')::boolean,false),v_level)
      RETURNING pending_id INTO v_pending_id;
      v_pending_ids:=v_pending_ids||jsonb_build_array(v_pending_id);
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','pending_save','pending_id',v_pending_id));
      INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
      VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
        'tipo','Resistência de '||CASE v_save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
        'alvos',CASE WHEN v_target_kind='character' THEN jsonb_build_array(v_target_id) ELSE '[]'::jsonb END,
        'npc_alvos',CASE WHEN v_target_kind='token' THEN jsonb_build_array(v_target_id) ELSE '[]'::jsonb END,
        'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
        'resolution_type','spell_save','pending_id',v_pending_id,'spell_id',p_spell_id,'save_type',v_save_type,'save_dc',v_save_dc
      ));
    END IF;
  END LOOP;
  v_state:=jsonb_build_object('version',1,'conhecidas',COALESCE(v_state->'conhecidas','[]'::jsonb),'preparadas',v_prepared,
    'dominio_preparadas',COALESCE(v_state->'dominio_preparadas','[]'::jsonb),'usos',COALESCE(v_state->'usos','{}'::jsonb));
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state WHERE character_id::text=p_character_id;
  RETURN jsonb_build_object('estado',v_state,'targets',v_targets,'target_count',cardinality(p_target_token_keys),
    'pending_resolution_ids',v_pending_ids,'effect_instance_ids',v_effect_ids,'slots_total',v_slot_total,'slots_remaining',v_slots_remaining,'multiple_targets',true);
END;
$function$
;
CREATE OR REPLACE FUNCTION public.conjurar_magia_dano_multialvo_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id bigint;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_spell record;
  v_class text;
  v_level integer;
  v_spell_level integer;
  v_score integer;
  v_state jsonb;
  v_prepared jsonb;
  v_prepared_idx integer;
  v_slots_remaining integer;
  v_slot_total integer;
  v_cba_data jsonb;
  v_tokens jsonb;
  v_key text;
  v_token jsonb;
  v_target_type text;
  v_target_kind text;
  v_target_id text;
  v_target_user_id uuid;
  v_target_name text;
  v_rule jsonb;
  v_effect_data jsonb;
  v_damage_expression text;
  v_damage_scale jsonb;
  v_die_count integer;
  v_die_size integer;
  v_damage_flat integer:=0;
  v_damage_dice_count integer;
  v_damage integer;
  v_damage_type text;
  v_save_type text;
  v_save_result text;
  v_save_dc integer;
  v_spell_resistance boolean:=false;
  v_sr integer:=0;
  v_pending_id uuid;
  v_pending_ids jsonb:='[]'::jsonb;
  v_pending_types jsonb:='[]'::jsonb;
  v_targets jsonb:='[]'::jsonb;
  v_roll_total integer:=0;
  v_resolution jsonb;
  v_pending_status text;
  v_willing_target boolean:=false;
  v_effect_kind text:='damage';
  v_extra_rolls jsonb:='[]'::jsonb; v_extra jsonb; v_extra_expression text; v_extra_count integer:=0; v_extra_size integer:=0;
  v_extra_dice_count integer:=0; v_total_roll_count integer:=0; v_extra_total integer:=0; v_duration_rounds integer:=0; v_secondary_condition_id text;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_target_token_keys IS NULL OR cardinality(p_target_token_keys) NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'Selecione entre 1 e 20 alvos.';
  END IF;
  IF EXISTS(SELECT 1 FROM (SELECT btrim(k) k,count(*) n FROM unnest(p_target_token_keys) k GROUP BY btrim(k)) x WHERE x.n>1 OR NULLIF(x.k,'') IS NULL) THEN
    RAISE EXCEPTION 'A lista de alvos contém identificadores vazios ou repetidos.';
  END IF;
  IF p_roll_results IS NULL OR cardinality(p_roll_results)<1 THEN RAISE EXCEPTION 'Role o dano manualmente antes de conjurar.'; END IF;

  SELECT ch.campaign_id INTO v_campaign_id
  FROM public.characters ch
  WHERE ch.id::text=btrim(p_character_id) AND ch.user_id=auth.uid()
  FOR UPDATE;
  IF NOT FOUND OR v_campaign_id IS NULL THEN RAISE EXCEPTION 'Personagem não encontrado ou sem campanha autorizada.'; END IF;
  IF NOT EXISTS(
    SELECT 1 FROM public.members m WHERE m.campaign_id=v_campaign_id AND m.user_id=auth.uid()
    UNION ALL SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND c.owner_id=auth.uid()
  ) THEN RAISE EXCEPTION 'O personagem não pertence a uma campanha da qual você participa.'; END IF;
  IF priv.srd_condition_has_flag(v_campaign_id,'character',btrim(p_character_id),'no_actions')
     OR priv.srd_condition_has_flag(v_campaign_id,'character',btrim(p_character_id),'cannot_cast') THEN
    RAISE EXCEPTION 'A condição atual impede conjurar magias.';
  END IF;

  SELECT sh.* INTO v_sheet FROM public.srd_character_sheets sh WHERE sh.character_id::text=btrim(p_character_id) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada.'; END IF;
  SELECT public._srd35_class_key(cl.nome) INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD incompatível.'; END IF;
  v_level:=public._srd35_character_class_level(p_character_id,v_class,v_sheet.classe_id,v_sheet.nivel);
  IF v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível de conjurador inválido para a classe.'; END IF;
  v_score:=CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['INT','inteligencia','intelligence'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['CAR','carisma','charisma','cha'])::integer
    WHEN 'bard' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['CAR','carisma','charisma','cha'])::integer
    WHEN 'paladin' THEN public._srd35_attr(to_jsonb(v_sheet),ARRAY['CAR','carisma','charisma','cha'])::integer
    ELSE public._srd35_attr(to_jsonb(v_sheet),ARRAY['SAB','sabedoria','wisdom','wis'])::integer END;
  IF v_score IS NULL OR v_score<1 THEN RAISE EXCEPTION 'Atributo-chave inválido.'; END IF;
  v_score:=v_score+priv.srd_effective_modifier(v_campaign_id,'character',p_character_id,
    CASE v_class WHEN 'wizard' THEN 'intelligence' WHEN 'sorcerer' THEN 'charisma' WHEN 'bard' THEN 'charisma' WHEN 'paladin' THEN 'charisma' ELSE 'wisdom' END);

  SELECT sp.* INTO v_spell FROM public.srd_spells sp WHERE sp.id=p_spell_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Magia não encontrada.'; END IF;
  v_spell_level:=public._srd35_spell_level_for_class(v_spell.nivel,v_class,v_spell_level);
  IF COALESCE(v_spell.dados_tecnicos->>'target_mode','')<>'multiple_targets_pending'
     OR COALESCE(v_spell.dados_tecnicos->>'engine_status','') NOT IN ('ready_multi_target','partial_multi_target') THEN
    RAISE EXCEPTION 'A magia não possui resolução automática de dano em múltiplos alvos.';
  END IF;
  IF p_slot_level IS NULL OR p_slot_level<>v_spell_level THEN RAISE EXCEPTION 'O espaço deve corresponder ao círculo da magia.'; END IF;
  IF NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN RAISE EXCEPTION 'Magia não disponível para esta classe.'; END IF;
  IF COALESCE((SELECT (slots_by_level->(v_level-1)->>v_spell_level)::integer FROM public.srd_spell_progressions WHERE class_key=v_class),0)<=0
     OR v_score<10+v_spell_level THEN RAISE EXCEPTION 'Nível de magia, espaço ou atributo insuficiente.'; END IF;

  SELECT se.parameters->'engine_rule' INTO v_rule
  FROM public.srd_spell_effects se
  WHERE se.spell_id=p_spell_id AND se.verification_status='verified_srd'
    AND se.effect_kind='damage'
  ORDER BY se.effect_index LIMIT 1;
  IF v_rule IS NULL OR v_rule->>'resolver'<>'damage' THEN RAISE EXCEPTION 'Regra de dano não validada.'; END IF;

  v_damage_expression:=COALESCE(v_rule->>'damage_expression','');
  IF v_damage_expression !~ '^[0-9]{1,3}d(2|3|4|6|8|10|12|20|100)([+-][0-9]{1,5})?$' THEN
    RAISE EXCEPTION 'Expressão de dano inválida.';
  END IF;
  v_die_count:=split_part(v_damage_expression,'d',1)::integer;
  v_die_size:=regexp_replace(split_part(v_damage_expression,'d',2),'[+-].*$','')::integer;
  v_damage_flat:=COALESCE(substring(v_damage_expression from '([+-][0-9]+)$')::integer,0);
  v_damage_dice_count:=v_die_count;
  v_damage_scale:=v_rule->'damage_scaling';
  IF v_damage_scale IS NOT NULL AND jsonb_typeof(v_damage_scale)='object' THEN
    v_damage_dice_count:=COALESCE((v_damage_scale->>'base_dice')::integer,v_die_count)
      +GREATEST(0,FLOOR((v_level-COALESCE((v_damage_scale->>'start_level')::integer,1))::numeric
      /GREATEST(1,COALESCE((v_damage_scale->>'every_levels')::integer,1)))::integer)
      *COALESCE((v_damage_scale->>'dice_per_level')::integer,0);
    IF v_damage_scale ? 'cap_dice' THEN v_damage_dice_count:=LEAST(v_damage_dice_count,(v_damage_scale->>'cap_dice')::integer); END IF;
  END IF;
  IF v_damage_dice_count<1 OR v_damage_dice_count>100 THEN RAISE EXCEPTION 'Quantidade de dados de dano fora do limite.'; END IF;
  v_extra_rolls:=COALESCE(v_rule->'extra_rolls','[]'::jsonb);
  IF jsonb_typeof(v_extra_rolls)='array' THEN
    FOR v_extra IN SELECT value FROM jsonb_array_elements(v_extra_rolls) LOOP
      v_extra_expression:=COALESCE(v_extra->>'expression','');
      IF v_extra_expression !~ '^[0-9]{1,2}d(2|4|6|8|10|12|20|100)$' THEN
        RAISE EXCEPTION 'Rolagem adicional inválida na regra de efeito.';
      END IF;
      v_extra_count:=split_part(v_extra_expression,'d',1)::integer;
      v_extra_size:=split_part(v_extra_expression,'d',2)::integer;
      IF v_extra_size<>v_die_size THEN RAISE EXCEPTION 'Rolagens adicionais precisam usar o mesmo tipo de dado do dano.'; END IF;
      v_extra_dice_count:=v_extra_dice_count+v_extra_count;
    END LOOP;
  END IF;
  v_total_roll_count:=v_damage_dice_count+v_extra_dice_count;
  IF v_total_roll_count>100 OR cardinality(p_roll_results)<>v_total_roll_count
     OR EXISTS(SELECT 1 FROM unnest(p_roll_results) value WHERE value<1 OR value>v_die_size) THEN
    RAISE EXCEPTION 'A rolagem precisa conter % dado(s) de dano e duração.',v_total_roll_count;
  END IF;
  SELECT COALESCE(SUM(value),0) INTO v_roll_total
  FROM unnest(p_roll_results) WITH ORDINALITY u(value,ord) WHERE ord<=v_damage_dice_count;
  SELECT COALESCE(SUM(value),0) INTO v_extra_total
  FROM unnest(p_roll_results) WITH ORDINALITY u(value,ord) WHERE ord>v_damage_dice_count;
  v_duration_rounds:=COALESCE((v_rule->>'duration_rounds')::integer,0);
  FOR v_extra IN SELECT value FROM jsonb_array_elements(v_extra_rolls) LOOP
    IF v_extra->>'key'='duration_rounds' THEN v_duration_rounds:=v_extra_total; END IF;
  END LOOP;
  v_secondary_condition_id:=NULLIF(v_rule->>'secondary_condition_id','');
  IF v_secondary_condition_id IS NOT NULL AND v_duration_rounds NOT BETWEEN 1 AND 10000 THEN
    RAISE EXCEPTION 'Duração da condição secundária inválida.';
  END IF;
  v_damage:=GREATEST(0,v_roll_total+v_damage_flat);
  v_damage_type:=COALESCE(NULLIF(v_rule->>'damage_type',''),'untyped');
  IF v_damage_type !~ '^[a-z_]{1,24}$' THEN RAISE EXCEPTION 'Tipo de dano inválido.'; END IF;
  v_save_type:=NULLIF(v_rule->>'save_type','');
  v_save_result:=COALESCE(v_rule->>'save_result','none');
  IF v_save_type IS NOT NULL AND v_save_type NOT IN ('fortitude','reflex','will') THEN RAISE EXCEPTION 'Tipo de resistência inválido.'; END IF;
  v_save_dc:=CASE WHEN v_save_type IS NOT NULL THEN 10+v_spell_level+FLOOR((v_score-10)::numeric/2)::integer ELSE NULL END;
  v_spell_resistance:=COALESCE((v_rule->>'spell_resistance')::boolean,false);
  v_willing_target:=COALESCE((v_rule->>'willing_target')::boolean,false);
  IF v_willing_target THEN v_save_type:=NULL; v_save_dc:=NULL; v_spell_resistance:=false; END IF;

  v_effect_data:=COALESCE(v_rule->'effect_data','{}'::jsonb)||jsonb_build_object(
    'damage',v_damage,'damage_type',v_damage_type,'save_result',v_save_result,
    'damage_expression',v_damage_dice_count::text||'d'||v_die_size,
    'secondary_condition_id',v_secondary_condition_id,'apply_secondary_condition',true
  );
  v_state:=COALESCE(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  v_prepared:=COALESCE(v_state->'preparadas','[]'::jsonb);
  SELECT (e.ord-1)::integer INTO v_prepared_idx
  FROM jsonb_array_elements(v_prepared) WITH ORDINALITY e(value,ord)
  WHERE e.value->>'spell_id'=p_spell_id AND (e.value->>'slot_level')::integer=p_slot_level
    AND COALESCE((e.value->>'expended')::boolean,false)=false
  ORDER BY e.ord LIMIT 1;
  IF v_prepared_idx IS NULL THEN RAISE EXCEPTION 'Nenhum espaço preparado disponível.'; END IF;
  v_prepared:=jsonb_set(v_prepared,ARRAY[v_prepared_idx::text,'expended'],'true'::jsonb,true);
  SELECT count(*)::integer INTO v_slots_remaining FROM jsonb_array_elements(v_prepared) e(value)
  WHERE (e.value->>'slot_level')::integer=p_slot_level AND COALESCE((e.value->>'expended')::boolean,false)=false;
  v_slot_total:=public._srd35_slots(v_class,v_level,v_score,p_slot_level);

  IF EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND UPPER(COALESCE(c.state,''))='COMBATE') THEN
    PERFORM public.consumir_acao_turno_srd(v_campaign_id,p_character_id,'padrao');
  END IF;
  SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;

  FOREACH v_key IN ARRAY p_target_token_keys LOOP
    SELECT t.value INTO v_token FROM jsonb_array_elements(v_tokens) t(value)
    WHERE t.value->>'key'=btrim(v_key) OR t.value->>'id'=btrim(v_key) LIMIT 1;
    IF NOT FOUND THEN RAISE EXCEPTION 'Token-alvo não encontrado: %.',v_key; END IF;
    v_target_type:=COALESCE(v_token->>'tipo','');
    IF v_target_type='player' THEN
      v_target_kind:='character'; v_target_id:=v_token->>'id';
      SELECT ch.user_id INTO v_target_user_id FROM public.characters ch
      WHERE ch.id::text=v_target_id AND ch.campaign_id=v_campaign_id;
      IF NOT FOUND THEN RAISE EXCEPTION 'Personagem-alvo não pertence à campanha.'; END IF;
    ELSIF v_target_type IN ('npc','monstro') THEN
      v_target_kind:='token'; v_target_id:=COALESCE(v_token->>'key',v_token->>'id'); v_target_user_id:=NULL;
    ELSE
      RAISE EXCEPTION 'Tipo de alvo inválido para magia de dano.';
    END IF;
    v_target_name:=COALESCE(v_token->>'nome',v_token->>'name','Alvo');
    v_sr:=CASE WHEN v_spell_resistance THEN priv.srd_spell_resistance_value(v_campaign_id,v_target_kind,v_target_id) ELSE 0 END;
    v_pending_status:=CASE WHEN v_sr>0 THEN 'awaiting_spell_resistance' ELSE 'pending_save' END;

    INSERT INTO priv.srd_pending_spell_resolutions(
      campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
      save_type,save_dc,condition_id,duration_rounds,effect_data,effect_kind,spell_resistance,caster_level,status
    ) VALUES(
      v_campaign_id,p_character_id,v_target_kind,v_target_id,v_target_user_id,p_spell_id,
      v_save_type,v_save_dc,NULL,CASE WHEN v_secondary_condition_id IS NOT NULL THEN v_duration_rounds ELSE NULL END,
      v_effect_data,'damage',v_spell_resistance,v_level,v_pending_status
    ) RETURNING pending_id INTO v_pending_id;
    v_pending_ids:=v_pending_ids||jsonb_build_array(v_pending_id);
    v_pending_types:=v_pending_types||jsonb_build_array(CASE WHEN v_sr>0 THEN 'spell_resistance' WHEN v_save_type IS NOT NULL THEN 'spell_save' ELSE 'damage' END);

    IF v_sr>0 THEN
      INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
      VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
        'tipo','Penetração de Resistência à Magia (D20)','alvos',jsonb_build_array(p_character_id),'npc_alvos','[]'::jsonb,
        'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
        'resolution_type','spell_resistance','pending_id',v_pending_id,'spell_id',p_spell_id,
        'spell_resistance',v_sr,'caster_level',v_level
      ));
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','awaiting_spell_resistance','pending_id',v_pending_id));
    ELSIF v_save_type IS NOT NULL THEN
      INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
      VALUES(v_campaign_id,'test_request','PUBLIC',jsonb_build_object(
        'tipo','Resistência de '||CASE v_save_type WHEN 'fortitude' THEN 'Fortitude' WHEN 'reflex' THEN 'Reflexos' ELSE 'Vontade' END||' (D20)',
        'alvos',CASE WHEN v_target_kind='character' THEN jsonb_build_array(v_target_id) ELSE '[]'::jsonb END,
        'npc_alvos',CASE WHEN v_target_kind='token' THEN jsonb_build_array(v_target_id) ELSE '[]'::jsonb END,
        'mestre','Sistema','mestre_id',auth.uid(),'request_id',v_pending_id::text,
        'resolution_type','spell_save','pending_id',v_pending_id,'spell_id',p_spell_id,'save_type',v_save_type,'save_dc',v_save_dc
      ));
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','pending_save','pending_id',v_pending_id));
    ELSE
      v_resolution:=priv.srd_apply_pending_spell_resolution(v_pending_id);
      v_targets:=v_targets||jsonb_build_array(jsonb_build_object('target_id',v_target_id,'target_kind',v_target_kind,'name',v_target_name,'status','applied','resolution',v_resolution));
    END IF;
  END LOOP;

  v_state:=jsonb_build_object('version',1,'conhecidas',COALESCE(v_state->'conhecidas','[]'::jsonb),
    'preparadas',v_prepared,'dominio_preparadas',COALESCE(v_state->'dominio_preparadas','[]'::jsonb),
    'usos',COALESCE(v_state->'usos','{}'::jsonb));
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state WHERE character_id::text=p_character_id;
  SELECT cba_data INTO v_cba_data FROM public.campaigns WHERE id=v_campaign_id;
  RETURN jsonb_build_object(
    'estado',v_state,'damage_roll',v_damage,'damage_expression',v_damage_dice_count::text||'d'||v_die_size,
    'damage_type',v_damage_type,'duration_rounds',NULLIF(v_duration_rounds,0),'secondary_condition_id',v_secondary_condition_id,'targets',v_targets,'target_count',cardinality(p_target_token_keys),
    'pending_resolution_ids',v_pending_ids,'pending_resolution_types',v_pending_types,
    'slots_total',v_slot_total,'slots_remaining',v_slots_remaining,'cba_data',v_cba_data,'multiple_targets',true
  );
END;
$function$
;
CREATE OR REPLACE FUNCTION public.salvar_grimorio_srd(p_character_id text, p_estado jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_doc jsonb; v_class text; v_level integer; v_score integer;
  v_known jsonb; v_prepared jsonb; v_usos jsonb; v_old jsonb;
  v_spell record; v_entry jsonb; v_spell_id text; v_circle integer; v_spell_level integer; v_slot integer;
  v_expended boolean; v_capacity integer; v_count integer; v_count_known integer;
  v_old_expended integer; v_new_ordinal integer; v_slot_key text; v_prepared_out jsonb := '[]'::jsonb;
  v_known_out jsonb := '[]'::jsonb; v_usos_out jsonb := '{}'::jsonb;
  v_key text; v_count_value integer; v_known_limits jsonb;
  v_domain_input jsonb; v_domain_out jsonb := '[]'::jsonb; v_domain_id text; v_domain_spell_id text;
  v_domain_level integer; v_domain_expended boolean; v_has_domain boolean;
  v_identity jsonb; v_specialization text; v_prohibited jsonb; v_base_capacity integer; v_specialized_count integer;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.characters c
                  WHERE c.id::text=p_character_id AND c.user_id=auth.uid()) THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização';
  END IF;
  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s
   WHERE s.character_id::text=p_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;
  v_old := coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  IF p_estado IS NULL OR jsonb_typeof(p_estado) <> 'object' OR p_estado->>'version' <> '1'
     OR jsonb_typeof(p_estado->'conhecidas') <> 'array'
     OR jsonb_typeof(p_estado->'preparadas') <> 'array'
     OR jsonb_typeof(p_estado->'usos') <> 'object' THEN
    RAISE EXCEPTION 'Formato inválido; esperado {version:1, conhecidas:[], preparadas:[], usos:{}}';
  END IF;
  v_doc := to_jsonb(v_sheet);
  v_identity := coalesce(v_sheet.identidade,'{}'::jsonb);
  v_specialization := coalesce(v_identity->>'wizard_specialization','universalista');
  v_prohibited := coalesce(v_identity->'wizard_prohibited_schools','[]'::jsonb);
  SELECT public._srd35_class_key(cl.nome) INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD referenciada por classe_id não encontrada ou incompatível'; END IF;
  v_level := public._srd35_character_class_level(p_character_id,v_class,v_sheet.classe_id,v_sheet.nivel);
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível de conjurador ausente ou fora de 1..20'; END IF;
  v_score := CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(v_doc,ARRAY['INT','inteligencia','intelligence','int_score','score_inteligencia'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(v_doc,ARRAY['CAR','carisma','charisma','cha','cha_score','score_carisma'])::integer
    ELSE public._srd35_attr(v_doc,ARRAY['SAB','sabedoria','wisdom','wis','wis_score','score_sabedoria'])::integer END;
  IF v_score IS NULL OR v_score < 1 THEN RAISE EXCEPTION 'Atributo-chave ausente ou inválido'; END IF;
  v_known := p_estado->'conhecidas'; v_prepared := p_estado->'preparadas'; v_usos := p_estado->'usos';
  IF v_class='wizard' THEN
    IF EXISTS (
      SELECT 1 FROM public.srd_spells sp
      WHERE v_score>=10 AND public._srd35_spell_level_for_class(sp.nivel,v_class,sp.circulo)=0 AND public._srd35_spell_class_ok(sp.classes,'wizard')
        AND NOT (public._srd35_school_key(sp.escola)=ANY(ARRAY(SELECT jsonb_array_elements_text(v_prohibited))))
        AND NOT (v_known ? sp.id)
    ) THEN
      RAISE EXCEPTION 'O grimório inicial do Mago deve conter todos os truques (círculo 0) permitidos.';
    END IF;
    SELECT count(*)::integer INTO v_count_known
    FROM jsonb_array_elements_text(v_known) AS k(spell_id)
    JOIN public.srd_spells sp ON sp.id=k.spell_id
    WHERE public._srd35_spell_level_for_class(sp.nivel,v_class,sp.circulo)=1;
    v_capacity:=CASE WHEN v_score>=11 THEN greatest(0,3+floor((v_score-10)/2)::integer) ELSE 0 END;
    IF v_count_known<>v_capacity THEN
      RAISE EXCEPTION 'O grimório inicial do Mago deve conter exatamente % magia(s) de 1º círculo (3 + modificador de Inteligência, quando o atributo permite aprender).',v_capacity;
    END IF;
  END IF;
  v_domain_input := coalesce(p_estado->'dominio_preparadas',v_old->'dominio_preparadas','[]'::jsonb);
  IF EXISTS (SELECT 1 FROM jsonb_array_elements(v_known) AS x(value) WHERE jsonb_typeof(x.value) <> 'string')
     OR EXISTS (SELECT 1 FROM jsonb_array_elements(v_prepared) AS x(value) WHERE jsonb_typeof(x.value) <> 'object') THEN
    RAISE EXCEPTION 'Conhecidas deve conter IDs string e preparadas deve conter objetos';
  END IF;
  IF jsonb_typeof(v_domain_input)<>'array' THEN RAISE EXCEPTION 'dominio_preparadas deve ser uma lista'; END IF;
  IF v_class<>'cleric' AND jsonb_array_length(v_domain_input)>0 THEN RAISE EXCEPTION 'Somente clérigos têm espaços de domínio'; END IF;
  IF (SELECT count(*) FROM jsonb_array_elements_text(v_known)) <>
     (SELECT count(DISTINCT x) FROM jsonb_array_elements_text(v_known) AS t(x)) THEN
    RAISE EXCEPTION 'IDs duplicados em conhecidas';
  END IF;
  FOR v_spell_id IN SELECT x FROM jsonb_array_elements_text(v_known) AS t(x) LOOP
    SELECT id,circulo,classes,escola,nivel INTO v_spell FROM public.srd_spells WHERE id=v_spell_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Magia conhecida inexistente, nível inválido ou incompatível: %',v_spell_id; END IF;
    v_spell_level:=public._srd35_spell_level_for_class(v_spell.nivel,v_class,v_spell.circulo);
    IF v_spell_level NOT BETWEEN 0 AND 9 OR NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN
      RAISE EXCEPTION 'Magia conhecida inexistente, nível inválido ou incompatível: %',v_spell_id;
    END IF;
    IF coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_spell_level)::integer
                   FROM public.srd_spell_progressions WHERE class_key=v_class),0)=0 THEN
      RAISE EXCEPTION 'Círculo não acessível neste nível: %',v_spell_id;
    END IF;
    IF v_score < 10+v_spell_level THEN RAISE EXCEPTION 'Atributo insuficiente para conhecer a magia: %',v_spell_id; END IF;
    IF v_class='wizard' AND public._srd35_school_key(v_spell.escola)=ANY(ARRAY(SELECT jsonb_array_elements_text(v_prohibited))) THEN
      RAISE EXCEPTION 'O Mago não pode conhecer magias de escola proibida: %',v_spell_id;
    END IF;
    v_known_out := v_known_out || to_jsonb(v_spell_id);
  END LOOP;
  IF v_class='sorcerer' THEN
    SELECT known_by_level -> (v_level-1) INTO v_known_limits
      FROM public.srd_spell_progressions WHERE class_key='sorcerer';
    FOR v_circle IN 0..9 LOOP
      SELECT count(*) INTO v_count_known
        FROM jsonb_array_elements_text(v_known) AS k(spell_id)
        JOIN public.srd_spells sp ON sp.id=k.spell_id WHERE public._srd35_spell_level_for_class(sp.nivel,v_class,sp.circulo)=v_circle;
      v_capacity := coalesce((v_known_limits ->> v_circle)::integer,0);
      IF v_count_known > v_capacity THEN RAISE EXCEPTION 'Magias conhecidas excedem o limite do círculo %',v_circle; END IF;
    END LOOP;
  ELSIF v_usos <> '{}'::jsonb THEN
    RAISE EXCEPTION 'O mapa usos só é aceito para feiticeiro';
  END IF;
  IF v_class='sorcerer' AND (jsonb_object_length(v_usos)>0 OR jsonb_object_length(coalesce(v_old->'usos','{}'::jsonb))>0) THEN
    FOR v_key,v_count_value IN
      SELECT k, greatest(coalesce((v_usos->>k)::integer,0),coalesce((v_old->'usos'->>k)::integer,0))
        FROM (SELECT key AS k FROM jsonb_each(v_usos)
              UNION SELECT key AS k FROM jsonb_each(coalesce(v_old->'usos','{}'::jsonb))) AS all_keys
    LOOP
      IF v_key !~ '^(0|[1-9])$' OR v_count_value<0 THEN RAISE EXCEPTION 'Usos deve mapear círculos 0..9 a inteiros não negativos'; END IF;
      v_circle := v_key::integer;
      IF coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_circle)::integer
                     FROM public.srd_spell_progressions WHERE class_key='sorcerer'),0)=0
         OR v_count_value > public._srd35_slots(v_class,v_level,v_score,v_circle) THEN
        RAISE EXCEPTION 'Usos excedem os espaços diários no círculo %',v_circle;
      END IF;
      v_usos_out := jsonb_set(v_usos_out,ARRAY[v_key],to_jsonb(v_count_value),true);
    END LOOP;
  END IF;
  FOR v_entry IN SELECT value FROM jsonb_array_elements(v_prepared) LOOP
    v_spell_id := v_entry->>'spell_id';
    IF v_spell_id IS NULL OR jsonb_typeof(v_entry->'slot_level') <> 'number'
       OR jsonb_typeof(v_entry->'expended') <> 'boolean' THEN
      RAISE EXCEPTION 'Cada preparado requer spell_id, slot_level inteiro e expended boolean';
    END IF;
    IF (v_entry->>'slot_level') !~ '^(0|[1-9])$' THEN RAISE EXCEPTION 'slot_level deve estar entre 0 e 9'; END IF;
    v_slot := (v_entry->>'slot_level')::integer;
    SELECT id,circulo,classes,nivel INTO v_spell FROM public.srd_spells WHERE id=v_spell_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Magia preparada inexistente, nível/slot inválido ou incompatível: %',v_spell_id; END IF;
    v_spell_level:=public._srd35_spell_level_for_class(v_spell.nivel,v_class,v_spell.circulo);
    IF v_spell_level NOT BETWEEN 0 AND 9 OR v_slot < v_spell_level
       OR NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN
      RAISE EXCEPTION 'Magia preparada inexistente, nível/slot inválido ou incompatível: %',v_spell_id;
    END IF;
    IF v_class='sorcerer' THEN RAISE EXCEPTION 'Feiticeiro usa conhecidas/usos, não prepara magias'; END IF;
    IF v_class='wizard' AND NOT (v_known ? v_spell_id) THEN
      RAISE EXCEPTION 'Mago só pode preparar magias conhecidas/no grimório: %',v_spell_id;
    END IF;
    IF v_class='wizard' AND public._srd35_school_key(v_spell.escola)=ANY(ARRAY(SELECT jsonb_array_elements_text(v_prohibited))) THEN
      RAISE EXCEPTION 'O Mago não pode preparar magias de escola proibida: %',v_spell_id;
    END IF;
    IF coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_spell_level)::integer
                   FROM public.srd_spell_progressions WHERE class_key=v_class),0)=0 THEN
      RAISE EXCEPTION 'Círculo da magia não acessível neste nível: %',v_spell_id;
    END IF;
    IF v_score < 10+v_spell_level THEN RAISE EXCEPTION 'Atributo insuficiente para preparar a magia: %',v_spell_id; END IF;
    v_prepared_out := v_prepared_out || jsonb_build_array(jsonb_build_object(
      'spell_id',v_spell_id,'slot_level',v_slot,'expended',coalesce((v_entry->>'expended')::boolean,false)));
  END LOOP;
  -- Domain slots are a separate daily slot, one per accessible circle for clerics.
  IF v_class='cleric' THEN
    IF (SELECT count(*) FROM jsonb_array_elements(v_domain_input)) <>
       (SELECT count(DISTINCT (value->>'slot_level')::integer) FROM jsonb_array_elements(v_domain_input)) THEN
      RAISE EXCEPTION 'Há mais de uma preparação no mesmo espaço de domínio';
    END IF;
    FOR v_entry IN SELECT value FROM jsonb_array_elements(v_domain_input) LOOP
      v_domain_id:=v_entry->>'domain_id'; v_domain_spell_id:=v_entry->>'spell_id';
      IF v_domain_id IS NULL OR v_domain_spell_id IS NULL
         OR jsonb_typeof(v_entry->'slot_level')<>'number'
         OR jsonb_typeof(v_entry->'expended')<>'boolean'
         OR (v_entry->>'slot_level') !~ '^[1-9]$' THEN
        RAISE EXCEPTION 'Cada espaço de domínio requer domain_id, spell_id, círculo 1..9 e expended';
      END IF;
      v_domain_level:=(v_entry->>'slot_level')::integer;
      SELECT EXISTS (
        SELECT 1 FROM public.srd_character_domain_choices choice
        JOIN public.srd_domain_spells ds USING (domain_id)
        WHERE choice.character_id::text=p_character_id AND choice.domain_id=v_domain_id
          AND ds.spell_id=v_domain_spell_id AND ds.spell_level=v_domain_level
      ) INTO v_has_domain;
      IF NOT v_has_domain THEN RAISE EXCEPTION 'A magia não pertence a um domínio escolhido ou círculo informado'; END IF;
      IF coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_domain_level)::integer
                     FROM public.srd_spell_progressions WHERE class_key='cleric'),0)=0
         OR v_score < 10+v_domain_level THEN
        RAISE EXCEPTION 'O círculo de domínio não está acessível para este nível/atributo';
      END IF;
      v_domain_expended:=coalesce((v_entry->>'expended')::boolean,false);
      IF EXISTS (SELECT 1 FROM jsonb_array_elements(coalesce(v_old->'dominio_preparadas','[]'::jsonb)) old_slot
                   WHERE (old_slot->>'slot_level')::integer=v_domain_level
                     AND coalesce((old_slot->>'expended')::boolean,false)) THEN
        v_domain_expended:=true;
      END IF;
      v_domain_out:=v_domain_out||jsonb_build_array(jsonb_build_object(
        'domain_id',v_domain_id,'spell_id',v_domain_spell_id,'slot_level',v_domain_level,'expended',v_domain_expended));
    END LOOP;
    -- A spent domain slot cannot be restored by changing its spell; only a daily rest resets it.
    FOR v_entry IN SELECT value FROM jsonb_array_elements(coalesce(v_old->'dominio_preparadas','[]'::jsonb)) old_slot(value)
      WHERE coalesce((value->>'expended')::boolean,false) LOOP
      IF NOT EXISTS (SELECT 1 FROM jsonb_array_elements(v_domain_out) x(value)
                     WHERE (value->>'slot_level')::integer=(v_entry->>'slot_level')::integer) THEN
        v_domain_out:=v_domain_out||jsonb_build_array(v_entry);
      END IF;
    END LOOP;
  END IF;
  -- Preserve previously expended slots by occurrence of the same spell/slot pair.
  FOR v_count IN 0..jsonb_array_length(v_prepared_out)-1 LOOP
    v_entry := v_prepared_out -> v_count;
    v_spell_id := v_entry->>'spell_id'; v_slot := (v_entry->>'slot_level')::integer;
    v_slot_key := v_spell_id || ':' || v_slot::text;
    SELECT count(*) INTO v_new_ordinal FROM jsonb_array_elements(v_prepared_out) WITH ORDINALITY q(value,ord)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot AND ord<=v_count+1;
    SELECT count(*) INTO v_old_expended FROM jsonb_array_elements(coalesce(v_old->'preparadas','[]'::jsonb)) q(value)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot
        AND coalesce((value->>'expended')::boolean,false);
    IF v_new_ordinal<=v_old_expended THEN
      v_prepared_out := jsonb_set(v_prepared_out,ARRAY[v_count::text,'expended'],'true'::jsonb,true);
    END IF;
  END LOOP;
  -- Preserve previously expended slots even if the client submits a different spell list.
  FOR v_entry IN SELECT value FROM jsonb_array_elements(coalesce(v_old->'preparadas','[]'::jsonb)) q(value)
    WHERE coalesce((value->>'expended')::boolean,false)
  LOOP
    v_spell_id:=v_entry->>'spell_id'; v_slot:=(v_entry->>'slot_level')::integer;
    SELECT count(*) INTO v_old_expended FROM jsonb_array_elements(coalesce(v_old->'preparadas','[]'::jsonb)) q(value)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot
        AND coalesce((value->>'expended')::boolean,false);
    SELECT count(*) INTO v_new_ordinal FROM jsonb_array_elements(v_prepared_out) q(value)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot
        AND coalesce((value->>'expended')::boolean,false);
    IF v_new_ordinal<v_old_expended THEN
      v_prepared_out:=v_prepared_out||jsonb_build_array(jsonb_set(v_entry,'{expended}','true'::jsonb,true));
    END IF;
  END LOOP;
  FOR v_circle IN 0..9 LOOP
    SELECT count(*) INTO v_count FROM jsonb_array_elements(v_prepared_out) e
      WHERE (e->>'slot_level')::integer=v_circle;
    v_base_capacity := public._srd35_slots(v_class,v_level,v_score,v_circle);
    v_capacity := v_base_capacity;
    IF v_class='wizard' AND v_specialization<>'universalista' AND v_base_capacity>0 THEN v_capacity:=v_base_capacity+1; END IF;
    IF v_count>v_capacity THEN RAISE EXCEPTION 'Preparadas excedem espaços diários do círculo % (% > %)',v_circle,v_count,v_capacity; END IF;
    IF v_class='wizard' AND v_count>v_base_capacity THEN
      SELECT count(*) INTO v_specialized_count
        FROM jsonb_array_elements(v_prepared_out) prep(value)
        JOIN public.srd_spells sp ON sp.id=prep.value->>'spell_id'
       WHERE (prep.value->>'slot_level')::integer=v_circle
         AND public._srd35_school_key(sp.escola)=v_specialization;
      IF v_specialized_count<1 THEN
        RAISE EXCEPTION 'O espaço adicional do círculo % exige uma magia da escola especializada (%).',v_circle,v_specialization;
      END IF;
    END IF;
  END LOOP;
  UPDATE public.srd_character_sheets
     SET magias_preparadas=jsonb_build_object('version',1,'conhecidas',v_known_out,'preparadas',v_prepared_out,'dominio_preparadas',v_domain_out,'usos',v_usos_out)
   WHERE character_id::text=p_character_id;
  RETURN jsonb_build_object('version',1,'conhecidas',v_known_out,'preparadas',v_prepared_out,'dominio_preparadas',v_domain_out,'usos',v_usos_out);
END
$function$
;
