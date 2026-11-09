# Vínculo RPG — Inventário de RPCs chamadas pelo frontend

> Snapshot-base de 2026-11-08, revalidado em 2026-11-09. A extração separa nomes literais de call sites dinâmicos e rastreia todos os alvos possíveis. A correspondência por nome e catálogo PostgreSQL não valida, por si só, argumentos em runtime.

## Resumo

- 100 nomes literais distintos extraídos diretamente de lobby.html, ficha.html e mesa.html; 4 call sites dinâmicos com 11 alternativas de dispatch e 9 alvos únicos (3 também aparecem literalmente), totalizando 106 nomes de função distintos resolvidos.
- mesa.html: 87; ficha.html: 12; lobby.html: 10.
- 0 nomes sem função pública correspondente (esperado: 0).
- 114 assinaturas públicas correspondentes aos 106 nomes distintos, incluindo sobrecargas.

## RPCs e assinaturas

| RPC | Página(s) | Assinaturas públicas encontradas | SECURITY DEFINER | Auth EXECUTE | Anon EXECUTE | Guarda estática | search_path + pg_temp |
|---|---|---|---|---|---|---|---|
| adicionar_combatente_iniciativa | mesa | p_campaign_id bigint, p_combatente_id text, p_nome text, p_valor integer, p_tipo text | sim | sim | não | uid, members | sim |
| adicionar_token_cba_completo | mesa | p_campaign_id bigint, p_token jsonb | sim | sim | não | uid | sim |
| alterar_pv_personagem | mesa | p_campaign_id bigint, p_character_id text, p_variacao integer | não | sim | não | uid, role | não |
| alterar_pv_token_cba | mesa | p_campaign_id bigint, p_token_id text, p_variacao integer, p_pv_max integer | sim | sim | não | uid, members | sim |
| alternar_estado_campanha | mesa | p_campaign_id bigint, p_novo_estado text | sim | sim | não | uid, members | sim |
| aplicar_dano_ataque_iterativo_npc_srd | mesa | p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[] | não | sim | não | não detectada | não |
| aplicar_dano_ataque_iterativo_srd | mesa | p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid<br>p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[] | sim | sim | não | uid, members | sim |
| aplicar_dano_ataque_npc_gm_srd | mesa | p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_raw_damage integer, p_damage_type text | não | sim | não | não detectada | não |
| aplicar_dano_token_ataque_srd_v2 | mesa | p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer<br>p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer, p_sneak_attack_dice integer, p_sneak_attack_damage integer | sim | sim | não | uid, members | sim |
| atualizar_configuracoes_campanha | lobby | p_campaign_id bigint, p_name text, p_require_code boolean, p_code text | sim | sim | não | uid | sim |
| avancar_turno | mesa | p_campaign_id bigint | sim | sim | não | uid, members | sim |
| clonar_equipamento_ficha_para_token | mesa | p_campaign_id bigint, p_token_id text, p_character_id text | sim | sim | não | uid, members | sim |
| conceder_xp_personagem_srd | mesa | p_campaign_id bigint, p_character_id text, p_xp integer | sim | sim | não | uid, members | sim |
| concluir_avanco_nivel_personagem_srd_v2 | ficha | p_campaign_id bigint, p_character_id text, p_hit_die_roll integer, p_skill_ranks jsonb, p_feats jsonb, p_attribute text, p_idiomas jsonb | não | sim | não | uid | não |
| confirmar_critico_ataque_iterativo_npc_srd | mesa | p_campaign_id bigint, p_attempt_id uuid, p_confirmation_d20 integer | não | sim | não | não detectada | não |
| confirmar_critico_ataque_iterativo_srd | mesa | p_campaign_id bigint, p_attempt_id uuid, p_confirmation_d20 integer | sim | sim | não | uid, members | sim |
| conjurar_magia_com_acao_srd_manual | mesa | p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_roll_results integer[] | sim | sim | não | uid | sim |
| conjurar_magia_com_acao_srd_multialvo_v3 | mesa | p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[] | sim | sim | não | uid | sim |
| conjurar_magia_dano_multialvo_srd | mesa | p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[] | sim | sim | não | uid, members | sim |
| conjurar_magia_efeitos_multialvo | mesa | p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[] | sim | sim | não | uid, members | sim |
| conjurar_missil_magico_srd_manual | mesa | p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_damage_rolls integer[] | sim | sim | não | uid | sim |
| consultar_ataque_iterativo_npc_pendente_srd | mesa | p_campaign_id bigint, p_actor_token_id text | não | sim | não | não detectada | não |
| consultar_ataque_iterativo_npc_srd | mesa | p_campaign_id bigint, p_token_id text, p_attack_type text | não | sim | não | não detectada | não |
| consultar_furia_barbaro_npc_srd | mesa,ficha | p_campaign_id bigint, p_token_id text | sim | sim | não | uid, role | sim |
| consultar_furia_barbaro_srd | mesa,ficha | p_character_id text | sim | sim | não | uid, role | sim |
| consultar_inventario_npc_vinculado_srd | mesa | p_campaign_id bigint, p_token_id text | não | sim | não | não detectada | sim |
| consultar_sequencia_ataque_iterativo_pendente_srd | mesa | p_campaign_id bigint, p_character_id text | sim | sim | não | uid, members | sim |
| consumir_acao_token_gm_srd | mesa | p_campaign_id bigint, p_token_id text, p_acao text | não | sim | não | não detectada | sim |
| consumir_acao_turno_srd | mesa | p_campaign_id bigint, p_character_id text, p_acao text | sim | sim | não | uid, members | sim |
| create_campaign | lobby | p_name text, p_code text, p_location bigint | sim | sim | não | uid | sim |
| descanso_longo_npc_vinculado_srd | mesa,ficha | p_campaign_id bigint, p_token_id text | não | sim | não | não detectada | sim |
| descanso_longo_personagem_srd | ficha | p_campaign_id bigint, p_character_id text | sim | sim | não | uid | sim |
| entrar_campanha_aberta | lobby | p_campaign_id bigint | sim | sim | não | uid, members | sim |
| entrar_campanha_com_codigo | lobby | p_campaign_id bigint, p_code text | sim | sim | não | uid, members | sim |
| entregar_item_srd | mesa | p_campaign_id bigint, p_character_id text, p_equipment_id text, p_quantidade integer | sim | sim | não | uid, members | sim |
| entregar_item_token_srd | mesa | p_campaign_id bigint, p_token_id text, p_equipment_id text, p_quantidade integer | sim | sim | não | uid, members | sim |
| equipar_item_npc_vinculado_srd | mesa | p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean | não | sim | não | não detectada | não |
| equipar_item_srd | mesa | p_character_id text, p_equipment_id text, p_equipado boolean | não | sim | não | uid, role | não |
| equipar_item_token_srd | mesa | p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean | sim | sim | não | uid, members | sim |
| excluir_ficha_propria | lobby | p_character_id text | sim | sim | não | uid | sim |
| finalizar_criacao_personagem_srd | ficha | p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb, p_pericias jsonb, p_talentos jsonb, p_identidade jsonb, p_idiomas jsonb, p_talentos_bonus jsonb, p_domain_ids text[], p_grimorio jsonb, p_equipamento_metodo text, p_equipamento_resultados jsonb, p_equipamento_itens jsonb | não | sim | não | uid | sim |
| finalizar_exclusao_campanha_propria | mesa,lobby | p_campaign_id bigint | não | sim | não | não detectada | sim |
| iniciar_ataque_iterativo_npc_srd | mesa | p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text<br>p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer | não | sim | não | não detectada | não |
| iniciar_iniciativa_com_dados | mesa | p_campaign_id bigint, p_expected_character_ids text[], p_request_id text, p_gm_d20_results jsonb | sim | sim | não | uid, members | sim |
| iniciar_sequencia_ataque_iterativo_srd | mesa | p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid<br>p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text<br>p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer | não | sim | não | não detectada | sim |
| join_campaign | lobby | p_code text | sim | sim | não | uid, role, members | sim |
| lobby_list_v2 | lobby | (sem argumentos) | sim | sim | não | uid, members | sim |
| mover_combatente_iniciativa | mesa | p_campaign_id bigint, p_indice integer, p_direcao integer | sim | sim | não | uid, members | sim |
| mover_token_gm_cba_srd | mesa | p_campaign_id bigint, p_token_id text, p_grid_x integer, p_grid_y integer | não | sim | não | não detectada | sim |
| mover_token_player_cba | mesa | p_campaign_id bigint, p_character_id text, p_grid_x integer, p_grid_y integer | não | sim | não | não detectada | sim |
| preparar_exclusao_campanha_propria | mesa,lobby | p_campaign_id bigint | não | sim | não | não detectada | sim |
| registrar_iniciativa_d20 | mesa | p_campaign_id bigint, p_personagem_id text, p_d20 integer | sim | sim | não | uid, members | sim |
| registrar_rolagem_ataque_iterativo_npc_srd | mesa | p_campaign_id bigint, p_sequence_id uuid, p_manual_d20 integer, p_idempotency_key uuid | não | sim | não | não detectada | não |
| registrar_rolagem_ataque_iterativo_srd | mesa | p_campaign_id bigint, p_sequence_id uuid, p_manual_d20 integer, p_idempotency_key uuid | sim | sim | não | uid, members | sim |
| resolver_ataque_iterativo_npc_srd | mesa | p_campaign_id bigint, p_attempt_id uuid | não | sim | não | não detectada | não |
| resolver_ataque_iterativo_srd | mesa | p_campaign_id bigint, p_attempt_id uuid | sim | sim | não | uid, members | sim |
| salvar_cena_cba | mesa | p_campaign_id bigint, p_scene jsonb | sim | sim | não | uid, members | sim |
| salvar_dominios_personagem_srd | ficha | p_character_id text, p_domain_ids text[] | sim | sim | não | uid | sim |
| salvar_grimorio_srd | ficha | p_character_id text, p_estado jsonb | sim | sim | não | uid | sim |
| sentar_personagem_na_mesa | lobby | p_campaign_id bigint, p_character_id text | sim | sim | não | uid, members | sim |
| srd_calcular_ca_personagem_srd | mesa,ficha | p_campaign_id bigint, p_character_id text, p_attack_context text<br>p_campaign_id bigint, p_character_id text, p_attack_context text, p_attacker_is_giant boolean | sim | sim | não | uid, role, members | sim |
| srd_cancelar_movimento_aoo_pendente_srd | mesa | p_campaign_id bigint, p_pending_id uuid | não | sim | não | não detectada | sim |
| srd_configurar_perfil_combate_token_srd | mesa | p_campaign_id bigint, p_token_id text, p_combat_faction text, p_melee_reach_ft integer | sim | sim | não | uid, role | sim |
| srd_configurar_rodada_surpresa_srd | mesa | p_campaign_id bigint, p_aware_ids text[] | sim | sim | não | uid, role | sim |
| srd_confirmar_critico_ataque_oportunidade_srd | mesa | p_campaign_id bigint, p_attack_id uuid, p_confirmation_d20 integer | sim | sim | não | uid, role | sim |
| srd_consultar_armas_aoo_srd | mesa | p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text | sim | sim | não | uid, role | sim |
| srd_consultar_ataque_oportunidade_srd | mesa | p_campaign_id bigint, p_attack_id uuid | sim | sim | não | uid, role | sim |
| srd_consultar_modificadores_manobra_srd | mesa | p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_maneuver text, p_defender_firm_ground boolean<br>p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_maneuver text, p_defender_firm_ground boolean, p_trip_using_weapon boolean | mista | sim | não | uid, role | sim |
| srd_effective_modifier | mesa | p_campaign_id bigint, p_target_kind text, p_target_id text, p_stat text | sim | sim | não | uid, role | sim |
| srd_encerrar_reacao_aoo_pendente_srd | mesa | p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean | não | sim | não | não detectada | sim |
| srd_finalizar_movimento_aoo_pendente_srd | mesa | p_campaign_id bigint, p_pending_id uuid | sim | sim | não | uid, role | sim |
| srd_iniciar_ataque_oportunidade_desarmado_srd | mesa | p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid | sim | sim | não | uid, role | sim |
| srd_iniciar_ataque_oportunidade_monstro_srd | mesa | p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid<br>p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_natural_attack_index integer | sim | sim | não | uid, role | sim |
| srd_iniciar_ataque_oportunidade_srd | mesa | p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text | sim | sim | não | uid, role | sim |
| srd_iniciar_derrubar_com_aoo_srd | mesa | p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean, p_trip_using_weapon boolean | não | sim | não | não detectada | sim |
| srd_iniciar_encontrao_srd | mesa | p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text | não | sim | não | não detectada | sim |
| srd_iniciar_levantar_caido_srd | mesa | p_campaign_id bigint, p_token_id text | não | sim | não | não detectada | sim |
| srd_listar_ataques_naturais_oportunidade_srd | mesa | p_campaign_id bigint, p_reactor_token_id text | não | sim | não | uid, role | sim |
| srd_listar_movimentos_aoo_pendentes_srd | mesa | p_campaign_id bigint | sim | sim | não | uid, role | sim |
| srd_registrar_ocultacao_ataque_oportunidade_srd | mesa | p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer | não | sim | não | não detectada | sim |
| srd_registrar_rolagem_ataque_oportunidade_srd | mesa | p_campaign_id bigint, p_attack_id uuid, p_manual_d20 integer, p_idempotency_key uuid | sim | sim | não | uid, role | sim |
| srd_reservar_reacao_movimento_aoo_srd | mesa | p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text | não | sim | não | não detectada | sim |
| srd_resolve_confusion_turn_srd | mesa | p_campaign_id bigint, p_target_kind text, p_target_id text, p_request_id uuid, p_manual_d100 integer | não | sim | não | não detectada | sim |
| srd_resolve_dying_round | mesa | p_campaign_id bigint, p_character_id text, p_d100 integer | sim | sim | não | uid, role | sim |
| srd_resolve_npc_dying_round | mesa | p_campaign_id bigint, p_token_id text, p_d100 integer | sim | sim | não | uid, role | sim |
| srd_resolve_pending_spell_save | mesa | p_pending_id uuid, p_d20 integer | sim | sim | não | uid, role | sim |
| srd_resolve_requested_saving_throw_srd | mesa | p_campaign_id bigint, p_character_id text, p_request_id text, p_d20 integer | sim | sim | não | uid, members | sim |
| srd_resolver_ataque_oportunidade_srd | mesa | p_campaign_id bigint, p_attack_id uuid | sim | sim | não | uid, role | sim |
| srd_resolver_derrubar_apos_aoo_srd | mesa | p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean | não | sim | não | não detectada | sim |
| srd_resolver_derrubar_srd | mesa | p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_attacker_d20 integer, p_defender_d20 integer, p_defender_uses_dex boolean, p_defender_firm_ground boolean, p_trip_using_weapon boolean | não | sim | não | não detectada | sim |
| srd_resolver_encontrao_srd | mesa | p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_follow boolean | não | sim | não | não detectada | sim |
| srd_resolver_levantar_caido_apos_aoo_srd | mesa | p_campaign_id bigint, p_pending_id uuid | não | sim | não | não detectada | sim |
| srd_solicitar_movimento_com_aoo_srd | mesa | p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer, p_controller text | sim | sim | não | uid, role | sim |
| srd_validar_uso_pericia_srd | mesa | p_character_id text, p_skill_id text | sim | sim | não | uid, members | sim |
| srd35_deslocamento_personagem | mesa,ficha | p_character_id text, p_base_speed_m numeric | sim | sim | não | uid, role, members | sim |
| usar_furia_barbaro_npc_srd | mesa,ficha | p_campaign_id bigint, p_token_id text, p_action text | sim | sim | não | uid, role | sim |
| usar_furia_barbaro_srd | mesa,ficha | p_character_id text, p_action text | sim | sim | não | uid, role | sim |
| usar_habilidade_classe_srd | mesa | p_character_id text, p_feature_key text, p_target_token_key text, p_amount integer | sim | sim | não | uid | sim |
| usar_imposicao_maos_mortos_vivos_srd | mesa | p_character_id text, p_target_token_key text, p_d20 integer, p_amount integer | sim | sim | não | uid | sim |
| usar_pocao_cura_srd_manual | mesa | p_character_id text, p_equipment_id text, p_roll_results integer[] | sim | sim | não | uid | sim |

