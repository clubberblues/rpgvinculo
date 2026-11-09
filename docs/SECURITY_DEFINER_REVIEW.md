# Revisão estática de SECURITY DEFINER expostas a authenticated — 2026-11-09

> Inventário das funções públicas que o Supabase Security Advisor sinaliza como SECURITY DEFINER executáveis por authenticated. O aviso é um alerta de superfície privilegiada, não prova automática de vulnerabilidade: RPCs legítimas frequentemente precisam executar com privilégios elevados, desde que validem autenticação, propriedade, papel e escopo dos dados.

## Resultado da triagem

- Funções SECURITY DEFINER públicas executáveis por authenticated: 99.
- EXECUTE para anon: 0.
- Todas com search_path explícito: sim.
- Todas incluem `pg_temp` no search_path: sim.
- Corpos com referência direta a `auth.uid()`: 96.
- Corpos com referência a `my_role()`: 39.
- Corpos com referência a `members`: 40.
- Corpos com padrões de propriedade: 47.
- Corpos com padrões de papel: 46.
- `gm_get_code` e `media_gc` delegam a verificação GM para `priv.need_gm`; `can_read_media` delega para `my_role`.

A triagem encontrou guardas diretas ou delegadas nos 99 corpos. Isto **não é aprovação semântica dos 99**: a presença de `auth.uid()` ou de uma consulta a `members` não prova que cada argumento esteja vinculado ao recurso correto. A revisão de autorização por função/fluxo continua obrigatória.

## Inventário por assinatura

