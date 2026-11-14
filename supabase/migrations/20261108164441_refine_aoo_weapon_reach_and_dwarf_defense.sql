
do $patch$
declare v_def text;
begin
  v_def:=pg_get_functiondef('public.srd_iniciar_ataque_oportunidade_srd(bigint,uuid,text,uuid,uuid,text,text)'::regprocedure);
  v_def:=replace(v_def,
    $old$v_reach:=coalesce(nullif(v_token->>'melee_reach_ft','')::integer,5);$old$,
    $new$v_reach:=coalesce(nullif(v_weapon.detalhes->>'reach_ft','')::integer,nullif(v_token->>'melee_reach_ft','')::integer,5);$new$);
  if strpos(v_def,$needle$v_weapon.detalhes->>'reach_ft'$needle$)=0 then
    raise exception 'Não foi possível atualizar o alcance da arma no ataque de oportunidade.';
  end if;
  execute v_def;

  v_def:=pg_get_functiondef('public.srd_resolver_ataque_oportunidade_srd(bigint,uuid)'::regprocedure);
  v_def:=replace(v_def,
    $old$  if v_target->>'tipo'='player' then
    v_target_ac_data:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_attack.target_token_id,'normal',false);
    v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer;$old$,
    $new$  v_actor_is_giant:=lower(concat_ws(' ',v_actor_token->>'creature_type',v_actor_token->'monsterStats'->>'type',v_actor_token->'monsterStats'->>'tipo',v_actor_token->'monsterStats'->>'creature_type',v_actor_token->'monsterStats'->>'subtype',v_actor_token->'monsterStats'->>'subtypes')) ~ '(giant|gigante)';
  if v_target->>'tipo'='player' then
    v_target_ac_data:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_attack.target_token_id,'normal',v_actor_is_giant);
    v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
      +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');$new$);
  if strpos(v_def,$needle$v_actor_is_giant:=lower(concat_ws$needle$)=0 then
    raise exception 'Não foi possível integrar o bônus racial contra gigantes no cálculo da CA.';
  end if;
  execute v_def;
end;
$patch$;
