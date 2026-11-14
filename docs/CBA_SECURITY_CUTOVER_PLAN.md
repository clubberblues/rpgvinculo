# CBA — corte de exposição do estado da mesa

Atualizado em 2026-11-12. **Status: em implementação; não aplicar em produção.**

## Contrato alvo

- O cliente não lê `campaigns.cba_data` nem `campaigns.combat_data` diretamente.
- O cliente não recebe UPDATE de `campaigns` via Postgres Changes/Realtime.
- Um endpoint server-side autentica o membro e retorna um snapshot por papel.
- GM/proprietário recebe a cena e o estado de combate completos.
- Jogador recebe mapa publicado, tokens explicitamente visíveis e seu próprio token; recebe somente a projeção pública da iniciativa. Reações pendentes, estado interno da economia de ações e dados de atores ocultos ficam no servidor.
- Escritas de cena e ações de combate permanecem RPCs transacionais; seus retornos também precisam ser projetados antes que o cliente receba a resposta.
- Fog of war/reveal por área está fora do escopo. O mapa de fundo é compartilhado; o Mestre controla apenas a visibilidade de cada token. Não criar campos de fog/reveals.

## Primitive criada nesta branch

Migration candidata `20261112140000_add_role_filtered_tabletop_snapshot.sql` cria:
- `priv.cba_visible_tabletop_snapshot(bigint)`: valida sessão, membership e papel; projeta cena e combate para jogador; entrega completo ao GM.
- `public.obter_snapshot_seguro_mesa(bigint)`: wrapper invoker para a mesa.
- Fixture `tests/sql/role_filtered_tabletop_snapshot_fixture.sql` verifica owner/GM, jogador, tokens ocultos/visíveis, estado de combate privado e iniciativa filtrada.
- Workflow PostgreSQL executa o fixture.

**Importante:** esse endpoint é uma primitive de transição, ainda não é usado por `mesa.html`. Não fecha a exposição enquanto existirem leitores diretos ou RPCs antigos que retornem JSONB completo.

## Leitores diretos remanescentes em `mesa.html`

A varredura atual encontrou 11 callsites que leem `campaigns` com `*`, `cba_data` ou `combat_data`:
- inicialização: linha 1345 (`select('*')`);
- refresh/recuperação: 1732, 1866, 2319, 2332, 2704, 2823, 2952, 5429, 6083 e 6113.
Também existe subscription Realtime em `campaigns` na linha 6860, que substitui o objeto local por `p.new` e consome ambos os JSONB privados (linhas 6860–6868).

Não restringir privilégios de coluna nem remover a publicação antes de substituir todos esses caminhos. O cliente ainda tem muitas mutações cujos RPCs retornam `cba_data` ou `combat_data`; elas precisam ser inventariadas e migradas para respostas seguras por papel ou respostas sem estado privado.

## Ordem de corte obrigatória

1. Migrar a inicialização e os 10 refreshes para snapshot/RPCs específicos; manter apenas colunas públicas necessárias em consultas diretas.
2. Remover a subscription de `campaigns`; introduzir Broadcast privado ou refresh por RPC com throttling. Não transmitir row payload.
3. Inventariar cada RPC que retorna `cba_data`/`combat_data` e cada RPC que aceita token id, campanha, movimento, dano, cura, iniciativa ou edição de cena. Verificar autenticação, ownership, GM/player, autorização do token e conteúdo do retorno.
4. Para cada RPC de mutação, devolver somente confirmação e valores necessários; o cliente atualiza a cena via snapshot filtrado. Nunca devolver JSONB integral a jogador.
5. Manter a visibilidade por token sob autoridade do Mestre; mapa de fundo sempre compartilhado. Não persistir fog/reveals.
6. Criar fixture de integração com GM, jogador A, jogador B e externo; testar consultas, RPCs, Realtime, token oculto, movimento, combate, reconexão e mudança de membership.
7. Só então revogar SELECT direto de `cba_data`/`combat_data` para `authenticated`, remover a tabela `campaigns` da publicação Realtime e validar todos os fluxos.
8. Repetir auditoria estática para provar zero referências cliente a colunas privadas e zero payloads integrais de RPC em contexto player.

