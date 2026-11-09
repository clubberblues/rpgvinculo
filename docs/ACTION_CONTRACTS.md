# Vínculo RPG — Contratos de ações e resultados

> Proposta arquitetural para padronização incremental. Este documento não altera RPCs existentes nem autoriza migrações. Os contratos atuais permanecem válidos até que cada fluxo seja migrado, testado e revisado.

## Objetivo

Definir um envelope comum para ações que atravessam interface, aplicação, regras de domínio, Supabase e clientes Realtime. O padrão deve permitir autorização consistente, rastreabilidade, retries seguros, erros previsíveis e integração entre módulos sem substituir prematuramente os contratos RPC existentes.

## Princípios obrigatórios

1. O servidor continua sendo a autoridade para identidade, autorização, estado, regras, consumo de recursos e persistência.
2. O cliente fornece apenas intenção e entradas observáveis (por exemplo, resultado de dado rolado manualmente); nunca declara o resultado mecânico final.
3. Toda ação mutável deve validar campanha, ator, papel, propriedade, turno e pré-condições no servidor.
4. Locks transacionais protegem concorrência; idempotência protege retries da mesma intenção. Um não substitui o outro.
5. A autorização deve ser validada antes de devolver um resultado idempotente previamente armazenado.
6. Reutilizar a mesma chave com payload semanticamente diferente deve retornar conflito, nunca executar uma segunda ação.
7. O envelope comum será introduzido por adaptadores e fatias verticais; não exigir alteração simultânea de todas as RPCs.
8. Eventos são notificações de fatos já confirmados. Realtime não é fonte canônica nem substitui a transação.

## Envelope proposto

### ActionRequest

```json
{
  "request_id": "UUID gerado uma vez por intenção do usuário",
  "action_type": "combat.advance_turn",
  "campaign_id": 131,
  "actor": {
    "character_id": "identificador opcional",
    "token_id": "identificador opcional"
  },
  "payload": {},
  "expected_state": {
    "round": 1,
    "turn_index": 2
  }
}
```

Regras:
- `request_id` é criado uma vez por intenção e preservado em todos os retries.
- `action_type` é estável, versionável e namespaced por domínio.
- `campaign_id` é contexto solicitado; o servidor confirma associação e autorização.
- `actor` identifica o ator pretendido; não substitui `auth.uid()` nem a verificação de propriedade.
- `payload` contém somente entradas necessárias à ação, nunca campos derivados que o servidor possa calcular.
- `expected_state` é opcional e permite rejeitar comandos feitos sobre um snapshot obsoleto.
- Identidade do usuário, papel efetivo e resultado final são sempre derivados/verificados no servidor.

### ActionResult

```json
{
  "request_id": "mesmo UUID da solicitação",
  "status": "accepted | rejected | pending",
  "code": "TURN_ADVANCED",
  "message": "Descrição segura para a interface",
  "data": {},
  "events": [],
  "state_version": null,
  "server_time": "timestamp ISO-8601"
}
```

Regras:
- `status` descreve o resultado do processamento, não o sucesso HTTP isoladamente.
- `code` é estável e destinado a lógica de interface/testes.
- `message` é apresentação; clientes não devem tomar decisões por comparação textual.
- `data` contém o snapshot mínimo necessário para atualizar o consumidor.
- `events` lista fatos confirmados produzidos pela transação; não autoriza repetir efeitos.
- `state_version` só será preenchido quando houver versão monotônica definida para o agregado.
- Respostas de rejeição não devem expor detalhes internos, SQL ou dados de outros membros.

## Idempotência e transações

Para ações com consumo de recurso, mudança de turno, dano, conjuração ou efeitos não reversíveis:
- Persistir chave única escopada por campanha, usuário, tipo de ação e request_id.
- Persistir hash canônico do payload relevante, estado final e resposta.
- Reservar a chave e executar a ação na mesma transação da alteração de domínio.
- Concorrência com a mesma chave deve aguardar/retornar a resposta já persistida, sem duplicar efeitos.
- Mesma chave com payload diferente deve retornar conflito.
- Falha transacional antes do commit não pode deixar reserva órfã nem efeito parcial.
- Replays devem respeitar autorização atual e não revelar resposta de outro usuário.
- Política de retenção e tabela compartilhada serão definidas após inventário dos fluxos e volume esperado.

