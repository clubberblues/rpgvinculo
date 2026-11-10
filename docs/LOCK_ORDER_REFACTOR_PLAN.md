# Plano proposto de refatoração da concorrência

**Estado:** proposta técnica, não aprovada para deploy.  
**Data:** 2026-11-10  
**Escopo:** D&D 3.5 VTT — transações de campanha, AOO, ataques iterativos, fichas, recursos de classe e conjuração.  
**Regra de segurança:** este documento não autoriza executar migrations no projeto Supabase de produção.

## 1. Objetivo e invariantes

Eliminar ciclos de espera e corridas de estado sem alterar regras de D&D 3.5, autorização ou resultados de combate.

Invariantes propostos:

1. Uma RPC que altera ou coordena o agregado de uma campanha adquire o lock da campanha antes de locks de linhas dependentes.
2. Identificadores de campanha/alvo podem ser descobertos por leitura MVCC; após o lock da campanha, vínculo, autorização, estado, rodada, turno, status e pré-condições são relidos e validados.
3. Uma helper privada não adquire implicitamente locks de campanha se alguns callers já mantêm ficha/recurso. O contrato de locks deve estar no entrypoint e ser documentado.
4. Todos os caminhos que atualizam a mesma fila AOO devem compartilhar a mesma ordem de pending e attack.
5. Locks de múltiplas linhas do mesmo tipo devem usar ordenação determinística por ID.
6. FOR UPDATE não substitui validação de versão/payload: lost update de snapshot JSONB é um problema separado.
7. Não existe uma hierarquia global aprovada para todas as tabelas. A ordem secundária é um grafo parcial por domínio.

## 2. Sequência de refatoração proposta

### Fase A — Preparação e contratos

- Congelar a fotografia das definições SQL, OIDs, grants, triggers, call sites e migrations que correspondem a cada RPC.
- Para cada entrypoint, registrar: locks próprios, locks herdados por helpers/triggers, leituras MVCC, linhas/IDs compartilhados, autoridade e condições revalidadas.
- Obter definição de referência e assinatura de cada função a partir do banco; não reconstruir migrations por nome/timestamp.
- Criar fixtures descartáveis baseadas em cópias das funções relevantes e testes que exercitem a semântica real em PostgreSQL, com papéis/claims de teste.
- Bloqueio atual: reconciliação local/remota tem 681 arquivos SQL e 966 registros remotos, com apenas 640 versões coincidentes exatas por timestamp/nome. Conteúdo SQL equivalente ainda não foi provado.

**Aceite:** matriz completa por OID/caller; nenhuma dependência desconhecida entre entrypoints e helpers; base de migration validada contra histórico remoto.

### Fase B — Ataques iterativos PC e NPC

Alvos identificados:
- PC: OID 27364 bloqueia instância de arma antes da implementação-base bloquear campanha (OID 27360).
- NPC: OID 26730 bloqueia sequência NPC antes da campanha; resolvers/dano usam campanha → tentativa → sequência.

Direção candidata para mutações campaign-scoped: campanha → sequência → tentativa → instância de arma. Normalizar wrappers e implementações privadas para que nenhum caminho de registro adquira arma/sequência antes da campanha. Manter idempotência de request/attempt e ordenar IDs se mais de uma arma/linha for bloqueada.

**Aceite:** testes concorrentes de início/registro/resolução/dano PC e NPC; repetição de request idempotente; nenhuma duplicação de ataque/consumo de arma/ação; matriz de papéis preservada.

### Fase C — AOO como fluxo transacional único

RPCs autenticadas principais observadas:
- Transição: alternar_estado_campanha OID 20103 — campanha → ataques → pendências.
- Resolução: OID 27025 — ataque → pending → campanha.
- Dano PC/NPC: OIDs 27036/27058 — ataque → pending → campanha → ficha persistente, quando aplicável.
- Início armado/desarmado/monstro: OIDs 27022/27065/27055 — pending → campanha → ledger (e arma FOR SHARE no armado).
- Finalização: OID 27038 — pending → campanha.
- Ocultação: helper OID 27254 — ataque → pending → campanha.

Direção candidata, sujeita à validação de todas as interseções:
1. Obter campaign_id, pending_id, attack_id, target character_id e IDs auxiliares por leitura MVCC.
2. Bloquear campanha.
3. Se o alvo for ficha persistente, bloquear personagem e ficha; revalidar vínculo token↔ficha e identidade do alvo.
4. Bloquear pending.
5. Bloquear attack(s) em ordem determinística.
6. Bloquear ledger/instância de arma na ordem final definida pelo subgrafo de reação/arma; revalidar reserva, equipamento, mão, rodada e idempotency key.
7. Aplicar dano/condição, atualizar estado terminal, registrar log e concluir movimento na mesma transação quando a regra exigir atomicidade.

