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
CREATE OR REPLACE FUNCTION priv.srd_confusion_nearest_target_id(p_campaign_id bigint, p_actor_token_id text)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
 v_actor jsonb;
 v_candidate jsonb;
 v_min_distance integer;
 v_distance integer;
 v_tied text[]:=ARRAY[]::text[];
 v_token_id text;
BEGIN
 SELECT t.token INTO v_actor
 FROM jsonb_array_elements(coalesce((SELECT c.cba_data->'tokens' FROM public.campaigns c WHERE c.id=p_campaign_id),'[]'::jsonb)) t(token)
 WHERE t.token->>'id'=btrim(p_actor_token_id)
   AND coalesce(t.token->>'gridX','') ~ '^-?[0-9]+$'
   AND coalesce(t.token->>'gridY','') ~ '^-?[0-9]+$'
 LIMIT 1;
 IF v_actor IS NULL THEN RETURN NULL; END IF;
 FOR v_candidate IN
   SELECT t.token
   FROM jsonb_array_elements(coalesce((SELECT c.cba_data->'tokens' FROM public.campaigns c WHERE c.id=p_campaign_id),'[]'::jsonb)) t(token)
   WHERE t.token->>'id' IS NOT NULL
     AND t.token->>'id'<>btrim(p_actor_token_id)
     AND coalesce(t.token->>'gridX','') ~ '^-?[0-9]+$'
     AND coalesce(t.token->>'gridY','') ~ '^-?[0-9]+$'
 LOOP
   v_distance:=priv.srd_grid_footprint_distance_ft(
     (v_actor->>'gridX')::integer,(v_actor->>'gridY')::integer,
     priv.srd_token_grid_footprint(p_campaign_id,p_actor_token_id),
     (v_candidate->>'gridX')::integer,(v_candidate->>'gridY')::integer,
     priv.srd_token_grid_footprint(p_campaign_id,v_candidate->>'id')
   );
   IF v_min_distance IS NULL OR v_distance<v_min_distance THEN
     v_min_distance:=v_distance;
     v_tied:=ARRAY[v_candidate->>'id'];
   ELSIF v_distance=v_min_distance THEN
     v_tied:=array_append(v_tied,v_candidate->>'id');
   END IF;
 END LOOP;
 IF cardinality(v_tied)=0 THEN RETURN NULL; END IF;
 RETURN v_tied[1+floor(random()*cardinality(v_tied))::integer];
END;
$function$
;
CREATE OR REPLACE FUNCTION priv.srd_confusion_attack_target_allowed(p_campaign_id bigint, p_actor_kind text, p_actor_id text, p_target_token_id text)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
 v_condition public.srd_campaign_conditions%rowtype;
 v_character_id text;
 v_round integer;
BEGIN
 IF p_actor_kind NOT IN ('character','token') OR NULLIF(BTRIM(p_actor_id),'') IS NULL
   OR NULLIF(BTRIM(p_target_token_id),'') IS NULL THEN RETURN false; END IF;
 SELECT greatest(1,coalesce(nullif(c.combat_data->>'round','')::integer,1))
 INTO v_round FROM public.campaigns c WHERE c.id=p_campaign_id;
 IF NOT FOUND THEN RETURN false; END IF;
 IF p_actor_kind='character' THEN
   SELECT * INTO v_condition FROM public.srd_campaign_conditions cc
   WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='character'
     AND cc.target_id=btrim(p_actor_id) AND cc.condition_id='confused' AND cc.active
   ORDER BY cc.condition_instance_id DESC LIMIT 1;
 ELSE
   SELECT nullif(t.token->>'sourceCharacterId','') INTO v_character_id
   FROM public.campaigns c,jsonb_array_elements(coalesce(c.cba_data->'tokens','[]'::jsonb)) t(token)
   WHERE c.id=p_campaign_id AND t.token->>'id'=btrim(p_actor_id) AND t.token->>'tipo'='npc'
   LIMIT 1;
   SELECT * INTO v_condition FROM public.srd_campaign_conditions cc
   WHERE cc.campaign_id=p_campaign_id AND cc.condition_id='confused' AND cc.active
     AND ((cc.target_kind='token' AND cc.target_id=btrim(p_actor_id))
       OR (v_character_id IS NOT NULL AND cc.target_kind='character' AND cc.target_id=v_character_id))
   ORDER BY CASE WHEN cc.target_kind='token' THEN 0 ELSE 1 END,cc.condition_instance_id DESC
   LIMIT 1;
 END IF;
 IF NOT FOUND THEN RETURN true; END IF;
 IF nullif(v_condition.notes->>'confusion_pending_request_id','') IS NOT NULL
   OR coalesce(nullif(v_condition.notes->>'confusion_last_round','')::integer,-1)<>v_round THEN
   RETURN false;
 END IF;
 CASE v_condition.notes->>'confusion_last_outcome'
   WHEN 'act_normally' THEN RETURN true;
   WHEN 'attack_caster' THEN
     RETURN v_condition.notes->>'confusion_last_selected_target_token_id'=btrim(p_target_token_id);
   WHEN 'attack_nearest' THEN
     RETURN v_condition.notes->>'confusion_last_selected_target_token_id'=btrim(p_target_token_id);
   ELSE RETURN false;
 END CASE;
END;
$function$
;
CREATE OR REPLACE FUNCTION priv.srd_confusion_flee_destination_allowed(p_campaign_id bigint, p_actor_token_id text, p_destination_x integer, p_destination_y integer)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
 v_token jsonb;
 v_caster_token jsonb;
 v_condition public.srd_campaign_conditions%rowtype;
 v_character_id text;
 v_round integer;
 v_old_distance integer;
 v_new_distance integer;