## Limitações e próxima validação

- Uma RPC pode ter várias sobrecargas. O frontend pode escolher a sobrecarga errada se o conjunto de chaves/tipos enviado não corresponder à assinatura esperada; esse cruzamento ainda está pendente.
- A coluna Guarda estática indica apenas a presença de marcadores textuais (auth.uid, my_role, need_gm, public.members). Não prova que a validação esteja correta, nem que cubra campanha, papel, alvo e estado.
- EXECUTE para authenticated é esperado em RPCs de aplicação, mas cada função SECURITY DEFINER precisa de validação semântica e testes por papel.
- Os 100 nomes literais e todos os destinos possíveis dos 4 call sites dinâmicos têm correspondência em public. Nenhuma permissão foi alterada nesta inspeção.
- Próximo recorte recomendado: comparar argumentos/assinaturas para fluxos críticos em ordem: lobby/campanha, criação e edição de personagem, equipamento/CA, iniciativa, movimento, ataques/dano, magias e progressão.

## Arquivos de origem

- [mesa.html](../mesa.html)
- [ficha.html](../ficha.html)
- [lobby.html](../lobby.html)
- [Mapa de integração](INTEGRATION_MAP.md)


## Sobrecargas verificadas estaticamente em fluxos críticos

| RPC | Argumentos enviados pelo frontend | Assinatura selecionada |
|---|---:|---|
| aplicar_dano_ataque_iterativo_srd | 5 | overload com p_sneak_damage_rolls |
| aplicar_dano_token_ataque_srd_v2 | 11 | overload com p_sneak_attack_dice e p_sneak_attack_damage |
| iniciar_ataque_iterativo_npc_srd | 8 | overload com p_power_attack_penalty |
| iniciar_sequencia_ataque_iterativo_srd | 8 | overload com p_power_attack_penalty |
| srd_calcular_ca_personagem_srd | 3 ou 4 | 3 para personagem; 4 para NPC vinculado/contexto de atacante gigante |
| srd_consultar_modificadores_manobra_srd | 6 | overload com p_trip_using_weapon |
| srd_iniciar_ataque_oportunidade_monstro_srd | 5 | overload com p_natural_attack_index |

