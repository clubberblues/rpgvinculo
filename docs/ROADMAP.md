# Vínculo RPG — Roadmap de execução

## Como ler este roadmap
O roadmap é organizado por dependências e resultados verificáveis, não por quantidade de sessões. Uma fase pode atravessar várias conversas. Sessões são janelas de execução; o projeto e suas prioridades permanecem contínuos.

Nenhuma fase deve ser repetida integralmente sem evidência de mudança ou lacuna.

## Fase 0 — Consolidação e reconciliação
**Estado:** concluída como baseline arquitetural; lacunas remanescentes foram explicitadas e transferidas às fases seguintes.
**Objetivo:** criar uma visão confiável a partir das auditorias e documentos existentes.
- [x] Identificar e consolidar README, arquitetura D&D 3.5 e Plano Mestre como referências centrais; reconciliação detalhada do conteúdo segue em andamento.
- [x] Consolidar fotografia atual de catálogos, funções, migrations e pendências; snapshots históricos divergentes estão registrados com data/critério e não foram apagados.
- [x] Mapear fluxos prioritários e registrar dependências frontend/RPC/tabelas; criados INTEGRATION_MAP, DATA_MODEL e inventário atualizado de 106 nomes de função/114 assinaturas públicas. Argumentos e consumidores externos restantes viram tarefas por fluxo nas fases 1–2; candidatos a legado estão documentados.
- [x] Inventariar o estado conhecido dos testes e criar CI estático aprovado; Playwright/pglast e integração/E2E ausentes ou não reproduzíveis estão registrados como lacunas da Fase 2.
- [x] Atualizar o registro de auditorias sem repetir itens já verificados; pendências e evidências centralizadas em AUDIT_REGISTER.md.
- [x] Capturar fotografia somente de leitura do estado remoto do Supabase; contagens, RLS, FKs, triggers, advisors e principais tabelas foram registrados.

**Aceite atingido:** mapa atual sustentado por evidências, divergências explicitadas e lista única de pendências priorizada. A conclusão da Fase 0 não significa que todos os módulos foram auditados funcionalmente.

## Fase 1 — Arquitetura e contratos
**Estado:** em andamento.
**Objetivo:** fechar responsabilidades e contratos entre módulos.
- [x] Definir proposta inicial de módulos e limites no ARCHITECTURE.md (ainda não implementada no código).
- [x] Mapear fontes canônicas atuais e registrar campos pendentes em DATA_MODEL.md; [ ] fechar decisões restantes de XP/ouro e valores derivados.
- [x] Criar proposta inicial de ActionRequest/ActionResult, catálogo inicial de erros/eventos e estratégia de adoção em ACTION_CONTRACTS.md; ainda não implementada e decisões de persistência/versionamento permanecem abertas.
- [ ] Fechar contratos por fluxo e cruzamento completo de argumentos/tipos JavaScript ↔ PostgreSQL.
- [ ] Definir política implementável de transações, idempotência e concorrência (auditoria de locks e proposta faseada registradas em [LOCK_ORDER_PROTOCOL_DRAFT.md](LOCK_ORDER_PROTOCOL_DRAFT.md) e [LOCK_ORDER_REFACTOR_PLAN.md](LOCK_ORDER_REFACTOR_PLAN.md); ainda falta fechar grafo transitivo, ordem por domínio, integração real e migração segura).
- [x] Definir limites de domínio SRD/Vínculo e separar catálogos/regras.
- [ ] Fechar estratégia de testes e implantação (CI estático é a primeira camada; integração/E2E e deploy permanecem pendentes).
- [x] Registrar proposta inicial de contratos de ação e resultado em [ACTION_CONTRACTS.md](ACTION_CONTRACTS.md), sem alterar contratos RPC existentes.

**Aceite:** arquitetura-alvo compatível com a aplicação existente e decisões registradas.

