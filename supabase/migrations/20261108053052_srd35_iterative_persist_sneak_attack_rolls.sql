do $patch$
declare v_def text; v_old text; v_new text;
begin
  select pg_get_functiondef('public.aplicar_dano_ataque_iterativo_srd(bigint,uuid,integer[],uuid,integer[])'::regprocedure) into v_def;
  v_old := '''sneak_attack_roll_sum'',v_sneak_roll_sum,''sneak_attack_dice'',v_sneak_dice_expected,''damage_bonus'',v_damage_bonus,';
  v_new := '''sneak_attack_roll_sum'',v_sneak_roll_sum,''sneak_attack_dice'',v_sneak_dice_expected,''sneak_damage_rolls'',to_jsonb(coalesce(p_sneak_damage_rolls,''{}''::integer[])),''damage_bonus'',v_damage_bonus,';
  if position(v_old in v_def)=0 then
    if position('sneak_damage_rolls' in v_def)=0 then raise exception 'Metadados para persistir dados furtivos não localizados.'; end if;
  else v_def:=replace(v_def,v_old,v_new); end if;
  execute v_def;
end
$patch$;