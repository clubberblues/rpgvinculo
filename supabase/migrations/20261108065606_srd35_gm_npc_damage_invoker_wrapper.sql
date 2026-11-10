
alter function public.aplicar_dano_ataque_npc_gm_srd(bigint,text,text,integer,text) set schema priv;
alter function priv.aplicar_dano_ataque_npc_gm_srd(bigint,text,text,integer,text) rename to gm_npc_apply_typed_damage_impl;
revoke all on function priv.gm_npc_apply_typed_damage_impl(bigint,text,text,integer,text) from public,anon;
grant execute on function priv.gm_npc_apply_typed_damage_impl(bigint,text,text,integer,text) to authenticated;
create function public.aplicar_dano_ataque_npc_gm_srd(
 p_campaign_id bigint,p_actor_token_id text,p_target_token_id text,
 p_raw_damage integer,p_damage_type text default 'untyped'
) returns jsonb
language sql security invoker set search_path=''
as $$ select priv.gm_npc_apply_typed_damage_impl($1,$2,$3,$4,$5); $$;
revoke all on function public.aplicar_dano_ataque_npc_gm_srd(bigint,text,text,integer,text) from public,anon;
grant execute on function public.aplicar_dano_ataque_npc_gm_srd(bigint,text,text,integer,text) to authenticated;
