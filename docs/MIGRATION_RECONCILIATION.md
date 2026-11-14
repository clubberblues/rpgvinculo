## Delta de reconciliação — 2026-11-13

Consulta direta ao ledger remoto e contagem da branch atual:

- Supabase remoto: **966** versões aplicadas, da `20261031160944` à `20261109005941`.
- Branch `audit/lock-order-rage-removal-2026-11-09`: **977** arquivos SQL em `supabase/migrations`.
- Delta: **11 migrations locais ainda não aplicadas**:
  - `20261110150000_fix_invoker_maneuver_catalog_helper_permissions.sql`
  - `20261110160000_revoke_public_feat_saving_throw_helper.sql`
  - `20261110170000_lock_down_internal_helper_execute.sql`
  - `20261112100000_harden_priv_default_privileges.sql`
  - `20261112110000_revoke_legacy_character_creation_rpc.sql`
  - `20261112120000_lock_down_character_creation_entrypoint.sql`
  - `20261112130000_fix_private_cba_storage_access.sql`
  - `20261112140000_add_role_filtered_tabletop_snapshot.sql`
  - `20261112150000_broadcast_campaign_refresh.sql`
  - `20261112160000_filter_player_damage_rpc_results.sql`
  - `20261112170000_allow_gm_controlled_character_rest.sql`

Nenhuma das 10 migrations foi aplicada ao projeto remoto. A proposta de revogar SELECT direto de `campaigns.cba_data/combat_data` foi retirada da pasta de migrations porque a revisão dos retornos RPC ainda não terminou. Não incluir esse corte até que todos os endpoints player-accessible estejam protegidos e testados.

O replay integral segue bloqueado por ausência do bootstrap pré-ledger que cria `public.campaigns`. Não fabricar schema mínimo nem marcar migrations como aplicadas artificialmente.

# Reconciliação de migrations — inventário e recuperação — 2026-11-10

## Resultado

| Métrica | Quantidade |
|---|---:|
| Arquivos em supabase/migrations (branch atual) | 969 |
| Registros remotos em `schema_migrations` | 966 |
| Arquivos correspondentes byte a byte às versões remotas (`statements[1]`) | 966 |
| Versões remotas sem arquivo local | 0 |
| Arquivos locais sem versão remota na pasta de migrations | 3 (candidatas de segurança, ainda não aplicadas) |
| Variantes locais de versões aplicadas preservadas em arquivo | 103 |
| Migrations locais sem versão remota preservadas em quarentena | 41 |
| Nomes duplicados no ledger remoto | 2 |

Os nomes duplicados remotos continuam sendo: `srd35_sneak_attack_damage_validation` (2 versões) e `srd35_rogue_uncanny_dodge_catalog_status` (2 versões). Das 103 variantes locais preservadas, 13 tinham diferença semântica e 90 eram equivalentes após normalização de comentários, espaços, casts redundantes em defaults e terminadores. Das 41 migrations locais em quarentena, 34 eram duplicatas semânticas com timestamp diferente, 5 eram variantes divergentes com mesmo nome lógico e 2 eram exclusivas de Anão/Bárbaro.

## Recuperação do SQL aplicado a partir do ledger remoto (2026-11-10)

A inspeção de `information_schema.columns` confirmou que `supabase_migrations.schema_migrations` contém a coluna `statements text[]`. Os 966 registros remotos têm um elemento SQL não vazio (`cardinality(statements)=1`). Portanto, ao contrário da hipótese inicial deste inventário, o ledger remoto **preserva o texto SQL executado** em `statements[1]`.

- Foram recuperados 326 arquivos ausentes, usando timestamp, nome e SQL de statements[1]: 72 de movimento/manobras/AOO e 254 de outros domínios.
- A comparação byte a byte identificou 103 variantes locais de versões já aplicadas. As 103 foram preservadas em docs/migration_reconciliation/local_variants/ e os caminhos de supabase/migrations foram alinhados ao SQL do ledger. A análise por tokens identificou 13 diferenças semânticas; os 90 restantes eram equivalentes após normalização de comentários, espaços, casts redundantes em defaults e terminadores.
- Os 41 arquivos locais sem versão remota foram preservados em docs/migration_reconciliation/unapplied_local/ e retirados de supabase/migrations para impedir que um db push os aplicasse por engano. Nenhum conteúdo foi descartado.
- Na conclusão da reconciliação, `supabase/migrations` continha exatamente 966 arquivos, um por versão remota, e todos os 966 hashes Git coincidiam byte a byte com `statements[1]`.
- Toda a recuperação e reconciliação ocorreu somente no GitHub. Nenhuma migration foi executada, reaplicada ou alterada no Supabase remoto.

## Inventário histórico anterior à recuperação — snapshot de 2026-11-09

A lista a seguir registra os 326 arquivos remotos que estavam ausentes antes da recuperação. Todos já foram reconstruídos na branch a partir de `statements[1]`; a lista foi mantida para rastreabilidade.

