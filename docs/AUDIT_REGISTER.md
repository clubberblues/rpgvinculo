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
- [RPC_INVENTORY.md](RPC_INVENTORY.md) registra 106 nomes de função distintos (100 literais + 6 nomes adicionais únicos alcançados por 4 call sites dinâmicos), 114 assinaturas públicas e marcadores de guarda. A correspondência nominal foi revalidada; compatibilidade completa de argumentos, autorização e runtime ainda precisa ser verificada por fluxo.
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


## Contratos RPC de combate — sobrecargas
- Conferidas estaticamente as chamadas de sete grupos sobrecarregados usados em combate: dano iterativo (5 args), dano de token (11), início de ataque NPC (8), sequência iterativa (8), CA (3/4 por tipo de alvo), modificadores de manobra (6) e AOO natural de monstro (5). Cada chamada corresponde à assinatura com o conjunto de argumentos observado.
- Wrappers de ataque iterativo NPC são SECURITY INVOKER e delegam a priv.*; resolvers de dano/CA relevantes são SECURITY DEFINER com auth.uid e verificações de campanha/papel. Ainda falta teste de execução por papel.

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


## Estado de combate, rolagens e log: caminho atual versus legado

Snapshot de contagens no banco: campaign_log=70, combat_state=0, roll_requests=0 e roll_log=0.

### Caminho atual observado
- A mesa atual usa campaigns.combat_data e campaigns.cba_data para estado de combate/cena.
- Iniciativa atual passa por iniciar_iniciativa_com_dados e/ou iniciar_iniciativa_com_pedido, que escrevem estado em campaigns e registram eventos em campaign_log.
- Dados são preparados no iframe Dice; a mesa recebe o resultado e usa roll_dice/log ou RPC específica da ação. O iframe não persiste diretamente no banco.
- Chat e eventos de jogo são registrados em campaign_log, com visibilidade aplicada por tipo de evento e policy.

### Caminho relacional legado
- combat_state está vazio no snapshot e é usado por start_combat, end_combat, combat_set_turn, end_turn e is_my_turn.
- roll_requests e roll_log estão vazios e são usados por ask_roll/answer_roll e por resolvers antigos de ataque/dano.
- Esses RPCs não aparecem na varredura de chamadas literais do frontend atual.
- Não remover tabelas ou funções nesta fase: podem existir clientes antigos, integrações externas ou dados fora do recorte. Classificar como legado candidato e decidir após confirmar ausência de consumidores e plano de migração.

O sistema atual tem dois modelos de estado de combate/rolagem coexistentes no banco. O caminho atual do produto é campaigns JSONB + campaign_log + iframe Dice; o caminho relacional permanece como compatibilidade/legado.


### RPC server-side roll_dice
public.roll_dice(p_expr,p_visibilidade) continua no banco como SECURITY DEFINER e delega a priv.roll_dice_expr, que gera o resultado no servidor e grava ROLL em campaign_log quando encontra uma campanha do usuário. A busca literal nas páginas ativas index.html, lobby.html, ficha.html, mesa.html e dice.html não encontrou chamada a esse RPC.

Portanto, classificar roll_dice como caminho legado/alternativo não conectado ao fluxo ativo de Dice iframe no snapshot atual. Não conectar esse RPC às ações de personagem: os fluxos de ataque, salvamento, iniciativa e dano devem continuar recebendo os resultados gerados após a interação do usuário no Dice UI. A remoção do RPC exige confirmar ausência de clientes externos/antigos.


## Contrato do fluxo Lobby → Campanha → Personagem

| Etapa | RPC | Contrato observado |
|---|---|---|
| Listar mesas | lobby_list_v2() | Exige auth.uid; retorna campanhas ativas e só revela código de convite ao proprietário |
| Entrar em mesa aberta | entrar_campanha_aberta(p_campaign_id) | Exige autenticação; rejeita campanha com código; cria membership PLAYER |
| Entrar por código da mesa | entrar_campanha_com_codigo(p_campaign_id,p_code) | Código de quatro dígitos; rate limit por usuário; cria membership PLAYER |
| Entrar por código global | join_campaign(p_code) | Procura campanha ativa pelo código; rate limit; cria membership PLAYER e registra entrada |
| Sentar com ficha | sentar_personagem_na_mesa(p_campaign_id,p_character_id) | Exige papel PLAYER e propriedade da ficha; atualiza characters.campaign_id |
| Criar campanha | create_campaign(p_name,p_code,p_location) | Exige autenticação; valida nome/código/local; rate limit; cria campaign, code, registro scenes e evento MESA_CRIADA |
| Alterar configurações | atualizar_configuracoes_campanha(p_campaign_id,p_name,p_require_code,p_code) | Somente owner_id da campanha; atualiza nome e código |
| Preparar exclusão | preparar_exclusao_campanha_propria(p_campaign_id) | Wrapper SECURITY INVOKER para helper privado; valida autorização e prepara a remoção de mídia |
| Finalizar exclusão | finalizar_exclusao_campanha_propria(p_campaign_id) | Wrapper SECURITY INVOKER para helper privado; finaliza remoção transacional após Storage |
| Excluir ficha própria | excluir_ficha_propria(p_character_id) | Exige propriedade da ficha; ajusta estado de combate e exclui dados associados |

As RPCs públicas com mutação são SECURITY DEFINER e têm auth.uid() no corpo, ou delegam a helper privado que valida autorização. Os wrappers de exclusão são SECURITY INVOKER e encaminham a lógica a private.*. A listagem e as rotas de entrada também têm EXECUTE autenticado e anon negado.

### Riscos e decisões ainda em aberto
- Há dois caminhos de entrada por código (global join_campaign e por campanha entrar_campanha_com_codigo); ambos são usados por controles diferentes do lobby, então não remover sem consolidar a UX.
- sentar_personagem_na_mesa atualiza characters.campaign_id; a constraint UNIQUE(campaign_id,user_id) limita um personagem por usuário por campanha. Esse comportamento precisa ser confirmado como regra de produto.
- create_campaign continua criando scenes, embora a mesa atual use campaigns.cba_data; preservar até resolver o destino da tabela scenes.
- O fluxo de exclusão da campanha remove arquivos do Storage entre preparação e finalização no banco; testar recuperação de falha parcial em ambiente descartável.


## Contrato da ficha (ficha.html)

A página de ficha atende dois rulesets por estado de aplicação, sem unificar seus catálogos:
- **Vínculo:** abilities, classes, character_notes, character_spells, character_talents, characters, inventory, items, spells, talents e vinculo_character_sheets.
- **D&D 3.5 SRD:** srd_character_sheets, srd_character_equipment, srd_character_weapon_instances e catálogos srd_* de classes, raças, perícias, talentos, magias, equipamentos, domínios e progressões.

A varredura encontrou 31 tabelas referenciadas diretamente na ficha. O caminho SRD usa JSONB em srd_character_sheets para atributos, perícias, talentos e estado de magias; equipamento e instâncias de armas são estruturas relacionais. O estado de magias conhecido/preparado é salvo em magias_preparadas via salvar_grimorio_srd; as tabelas srd_character_known_spells, srd_character_prepared_spells e srd_character_spell_slot_state não foram encontradas no call graph atual.

### RPCs centrais da ficha
- Criação: finalizar_criacao_personagem_srd (SECURITY INVOKER, auth.uid).
- Domínios e grimório: salvar_dominios_personagem_srd e salvar_grimorio_srd (SECURITY DEFINER, auth.uid).
- Progressão: concluir_avanco_nivel_personagem_srd_v2 (SECURITY INVOKER → núcleo priv).
- Descanso e recursos: descanso_longo_personagem_srd, descanso_longo_npc_vinculado_srd, consultar_furia_barbaro_srd/npc e usar_furia_barbaro_srd/npc.
- Derivados: srd_calcular_ca_personagem_srd e srd35_deslocamento_personagem.
- Equipamento: equipar_item_srd, equipar_item_npc_vinculado_srd e os três wrappers dinâmicos equipar_arma_instancia_*.