BEGIN
 SELECT greatest(1,coalesce(nullif(c.combat_data->>'round','')::integer,1)),
        (SELECT t.token FROM jsonb_array_elements(coalesce(c.cba_data->'tokens','[]'::jsonb)) t(token)
         WHERE t.token->>'id'=btrim(p_actor_token_id) LIMIT 1)
 INTO v_round,v_token
 FROM public.campaigns c WHERE c.id=p_campaign_id;
 IF v_token IS NULL THEN RETURN false; END IF;
 v_character_id:=nullif(v_token->>'sourceCharacterId','');
 SELECT * INTO v_condition FROM public.srd_campaign_conditions cc
 WHERE cc.campaign_id=p_campaign_id AND cc.condition_id='confused' AND cc.active
   AND ((cc.target_kind='token' AND cc.target_id=btrim(p_actor_token_id))
     OR (cc.target_kind='character' AND cc.target_id IN (btrim(p_actor_token_id),coalesce(v_character_id,''))))
 ORDER BY CASE WHEN cc.target_kind='token' THEN 0 ELSE 1 END,cc.condition_instance_id DESC
 LIMIT 1;
 IF NOT FOUND OR v_condition.notes->>'confusion_last_outcome'<>'flee'
   OR coalesce(nullif(v_condition.notes->>'confusion_last_round','')::integer,-1)<>v_round THEN
   RETURN true;
 END IF;
 IF coalesce(v_token->>'gridX','') !~ '^[0-9]{1,3}$'
   OR coalesce(v_token->>'gridY','') !~ '^[0-9]{1,3}$'
   OR p_destination_x NOT BETWEEN 0 AND 199 OR p_destination_y NOT BETWEEN 0 AND 199 THEN
   RETURN false;
 END IF;
 SELECT t.token INTO v_caster_token
 FROM jsonb_array_elements(coalesce((SELECT c.cba_data->'tokens' FROM public.campaigns c WHERE c.id=p_campaign_id),'[]'::jsonb)) t(token)
 WHERE t.token->>'id'=v_condition.notes->>'confusion_last_selected_target_token_id'
 LIMIT 1;
 IF v_caster_token IS NULL OR coalesce(v_caster_token->>'gridX','') !~ '^[0-9]{1,3}$'
   OR coalesce(v_caster_token->>'gridY','') !~ '^[0-9]{1,3}$' THEN RETURN false; END IF;
 v_old_distance:=priv.srd_grid_footprint_distance_ft(
   (v_token->>'gridX')::integer,(v_token->>'gridY')::integer,
   priv.srd_token_grid_footprint(p_campaign_id,p_actor_token_id),
   (v_caster_token->>'gridX')::integer,(v_caster_token->>'gridY')::integer,
   priv.srd_token_grid_footprint(p_campaign_id,v_caster_token->>'id'));
 v_new_distance:=priv.srd_grid_footprint_distance_ft(
   p_destination_x,p_destination_y,
   priv.srd_token_grid_footprint(p_campaign_id,p_actor_token_id),
   (v_caster_token->>'gridX')::integer,(v_caster_token->>'gridY')::integer,
   priv.srd_token_grid_footprint(p_campaign_id,v_caster_token->>'id'));
 RETURN v_new_distance>v_old_distance;
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
 v_actor_token_id text;
 v_caster_token_id text;
 v_selected_target_token_id text;
 v_caster_token_count integer:=0;
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
 SELECT t.token->>'id' INTO v_actor_token_id
 FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
 WHERE t.token->>'id'=p_target_id OR t.token->>'sourceCharacterId'=p_target_id
 ORDER BY CASE WHEN t.token->>'id'=p_target_id THEN 0 ELSE 1 END
 LIMIT 1;
 IF v_caster_id IS NOT NULL THEN
   v_caster_present:=EXISTS(
     SELECT 1 FROM jsonb_array_elements(v_order) e(entry)
     WHERE e.entry->>'id'=v_caster_id
        OR EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
                  WHERE t.token->>'id'=e.entry->>'id' AND t.token->>'sourceCharacterId'=v_caster_id)
   );
   SELECT count(*)::integer,(array_agg(t.token->>'id'))[1]
   INTO v_caster_token_count,v_caster_token_id
   FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
   WHERE t.token->>'id'=v_caster_id OR t.token->>'sourceCharacterId'=v_caster_id;
   IF v_caster_token_count<>1 THEN v_caster_token_id:=NULL; END IF;
 END IF;
 if p_manual_d100 between 1 and 10 then
   IF v_caster_id IS NOT NULL AND v_caster_present AND v_caster_token_id IS NOT NULL THEN
     v_outcome:='attack_caster';
     v_selected_target_token_id:=v_caster_token_id;
     v_description:='Ataca o conjurador responsável pela condição. Alvo obrigatório: token '||v_caster_token_id||'. O Mestre deve confirmar alcance e possibilidade de ataque.';
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
   IF v_caster_id IS NOT NULL AND v_caster_present AND v_caster_token_id IS NOT NULL THEN
     v_outcome:='flee';
     v_selected_target_token_id:=v_caster_token_id;
     v_description:='Foge do conjurador responsável pela condição em velocidade máxima. Referência para afastamento: token '||v_caster_token_id||'. O Mestre deve determinar uma rota desimpedida.';
   ELSE
     v_outcome:='babble';
     v_description:='Não foi possível identificar o conjurador na iniciativa; balbucia incoerentemente e não age.';
   END IF;
 else
   SELECT NULLIF(BTRIM(priv.srd_confusion_nearest_target_id(p_campaign_id,v_actor_token_id)),'')
     INTO v_selected_target_token_id;
   IF v_selected_target_token_id IS NOT NULL THEN
     v_outcome:='attack_nearest';
     v_description:='Ataca a criatura mais próxima. Alvo determinado pela mesa: token '||v_selected_target_token_id||'.';
   ELSE
     v_outcome:='babble';
     v_description:='Não há outra criatura com posição válida na grade; balbucia incoerentemente e não age.';
   END IF;
 end if;

 update public.srd_campaign_conditions
 set notes=coalesce(notes,'{}'::jsonb)
   - 'confusion_pending_request_id' - 'confusion_pending_round' - 'confusion_pending_turn' - 'confusion_pending_at'
   || jsonb_build_object(
     'confusion_last_request_id',p_request_id::text,
     'confusion_last_round',greatest(0,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0)),
     'confusion_last_d100',p_manual_d100,
     'confusion_last_outcome',v_outcome,'confusion_last_selected_target_token_id',v_selected_target_token_id,
     'confusion_last_result',jsonb_build_object(
       'target_kind',p_target_kind,'target_id',p_target_id,'name',v_name,
       'd100',p_manual_d100,'outcome',v_outcome,'description',v_description,
       'caster_character_id',v_caster_id,'caster_present_in_initiative',v_caster_present,'selected_target_token_id',v_selected_target_token_id,
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
   'description',v_description,'caster_character_id',v_caster_id,'selected_target_token_id',v_selected_target_token_id,
   'caster_present_in_initiative',v_caster_present,
   'request_id',p_request_id::text,'replayed',false);
end;
$function$
;
CREATE OR REPLACE FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_combat jsonb;
  v_tokens jsonb;
  v_target_count integer;
  v_turn integer;
  v_round integer;
  v_bab integer;
  v_attacks integer;
  v_action jsonb;
  v_sequence public.srd_attack_sequences%rowtype;
