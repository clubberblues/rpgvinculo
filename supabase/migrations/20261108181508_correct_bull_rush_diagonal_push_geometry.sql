
create or replace function priv.srd_resolver_encontrao_srd(
 p_campaign_id bigint,p_pending_id uuid,p_attacker_d20 integer,p_defender_d20 integer,p_follow boolean default false
) returns jsonb language plpgsql security definer
set search_path=pg_catalog,public,priv,pg_temp as $$
declare p priv.srd_aoo_pending_movements%rowtype; c public.campaigns%rowtype; calc jsonb; tokens jsonb; a jsonb; d jsonb;
 ax int; ay int; dx int; dy int; old_dx int; old_dy int; sx int; sy int; steps int; i int; nx int; ny int; moved int:=0; blocked boolean:=false; footprint int; af int;
 total_a int; total_d int; success boolean; rnd int; state jsonb; bychar jsonb; actions jsonb; vkey text; arr jsonb; idx int; aidx int; followed boolean:=false;
 remaining_ft int; step_cost int; diagonal_count int:=0; defender_size int;
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
   select t,ordinality into a,aidx from jsonb_array_elements(tokens) with ordinality t where t->>'id'=p.mover_token_id or t->>'key'=p.mover_token_id limit 1;
   if d is null or a is null then raise exception 'Um dos tokens saiu da cena antes da resolução.'; end if;
   ax:=(a->>'gridX')::int; ay:=(a->>'gridY')::int; dx:=(d->>'gridX')::int; dy:=(d->>'gridY')::int; old_dx:=dx; old_dy:=dy;
   sx:=case when dx>ax then 1 when dx<ax then -1 else 0 end; sy:=case when dy>ay then 1 when dy<ay then -1 else 0 end;
   remaining_ft:=greatest(5,total_a-total_d);
   footprint:=priv.srd_token_grid_footprint(p_campaign_id,p.threats->0->>'defender_token_id');
   defender_size:=footprint;
   while remaining_ft>=5 and (sx<>0 or sy<>0) loop
     step_cost:=case when sx<>0 and sy<>0 and mod(diagonal_count,2)=1 then 10 else 5 end;
     if remaining_ft<step_cost then exit; end if;
     nx:=dx+sx; ny:=dy+sy;
     if nx<0 or ny<0 or nx+footprint>200 or ny+footprint>200 then blocked:=true; exit; end if;
     if exists(select 1 from jsonb_array_elements(tokens) t where t->>'id' is distinct from p.threats->0->>'defender_token_id' and t->>'key' is distinct from p.threats->0->>'defender_token_id' and t->>'id' is distinct from p.mover_token_id and t->>'key' is distinct from p.mover_token_id and coalesce(t->>'gridX','') ~ '^[0-9]{1,3}$' and coalesce(t->>'gridY','') ~ '^[0-9]{1,3}$' and nx < (t->>'gridX')::int+priv.srd_token_grid_footprint(p_campaign_id,coalesce(t->>'id',t->>'key')) and nx+footprint>(t->>'gridX')::int and ny < (t->>'gridY')::int+priv.srd_token_grid_footprint(p_campaign_id,coalesce(t->>'id',t->>'key')) and ny+footprint>(t->>'gridY')::int) then blocked:=true; exit; end if;
     dx:=nx; dy:=ny; moved:=moved+1; remaining_ft:=remaining_ft-step_cost;
     if sx<>0 and sy<>0 then diagonal_count:=diagonal_count+1; end if;
   end loop;
   if p_follow and moved>0 then
     af:=priv.srd_token_grid_footprint(p_campaign_id,p.mover_token_id);
     if old_dx+af<=200 and old_dy+af<=200
       and not (old_dx < dx+defender_size and old_dx+af>dx and old_dy < dy+defender_size and old_dy+af>dy)
       and not exists(
       select 1 from jsonb_array_elements(tokens) t
       where t->>'id' is distinct from p.mover_token_id and t->>'key' is distinct from p.mover_token_id
       and t->>'id' is distinct from p.threats->0->>'defender_token_id' and t->>'key' is distinct from p.threats->0->>'defender_token_id'
       and coalesce(t->>'gridX','') ~ '^[0-9]{1,3}$' and coalesce(t->>'gridY','') ~ '^[0-9]{1,3}$'
       and old_dx < (t->>'gridX')::int+priv.srd_token_grid_footprint(p_campaign_id,coalesce(t->>'id',t->>'key'))
       and old_dx+af>(t->>'gridX')::int and old_dy < (t->>'gridY')::int+priv.srd_token_grid_footprint(p_campaign_id,coalesce(t->>'id',t->>'key'))
       and old_dy+af>(t->>'gridY')::int
     ) then followed:=true; end if;
   end if;
   select jsonb_agg(case when ordinality=idx then d||jsonb_build_object('gridX',dx,'gridY',dy)
     when ordinality=aidx and followed then a||jsonb_build_object('gridX',old_dx,'gridY',old_dy)
     else value end order by ordinality) into arr from jsonb_array_elements(tokens) with ordinality;
   update public.campaigns set cba_data=coalesce(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',arr) where id=p_campaign_id;
 end if;
 update priv.srd_aoo_pending_movements set status='committed',committed_at=now(),updated_at=now() where pending_id=p_pending_id;
 perform priv.log(p_campaign_id,'COMBAT_MANEUVER',jsonb_build_object('maneuver','bull_rush','attacker_token_id',p.mover_token_id,'defender_token_id',p.threats->0->>'defender_token_id','attacker_total',total_a,'defender_total',total_d,'success',success,'squares_pushed',moved,'remaining_push_ft',remaining_ft,'blocked',blocked,'follow_requested',p_follow,'attacker_followed',followed));
 return jsonb_build_object('ok',true,'resolved',true,'maneuver','bull_rush','success',success,'attacker_total',total_a,'defender_total',total_d,'squares_pushed',moved,'remaining_push_ft',remaining_ft,'blocked',blocked,'attacker_followed',followed,'follow_movement_supported',true,'action_consumed','padrao');
end $$;