- `20261104043845` — `srd35_open_ended_craft_profession_skills` — arquivo local com mesmo nome: 20261104043500
- `20261104050319` — `srd35_spell_save_secondary_damage_rules` — arquivo local com mesmo nome: 20261104050200
- `20261104050323` — `srd35_multitarget_damage_duration_rolls` — arquivo local com mesmo nome: 20261104050300
- `20261104051415` — `srd35_multitarget_class_spell_level` — arquivo local com mesmo nome: 20261104051000
- `20261104051419` — `srd35_damage_multitarget_class_spell_level` — arquivo local com mesmo nome: 20261104051015
- `20261104051422` — `srd35_grimoire_class_level_validation` — arquivo local com mesmo nome: 20261104051030
- `20261104051700` — `srd35_single_target_mixed_damage_components` — arquivo local com mesmo nome: 20261104051600
- `20261104051704` — `srd35_area_mixed_damage_components` — arquivo local com mesmo nome: 20261104051615
- `20261104051707` — `srd35_flame_strike_engine_rule` — arquivo local com mesmo nome: 20261104051630
- `20261104052302` — `srd35_ice_storm_component_damage_rolls` — sem arquivo local de mesmo nome
- `20261104133625` — `srd35_trap_sense_dodge_bonus_conditions` — arquivo local com mesmo nome: 20261104134500
- `20261104134036` — `srd35_barbarian_rage_skill_use_restrictions` — arquivo local com mesmo nome: 20261104135000
- `20261104134414` — `srd35_monk_still_mind_enchantment_saves` — arquivo local com mesmo nome: 20261104140500
- `20261104134422` — `srd35_monk_still_mind_feature_status_and_barbarian_rage_skill_status` — sem arquivo local de mesmo nome
- `20261104134939` — `srd35_paladin_lay_on_hands_harm_undead` — arquivo local com mesmo nome: 20261104142000
- `20261104135134` — `srd35_paladin_lay_on_hands_harm_undead_feature_status` — sem arquivo local de mesmo nome
- `20261104135536` — `srd35_evasion_and_improved_evasion_reflex_saves` — arquivo local com mesmo nome: 20261104143200
- `20261104135731` — `srd35_damage_components_null_fallback` — arquivo local com mesmo nome: 20261104143000
- `20261104135833` — `srd35_evasion_class_feature_status` — arquivo local com mesmo nome: 20261104143500
- `20261104140152` — `srd35_rogue_trap_sense_ca_and_reflex` — arquivo local com mesmo nome: 20261104144000
- `20261104140222` — `srd35_rogue_trap_sense_feature_status` — arquivo local com mesmo nome: 20261104144200
- `20261104143719` — `srd35_sneak_attack_damage_validation` — arquivo local com mesmo nome: 20261104150000
- `20261104143907` — `srd35_sneak_attack_damage_validation` — arquivo local com mesmo nome: 20261104150000
- `20261104144912` — `srd35_sneak_attack_feature_catalog_partial` — arquivo local com mesmo nome: 20261104151000
- `20261104145447` — `srd35_rogue_uncanny_dodge_catalog_status` — arquivo local com mesmo nome: 20261104152000
- `20261104145503` — `srd35_rogue_uncanny_dodge_catalog_status` — arquivo local com mesmo nome: 20261104152000
- `20261104150050` — `srd35_rogue_trapfinding_skill_gate` — arquivo local com mesmo nome: 20261104153000
- `20261104150143` — `srd35_rogue_trapfinding_feature_status` — arquivo local com mesmo nome: 20261104153200
- `20261104173853` — `dwarf_barbarian_racial_saves_and_fast_movement_fix` — sem arquivo local de mesmo nome
- `20261104173905` — `dwarf_spell_and_poison_save_contexts` — sem arquivo local de mesmo nome
- `20261104174603` — `barbarian_jump_skill_alias` — arquivo local com mesmo nome: 20261104193000
- `20261104174733` — `dwarf_barbarian_armor_load_classification` — sem arquivo local de mesmo nome
- `20261104175617` — `barbarian_initial_skill_spend_aliases` — arquivo local com mesmo nome: 20261104200000
- `20261104180113` — `barbarian_rage_duration_adjusted_constitution` — arquivo local com mesmo nome: 20261104203000
- `20261104180521` — `remove_wrong_atletismo_class_skill_alias` — arquivo local com mesmo nome: 20261104204500
- `20261104221937` — `srd35_dwarf_weapon_familiarity_server` — arquivo local com mesmo nome: 20261104223000
- `20261105013330` — `allow_campaign_gm_to_equip_character_items` — arquivo local com mesmo nome: 20261105021400
- `20261105013434` — `harden_gm_character_equipment_updates` — arquivo local com mesmo nome: 20261105021800
- `20261105013547` — `allow_campaign_gm_character_hp_adjustment` — arquivo local com mesmo nome: 20261105023000
- `20261105013620` — `harden_character_hp_adjustment` — arquivo local com mesmo nome: 20261105023500
- `20261105023710` — `unified_ability_mechanics_catalog` — arquivo local com mesmo nome: 20261105030000
- `20261105024654` — `allow_campaign_gm_to_use_barbarian_rage` — arquivo local com mesmo nome: 20261105031500
- `20261105024851` — `stage_all_feat_and_monster_mechanics_for_review` — arquivo local com mesmo nome: 20261105032000
- `20261105025431` — `expire_barbarian_rage_on_round_change` — arquivo local com mesmo nome: 20261105033000
- `20261105030332` — `structure_improved_initiative_feat` — arquivo local com mesmo nome: 20261105040000
- `20261105030406` — `fix_improved_initiative_translation_line_breaks` — arquivo local com mesmo nome: 20261105040100
- `20261105030639` — `generic_passive_feat_modifiers` — arquivo local com mesmo nome: 20261105041000
- `20261105034725` — `srd_feat_translation_batch_01` — sem arquivo local de mesmo nome
- `20261105034918` — `srd_feat_translation_batch_02` — sem arquivo local de mesmo nome
- `20261105035013` — `srd_feat_translation_batch_03` — sem arquivo local de mesmo nome
- `20261105035050` — `srd_feat_translation_correction_01` — sem arquivo local de mesmo nome
- `20261105035219` — `srd_feat_translation_batch_04` — sem arquivo local de mesmo nome
- `20261105040058` — `srd_feat_translation_batch_05` — sem arquivo local de mesmo nome
- `20261105040130` — `srd_feat_translation_batch_06` — sem arquivo local de mesmo nome
- `20261105134249` — `support_repeatable_srd_feats` — sem arquivo local de mesmo nome
- `20261105134441` — `fix_repeatable_feat_prerequisite_parameter_match` — sem arquivo local de mesmo nome
- `20261105134643` — `apply_toughness_hit_point_delta` — sem arquivo local de mesmo nome
- `20261105135824` — `add_generic_passive_feat_save_modifier` — sem arquivo local de mesmo nome
- `20261105135936` — `use_generic_passive_feat_save_modifier` — sem arquivo local de mesmo nome
- `20261105140129` — `apply_spell_penetration_feats` — sem arquivo local de mesmo nome
- `20261105141417` — `structure_point_blank_shot_conditional_effects` — sem arquivo local de mesmo nome
- `20261105141844` — `normalize_point_blank_shot_prerequisite_translation` — sem arquivo local de mesmo nome
- `20261105141916` — `translate_point_blank_shot_prerequisite_raw` — sem arquivo local de mesmo nome
- `20261105142511` — `translate_ranged_feat_mechanics_prerequisites` — sem arquivo local de mesmo nome
- `20261105142806` — `add_full_round_action_reservation` — sem arquivo local de mesmo nome
- `20261105143425` — `structure_rapid_and_precise_shot_mechanics` — sem arquivo local de mesmo nome
- `20261105154734` — `allow_iterative_attack_penalties` — sem arquivo local de mesmo nome
- `20261105160012` — `add_token_weapon_hand_slots` — sem arquivo local de mesmo nome
- `20261105160311` — `harden_token_weapon_hand_rpc` — sem arquivo local de mesmo nome
- `20261105173743` — `create_weapon_instance_inventory` — sem arquivo local de mesmo nome
- `20261105173821` — `equip_weapon_instances` — sem arquivo local de mesmo nome
- `20261105174012` — `sync_weapon_inventory_instances` — sem arquivo local de mesmo nome
- `20261105174607` — `sync_weapon_instance_equipped_state` — sem arquivo local de mesmo nome
- `20261105174709` — `validate_main_hand_sneak_attack` — sem arquivo local de mesmo nome
- `20261105174853` — `sync_legacy_weapon_inventory_flags` — sem arquivo local de mesmo nome
- `20261105174913` — `fix_weapon_inventory_trigger_nonweapon_guard` — sem arquivo local de mesmo nome
- `20261105175752` — `use_declared_attack_bonus_in_hit_resolution` — sem arquivo local de mesmo nome
- `20261108042941` — `fix_sneak_attack_ranged_distance_validation_order` — sem arquivo local de mesmo nome
- `20261108044134` — `srd35_iterative_attack_sequence_foundation` — sem arquivo local de mesmo nome
- `20261108044154` — `srd35_iterative_attack_manual_roll_ledger` — sem arquivo local de mesmo nome
- `20261108044221` — `index_iterative_attack_actor_fk` — sem arquivo local de mesmo nome
- `20261108050112` — `validate_iterative_attack_target_and_equipped_weapon` — sem arquivo local de mesmo nome
- `20261108051021` — `srd35_iterative_attempt_resolution_ledger` — sem arquivo local de mesmo nome
- `20261108051030` — `srd35_iterative_critical_confirmation_state` — sem arquivo local de mesmo nome
- `20261108051359` — `srd35_iterative_weapon_hand_and_end_binding` — sem arquivo local de mesmo nome
- `20261108051420` — `harden_iterative_weapon_selection_null_validation` — sem arquivo local de mesmo nome
- `20261108052016` — `srd35_resolve_iterative_attack_roll` — sem arquivo local de mesmo nome
- `20261108052032` — `serialize_iterative_attack_attempt_resolution` — sem arquivo local de mesmo nome
- `20261108052121` — `srd35_iterative_critical_confirmation` — sem arquivo local de mesmo nome
- `20261108052204` — `srd35_iterative_attack_damage_application` — sem arquivo local de mesmo nome
- `20261108052304` — `srd35_fix_iterative_attack_strength_damage` — sem arquivo local de mesmo nome
- `20261108052445` — `srd35_iterative_bab_multiclass_and_dwarf_familiarity` — sem arquivo local de mesmo nome
- `20261108052506` — `srd35_iterative_power_attack_support` — sem arquivo local de mesmo nome
- `20261108052703` — `srd35_iterative_weapon_specialization_damage` — sem arquivo local de mesmo nome
- `20261108052717` — `srd35_iterative_critical_static_damage_bonuses` — sem arquivo local de mesmo nome
- `20261108052725` — `srd35_iterative_damage_state_and_equipment_revalidation` — sem arquivo local de mesmo nome
- `20261108052739` — `index_srd_character_weapon_instances_equipment_id` — sem arquivo local de mesmo nome
- `20261108052749` — `srd35_iterative_power_attack_strength_prerequisite` — sem arquivo local de mesmo nome
- `20261108053033` — `srd35_iterative_sneak_attack_server_resolution` — sem arquivo local de mesmo nome
- `20261108053052` — `srd35_iterative_persist_sneak_attack_rolls` — sem arquivo local de mesmo nome
- `20261108053126` — `srd35_iterative_sneak_attack_target_type_fix` — sem arquivo local de mesmo nome
- `20261108053142` — `srd35_iterative_sneak_attack_type_fallback` — sem arquivo local de mesmo nome
- `20261108055903` — `srd35_barbarian_rage_npc_token_control` — sem arquivo local de mesmo nome
- `20261108055920` — `fix_npc_rage_token_json_aggregate` — sem arquivo local de mesmo nome
- `20261108055947` — `return_npc_rage_scene_after_end` — sem arquivo local de mesmo nome
- `20261108060246` — `harden_npc_rage_expiration_and_log` — sem arquivo local de mesmo nome
- `20261108062812` — `srd35_iterative_attack_sequence_recovery_read` — sem arquivo local de mesmo nome
- `20261108063451` — `srd35_gm_full_round_action_reservation` — sem arquivo local de mesmo nome
- `20261108063518` — `remove_duplicate_gm_full_round_action_rpc` — sem arquivo local de mesmo nome
- `20261108063614` — `srd35_npc_iterative_attack_profile_read` — sem arquivo local de mesmo nome
- `20261108063940` — `srd35_npc_iterative_attack_ledger` — sem arquivo local de mesmo nome
- `20261108064005` — `srd35_npc_iterative_attack_start_and_rolls` — sem arquivo local de mesmo nome
- `20261108064052` — `fix_npc_attack_weapon_json_selection` — sem arquivo local de mesmo nome
- `20261108064312` — `srd35_npc_iterative_attack_resolution` — sem arquivo local de mesmo nome
- `20261108064334` — `srd35_npc_iterative_attack_critical_and_damage` — sem arquivo local de mesmo nome
- `20261108064503` — `srd35_npc_attack_player_ca_and_hp_sync` — sem arquivo local de mesmo nome
- `20261108064540` — `srd35_npc_iterative_attack_recovery_read` — sem arquivo local de mesmo nome
- `20261108064831` — `srd35_npc_attack_early_gm_authorization` — sem arquivo local de mesmo nome
- `20261108064950` — `srd35_npc_attack_private_implementation_wrappers` — sem arquivo local de mesmo nome
- `20261108065400` — `srd35_gm_npc_typed_damage_application` — sem arquivo local de mesmo nome
- `20261108065415` — `srd35_fix_gm_npc_damage_target_selection` — sem arquivo local de mesmo nome
- `20261108065536` — `srd35_barbarian_damage_reduction_linked_npc_tokens` — sem arquivo local de mesmo nome
- `20261108065606` — `srd35_gm_npc_damage_invoker_wrapper` — sem arquivo local de mesmo nome
- `20261108065723` — `srd35_guard_single_gm_npc_attack_damage_per_turn` — sem arquivo local de mesmo nome
- `20261108065757` — `srd35_barbarian_fast_movement_medium_armor_fix` — sem arquivo local de mesmo nome
- `20261108065825` — `srd35_npc_attack_actor_character_index` — sem arquivo local de mesmo nome
- `20261108065928` — `srd35_expire_npc_barbarian_rage_on_round_change` — sem arquivo local de mesmo nome
- `20261108070046` — `srd35_linked_npc_saving_throw_sheet_and_racial_features` — sem arquivo local de mesmo nome
- `20261108070556` — `end_npc_barbarian_rage_when_combat_ends` — sem arquivo local de mesmo nome
- `20261108070650` — `clear_fatigue_conditions_after_long_rest` — sem arquivo local de mesmo nome
- `20261108071013` — `gm_long_rest_linked_npc_srd` — sem arquivo local de mesmo nome
- `20261108071057` — `fix_npc_long_rest_condition_count` — sem arquivo local de mesmo nome
- `20261108071152` — `harden_gm_npc_long_rest_rpc` — sem arquivo local de mesmo nome
- `20261108071749` — `apply_srd_speed_to_linked_npc_tokens` — sem arquivo local de mesmo nome
- `20261108071941` — `restrict_linked_npc_sheet_control_to_gm_owner` — sem arquivo local de mesmo nome
- `20261108134130` — `use_linked_npc_sheet_for_initiative` — sem arquivo local de mesmo nome
- `20261108135422` — `enforce_conditions_on_gm_token_actions` — sem arquivo local de mesmo nome
- `20261108140730` — `fix_npc_rage_temporary_hp_and_sync_sheet` — sem arquivo local de mesmo nome
- `20261108142811` — `sync_linked_npc_sheet_vitals_after_damage` — sem arquivo local de mesmo nome
- `20261108142904` — `sync_linked_npc_sheet_vitals_after_player_iterative_damage` — sem arquivo local de mesmo nome
- `20261108142915` — `support_key_based_linked_npc_vital_sync` — sem arquivo local de mesmo nome
- `20261108143108` — `sync_linked_npc_sheet_vitals_after_healing` — sem arquivo local de mesmo nome
- `20261108143126` — `allow_linked_npc_vital_sync_for_campaign_gm_owner` — sem arquivo local de mesmo nome
- `20261108143213` — `sync_linked_npc_sheet_vitals_after_magic_missile` — sem arquivo local de mesmo nome
- `20261108143249` — `normalize_positive_negative_energy_damage_types` — sem arquivo local de mesmo nome
- `20261108144619` — `npc_negative_hp_and_stabilization_engine` — sem arquivo local de mesmo nome
- `20261108144640` — `preserve_npc_vital_states_through_rage_and_healing` — sem arquivo local de mesmo nome
- `20261108144811` — `preserve_npc_stabilization_round_state` — sem arquivo local de mesmo nome
- `20261108144908` — `enforce_npc_disabled_action_economy` — sem arquivo local de mesmo nome
- `20261108152256` — `request_npc_dying_saves_each_combat_round` — sem arquivo local de mesmo nome
- `20261108152503` — `prevent_common_healing_from_reviving_dead` — sem arquivo local de mesmo nome
- `20261108152515` — `prevent_long_rest_from_reviving_dead_characters` — sem arquivo local de mesmo nome
- `20261108152639` — `prevent_manual_spell_healing_from_reviving_dead_tokens` — sem arquivo local de mesmo nome
- `20261108152652` — `block_healing_from_negative_ten_hp_without_dead_flag` — sem arquivo local de mesmo nome
- `20261108152712` — `allow_npc_dying_checks_outside_combat_rounds` — sem arquivo local de mesmo nome
- `20261108152748` — `prevent_restarting_npc_stabilization_after_success` — sem arquivo local de mesmo nome
- `20261108152959` — `sync_mass_healing_with_npc_vital_states` — sem arquivo local de mesmo nome
- `20261108153527` — `allow_barbarian_fast_movement_in_medium_armor` — sem arquivo local de mesmo nome
- `20261108153942` — `apply_dwarf_gnome_dodge_bonus_against_giants` — sem arquivo local de mesmo nome
- `20261108155648` — `srd_maneuver_profiles_and_dwarf_stability` — sem arquivo local de mesmo nome
- `20261108155815` — `harden_maneuver_profile_character_scope` — sem arquivo local de mesmo nome
- `20261108160529` — `maneuver_aoo_and_improved_feat_classification` — sem arquivo local de mesmo nome
- `20261108161435` — `srd_aoo_reaction_ledger_and_reservation` — sem arquivo local de mesmo nome
- `20261108163239` — `srd_token_combat_faction_and_melee_reach` — sem arquivo local de mesmo nome
- `20261108163407` — `srd_detect_exit_from_threatened_area` — sem arquivo local de mesmo nome
- `20261108163434` — `correct_threatened_square_distance_and_path_detection` — sem arquivo local de mesmo nome
- `20261108163620` — `srd_pending_movement_aoo_interruption` — sem arquivo local de mesmo nome
- `20261108163708` — `srd_pending_movement_aoo_reaction_reservation` — sem arquivo local de mesmo nome
- `20261108163758` — `derive_aoo_footprints_from_linked_character_races` — sem arquivo local de mesmo nome
- `20261108164159` — `srd_individual_opportunity_attack_roll_resolution` — sem arquivo local de mesmo nome
- `20261108164305` — `srd_aoo_damage_and_pending_movement_finalization` — sem arquivo local de mesmo nome
- `20261108164328` — `harden_aoo_roll_idempotency` — sem arquivo local de mesmo nome
- `20261108164412` — `srd_aoo_gm_queue_and_weapon_inspection` — sem arquivo local de mesmo nome
- `20261108164441` — `refine_aoo_weapon_reach_and_dwarf_defense` — sem arquivo local de mesmo nome
- `20261108164658` — `allow_gm_finalize_player_aoo_movement` — sem arquivo local de mesmo nome
- `20261108165025` — `srd_aoo_unlinked_monster_natural_attacks` — sem arquivo local de mesmo nome
- `20261108165246` — `srd_aoo_linked_character_unarmed_strikes` — sem arquivo local de mesmo nome
- `20261108165307` — `avoid_duplicate_dynamic_bonus_on_unarmed_aoo` — sem arquivo local de mesmo nome
- `20261108165650` — `srd_aoo_5_10_5_footprint_distance` — sem arquivo local de mesmo nome
- `20261108165806` — `srd_aoo_reach_validation_uses_token_footprints` — sem arquivo local de mesmo nome
- `20261108170021` — `srd_aoo_pending_movement_lifecycle_guards` — sem arquivo local de mesmo nome
- `20261108170453` — `srd35_flatfooted_condition_engine_core` — sem arquivo local de mesmo nome
- `20261108170504` — `srd35_flatfooted_turn_and_combat_lifecycle` — sem arquivo local de mesmo nome
- `20261108170548` — `srd_aoo_distinguish_flatfooted_from_dex_loss` — sem arquivo local de mesmo nome
- `20261108170655` — `srd_aoo_reactor_conditions_and_flatfooted_feedback` — sem arquivo local de mesmo nome
- `20261108171104` — `srd35_surprise_round_engine` — sem arquivo local de mesmo nome
- `20261108171117` — `srd35_surprise_round_action_economy_guard` — sem arquivo local de mesmo nome
- `20261108171210` — `srd35_surprise_round_movement_guards` — sem arquivo local de mesmo nome
- `20261108171241` — `srd35_surprise_round_flatfooted_and_action_refinement` — sem arquivo local de mesmo nome
- `20261108171318` — `harden_surprise_round_turn_authorization` — sem arquivo local de mesmo nome
- `20261108171614` — `reset_action_economy_after_surprise_round` — sem arquivo local de mesmo nome
- `20261108171828` — `separate_surprise_and_normal_aoo_reaction_ledgers` — sem arquivo local de mesmo nome
- `20261108172218` — `index_aoo_attacks_campaign_fk` — sem arquivo local de mesmo nome
- `20261108172229` — `index_weapon_instances_equipment_fk` — sem arquivo local de mesmo nome
- `20261108172638` — `block_multitarget_healing_spell_during_barbarian_rage` — sem arquivo local de mesmo nome
- `20261108173533` — `maneuver_trip_weapon_aoo_context` — sem arquivo local de mesmo nome
- `20261108173901` — `srd_trip_maneuver_resolution` — sem arquivo local de mesmo nome
- `20261108174016` — `harden_trip_resolution_rpc_boundary` — sem arquivo local de mesmo nome
- `20261108174137` — `trip_defender_uses_best_ability_modifier` — sem arquivo local de mesmo nome
- `20261108174844` — `integrate_trip_maneuver_aoo_reactions` — sem arquivo local de mesmo nome
- `20261108174944` — `harden_trip_aoo_resolution_wrapper` — sem arquivo local de mesmo nome
- `20261108174958` — `validate_trip_aoo_reach_against_selected_weapon` — sem arquivo local de mesmo nome
- `20261108175022` — `move_trip_aoo_definers_to_private_schema` — sem arquivo local de mesmo nome
- `20261108175045` — `derive_trip_aoo_reach_from_equipped_weapon` — sem arquivo local de mesmo nome
- `20261108175200` — `fix_trip_natural_attack_reach_parser` — sem arquivo local de mesmo nome
- `20261108175504` — `srd_stand_up_with_aoo_reactions` — sem arquivo local de mesmo nome
- `20261108175603` — `harden_stand_up_condition_and_faction_checks` — sem arquivo local de mesmo nome
- `20261108175624` — `allow_player_to_start_own_stand_up` — sem arquivo local de mesmo nome
- `20261108175631` — `allow_player_to_finish_own_stand_up` — sem arquivo local de mesmo nome
- `20261108175759` — `validate_stand_up_move_action_before_aoo` — sem arquivo local de mesmo nome
- `20261108175809` — `block_stand_up_while_helpless` — sem arquivo local de mesmo nome
- `20261108180836` — `srd_bull_rush_pending_and_resolution` — sem arquivo local de mesmo nome
- `20261108180917` — `fix_bull_rush_minimum_push_and_token_guard` — sem arquivo local de mesmo nome
- `20261108181057` — `complete_bull_rush_attacker_follow_movement` — sem arquivo local de mesmo nome
- `20261108181508` — `correct_bull_rush_diagonal_push_geometry` — sem arquivo local de mesmo nome
- `20261108181528` — `fix_bull_rush_minimum_and_margin_push_distance` — sem arquivo local de mesmo nome
- `20261108181547` — `derive_bull_rush_vector_from_token_footprints` — sem arquivo local de mesmo nome
- `20261108182658` — `complete_bull_rush_follow_movement_budget` — sem arquivo local de mesmo nome
- `20261108182803` — `refine_bull_rush_follow_movement_budget` — sem arquivo local de mesmo nome
- `20261108182845` — `handle_flat_footed_aoo_reactor_without_combat_reflexes` — sem arquivo local de mesmo nome
- `20261108183713` — `enforce_trip_attacker_reach_and_equipped_weapon` — sem arquivo local de mesmo nome
- `20261108184106` — `catalog_trip_weapons_and_validate_trip_property` — sem arquivo local de mesmo nome
- `20261108184220` — `validate_trip_aoo_weapon_threatened_squares` — sem arquivo local de mesmo nome
- `20261108184327` — `enforce_weapon_threatened_range_for_aoo` — sem arquivo local de mesmo nome
- `20261108184716` — `require_improved_unarmed_strike_for_unarmed_aoo` — sem arquivo local de mesmo nome
- `20261108184746` — `filter_non_threatening_weapons_from_aoo_picker` — sem arquivo local de mesmo nome
- `20261108185137` — `derive_movement_aoo_from_equipped_and_natural_threat_ranges` — sem arquivo local de mesmo nome
- `20261108185259` — `scale_trip_aoo_reach_by_creature_size` — sem arquivo local de mesmo nome
- `20261108185301` — `harden_aoo_movement_finalization_terminal_ledger` — sem arquivo local de mesmo nome
- `20261108185307` — `correct_trip_unarmed_reach_for_large_creatures` — sem arquivo local de mesmo nome
- `20261108185350` — `prevent_mover_token_removal_during_pending_aoo` — sem arquivo local de mesmo nome
- `20261108185611` — `scale_aoo_attack_weapon_reach_by_creature_size` — sem arquivo local de mesmo nome
- `20261108185905` — `add_structured_natural_attack_statblock_parser` — sem arquivo local de mesmo nome
- `20261108185917` — `expose_gm_natural_attack_opportunity_catalog` — sem arquivo local de mesmo nome
- `20261108185945` — `classify_natural_attacks_and_parse_iterative_bonuses` — sem arquivo local de mesmo nome
- `20261108190003` — `grant_authenticated_execute_natural_attack_parser` — sem arquivo local de mesmo nome
- `20261108190028` — `make_natural_attack_parser_fail_closed_per_group` — sem arquivo local de mesmo nome
- `20261108190044` — `support_alternate_and_comma_separated_monster_attacks` — sem arquivo local de mesmo nome
- `20261108191914` — `add_selected_natural_attack_opportunity_overload` — sem arquivo local de mesmo nome
- `20261108192044` — `preserve_natural_attack_critical_metadata` — sem arquivo local de mesmo nome
- `20261108192059` — `clean_natural_attack_additional_effect_metadata` — sem arquivo local de mesmo nome
- `20261108192342` — `support_monster_combat_reflexes_for_aoo` — sem arquivo local de mesmo nome
- `20261108192451` — `enforce_nauseated_no_attack_for_aoo` — sem arquivo local de mesmo nome
- `20261108192512` — `fix_monster_flatfooted_combat_reflexes_reservation` — sem arquivo local de mesmo nome
- `20261108192806` — `resolve_blinded_aoo_concealment_miss_chance` — sem arquivo local de mesmo nome
- `20261108192836` — `harden_aoo_blind_concealment_state` — sem arquivo local de mesmo nome
- `20261108192911` — `allow_aoo_awaiting_miss_chance_status` — sem arquivo local de mesmo nome
- `20261108193015` — `wrap_aoo_concealment_rpc_as_invoker` — sem arquivo local de mesmo nome
- `20261108193056` — `wrap_aoo_reaction_reservation_as_invoker` — sem arquivo local de mesmo nome
- `20261108193106` — `wrap_aoo_ledger_reservation_as_invoker` — sem arquivo local de mesmo nome
- `20261108193147` — `support_cancelling_resumable_aoo_states` — sem arquivo local de mesmo nome
- `20261108193353` — `automate_confusion_turn_d100_requests` — sem arquivo local de mesmo nome
- `20261108193752` — `enforce_confusion_turn_action_restrictions` — sem arquivo local de mesmo nome
- `20261108193848` — `persist_confusion_turn_results_in_campaign_log_v2` — sem arquivo local de mesmo nome
- `20261108193919` — `enforce_confused_attack_of_opportunity_engagement` — sem arquivo local de mesmo nome
- `20261108194110` — `fix_trip_surprise_and_character_condition_guards` — sem arquivo local de mesmo nome
- `20261108194308` — `enforce_linked_npc_character_action_conditions` — sem arquivo local de mesmo nome
- `20261108194339` — `wrap_gm_action_economy_rpcs_as_invoker` — sem arquivo local de mesmo nome
- `20261108194436` — `enforce_linked_npc_character_movement_conditions` — sem arquivo local de mesmo nome
- `20261108194444` — `wrap_gm_token_movement_rpc_as_invoker` — sem arquivo local de mesmo nome
- `20261108194705` — `preserve_confusion_caster_and_validate_turn_outcomes` — sem arquivo local de mesmo nome
- `20261108194944` — `integrate_confusion_caster_targeting_and_attack_guards` — sem arquivo local de mesmo nome
- `20261108195055` — `enforce_confusion_attack_targets_and_flee_direction` — sem arquivo local de mesmo nome
- `20261108195149` — `finalize_confusion_targeting_and_flee_movement_guards` — sem arquivo local de mesmo nome
- `20261108195245` — `wrap_player_attack_and_movement_rpcs_as_invoker` — sem arquivo local de mesmo nome
- `20261108195317` — `align_confusion_turn_round_zero_handling` — sem arquivo local de mesmo nome
- `20261108195700` — `sync_character_weapon_item_toggle_with_instances` — sem arquivo local de mesmo nome
- `20261108195718` — `fix_weapon_instance_selection_in_equipment_toggle` — sem arquivo local de mesmo nome
- `20261108200544` — `fix_duplicate_strength_in_normal_attack_damage` — sem arquivo local de mesmo nome
- `20261108201619` — `support_player_targets_in_iterative_player_attacks` — sem arquivo local de mesmo nome
- `20261108201705` — `allow_player_targets_in_iterative_sequence_start` — sem arquivo local de mesmo nome
- `20261108201919` — `sync_player_token_hp_after_gm_npc_attack` — sem arquivo local de mesmo nome
- `20261108203649` — `enforce_critical_immunity_in_iterative_attacks` — sem arquivo local de mesmo nome
- `20261108203741` — `enforce_critical_immunity_in_npc_iterative_attacks` — sem arquivo local de mesmo nome
- `20261108203819` — `tighten_player_critical_immunity_detection` — sem arquivo local de mesmo nome
- `20261108203823` — `tighten_npc_critical_immunity_detection` — sem arquivo local de mesmo nome
- `20261108204532` — `include_target_race_in_dwarf_npc_attack_bonus` — sem arquivo local de mesmo nome
- `20261108204617` — `include_target_race_in_dwarf_player_attack_bonus` — sem arquivo local de mesmo nome
- `20261108204831` — `bound_dwarf_and_gnome_racial_attack_target_matching` — sem arquivo local de mesmo nome
- `20261108204919` — `fix_grouping_in_racial_attack_target_regex` — sem arquivo local de mesmo nome
- `20261108205051` — `correct_imported_srd_equipment_weight_units` — sem arquivo local de mesmo nome
- `20261108205342` — `calculate_linked_npc_armor_class_from_srd_sheet` — sem arquivo local de mesmo nome
- `20261108210212` — `use_live_srd_armor_class_for_linked_npc_attack_targets` — sem arquivo local de mesmo nome
- `20261108210259` — `use_srd_armor_class_for_linked_npc_attack_targets` — sem arquivo local de mesmo nome
- `20261108210336` — `apply_token_dexterity_effects_to_linked_npc_armor_class` — sem arquivo local de mesmo nome
- `20261108210913` — `allow_single_full_attack_below_iterative_bab` — sem arquivo local de mesmo nome
- `20261108210956` — `support_power_attack_in_npc_iterative_sequences` — sem arquivo local de mesmo nome
- `20261108211032` — `grant_authenticated_access_to_guarded_npc_power_attack_start` — sem arquivo local de mesmo nome
- `20261108211116` — `apply_melee_and_ranged_ac_modifiers_to_linked_npc_targets` — sem arquivo local de mesmo nome
- `20261108212057` — `manage_linked_npc_sheet_equipment_from_gm_inventory` — sem arquivo local de mesmo nome
- `20261108212201` — `harden_linked_npc_equipment_rpc_boundary` — sem arquivo local de mesmo nome
- `20261108212706` — `add_gm_scoped_linked_npc_inventory_read` — sem arquivo local de mesmo nome
- `20261108213242` — `include_linked_npc_sheet_attributes_in_inventory_rpc` — sem arquivo local de mesmo nome
- `20261108213451` — `recognize_rage_on_gm_linked_npc_skill_checks` — sem arquivo local de mesmo nome
- `20261108214246` — `recognize_portuguese_goblinoid_for_dwarf_attacks` — sem arquivo local de mesmo nome
- `20261108214304` — `prevent_duplicate_dwarf_giant_ac_bonus` — sem arquivo local de mesmo nome
- `20261108214419` — `enforce_barbarian_literacy_skill_point_cost_on_edits` — sem arquivo local de mesmo nome
- `20261108214426` — `calculate_linked_npc_armor_class_for_opportunity_attacks` — sem arquivo local de mesmo nome
- `20261108214751` — `apply_dwarf_attack_bonus_to_linked_orc_targets_in_aoo` — sem arquivo local de mesmo nome
- `20261108214901` — `secure_character_movement_speed_rpc_access` — sem arquivo local de mesmo nome
- `20261108214942` — `apply_dwarf_weapon_familiarity_and_goblinoid_bonus_to_aoo` — sem arquivo local de mesmo nome
- `20261108215040` — `recognize_portuguese_goblinoids_in_player_and_aoo_attacks` — sem arquivo local de mesmo nome
- `20261108215219` — `include_linked_target_race_in_player_attack_validation` — sem arquivo local de mesmo nome
- `20261108215251` — `include_linked_target_race_in_unarmed_aoo` — sem arquivo local de mesmo nome
- `20261108215842` — `apply_effective_ability_scores_to_maneuver_profiles` — sem arquivo local de mesmo nome
- `20261108220936` — `add_gm_npc_token_saving_throw_resolution` — sem arquivo local de mesmo nome
- `20261108220958` — `name_linked_npc_equipment_rpc_arguments` — sem arquivo local de mesmo nome
- `20261108234011` — `fix_human_barbarian_literacy_skill_budget` — sem arquivo local de mesmo nome
- `20261108235808` — `fix_levelup_class_level_tracking_and_rpc_security` — sem arquivo local de mesmo nome
- `20261109000332` — `secure_levelup_rpc_as_invoker` — sem arquivo local de mesmo nome
- `20261109000615` — `move_levelup_core_rpc_to_private_schema` — sem arquivo local de mesmo nome
- `20261109001024` — `add_normalized_weapon_proficiency_resolver` — sem arquivo local de mesmo nome
- `20261109001128` — `fix_weapon_proficiency_group_resolution` — sem arquivo local de mesmo nome
- `20261109002021` — `harden_definer_search_paths` — sem arquivo local de mesmo nome
- `20261109002501` — `harden_private_definer_search_paths` — sem arquivo local de mesmo nome
- `20261109002536` — `enforce_natural_one_twenty_saving_throws` — sem arquivo local de mesmo nome
- `20261109002612` — `enforce_natural_saving_rolls_for_spell_saves` — sem arquivo local de mesmo nome
- `20261109003318` — `fix_medium_hide_armor_evasion_block` — sem arquivo local de mesmo nome
- `20261109003601` — `validate_spell_resistance_target_identity` — sem arquivo local de mesmo nome
- `20261109003621` — `prevent_duplicate_spell_penetration_feat_stacking` — sem arquivo local de mesmo nome
- `20261109004427` — `fix_magic_missile_spell_resistance_flow` — sem arquivo local de mesmo nome
- `20261109004644` — `include_active_spell_penetration_modifiers` — sem arquivo local de mesmo nome
- `20261109004751` — `harden_linked_npc_saving_throw_resolution` — sem arquivo local de mesmo nome
- `20261109004814` — `deduplicate_saving_throw_feat_bonuses` — sem arquivo local de mesmo nome
- `20261109005637` — `enforce_pending_spell_save_pair` — sem arquivo local de mesmo nome
- `20261109005941` — `prevent_fatigue_condition_penalty_stacking` — sem arquivo local de mesmo nome

