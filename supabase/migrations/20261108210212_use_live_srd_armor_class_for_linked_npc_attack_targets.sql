
DO $migration$
DECLARE
  v_helper text;
  v_resolver text;
  v_new text;
  v_old text;
BEGIN
  SELECT pg_get_functiondef('priv.srd_calcular_ca_alvo_campanha_srd(bigint,text,text)'::regprocedure) INTO v_helper;
  v_old := $old$public.my_role(p_campaign_id)='GM'$old$;
  IF position(v_old in v_helper)=0 THEN RAISE EXCEPTION 'Não foi encontrado o controle de acesso GM esperado no cálculo de CA.'; END IF;
  v_new := replace(v_helper,v_old,$new$public.my_role(p_campaign_id) IN ('GM','PLAYER')$new$);
  IF v_new=v_helper THEN RAISE EXCEPTION 'Falha ao ampliar acesso do cálculo de CA para membros autenticados.'; END IF;
  v_helper := v_new;

  v_old := $old$WHERE campaign_id=p_campaign_id AND target_kind='character'
       AND target_id=v_character.id::text AND active=true AND condition_id='flatfooted'$old$;
  v_new := $new$WHERE campaign_id=p_campaign_id AND active=true AND condition_id='flatfooted'
       AND (
         (target_kind='character' AND target_id=v_character.id::text)
         OR (target_kind='token' AND target_id IN (
           SELECT tok->>'id' FROM public.campaigns camp
           CROSS JOIN LATERAL jsonb_array_elements(
             CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
                  THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
           ) tok
           WHERE camp.id=p_campaign_id AND tok->>'tipo'='npc'
             AND tok->>'sourceCharacterId'=v_character.id::text
           UNION
           SELECT tok->>'key' FROM public.campaigns camp
           CROSS JOIN LATERAL jsonb_array_elements(
             CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
                  THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
           ) tok
           WHERE camp.id=p_campaign_id AND tok->>'tipo'='npc'
             AND tok->>'sourceCharacterId'=v_character.id::text
         ))
       )$new$;
  IF position(v_old in v_helper)=0 THEN RAISE EXCEPTION 'Consulta flatfooted não corresponde ao formato esperado.'; END IF;
  v_helper := replace(v_helper,v_old,v_new);

  v_old := $old$WHERE cc.campaign_id=p_campaign_id AND cc.target_kind='character'
       AND cc.target_id=v_character.id::text AND cc.active=true
       AND COALESCE(r.flags->>'loses_dex_ac','false')='true'
       AND cc.condition_id<>'flatfooted'$old$;
  v_new := $new$WHERE cc.campaign_id=p_campaign_id AND cc.active=true
       AND COALESCE(r.flags->>'loses_dex_ac','false')='true'
       AND cc.condition_id<>'flatfooted'
       AND (
         (cc.target_kind='character' AND cc.target_id=v_character.id::text)
         OR (cc.target_kind='token' AND cc.target_id IN (
           SELECT tok->>'id' FROM public.campaigns camp
           CROSS JOIN LATERAL jsonb_array_elements(
             CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
                  THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
           ) tok
           WHERE camp.id=p_campaign_id AND tok->>'tipo'='npc'
             AND tok->>'sourceCharacterId'=v_character.id::text
           UNION
           SELECT tok->>'key' FROM public.campaigns camp
           CROSS JOIN LATERAL jsonb_array_elements(
             CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
                  THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
           ) tok
           WHERE camp.id=p_campaign_id AND tok->>'tipo'='npc'
             AND tok->>'sourceCharacterId'=v_character.id::text
         ))
       )$new$;
  IF position(v_old in v_helper)=0 THEN RAISE EXCEPTION 'Consulta de condições que removem Destreza não corresponde ao formato esperado.'; END IF;
  v_helper := replace(v_helper,v_old,v_new);
  EXECUTE v_helper;

  SELECT pg_get_functiondef('public.resolver_ataque_iterativo_srd(bigint,uuid)'::regprocedure) INTO v_resolver;
  v_old := $old$  if v_target->>'tipo'='player' then
    v_player_ac:=priv.srd_calcular_ca_alvo_campanha_srd(
      p_campaign_id,v_seq.target_token_id,'normal'
    );
    v_ca:=nullif(v_player_ac->>'final_ac','')::integer;
    if v_ca is null then raise exception 'Não foi possível calcular a CA do personagem alvo.'; end if;
    v_ca:=v_ca+case when v_seq.attack_type='atk-corpo'
      then priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_melee')
      else priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_ranged') end;
  else
    v_ca_text := coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca');
    if coalesce(v_ca_text,'') !~ '^[0-9]{1,3}$' then raise exception 'O alvo não possui CA numérica válida.'; end if;
    v_ca := v_ca_text::integer + v_effect_ac;
  end if;$old$;
  v_new := $new$  if v_target->>'tipo'='player' OR (
       v_target->>'tipo'='npc' AND NULLIF(v_target->>'sourceCharacterId','') IS NOT NULL
     ) then
    v_player_ac:=priv.srd_calcular_ca_alvo_campanha_srd(
      p_campaign_id,
      CASE WHEN v_target->>'tipo'='player' THEN v_seq.target_token_id
           ELSE v_target->>'sourceCharacterId' END,
      'normal'
    );
    v_ca:=nullif(v_player_ac->>'final_ac','')::integer;
    if v_ca is null then raise exception 'Não foi possível calcular a CA atual da ficha SRD vinculada ao alvo.'; end if;
    v_ca:=v_ca+case when v_seq.attack_type='atk-corpo'
      then priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_melee')
      else priv.srd_effective_modifier(p_campaign_id,'token',v_seq.target_token_id,'ac_ranged') end;
  else
    v_ca_text := coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca');
    if coalesce(v_ca_text,'') !~ '^[0-9]{1,3}$' then raise exception 'O alvo não possui CA numérica válida.'; end if;
    v_ca := v_ca_text::integer + v_effect_ac;
  end if;$new$;
  IF position(v_old in v_resolver)=0 THEN RAISE EXCEPTION 'Bloco de CA do resolvedor iterativo não corresponde ao esperado.'; END IF;
  v_resolver := replace(v_resolver,v_old,v_new);
  EXECUTE v_resolver;
END
$migration$;