| Função | auth.uid | my_role | need_gm | members | propriedade | papel | anon | MD5 |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| `adicionar_combatente_iniciativa(p_campaign_id bigint, p_combatente_id text, p_nome text, p_valor integer, p_tipo text)` | sim | — | — | sim | sim | sim | não | `a0428bb1540effb553bca4d0c6687cf5` |
| `adicionar_token_cba_completo(p_campaign_id bigint, p_token jsonb)` | sim | — | — | — | — | — | não | `f0ce341c60ff19afa06d38eae0f8b8a7` |
| `alterar_pv_token_cba(p_campaign_id bigint, p_token_id text, p_variacao integer, p_pv_max integer)` | sim | — | — | sim | sim | sim | não | `c16193eb256fd156122f436fe9f669e0` |
| `alternar_estado_campanha(p_campaign_id bigint, p_novo_estado text)` | sim | — | — | sim | sim | sim | não | `77ff609586000e471759ef6c26dd21c7` |
| `aplicar_dano_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)` | sim | — | — | sim | sim | — | não | `ad87093138d4a3e4ea86557294723f25` |
| `aplicar_dano_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[])` | sim | — | — | sim | sim | — | não | `fc0c985d6d6e8fa86c42dcabc772e03d` |
| `aplicar_dano_token_ataque_srd_v2(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer)` | sim | — | — | sim | sim | — | não | `1993f6c033c12f4b9291e9cb5c422f52` |
| `aplicar_dano_token_ataque_srd_v2(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer, p_sneak_attack_dice integer, p_sneak_attack_damage integer)` | sim | — | — | sim | sim | — | não | `84a9cce6a6c3abe9571a66e7e38cf65d` |
| `aplicar_dano_token_gm_personagem_srd(p_campaign_id bigint, p_token_id text, p_character_id text, p_dano integer)` | sim | — | — | sim | sim | sim | não | `324a03cbf53209750104128ba5e48ae7` |
| `atualizar_configuracoes_campanha(p_campaign_id bigint, p_name text, p_require_code boolean, p_code text)` | sim | — | — | — | — | — | não | `76e8115c02135fc7c6dc4b5040df607d` |
| `avancar_turno(p_campaign_id bigint)` | sim | — | — | sim | sim | — | não | `0086242101af79898ecae9fb319c2e1e` |
| `can_read_media(p_path text)` | — | sim | — | — | — | — | não | `10bbdbb1fc9a41128134bf7c19af937d` |
| `clonar_equipamento_ficha_para_token(p_campaign_id bigint, p_token_id text, p_character_id text)` | sim | — | — | sim | sim | sim | não | `25a6306d66e468d9f449196ea3ec3e53` |
| `conceder_xp_personagem_srd(p_campaign_id bigint, p_character_id text, p_xp integer)` | sim | — | — | sim | sim | sim | não | `cd64caeb9ab3513c82fb1735d4f224de` |
| `confirmar_critico_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_confirmation_d20 integer)` | sim | — | — | sim | sim | — | não | `5f3deff88f2976d987b5a3445a459c5a` |
| `conjurar_magia_com_acao_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_roll_results integer[])` | sim | — | — | — | sim | — | não | `902eb4878ef7e9b3474bfce94b708739` |
| `conjurar_magia_com_acao_srd_multialvo_v3(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])` | sim | — | — | — | sim | — | não | `16e636a42055f5716ffdd77707ccf1a7` |
| `conjurar_magia_dano_multialvo_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])` | sim | — | — | sim | sim | — | não | `07a0bbe02f336d8f0296591c284f0866` |
| `conjurar_magia_efeitos_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])` | sim | — | — | sim | sim | — | não | `dee23f4384b4522d5cd67dc4feba9298` |
| `conjurar_missil_magico_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_damage_rolls integer[])` | sim | — | — | — | sim | — | não | `ba9983e6c955519a03fe6a6235dae5f5` |
| `consultar_furia_barbaro_npc_srd(p_campaign_id bigint, p_token_id text)` | sim | sim | — | — | — | sim | não | `c7c753d63edb840ce20e3862461ee681` |
| `consultar_furia_barbaro_srd(p_character_id text)` | sim | sim | — | — | sim | — | não | `b9bd5fc174faf0f970ae4b8013135899` |
| `consultar_sequencia_ataque_iterativo_pendente_srd(p_campaign_id bigint, p_character_id text)` | sim | — | — | sim | sim | — | não | `c3744ac6d89aeadb83b44473468fdf54` |
| `consumir_acao_turno_srd(p_campaign_id bigint, p_character_id text, p_acao text)` | sim | — | — | sim | sim | — | não | `8937c55a8b6ba7632eef037b5f5ecac4` |
| `create_campaign(p_name text, p_code text, p_location bigint)` | sim | — | — | — | — | — | não | `9351a6f21c64cc291a33fb18459793fc` |
| `criar_personagem_srd_completo(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb, p_pericias jsonb, p_talentos jsonb)` | sim | — | — | — | — | — | não | `97839c425fe0dd00b1570d7ba2f968fe` |
| `criar_personagem_srd_completo(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb, p_pericias jsonb, p_talentos jsonb, p_identidade jsonb)` | sim | — | — | — | — | — | não | `9065cd7adc215d53a18dfe2bdcbced9d` |
| `descanso_longo_personagem_srd(p_campaign_id bigint, p_character_id text)` | sim | — | — | — | — | — | não | `7448c5c9bc5ae10c0695f84cf09cb25b` |
| `entrar_campanha_aberta(p_campaign_id bigint)` | sim | — | — | sim | — | — | não | `f497e63e2f71e78486451c7442103f4c` |
| `entrar_campanha_com_codigo(p_campaign_id bigint, p_code text)` | sim | — | — | sim | — | — | não | `048393b68fa7a625a544ef9baa548af4` |
| `entregar_item_srd(p_campaign_id bigint, p_character_id text, p_equipment_id text, p_quantidade integer)` | sim | — | — | sim | — | sim | não | `1847f736d1e28a69ae8379963ba258b2` |
| `entregar_item_token_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_quantidade integer)` | sim | — | — | sim | — | sim | não | `5ac265f058a9ebd62486cf6201d0ae42` |
| `equipar_item_token_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean)` | sim | — | — | sim | — | sim | não | `435102caf1d2ab433659d3b936b09076` |
| `excluir_ficha_propria(p_character_id text)` | sim | — | — | — | sim | — | não | `5b92922b463a2730b51bae3bbbdfccbe` |
| `finalizar_equipamento_inicial_srd(p_character_id text, p_metodo text, p_resultados jsonb, p_itens jsonb)` | sim | — | — | — | sim | — | não | `e2db338d772849b7407be69cfc20038e` |
| `gm_get_code(cid bigint)` | — | — | sim | — | — | — | não | `d6e810d2ddb5cc115b86bb08883d668f` |
| `gm_grant(cid bigint, p_char bigint, p_ouro integer, p_xp integer, p_item text, p_qtd integer)` | sim | — | sim | — | — | — | não | `1951e9f08271e6876fa223152dcf289c` |
| `gm_kick(cid bigint, p_user uuid)` | sim | — | — | sim | — | — | não | `5cbe0a9946deda8466e76d702f83d9a3` |
| `gm_reopen_sheet(p_char bigint, p_motivo text)` | sim | — | sim | — | — | — | não | `c35a5060e4f416fb16439b5c144d07fb` |
| `gm_set_bonus(p_char bigint, p_ca integer, p_rm integer, p_motivo text)` | sim | — | sim | — | — | — | não | `6de89ef54a61b9d4ba68eb1d87f6664f` |
| `gm_set_code(cid bigint, p_code text)` | sim | — | — | — | — | — | não | `42cb1dc3b2dc7ecb35c5fed53a086795` |
| `gm_set_role(cid bigint, p_username text, p_role text)` | sim | — | — | sim | — | — | não | `27771cc4378c12fcb67bf8618c540df1` |
| `gm_transfer(cid bigint, p_username text, p_confirmar boolean)` | sim | — | — | sim | sim | sim | não | `04cc93a42b514f4ab2144014d26017a0` |
| `iniciar_iniciativa_com_dados(p_campaign_id bigint, p_expected_character_ids text[], p_request_id text, p_gm_d20_results jsonb)` | sim | — | — | sim | sim | sim | não | `9ed52a747bf33094cc06a8681083fea5` |
| `join_campaign(p_code text)` | sim | sim | — | sim | — | — | não | `8eb12c73a0f2653db49fde0daa120a3a` |
| `leave_campaign(cid bigint)` | sim | sim | — | sim | sim | — | não | `aa718dac694cfdcefc05a196e871816d` |
| `lobby_list_v2()` | sim | — | — | sim | — | — | não | `d07db5d1d5d0164ab4119e674f63a2b4` |
| `media_gc(cid bigint)` | — | — | sim | — | — | — | não | `1c6ea8fbe4b111b83fcc2d3a2aa242ec` |
| `mover_combatente_iniciativa(p_campaign_id bigint, p_indice integer, p_direcao integer)` | sim | — | — | sim | sim | sim | não | `1e9428072cb0ef03e7d5b4b8ab5388c8` |
| `my_role(cid bigint)` | sim | — | — | sim | sim | — | não | `ad46ae87c5e92aadf03bf74e90c80892` |
| `registrar_iniciativa_d20(p_campaign_id bigint, p_personagem_id text, p_d20 integer)` | sim | — | — | sim | sim | sim | não | `ccbdedd091fc77fa7e0b49705a69b812` |
| `registrar_rolagem_ataque_iterativo_srd(p_campaign_id bigint, p_sequence_id uuid, p_manual_d20 integer, p_idempotency_key uuid)` | sim | — | — | sim | sim | — | não | `e17a07f3da16e67bf478e0613a95c2f7` |
| `resolver_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid)` | sim | — | — | sim | sim | — | não | `80cefcc1fbbb3321e90d8f40d1d840d9` |
| `salvar_cena_cba(p_campaign_id bigint, p_scene jsonb)` | sim | — | — | sim | sim | sim | não | `038e93166a1d4f0cb3dfe2f4597f812f` |
| `salvar_dominios_personagem_srd(p_character_id text, p_domain_ids text[])` | sim | — | — | — | sim | — | não | `c063d9d2fdc95c46fd9b9e18d4a690f1` |
| `salvar_grimorio_srd(p_character_id text, p_estado jsonb)` | sim | — | — | — | sim | — | não | `e8a2ea1719dea2ed1d0503f73f933bb6` |
| `salvar_idiomas_personagem_srd(p_character_id text, p_idiomas jsonb)` | sim | — | — | — | sim | — | não | `87fdccf7582885794bef33bb580c72d3` |
| `salvar_talentos_bonus_classe_inicial_srd(p_character_id text, p_talentos jsonb)` | sim | — | — | — | sim | — | não | `046aba71de91ef0ff7f24a2e72a8e44b` |
| `sentar_personagem_na_mesa(p_campaign_id bigint, p_character_id text)` | sim | — | — | sim | sim | sim | não | `48d4187a1777360fea452ae40dd6fbf5` |
| `sou_membro(cid bigint)` | sim | — | — | sim | sim | — | não | `1d1d97a4bb8e6febfe2e9b2e8511a306` |
| `srd35_deslocamento_personagem(p_character_id text, p_base_speed_m numeric)` | sim | sim | — | sim | sim | — | não | `e6abacac8d4f3369ce44de022f9cdb3d` |
| `srd_aplicar_dano_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)` | sim | sim | — | — | — | sim | não | `e2673e828af60a967204f327bd6e3f28` |
| `srd_aplicar_dano_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)` | sim | sim | — | — | — | sim | não | `7a2e372249a04ccb3230aaec95ed89ef` |
| `srd_apply_campaign_condition(p_campaign_id bigint, p_target_kind text, p_target_id text, p_condition_id text, p_duration_rounds integer, p_notes jsonb)` | sim | sim | — | — | — | sim | não | `e43a03b0aaa226cb06e57cee90d5a38c` |
| `srd_apply_campaign_effect(p_campaign_id bigint, p_target_kind text, p_target_id text, p_effect_kind text, p_effect_data jsonb, p_duration_rounds integer, p_source_spell_id text, p_concentration_actor_id text)` | sim | sim | — | — | — | sim | não | `c0fae0b658c47fbf8d294d2e9c5029c6` |
| `srd_calcular_ca_personagem_srd(p_campaign_id bigint, p_character_id text, p_attack_context text)` | sim | sim | — | — | sim | — | não | `ad8845bc79f6a3e6cf2e558837d3ec16` |
| `srd_calcular_ca_personagem_srd(p_campaign_id bigint, p_character_id text, p_attack_context text, p_attacker_is_giant boolean)` | sim | sim | — | sim | — | sim | não | `40df6d8e89e8a61954a3c46b20ce3565` |
| `srd_configurar_perfil_combate_token_srd(p_campaign_id bigint, p_token_id text, p_combat_faction text, p_melee_reach_ft integer)` | sim | sim | — | — | — | sim | não | `ec877948308177f5e51e3637ccc14f46` |
| `srd_configurar_rodada_surpresa_srd(p_campaign_id bigint, p_aware_ids text[])` | sim | sim | — | — | — | sim | não | `4626e9470b45cca1cb459bdb5faaee20` |
| `srd_confirmar_critico_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_confirmation_d20 integer)` | sim | sim | — | — | — | sim | não | `84f2806567a32d263acaa9a820b1696c` |
| `srd_consultar_armas_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)` | sim | sim | — | — | — | sim | não | `c7270f541fe8293592d933cf9ed753a3` |
| `srd_consultar_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)` | sim | sim | — | — | — | sim | não | `f1ddcca1cda00b5b060045fab96d21f5` |
| `srd_consultar_modificadores_manobra_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_maneuver text, p_defender_firm_ground boolean)` | sim | sim | — | — | — | sim | não | `955be6d7459179774dc96004e7f23150` |
| `srd_consultar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)` | sim | sim | — | — | — | sim | não | `b3e6ea933e228678ee6dd6f1aca089e5` |
| `srd_detectar_saida_alcance_ameacado_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer)` | sim | sim | — | — | sim | — | não | `5419d26aad112ced391acf4efd4abc31` |
| `srd_effective_modifier(p_campaign_id bigint, p_target_kind text, p_target_id text, p_stat text)` | sim | sim | — | — | — | — | não | `ef864fdb5ef32b6f1dd5933a1f1ae10b` |
| `srd_finalizar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)` | sim | sim | — | — | — | sim | não | `17fb9a9259675bf9d1c2278135ff2394` |
| `srd_iniciar_ataque_oportunidade_desarmado_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)` | sim | sim | — | — | — | sim | não | `b891864a3d8c80653feeafb54d9a4dfe` |
| `srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)` | sim | sim | — | — | — | sim | não | `44c3145a7e5dc696e5e5643fb0a6b1ce` |
| `srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_natural_attack_index integer)` | sim | sim | — | — | — | sim | não | `b12188da9c009734f31a553849756ccf` |
| `srd_iniciar_ataque_oportunidade_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)` | sim | sim | — | — | — | sim | não | `a641aab6e59793b2bf5b09cc290746db` |
| `srd_listar_movimentos_aoo_pendentes_srd(p_campaign_id bigint)` | sim | sim | — | — | — | sim | não | `5ab451a12deb204eea23de23bca1d8cf` |
| `srd_registrar_rolagem_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d20 integer, p_idempotency_key uuid)` | sim | sim | — | — | — | sim | não | `950703066647366f6336bffb82e7f7d4` |
| `srd_remove_campaign_condition(p_campaign_id bigint, p_target_kind text, p_target_id text, p_condition_id text)` | sim | sim | — | — | — | sim | não | `8746eea5bb8b3c86e2ef9f63285a2589` |
| `srd_remove_campaign_effect(p_campaign_id bigint, p_effect_instance_id bigint)` | sim | sim | — | — | — | sim | não | `97c2a2e5017d89511a8adb5fb8027d51` |
| `srd_resolve_dying_round(p_campaign_id bigint, p_character_id text, p_d100 integer)` | sim | sim | — | — | — | sim | não | `98025fdbfd01a93f8526ff9d91797849` |
| `srd_resolve_npc_dying_round(p_campaign_id bigint, p_token_id text, p_d100 integer)` | sim | sim | — | — | — | sim | não | `59527cd47f6bb98ff391fc0753b6edbd` |
| `srd_resolve_pending_spell_resistance(p_pending_id uuid, p_d20 integer)` | sim | sim | — | — | — | sim | não | `1f14474ea3149934ae266ae9c359a1e6` |
| `srd_resolve_pending_spell_save(p_pending_id uuid, p_d20 integer)` | sim | sim | — | — | — | sim | não | `23b9c7d3261fb26f833f31a8347e70da` |
| `srd_resolve_requested_saving_throw_srd(p_campaign_id bigint, p_character_id text, p_request_id text, p_d20 integer)` | sim | — | — | sim | sim | — | não | `ad7715ce88f4b96057e3af2ec14d41f5` |
| `srd_resolver_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)` | sim | sim | — | — | — | sim | não | `80a04e98b926307fe74bcbc34c963e7f` |
| `srd_resolver_teste_resistencia_token_srd(p_campaign_id bigint, p_token_id text, p_save_type text, p_context text, p_d20 integer, p_dc integer)` | sim | sim | — | — | — | sim | não | `27fce17667eac7b2e7c718f8442fa292` |
| `srd_solicitar_movimento_com_aoo_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer, p_controller text)` | sim | sim | — | — | sim | sim | não | `38c1ffad22be8fe01381770a2bdb06b3` |
| `srd_validar_uso_pericia_srd(p_character_id text, p_skill_id text)` | sim | — | — | sim | sim | sim | não | `24569605397c98f983150ddab87ba47f` |
| `usar_furia_barbaro_npc_srd(p_campaign_id bigint, p_token_id text, p_action text)` | sim | sim | — | — | — | sim | não | `0ae3b0a69028727bc44d47892a6fa59c` |
| `usar_furia_barbaro_srd(p_character_id text, p_action text)` | sim | sim | — | — | sim | — | não | `493254f0dd26cd36b45b6ed9331ad7b2` |
| `usar_habilidade_classe_srd(p_character_id text, p_feature_key text, p_target_token_key text, p_amount integer)` | sim | — | — | — | sim | — | não | `10168e67e07af3f204fa409b9af67cc6` |
| `usar_imposicao_maos_mortos_vivos_srd(p_character_id text, p_target_token_key text, p_d20 integer, p_amount integer)` | sim | — | — | — | sim | — | não | `2c23baa69395acac6d0205737a6a5b97` |
| `usar_pocao_cura_srd_manual(p_character_id text, p_equipment_id text, p_roll_results integer[])` | sim | — | — | — | sim | — | não | `dbd9067f3679f7d4fde3848984cdf3f2` |