## Arquivos locais sem registro remoto na mesma versão

- `20261104043500` — `srd35_open_ended_craft_profession_skills` — versão(s) remota(s) com mesmo nome: 20261104043845
- `20261104050200` — `srd35_spell_save_secondary_damage_rules` — versão(s) remota(s) com mesmo nome: 20261104050319
- `20261104050300` — `srd35_multitarget_damage_duration_rolls` — versão(s) remota(s) com mesmo nome: 20261104050323
- `20261104051000` — `srd35_multitarget_class_spell_level` — versão(s) remota(s) com mesmo nome: 20261104051415
- `20261104051015` — `srd35_damage_multitarget_class_spell_level` — versão(s) remota(s) com mesmo nome: 20261104051419
- `20261104051030` — `srd35_grimoire_class_level_validation` — versão(s) remota(s) com mesmo nome: 20261104051422
- `20261104051600` — `srd35_single_target_mixed_damage_components` — versão(s) remota(s) com mesmo nome: 20261104051700
- `20261104051615` — `srd35_area_mixed_damage_components` — versão(s) remota(s) com mesmo nome: 20261104051704
- `20261104051630` — `srd35_flame_strike_engine_rule` — versão(s) remota(s) com mesmo nome: 20261104051707
- `20261104134500` — `srd35_trap_sense_dodge_bonus_conditions` — versão(s) remota(s) com mesmo nome: 20261104133625
- `20261104135000` — `srd35_barbarian_rage_skill_use_restrictions` — versão(s) remota(s) com mesmo nome: 20261104134036
- `20261104140500` — `srd35_monk_still_mind_enchantment_saves` — versão(s) remota(s) com mesmo nome: 20261104134414
- `20261104142000` — `srd35_paladin_lay_on_hands_harm_undead` — versão(s) remota(s) com mesmo nome: 20261104134939
- `20261104143000` — `srd35_damage_components_null_fallback` — versão(s) remota(s) com mesmo nome: 20261104135731
- `20261104143200` — `srd35_evasion_and_improved_evasion_reflex_saves` — versão(s) remota(s) com mesmo nome: 20261104135536
- `20261104143500` — `srd35_evasion_class_feature_status` — versão(s) remota(s) com mesmo nome: 20261104135833
- `20261104144000` — `srd35_rogue_trap_sense_ca_and_reflex` — versão(s) remota(s) com mesmo nome: 20261104140152
- `20261104144200` — `srd35_rogue_trap_sense_feature_status` — versão(s) remota(s) com mesmo nome: 20261104140222
- `20261104150000` — `srd35_sneak_attack_damage_validation` — versão(s) remota(s) com mesmo nome: 20261104143719, 20261104143907
- `20261104151000` — `srd35_sneak_attack_feature_catalog_partial` — versão(s) remota(s) com mesmo nome: 20261104144912
- `20261104152000` — `srd35_rogue_uncanny_dodge_catalog_status` — versão(s) remota(s) com mesmo nome: 20261104145447, 20261104145503
- `20261104153000` — `srd35_rogue_trapfinding_skill_gate` — versão(s) remota(s) com mesmo nome: 20261104150050
- `20261104153200` — `srd35_rogue_trapfinding_feature_status` — versão(s) remota(s) com mesmo nome: 20261104150143
- `20261104190000` — `dwarf_barbarian_n1_racial_movement_fixes` — sem nome remoto correspondente
- `20261104193000` — `barbarian_jump_skill_alias` — versão(s) remota(s) com mesmo nome: 20261104174603
- `20261104194500` — `dwarf_armor_load_classification` — sem nome remoto correspondente
- `20261104200000` — `barbarian_initial_skill_spend_aliases` — versão(s) remota(s) com mesmo nome: 20261104175617
- `20261104203000` — `barbarian_rage_duration_adjusted_constitution` — versão(s) remota(s) com mesmo nome: 20261104180113
- `20261104204500` — `remove_wrong_atletismo_class_skill_alias` — versão(s) remota(s) com mesmo nome: 20261104180521
- `20261104223000` — `srd35_dwarf_weapon_familiarity_server` — versão(s) remota(s) com mesmo nome: 20261104221937
- `20261105021400` — `allow_campaign_gm_to_equip_character_items` — versão(s) remota(s) com mesmo nome: 20261105013330
- `20261105021800` — `harden_gm_character_equipment_updates` — versão(s) remota(s) com mesmo nome: 20261105013434
- `20261105023000` — `allow_campaign_gm_character_hp_adjustment` — versão(s) remota(s) com mesmo nome: 20261105013547
- `20261105023500` — `harden_character_hp_adjustment` — versão(s) remota(s) com mesmo nome: 20261105013620
- `20261105030000` — `unified_ability_mechanics_catalog` — versão(s) remota(s) com mesmo nome: 20261105023710
- `20261105031500` — `allow_campaign_gm_to_use_barbarian_rage` — versão(s) remota(s) com mesmo nome: 20261105024654
- `20261105032000` — `stage_all_feat_and_monster_mechanics_for_review` — versão(s) remota(s) com mesmo nome: 20261105024851
- `20261105033000` — `expire_barbarian_rage_on_round_change` — versão(s) remota(s) com mesmo nome: 20261105025431
- `20261105040000` — `structure_improved_initiative_feat` — versão(s) remota(s) com mesmo nome: 20261105030332
- `20261105040100` — `fix_improved_initiative_translation_line_breaks` — versão(s) remota(s) com mesmo nome: 20261105030406
- `20261105041000` — `generic_passive_feat_modifiers` — versão(s) remota(s) com mesmo nome: 20261105030639

