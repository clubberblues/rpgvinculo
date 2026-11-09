# Vínculo RPG — Mapa de integração

> Inventário estático inicial do HEAD observado em 2026-11-08, cruzado com o catálogo do Supabase. Não é teste de execução nem inventário exaustivo de cada coluna.

## Fluxo geral

**index/autenticação → lobby/campanhas → ficha/personagem → mesa/sessão → dados/rolagens → RPCs/estado persistido → Realtime/log para os clientes.**

O fluxo é distribuído entre páginas independentes. Cada página inicializa seu próprio cliente Supabase; não foi identificado um módulo compartilhado único de cliente/API entre os arquivos principais nesta varredura.

## Entradas e responsabilidades por arquivo

| Arquivo | Responsabilidade observada | Integrações observadas |
|---|---|---|
| index.html | Entrada/autenticação e encaminhamento ao lobby | Inicializa cliente Supabase e consulta sessão; carrega vinculo-ui.js |
| lobby.html | Listagem, criação/entrada em campanha e escolha/vínculo de ficha | 10 RPCs distintas e 10 referências .from(); carrega vinculo-ui.js |
| lobby_atualizado.html | Arquivo legado com nome de espelho, mas conteúdo divergente do lobby atual | 4 RPCs distintas; lê também os catálogos legados spells/talents; não inclui vinculo-ui.js |
| ficha.html | Visualização e edição de personagem, progressão, equipamento, grimório e recursos | 12 RPCs distintas e 31 referências .from(); carrega vinculo-ui.js e comunica-se com o iframe de dados |
| mesa.html | Orquestração da sessão: cena, tokens, turnos, combate, inventário, magias, condições, chat e log | 87 RPCs distintas, 27 referências .from(), 9 chamadas channel()/on(); carrega vinculo-ui.js |
| dice.html | Interface visual de dados e retorno dos resultados ao documento pai | Sem chamadas .rpc() ou .from() detectadas; usa postMessage e carrega vinculo-ui.js |
| dex.html | Não encontrado no caminho consultado na branch main | Confirmar se é arquivo local/antigo ou se foi descontinuado |

## Utilitário compartilhado
O arquivo vinculo-ui.js (3.944 caracteres no snapshot) é um utilitário de interface para diálogos/entrada/confirmação, não um cliente de dados ou módulo de regras. index.html, lobby.html, ficha.html, mesa.html e dice.html o carregam; lobby_atualizado.html não o carrega.

## Divergência do lobby legado
A comparação estática encontrou lobby.html com 10 RPCs distintas e lobby_atualizado.html com 4; seis RPCs do lobby atual não aparecem no arquivo legado. O arquivo legado consulta spells/talents, enquanto o lobby atual consulta vinculo_spells/vinculo_talents e recursos SRD. Os arquivos também diferem em cerca de 30 mil caracteres e na inclusão de vinculo-ui.js. Portanto, lobby_atualizado.html **não é um espelho sincronizado** do lobby atual no HEAD observado. Não publicar nem editar como se fosse equivalente; primeiro decidir se deve ser removido, arquivado ou atualizado.

## Inventário de contratos RPC
O [RPC_INVENTORY.md](RPC_INVENTORY.md) registra as 100 chamadas literais e 108 assinaturas públicas correspondentes, com flags de acesso e marcadores estáticos de guarda. A próxima etapa é cruzar argumentos/tipos do JavaScript com sobrecargas e validar os fluxos críticos.

## Integração de dados e RPC

A varredura identificou 103 RPCs resolvidas (100 nomes literais e 3 destinos dinâmicos) chamadas por mesa.html, ficha.html e lobby.html. Uma consulta ao catálogo PostgreSQL encontrou os 100 nomes no schema public.

**O que isso confirma:** os nomes chamados pelo frontend têm função correspondente no schema public.

**O que isso não confirma:** assinatura/argumentos corretos, grants, autorização por papel, comportamento da função, atomicidade ou sucesso ponta a ponta. Funções sobrecarregadas precisam ser conferidas pela assinatura exata usada em cada chamada.

### Grupos funcionais visíveis na mesa

- Campanha e cena: estado da campanha, salvar cena e dados de mídia.
- Tokens e personagens: inclusão, movimento, PV, equipamento e fichas vinculadas.
- Iniciativa e turno: abertura, registro de rolagens, ordenação e avanço.
- Combate: ataques, ataques iterativos, crítico, dano, manobras e reações/AOO.
- Magias e recursos: conjuração, salvamentos, condições, fúria e habilidades de classe.
- Apoio ao mestre: bestiário, NPCs, XP, descanso e inventário.

### Grupos funcionais visíveis na ficha

- Criação/finalização de personagem.
- Avanço de nível.
- Grimório e escolhas de domínio.
- CA e deslocamento.
- Fúria de Bárbaro e descanso.
- Leitura/escrita de catálogos e dados de personagem.

