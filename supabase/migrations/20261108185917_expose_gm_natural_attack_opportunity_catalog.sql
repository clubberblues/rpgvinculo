
create or replace function public.srd_listar_ataques_naturais_oportunidade_srd(
  p_campaign_id bigint,
  p_reactor_token_id text
) returns jsonb
language plpgsql
security invoker
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_campaign public.campaigns%rowtype;
  v_token jsonb;
  v_count integer;
  v_profile jsonb;
  v_attack_text text;
  v_attacks jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar ataques naturais de oportunidade.';
  end if;
  if nullif(btrim(p_reactor_token_id),'') is null then
    raise exception 'Token atacante obrigatório.';
  end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id;
  if not found then raise exception 'Campanha não encontrada.'; end if;
  select count(*)::integer,(array_agg(t))[1] into v_count,v_token
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id);
  if v_count<>1 then raise exception 'Token ausente ou duplicado na cena.'; end if;
  if v_token->>'tipo' not in ('npc','monstro') then
    raise exception 'A consulta é destinada a NPCs e monstros.';
  end if;
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  if nullif(v_profile->>'character_id','') is not null then
    return jsonb_build_object('available',false,'reason','linked_character_requires_character_attack_catalog',
      'source_character_id',v_profile->>'character_id','attacks','[]'::jsonb);
  end if;
  v_attack_text:=coalesce(
    nullif(v_token->'monsterStats'->>'ataques',''),
    nullif(v_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'full_attack',''),
    nullif(v_token->'monsterStats'->>'full_attack',''),
    nullif(v_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'attack',''),
    nullif(v_token->'monsterStats'->>'attack','')
  );
  v_attacks:=priv.srd_parse_natural_attack_list(v_attack_text);
  return jsonb_build_object('available',jsonb_array_length(v_attacks)>0,
    'token_id',btrim(p_reactor_token_id),'source','monsterStats',
    'source_text',v_attack_text,'attacks',v_attacks,
    'selection_required',jsonb_array_length(v_attacks)>1);
end;
$function$;
revoke all on function public.srd_listar_ataques_naturais_oportunidade_srd(bigint,text) from public, anon;
grant execute on function public.srd_listar_ataques_naturais_oportunidade_srd(bigint,text) to authenticated;
