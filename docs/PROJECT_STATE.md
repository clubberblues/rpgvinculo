# Vínculo RPG — Estado do projeto

> Documento de continuidade entre sessões. Atualizar sempre que houver mudança relevante de código, banco, testes, decisões ou prioridades.
> **Regra:** este documento descreve evidências e incertezas; não transforma suposições em conclusão.

## Identificação
- Fase atual: Fase 1 — Arquitetura e contratos (em andamento). Fase 0 — Consolidação/reconciliação concluída como baseline, com lacunas transferidas ao roadmap.
- Repositório: clubberblues/rpgvinculo
- Branch principal observada: main
- Backend: Supabase / PostgreSQL
- Produto: plataforma de RPG virtual com VTT, fichas, dados, campanhas e motor de regras.
- Referências técnicas preexistentes: [README](../README.md), [Arquitetura do motor D&D 3.5](../DND35_RULE_ENGINE_ARCHITECTURE.md) e [Plano Mestre da Mesa](../PLANO_MESTRE_MESA.md).

## Objetivo do produto
Construir um ambiente integrado para campanhas de RPG, com experiência de mestre e jogadores, mesa virtual, fichas, dados, progressão, inventário, catálogos e resolução de regras. D&D 3.5 SRD e o sistema próprio Vínculo são domínios distintos, com catálogos e regras separados.

O produto deve preservar a experiência de rolagem manual dos jogadores quando definida pelo fluxo, enquanto o servidor valida regras, permissões, recursos e persistência. O objetivo não é apenas ter páginas funcionais: os módulos precisam operar como um sistema coerente.

## Referências históricas e baseline
Este registro começou como consolidação da documentação existente. A fotografia técnica e as atualizações posteriores neste arquivo são a referência atual; os parágrafos históricos abaixo não devem ser lidos como tarefas ainda não iniciadas.

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

## Próxima atividade — estado atual
**Fase 1 — concluir contratos arquiteturais antes de qualquer refatoração funcional.**
1. Conferir manualmente Supabase Dashboard → Project Settings → API → Exposed schemas; pg_settings e get_project não expõem essa configuração.
2. Completar o cruzamento de argumentos e tipos JavaScript ↔ PostgreSQL para os fluxos críticos restantes (movimento/AOO, magia, salvamentos, inventário e progressão).
3. Detalhar ActionRequest/ActionResult, códigos de erro, eventos, versionamento e ordem de locks em ACTION_CONTRACTS.md; a proposta inicial já foi criada, mas ainda não é contrato implementado.
4. Definir o desenho de persistência/idempotência e os critérios de teste em ambiente descartável, sem aplicar migrações nesta etapa.
5. Manter a validação de Thorgar/Thunga bloqueada até confirmação inequívoca do alvo; não alterar dados reais de campanha.
6. Escolher a primeira fatia técnica somente após os contratos, o ambiente de teste e os critérios de aceite estarem definidos.

## Documentos permanentes
- [Arquitetura geral](ARCHITECTURE.md)
- [Mapa de integração](INTEGRATION_MAP.md)
- [Inventário de RPCs](RPC_INVENTORY.md)
- [Modelo de dados](DATA_MODEL.md)
- [Roadmap](ROADMAP.md)
- [Decisões](DECISIONS.md)
- [Registro de auditorias](AUDIT_REGISTER.md)
- [Estratégia de testes](TEST_STRATEGY.md)
- [Contratos de ações e resultados](ACTION_CONTRACTS.md)
- [Item de trabalho ativo](ACTIVE_WORK_ITEM.md)

## Protocolo de continuidade entre sessões
Ao iniciar uma sessão:
- Ler este documento, ACTIVE_WORK_ITEM.md, ARCHITECTURE.md, DATA_MODEL.md, INTEGRATION_MAP.md, RPC_INVENTORY.md, ROADMAP.md, DECISIONS.md, AUDIT_REGISTER.md e TEST_STRATEGY.md.
- Conferir branch/HEAD e alterações recentes.
- Retomar a próxima tarefa aberta; não recomeçar o projeto.

Ao encerrar ou atingir limite:
- Atualizar status, tarefa em andamento, arquivos/objetos afetados, testes e resultados.
- Registrar bloqueios e próxima ação concreta.
- Não registrar como concluído algo que não foi verificado.

