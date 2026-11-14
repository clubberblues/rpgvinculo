
create or replace function priv.srd_condition_has_flag(
 p_campaign_id bigint,p_target_kind text,p_target_id text,p_flag text
) returns boolean
language sql
stable
security definer
set search_path=pg_catalog,public,priv,pg_temp
as $function$
 select exists (
   select 1
   from public.srd_campaign_conditions cc
   join priv.srd_condition_engine_rules r
     on r.condition_id=cc.condition_id and r.enabled
   where cc.campaign_id=p_campaign_id
     and cc.target_kind=p_target_kind
     and cc.target_id=p_target_id
     and cc.active
     and coalesce(r.flags->>p_flag,'false')='true'
 ) or exists (
   select 1
   from public.srd_campaign_effects e
   where e.campaign_id=p_campaign_id
     and e.target_kind=p_target_kind
     and e.target_id=p_target_id
     and e.active
     and coalesce(e.effect_data->'flags'->>p_flag,'false')='true'
 ) or exists (
   select 1
   from public.srd_campaign_conditions cc
   where cc.campaign_id=p_campaign_id
     and cc.target_kind=p_target_kind
     and cc.target_id=p_target_id
     and cc.condition_id='confused'
     and cc.active
     and (
       (p_flag='no_actions' and (
         nullif(cc.notes->>'confusion_pending_request_id','') is not null
         or cc.notes->>'confusion_last_outcome'='babble'
       ))
       or
       (p_flag='only_move_action' and cc.notes->>'confusion_last_outcome'='flee')
       or
       (p_flag='flee' and cc.notes->>'confusion_last_outcome'='flee')
     )
 );
$function$;
revoke all on function priv.srd_condition_has_flag(bigint,text,text,text) from public,anon;
grant execute on function priv.srd_condition_has_flag(bigint,text,text,text) to authenticated;
