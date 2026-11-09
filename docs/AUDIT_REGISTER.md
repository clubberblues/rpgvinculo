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
- **Perícias:** 59 linhas no catálogo (55 verified_srd, 4 excluded). A cobertura de 50 linhas-base corresponde a 46 verified_srd e 4 excluded; nove linhas adicionais são especializações de Atuação. A cobertura continua pending por validação mecânica/integração, não por nove perícias-base ausentes. A auditoria de fonte manual tem 50 linhas (46 verified_srd + 4 excluded); as nove especializações de Atuação não têm linha própria nessa tabela e devem ser tratadas conforme a modelagem da perícia Atuação, sem criar automaticamente nove perícias independentes.
- **Pendente:** reconciliar cobertura e resolvers atuais com o código e banco no HEAD/ambiente atual.

### Ficha, mesa e integração
- **Mapa inicial criado:** [INTEGRATION_MAP.md](INTEGRATION_MAP.md) registra a varredura estática dos arquivos principais e a correspondência nominal das RPCs.
- **Divergência encontrada:** lobby_atualizado.html não é espelho sincronizado de lobby.html (4 RPCs versus 10; consultas a catálogos legados). A publicação descrita no README usa lobby.html; não atualizar nem publicar o arquivo legado sem decisão explícita.
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

## Relacionamentos e integridade referencial
- Snapshot PostgreSQL: public 100 FKs, 76 PKs, 20 UNIQUE e 133 CHECKs; priv 10 FKs, 7 PKs, 4 UNIQUE e 28 CHECKs; 14 triggers de usuário (11 public, 3 priv).
- srd_character_equipment.character_id e srd_character_weapon_instances.character_id são text sem FK para characters.id bigint. Os 42 registros de equipamento e 6 de instância de arma consultados correspondem a characters existentes; não há órfãos no snapshot. Registrar como oportunidade de integridade, sem alterar antes de auditar consumidores e planejar migração.
- Identificadores de token em tabelas CBA são text e não têm FK direta para tokens.id; confirmar contrato antes de normalizar.

## Testes — inventário inicial
- **Implementado e aprovado:** scripts/check-static.mjs e workflow .github/workflows/validate-static.yml. Execução #1 passou em 9 blocos JavaScript de 5 páginas ativas e validou o contrato manual do Dice ([run](https://github.com/clubberblues/rpgvinculo/actions/runs/42546411046)).
- **Ainda pendente:** reconstituir Playwright/pglast, testes de regras, banco, autorização e E2E multiplayer.
- O README descreve parse local, pglast e smoke tests Playwright com Supabase simulado.
- package.json, configuração Playwright, arquivos de teste convencionais e workflow CI não foram encontrados nos caminhos consultados.
- Classificação: harness automatizado não localizado nos caminhos convencionais; localizar ou reconstituir os testes e torná-los reproduzíveis.

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
- Os quatro arquivos são páginas grandes com scripts inline; a varredura não representa grafo completo de chamadas nem teste de execução.
- Foram identificados 100 nomes distintos de RPC nas três páginas com chamadas; todos os 100 nomes existem em public no Supabase. Ainda falta conferir assinatura/argumentos, grants, autorização e resultado em execução.
- index.html e lobby_atualizado.html existem em main; dex.html não foi encontrado no caminho consultado.

Nenhum dado de personagem, ficha, campanha, token ou progresso foi modificado nesta fotografia. Nenhuma migration foi aplicada nesta etapa.


## Persistência de cena e tokens
- Foram confirmados dois caminhos coexistentes: CBA em campaigns.cba_data (JSONB) e modelo relacional public.tokens/monster_instances usado por RPCs antigas. Resolvedores de condição/efeito aceitam alvos em ambos os caminhos.
- A mesa atual usa RPCs CBA; RPCs antigas como move_token, attack e start_combat não aparecem na varredura direta do frontend atual. create_campaign ainda cria registro em scenes, mas não foi identificada leitura direta por mesa.html.
- Classificação: compatibilidade/legado a reconciliar; não remover nem migrar antes de mapear todos os consumidores e dados.


### Estado dos objetos relacionais de cena/token
No snapshot consultado: campaigns=3, scenes=3, tokens=0 e monster_instances=0. create_campaign insere uma linha em scenes por campanha. A mesa atual lê/grava campanhas.cba_data e não consulta scenes/tokens diretamente na varredura; os RPCs relacionais antigos continuam no banco, mas as tabelas tokens e monster_instances estão vazias neste snapshot.

A tabela scenes contém parâmetros de mídia/grid (imagem, vídeo, áudio, GIF, tile, offsets, escala e limites). Seu destino deve ser decidido após confirmar se esses campos foram migrados para campaigns.cba_data, media ou outro fluxo. Não apagar a tabela nem o INSERT de create_campaign nesta etapa.


