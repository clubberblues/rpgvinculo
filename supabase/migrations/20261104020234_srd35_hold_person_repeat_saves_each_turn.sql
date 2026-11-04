
ALTER TABLE priv.srd_pending_spell_resolutions
  ADD COLUMN IF NOT EXISTS condition_break boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS condition_break_instance_id bigint REFERENCES public.srd_campaign_conditions(condition_instance_id) ON DELETE CASCADE;

DO $patch_pending_spell_notes$
DECLARE v_definition text; v_old text; v_new text;
BEGIN
  SELECT pg_get_functiondef('priv.srd_apply_pending_spell_resolution(uuid)'::regprocedure) INTO v_definition;
  v_old:='jsonb_build_object(''source_spell_id'',v_pending.spell_id,''save_dc'',v_pending.save_dc,''save_type'',v_pending.save_type,';
  v_new:='jsonb_build_object(''source_spell_id'',v_pending.spell_id,''caster_character_id'',v_pending.caster_character_id,''save_dc'',v_pending.save_dc,''save_type'',v_pending.save_type,';
  IF position(v_old IN v_definition)=0 THEN RAISE EXCEPTION 'Notas de efeito de magia não localizadas.'; END IF;
  v_definition:=replace(v_definition,v_old,v_new);
  EXECUTE v_definition;
END;
$patch_pending_spell_notes$;

DO $patch_condition_break_save$
DECLARE v_definition text; v_marker text; v_add text;
BEGIN
  SELECT pg_get_functiondef('public.srd_resolve_pending_spell_save(uuid,integer)'::regprocedure) INTO v_definition;
  v_marker:='  v_total:=p_d20+v_bonus;';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Cálculo de resistência não localizado.'; END IF;
  IF position('condition_break' IN v_definition)=0 THEN
    v_definition:=replace(v_definition,'v_caster_user uuid;','v_caster_user uuid; v_round integer;');
    v_add:=$patch$
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
$patch$;
    v_definition:=replace(v_definition,v_marker,v_marker||E'\n'||v_add);
  END IF;
  EXECUTE v_definition;
END;
$patch_condition_break_save$;

DO $patch_advance_turn_condition_break$
DECLARE v_definition text; v_marker text; v_add text;
BEGIN
  SELECT pg_get_functiondef('public.avancar_turno(bigint)'::regprocedure) INTO v_definition;
  IF position('v_condition_break_pending' IN v_definition)>0 THEN RETURN; END IF;
  v_definition:=replace(v_definition,'v_dying_ids TEXT[]; v_dying_targets JSONB;',
    'v_dying_ids TEXT[]; v_dying_targets JSONB; v_current_actor JSONB; v_actor_id TEXT; v_actor_kind TEXT; v_condition_break RECORD; v_condition_break_pending UUID;');
  v_marker:='  RETURN v_next_data;';
  IF position(v_marker IN v_definition)=0 THEN RAISE EXCEPTION 'Retorno do avanço de turno não localizado.'; END IF;
  v_add:=$patch$
  v_current_actor:=v_order->v_next;
  v_actor_id:=v_current_actor->>'id';
  v_actor_kind:=CASE WHEN COALESCE((v_current_actor->>'is_monster')::boolean,false) THEN 'token' ELSE 'character' END;

  SELECT cc.condition_instance_id,cc.target_kind,cc.target_id,cc.notes,ch.user_id
    INTO v_condition_break
    FROM public.srd_campaign_conditions cc
    LEFT JOIN public.characters ch
      ON cc.target_kind='character' AND ch.id::text=cc.target_id AND ch.campaign_id=cc.campaign_id
   WHERE cc.campaign_id=p_campaign_id
     AND cc.target_kind=v_actor_kind
     AND cc.target_id=v_actor_id
     AND cc.condition_id='paralyzed'
     AND cc.active=true
     AND cc.notes->>'save_each_turn'='true'
     AND COALESCE(NULLIF(cc.notes->>'last_save_round','')::integer,0)<v_round
     AND NULLIF(cc.notes->>'caster_character_id','') IS NOT NULL
     AND NULLIF(cc.notes->>'source_spell_id','') IS NOT NULL
   ORDER BY cc.condition_instance_id DESC
   LIMIT 1;

  IF FOUND THEN
    INSERT INTO priv.srd_pending_spell_resolutions(
      campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
      save_type,save_dc,condition_id,duration_rounds,effect_data,spell_resistance,caster_level,
      condition_break,condition_break_instance_id
    ) VALUES (
      p_campaign_id,v_condition_break.notes->>'caster_character_id',
      v_condition_break.target_kind,v_condition_break.target_id,v_condition_break.user_id,
      v_condition_break.notes->>'source_spell_id',
      COALESCE(v_condition_break.notes->>'save_type','will'),
      COALESCE(NULLIF(v_condition_break.notes->>'save_dc','')::integer,10),
      'paralyzed',NULL,'{}'::jsonb,false,
      GREATEST(1,COALESCE(NULLIF(v_condition_break.notes->>'caster_level','')::integer,1)),
      true,v_condition_break.condition_instance_id
    ) RETURNING pending_id INTO v_condition_break_pending;

    INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
    VALUES (
      p_campaign_id,'test_request','PUBLIC',
      jsonb_build_object(
        'tipo','Resistência de Vontade para encerrar Paralisia (D20)',
        'alvos',CASE WHEN v_actor_kind='character' THEN jsonb_build_array(v_actor_id) ELSE '[]'::jsonb END,
        'npc_alvos',CASE WHEN v_actor_kind='token' THEN jsonb_build_array(v_actor_id) ELSE '[]'::jsonb END,
        'mestre','Sistema','mestre_id',auth.uid(),
        'request_id',v_condition_break_pending::text,
        'resolution_type','condition_break',
        'pending_id',v_condition_break_pending,
        'spell_id',v_condition_break.notes->>'source_spell_id',
        'save_type',COALESCE(v_condition_break.notes->>'save_type','will'),
        'save_dc',COALESCE(NULLIF(v_condition_break.notes->>'save_dc','')::integer,10)
      )
    );
  END IF;
$patch$;
  v_definition:=replace(v_definition,v_marker,v_add||E'\n'||v_marker);
  EXECUTE v_definition;
END;
$patch_advance_turn_condition_break$;