begin
  if v_user is null then
    raise exception 'É necessário estar autenticado.';
  end if;
  if nullif(btrim(p_character_id), '') is null
     or nullif(btrim(p_target_token_id), '') is null
     or p_attack_type not in ('atk-corpo','atk-dist') then
    raise exception 'Dados da sequência de ataque inválidos.';
  end if;

  select c.* into v_campaign
  from public.campaigns c
  where c.id = p_campaign_id
  for update;
  if not found or upper(coalesce(v_campaign.state,'')) <> 'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  if not exists (
    select 1
    from public.characters ch
    join public.members m on m.campaign_id = ch.campaign_id
      and m.user_id = ch.user_id and m.role = 'PLAYER'
    where ch.id::text = btrim(p_character_id)
      and ch.campaign_id = p_campaign_id
      and ch.user_id = v_user
  ) then
    raise exception 'A ficha atacante não pertence ao jogador nesta campanha.';
  end if;

  -- O alvo precisa ser um token real de NPC/monstro da própria campanha.
  v_tokens := case when jsonb_typeof(v_campaign.cba_data->'tokens') = 'array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end;
  select count(*)::integer into v_target_count
  from jsonb_array_elements(v_tokens) t(token)
  where t.token->>'id' = btrim(p_target_token_id)
    and t.token->>'tipo' in ('npc','monstro');
  if v_target_count <> 1 then
    raise exception 'O alvo NPC/monstro não foi encontrado ou está duplicado nesta campanha.';
  end if;
  if not priv.srd_confusion_attack_target_allowed(p_campaign_id,'character',btrim(p_character_id),btrim(p_target_token_id)) then
    raise exception 'A condição Confuso impede este alvo. Siga o resultado D100 do turno e o alvo obrigatório registrado.';
  end if;

  -- Se a interface informar uma instância, ela deve pertencer à ficha e estar equipada.
  -- Não aceitamos UUID arbitrário nem item apenas presente no inventário.
  if p_weapon_instance_id is not null and not exists (
    select 1
    from public.srd_character_weapon_instances wi
    where wi.instance_id = p_weapon_instance_id
      and wi.character_id = btrim(p_character_id)
      and wi.equipado is true
      and wi.hand_slot is not null
  ) then
    raise exception 'A instância de arma não pertence à ficha ou não está equipada em uma mão válida.';
  end if;

  select coalesce(sum(
    case lower(coalesce(c.bab_progression,''))
      when 'good' then cl.class_level
      when 'bom' then cl.class_level
      when 'average' then floor(3 * cl.class_level / 4.0)::integer
      when 'medium' then floor(3 * cl.class_level / 4.0)::integer
      when 'medio' then floor(3 * cl.class_level / 4.0)::integer
      when 'poor' then floor(cl.class_level / 2.0)::integer
      when 'ruim' then floor(cl.class_level / 2.0)::integer
      else 0
    end
  ),0)::integer
  into v_bab
  from public.srd_character_class_levels cl
  join public.srd_classes c on c.id = cl.class_id
  where cl.character_id::text = btrim(p_character_id);

  if v_bab < 6 then
    raise exception 'Esta ficha ainda não possui BBA +6 para ataques iterativos.';
  end if;

  v_attacks := least(6, floor((v_bab - 1) / 5.0)::integer + 1);
  v_combat := coalesce(v_campaign.combat_data,'{}'::jsonb);
  if lower(coalesce(v_combat->>'active','false')) <> 'true'
     or coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' then
    raise exception 'A iniciativa não está ativa ou o turno atual é inválido.';
  end if;
  v_turn := (v_combat->>'current_turn')::integer;
  v_round := case when coalesce(v_combat->>'round','') ~ '^[0-9]+$'
    then greatest(1,(v_combat->>'round')::integer) else 1 end;

  if exists (
    select 1 from public.srd_attack_sequences s
    where s.campaign_id = p_campaign_id
      and s.actor_character_id::text = btrim(p_character_id)
      and s.round_number = v_round and s.turn_index = v_turn
      and s.status = 'active'
  ) then
    raise exception 'Já existe uma sequência de ataques ativa para este turno.';
  end if;

  v_action := public.consumir_acao_rodada_completa_srd(
    p_campaign_id, btrim(p_character_id), 'character'
  );

  insert into public.srd_attack_sequences(
    campaign_id, actor_character_id, target_token_id, attack_type,
    weapon_instance_id, round_number, turn_index, base_attack_bonus,
    attacks_total, created_by
  ) values (
    p_campaign_id, btrim(p_character_id)::bigint, btrim(p_target_token_id), p_attack_type,
    p_weapon_instance_id, v_round, v_turn, v_bab, v_attacks, v_user
  )
  returning * into v_sequence;

  return jsonb_build_object(
    'sequence_id', v_sequence.id,
    'campaign_id', v_sequence.campaign_id,
    'actor_character_id', v_sequence.actor_character_id,
    'target_token_id', v_sequence.target_token_id,
    'attack_type', v_sequence.attack_type,
    'round', v_sequence.round_number,
    'turn_index', v_sequence.turn_index,
    'base_attack_bonus', v_sequence.base_attack_bonus,
    'attacks_total', v_sequence.attacks_total,
    'next_attack_index', v_sequence.next_attack_index,
    'action_economy', v_action->'action_economy'
  );