Locks de campanha/personagem/pendência continuam necessários para serializar mudanças no agregado correto. A ordem de locks deve ser documentada por fluxo para reduzir deadlocks.

## Eventos e sincronização

- Emitir/publicar eventos somente após commit.
- Cada evento deve conter `event_id`, `event_type`, `campaign_id`, `request_id` quando aplicável, `occurred_at` e versão do agregado quando disponível.
- Consumidores devem tolerar entrega repetida e fora de ordem; usar identificador/versão para deduplicar e descartar estado antigo.
- O cliente deve recuperar snapshot canônico após reconexão; não reconstruir o estado apenas pela sequência de notificações.
- Logs narrativos e eventos técnicos têm propósitos distintos, mesmo quando ambos derivam da mesma ação.

## Contrato de erros

Códigos iniciais recomendados:
- `UNAUTHENTICATED`
- `FORBIDDEN`
- `NOT_FOUND`
- `INVALID_ARGUMENT`
- `PRECONDITION_FAILED`
- `STALE_STATE`
- `RESOURCE_EXHAUSTED`
- `ACTION_NOT_ALLOWED`
- `IDEMPOTENCY_CONFLICT`
- `IN_PROGRESS`
- `INTERNAL_ERROR`

Os códigos devem ser mapeados a erros reais por fluxo. Não transformar toda exceção em erro genérico nem expor mensagens internas do banco.

## Fotografia dos fluxos existentes — consulta de catálogo em 2026-11-09

Assinaturas atuais confirmadas em `pg_proc`:
| RPC | Argumentos de identidade | Idempotência observada |
|---|---|---|
| `avancar_turno` | `p_campaign_id bigint` | Sem request_id no contrato atual; lock da campanha documentado. |
| `conjurar_magia_com_acao_srd_manual` | `p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_roll_results integer[]` | Sem chave no contrato atual; lock/consumo transacional documentado. |
| `conjurar_missil_magico_srd_manual` | `p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_damage_rolls integer[]` | Sem chave no contrato atual; lock/consumo transacional documentado. |
| `registrar_iniciativa_d20` | `p_campaign_id bigint, p_personagem_id text, p_d20 integer` | Idempotência por estado da rodada/ficha, sem request_id explícito. |
| `iniciar_iniciativa_com_dados` | `p_campaign_id bigint, p_expected_character_ids text[], p_request_id text, p_gm_d20_results jsonb` | Possui request_id no contrato atual. |

Essa fotografia registra apenas assinaturas e observações documentadas sobre implementação. Não comprova comportamento de retry em teste ponta a ponta.

### Chamadas observadas no frontend — mesa.html

Inspeção estática do HEAD atual encontrou:
- `avancarTurno()` chama `avancar_turno({p_campaign_id})`, sem request_id. Após a resposta, atualiza `combatDataState`, redesenha a iniciativa e publica mensagem de chat. O botão é desabilitado durante a chamada, mas isso protege apenas aquela instância da interface; não torna a RPC idempotente entre abas, retries ou chamadas concorrentes.
- O fluxo de conjuração escolhe entre as RPCs manuais e envia os resultados produzidos pelo Dice UI em `p_roll_results` ou `p_damage_rolls`. A chamada não contém request_id no contrato atual.
- `salvarIniciativa()` envia o d20 recebido do Dice UI a `registrar_iniciativa_d20`; o backend valida o valor e retorna o estado atual se a ficha já consta na ordem.
- `iniciar_iniciativa_com_dados` recebe `request_id`. O frontend gera `crypto.randomUUID()` quando disponível, mas mantém fallback textual baseado em timestamp + aleatoriedade. O contrato SQL é `text`, e a função atual exige apenas valor não vazio quando há fichas esperadas. Portanto, não presumir que todos os request_id existentes sejam UUIDs.
- A mensagem de chat é publicada depois da RPC de avanço do turno. Uma falha de rede entre o commit do turno e o envio da mensagem pode deixar o estado atualizado sem o anúncio correspondente; a estratégia futura deve distinguir evento transacional/outbox de mensagem narrativa enviada pelo cliente.