## Fase 2 — Fundação operacional
**Objetivo:** assegurar que identidade, autorização, persistência e sincronização suportem os módulos.
- [ ] Validar matriz de papéis Mestre/Jogador/Observador.
- [ ] Avaliar proteção de senha vazada no Auth; revisar limites MIME/tamanho do bucket midia; 52 índices marcados como não utilizados ficam sem remoção até análise de tráfego e planos.
- [ ] Validar RLS, RPCs e propriedade por fluxo; priorizar revisão individual das 99 SECURITY DEFINER acessíveis a authenticated e confirmar exposição dos schemas internos priv/private.
- [ ] Validar integridade relacional e transações críticas.
- [ ] Validar eventos, logs, Realtime e recuperação de estado.
- [ ] Estabelecer ambiente/campanha descartável e contas de teste.
- [ ] Automatizar verificações de regressão disponíveis.

**Aceite:** operações críticas seguras e repetíveis em ambiente de teste, sem alterar campanhas reais.

## Fase 3 — Motor de regras
**Objetivo:** consolidar regras reutilizáveis e autoritativas.
Ordem interna por dependências:
1. Atributos, modificadores e valores derivados.
2. BBA, resistências, perícias e talentos.
3. Equipamentos, armaduras, armas e proficiências.
4. Condições e modificadores tipados.
5. Ações, movimento, iniciativa e economia de ações.
6. Ataques, CA, crítico, dano, RD e resistências.
7. Magias: preparação/conhecidas, espaços, salvamentos, resistência à magia e efeitos.
8. Habilidades raciais, classes, níveis e recursos.
9. Manobras, flanqueamento, ataques de oportunidade e regras especiais.

**Aceite:** matriz de regras e casos por módulo aprovados; lacunas explícitas encaminhadas ao Mestre, sem resolução inventada.

## Fase 4 — Sistemas de personagem
- [ ] Criação e edição de ficha.
- [ ] Progressão e avanço de nível.
- [ ] Raça, classe, trilhas e características por nível.
- [ ] Perícias, talentos e pré-requisitos.
- [ ] Inventário, equipamento, carga e proficiência.
- [ ] Grimório, magias conhecidas/preparadas, domínios e recursos.
- [ ] Descanso, recuperação e sincronização com tokens.

**Aceite:** ciclo de vida do personagem validado da criação ao avanço e uso na mesa.

## Fase 5 — Mesa virtual e multiplayer
- [ ] Preparação de cena, mapa e grid.
- [ ] Tokens, tamanhos, ocupação e movimentação.
- [ ] Fog of war e visibilidade por jogador.
- [ ] Iniciativa e ordem do turno.
- [ ] Ações, reações e combate.
- [ ] Integração com dados manuais.
- [ ] Chat, log e eventos de jogo.
- [ ] Sincronização de Mestre e múltiplos jogadores.

**Aceite:** sessão completa de exploração e combate validada em contas autenticadas simultâneas.

## Fase 6 — Experiência e qualidade
- [ ] Onboarding contextual por papel e etapa.
- [ ] Menus e controles contextuais consistentes.
- [ ] Responsividade desktop/mobile.
- [ ] Acessibilidade e movimento reduzido.
- [ ] Desempenho e recuperação de falhas.
- [ ] Observabilidade e mensagens de erro úteis.

**Aceite:** experiência completa utilizável sem depender de conhecimento interno do projeto.

## Fase 7 — Estabilização e publicação
- [ ] Regressão integral.
- [ ] Revisão de segurança.
- [ ] Testes de carga compatíveis com a escala pretendida.
- [ ] Backup e recuperação.
- [ ] Procedimento de deploy/rollback.
- [ ] Documentação de operação e suporte.
- [ ] Checklist de liberação.

**Aceite:** critérios de lançamento atendidos e limitações conhecidas documentadas.

## Bloqueio P1 do motor de movimento — 2026-11-10