### Realtime e visibilidade
- Foram mapeadas 9 subscriptions na mesa: campaign_log, characters, srd_character_sheets, srd_character_equipment, srd_cba_token_equipment, members, srd_campaign_conditions, srd_campaign_effects e campaigns.
- srd_character_sheets e srd_character_equipment não usam filtro Realtime por campaign_id (essas tabelas não possuem essa coluna); as políticas RLS consultadas restringem leitura por vínculo do personagem/campanha. srd_character_equipment é visível ao proprietário/Mestre, enquanto srd_character_sheets é visível também aos membros da campanha.
- Não houve alteração de policies ou subscriptions. Revisar impacto de performance e confirmar comportamento real de Realtime em duas sessões autenticadas continua pendente.


## Advisories Supabase — fotografia de 2026-11-08
Consulta aos advisors de segurança e desempenho:
- **Segurança — WARN, 99 SECURITY DEFINER executáveis por authenticated:** corresponde ao conjunto de RPCs públicos acessíveis a usuários autenticados. O alerta é genérico; cada função deve ser validada quanto a identidade, papel, campanha, alvo, estado e consumo transacional. Não revogar em lote: isso quebraria fluxos legítimos.
- **Segurança — INFO, 7 tabelas com RLS e sem policy:** duas tabelas internas em priv e cinco tabelas de ledger/recursos/ataques em public. O histórico anterior registrou ausência de grants diretos para anon/authenticated nesses objetos; confirmar grants atuais antes de qualquer alteração. Não criar policies permissivas só para silenciar o advisor.
- **Segurança — WARN, proteção de senha vazada desabilitada:** melhoria de configuração do Auth a avaliar separadamente; nenhuma configuração foi alterada.
- **Desempenho — INFO, 52 índices não utilizados:** muitos são índices de FKs/estruturas recentes ou tabelas ainda pouco usadas. Não remover com base apenas no advisor; avaliar tráfego representativo, planos de consulta e janela de observação.

### Discrepância de ACL em schema interno
- A consulta atual encontrou priv.srd_feat_saving_throw_modifier(jsonb,text) com EXECUTE concedido a PUBLIC (ACL inclui =X); anon não possui USAGE no schema priv, enquanto authenticated possui USAGE.
- A contagem de funções SECURITY DEFINER também mostra 39 funções priv executáveis por authenticated e 6 funções private executáveis por authenticated; esses schemas não foram confirmados como expostos no PostgREST.
- Isso diverge do registro histórico de revogação de EXECUTE para helpers. Classificar como **pendente de confirmar schemas expostos pela API e ACL efetiva**, sem declarar exploração possível e sem alterar ACL antes dessa confirmação.


## CA de personagem vinculado a token NPC — verificação somente de leitura

- O frontend mesa.html usa a sobrecarga de 4 argumentos de public.srd_calcular_ca_personagem_srd para NPCs vinculados à ficha; a sobrecarga encaminha ao helper priv.srd_calcular_ca_alvo_campanha_srd quando o Mestre e o vínculo do token são confirmados.
- O helper calcula armadura/escudo a partir de srd_character_equipment, Destreza efetiva, condições, tamanho, efeitos e características de classe. A rotina de atualização da mesa também usa essa sobrecarga.
- Teste de leitura no ambiente atual: personagem 681 (Thorgar), GM-owned com campaign_id NULL, possui um token NPC vinculado na campanha 131. Ele é distinto do personagem 682 (Thunga Mestre), que pertence à campanha 131 e não possui token vinculado. Resultado da função: final_ac=10, armor_bonus=0, dexterity_modifier=0, effect_modifier=0.
- A linha Armadura de Couro existe no inventário com bônus de CA +2 e máximo de Destreza +6, mas equipado=false. Portanto, CA 10 é coerente com o estado persistido atual; CA 12 seria o resultado esperado depois de equipar a armadura.
- A consulta simulou apenas o claim de identidade para executar a função em modo somente leitura. Nenhum registro foi alterado.
- **Reclassificação:** a pendência histórica “CA 10 quando deveria ser 12” não comprova defeito no resolver. O código atual possui o caminho de CA vinculada; a validação visual final deve ser feita depois que o item estiver equipado por uma ação normal de jogo/fixture descartável, sem alterar os dados atuais.


### Revisão estática adicional dos 99 RPCs SECURITY DEFINER públicos
- Os 99 avisos do advisor foram cruzados com as definições atuais. Todos os 99 possuem ao menos um marcador explícito de guarda no corpo: 96 usam auth.uid(), 40 usam my_role(), 5 usam priv.need_gm(), 37 consultam public.members e 66 chamam helpers priv.* (categorias sobrepostas).
- Nenhum dos 99 ficou sem os marcadores heurísticos pesquisados. Isso reduz o risco de funções completamente desprotegidas, mas não substitui revisão semântica: é necessário verificar se cada guarda valida o usuário, campanha, papel e alvo corretos e se a operação é transacional.
- Os 7 objetos RLS sem policies foram reconsultados: anon e authenticated não têm SELECT/INSERT/UPDATE/DELETE direto nessas tabelas. Portanto, não criar policies apenas para remover o aviso INFO.
- O alerta de 99 SECURITY DEFINER continua registrado para revisão por fluxo; não houve revogação em lote nem alteração de permissões.
