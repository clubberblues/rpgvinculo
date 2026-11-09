# Vínculo RPG — Arquitetura

## Propósito
Consolidar a arquitetura do produto sem apagar ou contradizer os documentos específicos existentes. Este documento descreve a arquitetura atual em alto nível e a arquitetura-alvo. O documento [DND35_RULE_ENGINE_ARCHITECTURE.md](../DND35_RULE_ENGINE_ARCHITECTURE.md) continua sendo a referência especializada do motor de regras D&D 3.5; [PLANO_MESTRE_MESA.md](../PLANO_MESTRE_MESA.md) preserva decisões e requisitos específicos da mesa.

## Princípios arquiteturais
1. **Preservar antes de substituir:** evoluir o sistema existente; refatorações amplas exigem evidência e plano de migração.
2. **Responsabilidade única:** interface apresenta e coleta ações; aplicação coordena casos de uso; motor aplica regras; banco mantém estado persistente e integridade.
3. **Servidor autoritativo:** permissões, turno, recursos, movimentação validada e alterações de estado devem ser confirmados no servidor.
4. **Regras explicáveis:** resultados devem permitir identificar entradas, modificadores, regra aplicada, resultado e recursos consumidos.
5. **Dados separados por domínio:** D&D 3.5 SRD e Vínculo não compartilham catálogos mecanicamente por conveniência.
6. **Compatibilidade controlada:** formatos legados permanecem até existir equivalência comprovada e migração segura.
7. **Integração testável:** cada módulo deve ter contratos e testes isolados e integrados.

## Arquitetura atual — visão conhecida
A aplicação é descrita no README como um conjunto de páginas web HTML, com páginas para entrada/lobby, ficha, mesa e dados. A interface chama serviços/RPCs do Supabase; PostgreSQL mantém campanhas, membros, personagens, fichas, tokens, catálogos e estado de jogo. Realtime e Storage são usados em partes dos fluxos descritos pelo projeto.

O código atual contém lógica distribuída entre páginas HTML/JavaScript, funções SQL/RPCs e estruturas relacionais. O grau exato de separação, duplicação e acoplamento precisa ser confirmado pelo inventário do código atual. Não presumir que a arquitetura conceitual já esteja implementada como módulos isolados.

## Arquitetura-alvo
**Experiência/apresentação:** Lobby · Mesa · Ficha · Dados · Interfaces Mestre/Jogador.

↓ 

**Aplicação/casos de uso:** Campanhas · Sessões · Turnos · Personagens · Inventário · Progressão.

↓

**Domínios e regras:** D&D 3.5 SRD | Regras próprias Vínculo | Regras de campanha.

↓

**Serviços transversais:** Autenticação · Autorização · Validação · Eventos · Realtime · Logs.

↓

**Persistência e infraestrutura:** PostgreSQL · RPCs · RLS · Storage · Supabase · GitHub · Deploy.

As camadas são limites de responsabilidade, não uma ordem para criar serviços separados. A arquitetura pode permanecer em um monólito modular enquanto isso for suficiente. Não adotar microserviços, framework novo ou reescrita do frontend sem necessidade comprovada.

## Módulos de domínio

### Produto e campanha
- Usuários, campanhas, membros e papéis.
- Criação/entrada em campanha e ciclo de vida da sessão.
- Regras e opções habilitadas por campanha.

### Personagens
- Identidade, raça, classe/trilhas, atributos, perícias, talentos e progressão.
- Ficha permanente e valores derivados.
- Propriedade, vínculo com campanha e permissões.

### Equipamentos e inventário
- Catálogo, posse, quantidade, mochila, itens equipados e efeitos.
- Regras de proficiência, mão, categoria, peso e uso.
- Inventário de personagens separado de inventário de tokens quando necessário.

### Motor D&D 3.5
- Fontes/licenças, rulesets, módulos, catálogos e progressões.
- Cálculos e resoluções de combate, testes, condições, magias e recursos.
- Dados insuficientes devem produzir resolução manual explícita, não suposição.

### Regras Vínculo
- Classes, habilidades exclusivas, talentos gerais, magias e recursos próprios.
- Catálogos e fórmulas independentes das regras SRD.

### Mesa virtual
- Cena, mapa, grid, tokens, visão, fog of war e movimentação.
- Iniciativa, turnos, economia de ações, combate e reações.
- Mestre controla criaturas sob sua responsabilidade; jogador mantém controle de suas ações de personagem conforme as regras acordadas.

