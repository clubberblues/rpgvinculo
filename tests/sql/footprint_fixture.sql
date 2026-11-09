-- Minimal synthetic schema for the current remote footprint helper.
-- Snapshot date: 2026-11-09. Not a production migration.
CREATE SCHEMA IF NOT EXISTS priv;

DROP TABLE IF EXISTS public.srd_character_sheets;
DROP TABLE IF EXISTS public.srd_races;
DROP TABLE IF EXISTS public.campaigns;

CREATE TABLE public.campaigns (
  id bigint PRIMARY KEY,
  cba_data jsonb
);

CREATE TABLE public.srd_races (
  id text PRIMARY KEY,
  tamanho text
);

CREATE TABLE public.srd_character_sheets (
  character_id text PRIMARY KEY,
  raca_id text
);

CREATE OR REPLACE FUNCTION public.srd35_normalizar_parametro_talento(p_text text)
RETURNS text
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
SET search_path TO 'public', 'pg_temp'
AS $function$
  WITH n AS (
    SELECT regexp_replace(
      lower(translate(COALESCE(p_text,''),'ÁÀÂÃÉÊÍÓÔÕÚÜÇáàâãéêíóôõúüç','AAAAEEIOOOUUCaaaaeeiooouuc')),
      '[^a-z0-9]+','','g'
    ) AS value
  )
  SELECT CASE value
    WHEN 'conjuracao' THEN 'conjuration'
    WHEN 'conjuration' THEN 'conjuration'
    WHEN 'abjuracao' THEN 'abjuration'
    WHEN 'abjuration' THEN 'abjuration'
    WHEN 'adivinhacao' THEN 'divination'
    WHEN 'divination' THEN 'divination'
    WHEN 'encantamento' THEN 'enchantment'
    WHEN 'enchantment' THEN 'enchantment'
    WHEN 'invocacao' THEN 'evocation'
    WHEN 'evocation' THEN 'evocation'
    WHEN 'ilusao' THEN 'illusion'
    WHEN 'illusion' THEN 'illusion'
    WHEN 'necromancia' THEN 'necromancy'
    WHEN 'necromancy' THEN 'necromancy'
    WHEN 'transmutacao' THEN 'transmutation'
    WHEN 'transmutation' THEN 'transmutation'
    WHEN 'espadabastarda' THEN 'bastardsword'
    WHEN 'bastardsword' THEN 'bastardsword'
    WHEN 'machadodeguerraaanao' THEN 'dwarvenwaraxe'
    WHEN 'machadodeguerraanao' THEN 'dwarvenwaraxe'
    WHEN 'dwarvenwaraxe' THEN 'dwarvenwaraxe'
    WHEN 'waraxedwarven' THEN 'dwarvenwaraxe'
    WHEN 'urgroshdwarven' THEN 'dwarvenurgrosh'
    WHEN 'dwarvenurgrosh' THEN 'dwarvenurgrosh'
    WHEN 'urgroshanao' THEN 'dwarvenurgrosh'
    WHEN 'espadalonga' THEN 'longsword'
    WHEN 'longsword' THEN 'longsword'
    ELSE value
  END
  FROM n
$function$;

CREATE OR REPLACE FUNCTION priv.srd_token_grid_footprint(p_campaign_id bigint, p_token_id text)
RETURNS integer
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_token jsonb; v_count integer; v_type text; v_size text;
begin
  select count(*)::integer,(array_agg(t))[1] into v_count,v_token
  from jsonb_array_elements(coalesce((select cba_data->'tokens' from public.campaigns where id=p_campaign_id),'[]'::jsonb)) t
  where t->>'id'=btrim(p_token_id) or t->>'key'=btrim(p_token_id);
  if v_count<>1 then raise exception 'Token inexistente ou duplicado ao calcular ocupação na grade.'; end if;
  v_type:=v_token->>'tipo';
  select coalesce(nullif(v_token->'monsterStats'->>'tamanho',''),
                  nullif(v_token->'monsterStats'->>'size',''),
                  nullif(v_token->>'tamanho',''),
                  nullif(v_token->>'size',''),
                  r.tamanho,'Médio')
  into v_size
  from (select 1) seed
  left join lateral (
    select sr.tamanho
    from public.srd_character_sheets sh
    join public.srd_races sr on sr.id::text=sh.raca_id::text
    where sh.character_id::text=coalesce(nullif(v_token->>'sourceCharacterId',''),
      case when v_type='player' then v_token->>'id' end)
    limit 1
  ) r on true;
  v_size:=public.srd35_normalizar_parametro_talento(coalesce(v_size,'medio'));
  return case
    when v_size like 'colossal%' then 6
    when v_size like 'gargantuan%' or v_size like 'imenso%' then 4
    when v_size like 'huge%' or v_size like 'enorme%' then 3
    when v_size like 'large%' or v_size like 'grande%' then 2
    else 1 end;
end;
$function$;
