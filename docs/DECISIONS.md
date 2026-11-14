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

### DEC-004 — Rolagens físicas, transparência e chat
- **Decisão:** reutilizar o `dice.html` existente e seus dados disponíveis; não reconstruir o motor de rolagem. A interface abre como modal centralizado sobre a Mesa, sem ocupar uma coluna lateral.
- **Decisão complementar:** jogadores rolam seus próprios dados; o Mestre administra rolagens de NPCs/monstros e pode assumir temporariamente qualquer personagem jogador durante o combate, inclusive suas rolagens e ações. Isso não transfere a propriedade da ficha.
- **Visibilidade:** rolagens de jogadores são públicas e acompanhadas em tempo real pelo chat. Para cada rolagem do Mestre, ele pode escolher publicar para todos ou manter privada. O chat registra personagem/criatura, finalidade, face natural, modificadores separados e total calculado. Não haverá mensagens fixadas.
- **Motivo:** preservar a experiência de rolagem de mesa, a transparência e a autoridade do Mestre.
- **Consequência:** o Dice iframe devolve resultados por `postMessage`; o chat é o canal de acompanhamento dos demais participantes. A política RLS de `campaign_log` permite ao Mestre ler registros privados e limita jogadores a registros públicos. O RPC público `roll_dice`, que gera resultados no servidor, não deve substituir a rolagem física do jogador.

### DEC-005 — Controle e autoridade sobre personagens
- **Decisão:** o jogador controla sua própria ficha e token. O Mestre pode controlar qualquer personagem, NPC ou monstro, inclusive assumir temporariamente um personagem jogador durante combate e realizar rolagens/ações em seu nome, sem transferir a propriedade da ficha. O Mestre também pode conceder controle temporário de NPCs/criaturas a jogadores.
- **Motivo:** permitir continuidade da sessão, arbitragem e administração sem retirar a titularidade do personagem.
- **Consequência:** permissões devem distinguir propriedade da ficha, controle operacional temporário e autoridade do Mestre. Desconexão do jogador não remove token nem altera iniciativa.

### DEC-006 — Movimento assistido, sem bloqueio automático
- **Decisão:** o jogador pode movimentar seu token livremente durante o turno. A Mesa informa o deslocamento da ficha, mede distâncias e apresenta referências de movimento, mas não bloqueia automaticamente movimento excedente nem decide suas consequências. O Mestre pode mover/reposicionar qualquer token.
- **Motivo:** manter a fluidez e deixar a adjudicação de exceções sob responsabilidade do Mestre, sem abandonar as referências D&D 3.5.
- **Consequência:** movimento e deslocamento devem permanecer sincronizados com a ficha e o estado da campanha; alertas são informativos, não barreiras.

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


### DEC-018 — Grid fixo e mapa sem neblina de guerra
- **Data:** 2026-11-13
- **Decisão:** cada quadrado do grid representa sempre 1,5 m (5 pés), conforme D&D 3.5. O Mestre pode alinhar o grid à imagem e ajustar sua aparência/transparência, mas não alterar a metragem real do quadrado. Zoom por pinça no celular e scroll do mouse no desktop altera somente a visualização; arrastar o espaço vazio move a câmera, arrastar token move a criatura. Neblina de guerra/fog of war está fora do escopo.
- **Motivo:** manter distâncias consistentes e evitar complexidade visual desnecessária.
- **Consequência:** tamanho visual do grid, zoom e pan nunca alteram a escala mecânica de 1,5 m por quadrado.

