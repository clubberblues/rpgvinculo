# CBA — corte de exposição do estado da mesa

Atualizado em 2026-11-12. **Status: em implementação; não aplicar em produção.**

## Contrato alvo

- O cliente não lê `campaigns.cba_data` nem `campaigns.combat_data` diretamente.
- O cliente não recebe UPDATE de `campaigns` via Postgres Changes/Realtime.
- Um endpoint server-side autentica o membro e retorna um snapshot por papel.
- GM/proprietário recebe a cena e o estado de combate completos.
- Jogador recebe mapa publicado, tokens explicitamente visíveis e seu próprio token; recebe somente a projeção pública da iniciativa. Reações pendentes, estado interno da economia de ações e dados de atores ocultos ficam no servidor.
- Escritas de cena e ações de combate permanecem RPCs transacionais; seus retornos também precisam ser projetados antes que o cliente receba a resposta.
- Fog of war exige estado de revelação persistente e autorização por jogador/grupo; não existe campo de fog consistente no JSONB atual. Não simular fog apenas escondendo tokens no DOM.

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
5. Persistir fog/reveals com escopo de jogador/grupo e regras de visibilidade server-side. Definir política de revelação, não inferir visibilidade de campos ausentes.
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
