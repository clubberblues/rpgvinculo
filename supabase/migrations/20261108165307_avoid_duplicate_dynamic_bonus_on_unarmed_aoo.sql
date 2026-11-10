
do $patch$
declare v_def text;
begin
  v_def:=pg_get_functiondef('public.srd_iniciar_ataque_oportunidade_desarmado_srd(bigint,uuid,text,uuid)'::regprocedure);
  v_def:=replace(v_def,
    $old$v_attack_bonus:=v_bab+v_str_mod+v_size_mod+v_racial_bonus
    +priv.srd_effective_modifier(p_campaign_id,'token',btrim(p_reactor_token_id),'attack')
    +priv.srd_effective_modifier(p_campaign_id,'token',btrim(p_reactor_token_id),'attack_melee');$old$,
    $new$v_attack_bonus:=v_bab+v_str_mod+v_size_mod+v_racial_bonus;$new$);
  if strpos(v_def,'v_attack_bonus:=v_bab+v_str_mod+v_size_mod+v_racial_bonus;')=0 then
    raise exception 'Não foi possível remover a duplicação de modificadores de ataque desarmado.';
  end if;
  execute v_def;
end;
$patch$;
