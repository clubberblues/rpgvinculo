
create or replace function public.iniciar_ataque_iterativo_npc_srd(
 p_campaign_id bigint,p_actor_token_id text,p_target_token_id text,p_attack_type text,
 p_weapon_instance_id uuid,p_weapon_hand_slot text,p_weapon_end text default null
) returns jsonb
language plpgsql security definer
set search_path=pg_catalog,public,priv,pg_temp
as $function$
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
 select w into v_weapon
 from jsonb_array_elements(coalesce(v_profile->'weapons','[]'::jsonb)) w
 where w->>'instance_id'=p_weapon_instance_id::text
 and w->>'hand_slot'=p_weapon_hand_slot
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
 select (t.token) into v_actor
 from jsonb_array_elements(v_campaign.cba_data->'tokens') t(token)
 where t.token->>'id'=btrim(p_actor_token_id) and t.token->>'tipo'='npc';
 if v_actor is null then raise exception 'Token atacante NPC inválido.'; end if;
 select (t.token) into v_target
 from jsonb_array_elements(v_campaign.cba_data->'tokens') t(token)
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
$function$;

create or replace function public.registrar_rolagem_ataque_iterativo_npc_srd(
 p_campaign_id bigint,p_sequence_id uuid,p_manual_d20 integer,p_idempotency_key uuid
) returns jsonb
language plpgsql security definer
set search_path=pg_catalog,public,pg_temp
as $function$
declare
 v_user uuid:=auth.uid();
 v_seq public.srd_npc_attack_sequences%rowtype;
 v_attempt public.srd_npc_attack_attempts%rowtype;
 v_campaign public.campaigns%rowtype;
 v_index smallint;
begin
 if v_user is null or public.my_role(p_campaign_id) is distinct from 'GM' then
  raise exception 'Somente o Mestre autenticado pode registrar rolagens de NPC.';
 end if;
 if p_manual_d20 is null or p_manual_d20<1 or p_manual_d20>20 or p_idempotency_key is null then
  raise exception 'D20 manual ou chave idempotente inválida.';
 end if;
 select * into v_seq from public.srd_npc_attack_sequences
 where id=p_sequence_id and campaign_id=p_campaign_id and created_by=v_user
 for update;
 if not found or v_seq.status<>'active' then raise exception 'Sequência NPC não encontrada ou encerrada.'; end if;
 select * into v_campaign from public.campaigns where id=p_campaign_id for update;
 if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
  or lower(coalesce(v_campaign.combat_data->>'active','false'))<>'true'
  or (v_campaign.combat_data->>'current_turn')::integer<>v_seq.turn_index
  or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,1))<>v_seq.round_number then
  raise exception 'A rodada ou o turno mudou; sequência NPC invalidada.';
 end if;
 if exists(select 1 from public.srd_npc_attack_attempts a where a.sequence_id=v_seq.id
  and a.status in ('pending_resolution','critical_confirmation_pending','hit_pending_damage')) then
  raise exception 'Resolva a tentativa anterior antes de registrar outro d20.';
 end if;
 select * into v_attempt from public.srd_npc_attack_attempts
 where sequence_id=v_seq.id and idempotency_key=p_idempotency_key;
 if found then
  return jsonb_build_object('attempt_id',v_attempt.id,'status',v_attempt.status,'replayed',true);
 end if;
 v_index:=v_seq.next_attack_index;
 if v_index>v_seq.attacks_total then raise exception 'Todos os ataques da sequência já foram registrados.'; end if;
 insert into public.srd_npc_attack_attempts(sequence_id,attempt_index,manual_d20,iterative_penalty,idempotency_key)
 values(v_seq.id,v_index,p_manual_d20,((v_index-1)*5)::smallint,p_idempotency_key)
 returning * into v_attempt;
 update public.srd_npc_attack_sequences set next_attack_index=v_index+1 where id=v_seq.id;
 return jsonb_build_object('attempt_id',v_attempt.id,'sequence_id',v_seq.id,
  'attempt_index',v_index,'manual_d20',p_manual_d20,'iterative_penalty',v_attempt.iterative_penalty,'status',v_attempt.status);
end;
$function$;

revoke all on function public.iniciar_ataque_iterativo_npc_srd(bigint,text,text,text,uuid,text,text) from public,anon;
revoke all on function public.registrar_rolagem_ataque_iterativo_npc_srd(bigint,uuid,integer,uuid) from public,anon;
grant execute on function public.iniciar_ataque_iterativo_npc_srd(bigint,text,text,text,uuid,text,text) to authenticated;
grant execute on function public.registrar_rolagem_ataque_iterativo_npc_srd(bigint,uuid,integer,uuid) to authenticated;