A autoridade de movimento AOO precisa ser corrigida antes de ampliar combate: os endpoints autenticados de movimento direto do jogador e do Mestre podem gravar coordenadas sem passar pela solicitação AOO; o fluxo sem ameaça ainda separa detecção e commit em duas transações (TOCTOU). O frontend faz a sequência correta no fluxo normal, mas o servidor não a impõe. Além dos wrappers diretos, `salvar_cena_cba` (OID 20077) aceita atualização geral de `cba_data`; a guarda usa `LIMIT 1`, permite duplicidade de identidade e não protege a geometria de outros tokens nem os campos que definem ameaças. Spawn (OID 21726), perfil de combate (OID 26922) e equipamento (OIDs 20555/20556) também podem alterar o conjunto de ameaças durante pending. O snapshot não fixa a instância de arma que originou a ameaça; o Encontrão com acompanhamento pode ser rejeitado pelo guard. Footprint Colossal=5 persiste também em ataques físicos (OIDs 24744/25562) e toque/Imposição das Mãos (OID 25509), enquanto helper/detector usam 6. O reproducer isolado em `tests/sql/aoo_guard_duplicate_identity_repro.sql` passou em CI e confirmou a duplicata e mudança de outro token, mas copia o trigger e não executa RPCs remotas. Evidência e critérios em [MOVEMENT_AOO_AUTHORITY_GAP.md](MOVEMENT_AOO_AUTHORITY_GAP.md).

**Prioridade da Fase 3:** tratar a unificação server-side de detecção AOO + pending + commit e o footprint compartilhado como bloqueio P1 do módulo de movimento. Fechar antes a ordem parcial de locks com pending/attack/ficha; recuperar baseline porque 72 de 81 migrations remotas de movimento/manobras/AOO não têm arquivo local da mesma versão. Não aplicar migration remota enquanto a reconciliação do histórico não tiver aceite.

## Priorização de descobertas
- **P0:** segurança, perda/corrupção de dados, exposição indevida.
- **P1:** bloqueio de fluxo essencial ou falha que impede uso.
- **P2:** erro mecânico, cálculo ou integração relevante.
- **P3:** arquitetura, manutenção, desempenho e dívida técnica sem bloqueio imediato.
- **P4:** refinamento visual e melhorias opcionais.

Uma descoberta só interrompe a tarefa atual se for P0, P1, dependência direta ou risco de regressão da mudança em curso. Caso contrário, é registrada e priorizada no roadmap.

## Regras de mudança de escopo
- Não iniciar funcionalidades fora da fase atual sem dependência ou decisão explícita.
- Uma correção deve ser classificada e ligada a um módulo/critério de aceite.
- Replanejar quando nova evidência alterar dependências, riscos ou prioridade — não por curiosidade isolada.
- Não marcar uma fase concluída enquanto houver critérios de aceite pendentes.


## Continuidade de execução — 2026-11-09
- A proposta de contratos comuns foi registrada em ACTION_CONTRACTS.md. O documento distingue proposta arquitetural de implementação e proíbe migração especulativa.
- Próximo bloqueio externo: confirmar no Dashboard a lista de Exposed schemas da API; o conector e pg_settings não forneceram esse dado.
- Próxima execução técnica: completar análise estática dos contratos JS ↔ RPC e mapear divergências de idempotência; nenhuma alteração de comportamento até concluir essa etapa.


## Escopo e prioridade do caminho legado Vínculo — 2026-11-09
A divergência de nomes em ficha.html foi classificada como rota latente: o banco tem 5 personagens, todos SRD, nenhum com ficha Vínculo; o lobby atual cria fichas com ruleset=dnd35. Não alterar o ramo legado sem decisão de produto e sem fixture Vínculo descartável. A prioridade da Fase 1 permanece concluir arquitetura/contratos do fluxo ativo D&D 3.5 + mesa; manter o domínio Vínculo documentado como separado, sem misturar catálogos.


## Prioridade técnica identificada — lock order de AOO — 2026-11-09
Antes da primeira refatoração, fechar a matriz de locks do combate. Achado prioritário: potencial deadlock por inversão de ordem entre cancelamento de movimento AOO (pending → attacks) e aplicação de dano/resolução (attack → pending). Exige teste concorrente em fixture descartável; não alterar RPC de produção sem reproduzir e validar rollback.


