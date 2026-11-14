create or replace function public.confirmar_critico_ataque_iterativo_srd(
  p_campaign_id bigint,
  p_attempt_id uuid,
  p_confirmation_d20 integer
) returns jsonb
language plpgsql
security definer
set search_path = public, priv, pg_temp
as $$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_attempt public.srd_attack_sequence_attempts%rowtype;
  v_seq public.srd_attack_sequences%rowtype;
  v_bonus integer;
  v_total integer;
  v_confirmed boolean;
  v_scene jsonb;
  v_tokens jsonb;
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;
  if p_confirmation_d20 is null or p_confirmation_d20<1 or p_confirmation_d20>20 then
    raise exception 'Confirmação crítica exige um d20 válido.';
  end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;
  select * into v_attempt from public.srd_attack_sequence_attempts where id=p_attempt_id for update;
  if not found then raise exception 'Tentativa de ataque não encontrada.'; end if;
  select * into v_seq from public.srd_attack_sequences
    where id=v_attempt.sequence_id and campaign_id=p_campaign_id for update;
  if not found then raise exception 'Sequência não encontrada.'; end if;
  if v_seq.created_by<>v_user then raise exception 'Somente quem iniciou a sequência pode confirmar o crítico.'; end if;
  if v_attempt.status<>'critical_confirmation_pending' then
    return jsonb_build_object('attempt_id',v_attempt.id,'status',v_attempt.status,
      'is_critical',v_attempt.is_critical,'resolution_data',v_attempt.resolution_data,'replayed',true);
  end if;
  if not exists (
    select 1 from public.characters ch join public.members m
      on m.campaign_id=ch.campaign_id and m.user_id=ch.user_id
    where ch.id=v_seq.actor_character_id and ch.campaign_id=p_campaign_id
      and ch.user_id=v_user and m.role='PLAYER'
  ) then raise exception 'Personagem não pertence ao jogador autenticado.'; end if;
  if lower(coalesce(v_campaign.combat_data->>'active','false'))<>'true'
    or coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$'
    or (v_campaign.combat_data->>'current_turn')::integer<>v_seq.turn_index
    or coalesce(v_campaign.combat_data->>'round','') !~ '^[0-9]+$'
    or greatest(1,(v_campaign.combat_data->>'round')::integer)<>v_seq.round_number then
    raise exception 'Turno ou rodada mudou antes da confirmação crítica.';
  end if;
  select * into strict v_campaign from public.campaigns where id=p_campaign_id;
  v_scene:=coalesce(v_campaign.cba_data,'{}'::jsonb);
  v_tokens:=case when jsonb_typeof(v_scene->'tokens')='array' then v_scene->'tokens' else '[]'::jsonb end;
  if (select count(*) from jsonb_array_elements(v_tokens) t
      where t->>'id'=v_seq.target_token_id and t->>'tipo' in ('npc','monstro'))<>1 then
    raise exception 'Alvo não está mais presente na cena.';
  end if;
  if not exists (
    select 1 from public.srd_character_weapon_instances wi
    where wi.instance_id=v_seq.weapon_instance_id
      and wi.character_id=v_seq.actor_character_id::text
      and wi.equipado is true and wi.hand_slot=v_seq.weapon_hand_slot
  ) then raise exception 'A arma não está mais equipada na mão original.'; end if;
  if jsonb_typeof(v_attempt.resolution_data)<>'object'
     or coalesce(v_attempt.resolution_data->>'attack_total','') !~ '^-?[0-9]+$'
     or coalesce(v_attempt.resolution_data->>'target_ac','') !~ '^-?[0-9]+$' then
    raise exception 'Dados originais do ataque não permitem confirmar o crítico.';
  end if;
  v_bonus:=(v_attempt.resolution_data->>'attack_total')::integer-v_attempt.manual_d20;
  v_total:=p_confirmation_d20+v_bonus;
  v_confirmed:=p_confirmation_d20=20 or (p_confirmation_d20<>1 and v_total>=v_attempt.target_ac);
  update public.srd_attack_sequence_attempts
  set critical_confirmation_d20=p_confirmation_d20,
      is_critical=v_confirmed,
      status='hit_pending_damage',
      resolution_data=resolution_data||jsonb_build_object(
        'critical_confirmation_d20',p_confirmation_d20,
        'critical_confirmation_total',v_total,
        'critical_confirmed',v_confirmed
      )
  where id=p_attempt_id returning * into v_attempt;
  return jsonb_build_object('attempt_id',v_attempt.id,'status',v_attempt.status,
    'is_critical',v_attempt.is_critical,'confirmation_total',v_total,
    'target_ac',v_attempt.target_ac,'replayed',false);
end;
$$;
revoke all on function public.confirmar_critico_ataque_iterativo_srd(bigint,uuid,integer) from public, anon;
grant execute on function public.confirmar_critico_ataque_iterativo_srd(bigint,uuid,integer) to authenticated;