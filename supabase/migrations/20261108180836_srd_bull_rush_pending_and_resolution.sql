
create or replace function priv.srd_iniciar_encontrao_srd(
 p_campaign_id bigint,p_attacker_token_id text,p_defender_token_id text
) returns jsonb language plpgsql security definer
set search_path=pg_catalog,public,priv,pg_temp as $$
declare c public.campaigns%rowtype; calc jsonb; a jsonb; d jsonb;
 rid uuid:=gen_random_uuid(); rnd int; turnidx int; reach int:=5; dist int; prof jsonb; charid bigint;
 status text:='waiting'; triggerid text;
begin
 if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then raise exception 'Somente o Mestre pode iniciar Encontrão.'; end if;
 if coalesce(trim(p_attacker_token_id),'')='' or coalesce(trim(p_defender_token_id),'')='' or trim(p_attacker_token_id)=trim(p_defender_token_id) then raise exception 'Selecione atacante e defensor diferentes.'; end if;
 select * into c from public.campaigns where id=p_campaign_id for update;
 if not found or upper(coalesce(c.state,''))<>'COMBATE' or coalesce(c.combat_data->>'active','false')<>'true' then raise exception 'A iniciativa precisa estar ativa.'; end if;
 if coalesce(c.combat_data->'surprise'->>'phase','')='surprise_round' then raise exception 'Encontrão não pode ser iniciado durante a rodada surpresa.'; end if;
 if coalesce(c.combat_data->>'current_turn','') !~ '^[0-9]+$' then raise exception 'Turno inválido.'; end if;
 turnidx:=(c.combat_data->>'current_turn')::int;
 if c.combat_data->'turn_order'->turnidx->>'id' is distinct from trim(p_attacker_token_id) then raise exception 'O atacante precisa estar no turno ativo.'; end if;
 if exists(select 1 from priv.srd_aoo_pending_movements where campaign_id=p_campaign_id and status in ('waiting_reactions','ready_to_commit')) then raise exception 'Já existe reação de oportunidade pendente.'; end if;
 calc:=public.srd_consultar_modificadores_manobra_srd(p_campaign_id,p_attacker_token_id,p_defender_token_id,'bull_rush',false);
 select t into a from jsonb_array_elements(coalesce(c.cba_data->'tokens','[]'::jsonb)) t where t->>'id'=trim(p_attacker_token_id) or t->>'key'=trim(p_attacker_token_id) limit 1;
 select t into d from jsonb_array_elements(coalesce(c.cba_data->'tokens','[]'::jsonb)) t where t->>'id'=trim(p_defender_token_id) or t->>'key'=trim(p_defender_token_id) limit 1;
 if a is null or d is null then raise exception 'Atacante ou defensor ausente da cena.'; end if;
 if coalesce(a->>'gridX','') !~ '^[0-9]{1,3}$' or coalesce(a->>'gridY','') !~ '^[0-9]{1,3}$' or coalesce(d->>'gridX','') !~ '^[0-9]{1,3}$' or coalesce(d->>'gridY','') !~ '^[0-9]{1,3}$' then raise exception 'Posição inválida.'; end if;
 dist:=priv.srd_grid_footprint_distance_ft((a->>'gridX')::int,(a->>'gridY')::int,priv.srd_token_grid_footprint(p_campaign_id,p_attacker_token_id),(d->>'gridX')::int,(d->>'gridY')::int,priv.srd_token_grid_footprint(p_campaign_id,p_defender_token_id));
 prof:=priv.srd35_maneuver_profile(p_campaign_id,p_defender_token_id); charid:=nullif(prof->>'character_id','')::bigint;
 if charid is not null then
   select greatest(5,coalesce(max(nullif(eq.detalhes->>'reach_ft','')::int),5)) into reach
   from public.srd_character_weapon_instances wi join public.srd_equipment eq on eq.id=wi.equipment_id
   join public.srd_character_equipment ce on ce.character_id=wi.character_id and ce.equipment_id=wi.equipment_id and ce.equipado is true and ce.hand_slot=wi.hand_slot
   where wi.character_id=charid::text and wi.equipado is true and wi.hand_slot in ('main_hand','off_hand') and coalesce(eq.detalhes->>'weapon_melee','true')<>'false'
   and coalesce(eq.detalhes->>'reach_ft','') ~ '^[0-9]{1,3}$';
 else
   if coalesce(d->>'melee_reach_ft','') ~ '^[0-9]{1,3}$' then reach:=greatest(5,(d->>'melee_reach_ft')::int); end if;
 end if;
 if dist>5 then raise exception 'Encontrão exige alcance corpo a corpo adjacente (distância atual: % pés).',dist; end if;
 rnd:=greatest(1,coalesce(nullif(c.combat_data->>'round','')::int,1));
 triggerid:='bull_rush:'||rid::text;
 if calc->>'aoo_status'='suppressed_by_feat' then status:='ineligible'; end if;
 insert into priv.srd_aoo_pending_movements(pending_id,campaign_id,mover_token_id,movement_controller,destination_x,destination_y,origin_x,origin_y,combat_round,current_turn,turn_actor_id,threats,pending_reactions,status,created_by)
 values(rid,p_campaign_id,trim(p_attacker_token_id),'gm',(a->>'gridX')::int,(a->>'gridY')::int,(a->>'gridX')::int,(a->>'gridY')::int,rnd,turnidx,trim(p_attacker_token_id),
 jsonb_build_array(jsonb_build_object('maneuver_event','bull_rush','defender_token_id',trim(p_defender_token_id))),
 jsonb_build_array(jsonb_build_object('reactor_token_id',trim(p_defender_token_id),'trigger_key',triggerid,'status',status,'threat',jsonb_build_object('maneuver_event','bull_rush'))),'waiting_reactions',auth.uid());
 return jsonb_build_object('pending',true,'pending_id',rid,'maneuver','bull_rush','attacker_token_id',trim(p_attacker_token_id),'defender_token_id',trim(p_defender_token_id),'aoo_status',calc->>'aoo_status','modifiers',calc);
