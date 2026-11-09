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
- **Divergência:** snapshots citam 601 e 607 magias em datas diferentes; o número de registros não prova completude nem automatização.
- **Parcial:** estrutura e metadados tipados de efeitos de magia existem, mas classificação/estruturação não equivale a resolução automática validada.
- **Pendente:** reconciliar cobertura e resolvers atuais com o código e banco no HEAD/ambiente atual.

### Ficha, mesa e integração
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
