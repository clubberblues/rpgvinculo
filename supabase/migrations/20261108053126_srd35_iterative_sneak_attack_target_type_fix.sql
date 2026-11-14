do $patch$
declare v_def text; v_old text; v_new text;
begin
  select pg_get_functiondef('public.resolver_ataque_iterativo_srd(bigint,uuid)'::regprocedure) into v_def;
  v_old := '  v_target_denies_dex:=exists(select 1 from public.srd_campaign_conditions cc';
  v_new := '  v_target_type:=lower(coalesce(v_target->''monsterStats''->>''creature_type'',v_target->''monsterStats''->>''type'',v_target->''monsterStats''->>''tipo'',v_target->>''creature_type'',''''));'||chr(10)||v_old;
  if position(v_old in v_def)=0 then
    if position('v_target_type:=lower(coalesce(v_target->' in v_def)=0 then raise exception 'Bloco de condições do Ataque Furtivo não localizado.'; end if;
  else v_def:=replace(v_def,v_old,v_new); end if;
  execute v_def;
end
$patch$;