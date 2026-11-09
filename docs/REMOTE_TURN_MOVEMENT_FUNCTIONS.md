# Definições SQL remotas — movimento, ações, iniciativa e turnos

> Exportação somente de leitura de `pg_get_functiondef` do Supabase remoto em 2026-11-09. Documento de referência e comparação, não migration executável nem dump restaurável.

## Inventário

- Funções exportadas por nome: 41.
- SECURITY DEFINER: 32.
- SECURITY INVOKER: 9.
- anon EXECUTE: 0.
- authenticated EXECUTE: 28.
- Tamanho dos corpos SQL: 124950 caracteres.

| Assinatura | Definer | anon | authenticated | search_path | MD5 |
|---|---:|---:|---:|---|---|
| `priv.consumir_acao_rodada_completa_srd_impl(p_campaign_id bigint, p_actor_id text, p_actor_kind text)` | sim | não | sim | `search_path=public, priv, pg_temp` | `dc01b1d8c2804fd4b4213283a5c448af` |
| `priv.consumir_acao_token_gm_srd_impl(p_campaign_id bigint, p_token_id text, p_acao text)` | sim | não | sim | `search_path=public, priv, pg_temp` | `d447cd9c730f0b9e2da1898bd3c77978` |
| `priv.is_my_turn(p_campaign bigint, p_token bigint)` | sim | não | não | `search_path=public, pg_temp` | `9cc7822fb22d348b5f48b68faa3046e9` |
| `priv.srd_cancelar_movimento_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid)` | sim | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `ee1753fd8f8ad3e6c968942f42816125` |
| `priv.srd_encerrar_reacao_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean)` | sim | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `5cae44f8906a5b12952720e39d76f6cb` |
| `priv.srd_guard_pending_aoo_movement()` | sim | não | não | `search_path=pg_catalog, public, priv, pg_temp` | `9a9a41aa24a8ee42393daaa1ecc1ec37` |
| `priv.srd_registrar_ocultacao_ataque_oportunidade_impl(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)` | sim | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `43cb67bd4552bd98181d8d367850ff90` |
| `priv.srd_request_confusion_turn_roll()` | sim | não | não | `search_path=pg_catalog, public, priv, pg_temp` | `a71eafca99136cf156abe55a0aeceea6` |
| `priv.srd_reservar_reacao_movimento_aoo_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)` | sim | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `3775a7763a3ed392bacb2250504a9a24` |
| `priv.srd_resolve_confusion_turn_impl(p_campaign_id bigint, p_target_kind text, p_target_id text, p_request_id uuid, p_manual_d100 integer)` | sim | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `fd74396de748cabb99445fc5d53e9c1c` |
| `priv.srd_validate_aoo_pending_movement_preview()` | sim | não | não | `search_path=pg_catalog, public, priv, pg_temp` | `aca15b8ef5fd809cbd20b69adf8f01be` |
| `priv.srd_validate_surprise_action(p_campaign_id bigint, p_actor_id text, p_action text)` | sim | não | não | `search_path=pg_catalog, public, priv, pg_temp` | `9fd64a682dadce69e759d8db75c3be64` |
| `public.adicionar_combatente_iniciativa(p_campaign_id bigint, p_combatente_id text, p_nome text, p_valor integer, p_tipo text)` | sim | não | sim | `search_path=public, pg_temp` | `a0428bb1540effb553bca4d0c6687cf5` |
| `public.avancar_turno(p_campaign_id bigint)` | sim | não | sim | `search_path=public, pg_temp` | `0086242101af79898ecae9fb319c2e1e` |
| `public.combat_set_turn(p_token bigint)` | sim | não | não | `search_path=public, pg_temp` | `181f8156fd7b5ab61e81cfa2bf24c5dd` |
| `public.conjurar_magia_com_acao_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text)` | sim | não | não | `search_path=public, pg_temp` | `c2b07ced7d276e4124adb67bea7ccb6d` |
| `public.conjurar_magia_com_acao_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_roll_results integer[])` | sim | não | sim | `search_path=public, pg_temp` | `902eb4878ef7e9b3474bfce94b708739` |
| `public.conjurar_magia_com_acao_srd_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])` | sim | não | não | `search_path=public, pg_temp` | `412b763c16c11dc3de607efddcc4753d` |
| `public.conjurar_magia_com_acao_srd_multialvo_v2(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])` | sim | não | não | `search_path=public, pg_temp` | `b20039b960db80ad2953083c5742c19b` |
| `public.conjurar_magia_com_acao_srd_multialvo_v3(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])` | sim | não | sim | `search_path=public, pg_temp` | `16e636a42055f5716ffdd77707ccf1a7` |
| `public.consumir_acao_rodada_completa_srd(p_campaign_id bigint, p_actor_id text, p_actor_kind text)` | não | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `3cd0cce804652bd00d2a67cbe3839404` |
| `public.consumir_acao_token_gm_srd(p_campaign_id bigint, p_token_id text, p_acao text)` | não | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `153b71929c64b77d2450d91406106703` |
| `public.consumir_acao_turno_srd(p_campaign_id bigint, p_character_id text, p_acao text)` | sim | não | sim | `search_path=public, pg_temp` | `8937c55a8b6ba7632eef037b5f5ecac4` |
| `public.end_turn(p_token bigint)` | sim | não | não | `search_path=public, pg_temp` | `f55fcd29fb4a0ece7d4dc584614c9ad9` |
| `public.finalizar_criacao_personagem_srd(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb, p_pericias jsonb, p_talentos jsonb, p_identidade jsonb, p_idiomas jsonb, p_talentos_bonus jsonb, p_domain_ids text[], p_grimorio jsonb, p_equipamento_metodo text, p_equipamento_resultados jsonb, p_equipamento_itens jsonb)` | não | não | sim | `search_path=public, pg_temp` | `a074c97eff6040bfcf52860c639b5adf` |
| `public.iniciar_iniciativa(p_campaign_id bigint, p_expected_character_ids text[])` | sim | não | não | `search_path=public, pg_temp` | `e23893ad49c180f4ddcd116808ee8d63` |
| `public.iniciar_iniciativa_com_dados(p_campaign_id bigint, p_expected_character_ids text[], p_request_id text, p_gm_d20_results jsonb)` | sim | não | sim | `search_path=public, pg_temp` | `9ed52a747bf33094cc06a8681083fea5` |
| `public.iniciar_iniciativa_com_pedido(p_campaign_id bigint, p_expected_character_ids text[], p_request_id text)` | sim | não | não | `search_path=public, pg_temp` | `ddc82d3342763ddaa89a76e7934a0091` |
| `public.mover_combatente_iniciativa(p_campaign_id bigint, p_indice integer, p_direcao integer)` | sim | não | sim | `search_path=public, pg_temp` | `1e9428072cb0ef03e7d5b4b8ab5388c8` |
| `public.registrar_iniciativa(p_campaign_id bigint, p_personagem_id text, p_nome text, p_valor integer)` | sim | não | não | `search_path=public, pg_temp` | `286f08346c5f55ebf03d754fac7992e2` |
| `public.registrar_iniciativa_d20(p_campaign_id bigint, p_personagem_id text, p_d20 integer)` | sim | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `ccbdedd091fc77fa7e0b49705a69b812` |
| `public.set_turn(cid bigint, p_token bigint)` | não | não | sim | `search_path=public, pg_temp` | `5fd2c90bf9f7d42ba75e3ba949492eca` |
| `public.srd_cancelar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)` | não | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `2a9aa9d725069c8b19f7afab96f3b17a` |
| `public.srd_consultar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)` | sim | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `b3e6ea933e228678ee6dd6f1aca089e5` |
| `public.srd_encerrar_reacao_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean)` | não | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `0c1cd6771a68caf6d49e69af7dd45978` |
| `public.srd_finalizar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)` | sim | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `17fb9a9259675bf9d1c2278135ff2394` |
| `public.srd_listar_movimentos_aoo_pendentes_srd(p_campaign_id bigint)` | sim | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `5ab451a12deb204eea23de23bca1d8cf` |
| `public.srd_registrar_ocultacao_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)` | não | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `a2b55e84b7c44ed4b1b703254c4cc229` |
| `public.srd_reservar_reacao_movimento_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)` | não | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `c72562f95bbe3da5134f29a383011e77` |
| `public.srd_resolve_confusion_turn_srd(p_campaign_id bigint, p_target_kind text, p_target_id text, p_request_id uuid, p_manual_d100 integer)` | não | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `d79f056372807ffb2edddb491c0a158f` |
| `public.srd_solicitar_movimento_com_aoo_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer, p_controller text)` | sim | não | sim | `search_path=pg_catalog, public, priv, pg_temp` | `38c1ffad22be8fe01381770a2bdb06b3` |

## Definições atuais

### `priv.consumir_acao_rodada_completa_srd_impl(p_campaign_id bigint, p_actor_id text, p_actor_kind text)`

```sql
CREATE OR REPLACE FUNCTION priv.consumir_acao_rodada_completa_srd_impl(p_campaign_id bigint, p_actor_id text, p_actor_kind text DEFAULT 'character'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_user uuid := auth.uid();
  v_campaign public.campaigns%rowtype;
  v_combat jsonb;
  v_order jsonb;
  v_actor jsonb;
  v_current_turn integer;
  v_round integer;
  v_kind text := lower(btrim(coalesce(p_actor_kind, 'character')));
  v_target_kind text;
  v_linked_character_id text;
  v_action_state jsonb;
  v_by_actor jsonb;
  v_actor_actions jsonb;
  v_movement jsonb;
begin
  if v_user is null then
    raise exception 'É necessário estar autenticado.';
  end if;
  if nullif(btrim(p_actor_id), '') is null then
    raise exception 'O identificador do ator é obrigatório.';
  end if;
  if v_kind not in ('character', 'token') then
    raise exception 'Tipo de ator inválido.';
  end if;

  select c.* into v_campaign
  from public.campaigns c
  where c.id = p_campaign_id
  for update;
  if not found or upper(coalesce(v_campaign.state, '')) <> 'COMBATE' then
    raise exception 'A campanha não está em combate.';
  end if;

  v_combat := coalesce(v_campaign.combat_data, '{}'::jsonb);
  if lower(coalesce(v_combat->>'active', 'false')) <> 'true' then
    raise exception 'A iniciativa não está ativa.';
  end if;
  v_order := case when jsonb_typeof(v_combat->'turn_order') = 'array'
    then v_combat->'turn_order' else '[]'::jsonb end;
  if jsonb_array_length(v_order) = 0
     or coalesce(v_combat->>'current_turn', '') !~ '^[0-9]+$' then
    raise exception 'A ordem de iniciativa ou o turno atual é inválido.';
  end if;
  v_current_turn := (v_combat->>'current_turn')::integer;
  if v_current_turn < 0 or v_current_turn >= jsonb_array_length(v_order) then
    raise exception 'O índice do turno atual está fora da ordem de iniciativa.';
  end if;
  v_actor := v_order->v_current_turn;
  PERFORM priv.srd_validate_surprise_action(p_campaign_id,BTRIM(p_actor_id),'rodada_completa');
  if v_actor->>'id' is distinct from btrim(p_actor_id) then
    raise exception 'Somente o ator cujo turno está ativo pode executar uma ação de rodada completa.';
  end if;

  if v_kind = 'character' then
    v_target_kind := 'character';
    if coalesce(lower(v_actor->>'is_monster'), 'false') = 'true'
       or not exists (
         select 1 from public.characters ch
         join public.members m on m.campaign_id = ch.campaign_id
           and m.user_id = ch.user_id and m.role = 'PLAYER'
         where ch.id::text = btrim(p_actor_id)
           and ch.campaign_id = p_campaign_id
           and ch.user_id = v_user
       ) then
      raise exception 'A ficha não pertence a este jogador ou não está no turno dele.';
    end if;
  else
    v_target_kind := 'token';
    if not exists (
      select 1 from public.members m
      where m.campaign_id = p_campaign_id and m.user_id = v_user and m.role = 'GM'
    ) then
      raise exception 'Somente o Mestre pode coordenar tokens controlados por ele.';
    end if;
    if coalesce(lower(v_actor->>'is_monster'), 'false') <> 'true' then
      raise exception 'O token não está registrado como ator do Mestre na iniciativa.';
    end if;
    if not exists (
      select 1
      from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens', '[]'::jsonb)) t(token)
      where t.token->>'id' = btrim(p_actor_id)
        and (
          t.token->>'tipo' in ('npc', 'monstro')
          or (
            t.token->>'tipo' = 'player'
            and exists (
              select 1 from public.characters ch
              where ch.id::text = btrim(p_actor_id)
                and ch.user_id = v_user and ch.campaign_id = p_campaign_id
            )
          )
        )
    ) then
      raise exception 'Este token não é controlado pelo Mestre.';
    end if;
    select nullif(t.token->>'sourceCharacterId','') into v_linked_character_id
    from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
    where t.token->>'id'=btrim(p_actor_id) and t.token->>'tipo'='npc'
    limit 1;
  end if;

  if priv.srd_condition_has_flag(p_campaign_id, v_target_kind, btrim(p_actor_id), 'no_actions')
     or (v_linked_character_id is not null and priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'no_actions')) then
    raise exception 'A condição atual impede qualquer ação.';
  end if;
  if priv.srd_condition_has_flag(p_campaign_id, v_target_kind, btrim(p_actor_id), 'no_full_round')
     or (v_linked_character_id is not null and priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'no_full_round')) then
    raise exception 'A condição atual impede ações de rodada completa.';
  end if;
  if priv.srd_condition_has_flag(p_campaign_id, v_target_kind, btrim(p_actor_id), 'only_move_action')
     or priv.srd_condition_has_flag(p_campaign_id, v_target_kind, btrim(p_actor_id), 'one_move_or_standard')
     or (v_linked_character_id is not null and (
       priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'only_move_action')
       or priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'one_move_or_standard')
     )) then
    raise exception 'A condição atual não permite uma ação de rodada completa.';
  end if;

  v_round := case when coalesce(v_combat->>'round', '') ~ '^[0-9]+$'
    then greatest(1, (v_combat->>'round')::integer) else 1 end;
  v_action_state := v_combat->'action_economy';
  if jsonb_typeof(v_action_state) = 'object'
     and coalesce(v_action_state->>'round', '') = v_round::text
     and jsonb_typeof(v_action_state->'by_character') = 'object' then
    v_by_actor := v_action_state->'by_character';
  else
    v_by_actor := '{}'::jsonb;
  end if;
  v_actor_actions := case when jsonb_typeof(v_by_actor->btrim(p_actor_id)) = 'object'
    then v_by_actor->btrim(p_actor_id) else '{}'::jsonb end;

  if coalesce(v_actor_actions->>'padrao', 'false') = 'true'
     or coalesce(v_actor_actions->>'movimento', 'false') = 'true'
     or coalesce(v_actor_actions->>'ataque_total', 'false') = 'true' then
    raise exception 'A ação padrão ou de movimento já foi usada; a ação de rodada completa não está disponível.';
  end if;

  v_movement := v_combat->'movement_usage';
  if jsonb_typeof(v_movement) = 'object'
     and v_movement->>'character_id' = btrim(p_actor_id)
     and v_movement->>'round' = v_round::text
     and v_movement->>'current_turn' = v_current_turn::text
     and coalesce(v_movement->>'moved_squares', '0') ~ '^[0-9]+$'
     and (v_movement->>'moved_squares')::integer > 0 then
    raise exception 'O ator já se movimentou nesta rodada; não pode iniciar uma ação de rodada completa.';
  end if;

  v_actor_actions := v_actor_actions || jsonb_build_object(
    'padrao', true,
    'movimento', true,
    'ataque_total', true
  );
  v_by_actor := jsonb_set(v_by_actor, array[btrim(p_actor_id)], v_actor_actions, true);
  v_action_state := jsonb_build_object('round', v_round, 'by_character', v_by_actor);
  v_combat := v_combat || jsonb_build_object('action_economy', v_action_state);

  if v_kind = 'character'
     and priv.srd_condition_has_flag(p_campaign_id, 'character', btrim(p_actor_id), 'strenuous_action_cost_1hp') then
    update public.srd_character_sheets
       set pv_atual = -1
     where character_id::text = btrim(p_actor_id)
       and coalesce(pv_atual, 0) = 0;
    if found then
      perform priv.srd_sync_character_vital_condition(btrim(p_actor_id), -1, false);
    end if;
  end if;

  update public.campaigns set combat_data = v_combat where id = p_campaign_id;
  return jsonb_build_object(
    'combat_data', v_combat,
    'action_economy', v_action_state,
    'round', v_round,
    'actor_id', btrim(p_actor_id),
    'actor_kind', v_kind,
    'action', 'ataque_total'
  );
end;
$function$

```

### `priv.consumir_acao_token_gm_srd_impl(p_campaign_id bigint, p_token_id text, p_acao text)`

