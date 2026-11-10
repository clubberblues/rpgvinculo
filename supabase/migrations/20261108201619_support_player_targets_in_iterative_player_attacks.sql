
DO $migration$
DECLARE
  v_def text;
  v_old text := $old$AND (user_id=auth.uid() OR public.my_role(p_campaign_id)='GM');$old$;
  v_new text := $new$AND EXISTS (
       SELECT 1 FROM public.members m
       WHERE m.campaign_id=p_campaign_id
         AND m.user_id=public.characters.user_id
         AND m.role='PLAYER'
     );$new$;
  v_oid oid;
  v_old_target text := $old$where t.token->>'id'=v_seq.target_token_id and t.token->>'tipo' in ('npc','monstro');$old$;
  v_new_target text := $new$where t.token->>'id'=v_seq.target_token_id and t.token->>'tipo' in ('npc','monstro','player');$new$;
  v_old_ca text := $old$  v_ca_text := coalesce(v_target->>'ac',v_target->'monsterStats'->>'ca');
  if coalesce(v_ca_text,'') !~ '^[0-9]{1,3}$' then raise exception 'O alvo não possui CA numérica válida.'; end if;
  v_ca := v_ca_text::integer + v_effect_ac;$old$;
  v_new_ca text := $new$  if v_target->>'tipo'='player' then
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
  end if;$new$;
  v_old_hp text := $old$  if coalesce(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' then raise exception 'PV máximo do alvo inválido.'; end if;
  v_max_hp:=(v_target->>'maxHp')::integer;
  v_hp:=case when coalesce(v_target->>'hp','') ~ '^-?[0-9]{1,6}$' then (v_target->>'hp')::integer else v_max_hp end;$old$;
  v_new_hp text := $new$  if v_target->>'tipo'='player' then
    select sh.pv_max,sh.pv_atual into v_max_hp,v_hp
    from public.characters ch
    join public.members m on m.campaign_id=ch.campaign_id and m.user_id=ch.user_id
    join public.srd_character_sheets sh on sh.character_id=ch.id
    where ch.id::text=v_seq.target_token_id
      and ch.campaign_id=p_campaign_id and m.role='PLAYER'
    for update of sh;
    if not found or coalesce(v_max_hp,0)<1 or v_hp is null then
      raise exception 'Ficha de PV do personagem alvo ausente ou inválida.';
    end if;
  else
    if coalesce(v_target->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' then raise exception 'PV máximo do alvo inválido.'; end if;
    v_max_hp:=(v_target->>'maxHp')::integer;
    v_hp:=case when coalesce(v_target->>'hp','') ~ '^-?[0-9]{1,6}$' then (v_target->>'hp')::integer else v_max_hp end;
  end if;$new$;
  v_old_sync text := $old$  perform priv.srd_sync_linked_npc_token_vitals(p_campaign_id,v_seq.target_token_id,v_new_hp,v_max_hp);$old$;
  v_new_sync text := $new$  if v_target->>'tipo'='player' then
    update public.srd_character_sheets
       set pv_atual=v_new_hp
     where character_id::text=v_seq.target_token_id;
    if not found then raise exception 'Não foi possível sincronizar os PV da ficha do personagem.'; end if;
  else
    perform priv.srd_sync_linked_npc_token_vitals(p_campaign_id,v_seq.target_token_id,v_new_hp,v_max_hp);
  end if;$new$;
BEGIN
  v_def := pg_get_functiondef('public.srd_calcular_ca_personagem_srd(bigint,text,text)'::regprocedure);
  IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Padrão de autorização da CA não encontrado.'; END IF;
  v_def := replace(v_def,'FUNCTION public.srd_calcular_ca_personagem_srd(','FUNCTION priv.srd_calcular_ca_alvo_campanha_srd(');
  v_def := replace(v_def,v_old,v_new);
  EXECUTE v_def;
  EXECUTE 'REVOKE ALL ON FUNCTION priv.srd_calcular_ca_alvo_campanha_srd(bigint,text,text) FROM PUBLIC, anon, authenticated';

  SELECT p.oid INTO v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
  WHERE n.nspname='public' AND p.proname='resolver_ataque_iterativo_srd'
    AND pg_get_function_identity_arguments(p.oid)='p_campaign_id bigint, p_attempt_id uuid';
  IF v_oid IS NULL THEN RAISE EXCEPTION 'Resolver de ataque iterativo não encontrado.'; END IF;
  v_def:=pg_get_functiondef(v_oid);
  IF (length(v_def)-length(replace(v_def,v_old_target,'')))/length(v_old_target)<>1 THEN
    RAISE EXCEPTION 'Filtro de alvo do resolver não corresponde exatamente a uma ocorrência.';
  END IF;
  v_def:=replace(v_def,v_old_target,v_new_target);
  IF position('  v_end_meta jsonb;' in v_def)=0 THEN RAISE EXCEPTION 'Declaração final do resolver não encontrada.'; END IF;
  v_def:=replace(v_def,'  v_end_meta jsonb;','  v_end_meta jsonb;'||chr(10)||'  v_player_ac jsonb;');
  IF position(v_old_ca in v_def)=0 THEN RAISE EXCEPTION 'Bloco de cálculo de CA do resolver não encontrado.'; END IF;
  v_def:=replace(v_def,v_old_ca,v_new_ca);
  EXECUTE v_def;

  FOR v_oid IN
    SELECT p.oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.proname='aplicar_dano_ataque_iterativo_srd'
  LOOP
    v_def:=pg_get_functiondef(v_oid);
    IF (length(v_def)-length(replace(v_def,v_old_target,'')))/length(v_old_target)<>1 THEN
      RAISE EXCEPTION 'Filtro de alvo do aplicador de dano não corresponde exatamente a uma ocorrência: %',pg_get_function_identity_arguments(v_oid);
    END IF;
    v_def:=replace(v_def,v_old_target,v_new_target);
    IF position(v_old_hp in v_def)=0 THEN
      RAISE EXCEPTION 'Bloco de leitura de PV não encontrado: %',pg_get_function_identity_arguments(v_oid);
    END IF;
    v_def:=replace(v_def,v_old_hp,v_new_hp);
    IF position(v_old_sync in v_def)=0 THEN
      RAISE EXCEPTION 'Bloco de sincronização de PV não encontrado: %',pg_get_function_identity_arguments(v_oid);
    END IF;
    v_def:=replace(v_def,v_old_sync,v_new_sync);
    EXECUTE v_def;
  END LOOP;
END
$migration$;
