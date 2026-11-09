# Reconciliação focal — AOO e interrupção de movimento — 2026-11-09

## Escopo

Histórico remoto de migrations com nomes contendo `aoo`, `oportunidade` ou `pending_movement`, comparado com os nomes dos arquivos SQL em `supabase/migrations/` no branch main.

## Resultado

- Migrations remotas encontradas no escopo: 51.
- Migrations cujo nome não existe em arquivo local: 51.
- Funções atuais no subsistema: 37 (exportadas integralmente em [REMOTE_AOO_FUNCTIONS.sql.md](REMOTE_AOO_FUNCTIONS.sql.md)).
- A comparação por nome é apenas um indicador de lacuna documental; não prova que uma migration tenha ou não efeito equivalente por outro nome.

## Histórico remoto do subsistema

| Versão | Nome | Arquivo local com mesmo nome |
|---|---|---|
| `20261108160529` | `maneuver_aoo_and_improved_feat_classification` | **não** |
| `20261108161435` | `srd_aoo_reaction_ledger_and_reservation` | **não** |
| `20261108163620` | `srd_pending_movement_aoo_interruption` | **não** |
| `20261108163708` | `srd_pending_movement_aoo_reaction_reservation` | **não** |
| `20261108163758` | `derive_aoo_footprints_from_linked_character_races` | **não** |
| `20261108164305` | `srd_aoo_damage_and_pending_movement_finalization` | **não** |
| `20261108164328` | `harden_aoo_roll_idempotency` | **não** |
| `20261108164412` | `srd_aoo_gm_queue_and_weapon_inspection` | **não** |
| `20261108164441` | `refine_aoo_weapon_reach_and_dwarf_defense` | **não** |
| `20261108164658` | `allow_gm_finalize_player_aoo_movement` | **não** |
| `20261108165025` | `srd_aoo_unlinked_monster_natural_attacks` | **não** |
| `20261108165246` | `srd_aoo_linked_character_unarmed_strikes` | **não** |
| `20261108165307` | `avoid_duplicate_dynamic_bonus_on_unarmed_aoo` | **não** |
| `20261108165650` | `srd_aoo_5_10_5_footprint_distance` | **não** |
| `20261108165806` | `srd_aoo_reach_validation_uses_token_footprints` | **não** |
| `20261108170021` | `srd_aoo_pending_movement_lifecycle_guards` | **não** |
| `20261108170548` | `srd_aoo_distinguish_flatfooted_from_dex_loss` | **não** |
| `20261108170655` | `srd_aoo_reactor_conditions_and_flatfooted_feedback` | **não** |
| `20261108171828` | `separate_surprise_and_normal_aoo_reaction_ledgers` | **não** |
| `20261108172218` | `index_aoo_attacks_campaign_fk` | **não** |
| `20261108173533` | `maneuver_trip_weapon_aoo_context` | **não** |
| `20261108174844` | `integrate_trip_maneuver_aoo_reactions` | **não** |
| `20261108174944` | `harden_trip_aoo_resolution_wrapper` | **não** |
| `20261108174958` | `validate_trip_aoo_reach_against_selected_weapon` | **não** |
| `20261108175022` | `move_trip_aoo_definers_to_private_schema` | **não** |
| `20261108175045` | `derive_trip_aoo_reach_from_equipped_weapon` | **não** |
| `20261108175504` | `srd_stand_up_with_aoo_reactions` | **não** |
| `20261108175759` | `validate_stand_up_move_action_before_aoo` | **não** |
| `20261108182845` | `handle_flat_footed_aoo_reactor_without_combat_reflexes` | **não** |
| `20261108184220` | `validate_trip_aoo_weapon_threatened_squares` | **não** |
| `20261108184327` | `enforce_weapon_threatened_range_for_aoo` | **não** |
| `20261108184716` | `require_improved_unarmed_strike_for_unarmed_aoo` | **não** |
| `20261108184746` | `filter_non_threatening_weapons_from_aoo_picker` | **não** |
| `20261108185137` | `derive_movement_aoo_from_equipped_and_natural_threat_ranges` | **não** |
| `20261108185259` | `scale_trip_aoo_reach_by_creature_size` | **não** |
| `20261108185301` | `harden_aoo_movement_finalization_terminal_ledger` | **não** |
| `20261108185350` | `prevent_mover_token_removal_during_pending_aoo` | **não** |
| `20261108185611` | `scale_aoo_attack_weapon_reach_by_creature_size` | **não** |
| `20261108192342` | `support_monster_combat_reflexes_for_aoo` | **não** |
| `20261108192451` | `enforce_nauseated_no_attack_for_aoo` | **não** |
| `20261108192806` | `resolve_blinded_aoo_concealment_miss_chance` | **não** |
| `20261108192836` | `harden_aoo_blind_concealment_state` | **não** |
| `20261108192911` | `allow_aoo_awaiting_miss_chance_status` | **não** |
| `20261108193015` | `wrap_aoo_concealment_rpc_as_invoker` | **não** |
| `20261108193056` | `wrap_aoo_reaction_reservation_as_invoker` | **não** |
| `20261108193106` | `wrap_aoo_ledger_reservation_as_invoker` | **não** |
| `20261108193147` | `support_cancelling_resumable_aoo_states` | **não** |
| `20261108214751` | `apply_dwarf_attack_bonus_to_linked_orc_targets_in_aoo` | **não** |
| `20261108214942` | `apply_dwarf_weapon_familiarity_and_goblinoid_bonus_to_aoo` | **não** |
| `20261108215040` | `recognize_portuguese_goblinoids_in_player_and_aoo_attacks` | **não** |
| `20261108215251` | `include_linked_target_race_in_unarmed_aoo` | **não** |