```sql
CREATE OR REPLACE FUNCTION priv.consumir_acao_token_gm_srd_impl(p_campaign_id bigint, p_token_id text, p_acao text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
 v_user uuid:=auth.uid();
 v_campaign public.campaigns%ROWTYPE;
 v_combat jsonb;
 v_order jsonb;
 v_actor jsonb;
 v_action_state jsonb;
 v_by_token jsonb;
 v_token_actions jsonb;
 v_action text:=lower(btrim(coalesce(p_acao,'')));
 v_round integer; v_tokens jsonb; v_token jsonb; v_token_index bigint; v_linked_character_id text; v_token_count integer; v_hp integer; v_max_hp integer;
BEGIN
 IF v_user IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.members WHERE campaign_id=p_campaign_id AND user_id=v_user AND role='GM') THEN
  RAISE EXCEPTION 'Somente o Mestre pode coordenar os tokens controlados por ele.';
 END IF;
 IF v_action NOT IN ('padrao','movimento','rapida') THEN RAISE EXCEPTION 'Ação inválida.'; END IF;
 SELECT c.* INTO v_campaign FROM public.campaigns c WHERE c.id=p_campaign_id FOR UPDATE;
 IF NOT FOUND OR upper(coalesce(v_campaign.state,''))<>'COMBATE' THEN RAISE EXCEPTION 'A campanha não está em combate.'; END IF;
 v_combat:=coalesce(v_campaign.combat_data,'{}'::jsonb);
 IF coalesce(v_combat->>'active','false')<>'true' THEN RAISE EXCEPTION 'A iniciativa não está ativa.'; END IF;
 v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::jsonb END;
 IF coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN RAISE EXCEPTION 'O turno atual é inválido.'; END IF;
 v_actor:=v_order->(v_combat->>'current_turn')::integer;
 PERFORM priv.srd_validate_surprise_action(p_campaign_id,btrim(p_token_id),v_action);
 IF v_actor->>'id' IS DISTINCT FROM btrim(p_token_id) OR coalesce(v_actor->>'is_monster','false')<>'true' THEN RAISE EXCEPTION 'O token não está no turno ativo do Mestre.'; END IF;
 IF NOT EXISTS(
  SELECT 1 FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
  WHERE t.token->>'id'=btrim(p_token_id)
   AND (t.token->>'tipo' IN ('npc','monstro') OR
    (t.token->>'tipo'='player' AND EXISTS(
      SELECT 1 FROM public.characters ch WHERE ch.id::text=btrim(p_token_id)
       AND ch.user_id=v_user AND ch.campaign_id=p_campaign_id
    )))
 ) THEN RAISE EXCEPTION 'Este token não é controlado pelo Mestre.'; END IF;
 v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
 SELECT t.token INTO v_token FROM jsonb_array_elements(v_tokens) t(token)
 WHERE t.token->>'id'=btrim(p_token_id) LIMIT 1;
 v_linked_character_id:=nullif(v_token->>'sourceCharacterId','');
 IF priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'no_actions')
    OR (v_linked_character_id IS NOT NULL AND priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'no_actions')) THEN
  RAISE EXCEPTION 'A condição atual impede qualquer ação.';
 END IF;
 IF v_action<>'movimento' AND (
    priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'only_move_action')
    OR (v_linked_character_id IS NOT NULL AND priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'only_move_action'))
 ) THEN
  RAISE EXCEPTION 'A condição atual permite somente uma ação de movimento.';
 END IF;
 v_round:=CASE WHEN coalesce(v_combat->>'round','') ~ '^[0-9]+$' THEN greatest(1,(v_combat->>'round')::integer) ELSE 1 END;
 v_action_state:=v_combat->'action_economy';
 IF jsonb_typeof(v_action_state)='object' AND coalesce(v_action_state->>'round','')=v_round::text AND jsonb_typeof(v_action_state->'by_character')='object' THEN
  v_by_token:=v_action_state->'by_character';
 ELSE v_by_token:='{}'::jsonb; END IF;
 v_token_actions:=CASE WHEN jsonb_typeof(v_by_token->btrim(p_token_id))='object' THEN v_by_token->btrim(p_token_id) ELSE '{}'::jsonb END;
 IF (priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'one_move_or_standard')
     OR (v_linked_character_id IS NOT NULL AND priv.srd_condition_has_flag(p_campaign_id,'character',v_linked_character_id,'one_move_or_standard')))
    AND v_action IN ('padrao','movimento')
    AND (coalesce(v_token_actions->>'padrao','false')='true' OR coalesce(v_token_actions->>'movimento','false')='true') THEN
  RAISE EXCEPTION 'A condição permite apenas uma ação padrão ou de movimento por rodada.';
 END IF;
 IF coalesce(v_token_actions->>v_action,'false')='true' THEN RAISE EXCEPTION 'Esta ação do token já foi usada nesta rodada.'; END IF;
 v_token_actions:=v_token_actions||jsonb_build_object(v_action,true);
 v_by_token:=jsonb_set(v_by_token,ARRAY[btrim(p_token_id)],v_token_actions,true);
 v_action_state:=jsonb_build_object('round',v_round,'by_character',v_by_token);
 v_combat:=v_combat||jsonb_build_object('action_economy',v_action_state);
 IF v_action='padrao' AND priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_token_id),'strenuous_action_cost_1hp') THEN
  v_tokens:=CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array' THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END;
  SELECT count(*)::integer,min(t.ordinality),(array_agg(t.token ORDER BY t.ordinality))[1]
    INTO v_token_count,v_token_index,v_token FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality)
   WHERE t.token->>'id'=btrim(p_token_id) AND t.token->>'tipo'='npc';
  IF v_token_count=1 AND COALESCE(v_token->>'hp','') ~ '^[0-9]{1,6}$' AND (v_token->>'hp')::integer=0 THEN
   v_hp:=-1; v_max_hp:=NULLIF(v_token->>'maxHp','')::integer;
   v_token:=v_token||jsonb_build_object('hp',v_hp);
   SELECT COALESCE(jsonb_agg(CASE WHEN t.ordinality=v_token_index THEN v_token ELSE t.token END ORDER BY t.ordinality),'[]'::jsonb) INTO v_tokens
     FROM jsonb_array_elements(v_tokens) WITH ORDINALITY t(token,ordinality);
   UPDATE public.campaigns SET cba_data=COALESCE(cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens) WHERE id=p_campaign_id;
   IF v_max_hp IS NOT NULL AND v_max_hp>0 AND NULLIF(BTRIM(v_token->>'sourceCharacterId'),'') IS NOT NULL THEN
    PERFORM priv.srd_sync_linked_npc_token_vitals(p_campaign_id,p_token_id,v_hp,v_max_hp,false);
   END IF;
  END IF;
 END IF;
 UPDATE public.campaigns SET combat_data=v_combat WHERE id=p_campaign_id;
 RETURN jsonb_build_object('combat_data',v_combat,'token_id',btrim(p_token_id),'action',v_action,'round',v_round);
END;
$function$

```

### `priv.is_my_turn(p_campaign bigint, p_token bigint)`

```sql
CREATE OR REPLACE FUNCTION priv.is_my_turn(p_campaign bigint, p_token bigint)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
  select coalesce((select (ordem->>turno_index)::bigint = p_token
                   from public.combat_state where campaign_id = p_campaign and ativo), false)
$function$

```

### `priv.srd_cancelar_movimento_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid)`

```sql
CREATE OR REPLACE FUNCTION priv.srd_cancelar_movimento_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_pending priv.srd_aoo_pending_movements%rowtype; v_reactions jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode cancelar o movimento pendente.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where pending_id=p_pending_id and campaign_id=p_campaign_id for update;
  if not found then raise exception 'Movimento pendente não encontrado.'; end if;
  if v_pending.status not in ('waiting_reactions','ready_to_commit') then
    raise exception 'Este movimento não está mais pendente.';
  end if;
  update priv.srd_aoo_attacks set status='cancelled'
  where pending_id=p_pending_id
    and status in ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_miss_chance','awaiting_damage');
  select coalesce(jsonb_agg(
    case when r.value->>'status' in ('waiting','reserved','attack_started','hit_pending_damage')
      then r.value||jsonb_build_object('status','skipped','skip_reason','movement_cancelled')
      else r.value end order by r.ordinality),'[]'::jsonb)
  into v_reactions
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality r(value,ordinality);
  update priv.srd_aoo_pending_movements
  set status='cancelled',pending_reactions=v_reactions,cancelled_at=now(),updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('cancelled',true,'pending_id',p_pending_id,
    'mover_token_id',v_pending.mover_token_id,'reactions',v_reactions);
end;
$function$

```

### `priv.srd_encerrar_reacao_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean)`

```sql
CREATE OR REPLACE FUNCTION priv.srd_encerrar_reacao_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_idx bigint;
  v_reaction jsonb;
  v_attack priv.srd_aoo_attacks%rowtype;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode encerrar uma reação pendente.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'Movimento não está aguardando reações.';
  end if;
  select ordinality,value into v_idx,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where value->>'reactor_token_id'=btrim(p_reactor_token_id) limit 1;
  if v_reaction is null then raise exception 'Reação não encontrada neste movimento.'; end if;
  if v_reaction->>'status' in ('attack_started','hit_pending_damage') then
    if not p_cancel_attack then
      raise exception 'O ataque já começou; resolva-o ou autorize explicitamente seu cancelamento.';
    end if;
    select * into v_attack from priv.srd_aoo_attacks
    where attack_id=(v_reaction->>'attack_id')::uuid and campaign_id=p_campaign_id for update;
    if not found or v_attack.status not in ('awaiting_attack_roll','awaiting_critical_confirmation','awaiting_miss_chance','awaiting_damage') then
      raise exception 'Ataque não pode ser cancelado neste estado.';
    end if;
    update priv.srd_aoo_attacks set status='cancelled' where attack_id=v_attack.attack_id;
  elsif v_reaction->>'status' not in ('waiting','reserved') then
    raise exception 'Esta reação já foi encerrada.';
  end if;
  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_idx-1)::text],
      v_reaction||jsonb_build_object('status','skipped','skip_reason',case
        when v_reaction->>'status' in ('reserved','attack_started','hit_pending_damage')
          then 'gm_cancelled_after_reservation' else 'gm_declined_reaction' end),
      false),updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('closed',true,'pending_id',p_pending_id,
    'reactor_token_id',p_reactor_token_id,'reaction_spent',
    (v_reaction->>'status') in ('reserved','attack_started','hit_pending_damage'));
end;
$function$

```

### `priv.srd_guard_pending_aoo_movement()`

```sql
CREATE OR REPLACE FUNCTION priv.srd_guard_pending_aoo_movement()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_old_token jsonb;
  v_new_token jsonb;
  v_commit_id text;
begin
  if new.cba_data is not distinct from old.cba_data then return new; end if;
  select * into v_pending
  from priv.srd_aoo_pending_movements p
  where p.campaign_id=new.id
    and p.status in ('waiting_reactions','ready_to_commit')
  order by p.created_at desc limit 1;
  if not found then return new; end if;

  select t into v_old_token
  from jsonb_array_elements(case when jsonb_typeof(old.cba_data->'tokens')='array'
    then old.cba_data->'tokens' else '[]'::jsonb end) t
  where t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id
  limit 1;
  select t into v_new_token
  from jsonb_array_elements(case when jsonb_typeof(new.cba_data->'tokens')='array'
    then new.cba_data->'tokens' else '[]'::jsonb end) t
  where t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id
  limit 1;

  v_commit_id:=current_setting('app.srd_aoo_pending_commit',true);

  if v_old_token is not null and v_new_token is null
     and v_commit_id is distinct from v_pending.pending_id::text then
    raise exception 'Remoção do token bloqueada: há um movimento aguardando resolução de ataques de oportunidade.';
  end if;

  if v_old_token is not null and v_new_token is not null
     and ((v_old_token->>'gridX') is distinct from (v_new_token->>'gridX')
       or (v_old_token->>'gridY') is distinct from (v_new_token->>'gridY')) then
    if v_commit_id is distinct from v_pending.pending_id::text then
      raise exception 'Movimento bloqueado: há um ataque de oportunidade pendente de resolução.';
    end if;
  end if;
  return new;
end;
$function$

```

### `priv.srd_registrar_ocultacao_ataque_oportunidade_impl(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)`

```sql
CREATE OR REPLACE FUNCTION priv.srd_registrar_ocultacao_ataque_oportunidade_impl(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_attack priv.srd_aoo_attacks%rowtype;
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_next_status text;
  v_reaction_index integer;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode registrar a chance de falha por ocultação.';
  end if;
  if p_manual_d100 is null or p_manual_d100 not between 1 and 100 then
    raise exception 'A chance de falha exige um resultado D100 físico entre 1 e 100.';
  end if;
  select * into v_attack from priv.srd_aoo_attacks
  where campaign_id=p_campaign_id and attack_id=p_attack_id for update;
  if not found or v_attack.created_by<>auth.uid() then
    raise exception 'Ataque não encontrado ou sem autorização.';
  end if;
  if v_attack.status<>'awaiting_miss_chance' then
    if v_attack.resolution_data ? 'concealment_d100'
       and (v_attack.resolution_data->>'concealment_d100')::integer=p_manual_d100 then
      return jsonb_build_object('attack_id',p_attack_id,'status',v_attack.status,
        'miss_chance',50,'d100',p_manual_d100,
        'missed',coalesce((v_attack.resolution_data->>'concealment_missed')::boolean,false),
        'replayed',true);
    end if;
    raise exception 'Este ataque não aguarda a rolagem de ocultação.';
  end if;
  if coalesce(v_attack.resolution_data->>'concealment_miss_chance','')<>'50'
     or coalesce(v_attack.resolution_data->>'concealment_pending_status','')<>'awaiting_damage' then
    raise exception 'Os dados de ocultação do ataque são inválidos.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=v_attack.pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then
    raise exception 'O movimento que originou o ataque não está mais pendente.';
  end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
    or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate avançou antes da rolagem de ocultação.';
  end if;
  v_next_status:=case when p_manual_d100<=50 then 'miss' else 'awaiting_damage' end;
  update priv.srd_aoo_attacks
  set status=v_next_status,
      resolution_data=resolution_data||jsonb_build_object(
        'concealment_d100',p_manual_d100,
        'concealment_missed',(p_manual_d100<=50),
        'concealment_resolved_at',now()
      ),
      resolved_at=case when p_manual_d100<=50 then now() else resolved_at end
  where attack_id=p_attack_id returning * into v_attack;
  select (e.ordinality-1)::integer into v_reaction_index
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality e(value,ordinality)
  where e.value->>'reservation_id'=v_attack.reaction_id::text limit 1;
  if v_reaction_index is null then raise exception 'A reação vinculada ao ataque não foi encontrada.'; end if;
  update priv.srd_aoo_pending_movements p
  set pending_reactions=jsonb_set(p.pending_reactions,ARRAY[v_reaction_index::text],
    (p.pending_reactions->v_reaction_index)||jsonb_build_object(
      'status',case when p_manual_d100<=50 then 'miss' else 'hit_pending_damage' end,
      'concealment_d100',p_manual_d100,'concealment_missed',(p_manual_d100<=50)
    ),false),updated_at=now()
  where p.pending_id=v_attack.pending_id;
  return jsonb_build_object('attack_id',p_attack_id,'status',v_next_status,
    'd100',p_manual_d100,'miss_chance',50,'missed',(p_manual_d100<=50),'replayed',false);
end;
$function$

```

### `priv.srd_request_confusion_turn_roll()`

```sql
CREATE OR REPLACE FUNCTION priv.srd_request_confusion_turn_roll()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_order jsonb;
  v_index integer;
  v_actor jsonb;
  v_target_kind text;
  v_target_id text;
  v_round integer;
  v_condition public.srd_campaign_conditions%rowtype;
  v_request uuid;
  v_name text;
begin
  if new.combat_data is null
     or coalesce(new.combat_data->>'active','false')<>'true'
     or upper(coalesce(new.state,''))<>'COMBATE' then
    return new;
  end if;
  if tg_op='UPDATE'
     and new.combat_data->>'current_turn' is not distinct from old.combat_data->>'current_turn'
     and new.combat_data->>'round' is not distinct from old.combat_data->>'round'
     and new.combat_data->'surprise'->>'phase' is not distinct from old.combat_data->'surprise'->>'phase' then
    return new;
  end if;
  v_order:=case when jsonb_typeof(new.combat_data->'turn_order')='array'
    then new.combat_data->'turn_order' else '[]'::jsonb end;
  if jsonb_array_length(v_order)=0
     or coalesce(new.combat_data->>'current_turn','') !~ '^[0-9]+$' then
    return new;
  end if;
  v_index:=(new.combat_data->>'current_turn')::integer;
  if v_index<0 or v_index>=jsonb_array_length(v_order) then return new; end if;
  v_actor:=v_order->v_index;
  v_target_id:=nullif(btrim(v_actor->>'id'),'');
  if v_target_id is null then return new; end if;
  v_target_kind:=case when coalesce((v_actor->>'is_monster')::boolean,false) then 'token' else 'character' end;
  v_round:=greatest(0,coalesce(nullif(new.combat_data->>'round','')::integer,0));

  select * into v_condition
  from public.srd_campaign_conditions
  where campaign_id=new.id and target_kind=v_target_kind
    and target_id=v_target_id and condition_id='confused' and active=true
  order by condition_instance_id desc limit 1
  for update;
  if not found then return new; end if;

  if coalesce(v_condition.notes->>'confusion_pending_round','')=v_round::text
     and coalesce(v_condition.notes->>'confusion_pending_turn','')=v_index::text
     and nullif(v_condition.notes->>'confusion_pending_request_id','') is not null then
    return new;
  end if;
  v_request:=gen_random_uuid();
  v_name:=coalesce(v_actor->>'name',v_actor->>'nome','Combatente confuso');

  update public.srd_campaign_conditions
  set notes=coalesce(notes,'{}'::jsonb)||jsonb_build_object(
    'confusion_pending_request_id',v_request::text,
    'confusion_pending_round',v_round,
    'confusion_pending_turn',v_index,
    'confusion_pending_at',now()
  )
  where condition_instance_id=v_condition.condition_instance_id;

  insert into public.campaign_log(campaign_id,type,visibilidade,data)
  values(new.id,'test_request','PUBLIC',jsonb_build_object(
    'tipo','Confusão — comportamento aleatório (D100)',
    'resolution_type','confusion_d100',
    'request_id',v_request::text,
    'alvos',case when v_target_kind='character' then jsonb_build_array(v_target_id) else '[]'::jsonb end,
    'npc_alvos',case when v_target_kind='token' then jsonb_build_array(v_target_id) else '[]'::jsonb end,
    'target_kind',v_target_kind,
    'target_id',v_target_id,
    'combat_round',v_round,
    'current_turn',v_index,
    'mestre','Sistema',
    'mestre_id',new.owner_id,
    'detalhes',jsonb_build_array(jsonb_build_object('id',v_target_id,'name',v_name))
  ));
  return new;
end;
$function$

```