## Histórico de atualização
- 2026-11-08: mapa de integração ampliado; 106 nomes de função distintos resolvidos (100 literais + 6 adicionais via dispatch dinâmico) e 114 assinaturas públicas; fluxos de lobby, ficha, iniciativa, combate, Storage e Realtime mapeados.
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

A varredura atual encontrou 100 nomes literais distintos e 4 call sites dinâmicos com 11 alternativas de dispatch e 9 alvos únicos (3 também aparecem literalmente), totalizando 106 nomes de função distintos e 114 assinaturas públicas correspondentes. Todos os 106 nomes têm correspondência no schema public. Essa correspondência nominal não comprova tipos em runtime, semântica, autorização ou execução ponta a ponta. As sete famílias de RPC sobrecarregadas mais críticas de combate tiveram suas chamadas e assinaturas comparadas estaticamente; quantidades/chaves correspondem às sobrecargas esperadas. A validação runtime e por papel permanece pendente. A mesa atual opera sobre campaigns.cba_data (JSONB), enquanto public.tokens/monster_instances permanecem como caminho relacional compatível com RPCs antigas e alguns resolvers. A CA de NPC vinculado já possui sobrecarga específica e helper que lê ficha/equipamento; o teste de leitura de Thorgar retornou CA 10 porque a Armadura de Couro está persistida como não equipada. No snapshot, campaigns=3, scenes=3, tokens=0 e monster_instances=0; create_campaign ainda cria uma linha em scenes, embora a mesa atual não a leia diretamente. index.html e lobby_atualizado.html existem no repositório; dex.html não foi encontrado em main no caminho consultado. A comparação revelou que lobby_atualizado.html não está sincronizado com lobby.html (4 RPCs contra 10 e referências a catálogos legados); tratá-lo como legado até decisão sobre seu destino.

O README registra testes locais anteriores (parse HTML/JS, pglast e smoke tests Playwright com Supabase simulado), mas não foram encontrados package.json, configuração Playwright ou testes em tests/ nos caminhos convencionais. Foi criado um primeiro workflow CI sem dependências para sintaxe de scripts inline/compartilhados e contrato de rolagem manual. A reconstituição dos testes históricos de Playwright/pglast e a expansão para integração/E2E continuam pendentes; a busca não prova que não existam scripts em outros diretórios.

O mapa relacional inicial identificou 100 FKs em public e 10 em priv. O estado atual de combate/rolagens está em campaigns.cba_data/combat_data e campaign_log; combat_state, roll_requests e roll_log estão vazios no snapshot e só aparecem em RPCs legadas não chamadas diretamente pelo frontend atual. As tabelas srd_character_equipment e srd_character_weapon_instances mantêm character_id como text sem FK para characters.id; as 48 linhas atuais conferidas correspondem a personagens existentes, sem órfãos. Isso fica registrado como ponto estrutural para análise futura, sem alteração de schema.

Os advisors atuais reportaram 99 RPCs SECURITY DEFINER executáveis por authenticated (todos possuem marcadores de guarda na varredura estática: 96 auth.uid, 40 my_role, 5 need_gm, 37 consultam members; revisão semântica individual continua necessária), 7 tabelas RLS sem policies (grants diretos anon/authenticated reconsultados e todos negados), proteção de senha vazada desabilitada e 52 índices não utilizados. Também foi encontrada uma ACL PUBLIC EXECUTE em um helper do schema priv; anon não tem USAGE nesse schema, mas a exposição de priv no PostgREST ainda precisa ser confirmada. Nenhuma ACL, configuração Auth, índice ou policy foi alterada. Os dois primeiros workflows estáticos do GitHub Actions concluíram com sucesso (runs 42546411046 e 42548214654). O segundo também protege iniciativa manual, registro de ataque e ausência de chamadas roll_dice nas páginas ativas.

Nenhuma linha de personagem, ficha, campanha, token ou progresso foi alterada nesta fotografia.


## Item de trabalho ativo — 2026-11-08

A pauta operacional recuperada para a próxima fatia está em [ACTIVE_WORK_ITEM.md](ACTIVE_WORK_ITEM.md). A consulta confirmou dois registros distintos na campanha/contexto TESTE 2: **Thunga Mestre (ID 682)** pertence à campanha 131, tem Armadura de Couro equipada, Machado Grande não equipado e não possui token vinculado; **Thorgar (ID 681)** é um personagem do Mestre fora da associação direta à campanha, mas tem um token NPC vinculado em cba_data. O teste de CA 10 realizado para Thorgar não se aplica a Thunga. A identidade do alvo da pauta histórica permanece **não confirmada**; não iniciar testes funcionais nem alterar dados reais até confirmação.

