CREATE OR REPLACE FUNCTION priv.srd_apply_campaign_condition(p_campaign_id bigint, p_target_kind text, p_target_id text, p_condition_id text, p_duration_rounds integer DEFAULT NULL::integer, p_notes jsonb DEFAULT '{}'::jsonb, p_source_spell_id text DEFAULT NULL::text)
 RETURNS bigint
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_round integer;
  v_cba jsonb;
  v_instance bigint;
BEGIN
  IF p_campaign_id IS NULL OR p_campaign_id<1 THEN RAISE EXCEPTION 'Campanha inválida.'; END IF;
  IF p_target_kind NOT IN ('character','token') THEN RAISE EXCEPTION 'Tipo de alvo inválido.'; END IF;
  IF NULLIF(BTRIM(p_target_id),'') IS NULL OR length(p_target_id)>160 THEN RAISE EXCEPTION 'Alvo inválido.'; END IF;
  IF p_duration_rounds IS NOT NULL AND p_duration_rounds NOT BETWEEN 1 AND 10000 THEN
    RAISE EXCEPTION 'A duração deve estar entre 1 e 10000 rodadas.';
  END IF;
  IF p_notes IS NULL OR jsonb_typeof(p_notes)<>'object' OR octet_length(p_notes::text)>12000 THEN
    RAISE EXCEPTION 'Metadados da condição inválidos.';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.srd_conditions WHERE condition_id=p_condition_id
  ) THEN RAISE EXCEPTION 'Condição D&D 3.5 inexistente.'; END IF;

  SELECT COALESCE(NULLIF(c.combat_data->>'round','')::integer,1),
         COALESCE(c.cba_data,'{}'::jsonb)
    INTO v_round,v_cba
    FROM public.campaigns c
   WHERE c.id=p_campaign_id
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;

  IF p_target_kind='character' AND NOT EXISTS (
    SELECT 1 FROM public.characters ch
    WHERE ch.id::text=p_target_id AND ch.campaign_id=p_campaign_id
  ) THEN
    RAISE EXCEPTION 'Personagem não pertence a esta campanha.';
  ELSIF p_target_kind='token' AND NOT (
    EXISTS (
      SELECT 1
      FROM jsonb_array_elements(
        CASE WHEN jsonb_typeof(v_cba->'tokens')='array' THEN v_cba->'tokens' ELSE '[]'::jsonb END
      ) t
      WHERE t->>'id'=p_target_id OR t->>'key'=p_target_id
    )
    OR EXISTS (
      SELECT 1 FROM public.tokens t
      WHERE t.campaign_id=p_campaign_id AND t.id::text=p_target_id
    )
  ) THEN
    RAISE EXCEPTION 'Token não pertence ao tabuleiro desta campanha.';
  END IF;

  IF p_condition_id='slowed' THEN
    UPDATE public.srd_campaign_effects SET active=false
     WHERE campaign_id=p_campaign_id AND target_kind=p_target_kind AND target_id=p_target_id
       AND source_spell_id='srd35_spell_haste' AND active=true;
  END IF;
  UPDATE public.srd_campaign_conditions
     SET active=false
   WHERE campaign_id=p_campaign_id AND target_kind=p_target_kind
     AND target_id=p_target_id AND condition_id=p_condition_id AND active=true;

  INSERT INTO public.srd_campaign_conditions(
    campaign_id,target_kind,target_id,condition_id,source_actor_id,source_spell_id,
    started_round,expires_round,active,notes
  ) VALUES (
    p_campaign_id,p_target_kind,p_target_id,p_condition_id,
    NULLIF(BTRIM(p_notes->>'caster_character_id'),''),p_source_spell_id,
    v_round,
    CASE WHEN p_duration_rounds IS NULL THEN NULL ELSE v_round+p_duration_rounds END,
    true,p_notes
  )
  RETURNING condition_instance_id INTO v_instance;

  RETURN v_instance;
