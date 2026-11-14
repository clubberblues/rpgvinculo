
create or replace function priv.srd_clear_combat_flatfooted_actor(p_campaign_id bigint,p_actor jsonb)
returns integer language plpgsql security definer
set search_path=pg_catalog,public,priv,pg_temp
as $function$
declare v_kind text; v_id text; v_count integer;
begin
 if p_actor is null or jsonb_typeof(p_actor) is distinct from 'object' then return 0; end if;
 v_id:=nullif(btrim(p_actor->>'id'),'');
 if v_id is null then return 0; end if;
 v_kind:=case when coalesce((p_actor->>'is_monster')::boolean,false) then 'token' else 'character' end;
 update public.srd_campaign_conditions set active=false,
 notes=notes||jsonb_build_object('ended_reason','first_turn_started','ended_at',now())
 where campaign_id=p_campaign_id and target_kind=v_kind and target_id=v_id
 and condition_id='flatfooted' and active=true and notes->>'source_feature'='combat_flatfooted';
 get diagnostics v_count=row_count;
 return v_count;
end;
$function$;

create or replace function priv.srd_start_combat_flatfooted(p_campaign_id bigint,p_turn_order jsonb,p_first_turn integer default 0)
returns jsonb language plpgsql security definer
set search_path=pg_catalog,public,priv,pg_temp
as $function$
declare v_entry jsonb; v_kind text; v_id text; v_added integer:=0; v_first jsonb;
begin
 if jsonb_typeof(p_turn_order) is distinct from 'array' then raise exception 'Fila de iniciativa inválida.'; end if;
 for v_entry in select value from jsonb_array_elements(p_turn_order) as entries(value)
 loop
  v_id:=nullif(btrim(v_entry->>'id'),'');
  if v_id is null then continue; end if;
  v_kind:=case when coalesce((v_entry->>'is_monster')::boolean,false) then 'token' else 'character' end;
  if not exists(select 1 from public.srd_campaign_conditions cc where cc.campaign_id=p_campaign_id
    and cc.target_kind=v_kind and cc.target_id=v_id and cc.condition_id='flatfooted' and cc.active=true) then
   insert into public.srd_campaign_conditions(campaign_id,target_kind,target_id,condition_id,source_actor_id,started_round,expires_round,active,notes)
   values(p_campaign_id,v_kind,v_id,'flatfooted',null,1,null,true,
    jsonb_build_object('source_feature','combat_flatfooted','rule','until_first_turn','initiative_id',v_id));
   v_added:=v_added+1;
  end if;
 end loop;
 if jsonb_array_length(p_turn_order)>0 then
  v_first:=p_turn_order->greatest(0,least(jsonb_array_length(p_turn_order)-1,coalesce(p_first_turn,0)));
  perform priv.srd_clear_combat_flatfooted_actor(p_campaign_id,v_first);
 end if;
 return jsonb_build_object('applied',v_added,'first_actor_id',v_first->>'id');
end;
$function$;

create or replace function priv.srd_clear_combat_flatfooted_all(p_campaign_id bigint)
returns integer language plpgsql security definer
set search_path=pg_catalog,public,priv,pg_temp
as $function$
declare v_count integer;
begin
 update public.srd_campaign_conditions set active=false,
 notes=notes||jsonb_build_object('ended_reason','combat_ended','ended_at',now())
 where campaign_id=p_campaign_id and active=true and condition_id='flatfooted'
 and notes->>'source_feature'='combat_flatfooted';
 get diagnostics v_count=row_count;
 return v_count;
end;
$function$;
revoke all on function priv.srd_clear_combat_flatfooted_actor(bigint,jsonb) from public,anon,authenticated;
revoke all on function priv.srd_start_combat_flatfooted(bigint,jsonb,integer) from public,anon,authenticated;
revoke all on function priv.srd_clear_combat_flatfooted_all(bigint) from public,anon,authenticated;

do $patch$
declare v_def text; v_old text; v_new text;
begin
 v_def:=replace(pg_get_functiondef('public.registrar_iniciativa(bigint,text,text,integer)'::regprocedure),chr(13)||chr(10),chr(10));
 v_old:=$old$  UPDATE public.campaigns SET combat_data=v_next WHERE id=p_campaign_id;
  RETURN v_next;$old$;
 v_new:=$new$  UPDATE public.campaigns SET combat_data=v_next WHERE id=p_campaign_id;
  IF v_active AND NOT COALESCE((v_data->>'active')::boolean,false) THEN
   PERFORM priv.srd_start_combat_flatfooted(p_campaign_id,v_sorted,v_current_turn);
  END IF;
  RETURN v_next;$new$;
 if strpos(v_def,v_old)=0 then raise exception 'Âncora registrar_iniciativa não encontrada'; end if;
 execute replace(v_def,v_old,v_new);
end;
$patch$;
