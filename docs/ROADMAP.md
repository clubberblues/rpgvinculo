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
- [ ] Definir política implementável de transações, idempotência e concorrência (locks e idempotência de ataques/pending já mapeados; revisar avanço de turno e conjuração manual).
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
- [ ] Reconciliar 681 arquivos locais em supabase/migrations com 966 registros remotos em supabase_migrations.schema_migrations (diferença de contagem: 285).
- [ ] Comparar versão por versão; não inferir arquivos ausentes somente pela diferença de contagem.
- [ ] Capturar DDL remoto completo e classificar drift de funções, tabelas, constraints, policies, grants, triggers, extensões e schemas.
- [ ] Recuperar/gerar migrations reproduzíveis a partir do estado atual somente após revisão de segurança e dependências.
- [ ] Estabelecer CI que detecte migration local ausente, versão duplicada e divergência de schema antes de qualquer deploy.
- [ ] Definir procedimento de deploy/rollback e ambiente local descartável.

**Regra temporária:** não executar `supabase db reset`, deploy automático de migrations, reconstrução de banco ou squash do histórico até o aceite desta reconciliação.