As chaves e quantidades observadas correspondem às assinaturas existentes. Isso reduz risco de resolução acidental para overload legado, mas ainda não prova compatibilidade de tipos em runtime nem resultado funcional. Os wrappers de ataque iterativo NPC são SECURITY INVOKER e delegam a implementações priv.*; os resolvers de dano e CA relevantes são SECURITY DEFINER com auth.uid e validação de campanha/papel no corpo.


## Chamadas dinâmicas resolvidas fora da extração literal

| RPC dinâmica | Página(s) | Assinatura pública | SECURITY DEFINER | Auth EXECUTE | Anon EXECUTE | Contrato |
|---|---|---|---|---|---|---|
| equipar_arma_instancia_personagem | ficha, mesa | p_character_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean | não | sim | não | Wrapper INVOKER → private.equipar_arma_instancia_personagem_impl; helper exige auth.uid e propriedade da ficha ou papel GM |
| equipar_arma_instancia_npc_vinculado_srd | ficha, mesa | p_campaign_id bigint, p_token_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean | não | sim | não | Wrapper INVOKER → private.equipar_arma_instancia_npc_vinculado_impl; helper exige auth.uid, GM e vínculo NPC válido |
| equipar_arma_instancia_token | mesa | p_campaign_id bigint, p_token_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean | não | sim | não | Wrapper INVOKER → private.equipar_arma_instancia_token_impl; helper exige auth.uid, papel GM e token NPC/monstro |
| srd_aplicar_dano_ataque_oportunidade_srd | mesa | p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid | sim | sim | não | search_path pg_catalog, public, priv, pg_temp; chave idempotente |
| srd_aplicar_dano_ataque_oportunidade_monstro_srd | mesa | p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid | sim | sim | não | search_path pg_catalog, public, priv, pg_temp; chave idempotente |
| srd_resolve_pending_spell_save | mesa | p_pending_id uuid, p_d20 integer | sim | sim | não | search_path pg_catalog, public, priv, pg_temp; também aparece em chamada literal |
| srd_resolve_pending_spell_resistance | mesa | p_pending_id uuid, p_d20 integer | sim | sim | não | search_path pg_catalog, public, priv, pg_temp |

