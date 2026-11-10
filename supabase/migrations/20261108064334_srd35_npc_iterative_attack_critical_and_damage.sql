
alter table public.srd_npc_attack_attempts
 add column if not exists damage_type text,
 add column if not exists damage_applied_at timestamptz;

do $migration$
declare
 v_def text;
begin
 v_def:=pg_get_functiondef('public.confirmar_critico_ataque_iterativo_srd(bigint,uuid,integer)'::regprocedure);
 v_def:=replace(v_def,'public.srd_attack_sequences%rowtype','public.srd_npc_attack_sequences%rowtype');
 v_def:=replace(v_def,'public.srd_attack_sequence_attempts%rowtype','public.srd_npc_attack_attempts%rowtype');
 v_def:=replace(v_def,'public.srd_attack_sequences','public.srd_npc_attack_sequences');
 v_def:=replace(v_def,'public.srd_attack_sequence_attempts','public.srd_npc_attack_attempts');
 v_def:=replace(v_def,'public.confirmar_critico_ataque_iterativo_srd','public.confirmar_critico_ataque_iterativo_npc_srd');
 v_def:=replace(v_def,
 '  if not exists ('
 || E'\n    select 1 from public.characters ch join public.members m'
 || E'\n      on m.campaign_id=ch.campaign_id and m.user_id=ch.user_id'
 || E'\n    where ch.id=v_seq.actor_character_id and ch.campaign_id=p_campaign_id'
 || E'\n      and ch.user_id=v_user and m.role=''PLAYER'''
 || E'\n  ) then raise exception ''Personagem não pertence ao jogador autenticado.''; end if;',
 '  if public.my_role(p_campaign_id) is distinct from ''GM'' or v_seq.created_by<>v_user then'
 || E'\n    raise exception ''Somente o Mestre que iniciou a sequência pode confirmar o crítico.'';'
 || E'\n  end if;');
 v_def:=replace(v_def,
 'where t->>''id''=v_seq.target_token_id and t->>''tipo'' in (''npc'',''monstro''))<>1',
 'where t->>''id''=v_seq.target_token_id and t->>''tipo'' in (''player'',''npc'',''monstro''))<>1');
 if position('public.srd_npc_attack_attempts%rowtype' in v_def)=0
 or position('public.srd_npc_attack_sequences%rowtype' in v_def)=0
 or position('public.my_role(p_campaign_id)' in v_def)=0
 or position('public.srd_attack_sequence_attempts' in v_def)>0 then
  raise exception 'Adaptação da confirmação crítica NPC incompleta.';
 end if;
 execute v_def;

 v_def:=pg_get_functiondef('public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid,integer[])'::regprocedure);
 v_def:=replace(v_def,'public.srd_attack_sequences%rowtype','public.srd_npc_attack_sequences%rowtype');
 v_def:=replace(v_def,'public.srd_attack_sequence_attempts%rowtype','public.srd_npc_attack_attempts%rowtype');
 v_def:=replace(v_def,'public.srd_attack_sequences','public.srd_npc_attack_sequences');
 v_def:=replace(v_def,'public.srd_attack_sequence_attempts','public.srd_npc_attack_attempts');
 v_def:=replace(v_def,'public.aplicar_dano_ataque_iterativo_srd','public.aplicar_dano_ataque_iterativo_npc_srd');
 v_def:=replace(v_def,
 '  if not exists ('
 || E'\n    select 1 from public.characters ch join public.members m'
 || E'\n      on m.campaign_id=ch.campaign_id and m.user_id=ch.user_id'
 || E'\n    where ch.id=v_seq.actor_character_id and ch.campaign_id=p_campaign_id'
 || E'\n      and ch.user_id=v_user and m.role=''PLAYER'''
 || E'\n  ) then raise exception ''Personagem não pertence ao jogador autenticado.''; end if;',
 '  if public.my_role(p_campaign_id) is distinct from ''GM'' or v_seq.created_by<>v_user then'
 || E'\n    raise exception ''Somente o Mestre que iniciou a sequência pode aplicar dano de NPC.'';'
 || E'\n  end if;');
 v_def:=replace(v_def,
 'where t.token->>''id''=v_seq.target_token_id and t.token->>''tipo'' in (''npc'',''monstro'');',
 'where t.token->>''id''=v_seq.target_token_id and t.token->>''tipo'' in (''player'',''npc'',''monstro'');');
 v_def:=replace(v_def,
 'priv.srd_effective_modifier(p_campaign_id,''character'',v_seq.actor_character_id::text,',
 'priv.srd_effective_modifier(p_campaign_id,''token'',v_seq.actor_token_id,');
 if position('public.srd_npc_attack_attempts%rowtype' in v_def)=0
 or position('public.srd_npc_attack_sequences%rowtype' in v_def)=0
 or position('public.my_role(p_campaign_id)' in v_def)=0
 or position('public.srd_attack_sequence_attempts' in v_def)>0
 or position('public.srd_attack_sequences' in v_def)>0 then
  raise exception 'Adaptação da aplicação de dano NPC incompleta.';
 end if;
 execute v_def;
end
$migration$;

revoke all on function public.confirmar_critico_ataque_iterativo_npc_srd(bigint,uuid,integer) from public,anon;
revoke all on function public.aplicar_dano_ataque_iterativo_npc_srd(bigint,uuid,integer[],uuid,integer[]) from public,anon;
grant execute on function public.confirmar_critico_ataque_iterativo_npc_srd(bigint,uuid,integer) to authenticated;
grant execute on function public.aplicar_dano_ataque_iterativo_npc_srd(bigint,uuid,integer[],uuid,integer[]) to authenticated;
