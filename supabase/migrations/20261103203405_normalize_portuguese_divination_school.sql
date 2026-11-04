create or replace function public._srd35_school_key(p_school text)
returns text language sql immutable set search_path=pg_catalog
as $function$
select case
when lower(coalesce(p_school,'')) like 'abjur%' then 'abjuration'
when lower(coalesce(p_school,'')) like 'conjur%' then 'conjuration'
when lower(coalesce(p_school,'')) like 'divin%' or lower(coalesce(p_school,'')) like 'adivin%' then 'divination'
when lower(coalesce(p_school,'')) like 'enchant%' or lower(coalesce(p_school,'')) like 'encant%' then 'enchantment'
when lower(coalesce(p_school,'')) like 'evoc%' then 'evocation'
when lower(coalesce(p_school,'')) like 'illus%' then 'illusion'
when lower(coalesce(p_school,'')) like 'necrom%' then 'necromancy'
when lower(coalesce(p_school,'')) like 'transmut%' then 'transmutation'
when lower(coalesce(p_school,'')) like 'universal%' then 'universal'
else null end
$function$;