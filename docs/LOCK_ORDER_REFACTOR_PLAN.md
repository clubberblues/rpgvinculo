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


### Complemento de escopo single-target (2026-11-10)

A inspeção de mesa.html confirmou que Míssil Mágico usa o wrapper autenticado OID 25191 (personagem → ficha → campanha, por helpers internos), enquanto as demais magias manuais single-target usam OID 24658 (personagem → campanha → ficha). Ambos devem entrar na Fase D e ser testados separadamente. Os helpers internos OIDs 24356, 20410 e 24656 não têm EXECUTE autenticado no snapshot; isso não é falha por si só, pois são invocados pelos wrappers SECURITY DEFINER autenticados.


A cura multialvo usa o wrapper autenticado OID 24661, que adquire personagem → campanha antes de delegar ao helper OID 24659, que bloqueia ficha. Não confundir com dano/efeito multialvo (OIDs 25246/25109), que bloqueiam personagem → ficha antes da campanha. A Fase D deve manter contratos de teste separados por branch e reordenar todos os entrypoints para campaign-first, sem depender da ordem herdada pelo wrapper.
