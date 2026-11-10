
create or replace function public.aplicar_dano_ataque_npc_gm_srd(
 p_campaign_id bigint,
 p_actor_token_id text,
 p_target_token_id text,
 p_raw_damage integer,
 p_damage_type text default 'untyped'
) returns jsonb
language plpgsql
security definer
set search_path=pg_catalog,public,priv,pg_temp
as $function$
declare
 v_campaign public.campaigns%rowtype;
 v_order jsonb;
 v_actor jsonb;
 v_tokens jsonb;
 v_target jsonb;
 v_count integer;
 v_index bigint;
 v_kind text;
 v_damage_type text;
 v_damage integer;
 v_hp integer;
 v_max_hp integer;
 v_new_hp integer;
begin
 if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
  raise exception 'Somente o Mestre autenticado pode aplicar dano de NPC.';
 end if;
 if p_raw_damage is null or p_raw_damage<1 or p_raw_damage>1000 then
  raise exception 'Dano bruto inválido.';
 end if;
 v_damage_type:=lower(btrim(coalesce(p_damage_type,'untyped')));
 if v_damage_type not in ('slashing','piercing','bludgeoning','physical','untyped','fire','cold','electricity','acid','sonic','force','positive','negative') then
  raise exception 'Tipo de dano inválido.';
 end if;
 select * into v_campaign from public.campaigns where id=p_campaign_id for update;
 if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
   or coalesce(v_campaign.combat_data->>'active','false')<>'true' then
  raise exception 'A campanha não está em combate ativo.';
 end if;
 v_order:=case when jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
  then v_campaign.combat_data->'turn_order' else '[]'::jsonb end;
 if coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$' then
  raise exception 'Turno atual inválido.';
 end if;
 v_actor:=v_order->(v_campaign.combat_data->>'current_turn')::integer;
 if v_actor->>'id' is distinct from btrim(p_actor_token_id)
   or coalesce(v_actor->>'is_monster','false')<>'true' then
  raise exception 'O token atacante não pertence ao turno atual do Mestre.';
 end if;
 v_tokens:=case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
  then v_campaign.cba_data->'tokens' else '[]'::jsonb end;
 select count(*)::integer,min(t.ordinality),min(t.token)
 into v_count,v_index,v_target
 from jsonb_array_elements(v_tokens) with ordinality t(token,ordinality)
 where t.token->>'id'=btrim(p_target_token_id)
  and coalesce(t.token->>'tipo','') in ('player','npc','monstro');
 if v_count<>1 then raise exception 'O alvo não foi encontrado ou está duplicado na cena.'; end if;
 v_kind:=v_target->>'tipo';
 if v_kind='player' then
  select sh.pv_atual,sh.pv_max into v_hp,v_max_hp
  from public.characters ch
  join public.members m on m.campaign_id=ch.campaign_id and m.user_id=ch.user_id and m.role='PLAYER'
  join public.srd_character_sheets sh on sh.character_id=ch.id
  where ch.id::text=btrim(p_target_token_id) and ch.campaign_id=p_campaign_id
  for update of sh;
  if not found or v_max_hp is null or v_max_hp<1 then
   raise exception 'Ficha do personagem alvo não encontrada ou sem PV máximos válidos.';
  end if;
  v_damage:=priv.srd_adjust_damage(p_campaign_id,'character',btrim(p_target_token_id),v_damage_type,p_raw_damage);
  v_new_hp:=greatest(-10,least(v_max_hp,coalesce(v_hp,v_max_hp)-v_damage));
  perform priv.srd_sync_character_vital_condition(btrim(p_target_token_id),v_new_hp,false);
  update public.srd_character_sheets set pv_atual=v_new_hp
   where character_id::text=btrim(p_target_token_id);
  return jsonb_build_object('target_kind','character','target_id',p_target_token_id,
   'damage_raw',p_raw_damage,'damage_applied',v_damage,'damage_type',v_damage_type,
   'pv_atual',v_new_hp,'pv_max',v_max_hp);
 end if;
 if coalesce(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' then
  raise exception 'O alvo NPC/monstro não possui PV máximos válidos.';
 end if;
 v_max_hp:=(v_target->>'maxHp')::integer;
 if coalesce(v_target->>'hp','') !~ '^[0-9]{1,6}$' then
  raise exception 'O alvo NPC/monstro não possui PV atuais válidos.';
 end if;
 v_hp:=(v_target->>'hp')::integer;
 v_damage:=priv.srd_adjust_damage(p_campaign_id,'token',btrim(p_target_token_id),v_damage_type,p_raw_damage);
 v_new_hp:=greatest(0,least(v_max_hp,v_hp-v_damage));
 v_target:=v_target||jsonb_build_object('hp',v_new_hp,'maxHp',v_max_hp);
 v_tokens:=jsonb_set(v_tokens,array[(v_index-1)::text],v_target,false);
 update public.campaigns set cba_data=coalesce(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens)
 where id=p_campaign_id;
 return jsonb_build_object('target_kind','token','target_id',p_target_token_id,
  'damage_raw',p_raw_damage,'damage_applied',v_damage,'damage_type',v_damage_type,
  'hp',v_new_hp,'max_hp',v_max_hp,
  'cba_data',(select cba_data from public.campaigns where id=p_campaign_id));
end;
$function$;
revoke all on function public.aplicar_dano_ataque_npc_gm_srd(bigint,text,text,integer,text) from public,anon;
grant execute on function public.aplicar_dano_ataque_npc_gm_srd(bigint,text,text,integer,text) to authenticated;
