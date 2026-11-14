
alter function public.consultar_ataque_iterativo_npc_srd(bigint,text,text) set schema priv;
alter function priv.consultar_ataque_iterativo_npc_srd(bigint,text,text) rename to npc_consultar_ataque_iterativo_impl;
alter function public.iniciar_ataque_iterativo_npc_srd(bigint,text,text,text,uuid,text,text) set schema priv;
alter function priv.iniciar_ataque_iterativo_npc_srd(bigint,text,text,text,uuid,text,text) rename to npc_iniciar_ataque_iterativo_impl;
alter function public.registrar_rolagem_ataque_iterativo_npc_srd(bigint,uuid,integer,uuid) set schema priv;
alter function priv.registrar_rolagem_ataque_iterativo_npc_srd(bigint,uuid,integer,uuid) rename to npc_registrar_rolagem_ataque_iterativo_impl;
alter function public.resolver_ataque_iterativo_npc_srd(bigint,uuid) set schema priv;
alter function priv.resolver_ataque_iterativo_npc_srd(bigint,uuid) rename to npc_resolver_ataque_iterativo_impl;
alter function public.confirmar_critico_ataque_iterativo_npc_srd(bigint,uuid,integer) set schema priv;
alter function priv.confirmar_critico_ataque_iterativo_npc_srd(bigint,uuid,integer) rename to npc_confirmar_critico_ataque_iterativo_impl;
alter function public.aplicar_dano_ataque_iterativo_npc_srd(bigint,uuid,integer[],uuid,integer[]) set schema priv;
alter function priv.aplicar_dano_ataque_iterativo_npc_srd(bigint,uuid,integer[],uuid,integer[]) rename to npc_aplicar_dano_ataque_iterativo_impl;
alter function public.consultar_ataque_iterativo_npc_pendente_srd(bigint,text) set schema priv;
alter function priv.consultar_ataque_iterativo_npc_pendente_srd(bigint,text) rename to npc_consultar_ataque_iterativo_pendente_impl;

revoke all on function priv.npc_consultar_ataque_iterativo_impl(bigint,text,text) from public,anon;
revoke all on function priv.npc_iniciar_ataque_iterativo_impl(bigint,text,text,text,uuid,text,text) from public,anon;
revoke all on function priv.npc_registrar_rolagem_ataque_iterativo_impl(bigint,uuid,integer,uuid) from public,anon;
revoke all on function priv.npc_resolver_ataque_iterativo_impl(bigint,uuid) from public,anon;
revoke all on function priv.npc_confirmar_critico_ataque_iterativo_impl(bigint,uuid,integer) from public,anon;
revoke all on function priv.npc_aplicar_dano_ataque_iterativo_impl(bigint,uuid,integer[],uuid,integer[]) from public,anon;
revoke all on function priv.npc_consultar_ataque_iterativo_pendente_impl(bigint,text) from public,anon;
grant execute on function priv.npc_consultar_ataque_iterativo_impl(bigint,text,text) to authenticated;
grant execute on function priv.npc_iniciar_ataque_iterativo_impl(bigint,text,text,text,uuid,text,text) to authenticated;
grant execute on function priv.npc_registrar_rolagem_ataque_iterativo_impl(bigint,uuid,integer,uuid) to authenticated;
grant execute on function priv.npc_resolver_ataque_iterativo_impl(bigint,uuid) to authenticated;
grant execute on function priv.npc_confirmar_critico_ataque_iterativo_impl(bigint,uuid,integer) to authenticated;
grant execute on function priv.npc_aplicar_dano_ataque_iterativo_impl(bigint,uuid,integer[],uuid,integer[]) to authenticated;
grant execute on function priv.npc_consultar_ataque_iterativo_pendente_impl(bigint,text) to authenticated;