## Funções e fronteira de execução atuais

| Assinatura | SECURITY DEFINER | anon EXECUTE | authenticated EXECUTE | MD5 |
|---|---:|---:|---:|---|
| `priv.srd_aoo_require_blind_concealment_roll()` | sim | não | não | `1669bd6e269520fa5e2dcb7499b4057e` |
| `priv.srd_cancelar_movimento_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid)` | sim | não | sim | `ee1753fd8f8ad3e6c968942f42816125` |
| `priv.srd_confusion_aoo_engaged(p_campaign_id bigint, p_actor_token_id text, p_actor_character_id text, p_mover_token_id text)` | sim | não | não | `94e8a45d2e8ca3745420a1f12f937f8c` |
| `priv.srd_encerrar_reacao_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean)` | sim | não | sim | `5cae44f8906a5b12952720e39d76f6cb` |
| `priv.srd_guard_aoo_cannot_attack()` | sim | não | não | `0ff70ee88e3cc734581db3df022f0409` |
| `priv.srd_guard_pending_aoo_movement()` | sim | não | não | `9a9a41aa24a8ee42393daaa1ecc1ec37` |
| `priv.srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)` | sim | não | sim | `2ab33685b041ef930b6ae7e2b48e3991` |
| `priv.srd_registrar_ocultacao_ataque_oportunidade_impl(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)` | sim | não | sim | `43cb67bd4552bd98181d8d367850ff90` |
| `priv.srd_reservar_ataque_oportunidade_impl(p_campaign_id bigint, p_actor_token_id text, p_trigger_key text, p_actor_flat_footed boolean)` | sim | não | sim | `4c9a7d64f8d098ae43a7bfc42beffce4` |
| `priv.srd_reservar_reacao_movimento_aoo_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)` | sim | não | sim | `3775a7763a3ed392bacb2250504a9a24` |
| `priv.srd_resolver_derrubar_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean)` | sim | não | sim | `5bf3be6185cbd49939f07ff35c540afc` |
| `priv.srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid)` | sim | não | sim | `fa34c68e20bb6b03fb13b1d11c09c523` |
| `priv.srd_validate_aoo_pending_movement_preview()` | sim | não | não | `aca15b8ef5fd809cbd20b69adf8f01be` |
| `public.srd_aplicar_dano_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)` | sim | não | sim | `e2673e828af60a967204f327bd6e3f28` |
| `public.srd_aplicar_dano_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)` | sim | não | sim | `7a2e372249a04ccb3230aaec95ed89ef` |
| `public.srd_cancelar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)` | não | não | sim | `2a9aa9d725069c8b19f7afab96f3b17a` |
| `public.srd_confirmar_critico_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_confirmation_d20 integer)` | sim | não | sim | `84f2806567a32d263acaa9a820b1696c` |
| `public.srd_consultar_armas_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)` | sim | não | sim | `c7270f541fe8293592d933cf9ed753a3` |
| `public.srd_consultar_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)` | sim | não | sim | `f1ddcca1cda00b5b060045fab96d21f5` |
| `public.srd_consultar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)` | sim | não | sim | `b3e6ea933e228678ee6dd6f1aca089e5` |
| `public.srd_encerrar_reacao_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean)` | não | não | sim | `0c1cd6771a68caf6d49e69af7dd45978` |
| `public.srd_finalizar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)` | sim | não | sim | `17fb9a9259675bf9d1c2278135ff2394` |
| `public.srd_iniciar_ataque_oportunidade_desarmado_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)` | sim | não | sim | `b891864a3d8c80653feeafb54d9a4dfe` |
| `public.srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)` | sim | não | sim | `44c3145a7e5dc696e5e5643fb0a6b1ce` |
| `public.srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_natural_attack_index integer)` | sim | não | sim | `b12188da9c009734f31a553849756ccf` |
| `public.srd_iniciar_ataque_oportunidade_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)` | sim | não | sim | `a641aab6e59793b2bf5b09cc290746db` |
| `public.srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)` | não | não | sim | `bfced6e0a1cec2ec606ff65dc64e9a2c` |
| `public.srd_listar_ataques_naturais_oportunidade_srd(p_campaign_id bigint, p_reactor_token_id text)` | não | não | sim | `f9399cd730c4cfea4c66706207d2ffea` |
| `public.srd_listar_movimentos_aoo_pendentes_srd(p_campaign_id bigint)` | sim | não | sim | `5ab451a12deb204eea23de23bca1d8cf` |
| `public.srd_registrar_ocultacao_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)` | não | não | sim | `a2b55e84b7c44ed4b1b703254c4cc229` |
| `public.srd_registrar_rolagem_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d20 integer, p_idempotency_key uuid)` | sim | não | sim | `950703066647366f6336bffb82e7f7d4` |
| `public.srd_reservar_ataque_oportunidade_srd(p_campaign_id bigint, p_actor_token_id text, p_trigger_key text, p_actor_flat_footed boolean)` | não | não | sim | `55f3d2fded1997d551aea8f163409603` |
| `public.srd_reservar_reacao_movimento_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)` | não | não | sim | `c72562f95bbe3da5134f29a383011e77` |
| `public.srd_resolver_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)` | sim | não | sim | `80a04e98b926307fe74bcbc34c963e7f` |
| `public.srd_resolver_derrubar_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean)` | não | não | sim | `14034f46a624a140d274163c2da73e37` |
| `public.srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid)` | não | não | sim | `a43d163405b49ee3ca459241c0177a43` |
| `public.srd_solicitar_movimento_com_aoo_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer, p_controller text)` | sim | não | sim | `38c1ffad22be8fe01381770a2bdb06b3` |