**Implicação:** o envelope-alvo pode padronizar UUID para novas ações, mas a migração de `iniciar_iniciativa_com_dados` deve aceitar os identificadores legados durante a compatibilidade ou introduzir um wrapper versionado. Não converter nem restringir o parâmetro atual sem avaliar consumidores e retries históricos.

## Plano de adoção sem quebra

1. Definir a tabela/estrutura de idempotência e o helper transacional comum, após revisar grants, RLS e exposição de schemas.
2. Escolher uma primeira fatia de baixo risco em ambiente descartável; não começar por conjuração ou avanço de turno em produção.
3. Adaptar uma RPC por vez, mantendo wrappers de compatibilidade para consumidores existentes.
4. Adicionar testes de retry, payload divergente, concorrência, autorização e rollback.
5. Atualizar adaptador frontend e eventos somente após contrato do servidor estar validado.
6. Migrar os fluxos restantes por prioridade; remover compatibilidade apenas com evidência de que não há consumidores.

## Itens ainda não decididos

- Schema e política de acesso da tabela de idempotência.
- Escopo exato da chave (usuário/campanha/ação) por família de operação.
- Retenção e limpeza dos resultados.
- Estratégia de versionamento de ActionRequest/ActionResult.
- Catálogo definitivo de eventos e códigos de erro.
- Uso de versão monotônica em campaigns.cba_data/combat_data.
- Política de locks e ordem por agregado.

Nenhum desses itens deve ser resolvido por migração especulativa. Primeiro completar os contratos e a validação de acesso aos schemas internos.

## Próximas tarefas

1. Conferir manualmente os schemas expostos em Supabase Dashboard → Project Settings → API → Exposed schemas.
2. Completar o cruzamento dos argumentos JS ↔ PostgreSQL nos fluxos críticos restantes.
3. Definir ActionRequest/ActionResult por fluxo, com catálogo de erros e eventos.
4. Definir desenho de persistência/idempotência e ordem de locks sem aplicar alterações ainda.
5. Preparar uma primeira fatia vertical em branch e PR, com fixture descartável e testes automatizados.


## Evidência adicional — 2026-11-09
- A assinatura de `avancar_turno` e seu corpo foram consultados diretamente no catálogo PostgreSQL: a função autentica membro GM/PLAYER, bloqueia a linha da campanha com FOR UPDATE, verifica turno/propriedade e atualiza combat_data, mas não recebe chave de idempotência.
- `registrar_iniciativa_d20` bloqueia a campanha e a ficha; se a ficha já aparece na ordem atual, retorna o estado existente antes de inserir novo resultado.
- `iniciar_iniciativa_com_dados` exige request_id não vazio quando há participantes esperados, mas o tipo permanece text e não há evidência de tabela comum de idempotência no contrato inspecionado.
- A inspeção foi somente de leitura. Nenhuma função, tabela ou dado de jogo foi alterado.


## Cruzamento inicial frontend ↔ PostgreSQL — 2026-11-09

Amostra dos fluxos críticos inspecionados estaticamente em `mesa.html` e comparados às assinaturas atuais em `pg_proc`:

| Fluxo | Argumentos enviados pelo frontend | Assinatura PostgreSQL | Situação estática |
|---|---|---|---|
| Avançar turno | `p_campaign_id: Number(MESA_ID)` | `p_campaign_id bigint` | Chave e tipo de contexto compatíveis. Sem request_id no contrato. |
| Conjuração manual | character_id, spell_id, slot_level, target_token_key, roll_results | text, text, smallint, text, integer[] | Nomes e estrutura compatíveis; slot é convertido para Number e dados são arrays numéricos do Dice UI. Sem request_id. |
| Míssil Mágico manual | character_id, spell_id, slot_level, target_token_key, damage_rolls | text, text, smallint, text, integer[] | Nomes e estrutura compatíveis; sem request_id. |
| Registrar iniciativa do jogador | campaign_id, personagem_id, d20 | bigint, text, integer | Compatível; d20 validado no servidor entre 1 e 20. Idempotência atual é pelo estado da ordem/ficha. |
| Iniciar iniciativa | campaign_id, expected_character_ids, request_id, gm_d20_results | bigint, text[], text, jsonb | Chaves e estrutura compatíveis; request_id é text e tem fallback não UUID no frontend. |