### Bloqueio de infraestrutura identificado — histórico de migrations
**Prioridade:** P1 para confiabilidade de implantação / P0 se houver tentativa de reconstrução ou deploy cego.
- [x] Comparar exatamente as versões locais e remotas: 681 arquivos locais, 966 registros remotos, 640 versões coincidentes, 326 remotas sem versão local e 41 locais sem versão remota. Desses conjuntos, 41 pares têm o mesmo nome em timestamps diferentes; restam 285 nomes remotos sem arquivo local de mesmo nome e 2 nomes locais sem contraparte remota. Nomes coincidentes não comprovam equivalência do SQL.
- [x] Capturar inventário estrutural remoto inicial (83 relações, 229 índices, 327 assinaturas/fingerprints) em REMOTE_SCHEMA_SNAPSHOT.md.
- [ ] Exportar DDL executável completo e classificar drift de funções, tabelas, constraints, policies, grants, triggers, extensões e schemas.
- [ ] Recuperar/gerar migrations reproduzíveis a partir do estado atual somente após revisão de segurança e dependências.
- [ ] Estabelecer CI que detecte migration local ausente, versão duplicada e divergência de schema antes de qualquer deploy.
- [ ] Definir procedimento de deploy/rollback e ambiente local descartável.

**Regra temporária:** não executar `supabase db reset`, deploy automático de migrations, reconstrução de banco ou squash do histórico até o aceite desta reconciliação.


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


### Duplicidade de nomes no histórico remoto
A comparação também identificou dois nomes de migration repetidos em versões remotas distintas: `srd35_sneak_attack_damage_validation` e `srd35_rogue_uncanny_dodge_catalog_status` (duas ocorrências cada). Portanto, os 41 registros remotos que compartilham nome com arquivos locais correspondem a 39 nomes únicos, não a 41 pares um-para-um. Isso reforça que nome não é chave de equivalência; a reconciliação precisa considerar versão, conteúdo/efeito e ordem de aplicação.


## Configuração local e higiene de migrations — 2026-11-09

A árvore atual de `main` contém 681 arquivos SQL em `supabase/migrations/`, sem timestamps duplicados. Um arquivo foge ao padrão ASCII de nome por conter acento: `20261102052430_srd35_skill_natação_verification.sql`. Não foi renomeado para evitar alteração desnecessária durante a reconciliação. Também não há `supabase/config.toml`, `package.json`, diretório `tests/` ou configuração Playwright/Vitest/Jest no repositório. Existem quatro workflows GitHub Actions e scripts em `scripts/`; o smoke test instala Playwright explicitamente no workflow. A ausência de config local limita a reprodutibilidade por Supabase CLI, mas não prova ausência de scripts externos ou configuração em outro ambiente.



## Privilégios padrão do schema interno priv — 2026-11-09

A inspeção de `pg_default_acl` identificou privilégios padrão permissivos para objetos futuros criados pelo owner postgres em `priv`: authenticated recebe SELECT/INSERT/UPDATE/DELETE/TRUNCATE/REFERENCES/TRIGGER/MAINTAIN em futuras tabelas, SELECT/USAGE/UPDATE em sequences e EXECUTE em futuras funções. service_role também recebe privilégios administrativos. Não há default ACL personalizado em `private`.

As relações internas existentes foram individualmente configuradas sem privilégios diretos para anon/authenticated, e as funções existentes passaram por revisão de search_path; portanto, o achado é **risco preventivo para novos objetos**, não evidência de acesso direto atual. Se `priv` estiver exposto no PostgREST, o risco é maior. A configuração Exposed schemas ainda precisa ser confirmada.

**Ação proposta, não executada:** restringir default privileges de authenticated em `priv` (tabelas/sequences/funções) e conceder EXECUTE explicitamente apenas aos helpers internos chamados por wrappers SECURITY INVOKER. Não aplicar antes de reconciliar o histórico e mapear todas as dependências; a alteração de defaults sem grants pontuais pode quebrar chamadas legítimas. Nenhuma ACL foi alterada.


