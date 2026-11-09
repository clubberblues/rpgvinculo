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
- **Consequência:** o fluxo aguarda as rolagens exigidas antes de avançar.

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