Os três destinos da tabela acima são selecionados por dispatch dinâmico conforme o escopo character/linked_npc/token. Além deles, há dois dispatches dinâmicos na mesa: dano de AOO (arma natural vs. arma equipada) e resolução pendente de magia (salvamento vs. resistência à magia). Esses dispatches têm sete alvos possíveis no total; um alvo de salvamento também aparece em chamada literal. A união contém 106 nomes distintos (100 literais + 6 nomes adicionais únicos), com 114 assinaturas públicas.


## Verificação adicional de nomes literais — 2026-11-09
Varredura estática do HEAD atual em `mesa.html`, `ficha.html` e `lobby.html` extraiu 100 nomes literais distintos de chamadas `.rpc()`: 87 na mesa, 12 na ficha e 10 no lobby (há sobreposição entre páginas). Consulta somente de leitura ao catálogo `pg_proc` confirmou correspondência de **100/100 nomes no schema public**, sem nome literal ausente.

**Limite da evidência:** a correspondência por nome não comprova correspondência de argumentos/tipos, seleção correta de sobrecarga, autorização, semântica ou comportamento em runtime. Os 4 call sites dinâmicos e todas as 11 alternativas de dispatch (9 alvos únicos) foram rastreados estaticamente; suas assinaturas e grants precisam ser conferidos por fluxo.