## Evidência e limitações atuais

Consulta read-only ao Supabase em 2026-11-12 confirmou:
- `authenticated` tem SELECT de tabela e de ambas as colunas privadas `campaigns.cba_data` e `campaigns.combat_data`.
- `campaigns` e a tabela legada `tokens` estão na publicação `supabase_realtime`.
- As definições instaladas de dezenas de RPCs leem e retornam uma ou ambas as colunas. A revisão por endpoint não está concluída.
- Não foi feita mudança remota. A migration nova não foi aplicada.
- O teste SQL da primitive não equivale a teste autenticado real do PostgREST/Realtime, nem a teste de fluxo no navegador.

## Verificação versionada

`supabase/verification/verify_role_filtered_tabletop_snapshot.sql` confirma presença/ACL do novo RPC e reporta explicitamente se SELECT direto das colunas privadas e publicação Realtime ainda permanecem ativos. É um verificador de transição; não declara corte concluído nem revoga acesso.

## Implementação incremental do cutover — 2026-11-12

- `mesa.html` agora inicializa e atualiza o estado por `obter_snapshot_seguro_mesa`; os 10 refreshes que antes liam `cba_data/combat_data` diretamente foram substituídos. A leitura inicial `select('*')` também foi removida.
- Os três leitores de `campaigns.cba_data` em `ficha.html` (descanso, Fúria e equipamento de NPC vinculado) agora usam o snapshot filtrado.
- A subscription `postgres_changes` da linha de `campaigns` foi removida de `mesa.html`. A mesa agora escuta o canal privado `campaign:{id}` e, ao receber o evento, busca um snapshot filtrado; não recebe row payload.
- Migration candidata `20261112150000_broadcast_campaign_refresh.sql` instala trigger que envia somente `{campaign_id}` via `realtime.send(..., private=true)` e policy de leitura em `realtime.messages` para owner/membros. A fixture `tests/sql/campaign_refresh_broadcast_fixture.sql` verifica payload mínimo e negação para externo.
- A auditoria estática atual encontrou zero consultas diretas a `campaigns.* / cba_data / combat_data` e zero subscriptions da tabela `campaigns` nos três arquivos `mesa.html`, `ficha.html` e `lobby.html`.
- A publicação `supabase_realtime` ainda contém `campaigns`; não removê-la até revisar todos os outros consumidores/arquivos e confirmar a configuração de private channels no Dashboard (Allow public access desativado).
- **Bloqueio remanescente:** vários RPCs de mutação ainda retornam `cba_data` ou `combat_data` diretamente. A resposta HTTP desses RPCs pode expor tokens ocultos mesmo que o cliente depois faça refresh seguro. É necessário revisar e corrigir cada endpoint antes de revogar SELECT de coluna.
- O helper de snapshot e a migration de Broadcast ainda são candidatas não aplicadas. Nenhum corte de ACL foi feito.

## Primeira família de respostas RPC filtradas

- Migration candidata `20261112160000_filter_player_damage_rpc_results.sql` move as duas sobrecargas de `aplicar_dano_token_ataque_srd_v2` para `priv` e mantém o mesmo nome/signatura pública como wrapper SECURITY DEFINER.
- O wrapper chama a implementação original e substitui recursivamente qualquer chave `cba_data`/`combat_data` no JSONB de retorno pela projeção do snapshot seguro. Assim preserva os campos mecânicos do resultado (dano, PV, CA, total de ataque) sem devolver tokens ocultos ou estado interno do combate ao jogador.
- O acesso EXECUTE direto às implementações movidas para `priv` é revogado para PUBLIC/anon/authenticated; somente o wrapper público mantém EXECUTE para authenticated.
- Fixture `tests/sql/filter_player_damage_rpc_results_fixture.sql` simula ambas as sobrecargas, testa payload player filtrado, payload owner completo e impossibilidade de chamar a implementação interna. A aprovação CI desta fixture ainda precisa ser confirmada.
- Essa é apenas a primeira família. Outros RPCs com retornos de CBA/combate ainda precisam da mesma análise e tratamento; não revogar SELECT de colunas até todos os retornos estarem cobertos.


