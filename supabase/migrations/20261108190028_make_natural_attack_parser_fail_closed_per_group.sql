
create or replace function priv.srd_parse_natural_attack_list(p_attack_text text)
returns jsonb language plpgsql immutable security invoker
set search_path = pg_catalog, public, priv
as $function$
declare
  v_part text; v_match text[]; v_result jsonb := '[]'::jsonb;
  v_index integer := 0; v_name text; v_count integer; v_bonus integer;
  v_damage text; v_flat integer; v_extra text; v_natural boolean;
begin
  if nullif(btrim(p_attack_text),'') is null then return v_result; end if;
  foreach v_part in array regexp_split_to_array(btrim(p_attack_text), '[[:space:]]+and[[:space:]]+')
  loop
    v_index:=v_index+1;
    v_match:=regexp_match(btrim(v_part),
      '^([0-9]+[[:space:]]+)?([[:alpha:]][[:alpha:]'' -]*?)[[:space:]]+([+-][0-9]+(/[+-]?[0-9]+)*)[[:space:]]+melee[[:space:]]+\(([0-9]+d[0-9]+)([+-][0-9]+)?([^)]*)\)[[:space:]]*$','i');
    if v_match is null then
      v_result:=v_result||jsonb_build_array(jsonb_build_object(
        'index',v_index,'is_natural',false,'parse_supported',false,
        'attack_group_text',btrim(v_part),'warning','unsupported_statblock_attack_syntax'));
      continue;
    end if;
    v_count:=coalesce(nullif(btrim(v_match[1]),'')::integer,1);
    v_name:=btrim(v_match[2]); v_bonus:=split_part(v_match[3],'/',1)::integer;
    v_damage:=v_match[5]||coalesce(v_match[6],'');
    v_flat:=coalesce(nullif(v_match[6],'')::integer,0);
    v_extra:=nullif(btrim(v_match[7]),'');
    v_natural:=lower(v_name) ~
      '^(bite|claw|claws|tentacle|tentacles|slam|slams|gore|sting|tail|tail slap|wing|wings|hoof|hooves|talon|talons|rake|rakes|pseudopod|pseudopods|slam attack|constrict|incorporeal touch|touch|spike|spikes|stomp|stinger|beak|fist|fists|horn|horns|trample|rend|swallow whole)$';
    if v_count<1 or v_count>20 or v_damage !~ '^[0-9]+d[0-9]+([+-][0-9]+)?$' then
      v_result:=v_result||jsonb_build_array(jsonb_build_object(
        'index',v_index,'is_natural',false,'parse_supported',false,
        'attack_group_text',btrim(v_part),'warning','invalid_attack_metadata'));
      continue;
    end if;
    v_result:=v_result||jsonb_build_array(jsonb_build_object(
      'index',v_index,'name',v_name,'count',v_count,'attack_bonus',v_bonus,
      'attack_bonus_progression',v_match[3],'damage_expression',v_damage,
      'damage_flat',v_flat,'additional_effect',v_extra,'is_natural',v_natural,
      'parse_supported',true,'attack_group_text',btrim(v_part)));
  end loop;
  return v_result;
end;
$function$;