end;
$function$
;
CREATE OR REPLACE FUNCTION priv.npc_iniciar_ataque_iterativo_impl(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
 v_user uuid:=auth.uid();
 v_profile jsonb;
 v_weapon jsonb;
 v_campaign public.campaigns%rowtype;
 v_actor jsonb;
 v_target jsonb;
 v_target_count integer;
 v_actor_character_id bigint;
 v_sequence public.srd_npc_attack_sequences%rowtype;
 v_action jsonb;
begin
 if v_user is null or public.my_role(p_campaign_id) is distinct from 'GM' then
  raise exception 'Somente o Mestre autenticado pode iniciar Ataque Total de NPC.';
 end if;
 v_profile:=public.consultar_ataque_iterativo_npc_srd(p_campaign_id,p_actor_token_id,p_attack_type);
 if coalesce((v_profile->>'eligible')::boolean,false) is not true then
  raise exception 'NPC sem requisitos para Ataque Total: %.',coalesce(v_profile->>'reason','não elegível');
 end if;
 if coalesce((v_profile->>'full_round_action_already_used')::boolean,false) then
  raise exception 'A ação de rodada completa deste NPC já foi consumida.';
 end if;
 select e.value into v_weapon
 from jsonb_array_elements(coalesce(v_profile->'weapons','[]'::jsonb)) as e(value)
 where e.value->>'instance_id'=p_weapon_instance_id::text
 and e.value->>'hand_slot'=p_weapon_hand_slot
 limit 1;
 if v_weapon is null then raise exception 'A instância selecionada não está equipada nesta mão.'; end if;
 if p_attack_type='atk-corpo' and coalesce(v_weapon->'details'->>'weapon_melee','true')='false' then
  raise exception 'A arma selecionada não permite ataque corpo a corpo.';
 end if;
 if p_attack_type='atk-dist' and coalesce(v_weapon->'details'->>'weapon_ranged','false')<>'true' then
  raise exception 'A arma selecionada não permite ataque à distância.';
 end if;
 select c.* into v_campaign from public.campaigns c where c.id=p_campaign_id for update;
 if not found then raise exception 'Campanha não encontrada.'; end if;
 select count(*)::integer into v_target_count
 from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
  then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t(token)
 where t.token->>'id'=btrim(p_target_token_id);
 if v_target_count<>1 or p_target_token_id=p_actor_token_id then
  raise exception 'Alvo ausente, duplicado ou igual ao atacante.';
 end if;
 if not priv.srd_confusion_attack_target_allowed(p_campaign_id,'token',btrim(p_actor_token_id),btrim(p_target_token_id)) then
  raise exception 'A condição Confuso impede este alvo. Siga o resultado D100 do turno e o alvo obrigatório registrado.';
 end if;
 select (t.token) into v_actor
 from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array' then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t(token)
 where t.token->>'id'=btrim(p_actor_token_id) and t.token->>'tipo'='npc';
 if v_actor is null then raise exception 'Token atacante NPC inválido.'; end if;
 select (t.token) into v_target
 from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array' then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t(token)
 where t.token->>'id'=btrim(p_target_token_id);
 if coalesce(v_actor->>'gridX','') !~ '^-?[0-9]+$' or coalesce(v_actor->>'gridY','') !~ '^-?[0-9]+$'
  or coalesce(v_target->>'gridX','') !~ '^-?[0-9]+$' or coalesce(v_target->>'gridY','') !~ '^-?[0-9]+$' then
  raise exception 'Posição de token inválida para iniciar Ataque Total.';
 end if;
 v_actor_character_id:=(v_profile->>'character_id')::bigint;
 v_action:=public.consumir_acao_rodada_completa_srd(p_campaign_id,p_actor_token_id,'token');
 insert into public.srd_npc_attack_sequences(
  campaign_id,actor_token_id,actor_character_id,target_token_id,attack_type,
  weapon_instance_id,weapon_hand_slot,weapon_end,base_attack_bonus,attacks_total,
  round_number,turn_index,created_by
 ) values (
  p_campaign_id,p_actor_token_id,v_actor_character_id,p_target_token_id,p_attack_type,
  p_weapon_instance_id,p_weapon_hand_slot,p_weapon_end,
  (v_profile->>'base_attack_bonus')::integer,(v_profile->>'attacks_total')::smallint,
  greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,1)),
  (v_campaign.combat_data->>'current_turn')::integer,v_user
 ) returning * into v_sequence;
 return jsonb_build_object('sequence_id',v_sequence.id,'status',v_sequence.status,
  'actor_token_id',v_sequence.actor_token_id,'target_token_id',v_sequence.target_token_id,
  'attacks_total',v_sequence.attacks_total,'next_attack_index',v_sequence.next_attack_index,
  'weapon',v_weapon,'action_economy',v_action->'action_economy');