### `priv.srd_reservar_reacao_movimento_aoo_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)`

```sql
CREATE OR REPLACE FUNCTION priv.srd_reservar_reacao_movimento_aoo_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_profile jsonb;
  v_character_id text;
  v_confused_engagement boolean:=false;
  v_token_type text;
  v_flat_footed boolean:=false;
  v_has_combat_reflexes boolean:=false;
  v_disabled boolean:=false;
  v_index bigint;
  v_reaction jsonb;
  v_reactor_token jsonb;
  v_trigger text;
  v_reservation jsonb;
  v_updated jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode autorizar a reação.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento não está aguardando reações.'; end if;
  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
    or coalesce(v_campaign.combat_data->>'active','false')<>'true'
    or coalesce(v_campaign.combat_data->>'round','') !~ '^[0-9]+$'
    or greatest(1,(v_campaign.combat_data->>'round')::integer)<>v_pending.combat_round
    or coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$'
    or (v_campaign.combat_data->>'current_turn')::integer<>v_pending.current_turn then
    raise exception 'O combate avançou desde a solicitação; o movimento precisa ser reavaliado.';
  end if;
  select ordinality,value into v_index,v_reaction
  from jsonb_array_elements(v_pending.pending_reactions) with ordinality
  where coalesce(value->>'reactor_token_id','')=btrim(p_reactor_token_id) limit 1;
  if v_reaction is null then raise exception 'Este token não está entre os combatentes ameaçadores detectados.'; end if;
  if v_reaction->>'status'='reserved' then
    return jsonb_build_object('reserved',true,'duplicate',true,
      'reservation_id',v_reaction->>'reservation_id','pending_id',p_pending_id,
      'reactor_token_id',p_reactor_token_id);
  end if;
  if v_reaction->>'status'<>'waiting' then raise exception 'Esta reação já foi processada.'; end if;
  select t->>'tipo' into v_token_type
  from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
  where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id) limit 1;
  if v_token_type is null then raise exception 'Token reator não existe mais na cena.'; end if;
  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_reactor_token_id));
  v_character_id:=v_profile->>'character_id';

  v_confused_engagement:=priv.srd_condition_has_flag(
    p_campaign_id,'token',btrim(p_reactor_token_id),'no_aoo_against_unengaged');
  if nullif(v_character_id,'') is not null then
    v_confused_engagement:=v_confused_engagement or priv.srd_condition_has_flag(
      p_campaign_id,'character',v_character_id,'no_aoo_against_unengaged');
  end if;
  if v_confused_engagement and not priv.srd_confusion_aoo_engaged(
    p_campaign_id,btrim(p_reactor_token_id),v_character_id,v_pending.mover_token_id) then
    update priv.srd_aoo_pending_movements
    set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
      v_reaction||jsonb_build_object('status','ineligible','reason','confused_target_not_engaged'),
      false),updated_at=now()
    where pending_id=p_pending_id;
    return jsonb_build_object('reserved',false,'ineligible',true,
      'reason','confused_target_not_engaged','reactor_token_id',p_reactor_token_id);
  end if;

  v_disabled :=
    priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_actions')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'helpless')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stunned')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'unconscious')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dying')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'stable')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'dead')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_threaten_squares')
    or priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'cannot_attack');
  if v_character_id is not null then
    v_disabled:=v_disabled
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_actions')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'helpless')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'stunned')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'unconscious')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dying')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'stable')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'dead')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_threaten_squares')
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'cannot_attack');
  end if;
  if v_disabled then
    update priv.srd_aoo_pending_movements
    set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
      v_reaction||jsonb_build_object('status','ineligible','reason','reactor_condition_prevents_aoo'),
      false),updated_at=now()
    where pending_id=p_pending_id;
    return jsonb_build_object('reserved',false,'ineligible',true,
      'reason','reactor_condition_prevents_aoo','reactor_token_id',p_reactor_token_id);
  end if;

  v_flat_footed:=priv.srd_condition_has_flag(p_campaign_id,'token',btrim(p_reactor_token_id),'no_aoo');
  if v_character_id is not null then
    v_flat_footed:=v_flat_footed
      or priv.srd_condition_has_flag(p_campaign_id,'character',v_character_id,'no_aoo');
  end if;
  if v_flat_footed then
    if v_character_id is not null then
      select exists(
        select 1 from public.srd_character_sheets sh
        cross join lateral jsonb_array_elements(
          case when jsonb_typeof(sh.talentos)='array' then sh.talentos else '[]'::jsonb end
        ) feat
        where sh.character_id::text=v_character_id
          and (lower(coalesce(feat->>'id','')) in
            ('reflexos_de_combate','combat_reflexes','srd35_feat_combat_reflexes')
            or lower(coalesce(feat->>'nome','')) in ('reflexos de combate','combat reflexes'))
      ) into v_has_combat_reflexes;
    else
      select t into v_reactor_token
      from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
      where t->>'id'=btrim(p_reactor_token_id) or t->>'key'=btrim(p_reactor_token_id) limit 1;
      v_has_combat_reflexes:=concat_ws(',',
        v_reactor_token->'monsterStats'->>'feats',
        v_reactor_token->'monsterStats'->>'talentos',
        v_reactor_token->'monsterStats'->'dados_tecnicos'->'statblock'->>'feats',
        v_reactor_token->'monsterStats'->'dados_tecnicos'->>'feats'
      ) ~* '(^|[,;[:space:]])combat[[:space:]]+reflexesb?([,;[:space:]]|$)';
    end if;
    if not v_has_combat_reflexes then
      update priv.srd_aoo_pending_movements
      set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],
        v_reaction||jsonb_build_object('status','ineligible',
          'reason','flat_footed_without_combat_reflexes'),false),updated_at=now()
      where pending_id=p_pending_id;
      return jsonb_build_object('reserved',false,'ineligible',true,
        'reason','flat_footed_without_combat_reflexes','reactor_token_id',p_reactor_token_id);
    end if;
  end if;

  v_trigger:=v_reaction->>'trigger_key';
  v_reservation:=public.srd_reservar_ataque_oportunidade_srd(
    p_campaign_id,btrim(p_reactor_token_id),v_trigger,v_flat_footed);
  v_updated:=v_reaction||jsonb_build_object(
    'status','reserved','reservation_id',v_reservation->>'reaction_id',
    'reservation_number',v_reservation->'used','reservation_limit',v_reservation->'limit',
    'flat_footed',v_flat_footed);
  update priv.srd_aoo_pending_movements
  set pending_reactions=jsonb_set(pending_reactions,ARRAY[(v_index-1)::text],v_updated,false),
      updated_at=now()
  where pending_id=p_pending_id;
  return jsonb_build_object('reserved',true,
    'duplicate',coalesce((v_reservation->>'duplicate')::boolean,false),
    'reservation',v_reservation,'pending_id',p_pending_id,
    'reactor_token_id',p_reactor_token_id,'reaction',v_updated);
end;
$function$

```

### `priv.srd_resolve_confusion_turn_impl(p_campaign_id bigint, p_target_kind text, p_target_id text, p_request_id uuid, p_manual_d100 integer)`

```sql
CREATE OR REPLACE FUNCTION priv.srd_resolve_confusion_turn_impl(p_campaign_id bigint, p_target_kind text, p_target_id text, p_request_id uuid, p_manual_d100 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
 v_condition public.srd_campaign_conditions%rowtype;
 v_campaign public.campaigns%rowtype;
 v_actor jsonb;
 v_order jsonb;
 v_name text;
 v_outcome text;
 v_description text;
 v_existing integer;
 v_caster_id text;
 v_caster_present boolean:=false;
 v_actor_token_id text;
 v_caster_token_id text;
 v_selected_target_token_id text;
 v_caster_token_count integer:=0;
begin
 if auth.uid() is null then raise exception 'É necessário estar autenticado.'; end if;
 if p_target_kind not in ('character','token') or nullif(btrim(p_target_id),'') is null then
   raise exception 'Alvo da condição Confuso inválido.';
 end if;
 if p_manual_d100 is null or p_manual_d100 not between 1 and 100 then
   raise exception 'O comportamento aleatório exige uma rolagem física de D100 entre 1 e 100.';
 end if;
 select * into v_campaign from public.campaigns where id=p_campaign_id for update;
 if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
   or coalesce(v_campaign.combat_data->>'active','false')<>'true' then
   raise exception 'A campanha não está em combate ativo.';
 end if;
 v_order:=case when jsonb_typeof(v_campaign.combat_data->'turn_order')='array'
   then v_campaign.combat_data->'turn_order' else '[]'::jsonb end;
 if coalesce(v_campaign.combat_data->>'current_turn','') !~ '^[0-9]+$' then
   raise exception 'O turno atual é inválido.';
 end if;
 v_actor:=v_order->(v_campaign.combat_data->>'current_turn')::integer;
 if v_actor->>'id' is distinct from p_target_id
   or (case when coalesce((v_actor->>'is_monster')::boolean,false) then 'token' else 'character' end)<>p_target_kind then
   raise exception 'A rolagem só pode ser registrada no turno do combatente confuso.';
 end if;
 if p_target_kind='token' then
   if public.my_role(p_campaign_id) is distinct from 'GM' then
     raise exception 'Somente o Mestre pode rolar pelo NPC ou monstro.';
   end if;
 else
   if not exists(select 1 from public.characters ch
     where ch.id::text=p_target_id and ch.campaign_id=p_campaign_id
       and (ch.user_id=auth.uid() or public.my_role(p_campaign_id)='GM')) then
     raise exception 'Somente o dono da ficha ou o Mestre pode registrar esta rolagem.';
   end if;
 end if;
 select * into v_condition from public.srd_campaign_conditions
 where campaign_id=p_campaign_id and target_kind=p_target_kind
   and target_id=p_target_id and condition_id='confused' and active=true
 order by condition_instance_id desc limit 1 for update;
 if not found then raise exception 'O combatente não possui a condição Confuso ativa.'; end if;

 if v_condition.notes->>'confusion_last_request_id'=p_request_id::text then
   v_existing:=nullif(v_condition.notes->>'confusion_last_d100','')::integer;
   if v_existing=p_manual_d100 then
     return coalesce(v_condition.notes->'confusion_last_result','{}'::jsonb)||jsonb_build_object('replayed',true);
   end if;
   raise exception 'Esta solicitação já foi respondida com outro resultado.';
 end if;
 if v_condition.notes->>'confusion_pending_request_id' is distinct from p_request_id::text then
   raise exception 'A solicitação de comportamento aleatório expirou ou não corresponde ao turno atual.';
 end if;

 v_name:=coalesce(v_actor->>'name',v_actor->>'nome','Combatente confuso');
 v_caster_id:=coalesce(nullif(v_condition.source_actor_id,''),nullif(v_condition.notes->>'caster_character_id',''));
 SELECT t.token->>'id' INTO v_actor_token_id
 FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
 WHERE t.token->>'id'=p_target_id OR t.token->>'sourceCharacterId'=p_target_id
 ORDER BY CASE WHEN t.token->>'id'=p_target_id THEN 0 ELSE 1 END
 LIMIT 1;
 IF v_caster_id IS NOT NULL THEN
   v_caster_present:=EXISTS(
     SELECT 1 FROM jsonb_array_elements(v_order) e(entry)
     WHERE e.entry->>'id'=v_caster_id
        OR EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
                  WHERE t.token->>'id'=e.entry->>'id' AND t.token->>'sourceCharacterId'=v_caster_id)
   );
   SELECT count(*)::integer,(array_agg(t.token->>'id'))[1]
   INTO v_caster_token_count,v_caster_token_id
   FROM jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t(token)
   WHERE t.token->>'id'=v_caster_id OR t.token->>'sourceCharacterId'=v_caster_id;
   IF v_caster_token_count<>1 THEN v_caster_token_id:=NULL; END IF;
 END IF;
 if p_manual_d100 between 1 and 10 then
   IF v_caster_id IS NOT NULL AND v_caster_present AND v_caster_token_id IS NOT NULL THEN
     v_outcome:='attack_caster';
     v_selected_target_token_id:=v_caster_token_id;
     v_description:='Ataca o conjurador responsável pela condição. Alvo obrigatório: token '||v_caster_token_id||'. O Mestre deve confirmar alcance e possibilidade de ataque.';
   ELSE
     v_outcome:='babble';
     v_description:='Não foi possível identificar o conjurador na iniciativa; balbucia incoerentemente e não age.';
   END IF;
 elsif p_manual_d100 between 11 and 20 then
   v_outcome:='act_normally';
   v_description:='Age normalmente neste turno.';
 elsif p_manual_d100 between 21 and 50 then
   v_outcome:='babble';
   v_description:='Fica balbuciando incoerentemente, sem realizar ações.';
 elsif p_manual_d100 between 51 and 70 then
   IF v_caster_id IS NOT NULL AND v_caster_present AND v_caster_token_id IS NOT NULL THEN
     v_outcome:='flee';
     v_selected_target_token_id:=v_caster_token_id;
     v_description:='Foge do conjurador responsável pela condição em velocidade máxima. Referência para afastamento: token '||v_caster_token_id||'. O Mestre deve determinar uma rota desimpedida.';
   ELSE
     v_outcome:='babble';
     v_description:='Não foi possível identificar o conjurador na iniciativa; balbucia incoerentemente e não age.';
   END IF;
 else
   SELECT NULLIF(BTRIM(priv.srd_confusion_nearest_target_id(p_campaign_id,v_actor_token_id)),'')
     INTO v_selected_target_token_id;
   IF v_selected_target_token_id IS NOT NULL THEN
     v_outcome:='attack_nearest';
     v_description:='Ataca a criatura mais próxima. Alvo determinado pela mesa: token '||v_selected_target_token_id||'.';
   ELSE
     v_outcome:='babble';
     v_description:='Não há outra criatura com posição válida na grade; balbucia incoerentemente e não age.';
   END IF;
 end if;

 update public.srd_campaign_conditions
 set notes=coalesce(notes,'{}'::jsonb)
   - 'confusion_pending_request_id' - 'confusion_pending_round' - 'confusion_pending_turn' - 'confusion_pending_at'
   || jsonb_build_object(
     'confusion_last_request_id',p_request_id::text,
     'confusion_last_round',greatest(0,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0)),
     'confusion_last_d100',p_manual_d100,
     'confusion_last_outcome',v_outcome,'confusion_last_selected_target_token_id',v_selected_target_token_id,
     'confusion_last_result',jsonb_build_object(
       'target_kind',p_target_kind,'target_id',p_target_id,'name',v_name,
       'd100',p_manual_d100,'outcome',v_outcome,'description',v_description,
       'caster_character_id',v_caster_id,'caster_present_in_initiative',v_caster_present,'selected_target_token_id',v_selected_target_token_id,
       'round',greatest(0,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0)),
       'request_id',p_request_id::text
     )
   )
 where condition_instance_id=v_condition.condition_instance_id;

 insert into public.campaign_log(campaign_id,type,visibilidade,data)
 values(p_campaign_id,'system_event','PUBLIC',jsonb_build_object(
   'event','confusion_turn_resolved',
   'target_kind',p_target_kind,'target_id',p_target_id,'name',v_name,
   'd100',p_manual_d100,'outcome',v_outcome,'description',v_description,
   'round',greatest(0,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0)),
   'request_id',p_request_id::text
 ));

 return jsonb_build_object('target_kind',p_target_kind,'target_id',p_target_id,
   'name',v_name,'d100',p_manual_d100,'outcome',v_outcome,
   'description',v_description,'caster_character_id',v_caster_id,'selected_target_token_id',v_selected_target_token_id,
   'caster_present_in_initiative',v_caster_present,
   'request_id',p_request_id::text,'replayed',false);
end;
$function$

```

### `priv.srd_validate_aoo_pending_movement_preview()`

```sql
CREATE OR REPLACE FUNCTION priv.srd_validate_aoo_pending_movement_preview()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_preview jsonb;
begin
  perform set_config('app.srd_aoo_pending_commit',new.pending_id::text,true);
  begin
    if new.movement_controller='player' then
      v_preview:=public.mover_token_player_cba(
        new.campaign_id,new.mover_token_id,new.destination_x,new.destination_y
      );
    else
      v_preview:=public.mover_token_gm_cba_srd(
        new.campaign_id,new.mover_token_id,new.destination_x,new.destination_y
      );
    end if;
    raise exception using errcode='P0001',message='__SRD_AOO_PREVIEW_ROLLBACK__';
  exception when others then
    if sqlerrm='__SRD_AOO_PREVIEW_ROLLBACK__' then
      null;
    else
      raise;
    end if;
  end;
  return new;
end;
$function$

```

### `priv.srd_validate_surprise_action(p_campaign_id bigint, p_actor_id text, p_action text)`