**Classificação:** correspondência estática preliminar. Não comprova coerção de tipos em runtime pelo PostgREST, autorização com sessões reais, semântica completa, retries ou sincronização entre dois clientes. A validação desses pontos requer ambiente descartável e sessões autenticadas.


## Cruzamento inicial — movimento e Ataques de Oportunidade — 2026-11-09

Inspeção estática de `mesa.html` comparada às assinaturas atuais de `pg_proc`:

| Etapa | RPC | Argumentos enviados / assinatura PostgreSQL | Resultado |
|---|---|---|---|
| Solicitar movimento do jogador ou Mestre | `srd_solicitar_movimento_com_aoo_srd` | campaign_id bigint, mover_token_id text, destination_x integer, destination_y integer, controller text | Chaves e tipos aparentes correspondem; frontend envia controller player/gm. |
| Concluir movimento sem reação pendente | `mover_token_player_cba` / `mover_token_gm_cba_srd` | player: campaign_id bigint, character_id text, grid_x integer, grid_y integer; GM: campaign_id bigint, token_id text, grid_x integer, grid_y integer | Chaves e tipos aparentes correspondem; atualização do snapshot CBA ocorre após resposta. |
| Reservar reação | `srd_reservar_reacao_movimento_aoo_srd` | campaign_id bigint, pending_id uuid, reactor_token_id text | Correspondência estática. |
| Iniciar ataque armado | `srd_iniciar_ataque_oportunidade_srd` | campaign_id bigint, pending_id uuid, reactor_token_id text, reaction_id uuid, weapon_instance_id uuid, weapon_hand_slot text, weapon_end text | Correspondência estática; weapon_end aceita null quando não há arma dupla. |
| Registrar d20 manual | `srd_registrar_rolagem_ataque_oportunidade_srd` | campaign_id bigint, attack_id uuid, manual_d20 integer, idempotency_key uuid | Correspondência estática; d20 vem do Dice UI e chave é gerada pelo helper de UUID. |
| Resolver ataque | `srd_resolver_ataque_oportunidade_srd` | campaign_id bigint, attack_id uuid | Correspondência estática. |
| Aplicar dano | `srd_aplicar_dano_ataque_oportunidade_srd` ou variante monstro | campaign_id bigint, attack_id uuid, damage_rolls integer[], idempotency_key uuid | Ambos os alvos dinâmicos têm assinatura compatível e grants/search_path seguros conforme verificação anterior. |
| Concluir ou cancelar movimento pendente | `srd_finalizar_movimento_aoo_pendente_srd` / `srd_cancelar_movimento_aoo_pendente_srd` | campaign_id bigint, pending_id uuid | Correspondência estática. |

**Observações de arquitetura:** o frontend separa a solicitação de movimento da efetiva gravação de posição; quando há reação pendente, atualiza o snapshot e aguarda a fila do Mestre. O ataque de oportunidade mantém d20 manual e chave de idempotência tanto no registro da rolagem quanto na aplicação de dano. O fluxo depende de múltiplas RPCs e estados persistidos; sua correção não pode ser inferida apenas pelo pareamento de argumentos.

**Ainda não testado:** concorrência entre dois clientes, desconexão entre reserva/início/rolagem/dano, retry com mesma chave, retry com payload divergente, cancelamento durante reação e sincronização após reconexão. Não foi feita qualquer mutação de campanha ou token.


## Cruzamento inicial — inventário e equipamento — 2026-11-09

Chamadas observadas em `mesa.html` e dispatcher de ações da ficha, comparadas às assinaturas PostgreSQL:

| Operação | RPC / assinatura | Evidência estática |
|---|---|---|
| Entregar item à ficha | `entregar_item_srd(p_campaign_id bigint, p_character_id text, p_equipment_id text, p_quantidade integer)` | mesa envia campaign_id, character_id, item.id e quantidade 1. |
| Entregar item a token | `entregar_item_token_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_quantidade integer)` | mesa envia campaign_id, token.id, item.id e quantidade 1. |
| Equipar item de ficha | `equipar_item_srd(p_character_id text, p_equipment_id text, p_equipado boolean)` | ID e estado desejado são enviados a partir dos atributos data-* do botão. |
| Equipar item de token | `equipar_item_token_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean)` | campanha/token/ID e estado desejado correspondem à assinatura. |
| Equipar item de NPC vinculado | `equipar_item_npc_vinculado_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean)` | dispatcher da ficha remapeia o pedido para a RPC específica quando há p_campaign_id. |
| Clonar inventário para token NPC | `clonar_equipamento_ficha_para_token(p_campaign_id bigint, p_token_id text, p_character_id text)` | chamado após adicionar NPC vinculado; erro é tratado como falha parcial e informado ao Mestre. |
| Consultar inventário de NPC vinculado | `consultar_inventario_npc_vinculado_srd(p_campaign_id bigint, p_token_id text)` | consulta usa campanha e token; frontend separa ficha vinculada do inventário CBA genérico. |
| Equipar instância de arma | três RPCs por escopo, com `p_instance_id uuid`, `p_hand_slot text` e `p_equipado boolean` | dispatcher escolhe personagem, NPC vinculado ou token; o estado enviado é o inverso do estado atual do botão. |

O frontend prepara o estado desejado de equipamento nos atributos `data-equipped`; a leitura estática confirmou que os botões de item enviam esse valor desejado e os botões de instância de arma enviam `!equipped`. Não foi encontrado, nesta amostra, um erro de inversão do toggle.

**Ainda não validado:** concorrência entre duas ações de equipamento, retry após resposta perdida, consistência entre ficha e token vinculado, duplicação/quantidade de itens, clonagem repetida do inventário e comportamento após desconexão. Não houve alteração de inventário, personagem, token ou campanha.


## Cruzamento inicial — progressão, descanso e valores derivados — 2026-11-09

| Fluxo | RPC / assinatura PostgreSQL | Evidência estática e limite |
|---|---|---|
| Conceder XP | `conceder_xp_personagem_srd(p_campaign_id bigint, p_character_id text, p_xp integer)` | mesa envia campanha, ID de ficha como texto e quantidade; a distribuição para múltiplos selecionados ocorre em chamadas sequenciais individuais, portanto o lote pode ter sucesso parcial. |
| Avançar nível | `concluir_avanco_nivel_personagem_srd_v2(p_campaign_id bigint, p_character_id text, p_hit_die_roll integer, p_skill_ranks jsonb, p_feats jsonb, p_attribute text, p_idiomas jsonb)` | ficha envia todos os argumentos previstos; rolagem de dado de vida vem do fluxo manual de dados. Não há request_id no contrato atual. |
| Descanso longo de personagem | `descanso_longo_personagem_srd(p_campaign_id bigint, p_character_id text)` | ficha envia campanha e ID do personagem. |
| Descanso longo de NPC vinculado | `descanso_longo_npc_vinculado_srd(p_campaign_id bigint, p_token_id text)` | dispatcher escolhe a RPC conforme o alvo ser ficha ou token NPC vinculado. |
| Salvar grimório | `salvar_grimorio_srd(p_character_id text, p_estado jsonb)` | ficha envia o estado serializado do grimório como JSONB. |
| Salvar domínios | `salvar_dominios_personagem_srd(p_character_id text, p_domain_ids text[])` | IDs de domínio são convertidos para string e enviados como array. |
| Calcular CA | duas sobrecargas de `srd_calcular_ca_personagem_srd` | ficha envia campanha, personagem, contexto normal e `p_attacker_is_giant=false`, selecionando a assinatura de quatro argumentos. |
| Calcular deslocamento | `srd35_deslocamento_personagem(p_character_id text, p_base_speed_m numeric)` | ficha envia ID do personagem e deslocamento racial convertido para Number. |