### DEC-019 — Lobby, participantes e continuidade da sessão
- **Data:** 2026-11-13
- **Decisão:** o Lobby mostra campanha, Mestre, participantes, personagens vinculados, presença online/offline e prontidão. O Mestre pode iniciar a sessão sem exigir que todos estejam prontos e controla quando libera a entrada na Mesa.
- **Decisão complementar:** o painel de participantes mostra identidade, personagem e turno atual, podendo ser recolhido. Jogadores podem desconectar e retornar sem interromper a sessão; tokens, dados e iniciativa permanecem. O Mestre pode assumir temporariamente o personagem desconectado.
- **Notificações:** alertas discretos e não bloqueantes informam início/fim de combate, início de turno, dano/0 PV, efeitos prestes a terminar, XP/ouro/itens e entrada/saída. Os eventos podem ser consultados posteriormente no chat/histórico. Não haverá mensagens fixadas.
- **Motivo:** permitir sessões resilientes e acompanhamento da mesa sem interromper a interação.
- **Consequência:** presença online/offline não altera propriedade do personagem nem estado do combate.

### DEC-020 — Criação de campanhas e ciclo de vida de personagens
- **Data:** 2026-11-13
- **Decisão:** o Mestre cria campanhas independentes com nome, descrição e imagem de apresentação. Cada campanha tem código de convite; o Mestre pode aprovar ou recusar solicitações de entrada e vincular personagens existentes ou criar novos. Participantes, personagens, mapas, encontros, inventários, configurações e histórico ficam isolados por campanha.
- **Personagens:** podem estar ativos, em reserva ou arquivados. O Mestre pode substituir um personagem ativo sem apagar ficha ou histórico.
- **Motivo:** preservar continuidade e impedir mistura de dados entre campanhas.
- **Consequência:** relacionamentos e consultas devem ser sempre escopados pela campanha e respeitar a titularidade do personagem.

### DEC-021 — Sem voz ou vídeo integrados
- **Data:** 2026-11-13
- **Decisão:** comunicação por voz e vídeo não faz parte do escopo do Vínculo nesta etapa. A comunicação integrada permanece no chat textual e nos registros de eventos/rolagens.
- **Motivo:** manter o foco na mesa e evitar infraestrutura adicional.
- **Consequência:** não desenvolver chamadas, transmissão de câmera ou áudio como requisito do MVP.

### DEC-022 — Automação proporcional à confiabilidade
- **Data:** 2026-11-13
- **Decisão:** automatizar operações simples, determinísticas e confiáveis; para regras ou efeitos que exigem interpretação, apresentar dados e ferramentas gerais e permitir que o Mestre decida/aplique manualmente. A plataforma não deve bloquear ações de jogo como substituto da adjudicação do Mestre.
- **Motivo:** entregar uma mesa jogável sem exigir um motor completo e inflexível de regras antes da primeira campanha.
- **Consequência:** priorizar operações reutilizáveis, persistência consistente e integração entre ficha, motor e Mesa; não criar implementação isolada para cada talento, magia ou habilidade quando uma ferramenta geral resolver.


### DEC-023 — Biblioteca central D&D 3.5
- **Data:** 2026-11-13
- **Decisão:** centralizar conteúdo oficial D&D 3.5 em uma biblioteca compartilhada: classes, raças, talentos, perícias, magias, armas, armaduras, equipamentos, monstros/criaturas, condições, regras e tabelas. Conteúdo oficial fica separado do conteúdo personalizado criado pelo Mestre. A visibilidade respeita permissões de campanha e ficha.
- **Motivo:** oferecer consulta consistente durante preparação e jogo sem duplicar catálogos por campanha.
- **Consequência:** conteúdo oficial não é sobrescrito por personalizações; modelos do Mestre permanecem identificados como conteúdo personalizado.

### DEC-024 — Consulta contextual de regras na Mesa
- **Data:** 2026-11-13
- **Decisão:** ao selecionar um elemento da ficha ou criatura, o usuário pode abrir uma consulta sobreposta à Mesa com descrição, requisitos, funcionamento D&D 3.5, valores, bônus, penalidades, limitações, referência da fonte e observações do Mestre. A consulta não navega para fora da Mesa.
- **Motivo:** tornar as regras acessíveis durante o jogo sem interromper a sessão.
- **Consequência:** a consulta é uma camada de referência; não substitui a adjudicação do Mestre nem automatiza efeitos que dependem de interpretação.
