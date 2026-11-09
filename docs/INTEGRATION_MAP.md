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

## Integração de dados e RPC

A varredura identificou 100 nomes distintos de RPC chamados por mesa.html, ficha.html e lobby.html. Uma consulta ao catálogo PostgreSQL encontrou os 100 nomes no schema public.

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
