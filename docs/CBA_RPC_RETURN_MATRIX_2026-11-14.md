# Matriz estática de RPCs com dependência de estado CBA/combate — 2026-11-14

> Inventário read-only do Supabase de produção. 85 overloads públicos com EXECUTE para authenticated; 53 referenciam cba_data/combat_data diretamente e 59 chamam helpers priv que alcançam esse estado (conjuntos sobrepostos). Isso é uma matriz de revisão de superfície, não uma afirmação de 85 vazamentos.

## Resumo

- Total: 85 overloads; 83 JSONB e 2 escalares.
- SECURITY DEFINER: 59; SECURITY INVOKER: 26.
- Guarda textual auth.uid(): 61; referência textual my_role(): 29; verificação literal de GM: 4.
- Indicador textual de filtro/visibilidade/snapshot: 12. Este indicador não comprova que o payload esteja filtrado.
- Menção textual nos arquivos: mesa 76; ficha 8; lobby 1. A contagem de menções não comprova chamada executável nem cobre SQL dinâmico.
- A análise transitiva segue chamadas priv.* qualificadas por texto. SQL dinâmico, chamadas não qualificadas, wrappers em outros schemas e profundidade além do grafo reconhecido podem ficar fora.

## Matriz

| RPC (assinatura) | Retorno | Execução | CBA direto | CBA transitivo | auth.uid textual | my_role textual | GM literal | Menção em arquivo |
|---|---|---|---|---|---|---|---|---|
| `adicionar_combatente_iniciativa(p_campaign_id bigint, p_combatente_id text, p_nome text, p_valor integer, p_tipo text)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `adicionar_token_cba_completo(p_campaign_id bigint, p_token jsonb)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `alterar_pv_token_cba(p_campaign_id bigint, p_token_id text, p_variacao integer, p_pv_max integer)` | jsonb | DEFINER | sim | sim | sim | não | sim | mesa |
| `alternar_estado_campanha(p_campaign_id bigint, p_novo_estado text)` | jsonb | DEFINER | sim | sim | sim | não | não | mesa |
| `aplicar_dano_ataque_iterativo_npc_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[])` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `aplicar_dano_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)` | jsonb | DEFINER | sim | sim | sim | não | não | mesa |
| `aplicar_dano_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[])` | jsonb | DEFINER | sim | sim | sim | não | não | mesa |
| `aplicar_dano_ataque_npc_gm_srd(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_raw_damage integer, p_damage_type text)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `aplicar_dano_token_ataque_srd_v2(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer)` | jsonb | DEFINER | sim | sim | sim | não | não | mesa |
| `aplicar_dano_token_ataque_srd_v2(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer, p_sneak_attack_dice integer, p_sneak_attack_damage integer)` | jsonb | DEFINER | sim | sim | sim | não | não | mesa |
| `aplicar_dano_token_gm_personagem_srd(p_campaign_id bigint, p_token_id text, p_character_id text, p_dano integer)` | jsonb | DEFINER | sim | sim | sim | não | sim | — |
| `avancar_turno(p_campaign_id bigint)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `clonar_equipamento_ficha_para_token(p_campaign_id bigint, p_token_id text, p_character_id text)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `confirmar_critico_ataque_iterativo_npc_srd(p_campaign_id bigint, p_attempt_id uuid, p_confirmation_d20 integer)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `confirmar_critico_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_confirmation_d20 integer)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `conjurar_magia_com_acao_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_roll_results integer[])` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `conjurar_magia_com_acao_srd_multialvo_v3(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `conjurar_magia_dano_multialvo_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])` | jsonb | DEFINER | sim | sim | sim | não | não | mesa |
| `conjurar_magia_efeitos_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])` | jsonb | DEFINER | sim | sim | sim | não | não | mesa |
| `consultar_ataque_iterativo_npc_srd(p_campaign_id bigint, p_token_id text, p_attack_type text)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `consultar_furia_barbaro_npc_srd(p_campaign_id bigint, p_token_id text)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa, ficha |
| `consultar_furia_barbaro_srd(p_character_id text)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa, ficha |
| `consumir_acao_rodada_completa_srd(p_campaign_id bigint, p_actor_id text, p_actor_kind text)` | jsonb | INVOKER | não | sim | não | não | não | — |
| `consumir_acao_token_gm_srd(p_campaign_id bigint, p_token_id text, p_acao text)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `consumir_acao_turno_srd(p_campaign_id bigint, p_character_id text, p_acao text)` | jsonb | DEFINER | sim | sim | sim | não | não | mesa |
| `descanso_longo_npc_vinculado_srd(p_campaign_id bigint, p_token_id text)` | jsonb | INVOKER | não | sim | não | não | não | mesa, ficha |
| `descanso_longo_personagem_srd(p_campaign_id bigint, p_character_id text)` | jsonb | DEFINER | não | sim | sim | não | não | ficha |
| `entregar_item_token_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_quantidade integer)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `equipar_item_token_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `excluir_ficha_propria(p_character_id text)` | jsonb | DEFINER | sim | não | sim | não | não | lobby |
| `iniciar_ataque_iterativo_npc_srd(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `iniciar_ataque_iterativo_npc_srd(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `iniciar_iniciativa_com_dados(p_campaign_id bigint, p_expected_character_ids text[], p_request_id text, p_gm_d20_results jsonb)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `mover_combatente_iniciativa(p_campaign_id bigint, p_indice integer, p_direcao integer)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `mover_token_gm_cba_srd(p_campaign_id bigint, p_token_id text, p_grid_x integer, p_grid_y integer)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `mover_token_player_cba(p_campaign_id bigint, p_character_id text, p_grid_x integer, p_grid_y integer)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `registrar_iniciativa_d20(p_campaign_id bigint, p_personagem_id text, p_d20 integer)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `registrar_rolagem_ataque_iterativo_npc_srd(p_campaign_id bigint, p_sequence_id uuid, p_manual_d20 integer, p_idempotency_key uuid)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `registrar_rolagem_ataque_iterativo_srd(p_campaign_id bigint, p_sequence_id uuid, p_manual_d20 integer, p_idempotency_key uuid)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `resolver_ataque_iterativo_npc_srd(p_campaign_id bigint, p_attempt_id uuid)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `resolver_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid)` | jsonb | DEFINER | sim | sim | sim | não | não | mesa |
| `salvar_cena_cba(p_campaign_id bigint, p_scene jsonb)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `srd35_deslocamento_personagem(p_character_id text, p_base_speed_m numeric)` | numeric | DEFINER | sim | não | sim | sim | não | mesa, ficha |
| `srd_aplicar_dano_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)` | jsonb | DEFINER | sim | sim | sim | sim | não | mesa |
| `srd_aplicar_dano_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)` | jsonb | DEFINER | sim | sim | sim | sim | não | mesa |
| `srd_apply_campaign_condition(p_campaign_id bigint, p_target_kind text, p_target_id text, p_condition_id text, p_duration_rounds integer, p_notes jsonb)` | bigint | DEFINER | não | sim | sim | sim | não | — |
| `srd_apply_campaign_effect(p_campaign_id bigint, p_target_kind text, p_target_id text, p_effect_kind text, p_effect_data jsonb, p_duration_rounds integer, p_source_spell_id text, p_concentration_actor_id text)` | jsonb | DEFINER | não | sim | sim | sim | não | — |
| `srd_calcular_ca_personagem_srd(p_campaign_id bigint, p_character_id text, p_attack_context text, p_attacker_is_giant boolean)` | jsonb | DEFINER | sim | sim | sim | sim | sim | mesa, ficha |
| `srd_configurar_perfil_combate_token_srd(p_campaign_id bigint, p_token_id text, p_combat_faction text, p_melee_reach_ft integer)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_configurar_rodada_surpresa_srd(p_campaign_id bigint, p_aware_ids text[])` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_consultar_armas_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)` | jsonb | DEFINER | não | sim | sim | sim | não | mesa |
| `srd_consultar_modificadores_manobra_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_maneuver text, p_defender_firm_ground boolean)` | jsonb | DEFINER | não | sim | sim | sim | não | mesa |
| `srd_consultar_modificadores_manobra_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_maneuver text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)` | jsonb | INVOKER | sim | sim | sim | sim | não | mesa |
| `srd_detectar_saida_alcance_ameacado_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer)` | jsonb | DEFINER | sim | não | sim | sim | não | — |
| `srd_finalizar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_iniciar_ataque_oportunidade_desarmado_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)` | jsonb | DEFINER | sim | sim | sim | sim | não | mesa |
| `srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)` | jsonb | DEFINER | sim | sim | sim | sim | não | mesa |
| `srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_natural_attack_index integer)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_iniciar_ataque_oportunidade_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)` | jsonb | DEFINER | sim | sim | sim | sim | não | mesa |
| `srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_iniciar_encontrao_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_iniciar_levantar_caido_srd(p_campaign_id bigint, p_token_id text)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_listar_ataques_naturais_oportunidade_srd(p_campaign_id bigint, p_reactor_token_id text)` | jsonb | INVOKER | sim | sim | sim | sim | não | mesa |
| `srd_registrar_ocultacao_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_reservar_ataque_oportunidade_srd(p_campaign_id bigint, p_actor_token_id text, p_trigger_key text, p_actor_flat_footed boolean)` | jsonb | INVOKER | não | sim | não | não | não | — |
| `srd_reservar_reacao_movimento_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_resolve_confusion_turn_srd(p_campaign_id bigint, p_target_kind text, p_target_id text, p_request_id uuid, p_manual_d100 integer)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_resolve_dying_round(p_campaign_id bigint, p_character_id text, p_d100 integer)` | jsonb | DEFINER | sim | sim | sim | sim | não | mesa |
| `srd_resolve_npc_dying_round(p_campaign_id bigint, p_token_id text, p_d100 integer)` | jsonb | DEFINER | sim | sim | sim | sim | não | mesa |
| `srd_resolve_pending_spell_resistance(p_pending_id uuid, p_d20 integer)` | jsonb | DEFINER | não | sim | sim | sim | não | mesa |
| `srd_resolve_pending_spell_save(p_pending_id uuid, p_d20 integer)` | jsonb | DEFINER | sim | sim | sim | sim | não | mesa |
| `srd_resolve_requested_saving_throw_srd(p_campaign_id bigint, p_character_id text, p_request_id text, p_d20 integer)` | jsonb | DEFINER | não | sim | sim | não | não | mesa |
| `srd_resolver_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)` | jsonb | DEFINER | sim | sim | sim | sim | não | mesa |
| `srd_resolver_derrubar_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_attacker_d20 integer, p_defender_d20 integer, p_defender_uses_dex boolean, p_defender_firm_ground boolean, p_trip_using_weapon boolean)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_resolver_encontrao_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_follow boolean)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid)` | jsonb | INVOKER | não | sim | não | não | não | mesa |
| `srd_resolver_teste_resistencia_token_srd(p_campaign_id bigint, p_token_id text, p_save_type text, p_context text, p_d20 integer, p_dc integer)` | jsonb | DEFINER | sim | sim | sim | sim | não | — |
| `srd_solicitar_movimento_com_aoo_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer, p_controller text)` | jsonb | DEFINER | sim | não | sim | sim | não | mesa |
| `srd_validar_uso_pericia_srd(p_character_id text, p_skill_id text)` | jsonb | DEFINER | sim | não | sim | não | sim | mesa |
| `usar_furia_barbaro_npc_srd(p_campaign_id bigint, p_token_id text, p_action text)` | jsonb | DEFINER | sim | sim | sim | sim | não | mesa, ficha |
| `usar_furia_barbaro_srd(p_character_id text, p_action text)` | jsonb | DEFINER | sim | sim | sim | sim | não | mesa, ficha |
| `usar_habilidade_classe_srd(p_character_id text, p_feature_key text, p_target_token_key text, p_amount integer)` | jsonb | DEFINER | sim | sim | sim | não | não | mesa |
| `usar_imposicao_maos_mortos_vivos_srd(p_character_id text, p_target_token_key text, p_d20 integer, p_amount integer)` | jsonb | DEFINER | sim | não | sim | não | não | mesa |
| `usar_pocao_cura_srd_manual(p_character_id text, p_equipment_id text, p_roll_results integer[])` | jsonb | DEFINER | não | sim | sim | não | não | mesa |

## Como usar esta matriz

1. Para cada assinatura, identificar o consumidor real e o papel autorizado (GM, dono da ficha, jogador, observador ou externo).
2. Seguir a implementação até o ponto em que lê ou grava CBA/combate e classificar o retorno: estado completo, estado parcial, payload filtrado ou escalar sem estado privado.
3. Validar cada RPC com fixtures por papel e teste HTTP/PostgREST; a presença de auth.uid() não demonstra autorização correta, e ausência no wrapper não demonstra ausência de guardas transitivas.
4. Só depois de todas as raízes e canais Realtime estarem cobertos, preparar a migration de corte de SELECT/Realtime. Não aplicar revogação em massa.