END;
$function$
;
CREATE OR REPLACE FUNCTION priv.srd_resolve_confusion_turn_impl(p_campaign_id bigint, p_target_kind text, p_target_id text, p_request_id uuid, p_manual_d100 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
 v_condition public.srd_campaign_conditions%rowtype;
 v_campaign public.campaigns%rowtype;
 v_actor jsonb;
 v_order jsonb;
 v_name text;
 v_outcome text;
 v_description text;
 v_existing integer;
 v_caster_id text;
 v_caster_present boolean:=false;
begin
 if auth.uid() is null then raise exception 'É necessário estar autenticado.'; end if;
 if p_target_kind not in ('character','token') or nullif(btrim(p_target_id),'') is null then
   raise exception 'Alvo da condição Confuso inválido.';
 end if;
 if p_manual_d100 is null or p_manual_d100 not between 1 and 100 then
   raise exception 'O comportamento aleatório exige uma rolagem física de D100 entre 1 e 100.';
 end if;
 select * into v_campaign from public.campaigns where id=p_campaign_id for update;
 if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
   or coalesce(v_campaign.combat_data->>'active','false')<>'true' then
   raise exception 'A campanha não está em combate ativo.';
 end if;
 v_order:=case when jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
   then v_campaign.combat_data->'turn_order' else '[]'::jsonb end;
 if coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$' then
   raise exception 'O turno atual é inválido.';
 end if;
 v_actor:=v_order->(v_campaign.combat_data->>'current_turn')::integer;
 if v_actor->>'id' is distinct from p_target_id
   or (case when coalesce((v_actor->>'is_monster')::boolean,false) then 'token' else 'character' end)<>p_target_kind then
   raise exception 'A rolagem só pode ser registrada no turno do combatente confuso.';
 end if;
 if p_target_kind='token' then
   if public.my_role(p_campaign_id) is distinct from 'GM' then
     raise exception 'Somente o Mestre pode rolar pelo NPC ou monstro.';
   end if;
 else
   if not exists(select 1 from public.characters ch
     where ch.id::text=p_target_id and ch.campaign_id=p_campaign_id
       and (ch.user_id=auth.uid() or public.my_role(p_campaign_id)='GM')) then
     raise exception 'Somente o dono da ficha ou o Mestre pode registrar esta rolagem.';
   end if;
 end if;
 select * into v_condition from public.srd_campaign_conditions
 where campaign_id=p_campaign_id and target_kind=p_target_kind
   and target_id=p_target_id and condition_id='confused' and active=true
 order by condition_instance_id desc limit 1 for update;
 if not found then raise exception 'O combatente não possui a condição Confuso ativa.'; end if;

 if v_condition.notes->>'confusion_last_request_id'=p_request_id::text then
   v_existing:=nullif(v_condition.notes->>'confusion_last_d100','')::integer;
   if v_existing=p_manual_d100 then
     return coalesce(v_condition.notes->'confusion_last_result','{}'::jsonb)||jsonb_build_object('replayed',true);
   end if;
   raise exception 'Esta solicitação já foi respondida com outro resultado.';
 end if;
 if v_condition.notes->>'confusion_pending_request_id' is distinct from p_request_id::text then
   raise exception 'A solicitação de comportamento aleatório expirou ou não corresponde ao turno atual.';
 end if;

 v_name:=coalesce(v_actor->>'name',v_actor->>'nome','Combatente confuso');
 v_caster_id:=coalesce(nullif(v_condition.source_actor_id,''),nullif(v_condition.notes->>'caster_character_id',''));
 IF v_caster_id IS NOT NULL THEN
   v_caster_present:=EXISTS(
     SELECT 1 FROM jsonb_array_elements(v_order) e(entry)
     WHERE e.entry->>'id'=v_caster_id
        OR EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
                  WHERE t.token->>'id'=e.entry->>'id' AND t.token->>'sourceCharacterId'=v_caster_id)
   );
 END IF;
 if p_manual_d100 between 1 and 10 then
   IF v_caster_id IS NOT NULL AND v_caster_present THEN
     v_outcome:='attack_caster';
     v_description:='Ataca o conjurador responsável pela condição. O Mestre deve confirmar alcance e possibilidade de ataque.';
   ELSE
     v_outcome:='babble';
     v_description:='Não foi possível identificar o conjurador na iniciativa; balbucia incoerentemente e não age.';
   END IF;
 elsif p_manual_d100 between 11 and 20 then
   v_outcome:='act_normally';
   v_description:='Age normalmente neste turno.';
 elsif p_manual_d100 between 21 and 50 then
   v_outcome:='babble';
   v_description:='Fica balbuciando incoerentemente, sem realizar ações.';
 elsif p_manual_d100 between 51 and 70 then
   IF v_caster_id IS NOT NULL AND v_caster_present THEN
     v_outcome:='flee';
     v_description:='Foge do conjurador responsável pela condição em velocidade máxima. O Mestre deve determinar uma rota desimpedida.';
   ELSE
     v_outcome:='babble';
     v_description:='Não foi possível identificar o conjurador na iniciativa; balbucia incoerentemente e não age.';
   END IF;
 else
   v_outcome:='attack_nearest';
   v_description:='Ataca a criatura mais próxima que conseguir alcançar. O Mestre deve selecionar a criatura válida mais próxima; em caso de empate, determine aleatoriamente entre as empatadas.';
 end if;

 update public.srd_campaign_conditions
 set notes=coalesce(notes,'{}'::jsonb)
   - 'confusion_pending_request_id' - 'confusion_pending_round' - 'confusion_pending_turn' - 'confusion_pending_at'
   || jsonb_build_object(
     'confusion_last_request_id',p_request_id::text,
     'confusion_last_round',greatest(0,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0)),
     'confusion_last_d100',p_manual_d100,
     'confusion_last_outcome',v_outcome,
     'confusion_last_result',jsonb_build_object(
       'target_kind',p_target_kind,'target_id',p_target_id,'name',v_name,
       'd100',p_manual_d100,'outcome',v_outcome,'description',v_description,
       'caster_character_id',v_caster_id,'caster_present_in_initiative',v_caster_present,
       'round',greatest(0,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0)),
       'request_id',p_request_id::text
     )
   )
 where condition_instance_id=v_condition.condition_instance_id;

 insert into public.campaign_log(campaign_id,type,visibilidade,data)
 values(p_campaign_id,'system_event','PUBLIC',jsonb_build_object(
   'event','confusion_turn_resolved',
   'target_kind',p_target_kind,'target_id',p_target_id,'name',v_name,
   'd100',p_manual_d100,'outcome',v_outcome,'description',v_description,
   'round',greatest(0,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0)),
   'request_id',p_request_id::text
 ));

 return jsonb_build_object('target_kind',p_target_kind,'target_id',p_target_id,
   'name',v_name,'d100',p_manual_d100,'outcome',v_outcome,
   'description',v_description,'caster_character_id',v_caster_id,
   'caster_present_in_initiative',v_caster_present,
   'request_id',p_request_id::text,'replayed',false);
end;
$function$
;
revoke all on function priv.srd_apply_campaign_condition(bigint,text,text,text,integer,jsonb,text) from public,anon;
revoke all on function priv.srd_resolve_confusion_turn_impl(bigint,text,text,uuid,integer) from public,anon;
grant execute on function priv.srd_resolve_confusion_turn_impl(bigint,text,text,uuid,integer) to authenticated;