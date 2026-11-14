
create or replace function public.srd_reservar_ataque_oportunidade_srd(
  p_campaign_id bigint,
  p_actor_token_id text,
  p_trigger_key text,
  p_actor_flat_footed boolean default false
) returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_combat jsonb;
  v_round integer;
  v_phase text;
  v_profile jsonb;
  v_character_id bigint;
  v_feats jsonb := '[]'::jsonb;
  v_has_combat_reflexes boolean := false;
  v_dex_mod integer := 0;
  v_limit integer := 1;
  v_used integer := 0;
  v_existing priv.srd_aoo_reaction_ledger%rowtype;
  v_new priv.srd_aoo_reaction_ledger%rowtype;
  v_token jsonb;
  v_stats jsonb;
  v_monster_feats text;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode autorizar e registrar uma reação de ataque de oportunidade.';
  end if;
  if nullif(btrim(p_actor_token_id),'') is null
     or nullif(btrim(p_trigger_key),'') is null
     or length(p_trigger_key)>160 then
    raise exception 'Identificador do combatente ou do evento provocador inválido.';
  end if;

  select combat_data into v_combat
  from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce((select state from public.campaigns where id=p_campaign_id),''))<>'COMBATE'
     or coalesce((v_combat->>'active')::boolean,false) is not true then
    raise exception 'A iniciativa precisa estar ativa para registrar uma reação.';
  end if;
  if coalesce(v_combat->>'round','') !~ '^[0-9]+$' then
    raise exception 'A rodada atual é inválida.';
  end if;
  v_phase:=case when coalesce(v_combat->'surprise'->>'phase','')='surprise_round'
    then 'surprise_round' else 'normal' end;
  v_round:=greatest(1,(v_combat->>'round')::integer);

  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_actor_token_id));
  if v_profile is null or (v_profile->>'character_id' is null and v_profile->>'size_rank' is null) then
    raise exception 'Não foi possível validar o combatente que pretende reagir.';
  end if;
  if coalesce(v_profile->>'dexterity_modifier','') ~ '^-?[0-9]+$' then
    v_dex_mod:=(v_profile->>'dexterity_modifier')::integer;
  end if;
  v_character_id:=nullif(v_profile->>'character_id','')::bigint;

  if v_character_id is not null then
    select coalesce(talentos,'[]'::jsonb) into v_feats
    from public.srd_character_sheets where character_id=v_character_id;
    v_has_combat_reflexes:=exists(
      select 1 from jsonb_array_elements(
        case when jsonb_typeof(v_feats)='array' then v_feats else '[]'::jsonb end
      ) f
      where lower(coalesce(f->>'id','')) in
        ('reflexos_de_combate','combat_reflexes','srd35_feat_combat_reflexes')
        or lower(coalesce(f->>'nome','')) in ('reflexos de combate','combat reflexes')
    );
  else
    select t into v_token
    from public.campaigns c,
      lateral jsonb_array_elements(case when jsonb_typeof(c.cba_data->'tokens')='array'
        then c.cba_data->'tokens' else '[]'::jsonb end) t
    where c.id=p_campaign_id and (t->>'id'=btrim(p_actor_token_id) or t->>'key'=btrim(p_actor_token_id))
    limit 1;
    if v_token is null then raise exception 'Token reator não existe mais na cena.'; end if;
    v_stats:=coalesce(v_token->'monsterStats','{}'::jsonb);
    v_monster_feats:=concat_ws(',',
      nullif(v_stats->>'feats',''),
      nullif(v_stats->>'talentos',''),
      nullif(v_stats->'dados_tecnicos'->'statblock'->>'feats',''),
      nullif(v_stats->'dados_tecnicos'->>'feats','')
    );
    v_has_combat_reflexes:=coalesce(v_monster_feats,'') ~*
      '(^|[,;[:space:]])combat[[:space:]]+reflexesb?([,;[:space:]]|$)';
  end if;

  if p_actor_flat_footed and not v_has_combat_reflexes then
    raise exception 'Este combatente está surpreso/desprevenido e não possui Reflexos de Combate para reagir.';
  end if;
  if v_has_combat_reflexes then
    v_limit:=1+greatest(0,v_dex_mod);
  end if;

  select * into v_existing
  from priv.srd_aoo_reaction_ledger
  where campaign_id=p_campaign_id and combat_phase=v_phase and combat_round=v_round
    and actor_token_id=btrim(p_actor_token_id) and trigger_key=btrim(p_trigger_key);
  if found then
    return jsonb_build_object('reserved',true,'duplicate',true,
      'reaction_id',v_existing.reaction_id,'round',v_round,
      'used',v_existing.reaction_number,'limit',v_existing.max_reactions,
      'combat_reflexes',v_has_combat_reflexes,'dexterity_modifier',v_dex_mod);
  end if;

  select count(*)::integer into v_used
  from priv.srd_aoo_reaction_ledger
  where campaign_id=p_campaign_id and combat_phase=v_phase and combat_round=v_round
    and actor_token_id=btrim(p_actor_token_id);
  if v_used>=v_limit then
    raise exception 'Limite de ataques de oportunidade atingido nesta rodada (%/%).',v_used,v_limit;
  end if;

  insert into priv.srd_aoo_reaction_ledger(
    campaign_id,combat_phase,combat_round,actor_token_id,trigger_key,reaction_number,max_reactions
  ) values (
    p_campaign_id,v_phase,v_round,btrim(p_actor_token_id),btrim(p_trigger_key),v_used+1,v_limit
  ) returning * into v_new;

  return jsonb_build_object('reserved',true,'duplicate',false,
    'reaction_id',v_new.reaction_id,'round',v_round,
    'used',v_new.reaction_number,'limit',v_limit,
    'combat_reflexes',v_has_combat_reflexes,'dexterity_modifier',v_dex_mod,
    'flat_footed_allowed',v_has_combat_reflexes);
end;
$function$;
revoke all on function public.srd_reservar_ataque_oportunidade_srd(bigint,text,text,boolean) from public,anon;
grant execute on function public.srd_reservar_ataque_oportunidade_srd(bigint,text,text,boolean) to authenticated;
