# PostgreSQL fixture tests

Executados em um serviço PostgreSQL descartável no GitHub Actions. Não se conectam ao Supabase, não leem nem alteram campanhas reais e não são migrations.

## Footprint D&D 3.5

- O fixture contém cópias capturadas das definições de `public.srd35_normalizar_parametro_talento` e `priv.srd_token_grid_footprint` (snapshot de 2026-11-09).
- Asserções cobrem categorias de tamanho e footprint, aliases em português, fallback de raça do jogador vinculado, busca por key, tamanho desconhecido e rejeição de token duplicado.
- O teste valida o helper canônico isoladamente. Não demonstra que movimento, ataque, spawn e AOO usam o helper; a auditoria ainda encontrou lógica geométrica divergente nesses caminhos.

## Concorrência e locks

O script `lock_cycle_test.sh` modela **oito padrões sintéticos de inversão** e um controle positivo:

1. campanha → instância de arma versus instância de arma → campanha (início PC de Ataque Total versus resolução).
2. campanha → personagem versus personagem → campanha.
3. campanha → pending AOO versus pending AOO → campanha.
4. pending AOO → ataque versus ataque → pending AOO.
5. campanha → personagem → ficha → recurso de classe versus personagem → ficha → recurso → campanha (condicional à colisão da mesma linha de personagem/recurso).
6. campanha → personagem → ficha versus personagem → ficha → campanha (conjuração multialvo e estabilização).
7. campanha → ataque versus ataque → pending → campanha (mudança de estado do combate versus resolução AOO).
8. sequência NPC → campanha versus campanha → tentativa → sequência NPC.

O controle positivo faz duas sessões adquirirem campanha → efeito e verifica que ambas concluem sem deadlock.

**Limites importantes:** cada cenário constrói manualmente os prefixos de lock em tabelas descartáveis. Nenhum executa RPC de produção, trigger real, autorização, semântica de combate ou dados de campanha. Um teste verde prova que o PostgreSQL detecta o ciclo sintético e que o harness funciona; não prova que uma chamada real já tenha produzido deadlock. O cenário de recurso de classe é condicional: a consulta read-only mais recente encontrou três fichas de origem de NPC, mas nenhuma vinculada à mesma campanha do token. O cenário de inventário/equipamento foi removido do harness ativo por não haver writer atual que alcance o ramo negativo do trigger.

## Validação CI

- Workflow [42727408284](https://github.com/clubberblues/rpgvinculo/actions/runs/42727408284), run #69, concluiu com sucesso no commit `54b7db97c6a0724e8e3cd6e2b53737859e6c6a10`.
- O job `postgres-fixtures` completou setup, inicialização dos containers, checkout, instalação do cliente PostgreSQL, execução dos fixtures isolados, teardown e finalização.
- O commit documental posterior `bf34920bfc9cefd9d9ff8abb91dcc2fc0a7488f2` não alterou nenhum fixture SQL; apenas `docs/LOCK_ORDER_PROTOCOL_DRAFT.md` foi modificado.
- O harness permanece uma validação sintética, não um teste de integração das RPCs Supabase.