### Dados e eventos
- Interface de rolagem integrada aos fluxos de jogo.
- Resultados vinculados à ação que os solicitou.
- Log de eventos de jogo e chat livre como responsabilidades distintas.

### Experiência e onboarding
- Tutoriais contextuais, menus, HUD, responsividade e acessibilidade.
- Interface não é fonte autoritativa de regras ou permissões.

## Contratos entre módulos
- A interface envia intenção e entradas explícitas; não é autoridade para decidir sucesso, dano, gasto ou permissão.
- Casos de uso validam identidade, papel, campanha, estado e pré-condições.
- Resolvedores de regras recebem dados explícitos e retornam resultado explicável.
- Operações que alteram recursos relacionados devem ser transacionais.
- Eventos/logs devem referenciar a operação que os originou, evitando duplicação ou perda de contexto.
- Dados publicados em tempo real devem derivar do estado persistido/validado.
- Valores derivados devem ter fonte canônica definida; evitar múltiplas fórmulas independentes em HTML e SQL.

## Segurança e integridade
- RLS em tabelas expostas, com políticas baseadas em propriedade e pertencimento real.
- RPCs privilegiadas com validação explícita de usuário, campanha, papel e alvo.
- SECURITY DEFINER somente quando necessário, com search_path seguro e EXECUTE mínimo.
- Nenhuma chave privilegiada no navegador.
- Operações de combate e recursos devem prevenir repetição, concorrência e consumo duplicado.
- Logs não devem substituir validação de autorização.

## Estratégia de evolução
1. Mapear os módulos reais e seus pontos de acoplamento.
2. Definir contratos antes de mover lógica.
3. Refatorar por fatias verticais pequenas, preservando compatibilidade.
4. Testar o comportamento anterior e o novo.
5. Migrar consumidores e dados somente após equivalência.
6. Remover legado apenas depois de comprovação e plano de rollback.

## Pontos a confirmar no diagnóstico de reconciliação
- Mapa real de dependências entre HTMLs, scripts, RPCs e tabelas.
- Fonte canônica de cada valor mecânico exibido na mesa/ficha.
- Limites atuais entre regras SRD e regras Vínculo.
- Uso efetivo de Realtime e Storage por fluxo.
- Fluxos ainda dependentes de dados JSON/legados.
- Testes automatizados disponíveis e lacunas.
- Estado de deploy e processo de publicação.

## Storage e mídia
Consulte a seção Storage em [INTEGRATION_MAP.md](INTEGRATION_MAP.md): buckets midia público e mesa-media privado, políticas por caminho/campanha e risco P2 de limites MIME/tamanho no bucket público.

## Modelo de dados
Consulte [DATA_MODEL.md](DATA_MODEL.md) para fontes canônicas, relações, estruturas JSONB, compatibilidade e tabelas sem uso atual identificado.

## Mapa detalhado de integração
Consulte [INTEGRATION_MAP.md](INTEGRATION_MAP.md) para o inventário das páginas, fluxos de campanha, ficha, combate, RPCs, tabelas, Realtime e comunicação com o iframe de dados.

## Inventário de contratos RPC
Consulte [RPC_INVENTORY.md](RPC_INVENTORY.md) para nomes literais/dinâmicos, assinaturas, sobrecargas, grants e guardas estáticas.