**Pontos arquiteturais:** concessão de XP em lote não é uma única transação; a interface registra quais personagens receberam XP e quais falharam. Avanço de nível é uma operação de alto impacto e não recebe request_id no contrato atual; sua proteção contra retry precisa ser examinada no corpo da função e validada em fixture descartável antes de qualquer alteração. Descanso e atualização de grimório também são operações mutáveis que precisam de casos de retry e autorização por papel.

**Limite da verificação:** foram comparadas chaves/formatos enviados e assinaturas do catálogo. Não foram executadas RPCs mutáveis nem alterados XP, nível, PV, grimório, domínios ou campanha.


## Cruzamento inicial — ciclo de vida de campanhas e lobby — 2026-11-09

Inspeção estática de `lobby.html` e leitura de definições SQL em `pg_get_functiondef`, sem executar ações mutáveis:

| Operação | RPC / contrato | Verificação |
|---|---|---|
| Listar mesas | `lobby_list_v2()` | Sem argumentos; frontend complementa com leitura de `campaigns(id, owner_id)` para distinguir o criador. |
| Criar campanha | `create_campaign(p_name text, p_code text, p_location bigint)` | Valida autenticação, nome, código de quatro dígitos e cidade opcional; insere campanha/código/cena e registra log na mesma transação. Há rate limit por usuário via `priv.locked/fail/clear`. |
| Entrar por código global | `join_campaign(p_code text)` | Resolve código para campanha ativa, registra membro PLAYER e log; código inválido consome tentativa do limitador. |
| Entrar em mesa aberta | `entrar_campanha_aberta(p_campaign_id bigint)` | Bloqueia leitura da campanha com FOR SHARE, exige campanha ativa e ausência de código; insere membro com ON CONFLICT DO NOTHING. |
| Entrar com código da mesa | `entrar_campanha_com_codigo(p_campaign_id bigint, p_code text)` | Valida autenticação, formato, rate limit, campanha ativa e código da campanha; cria membro idempotentemente por conflito. |
| Sentar ficha | `sentar_personagem_na_mesa(p_campaign_id bigint, p_character_id text)` | Exige papel PLAYER na campanha e propriedade da ficha; bloqueia a ficha FOR UPDATE e atualiza campaign_id. Não verifica explicitamente se a campanha está ativa no corpo inspecionado. |
| Alterar configurações | `atualizar_configuracoes_campanha(p_campaign_id bigint, p_name text, p_require_code boolean, p_code text)` | Exige auth.uid, owner_id e campanha ativa; valida nome/código e atualiza campanha/código sob lock da linha. |
| Excluir ficha própria | `excluir_ficha_propria(p_character_id text)` | Exige propriedade, bloqueia ficha e campanha, remove dependências e ajusta ordem de combate na mesma transação. Operação destrutiva; não foi executada. |

### Exclusão de campanha: saga com Storage externo

A exclusão usa duas RPCs e operações Storage no cliente, não uma transação única:

1. `preparar_exclusao_campanha_propria` bloqueia a campanha, confirma proprietário e grava/atualiza `priv.campaign_deletion_cleanup`.
2. O cliente lista recursivamente `midia/campaigns/{id}` e pagina `midia/capas_mesas`, filtrando nomes `mesa-{id}-*`; remove os arquivos em lotes de até 1.000.
3. `finalizar_exclusao_campanha_propria` confirma proprietário da pendência, bloqueia a campanha, apaga a campanha e remove a pendência. A RPC pública é wrapper SECURITY INVOKER para implementação privada SECURITY DEFINER.

**Riscos/limites identificados, ainda sem correção:**
- A preparação não marca a campanha como inativa nem grava estado de exclusão na própria linha `campaigns`; os fluxos de entrada continuam verificando `active`, que permanece inalterado. Assim, uma entrada pode ocorrer entre preparação e finalização. A exclusão final ainda remove a campanha, mas a experiência de membros concorrentes pode ser abrupta.
- A saga depende de o navegador permanecer aberto e ter permissão Storage; falhas parciais podem deixar a pendência gravada e parte dos arquivos removida. A repetição da listagem/remoção é compatível com arquivos já ausentes, mas não existe worker de retomada documentado.
- Se a finalização for confirmada no banco mas a resposta se perder, repetir a finalização falha porque a linha de pendência já foi removida e a campanha já não existe. O cliente pode resolver recarregando o lobby, mas o contrato não é idempotente para esse cenário.
- O upload da capa ocorre antes da atualização de `campaigns.capa_url`; se o upload funcionar e a atualização da linha falhar, o objeto recém-enviado pode ficar órfão. A exclusão varre capas pelo prefixo `mesa-{id}-`, mas não há rotina de GC específica para uploads órfãos.
- A varredura de exclusão cobre o bucket `midia` e os prefixos observados no código; não foi feita auditoria de todos os buckets/objetos históricos do projeto.