## Conclusões estáticas e riscos conhecidos

1. Nenhuma função do subsistema consultado concede EXECUTE a anon; authenticated possui EXECUTE nos wrappers públicos e nos helpers internos explicitamente usados por wrappers INVOKER.
2. Os wrappers INVOKER reduzem a superfície de execução privilegiada, mas dependem de grants em helpers internos; não revogar em lote sem rastrear dependências.
3. A ordem de locks apresenta inversão confirmada em dois caminhos: cancelamento bloqueia primeiro `srd_aoo_pending_movements` e depois atualiza `srd_aoo_attacks`; resolução/aplicação de dano bloqueia primeiro `srd_aoo_attacks`, depois `srd_aoo_pending_movements`. Deadlock é possível sob concorrência, ainda não reproduzido.
4. A correção não deve ser feita apenas por mudança textual. Definir ordem global e determinística para locks de ataque, movimento pendente e campanha, então reproduzir cancelamento × resolução/dano em ambiente descartável.
5. A migração remota sem arquivo local precisa ser recuperada por Git history/artefatos de origem ou reconstruída com base nas definições atuais e efeitos observáveis; não criar migrations vazias para igualar histórico.

## Próxima etapa

- Exportar e comparar funções de movimento normal, ataque iterativo, economia de ações e turnos.
- Formalizar matriz de lock order de todas as RPCs que alteram combate.
- Criar teste concorrente de deadlock em banco descartável após baseline reproduzível.


