
CREATE OR REPLACE FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(
  p_campaign_id bigint,
  p_character_id text,
  p_target_token_id text,
  p_attack_type text,
  p_weapon_instance_id uuid DEFAULT NULL::uuid
)
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
$function$;

REVOKE ALL ON FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.iniciar_sequencia_ataque_iterativo_srd(bigint,text,text,text,uuid) TO authenticated;
