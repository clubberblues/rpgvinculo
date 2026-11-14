create or replace function private.consultar_inventario_npc_vinculado_impl(
  p_campaign_id bigint,
  p_token_id text
) returns jsonb
language plpgsql
security definer
set search_path = pg_catalog, public, pg_temp
as $$
declare
  v_campaign public.campaigns%rowtype;
  v_token jsonb;
  v_character_id text;
  v_owner uuid;
  v_items jsonb;
  v_instances jsonb;
  v_attributes jsonb;
  v_race_id text;
  v_level integer;
begin
  if auth.uid() is null then raise exception 'Autenticação obrigatória.'; end if;
  if public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar o inventário de NPC vinculado.';
  end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id;
  if not found then raise exception 'Campanha não encontrada.'; end if;
  select t.value into v_token
  from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t(value)
  where t.value->>'id'=btrim(p_token_id) and t.value->>'tipo'='npc'
  limit 1;
  if v_token is null or nullif(v_token->>'sourceCharacterId','') is null then
    raise exception 'NPC não está vinculado a uma ficha de personagem.';
  end if;
  v_character_id:=v_token->>'sourceCharacterId';
  select ch.user_id into v_owner from public.characters ch where ch.id::text=v_character_id;
  if not found or not exists (
    select 1 from public.members gm
    where gm.campaign_id=p_campaign_id and gm.user_id=v_owner and gm.role='GM'
  ) then raise exception 'A ficha vinculada não pertence ao Mestre desta campanha.'; end if;
  select sh.atributos,sh.raca_id,sh.nivel
    into v_attributes,v_race_id,v_level
  from public.srd_character_sheets sh
  where sh.character_id::text=v_character_id;
  if not found then raise exception 'Ficha SRD vinculada não encontrada.'; end if;
  select coalesce(jsonb_agg(
    jsonb_build_object('equipment_id',ce.equipment_id,'quantidade',ce.quantidade,
      'equipado',ce.equipado,'equipment',to_jsonb(eq))
    order by eq.nome
  ),'[]'::jsonb) into v_items
  from public.srd_character_equipment ce
  join public.srd_equipment eq on eq.id=ce.equipment_id
  where ce.character_id=v_character_id;
  select coalesce(jsonb_agg(
    jsonb_build_object('instance_id',wi.instance_id,'equipment_id',wi.equipment_id,
      'equipado',wi.equipado,'hand_slot',wi.hand_slot)
    order by wi.created_at,wi.instance_id
  ),'[]'::jsonb) into v_instances
  from public.srd_character_weapon_instances wi
  where wi.character_id=v_character_id;
  return jsonb_build_object('character_id',v_character_id,'attributes',coalesce(v_attributes,'{}'::jsonb),
    'race_id',v_race_id,'level',v_level,'items',v_items,'weapon_instances',v_instances);
end;
$$;
revoke all on function private.consultar_inventario_npc_vinculado_impl(bigint,text) from public, anon;
grant execute on function private.consultar_inventario_npc_vinculado_impl(bigint,text) to authenticated;