## Segunda etapa — resultados de mutações (2026-11-12)

- Migration candidata `20261112160000_filter_player_damage_rpc_results.sql` cria filtro recursivo para campos `cba_data` e `combat_data` em JSONB, inclusive em objetos e arrays aninhados. Move oito implementações RPC para `priv` e recria wrappers públicos que preservam os campos mecânicos, substituindo os JSONB privados pelo snapshot autorizado. O filtro falha fechado: se não consegue obter snapshot autorizado, remove os campos privados do resultado.
- A família cobre as duas sobrecargas de ataque v2, ajuste de PV de token, equipamento de token, perfil de combate, dano mágico multialvo, habilidade de classe e finalização de movimento AOO. Implementações internas perdem EXECUTE de PUBLIC/anon/authenticated; wrappers públicos ficam acessíveis somente a authenticated.
- Fixture `tests/sql/filter_player_damage_rpc_results_fixture.sql` e verificador `supabase/verification/verify_cba_rpc_response_isolation.sql` testam projeção de jogador, retorno completo ao proprietário, preservação de campos de negócio, payload aninhado e impossibilidade de bypass direto.
- A consulta read-only do catálogo remoto encontrou 65 overloads em 62 nomes públicos de funções JSONB que referenciam `cba_data` ou `combat_data`; 52 overloads têm EXECUTE para authenticated e nenhum desses overloads concede EXECUTE a anon. Isso é um inventário de candidatos, não prova de que todos vazem: há endpoints exclusivamente GM e wrappers internos que exigem classificação individual. A família de oito assinaturas acima é apenas o primeiro corte.
- O primeiro CI da fixture encontrou erro de dollar quoting; corrigido no commit `1c0a002c`. A execução seguinte revelou incompatibilidade de tipo no argumento `smallint` do teste de magia; corrigida no commit `7087d188`. O resultado do CI para esse último commit ainda precisa ser confirmado. Não registrar a fixture como aprovada antes da conclusão.
- A migration continua candidata e não aplicada ao Supabase ativo. A exposição direta por coluna permanece liberada até todas as respostas RPC player-accessible serem filtradas e verificadas.


## Endurecimento da projeção por allowlist — 2026-11-12

- Revisão do contrato do frontend confirmou que a mesa consome da cena versão, fundo/caminho compartilhado, escala visual, grade e tokens; não existe nem será usado campo `fogEnabled`. Da iniciativa consome apenas id, nome, tipo, indicador de monstro, valor, d20 e modificador de Destreza.
- A migration candidata `20261112140000` foi endurecida: o snapshot de jogador agora reconstrói a cena por allowlist, projeta cada token visível/pertencente para os campos usados pela mesa, projeta cada ator visível na iniciativa e limita o objeto campaign a id/nome/owner/state/active. Metadados desconhecidos de GM não são mais propagados por cópia do JSONB integral.
- A fixture agora inclui segredos sintéticos no nível da campanha, cena, token visível e ator de iniciativa; jogador deve receber nenhum deles, enquanto o proprietário GM continua recebendo os dados completos de cena/combate.
- Essa alteração reduz vazamento acidental por campos JSONB futuros, mas não substitui o corte de SELECT direto nem a filtragem das demais respostas RPC. Resultado CI da nova fixture/migration ainda pendente.


## Projeção de controles de turno e RPC de avanço — 2026-11-12

- O snapshot de jogador preserva agora somente `action_economy.by_character` do próprio personagem, e apenas quando a rodada do estado de ações coincide com a rodada atual. `movement_usage` é retornado somente quando pertence a uma ficha do usuário; `expected_character_ids` é filtrado para as fichas do próprio usuário. Isso mantém o painel de ações e a prévia de movimento sem revelar os estados dos demais.
- A migration candidata `20261112160000` também envolve `avancar_turno(bigint)`: a implementação original retorna o objeto `combat_data` diretamente no topo do JSONB, não dentro de uma chave `combat_data`. O wrapper envolve o retorno para executar o filtro recursivo e depois devolve a projeção no formato original, preservando o contrato do frontend.
- A fixture modela o retorno top-level real, testa que jogador não recebe reações/atores ocultos e que o GM mantém o estado completo. O CI dessa extensão ainda está pendente; não considerar aprovada antes do resultado.


