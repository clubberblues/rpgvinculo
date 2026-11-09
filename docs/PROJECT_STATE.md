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

## Documentos permanentes
- [Arquitetura geral](ARCHITECTURE.md)
- [Mapa de integração](INTEGRATION_MAP.md)
- [Inventário de RPCs](RPC_INVENTORY.md)
- [Roadmap](ROADMAP.md)
- [Decisões](DECISIONS.md)
- [Registro de auditorias](AUDIT_REGISTER.md)
- [Estratégia de testes](TEST_STRATEGY.md)

## Protocolo de continuidade entre sessões
Ao iniciar uma sessão:
- Ler este documento, ARCHITECTURE.md, INTEGRATION_MAP.md, ROADMAP.md, DECISIONS.md, AUDIT_REGISTER.md e TEST_STRATEGY.md.
- Conferir branch/HEAD e alterações recentes.
- Retomar a próxima tarefa aberta; não recomeçar o projeto.

Ao encerrar ou atingir limite:
- Atualizar status, tarefa em andamento, arquivos/objetos afetados, testes e resultados.
- Registrar bloqueios e próxima ação concreta.
- Não registrar como concluído algo que não foi verificado.

## Histórico de atualização
- 2026-11-08: mapa inicial de integração criado; 100 nomes distintos de RPC do frontend encontrados no schema public; fluxo de rolagem manual do iframe Dice conferido estaticamente.
- 2026-11-08: criado como registro inicial de continuidade; conteúdo baseado nas referências existentes no repositório e no histórico de trabalho. Reconciliação do estado atual permanece como primeira tarefa.


## Fotografia técnica verificada — 2026-11-08

Levantamento somente de leitura realizado durante a implantação do método:

### Repositório
- Branch principal observada: main.
- A documentação existente inclui README, DND35_RULE_ENGINE_ARCHITECTURE.md e PLANO_MESTRE_MESA.md.
- A camada web atual ainda concentra grandes blocos de HTML/CSS/JavaScript nas páginas:
  - mesa.html: 691.956 caracteres, 5 tags script, 87 nomes distintos de RPC, 27 referências .from() e 9 chamadas channel()/on() identificadas por varredura estática.
  - ficha.html: 362.301 caracteres, 4 tags script, 12 nomes distintos de RPC e 31 referências .from().
  - lobby.html: 138.602 caracteres, 4 tags script, 10 nomes distintos de RPC e 10 referências .from().
  - dice.html: 214.174 caracteres, 5 tags script; nenhuma chamada .rpc() ou .from() detectada na varredura.
- Essa varredura é um inventário inicial de chamadas, não um grafo completo de dependências.

### Supabase — fotografia somente de leitura
- Histórico de migrations: 966 registros; versão mínima observada 20261031160944 e máxima 20261109005941.
- Relações: 76 em public e 7 em priv.
- RLS: 76/76 tabelas public com RLS habilitado; 5/7 tabelas priv com RLS habilitado. A exposição e os grants do schema priv devem continuar avaliados separadamente.
- Funções por schema: public 225 (150 SECURITY DEFINER); priv 94 (88 SECURITY DEFINER); private 8 (8 SECURITY DEFINER). São contagens atuais de funções no catálogo, não uma avaliação individual de autorização.

### Catálogos atuais
- SRD: 7 raças; 11 classes; 59 registros em srd_skills; 110 talentos; 1.021 equipamentos; 607 magias; 607 efeitos tipados; 445 monstros; 220 progressões de classe; 1.400 progressões de espaços de magia; 131 características de classe.
- Auditoria de catálogo: 1.403 linhas em srd_catalog_entry_audit, todas com audit_status manual_verified.
- Cobertura: 15 linhas em srd_catalog_coverage — 3 complete, 8 in_progress e 4 pending.
- srd_spell_effects: 25 verification_status verified_srd e 582 needs_review.
- Características de classe: 131/131 com verification_status verified_srd.
- Perícias: 59 registros (55 verified_srd e 4 excluded). A cobertura/auditoria contém 50 entradas-base: 46 verified_srd e 4 excluded; os 9 registros adicionais são especializações de Atuação. A cobertura permanece pending porque a validação mecânica e de integração não foi concluída, não porque faltem nove perícias-base.
- Vínculo: 16 classes; 160 habilidades; 95 magias; 191 itens; 72 talentos.

### Interpretação
- O estado do banco e o estado dos catálogos não são equivalentes: uma linha manual_verified no registro de auditoria não significa que a mecânica correspondente esteja implementada ou automatizada.
- Os 607 efeitos tipados não estão todos resolvidos: 582 permanecem needs_review.
- Os totais históricos de 49/50/59 perícias e os diferentes snapshots de funções/migrations não devem ser usados sem indicar data, tabela e critério de contagem.