## Validação automatizada
O primeiro workflow estático foi aprovado: [GitHub Actions run #1](https://github.com/clubberblues/rpgvinculo/actions/runs/42546411046). A cobertura atual é sintaxe de scripts inline/compartilhados e contrato de rolagem manual; integração/E2E ainda não.

## Referências
- [Arquitetura do motor D&D 3.5](../DND35_RULE_ENGINE_ARCHITECTURE.md)
- [Plano Mestre da Mesa Virtual](../PLANO_MESTRE_MESA.md)
- [README e instruções de implantação](../README.md)


## Fotografia da implementação observada — 2026-11-08

Varredura estática dos arquivos principais no HEAD observado:

| Arquivo | Tamanho aproximado | Blocos script | RPCs distintas | Referências .from() | Realtime channel/on |
|---|---:|---:|---:|---:|---:|
| mesa.html | 692 mil caracteres | 5 | 87 | 27 | 9 |
| ficha.html | 362 mil caracteres | 4 | 12 | 31 | 0 |
| lobby.html | 139 mil caracteres | 4 | 10 | 10 | 0 |
| dice.html | 214 mil caracteres | 5 | 0 | 0 | 0 |

As referências .from() são chamadas de acesso a dados/serviços detectadas estaticamente e podem incluir recursos que não são tabelas relacionais. A contagem não substitui análise de cada chamada.

### Consequências arquiteturais observadas
- A mesa concentra a maior quantidade de integrações de RPC e subscriptions Realtime; é o principal ponto de orquestração da sessão de jogo.
- Ficha e lobby também acessam diretamente múltiplos recursos Supabase.
- Os arquivos principais são páginas HTML grandes com scripts inline; portanto, a separação lógica por domínio ainda precisa ser mapeada e não deve ser presumida a partir da arquitetura-alvo.
- A primeira refatoração, se necessária, deve extrair responsabilidades com testes e contratos, sem alterar a experiência ou migrar toda a stack de uma vez.
- dice.html não mostrou chamadas diretas de RPC/tabela na varredura; isso não prova ausência de comunicação indireta por iframe, eventos ou postMessage.

### Banco observado
O snapshot atual mostra 76 relações em public e 7 em priv, com funções distribuídas entre public, priv e private. As tabelas públicas estão todas com RLS habilitado no momento da consulta. A contagem de SECURITY DEFINER é registrada em PROJECT_STATE.md e AUDIT_REGISTER.md; cada função precisa ser avaliada pelo contrato de autorização, não apenas pela classificação.

A varredura identificou 100 nomes literais distintos e 4 call sites dinâmicos em mesa.html, ficha.html e lobby.html. Os quatro dispatches dinâmicos possuem 11 alternativas e 9 alvos únicos (três também aparecem literalmente), resultando em 106 nomes de função distintos e 114 assinaturas públicas correspondentes, incluindo sobrecargas. Isso é correspondência estática; não valida tipos em runtime, semântica, autorização por papel ou execução ponta a ponta.

index.html e lobby_atualizado.html estão presentes no repositório; dex.html não foi encontrado em main no caminho consultado.

Esses números são fotografia de implementação, não arquitetura final nem critério de qualidade isolado.


## Persistência CBA e compatibilidade relacional

A mesa atual usa o estado CBA em campaigns.cba_data (JSONB), com RPCs específicas para adicionar e mover tokens, alterar PV e atualizar cena. O schema também conserva public.tokens e public.monster_instances, utilizados por RPCs relacionais antigas (movimento, ataque, dano, turno e inclusão de monstros). Os resolvedores de condições e efeitos aceitam alvos encontrados tanto no array JSON CBA quanto no modelo relacional.

Esse desenho deve ser tratado como coexistência/compatibilidade até que todos os consumidores e dados sejam mapeados. Não remover a tabela relacional nem migrar tokens para JSON ou vice-versa sem plano, equivalência, backfill, testes e rollback.


## Estado de reconciliação — 2026-11-08

| Ponto a confirmar | Estado atual |
|---|---|
| Dependências entre HTML, RPCs e tabelas | Mapa inicial e inventário RPC criados; argumentos de todos os fluxos ainda não conferidos |
| Fonte canônica dos valores mecânicos | DATA_MODEL documenta principais fontes; XP/ouro e alguns campos JSONB ainda precisam de decisão |
| Limites SRD/Vínculo | Separação de catálogos e fichas mapeada; não unificar regras |
| Realtime e Storage | 9 subscriptions mapeadas com filtros e policies; fluxos Storage de mídia/exclusão ainda exigem E2E |
| Dados JSON/legados | CBA JSONB vs tabelas relacionais, combate JSONB vs combat_state e campaign_log vs roll_log registrados |
| Testes | CI estático aprovado; Playwright/pglast e integração/E2E não reproduzíveis no repositório |
| Deploy/publicação | Processo de publicação ainda precisa de confirmação e checklist |


## Organização de código proposta — ainda não implementada

Manter as páginas de entrada na raiz para preservar URLs e publicação estática:
- index.html
- lobby.html
- ficha.html
- mesa.html
- dice.html

Extrair responsabilidades gradualmente para módulos locais, sem mover as páginas de entrada:

```text
assets/js/
  core/
    supabase-client.js
    auth-context.js
    rpc-client.js
    errors.js
  application/
    campaigns/
    characters/
    inventory/
    combat/
    movement/
    spells/
  domain/
    shared/
    srd35/
    vinculo/
  infrastructure/
    supabase/
      repositories/
      realtime/
      storage/
  ui/
    dialogs/
    components/
tests/
  static/
  domain/
  integration/
  e2e/
```

### Limites de responsabilidade
- **pages:** montagem da tela, eventos de UI e apresentação.
- **application:** casos de uso e orquestração entre módulos.
- **domain/srd35:** regras D&D 3.5 puras/explicáveis, sem acesso direto ao DOM.
- **domain/vinculo:** regras próprias Vínculo, sem importar regras SRD.
- **infrastructure:** cliente Supabase, RPC adapters, queries, Realtime e Storage.
- **core:** identidade, contexto de campanha, erros e contratos comuns.
- **tests:** validação estática, regras isoladas, integração com banco e E2E.

### Ordem de extração
1. Centralizar inicialização/configuração Supabase e contexto de autenticação depois de mapear diferenças de sessão entre páginas.
2. Criar adaptadores RPC tipados por fluxo, sem mudar as funções SQL.
3. Extrair utilitários compartilhados e eventos do iframe Dice.
4. Extrair casos de uso da mesa por fatias (iniciativa, movimento, ataque, magia).
5. Extrair regras puras e adicionar testes antes de mover cálculos do cliente.
6. Migrar cada página gradualmente para os adaptadores, mantendo fallback/compatibilidade até a validação.

Não introduzir framework, TypeScript, bundler ou microserviços como pré-requisito. A decisão depende de benefício mensurável e de um caminho de deploy testável.


### Inicialização Supabase observada
Cada página ativa cria sua própria instância do cliente; não há módulo compartilhado de auth/RPC. O CDN @supabase/supabase-js@2 e a configuração do projeto são repetidos. A extração de um cliente compartilhado é uma possível primeira refatoração, mas deve ocorrer somente após comparar auth options, guards e ciclo de sessão por página; não alterar a sessão em lote.


## Versionamento e implantação — controle temporário
O histórico remoto do projeto conectado contém 966 migrations aplicadas; o repositório main contém 681 arquivos em `supabase/migrations/`. A diferença de 285 exige reconciliação por versão e comparação do schema efetivo antes de considerar o diretório como fonte completa de reconstrução. Até lá, produção não deve ser resetada, reconstruída ou receber deploy automático baseado apenas no diretório atual. O snapshot remoto e a classificação de drift passam a ser entregáveis da Fase 1/2.


## Reconciliação exata do histórico de migrations — 2026-11-09

Comparação somente de leitura entre a árvore recursiva de `main` e `supabase_migrations.schema_migrations` no projeto remoto conectado:
- Arquivos locais em `supabase/migrations/`: **681**.
- Registros remotos aplicados: **966**.
- Versões exatamente coincidentes: **640**; nos 640 casos, o nome também coincide.
- Registros remotos sem arquivo local com a mesma versão: **326**.
- Arquivos locais sem registro remoto com a mesma versão: **41**.
- Entre esses dois conjuntos, **41 pares** compartilham o mesmo nome, mas têm timestamps diferentes. Assim, existem **285 nomes remotos sem arquivo local de mesmo nome** e **2 nomes locais sem registro remoto correspondente**.

Distribuição dos 326 registros remotos sem versão local: 2026-11-04: 36; 2026-11-05: 41; 2026-11-08: 232; 2026-11-09: 17. Os 41 arquivos locais sem versão remota são 30 em 2026-11-04 e 11 em 2026-11-05. Os dois nomes locais sem qualquer nome remoto correspondente são `dwarf_barbarian_n1_racial_movement_fixes` e `dwarf_armor_load_classification`.

**Interpretação:** a diferença líquida de 285 não representa, por si só, 285 arquivos simplesmente removidos. Há versões com timestamps reescritos, 285 migrações remotas sem arquivo de mesmo nome e dois arquivos locais sem contraparte remota. Os nomes coincidentes não provam equivalência do SQL; a comparação de conteúdo/efeitos ainda não foi realizada. O histórico remoto registra versão e nome, não o texto SQL original.

**Decisão de segurança:** manter bloqueados reset, deploy automático, squash e reconstrução do banco. Próxima etapa: inventariar o schema remoto efetivo (DDL, funções, constraints, índices, triggers, policies, grants, enums, extensões e schemas), identificar quais objetos correspondem às migrações sem arquivo e elaborar um baseline reproduzível revisado. Nenhum DDL ou dado de jogo foi alterado nesta etapa.


## Inventário estrutural inicial do schema remoto — 2026-11-09

Consulta somente de leitura ao catálogo PostgreSQL, restrita às relações/funções dos schemas public, priv e private:
- 83 relações: 76 public + 7 priv; 81 com RLS habilitado (76/76 public e 5/7 priv).
- 327 funções: 225 public, 94 priv e 8 private; 246 SECURITY DEFINER no conjunto desses schemas.
- 378 constraints, 14 triggers não internos e 114 policies nos três schemas consultados.
- 5 extensões instaladas: pg_stat_statements, pgcrypto, plpgsql, supabase_vault e uuid-ossp. Nenhum enum foi encontrado nos três schemas consultados.
- Privilégio USAGE: anon não tem USAGE em priv/private; authenticated tem USAGE em ambos. Isso não comprova se os schemas estão expostos no PostgREST; a configuração de Exposed schemas continua pendente de confirmação no Dashboard.

Este é um inventário estrutural agregado, não um snapshot DDL nem uma revisão semântica. As 378 constraints, 14 triggers, 114 policies e 327 funções ainda precisam ser exportadas/classificadas por objeto e comparadas com os arquivos versionados. Não houve alteração de schema, ACL, policies, triggers ou dados.


## Snapshot estrutural remoto

O inventário descritivo de relações/colunas, índices e assinaturas/fingerprints das funções foi registrado em [REMOTE_SCHEMA_SNAPSHOT.md](REMOTE_SCHEMA_SNAPSHOT.md). Ele é uma referência de comparação, não um dump restaurável nem uma migration. Os detalhes de ACL, policies, triggers e corpos SQL seguem em revisão.


### Duplicidade de nomes no histórico remoto
A comparação também identificou dois nomes de migration repetidos em versões remotas distintas: `srd35_sneak_attack_damage_validation` e `srd35_rogue_uncanny_dodge_catalog_status` (duas ocorrências cada). Portanto, os 41 registros remotos que compartilham nome com arquivos locais correspondem a 39 nomes únicos, não a 41 pares um-para-um. Isso reforça que nome não é chave de equivalência; a reconciliação precisa considerar versão, conteúdo/efeito e ordem de aplicação.


O mapeamento exato de versões locais/remotas e todos os registros divergentes está em [MIGRATION_RECONCILIATION.md](MIGRATION_RECONCILIATION.md); o snapshot de objetos atuais está em [REMOTE_SCHEMA_SNAPSHOT.md](REMOTE_SCHEMA_SNAPSHOT.md).


## Exportação de definições atuais

As definições remotas atuais dos subsistemas AOO e movimento/turnos foram preservadas em [REMOTE_AOO_FUNCTIONS.sql.md](REMOTE_AOO_FUNCTIONS.sql.md) e [REMOTE_TURN_MOVEMENT_FUNCTIONS.md](REMOTE_TURN_MOVEMENT_FUNCTIONS.md). A reconciliação de histórico AOO está em [AOO_RECONCILIATION.md](AOO_RECONCILIATION.md). Estes documentos preservam o estado observável atual e fingerprints, mas não substituem o SQL original das migrations nem são um dump restaurável.


## Invariante de movimento e AOO
A detecção de ataques de oportunidade e a persistência do movimento devem ocorrer sob o mesmo lock/transação autoritativa. Um pré-check de frontend separado não é barreira de segurança: qualquer RPC autenticada que persista coordenadas precisa repetir a detecção/validar um ticket de movimento assinado e de uso único. A RPC direta de movimento atual não integra o detector, criando bypass e janela TOCTOU. A correção deve unificar o fluxo ou introduzir protocolo transacional de reserva/commit, sem permitir consumo de ação ou movimento antes da resolução das reações.


A existência de qualquer movimento AOO em estado ativo deve serializar a movimentação da campanha, não apenas congelar o token que provocou o movimento. As RPCs de movimento precisam verificar a fila pending dentro do mesmo lock de campanha, impedir movimentos paralelos de outros tokens e executar a detecção AOO no caminho autoritativo.


## Drift de implementação: movimento
As migrations locais 20261108134918 e 20261108135111 fazem patch textual nos corpos de `public.mover_token_player_cba` e `public.mover_token_gm_cba_srd`. O remoto atual usa wrappers SECURITY INVOKER que delegam para `priv.mover_token_player_cba_impl` e `priv.mover_token_gm_cba_srd_impl`; a extração foi registrada em migrations remotas sem arquivo local (20261108194444, 20261108195245, 20261108214901). A baseline precisa refletir a arquitetura final, não apenas reaplicar os patches locais.


## Arquitetura de qualidade e entrega

O diagnóstico dos quatro workflows e a arquitetura-alvo de CI/testes estão em [CI_TEST_ARCHITECTURE.md](CI_TEST_ARCHITECTURE.md). A prioridade é adicionar validação SQL/RPC/RLS em ambiente descartável após a reconciliação do baseline, preservando os testes existentes de dado manual e smoke test Pages.


## Exportação integral das funções/procedures remotas — 2026-11-09

As 327 definições atuais retornadas por `pg_get_functiondef` foram exportadas em arquivos SQL separados por schema:
- `docs/snapshots/remote_public_functions.sql` — 225 definições.
- `docs/snapshots/remote_priv_functions.sql` — 94 definições.
- `docs/snapshots/remote_private_functions.sql` — 8 definições.

Total exportado: 1.216.018 caracteres de definições (sem cabeçalhos). Isso fecha a captura dos corpos das rotinas atuais, mas **não** transforma o conjunto em dump restaurável: tabelas, tipos, extensões, owners, ACLs, policies, triggers, constraints, índices e ordem de dependência continuam sendo reconciliados em separado. Os arquivos são snapshots de referência; não executar diretamente como migration.


## Storage e mídia — snapshot de policies

O inventário de buckets, allowlists MIME, policies e funções de caminho está em [STORAGE_POLICIES_SNAPSHOT.md](STORAGE_POLICIES_SNAPSHOT.md). Não foram lidos objetos de usuários nem alteradas policies/buckets.


## Invariante de geometria de tokens
Toda regra de ocupação, colisão, distância, alcance, ataque e AOO deve usar um único cálculo canônico de footprint (`priv.srd_token_grid_footprint`). Para Colossal, o footprint é 6×6 (30 ft); não manter CASEs locais divergentes nas RPCs. A auditoria encontrou implementações que usam 5×5 em movimento/ataque enquanto o helper e o detector AOO usam 6×6.


## Autoridade de escrita do CBA — decisão arquitetural 2026-11-09

`campaigns.cba_data` é estado autoritativo da cena, mas não deve ser tratado como documento substituível livremente pelo cliente durante combate. As RPCs de movimento/combate atualizam tokens no servidor; um snapshot completo enviado depois pode sobrescrever essas alterações.

### Separação obrigatória de comandos

- **Metadados de cena:** fundo, escala, grade, opacidade e layout. Não podem alterar coordenadas nem estado de combate dos tokens.
- **Spawn/remoção:** operações explícitas, com papel GM, identidade única, limites, footprint e ocupação validados no servidor.
- **Metadados de ficha/token:** operações explícitas com allowlist de campos; não podem sobrescrever PV, posição, equipamento ou estado autoritativo mais recente por snapshot obsoleto.
- **Movimento:** somente RPCs server-authoritative, com turno, ação, deslocamento, condições, ocupação, footprint e AOO verificados na mesma transação.
- **Resolução AOO:** a pendência é global por campanha; enquanto ativa, nenhum outro movimento ou escrita genérica pode alterar posições relevantes. O commit usa apenas o pending ID e o destino validados pelo fluxo interno.

### Estado legado e transição

`public.salvar_cena_cba` atualmente aceita snapshot de tokens, substitui objetos existentes e não valida mudança de coordenadas, ocupação, pending AOO ou versão do estado. O frontend usa a função em fluxos legítimos durante combate, então não pode ser removida/bloqueada isoladamente. A transição precisa migrar os call sites para comandos específicos antes de restringir o endpoint legado.

A gravação deve usar versão gerada no servidor (cena/token) ou comandos por intenção com merge de campos autorizados. Um lock `FOR UPDATE` sozinho não impede lost update quando o payload já chega obsoleto.

**Status:** contrato arquitetural aprovado para orientar a correção; implementação pendente de fixtures e regressões gratuitas. Nenhuma mudança foi aplicada ao banco ou ao frontend nesta etapa.
