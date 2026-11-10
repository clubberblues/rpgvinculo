# Auditoria de endpoints GM — 2026-11-10

## Escopo e limites

Leitura read-only do catálogo PostgreSQL remoto do projeto Supabase `grrgwxcagvvafdmzsmro`. Nenhuma função, migration, ACL, policy ou dado remoto foi alterado. Os cenários adicionados em `tests/sql` usam somente tabelas descartáveis no CI e não executam RPCs de produção.

As funções abaixo têm `SECURITY DEFINER` e `EXECUTE` para `authenticated` no snapshot consultado. A ausência de call site no frontend/repositório não prova ausência de consumidor externo.

## Achados confirmados

### 1. `public.gm_grant` — autorização GM antes do lock de personagem

OID 18752. Executa `priv.need_gm(cid)` antes de bloquear `characters(id, campaign_id)` com `FOR UPDATE`. Não bloqueia/revalida a campanha depois do check. A revogação concorrente do papel GM pode ocorrer enquanto a chamada prossegue para o lock do personagem; o endpoint pode então conceder ouro/XP/itens com autorização obsoleta.

Correção candidata: leitura MVCC para localizar a campanha/personagem → `campaigns FOR UPDATE` → revalidar papel GM e vínculo do personagem → `characters FOR UPDATE` → inventário/XP/ouro/log. Não mover o lock para dentro de `priv.need_gm` sem revisar todos os callers.

**Defeito funcional adicional:** o corpo instalado consulta `items` e grava em `inventory`, mas no catálogo atual não existem relações `public.items` nem `public.inventory`. Existem `public.vinculo_items` e `public.vinculo_inventory`, com FK de inventário para itens. Portanto, o ramo de concessão de item está estaticamente incompatível com o schema atual e tende a falhar em runtime; os ramos de ouro/XP não dependem dessas duas relações. Não foi localizado call site literal de `gm_grant` no frontend principal/repo. Não foi feita invocação remota para evitar mutação de dados.

O fixture de corrida valida somente a autorização/ordem de locks; não valida nomes de tabelas nem executa a RPC real.

### 2. `gm_reopen_sheet` / `gm_set_bonus`

OID 18892/18893. A ficha é localizada sem lock, a autorização GM é checada por `priv.need_gm`, e a tabela `character_sheets` é alterada sem lock de campanha nem revalidação. Correção candidata: localizar campanha por MVCC → campanha FOR UPDATE → revalidar GM e vínculo → personagem → ficha. Fixture sintético já cobre reprodução e controle campaign-first (CI #164 e #167).

### 3. Aplicação e remoção de condições/efeitos

- `srd_apply_campaign_condition` OID 24805 e `srd_apply_campaign_effect` OID 24896 verificam `my_role(...)=GM` antes de chamar helpers privados. Os helpers bloqueiam a campanha, mas não revalidam o papel depois do lock. A chamada pode esperar pela campanha e aplicar a condição/efeito após o GM ter sido revogado.
- `srd_remove_campaign_condition` OID 24806 e `srd_remove_campaign_effect` OID 24897 verificam GM e atualizam as tabelas-alvo sem bloquear a campanha.

Correção candidata para os quatro: campanha FOR UPDATE → revalidar GM → helper/linha de condição ou efeito. Os helpers privados já bloqueiam a campanha; o lock reentrante na mesma transação é aceitável, mas a checagem definitiva deve ocorrer após o primeiro lock. Não exigir GM para ações de jogador em outros endpoints.

Fixture sintético anterior já cobre aplicação de efeito (CI #161/#164). Novos cenários cobrem remoção de condição/efeito e o controle campaign-first (CI pendente no head atual).

### 4. `media_gc` e Storage

OID 18760. Verifica GM antes de apagar linhas `media` sem linha correspondente em `layers`; não bloqueia campanha nem revalida papel. A FK `layers.media_id → media.id` protege a integridade referencial da camada, mas não resolve a autorização obsoleta. A função retorna os paths para que o navegador do Mestre remova os arquivos do Storage: banco e Storage não são uma transação única.

Correção candidata: campanha FOR UPDATE → revalidar GM → excluir metadados elegíveis e devolver paths; a remoção no Storage deve ser idempotente e reconciliável, sem tratar falha parcial como transação atômica. Não foi encontrado call site literal no frontend/repo, então a exposição é classificada como superfície RPC authenticated, não fluxo UI confirmado. Não foi adicionado teste de exclusão de Storage: a integração real depende do cliente/Storage e requer fixture apropriado.

### 5. Leitura protegida `gm_get_code`

OID 18746. É leitura, não mutação; `priv.need_gm` não bloqueia campanha. Decidir separadamente se a revogação precisa ser linearizável para esse segredo. Se sim, lock campaign-first e revalidação; se não, documentar explicitamente a consistência permitida. Não agrupar automaticamente com mutações.

## Fixtures CI adicionados

- `gm_grant`: reproduz concessão após revogação de GM e controle que espera pelo lock da campanha e rejeita o pedido obsoleto. O cenário representa a sequência de ouro/XP/inventário de forma sintética.
- Remoção de condição/efeito: reproduz mutação após revogação e controle campaign-first.
- Aplicação de efeito já tinha reprodução e controle campaign-first.
- Todos os testes são padrões transacionais sintéticos, não execução das RPCs remotas.

## Próximos passos seguros

1. Classificar `gm_get_code` como política de leitura (consistência estrita ou eventual).
2. Rastrear consumidores externos/antigos de `gm_grant` e `media_gc`; buscas no frontend atual não encontraram chamadas literais.
3. Comparar migrações locais/remotas e localizar a mudança que renomeou `items/inventory` para `vinculo_items/vinculo_inventory`; não corrigir função antes de reconstruir histórico e contrato de dados.
4. Projetar migrations de campaign-first por fatias, com testes de integração autenticados em banco descartável.
5. Manter qualquer alteração remota bloqueada até reconciliação completa das 681 migrations locais versus 966 registros remotos.