create function public.consultar_ataque_iterativo_npc_srd(p_campaign_id bigint,p_token_id text,p_attack_type text)
returns jsonb language sql security invoker set search_path=''
as $$ select priv.npc_consultar_ataque_iterativo_impl($1,$2,$3); $$;
create function public.iniciar_ataque_iterativo_npc_srd(p_campaign_id bigint,p_actor_token_id text,p_target_token_id text,p_attack_type text,p_weapon_instance_id uuid,p_weapon_hand_slot text,p_weapon_end text default null)
returns jsonb language sql security invoker set search_path=''
as $$ select priv.npc_iniciar_ataque_iterativo_impl($1,$2,$3,$4,$5,$6,$7); $$;
create function public.registrar_rolagem_ataque_iterativo_npc_srd(p_campaign_id bigint,p_sequence_id uuid,p_manual_d20 integer,p_idempotency_key uuid)
returns jsonb language sql security invoker set search_path=''
as $$ select priv.npc_registrar_rolagem_ataque_iterativo_impl($1,$2,$3,$4); $$;
create function public.resolver_ataque_iterativo_npc_srd(p_campaign_id bigint,p_attempt_id uuid)
returns jsonb language sql security invoker set search_path=''
as $$ select priv.npc_resolver_ataque_iterativo_impl($1,$2); $$;
create function public.confirmar_critico_ataque_iterativo_npc_srd(p_campaign_id bigint,p_attempt_id uuid,p_confirmation_d20 integer)
returns jsonb language sql security invoker set search_path=''
as $$ select priv.npc_confirmar_critico_ataque_iterativo_impl($1,$2,$3); $$;
create function public.aplicar_dano_ataque_iterativo_npc_srd(p_campaign_id bigint,p_attempt_id uuid,p_damage_rolls integer[],p_idempotency_key uuid,p_sneak_damage_rolls integer[])
returns jsonb language sql security invoker set search_path=''
as $$ select priv.npc_aplicar_dano_ataque_iterativo_impl($1,$2,$3,$4,$5); $$;
create function public.consultar_ataque_iterativo_npc_pendente_srd(p_campaign_id bigint,p_actor_token_id text)
returns jsonb language sql security invoker set search_path=''
as $$ select priv.npc_consultar_ataque_iterativo_pendente_impl($1,$2); $$;

revoke all on function public.consultar_ataque_iterativo_npc_srd(bigint,text,text) from public,anon;
revoke all on function public.iniciar_ataque_iterativo_npc_srd(bigint,text,text,text,uuid,text,text) from public,anon;
revoke all on function public.registrar_rolagem_ataque_iterativo_npc_srd(bigint,uuid,integer,uuid) from public,anon;
revoke all on function public.resolver_ataque_iterativo_npc_srd(bigint,uuid) from public,anon;
revoke all on function public.confirmar_critico_ataque_iterativo_npc_srd(bigint,uuid,integer) from public,anon;
revoke all on function public.aplicar_dano_ataque_iterativo_npc_srd(bigint,uuid,integer[],uuid,integer[]) from public,anon;
revoke all on function public.consultar_ataque_iterativo_npc_pendente_srd(bigint,text) from public,anon;
grant execute on function public.consultar_ataque_iterativo_npc_srd(bigint,text,text) to authenticated;
grant execute on function public.iniciar_ataque_iterativo_npc_srd(bigint,text,text,text,uuid,text,text) to authenticated;
grant execute on function public.registrar_rolagem_ataque_iterativo_npc_srd(bigint,uuid,integer,uuid) to authenticated;
grant execute on function public.resolver_ataque_iterativo_npc_srd(bigint,uuid) to authenticated;
grant execute on function public.confirmar_critico_ataque_iterativo_npc_srd(bigint,uuid,integer) to authenticated;
grant execute on function public.aplicar_dano_ataque_iterativo_npc_srd(bigint,uuid,integer[],uuid,integer[]) to authenticated;
grant execute on function public.consultar_ataque_iterativo_npc_pendente_srd(bigint,text) to authenticated;