Os wrappers dinâmicos de arma são SECURITY INVOKER e encaminham a helpers private.* SECURITY DEFINER que verificam autenticação, propriedade da ficha ou papel GM, identidade do token e vínculo NPC. Isso é um padrão válido de separação entre endpoint público e implementação privilegiada.

### Limites ainda não testados
- Não foi executado fluxo ponta a ponta de criação, progressão, descanso ou equipamento nesta sessão.
- A validação de ficha/mesa com Thunga Mestre (ID 682) permanece bloqueada até confirmar que esse é o personagem de teste pretendido; não confundir com Thorgar (ID 681), NPC-modelo do Mestre.


## Contrato da mesa: iniciativa, turnos, ações e combate

### Iniciativa coletiva
1. O Mestre chama a iniciativa com a lista explícita de personagens jogadores esperados e os resultados individuais dos d20 rolados para seus próprios tokens.
2. mesa.html prepara os dados no iframe; o Mestre clica para rolar. O backend verifica que o número de resultados corresponde ao número de tokens que o Mestre controla e os distribui aleatoriamente entre eles.
3. iniciar_iniciativa_com_dados grava os combatentes do Mestre em campaigns.combat_data e, se houver jogadores esperados, deixa active=false e registra pedido público em campaign_log.
4. Cada jogador rola o próprio d20 no Dice UI. registrar_iniciativa_d20 valida membership PLAYER, propriedade da ficha, presença na lista esperada e resultado 1–20; calcula Destreza + talentos passivos + efeitos e registra a iniciativa.
5. registrar_iniciativa impede nova rolagem da mesma ficha e ativa a ordem somente quando todos os IDs esperados foram registrados.

### Turno e economia de ações
- avancar_turno bloqueia quando há movimento interrompido por AOO, valida o papel e, para jogador, a propriedade do personagem cujo turno está ativo.
- Na passagem de rodada, o backend expira condições e cria pedidos de estabilização/encerramento de paralisia quando aplicável.
- consumir_acao_turno_srd valida turno ativo, propriedade, condições impeditivas e limites de ação padrão/movimento/rápida; persiste action_economy em combat_data.

### Movimento e reações
- O movimento do jogador em combate solicita primeiro a validação AOO; se houver reação pendente, o movimento é interrompido até o Mestre concluir ou cancelar.
- O movimento do Mestre usa mover_token_gm_cba_srd; o movimento do jogador usa mover_token_player_cba quando não há fila AOO pendente.
- Estado de movimento e combate é atualizado em campaigns.cba_data/combat_data; a mesa reaplica o snapshot retornado.

### Ataques e dano
- Ataque iterativo: iniciar sequência → registrar d20 manual com chave de idempotência → resolver tentativa → se crítico, confirmar com outro d20 manual → rolar dano no Dice UI → aplicar dano com arrays de resultados e chave de idempotência.
- O fluxo possui estados recuperáveis (pending_resolution, critical_confirmation_pending, hit_pending_damage, miss, damage_applied) e rotinas de retomada após reconexão.
- NPCs possuem wrappers equivalentes para rolagens do Mestre, com validação de token e papel.

### Magias
- As RPCs de conjuração usadas pela mesa recebem resultados manuais: conjurar_magia_com_acao_srd_manual, conjurar_magia_dano_multialvo_srd, conjurar_magia_efeitos_multialvo e conjurar_missil_magico_srd_manual.
- Salvamentos e Resistência à Magia pendentes são resolvidos com d20 informado pelo jogador/Mestre por srd_resolve_pending_spell_save e srd_resolve_pending_spell_resistance.
- O backend mantém pendências, consome recursos e aplica efeitos; o iframe apenas gera e devolve resultados após clique.

Este contrato está confirmado por inspeção do frontend e das funções SQL. Ainda falta teste de integração com duas sessões autenticadas e uma fixture descartável para validar a sequência completa sem tocar em dados reais.


## Rotas e páginas candidatas a legado
- index.html autentica e redireciona explicitamente para lobby.html.
- lobby.html é a página ativa observada: 10 RPCs literais, incluindo entrada, seleção de ficha, configuração e exclusão de campanha.
- lobby_atualizado.html existe (1.761 linhas), mas não é referenciada por index.html nem pelas páginas ativas. Tem somente 4 RPCs literais e ainda consulta os catálogos antigos public.spells/public.talents; sua navegação interna aponta para lobby.html.
- dex.html não existe no HEAD atual do repositório (404).
- Classificação: lobby_atualizado.html é candidato a arquivo legado/backup; dex.html é referência histórica ausente. Não apagar nem recriar nesta etapa.


