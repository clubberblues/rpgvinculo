
alter table public.srd_npc_attack_sequences
 add column if not exists power_attack_penalty integer not null default 0
 check (power_attack_penalty>=0 and power_attack_penalty<=base_attack_bonus);

do $migration$
declare
 v_def text;
begin
 v_def:=pg_get_functiondef('public.resolver_ataque_iterativo_srd(bigint,uuid)'::regprocedure);
 v_def:=replace(v_def,'public.srd_attack_sequences%rowtype','public.srd_npc_attack_sequences%rowtype');
 v_def:=replace(v_def,'public.srd_attack_sequence_attempts%rowtype','public.srd_npc_attack_attempts%rowtype');
 v_def:=replace(v_def,'public.srd_attack_sequences','public.srd_npc_attack_sequences');
 v_def:=replace(v_def,'public.srd_attack_sequence_attempts','public.srd_npc_attack_attempts');
 v_def:=replace(v_def,'public.resolver_ataque_iterativo_srd','public.resolver_ataque_iterativo_npc_srd');

 v_def:=replace(v_def,
 '  if not exists ('
 || E'\n    select 1 from public.characters ch'
 || E'\n    join public.members m on m.campaign_id=ch.campaign_id and m.user_id=ch.user_id'
 || E'\n    where ch.id=v_seq.actor_character_id and ch.campaign_id=p_campaign_id'
 || E'\n      and ch.user_id=v_user and m.role=''PLAYER'''
 || E'\n  ) then raise exception ''A ficha atacante não pertence ao jogador autenticado nesta campanha.''; end if;',
 '  if public.my_role(p_campaign_id) is distinct from ''GM'' then'
 || E'\n    raise exception ''Somente o Mestre pode resolver ataques de NPC.'';'
 || E'\n  end if;'
 || E'\n  if v_seq.created_by<>v_user then raise exception ''Somente o Mestre que iniciou a sequência pode resolvê-la.''; end if;');

 v_def:=replace(v_def,
 'where t.token->>''id''=v_seq.target_token_id and t.token->>''tipo'' in (''npc'',''monstro'');',
 'where t.token->>''id''=v_seq.target_token_id and t.token->>''tipo'' in (''player'',''npc'',''monstro'');');

 v_def:=replace(v_def,
 'where t.token->>''id''=v_seq.actor_character_id::text and t.token->>''tipo''=''player'';',
 'where t.token->>''id''=v_seq.actor_token_id and t.token->>''tipo''=''npc'';');

 v_def:=replace(v_def,
 'where e->>''id''=v_seq.actor_character_id::text and coalesce(e->>''is_monster'',''false'')<>''true'''
 || E'\n      and (select ordinality-1 from jsonb_array_elements(coalesce(v_campaign.combat_data->''turn_order'',''[]''::jsonb)) with ordinality x(e,ordinality) where x.e->>''id''=v_seq.actor_character_id::text limit 1)=v_turn',
 'where e->>''id''=v_seq.actor_token_id and coalesce(e->>''is_monster'',''false'')=''true'''
 || E'\n      and (select ordinality-1 from jsonb_array_elements(coalesce(v_campaign.combat_data->''turn_order'',''[]''::jsonb)) with ordinality x(e,ordinality) where x.e->>''id''=v_seq.actor_token_id limit 1)=v_turn');

 v_def:=replace(v_def,
 'priv.srd_effective_modifier(p_campaign_id,''character'',v_seq.actor_character_id::text,',
 'priv.srd_effective_modifier(p_campaign_id,''token'',v_seq.actor_token_id,');

 if position('public.srd_npc_attack_sequences%rowtype' in v_def)=0
 or position('public.srd_npc_attack_attempts%rowtype' in v_def)=0
 or position('v_seq.actor_token_id' in v_def)=0
 or position('public.my_role(p_campaign_id)' in v_def)=0
 or position('resolver_ataque_iterativo_npc_srd' in v_def)=0
 or position('public.srd_attack_sequence_attempts' in v_def)>0
 or position('public.srd_attack_sequences' in v_def)>0 then
  raise exception 'A adaptação do resolvedor NPC não passou nas verificações de transformação.';
 end if;
 execute v_def;
end
$migration$;

revoke all on function public.resolver_ataque_iterativo_npc_srd(bigint,uuid) from public,anon;
grant execute on function public.resolver_ataque_iterativo_npc_srd(bigint,uuid) to authenticated;