```sql
CREATE OR REPLACE FUNCTION priv.srd_validate_surprise_action(p_campaign_id bigint, p_actor_id text, p_action text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
 v_combat jsonb;v_surprise jsonb;v_order jsonb;v_idx integer;v_actor jsonb;v_aware jsonb;
 v_used jsonb;v_economy jsonb;v_by_actor jsonb;v_movement jsonb;
BEGIN
 SELECT combat_data INTO v_combat FROM public.campaigns WHERE id=p_campaign_id;
 v_surprise:=coalesce(v_combat->'surprise','{}'::jsonb);
 IF coalesce(v_surprise->>'phase','')<>'surprise_round' THEN RETURN; END IF;
 v_order:=CASE WHEN jsonb_typeof(v_combat->'turn_order')='array' THEN v_combat->'turn_order' ELSE '[]'::jsonb END;
 IF coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' THEN RAISE EXCEPTION 'Turno da rodada surpresa inválido.'; END IF;
 v_idx:=(v_combat->>'current_turn')::integer;
 IF v_idx<0 OR v_idx>=jsonb_array_length(v_order) THEN RAISE EXCEPTION 'Índice do turno inválido na rodada surpresa.'; END IF;
 v_actor:=v_order->v_idx;
 IF v_actor->>'id' IS DISTINCT FROM btrim(p_actor_id) THEN RAISE EXCEPTION 'Somente o participante ativo pode agir na rodada surpresa.'; END IF;
 v_aware:=CASE WHEN jsonb_typeof(v_surprise->'aware_ids')='array' THEN v_surprise->'aware_ids' ELSE '[]'::jsonb END;
 IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements_text(v_aware) x(id) WHERE x.id=btrim(p_actor_id)) THEN
  RAISE EXCEPTION 'Este participante foi surpreendido e não pode agir na rodada surpresa.';
 END IF;
 IF p_action NOT IN ('padrao','movimento') THEN
  RAISE EXCEPTION 'Na rodada surpresa, somente uma ação padrão ou uma ação de movimento é permitida.';
 END IF;
 v_economy:=v_combat->'action_economy';
 v_by_actor:=CASE WHEN jsonb_typeof(v_economy->'by_character')='object' THEN v_economy->'by_character' ELSE '{}'::jsonb END;
 v_used:=v_by_actor->btrim(p_actor_id);
 IF jsonb_typeof(v_used)='object' AND
   (coalesce(v_used->>'padrao','false')='true' OR coalesce(v_used->>'movimento','false')='true') THEN
  RAISE EXCEPTION 'Na rodada surpresa, cada participante consciente pode realizar somente uma ação padrão ou de movimento.';
 END IF;
 v_movement:=v_combat->'movement_usage';
 IF p_action='padrao' AND jsonb_typeof(v_movement)='object'
   AND v_movement->>'character_id'=btrim(p_actor_id)
   AND coalesce(v_movement->>'moved_squares','0') ~ '^[0-9]+$'
   AND (v_movement->>'moved_squares')::integer>0 THEN
  RAISE EXCEPTION 'O participante já utilizou sua ação de movimento na rodada surpresa.';
 END IF;
END;
$function$

```

### `public.adicionar_combatente_iniciativa(p_campaign_id bigint, p_combatente_id text, p_nome text, p_valor integer, p_tipo text)`

```sql
CREATE OR REPLACE FUNCTION public.adicionar_combatente_iniciativa(p_campaign_id bigint, p_combatente_id text, p_nome text, p_valor integer, p_tipo text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_role TEXT;
  v_estado TEXT;
  v_scene JSONB;
  v_data JSONB;
  v_order JSONB;
  v_expected JSONB;
  v_entry JSONB;
  v_sorted JSONB;
  v_current_id TEXT;
  v_current_turn INTEGER := 0;
  v_round INTEGER := 1;
  v_active BOOLEAN := FALSE;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  SELECT m.role INTO v_role
  FROM public.members AS m
  WHERE m.campaign_id = p_campaign_id AND m.user_id = auth.uid()
  LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode inserir reforços na iniciativa.';
  END IF;
  IF NULLIF(BTRIM(p_combatente_id), '') IS NULL OR NULLIF(BTRIM(p_nome), '') IS NULL THEN
    RAISE EXCEPTION 'Identificador e nome do combatente são obrigatórios.';
  END IF;
  IF p_tipo IS DISTINCT FROM 'npc' AND p_tipo IS DISTINCT FROM 'monstro' THEN
    RAISE EXCEPTION 'Tipo de reforço inválido.';
  END IF;
  IF p_valor IS NULL OR p_valor < -50 OR p_valor > 100 THEN
    RAISE EXCEPTION 'A iniciativa deve ser um número entre -50 e 100.';
  END IF;

  SELECT state, cba_data, combat_data INTO v_estado, v_scene, v_data
  FROM public.campaigns
  WHERE id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF UPPER(COALESCE(v_estado, '')) <> 'COMBATE' THEN
    RAISE EXCEPTION 'Reforços só entram na iniciativa durante o combate.';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
           THEN v_scene->'tokens' ELSE '[]'::JSONB END
    ) AS token(item)
    WHERE token.item->>'id' = p_combatente_id
      AND token.item->>'tipo' = p_tipo
  ) THEN
    RAISE EXCEPTION 'O combatente não corresponde a um token publicado nesta campanha.';
  END IF;

  v_data := COALESCE(v_data, jsonb_build_object(
    'turn_order', '[]'::JSONB, 'current_turn', 0, 'active', FALSE,
    'round', 1, 'expected_character_ids', '[]'::JSONB
  ));
  v_order := CASE WHEN jsonb_typeof(v_data->'turn_order') = 'array'
                  THEN v_data->'turn_order' ELSE '[]'::JSONB END;
  v_expected := CASE WHEN jsonb_typeof(v_data->'expected_character_ids') = 'array'
                     THEN v_data->'expected_character_ids' ELSE '[]'::JSONB END;
  v_round := GREATEST(1, COALESCE((v_data->>'round')::INTEGER, 1));
  v_active := COALESCE((v_data->>'active')::BOOLEAN, FALSE);
  IF v_active THEN
    SELECT old.entry->>'id' INTO v_current_id
    FROM jsonb_array_elements(v_order) WITH ORDINALITY AS old(entry, ordinality)
    WHERE old.ordinality = COALESCE((v_data->>'current_turn')::INTEGER, 0) + 1
    LIMIT 1;
  END IF;

  v_entry := jsonb_build_object(
    'id', p_combatente_id, 'nome', LEFT(BTRIM(p_nome), 120), 'valor', p_valor,
    'is_monster', TRUE, 'tipo', p_tipo
  );
  IF v_active THEN
    SELECT COALESCE(jsonb_agg(
      CASE WHEN old.entry->>'id' = p_combatente_id THEN v_entry ELSE old.entry END
      ORDER BY old.ordinality
    ), '[]'::JSONB) INTO v_sorted
    FROM jsonb_array_elements(v_order) WITH ORDINALITY AS old(entry, ordinality);
    IF NOT EXISTS (
      SELECT 1 FROM jsonb_array_elements(v_order) AS old(entry)
      WHERE old.entry->>'id' = p_combatente_id
    ) THEN
      v_sorted := v_sorted || jsonb_build_array(v_entry);
    END IF;
  ELSE
    SELECT COALESCE(
      jsonb_agg(q.entry ORDER BY COALESCE(NULLIF(q.entry->>'valor', '')::NUMERIC, 0) DESC,
                                      q.entry->>'nome' ASC, q.entry->>'id' ASC),
      '[]'::JSONB
    ) INTO v_sorted
    FROM (
      SELECT old.entry
      FROM jsonb_array_elements(v_order) AS old(entry)
      WHERE old.entry->>'id' <> p_combatente_id
      UNION ALL
      SELECT v_entry
    ) AS q;
  END IF;

  IF jsonb_array_length(v_expected) > 0 THEN
    SELECT NOT EXISTS (
      SELECT 1 FROM jsonb_array_elements_text(v_expected) AS expected(character_id)
      WHERE NOT EXISTS (
        SELECT 1 FROM jsonb_array_elements(v_sorted) AS current_entry(entry)
        WHERE current_entry.entry->>'id' = expected.character_id
      )
    ) INTO v_active;
  END IF;
  IF v_active AND v_current_id IS NOT NULL THEN
    SELECT sorted.ordinality - 1 INTO v_current_turn
    FROM jsonb_array_elements(v_sorted) WITH ORDINALITY AS sorted(entry, ordinality)
    WHERE sorted.entry->>'id' = v_current_id
    LIMIT 1;
    v_current_turn := COALESCE(v_current_turn, 0);
  ELSE
    v_current_turn := 0;
  END IF;

  v_data := v_data || jsonb_build_object(
    'turn_order', v_sorted, 'current_turn', v_current_turn,
    'active', v_active, 'round', v_round, 'expected_character_ids', v_expected
  );
  UPDATE public.campaigns SET combat_data = v_data WHERE id = p_campaign_id;
  RETURN v_data;
END;
$function$

```

### `public.avancar_turno(p_campaign_id bigint)`

```sql
CREATE OR REPLACE FUNCTION public.avancar_turno(p_campaign_id bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_role TEXT;
  v_data JSONB;
  v_order JSONB;
  v_current INTEGER;
  v_next INTEGER;
  v_round INTEGER;
  v_entry JSONB;
  v_next_data JSONB;
  v_dying_ids TEXT[]; v_dying_targets JSONB; v_current_actor JSONB; v_actor_id TEXT; v_actor_kind TEXT; v_condition_break RECORD; v_condition_break_pending UUID;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT m.role INTO v_role
  FROM public.members AS m
  WHERE m.campaign_id = p_campaign_id AND m.user_id = auth.uid()
  LIMIT 1;

  IF v_role IS NULL OR v_role NOT IN ('GM', 'PLAYER') THEN
    RAISE EXCEPTION 'Somente um membro ativo da campanha pode avançar o turno.';
  END IF;

  SELECT combat_data INTO v_data
  FROM public.campaigns
  WHERE id = p_campaign_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF EXISTS(select 1 from priv.srd_aoo_pending_movements
    where campaign_id=p_campaign_id and status in ('waiting_reactions','ready_to_commit')) THEN
    RAISE EXCEPTION 'Há um movimento interrompido por Ataques de Oportunidade. O Mestre deve concluir ou cancelar esse movimento antes de avançar o turno.';
  END IF;
  IF v_data IS NULL OR COALESCE((v_data->>'active')::BOOLEAN, FALSE) IS NOT TRUE THEN
    RAISE EXCEPTION 'A iniciativa ainda não está ativa.';
  END IF;

  v_order := CASE WHEN jsonb_typeof(v_data->'turn_order') = 'array'
                  THEN v_data->'turn_order' ELSE '[]'::JSONB END;
  IF jsonb_array_length(v_order) = 0 THEN
    RAISE EXCEPTION 'A fila de iniciativa está vazia.';
  END IF;

  v_current := GREATEST(0, LEAST(jsonb_array_length(v_order)-1, COALESCE((v_data->>'current_turn')::INTEGER, 0)));
  v_entry := v_order->v_current;

  IF v_role <> 'GM' THEN
    IF COALESCE((v_entry->>'is_monster')::BOOLEAN, FALSE) THEN
      RAISE EXCEPTION 'O turno atual pertence a uma criatura controlada pelo Mestre.';
    END IF;
    IF NOT EXISTS (
      SELECT 1 FROM public.characters AS c
      WHERE c.campaign_id = p_campaign_id
        AND c.id::TEXT = v_entry->>'id'
        AND c.user_id = auth.uid()
    ) THEN
      RAISE EXCEPTION 'Você só pode encerrar o turno da sua própria ficha.';
    END IF;
  END IF;

  -- Rodada surpresa: somente participantes conscientes recebem turno nesta fase.
  IF coalesce(v_data->'surprise'->>'phase','')='surprise_round' THEN
    DECLARE v_indices jsonb; v_cursor integer; v_next_index integer; v_surprise jsonb; v_actor jsonb;
    BEGIN
      v_surprise:=v_data->'surprise';
      v_indices:=CASE WHEN jsonb_typeof(v_surprise->'order_indices')='array' THEN v_surprise->'order_indices' ELSE '[]'::jsonb END;
      v_cursor:=coalesce(nullif(v_surprise->>'cursor','')::integer,0)+1;
      IF v_cursor<jsonb_array_length(v_indices) THEN
        v_next_index:=(v_indices->>v_cursor)::integer;
        v_actor:=v_order->v_next_index;
        v_surprise:=v_surprise||jsonb_build_object('cursor',v_cursor);
        v_next_data:=v_data||jsonb_build_object('surprise',v_surprise,'current_turn',v_next_index,'round',0,'active',true);
        UPDATE public.campaigns SET combat_data=v_next_data WHERE id=p_campaign_id;
        PERFORM priv.srd_clear_combat_flatfooted_actor(p_campaign_id,v_actor);
        RETURN v_next_data;
      ELSE
        v_surprise:=v_surprise||jsonb_build_object('phase','normal','completed_at',now());
        v_next_data:=v_data||jsonb_build_object('surprise',v_surprise,'current_turn',0,'round',1,'active',true,'action_economy',jsonb_build_object('round',1,'by_character','{}'::jsonb),'movement_usage','{}'::jsonb);
        UPDATE public.campaigns SET combat_data=v_next_data WHERE id=p_campaign_id;
        v_actor:=v_order->0;
        PERFORM priv.srd_clear_combat_flatfooted_actor(p_campaign_id,v_actor);
        RETURN v_next_data;
      END IF;
    END;
  END IF;

  v_next := v_current + 1;
  v_round := GREATEST(1, COALESCE((v_data->>'round')::INTEGER, 1));
  IF v_next >= jsonb_array_length(v_order) THEN
    v_next := 0;
    v_round := v_round + 1;
  END IF;

  v_next_data := v_data || jsonb_build_object('current_turn', v_next, 'round', v_round, 'active', TRUE);
  UPDATE public.campaigns SET combat_data = v_next_data WHERE id = p_campaign_id;
  IF v_next = 0 THEN
    PERFORM public.srd_expire_campaign_conditions(p_campaign_id);

    SELECT array_agg(DISTINCT ch.id::text ORDER BY ch.id::text)
      INTO v_dying_ids
      FROM public.srd_campaign_conditions cc
      JOIN public.characters ch
        ON ch.id::text=cc.target_id AND ch.campaign_id=cc.campaign_id
      JOIN public.srd_character_sheets sh
        ON sh.character_id=ch.id
     WHERE cc.campaign_id=p_campaign_id
       AND cc.target_kind='character'
       AND cc.condition_id='dying'
       AND cc.active=true
       AND COALESCE(sh.pv_atual,0) BETWEEN -9 AND -1
       AND COALESCE(NULLIF(cc.notes->>'last_resolved_round','')::integer,0)<v_round;

    IF COALESCE(cardinality(v_dying_ids),0)>0 THEN
      SELECT jsonb_agg(
        jsonb_build_object(
          'character_id',ch.id::text,
          'name',ch.nome,
          'user_id',ch.user_id,
          'pv',sh.pv_atual
        ) ORDER BY ch.id
      )
      INTO v_dying_targets
      FROM public.characters ch
      JOIN public.srd_character_sheets sh ON sh.character_id=ch.id
      WHERE ch.campaign_id=p_campaign_id
        AND ch.id::text=ANY(v_dying_ids);

      INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
      VALUES (
        p_campaign_id,
        'test_request',
        'PUBLIC',
        jsonb_build_object(
          'tipo','Estabilização (D100)',
          'alvos',to_jsonb(v_dying_ids),
          'mestre','Sistema',
          'mestre_id',auth.uid(),
          'request_id',gen_random_uuid()::text,
          'detalhes',COALESCE(v_dying_targets,'[]'::jsonb)
        )
      );
      v_next_data:=v_next_data||jsonb_build_object('dying_saves',COALESCE(v_dying_targets,'[]'::jsonb));
    ELSE
      v_next_data:=v_next_data||jsonb_build_object('dying_saves','[]'::jsonb);
    END IF;

  END IF;


  IF v_next=0 THEN
    DECLARE
      v_npc_dying_ids text[];
      v_npc_dying_targets jsonb;
    BEGIN
      SELECT array_agg(DISTINCT t.token->>'id' ORDER BY t.token->>'id')
        INTO v_npc_dying_ids
      FROM public.campaigns c
      CROSS JOIN LATERAL jsonb_array_elements(
        CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array' THEN c.cba_data->'tokens' ELSE '[]'::jsonb END
      ) t(token)
      JOIN public.srd_campaign_conditions cc
        ON cc.campaign_id=c.id AND cc.target_kind='token'
       AND cc.target_id=t.token->>'id'
       AND cc.condition_id='dying' AND cc.active=true
      WHERE c.id=p_campaign_id
        AND t.token->>'tipo'='npc'
        AND NULLIF(t.token->>'sourceCharacterId','') ~ '^[0-9]+$'
        AND COALESCE(t.token->>'id','')<>''
        AND COALESCE(t.token->>'hp','') ~ '^-?[0-9]{1,6}$'
        AND (t.token->>'hp')::integer BETWEEN -9 AND -1
        AND COALESCE(NULLIF(cc.notes->>'last_resolved_round','')::integer,0)<v_round;

      IF COALESCE(cardinality(v_npc_dying_ids),0)>0 THEN
        SELECT jsonb_agg(jsonb_build_object(
          'token_id',t.token->>'id',
          'name',COALESCE(t.token->>'nome',t.token->>'name','NPC'),
          'source_character_id',t.token->>'sourceCharacterId',
          'pv',(t.token->>'hp')::integer
        ) ORDER BY t.token->>'id')
        INTO v_npc_dying_targets
        FROM public.campaigns c
        CROSS JOIN LATERAL jsonb_array_elements(
          CASE WHEN jsonb_typeof(c.cba_data->'tokens')='array' THEN c.cba_data->'tokens' ELSE '[]'::jsonb END
        ) t(token)
        WHERE c.id=p_campaign_id AND t.token->>'tipo'='npc'
          AND t.token->>'id'=ANY(v_npc_dying_ids);

        INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
        VALUES(
          p_campaign_id,'test_request','PUBLIC',
          jsonb_build_object(
            'tipo','Estabilização (D100)',
            'npc_alvos',to_jsonb(v_npc_dying_ids),
            'mestre','Sistema','mestre_id',auth.uid(),
            'request_id',gen_random_uuid()::text,
            'resolution_type','npc_dying_save',
            'detalhes',COALESCE(v_npc_dying_targets,'[]'::jsonb)
          )
        );
        v_next_data:=v_next_data||jsonb_build_object('npc_dying_saves',COALESCE(v_npc_dying_targets,'[]'::jsonb));
      ELSE
        v_next_data:=v_next_data||jsonb_build_object('npc_dying_saves','[]'::jsonb);
      END IF;
    END;
  END IF;

  v_current_actor:=v_order->v_next;
  v_actor_id:=v_current_actor->>'id';
  v_actor_kind:=CASE WHEN COALESCE((v_current_actor->>'is_monster')::boolean,false) THEN 'token' ELSE 'character' END;
  PERFORM priv.srd_clear_combat_flatfooted_actor(p_campaign_id,v_current_actor);

  SELECT cc.condition_instance_id,cc.target_kind,cc.target_id,cc.notes,ch.user_id
    INTO v_condition_break
    FROM public.srd_campaign_conditions cc
    LEFT JOIN public.characters ch
      ON cc.target_kind='character' AND ch.id::text=cc.target_id AND ch.campaign_id=cc.campaign_id
   WHERE cc.campaign_id=p_campaign_id
     AND cc.target_kind=v_actor_kind
     AND cc.target_id=v_actor_id
     AND cc.condition_id='paralyzed'
     AND cc.active=true
     AND cc.notes->>'save_each_turn'='true'
     AND COALESCE(NULLIF(cc.notes->>'last_save_round','')::integer,0)<v_round
     AND NULLIF(cc.notes->>'caster_character_id','') IS NOT NULL
     AND NULLIF(cc.notes->>'source_spell_id','') IS NOT NULL
   ORDER BY cc.condition_instance_id DESC
   LIMIT 1;

  IF FOUND THEN
    INSERT INTO priv.srd_pending_spell_resolutions(
      campaign_id,caster_character_id,target_kind,target_id,target_user_id,spell_id,
      save_type,save_dc,condition_id,duration_rounds,effect_data,spell_resistance,caster_level,
      condition_break,condition_break_instance_id
    ) VALUES (
      p_campaign_id,v_condition_break.notes->>'caster_character_id',
      v_condition_break.target_kind,v_condition_break.target_id,v_condition_break.user_id,
      v_condition_break.notes->>'source_spell_id',
      COALESCE(v_condition_break.notes->>'save_type','will'),
      COALESCE(NULLIF(v_condition_break.notes->>'save_dc','')::integer,10),
      'paralyzed',NULL,'{}'::jsonb,false,
      GREATEST(1,COALESCE(NULLIF(v_condition_break.notes->>'caster_level','')::integer,1)),
      true,v_condition_break.condition_instance_id
    ) RETURNING pending_id INTO v_condition_break_pending;

    INSERT INTO public.campaign_log(campaign_id,type,visibilidade,data)
    VALUES (
      p_campaign_id,'test_request','PUBLIC',
      jsonb_build_object(
        'tipo','Resistência de Vontade para encerrar Paralisia (D20)',
        'alvos',CASE WHEN v_actor_kind='character' THEN jsonb_build_array(v_actor_id) ELSE '[]'::jsonb END,
        'npc_alvos',CASE WHEN v_actor_kind='token' THEN jsonb_build_array(v_actor_id) ELSE '[]'::jsonb END,
        'mestre','Sistema','mestre_id',auth.uid(),
        'request_id',v_condition_break_pending::text,
        'resolution_type','condition_break',
        'pending_id',v_condition_break_pending,
        'spell_id',v_condition_break.notes->>'source_spell_id',
        'save_type',COALESCE(v_condition_break.notes->>'save_type','will'),
        'save_dc',COALESCE(NULLIF(v_condition_break.notes->>'save_dc','')::integer,10)
      )
    );
  END IF;

  IF v_next=0 THEN
    UPDATE public.srd_campaign_effects SET active=false
     WHERE campaign_id=p_campaign_id AND active=true AND expires_round IS NOT NULL AND expires_round<=v_round;
  END IF;
  RETURN v_next_data;
END;
$function$

```