**Segurança observada nas RPCs de lobby:** as funções públicas listadas têm EXECUTE para authenticated, sem EXECUTE para anon ou PUBLIC. As SECURITY DEFINER consultadas usam search_path com pg_temp por último. Isso é apenas a camada de grants/configuração; as guardas semânticas foram descritas por função acima e ainda precisam de testes com papéis reais.

Não foram criadas/excluídas campanhas, membros, fichas, arquivos Storage ou registros de pendência durante esta análise.


## Divergência confirmada — caminho legado Vínculo em ficha.html — 2026-11-09

A página `ficha.html` possui dois caminhos: se a ficha tem linha em `srd_character_sheets`, usa o fluxo D&D 3.5; caso contrário, usa o caminho legado Vínculo. A criação Vínculo também usa esse caminho. A comparação do código com `information_schema.tables` encontrou nomes antigos ainda referenciados pelo frontend, enquanto o banco conectado possui os nomes versionados:

| Referência atual no frontend legado | Relação existente no banco | Situação |
|---|---|---|
| `classes` | `vinculo_classes` | Nome antigo ausente; criação/abertura de classe tende a falhar. |
| `abilities` | `vinculo_abilities` | Nome antigo ausente. |
| `talents` | `vinculo_talents` | Nome antigo ausente. |
| `spells` | `vinculo_spells` | Nome antigo ausente. |
| `inventory` | `vinculo_inventory` + `vinculo_items` | Nome antigo ausente; carregamento do inventário falha e é silenciosamente convertido em lista vazia. |
| `character_notes` | `vinculo_character_notes` | Nome antigo ausente; carregamento de notas ignora o erro e apresenta lista vazia. |
| `vinculo_character_sheets` | `vinculo_character_sheets` | Correspondência atual. |
| `character_talents`, `character_spells` | relações ainda existentes | Permanecem, mas o catálogo correspondente consultado pelo frontend usa nomes antigos; não presumir que representam o modelo final Vínculo. |

O fluxo de criação legado tenta inserir em `characters` e depois fazer upsert em `vinculo_character_sheets`, mas consulta classe em `classes` e habilidades em `abilities`. Como esses nomes não existem no schema public atual, o caminho legado de criação/abertura está incompatível com o banco observado. A página D&D 3.5 tem um desvio próprio e não é afetada por essa constatação quando a ficha possui linha SRD.

### RLS observado nas relações Vínculo atuais
- Catálogos `vinculo_classes`, `vinculo_abilities`, `vinculo_talents`, `vinculo_spells` e `vinculo_items`: leitura pública por políticas SELECT.
- `vinculo_character_notes`: SELECT/INSERT/UPDATE/DELETE para proprietário da ficha ou Mestre da campanha.
- `vinculo_inventory`: SELECT/INSERT/UPDATE para proprietário ou Mestre; DELETE somente para Mestre na política observada. Isso conflita com o código legado, que tenta apagar o item ao consumir a última unidade ou removê-lo. Mesmo após corrigir o nome da relação, a operação de jogador precisaria de decisão explícita de regra e política.
- `vinculo_character_sheets`: leitura por membros da campanha, INSERT pelo proprietário e UPDATE pelo proprietário ou Mestre.

**Classificação:** incompatibilidade frontend ↔ schema confirmada, não apenas hipótese. Não foi feita substituição de nomes nem alteração de RLS nesta fase, porque precisamos decidir se o caminho legado Vínculo será reativado, adaptado ao novo schema ou descontinuado em favor do novo modelo. Não houve escrita em personagem, inventário, notas, talento, magia ou catálogo.
