
create or replace function priv.srd_parse_natural_attack_list(p_attack_text text)
returns jsonb language plpgsql immutable security invoker
set search_path = pg_catalog, public, priv
as $function$
declare
  v_part text; v_match text[]; v_result jsonb := '[]'::jsonb;
  v_index integer := 0; v_name text; v_count integer; v_bonus integer;
  v_damage text; v_flat integer; v_extra text; v_natural boolean;
  v_crit_match text[]; v_crit_min integer; v_crit_mult integer;
begin
  if nullif(btrim(p_attack_text),'') is null then return v_result; end if;
  foreach v_part in array regexp_split_to_array(btrim(p_attack_text),
    ',[[:space:]]+and[[:space:]]+|[[:space:]]+and[[:space:]]+|;[[:space:]]+or[[:space:]]+|[[:space:]]+or[[:space:]]+')
  loop
    v_part:=btrim(v_part, E' \t\n\r,;');
    if v_part='' then continue; end if;
    v_index:=v_index+1;
    v_match:=regexp_match(v_part,
      '^([0-9]+[[:space:]]+)?([[:alpha:]][[:alpha:]'' -]*?)[[:space:]]+([+-][0-9]+(/[+-]?[0-9]+)*)[[:space:]]+melee[[:space:]]+\(([0-9]+d[0-9]+)([+-][0-9]+)?([^)]*)\)$','i');
    if v_match is null then
      v_result:=v_result||jsonb_build_array(jsonb_build_object(
        'index',v_index,'is_natural',false,'parse_supported',false,
        'attack_group_text',v_part,'warning','unsupported_statblock_attack_syntax'));
      continue;
    end if;
    v_count:=coalesce(nullif(btrim(v_match[1]),'')::integer,1);
    v_name:=btrim(v_match[2]); v_bonus:=split_part(v_match[3],'/',1)::integer;
    v_damage:=v_match[5]||coalesce(v_match[6],'');
    v_flat:=coalesce(nullif(v_match[6],'')::integer,0);
    v_extra:=nullif(btrim(v_match[7]),'');
    v_natural:=lower(v_name) ~
      '^(bite|claw|claws|tentacle|tentacles|slam|slams|gore|sting|tail|tail slap|wing|wings|hoof|hooves|talon|talons|rake|rakes|pseudopod|pseudopods|slam attack|constrict|incorporeal touch|touch|spike|spikes|stomp|stinger|beak|fist|fists|horn|horns|trample|rend|swallow whole)$';
    v_crit_min:=20; v_crit_mult:=2;
    v_crit_match:=regexp_match(coalesce(v_extra,''),'([0-9]{2})(?:-([0-9]{2}))?/x([2-5])','i');
    if v_crit_match is not null then
      v_crit_min:=v_crit_match[1]::integer;
      v_crit_mult:=v_crit_match[3]::integer;
      v_extra:=nullif(btrim(regexp_replace(v_extra,'[0-9]{2}(?:-[0-9]{2})?/x[2-5]','', 'i')),'');
    else
      v_crit_match:=regexp_match(coalesce(v_extra,''),'/x([2-5])','i');
      if v_crit_match is not null then
        v_crit_mult:=v_crit_match[1]::integer;
        v_extra:=nullif(btrim(regexp_replace(v_extra,'/x[2-5]','', 'i')),'');
      end if;
    end if;
    if v_count<1 or v_count>20 or v_damage !~ '^[0-9]+d[0-9]+([+-][0-9]+)?$'
      or v_crit_min<2 or v_crit_min>20 then
      v_result:=v_result||jsonb_build_array(jsonb_build_object(
        'index',v_index,'is_natural',false,'parse_supported',false,
        'attack_group_text',v_part,'warning','invalid_attack_metadata'));
      continue;
    end if;
    v_result:=v_result||jsonb_build_array(jsonb_build_object(
      'index',v_index,'name',v_name,'count',v_count,'attack_bonus',v_bonus,
      'attack_bonus_progression',v_match[3],'damage_expression',v_damage,
      'damage_flat',v_flat,'additional_effect',v_extra,'is_natural',v_natural,
      'critical_threat_minimum',v_crit_min,'critical_multiplier',v_crit_mult,
      'parse_supported',true,'attack_group_text',v_part));
  end loop;
  return v_result;
end;
$function$;

