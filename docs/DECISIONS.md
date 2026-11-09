# Vínculo RPG — Registro de decisões

Este documento registra decisões que devem sobreviver às sessões. Decisões novas devem incluir data, contexto, escolha e consequências. Uma decisão só muda mediante evidência ou confirmação do proprietário quando afetar requisito de produto.

## Decisões de produto e escopo

### DEC-001 — Evoluir a aplicação existente
- **Decisão:** preservar e evoluir o repositório e o banco existentes; não reconstruir a aplicação do zero.
- **Motivo:** preservar investimento, dados, fluxos e comportamento já implementados.
- **Consequência:** refatorações devem ser incrementais e compatíveis.

### DEC-002 — Domínios de regras separados
- **Decisão:** D&D 3.5 SRD e regras próprias do Vínculo permanecem em catálogos e modelos separados (srd_* e vinculo_*).
- **Motivo:** evitar mistura de progressões, fórmulas, talentos, magias e recursos de sistemas diferentes.
- **Consequência:** integração visual não significa compartilhar regras mecanicamente.

### DEC-003 — Servidor como autoridade
- **Decisão:** permissões, turno, consumo de recursos, validação de movimento e persistência são validados no servidor.
- **Motivo:** o navegador não pode decidir sozinho resultados ou autorizações.
- **Consequência:** prévias no cliente são informativas; RPC/serviço valida e grava o resultado final.

### DEC-004 — Dados manuais do jogador
- **Decisão:** ações de jogadores que exigem rolagem devem solicitar rolagem pela interface de dados; o sistema não gera automaticamente um d20 oculto para substituir a rolagem do jogador.
- **Decisão complementar:** o fluxo de iniciativa convoca os jogadores a rolar seus próprios dados. O Mestre rola dados para NPCs/monstros sob seu controle; resultados múltiplos devem ser associados uma única vez aos tokens selecionados, não aos personagens dos jogadores.
- **Motivo:** preservar a experiência de rolagem de mesa e a transparência.
- **Consequência:** o fluxo aguarda as rolagens exigidas antes de avançar. O Dice iframe gera o resultado após clique e devolve-o por postMessage; os resolvers de ação recebem os valores manuais. O RPC público roll_dice, que gera resultados no servidor, não está conectado às páginas ativas no snapshot e não deve ser usado para ações de personagem sem decisão explícita.

### DEC-005 — Controle de tokens
- **Decisão:** jogador controla seu personagem; Mestre controla NPCs/monstros. O Mestre pode mover token de jogador nas condições já acordadas, sem assumir suas ações de combate, magia ou inventário.
- **Motivo:** separar autoridade do Mestre e agência do jogador.
- **Consequência:** interface e RPCs devem aplicar a mesma matriz de permissões.

### DEC-006 — Exploração e combate
- **Decisão:** movimento fora de combate é livre, respeitando grid e validações acordadas; durante combate, movimento respeita deslocamento, turno e economia de ações.
- **Motivo:** manter exploração fluida e combate regido pelas regras.
- **Consequência:** não aplicar custo de ação de combate durante exploração.

### DEC-007 — Conclusão exige validação
- **Decisão:** interface, catálogo ou RPC existente não basta para declarar um módulo completo.
- **Motivo:** existência de código não prova correção nem integração.
- **Consequência:** cada módulo precisa de testes e critérios de aceite.

### DEC-008 — Preservação de dados de jogo durante auditorias
- **Decisão:** não modificar dados reais de personagens, fichas, campanhas, tokens ou progresso durante auditorias sem autorização explícita.
- **Motivo:** proteger dados de jogo e evitar alterações acidentais.
- **Consequência:** usar ambiente descartável, fixtures ou transações revertidas.

### DEC-009 — Sem resolução inventada
- **Decisão:** quando dados mecânicos necessários não existirem ou não forem confiáveis, não inventar CA, bônus, resistência, dano ou efeito.
- **Motivo:** manter fidelidade e transparência.
- **Consequência:** registrar a lacuna e encaminhar resolução ao Mestre.

### DEC-010 — Continuidade entre sessões
- **Decisão:** documentação versionada no repositório é a fonte de continuidade; conversas são contexto auxiliar.
- **Motivo:** evitar perda de decisões e repetição de trabalho.
- **Consequência:** atualizar estado, roadmap, auditorias e testes durante a execução.