## Regras de interpretação

1. A versão (timestamp de 14 dígitos) é a chave usada para a comparação exata.
2. Nome igual com timestamp diferente não é considerado versão aplicada; é apenas um candidato a migração renomeada/recriada.
3. Nome igual não comprova conteúdo igual. Para cada candidato é necessário comparar o SQL e o efeito final no schema.
4. Arquivo local sem registro remoto não deve ser renomeado, apagado ou reaplicado sem comparar seus efeitos com o estado remoto.
5. O ledger remoto preserva o SQL executado em `statements[1]`; isso permite recuperar a instrução aplicada, mas não necessariamente comentários/formatação originais. Comparar semanticamente com os arquivos locais antes de sobrescrever diferenças.
6. Nenhum reset, deploy automático, squash ou reconstrução até a reconciliação ser aprovada.


## Caso comprovado de drift — movimento e economia de ações — 2026-11-09

Os arquivos locais `20261108134918_player_movement_action_economy.sql` e `20261108135111_block_movement_when_no_actions.sql` usam `pg_get_functiondef` e patch textual para alterar diretamente `public.mover_token_player_cba` e `public.mover_token_gm_cba_srd`. O SQL local procura declarações/blocos internos dessas funções públicas.

No schema remoto atual, ambas as funções públicas são wrappers SQL SECURITY INVOKER de poucas linhas, delegando a implementação para `priv.mover_token_player_cba_impl` e `priv.mover_token_gm_cba_srd_impl` (SECURITY DEFINER). As implementações atuais têm os controles de economia de ações e movimento, mas estão em outro schema/função.

