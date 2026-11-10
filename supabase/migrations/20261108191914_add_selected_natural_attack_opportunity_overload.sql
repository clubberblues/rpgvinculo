
create or replace function public.srd_iniciar_ataque_oportunidade_monstro_srd(
  p_campaign_id bigint,
  p_pending_id uuid,
  p_reactor_token_id text,
  p_reaction_id uuid,
  p_natural_attack_index integer
) returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_catalog jsonb;
  v_selected jsonb;
  v_started jsonb;
  v_attack_id uuid;
  v_damage_type text;
  v_attack_text text;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode iniciar um ataque natural de oportunidade.';
  end if;
  if p_natural_attack_index is null or p_natural_attack_index<1 then
    raise exception 'Selecione um grupo de ataque natural válido.';
  end if;

  v_catalog:=public.srd_listar_ataques_naturais_oportunidade_srd(
    p_campaign_id,btrim(p_reactor_token_id));
  if coalesce((v_catalog->>'available')::boolean,false) is not true then
    raise exception 'O token não possui ataques naturais catalogados: %',
      coalesce(v_catalog->>'reason','sem ataque natural válido');
  end if;
  select a.value into v_selected
  from jsonb_array_elements(coalesce(v_catalog->'attacks','[]'::jsonb)) a(value)
  where (a.value->>'index')::integer=p_natural_attack_index
    and coalesce((a.value->>'parse_supported')::boolean,false)
    and coalesce((a.value->>'is_natural')::boolean,false)
  limit 1;
  if v_selected is null then
    raise exception 'O grupo selecionado não existe ou não é um ataque natural suportado.';
  end if;

  -- Reutiliza todas as validações existentes: reserva, reação, condição,
  -- alcance, turno e criação idempotente do ataque.
  v_started:=public.srd_iniciar_ataque_oportunidade_monstro_srd(
    p_campaign_id,p_pending_id,p_reactor_token_id,p_reaction_id);
  v_attack_id:=nullif(v_started->>'attack_id','')::uuid;
  if v_attack_id is null then raise exception 'O fluxo legado não retornou um ataque válido.'; end if;

  v_attack_text:=v_catalog->>'source_text';
  v_damage_type:=lower(coalesce(
    (select t->'monsterStats'->>'tipo_dano'
     from public.campaigns c,
       lateral jsonb_array_elements(coalesce(c.cba_data->'tokens','[]'::jsonb)) t
     where c.id=p_campaign_id
       and (t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id))
     limit 1),'physical'));

  update priv.srd_aoo_attacks
  set resolution_data=resolution_data||jsonb_build_object(
    'weapon_name',v_selected->>'name',
    'natural_attack_index',p_natural_attack_index,
    'natural_attack_count',coalesce(nullif(v_selected->>'count','')::integer,1),
    'weapon_damage',v_selected->>'damage_expression',
    'damage_expression',v_selected->>'damage_expression',
    'monster_attack_bonus',coalesce(nullif(v_selected->>'attack_bonus','')::integer,0),
    'natural_attack_bonus_progression',v_selected->>'attack_bonus_progression',
    'natural_attack_group_text',v_selected->>'attack_group_text',
    'natural_attack_additional_effect',v_selected->>'additional_effect',
    'natural_attack_source_text',v_attack_text,
    'natural_attack_selected',true,
    'damage_type',v_damage_type,
    'critical_threat_minimum',20,
    'critical_multiplier',2
  )
  where attack_id=v_attack_id and campaign_id=p_campaign_id
    and created_by=auth.uid() and status='awaiting_attack_roll';
  if not found then raise exception 'Ataque não está mais aguardando rolagem manual.'; end if;

  return v_started||jsonb_build_object(
    'attack_id',v_attack_id,
    'weapon_name',v_selected->>'name',
    'natural_attack_index',p_natural_attack_index,
    'natural_attack_count',coalesce(nullif(v_selected->>'count','')::integer,1),
    'damage_expression',v_selected->>'damage_expression',
    'attack_bonus',coalesce(nullif(v_selected->>'attack_bonus','')::integer,0),
    'additional_effect',v_selected->>'additional_effect',
    'selected_natural_attack',v_selected,
    'awaiting_manual_d20',true
  );
end;
$function$;
revoke all on function public.srd_iniciar_ataque_oportunidade_monstro_srd(bigint,uuid,text,uuid,integer) from public,anon;
grant execute on function public.srd_iniciar_ataque_oportunidade_monstro_srd(bigint,uuid,text,uuid,integer) to authenticated;