## Verificação de ACL direta e ordem final do cutover — 2026-11-13

Consulta read-only ao Supabase ativo confirmou uma exposição que o endpoint de snapshot, sozinho, não fecha:

- Policy `campaigns_member_read`: qualquer membro com `public.my_role(id) IS NOT NULL` pode ler a linha da campanha.
- ACL efetivo de `public.campaigns`: `authenticated=r`; `anon` não tem SELECT.
- `has_column_privilege('authenticated', 'public.campaigns', 'cba_data', 'SELECT')` e o equivalente para `combat_data` retornam **true**.
- Portanto, qualquer jogador autenticado membro pode consultar diretamente o JSONB integral da campanha e obter dados que o snapshot filtrado pretende ocultar. O mesmo risco alcança a publicação `supabase_realtime`, que ainda contém `campaigns`.

A integração de frontend na branch avançou:
- `mesa.html` inicializa/atualiza por `obter_snapshot_seguro_mesa`, usa Broadcast privado `campaign:{id}` e não assina `campaigns` por `postgres_changes`.
- `ficha.html` usa o snapshot para as consultas de tokens NPC vinculados.
- `lobby.html` lê diretamente apenas `id,owner_id` para identificar o proprietário e atualiza `capa_url`; os metadados da lista vêm da RPC `lobby_list_v2`.
- Isso elimina os leitores diretos dos clientes ativos, mas não impede um membro de chamar a Data API diretamente nem fecha os retornos RPC ainda não classificados.

A consulta remota anterior encontrou 65 overloads em 62 nomes públicos que referenciam `cba_data` ou `combat_data`; 52 têm EXECUTE para `authenticated`. A migration candidata `20261112160000` cobre uma primeira família de oito implementações, não todos os retornos. As demais assinaturas precisam ser classificadas como GM-only, player-accessible com resposta segura, ou internas sem execução direta.

**Ordem obrigatória preservada:**
1. Classificar todos os overloads executáveis por authenticated e localizar quais retornam estado privado em contexto de jogador.
2. Filtrar ou substituir cada resposta RPC player-accessible, mantendo os campos mecânicos necessários ao cliente.
3. Validar com fixtures de GM, jogador dono, outro jogador e usuário externo.
4. Somente então revogar SELECT de tabela/colunas privadas em `campaigns` e retirar `campaigns` da publicação `supabase_realtime`.
5. Revalidar todas as consultas, RPCs, Broadcast, Storage e reconexão.

Dois leitores GM-only ainda são SECURITY INVOKER e leem `campaigns.cba_data`: a sobrecarga de seis argumentos de `srd_consultar_modificadores_manobra_srd` e `srd_listar_ataques_naturais_oportunidade_srd`. Ambos verificam `auth.uid()` e `my_role(...)=GM`; antes de retirar privilégios de coluna, deverão executar sob SECURITY DEFINER com search_path fixo ou migrar para helper interno autorizado.

Uma migration preliminar de revogação de SELECT foi preparada durante a revisão, mas foi retirada de `supabase/migrations` e seu fixture removido, pois seria prematuro enquanto as respostas RPC restantes não estiverem cobertas. Nenhuma alteração foi aplicada ao Supabase remoto. **A exposição está confirmada e permanece aberta; não declarar o corte de CBA concluído.**


## Cobertura adicional de ações e magias — 2026-11-13

A migration candidata `20261112160000_filter_player_damage_rpc_results.sql` foi ampliada para envolver também quatro RPCs player-facing que retornam estado privado:

- `consumir_acao_turno_srd(bigint,text,text)`
- `conjurar_magia_com_acao_srd_manual(text,text,smallint,text,integer[])`
- `conjurar_magia_com_acao_srd_multialvo_v3(text,text,smallint,text[],integer[])`
- `usar_imposicao_maos_mortos_vivos_srd(text,text,integer,integer)`