## Ampliação da análise de deadlock — fechamento de reação — 2026-11-09

A revisão do corpo atual de `priv.srd_encerrar_reacao_aoo_pendente_impl` confirmou uma segunda rota com inversão de locks: quando `p_cancel_attack=true`, ela bloqueia primeiro `priv.srd_aoo_pending_movements` (`FOR UPDATE`) e depois `priv.srd_aoo_attacks` (`FOR UPDATE`). Já `priv.srd_registrar_ocultacao_ataque_oportunidade_impl`, `public.srd_resolver_ataque_oportunidade_srd` e as RPCs de aplicar dano bloqueiam primeiro a linha de ataque e depois o movimento pendente. Portanto, o deadlock potencial não se limita ao cancelamento total do movimento: o cancelamento explícito de uma reação/ataque também pode disputar com ocultação, resolução ou dano.

**Ordem observada nas rotas principais:**
- Cancelar movimento: pending → UPDATE attacks → UPDATE pending.
- Encerrar reação com cancelamento de ataque: pending → attack → UPDATE attack → UPDATE pending.
- Resolver ataque: attack → pending → campaign.
- Resolver ocultação: attack → pending → campaign → atualiza attack/pending.
- Aplicar dano: attack → pending → campaign → ficha de personagem quando alvo player.
- Iniciar ataque/reservar reação: pending → campaign → ledger/arma (conforme caminho).
- Finalizar movimento: pending → campaign.

**Classificação:** risco de deadlock por inversão de ordem de locks sustentado pela leitura dos corpos atuais; ainda não reproduzido. Correção proposta: padronizar uma ordem global, por exemplo campaign → pending → attack → ficha/ledger, e garantir que todas as rotas adquiram locks nessa ordem. A ordem final deve considerar locks transitivos de helpers e não deve ser aplicada até teste concorrente em ambiente descartável.


## Achado P1 — movimento pode contornar o pré-check de AOO — 2026-11-09

**Evidência estática confirmada no estado remoto:**
1. `mesa.html` chama `srd_solicitar_movimento_com_aoo_srd` antes de mover o token. Se o RPC retorna `pending=false`, o frontend continua e chama `mover_token_player_cba` (jogador) ou `mover_token_gm_cba_srd` (Mestre).
2. `public.mover_token_player_cba` é um wrapper SECURITY INVOKER com EXECUTE para authenticated e chama `priv.mover_token_player_cba_impl`.
3. A implementação privada valida autenticação, propriedade, campanha, turno, ação, deslocamento, ocupação e condições, mas **não chama** `srd_detectar_saida_alcance_ameacado_srd` nem o fluxo AOO.
4. `public.mover_token_gm_cba_srd` também é wrapper INVOKER autenticado; a implementação GM valida papel/turno/deslocamento, mas não integra o detector AOO.
5. O trigger `trg_srd_guard_pending_aoo_movement` só bloqueia alteração/removal do token que já tenha um movimento pendente ativo; ele não detecta uma ameaça nova nem protege o caminho sem pending.

**Impacto:** um cliente autenticado pode chamar diretamente `mover_token_player_cba` e mover seu personagem durante o combate sem executar o pré-check AOO. Também existe uma janela TOCTOU entre o RPC de pré-checagem (que bloqueia a campanha apenas durante sua transação) e o RPC que persiste o movimento: outra alteração de token pode ocorrer entre ambos, invalidando a detecção original. O movimento ainda respeita outras validações de servidor, mas o AOO pode ser ignorado.

**Classificação:** P1 — integridade das regras/autoridade do servidor. Confirmado por leitura de frontend, ACL, wrapper, implementação e trigger; não foi executado um exploit nem alterado estado de jogo.

**Correção arquitetural recomendada:** tornar o RPC de persistência de movimento a autoridade única: dentro da mesma transação/lock de campanha, validar identidade/turno/ação, recalcular ameaças, criar o registro pending e retornar sem mover quando houver AOO; somente mover e consumir deslocamento quando não houver ameaça. Adaptar o frontend para um único resultado (`pending` ou `moved`) e retirar a confiança no pré-check separado. Aplicar ao caminho de jogador e, após confirmar a política de autoridade do Mestre, ao caminho GM. Não aplicar patch isolado sem fixture e teste de regressão.


