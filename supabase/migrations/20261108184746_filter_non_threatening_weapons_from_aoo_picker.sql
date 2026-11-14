CREATE OR REPLACE FUNCTION public.srd_consultar_armas_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_reaction jsonb;
  v_profile jsonb;
  v_character_id bigint;
  v_weapons jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar armas para a reação.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'Movimento pendente não encontrado ou encerrado.';
  end if;
  select value into v_reaction
  from jsonb_array_elements(v_pending.pending_reactions)
  where value->>'reactor_token_id'=btrim(p_reactor_token_id)
    and value->>'status'='reserved'
  limit 1;
  if v_reaction is null then raise exception 'O combatente ainda não possui reação reservada.'; end if;
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  v_character_id:=nullif(v_profile->>'character_id','')::bigint;
  if v_character_id is null then
    return jsonb_build_object('eligible_for_automated_attack',false,
      'reason','unlinked_creature_requires_gm_adjudication','weapons','[]'::jsonb);
  end if;
  select coalesce(jsonb_agg(jsonb_build_object(
    'instance_id',wi.instance_id,'equipment_id',eq.id,
    'name',eq.nome,'hand_slot',wi.hand_slot,'damage',eq.dano,
    'critical',coalesce(eq.detalhes->>'critical',eq.critico,'x2'),
    'weapon_end_main',eq.detalhes->'weapon_end_main',
    'weapon_end_off',eq.detalhes->'weapon_end_off',
    'weapon_double',coalesce((eq.detalhes->>'weapon_double')::boolean,false),
    'weapon_reach_ft',coalesce(nullif(eq.detalhes->>'reach_ft','')::integer,5),
    'weapon_threat_min_ft',coalesce(nullif(eq.detalhes->>'threat_min_ft','')::integer,5),
    'weapon_threatens_squares',coalesce((eq.detalhes->>'threatens_squares')::boolean,true),
    'damage_type',eq.tipo_dano
  ) order by case wi.hand_slot when 'main_hand' then 1 else 2 end,eq.nome),'[]'::jsonb)
  into v_weapons
  from public.srd_character_weapon_instances wi
  join public.srd_equipment eq on eq.id=wi.equipment_id
  join public.srd_character_equipment ce
    on ce.character_id=v_character_id::text and ce.equipment_id=wi.equipment_id
    and ce.equipado is true and ce.hand_slot=wi.hand_slot
  where wi.character_id=v_character_id::text and wi.equipado is true
    and wi.hand_slot in ('main_hand','off_hand')
    and coalesce(eq.detalhes->>'weapon_melee','true')<>'false'
    and coalesce((eq.detalhes->>'threatens_squares')::boolean,true) IS TRUE;
  return jsonb_build_object('eligible_for_automated_attack',jsonb_array_length(v_weapons)>0,
    'character_id',v_character_id,'weapons',v_weapons,
    'note',case when jsonb_array_length(v_weapons)=0
      then 'Sem arma corpo a corpo equipada; a resolução manual pelo Mestre ainda é necessária.'
      else null end);
end;
$function$
;
REVOKE ALL ON FUNCTION public.srd_consultar_armas_aoo_srd(bigint,uuid,text) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.srd_consultar_armas_aoo_srd(bigint,uuid,text) TO authenticated;