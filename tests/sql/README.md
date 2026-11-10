# PostgreSQL fixture tests

Executados em um serviço PostgreSQL descartável no GitHub Actions. Não se conectam ao Supabase, não leem nem alteram campanhas reais e não são migrations.

## Footprint D&D 3.5

- O fixture contém cópias capturadas das definições de public.srd35_normalizar_parametro_talento e priv.srd_token_grid_footprint (snapshot de 2026-11-09).
- Asserções cobrem categorias de tamanho e footprint, aliases em português, fallback de raça do jogador vinculado, busca por key, tamanho desconhecido e rejeição de token duplicado.
- O teste valida o helper canônico isoladamente. Não demonstra que movimento, ataque, spawn e AOO usam o helper; a auditoria ainda encontrou lógica geométrica divergente nesses caminhos.

## Concorrência e locks

O script lock_cycle_test.sh modela oito padrões sintéticos de inversão e um controle positivo:

1. campanha → instância de arma versus instância de arma → campanha (início PC de Ataque Total versus resolução).
2. campanha → personagem versus personagem → campanha.
3. campanha → pending AOO versus pending AOO → campanha.
4. pending AOO → ataque versus ataque → pending AOO.
5. campanha → personagem → ficha → recurso de classe versus personagem → ficha → recurso → campanha (condicional à colisão da mesma linha de personagem/recurso).
6. campanha → personagem → ficha versus personagem → ficha → campanha (conjuração multialvo e estabilização).
7. campanha → ataque versus ataque → pending → campanha (mudança de estado do combate versus resolução AOO).
8. sequência NPC → campanha versus campanha → tentativa → sequência NPC.

O controle positivo faz duas sessões adquirirem campanha → efeito e verifica que ambas concluem sem deadlock.

## Concorrência de autorização

O mesmo script também contém dois cenários de transferência de Mestre, em tabelas descartáveis:
- **Reprodução TOCTOU:** duas sessões validam owner_id sem lock; a primeira transfere a propriedade, a segunda continua após esperar na linha de membro e transfere novamente. O fixture verifica que a segunda operação consegue alterar owner_id e deixa dois membros com role GM.
- **Controle corrigido:** as duas sessões bloqueiam primeiro a linha da campanha; após a primeira transferência, a segunda relê owner_id sob lock e é rejeitada por perda de autoridade. O fixture verifica um único GM e o proprietário esperado.

Esses cenários reproduzem a forma transacional observada em gm_transfer/priv.need_owner, não executam a RPC instalada nem provam que houve exploração em produção.

**Limites importantes:** cada cenário constrói manualmente os prefixos de lock/checagem em tabelas descartáveis. Nenhum executa RPC de produção, trigger real, autorização Supabase, semântica de combate ou dados de campanha. Um teste verde prova o comportamento PostgreSQL do cenário sintético e que o harness funciona; não prova que uma chamada real já tenha produzido deadlock ou que gm_transfer tenha sido explorado. O cenário de recurso de classe é condicional: a consulta read-only mais recente encontrou três fichas de origem de NPC, mas nenhuma vinculada à mesma campanha do token. O cenário de inventário/equipamento foi removido do harness ativo por não haver writer atual que alcance o ramo negativo do trigger.

## Validação CI

- Workflow PostgreSQL #72 [42730159992](https://github.com/clubberblues/rpgvinculo/actions/runs/42730159992) concluiu com sucesso no commit documental anterior; executou footprint e oito padrões de inversão + controle positivo.
- Workflow #100 [42731471362](https://github.com/clubberblues/rpgvinculo/actions/runs/42731471362) concluiu success no commit `dd38946efd5cd9ef58ec8ef33b492227793141e7`. Logs confirmam footprint helper, oito inversões sintéticas, um controle positivo, reprodução TOCTOU com dois GM após duas transferências stale e controle campaign-first em que a segunda transferência é rejeitada e permanece um único GM. O commit posterior só alterou documentação; os arquivos de teste permanecem iguais.
- O harness permanece uma validação sintética, não um teste de integração das RPCs Supabase.


### Papel GM em mutações de inventário

O harness inclui dois cenários sintéticos adicionais para endpoints que validam `members.role='GM'` antes de bloquear a campanha:
- Reprodução: a sessão A valida GM, a sessão B revoga o papel, e A continua a alteração de inventário usando a validação obsoleta.
- Controle campaign-first: a sessão que revoga o papel bloqueia campanha primeiro; a sessão stale espera, relê o papel após obter o lock e é rejeitada.

Modela a janela observada nos corpos instalados de `entregar_item_srd` (OID 20556), `entregar_item_token_srd` (OID 21668) e `equipar_item_token_srd` (OID 21670). Não executa essas RPCs, nem comprova exploração em produção.


Nota de execução (2026-11-10): os primeiros runs #116 e #117 falharam no harness novo, não nos oito testes de deadlock existentes. A sincronização inicial usava advisory-lock polling que podia monopolizar a barreira e expirar; foi substituída por eventos de fixture confirmados em commits/autocommit e por duas conexões independentes. O controle campaign-first usa o lock real da linha de campanha e espera a transação de revogação. A nova versão está sendo reexecutada; considerar o cenário pendente até CI verde.