## Decisões técnicas pendentes de confirmação
Os itens abaixo não são decisões tomadas; precisam ser definidos após o diagnóstico:
- Estratégia final de modularização do JavaScript e SQL sem reescrita desnecessária.
- Contratos de eventos e idempotência.
- Ambiente formal de staging/testes e política de dados sintéticos.
- Ferramenta e cobertura de testes automatizados.
- Estratégia de deploy e rollback.
- Política de versionamento de rulesets por campanha.


### DEC-011 — Monólito modular antes de microserviços
- **Data:** 2026-11-08
- **Decisão:** manter a aplicação como monólito modular enquanto escala, equipe e requisitos não justificarem separação em serviços. Definir limites de domínio, contratos e testes antes de extrair módulos.
- **Motivo:** reduzir complexidade operacional e preservar a stack atual; o problema principal é acoplamento, não falta de microserviços.
- **Consequência:** refatorar por fatias verticais e extrair código compartilhado apenas quando consumidores e contratos estiverem mapeados.

### DEC-012 — Preservar modelos de persistência coexistentes até reconciliação
- **Data:** 2026-11-08
- **Decisão:** campaigns.cba_data/combat_data e campaign_log são o caminho ativo observado; scenes/tokens/monster_instances/combat_state/roll_requests/roll_log permanecem como compatibilidade/legado até confirmar todos os consumidores.
- **Motivo:** o banco e o frontend ainda contêm RPCs e estruturas de ambos os modelos; remover por aparência pode quebrar integrações externas ou dados históricos.
- **Consequência:** nenhuma tabela, coluna ou RPC legada será removida sem mapa de consumidores, equivalência, backfill, testes e rollback.

### DEC-013 — Documentação versionada como fonte de continuidade
- **Data:** 2026-11-08
- **Decisão:** PROJECT_STATE, ARCHITECTURE, DATA_MODEL, INTEGRATION_MAP, RPC_INVENTORY, ROADMAP, DECISIONS, AUDIT_REGISTER e TEST_STRATEGY são atualizados como parte do trabalho.
- **Motivo:** o desenvolvimento atravessa várias sessões e não pode depender da memória da conversa.
- **Consequência:** sessão é janela de execução, não marco do projeto; retomar do estado do repositório e validar o HEAD antes de continuar.

### DEC-014 — CI estático incremental e sem dependências
- **Data:** 2026-11-08
- **Decisão:** iniciar validação automatizada com Node.js e recursos nativos, verificando scripts inline/compartilhados e invariantes críticos do Dice.
- **Motivo:** estabelecer feedback reproduzível sem introduzir framework ou dependências antes de conhecer a aplicação.
- **Consequência:** ampliar gradualmente para testes SQL, domínio, integração e E2E quando houver ambiente de teste seguro e reproduzível.


### DEC-015 — Mudanças de implementação por branch e PR
- **Data:** 2026-11-08
- **Decisão:** manter main como linha estável; alterações de código, schema ou configuração que afetem comportamento serão feitas em branch de trabalho e integradas por Pull Request após CI e revisão do diff. A documentação-base inicial foi consolidada diretamente na linha principal; novas alterações funcionais seguem o fluxo branch/PR.
- **Motivo:** permitir revisão, testes, rollback e separação clara entre trabalho em andamento e versão estável.
- **Consequência:** não usar uma branch de conversa como substituto de branch Git; nomear branches por tarefa técnica, não por sessão.

### DEC-016 — Proteção de dados reais durante auditorias
- **Data:** 2026-11-08
- **Decisão:** auditorias e testes iniciais são somente de leitura. Dados de personagens, campanhas, tokens e progresso não serão alterados para facilitar testes; cenários mutáveis devem usar fixture/campanha descartável.
- **Motivo:** preservar o estado de jogo e impedir que validações técnicas alterem dados do usuário.
- **Consequência:** testes que exigem mutação ficam bloqueados até existir ambiente/fixture isolado e procedimento de limpeza/rollback.


### DEC-017 — Idempotência para ações com consumo/efeitos
- **Data:** 2026-11-08
- **Decisão:** ações que consomem recursos ou produzem efeitos não reversíveis devem adotar request_id/idempotency_key persistido e escopado por usuário/campanha/ação, além de locks transacionais.
- **Motivo:** locks serializam concorrência, mas não distinguem retry da mesma ação de uma nova ação intencional.
- **Consequência:** primeiro padronizar ActionRequest/resultado; depois migrar fluxos em fatias e cobrir retries em testes descartáveis. Não alterar contratos existentes antes dessa definição.
