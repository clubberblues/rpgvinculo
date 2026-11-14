
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
begin
  if nullif(btrim(p_attack_text),'') is null then
    return v_result;
  end if;
  -- O statblock SRD separa grupos de ataques por "and"; cada grupo
  -- mantém sua quantidade, bônus, dano e efeitos adicionais.
  foreach v_part in array regexp_split_to_array(btrim(p_attack_text), '[[:space:]]+and[[:space:]]+')
  loop
    v_match := regexp_match(btrim(v_part),
      '^([0-9]+[[:space:]]+)?([[:alpha:]][[:alpha:]'' -]*?)[[:space:]]+([+-][0-9]+)[[:space:]]+melee[[:space:]]+\(([0-9]+d[0-9]+)([+-][0-9]+)?([^)]*)\)[[:space:]]*$',
      'i');
    if v_match is null then
      -- Sem correspondência inequívoca: não inventar nem descartar silenciosamente.
      raise exception 'Grupo de ataque natural não reconhecido: %', v_part;
    end if;
    v_count := coalesce(nullif(btrim(v_match[1]),'')::integer,1);
    v_name := btrim(v_match[2]);
    v_bonus := v_match[3]::integer;
    v_damage := v_match[4] || coalesce(v_match[5],'');
    v_flat := coalesce(nullif(v_match[5], '')::integer,0);
    v_extra := nullif(btrim(v_match[6]),'');
    if v_count<1 or v_count>20 or v_damage !~ '^[0-9]+d[0-9]+([+-][0-9]+)?$' then
      raise exception 'Metadados de ataque natural fora dos limites: %',v_part;
    end if;
    v_index := v_index+1;
    v_result := v_result || jsonb_build_array(jsonb_build_object(
      'index',v_index,'name',v_name,'count',v_count,'attack_bonus',v_bonus,
      'damage_expression',v_damage,'damage_flat',v_flat,
      'additional_effect',v_extra,'attack_group_text',btrim(v_part)
    ));
  end loop;
  return v_result;
end;
$function$;

revoke all on function priv.srd_parse_natural_attack_list(text) from public, anon, authenticated;
grant execute on function priv.srd_parse_natural_attack_list(text) to postgres, service_role;