O histórico remoto registra as migrations posteriores que efetuaram essa mudança:
- `20261108194444_wrap_gm_token_movement_rpc_as_invoker`
- `20261108195245_wrap_player_attack_and_movement_rpcs_as_invoker`
- `20261108214901_secure_character_movement_speed_rpc_access`

Nenhuma dessas três tem arquivo local de mesmo nome. Portanto, o conjunto local não representa a transformação de arquitetura remota. Os arquivos locais de economia de ações não devem ser reaplicados sobre o schema remoto atual: os pontos de patch textual já não existem nos wrappers. Isso é evidência concreta de que igualar apenas o número ou o nome das migrations não restaura a arquitetura. Não foi feita alteração no banco.


## Recorte crítico — movimento, manobras e AOO após recuperação

As 81 migrations remotas desse conjunto estão agora presentes em supabase/migrations e são byte a byte idênticas às entradas statements[1] do ledger. As 72 versões que faltavam foram recuperadas; as 8 variantes locais divergentes foram preservadas em docs/migration_reconciliation/local_variants/. Os arquivos locais de Anão/Bárbaro que não têm versão remota estão preservados em docs/migration_reconciliation/unapplied_local/ e não fazem parte do baseline aplicado.

**Consequência:** o baseline histórico de movimento/AOO está reconstruído e alinhado ao ledger remoto. Nenhuma migration foi aplicada no Supabase. A ordem de locks, os 13 desvios semânticos preservados e os testes de integração contra o schema completo continuam sendo etapas obrigatórias antes de qualquer nova migration ou deploy.