## Rastreamento dos quatro call sites dinâmicos — 2026-11-09

A inspeção atual de `mesa.html` encontrou exatamente três chamadas `.rpc(variável, ...)`:

| Variável/dispatch | Condição | Alvos possíveis | Resultado da conferência PostgreSQL |
|---|---|---|---|
| `damageRpc` | `weapon_hand_slot === 'natural'` | `srd_aplicar_dano_ataque_oportunidade_monstro_srd`; `srd_aplicar_dano_ataque_oportunidade_srd` | Ambos existem em public, uma assinatura cada, SECURITY DEFINER, EXECUTE authenticated, sem anon/PUBLIC e search_path pg_catalog, public, priv, pg_temp. |
| `rpcName` do equipamento | scope character / linked_npc / token | `equipar_arma_instancia_personagem`; `equipar_arma_instancia_npc_vinculado_srd`; `equipar_arma_instancia_token` | Três alvos já documentados na tabela acima; cada um possui uma assinatura pública. |
| `rpcName` de resolução pendente | salvamento / resistência à magia | `srd_resolve_pending_spell_save`; `srd_resolve_pending_spell_resistance` | Ambos existem em public, uma assinatura cada, SECURITY DEFINER, EXECUTE authenticated, sem anon/PUBLIC e search_path pg_catalog, public, priv, pg_temp. O alvo de salvamento também aparece em uma chamada literal em outra parte do código. |