### `public.combat_set_turn(p_token bigint)`

```sql
CREATE OR REPLACE FUNCTION public.combat_set_turn(p_token bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE t public.tokens; cs public.combat_state; idx integer;
BEGIN
  SELECT * INTO t FROM public.tokens WHERE id=p_token;
  IF NOT FOUND THEN RAISE EXCEPTION 'Token inexistente.'; END IF;
  PERFORM priv.need_gm(t.campaign_id);
  SELECT * INTO cs FROM public.combat_state WHERE campaign_id=t.campaign_id FOR UPDATE;
  IF NOT FOUND OR cs.ativo IS NOT TRUE THEN RAISE EXCEPTION 'Combate não está ativo.'; END IF;
  SELECT ordinality-1 INTO idx FROM jsonb_array_elements_text(cs.ordem) WITH ORDINALITY WHERE value=p_token::text;
  IF idx IS NULL THEN RAISE EXCEPTION 'Token fora da ordem.'; END IF;
  UPDATE public.combat_state SET turno_index=idx WHERE campaign_id=t.campaign_id;
  PERFORM priv.log(t.campaign_id,'TURNO_DEFINIDO',jsonb_build_object('token',p_token,'por',auth.uid()));
END $function$

```

### `public.conjurar_magia_com_acao_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text)`

```sql
CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text DEFAULT NULL::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id BIGINT;
  v_campaign_state TEXT;
  v_combat JSONB;
  v_result JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Autenticação obrigatória.';
  END IF;
  SELECT ch.campaign_id INTO v_campaign_id
    FROM public.characters AS ch
   WHERE ch.id::TEXT = BTRIM(p_character_id)
     AND ch.user_id = auth.uid()
   FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização.';
  END IF;

  IF v_campaign_id IS NOT NULL THEN
    SELECT c.state INTO v_campaign_state
      FROM public.campaigns AS c
     WHERE c.id = v_campaign_id
     FOR UPDATE;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Campanha do personagem não encontrada.';
    END IF;
    IF UPPER(COALESCE(v_campaign_state, '')) = 'COMBATE' THEN
      PERFORM public.consumir_acao_turno_srd(v_campaign_id, p_character_id, 'padrao');
    END IF;
  END IF;

  v_result := public.conjurar_magia_srd(
    p_character_id,
    p_spell_id,
    p_slot_level,
    p_target_token_key
  );

  IF v_campaign_id IS NOT NULL
     AND UPPER(COALESCE(v_campaign_state, '')) = 'COMBATE' THEN
    SELECT c.combat_data INTO v_combat
      FROM public.campaigns AS c
     WHERE c.id = v_campaign_id;
    RETURN COALESCE(v_result, '{}'::JSONB) || jsonb_build_object(
      'combat_data', COALESCE(v_combat, '{}'::JSONB),
      'action_economy', COALESCE(v_combat->'action_economy', '{}'::JSONB)
    );
  END IF;
  RETURN COALESCE(v_result, '{}'::JSONB);
END;
$function$

```

### `public.conjurar_magia_com_acao_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_roll_results integer[])`

```sql
CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text DEFAULT NULL::text, p_roll_results integer[] DEFAULT NULL::integer[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id BIGINT;
  v_campaign_state TEXT;
  v_combat JSONB;
  v_result JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Autenticação obrigatória.';
  END IF;
  SELECT ch.campaign_id INTO v_campaign_id
    FROM public.characters AS ch
   WHERE ch.id::TEXT = BTRIM(p_character_id)
     AND ch.user_id = auth.uid()
   FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização.';
  END IF;

  IF v_campaign_id IS NOT NULL THEN
    SELECT c.state INTO v_campaign_state
      FROM public.campaigns AS c
     WHERE c.id = v_campaign_id
     FOR UPDATE;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Campanha do personagem não encontrada.';
    END IF;
    IF UPPER(COALESCE(v_campaign_state, '')) = 'COMBATE' THEN
      PERFORM public.consumir_acao_turno_srd(v_campaign_id, p_character_id, 'padrao');
    END IF;
  END IF;

  v_result := public.conjurar_magia_srd_manual(
    p_character_id,
    p_spell_id,
    p_slot_level,
    p_target_token_key,
    p_roll_results
  );

  IF v_campaign_id IS NOT NULL
     AND UPPER(COALESCE(v_campaign_state, '')) = 'COMBATE' THEN
    SELECT c.combat_data INTO v_combat
      FROM public.campaigns AS c
     WHERE c.id = v_campaign_id;
    RETURN COALESCE(v_result, '{}'::JSONB) || jsonb_build_object(
      'combat_data', COALESCE(v_combat, '{}'::JSONB),
      'action_economy', COALESCE(v_combat->'action_economy', '{}'::JSONB)
    );
  END IF;
  RETURN COALESCE(v_result, '{}'::JSONB);
END;
$function$

```

### `public.conjurar_magia_com_acao_srd_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])`

```sql
CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id bigint;
  v_state text;
  v_result jsonb;
  v_combat jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  SELECT ch.campaign_id INTO v_campaign_id
  FROM public.characters ch
  WHERE ch.id::text=btrim(p_character_id) AND ch.user_id=auth.uid()
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização'; END IF;
  SELECT c.state INTO v_state FROM public.campaigns c
  WHERE c.id=v_campaign_id FOR UPDATE;
  IF upper(coalesce(v_state,''))='COMBATE' THEN
    PERFORM public.consumir_acao_turno_srd(v_campaign_id,p_character_id,'padrao');
  END IF;
  v_result:=public.conjurar_magia_srd_multialvo(
    p_character_id,p_spell_id,p_slot_level,p_target_token_keys
  );
  IF upper(coalesce(v_state,''))='COMBATE' THEN
    SELECT combat_data INTO v_combat FROM public.campaigns WHERE id=v_campaign_id;
    RETURN coalesce(v_result,'{}'::jsonb)||jsonb_build_object(
      'combat_data',coalesce(v_combat,'{}'::jsonb),
      'action_economy',coalesce(v_combat->'action_economy','{}'::jsonb)
    );
  END IF;
  RETURN coalesce(v_result,'{}'::jsonb);
END;
$function$

```

### `public.conjurar_magia_com_acao_srd_multialvo_v2(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])`

```sql
CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v2(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE v_campaign_id bigint; v_state text; v_result jsonb; v_combat jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  SELECT ch.campaign_id INTO v_campaign_id FROM public.characters ch
  WHERE ch.id::text=btrim(p_character_id) AND ch.user_id=auth.uid() FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização'; END IF;
  SELECT c.state INTO v_state FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
  IF upper(coalesce(v_state,''))='COMBATE' THEN
    PERFORM public.consumir_acao_turno_srd(v_campaign_id,p_character_id,'padrao');
  END IF;
  v_result:=public.conjurar_magia_srd_multialvo_v2(p_character_id,p_spell_id,p_slot_level,p_target_token_keys);
  IF upper(coalesce(v_state,''))='COMBATE' THEN
    SELECT combat_data INTO v_combat FROM public.campaigns WHERE id=v_campaign_id;
    RETURN v_result||jsonb_build_object('combat_data',coalesce(v_combat,'{}'::jsonb));
  END IF;
  RETURN v_result;
END;
$function$

```

### `public.conjurar_magia_com_acao_srd_multialvo_v3(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])`

```sql
CREATE OR REPLACE FUNCTION public.conjurar_magia_com_acao_srd_multialvo_v3(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_campaign_id bigint;
  v_state text;
  v_result jsonb;
  v_combat jsonb;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Autenticação obrigatória';
  END IF;

  SELECT ch.campaign_id
    INTO v_campaign_id
    FROM public.characters ch
   WHERE ch.id::text = btrim(p_character_id)
     AND ch.user_id = auth.uid()
   FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização';
  END IF;

  IF priv.srd_condition_has_flag(
       v_campaign_id, 'character', btrim(p_character_id), 'no_actions'
     )
     OR priv.srd_condition_has_flag(
       v_campaign_id, 'character', btrim(p_character_id), 'cannot_cast'
     ) THEN
    RAISE EXCEPTION 'A condição atual impede conjurar magias.';
  END IF;

  SELECT c.state
    INTO v_state
    FROM public.campaigns c
   WHERE c.id = v_campaign_id
   FOR UPDATE;

  IF upper(coalesce(v_state, '')) = 'COMBATE' THEN
    PERFORM public.consumir_acao_turno_srd(
      v_campaign_id, p_character_id, 'padrao'
    );
  END IF;

  v_result := public.conjurar_magia_srd_multialvo_v3(
    p_character_id, p_spell_id, p_slot_level,
    p_target_token_keys, p_roll_results
  );

  IF upper(coalesce(v_state, '')) = 'COMBATE' THEN
    SELECT combat_data
      INTO v_combat
      FROM public.campaigns
     WHERE id = v_campaign_id;

    RETURN v_result || jsonb_build_object(
      'combat_data', coalesce(v_combat, '{}'::jsonb)
    );
  END IF;

  RETURN v_result;
END;
$function$

```

### `public.consumir_acao_rodada_completa_srd(p_campaign_id bigint, p_actor_id text, p_actor_kind text)`

```sql
CREATE OR REPLACE FUNCTION public.consumir_acao_rodada_completa_srd(p_campaign_id bigint, p_actor_id text, p_actor_kind text DEFAULT 'character'::text)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ select priv.consumir_acao_rodada_completa_srd_impl(p_campaign_id,p_actor_id,p_actor_kind); $function$

```

### `public.consumir_acao_token_gm_srd(p_campaign_id bigint, p_token_id text, p_acao text)`

```sql
CREATE OR REPLACE FUNCTION public.consumir_acao_token_gm_srd(p_campaign_id bigint, p_token_id text, p_acao text)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ select priv.consumir_acao_token_gm_srd_impl(p_campaign_id,p_token_id,p_acao); $function$

```

### `public.consumir_acao_turno_srd(p_campaign_id bigint, p_character_id text, p_acao text)`