### Grupos funcionais visíveis no lobby

- Listagem de campanhas.
- Criação e entrada em campanha.
- Entrada por código.
- Associação de ficha própria à mesa.
- Atualização de configurações e exclusão protegida.

## Dados e estado
O [DATA_MODEL.md](DATA_MODEL.md) registra as relações verificadas, fontes canônicas e estruturas de compatibilidade.

O snapshot do banco observado possui 76 relações em public e 7 em priv. Os domínios identificáveis incluem:

- Campanhas e sessão: campaigns, members, campaign_log, scenes, tokens, combat_state e roll_requests/roll_log.
- Personagens: characters, srd_character_sheets e vinculo_character_sheets.
- Regras D&D 3.5: tabelas srd_* de classes, raças, perícias, talentos, equipamentos, magias, efeitos, progressões, condições, domínios e monstros.
- Regras Vínculo: tabelas vinculo_* de classes, habilidades, talentos, magias, itens, fichas e inventário.
- Estado interno: tabelas priv.* para operações pendentes, sequências e controles internos.

A separação srd_* / vinculo_* é uma fronteira de domínio. Não misturar regras ou catálogos entre elas.

## Realtime e sincronização

A mesa contém subscriptions Realtime para atualizações de chat/log e estado de personagens, membros, equipamentos, condições e efeitos. A contagem estática identificou 9 chamadas channel()/on(); o filtro e o escopo de cada subscription devem ser revisados no diagnóstico de segurança e sincronização.

O estado de jogo deve ser validado e persistido no servidor antes de ser tratado como definitivo pelo cliente. Realtime distribui mudanças; não substitui autorização nem a fonte canônica.

## Integração do dado 3D

- mesa.html e ficha.html incorporam dice.html em iframe.
- A comunicação usa postMessage, requestId de sessão e validação da origem/janela remetente.
- mesa.html prepara expressões de dados e recebe resultados individuais do iframe.
- Na varredura de mesa.html, os 38 callsites que passam os dois parâmetros booleanos usam true,true; não foi encontrado callsite explícito true,false. Nesse contrato, true,true envia prepareRoll, que configura a expressão e aguarda o clique do usuário.
- dice.html só envia rollResult depois da interação de rolagem. O modo prepareRoll apresenta “ROLAR AGORA”; não executa triggerNativeThrow automaticamente.
- A iniciativa coletiva do Mestre distribui resultados físicos individuais aos tokens selecionados, conforme a regra de produto registrada.

Essa evidência estática é consistente com a decisão de não gerar automaticamente rolagens dos jogadores. Mudanças futuras devem preservar esse contrato e incluir teste de regressão.

## Pontos de atenção arquitetural

1. Arquivos HTML grandes com scripts inline concentram muitas responsabilidades e chamadas diretas ao Supabase.
2. A inicialização do cliente Supabase é repetida entre páginas.
3. A mesa concentra 87 RPCs e subscriptions; precisa de mapa de dependências mais detalhado antes de refatoração.
4. A correspondência nominal das 100 RPCs ainda não verifica argumentos, overloads ou permissões.
5. Subscriptions Realtime devem ser verificadas quanto a filtros de campanha, payloads e atualização de estado.
6. A página de dados deve continuar sem autoridade de persistência; a mesa/ficha e o backend controlam o contexto da ação.
7. Não criar uma camada de API ou mover scripts até mapear consumidores, testes e contratos atuais.

## Próximas verificações

- Conferir assinaturas e argumentos das RPCs por fluxo crítico.
- Relacionar cada RPC às tabelas que lê/escreve e aos papéis autorizados.
- Mapear as 9 subscriptions Realtime com evento, tabela, filtro e handler.
- Identificar todas as fontes canônicas de CA, PV, ataque, dano, iniciativa e estado de turno.
- Comparar lobby.html e lobby_atualizado.html para confirmar o papel do espelho.
- Confirmar se dex.html é obsoleto ou apenas local.
- Completar o grafo de dependências antes de propor extração de módulos.


## Relacionamentos do banco — fotografia de 2026-11-08

Consulta ao catálogo PostgreSQL identificou:
- public: 100 foreign keys, 76 primary keys, 20 constraints UNIQUE e 133 CHECK constraints.
- priv: 10 foreign keys, 7 primary keys, 4 UNIQUE e 28 CHECK constraints.
- Triggers de usuário: 11 em public e 3 em priv.