Os nove alvos dinâmicos únicos incluem três nomes que também aparecem em chamadas literais e seis nomes adicionais únicos além dos 100 nomes literais. Os quatro call sites dinâmicos somam onze alternativas de dispatch. A união contém **106 nomes distintos e 114 assinaturas públicas**, sem nome ausente na consulta atual. A consulta de assinatura/grants dos quatro alvos não relacionados a equipamento foi somente de leitura.



### Quarto call site dinâmico — ficha.html
A função de aplicação do inventário recebe `request.name` e resolve argumentos antes da chamada. Os nomes-base aceitos pelo dispatcher são `equipar_item_srd` e `equipar_arma_instancia_personagem`; quando os argumentos contêm `p_campaign_id`, o dispatcher troca para `equipar_item_npc_vinculado_srd` ou `equipar_arma_instancia_npc_vinculado_srd`. Esses quatro alvos já pertencem ao conjunto de 106 nomes (dois são nomes literais em mesa.html e dois já aparecem como destinos dinâmicos do dispatcher de armas). O call site não adiciona novo nome único, mas deve ser incluído na contagem de dispatches.


## Conferência de lobby/campanha — 2026-11-09
- 10 RPCs de lobby/ciclo de vida foram conferidas por assinatura, SECURITY DEFINER, EXECUTE authenticated/anon/PUBLIC e search_path: lobby_list_v2, create_campaign, join_campaign, entrar_campanha_aberta, entrar_campanha_com_codigo, sentar_personagem_na_mesa, atualizar_configuracoes_campanha, excluir_ficha_propria, preparar_exclusao_campanha_propria e finalizar_exclusao_campanha_propria (as duas últimas são wrappers INVOKER com implementação privada DEFINER).
- A exclusão de campanha foi rastreada como saga Storage + preparação/finalização. Ver ACTION_CONTRACTS.md para sequência, limites e riscos observados.
- Limite: grants e busca de marcadores no código não substituem teste autenticado por papel; nenhuma RPC mutável foi executada.