Todos os endpoints que alteram uma pending ou attack existente — incluindo rolagem, crítico, ocultação, dano, cancelamento, finalização e transição de estado — devem respeitar o mesmo prefixo. O desenho deve evitar que um endpoint segure attack enquanto espera pending, ou segure pending enquanto espera attack, fora da ordem escolhida.

**Aceite:** dois clientes concorrentes não podem resolver/cancelar/finalizar o mesmo movimento em duplicidade; nenhuma transação consegue mover o token antes de todas as reações terminais; AOO e mudança de estado não formam ciclo; dano em personagem e estabilização não formam ciclo na mesma ficha; reação/arma mantém validação e idempotência.

### Fase D — Ficha, magia e recursos de classe

Entrypoints confirmados:
- Estabilização OID 24914: personagem → ficha → campanha → condição.
- Magias multialvo OIDs 25109/25246: personagem → ficha → consumo de ação/campanha → cena/pendências.
- Imposição das Mãos contra mortos-vivos OID 25509: personagem → ficha → recurso → campanha.
- Habilidade de classe OID 25236: personagem → ficha → recurso; a aquisição de campanha varia por branch/alvo.
- Aplicação de magia pendente OID 25071: pending → campanha → ficha/efeitos.
- Resolvers de salvamento/resistência OIDs 25072/25073: pending-first; o branch condition_break altera condição sem lock explícito da campanha.
- Descanso longo PC OID 24366: personagem → leitura MVCC do estado da campanha → ficha → recursos/condições; não bloqueia campanha e tem corrida de estado, não ciclo de lock.

Direção candidata para operações que alteram campanha: campanha → personagem → ficha → recurso/condição → pending (ou a ordem pending/ficha que a matriz final justificar para cada resolução de magia). Para magia pendente, obter campaign_id/target por MVCC, bloquear campanha e revalidar pending/status/alvo antes de alterar condição, efeito, PV ou log. Helpers de condição/vitalidade devem herdar contrato explícito do caller; não inserir lock de campanha dentro deles sem migrar todos os callers.

Descanso e poção devem revalidar estado de combate sob lock da campanha antes de consumir item/recurso ou alterar PV. A regra de descanso não deve ser executada se combate iniciou concorrentemente.

**Aceite:** concorrência entre estabilização, dano, cura, descanso, magia, recurso de classe e transição de combate preserva PV, condições, espaços, recursos e ações sem consumo/perda duplicada.

### Fase E — CBA JSONB e movimento

Tratar separadamente dos deadlocks:
- salvar_cena_cba substitui snapshot integral; FOR UPDATE não impede que payload antigo reverta atualizações concorrentes.
- cbaWriteQueue serializa apenas um cliente.
- movimento player/GM ainda tem lógica divergente de footprint e não centraliza AOO/pending em todos os caminhos.

Direção candidata:
1. Substituir gravações genéricas por comandos parciais por domínio.
2. Adotar revisão monotônica gerada/validada no servidor ou comparar revisão esperada antes de aceitar snapshot.
3. Tornar RPCs de movimento a autoridade única: geometria/footprint, ocupação, AOO, pending, validação de turno e commit devem estar no mesmo limite transacional.
4. Separar publicação de mapa/metadados, spawn/remoção, PV e movimento; definir quais mutações são permitidas enquanto existe pending.

**Aceite:** snapshots obsoletos são rejeitados; movimento direto não contorna AOO; footprint Grande–Colossal é idêntico em spawn, movimento, alcance e ataque.

## 3. Estratégia de migrations e rollback

- Não aplicar nenhuma migration até reconciliar conteúdo SQL, nomes/timestamps duplicados e os 41 arquivos locais sem correspondência remota.
- Cada fatia deve ter migration nova e append-only, com pré-condições explícitas; nunca reescrever migration já aplicada.
- Antes de aplicar: comparar definição instalada com baseline capturada; validar assinatura, grants, search_path, SECURITY DEFINER/INVOKER, RLS, triggers e dependências.
- Em ambiente descartável, executar migration, testes concorrentes, testes de autorização, regressão de regras e smoke dos call sites.
- Rollback deve restaurar a definição anterior de cada RPC/trigger e preservar os dados; testar rollback antes de produção.
- Deploy remoto somente após aprovação explícita e reconciliação do histórico.

## 4. Critérios gerais de liberação

- Grafo de locks sem ciclo entre caminhos autenticados alcançáveis; helper/trigger não introduz aresta inversa.
- Revalidação pós-lock de identidade, papel, campanha, token, alvo, estado, rodada, turno, status e idempotência.
- Testes reais de concorrência usando RPCs instaladas em PostgreSQL descartável, não apenas padrões sintéticos.
- Matriz de autorização: não autenticado, dono, outro jogador, Mestre, outra campanha e alvo ausente/duplicado.
- Regressão D&D 3.5: resultados, ações, PV, condições, duração, recursos, inventário, armas e logs.
- Sem regressão de contratos do frontend e sem perda de dados CBA.
- Observabilidade de falhas, deadlocks e transações canceladas; procedimento de rollback reproduzível.

