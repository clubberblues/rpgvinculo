do $patch$
declare v_def text; v_old text; v_new text;
begin
  select pg_get_functiondef('public.resolver_ataque_iterativo_srd(bigint,uuid)'::regprocedure) into v_def;
  v_old := '  v_target_type:=lower(coalesce(v_target->''monsterStats''->>''creature_type'',v_target->''monsterStats''->>''type'',v_target->''monsterStats''->>''tipo'',v_target->>''creature_type'',''''));';
  v_new := '  v_target_type:=lower(coalesce(nullif(v_target->''monsterStats''->>''creature_type'',''''),nullif(v_target->''monsterStats''->>''type'',''''),nullif(v_target->''monsterStats''->>''tipo'',''''),nullif(v_target->>''creature_type'',''''),''''));';
  if position(v_old in v_def)=0 then
    if position(v_new in v_def)=0 then raise exception 'Normalização de tipo da criatura não localizada.'; end if;
  else v_def:=replace(v_def,v_old,v_new); end if;
  execute v_def;
end
$patch$;