### Grafo principal observado
- campaigns é o agregado central da sessão: members, characters, tokens, scenes, campaign_log, combat_state, roll_requests/roll_log, layers, media e condições/efeitos de campanha se relacionam com campanha.
- characters é a entidade-base de personagem; srd_character_sheets e vinculo_character_sheets mantêm os dados específicos de cada ruleset.
- O domínio SRD relaciona trilhas e níveis a srd_classes; características de nível dependem da progressão; grimório, magias conhecidas/preparadas e slots relacionam personagens, classes e srd_spells.
- Catálogos SRD referenciam srd_rule_sources; campanhas podem habilitar srd_rule_modules.
- O domínio Vínculo mantém suas próprias classes, itens, magias, talentos e fichas.

### Ponto estrutural para revisão futura
- srd_character_equipment.character_id e srd_character_weapon_instances.character_id são text e não possuem FK para characters.id (bigint). No snapshot, 42/42 linhas de equipamento e 6/6 instâncias de arma continham IDs numéricos que correspondem a characters existentes; nenhum órfão foi observado.
- Isso é uma oportunidade/risco de integridade referencial, não uma falha de dados comprovada. Não alterar tipos ou adicionar FKs antes de auditar todos os consumidores, RPCs, políticas, triggers e compatibilidade. Planejar migração futura somente com backfill e validação.
- srd_cba_token_equipment e srd_cba_token_weapon_instances usam token_id text, sem FK direta para tokens.id bigint; revisar o contrato entre token persistido e identificador CBA antes de qualquer normalização.

Nenhuma linha de jogo foi alterada durante esta consulta.


## Persistência da cena e tokens: modelo atual e compatibilidade

A inspeção dos RPCs confirmou dois caminhos coexistentes:

1. **CBA atual:** o estado de cena/token é persistido em campaigns.cba_data (JSONB). RPCs CBA como adicionar_token_cba_completo e alterar_pv_token_cba operam nesse documento; mover_token_gm_cba_srd e mover_token_player_cba delegam a implementações privadas do fluxo CBA.
2. **Modelo relacional legado/compatível:** public.tokens e public.monster_instances guardam tokens relacionais. RPCs antigas como add_monster_to_scene, move_token, attack, apply_damage, apply_heal, start_combat, combat_set_turn e end_turn usam public.tokens.

As rotinas priv.srd_apply_campaign_condition e priv.srd_apply_campaign_effect aceitam a identidade de alvo quando ela existe no array campaigns.cba_data->tokens **ou** em public.tokens. Isso mostra compatibilidade explícita entre os dois modelos, não prova que ambos sejam usados pela interface atual.

A mesa atual não chama diretamente os RPCs legados listados acima na varredura de 87 RPCs; usa os RPCs CBA. A função create_campaign ainda insere um registro em scenes, mas a interface atual não mostrou leitura direta dessa tabela na varredura. Antes de qualquer remoção/normalização, mapear consumidores indiretos, funções internas, triggers, histórico e dados existentes.

**Decisão arquitetural provisória:** manter os dois modelos intactos até concluir o grafo de dependências e uma decisão formal de migração. Não migrar tokens JSONB para a tabela relacional nem apagar tabelas/RPCs apenas por parecerem legadas.


### Estado dos objetos relacionais de cena/token
No snapshot consultado: campaigns=3, scenes=3, tokens=0 e monster_instances=0. create_campaign insere uma linha em scenes por campanha. A mesa atual lê/grava campanhas.cba_data e não consulta scenes/tokens diretamente na varredura; os RPCs relacionais antigos continuam no banco, mas as tabelas tokens e monster_instances estão vazias neste snapshot.

A tabela scenes contém parâmetros de mídia/grid (imagem, vídeo, áudio, GIF, tile, offsets, escala e limites). Seu destino deve ser decidido após confirmar se esses campos foram migrados para campaigns.cba_data, media ou outro fluxo. Não apagar a tabela nem o INSERT de create_campaign nesta etapa.


### Subscriptions Realtime detalhadas
| Canal lógico | Tabela | Evento | Filtro Realtime |
|---|---|---|---|
| chat | campaign_log | INSERT | campaign_id=eq.{MESA_ID} |
| chars | characters | * | campaign_id=eq.{MESA_ID} |
| srd | srd_character_sheets | * | Sem filtro |
| gear | srd_character_equipment | * | Sem filtro |
| token-gear | srd_cba_token_equipment | * | campaign_id=eq.{MESA_ID} |
| members | members | * | campaign_id=eq.{MESA_ID} |
| conditions | srd_campaign_conditions | * | campaign_id=eq.{MESA_ID} |
| effects | srd_campaign_effects | * | campaign_id=eq.{MESA_ID} |
| camp | campaigns | UPDATE | id=eq.{MESA_ID} |

As subscriptions sem filtro estão em tabelas sem coluna campaign_id. As políticas RLS atuais restringem srd_character_sheets a proprietário/membros da campanha e srd_character_equipment a proprietário/Mestre; o handler da mesa ainda verifica se o personagem afetado pertence ao conjunto carregado localmente. Realtime não deve ser tratado como canal privado por si só: a garantia de visibilidade vem das políticas e da autorização do banco.