```sql
CREATE OR REPLACE FUNCTION public.consumir_acao_turno_srd(p_campaign_id bigint, p_character_id text, p_acao text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_combat JSONB;
  v_order JSONB;
  v_actor JSONB;
  v_current_turn INTEGER;
  v_round INTEGER;
  v_action_state JSONB;
  v_by_character JSONB;
  v_character_actions JSONB;
  v_action TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  IF NULLIF(BTRIM(p_character_id), '') IS NULL THEN
    RAISE EXCEPTION 'O identificador do personagem é obrigatório.';
  END IF;
  v_action := LOWER(BTRIM(COALESCE(p_acao, '')));
  IF v_action NOT IN ('padrao', 'movimento', 'rapida') THEN
    RAISE EXCEPTION 'Ação inválida. Use padrao, movimento ou rapida.';
  END IF;

  SELECT c.* INTO v_campaign
    FROM public.campaigns AS c
   WHERE c.id = p_campaign_id
   FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF UPPER(COALESCE(v_campaign.state, '')) <> 'COMBATE' THEN
    RAISE EXCEPTION 'A economia de ações só está ativa durante o combate.';
  END IF;

  IF NOT EXISTS (
    SELECT 1
      FROM public.characters AS ch
      JOIN public.members AS m
        ON m.campaign_id = ch.campaign_id
       AND m.user_id = ch.user_id
       AND m.role = 'PLAYER'
     WHERE ch.id::TEXT = BTRIM(p_character_id)
       AND ch.campaign_id = p_campaign_id
       AND ch.user_id = auth.uid()
  ) THEN
    RAISE EXCEPTION 'A ficha não pertence a este jogador nesta campanha.';
  END IF;

  IF priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'no_actions') THEN RAISE EXCEPTION 'A condição atual impede qualquer ação.'; END IF;
  IF v_action<>'movimento' AND priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'only_move_action') THEN RAISE EXCEPTION 'A condição atual permite somente uma ação de movimento.'; END IF;
  v_combat := COALESCE(v_campaign.combat_data, '{}'::JSONB);
  IF LOWER(COALESCE(v_combat->>'active', 'false')) <> 'true' THEN
    RAISE EXCEPTION 'Não há iniciativa ativa; o Mestre deve iniciar a ordem de combate.';
  END IF;
  v_order := CASE
    WHEN jsonb_typeof(v_combat->'turn_order') = 'array' THEN v_combat->'turn_order'
    ELSE '[]'::JSONB
  END;
  IF jsonb_array_length(v_order) = 0 THEN
    RAISE EXCEPTION 'A ordem de iniciativa está vazia.';
  END IF;
  IF COALESCE(v_combat->>'current_turn', '') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'O índice do turno atual é inválido.';
  END IF;
  v_current_turn := (v_combat->>'current_turn')::INTEGER;
  IF v_current_turn < 0 OR v_current_turn >= jsonb_array_length(v_order) THEN
    RAISE EXCEPTION 'O índice do turno atual está fora da ordem de iniciativa.';
  END IF;
  v_actor := v_order->v_current_turn;
  PERFORM priv.srd_validate_surprise_action(p_campaign_id,BTRIM(p_character_id),v_action);
  IF COALESCE(LOWER(v_actor->>'is_monster'), 'false') = 'true'
     OR v_actor->>'id' IS DISTINCT FROM BTRIM(p_character_id) THEN
    RAISE EXCEPTION 'Apenas o personagem cujo turno está ativo pode gastar esta ação.';
  END IF;

  v_round := CASE
    WHEN COALESCE(v_combat->>'round', '') ~ '^[0-9]+$'
      THEN GREATEST(1, (v_combat->>'round')::INTEGER)
    ELSE 1
  END;
  v_action_state := v_combat->'action_economy';
  IF jsonb_typeof(v_action_state) = 'object'
     AND COALESCE(v_action_state->>'round', '') = v_round::TEXT
     AND jsonb_typeof(v_action_state->'by_character') = 'object' THEN
    v_by_character := v_action_state->'by_character';
  ELSE
    -- A mudança de rodada reinicia o registro sem depender de renderizações no navegador.
    v_by_character := '{}'::JSONB;
  END IF;

  v_character_actions := CASE
    WHEN jsonb_typeof(v_by_character->BTRIM(p_character_id)) = 'object'
      THEN v_by_character->BTRIM(p_character_id)
    ELSE '{}'::JSONB
  END;
  IF priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'one_move_or_standard')
     AND (LOWER(COALESCE(v_character_actions->>'padrao','false'))='true' OR LOWER(COALESCE(v_character_actions->>'movimento','false'))='true') THEN
    RAISE EXCEPTION 'A condição permite apenas uma ação padrão ou de movimento por rodada.';
  END IF;
  IF LOWER(COALESCE(v_character_actions->>v_action, 'false')) = 'true' THEN
    RAISE EXCEPTION 'A ação % deste personagem já foi usada nesta rodada.', v_action;
  END IF;

  v_character_actions := v_character_actions || jsonb_build_object(v_action, TRUE);
  v_by_character := jsonb_set(
    v_by_character,
    ARRAY[BTRIM(p_character_id)],
    v_character_actions,
    TRUE
  );
  v_action_state := jsonb_build_object(
    'round', v_round,
    'by_character', v_by_character
  );
  v_combat := v_combat || jsonb_build_object('action_economy', v_action_state);

  IF v_action='padrao' AND priv.srd_condition_has_flag(p_campaign_id,'character',BTRIM(p_character_id),'strenuous_action_cost_1hp') THEN
    UPDATE public.srd_character_sheets SET pv_atual=-1 WHERE character_id::text=BTRIM(p_character_id) AND COALESCE(pv_atual,0)=0;
    IF FOUND THEN PERFORM priv.srd_sync_character_vital_condition(BTRIM(p_character_id),-1,false); END IF;
  END IF;
  UPDATE public.campaigns
     SET combat_data = v_combat
   WHERE id = p_campaign_id;

  RETURN jsonb_build_object(
    'combat_data', v_combat,
    'action_economy', v_action_state,
    'round', v_round,
    'character_id', BTRIM(p_character_id),
    'action', v_action
  );
END;
$function$

```

### `public.end_turn(p_token bigint)`

```sql
CREATE OR REPLACE FUNCTION public.end_turn(p_token bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_token public.tokens%ROWTYPE;
  v_combat public.combat_state%ROWTYPE;
  v_role TEXT;
  v_owner UUID;
  v_count INTEGER;
  v_next_index INTEGER;
  v_next_round INTEGER;
  v_next_token BIGINT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT * INTO v_token
  FROM public.tokens t
  WHERE t.id = p_token;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Token inexistente.';
  END IF;
  SELECT c.user_id INTO v_owner
  FROM public.characters c
  WHERE c.id = v_token.character_id;

  v_role := public.my_role(v_token.campaign_id);
  IF v_role IS NULL OR v_role NOT IN ('GM', 'PLAYER') THEN
    RAISE EXCEPTION 'Sem permissão.';
  END IF;
  IF v_role = 'PLAYER' AND v_owner IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'Você só encerra o seu próprio turno.';
  END IF;

  SELECT * INTO v_combat
  FROM public.combat_state
  WHERE campaign_id = v_token.campaign_id
  FOR UPDATE;
  IF NOT FOUND OR v_combat.ativo IS NOT TRUE THEN
    RAISE EXCEPTION 'Combate não está ativo.';
  END IF;
  IF (v_combat.ordem->>v_combat.turno_index)::BIGINT IS DISTINCT FROM p_token THEN
    RAISE EXCEPTION 'Não é o turno deste token.';
  END IF;

  v_count := JSONB_ARRAY_LENGTH(v_combat.ordem);
  IF v_count = 0 THEN
    RAISE EXCEPTION 'A ordem de combate está vazia.';
  END IF;
  v_next_index := v_combat.turno_index + 1;
  v_next_round := v_combat.rodada;
  IF v_next_index >= v_count THEN
    v_next_index := 0;
    v_next_round := v_next_round + 1;
  END IF;
  v_next_token := (v_combat.ordem->>v_next_index)::BIGINT;

  UPDATE public.combat_state
  SET turno_index = v_next_index, rodada = v_next_round
  WHERE campaign_id = v_token.campaign_id;
  PERFORM priv.log(
    v_token.campaign_id,
    'TURNO_AVANCOU',
    JSONB_BUILD_OBJECT('de', p_token, 'para', v_next_token, 'rodada', v_next_round)
  );
  RETURN JSONB_BUILD_OBJECT('ok', TRUE, 'proximo', v_next_token, 'rodada', v_next_round);
END
$function$

```

### `public.finalizar_criacao_personagem_srd(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb, p_pericias jsonb, p_talentos jsonb, p_identidade jsonb, p_idiomas jsonb, p_talentos_bonus jsonb, p_domain_ids text[], p_grimorio jsonb, p_equipamento_metodo text, p_equipamento_resultados jsonb, p_equipamento_itens jsonb)`

```sql
CREATE OR REPLACE FUNCTION public.finalizar_criacao_personagem_srd(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb, p_pericias jsonb, p_talentos jsonb, p_identidade jsonb, p_idiomas jsonb, p_talentos_bonus jsonb, p_domain_ids text[], p_grimorio jsonb, p_equipamento_metodo text, p_equipamento_resultados jsonb, p_equipamento_itens jsonb)
 RETURNS text
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_character_id text;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  -- A criação e todas as escolhas dependentes são uma única transação.
  v_character_id := public.criar_personagem_srd_completo(
    p_nome,
    p_raca_id,
    p_classe_id,
    p_atributos,
    p_pericias,
    p_talentos,
    p_identidade
  );

  PERFORM public.salvar_idiomas_personagem_srd(v_character_id, p_idiomas);
  PERFORM public.salvar_talentos_bonus_classe_inicial_srd(
    v_character_id,
    COALESCE(p_talentos_bonus, '[]'::jsonb)
  );

  IF COALESCE(array_length(p_domain_ids, 1), 0) > 0 THEN
    PERFORM public.salvar_dominios_personagem_srd(v_character_id, p_domain_ids);
  END IF;

  IF p_grimorio IS NOT NULL THEN
    PERFORM public.salvar_grimorio_srd(v_character_id, p_grimorio);
  END IF;

  PERFORM public.finalizar_equipamento_inicial_srd(
    v_character_id,
    p_equipamento_metodo,
    COALESCE(p_equipamento_resultados, '[]'::jsonb),
    COALESCE(p_equipamento_itens, '[]'::jsonb)
  );

  RETURN v_character_id;
END;
$function$

```

### `public.iniciar_iniciativa(p_campaign_id bigint, p_expected_character_ids text[])`

```sql
CREATE OR REPLACE FUNCTION public.iniciar_iniciativa(p_campaign_id bigint, p_expected_character_ids text[])
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_role TEXT;
  v_state TEXT;
  v_expected TEXT[];
  v_cba JSONB;
  v_combat JSONB;
  v_previous JSONB;
  v_existing_gm_entries JSONB;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT m.role INTO v_role
  FROM public.members AS m
  WHERE m.campaign_id = p_campaign_id AND m.user_id = auth.uid()
  LIMIT 1;

  IF v_role IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre da campanha pode iniciar a iniciativa.';
  END IF;

  SELECT COALESCE(array_agg(DISTINCT expanded.character_id), ARRAY[]::TEXT[])
  INTO v_expected
  FROM unnest(COALESCE(p_expected_character_ids, ARRAY[]::TEXT[])) AS expanded(character_id);

  IF EXISTS (
    SELECT 1
    FROM unnest(v_expected) AS requested(character_id)
    WHERE NOT EXISTS (
      SELECT 1
      FROM public.characters AS c
      JOIN public.members AS m
        ON m.campaign_id = c.campaign_id
       AND m.user_id = c.user_id
       AND m.role = 'PLAYER'
      WHERE c.campaign_id = p_campaign_id
        AND c.id::TEXT = requested.character_id
    )
  ) THEN
    RAISE EXCEPTION 'A lista inclui personagem que não pertence a um jogador desta campanha.';
  END IF;

  SELECT state, cba_data, combat_data INTO v_state, v_cba, v_previous
  FROM public.campaigns
  WHERE id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF UPPER(COALESCE(v_state, '')) <> 'COMBATE' THEN
    RAISE EXCEPTION 'A iniciativa só pode ser iniciada quando a campanha está em COMBATE.';
  END IF;
  IF COALESCE((v_previous->>'active')::BOOLEAN, FALSE)
     OR jsonb_array_length(CASE WHEN jsonb_typeof(v_previous->'expected_character_ids') = 'array'
                                THEN v_previous->'expected_character_ids' ELSE '[]'::JSONB END) > 0 THEN
    RAISE EXCEPTION 'A iniciativa desta rodada já foi iniciada. Encerre e inicie o combate novamente para zerá-la.';
  END IF;

  SELECT COALESCE(jsonb_agg(
    jsonb_build_object('id', rolled.id, 'nome', rolled.nome, 'valor', rolled.valor,
                       'is_monster', TRUE, 'tipo', rolled.tipo)
    ORDER BY rolled.valor DESC, rolled.nome ASC, rolled.id ASC
  ), '[]'::JSONB)
  INTO v_existing_gm_entries
  FROM (
    SELECT token.entry->>'id' AS id,
           LEFT(COALESCE(NULLIF(token.entry->>'nome', ''), 'Criatura'), 120) AS nome,
           CASE WHEN token.entry->>'tipo' = 'monstro' THEN 'monstro' ELSE 'npc' END AS tipo,
           FLOOR(random() * 20)::INTEGER + 1 AS valor
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_cba->'tokens') = 'array'
           THEN v_cba->'tokens' ELSE '[]'::JSONB END
    ) AS token(entry)
    WHERE token.entry->>'tipo' IN ('npc', 'monstro')
      AND NULLIF(BTRIM(token.entry->>'id'), '') IS NOT NULL
  ) AS rolled;

  IF cardinality(v_expected) = 0 AND jsonb_array_length(v_existing_gm_entries) = 0 THEN
    RAISE EXCEPTION 'Adicione fichas de jogadores ou NPCs/monstros ao CBA antes de iniciar a iniciativa.';
  END IF;

  v_combat := jsonb_build_object(
    'turn_order', v_existing_gm_entries,
    'current_turn', 0,
    'active', cardinality(v_expected) = 0,
    'round', 1,
    'expected_character_ids', to_jsonb(v_expected)
  );

  UPDATE public.campaigns SET combat_data = v_combat WHERE id = p_campaign_id;
  RETURN v_combat;
END;
$function$

```

### `public.iniciar_iniciativa_com_dados(p_campaign_id bigint, p_expected_character_ids text[], p_request_id text, p_gm_d20_results jsonb)`

```sql
CREATE OR REPLACE FUNCTION public.iniciar_iniciativa_com_dados(p_campaign_id bigint, p_expected_character_ids text[], p_request_id text, p_gm_d20_results jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_role TEXT;
  v_state TEXT;
  v_expected TEXT[];
  v_scene JSONB;
  v_previous JSONB;
  v_order JSONB;
  v_gm_count INTEGER;
  v_master TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT member.role INTO v_role
  FROM public.members AS member
  WHERE member.campaign_id = p_campaign_id AND member.user_id = auth.uid()
  LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode iniciar a iniciativa.';
  END IF;

  SELECT COALESCE(
    array_agg(DISTINCT BTRIM(requested.character_id) ORDER BY BTRIM(requested.character_id)),
    ARRAY[]::TEXT[]
  )
  INTO v_expected
  FROM unnest(COALESCE(p_expected_character_ids, ARRAY[]::TEXT[])) AS requested(character_id)
  WHERE NULLIF(BTRIM(requested.character_id), '') IS NOT NULL;

  IF EXISTS (
    SELECT 1
    FROM unnest(v_expected) AS requested(character_id)
    WHERE NOT EXISTS (
      SELECT 1
      FROM public.characters AS ch
      JOIN public.members AS player
        ON player.campaign_id = ch.campaign_id
       AND player.user_id = ch.user_id
       AND player.role = 'PLAYER'
      WHERE ch.campaign_id = p_campaign_id
        AND ch.id::TEXT = requested.character_id
    )
  ) THEN
    RAISE EXCEPTION 'A lista inclui ficha que não pertence a um jogador desta campanha.';
  END IF;

  IF cardinality(v_expected) > 0 AND NULLIF(BTRIM(p_request_id), '') IS NULL THEN
    RAISE EXCEPTION 'O identificador do pedido de iniciativa é obrigatório.';
  END IF;

  SELECT campaign.state, campaign.cba_data, campaign.combat_data
  INTO v_state, v_scene, v_previous
  FROM public.campaigns AS campaign
  WHERE campaign.id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF UPPER(COALESCE(v_state, '')) <> 'COMBATE' THEN
    RAISE EXCEPTION 'A iniciativa só pode ser iniciada no modo COMBATE.';
  END IF;
  IF COALESCE((v_previous->>'active')::BOOLEAN, FALSE)
     OR jsonb_array_length(
       CASE WHEN jsonb_typeof(v_previous->'expected_character_ids') = 'array'
            THEN v_previous->'expected_character_ids' ELSE '[]'::JSONB END
     ) > 0 THEN
    RAISE EXCEPTION 'A iniciativa desta rodada já foi iniciada.';
  END IF;

  IF jsonb_typeof(p_gm_d20_results) IS DISTINCT FROM 'array' THEN
    RAISE EXCEPTION 'Os resultados dos dados do Mestre são inválidos.';
  END IF;
  IF EXISTS (
    SELECT 1
    FROM jsonb_array_elements(p_gm_d20_results) AS roll(value)
    WHERE jsonb_typeof(roll.value) IS DISTINCT FROM 'number'
       OR roll.value::TEXT !~ '^(1[0-9]|20|[1-9])$'
  ) THEN
    RAISE EXCEPTION 'Cada resultado de iniciativa precisa ser um inteiro entre 1 e 20.';
  END IF;

  SELECT count(*)::INTEGER
  INTO v_gm_count
  FROM jsonb_array_elements(
    CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
         THEN v_scene->'tokens' ELSE '[]'::JSONB END
  ) AS candidate(token)
  LEFT JOIN public.characters AS character
    ON character.campaign_id = p_campaign_id
   AND character.id::TEXT = candidate.token->>'id'
  WHERE candidate.token->>'tipo' IN ('npc', 'monstro')
     OR (candidate.token->>'tipo' = 'player' AND character.user_id = auth.uid());

  IF EXISTS (
    SELECT 1
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
           THEN v_scene->'tokens' ELSE '[]'::JSONB END
    ) AS linked(token)
    WHERE linked.token->>'tipo' = 'npc'
      AND NULLIF(BTRIM(linked.token->>'sourceCharacterId'), '') IS NOT NULL
      AND NOT EXISTS (
        SELECT 1
        FROM public.characters AS source_character
        JOIN public.srd_character_sheets AS source_sheet
          ON source_sheet.character_id = source_character.id
        WHERE source_character.id::TEXT = BTRIM(linked.token->>'sourceCharacterId')
          AND source_character.user_id = auth.uid()
      )
  ) THEN
    RAISE EXCEPTION 'A ficha de origem de um NPC vinculado não existe, não é SRD ou não pertence ao Mestre autenticado.';
  END IF;

  IF jsonb_array_length(p_gm_d20_results) <> v_gm_count THEN
    RAISE EXCEPTION 'O Mestre precisa rolar exatamente % d20 para os tokens que controla; recebeu %.',
      v_gm_count, jsonb_array_length(p_gm_d20_results);
  END IF;
  IF cardinality(v_expected) = 0 AND v_gm_count = 0 THEN
    RAISE EXCEPTION 'Adicione participantes ao combate antes de iniciar a iniciativa.';
  END IF;

  WITH gm_tokens AS (
    SELECT candidate.token,
           character.id AS linked_character_id,
           sheet.atributos AS linked_attributes,
           sheet.talentos AS linked_feats
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_scene->'tokens') = 'array'
           THEN v_scene->'tokens' ELSE '[]'::JSONB END
    ) AS candidate(token)
    LEFT JOIN public.characters AS character
      ON character.id::TEXT = CASE
        WHEN candidate.token->>'tipo' = 'npc'
         AND NULLIF(BTRIM(candidate.token->>'sourceCharacterId'), '') IS NOT NULL
          THEN BTRIM(candidate.token->>'sourceCharacterId')
        ELSE candidate.token->>'id'
      END
     AND (
       (candidate.token->>'tipo' = 'npc'
        AND NULLIF(BTRIM(candidate.token->>'sourceCharacterId'), '') IS NOT NULL
        AND character.user_id = auth.uid())
       OR
       ((candidate.token->>'tipo' <> 'npc'
         OR NULLIF(BTRIM(candidate.token->>'sourceCharacterId'), '') IS NULL)
        AND character.campaign_id = p_campaign_id)
     )
    LEFT JOIN public.srd_character_sheets AS sheet
      ON sheet.character_id::TEXT = character.id::TEXT
    WHERE candidate.token->>'tipo' IN ('npc', 'monstro')
       OR (candidate.token->>'tipo' = 'player' AND character.user_id = auth.uid())
  ),
  numbered_tokens AS (
    SELECT gm_tokens.*,
           row_number() OVER (ORDER BY random()) AS assignment_number
    FROM gm_tokens
  ),
  numbered_rolls AS (
    SELECT roll.value::INTEGER AS d20,
           row_number() OVER (ORDER BY roll.ordinality) AS assignment_number
    FROM jsonb_array_elements(p_gm_d20_results) WITH ORDINALITY AS roll(value, ordinality)
  ),
  calculated AS (
    SELECT
      COALESCE(NULLIF(BTRIM(token.token->>'id'), ''), 'combatant-' || token.assignment_number::TEXT) AS id,
      LEFT(COALESCE(NULLIF(BTRIM(token.token->>'nome'), ''), 'Criatura'), 120) AS nome,
      CASE WHEN token.token->>'tipo' = 'monstro' THEN 'monstro'
           WHEN token.token->>'tipo' = 'player' THEN 'personagem_gm' ELSE 'npc' END AS tipo,
      roll.d20,
      FLOOR((
        COALESCE(
          NULLIF(token.linked_attributes->>'DES','')::NUMERIC,
          NULLIF(token.token->>'dexMod','')::NUMERIC,
          10
        ) - 10
      ) / 2)::INTEGER AS dex_mod,
      COALESCE(
        CASE WHEN token.token->>'bonusIniciativa' ~ '^-?[0-9]{1,2}$'
             THEN (token.token->>'bonusIniciativa')::INTEGER END,
        CASE WHEN token.token->>'bonus_iniciativa' ~ '^-?[0-9]{1,2}$'
             THEN (token.token->>'bonus_iniciativa')::INTEGER END,
        priv.srd_passive_feat_modifier(token.linked_character_id,'initiative'),
        0
      ) AS initiative_bonus
    FROM numbered_tokens AS token
    JOIN numbered_rolls AS roll USING (assignment_number)
  )
  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'id', calculated.id,
      'nome', calculated.nome,
      'valor', calculated.d20 + calculated.dex_mod + calculated.initiative_bonus,
      'd20', calculated.d20,
      'dex_mod', calculated.dex_mod,
      'bonus_iniciativa', calculated.initiative_bonus,
      'is_monster', TRUE,
      'tipo', calculated.tipo
    )
    ORDER BY calculated.d20 + calculated.dex_mod + calculated.initiative_bonus DESC,
             calculated.dex_mod DESC, calculated.nome ASC, calculated.id ASC
  ), '[]'::JSONB)
  INTO v_order
  FROM calculated;

  UPDATE public.campaigns
  SET combat_data = jsonb_build_object(
    'turn_order', v_order,
    'current_turn', 0,
    'active', cardinality(v_expected) = 0,
    'round', 1,
    'expected_character_ids', to_jsonb(v_expected)
  )
  WHERE id = p_campaign_id;
  IF cardinality(v_expected) = 0 THEN
    PERFORM priv.srd_start_combat_flatfooted(p_campaign_id,v_order,0);
  END IF;

  IF cardinality(v_expected) > 0 THEN
    SELECT COALESCE(NULLIF(BTRIM(profile.username), ''), 'Mestre')
    INTO v_master
    FROM public.profiles AS profile
    WHERE profile.id = auth.uid();
    v_master := COALESCE(v_master, 'Mestre');

    INSERT INTO public.campaign_log (campaign_id, type, visibilidade, data)
    VALUES (
      p_campaign_id, 'test_request', 'PUBLIC',
      jsonb_build_object(
        'tipo', 'Iniciativa (DES)',
        'alvos', to_jsonb(v_expected),
        'mestre', v_master,
        'mestre_id', auth.uid(),
        'request_id', BTRIM(p_request_id)
      )
    );
  END IF;

  RETURN (SELECT combat_data FROM public.campaigns WHERE id = p_campaign_id);
END;
$function$

```