### Arquivos locais sem contraparte remota nominal — análise preliminar
Os dois arquivos locais sem nome remoto correspondente foram inspecionados. `20261104190000_dwarf_barbarian_n1_racial_movement_fixes.sql` declara quatro funções; `20261104194500_dwarf_armor_load_classification.sql` declara uma função de deslocamento. As definições atuais dessas funções no banco não são idênticas aos corpos encontrados nesses arquivos. Há migrations remotas com nomes relacionados (por exemplo, correções de movimento/armadura e resistências raciais), mas ainda não foi demonstrada equivalência completa nem ordem de substituição. Manter os arquivos como evidência histórica; não renomear, excluir ou marcar como aplicados sem reconstruir o efeito por função.


Inventário detalhado da divergência de migrations (listas de todas as versões sem correspondência exata) registrado em [MIGRATION_RECONCILIATION.md](MIGRATION_RECONCILIATION.md).


## Próximo lote de auditoria — funções remotas

- [x] Exportar definições atuais do subsistema AOO (37 funções).
- [x] Exportar definições de movimento, economia de ações, iniciativa e turnos (41 funções).
- [x] Registrar reconciliação focal das 51 migrations remotas de AOO/movimento pendente sem arquivo local de mesmo nome.
- [ ] Comparar a ordem de locks transitiva de todas as RPCs de combate e movimento, incluindo helpers privados.
- [ ] Fechar matriz de autorização por papel e fluxo frontend→RPC para as funções com authenticated EXECUTE.
- [ ] Reproduzir concorrência cancelamento AOO × resolução/dano em ambiente descartável após baseline.


### Bloqueio P1 descoberto — autoridade do movimento/AOO
Unificar detecção AOO e persistência de movimento na mesma RPC/transação. O frontend hoje chama pré-check AOO e depois RPC de movimento separada; a RPC de movimento autenticada pode ser chamada diretamente e não reexecuta o detector. Não corrigir até ter fixture descartável e testes de regressão; tratar como prioridade antes de ampliar testes de combate.


## Segurança — triagem SECURITY DEFINER — 2026-11-09

O advisor sinaliza 99 funções públicas SECURITY DEFINER executáveis por authenticated. A triagem está em [SECURITY_DEFINER_REVIEW.md](SECURITY_DEFINER_REVIEW.md): 0 EXECUTE para anon, 99/99 com search_path explícito e pg_temp, e padrões diretos/delegados de autenticação/autorização presentes nos corpos. A revisão semântica de autorização segue pendente; não revogar nem converter em lote.


## CI e testes — diagnóstico atual — 2026-11-09

Quatro workflows atuais cobrem sintaxe JavaScript, invariantes do dado manual e smoke test HTTP de GitHub Pages, mas não há validação SQL, pgTAP, RPC autenticado, RLS ou concorrência. O desenho atual/alvo e a sequência de implantação estão em [CI_TEST_ARCHITECTURE.md](CI_TEST_ARCHITECTURE.md). Consolidar workflows somente depois de preservar os gatilhos/cobertura existentes.


## Storage e mídia

Snapshot de buckets/policies criado em [STORAGE_POLICIES_SNAPSHOT.md](STORAGE_POLICIES_SNAPSHOT.md). A revisão identificou bucket público `midia` sem limite/allowlist MIME configurados e bucket privado `mesa-media` com SVG/áudio/vídeo permitidos; alterações ficam pendentes de revisão de compatibilidade.


### P2 — unificar footprint de criaturas Colossais
A geometria atual diverge: helper canônico/AOO usam 6, mas os dois RPCs de movimento, duas sobrecargas de ataque e Imposição de Mãos contra mortos-vivos usam 5. Corrigir para 6 e centralizar no helper `priv.srd_token_grid_footprint` após baseline e fixture. Testes descritos em TEST_STRATEGY.md.