## Diferenças semânticas preservadas para revisão

Os 13 arquivos de versões aplicadas cujo conteúdo local diferia semanticamente do ledger foram alinhados em supabase/migrations ao SQL executado e suas variantes locais foram preservadas em docs/migration_reconciliation/local_variants/:

- 20261104044506 srd35_paladin_lay_on_hands_engine
- 20261104045534 srd35_fireball_partial_scope
- 20261104050119 srd35_area_damage_secondary_conditions
- 20261104050939 srd35_class_specific_spell_levels_and_caster_class_level
- 20261104051117 srd35_grimoire_jsonb_key_count_fix
- 20261104051135 srd35_grimoire_prepared_spell_school_select
- 20261104051204 srd35_grimoire_nonnegative_slot_capacity
- 20261104051555 srd35_flame_strike_split_damage_components
- 20261104123152 srd35_barbarian_rage_engine
- 20261104123351 srd35_barbarian_rage_class_level_fallback
- 20261104123425 srd35_barbarian_rage_legacy_class_lookup_fix
- 20261104132528 srd35_character_ac_uncanny_dodge_and_trap_sense
- 20261104212203 srd35_halfling_thrown_weapon_attack_bonus

Cinco variantes locais sem versão remota, mas com nome lógico correspondente a uma versão remota, também foram preservadas em quarentena: srd35_flame_strike_engine_rule, srd35_monk_still_mind_enchantment_saves, srd35_paladin_lay_on_hands_harm_undead, stage_all_feat_and_monster_mechanics_for_review e structure_improved_initiative_feat. Duas migrations locais exclusivas de Anão/Bárbaro foram preservadas na mesma quarentena: dwarf_barbarian_n1_racial_movement_fixes e dwarf_armor_load_classification. Essas variantes não foram descartadas nem aplicadas; se alguma for aprovada, deverá ser convertida em nova migration pelo Supabase CLI, com novo timestamp e testes.