## 5. Fora do escopo desta proposta

- Não altera regras de D&D 3.5 nem adiciona automação de efeitos ainda não implementados.
- Não remove índices, tabelas, funções ou grants por inferência.
- Não altera TESTE 2 ou outras campanhas.
- Não aplica mudanças no Supabase conectado.
- Não aprova merge ou deploy por si só.


## 6. Adendos identificados em auditoria subsequente

### Complemento de escopo single-target (2026-11-10)

A inspeção de mesa.html confirmou que Míssil Mágico usa o wrapper autenticado OID 25191 (personagem → ficha → campanha, por helpers internos), enquanto as demais magias manuais single-target usam OID 24658 (personagem → campanha → ficha). Ambos devem entrar na Fase D e ser testados separadamente. Os helpers internos OIDs 24356, 20410 e 24656 não têm EXECUTE autenticado no snapshot; isso não é falha por si só, pois são invocados pelos wrappers SECURITY DEFINER autenticados.


A cura multialvo usa o wrapper autenticado OID 24661, que adquire personagem → campanha antes de delegar ao helper OID 24659, que bloqueia ficha. Não confundir com dano/efeito multialvo (OIDs 25246/25109), que bloqueiam personagem → ficha antes da campanha. A Fase D deve manter contratos de teste separados por branch e reordenar todos os entrypoints para campaign-first, sem depender da ordem herdada pelo wrapper.


### Writer legado de transferência de Mestre

Incluir public.gm_transfer (OID 18749) na Fase A caso seja mantido: endpoint SECURITY DEFINER com EXECUTE authenticated chama priv.need_owner sem lock e depois atualiza dois membros e owner_id. Há uma corrida TOCTOU em chamadas concorrentes do proprietário atual. A correção candidata é lock de campanha antes da revalidação de owner_id/active e atualização de membros em ordem determinística. Antes de remover ou alterar, localizar consumidores externos; não há call site direto localizado nas três páginas principais consultadas. Teste de aceitação: duas transferências simultâneas, somente uma autorizada.


### Complemento da Fase D — gates de estado e inventário (2026-11-10)

Incluir descanso longo (OID 24366) e poção de cura manual (OID 24655) como mutações autenticadas que dependem do estado da campanha. Ambos fazem leitura de `campaigns.state` sem lock. Descanso bloqueia personagem antes da leitura; poção só chama o consumo de ação (OID 20405, que bloqueia campanha) quando a leitura anterior já indicou combate. A transição autenticada (OID 20103) bloqueia campanha primeiro. Há, portanto, janela de estado obsoleto: descanso pode continuar depois do início do combate; poção que observou exploração pode ser consumida sem ação se o combate iniciar em seguida.

Direção candidata: MVCC localizar campanha → `campaigns FOR UPDATE` → revalidar vínculo/owner/estado → locks de personagem/ficha/equipamento/recursos conforme a ordem específica do inventário. A decisão de gastar ação da poção deve ocorrer dentro da mesma serialização da transição, não por leitura anterior sem lock. Não mover o lock de campanha para dentro de `srd_sync_character_vital_condition`: helper sem lock próprio, com pré-condição campaign-first explícita no caller, evita lock implícito campanha-after-sheet.

**Aceite:** testes concorrentes com RPCs reais em PostgreSQL descartável para descanso × início de combate, poção × início de combate, poção em combate × ação já consumida e duas poções × última unidade; confirmar que estado, ação, inventário, PV, magias, recursos e condições não divergem.


Nota de escopo: o descanso longo de NPC vinculado (wrapper OID 26801 → implementação privada OID 26808) já bloqueia campanha e valida estado antes de personagem/ficha. A correção de estado da Fase D deve priorizar o descanso PC (OID 24366); preservar e testar separadamente o caminho NPC existente, sem reordená-lo por suposição.


Complemento transacional: triggers AFTER INSERT/DELETE/UPDATE OF quantidade de `srd_character_equipment` e `srd_cba_token_equipment` materializam/removem instâncias de arma e sincronizam campos do inventário (funções private OIDs 26446/26447). Assim, operações de inventário adquirem locks transitivos em weapon instances; incluir essas arestas no grafo e nos testes de PC/NPC, sem concluir deadlock apenas pela existência do trigger.


### Equipamento: ordem por domínio e autorização GM