end $$;

create or replace function priv.srd_resolver_encontrao_srd(
 p_campaign_id bigint,p_pending_id uuid,p_attacker_d20 integer,p_defender_d20 integer,p_follow boolean default false
) returns jsonb language plpgsql security definer
set search_path=pg_catalog,public,priv,pg_temp as $$
declare p priv.srd_aoo_pending_movements%rowtype; c public.campaigns%rowtype; calc jsonb; tokens jsonb; a jsonb; d jsonb;
 ax int; ay int; dx int; dy int; sx int; sy int; steps int; i int; nx int; ny int; moved int:=0; blocked boolean:=false; footprint int; ft int;
 total_a int; total_d int; success boolean; rnd int; state jsonb; bychar jsonb; actions jsonb; vkey text; arr jsonb; idx int;
begin
 if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then raise exception 'Somente o Mestre pode resolver Encontrão.'; end if;
 if p_attacker_d20 not between 1 and 20 or p_defender_d20 not between 1 and 20 then raise exception 'Use resultados físicos de D20 entre 1 e 20.'; end if;
 select * into p from priv.srd_aoo_pending_movements where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
 if not found or p.status<>'waiting_reactions' or not (p.threats @> '[{"maneuver_event":"bull_rush"}]'::jsonb) then raise exception 'Encontrão pendente não encontrado.'; end if;
 if exists(select 1 from jsonb_array_elements(p.pending_reactions) r where r->>'status' in ('waiting','reserved','attack_started','hit_pending_damage')) then raise exception 'Resolva todas as reações antes do teste resistido.'; end if;
 select * into c from public.campaigns where id=p_campaign_id for update;
 if upper(coalesce(c.state,''))<>'COMBATE' or coalesce(c.combat_data->>'active','false')<>'true' or greatest(1,coalesce(nullif(c.combat_data->>'round','')::int,0))<>p.combat_round or coalesce(nullif(c.combat_data->>'current_turn','')::int,-1)<>p.current_turn then raise exception 'O turno ou a rodada mudou; manobra cancelada.'; end if;
 calc:=public.srd_consultar_modificadores_manobra_srd(p_campaign_id,p.mover_token_id,p.threats->0->>'defender_token_id','bull_rush',false);
 total_a:=p_attacker_d20+(calc->>'attacker_modifier')::int; total_d:=p_defender_d20+(calc->>'defender_modifier')::int; success:=total_a>total_d;
 rnd:=p.combat_round; vkey:=p.mover_token_id;
 state:=coalesce(c.combat_data->'action_economy','{}'::jsonb);
 if jsonb_typeof(state)='object' and coalesce(state->>'round','')=rnd::text then bychar:=coalesce(state->'by_character','{}'::jsonb); else bychar:='{}'::jsonb; end if;
 actions:=case when jsonb_typeof(bychar->vkey)='object' then bychar->vkey else '{}'::jsonb end;
 if coalesce((actions->>'padrao')::boolean,false) then raise exception 'A ação padrão já foi consumida.'; end if;
 if priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'no_actions') or priv.srd_condition_has_flag(p_campaign_id,'token',vkey,'only_move_action') then raise exception 'As condições impedem Encontrão.'; end if;
 actions:=actions||jsonb_build_object('padrao',true); bychar:=jsonb_set(bychar,array[vkey],actions,true);
 update public.campaigns set combat_data=combat_data||jsonb_build_object('action_economy',jsonb_build_object('round',rnd,'by_character',bychar)) where id=p_campaign_id;
 if success then
   tokens:=coalesce(c.cba_data->'tokens','[]'::jsonb);
   select t,ordinality into d,idx from jsonb_array_elements(tokens) with ordinality t where t->>'id'=p.threats->0->>'defender_token_id' or t->>'key'=p.threats->0->>'defender_token_id' limit 1;
   select t into a from jsonb_array_elements(tokens) t where t->>'id'=p.mover_token_id or t->>'key'=p.mover_token_id limit 1;
   ax:=(a->>'gridX')::int; ay:=(a->>'gridY')::int; dx:=(d->>'gridX')::int; dy:=(d->>'gridY')::int;
   sx:=case when dx>ax then 1 when dx<ax then -1 else 0 end; sy:=case when dy>ay then 1 when dy<ay then -1 else 0 end;
   steps:=least(4,greatest(1,floor((total_a-total_d)::numeric/5)::int));
   footprint:=priv.srd_token_grid_footprint(p_campaign_id,p.threats->0->>'defender_token_id');
   for i in 1..steps loop
     nx:=dx+sx; ny:=dy+sy;
     if nx<0 or ny<0 or nx>199 or ny>199 then blocked:=true; exit; end if;
     if exists(select 1 from jsonb_array_elements(tokens) t where (t->>'id' is distinct from p.threats->0->>'defender_token_id') and coalesce(t->>'gridX','') ~ '^[0-9]{1,3}$' and coalesce(t->>'gridY','') ~ '^[0-9]{1,3}$' and nx < (t->>'gridX')::int+priv.srd_token_grid_footprint(p_campaign_id,t->>'id') and nx+footprint>(t->>'gridX')::int and ny < (t->>'gridY')::int+priv.srd_token_grid_footprint(p_campaign_id,t->>'id') and ny+footprint>(t->>'gridY')::int) then blocked:=true; exit; end if;
     dx:=nx; dy:=ny; moved:=moved+1;
   end loop;
   select jsonb_agg(case when ordinality=idx then d||jsonb_build_object('gridX',dx,'gridY',dy) else value end order by ordinality) into arr from jsonb_array_elements(tokens) with ordinality;
   update public.campaigns set cba_data=coalesce(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',arr) where id=p_campaign_id;
 end if;
 update priv.srd_aoo_pending_movements set status='committed',committed_at=now(),updated_at=now() where pending_id=p_pending_id;
 perform priv.log(p_campaign_id,'COMBAT_MANEUVER',jsonb_build_object('maneuver','bull_rush','attacker_token_id',p.mover_token_id,'defender_token_id',p.threats->0->>'defender_token_id','attacker_total',total_a,'defender_total',total_d,'success',success,'squares_pushed',moved,'blocked',blocked,'follow',false));
 return jsonb_build_object('ok',true,'resolved',true,'maneuver','bull_rush','success',success,'attacker_total',total_a,'defender_total',total_d,'squares_pushed',moved,'blocked',blocked,'follow_movement_supported',false,'action_consumed','padrao');
end $$;

create or replace function public.srd_iniciar_encontrao_srd(p_campaign_id bigint,p_attacker_token_id text,p_defender_token_id text)
returns jsonb language sql security invoker set search_path=pg_catalog,public,priv,pg_temp
as $$ select priv.srd_iniciar_encontrao_srd($1,$2,$3) $$;
create or replace function public.srd_resolver_encontrao_srd(p_campaign_id bigint,p_pending_id uuid,p_attacker_d20 integer,p_defender_d20 integer,p_follow boolean default false)
returns jsonb language sql security invoker set search_path=pg_catalog,public,priv,pg_temp
as $$ select priv.srd_resolver_encontrao_srd($1,$2,$3,$4,$5) $$;
revoke all on function priv.srd_iniciar_encontrao_srd(bigint,text,text) from public,anon,authenticated;
revoke all on function priv.srd_resolver_encontrao_srd(bigint,uuid,integer,integer,boolean) from public,anon,authenticated;
grant execute on function priv.srd_iniciar_encontrao_srd(bigint,text,text) to authenticated;
grant execute on function priv.srd_resolver_encontrao_srd(bigint,uuid,integer,integer,boolean) to authenticated;
revoke all on function public.srd_iniciar_encontrao_srd(bigint,text,text) from public,anon;
revoke all on function public.srd_resolver_encontrao_srd(bigint,uuid,integer,integer,boolean) from public,anon;
grant execute on function public.srd_iniciar_encontrao_srd(bigint,text,text) to authenticated;
grant execute on function public.srd_resolver_encontrao_srd(bigint,uuid,integer,integer,boolean) to authenticated;