## Bloqueio de replay integral identificado em CI (2026-11-10)

Foi criado um workflow de replay em stack Supabase descartável usando CLI 3.0.0, sem token, project ref, conexão ou credenciais de produção. O workflow copia os 966 arquivos versionados, inicia Postgres/Auth/Storage local e tenta aplicar todas as migrations do zero.

**Resultado observado no primeiro run:** falha na migration inicial 20261031160944_srd35_action_economy.sql, pois ela declara public.campaigns%ROWTYPE e o banco descartável ainda não possui a relação public.campaigns (SQLSTATE 42P01). A falha acontece antes de qualquer migration ser aplicada e não envolve o Supabase remoto.

A causa estrutural foi confirmada nos arquivos:
- A migration 20261031160944_srd35_action_economy.sql declara no cabeçalho que deve ser aplicada depois de cba_iniciativa_migration.sql, vtt_dnd35_final_migration.sql e srd35_spellcasting_migration.sql, arquivos legados no root do repositório.
- Esses scripts legados também pressupõem tabelas preexistentes (por exemplo, cba_iniciativa_migration.sql faz ALTER TABLE public.campaigns; vtt_dnd35_final_migration.sql substitui rotinas e depende de characters/campaigns). Nenhum dos 966 arquivos atuais cria public.campaigns como primeira etapa.
- Logo, os 966 SQL recuperados do ledger remoto constituem um histórico incremental pós-bootstrap, não uma instalação completa desde banco vazio. O schema-base inicial foi criado por processo anterior/manual ou fora do conjunto versionado e ainda não foi recuperado como baseline reproduzível.