A consulta não modificou personagens, fichas, campanhas, tokens, inventário, equipamento ou progresso.


## Reconciliação adicional de identidade — 2026-11-08

Consulta somente de leitura confirmou dois registros distintos:
- **Thorgar (ID 681):** campaign_id NULL; pertence ao Mestre da campanha 131 e está vinculado a um token do tipo NPC nessa campanha (sourceCharacterId=681). A Armadura de Couro e os demais itens consultados estão com equipado=false. A sobrecarga de CA para NPC vinculado retornou CA 10, coerente com esse estado.
- **Thunga Mestre (ID 682):** campaign_id=131; não possui token vinculado em cba_data; Armadura de Couro está equipada e Machado Grande não está equipado.

Portanto, o teste de CA 10 executado para Thorgar (681) **não valida nem invalida** a CA de Thunga Mestre (682). São registros diferentes; a identidade do personagem que deve ser alvo da pauta histórica precisa ser confirmada antes de qualquer teste funcional. Nenhum dado foi alterado.


## Próxima ação concreta — continuidade
- Continuar a reconciliação de contratos RPC nos fluxos críticos ainda não cruzados; não refazer os sete grupos de sobrecargas já verificados.
- Confirmar schemas expostos pelo PostgREST e ACL dos schemas internos antes de qualquer alteração de permissão.
- Aguardar confirmação do alvo de teste (Thunga Mestre 682 ou Thorgar 681) antes de testes funcionais mutáveis ou leituras funcionais adicionais.
- Manter o código de jogo e os dados do Supabase intactos até a primeira tarefa de implementação estar especificada, isolada em branch e coberta por teste.
- Última CI estática aprovada: [run #2](https://github.com/clubberblues/rpgvinculo/actions/runs/42548214654).


## Riscos e bloqueios atuais
- **P1 — validação funcional bloqueada:** há dois registros distintos de teste (Thunga Mestre 682 e Thorgar 681). A identidade do alvo deve ser confirmada antes de testes funcionais.
- **P2 — idempotência:** avanço de turno e conjuração manual não recebem request_id explícito; risco potencial de repetição/retry ainda não reproduzido.
- **P2 — Storage:** bucket público midia sem allowlist MIME e sem limite explícito de tamanho; validações atuais são majoritariamente no cliente.
- **P2 — configuração de API:** exposição PostgREST de priv/private não foi confirmada; não alterar ACL até verificar.
- **P2 — Auth:** proteção contra senhas vazadas está desabilitada no projeto; habilitação depende de decisão/configuração do proprietário.
- **P3 — índices:** 52 índices aparecem como não utilizados no advisor; não remover sem análise de workload.
- **P3 — legado:** lobby_atualizado, scenes/tokens/combat_state/roll_requests/roll_log e tabelas de magia normalizadas sem uso atual detectado devem permanecer até confirmar consumidores externos.


### Exposição de schemas internos — verificação parcial
- authenticated possui USAGE em priv e private; anon não possui USAGE em nenhum dos dois; CREATE é negado para ambos.
- Há 40 funções priv com EXECUTE para authenticated e 6 funções private com EXECUTE para authenticated. Uma função priv.srd_feat_saving_throw_modifier também conserva EXECUTE para PUBLIC; ela é SECURITY DEFINER, STABLE e consulta apenas o catálogo público de talentos, sem acessar dados de campanha/personagem.
- As cinco funções public executáveis por anon são utilitários/trigger SECURITY INVOKER, não SECURITY DEFINER.
- A configuração PostgREST de schemas expostos não está disponível via pg_settings nem pelo endpoint de metadados get_project do conector. Portanto, ainda não foi possível confirmar se priv/private estão ou não expostos à API REST.
- **Ação necessária:** conferir manualmente Supabase Dashboard → Project Settings → API → Exposed schemas. Se priv/private estiverem expostos, revisar imediatamente o conjunto de funções com EXECUTE para authenticated antes de qualquer revogação. Não remover USAGE/EXECUTE agora, pois wrappers SECURITY INVOKER dependem desses grants para chamar helpers internos.


## Continuidade — 2026-11-09
- Criado ACTION_CONTRACTS.md com proposta não disruptiva de ActionRequest/ActionResult, idempotência, eventos, erros e plano de adoção. Nenhuma RPC ou tabela foi alterada.
- Consulta atual a pg_proc confirmou assinaturas de avancar_turno, conjurar_magia_com_acao_srd_manual, conjurar_missil_magico_srd_manual, registrar_iniciativa_d20 e iniciar_iniciativa_com_dados; diferenças de idempotência estão documentadas no novo contrato.
- get_project confirmou projeto ACTIVE_HEALTHY em PostgreSQL 17.6. Consulta a pg_settings não retornou parâmetros PGRST/schema, portanto a exposição REST de priv/private continua exigindo conferência no Dashboard.
- A prioridade permanece Fase 1; validação funcional em personagens reais continua bloqueada pela divergência documentada entre Thorgar 681 e Thunga Mestre 682.


## Verificação de RPCs — 2026-11-09
- Nova varredura estática de `mesa.html`, `ficha.html` e `lobby.html` encontrou 100 nomes literais distintos de `.rpc()` (87/12/10 por página, com sobreposição).
- Consulta somente de leitura a `pg_proc` confirmou 100/100 nomes no schema `public`; nenhum nome literal ausente. Essa verificação é apenas por nome e não comprova argumentos, sobrecargas, autorização ou execução.
- A conferência detalhada JS ↔ PostgreSQL continua pendente por fluxo; não marcar os contratos RPC como concluídos com base nessa correspondência nominal.

- 2026-11-09: rastreados os quatro call sites dinâmicos em mesa.html; identificados nove alvos dinâmicos únicos, três já presentes nas chamadas literais e seis nomes adicionais únicos; união validada com 106 nomes e 114 assinaturas públicas, sem nome ausente. Grants/search_path dos quatro alvos não relacionados a equipamento também conferidos.


## Contratos frontend ↔ PostgreSQL — progresso em 2026-11-09
- Nomes RPC: 100/100 nomes literais distintos em mesa.html, ficha.html e lobby.html encontrados no schema public; quatro call sites dinâmicos foram rastreados, com onze alternativas de dispatch e nove alvos únicos (três também aparecem em chamadas literais). A união contém 106 nomes distintos e 114 assinaturas públicas.
- Amostras de cruzamento documentadas em ACTION_CONTRACTS.md: avanço de turno, iniciativa manual, conjuração e Míssil Mágico, movimento/AOO, inventário/equipamento, progressão, descanso, grimório, domínios, CA e deslocamento.
- Foram identificadas operações sem request_id no contrato atual (avanço de turno, conjuração manual, XP, avanço de nível e algumas rotinas de descanso/equipamento); isso é inventário de risco para desenho de retry, não prova de falha reproduzida.
- A compatibilidade integral de argumentos em todos os fluxos, testes com sessões autenticadas, exposição dos schemas internos e execução transacional/E2E continuam pendentes. Nenhuma função SQL, migration, personagem, ficha, campanha, token ou dado de jogo foi alterado nesta rodada.


## Contratos de lobby e ciclo de vida — 2026-11-09
- Mapeado o fluxo de listagem, criação, entrada por código/mesa aberta, associação de ficha à mesa, configurações e exclusão de ficha/campanha. Definições SQL e argumentos frontend foram comparados estaticamente; grants de authenticated/anon/PUBLIC e search_path foram consultados para as RPCs do lobby.
- Exclusão de campanha é uma saga cliente + Storage + duas RPCs, não uma transação única. Foram registrados riscos de entrada concorrente durante a pendência, retomada dependente do navegador, finalização não idempotente após resposta perdida e possível objeto de capa órfão. Nenhum desses riscos foi alterado nesta rodada.
- Nenhuma ação mutável foi executada; dados de jogo e Storage permaneceram intactos.


## Fronteira de escrita frontend — 2026-11-09
- mesa.html: somente INSERT direto em campaign_log (chat/pedidos), com RLS de autoria/papel; mutações de combate/personagem/token seguem RPCs. Nenhuma mutação direta nessas entidades foi encontrada na varredura estática.
- lobby.html: operações de campanha via RPC; upload de capa/avatar em Storage e update direto de campaigns.capa_url.
- ficha.html: ramo D&D 3.5 usa RPCs para operações mecânicas críticas; ramo legado Vínculo mantém escritas diretas e referências de schema antigas. Criação em duas transações, aquisição de talentos/magias sem validação de pré-requisitos no servidor, update direto de ficha e consumo de inventário não atômico foram registrados como riscos, não corrigidos.
- Decisão de arquitetura: uniformizar a autoridade do servidor para ações mecânicas nos dois rulesets. Não misturar catálogos ou tabelas SRD e Vínculo.


## Contratos adicionais D&D 3.5 — 2026-11-09
- Cruzada a chamada de criação D&D 3.5 com a assinatura de 14 argumentos de finalizar_criacao_personagem_srd. O corpo é transacional e delega validações de personagem, idiomas, talentos bônus, domínios, grimório e equipamento inicial; não tem request_id explícito.
- Leitura dos corpos de salvar_grimorio_srd, salvar_dominios_personagem_srd e descanso_longo_personagem_srd confirmou validações server-side e locks na ficha; descanso aplica intervalo de 8 horas. Fúria tem consultas e comandos separados para personagem/NPC; retry/concorrência não foram testados.
- Nenhuma ação mutável foi executada.

- Escopo do legado Vínculo refinado por consulta agregada: 5 personagens existentes, 5 com ficha SRD, 0 sem ficha SRD e 0 com ficha Vínculo; o lobby atual inicia criação com ruleset=dnd35. A divergência em ficha.html é rota legada latente, sem impacto demonstrado no fluxo ativo atual.


## Realtime — primeira fotografia da mesa — 2026-11-09
- mapeados 9 canais Postgres Changes em mesa.html: chat, characters, SRD sheets, character equipment, token equipment, members, conditions, campaign effects e campaign updates.
- Dois canais SRD (srd_character_sheets e srd_character_equipment) não têm filtro de campaign_id; callbacks filtram IDs em memória. Sem status callback de subscribe ou resync explícito pós-reconexão identificado no método atual.
- Riscos documentados: eventos perdidos em desconexão, duplicação de chat sem dedupe explícito e ausência de state_version nos snapshots. São riscos de arquitetura a testar, não falhas reproduzidas.
- Próximo contrato necessário: state_version/ordem de eventos, resync snapshot e deduplicação antes de refatorar Realtime.


## Concorrência — risco estático priorizado — 2026-11-09
- Análise de ordem de locks no fluxo AOO encontrou inversão entre cancelamento (pending → attacks) e resolução/aplicação de dano (attack → pending). Há risco potencial de deadlock quando as ações concorrem sobre o mesmo ataque/movimento.
- Ainda não reproduzido; nenhuma função alterada. Priorizar teste concorrente em fixture descartável e definir ordem global determinística antes de corrigir.


## Divergência crítica de versionamento de migrations — 2026-11-09
- Repositório main: 681 arquivos SQL em `supabase/migrations/`; arquivo mais recente `20261108135111_block_movement_when_no_actions.sql`.
- Supabase conectado: 966 registros em `supabase_migrations.schema_migrations`; última versão aplicada `20261109005941`.
- Diferença de contagem: 285 registros aplicados a mais no histórico remoto do que arquivos atualmente versionados nesse diretório. Distribuição por dia (repo/remoto): 31/10 8/8; 01/11 25/25; 02/11 422/422; 03/11 72/72; 04/11 140/146; 05/11 12/42; 08/11 2/234; 09/11 0/17.
- Isso demonstra divergência entre histórico de implantação e migrations versionadas, mas a correspondência exata por versão ainda precisa ser reconciliada; diferença de contagem não prova sozinha quais arquivos estão ausentes nem autoriza recriar migrations.
- Risco: outro ambiente não pode ser reconstruído com segurança apenas pelo diretório atual; deploy automatizado ou reset local seria inseguro até reconciliação. Não aplicar migration de reparo nem alterar banco nesta etapa.
- Nova prioridade de Fase 1: obter snapshot do schema remoto (DDL, funções, policies, grants, triggers, enums e extensões), comparar por versão com os arquivos locais e classificar cada migration como aplicada/versionada, aplicada/sem arquivo, arquivo/não aplicada ou divergente. Só então consolidar histórico e definir fluxo de deploy/rollback.


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
