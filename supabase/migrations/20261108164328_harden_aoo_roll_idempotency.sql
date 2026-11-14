
alter table priv.srd_aoo_attacks
  add column if not exists attack_roll_idempotency_key uuid;
create unique index if not exists srd_aoo_attack_roll_idempotency_unique
  on priv.srd_aoo_attacks(attack_roll_idempotency_key)
  where attack_roll_idempotency_key is not null;

create or replace function public.srd_registrar_rolagem_ataque_oportunidade_srd(
  p_campaign_id bigint,
  p_attack_id uuid,
  p_manual_d20 integer,
  p_idempotency_key uuid
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_existing priv.srd_aoo_attacks%rowtype;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode registrar a rolagem do ataque de oportunidade.';
  end if;
  if p_manual_d20 not between 1 and 20 or p_idempotency_key is null then
    raise exception 'A rolagem exige d20 físico válido e chave de idempotência.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where attack_id=p_attack_id and campaign_id=p_campaign_id for update;
  if not found or v_attack.created_by<>auth.uid() then
    raise exception 'Ataque não encontrado ou sem autorização.';
  end if;
  select * into v_existing from priv.srd_aoo_attacks
  where attack_roll_idempotency_key=p_idempotency_key;
  if found then
    if v_existing.attack_id<>p_attack_id or v_existing.manual_d20<>p_manual_d20 then
      raise exception 'Chave de idempotência já utilizada em outra rolagem.';
    end if;
    return jsonb_build_object('attack_id',p_attack_id,'manual_d20',v_existing.manual_d20,'replayed',true);
  end if;
  if v_attack.status<>'awaiting_attack_roll' then
    if v_attack.manual_d20=p_manual_d20 then
      return jsonb_build_object('attack_id',p_attack_id,'manual_d20',v_attack.manual_d20,'replayed',true);
    end if;
    raise exception 'Este ataque já recebeu uma rolagem diferente.';
  end if;
  update priv.srd_aoo_attacks
  set manual_d20=p_manual_d20,attack_roll_idempotency_key=p_idempotency_key
  where attack_id=p_attack_id;
  return jsonb_build_object('attack_id',p_attack_id,'manual_d20',p_manual_d20,
    'ready_to_resolve',true,'replayed',false);
end;
$function$;

create or replace function public.srd_confirmar_critico_ataque_oportunidade_srd(
  p_campaign_id bigint,
  p_attack_id uuid,
  p_confirmation_d20 integer
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_bonus integer;
  v_total integer;
  v_confirmed boolean;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode confirmar o crítico.';
  end if;
  if p_confirmation_d20 not between 1 and 20 then raise exception 'Confirmação crítica exige d20 físico válido.'; end if;
  select * into v_attack from priv.srd_aoo_attacks
  where attack_id=p_attack_id and campaign_id=p_campaign_id for update;
  if not found or v_attack.created_by<>auth.uid() then raise exception 'Ataque não encontrado ou sem autorização.'; end if;
  if v_attack.status<>'awaiting_critical_confirmation' then
    if v_attack.resolution_data ? 'critical_confirmation_d20'
       and (v_attack.resolution_data->>'critical_confirmation_d20')::integer=p_confirmation_d20 then
      return jsonb_build_object('attack_id',p_attack_id,'status',v_attack.status,
        'is_critical',v_attack.is_critical,'replayed',true);
    end if;
    raise exception 'Este ataque não aguarda confirmação crítica ou recebeu outra rolagem.';
  end if;
  v_bonus:=v_attack.attack_total-v_attack.manual_d20;
  v_total:=p_confirmation_d20+v_bonus;
  v_confirmed:=p_confirmation_d20=20 or (p_confirmation_d20<>1 and v_total>=v_attack.target_ac);
  update priv.srd_aoo_attacks set
    critical_confirmation_d20=p_confirmation_d20,is_critical=v_confirmed,
    status='awaiting_damage',
    resolution_data=resolution_data||jsonb_build_object(
      'critical_confirmation_d20',p_confirmation_d20,
      'critical_confirmation_total',v_total,'critical_confirmed',v_confirmed
    )
  where attack_id=p_attack_id returning * into v_attack;
  update priv.srd_aoo_pending_movements p
  set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[
    (select (e.ordinality-1)::text from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
     where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1)
  ],(
    select e.value||jsonb_build_object('status','hit_pending_damage','critical',v_confirmed)
    from jsonb_array_elements(p.pending_reactions) with ordinality e(value,ordinality)
    where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1
  ),false),updated_at=now()
  where p.pending_id=v_attack.pending_id;
  return jsonb_build_object('attack_id',p_attack_id,'status','awaiting_damage',
    'critical_confirmed',v_confirmed,'confirmation_total',v_total,
    'damage_expression',v_attack.resolution_data->>'weapon_damage');
end;
$function$;

revoke all on function public.srd_registrar_rolagem_ataque_oportunidade_srd(bigint,uuid,integer,uuid) from public,anon;
grant execute on function public.srd_registrar_rolagem_ataque_oportunidade_srd(bigint,uuid,integer,uuid) to authenticated;
revoke all on function public.srd_confirmar_critico_ataque_oportunidade_srd(bigint,uuid,integer) from public,anon;
grant execute on function public.srd_confirmar_critico_ataque_oportunidade_srd(bigint,uuid,integer) to authenticated;
