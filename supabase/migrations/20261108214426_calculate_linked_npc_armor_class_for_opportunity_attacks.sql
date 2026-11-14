DO $migration$
DECLARE
  v_definition text;
  v_old1 text := $old$
    if v_target->>'tipo'='player' then
      v_target_ac_data:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_attack.target_token_id,'normal',v_actor_is_giant);
      v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
    else
      if coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca','') !~ '^[0-9]{1,3}$' then
        raise exception 'O alvo não possui CA numérica válida.';
      end if;
      v_target_ac:=(coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca'))::integer
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac')
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
    end if;$old$;
  v_new1 text := $new$
    if v_target->>'tipo'='player' then
      v_target_ac_data:=public.srd_calcular_ca_personagem_srd(p_campaign_id,v_attack.target_token_id,'normal',v_actor_is_giant);
      v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
    elsif v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL then
      v_target_ac_data:=priv.srd_calcular_ca_alvo_campanha_srd(
        p_campaign_id,v_target->>'sourceCharacterId','normal'
      );
      v_target_ac:=nullif(v_target_ac_data->>'final_ac','')::integer
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
      if v_actor_is_giant then
        select lower(sh.raca_id::text) into v_target_race
          from public.srd_character_sheets sh
         where sh.character_id::text=v_target->>'sourceCharacterId';
        if v_target_race in ('anao','gnomo')
           and not coalesce((v_target_ac_data->>'dexterity_lost')::boolean,false) then
          v_target_ac:=v_target_ac+4;
        end if;
      end if;
    else
      if coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca','') !~ '^[0-9]{1,3}$' then
        raise exception 'O alvo não possui CA numérica válida.';
      end if;
      v_target_ac:=(coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca'))::integer
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac')
        +priv.srd_effective_modifier(p_campaign_id,'token',v_attack.target_token_id,'ac_melee');
    end if;$new$;
  v_old2 text := replace(v_old1,E'\n    ',E'\n  ');
  v_new2 text := replace(v_new1,E'\n    ',E'\n  ');
BEGIN
  v_definition:=pg_get_functiondef('public.srd_resolver_ataque_oportunidade_srd(bigint,uuid)'::regprocedure);
  IF position('v_target_race text;' in v_definition)>0 THEN
    RAISE EXCEPTION 'A variável de raça já existe; migration abortada.';
  END IF;
  IF position('v_actor_is_giant boolean:=false;' in v_definition)=0 THEN
    RAISE EXCEPTION 'Declaração esperada de v_actor_is_giant não encontrada.';
  END IF;
  IF position(v_old1 in v_definition)=0 OR position(v_old2 in v_definition)=0 THEN
    RAISE EXCEPTION 'Blocos originais de CA não encontrados; migration abortada.';
  END IF;
  v_definition:=replace(v_definition,'v_actor_is_giant boolean:=false;','v_actor_is_giant boolean:=false;'||E'\n  v_target_race text;');
  v_definition:=replace(v_definition,v_old1,v_new1);
  v_definition:=replace(v_definition,v_old2,v_new2);
  EXECUTE v_definition;
END
$migration$;