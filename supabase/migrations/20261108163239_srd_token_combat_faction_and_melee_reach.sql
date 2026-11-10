
create or replace function public.srd_configurar_perfil_combate_token_srd(
  p_campaign_id bigint,
  p_token_id text,
  p_combat_faction text,
  p_melee_reach_ft integer
)
returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, pg_temp
as $function$
declare
  v_campaign public.campaigns%rowtype;
  v_tokens jsonb;
  v_token jsonb;
  v_count integer;
  v_index bigint;
  v_faction text;
  v_reach integer;
  v_new_token jsonb;
  v_new_scene jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode configurar o perfil de combate dos tokens.';
  end if;
  if nullif(btrim(p_token_id),'') is null then
    raise exception 'O identificador do token é obrigatório.';
  end if;

  v_faction := lower(btrim(coalesce(p_combat_faction,'')));
  if v_faction not in ('ally','hostile','neutral') then
    raise exception 'Facção inválida. Use ally, hostile ou neutral.';
  end if;
  if p_melee_reach_ft is null or p_melee_reach_ft < 0 or p_melee_reach_ft > 100 then
    raise exception 'O alcance corpo a corpo deve estar entre 0 e 100 pés.';
  end if;

  select * into v_campaign
  from public.campaigns
  where id=p_campaign_id
  for update;
  if not found then raise exception 'Campanha não encontrada.'; end if;

  v_tokens := case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end;
  select count(*)::integer, min(x.ordinality), (array_agg(x.token))[1]
    into v_count, v_index, v_token
  from jsonb_array_elements(v_tokens) with ordinality x(token,ordinality)
  where x.token->>'id'=btrim(p_token_id) or x.token->>'key'=btrim(p_token_id);

  if v_count <> 1 then
    raise exception 'Token inexistente ou duplicado na cena.';
  end if;

  v_new_token := v_token || jsonb_build_object(
    'combat_faction',v_faction,
    'melee_reach_ft',p_melee_reach_ft,
    'combat_profile_configured',true
  );
  v_new_scene := coalesce(v_campaign.cba_data,'{}'::jsonb) ||
    jsonb_build_object('tokens',jsonb_set(v_tokens,array[(v_index-1)::text],v_new_token,false));

  update public.campaigns set cba_data=v_new_scene where id=p_campaign_id;

  return jsonb_build_object(
    'token_id',v_token->>'id',
    'combat_faction',v_faction,
    'melee_reach_ft',p_melee_reach_ft,
    'combat_profile_configured',true,
    'cba_data',v_new_scene
  );
end;
$function$;

revoke all on function public.srd_configurar_perfil_combate_token_srd(bigint,text,text,integer) from public, anon;
grant execute on function public.srd_configurar_perfil_combate_token_srd(bigint,text,text,integer) to authenticated;