## Interpretação e ações

1. Não revogar EXECUTE em lote: isso quebraria RPCs legítimas usadas pelo frontend e wrappers INVOKER.
2. Não converter SECURITY DEFINER para INVOKER em lote: o desenho atual usa funções privilegiadas para aplicar validações e gravar dados sob RLS.
3. Revisar por prioridade as funções que alteram dados de campanha/personagem, especialmente aquelas cujo corpo consulta apenas `auth.uid()` sem vínculo explícito de owner/membership no mesmo corpo; chamadas transitivas precisam ser abertas e auditadas.
4. Manter `search_path` explícito e `pg_temp` por último em todas as SECURITY DEFINER.
5. Confirmar no Dashboard os Exposed schemas; a lista de avisos é sobre funções public, mas funções internas priv/private também precisam de política de exposição e grants mínimos.
6. Configurar proteção contra senhas vazadas no Supabase Auth é uma ação operacional separada, não corrigida nesta auditoria.

## Avisos do advisor relacionados

- Security: 99 SECURITY DEFINER executáveis por authenticated (WARN); 7 tabelas com RLS habilitado sem policy (INFO; acesso direto negado por padrão); proteção contra senhas vazadas desabilitada (WARN).
- Performance: 52 índices sem uso registrado (INFO). Não remover automaticamente; parte pode ser recente, preventiva para FKs ou ainda não exercitada, incluindo índices do subsistema AOO.