end;
$function$
;
CREATE OR REPLACE FUNCTION public.mover_token_player_cba(p_campaign_id bigint, p_character_id text, p_grid_x integer, p_grid_y integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_combat JSONB;
  v_campaign_state TEXT;
  v_scene JSONB;
  v_tokens JSONB;
  v_order JSONB;
  v_usage JSONB;
  v_entry JSONB;
  v_current_id TEXT;
  v_round INTEGER;
  v_current_turn INTEGER;
  v_token_index BIGINT;
  v_token_count INTEGER;
  v_character_id TEXT;
  v_race_id TEXT;
  v_mover_size_text TEXT;
  v_token_size INTEGER := 1;
  v_raw_speed TEXT;
  v_speed_m NUMERIC;
  v_used_squares INTEGER := 0;
  v_move_squares INTEGER;
  v_total_squares INTEGER;
  v_used_diagonal_steps INTEGER := 0;
  v_segment_diagonal_steps INTEGER := 0;
  v_diagonal_steps INTEGER := 0;
  v_diagonal_extra INTEGER := 0;
  v_remaining_m NUMERIC;
  v_old_x INTEGER;
  v_old_y INTEGER;
  v_active BOOLEAN;
  v_action_state JSONB;
  v_by_character JSONB;
  v_character_actions JSONB;
  v_new_token JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF NULLIF(BTRIM(p_character_id), '') IS NULL THEN
    RAISE EXCEPTION 'O identificador do personagem é obrigatório.';
  END IF;
  IF p_grid_x IS NULL OR p_grid_y IS NULL OR p_grid_x < 0 OR p_grid_y < 0
     OR p_grid_x > 199 OR p_grid_y > 199 THEN
    RAISE EXCEPTION 'A posição deve estar na grade, com coordenadas inteiras entre 0 e 199.';
  END IF;

  SELECT c.cba_data, c.combat_data, c.state INTO v_scene, v_combat, v_campaign_state
  FROM public.campaigns AS c
  WHERE c.id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  v_combat := COALESCE(v_combat,'{}'::JSONB);
  v_active := lower(COALESCE(v_combat->>'active', 'false')) = 'true';
  IF v_active THEN
    v_order := CASE WHEN jsonb_typeof(v_combat->'turn_order') = 'array'
                    THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
    IF jsonb_array_length(v_order) = 0 THEN RAISE EXCEPTION 'A ordem de iniciativa está vazia.'; END IF;
    v_current_turn := CASE WHEN COALESCE(v_combat->>'current_turn', '') ~ '^[0-9]+$'
                           THEN (v_combat->>'current_turn')::INTEGER ELSE 0 END;
    IF v_current_turn >= jsonb_array_length(v_order) THEN RAISE EXCEPTION 'O turno atual da iniciativa é inválido.'; END IF;
    v_entry := v_order->v_current_turn;
    PERFORM priv.srd_validate_surprise_action(p_campaign_id,BTRIM(p_character_id),'movimento');
    v_current_id := v_entry->>'id';
    IF COALESCE(lower(v_entry->>'is_monster'), 'false') = 'true' THEN RAISE EXCEPTION 'O turno atual pertence a uma criatura controlada pelo Mestre.'; END IF;
    IF v_current_id IS DISTINCT FROM BTRIM(p_character_id) THEN RAISE EXCEPTION 'Somente o personagem cujo turno está ativo pode mover seu token.'; END IF;
  ELSIF UPPER(COALESCE(v_campaign_state,''))='COMBATE' THEN
    RAISE EXCEPTION 'Aguarde a ativação da iniciativa para mover durante o combate.';
  END IF;

  SELECT c.id::TEXT, s.raca_id::TEXT INTO v_character_id, v_race_id
  FROM public.characters AS c
  JOIN public.srd_character_sheets AS s ON s.character_id::TEXT = c.id::TEXT
  WHERE c.id::TEXT = BTRIM(p_character_id)
    AND c.campaign_id = p_campaign_id
    AND c.user_id = auth.uid()
  FOR UPDATE OF c, s;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'O personagem não pertence à sua conta ou não tem ficha SRD nesta campanha.';
  END IF;

  SELECT to_jsonb(r)->>'deslocamento', r.tamanho::TEXT INTO v_raw_speed, v_mover_size_text
  FROM public.srd_races AS r
  WHERE r.id::TEXT = v_race_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'A raça da ficha não foi encontrada.';
  END IF;
  IF v_raw_speed IS NULL THEN
    v_speed_m := 9;
  ELSIF v_raw_speed ~ '^[0-9]+([.][0-9]+)?$' THEN
    v_speed_m := v_raw_speed::NUMERIC;
  ELSE
    RAISE EXCEPTION 'O deslocamento racial não possui um valor numérico válido em metros.';
  END IF;
  IF priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_move') OR (priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_actions') AND NOT priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'flee')) THEN RAISE EXCEPTION 'A condição atual impede movimentação.'; END IF;
  v_speed_m := public.srd35_deslocamento_personagem(v_character_id,v_speed_m);
  v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,'character',v_character_id);
  v_speed_m:=LEAST(v_speed_m*2,v_speed_m+priv.srd_effective_modifier(p_campaign_id,'character',v_character_id,'speed_m'));
  IF v_speed_m < 0 THEN
    RAISE EXCEPTION 'O deslocamento racial não pode ser negativo.';
  END IF;

  v_tokens := CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
                   THEN v_scene->'tokens' ELSE '[]'::JSONB END;
  SELECT count(*)::INTEGER, min(q.ordinality)
  INTO v_token_count, v_token_index
  FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS q(token, ordinality)
  WHERE q.token->>'id' = v_character_id AND q.token->>'tipo' = 'player';
  IF v_token_count = 0 THEN
    RAISE EXCEPTION 'Não existe token player publicado para este personagem.';
  ELSIF v_token_count > 1 THEN
    RAISE EXCEPTION 'Há mais de um token player para este personagem; peça ao Mestre para corrigir a cena.';
  END IF;
  v_entry := v_tokens->(v_token_index::INTEGER - 1);
  IF COALESCE(v_entry->>'gridX', '') !~ '^[0-9]+$'
     OR COALESCE(v_entry->>'gridY', '') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'A posição atual do token é inválida.';
  END IF;
  v_old_x := (v_entry->>'gridX')::INTEGER;
  v_old_y := (v_entry->>'gridY')::INTEGER;
  IF NOT priv.srd_confusion_flee_destination_allowed(p_campaign_id,v_character_id,p_grid_x,p_grid_y) THEN
    RAISE EXCEPTION 'Confuso: a movimentação deve aumentar a distância em relação ao conjurador.';
  END IF;
  IF v_old_x < 0 OR v_old_y < 0 OR v_old_x > 199 OR v_old_y > 199 THEN
    RAISE EXCEPTION 'A posição atual do token está fora do domínio válido da grade.';
  END IF;
  v_token_size := CASE
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'colossal%' THEN 5
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'gargantuan%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'imenso%' THEN 4
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'huge%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'enorme%' THEN 3
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'large%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_mover_size_text,'')) LIKE 'grande%' THEN 2
    ELSE 1 END;

  IF EXISTS (
    SELECT 1
      FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS q(token, ordinality)
      LEFT JOIN public.characters other_character
        ON other_character.id::TEXT=q.token->>'id' AND other_character.campaign_id=p_campaign_id
      LEFT JOIN public.srd_character_sheets other_sheet
        ON other_sheet.character_id=other_character.id
      LEFT JOIN public.srd_races other_race
        ON other_race.id::TEXT=other_sheet.raca_id::TEXT
      CROSS JOIN LATERAL (
        SELECT
          CASE
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'colossal%' THEN 5
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'gargantuan%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'imenso%' THEN 4
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'huge%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'enorme%' THEN 3
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'large%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(q.token->'monsterStats'->>'tamanho',q.token->'monsterStats'->>'size',q.token->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'grande%' THEN 2
            ELSE 1
          END AS footprint,
          CASE WHEN COALESCE(q.token->>'gridX','') ~ '^[0-9]{1,3}$' THEN (q.token->>'gridX')::INTEGER ELSE -1 END AS gx,
          CASE WHEN COALESCE(q.token->>'gridY','') ~ '^[0-9]{1,3}$' THEN (q.token->>'gridY')::INTEGER ELSE -1 END AS gy
      ) AS other_space
     WHERE q.ordinality<>v_token_index AND other_space.gx>=0 AND other_space.gy>=0
       AND p_grid_x < other_space.gx+other_space.footprint AND p_grid_x+v_token_size > other_space.gx
       AND p_grid_y < other_space.gy+other_space.footprint AND p_grid_y+v_token_size > other_space.gy
  ) THEN
    RAISE EXCEPTION 'O espaço de destino está ocupado pela área de outro token.';
  END IF;

