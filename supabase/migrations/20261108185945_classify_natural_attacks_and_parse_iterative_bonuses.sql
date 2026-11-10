
create or replace function priv.srd_parse_natural_attack_list(p_attack_text text)
returns jsonb
language plpgsql
immutable
security invoker
set search_path = pg_catalog, public, priv
as $function$
declare
  v_part text;
  v_match text[];
  v_result jsonb := '[]'::jsonb;
  v_index integer := 0;
  v_name text;
  v_count integer;
  v_bonus integer;
  v_damage text;
  v_flat integer;
  v_extra text;
  v_natural boolean;
begin
  if nullif(btrim(p_attack_text),'') is null then return v_result; end if;
  foreach v_part in array regexp_split_to_array(btrim(p_attack_text), '[[:space:]]+and[[:space:]]+')
  loop
    v_match := regexp_match(btrim(v_part),
      '^([0-9]+[[:space:]]+)?([[:alpha:]][[:alpha:]'' -]*?)[[:space:]]+([+-][0-9]+(/[+-]?[0-9]+)*)[[:space:]]+melee[[:space:]]+\(([0-9]+d[0-9]+)([+-][0-9]+)?([^)]*)\)[[:space:]]*$',
      'i');
    if v_match is null then
      raise exception 'Grupo de ataque natural não reconhecido: %', v_part;
    end if;
    v_count := coalesce(nullif(btrim(v_match[1]),'')::integer,1);
    v_name := btrim(v_match[2]);
    v_bonus := split_part(v_match[3],'/',1)::integer;
    v_damage := v_match[5] || coalesce(v_match[6],'');
    v_flat := coalesce(nullif(v_match[6], '')::integer,0);
    v_extra := nullif(btrim(v_match[7]),'');
    v_natural := lower(v_name) ~
      '^(bite|claw|claws|tentacle|tentacles|slam|slams|gore|sting|tail|tail slap|wing|wings|hoof|hooves|talon|talons|rake|rakes|pseudopod|pseudopods|slam attack|constrict|incorporeal touch|touch|spike|spikes|stomp|stinger|beak|fist|fists|horn|horns|trample|rend|swallow whole)$';
    if v_count<1 or v_count>20 or v_damage !~ '^[0-9]+d[0-9]+([+-][0-9]+)?$' then
      raise exception 'Metadados de ataque natural fora dos limites: %',v_part;
    end if;
    v_index := v_index+1;
    v_result := v_result || jsonb_build_array(jsonb_build_object(
      'index',v_index,'name',v_name,'count',v_count,'attack_bonus',v_bonus,
      'attack_bonus_progression',v_match[3],'damage_expression',v_damage,
      'damage_flat',v_flat,'additional_effect',v_extra,'is_natural',v_natural,
      'attack_group_text',btrim(v_part)
    ));
  end loop;
  return v_result;
end;
$function$;

create or replace function public.srd_listar_ataques_naturais_oportunidade_srd(
  p_campaign_id bigint,p_reactor_token_id text
) returns jsonb
language plpgsql security invoker
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_campaign public.campaigns%rowtype;
  v_token jsonb;
  v_count integer;
  v_profile jsonb;
  v_attack_text text;
  v_all jsonb;
  v_attacks jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar ataques naturais de oportunidade.';
  end if;
  if nullif(btrim(p_reactor_token_id),'') is null then raise exception 'Token atacante obrigatório.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id;
  if not found then raise exception 'Campanha não encontrada.'; end if;
  select count(*)::integer,(array_agg(t))[1] into v_count,v_token
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id);
  if v_count<>1 then raise exception 'Token ausente ou duplicado na cena.'; end if;
  if v_token->>'tipo' not in ('npc','monstro') then raise exception 'A consulta é destinada a NPCs e monstros.'; end if;
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
    nullif(v_token->'monsterStats'->>'attack',''));
  v_all:=priv.srd_parse_natural_attack_list(v_attack_text);
  select coalesce(jsonb_agg(a.value order by (a.value->>'index')::integer),'[]'::jsonb)
    into v_attacks from jsonb_array_elements(v_all) a(value)
    where coalesce((a.value->>'is_natural')::boolean,false);
  return jsonb_build_object('available',jsonb_array_length(v_attacks)>0,
    'token_id',btrim(p_reactor_token_id),'source','monsterStats','source_text',v_attack_text,
    'attacks',v_attacks,'selection_required',jsonb_array_length(v_attacks)>1);
end;
$function$;
revoke all on function priv.srd_parse_natural_attack_list(text) from public, anon, authenticated;
grant execute on function priv.srd_parse_natural_attack_list(text) to postgres, service_role;
revoke all on function public.srd_listar_ataques_naturais_oportunidade_srd(bigint,text) from public, anon;
grant execute on function public.srd_listar_ataques_naturais_oportunidade_srd(bigint,text) to authenticated;
