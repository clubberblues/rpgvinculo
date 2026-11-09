# Vínculo RPG — Registro de auditorias

## Objetivo
Manter um inventário único de auditorias, evidências, limitações e pendências. Este registro evita repetir trabalho e impede que uma verificação parcial seja interpretada como aceite completo.

## Como registrar
Cada entrada deve indicar data e escopo; fonte examinada (commit/arquivo, migration, função, tabela ou ambiente); método de verificação; resultado observado; limitações; pendências e próxima ação; e se houve alteração de código/schema/dados.

Use os estados: **verificado**, **parcial**, **pendente**, **bloqueado**, **obsoleto/reconciliar**.

## Auditorias e referências preexistentes

### Repositório e documentação
- **Verificado como existente:** README, DND35_RULE_ENGINE_ARCHITECTURE.md, PLANO_MESTRE_MESA.md e fontes de conjuração.
- **Pendente:** consolidar snapshots e divergências entre documentos com o HEAD atual.
- **Restrição:** não substituir documentos especializados por resumos genéricos.

### Banco, migrations e segurança
- **Histórico registrado:** auditorias anteriores cobriram migrations, índices, RLS, permissões e funções privilegiadas.
- **Snapshot citado no histórico de trabalho:** 592/592 migrations verificadas e 50 índices examinados.
- **Divergência a reconciliar:** os documentos históricos citam diferentes totais de funções SECURITY DEFINER (63, 86 e 90 em momentos/escopos distintos). Nenhum desses totais deve ser tratado como estado atual sem consulta ao banco.
- **Pendente:** validar apenas alterações posteriores, objetos novos ou inconsistências entre os snapshots.
- **Restrição:** não reexecutar migrations aplicadas nem modificar dados de personagens/campanhas.

### Motor D&D 3.5 e catálogos
- **Referência:** DND35_RULE_ENGINE_ARCHITECTURE.md registra auditorias de perícias, talentos, domínios, condições, características de classe, magias, monstros e equipamentos.
- **Divergência histórica:** snapshots citam 601 e 607 magias em datas diferentes; o número de registros não prova completude nem automatização.
- **Parcial:** estrutura e metadados tipados de efeitos de magia existem, mas classificação/estruturação não equivale a resolução automática validada.
- **Perícias:** 59 linhas no catálogo (55 verified_srd, 4 excluded). A cobertura de 50 linhas-base corresponde a 46 verified_srd e 4 excluded; nove linhas adicionais são especializações de Atuação. A cobertura continua pending por validação mecânica/integração, não por nove perícias-base ausentes. A auditoria de fonte manual tem 50 linhas (46 verified_srd + 4 excluded); as nove especializações de Atuação não têm linha própria nessa tabela e devem ser tratadas conforme a modelagem da perícia Atuação, sem criar automaticamente nove perícias independentes.\n- **Pendente:** reconciliar cobertura e resolvers atuais com o código e banco no HEAD/ambiente atual.

### Ficha, mesa e integração
- **Mapa inicial criado:** [INTEGRATION_MAP.md](INTEGRATION_MAP.md) registra a varredura estática dos arquivos principais e a correspondência nominal das RPCs.\n- **Divergência encontrada:** lobby_atualizado.html não é espelho sincronizado de lobby.html (4 RPCs versus 10; consultas a catálogos legados). A publicação descrita no README usa lobby.html; não atualizar nem publicar o arquivo legado sem decisão explícita.
- **Referência:** PLANO_MESTRE_MESA.md contém matriz de fluxos, decisões de iniciativa, tokens, movimento, combate, inventário e conjuração.
- **Parcial:** há fluxos implementados e testes transacionais revertidos documentados.
- **Pendente:** aceite ponta a ponta com sessões autenticadas simultâneas de Mestre e Jogador em campanha descartável.
- **Pendente:** confirmar no código atual as lacunas históricas de ações por classe/nível, evolução de nível, combate, magia, fog of war e experiência de jogador.

### Trabalho recente de progressão e proficiência
- **Evidência recente no histórico Git:** commits relacionados a alfabetização do Bárbaro, orçamento de perícias, idiomas por aumento de Inteligência e normalização/proficiência de armas.
- **Estado:** alterações recentes existem; o aceite funcional completo deve ser conferido antes de declarar a área encerrada.
- **Pendente:** reconciliar cada alteração com testes e critérios de aceite.

