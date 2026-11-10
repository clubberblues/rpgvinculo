
create or replace function priv.srd_request_confusion_turn_roll()
returns trigger
language plpgsql
security definer
set search_path=pg_catalog,public,priv,pg_temp
as $function$
declare
  v_order jsonb;
  v_index integer;
  v_actor jsonb;
  v_target_kind text;
  v_target_id text;
  v_round integer;
  v_condition public.srd_campaign_conditions%rowtype;
  v_request uuid;
  v_name text;
begin
  if new.combat_data is null
     or coalesce(new.combat_data->>'active','false')<>'true'
     or upper(coalesce(new.state,''))<>'COMBATE' then
    return new;
  end if;
  if tg_op='UPDATE'
     and new.combat_data->>'current_turn' is not distinct from old.combat_data->>'current_turn'
     and new.combat_data->>'round' is not distinct from old.combat_data->>'round'
     and new.combat_data->'surprise'->>'phase' is not distinct from old.combat_data->'surprise'->>'phase' then
    return new;
  end if;
  v_order:=case when jsonb_typeof(new.combat_data->'turn_order')='array'
    then new.combat_data->'turn_order' else '[]'::jsonb end;
  if jsonb_array_length(v_order)=0
     or coalesce(new.combat_data->>'current_turn','') !~ '^[0-9]+$' then
    return new;
  end if;
  v_index:=(new.combat_data->>'current_turn')::integer;
  if v_index<0 or v_index>=jsonb_array_length(v_order) then return new; end if;
  v_actor:=v_order->v_index;
  v_target_id:=nullif(btrim(v_actor->>'id'),'');
  if v_target_id is null then return new; end if;
  v_target_kind:=case when coalesce((v_actor->>'is_monster')::boolean,false) then 'token' else 'character' end;
  v_round:=greatest(0,coalesce(nullif(new.combat_data->>'round','')::integer,0));

  select * into v_condition
  from public.srd_campaign_conditions
  where campaign_id=new.id and target_kind=v_target_kind
    and target_id=v_target_id and condition_id='confused' and active=true
  order by condition_instance_id desc limit 1
  for update;
  if not found then return new; end if;

  if coalesce(v_condition.notes->>'confusion_pending_round','')=v_round::text
     and coalesce(v_condition.notes->>'confusion_pending_turn','')=v_index::text
     and nullif(v_condition.notes->>'confusion_pending_request_id','') is not null then
    return new;
  end if;
  v_request:=gen_random_uuid();
  v_name:=coalesce(v_actor->>'name',v_actor->>'nome','Combatente confuso');

  update public.srd_campaign_conditions
  set notes=coalesce(notes,'{}'::jsonb)||jsonb_build_object(
    'confusion_pending_request_id',v_request::text,
    'confusion_pending_round',v_round,
    'confusion_pending_turn',v_index,
    'confusion_pending_at',now()
  )
  where condition_instance_id=v_condition.condition_instance_id;

  insert into public.campaign_log(campaign_id,type,visibilidade,data)
  values(new.id,'test_request','PUBLIC',jsonb_build_object(
    'tipo','Confusão — comportamento aleatório (D100)',
    'resolution_type','confusion_d100',
    'request_id',v_request::text,
    'alvos',case when v_target_kind='character' then jsonb_build_array(v_target_id) else '[]'::jsonb end,
    'npc_alvos',case when v_target_kind='token' then jsonb_build_array(v_target_id) else '[]'::jsonb end,
    'target_kind',v_target_kind,
    'target_id',v_target_id,
    'combat_round',v_round,
    'current_turn',v_index,
    'mestre','Sistema',
    'mestre_id',new.owner_id,
    'detalhes',jsonb_build_array(jsonb_build_object('id',v_target_id,'name',v_name))
  ));
  return new;
end;
$function$;
revoke all on function priv.srd_request_confusion_turn_roll() from public,anon,authenticated;
drop trigger if exists trg_srd_request_confusion_turn_roll on public.campaigns;
create trigger trg_srd_request_confusion_turn_roll
after update of combat_data on public.campaigns
for each row execute function priv.srd_request_confusion_turn_roll();

create or replace function priv.srd_resolve_confusion_turn_impl(
 p_campaign_id bigint,p_target_kind text,p_target_id text,p_request_id uuid,p_manual_d100 integer
) returns jsonb
language plpgsql
security definer
set search_path=pg_catalog,public,priv,pg_temp
as $function$
declare
 v_condition public.srd_campaign_conditions%rowtype;
 v_campaign public.campaigns%rowtype;
 v_actor jsonb;
 v_order jsonb;
 v_name text;
 v_outcome text;
 v_description text;
 v_existing integer;
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
 if p_manual_d100 between 1 and 10 then
   v_outcome:='attack_caster';
   v_description:='Ataca o conjurador da condição, se conseguir alcançá-lo e realizar a ação.';
 elsif p_manual_d100 between 11 and 20 then
   v_outcome:='act_normally';
   v_description:='Age normalmente neste turno.';
 elsif p_manual_d100 between 21 and 50 then
   v_outcome:='babble';
   v_description:='Fica balbuciando incoerentemente, sem realizar ações.';
 elsif p_manual_d100 between 51 and 70 then
   v_outcome:='flee';
   v_description:='Foge do conjurador em velocidade máxima, conforme o espaço e as condições permitirem.';
 else
   v_outcome:='attack_nearest';
   v_description:='Ataca a criatura mais próxima que conseguir alcançar; o Mestre determina o alvo válido mais próximo.';
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
       'round',greatest(0,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0)),
       'request_id',p_request_id::text
     )
   )
 where condition_instance_id=v_condition.condition_instance_id;

 return jsonb_build_object('target_kind',p_target_kind,'target_id',p_target_id,
   'name',v_name,'d100',p_manual_d100,'outcome',v_outcome,
   'description',v_description,'request_id',p_request_id::text,'replayed',false);
end;
$function$;
revoke all on function priv.srd_resolve_confusion_turn_impl(bigint,text,text,uuid,integer) from public,anon;
grant execute on function priv.srd_resolve_confusion_turn_impl(bigint,text,text,uuid,integer) to authenticated;

create or replace function public.srd_resolve_confusion_turn_srd(
 p_campaign_id bigint,p_target_kind text,p_target_id text,p_request_id uuid,p_manual_d100 integer
) returns jsonb
language sql
security invoker
set search_path=pg_catalog,public,priv,pg_temp
as $function$
 select priv.srd_resolve_confusion_turn_impl(
   p_campaign_id,p_target_kind,p_target_id,p_request_id,p_manual_d100
 );
$function$;
revoke all on function public.srd_resolve_confusion_turn_srd(bigint,text,text,uuid,integer) from public,anon;
grant execute on function public.srd_resolve_confusion_turn_srd(bigint,text,text,uuid,integer) to authenticated;