### Extensão do bypass — fila pending pode ser contornada por outro token
Consulta direta aos corpos de `priv.mover_token_player_cba_impl` e `priv.mover_token_gm_cba_srd_impl` confirmou que ambos não referenciam `priv.srd_aoo_pending_movements`, não chamam o detector AOO e não chamam o pré-check. O trigger `priv.srd_guard_pending_aoo_movement` busca um pending ativo, mas só impede alteração/removal do token que é o próprio `mover_token_id`; ele não bloqueia alterações de outros tokens. Assim, uma chamada direta ao RPC de movimento de outro token pode contornar também a serialização global que `srd_solicitar_movimento_com_aoo_srd` tenta impor (a função de pré-check rejeita qualquer pending ativo). Isso pode alterar a posição de ameaças enquanto uma reação está sendo resolvida.

**Impacto adicional:** quebra da invariável “uma única movimentação pendente por campanha” e mutação da cena durante a resolução AOO, além do bypass do detector e da janela TOCTOU. Mantida classificação P1.


## Contrato proposto para corrigir a autoridade do movimento — 2026-11-09

Leitura do corpo completo de `public.srd_solicitar_movimento_com_aoo_srd` acrescentou duas condições importantes ao desenho da correção:

1. O helper bloqueia outra pendência ativa **somente depois** de detectar uma nova ameaça. Se o destino não gerar AOO, ele retorna `pending=false` antes de consultar `priv.srd_aoo_pending_movements`. Portanto, chamar apenas esse helper dentro do RPC de movimento não basta para garantir a invariável global de uma única movimentação pendente.
2. O trigger `priv.srd_validate_aoo_pending_movement_preview` define o GUC transacional `app.srd_aoo_pending_commit` com o ID da pendência e chama o RPC de movimento para validar o preview, forçando rollback por exceção sentinela. A integração no RPC de movimento precisa preservar esse caminho de validação; não pode tratar o próprio preview como uma nova solicitação AOO.

### Invariantes obrigatórias do futuro RPC de persistência

- Adquirir o lock da campanha antes de ler estado de combate, tokens, pending e ameaças.
- Validar identidade, papel, controle do token, turno, ação, destino, deslocamento, ocupação e condições no servidor.
- Se existir pending ativo da campanha, rejeitar movimento de qualquer outro token, mesmo quando o trajeto desse token não provocaria AOO.
- Para movimento normal sem pending, recalcular ameaças e criar a pending na mesma transação do RPC que recebeu a solicitação; se houver ameaça, retornar pending sem mover nem consumir deslocamento.
- Se não houver ameaça e não houver pending global, persistir movimento e consumo de deslocamento na mesma transação.
- O commit de uma pending deve ser uma exceção estreita e verificável: aceitar apenas o ID de pending fornecido pelo fluxo interno, confirmar campanha, token, destino, status e controlador, e não abrir uma rota para o cliente ignorar o bloqueio.
- O fluxo de preview do trigger deve continuar sem mutação persistida e sem criar uma segunda pending.
- Aplicar a mesma autoridade aos caminhos de jogador e Mestre, mantendo as diferenças de autorização já existentes.

**Não aplicado.** Este é o contrato de implementação e teste, não uma instrução para alterar produção isoladamente. A ordem de locks transitiva e o caminho de preview precisam ser preservados na implementação.


## Achado P1 adicional — publicação genérica da cena contorna validações de movimento — 2026-11-09

A leitura do corpo remoto de `public.salvar_cena_cba(p_campaign_id,p_scene)` identificou um caminho independente do RPC de movimento:

- A função é `SECURITY DEFINER`, exige apenas autenticação e papel GM na campanha, bloqueia a linha da campanha com `FOR UPDATE` e substitui `campaigns.cba_data` pela cena recebida.
- Para tokens, combina os tokens enviados com os atuais por `key`/`id`, mas usa integralmente o objeto enviado para cada token existente.
- Não verifica se `gridX`/`gridY` de tokens existentes mudaram; não aplica deslocamento, turno, ação, ocupação, tamanho de footprint, pending AOO ou detector de ameaças.
- Também não valida sobreposição/ocupação de tokens recém-inseridos na lista enviada.
- O frontend chama esse RPC durante combate em fluxos legítimos, como adicionar NPC/arquetipo, persistir modificadores de iniciativa e completar dados de criaturas. Portanto, simplesmente bloquear a RPC durante combate quebraria operações válidas.

