# Vínculo RPG — Estado do projeto

> Documento de continuidade entre sessões. Atualizar sempre que houver mudança relevante de código, banco, testes, decisões ou prioridades.
> **Regra:** este documento descreve evidências e incertezas; não transforma suposições em conclusão.

## Identificação
- Repositório: clubberblues/rpgvinculo
- Branch principal observada: main
- Backend: Supabase / PostgreSQL
- Produto: plataforma de RPG virtual com VTT, fichas, dados, campanhas e motor de regras.
- Referências técnicas preexistentes: [README](../README.md), [Arquitetura do motor D&D 3.5](../DND35_RULE_ENGINE_ARCHITECTURE.md) e [Plano Mestre da Mesa](../PLANO_MESTRE_MESA.md).

## Objetivo do produto
Construir um ambiente integrado para campanhas de RPG, com experiência de mestre e jogadores, mesa virtual, fichas, dados, progressão, inventário, catálogos e resolução de regras. D&D 3.5 SRD e o sistema próprio Vínculo são domínios distintos, com catálogos e regras separados.

O produto deve preservar a experiência de rolagem manual dos jogadores quando definida pelo fluxo, enquanto o servidor valida regras, permissões, recursos e persistência. O objetivo não é apenas ter páginas funcionais: os módulos precisam operar como um sistema coerente.

## Estado documental inicial
Este registro consolida documentação já existente, não reinicia auditorias. A primeira atividade de execução é reconciliar o estado descrito abaixo com o HEAD atual de main e com o projeto Supabase, apenas onde houver lacunas ou divergências.

### Evidências já existentes no repositório
- Aplicação web organizada em páginas HTML existentes, incluindo lobby, ficha, mesa e dados.
- O README descreve implantação dos arquivos principais e preservação de compatibilidade.
- O documento de arquitetura D&D 3.5 define camadas de fonte/licença, rulesets, catálogo, ficha, estado de jogo, resolução transacional e interface.
- O Plano Mestre registra decisões de produto, fluxos de mestre/jogador, auditorias e pendências funcionais.
- O banco mantém catálogos separados para D&D 3.5 (srd_*) e Vínculo (vinculo_*).
- O histórico documenta migrações, RPCs, RLS, inventários, conjuração, iniciativa, combate, economia de ações e integrações da mesa.

### Estado conhecido, ainda sujeito à reconciliação
- A fundação relacional do motor D&D 3.5 foi aplicada no Supabase, mas isso não significa que todos os efeitos e regras estejam automatizados.
- Existem implementações de ficha, inventário, equipamentos, magias, tokens, combate e progressão; a cobertura e integração variam por funcionalidade.
- Há validações estáticas, testes de fumaça e testes transacionais revertidos documentados.
- A validação real de ponta a ponta com duas sessões autenticadas de mestre e jogador permanece uma frente importante.
- O README e os documentos técnicos contêm snapshots de datas diferentes e alguns totais divergentes. Não consolidar esses totais sem nova consulta verificável.

## Restrições permanentes
1. Não alterar personagens, fichas, campanhas, tokens ou progresso de jogo durante auditorias sem autorização explícita.
2. Não repetir auditorias concluídas sem evidência de mudança, lacuna ou inconsistência.
3. Não misturar dados/regras srd_* com vinculo_*.
4. Não reconstruir ou migrar a aplicação para outra stack apenas por preferência arquitetural; exigir justificativa técnica.
5. Não declarar módulo concluído apenas porque existe interface, RPC ou catálogo.
6. Não inventar valores ou resoluções de regra quando faltarem dados; encaminhar ao Mestre e registrar a limitação.
7. Toda alteração de banco deve ser versionada, revisada e verificada.
8. Toda mudança funcional deve ter teste adequado e avaliação de regressão.

## Próxima atividade
**Consolidação arquitetural baseada no material existente.**
1. Reconciliar os documentos atuais com o código e o banco, sem repetir verificações válidas.
2. Identificar divergências e estado real das pendências.
3. Confirmar arquitetura atual e arquitetura-alvo.
4. Organizar roadmap por dependências e critérios de aceite.
5. Retomar execução na prioridade mais alta do plano aprovado.

## Protocolo de continuidade entre sessões
Ao iniciar uma sessão:
- Ler este documento, ARCHITECTURE.md, ROADMAP.md, DECISIONS.md, AUDIT_REGISTER.md e TEST_STRATEGY.md.
- Conferir branch/HEAD e alterações recentes.
- Retomar a próxima tarefa aberta; não recomeçar o projeto.

Ao encerrar ou atingir limite:
- Atualizar status, tarefa em andamento, arquivos/objetos afetados, testes e resultados.
- Registrar bloqueios e próxima ação concreta.
- Não registrar como concluído algo que não foi verificado.

## Histórico de atualização
- 2026-11-08: criado como registro inicial de continuidade; conteúdo baseado nas referências existentes no repositório e no histórico de trabalho. Reconciliação do estado atual permanece como primeira tarefa.