**Decisão segura:** manter o workflow vermelho; não mascarar a falha, não marcar migrations como já aplicadas, não pular a primeira migration e não inventar uma tabela campaigns mínima. Próximo trabalho de reconciliação:
1. Recuperar um dump estrutural do schema-base real a partir de uma fonte confiável/backup do projeto (sem dados de usuários), incluindo tabelas, tipos, extensões, constraints, índices, funções/triggers de base e configurações necessárias.
2. Identificar e documentar exatamente quais scripts legados foram aplicados antes da primeira migration versionada, com ordem e hashes, sem reaplicar scripts cumulativos sobre o schema existente.
3. Construir um bootstrap versionado e idempotente em banco descartável; depois executar as 966 migrations em sequência e comparar objetos críticos com o catálogo remoto.
4. Só então usar o replay como gate para futuras mudanças. Não exportar nem versionar dados reais de campanhas, usuários, fichas ou tokens.

O workflow em .github/workflows/supabase-migration-replay.yml permanece intencionalmente sem credenciais ou referência ao projeto de produção. O primeiro run falhou na etapa de replay, após iniciar apenas o stack local descartável. Nenhuma escrita foi executada no Supabase remoto.


### Inspeção complementar do repositório — origem do bootstrap ainda ausente (2026-11-10)

A listagem da raiz e de `supabase/` foi revisada para localizar uma base SQL anterior aos 966 arquivos:

- A raiz contém scripts como `cba_iniciativa_migration.sql`, `vtt_dnd35_final_migration.sql`, `srd35_spellcasting_migration.sql`, `srd35_schema_reconciliation.sql` e `srd35_character_migration.sql`. A leitura dos cabeçalhos/corpos confirma que são incrementais: por exemplo, `cba_iniciativa_migration.sql` começa com `ALTER TABLE public.campaigns`; `srd35_schema_reconciliation.sql` começa alterando `public.srd_equipment`; `srd35_character_migration.sql` altera `public.srd_character_sheets`.
- `supabase/manual_sql_archive/` contém correções e reconciliações pontuais (policies, RPCs, Storage, combate), não uma criação inicial das tabelas-base.
- `supabase/migration_archive/` contém somente dois scripts de level-up, também incrementais.
- `supabase/verification/` contém fixtures/consultas de verificação, não bootstrap.
- A pasta `supabase/` não possui atualmente `config.toml`; o workflow inicializa um diretório temporário com `supabase init`, o que resolve configuração da CLI, mas não cria o schema histórico da aplicação.

**Conclusão refinada:** não há, no conjunto de arquivos versionados inspecionado, um SQL que crie a base original `public.campaigns`, `public.characters`, `public.members` e demais tabelas antes das migrações incrementais. A evidência aponta para bootstrap anterior/manual ou executado fora deste repositório. Não é seguro converter os scripts incrementais em bootstrap por tentativa, nem criar tabelas mínimas para satisfazer a primeira migration: isso produziria um schema fictício e poderia ocultar dependências/constraints ausentes.

**Próxima ação técnica sem tocar produção:** recuperar uma definição estrutural confiável do schema-base (backup/schema-only dump, histórico SQL do projeto ou export do catálogo atual com trilha de proveniência); comparar com o catálogo remoto e separar objetos pré-migration dos criados pelas 966 migrations. Um `pg_dump --schema-only` do estado atual é evidência útil para comparação, mas sozinho não prova qual era o schema antes da primeira migration. Depois, reconstruir o bootstrap histórico em branch/stack descartável e executar replay integral + comparação de catálogo.



## Delta posterior à reconciliação — 2026-11-10

A reconciliação histórica de 966 versões permanece válida para o conjunto já aplicado no projeto. Depois dela, três migrations de endurecimento foram adicionadas à branch e ainda não existem no ledger remoto:

- `20261110150000_fix_invoker_maneuver_catalog_helper_permissions.sql`
- `20261110160000_revoke_public_feat_saving_throw_helper.sql`
- `20261110170000_lock_down_internal_helper_execute.sql`

Estado verificado por consulta read-only:

- Branch: 969 arquivos SQL em `supabase/migrations`.
- Supabase remoto: 966 versões distintas, da `20261031160944` à `20261109005941`.
- Delta: exatamente as três migrations acima, ainda pendentes.
- Nenhuma dessas migrations foi aplicada no projeto remoto.

O workflow de replay foi corrigido para derivar a contagem esperada dos arquivos presentes, em vez de manter o número histórico 966 fixo. A execução no commit anterior falhou antes de iniciar o stack porque a contagem havia ficado desatualizada. Uma tentativa anterior de replay em banco vazio também confirmou que a primeira migration pressupõe `public.campaigns` já existente. O repositório ainda não contém um bootstrap confiável desse schema.

**Regra:** não inventar schema mínimo nem executar as três migrations no remoto. O replay integral só pode ser considerado válido depois de recuperar um bootstrap/schema-only dump com proveniência e reproduzir o estado completo em PostgreSQL descartável.


## Caminho de desbloqueio para testar migrations novas sem fingir replay histórico (2026-11-11)

Há dois objetivos distintos e eles não devem ser confundidos:

1. **Testar as migrations candidatas contra o estado remoto atual:** gerar um snapshot schema-only do banco atual com `supabase db dump` (script local `scripts/export-current-schema.ps1`), restaurá-lo em um stack Supabase descartável e marcar no banco local as 966 versões remotas como já aplicadas. Então aplicar somente as três migrations pendentes e executar fixtures/invariantes. Isso valida o delta novo sobre a estrutura atual, mas não valida a história desde zero.
2. **Provar replay integral desde a primeira migration:** ainda exige recuperar o schema-base pré-ledger com proveniência. O snapshot atual sozinho não pode ser usado como bootstrap e depois reaplicar as 966 migrations, pois ele já contém o resultado delas.

O caminho 1 é o desbloqueio pragmático imediato e não requer plano Supabase pago; exige que o usuário execute o script no PC com CLI linkada e Docker Desktop e disponibilize o arquivo schema-only para preparar o ambiente descartável. O arquivo não deve ser enviado ao repositório público nem contém dados/Auth/Storage. O caminho 2 permanece como trabalho de recuperação histórica. Nenhuma alteração remota.
