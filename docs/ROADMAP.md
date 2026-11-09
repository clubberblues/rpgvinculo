# Vínculo RPG — Roadmap de execução

## Como ler este roadmap
O roadmap é organizado por dependências e resultados verificáveis, não por quantidade de sessões. Uma fase pode atravessar várias conversas. Sessões são janelas de execução; o projeto e suas prioridades permanecem contínuos.

Nenhuma fase deve ser repetida integralmente sem evidência de mudança ou lacuna.

## Fase 0 — Consolidação e reconciliação
**Estado:** em andamento.
**Objetivo:** criar uma visão confiável a partir das auditorias e documentos existentes.
- [x] Identificar e consolidar README, arquitetura D&D 3.5 e Plano Mestre como referências centrais; reconciliação detalhada do conteúdo segue em andamento.
- [ ] Reconciliar snapshots divergentes de catálogos, funções, migrations e pendências (snapshot atual consolidado; ainda reconciliar cada documento histórico especializado).
- [ ] Completar mapa de dependências entre frontend, RPCs e tabelas (mapa inicial, DATA_MODEL e inventário de 103 RPCs/111 assinaturas criados; falta cruzar todos os argumentos, consumers indiretos e decidir destino de lobby_atualizado/scenes/tokens/combat_state/roll_log).
- [ ] Inventariar testes disponíveis, testes simulados e testes reais por módulo (CI estático criado e aprovado; Playwright/pglast e integração/E2E ainda não estão reproduzíveis no repositório).
- [x] Atualizar o registro de auditorias sem repetir itens já verificados; pendências e evidências centralizadas em AUDIT_REGISTER.md.
- [x] Capturar fotografia somente de leitura do estado remoto do Supabase; contagens, RLS, FKs, triggers, advisors e principais tabelas foram registrados.

**Aceite:** mapa atual sustentado por evidências, divergências explicitadas e lista única de pendências priorizada.

## Fase 1 — Arquitetura e contratos
**Objetivo:** fechar responsabilidades e contratos entre módulos.
- [ ] Confirmar módulos e limites reais (proposta inicial de organização em ARCHITECTURE.md; ainda não implementada).
- [ ] Definir fonte canônica para atributos e valores derivados (DATA_MODEL.md registra fontes atuais e campos pendentes).
- [ ] Definir contratos de ações, resultados, eventos e erros.
- [ ] Definir política de transações, idempotência e concorrência.
- [ ] Definir limites SRD/Vínculo e regras habilitadas por campanha.
- [ ] Definir estratégia de testes e implantação.

**Aceite:** arquitetura-alvo compatível com a aplicação existente e decisões registradas.

## Fase 2 — Fundação operacional
**Objetivo:** assegurar que identidade, autorização, persistência e sincronização suportem os módulos.
- [ ] Validar matriz de papéis Mestre/Jogador/Observador.
- [ ] Avaliar proteção de senha vazada no Auth; 52 índices marcados como não utilizados ficam sem remoção até análise de tráfego e planos.
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