**Impacto:** um Mestre autenticado pode chamar diretamente `salvar_cena_cba` e reposicionar qualquer token da campanha durante combate sem passar pelo motor de movimento, inclusive enquanto outra movimentação AOO está pendente. O endpoint também pode inserir token sobreposto. A autoridade do Mestre não substitui os contratos do motor: a movimentação ainda precisa ser validada pelo servidor.

### Direção de correção

1. Separar publicação de metadados de cena (fundo, escala, grade, opacidade) de mutações de tokens.
2. No endpoint genérico legado, preservar coordenadas dos tokens existentes quando a campanha estiver em combate; rejeitar qualquer mudança de posição fora dos RPCs de movimento autorizados.
3. Criar/usar operações específicas para inserir/remover token e atualizar metadados de ficha, com validação de identidade, unicidade, footprint e ocupação.
4. Para inserção durante combate, permitir spawn apenas em célula livre validada no servidor, sem usar a operação como teleporte de token existente.
5. Manter a fila global AOO: nenhuma escrita genérica pode mudar posição de ameaça ou do token movido enquanto existir pending ativo.
6. Manter compatibilidade dos fluxos legítimos atuais do frontend, migrando cada chamada antes de restringir o endpoint legado.

**Estado:** confirmado por leitura do corpo SQL remoto e dos call sites em `mesa.html`; ainda não testado por chamada autenticada direta. Não corrigido.


### Impact adicional — escrita de cena obsoleta pode sobrescrever estado concorrente

O endpoint recebe um snapshot completo do cliente e, para cada token cujo `id`/`key` aparece no payload, prefere integralmente o objeto enviado ao objeto atual. O lock `FOR UPDATE` serializa as transações, mas **não impede lost update**: uma cena carregada antes de uma ação pode ser salva depois dela com valores antigos.

Exemplo de sequência possível:
1. Cliente GM mantém snapshot com posição/PV antigos.
2. Um RPC de combate persiste movimento ou dano e atualiza `campaigns.cba_data`.
3. O cliente GM salva uma alteração não relacionada (por exemplo, metadados de iniciativa ou inclusão de NPC) usando o snapshot antigo.
4. `salvar_cena_cba` substitui novamente os objetos dos tokens e pode restaurar coordenadas/PV anteriores.

A fila `cbaWriteQueue` serializa somente as chamadas feitas por esse cliente; não sincroniza com RPCs de combate, outros clientes ou alterações diretas no servidor.

**Correção estrutural necessária:** evitar substituição integral de tokens. Usar RPCs específicas por intenção/colunas, ou controle de versão otimista por cena/token com merge server-side de campos permitidos. A operação de publicação de metadados não deve poder regravar estado autoritativo de combate. Não aplicar apenas um timestamp gerado no cliente como proteção; a versão deve ser lida e incrementada no servidor.


### Call-site inventory do writer genérico

Os usos em `mesa.html` foram localizados nas linhas atuais 2294, 3626, 4974, 5116, 5431, 5468, 6154 e 6633. As intenções são, respectivamente: retrato, spellState, spawn de NPC, bônus de iniciativa de reforço, fallback fora de combate, publicação de mapa/grade, preparação da iniciativa e enriquecimento de dados de monstro. A linha 5325 contém a chamada central a `sb.rpc('salvar_cena_cba',...)`.

A separação de comandos deve manter esses fluxos funcionando, mas nenhum deles pode reescrever coordenadas/PV/equipamentos de tokens por snapshot obsoleto. O spawn deve passar por validação server-side de célula livre; mapa/grade deve atualizar somente metadados; movimento deve passar pelos RPCs de movimento.


### Call-site inventory do writer genérico

Os usos em `mesa.html` foram localizados nas linhas atuais 2294, 3626, 4974, 5116, 5431, 5468, 6154 e 6633. As intenções são, respectivamente: retrato, spellState, spawn de NPC, bônus de iniciativa de reforço, fallback fora de combate, publicação de mapa/grade, preparação da iniciativa e enriquecimento de dados de monstro. A linha 5325 contém a chamada central a `sb.rpc('salvar_cena_cba',...)`.

