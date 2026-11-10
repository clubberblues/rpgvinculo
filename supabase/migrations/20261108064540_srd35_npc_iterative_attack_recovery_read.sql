
create or replace function public.consultar_ataque_iterativo_npc_pendente_srd(
 p_campaign_id bigint,p_actor_token_id text
) returns jsonb
language plpgsql
security definer
set search_path=pg_catalog,public,pg_temp
as $function$
declare
 v_user uuid:=auth.uid();
 v_seq public.srd_npc_attack_sequences%rowtype;
 v_attempts jsonb;
begin
 if v_user is null or public.my_role(p_campaign_id) is distinct from 'GM' then
  raise exception 'Somente o Mestre autenticado pode consultar sequências de NPC.';
 end if;
 select * into v_seq from public.srd_npc_attack_sequences
 where campaign_id=p_campaign_id and actor_token_id=btrim(p_actor_token_id)
  and created_by=v_user and status='active'
 order by created_at desc limit 1;
 if not found then return jsonb_build_object('active',false); end if;
 select coalesce(jsonb_agg(jsonb_build_object(
  'id',a.id,'attempt_index',a.attempt_index,'manual_d20',a.manual_d20,
  'iterative_penalty',a.iterative_penalty,'status',a.status,
  'attack_total',a.attack_total,'target_ac',a.target_ac,
  'resolution_data',a.resolution_data,
  'critical_confirmation_d20',a.critical_confirmation_d20,
  'is_critical',a.is_critical,'damage_rolls',a.damage_rolls,
  'damage_applied',a.damage_applied
 ) order by a.attempt_index),'[]'::jsonb)
 into v_attempts from public.srd_npc_attack_attempts a where a.sequence_id=v_seq.id;
 return jsonb_build_object(
  'active',true,'sequence_id',v_seq.id,'campaign_id',v_seq.campaign_id,
  'actor_token_id',v_seq.actor_token_id,'actor_character_id',v_seq.actor_character_id,
  'target_token_id',v_seq.target_token_id,'attack_type',v_seq.attack_type,
  'weapon_instance_id',v_seq.weapon_instance_id,'weapon_hand_slot',v_seq.weapon_hand_slot,
  'weapon_end',v_seq.weapon_end,'base_attack_bonus',v_seq.base_attack_bonus,
  'attacks_total',v_seq.attacks_total,'next_attack_index',v_seq.next_attack_index,
  'round_number',v_seq.round_number,'turn_index',v_seq.turn_index,
  'power_attack_penalty',v_seq.power_attack_penalty,'attempts',v_attempts
 );
end;
$function$;
revoke all on function public.consultar_ataque_iterativo_npc_pendente_srd(bigint,text) from public,anon;
grant execute on function public.consultar_ataque_iterativo_npc_pendente_srd(bigint,text) to authenticated;