- PC weapon equip (OID 26441): character → weapon instance → inventory row. Token weapon equip (OID 26443): campaign → token weapon instance → token inventory row. Manter ordens distintas por domínio.
- Inventory quantity triggers (OIDs 26446/26447) produzem inventory row → weapon instances. No snapshot de writers authenticated, nenhum caminho reduz quantidade de arma; os decrementos encontrados são consumo de poção. Não classificar como ciclo ativo até existir writer que reduza/exclua arma; manter o ramo negativo como requisito de teste futuro.
- Entrega de item PC (OID 20556) valida papel GM sem lock de campanha. Entrega/equipamento de item em token (OIDs 21668/21670) validam papel antes do lock de campanha. Como `gm_transfer` altera owner/membership, essas validações podem ficar obsoletas. Candidato: campaign FOR UPDATE → revalidar role GM e alvo → mutação de inventário/trigger; teste concorrente de revogação/transferência versus entrega/equipamento.


### Administração da campanha: escopo ampliado da correção campaign-first

Além de `gm_transfer`, os endpoints authenticated `gm_set_role` (OID 18748) e `gm_kick` (OID 19188) usam `priv.need_owner` (OID 18742), que consulta owner sem lock, e depois alteram `members` sem lock de campanha. `iniciar_iniciativa_com_dados` (OID 20577) valida GM antes de `campaigns FOR UPDATE`. Corrigir como uma família: campanha FOR UPDATE primeiro, revalidar owner/active/papel e alvo, depois mutações de membership/iniciativa. Testes concorrentes: transferência × mudança de papel, transferência × expulsão, transferência × início de iniciativa; apenas a operação autorizada sob o lock deve concluir.

`sentar_personagem_na_mesa` (OID 21606) valida PLAYER antes do lock da ficha e altera campaign_id sem lock de campanha. Tratar em trilha separada: definir invariantes de associação de personagem e coordenar com join/leave/kick antes de impor campaign-first, evitando inventar uma ordem character↔campaign que gere ciclo.


### Bloqueador de transferência: trigger de papel

`gm_transfer` (OID 18749) altera membership antes de atualizar `campaigns.owner_id`, mas `enforce_campaign_member_role` (OID 21603) força o owner atual a GM e impede qualquer outro membro de receber GM. A ordem atual pode deixar owner_id no novo usuário enquanto membership preserva o antigo GM e rebaixa o novo para PLAYER. O snapshot atual tem 3 campanhas e todas mantêm owner=GM e exatamente um GM; não há inconsistência observada nos registros existentes. Novo teste fixture reproduz a ordem atual e valida controle owner-first, com lock de campanha. A correção candidata deve atualizar owner_id antes dos papéis, tudo sob campaign FOR UPDATE e na mesma transação.


### Matriz de endpoints GM a revalidar depois do lock

Além de inventário e iniciativa, a varredura identificou endpoints ativos que verificam GM antes de `campaigns FOR UPDATE`: `alternar_estado_campanha` (20103), `salvar_cena_cba` (20077), `adicionar_combatente_iniciativa` (20078), `mover_combatente_iniciativa` (20080), `iniciar_iniciativa_com_dados` (20577), `srd_configurar_perfil_combate_token_srd` (26922), `srd_configurar_rodada_surpresa_srd` (27092), `usar_furia_barbaro_npc_srd` (26656), `entregar_item_token_srd` (21668) e `equipar_item_token_srd` (21670). O frontend principal chama esses fluxos em `mesa.html`/ `ficha.html`.

Correção comum: obter campaign FOR UPDATE antes da autorização definitiva; revalidar papel GM após o lock; só então executar mutação. Preservar locks de domínio subsequentes e evitar que helpers adquiram campanha depois de personagem/ficha. Incluir testes concorrentes de transferência × alternância de estado, transferência × CBA snapshot, transferência × iniciativa, transferência × perfil/rodada surpresa/Fúria NPC e transferência × inventário token.


#### Completar endpoints de owner: código de acesso

A mesma dependência de `priv.need_owner` (OID 18742) aparece em `public.gm_set_code` (OID 18747), EXECUTE authenticated. A função valida owner/active por `need_owner` e depois altera `campaign_codes` sem lock de campanha. Assim, o antigo proprietário também pode alterar o código de entrada depois de uma transferência concorrente se a autorização tiver sido validada antes da revogação. A matriz de operações owner-first passa a incluir `gm_set_code`, `gm_set_role`, `gm_kick` e `gm_transfer`; o helper não deve ganhar lock implícito sem auditar callers.


### Estado de verificação do bloco owner-admin

A consulta de dependências confirmou que `priv.need_owner` só é chamado por `gm_set_code`, `gm_set_role`, `gm_transfer` e `gm_kick` no catálogo atual. Tratar os quatro na mesma mudança. A suíte sintética atual já cobre corrida de transferência, expulsão após perda de ownership e a incompatibilidade com trigger; acrescentar casos dedicados para mudança de código e alteração de papel antes de aprovar a refatoração. CI #141 (SHA `cf1ba84`) passou integralmente.