### `public.iniciar_iniciativa_com_pedido(p_campaign_id bigint, p_expected_character_ids text[], p_request_id text)`

```sql
CREATE OR REPLACE FUNCTION public.iniciar_iniciativa_com_pedido(p_campaign_id bigint, p_expected_character_ids text[], p_request_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_expected TEXT[];
  v_combat JSONB;
  v_mestre TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;

  SELECT COALESCE(array_agg(DISTINCT BTRIM(requested.character_id) ORDER BY BTRIM(requested.character_id)), ARRAY[]::TEXT[])
  INTO v_expected
  FROM unnest(COALESCE(p_expected_character_ids, ARRAY[]::TEXT[])) AS requested(character_id)
  WHERE NULLIF(BTRIM(requested.character_id), '') IS NOT NULL;

  IF cardinality(v_expected) > 0 AND NULLIF(BTRIM(p_request_id), '') IS NULL THEN
    RAISE EXCEPTION 'O identificador do pedido de iniciativa é obrigatório.';
  END IF;

  -- Esta função valida o papel GM, a campanha, o estado COMBATE e as fichas.
  v_combat := public.iniciar_iniciativa(p_campaign_id, v_expected);

  IF cardinality(v_expected) > 0 THEN
    SELECT COALESCE(NULLIF(BTRIM(p.username), ''), 'Mestre')
    INTO v_mestre
    FROM public.profiles AS p
    WHERE p.id = auth.uid();
    v_mestre := COALESCE(v_mestre, 'Mestre');

    INSERT INTO public.campaign_log (campaign_id, type, visibilidade, data)
    VALUES (
      p_campaign_id,
      'test_request',
      'PUBLIC',
      jsonb_build_object(
        'tipo', 'Iniciativa (DES)',
        'alvos', to_jsonb(v_expected),
        'mestre', v_mestre,
        'mestre_id', auth.uid(),
        'request_id', BTRIM(p_request_id)
      )
    );
  END IF;

  RETURN v_combat;
END;
$function$

```

### `public.mover_combatente_iniciativa(p_campaign_id bigint, p_indice integer, p_direcao integer)`

```sql
CREATE OR REPLACE FUNCTION public.mover_combatente_iniciativa(p_campaign_id bigint, p_indice integer, p_direcao integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_role TEXT;
  v_data JSONB;
  v_order JSONB;
  v_sorted JSONB;
  v_items JSONB[];
  v_temp JSONB;
  v_target INTEGER;
  v_current_id TEXT;
  v_current_turn INTEGER := 0;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'É necessário estar autenticado.';
  END IF;
  SELECT m.role INTO v_role
  FROM public.members AS m
  WHERE m.campaign_id = p_campaign_id AND m.user_id = auth.uid()
  LIMIT 1;
  IF v_role IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode reordenar a iniciativa.';
  END IF;
  IF p_direcao IS NULL OR p_direcao NOT IN (-1, 1) THEN
    RAISE EXCEPTION 'A direção de movimento deve ser -1 ou 1.';
  END IF;

  SELECT combat_data INTO v_data
  FROM public.campaigns
  WHERE id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;
  IF v_data IS NULL OR jsonb_typeof(v_data->'turn_order') IS DISTINCT FROM 'array' THEN
    RAISE EXCEPTION 'Ainda não há uma ordem de iniciativa para reordenar.';
  END IF;
  v_order := v_data->'turn_order';
  IF jsonb_array_length(v_order) = 0 THEN
    RAISE EXCEPTION 'A fila de iniciativa está vazia.';
  END IF;
  v_target := p_indice + p_direcao;
  IF p_indice IS NULL OR p_indice < 0 OR p_indice >= jsonb_array_length(v_order)
     OR v_target < 0 OR v_target >= jsonb_array_length(v_order) THEN
    RAISE EXCEPTION 'A posição solicitada está fora da fila.';
  END IF;

  IF COALESCE((v_data->>'active')::BOOLEAN, FALSE) THEN
    SELECT old.entry->>'id' INTO v_current_id
    FROM jsonb_array_elements(v_order) WITH ORDINALITY AS old(entry, ordinality)
    WHERE old.ordinality = COALESCE((v_data->>'current_turn')::INTEGER, 0) + 1
    LIMIT 1;
  END IF;
  SELECT array_agg(old.entry ORDER BY old.ordinality) INTO v_items
  FROM jsonb_array_elements(v_order) WITH ORDINALITY AS old(entry, ordinality);
  v_temp := v_items[p_indice + 1];
  v_items[p_indice + 1] := v_items[v_target + 1];
  v_items[v_target + 1] := v_temp;
  SELECT COALESCE(jsonb_agg(new_order.entry ORDER BY new_order.ordinality), '[]'::JSONB)
  INTO v_sorted
  FROM unnest(v_items) WITH ORDINALITY AS new_order(entry, ordinality);

  IF v_current_id IS NOT NULL THEN
    SELECT sorted.ordinality - 1 INTO v_current_turn
    FROM jsonb_array_elements(v_sorted) WITH ORDINALITY AS sorted(entry, ordinality)
    WHERE sorted.entry->>'id' = v_current_id
    LIMIT 1;
    v_current_turn := COALESCE(v_current_turn, 0);
  ELSE
    v_current_turn := 0;
  END IF;
  v_data := v_data || jsonb_build_object('turn_order', v_sorted, 'current_turn', v_current_turn);
  UPDATE public.campaigns SET combat_data = v_data WHERE id = p_campaign_id;
  RETURN v_data;
END;
$function$

```

### `public.registrar_iniciativa(p_campaign_id bigint, p_personagem_id text, p_nome text, p_valor integer)`

```sql
CREATE OR REPLACE FUNCTION public.registrar_iniciativa(p_campaign_id bigint, p_personagem_id text, p_nome text, p_valor integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE
  v_role TEXT;
  v_state TEXT;
  v_data JSONB;
  v_order JSONB;
  v_expected JSONB;
  v_entry JSONB;
  v_sorted JSONB;
  v_next JSONB;
  v_current_id TEXT;
  v_dex_mod INTEGER := 0;
  v_current_turn INTEGER := 0;
  v_round INTEGER := 1;
  v_active BOOLEAN := FALSE;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'É necessário estar autenticado.'; END IF;

  SELECT member.role INTO v_role
  FROM public.members AS member
  WHERE member.campaign_id = p_campaign_id AND member.user_id = auth.uid()
  LIMIT 1;
  IF v_role IS DISTINCT FROM 'PLAYER' THEN
    RAISE EXCEPTION 'Somente um jogador pode registrar a iniciativa de sua ficha.';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.characters AS character
    WHERE character.campaign_id = p_campaign_id
      AND character.id::TEXT = p_personagem_id
      AND character.user_id = auth.uid()
  ) THEN RAISE EXCEPTION 'A ficha de iniciativa não pertence ao jogador autenticado.'; END IF;

  SELECT FLOOR((COALESCE(NULLIF(sheet.atributos->>'DES','')::NUMERIC,10)-10)/2)::INTEGER
    INTO v_dex_mod
    FROM public.srd_character_sheets AS sheet
   WHERE sheet.character_id::TEXT=p_personagem_id;
  v_dex_mod:=COALESCE(v_dex_mod,0);

  SELECT campaign.state, campaign.combat_data INTO v_state, v_data
  FROM public.campaigns AS campaign
  WHERE campaign.id = p_campaign_id
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  IF UPPER(COALESCE(v_state,'')) <> 'COMBATE' THEN
    RAISE EXCEPTION 'A iniciativa só pode ser registrada durante o combate.';
  END IF;
  IF v_data IS NULL THEN RAISE EXCEPTION 'O Mestre ainda não solicitou a iniciativa.'; END IF;

  v_expected := CASE WHEN jsonb_typeof(v_data->'expected_character_ids')='array'
                     THEN v_data->'expected_character_ids' ELSE '[]'::JSONB END;
  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements_text(v_expected) AS expected(character_id)
    WHERE expected.character_id = p_personagem_id
  ) THEN RAISE EXCEPTION 'Esta ficha não faz parte da solicitação de iniciativa atual.'; END IF;

  v_order := CASE WHEN jsonb_typeof(v_data->'turn_order')='array' THEN v_data->'turn_order' ELSE '[]'::JSONB END;
  IF EXISTS (
    SELECT 1 FROM jsonb_array_elements(v_order) AS existing(entry)
    WHERE existing.entry->>'id'=p_personagem_id AND COALESCE((existing.entry->>'is_monster')::BOOLEAN,FALSE)=FALSE
  ) THEN
    SELECT existing.entry INTO v_entry
    FROM jsonb_array_elements(v_order) AS existing(entry)
    WHERE existing.entry->>'id'=p_personagem_id AND COALESCE((existing.entry->>'is_monster')::BOOLEAN,FALSE)=FALSE
    LIMIT 1;
    IF COALESCE(NULLIF(v_entry->>'valor','')::INTEGER,0)<>p_valor THEN
      RAISE EXCEPTION 'Esta ficha já registrou sua iniciativa nesta rodada; uma nova rolagem não é permitida.';
    END IF;
    RETURN v_data;
  END IF;
  v_round := CASE WHEN COALESCE(v_data->>'round','') ~ '^[0-9]+$' THEN GREATEST(1,(v_data->>'round')::INTEGER) ELSE 1 END;
  IF COALESCE((v_data->>'active')::BOOLEAN,FALSE) THEN
    SELECT old_order.entry->>'id' INTO v_current_id
    FROM jsonb_array_elements(v_order) WITH ORDINALITY AS old_order(entry, ordinality)
    WHERE old_order.ordinality = GREATEST(0,COALESCE((v_data->>'current_turn')::INTEGER,0))+1
    LIMIT 1;
  END IF;

  v_entry := jsonb_build_object('id',p_personagem_id,'nome',LEFT(COALESCE(NULLIF(p_nome,''),'Aventureiro'),120),
    'valor',p_valor,'dex_mod',v_dex_mod,'is_monster',FALSE);
  SELECT COALESCE(jsonb_agg(q.entry ORDER BY COALESCE(NULLIF(q.entry->>'valor','')::NUMERIC,0) DESC,
                            COALESCE(NULLIF(q.entry->>'dex_mod','')::NUMERIC,0) DESC,
                            q.entry->>'nome' ASC, q.entry->>'id' ASC),'[]'::JSONB)
  INTO v_sorted
  FROM (
    SELECT old.entry FROM jsonb_array_elements(v_order) AS old(entry)
    WHERE old.entry->>'id' <> p_personagem_id
    UNION ALL SELECT v_entry
  ) AS q;

  SELECT NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements_text(v_expected) AS expected(character_id)
    WHERE NOT EXISTS (
      SELECT 1 FROM jsonb_array_elements(v_sorted) AS current_entry(entry)
      WHERE current_entry.entry->>'id'=expected.character_id
    )
  ) INTO v_active;
  IF v_active AND v_current_id IS NOT NULL THEN
    SELECT sorted.ordinality-1 INTO v_current_turn
    FROM jsonb_array_elements(v_sorted) WITH ORDINALITY AS sorted(entry, ordinality)
    WHERE sorted.entry->>'id'=v_current_id LIMIT 1;
    v_current_turn := COALESCE(v_current_turn,0);
  ELSE v_current_turn := 0; END IF;

  v_next := v_data || jsonb_build_object('turn_order',v_sorted,'current_turn',v_current_turn,
    'active',v_active,'round',v_round,'expected_character_ids',v_expected);
  UPDATE public.campaigns SET combat_data=v_next WHERE id=p_campaign_id;
  IF v_active AND NOT COALESCE((v_data->>'active')::boolean,false) THEN
   PERFORM priv.srd_start_combat_flatfooted(p_campaign_id,v_sorted,v_current_turn);
  END IF;
  RETURN v_next;
END;
$function$

```

### `public.registrar_iniciativa_d20(p_campaign_id bigint, p_personagem_id text, p_d20 integer)`

