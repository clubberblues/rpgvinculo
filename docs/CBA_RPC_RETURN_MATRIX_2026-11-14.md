# Matriz de RPCs com dependência de estado CBA/combate — 2026-11-14

> Inventário read-only do Supabase de produção. O grafo inclui chamadas qualificadas public.* e priv.* por nome; quando há overloads, o vínculo por nome é uma aproximação conservadora e pode incluir relações possíveis não escolhidas pelo resolvedor SQL. Não é prova de vazamento.

## Resumo

- Total: 90 overloads public com EXECUTE para authenticated; 53 mencionam cba_data/combat_data diretamente e 37 são transitivos sem menção direta.
- Retornos: 88 JSONB e 2 escalares.
- SECURITY DEFINER: 61; SECURITY INVOKER: 29.
- auth.uid() textual: 63; my_role() textual: 30; verificação literal de GM: 4.
- Indicador textual de filtro/visibilidade/snapshot: 13; não comprova que o payload esteja filtrado.
- Menções por arquivo: mesa 81; ficha 9; lobby 1. É busca textual, não confirmação de chamada executável.

## Matriz

| RPC (assinatura) | Retorno | Execução | Direta | Transitiva | auth.uid textual | my_role textual | GM literal | Menção em arquivo |
|---|---|---|---|---|---|---|---|---|
| `adicionar_combatente_iniciativa(p_campaign_id bigint, p_combatente_id text, p_nome text, p_valor integer, p_tipo text)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `adicionar_token_cba_completo(p_campaign_id bigint, p_token jsonb)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `alterar_pv_token_cba(p_campaign_id bigint, p_token_id text, p_variacao integer, p_pv_max integer)` | jsonb | DEFINER | sim | não | sim | não | sim | mesa |
| `alternar_estado_campanha(p_campaign_id bigint, p_novo_estado text)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `aplicar_dano_ataque_iterativo_npc_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[])` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `aplicar_dano_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `aplicar_dano_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[])` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `aplicar_dano_ataque_npc_gm_srd(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_raw_damage integer, p_damage_type text)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `aplicar_dano_token_ataque_srd_v2(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `aplicar_dano_token_ataque_srd_v2(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer, p_sneak_attack_dice integer, p_sneak_attack_damage integer)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `aplicar_dano_token_gm_personagem_srd(p_campaign_id bigint, p_token_id text, p_character_id text, p_dano integer)` | jsonb | DEFINER | sim | não | sim | não | sim | — |
| `avancar_turno(p_campaign_id bigint)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `clonar_equipamento_ficha_para_token(p_campaign_id bigint, p_token_id text, p_character_id text)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `confirmar_critico_ataque_iterativo_npc_srd(p_campaign_id bigint, p_attempt_id uuid, p_confirmation_d20 integer)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `confirmar_critico_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_confirmation_d20 integer)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `conjurar_magia_com_acao_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_roll_results integer[])` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `conjurar_magia_com_acao_srd_multialvo_v3(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `conjurar_magia_dano_multialvo_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `conjurar_magia_efeitos_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `conjurar_missil_magico_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_damage_rolls integer[])` | jsonb | DEFINER | não | sim | sim | não | não | mesa |
| `consultar_ataque_iterativo_npc_srd(p_campaign_id bigint, p_token_id text, p_attack_type text)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `consultar_furia_barbaro_npc_srd(p_campaign_id bigint, p_token_id text)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa, ficha |
| `consultar_furia_barbaro_srd(p_character_id text)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa, ficha |
| `consumir_acao_rodada_completa_srd(p_campaign_id bigint, p_actor_id text, p_actor_kind text)` | jsonb | INVOKER | não | sim | não | não | não | — |
| `consumir_acao_token_gm_srd(p_campaign_id bigint, p_token_id text, p_acao text)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `consumir_acao_turno_srd(p_campaign_id bigint, p_character_id text, p_acao text)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `descanso_longo_npc_vinculado_srd(p_campaign_id bigint, p_token_id text)` | jsonb | INVOKER | não | sim | não | não | não | mesa, ficha |
| `descanso_longo_personagem_srd(p_campaign_id bigint, p_character_id text)` | jsonb | DEFINER | não | sim | sim | não | não | ficha |
| `entregar_item_token_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_quantidade integer)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `equipar_item_token_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `excluir_ficha_propria(p_character_id text)` | jsonb | DEFINER | sim | não | sim | não | não | lobby |
| `iniciar_ataque_iterativo_npc_srd(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `iniciar_ataque_iterativo_npc_srd(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `iniciar_iniciativa_com_dados(p_campaign_id bigint, p_expected_character_ids text[], p_request_id text, p_gm_d20_results jsonb)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `mover_combatente_iniciativa(p_campaign_id bigint, p_indice integer, p_direcao integer)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `mover_token_gm_cba_srd(p_campaign_id bigint, p_token_id text, p_grid_x integer, p_grid_y integer)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `mover_token_player_cba(p_campaign_id bigint, p_character_id text, p_grid_x integer, p_grid_y integer)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `registrar_iniciativa_d20(p_campaign_id bigint, p_personagem_id text, p_d20 integer)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `registrar_rolagem_ataque_iterativo_npc_srd(p_campaign_id bigint, p_sequence_id uuid, p_manual_d20 integer, p_idempotency_key uuid)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `registrar_rolagem_ataque_iterativo_srd(p_campaign_id bigint, p_sequence_id uuid, p_manual_d20 integer, p_idempotency_key uuid)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `resolver_ataque_iterativo_npc_srd(p_campaign_id bigint, p_attempt_id uuid)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `resolver_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `salvar_cena_cba(p_campaign_id bigint, p_scene jsonb)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `srd35_deslocamento_personagem(p_character_id text, p_base_speed_m numeric)` | numeric | DEFINER | sim | não | sim | sim | não | mesa, ficha |
| `srd_aplicar_dano_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_aplicar_dano_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_apply_campaign_condition(p_campaign_id bigint, p_target_kind text, p_target_id text, p_condition_id text, p_duration_rounds integer, p_notes jsonb)` | bigint | DEFINER | não | sim | sim | sim | não | — |
| `srd_apply_campaign_effect(p_campaign_id bigint, p_target_kind text, p_target_id text, p_effect_kind text, p_effect_data jsonb, p_duration_rounds integer, p_source_spell_id text, p_concentration_actor_id text)` | jsonb | DEFINER | não | sim | sim | sim | não | — |
| `srd_calcular_ca_personagem_srd(p_campaign_id bigint, p_character_id text, p_attack_context text)` | jsonb | DEFINER | não | sim | sim | sim | não | mesa, ficha |
| `srd_calcular_ca_personagem_srd(p_campaign_id bigint, p_character_id text, p_attack_context text, p_attacker_is_giant boolean)` | jsonb | DEFINER | sim | não | sim | sim | sim | mesa, ficha |
| `srd_configurar_perfil_combate_token_srd(p_campaign_id bigint, p_token_id text, p_combat_faction text, p_melee_reach_ft integer)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_configurar_rodada_surpresa_srd(p_campaign_id bigint, p_aware_ids text[])` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_consultar_armas_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)` | jsonb | DEFINER | não | sim | sim | sim | não | mesa |
| `srd_consultar_modificadores_manobra_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_maneuver text, p_defender_firm_ground boolean)` | jsonb | DEFINER | não | sim | sim | sim | não | mesa |
| `srd_consultar_modificadores_manobra_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_maneuver text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)` | jsonb | INVOKER | sim | não | sim | sim | não | mesa |
| `srd_detectar_saida_alcance_ameacado_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer)` | jsonb | DEFINER | sim | não | sim | sim | não | — |
| `srd_finalizar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_iniciar_ataque_oportunidade_desarmado_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_natural_attack_index integer)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_iniciar_ataque_oportunidade_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_iniciar_encontrao_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_iniciar_levantar_caido_srd(p_campaign_id bigint, p_token_id text)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_listar_ataques_naturais_oportunidade_srd(p_campaign_id bigint, p_reactor_token_id text)` | jsonb | INVOKER | sim | não | sim | sim | não | mesa |
| `srd_registrar_ocultacao_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_reservar_ataque_oportunidade_srd(p_campaign_id bigint, p_actor_token_id text, p_trigger_key text, p_actor_flat_footed boolean)` | jsonb | INVOKER | não | sim | não | não | não | — |
| `srd_reservar_reacao_movimento_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_resolve_confusion_turn_srd(p_campaign_id bigint, p_target_kind text, p_target_id text, p_request_id uuid, p_manual_d100 integer)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_resolve_dying_round(p_campaign_id bigint, p_character_id text, p_d100 integer)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_resolve_npc_dying_round(p_campaign_id bigint, p_token_id text, p_d100 integer)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_resolve_pending_spell_resistance(p_pending_id uuid, p_d20 integer)` | jsonb | DEFINER | não | sim | sim | sim | não | mesa |
| `srd_resolve_pending_spell_save(p_pending_id uuid, p_d20 integer)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_resolve_requested_saving_throw_srd(p_campaign_id bigint, p_character_id text, p_request_id text, p_d20 integer)` | jsonb | DEFINER | não | sim | sim | não | não | mesa |
| `srd_resolver_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_resolver_derrubar_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_resolver_derrubar_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_attacker_d20 integer, p_defender_d20 integer, p_defender_uses_dex boolean, p_defender_firm_ground boolean, p_trip_using_weapon boolean)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_resolver_encontrao_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_follow boolean)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_resolver_teste_resistencia_token_srd(p_campaign_id bigint, p_token_id text, p_save_type text, p_context text, p_d20 integer, p_dc integer)` | jsonb | DEFINER | sim | não | sim | sim | não | — |
| `srd_solicitar_movimento_com_aoo_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer, p_controller text)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_validar_uso_pericia_srd(p_character_id text, p_skill_id text)` | jsonb | DEFINER | sim | não | sim | não | sim | mesa |
| `usar_furia_barbaro_npc_srd(p_campaign_id bigint, p_token_id text, p_action text)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa, ficha |
| `usar_furia_barbaro_srd(p_character_id text, p_action text)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa, ficha |
| `usar_habilidade_classe_srd(p_character_id text, p_feature_key text, p_target_token_key text, p_amount integer)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `usar_imposicao_maos_mortos_vivos_srd(p_character_id text, p_target_token_key text, p_d20 integer, p_amount integer)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `usar_pocao_cura_srd_manual(p_character_id text, p_equipment_id text, p_roll_results integer[])` | jsonb | DEFINER | não | sim | sim | não | não | mesa |

## Observações de autorização e retorno

- A análise anterior, limitada a chamadas priv.*, encontrou 85 raízes. A ampliação para public.* identificou cinco overloads adicionais: conjurar_missil_magico_srd_manual; duas sobrecargas de iniciar_sequencia_ataque_iterativo_srd; duas sobrecargas de srd_calcular_ca_personagem_srd; e srd_resolver_derrubar_apos_aoo_srd. A contagem total correta para esta análise ampliada é 90.
- Entre os cinco novos tipos, conjurar_missil_magico_srd_manual é o achado de retorno privado: a implementação interna retorna cba_data dentro do JSON e a RPC manual tem EXECUTE authenticated. A migration candidata 20261112160000_filter_player_damage_rpc_results.sql agora move a implementação para priv e cria wrapper filtrado. O helper GM de conjuração foi ajustado para alterar a implementação priv, preservando a permissão do Mestre sem abrir a implementação interna.
- As duas sobrecargas novas de iniciar_sequencia_ataque_iterativo_srd são wrappers INVOKER que chamam implementações priv SECURITY DEFINER; o retorno é sequência/resultado de ataque, não snapshot bruto. As duas sobrecargas srd_calcular_ca_personagem_srd retornam breakdown de CA, não CBA/combate bruto. srd_resolver_derrubar_apos_aoo_srd é wrapper INVOKER para implementação priv SECURITY DEFINER; validar o payload específico nos fixtures de manobra/AOO.
- A análise de texto e call graph não substitui inspeção de cada retorno. SQL dinâmico, chamadas não qualificadas, funções de outros schemas e resolução exata de overloads não são completamente inferidos.

## Wrappers INVOKER

- A análise anterior identificou 26 raízes INVOKER; a expansão de chamadas public.* acrescentou três overloads INVOKER, totalizando 29.
- 24 wrappers antigos não contêm auth.uid() no corpo público, mas delegam a implementações priv SECURITY DEFINER com guarda auth.uid(). Dois leitores GM-only (srd_consultar_modificadores_manobra_srd de 6 args e srd_listar_ataques_naturais_oportunidade_srd) verificam auth.uid()+my_role='GM', mas ainda aparecem INVOKER no remoto. A migration 20261110150000_fix_invoker_maneuver_catalog_helper_permissions.sql muda ambos para SECURITY DEFINER e fixa search_path, mas não consta no ledger remoto.
- Os wrappers INVOKER de ataque iterativo, movimento, descanso e AOO devem ser avaliados pela implementação privada e pelos resultados devolvidos, não apenas pelo corpo público.

## Retornos com estado CBA/combate

- A consulta de retorno por texto identificou funções que retornam cba_data/combat_data bruto e outras que apenas consultam esses campos para calcular um resultado. Entre os retornos brutos confirmados estão adicionar_combatente_iniciativa, adicionar_token_cba_completo, alterar_pv_token_cba, alternar_estado_campanha, aplicar_dano_token_ataque_srd_v2 (duas sobrecargas), avancar_turno, conjurar_magia_com_acao_srd_manual, conjurar_magia_com_acao_srd_multialvo_v3, consumir_acao_turno_srd, equipar_item_token_srd, iniciar_iniciativa_com_dados, mover_combatente_iniciativa, registrar_iniciativa_d20, salvar_cena_cba, srd_configurar_perfil_combate_token_srd, srd_configurar_rodada_surpresa_srd, usar_furia_barbaro_npc_srd, usar_habilidade_classe_srd e conjurar_magia_dano_multialvo_srd. A lista é candidata e inclui funções GM-only; guardas e retornos devem ser conferidos individualmente.
- registrar_iniciativa_d20 é PLAYER-only e devolve combat_data completo no caminho de iniciativa já registrada e no caminho normal via registrar_iniciativa. Foi adicionada como wrapper filtrado à migration candidata 20261112160000; o fixture verifica que o jogador mantém seu ator e não recebe pending_reactions/atores ocultos.
- conjurar_missil_magico_srd_manual é PLAYER-executable e devolvia cba_data dentro do resultado da resolução de Míssil Mágico. Também foi adicionada à migration candidata e ao fixture de isolamento.

## Situação efetiva do corte CBA no Supabase remoto

- priv.cba_filter_rpc_result(jsonb,bigint), priv.cba_visible_tabletop_snapshot(bigint) e public.obter_snapshot_seguro_mesa(bigint) ainda não existem no banco remoto; migrations 20261112140000, 20261112150000 e 20261112160000 não constam no ledger.
- Portanto, as wrappers filtradas são candidatas na branch, não proteção ativa em produção. campaigns ainda concede SELECT a authenticated nas colunas cba_data/combat_data e permanece na publicação supabase_realtime. Nenhum corte foi aplicado.

## Próximos passos

1. Executar os fixtures de snapshot, filtragem de respostas e GM; conferir as novas wrappers de iniciativa e Míssil Mágico.
2. Classificar os retornos restantes por papel autorizado e payload; verificar cada GM-only raw-state function e os três novos wrappers INVOKER.
3. Resolver o bootstrap pré-ledger e replay integral antes de aprovar a sequência de migrations.
4. Somente depois validar os quatro perfis (GM, dono, outro jogador, externo) por RPC e HTTP/PostgREST, então planejar corte ACL/Realtime.