## Verificação adicional das duas funções delegadas — 2026-11-09

A triagem de padrões não encontrou `auth.uid()`, `my_role()` ou consulta direta a `members` no corpo de `gm_get_code` e `media_gc`. A abertura dos corpos confirmou que ambas chamam `priv.need_gm(cid)`. Essa helper chama `public.my_role(cid)` e exige papel GM; `priv.need_gm` não concede EXECUTE direto a authenticated ou anon. `can_read_media` delega a verificação para `public.my_role`.

A consulta agregada confirmou para as 99 funções: 0 EXECUTE para anon, 99 EXECUTE para authenticated, 0 sem search_path explícito e 0 sem `pg_temp` no search_path. Isso fecha apenas a triagem de exposição/ambiente de execução; não substitui a validação semântica de cada parâmetro e recurso.


## Cruzamento com chamadas RPC do frontend principal — 2026-11-09

O cruzamento de assinaturas com chamadas literais `sb.rpc('nome', ...)` em `mesa.html`, `ficha.html` e `lobby.html` encontrou 70 assinaturas com nome em chamada literal. Outras 29 não apareceram como chamada literal nesses três arquivos. Quatro dessas 29 são chamadas por dispatch dinâmico confirmado:
- `srd_aplicar_dano_ataque_oportunidade_srd` e variante monstro, selecionadas por `damageRpc` em `mesa.html`.
- `srd_resolve_pending_spell_save` e `srd_resolve_pending_spell_resistance`, selecionadas por `rpcName` em `mesa.html`.

As 25 assinaturas restantes não foram encontradas em chamadas literais nem nesses dispatchers dinâmicos. Isso **não significa que estejam sem uso**: podem ser chamadas por outras páginas/scripts, por Storage policies, triggers ou internamente por outras funções. São candidatas a revisão de superfície e legado, não a revogação imediata. Entre elas estão `srd_detectar_saida_alcance_ameacado_srd`, que é chamada internamente por `srd_solicitar_movimento_com_aoo_srd` e também conserva EXECUTE para authenticated; sua exposição direta merece revisão de necessidade mínima.


### Dependência interna de `srd_detectar_saida_alcance_ameacado_srd`
Consulta aos corpos de funções em `public`, `priv` e `private` encontrou somente um chamador SQL: `public.srd_solicitar_movimento_com_aoo_srd`, que é SECURITY DEFINER. Não foi encontrado uso direto em `mesa.html`, `ficha.html` ou `lobby.html`. Assim, EXECUTE para authenticated na função detector parece dispensável para o fluxo atual; a opção de hardening de menor superfície é mover a implementação para `priv` ou revogar o grant direto a authenticated após verificar todos os artefatos externos e políticas. Não alterado nesta fase de reconciliação.