-- O custo do deslocamento é calculado após recuperar a sequência diagonal da rodada.
  IF v_active THEN
    v_round := CASE WHEN COALESCE(v_combat->>'round', '') ~ '^[0-9]+$'
                    THEN GREATEST(1, (v_combat->>'round')::INTEGER) ELSE 1 END;
    v_usage := CASE WHEN jsonb_typeof(v_combat->'movement_usage') = 'object'
                    THEN v_combat->'movement_usage' ELSE '{}'::JSONB END;
    IF v_usage->>'character_id' = v_character_id
       AND v_usage->>'round' = v_round::TEXT
       AND v_usage->>'current_turn' = v_current_turn::TEXT
       AND COALESCE(v_usage->>'moved_squares', '') ~ '^[0-9]+$' THEN
      v_used_squares := (v_usage->>'moved_squares')::INTEGER;
      IF COALESCE(v_usage->>'diagonal_steps','') ~ '^[0-9]+$' THEN
        v_used_diagonal_steps := (v_usage->>'diagonal_steps')::INTEGER;
      END IF;
    END IF;
    -- D&D 3.5: diagonais alternam custo de 1 e 2 quadrados (5 ft / 10 ft).
    v_segment_diagonal_steps := LEAST(ABS(p_grid_x - v_old_x), ABS(p_grid_y - v_old_y));
    v_diagonal_extra := FLOOR((v_used_diagonal_steps + v_segment_diagonal_steps) / 2.0)::INTEGER
      - FLOOR(v_used_diagonal_steps / 2.0)::INTEGER;
    v_move_squares := GREATEST(ABS(p_grid_x - v_old_x), ABS(p_grid_y - v_old_y)) + v_diagonal_extra;
    v_diagonal_steps := v_used_diagonal_steps + v_segment_diagonal_steps;
    v_total_squares := v_used_squares + v_move_squares;
    v_remaining_m := GREATEST(0::NUMERIC, v_speed_m - (v_total_squares * 1.5));
    IF v_total_squares * 1.5 > v_speed_m THEN
      RAISE EXCEPTION 'Movimento excede o deslocamento restante deste turno (%.1f m restantes).',
        GREATEST(0::NUMERIC, v_speed_m - (v_used_squares * 1.5));
    END IF;
  ELSE
    v_remaining_m := NULL;
  END IF;

  IF v_active THEN
    v_action_state := v_combat->'action_economy';
    IF jsonb_typeof(v_action_state)='object'
       AND COALESCE(v_action_state->>'round','')=v_round::TEXT
       AND jsonb_typeof(v_action_state->'by_character')='object' THEN
      v_by_character := v_action_state->'by_character';
    ELSE v_by_character := '{}'::JSONB; END IF;
    v_character_actions := CASE WHEN jsonb_typeof(v_by_character->v_character_id)='object'
      THEN v_by_character->v_character_id ELSE '{}'::JSONB END;
    IF COALESCE(v_character_actions->>'movimento','false')='true' AND v_used_squares=0 THEN
      RAISE EXCEPTION 'A ação de movimento deste personagem já foi usada neste turno.';
    END IF;
    IF priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'one_move_or_standard')
       AND COALESCE(v_character_actions->>'padrao','false')='true' THEN
      RAISE EXCEPTION 'A condição permite apenas uma ação padrão ou de movimento por rodada.';
    END IF;
    v_character_actions := v_character_actions || jsonb_build_object('movimento',TRUE);
    v_by_character := jsonb_set(v_by_character,ARRAY[v_character_id],v_character_actions,TRUE);
    v_action_state := jsonb_build_object('round',v_round,'by_character',v_by_character);
    v_combat := v_combat || jsonb_build_object('action_economy',v_action_state);
  END IF;

  v_new_token := v_entry || jsonb_build_object('gridX', p_grid_x, 'gridY', p_grid_y);
  v_scene := COALESCE(v_scene, '{}'::JSONB) || jsonb_build_object(
    'tokens', jsonb_set(v_tokens, ARRAY[(v_token_index - 1)::TEXT], v_new_token, FALSE)
  );
  IF v_active THEN
    v_combat := v_combat || jsonb_build_object(
      'movement_usage', jsonb_build_object(
        'round', v_round,
        'current_turn', v_current_turn,
        'character_id', v_character_id,
        'moved_squares', v_total_squares,
        'diagonal_steps', v_diagonal_steps
      )
    );
  END IF;
  UPDATE public.campaigns
  SET cba_data = v_scene, combat_data = v_combat
  WHERE id = p_campaign_id;
  RETURN jsonb_build_object(
    'cba_data', v_scene,
    'movement_remaining_m', v_remaining_m
  );
