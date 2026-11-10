
do $hardening$
declare v_def text;
begin
 v_def:=pg_get_functiondef('public.resolver_ataque_iterativo_npc_srd(bigint,uuid)'::regprocedure);
 v_def:=replace(v_def,
 '  if v_user is null then raise exception ''É necessário estar autenticado.''; end if;',
 '  if v_user is null then raise exception ''É necessário estar autenticado.''; end if;'
 || E'\n  if public.my_role(p_campaign_id) is distinct from ''GM'' then raise exception ''Somente o Mestre pode resolver ataques de NPC.''; end if;');
 execute v_def;

 v_def:=pg_get_functiondef('public.confirmar_critico_ataque_iterativo_npc_srd(bigint,uuid,integer)'::regprocedure);
 v_def:=replace(v_def,
 '  if v_user is null then raise exception ''É necessário estar autenticado.''; end if;',
 '  if v_user is null then raise exception ''É necessário estar autenticado.''; end if;'
 || E'\n  if public.my_role(p_campaign_id) is distinct from ''GM'' then raise exception ''Somente o Mestre pode confirmar críticos de NPC.''; end if;');
 execute v_def;

 v_def:=pg_get_functiondef('public.aplicar_dano_ataque_iterativo_npc_srd(bigint,uuid,integer[],uuid,integer[])'::regprocedure);
 v_def:=replace(v_def,
 '  if v_user is null then raise exception ''É necessário estar autenticado.''; end if;',
 '  if v_user is null then raise exception ''É necessário estar autenticado.''; end if;'
 || E'\n  if public.my_role(p_campaign_id) is distinct from ''GM'' then raise exception ''Somente o Mestre pode aplicar dano de NPC.''; end if;');
 execute v_def;
end
$hardening$;
