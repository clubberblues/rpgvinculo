CREATE OR REPLACE FUNCTION priv.srd_guard_pending_aoo_movement()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_old_token jsonb;
  v_new_token jsonb;
  v_commit_id text;
begin
  if new.cba_data is not distinct from old.cba_data then return new; end if;
  select * into v_pending
  from priv.srd_aoo_pending_movements p
  where p.campaign_id=new.id
    and p.status in ('waiting_reactions','ready_to_commit')
  order by p.created_at desc limit 1;
  if not found then return new; end if;

  select t into v_old_token
  from jsonb_array_elements(case when jsonb_typeof(old.cba_data->'tokens')='array'
    then old.cba_data->'tokens' else '[]'::jsonb end) t
  where t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id
  limit 1;
  select t into v_new_token
  from jsonb_array_elements(case when jsonb_typeof(new.cba_data->'tokens')='array'
    then new.cba_data->'tokens' else '[]'::jsonb end) t
  where t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id
  limit 1;

  v_commit_id:=current_setting('app.srd_aoo_pending_commit',true);

  if v_old_token is not null and v_new_token is null
     and v_commit_id is distinct from v_pending.pending_id::text then
    raise exception 'Remoção do token bloqueada: há um movimento aguardando resolução de ataques de oportunidade.';
  end if;

  if v_old_token is not null and v_new_token is not null
     and ((v_old_token->>'gridX') is distinct from (v_new_token->>'gridX')
       or (v_old_token->>'gridY') is distinct from (v_new_token->>'gridY')) then
    if v_commit_id is distinct from v_pending.pending_id::text then
      raise exception 'Movimento bloqueado: há um ataque de oportunidade pendente de resolução.';
    end if;
  end if;
  return new;
end;
$function$
;
REVOKE ALL ON FUNCTION priv.srd_guard_pending_aoo_movement() FROM PUBLIC,anon,authenticated;