## Segunda execução CI — 2026-11-08
- [GitHub Actions run #2](https://github.com/clubberblues/rpgvinculo/actions/runs/42548214654) — **success**.
- Além da sintaxe, protege os contratos de iniciativa manual (registrar_iniciativa_d20 e iniciar_iniciativa_com_dados), registro de ataque manual e proíbe chamadas literais a roll_dice nas páginas ativas.
- Nenhuma alteração de dados de jogo foi necessária.


## Storage e mídia

| Bucket | Acesso | Escrita/remoção | Configuração atual |
|---|---|---|---|
| midia | Público para leitura | Autenticado com validação de caminho/proprietário via priv.can_write_midia/can_delete_midia | Sem limite explícito de tamanho nem allowlist MIME |
| mesa-media | Privado; leitura por can_read_media | Mestre, dentro da pasta da campanha | 50 MiB; allowlist de imagens, vídeo e áudio |

Uso observado:
- lobby.html: avatar de perfil (recorte JPEG 512×512) e capa de campanha.
- ficha.html: retrato e fundo do cabeçalho do personagem.
- mesa.html: fundo da cena e imagem de token no bucket privado mesa-media; usa signed URL de 24 h e caminho persistido em cba_data.
- Snapshot: midia tem 135 objetos, todos image/png/jpeg/webp; maior objeto 16.530.626 bytes e total aproximado 200 MB. mesa-media tem 0 objetos.

### Risco de configuração
priv.can_write_midia valida o caminho e a propriedade, mas não MIME/tamanho. Os inputs do navegador usam accept=image/* em parte dos fluxos, o que não é validação de servidor; capa, retrato e fundo não têm limite de tamanho uniforme no cliente. Como midia é público e não tem allowlist/limite explícito, registrar como **P2 — endurecimento de upload**.

Não alterar bucket, políticas ou objetos nesta fase. Antes de aplicar limites, definir tamanho máximo compatível com os arquivos atuais (o maior tem ~16,5 MB), tipos realmente suportados e mensagens de erro/validação em todos os fluxos. O bucket mesa-media já impõe 50 MiB e allowlist, mas o upload do fundo precisa validar o tamanho antes de enviar.


## Transações, concorrência e idempotência

### Padrões confirmados
- Operações que alteram o agregado da campanha (iniciativa, avanço de turno, movimento GM, pedido de AOO e aplicação de dano iterativo) bloqueiam a linha de campaigns com FOR UPDATE antes de atualizar cba_data/combat_data.
- Movimento de jogador e início de sequência de ataque usam wrappers SECURITY INVOKER que delegam a helpers priv SECURITY DEFINER; os helpers fazem o lock da campanha e validam usuário/estado.
- Ataques iterativos usam idempotency_key em registro de rolagem e aplicação de dano; a sequência mantém estados recuperáveis e tentativas.
- Iniciativa do jogador é idempotente por estado: se a ficha já foi registrada na ordem atual, a RPC retorna o estado existente em vez de aceitar outro d20.
- Pending spell save/SR bloqueia a linha da pendência com FOR UPDATE e valida o status antes de resolver.
- Fúria bloqueia personagem, ficha e campanha; o estado ativo e os usos/dia impedem iniciar duas Fúrias simultâneas.
- Conjuração manual bloqueia personagem/ficha; durante combate também consome ação padrão sob lock da campanha. A atualização do grimório/slot ocorre na mesma transação.

### Lacunas de idempotência para revisão
- avancar_turno recebe apenas campaign_id e usa FOR UPDATE, mas não recebe uma chave de requisição. Jogador tende a ser barrado após o primeiro avanço porque o turno muda; um Mestre pode, em princípio, enviar dois avanços sequenciais e mover dois turnos.
- conjurar_magia_com_acao_srd_manual e conjurar_missil_magico_srd_manual não recebem idempotency key. Locks e economia de ação protegem parte dos cenários, sobretudo em combate, mas uma repetição de requisição fora de combate pode consumir outro espaço e repetir o efeito quando houver recursos.
- Esses pontos são **riscos potenciais de repetição/retry**, não defeitos funcionais reproduzidos. Não adicionar chaves ou alterar contratos antes de definir o padrão comum de ActionRequest/Idempotency e criar testes descartáveis.

### Regra arquitetural proposta
Ações com efeitos não reversíveis ou consumo de recursos devem aceitar um request_id/idempotency_key gerado pelo cliente, armazenar resultado por escopo de usuário/campanha/ação e devolver o mesmo resultado em retries. Locks continuam necessários para concorrência; idempotência não os substitui.


### Exposição de schemas internos — verificação parcial
- authenticated possui USAGE em priv e private; anon não possui USAGE em nenhum dos dois; CREATE é negado para ambos.
- Há 40 funções priv com EXECUTE para authenticated e 6 funções private com EXECUTE para authenticated. Uma função priv.srd_feat_saving_throw_modifier também conserva EXECUTE para PUBLIC; ela é SECURITY DEFINER, STABLE e consulta apenas o catálogo público de talentos, sem acessar dados de campanha/personagem.
- As cinco funções public executáveis por anon são utilitários/trigger SECURITY INVOKER, não SECURITY DEFINER.
- A configuração PostgREST de schemas expostos não está disponível via pg_settings nem pelo endpoint de metadados get_project do conector. Portanto, ainda não foi possível confirmar se priv/private estão ou não expostos à API REST.
- **Ação necessária:** conferir manualmente Supabase Dashboard → Project Settings → API → Exposed schemas. Se priv/private estiverem expostos, revisar imediatamente o conjunto de funções com EXECUTE para authenticated antes de qualquer revogação. Não remover USAGE/EXECUTE agora, pois wrappers SECURITY INVOKER dependem desses grants para chamar helpers internos.


## Revisão de tabelas internas com RLS desabilitado — 2026-11-09

O inventário verbose do Supabase e a consulta direta a ACL identificaram duas relações em `priv` com RLS desabilitado: `priv.throttle` e `priv.srd_aoo_reaction_ledger`.

**Permissões efetivas conferidas:** anon não tem USAGE no schema priv nem privilégios SELECT/INSERT/UPDATE/DELETE nessas relações; authenticated tem USAGE no schema, mas também não possui privilégios diretos nessas tabelas. A ACL de ambas lista somente postgres e service_role. Logo, o alerta do advisor (“RLS disabled”) é válido como hardening pendente, mas não demonstra, isoladamente, leitura/escrita direta por clientes PostgREST.

**Uso interno identificado:** `priv.throttle` é acessada por `priv.locked(text)`, `priv.fail(text,integer)` e `priv.clear(text)`, chamadas por `public.create_campaign`, `public.join_campaign` e `public.entrar_campanha_com_codigo` (SECURITY DEFINER). `priv.srd_aoo_reaction_ledger` é acessada por helpers SECURITY DEFINER de reserva/início de AOO; o helper de reserva exige autenticação e papel GM. Não foi alterado nenhum privilégio, policy ou estado de RLS.

**Tratamento:** manter como hardening P2 condicionado à confirmação de Exposed schemas e revisão dos caminhos SECURITY DEFINER. Não aplicar automaticamente o SQL sugerido pelo advisor: habilitar RLS sem desenhar e testar as policies/semântica de bypass pode quebrar o acesso interno esperado ou criar falsa sensação de segurança. Nenhum dado foi alterado.


## Privilégios padrão do schema interno priv — 2026-11-09

A inspeção de `pg_default_acl` identificou privilégios padrão permissivos para objetos futuros criados pelo owner postgres em `priv`: authenticated recebe SELECT/INSERT/UPDATE/DELETE/TRUNCATE/REFERENCES/TRIGGER/MAINTAIN em futuras tabelas, SELECT/USAGE/UPDATE em sequences e EXECUTE em futuras funções. service_role também recebe privilégios administrativos. Não há default ACL personalizado em `private`.

As relações internas existentes foram individualmente configuradas sem privilégios diretos para anon/authenticated, e as funções existentes passaram por revisão de search_path; portanto, o achado é **risco preventivo para novos objetos**, não evidência de acesso direto atual. Se `priv` estiver exposto no PostgREST, o risco é maior. A configuração Exposed schemas ainda precisa ser confirmada.

**Ação proposta, não executada:** restringir default privileges de authenticated em `priv` (tabelas/sequences/funções) e conceder EXECUTE explicitamente apenas aos helpers internos chamados por wrappers SECURITY INVOKER. Não aplicar antes de reconciliar o histórico e mapear todas as dependências; a alteração de defaults sem grants pontuais pode quebrar chamadas legítimas. Nenhuma ACL foi alterada.


## Exportação remota de AOO e movimento — 2026-11-09

As definições atuais de 37 funções AOO e 41 funções de movimento/ações/iniciativa/turnos foram exportadas em documentos próprios, com SECURITY DEFINER/INVOKER, search_path, grants anon/authenticated e fingerprints. No conjunto AOO, 0 funções concedem EXECUTE a anon; no conjunto movimento/turnos, também 0. Isso não confirma a configuração PostgREST Exposed schemas nem substitui revisão de autorização por caminho de chamada.

Snapshot histórico anterior à recuperação: havia migrations remotas AOO/movimento sem arquivo local. Em 2026-11-10, todas as 81 versões desse conjunto foram restauradas e alinhadas byte a byte ao ledger. A inversão de lock entre cancelamento e resolução/dano segue como risco de deadlock não reproduzido em ambiente concorrente.


### Risco adicional de inversão AOO
A análise de `priv.srd_encerrar_reacao_aoo_pendente_impl` confirmou que o cancelamento explícito de ataque também adquire pending → attack, enquanto ocultação/resolução/dano adquire attack → pending. O risco de deadlock inclui agora cancelamento de reação × ocultação/resolução/dano, além do cancelamento total do movimento.


## Achado P1 — movimento pode contornar o pré-check de AOO — 2026-11-09

**Evidência estática confirmada no estado remoto:**
1. `mesa.html` chama `srd_solicitar_movimento_com_aoo_srd` antes de mover o token. Se o RPC retorna `pending=false`, o frontend continua e chama `mover_token_player_cba` (jogador) ou `mover_token_gm_cba_srd` (Mestre).
2. `public.mover_token_player_cba` é um wrapper SECURITY INVOKER com EXECUTE para authenticated e chama `priv.mover_token_player_cba_impl`.
3. A implementação privada valida autenticação, propriedade, campanha, turno, ação, deslocamento, ocupação e condições, mas **não chama** `srd_detectar_saida_alcance_ameacado_srd` nem o fluxo AOO.
4. `public.mover_token_gm_cba_srd` também é wrapper INVOKER autenticado; a implementação GM valida papel/turno/deslocamento, mas não integra o detector AOO.
5. O trigger `trg_srd_guard_pending_aoo_movement` só bloqueia alteração/removal do token que já tenha um movimento pendente ativo; ele não detecta uma ameaça nova nem protege o caminho sem pending.

**Impacto:** um cliente autenticado pode chamar diretamente `mover_token_player_cba` e mover seu personagem durante o combate sem executar o pré-check AOO. Também existe uma janela TOCTOU entre o RPC de pré-checagem (que bloqueia a campanha apenas durante sua transação) e o RPC que persiste o movimento: outra alteração de token pode ocorrer entre ambos, invalidando a detecção original. O movimento ainda respeita outras validações de servidor, mas o AOO pode ser ignorado.

**Classificação:** P1 — integridade das regras/autoridade do servidor. Confirmado por leitura de frontend, ACL, wrapper, implementação e trigger; não foi executado um exploit nem alterado estado de jogo.

**Correção arquitetural recomendada:** tornar o RPC de persistência de movimento a autoridade única: dentro da mesma transação/lock de campanha, validar identidade/turno/ação, recalcular ameaças, criar o registro pending e retornar sem mover quando houver AOO; somente mover e consumir deslocamento quando não houver ameaça. Adaptar o frontend para um único resultado (`pending` ou `moved`) e retirar a confiança no pré-check separado. Aplicar ao caminho de jogador e, após confirmar a política de autoridade do Mestre, ao caminho GM. Não aplicar patch isolado sem fixture e teste de regressão.


### Extensão do bypass — fila pending pode ser contornada por outro token
Consulta direta aos corpos de `priv.mover_token_player_cba_impl` e `priv.mover_token_gm_cba_srd_impl` confirmou que ambos não referenciam `priv.srd_aoo_pending_movements`, não chamam o detector AOO e não chamam o pré-check. O trigger `priv.srd_guard_pending_aoo_movement` busca um pending ativo, mas só impede alteração/removal do token que é o próprio `mover_token_id`; ele não bloqueia alterações de outros tokens. Assim, uma chamada direta ao RPC de movimento de outro token pode contornar também a serialização global que `srd_solicitar_movimento_com_aoo_srd` tenta impor (a função de pré-check rejeita qualquer pending ativo). Isso pode alterar a posição de ameaças enquanto uma reação está sendo resolvida.

**Impacto adicional:** quebra da invariável “uma única movimentação pendente por campanha” e mutação da cena durante a resolução AOO, além do bypass do detector e da janela TOCTOU. Mantida classificação P1.


## Achado P2 — footprint Colossal inconsistente (5×5 vs 6×6) — 2026-11-09

A consulta de todas as funções com classificação de tamanho encontrou divergência no tamanho de espaço Colossal:
- Correto no banco: `priv.srd_token_grid_footprint` retorna 6 para Colossal; `public.srd_detectar_saida_alcance_ameacado_srd` também usa footprint 6.
- Incorreto: `priv.mover_token_player_cba_impl` e `priv.mover_token_gm_cba_srd_impl` usam 5; as duas sobrecargas de `public.aplicar_dano_token_ataque_srd_v2` usam 5 para atacante e alvo; `public.usar_imposicao_maos_mortos_vivos_srd` também usa 5 para atacante/alvo em cálculo de distância.

Em D&D 3.5, Colossal ocupa 30 ft (6 quadrados). A inconsistência pode permitir ocupação/colisão incorreta e calcular distância/alcance de ataque ou habilidade de forma divergente em tokens Colossais. As outras categorias consultadas usam Fine/Diminuto 1, Pequeno/Médio 1, Grande 2, Enorme 3 e Imenso/Gargantuan 4, sem divergência semelhante nesta busca.

**Classificação:** P2 — regra de borda, mas afeta ocupação, distância e alcance de tokens Colossais. Confirmado por comparação estática dos corpos remotos; não reproduzido em fixture. Não alterado.

**Correção candidata:** substituir as classificações duplicadas por chamada ao helper canônico `priv.srd_token_grid_footprint` ou alinhar explicitamente para 6, e centralizar toda geometria de footprint nesse helper. Testar limite de 5/6 quadrados, sobreposição, alcance, AOO, ataques e imposição de mãos contra mortos-vivos.


## 2026-11-09 — advisors remotos e integridade de movimento
- Coletados advisors Supabase security/performance em modo read-only; baseline detalhado em [ADVISOR_SNAPSHOT_2026-11-09.md](ADVISOR_SNAPSHOT_2026-11-09.md).
- 99 SECURITY DEFINER públicas executáveis por authenticated foram sinalizadas. Revisar autorização individualmente; não revogar EXECUTE em lote.
- 7 tabelas com RLS ativo sem policy e 52 índices não utilizados foram sinalizados. Não são, por si só, evidência de exposição ou de índice descartável.
- Proteção de senha comprometida está desativada no Auth; depende de ajuste no Dashboard.
- Deploy Pages do HEAD `89590799209d1c86395a65eb9ebe968087120d5d` passou. Execuções anteriores concorrentes foram canceladas; o resultado não valida os fluxos de jogo.
- Reafirmado P1: movimento direto por RPC não integra o detector AOO e pode contornar a serialização de pendências. Nenhuma correção foi aplicada sem fixture/regressão segura.


## 2026-11-09 — ampliação do P1 de movimento/CBA
- Confirmado que `public.salvar_cena_cba` pode substituir coordenadas de tokens existentes e aceitar inserções sem validação de ocupação; a função é usada por fluxos legítimos durante combate.
- Identificado risco de lost update por snapshot obsoleto, capaz de reverter estado de token gravado por RPC concorrente.
- A correção deve separar escrita de metadados, mutações de ficha/token, spawn e movimento; preservar coordenadas e estado autoritativo de combate fora dos RPCs próprios.
- Regressões 9–15 adicionadas em TEST_STRATEGY.md. Não executadas; nenhuma mudança de produção aplicada.
- Restrição de custo: somente harness gratuito/efêmero em GitHub Actions; nenhum projeto/branch Supabase pago.


## 2026-11-09 — ordem transitiva de locks de combate, ficha e equipamento

A auditoria read-only foi ampliada para recursos de classe, descanso, arma equipada e sequência iterativa. Corpos remotos consultados por assinatura completa; triggers também foram verificados.

### Achados adicionados
- **Ataque iterativo — ciclo instância de arma → campanha → instância:** wrapper 7 bloqueia instância antes de iniciar sequência/campanha; resolver bloqueia campanha, tentativa e sequência e depois solicita `FOR SHARE` na mesma instância. A janela é plausível quando a resolução de uma sequência anterior concorre com nova chamada de início usando a mesma arma. Não reproduzido em produção.
- **Ficha — inversão campanha/personagem:** descanso longo de NPC vinculado bloqueia campanha → personagem → ficha; habilidades de classe/Imposição das Mãos bloqueiam personagem → ficha → recurso → campanha. O ciclo depende de ambas as operações incidirem na mesma ficha de NPC vinculada e de propriedade do Mestre. Não generalizar para personagens diferentes.
- **Arma — inversão condicional campanha/instância:** equipamento de NPC vinculado bloqueia campanha → instância; início de ataque iterativo 7 bloqueia instância → campanha. Depende de compartilhar campanha e instância.
- **Consistência parcial:** registro/resolução/aplicação de dano de ataques iterativos começam pela campanha antes de tentativa/sequência; o lock antecipado da instância está concentrado no wrapper 7. O caminho de consulta de sequência bloqueia apenas a sequência e não adquire depois campanha no corpo observado.
- **Condições de PV:** `priv.srd_sync_character_vital_condition` altera condições sem lock inicial de campanha. A ordem depende do chamador; não deve ser tratada como helper campanha-primeiro.
- **Trigger de inventário:** `srd_character_equipment` possui trigger AFTER INSERT/DELETE/UPDATE OF quantidade que cria/remove instâncias de armas. A função de trigger sincroniza instâncias e o estado agregado do inventário. A interação com operações concorrentes de equipamento exige análise de DML/row locks por endpoint; não foi classificada como ciclo confirmado nesta etapa.

### Testes sintéticos adicionados
- `tests/sql/lock_cycle_test.sh` agora cobre três padrões deliberadamente invertidos: campaign/effect (existente), campaign/weapon e campaign/character.
- Fixtures usam tabelas isoladas no PostgreSQL efêmero. Elas comprovam somente que o PostgreSQL detecta o padrão de lock montado; não executam RPCs reais, não medem incidência em produção e não simulam Auth/RLS.
- O workflow gratuito `PostgreSQL fixture tests` para o commit `7de4c031087c3a5084881c0f2049c3596915d6c0` terminou em **success** (run 42670106095). Os logs confirmam a aprovação das fixtures de footprint e dos três padrões sintéticos campaign/effect, campaign/weapon e campaign/character. Não executa RPCs reais nem comprova deadlocks de produção.

### Advisors Supabase — nova coleta 2026-11-09 18:00 UTC
- Security: 99 funções SECURITY DEFINER executáveis por authenticated (WARN), 7 tabelas com RLS e sem policy (INFO), proteção contra senha vazada desativada no Auth (WARN).
- Performance: 52 índices sinalizados como não utilizados (INFO).
- Health: nenhum lint retornado.
- Estes resultados repetem os grupos já registrados. Não revogar grants, criar policies genéricas, remover índices ou alterar Auth automaticamente; cada medida exige avaliação funcional e operacional própria.

### Estado das alterações
- Commits documentais/testes publicados em `main`: `773a96b` (recursos/equipamento), `158573b` (ciclo de arma no ataque iterativo), `7de4c03` (fixtures sintéticas).
- Nenhuma função, trigger, ACL, policy, migration, setting de Auth ou dado de campanha foi alterado no Supabase remoto.
- Próxima etapa: aguardar/validar CI; continuar análise de locks transitivos por assinaturas e triggers, e só então desenhar protocolo global. Reconciliação de migrations continua pré-condição para qualquer patch SQL remoto.


### Conjuração e lock de ficha — 2026-11-09
- Entry points de conjuração manual/dano/efeitos foram inspecionados por assinatura. Os caminhos atuais adquirem personagem e ficha antes da campanha; alguns bloqueiam também fichas-alvo.
- Isso amplia a família personagem/ficha → campanha que pode concorrer com o descanso longo de NPC vinculado (campanha → personagem → ficha) quando as duas operações incidem sobre a mesma ficha de propriedade do Mestre.
- Resolução de pendência de magia: aplicador interno bloqueia pendência → campanha; resolvers de salvamento/RM bloqueiam pendência sem lock posterior de campanha no corpo observado. Não há evidência suficiente para classificar a relação como ciclo.
- Regressão de descanso × conjuração na mesma ficha vinculada incluída no escopo de concorrência. Não executada contra produção.


### Protocolo global de locks — proposta
- [LOCK_ORDER_PROTOCOL_DRAFT.md](LOCK_ORDER_PROTOCOL_DRAFT.md) consolida a ordem candidata de aquisição de locks, evidências de inversões, critérios de aceite e bloqueios antes de qualquer migration.
- Status: rascunho não aprovado. A ordem ainda depende do mapeamento de todas as chamadas transitivas por OID/assinatura e testes de concorrência; não autoriza alteração no Supabase.


### Triggers e inventário — 2026-11-09
- Confirmado o efeito transitivo do trigger `sync_character_weapon_instances_from_inventory`: alterações de inventário por INSERT/DELETE/UPDATE OF quantidade também criam/removem instâncias de armas e atualizam o resumo da linha de equipamento.
- A função de equipar instância de personagem segue personagem → instância → resumo de inventário; caminhos de inventário podem adquirir locks na linha de equipamento antes de chegar às instâncias via trigger. Risco de inversão é condicional a operações de quantidade/remoção na mesma ficha/arma; ainda não reproduzido.
- O trigger de preview AOO executa RPC de movimento em subtransação e força rollback para validar sem persistir movimento. Isso deve ser incluído na revisão dos locks transitivos dos requests de movimento.
- Regressões de inventário/instâncias foram adicionadas à estratégia; nenhuma operação de inventário remota foi executada.


### CI de extensão AOO — diagnóstico pendente
A execução 42673083206 para o commit `91a13d7db6c46b88d1cd9c64570c84409d085d24` terminou com `failure`, porém o endpoint de jobs retornou zero jobs e não há logs de etapas. O GitHub recusou retry. Não classificar como falha dos testes SQL sem job/log que a comprove. Uma nova execução será gerada após a alteração de testes em `tests/sql`.


### Estado consolidado dos testes AOO/inventário — 2026-11-09
- Novos modelos sintéticos incluídos: campaign/pending, pending/attack e equipment/weapon instance, além dos pares anteriores.
- A execução do workflow para commit `502b47bc28b61ed7ed5c3dab181fee62c9f433ec` está queued (run 42673548023); aguardar resultado antes de declarar aprovação.
- A tentativa anterior (run 42673083206) falhou sem check jobs ou logs de etapas. Foi classificada como falha sem diagnóstico, não como erro confirmado dos testes SQL. A concorrência que cancelava execuções foi removida.


## Concorrência e ordem de locks — 2026-11-10
- **Parcial / verificado estaticamente:** auditoria read-only de OIDs, definições instaladas, privilégios efetivos e call sites para AOO, ataques iterativos PC/NPC, ficha, magia, recursos de classe, condições e movimento.
- **Evidência:** [LOCK_ORDER_PROTOCOL_DRAFT.md](LOCK_ORDER_PROTOCOL_DRAFT.md) contém o grafo parcial, OIDs, locks próprios/herdados e limites; [LOCK_ORDER_REFACTOR_PLAN.md](LOCK_ORDER_REFACTOR_PLAN.md) contém proposta faseada ainda não aprovada para deploy.
- **CI:** PostgreSQL fixture run #72 [42730159992](https://github.com/clubberblues/rpgvinculo/actions/runs/42730159992) passou footprint helper + oito padrões sintéticos de deadlock + um controle positivo. Não executa RPCs de produção.
- **Limites:** deadlocks de produção não foram reproduzidos; `pg_stat_database` mostra zero desde reset em 2026-08-25 e nenhum lock aguardando na amostragem de 2026-11-10, o que não elimina ciclos potenciais.
- **Bloqueio de mudança:** 681 arquivos SQL locais versus 966 registros remotos, 640 versões coincidentes por timestamp/nome e conteúdo não reconciliado. Não alterar funções/migrations/ACL/policies/dados até reconciliar e validar em ambiente descartável.
- **Próxima ação:** fechar grafo transitivo dos writers/callers e helpers/triggers; depois implementar fatias pequenas com teste real das RPCs em PostgreSQL descartável e plano de rollback.

- **Achado adicional condicionado:** public.gm_transfer (OID 18749), SECURITY DEFINER com EXECUTE authenticated, valida owner por leitura sem lock via priv.need_owner e depois altera papéis/owner_id; chamadas concorrentes podem reutilizar uma validação de propriedade obsoleta. Sem call site direto localizado nas páginas principais. Registrar como corrida de autorização a testar antes de manter/alterar o endpoint; não é deadlock reproduzido.

- **Regressão de transferência:** CI PostgreSQL #100 [42731471362](https://github.com/clubberblues/rpgvinculo/actions/runs/42731471362) passou os dois cenários sintéticos de TOCTOU/campaign-first. A simulação reproduziu a dupla transferência stale e demonstrou que lock da campanha + revalidação rejeita a segunda chamada. Não executou gm_transfer remoto.


### Movimento/AOO — ampliação do bypass e regressão do Encontrão (2026-11-10)
- **P1, confirmado estaticamente:** além dos wrappers diretos de movimento, public.salvar_cena_cba (OID 20077, authenticated EXECUTE, GM-only) substitui tokens em campaigns.cba_data e aceita coordenadas sem detector AOO quando não existe pending ativo. Revogar somente os wrappers de movimento não fecha a rota.
- **P1, integridade da pending:** adicionar_token_cba_completo (OID 21726) permite spawn de token autenticado durante combate; srd_configurar_perfil_combate_token_srd (OID 26922) altera facção/alcance. O guard atual não congela essas mudanças durante pending, podendo tornar obsoleta a lista de ameaças. Definir política explícita de freeze/cancelamento e exceções de reação.
- **P2, regressão funcional provável/estaticamente demonstrada:** o resolver de Encontrão (OID 27169; wrapper OID 27172) altera as coordenadas do token mover no ramo p_follow=true, mas não define app.srd_aoo_pending_commit; o trigger de pending rejeita alteração de coordenadas do mover. O frontend oferece essa opção. Teste de integração deve confirmar e corrigir com autorização restrita à manobra.
- **Evidência:** docs/MOVEMENT_AOO_AUTHORITY_GAP.md e docs/CBA_MUTATION_INVENTORY.md. Consultas ao Supabase foram somente leitura; nenhuma RPC de jogo, migration, ACL, policy, dado ou TESTE 2 foi alterado.
- **CI:** commit fc2f008e59e980305990e9083058f2b2e76c7750 teve Static validation #62, Validate application JavaScript #110, Validate mesa JavaScript #365 e PostgreSQL fixture #271 (42749952496) em success. O fixture não testa RPCs remotas. Commits seguintes até o HEAD corrente alteram somente documentação.
- **Decisão:** não implementar trigger/ACL/migration ainda. Fechar identidade estável de tokens, writers geométricos, exceções de manobra e ordem de locks; reconciliação do histórico de migrations continua bloqueio de deploy.



### AOO — mutabilidade das fontes do snapshot (2026-11-10)
- **P1, confirmado estaticamente:** detector OID 26923 deriva ameaças de posição/footprint/facção/alcance, raça/tamanho de ficha, armas equipadas, ataques naturais e Monge/Ataque Desarmado Aprimorado. Pending armazena o snapshot, mas o guard só verifica mover/remoção/posição.
- **P1, endpoint ativo:** equipar_item_srd OID 20555 (authenticated EXECUTE) permite dono/GM alterar arma; cadeia OID 26390 → 26442 → 26441 bloqueia personagem/instância, mas não campanha/pending. entregar_item_srd OID 20556 (GM-only) pode adicionar item equipado automaticamente, também sem lock de campanha/pending. O resolver AOO revalida arma equipada, portanto a reação pode ficar inválida após a detecção.
- **P1, fontes CBA:** salvar_cena_cba OID 20077 substitui dados completos de token e srd_configurar_perfil_combate_token_srd OID 26922 altera facção/alcance; o guard não protege esses campos. adicionar_token_cba_completo OID 21726 adiciona novo possível ameaçador durante pending.
- **Política ainda em aberto:** congelar todas as dependências até terminalidade ou invalidar/cancelar e recalcular pending de modo atômico. Não há implementação ainda; consultas foram read-only.
- **Detalhes e testes:** docs/MOVEMENT_AOO_AUTHORITY_GAP.md e docs/CBA_MUTATION_INVENTORY.md.



- **P1, TOCTOU normal do movimento:** OID 26964 retorna `continue_with_existing_movement_rpc=true` sem commit quando não há ameaça; frontend então grava por OID 20522/21615 em transação separada. Outro writer pode alterar ameaças entre as chamadas e o RPC direto não recalcula AOO. Requer detecção + movimento na mesma transação. Evidência: MOVEMENT_AOO_AUTHORITY_GAP.md.


- **Reproducer CI, 2026-11-10:** fixtures #284 [42751013687](https://github.com/clubberblues/rpgvinculo/actions/runs/42751013687) e #285 [42751022904](https://github.com/clubberblues/rpgvinculo/actions/runs/42751022904) success. O modelo copiado do trigger reproduziu duplicata do mover e movimento de outro token durante pending; controlou bloqueio de movimento único e atualização de metadados. Não executa o trigger/RPC Supabase instalado.



- **P1 mecânico — snapshot de armas incompleto:** OID 26923 grava source/range sem instância; consulta OID 27044 lista equipamento atual; início OID 27022 aceita instância atual equipada sem provar que estava equipada no gatilho. Mudanças por OIDs 20555/20556 durante pending podem invalidar/criar elegibilidade AOO. Correção exige snapshot de arma exata ou freeze de equipamento. Evidência em MOVEMENT_AOO_AUTHORITY_GAP.md.



- **P1/P2 mecânico — footprint duplicado Colossal:** OIDs 24744/25562 (ataque físico, overload ativo na mesa) e 25509 (Imposição das Mãos/toque, callsite ativo) ainda calculam Colossal=5 e não usam helper; OIDs 27073/26923 usam 6. A centralização deve alcançar ataques e toque, não apenas movimento. Evidência em MOVEMENT_AOO_AUTHORITY_GAP.md.



### Reconciliação do baseline de migrations — 2026-11-10
- `supabase_migrations.schema_migrations` preserva `statements[1]` para os 966 registros. Foram recuperados 326 arquivos ausentes; 103 variantes locais de versões aplicadas e 41 migrations locais sem versão remota foram preservadas em `docs/migration_reconciliation/`.
- A pasta `supabase/migrations` contém agora exatamente 966 arquivos e os 966 hashes Git coincidem byte a byte com o ledger remoto. As 81 versões movimento/manobras/AOO estão alinhadas.
- 13 variantes locais de versões aplicadas apresentavam diferenças semânticas; 90 eram diferenças de comentários/formatação/casts/terminadores. As 41 migrations locais em quarentena: 34 duplicatas semânticas com timestamp divergente, 5 variantes divergentes e 2 exclusivas de Anão/Bárbaro.
- Nenhuma migration foi aplicada no Supabase; nenhum schema, função, ACL, policy, dado ou TESTE 2 foi alterado. Próximo gate é reproduzir o baseline completo em stack local descartável antes de nova migration.


- **Bypass reproduzido em fixture descartável:** tests/sql/aoo_guard_duplicate_identity_repro.sql copia o trigger remoto e confirma que dois tokens com a mesma identidade (id/key) passam quando a primeira cópia permanece na origem e a segunda muda de coordenadas; o LIMIT 1 só compara a primeira. A mesma fixture confirma que outro token (ameaçador) pode mudar coordenadas enquanto o mover está pendente. Runs #284/#285/#293 passaram como reproduções intencionais, não como correção de segurança. Não executa a RPC instalada nem comprova exploração via API.


### CI — replay de migrations e harness de AOO (2026-11-10)
- PostgreSQL fixtures run [42808666665](https://github.com/clubberblues/rpgvinculo/actions/runs/42808666665): success. Logs confirmiram reprodução de duplicação de identidade do mover, alteração de coordenadas do ameaçador durante pending, footprint, lifecycle NPC e testes sintéticos de lock/autorização/Storage. A fixture AOO é reproducer intencional, não aprovação de segurança.
- Replay integral [42808666675](https://github.com/clubberblues/rpgvinculo/actions/runs/42808666675): failure na primeira migration 20261031160944, SQLSTATE 42P01, relation public.campaigns does not exist. O stack era local descartável e foi parado pelo cleanup; nenhuma credencial/projeto Supabase remoto foi configurado.
- Root cause e plano de recuperação em docs/MIGRATION_RECONCILIATION.md. PR segue draft e não mesclado.


- **Nova confirmação read-only no catálogo Supabase (2026-11-10):** as funções AOO não compartilham ordem de locks. `srd_resolver_ataque_oportunidade_srd` OID 27025 e `srd_registrar_ocultacao_ataque_oportunidade_impl` OID 27254 bloqueiam attack → pending → campaign; `srd_reservar_reacao_movimento_aoo_impl` OID 27256 e `srd_resolver_encontrao_srd` OID 27169 bloqueiam pending → campaign. Solicitação/finalização são campaign-first. Isso confirma inversão estrutural e risco de deadlock, sem demonstrar deadlock ocorrido. Protocolo e regressões atualizados em `docs/LOCK_ORDER_PROTOCOL_DRAFT.md`.


### AOO — inventário ampliado de escritores CBA (2026-11-10)
- Catálogo remoto read-only identificou escritores adicionais de `campaigns.cba_data`: movimento GM/jogador OID 27306/27366; salvamento geral OID 20077; spawn completo OID 21726; perfil facção/alcance OID 26922; avanço de turno OID 20074; ataque físico v2 OID 24744/25562; Imposição das Mãos OID 25509; finalização AOO OID 27038; Encontrão OID 27169, além de rotas de PV/equipamento/efeitos.
- Referência textual a coordenadas não prova que a função altere geometria; ainda é necessário classificar diffs efetivos por função. O trigger ligado a `cba_data` é único e não substitui contrato comum para todos os writers.
- Arquitetura futura deve centralizar ou fechar o conjunto de escritores, com política explícita para pending ativo (freeze ou invalidar/recalcular dependências AOO). Booleano `has_function_privilege` em `priv.*` não prova exposição PostgREST sem verificar grants do schema e wrappers.
- Sem alteração de produção. Evidência detalhada: `docs/MOVEMENT_AOO_AUTHORITY_GAP.md`.


### Segurança — grants do schema interno `priv` (2026-11-10)
- Supabase remoto: authenticated tem USAGE no schema `priv` e EXECUTE em funções internas SECURITY DEFINER, incluindo OIDs 27306, 27366 e 27169. ACL inclui `authenticated=X`. Risco confirmado na camada SQL; exposição REST/PostgREST não foi provada, pois a configuração `pgrst.db_schemas` não foi obtida.
- Correção candidata: revogar USAGE/EXECUTE para papéis cliente após inventário de dependências e manter wrappers públicos autorizadores. Nenhuma ACL alterada. Evidência em `docs/MOVEMENT_AOO_AUTHORITY_GAP.md`.

- **Ressalva da remediação `priv`:** revogação em bloco de USAGE/EXECUTE não é segura; wrappers públicos invoker chamam diretamente funções internas. Necessário converter/reprojetar cadeia de chamadas após revisão de search_path/ownership/autorização, com testes de regressão, antes de restringir grants. Nenhuma mudança aplicada.


### Schema `priv` — dependências públicas quantificadas (2026-11-10)
- 70 funções internas `priv.*` distintas chamadas a partir de `public`; 35 funções públicas `SECURITY INVOKER` distintas chamam `priv.*` e têm EXECUTE para authenticated. O escopo inclui movimento, AOO, ataques iterativos NPC, dano, ações de turno, avanço de nível e descanso.
- Revogar USAGE/EXECUTE em bloco quebraria cadeias invoker; conversão em lote também não é segura. Exigir matriz por assinatura, autorização, owner e search_path e migração/testes individuais antes de restringir schema. Sem alteração de ACL/função. Ver `docs/MOVEMENT_AOO_AUTHORITY_GAP.md`.

- ACL interna: 40 funções `priv.*` com EXECUTE authenticated, 39 SECURITY DEFINER. Exceção: `priv.srd_feat_saving_throw_modifier(jsonb,text)` OID 26355 tem grant PUBLIC/EXECUTE e é chamada também por anon; parece helper read-only de cálculo de talentos, mas precisa decisão explícita. Nenhum CREATE de authenticated/anon em public/priv. Sem alteração de grants.

- `priv` ownership: 94 funções com owner postgres, 88 SECURITY DEFINER. Helper invoker `srd_parse_natural_attack_list(text)` OID 27228 também tem EXECUTE authenticated; demais cinco helpers invoker observados não têm EXECUTE cliente. Config PostgREST não pôde ser obtida via current_setting (NULL), logo exposição REST de `priv` não comprovada.


### CI concluído e incompatibilidade invoker/priv (2026-11-10)

- PR #74 / HEAD `e32716894d3388478d416e63a31926a811810395`: 4 workflows concluídos com sucesso (validação estática, JS aplicação, JS mesa, PostgreSQL fixtures); replay completo das 966 migrations falhou na inicialização do stack descartável, ao aplicar `20261031160944_srd35_action_economy.sql`, por `relation public.campaigns does not exist`. Nenhuma migration foi efetivamente reproduzida; a causa continua sendo a ausência de bootstrap histórico confiável.
- O job de fixtures confirmou assertions de footprint, reproduziu bypass por identidade duplicada do mover, e executou ciclos de lock/concorrência e controles de autorização isolados. Os logs exibem deadlocks e autorizações obsoletas como resultados intencionais das reproduções; os controles campaign-first passaram. Isso não equivale a teste das RPCs reais no Supabase remoto.
- Catálogo remoto: duas RPCs invoker de manobra/ataques naturais têm EXECUTE authenticated, mas chamam helper(s) `priv` sem EXECUTE para authenticated: `srd_consultar_modificadores_manobra_srd` (OID 27119) e `srd_listar_ataques_naturais_oportunidade_srd` (OID 27229). A incompatibilidade é objetiva no catálogo; confirmar erro ponta a ponta em sessão autenticada antes de corrigir. Nenhuma ACL/função alterada.
- Evidência detalhada e proposta de correção específica em `docs/MOVEMENT_AOO_AUTHORITY_GAP.md`.


### Correção de autorização em catálogo de manobras (2026-11-10)

- Identificada incompatibilidade específica de privilégio: dois wrappers públicos SECURITY INVOKER chamam helpers `priv.*` sem EXECUTE authenticated. A sobrecarga de 6 argumentos da consulta de manobras é afetada no ramo Derrubar; o catálogo de ataques naturais é afetado ao construir perfil.
- A origem está nas migrations de 08/11 que criaram esses wrappers como invoker. A análise refinada não encontrou outros wrappers públicos invoker com dependência direta sem EXECUTE authenticated na amostra de chamadas diretas resolvidas.
- Migration focalizada e script de verificação foram adicionados ao branch de auditoria; nenhum SQL foi executado no banco remoto. A conversão para SECURITY DEFINER preserva os guards auth.uid()/GM e search_path fixo, sem abrir EXECUTE dos helpers internos ao cliente.
- Regressão autenticada e revisão final ainda pendentes; não declarar corrigido em produção.

### EXECUTE em wrappers de manobra e helper passivo (2026-11-10)

- Duas funções públicas invoker com chamadas a helpers internos sem EXECUTE authenticated foram corrigidas em migration proposta, sem abrir grants nos helpers.
- Um helper passivo de talentos tinha EXECUTE herdado de PUBLIC, tornando-o também executável por anon; chamador SQL catalogal identificado é função SECURITY DEFINER interna; grants explícitos de authenticated/service_role foram preservados. Migration proposta remove somente o grant PUBLIC e preserva authenticated/service_role no helper, e preserva os grants authenticated/service_role já existentes nas RPCs GM.
- Adicionados dois scripts de verificação e um fixture PostgreSQL que aplica as migrations e testa o modelo de privilégio isoladamente; workflow de fixtures atualizado.
- Nada aplicado em produção. A execução do CI no HEAD atual e as chamadas reais autenticadas permanecem pendentes.

### EXECUTE interno: condição, talentos, parser e ataque iterativo (2026-11-10)

- A revisão de helpers com EXECUTE authenticated encontrou três funções sem contexto de autorização que não precisavam ser chamadas diretamente pelo cliente: leitura booleana de flags de condições, cálculo passivo de modificadores de resistência e parser de ataques naturais. Seus chamadores identificados são funções SECURITY DEFINER/triggers.
- Também foi identificado que os helpers SECURITY DEFINER de sequência iterativa 7/8 argumentos estavam diretamente executáveis por authenticated. O helper de 7 args não validava usuário/propriedade antes de acessar arma; o de 8 args consultava ficha/arma antes de delegar a validação.
- Migration proposta remove EXECUTE cliente desses cinco helpers, preserva service_role, e move a fronteira autenticada para wrappers públicos com checagem explícita de usuário, propriedade e membership PLAYER.
- Fixture isolado e script de verificação ampliados. Nenhuma ACL/função foi alterada no banco remoto; schema REST PostgREST ainda não foi confirmado.


### Dependências AOO em inventário, ficha e schema interno `private` (2026-11-10)

- Trigger `private.sync_character_weapon_instances_from_inventory` propaga INSERT/DELETE/UPDATE de quantidade em `srd_character_equipment` para `srd_character_weapon_instances`; inventário é writer transitivo de armas/alcance AOO.
- `entregar_item_srd` e `equipar_item_srd` são chamados por `mesa.html` e não adquirem lock de campanha no fluxo de personagem. `private.equipar_arma_instancia_personagem_impl` também tem EXECUTE authenticated e bloqueia personagem → instância, sem campanha/pending. O schema `private` tem USAGE authenticated; 8 funções SECURITY DEFINER, 6 com EXECUTE authenticated e nenhuma com anon. Exposição PostgREST permanece não confirmada.
- `ficha.html` chama o wrapper ativo de avanço de nível. A implementação interna bloqueia personagem → ficha e atualiza nível/atributos/talentos/progressão de classe sem lock de campanha nem guarda real de combate. Talento Ataque Desarmado Aprimorado e classe Monge são entradas do detector AOO; avanço durante pending pode alterar elegibilidade/ameaça.
- Metadados de idiomas e PV derivados foram separados das premissas de ameaça; não congelar toda escrita de ficha/inventário. Refatoração deve ser por campo/efeito, campaign-first, com invalidação atômica quando uma premissa AOO mudar.
- Evidência e limites registrados em `docs/ACTIVE_WORK_ITEM.md`. Consulta read-only; nenhuma mudança remota.


### Writers de condição/efeito que alteram elegibilidade AOO (2026-11-10)

- O helper de flags usado na reserva AOO consulta condições, efeitos ativos e estado de Confusão. A reserva verifica flags que tornam o reator inelegível, incluindo `no_actions`, `helpless`, `stunned`, `unconscious`, `disabled` e `no_aoo_against_unengaged`.
- As funções de aplicação de condição/efeito já bloqueiam `campaigns` antes da mutação. Em contraste, `public.srd_remove_campaign_condition` e `public.srd_remove_campaign_effect` atualizam suas tabelas sem lock de campanha ou tratamento de pending; a remoção de efeito é um bypass direto de elegibilidade tão relevante quanto remoção de condição.
- `public.srd_resolve_dying_round` mantém ordem personagem → ficha → campanha → condição, incompatível com campaign-first e potencial fonte de deadlock concorrente com operações de combate.
- O contrato deve serializar escritores de condições/efeitos por campanha e tratar alterações internas como parte da transação de reação; sem trigger AOO nessas tabelas, a consistência hoje depende dos contratos RPC.
- Nenhuma alteração remota ou execução funcional realizada; evidência estática documentada em `docs/ACTIVE_WORK_ITEM.md`.


### Fúria: novos callers com ordem de bloqueio inconsistente (2026-11-10)

- `public.usar_furia_barbaro_srd` bloqueia personagem e ficha antes da campanha; `public.end_combat` bloqueia efeitos de Fúria antes de obter lock da campanha. Ambos divergem do protocolo campaign-first e podem formar espera circular com operações de combate.
- Os helpers internos `priv.srd_end_barbarian_rage` e `_token` bloqueiam o efeito primeiro; são seguros apenas quando o caller já mantém lock da campanha. O catálogo indica que não são diretamente executáveis por authenticated.
- Os caminhos NPC via `usar_furia_barbaro_npc_srd`, descanso longo, expiração de condições, mudança de estado e trigger de rodada obtêm campaign lock antes de chamar os helpers; não generalizar a falha a todos os caminhos.
- CI no commit `1959849`: JS ficha/lobby, JS mesa e fixtures PostgreSQL passaram; inicialização do stack descartável para replay de migrations falhou antes do replay começar.
- Correção requerida: campanha primeiro e revalidação de autorização/estado/turno, depois personagem/ficha/efeito/recurso; testes de concorrência reais/isolados antes de considerar resolvido. Nenhuma execução mutável remota.


### Condições de combate: descanso de jogador e resistência a magia (2026-11-10)

- `descanso_longo_personagem_srd` altera condições de fadiga/exaustão e recursos após bloquear personagem/ficha, mas lê campanha sem lock. Pode competir com início de combate e não participa da serialização por campanha.
- `srd_resolve_pending_spell_save` bloqueia pedido de resistência antes da campanha e, no ramo de quebra de condição, atualiza diretamente a condição sem campaign lock. A cadeia de aplicação de efeitos ainda exige revisão transitiva para ordenar campanha antes de pedido/condição.
- `srd_resolve_dying_round` confirma ordem personagem → ficha → campanha → condição, incluindo rodada consultada somente depois de segurar os locks anteriores. Refatorar para campaign-first e revalidar turno/rodada após lock.
- Inventário de writers deve incluir descansos, resistências, estabilização e efeitos derivados, não só rotas GM de administração. Nenhuma execução mutável remota.


### Magias pendentes: ordem pedido → campanha (2026-11-10)

- `priv.srd_apply_pending_spell_resolution` bloqueia o pedido de magia e depois a campanha; as RPCs públicas de resistência a magia/resistência de salvamento também bloqueiam o pedido primeiro e podem delegar a esse helper.
- `srd_resolve_pending_spell_save` também encerra condição diretamente sem lock da campanha no ramo de quebra de condição. Isso altera a fonte consultada pela elegibilidade AOO.
- Divergência do protocolo campaign-first confirmada por leitura estática; ainda não foi demonstrado ciclo de deadlock real para um mesmo pedido, portanto registrar como risco/ordem inconsistente, não como deadlock ocorrido.
- Refatorar para campaign lock → revalidar pedido → lock do pedido → aplicar consequência, mantendo resolução idempotente. Nenhuma mutação remota executada.
