
CREATE OR REPLACE FUNCTION public.conjurar_magia_efeitos_multialvo(
  p_character_id text,p_spell_id text,p_slot_level smallint,p_target_token_keys text[]
)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET search_path=public,priv,pg_temp
AS $function$
DECLARE
  v_campaign_id bigint; v_sheet public.srd_character_sheets%ROWTYPE; v_spell record;
  v_class text; v_level integer; v_score integer; v_state jsonb; v_prepared jsonb;
  v_prepared_idx integer; v_slots_remaining integer; v_slot_total integer;
  v_cba_data jsonb; v_tokens jsonb; v_key text; v_token jsonb; v_target_type text;
  v_target_kind text; v_target_id text; v_target_user_id uuid; v_target_name text;
  v_engine_rule jsonb; v_effect_data jsonb; v_effect_kind text; v_save_type text;
  v_save_dc integer; v_condition_id text; v_duration_rounds integer; v_scale jsonb;
  v_scaled_value integer; v_pending_id uuid; v_effect_instance bigint;
  v_pending_ids jsonb:='[]'::jsonb; v_effect_ids jsonb:='[]'::jsonb; v_targets jsonb:='[]'::jsonb;
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
  SELECT sh.* INTO v_sheet FROM public.srd_character_sheets sh WHERE sh.character_id::text=btrim(p_character_id) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada.'; END IF;
  SELECT public._srd35_class_key(cl.nome) INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD incompatível.'; END IF;
  v_level:=v_sheet.nivel;
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível inválido.'; END IF;
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
  IF NOT FOUND OR COALESCE(v_spell.dados_tecnicos->>'target_mode','')<>'multiple_targets_pending'
     OR COALESCE(v_spell.dados_tecnicos->>'engine_status','')<>'ready_multi_target' THEN
    RAISE EXCEPTION 'A magia ainda não possui resolução automática de múltiplos alvos.';
  END IF;
  IF p_slot_level IS NULL OR p_slot_level<>v_spell.circulo THEN RAISE EXCEPTION 'O espaço deve corresponder ao círculo da magia.'; END IF;
  IF NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN RAISE EXCEPTION 'Magia não disponível para esta classe.'; END IF;
  IF COALESCE((SELECT (slots_by_level->(v_level-1)->>v_spell.circulo)::integer FROM public.srd_spell_progressions WHERE class_key=v_class),0)<=0
     OR v_score<10+v_spell.circulo THEN RAISE EXCEPTION 'Nível de magia, espaço ou atributo insuficiente.'; END IF;
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
  PERFORM public.consumir_acao_turno_srd(v_campaign_id,p_character_id,'padrao');
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
  IF v_save_type IS NOT NULL THEN v_save_dc:=10+v_spell.circulo+FLOOR((v_score-10)::numeric/2)::integer; END IF;

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
    IF v_engine_rule->>'resolver'='buff' OR (v_engine_rule->>'resolver'='debuff' AND v_save_type IS NULL) THEN
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
$function$;

REVOKE ALL ON FUNCTION public.conjurar_magia_efeitos_multialvo(text,text,smallint,text[]) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_efeitos_multialvo(text,text,smallint,text[]) TO authenticated;

UPDATE public.srd_spells
SET dados_tecnicos=jsonb_set(
  jsonb_set(COALESCE(dados_tecnicos,'{}'::jsonb),'{target_mode}',to_jsonb('multiple_targets_pending'::text),true),
  '{engine_status}',to_jsonb('ready_multi_target'::text),true
)
WHERE id IN ('srd35_bless','srd35_spell_bane','srd35_spell_haste','srd35_spell_slow');