A separação de comandos deve manter esses fluxos funcionando, mas nenhum deles pode reescrever coordenadas/PV/equipamentos de tokens por snapshot obsoleto. O spawn deve passar por validação server-side de célula livre; mapa/grade deve atualizar somente metadados; movimento deve passar pelos RPCs de movimento.


### Controles existentes confirmados e limite do trigger

- O índice único parcial `srd_aoo_one_pending_movement_per_campaign` garante no banco no máximo uma linha com status `waiting_reactions` ou `ready_to_commit` por campanha. A invariável de unicidade da fila já tem proteção estrutural.
- O trigger `trg_srd_guard_pending_aoo_movement` em `public.campaigns` compara apenas o token indicado em `pending.mover_token_id`: impede remover esse token ou alterar suas coordenadas sem o GUC do commit autorizado.
- O trigger **não** bloqueia mudança de coordenadas de outros tokens, mesmo enquanto há pending ativo, nem valida snapshot genérico, footprint, ocupação ou estado/PV de tokens. Assim, não fecha o bypass por `salvar_cena_cba` nem a alteração de ameaças durante a reação.
- O GUC `app.srd_aoo_pending_commit` é comparado ao pending ID para liberar o token movido. O futuro contrato deve validar também campanha, token, destino e status do pending no caminho interno de commit, sem confiar apenas em um valor de sessão fornecido pelo cliente.

A evidência confirma que o banco já impede duplicidade de pendências, mas ainda não garante imutabilidade da cena relevante durante a resolução.


## Achado adicional — spawn de token não respeita pending global nem footprint — 2026-11-09

A revisão de `public.adicionar_token_cba` e wrapper `public.adicionar_token_cba_completo` encontrou outro caminho de mutação:

- `adicionar_token_cba` exige GM, identidade, campanha e célula de origem; bloqueia IDs/keys duplicados e tenta encontrar uma célula livre.
- A função não consulta `priv.srd_aoo_pending_movements`; portanto, não bloqueia spawn enquanto uma reação AOO está pendente.
- A busca de célula livre compara somente `gridX` e `gridY` dos tokens existentes. Não consulta `priv.srd_token_grid_footprint` nem verifica todos os quadrados ocupados por tokens Grandes/Enormes/Imensos/Colossais.
- `adicionar_token_cba_completo` delega para essa função e depois acrescenta atributos; mantém o mesmo limite de validação espacial.
- `salvar_cena_cba` é ainda mais amplo: pode inserir novos tokens sem passar pela validação acima.

**Impacto:** spawn durante uma pending pode alterar a cena e a geometria/ameaças enquanto as reações estão sendo resolvidas. Fora de pending, um token com footprint maior que 1 pode ser colocado sobre outro token se os pontos de origem forem diferentes, mas as áreas ocupadas se cruzarem.

**Classificação:** P1 para mutação durante pending; P2 para sobreposição por footprint incompleto. Correção: bloquear spawn/removal/alterações estruturais enquanto pending ativa (salvo fluxo explicitamente autorizado) e centralizar validação de ocupação em helper canônico que considera footprint completo. Não corrigido.


### Outras mutações durante pending que precisam de política explícita

A revisão de mutações correlatas encontrou:
- `public.srd_configurar_perfil_combate_token_srd` atualiza facção e alcance corpo a corpo de token sem consultar pending AOO.
- `public.alterar_pv_token_cba` altera PV de NPC/monstro sem consultar pending.
- `public.adicionar_combatente_iniciativa` pode inserir/atualizar combatente em `combat_data` durante combate sem consultar pending; preserva o ator atual, mas altera a ordem da iniciativa.
- `public.adicionar_token_cba` e o wrapper completo podem inserir token sem bloquear pending.

Nem toda alteração de PV/metadado precisa ser proibida em qualquer cenário, mas mudanças de geometria, facção, alcance, spawn e iniciativa durante uma reação devem ser congeladas ou explicitamente autorizadas pelo Mestre com evento auditável. A política deve distinguir as mutações necessárias para resolver o próprio AOO (ataque/dano) das mutações externas concorrentes.


## Matriz de locks AOO — confirmação por definições atuais — 2026-11-09