A varredura encontrou 100 nomes distintos de RPC chamados por mesa.html, ficha.html e lobby.html; os 100 nomes existem no schema public do Supabase. Isso confirma correspondência nominal, não assinatura, autorização ou execução ponta a ponta. As sete famílias de RPC sobrecarregadas mais críticas de combate tiveram suas chamadas e assinaturas comparadas estaticamente; quantidades/chaves correspondem às sobrecargas esperadas. A validação runtime e por papel permanece pendente. A mesa atual opera sobre campaigns.cba_data (JSONB), enquanto public.tokens/monster_instances permanecem como caminho relacional compatível com RPCs antigas e alguns resolvers. A CA de NPC vinculado já possui sobrecarga específica e helper que lê ficha/equipamento; o teste de leitura de Thorgar retornou CA 10 porque a Armadura de Couro está persistida como não equipada. No snapshot, campaigns=3, scenes=3, tokens=0 e monster_instances=0; create_campaign ainda cria uma linha em scenes, embora a mesa atual não a leia diretamente. index.html e lobby_atualizado.html existem no repositório; dex.html não foi encontrado em main no caminho consultado. A comparação revelou que lobby_atualizado.html não está sincronizado com lobby.html (4 RPCs contra 10 e referências a catálogos legados); tratá-lo como legado até decisão sobre seu destino.

O README registra testes locais anteriores (parse HTML/JS, pglast e smoke tests Playwright com Supabase simulado), mas não foram encontrados package.json, configuração Playwright ou testes em tests/ nos caminhos convencionais. Foi criado um primeiro workflow CI sem dependências para sintaxe de scripts inline/compartilhados e contrato de rolagem manual. A reconstituição dos testes históricos de Playwright/pglast e a expansão para integração/E2E continuam pendentes; a busca não prova que não existam scripts em outros diretórios.

O mapa relacional inicial identificou 100 FKs em public e 10 em priv. As tabelas srd_character_equipment e srd_character_weapon_instances mantêm character_id como text sem FK para characters.id; as 48 linhas atuais conferidas correspondem a personagens existentes, sem órfãos. Isso fica registrado como ponto estrutural para análise futura, sem alteração de schema.

Os advisors atuais reportaram 99 RPCs SECURITY DEFINER executáveis por authenticated (todos possuem marcadores de guarda na varredura estática: 96 auth.uid, 40 my_role, 5 need_gm, 37 consultam members; revisão semântica individual continua necessária), 7 tabelas RLS sem policies (grants diretos anon/authenticated reconsultados e todos negados), proteção de senha vazada desabilitada e 52 índices não utilizados. Também foi encontrada uma ACL PUBLIC EXECUTE em um helper do schema priv; anon não tem USAGE nesse schema, mas a exposição de priv no PostgREST ainda precisa ser confirmada. Nenhuma ACL, configuração Auth, índice ou policy foi alterada. O primeiro workflow estático do GitHub Actions concluiu com sucesso (run 42546411046), validando 9 blocos JavaScript em 5 páginas e o contrato de rolagem manual.

Nenhuma linha de personagem, ficha, campanha, token ou progresso foi alterada nesta fotografia.


## Item de trabalho ativo — 2026-11-08

A pauta operacional recuperada para a próxima fatia está em [ACTIVE_WORK_ITEM.md](ACTIVE_WORK_ITEM.md). A consulta confirmou dois registros distintos na campanha/contexto TESTE 2: **Thunga Mestre (ID 682)** pertence à campanha 131, tem Armadura de Couro equipada, Machado Grande não equipado e não possui token vinculado; **Thorgar (ID 681)** é um personagem do Mestre fora da associação direta à campanha, mas tem um token NPC vinculado em cba_data. O teste de CA 10 realizado para Thorgar não se aplica a Thunga. A identidade do alvo da pauta histórica permanece **não confirmada**; não iniciar testes funcionais nem alterar dados reais até confirmação.

A consulta não modificou personagens, fichas, campanhas, tokens, inventário, equipamento ou progresso.


## Reconciliação adicional de identidade — 2026-11-08

Consulta somente de leitura confirmou dois registros distintos:
- **Thorgar (ID 681):** campaign_id NULL; pertence ao Mestre da campanha 131 e está vinculado a um token do tipo NPC nessa campanha (sourceCharacterId=681). A Armadura de Couro e os demais itens consultados estão com equipado=false. A sobrecarga de CA para NPC vinculado retornou CA 10, coerente com esse estado.
- **Thunga Mestre (ID 682):** campaign_id=131; não possui token vinculado em cba_data; Armadura de Couro está equipada e Machado Grande não está equipado.

Portanto, o teste de CA 10 executado para Thorgar (681) **não valida nem invalida** a CA de Thunga Mestre (682). São registros diferentes; a identidade do personagem que deve ser alvo da pauta histórica precisa ser confirmada antes de qualquer teste funcional. Nenhum dado foi alterado.