create or replace function public.srd_iniciar_ataque_oportunidade_monstro_srd(
  p_campaign_id bigint,p_pending_id uuid,p_reactor_token_id text,
  p_reaction_id uuid,p_natural_attack_index integer
) returns jsonb
language plpgsql security definer
set search_path = pg_catalog, public, priv, pg_temp
as $function$
declare
  v_catalog jsonb; v_selected jsonb; v_started jsonb; v_attack_id uuid;
  v_damage_type text; v_attack_text text;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode iniciar um ataque natural de oportunidade.';
  end if;
  if p_natural_attack_index is null or p_natural_attack_index<1 then
    raise exception 'Selecione um grupo de ataque natural válido.';
  end if;
  v_catalog:=public.srd_listar_ataques_naturais_oportunidade_srd(p_campaign_id,btrim(p_reactor_token_id));
  if coalesce((v_catalog->>'available')::boolean,false) is not true then
    raise exception 'O token não possui ataques naturais catalogados: %',
      coalesce(v_catalog->>'reason','sem ataque natural válido');
  end if;
  select a.value into v_selected from jsonb_array_elements(coalesce(v_catalog->'attacks','[]'::jsonb)) a(value)
  where (a.value->>'index')::integer=p_natural_attack_index
    and coalesce((a.value->>'parse_supported')::boolean,false)
    and coalesce((a.value->>'is_natural')::boolean,false) limit 1;
  if v_selected is null then raise exception 'O grupo selecionado não existe ou não é um ataque natural suportado.'; end if;
  v_started:=public.srd_iniciar_ataque_oportunidade_monstro_srd(
    p_campaign_id,p_pending_id,p_reactor_token_id,p_reaction_id);
  v_attack_id:=nullif(v_started->>'attack_id','')::uuid;
  if v_attack_id is null then raise exception 'O fluxo legado não retornou um ataque válido.'; end if;
  v_attack_text:=v_catalog->>'source_text';
  select lower(coalesce(t->'monsterStats'->>'tipo_dano','physical')) into v_damage_type
  from public.campaigns c,lateral jsonb_array_elements(coalesce(c.cba_data->'tokens','[]'::jsonb)) t
  where c.id=p_campaign_id and (t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id))
  limit 1;
  update priv.srd_aoo_attacks
  set resolution_data=resolution_data||jsonb_build_object(
    'weapon_name',v_selected->>'name','natural_attack_index',p_natural_attack_index,
    'natural_attack_count',coalesce(nullif(v_selected->>'count','')::integer,1),
    'weapon_damage',v_selected->>'damage_expression','damage_expression',v_selected->>'damage_expression',
    'monster_attack_bonus',coalesce(nullif(v_selected->>'attack_bonus','')::integer,0),
    'natural_attack_bonus_progression',v_selected->>'attack_bonus_progression',
    'natural_attack_group_text',v_selected->>'attack_group_text',
    'natural_attack_additional_effect',v_selected->>'additional_effect',
    'natural_attack_source_text',v_attack_text,'natural_attack_selected',true,
    'damage_type',coalesce(v_damage_type,'physical'),
    'critical_threat_minimum',coalesce(nullif(v_selected->>'critical_threat_minimum','')::integer,20),
    'critical_multiplier',coalesce(nullif(v_selected->>'critical_multiplier','')::integer,2)
  )
  where attack_id=v_attack_id and campaign_id=p_campaign_id and created_by=auth.uid()
    and status='awaiting_attack_roll';
  if not found then raise exception 'Ataque não está mais aguardando rolagem manual.'; end if;
  return v_started||jsonb_build_object(
    'attack_id',v_attack_id,'weapon_name',v_selected->>'name',
    'natural_attack_index',p_natural_attack_index,
    'natural_attack_count',coalesce(nullif(v_selected->>'count','')::integer,1),
    'damage_expression',v_selected->>'damage_expression',
    'attack_bonus',coalesce(nullif(v_selected->>'attack_bonus','')::integer,0),
    'critical_threat_minimum',coalesce(nullif(v_selected->>'critical_threat_minimum','')::integer,20),
    'critical_multiplier',coalesce(nullif(v_selected->>'critical_multiplier','')::integer,2),
    'additional_effect',v_selected->>'additional_effect',
    'selected_natural_attack',v_selected,'awaiting_manual_d20',true
  );
end;
$function$;
revoke all on function public.srd_iniciar_ataque_oportunidade_monstro_srd(bigint,uuid,text,uuid,integer) from public,anon;
grant execute on function public.srd_iniciar_ataque_oportunidade_monstro_srd(bigint,uuid,text,uuid,integer) to authenticated;