A comparação das definições remotas completas confirmou uma inversão concreta de locks:

| RPC/implementação | Ordem observada |
|---|---|
| `priv.srd_cancelar_movimento_aoo_pendente_impl` | pending `FOR UPDATE` → atualiza ataques associados → atualiza pending |
| `priv.srd_encerrar_reacao_aoo_pendente_impl` | pending `FOR UPDATE` → attack `FOR UPDATE` → atualiza attack/pending |
| `public.srd_resolver_ataque_oportunidade_srd` | attack `FOR UPDATE` → pending `FOR UPDATE` → campaign `FOR UPDATE` |
| `public.srd_aplicar_dano_ataque_oportunidade_srd` | attack `FOR UPDATE` → pending `FOR UPDATE` → campaign `FOR UPDATE` |
| `public.srd_aplicar_dano_ataque_oportunidade_monstro_srd` | attack `FOR UPDATE` → pending `FOR UPDATE` → campaign `FOR UPDATE` |
| `public.srd_finalizar_movimento_aoo_pendente_srd` | pending `FOR UPDATE` → campaign `FOR UPDATE` |
| `priv.srd_reservar_reacao_movimento_aoo_impl` | pending `FOR UPDATE` → campaign `FOR UPDATE` |
| `public.srd_iniciar_ataque_oportunidade_srd` | pending `FOR UPDATE` → campaign `FOR UPDATE` → ledger `FOR UPDATE` |

**Ciclo de deadlock possível:** cancelamento/encerramento segura pending e aguarda attack; resolução/dano segura attack e aguarda pending. O PostgreSQL detectaria o deadlock e abortaria uma das transações. A análise estática confirma a ordem conflitante; ainda não houve reprodução concorrente.

### Direção de correção

Adotar ordem única documentada e aplicada em todas as rotinas do subsistema. A opção menos disruptiva aparente é obter o pending ID sem lock, depois bloquear pending → attack → campaign, relendo e validando cada registro após adquirir o lock. Antes de escolher definitivamente, concluir a matriz transitiva de todas as 37 rotinas e dependências chamadas, incluindo ledger, sequences, character sheets e campanhas. Não reordenar apenas duas funções sem revisar as demais.


A varredura das 37 definições exportadas identificou 18 rotinas com `FOR UPDATE` explícito. Além das linhas da matriz acima, `priv.srd_registrar_ocultacao_ataque_oportunidade_impl` também adquire attack → pending → campaign, confirmando que ocultação/rolagem de chance de falha participa da mesma inversão. As demais 19 definições não exibem `FOR UPDATE` diretamente, mas podem adquirir locks por `UPDATE`, triggers ou chamadas transitivas; não são consideradas livres de concorrência sem revisão adicional.


## Correção do mapa de centralização do footprint — 2026-11-09

Uma consulta de chamadas diretas a `priv.srd_token_grid_footprint` identificou 10 consumidores atuais: seis helpers privados de confusão/manobras/levantar, uma consulta pública de modificadores de manobra e três iniciadores de AOO (desarmado, monstro e arma). **O detector de saída de alcance não é um consumidor do helper.**

`public.srd_detectar_saida_alcance_ameacado_srd` duplica a classificação de tamanho em três blocos CASE próprios (mover, tokens ameaçadores e alcance base de armas). Esses blocos atualmente atribuem 6 a Colossal, 4 a Gargantuan/Imenso, 3 a Huge/Enorme e 2 a Large/Grande; estão corretos nos valores consultados, mas duplicados. O cálculo geométrico posterior usa `priv.srd_grid_footprint_distance_ft` com os footprints calculados localmente.

Portanto, a fotografia correta é:
- helper canônico atual: 6 para Colossal;
- detector AOO: cálculo duplicado, também 6 para Colossal;
- movimento jogador/Mestre, duas sobrecargas de ataque SRD v2 e Imposição de Mãos contra mortos-vivos: 5 para Colossal;
- spawn `adicionar_token_cba`: verifica apenas a célula de origem, sem helper/footprint completo.

A centralização ainda não existe. O fixture PostgreSQL criado nesta etapa testa somente o helper atual; não deve ser interpretado como validação dos call sites divergentes. A correção futura deve fazer detector, movimento, spawn, ataques e habilidades consumirem a mesma fonte de footprint.