```sql
CREATE OR REPLACE FUNCTION public.registrar_iniciativa_d20(p_campaign_id bigint, p_personagem_id text, p_d20 integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_role TEXT;
  v_state TEXT;
  v_data JSONB;
  v_order JSONB;
  v_expected JSONB;
  v_name TEXT;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_dex INTEGER;
  v_dex_mod INTEGER;
  v_feat_bonus INTEGER := 0;
  v_effect_bonus INTEGER := 0;
  v_total INTEGER;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF p_d20 IS NULL OR p_d20 NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'A iniciativa exige o resultado manual de um D20 entre 1 e 20.';
  END IF;

  SELECT role INTO v_role FROM public.members
  WHERE campaign_id=p_campaign_id AND user_id=auth.uid() LIMIT 1;
  IF v_role IS DISTINCT FROM 'PLAYER' THEN RAISE EXCEPTION 'Somente um jogador pode registrar sua iniciativa.'; END IF;

  SELECT nome INTO v_name FROM public.characters
  WHERE id::TEXT=BTRIM(p_personagem_id) AND campaign_id=p_campaign_id AND user_id=auth.uid();
  IF NOT FOUND THEN RAISE EXCEPTION 'A ficha não pertence ao jogador autenticado.'; END IF;

  SELECT state,combat_data INTO v_state,v_data
  FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR UPPER(COALESCE(v_state,''))<>'COMBATE' OR v_data IS NULL THEN
    RAISE EXCEPTION 'Não há solicitação de iniciativa ativa nesta campanha.';
  END IF;
  v_expected:=CASE WHEN jsonb_typeof(v_data->'expected_character_ids')='array' THEN v_data->'expected_character_ids' ELSE '[]'::JSONB END;
  IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements_text(v_expected) e(id) WHERE e.id=BTRIM(p_personagem_id)) THEN
    RAISE EXCEPTION 'Esta ficha não faz parte da solicitação de iniciativa atual.';
  END IF;
  v_order:=CASE WHEN jsonb_typeof(v_data->'turn_order')='array' THEN v_data->'turn_order' ELSE '[]'::JSONB END;
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(v_order) e(value)
    WHERE e.value->>'id'=BTRIM(p_personagem_id)
      AND COALESCE((e.value->>'is_monster')::BOOLEAN,FALSE)=FALSE) THEN
    RETURN v_data;
  END IF;

  SELECT * INTO v_sheet FROM public.srd_character_sheets
  WHERE character_id::TEXT=BTRIM(p_personagem_id) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD necessária para calcular iniciativa.'; END IF;

  v_dex:=COALESCE(
    CASE WHEN COALESCE(v_sheet.atributos->>'DES','') ~ '^-?[0-9]{1,2}$' THEN (v_sheet.atributos->>'DES')::INTEGER END,
    CASE WHEN COALESCE(v_sheet.atributos->>'destreza','') ~ '^-?[0-9]{1,2}$' THEN (v_sheet.atributos->>'destreza')::INTEGER END,
    CASE WHEN COALESCE(v_sheet.atributos->>'dexterity','') ~ '^-?[0-9]{1,2}$' THEN (v_sheet.atributos->>'dexterity')::INTEGER END,
    CASE WHEN COALESCE(v_sheet.atributos->>'DEX','') ~ '^-?[0-9]{1,2}$' THEN (v_sheet.atributos->>'DEX')::INTEGER END
  );
  IF v_dex IS NULL OR v_dex NOT BETWEEN -20 AND 50 THEN RAISE EXCEPTION 'Destreza inválida na ficha.'; END IF;
  v_dex_mod:=CASE WHEN v_dex>=4 THEN FLOOR((v_dex-10)::NUMERIC/2)::INTEGER ELSE v_dex END;

  v_feat_bonus:=priv.srd_passive_feat_modifier(v_sheet.character_id,'initiative');

  v_effect_bonus:=COALESCE(priv.srd_effective_modifier(p_campaign_id,'character',BTRIM(p_personagem_id),'initiative'),0);
  v_total:=p_d20+v_dex_mod+v_feat_bonus+v_effect_bonus;

  RETURN public.registrar_iniciativa(p_campaign_id,p_personagem_id,v_name,v_total);
END;
$function$

```

### `public.set_turn(cid bigint, p_token bigint)`

```sql
CREATE OR REPLACE FUNCTION public.set_turn(cid bigint, p_token bigint)
 RETURNS void
 LANGUAGE plpgsql
 SET search_path TO 'public', 'pg_temp'
AS $function$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.tokens
    WHERE id = p_token AND campaign_id = cid
  ) THEN
    RAISE EXCEPTION 'Token inexistente.';
  END IF;

  -- A RPC privilegiada mantém a validação definitiva de GM e combate ativo.
  PERFORM public.combat_set_turn(p_token);
END
$function$

```

### `public.srd_cancelar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)`

```sql
CREATE OR REPLACE FUNCTION public.srd_cancelar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ select priv.srd_cancelar_movimento_aoo_pendente_impl(p_campaign_id,p_pending_id); $function$

```

### `public.srd_consultar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)`

```sql
CREATE OR REPLACE FUNCTION public.srd_consultar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_pending priv.srd_aoo_pending_movements%rowtype;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode consultar movimentos aguardando ataques de oportunidade.';
  end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id;
  if not found then raise exception 'Movimento pendente não encontrado.'; end if;
  return jsonb_build_object(
    'pending_id',v_pending.pending_id,'status',v_pending.status,
    'mover_token_id',v_pending.mover_token_id,
    'movement_controller',v_pending.movement_controller,
    'origin',jsonb_build_array(v_pending.origin_x,v_pending.origin_y),
    'destination',jsonb_build_array(v_pending.destination_x,v_pending.destination_y),
    'round',v_pending.combat_round,'current_turn',v_pending.current_turn,
    'turn_actor_id',v_pending.turn_actor_id,
    'threats',v_pending.threats,'pending_reactions',v_pending.pending_reactions,
    'created_at',v_pending.created_at
  );
end;
$function$

```

### `public.srd_encerrar_reacao_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean)`

```sql
CREATE OR REPLACE FUNCTION public.srd_encerrar_reacao_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$ select priv.srd_encerrar_reacao_aoo_pendente_impl(p_campaign_id,p_pending_id,p_reactor_token_id,p_cancel_attack); $function$

```

### `public.srd_finalizar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)`

```sql
CREATE OR REPLACE FUNCTION public.srd_finalizar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_pending priv.srd_aoo_pending_movements%rowtype;
  v_campaign public.campaigns%rowtype;
  v_preview jsonb;
  v_remaining integer;
  v_user uuid:=auth.uid();
begin
  if v_user is null then raise exception 'É necessário estar autenticado.'; end if;
  select * into v_pending from priv.srd_aoo_pending_movements
  where campaign_id=p_campaign_id and pending_id=p_pending_id for update;
  if not found or v_pending.status<>'waiting_reactions' then raise exception 'Movimento pendente não está ativo.'; end if;

  if public.my_role(p_campaign_id) is distinct from 'GM'
     and (v_pending.movement_controller='gm' or v_user<>v_pending.created_by) then
    raise exception 'Somente o Mestre ou o jogador que solicitou o movimento pode concluí-lo.';
  end if;

  if exists(
    select 1 from jsonb_array_elements(v_pending.pending_reactions) r
    where coalesce(r->>'status','') not in ('ineligible','skipped','miss','damage_applied')
  ) then
    raise exception 'Ainda existem reações de oportunidade sem estado terminal válido.';
  end if;

  if exists(
    select 1 from priv.srd_aoo_attacks a
    where a.pending_id=p_pending_id and a.campaign_id=p_campaign_id
      and a.status not in ('miss','damage_applied','cancelled')
  ) then
    raise exception 'Ainda existe um ataque de oportunidade sem resolução completa.';
  end if;

  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found or upper(coalesce(v_campaign.state,''))<>'COMBATE'
     or coalesce(v_campaign.combat_data->>'active','false')<>'true'
     or greatest(1,coalesce(nullif(v_campaign.combat_data->>'round','')::integer,0))<>v_pending.combat_round
     or coalesce(nullif(v_campaign.combat_data->>'current_turn','')::integer,-1)<>v_pending.current_turn then
    raise exception 'O combate avançou; solicite uma nova movimentação.';
  end if;
  if not exists(select 1 from jsonb_array_elements(coalesce(v_campaign.cba_data->'tokens','[]'::jsonb)) t
    where (t->>'id'=v_pending.mover_token_id or t->>'key'=v_pending.mover_token_id)
      and coalesce(t->>'gridX','')=v_pending.origin_x::text
      and coalesce(t->>'gridY','')=v_pending.origin_y::text) then
    raise exception 'A posição original do token mudou; movimento não pode ser concluído.';
  end if;

  perform set_config('app.srd_aoo_pending_commit',p_pending_id::text,true);
  if v_pending.movement_controller='player' and v_user=v_pending.created_by
     and public.my_role(p_campaign_id) is distinct from 'GM' then
    v_preview:=public.mover_token_player_cba(
      p_campaign_id,v_pending.mover_token_id,v_pending.destination_x,v_pending.destination_y);
  else
    v_preview:=public.mover_token_gm_cba_srd(
      p_campaign_id,v_pending.mover_token_id,v_pending.destination_x,v_pending.destination_y);
  end if;

  update priv.srd_aoo_pending_movements set status='committed',
    committed_at=now(),updated_at=now() where pending_id=p_pending_id;
  perform set_config('app.srd_aoo_pending_commit','',true);
  return jsonb_build_object('committed',true,'pending_id',p_pending_id,
    'mover_token_id',v_pending.mover_token_id,
    'destination',jsonb_build_array(v_pending.destination_x,v_pending.destination_y),
    'movement_result',v_preview);
end;
$function$

```

### `public.srd_listar_movimentos_aoo_pendentes_srd(p_campaign_id bigint)`

```sql
CREATE OR REPLACE FUNCTION public.srd_listar_movimentos_aoo_pendentes_srd(p_campaign_id bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare v_rows jsonb;
begin
  if auth.uid() is null or public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode listar movimentos aguardando ataques de oportunidade.';
  end if;
  select coalesce(jsonb_agg(jsonb_build_object(
    'pending_id',p.pending_id,'mover_token_id',p.mover_token_id,
    'movement_controller',p.movement_controller,
    'origin',jsonb_build_array(p.origin_x,p.origin_y),
    'destination',jsonb_build_array(p.destination_x,p.destination_y),
    'round',p.combat_round,'current_turn',p.current_turn,
    'status',p.status,'threats',p.threats,
    'pending_reactions',p.pending_reactions,
    'created_at',p.created_at
  ) order by p.created_at),'[]'::jsonb)
  into v_rows
  from priv.srd_aoo_pending_movements p
  where p.campaign_id=p_campaign_id
    and p.status in ('waiting_reactions','ready_to_commit');
  return jsonb_build_object('pending_movements',v_rows);
end;
$function$

```

### `public.srd_registrar_ocultacao_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)`

```sql
CREATE OR REPLACE FUNCTION public.srd_registrar_ocultacao_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
  select priv.srd_registrar_ocultacao_ataque_oportunidade_impl(
    p_campaign_id,p_attack_id,p_manual_d100
  );
$function$

```

### `public.srd_reservar_reacao_movimento_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)`

```sql
CREATE OR REPLACE FUNCTION public.srd_reservar_reacao_movimento_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
 select priv.srd_reservar_reacao_movimento_aoo_impl(
   p_campaign_id,p_pending_id,p_reactor_token_id
 );
$function$

```

### `public.srd_resolve_confusion_turn_srd(p_campaign_id bigint, p_target_kind text, p_target_id text, p_request_id uuid, p_manual_d100 integer)`

```sql
CREATE OR REPLACE FUNCTION public.srd_resolve_confusion_turn_srd(p_campaign_id bigint, p_target_kind text, p_target_id text, p_request_id uuid, p_manual_d100 integer)
 RETURNS jsonb
 LANGUAGE sql
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
 select priv.srd_resolve_confusion_turn_impl(
   p_campaign_id,p_target_kind,p_target_id,p_request_id,p_manual_d100
 );
$function$

```

### `public.srd_solicitar_movimento_com_aoo_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer, p_controller text)`

```sql
CREATE OR REPLACE FUNCTION public.srd_solicitar_movimento_com_aoo_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer, p_controller text DEFAULT 'player'::text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
declare
  v_campaign public.campaigns%rowtype;
  v_combat jsonb;
  v_order jsonb;
  v_round integer;
  v_turn integer;
  v_actor_id text;
  v_token jsonb;
  v_token_type text;
  v_pos_x integer;
  v_pos_y integer;
  v_detection jsonb;
  v_pending_id uuid;
  v_reactions jsonb;
begin
  if auth.uid() is null then raise exception 'É necessário estar autenticado.'; end if;
  if p_controller not in ('player','gm') then raise exception 'Controlador de movimento inválido.'; end if;
  if p_controller='gm' and public.my_role(p_campaign_id) is distinct from 'GM' then
    raise exception 'Somente o Mestre pode solicitar movimento de token sob seu controle.';
  end if;

  select * into v_campaign from public.campaigns where id=p_campaign_id for update;
  if not found then raise exception 'Campanha não encontrada.'; end if;
  v_combat:=coalesce(v_campaign.combat_data,'{}'::jsonb);
  if upper(coalesce(v_campaign.state,''))<>'COMBATE'
     or coalesce(v_combat->>'active','false')<>'true' then
    return jsonb_build_object('pending',false,'requires_aoo',false,
      'reason','combat_not_active','continue_with_existing_movement_rpc',true);
  end if;
  if coalesce(v_combat->>'round','') !~ '^[0-9]+$'
     or coalesce(v_combat->>'current_turn','') !~ '^[0-9]+$' then
    raise exception 'Rodada ou turno de combate inválido.';
  end if;
  v_round:=greatest(1,(v_combat->>'round')::integer);
  v_turn:=(v_combat->>'current_turn')::integer;
  v_order:=case when jsonb_typeof(v_combat->'turn_order')='array'
    then v_combat->'turn_order' else '[]'::jsonb end;
  if v_turn<0 or v_turn>=jsonb_array_length(v_order) then
    raise exception 'Índice do turno atual inválido.';
  end if;
  v_actor_id:=v_order->v_turn->>'id';

  select t into v_token
  from jsonb_array_elements(case when jsonb_typeof(v_campaign.cba_data->'tokens')='array'
    then v_campaign.cba_data->'tokens' else '[]'::jsonb end) t
  where t->>'id'=btrim(p_mover_token_id) or t->>'key'=btrim(p_mover_token_id)
  limit 1;
  if v_token is null then raise exception 'Token não encontrado na cena.'; end if;
  v_token_type:=v_token->>'tipo';
  if coalesce(v_token->>'gridX','') !~ '^[0-9]{1,3}$'
     or coalesce(v_token->>'gridY','') !~ '^[0-9]{1,3}$' then
    raise exception 'Posição atual do token inválida.';
  end if;
  v_pos_x:=(v_token->>'gridX')::integer;
  v_pos_y:=(v_token->>'gridY')::integer;

  if p_controller='player' then
    if v_token_type<>'player'
       or v_actor_id is distinct from btrim(p_mover_token_id)
       or not exists(select 1 from public.characters c
         where c.id::text=btrim(p_mover_token_id)
           and c.campaign_id=p_campaign_id and c.user_id=auth.uid()) then
      raise exception 'O personagem não é seu ou não está no turno ativo.';
    end if;
  else
    if v_actor_id is distinct from btrim(p_mover_token_id)
       or v_token_type not in ('npc','monstro','player') then
      raise exception 'O token não está no turno ativo ou não pode ser controlado pelo Mestre.';
    end if;
  end if;

  v_detection:=public.srd_detectar_saida_alcance_ameacado_srd(
    p_campaign_id,btrim(p_mover_token_id),p_destination_x,p_destination_y);
  if coalesce((v_detection->>'detected')::boolean,false) is not true then
    return jsonb_build_object('pending',false,'requires_aoo',false,
      'reason',coalesce(v_detection->>'reason','no_threat_detected'),
      'detection',v_detection,'continue_with_existing_movement_rpc',true);
  end if;

  if exists(select 1 from priv.srd_aoo_pending_movements
    where campaign_id=p_campaign_id and status in ('waiting_reactions','ready_to_commit')) then
    raise exception 'Já existe um movimento aguardando resolução de ataques de oportunidade nesta campanha.';
  end if;

  v_reactions:=(
    select coalesce(jsonb_agg(jsonb_build_object(
      'reactor_token_id',coalesce(x->>'token_id',x->>'token_key'),
      'trigger_key',concat('move:',p_mover_token_id,':',v_round,':',p_destination_x,':',p_destination_y,':',coalesce(x->>'token_id',x->>'token_key')),
      'status','waiting',
      'threat',x
    )),'[]'::jsonb)
    from jsonb_array_elements(coalesce(v_detection->'threats','[]'::jsonb)) x
  );
  insert into priv.srd_aoo_pending_movements(
    campaign_id,mover_token_id,movement_controller,destination_x,destination_y,
    origin_x,origin_y,combat_round,current_turn,turn_actor_id,threats,
    pending_reactions,created_by
  ) values (
    p_campaign_id,btrim(p_mover_token_id),p_controller,p_destination_x,p_destination_y,
    v_pos_x,v_pos_y,v_round,v_turn,v_actor_id,
    coalesce(v_detection->'threats','[]'::jsonb),v_reactions,auth.uid()
  ) returning pending_id into v_pending_id;

  return jsonb_build_object('pending',true,'requires_aoo',true,
    'pending_id',v_pending_id,'status','waiting_reactions',
    'round',v_round,'current_turn',v_turn,'mover_token_id',p_mover_token_id,
    'from',jsonb_build_array(v_pos_x,v_pos_y),
    'to',jsonb_build_array(p_destination_x,p_destination_y),
    'pending_reactions',v_reactions,
    'movement_committed',false);
end;
$function$

```

## Observações

- A matriz de EXECUTE registra privilégios efetivos para os papéis consultados, mas não substitui a confirmação de schemas expostos no PostgREST.
- Funções antigas sem EXECUTE para authenticated podem ser mantidas por compatibilidade interna, trigger ou histórico; não as remover apenas por não estarem acessíveis ao cliente.
- A iniciativa deve permanecer baseada em rolagens manuais de jogadores; esta exportação preserva os caminhos existentes para revisão e não altera a política do cliente.
- A ordem de locks deve ser fechada considerando chamadas transitivas, incluindo helpers privados, não apenas o primeiro SELECT ... FOR UPDATE visível em cada RPC.