As implementações originais são movidas para `priv`; wrappers públicos preservam os campos mecânicos e substituem `cba_data/combat_data` pela projeção autorizada. A fixture `filter_player_damage_rpc_results_fixture.sql` agora simula essas quatro respostas, testa filtragem para jogador, estado completo para GM e impossibilidade de chamar diretamente as implementações privadas.

**Importante:** isso amplia a primeira família, mas não conclui a revisão das 65 assinaturas JSONB/52 executáveis por authenticated. As demais precisam ser classificadas individualmente. Os endpoints exclusivamente GM podem preservar retorno completo se a autorização estiver comprovada; ações de jogador devem filtrar o estado.

### Lacuna funcional separada — controle do Mestre sobre personagem de jogador

A decisão de produto permite ao Mestre assumir temporariamente qualquer personagem durante combate, sem transferir a propriedade da ficha. A revisão dos corpos atuais encontrou endpoints que ainda exigem `characters.user_id = auth.uid()`, inclusive a economia de ações e alguns fluxos de conjuração/recursos. A filtragem de retorno não concede essa permissão.

Antes de declarar o controle do Mestre concluído, classificar e ajustar os endpoints de ação usados em combate para aceitar o Mestre da campanha como controlador operacional, mantendo as verificações de campanha, turno, requisitos e recursos. Não remover as validações do jogador proprietário.


## Matriz de chamadas frontend e funções invoker — 2026-11-14

Consulta direta ao catálogo do Supabase e busca textual dos callsites .rpc nos sete arquivos cliente versionados (mesa.html, ficha.html, lobby.html, lobby_atualizado.html, dice.html, index.html e vinculo-ui.js):

- 53 overloads públicos executáveis por authenticated referenciam cba_data ou combat_data.
- 52 retornam JSONB e um retorna numeric; 51 são SECURITY DEFINER e duas são SECURITY INVOKER.
- 50 nomes distintos: 45 possuem chamada .rpc direta em pelo menos um dos arquivos cliente inspecionados. Os cinco nomes sem callsite direto nesses arquivos são aplicar_dano_token_gm_personagem_srd, srd_aplicar_dano_ataque_oportunidade_monstro_srd, srd_aplicar_dano_ataque_oportunidade_srd, srd_detectar_saida_alcance_ameacado_srd e srd_resolver_teste_resistencia_token_srd. Ausência de chamada direta não autoriza revogação: podem ser dependências SQL de outras funções ou chamadas dinâmicas.
- As duas funções SECURITY INVOKER são srd_consultar_modificadores_manobra_srd(bigint,text,text,text,boolean,boolean) e srd_listar_ataques_naturais_oportunidade_srd(bigint,text). Ambas referenciam estado privado da campanha e contêm checagem auth.uid()/my_role/GM. Como invoker, dependem do SELECT de campaigns.cba_data enquanto esse privilégio existir; precisam de execução interna autorizada/SECURITY DEFINER com search_path fixo antes do corte de SELECT.
- A busca de wrappers no catálogo público não encontrou chamada ao snapshot seguro nos 53 overloads; a migration candidata de wrappers não está aplicada ao banco remoto. Isso não classifica automaticamente todos os 52 JSONB como vazamento: é necessário inspecionar o retorno real e a autoridade de cada endpoint.

Próxima entrega de auditoria: matriz individual das 53 assinaturas com chamada frontend ou dependência SQL, classe de ator permitida (owner/GM/player), ownership/token guard, forma de retorno e estratégia de filtragem. Manter sem alterações as ACLs remotas até a matriz e os testes com quatro identidades estarem completos.

## CI pós-registro documental — 2026-11-14

No commit 17b24b8093e9a4b1900553dc52582ac8faeb78bc, os workflows de validação JavaScript da aplicação (run 577), JavaScript da mesa (run 833), validação estática (run 529) e fixtures PostgreSQL (run 850) concluíram success. O replay integral (run 413) voltou a falhar pelo mesmo bloqueio pré-ledger: a primeira migration tenta usar public.campaigns antes de existir bootstrap. Nenhum teste autenticado via PostgREST/Realtime foi executado.