END;
$function$
;
CREATE OR REPLACE FUNCTION priv.mover_token_gm_cba_srd_impl(p_campaign_id bigint, p_token_id text, p_grid_x integer, p_grid_y integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_user UUID := auth.uid();
  v_campaign public.campaigns%ROWTYPE;
  v_combat JSONB;
  v_scene JSONB;
  v_tokens JSONB;
  v_order JSONB;
  v_actor JSONB;
  v_token JSONB;
  v_token_count INTEGER;
  v_token_index BIGINT;
  v_token_type TEXT;
  v_token_size_text TEXT;
  v_token_size INTEGER := 1;
  v_speed_text TEXT;
  v_speed_number TEXT;
  v_speed_m NUMERIC;
  v_old_x INTEGER;
  v_old_y INTEGER;
  v_move_squares INTEGER;
  v_diagonal_steps INTEGER := 0;
  v_diagonal_extra INTEGER := 0;
  v_movement_used NUMERIC;
  v_remaining_m NUMERIC;
  v_round INTEGER;
  v_current_turn INTEGER;
  v_economy JSONB;
  v_by_token JSONB;
  v_token_actions JSONB;
  v_movement_usage JSONB;
  v_usage JSONB;
  v_used_squares INTEGER:=0;
  v_total_squares INTEGER;
  v_used_diagonal_steps INTEGER:=0;
  v_segment_diagonal_steps INTEGER:=0;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
  IF p_grid_x IS NULL OR p_grid_y IS NULL OR p_grid_x < 0 OR p_grid_y < 0
     OR p_grid_x > 199 OR p_grid_y > 199 THEN
    RAISE EXCEPTION 'A posição deve estar na grade, com coordenadas inteiras entre 0 e 199.';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.members
    WHERE campaign_id = p_campaign_id AND user_id = v_user AND role = 'GM'
  ) THEN RAISE EXCEPTION 'Somente o Mestre pode mover tokens sob seu controle.'; END IF;

  SELECT campaign.* INTO v_campaign
  FROM public.campaigns AS campaign
  WHERE campaign.id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND OR UPPER(COALESCE(v_campaign.state, '')) <> 'COMBATE' THEN
    RAISE EXCEPTION 'A campanha não está em combate.';
  END IF;
  v_combat := COALESCE(v_campaign.combat_data, '{}'::JSONB);
  IF COALESCE(v_combat->>'active', 'false') <> 'true' THEN
    RAISE EXCEPTION 'Não há turno de combate ativo.';
  END IF;
  v_order := CASE WHEN jsonb_typeof(v_combat->'turn_order') = 'array'
                  THEN v_combat->'turn_order' ELSE '[]'::JSONB END;
  IF COALESCE(v_combat->>'current_turn', '') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'O turno atual da iniciativa é inválido.';
  END IF;
  v_current_turn := (v_combat->>'current_turn')::INTEGER;
  v_actor := v_order->v_current_turn;
  PERFORM priv.srd_validate_surprise_action(p_campaign_id,BTRIM(p_token_id),'movimento');
  IF v_actor->>'id' IS DISTINCT FROM BTRIM(p_token_id) THEN
    RAISE EXCEPTION 'O token não está no turno ativo.';
  END IF;

  v_scene := COALESCE(v_campaign.cba_data, '{}'::JSONB);
  v_tokens := CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
                   THEN v_scene->'tokens' ELSE '[]'::JSONB END;
  SELECT COUNT(*)::INTEGER, MIN(token.ordinality)
  INTO v_token_count, v_token_index
  FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS token(value, ordinality)
  WHERE token.value->>'id' = BTRIM(p_token_id);
  IF v_token_count <> 1 THEN RAISE EXCEPTION 'O token não existe na cena ou está duplicado.'; END IF;
  v_token := v_tokens->(v_token_index::INTEGER - 1);
  v_token_type := v_token->>'tipo';
  IF v_token_type NOT IN ('npc', 'monstro', 'player') THEN
    RAISE EXCEPTION 'Este tipo de token não pode ser movido pelo Mestre nesta ação.';
  END IF;
  IF v_token_type = 'player' AND NOT EXISTS (
    SELECT 1 FROM public.characters AS character
    WHERE character.id::TEXT = BTRIM(p_token_id)
      AND character.campaign_id = p_campaign_id
  ) THEN RAISE EXCEPTION 'O token de personagem não pertence ao Mestre.'; END IF;
  IF COALESCE(v_token->>'gridX', '') !~ '^[0-9]{1,3}$'
     OR COALESCE(v_token->>'gridY', '') !~ '^[0-9]{1,3}$' THEN
    RAISE EXCEPTION 'A posição atual do token é inválida.';
  END IF;
  v_old_x := (v_token->>'gridX')::INTEGER;
  v_old_y := (v_token->>'gridY')::INTEGER;
  IF NOT priv.srd_confusion_flee_destination_allowed(p_campaign_id,BTRIM(p_token_id),p_grid_x,p_grid_y) THEN
    RAISE EXCEPTION 'Confuso: a movimentação deve aumentar a distância em relação ao conjurador.';
  END IF;
  v_token_size_text := COALESCE(v_token->'monsterStats'->>'tamanho',v_token->'monsterStats'->>'size',v_token->>'tamanho');
  IF v_token_type='player' THEN
    SELECT race.tamanho::TEXT INTO v_token_size_text
      FROM public.characters character
      JOIN public.srd_character_sheets sheet ON sheet.character_id=character.id
      JOIN public.srd_races race ON race.id::TEXT=sheet.raca_id::TEXT
     WHERE character.id::TEXT=BTRIM(p_token_id) AND character.campaign_id=p_campaign_id;
  END IF;
  v_token_size := CASE
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'colossal%' THEN 5
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'gargantuan%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'imenso%' THEN 4
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'huge%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'enorme%' THEN 3
    WHEN public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'large%'
      OR public.srd35_normalizar_parametro_talento(COALESCE(v_token_size_text,'')) LIKE 'grande%' THEN 2
    ELSE 1 END;

  IF EXISTS (
    SELECT 1
      FROM jsonb_array_elements(v_tokens) WITH ORDINALITY AS other_token(value, ordinality)
      LEFT JOIN public.characters other_character
        ON other_character.id::TEXT=other_token.value->>'id' AND other_character.campaign_id=p_campaign_id
      LEFT JOIN public.srd_character_sheets other_sheet
        ON other_sheet.character_id=other_character.id
      LEFT JOIN public.srd_races other_race
        ON other_race.id::TEXT=other_sheet.raca_id::TEXT
      CROSS JOIN LATERAL (
        SELECT
          CASE
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'colossal%' THEN 5
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'gargantuan%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'imenso%' THEN 4
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'huge%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'enorme%' THEN 3
            WHEN public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'large%'
              OR public.srd35_normalizar_parametro_talento(COALESCE(other_token.value->'monsterStats'->>'tamanho',other_token.value->'monsterStats'->>'size',other_token.value->>'tamanho',other_race.tamanho::TEXT,'Médio')) LIKE 'grande%' THEN 2
            ELSE 1
          END AS footprint,
          CASE WHEN COALESCE(other_token.value->>'gridX','') ~ '^[0-9]{1,3}$' THEN (other_token.value->>'gridX')::INTEGER ELSE -1 END AS gx,
          CASE WHEN COALESCE(other_token.value->>'gridY','') ~ '^[0-9]{1,3}$' THEN (other_token.value->>'gridY')::INTEGER ELSE -1 END AS gy
      ) AS other_space
     WHERE other_token.ordinality<>v_token_index AND other_space.gx>=0 AND other_space.gy>=0
       AND p_grid_x < other_space.gx+other_space.footprint AND p_grid_x+v_token_size > other_space.gx
       AND p_grid_y < other_space.gy+other_space.footprint AND p_grid_y+v_token_size > other_space.gy
  ) THEN RAISE EXCEPTION 'O espaço de destino está ocupado pela área de outro token.'; END IF;

  