### Auditorias de regras/correções recentes
O histórico de continuidade registra correções em:
- Rolagens naturais 1/20 para ataques e salvamentos.
- Resistência à magia e Penetração de Magia.
- Bônus de salvamento e duplicação de talentos.
- Evasão e restrição por armadura.
- Proficiência de armas e familiaridade anã.
- Empilhamento de condições de medo e fadiga.
- search_path e privilégios de funções privilegiadas.
- Integridade de pares save_type/save_dc.

Essas correções não devem ser refeitas automaticamente. Antes, conferir os commits/migrations correspondentes e validar se o estado atual as contém.

## Pendências consolidadas a reconciliar
1. Estado real de cada fluxo da ficha e mesa no HEAD atual.
2. Fonte canônica de CA, ataques, dano, PV e atributos derivados em fichas e tokens.
3. Matriz de ações e capacidades por classe/nível.
4. Evolução de nível e suas escolhas/validações.
5. Cobertura automática dos resolvers de magia, salvamentos, RM e efeitos.
6. Flanqueamento, ataque furtivo, AOO e defesa contra flanqueamento.
7. Testes ponta a ponta com duas sessões autenticadas.
8. Fog of war, visibilidade individual e sincronização multiplayer.
9. Testes de regressão após correções recentes.
10. Divergências entre snapshots históricos do README e dos documentos especializados.

## Regra contra repetição
Uma auditoria só deve ser reaberta quando código/schema relacionado mudou; teste falhou; documentação diverge do estado real; há evidência concreta de risco; ou a auditoria anterior não cobriu o caso necessário.

Ao reabrir, delimitar o delta em vez de repetir todo o escopo.


## Fotografia reconciliada do ambiente — 2026-11-08

Consulta somente de leitura ao Supabase conectado e varredura estática do HEAD do GitHub:

### Banco e funções
- Histórico de migrations: 966 registros (mínima 20261031160944; máxima 20261109005941).
- Relações: public 76; priv 7.
- RLS habilitado: public 76/76; priv 5/7.
- Funções: public 225, sendo 150 SECURITY DEFINER; priv 94, sendo 88 SECURITY DEFINER; private 8, sendo 8 SECURITY DEFINER.
- A fotografia não concede conclusão automática de segurança. Grants efetivos, RLS, search_path, validação interna e exposição por API continuam sendo os critérios de cada função/tabela.

### Catálogos e cobertura
- SRD: 7 raças; 11 classes; 59 registros de perícias; 110 talentos; 1.021 equipamentos; 607 magias; 607 efeitos; 445 monstros; 220 progressões de classe; 1.400 progressões de slots; 131 características de classe.
- Vínculo: 16 classes; 160 habilidades; 95 magias; 191 itens; 72 talentos.
- srd_catalog_entry_audit: 1.403/1.403 linhas em manual_verified.
- srd_catalog_coverage: 15 categorias; 3 complete, 8 in_progress, 4 pending.
- srd_spell_effects: 25 verified_srd e 582 needs_review.
- srd_class_level_features: 131 verified_srd.
- srd_skills: 55 verified_srd e 4 excluded; srd_catalog_coverage.skills ainda registra actual_entries=50. Reconciliar a diferença de 9 registros entre o catálogo (59) e a cobertura (50), verificando critérios de inclusão/exclusão e possíveis duplicatas.

### Distinção importante
A auditoria manual de entradas, a verificação da fonte SRD e a implementação mecânica são estados diferentes. O status manual_verified de 1.403 entradas não significa que todas as regras estejam implementadas. A própria tabela de cobertura registra lacunas mecânicas em características de classe, condições, domínios, magias e efeitos.

### Varredura estática da interface
- mesa.html: 87 RPCs distintas, 27 referências .from(), 9 channel()/on().
- ficha.html: 12 RPCs distintas, 31 referências .from().
- lobby.html: 10 RPCs distintas, 10 referências .from().
- dice.html: nenhuma chamada .rpc() ou .from() detectada.
- Os quatro arquivos são páginas grandes com scripts inline; a varredura não representa grafo completo de chamadas nem teste de execução.\n- Foram identificados 100 nomes distintos de RPC nas três páginas com chamadas; todos os 100 nomes existem em public no Supabase. Ainda falta conferir assinatura/argumentos, grants, autorização e resultado em execução.\n- index.html e lobby_atualizado.html existem em main; dex.html não foi encontrado no caminho consultado.

Nenhum dado de personagem, ficha, campanha, token ou progresso foi modificado nesta fotografia. Nenhuma migration foi aplicada nesta etapa.