A fotografia de políticas também mostrou:
- campaign_log: GM lê a campanha; jogadores/observadores leem apenas eventos PUBLIC.
- characters: proprietário ou membro da campanha pode ler.
- members/campaigns: leitura limitada ao próprio usuário ou membros da campanha.
- srd_cba_token_equipment e srd_campaign_conditions/effects: leitura limitada a membros da campanha.
- srd_character_equipment: leitura para proprietário ou Mestre, não para todos os jogadores.
- srd_character_sheets: leitura para proprietário ou membros da campanha.

Não foi feita alteração de política nem de subscription.


## CA de personagem vinculado a token NPC — verificação somente de leitura

- O frontend mesa.html usa a sobrecarga de 4 argumentos de public.srd_calcular_ca_personagem_srd para NPCs vinculados à ficha; a sobrecarga encaminha ao helper priv.srd_calcular_ca_alvo_campanha_srd quando o Mestre e o vínculo do token são confirmados.
- O helper calcula armadura/escudo a partir de srd_character_equipment, Destreza efetiva, condições, tamanho, efeitos e características de classe. A rotina de atualização da mesa também usa essa sobrecarga.
- Teste de leitura no ambiente atual: personagem 681 (Thorgar), token NPC vinculado na campanha 131. Resultado da função: final_ac=10, armor_bonus=0, dexterity_modifier=0, effect_modifier=0.
- A linha Armadura de Couro existe no inventário com bônus de CA +2 e máximo de Destreza +6, mas equipado=false. Portanto, CA 10 é coerente com o estado persistido atual; CA 12 seria o resultado esperado depois de equipar a armadura.
- A consulta simulou apenas o claim de identidade para executar a função em modo somente leitura. Nenhum registro foi alterado.
- **Reclassificação:** a pendência histórica “CA 10 quando deveria ser 12” não comprova defeito no resolver. O código atual possui o caminho de CA vinculada; a validação visual final deve ser feita depois que o item estiver equipado por uma ação normal de jogo/fixture descartável, sem alterar os dados atuais.


## Contrato de CA entre ficha e token

O frontend e o backend possuem três caminhos de CA:
1. **Personagem jogador:** mesa.html chama public.srd_calcular_ca_personagem_srd(campaign_id, character_id, attack_context). O resolvedor usa ficha SRD, equipamento marcado como equipado, Destreza, condições, tamanho e efeitos do personagem.
2. **NPC vinculado a ficha:** mesa.html chama a sobrecarga de quatro argumentos (inclui attacker_is_giant). Quando o Mestre e o vínculo são válidos, ela delega a priv.srd_calcular_ca_alvo_campanha_srd. O helper usa equipamento da ficha vinculada, Destreza/efeitos do token CBA, condições associadas à ficha/token, tamanho, características de classe e bônus racial contra gigantes. Mais de um token vinculado à mesma ficha causa erro de ambiguidade.
3. **NPC sem ficha vinculada:** a mesa usa os dados de CA presentes em monsterStats do próprio token, aplicando os modificadores de contexto suportados no cliente/fluxo.

Os resolvedores de ataque iterativo de NPC e ataque de oportunidade também chamam o helper de CA vinculada. Portanto, o cálculo não é apenas decorativo: participa da resolução de combate.

**Fonte canônica:** para personagem jogador e NPC vinculado, a ficha SRD e seu equipamento equipado são a base; o token fornece efeitos temporários/contextuais quando o fluxo os prevê. O inventário de token é um domínio separado e não deve substituir silenciosamente o equipamento da ficha vinculada.

**Limite de validação:** a função foi inspecionada estaticamente e executada uma vez em leitura para o registro Thorgar (ID 681), cujo item Armadura de Couro está não equipado; retornou CA 10. Esse registro é distinto de Thunga Mestre (ID 682), que pertence à campanha 131 e tem Armadura de Couro equipada. Não transferir o resultado de um personagem ao outro. A validação funcional de Thunga permanece bloqueada até a confirmação do alvo e deve ocorrer em fixture/campanha descartável.


## Estado de combate, rolagens e log: caminho atual versus legado

Snapshot de contagens no banco: campaign_log=70, combat_state=0, roll_requests=0 e roll_log=0.

### Caminho atual observado
- A mesa atual usa campaigns.combat_data e campaigns.cba_data para estado de combate/cena.
- Iniciativa atual passa por iniciar_iniciativa_com_dados e/ou iniciar_iniciativa_com_pedido, que escrevem estado em campaigns e registram eventos em campaign_log.
- Dados são preparados no iframe Dice; a mesa recebe o resultado por postMessage e os fluxos de ação enviam os valores às RPCs específicas (ataque, salvamento, iniciativa, dano etc.). O iframe não persiste diretamente no banco.
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