IF v_token_type='npc' AND NULLIF(BTRIM(v_token->>'sourceCharacterId'),'') IS NOT NULL THEN
    SELECT race.deslocamento INTO v_speed_m
      FROM public.srd_character_sheets AS sheet
      JOIN public.srd_races AS race ON race.id::TEXT=sheet.raca_id::TEXT
     WHERE sheet.character_id::TEXT=BTRIM(v_token->>'sourceCharacterId');
    IF NOT FOUND OR v_speed_m IS NULL THEN
      RAISE EXCEPTION 'Não foi possível obter o deslocamento racial da ficha vinculada a %.',v_token->>'nome';
    END IF;
    v_speed_m:=public.srd35_deslocamento_personagem(BTRIM(v_token->>'sourceCharacterId'),v_speed_m);
    IF priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'no_move')
       OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(v_token->>'sourceCharacterId'),'no_move')
       OR ((priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'no_actions')
         OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(v_token->>'sourceCharacterId'),'no_actions'))
         AND NOT (priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'flee')
           OR priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(v_token->>'sourceCharacterId'),'flee'))) THEN
      RAISE EXCEPTION 'A condição atual impede movimentação.';
    END IF;
    v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,'token',BTRIM(p_token_id));
  ELSE
    v_speed_text := COALESCE(
      NULLIF(v_token->>'deslocamento_m', ''),
      NULLIF(v_token->'monsterStats'->>'deslocamento', ''),
      NULLIF(v_token->'monsterStats'->>'speed', ''),
      NULLIF(v_token->>'speed_m', '')
    );
    IF v_token_type = 'player' THEN
      SELECT race.deslocamento::TEXT INTO v_speed_text
      FROM public.characters AS character
      JOIN public.srd_character_sheets AS sheet ON sheet.character_id::TEXT = character.id::TEXT
      JOIN public.srd_races AS race ON race.id::TEXT = sheet.raca_id::TEXT
      WHERE character.id::TEXT = BTRIM(p_token_id)
        AND character.campaign_id = p_campaign_id;
    END IF;
    IF v_speed_text IS NULL OR BTRIM(v_speed_text) = '' THEN
      v_speed_m := 9;
    ELSE
      v_speed_number := substring(v_speed_text FROM '([0-9]+([.][0-9]+)?)');
      IF v_speed_number IS NULL THEN RAISE EXCEPTION 'Não foi possível ler o deslocamento de %.', v_token->>'nome'; END IF;
      v_speed_m := v_speed_number::NUMERIC;
      IF LOWER(v_speed_text) ~ '(ft|feet|foot|p[eé]s|pé)' THEN v_speed_m := v_speed_m * 0.3048; END IF;
    END IF;
    IF v_token_type<>'player' THEN
      IF priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'no_move') OR (priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'no_actions') AND NOT priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'flee')) THEN
        RAISE EXCEPTION 'A condição atual impede movimentação.';
      END IF;
      v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,'token',BTRIM(p_token_id));
    END IF;
    IF v_token_type='player' THEN
      IF priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_token_id),'no_move') OR (priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_token_id),'no_actions') AND NOT priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_token_id),'flee')) THEN
        RAISE EXCEPTION 'A condição atual impede movimentação.';
      END IF;
      v_speed_m:=public.srd35_deslocamento_personagem(BTRIM(p_token_id),v_speed_m);
      v_speed_m:=v_speed_m*priv.srd_condition_speed_multiplier(p_campaign_id,'character',BTRIM(p_token_id));
    END IF;
  END IF;

  -- D&D 3.5: permite dividir a ação de movimento antes/depois da ação padrão,
  -- acumulando distância e alternância diagonal durante o mesmo turno.
  v_round := CASE WHEN COALESCE(v_combat->>'round', '') ~ '^[0-9]+$'
                  THEN GREATEST(1, (v_combat->>'round')::INTEGER) ELSE 1 END;
  v_usage := CASE WHEN jsonb_typeof(v_combat->'movement_usage')='object'
                  THEN v_combat->'movement_usage' ELSE '{}'::JSONB END;
  IF v_usage->>'character_id'=BTRIM(p_token_id)
     AND v_usage->>'round'=v_round::TEXT
     AND v_usage->>'current_turn'=v_current_turn::TEXT
     AND COALESCE(v_usage->>'moved_squares','') ~ '^[0-9]+$' THEN
    v_used_squares:=(v_usage->>'moved_squares')::INTEGER;
    IF COALESCE(v_usage->>'diagonal_steps','') ~ '^[0-9]+$' THEN
      v_used_diagonal_steps:=(v_usage->>'diagonal_steps')::INTEGER;
    END IF;
  END IF;
  v_segment_diagonal_steps:=LEAST(ABS(p_grid_x-v_old_x),ABS(p_grid_y-v_old_y));
  v_diagonal_extra:=FLOOR((v_used_diagonal_steps+v_segment_diagonal_steps)/2.0)::INTEGER
    - FLOOR(v_used_diagonal_steps/2.0)::INTEGER;
  v_move_squares:=GREATEST(ABS(p_grid_x-v_old_x),ABS(p_grid_y-v_old_y))+v_diagonal_extra;
  v_diagonal_steps:=v_used_diagonal_steps+v_segment_diagonal_steps;
  v_total_squares:=v_used_squares+v_move_squares;
  v_movement_used:=v_total_squares*1.5;
  v_remaining_m:=GREATEST(0::NUMERIC,v_speed_m-v_movement_used);
  IF v_movement_used>v_speed_m THEN
    RAISE EXCEPTION 'Movimento excede o deslocamento restante deste turno (%.1f m restantes).',
      GREATEST(0::NUMERIC,v_speed_m-(v_used_squares*1.5));
  END IF;
  v_economy := v_combat->'action_economy';
  IF jsonb_typeof(v_economy) = 'object'
     AND COALESCE(v_economy->>'round', '') = v_round::TEXT
     AND jsonb_typeof(v_economy->'by_character') = 'object' THEN
    v_by_token := v_economy->'by_character';
  ELSE v_by_token := '{}'::JSONB; END IF;
  v_token_actions := CASE WHEN jsonb_typeof(v_by_token->BTRIM(p_token_id)) = 'object'
                          THEN v_by_token->BTRIM(p_token_id) ELSE '{}'::JSONB END;
  IF priv.srd_condition_has_flag(p_campaign_id,'token',BTRIM(p_token_id),'one_move_or_standard') AND COALESCE(v_token_actions->>'padrao','false')='true' THEN RAISE EXCEPTION 'A condição permite apenas uma ação padrão ou de movimento por rodada.'; END IF;
  IF COALESCE(v_token_actions->>'movimento', 'false') = 'true' AND v_used_squares=0 THEN
    RAISE EXCEPTION 'A ação de movimento deste token já foi usada no turno.';
  END IF;
  v_token_actions := v_token_actions || jsonb_build_object('movimento', TRUE);
  v_by_token := jsonb_set(v_by_token, ARRAY[BTRIM(p_token_id)], v_token_actions, TRUE);
  v_combat := v_combat || jsonb_build_object(
    'action_economy', jsonb_build_object('round', v_round, 'by_character', v_by_token),
    'movement_usage', jsonb_build_object('round',v_round,'current_turn',v_current_turn,
      'character_id',BTRIM(p_token_id),'moved_squares',v_total_squares,'diagonal_steps',v_diagonal_steps)
  );
  v_token := v_token || jsonb_build_object('gridX', p_grid_x, 'gridY', p_grid_y);
  v_scene := v_scene || jsonb_build_object('tokens', jsonb_set(v_tokens, ARRAY[(v_token_index - 1)::TEXT], v_token, FALSE));
  UPDATE public.campaigns SET cba_data = v_scene, combat_data = v_combat WHERE id = p_campaign_id;
  RETURN jsonb_build_object('cba_data',v_scene,'combat_data',v_combat,
    'movement_remaining_m',GREATEST(0::NUMERIC,v_speed_m-v_movement_used));
END
$function$
;
REVOKE ALL ON FUNCTION priv.srd_apply_campaign_condition(bigint,text,text,text,integer,jsonb,text) FROM PUBLIC,anon;
REVOKE ALL ON FUNCTION priv.srd_confusion_nearest_target_id(bigint,text) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION priv.srd_confusion_attack_target_allowed(bigint,text,text,text) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION priv.srd_confusion_flee_destination_allowed(bigint,text,integer,integer) FROM PUBLIC,anon,authenticated;
REVOKE ALL ON FUNCTION priv.srd_resolve_confusion_turn_impl(bigint,text,text,uuid,integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION priv.srd_resolve_confusion_turn_impl(bigint,text,text,uuid,integer) TO authenticated;
REVOKE ALL ON FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid) TO authenticated;
REVOKE ALL ON FUNCTION priv.npc_iniciar_ataque_iterativo_impl(bigint,text,text,text,uuid,text,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION priv.npc_iniciar_ataque_iterativo_impl(bigint,text,text,text,uuid,text,text) TO authenticated;
REVOKE ALL ON FUNCTION public.mover_token_player_cba(bigint,text,integer,integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.mover_token_player_cba(bigint,text,integer,integer) TO authenticated;
REVOKE ALL ON FUNCTION priv.mover_token_gm_cba_srd_impl(bigint,text,integer,integer) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION priv.mover_token_gm_cba_srd_impl(bigint,text,integer,integer) TO authenticated;