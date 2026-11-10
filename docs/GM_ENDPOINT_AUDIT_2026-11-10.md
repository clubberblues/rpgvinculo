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


## CI #170 — cobertura sintética aprovada

GitHub Actions [run #170](https://github.com/clubberblues/rpgvinculo/actions/runs/42739191233), SHA `3c7144a5894e161d90dfa82762c040a97955e652`, concluiu SUCCESS. Os logs confirmam stale GM grant após revogação e rejeição campaign-first, stale condition/effect removal e rejeição campaign-first, além da cobertura de ficha GM. As exceções de autorização dos controles negativos eram esperadas. Testes sintéticos não executam RPCs remotas nem verificam o caminho de concessão de item.


## Achado adicional — exclusão de ficha ativa no lobby

`public.excluir_ficha_propria(text)` (OID 20219) tem `SECURITY DEFINER` e `EXECUTE authenticated`; `lobby.html` chama essa RPC diretamente quando o usuário confirma a exclusão da ficha. A leitura do corpo instalado e do catálogo atual confirmou dois nomes de relação obsoletos no caminho executado:

- `public.character_notes` não existe; a tabela atual é `public.vinculo_character_notes`.
- `public.inventory` não existe; a tabela atual é `public.vinculo_inventory`.

A primeira instrução `DELETE FROM public.character_notes` falha antes da exclusão da linha `characters`; a transação inteira reverte, logo a ação de exclusão do lobby não conclui no schema atual. O `DELETE FROM public.inventory` também é inválido, embora não seja alcançado depois da primeira falha.

A limpeza atual já tem mecanismos de schema: `vinculo_inventory` e `vinculo_character_notes` possuem FK para `characters` com `ON DELETE CASCADE`; o trigger BEFORE DELETE remove `srd_character_sheets` e o AFTER DELETE remove `srd_character_equipment`, cujo trigger remove instâncias de armas. Preservar e testar essas cadeias antes de simplificar o corpo; não presumir que todo dado SRD seja removido apenas pelo cascade sem conferir todas as relações.

**Concorrência:** a função bloqueia `characters FOR UPDATE` primeiro e, se `campaign_id` não for NULL, bloqueia `campaigns FOR UPDATE` depois. O call site ativo no lobby torna essa inversão character → campaign alcançável contra writers campaign-first → character do combate. Correção candidata: leitura MVCC para obter campaign_id → campaign FOR UPDATE → revalidar propriedade/vínculo → character FOR UPDATE → atualizar ordem de iniciativa e excluir. Para ficha sem campanha, preservar um caminho sem lock de campanha e definir como serializar associação/join concorrente.

Outras rotinas legadas com referências às relações ausentes: `calc_ca` (18881), `calc_desl` (18882), `calc_sheet` (18883), `sell_price` (19287), além de `gm_grant` (18752). `save_sheet` (18889) também referencia `public.items/inventory`, mas no snapshot seu EXECUTE está restrito a `service_role`. `calc_sheet`, `calc_ca`, `calc_desl` e `sell_price` têm EXECUTE authenticated; buscas em todas as seis páginas HTML do repositório não encontraram call sites para essas funções. `gm_reopen_sheet/gm_set_bonus` chamam `calc_sheet`, mas também não têm call site literal nas páginas consultadas.

O fixture existente campaign → character versus character → campaign cobre o padrão de lock; o endpoint de exclusão foi associado explicitamente a esse cenário. Nenhuma chamada de exclusão foi executada no banco remoto e nenhum dado foi alterado.


### Efeito indireto em `gm_reopen_sheet` e `gm_set_bonus`

As duas RPCs atualizam `character_sheets` e depois retornam `public.calc_sheet(p_char)`. O corpo instalado de `calc_sheet` (OID 18883) consulta `public.inventory` e `public.items`, ambos ausentes no catálogo. Para fichas com registro existente, essa chamada final falha e a transação reverte também a alteração de reabertura/bônus. Assim, além do TOCTOU GM já testado, essas duas rotas têm incompatibilidade funcional indireta. Sem call site literal nas páginas HTML consultadas; classificar como superfície RPC authenticated até confirmar consumidor.


**Qualificação da inversão:** o prefixo character → campaign está confirmado no corpo e o padrão contrário existe em operações campaign-scoped; um deadlock real exige que ambas bloqueiem a mesma linha de personagem e a mesma campanha. O snapshot consultado anteriormente encontrou três tokens NPC com sourceCharacterId existente, mas todos os personagens-fonte tinham `campaign_id IS NULL`; para esses três casos, a exclusão não adquire lock de campanha e não forma esse ciclo específico. Classificar como inversão estrutural/condicional, não como deadlock de produção reproduzido.


## Auditoria cruzada do schema legado e dependências — 2026-11-10

### Estado observado no banco remoto

O catálogo atual não contém `public.items`, `public.inventory`, `public.character_notes` nem `public.character_sheets`. As relações atuais equivalentes/relacionadas são `vinculo_items`, `vinculo_inventory`, `vinculo_character_notes` e `vinculo_character_sheets`; a ficha SRD é `srd_character_sheets`. A constatação veio de `pg_class` e das constraints do banco conectado, não apenas de busca no repositório.

A tabela `supabase_migrations.schema_migrations` não tem uma linha com nome `srd35_character_sheets_cleanup_migration`; o arquivo homônimo no root é um script SQL manual, sem timestamp, e seu conteúdo é apenas diagnóstico/remoção de triggers que referenciam o antigo `public.character_sheets`, mais listagem de RPCs ainda contaminadas. Ele não recria nem substitui essas RPCs. A origem exata da remoção/renomeação de relações antigas não está demonstrada pelo histórico de migrations reconciliado. Tratar como divergência de schema/proveniência pendente, não atribuir a uma migration específica.

### RPCs instaladas que permanecem incompatíveis

- `excluir_ficha_propria` (20219): chamada confirmada no botão do lobby. Antes de apagar `characters`, executa `DELETE public.character_notes` e `DELETE public.inventory`; ambas as relações não existem. A primeira instrução aborta a transação, impedindo a exclusão. A função também bloqueia personagem antes da campanha.
- `gm_reopen_sheet` (18892) e `gm_set_bonus` (18893): atualizam `public.character_sheets`, que não existe. A falha acontece no UPDATE antes de `calc_sheet`; não é apenas um erro de retorno.
- `calc_sheet` (18883): declara `s public.character_sheets` e lê `public.inventory`/ `public.items`; não pode calcular ficha no schema atual.
- `calc_ca` (18881), `calc_desl` (18882) e `sell_price` (19287): consultam `public.items`, inexistente. Têm EXECUTE authenticated no snapshot, mas não foram encontrados call sites nas seis páginas HTML atuais.
- `gm_grant` (18752): os ramos de ouro/XP atualizam `characters`; o ramo de item consulta `items` e grava em `inventory`, relações inexistentes. Não foi encontrado call site literal no frontend atual.
- `save_sheet` (18889): também referencia `public.character_sheets`, `public.items` e `public.inventory`, mas seu EXECUTE está restrito a `service_role` no snapshot; não classificar como endpoint authenticated disponível.

### Dependências de exclusão de personagem

O grafo de FK/triggers confirma que a exclusão de `characters` já possui limpeza em cascata:
- `character_spells`, `character_talents`, `character_abilities`, `character_conditions`, `vinculo_inventory`, `vinculo_character_notes`, `vinculo_character_sheets`, `srd_character_sheets`, tokens e diversas tabelas SRD têm FK `ON DELETE CASCADE`.
- Trigger BEFORE DELETE em `characters` remove `srd_character_sheets`; trigger AFTER DELETE remove `srd_character_equipment`.
- Trigger AFTER DELETE de `srd_character_equipment` remove as instâncias correspondentes em `srd_character_weapon_instances`.
- `srd_npc_attack_sequences.actor_character_id` tem FK `ON DELETE RESTRICT`, que pode bloquear a exclusão se houver sequência NPC ainda referenciando o personagem. Snapshot atual: zero linhas na tabela, então não bloqueia os dados observados.

Portanto, não substituir cegamente os DELETEs inválidos por nomes com prefixo. A correção deve decidir quais deletes manuais são redundantes por cascade, preservar os triggers SRD, e tratar a referência RESTRICT de sequência NPC de modo explícito (cancelar/recusar com mensagem segura, sem apagar estado ativo inadvertidamente).

### Ordem transacional candidata para exclusão

Para personagem vinculado a campanha: leitura MVCC para localizar `campaign_id` → lock `campaigns FOR UPDATE` → revalidar `user_id=auth.uid()` e que o `campaign_id` do personagem continua igual → lock `characters FOR UPDATE` → ajustar `combat_data`/ordem de iniciativa → excluir personagem e deixar cascades/triggers aplicarem a limpeza. Se a ficha não estiver vinculada, manter caminho sem campanha, mas revalidar associação após bloquear personagem e definir interação com corrida de join/seat. O contrato precisa ser compatível com `sentar_personagem_na_mesa` e demais mudanças de campaign_id.

### Cobertura e limites

O fixture de lock-cycle já testa o padrão character → campaign versus campaign → character; agora está associado ao endpoint ativo. Nenhum teste de integração executou `excluir_ficha_propria` no banco remoto. O estado do schema foi consultado read-only. Correções devem ser criadas como migrations novas somente após reconciliação das 681 migrations locais versus 966 linhas remotas e revisão do SQL manual fora do ledger.



## Refinamento do inventário de RPCs legadas e cópia para token

### Varredura de referências: distinção entre relações e falsos positivos

A varredura foi refinada para exigir contexto SQL de FROM/JOIN/UPDATE/INSERT/DELETE, evitando contar palavras como `"items"` em JSON ou comentários como referências a relações. Foram encontrados 17 corpos de função com referências efetivas às relações antigas:
- Oito com EXECUTE authenticated: `calc_ca`, `calc_desl`, `calc_sheet`, `excluir_ficha_propria`, `gm_grant`, `gm_reopen_sheet`, `gm_set_bonus`, `sell_price`.
- Nove com EXECUTE restrito a service_role (incluindo helpers/rotinas antigas): `priv.new_sheet`, `answer_roll`, `confirm_sheet`, `learn_abilities_for_level`, `learn_spell`, `long_rest`, `roll_death_save`, `save_sheet`, `short_rest`.

A rotina `priv.new_sheet` não está ligada a nenhum trigger no snapshot. `save_sheet` também tem referências antigas, mas não é callable por authenticated no ACL atual. `finalizar_equipamento_inicial_srd` e `clonar_equipamento_ficha_para_token` foram falsos positivos da busca ampla: usam `srd_equipment` e tabelas SRD atuais; a palavra items aparece em nomes de variáveis/JSON ou comentários, não em FROM/UPDATE de uma tabela legada.

### Cópia de equipamento para token NPC — fluxo ativo

`mesa.html` chama `public.clonar_equipamento_ficha_para_token` após criar token NPC vinculado a uma ficha do Mestre. O endpoint (OID 26515) verifica papel GM em `members` antes de consultar a cena e inserir `srd_cba_token_equipment`/ `srd_cba_token_weapon_instances`, sem bloquear `campaigns` nem revalidar o papel depois de um lock. A função não usa as relações legadas ausentes; o problema aqui é autorização obsoleta e sincronização concorrente da cena/equipamento. Como a criação do token e a cópia são duas RPCs separadas, o token pode já estar criado quando a segunda operação falhar (o frontend já mostra aviso nesse caso).

Correção candidata: localizar e bloquear campanha primeiro → revalidar GM, token NPC, sourceCharacterId e propriedade da ficha → bloquear/validar ficha de origem → copiar equipamento e instâncias. Não misturar essa correção com a substituição de tabelas legadas.

### Impacto e prioridade

1. `excluir_ficha_propria`: endpoint ativo no lobby e falha garantida na primeira relação antiga.
2. `gm_reopen_sheet`/`gm_set_bonus`: authenticated, mas sem call site literal nas páginas atuais; UPDATE em `character_sheets` inexistente.
3. `gm_grant`: ouro/XP independem do branch antigo; concessão de item falha na consulta a `items`/inserção em `inventory`.
4. `calc_sheet`, `calc_ca`, `calc_desl`, `sell_price`: authenticated, mas sem call site literal nas páginas atuais; dependências antigas.
5. Nove rotinas service_role-only: revisar se ainda fazem parte de qualquer integração de serviço antes de revogar/substituir; não tratá-las como endpoints de jogador/Mestre.

Nenhuma dessas funções foi invocada remotamente. O inventário e os ACLs foram consultados read-only.



## Regra de remediação: não reativar o modelo Vínculo legado

A inspeção das colunas confirmou que `vinculo_character_sheets`, `vinculo_items` e `vinculo_inventory` preservam o modelo antigo de ficha/equipamento. Embora `vinculo_character_sheets` tenha colunas semelhantes às antigas `character_sheets`, isso não a torna a ficha correta do VTT D&D 3.5. O modelo atual D&D 3.5 é `srd_character_sheets`, `srd_equipment`, `srd_character_equipment` e `srd_character_weapon_instances`.

Portanto:
- Não corrigir `calc_sheet`, `calc_ca`, `calc_desl`, `sell_price`, `save_sheet`, `confirm_sheet`, `gm_reopen_sheet` ou `gm_set_bonus` apenas trocando `items/inventory/character_sheets` por `vinculo_*`. Isso ressuscitaria o motor de regras legado e contrariaria a direção D&D 3.5.
- Para endpoints sem call site atual e restritos ao fluxo antigo, avaliar revogação de EXECUTE para authenticated/public e manter só se houver consumidor legado explicitamente suportado.
- Se reabrir ficha ou editar bônus ainda for requisito do VTT D&D 3.5, criar RPCs próprias sobre `srd_character_sheets` com regras D&D e autorização/locks campaign-first.
- `excluir_ficha_propria` é diferente: permanece chamada no lobby e deve ser corrigida para excluir o personagem com segurança, usando cascades/triggers atuais em vez de voltar a operar no inventário legado.
- `gm_grant` não tem call site atual identificado; não reescrever para o inventário D&D automaticamente. Se o Mestre precisar conceder ouro/XP/itens na mesa D&D, desenhar RPC específica sobre `characters` + `srd_character_equipment` e `srd_equipment`, com logs, validação e campaign-first.

Essa distinção evita que a correção de schema reintroduza o sistema Vínculo antigo no motor D&D 3.5.



## Estado real do fallback legado no frontend

A revisão das seis páginas HTML encontrou um fallback legado ainda presente em `ficha.html`:
- A rota ativa do lobby cria personagens com `mode=criar&ruleset=dnd35`, que entra em `carregarNovaFichaSRD35`.
- Ao abrir personagem existente, `ficha.html` primeiro procura `srd_character_sheets`; se encontrar, usa o fluxo SRD atual.
- Se não houver ficha SRD, o fallback consulta `vinculo_character_sheets`, mas também tenta ler `inventory` e `character_notes` por nomes ausentes. O formulário de criação legado ainda pode inserir `characters` e `vinculo_character_sheets` se a rota for aberta sem o parâmetro `ruleset=dnd35`.
- As funções de inventário legado ainda executam writes diretos em `inventory`, e anotações em `character_notes`; ambos os endpoints/tabelas não existem no schema atual. Não foi encontrado uso de `vinculo_inventory` ou `vinculo_items` nessa página.

Snapshot read-only de dados: 5 personagens no total; 5 têm `srd_character_sheets`; 0 estão sem ficha SRD e 0 estão vinculados a campanha sem ficha SRD. Portanto, o fallback quebrado não está sendo usado pelos personagens existentes observados, mas continua como caminho de código acessível por URL antiga/legada.

Não remover o fallback nem revogar tabelas/ACLs enquanto não houver decisão explícita sobre compatibilidade e eventual migração de dados. Para o escopo D&D 3.5, manter a rota principal do lobby no caminho SRD e planejar desativação controlada do fallback legado, sem reativar o modelo antigo.



### Incompatibilidade estrutural entre fichas legadas e SRD

Além dos nomes, os modelos não são intercambiáveis por estrutura. `vinculo_character_sheets` contém `classe`, `cultura`, `armadura`, `escudo`, `bonus_ca`, `bonus_rm`, `ready`, `preserve_pv`, `pv_atual` e `pm_atual`. Já `srd_character_sheets` contém `classe_id`, `raca_id`, `nivel`, `atributos`, `pericias`, `talentos`, `magias_preparadas`, `idiomas_conhecidos`, `identidade`, `pv_atual` e dados SRD; não possui os campos legados `ready/preserve_pv/bonus_ca/bonus_rm`. Portanto, nem mesmo trocar `public.character_sheets` por `vinculo_character_sheets` corrigiria o fluxo para D&D 3.5. Os endpoints legados de reabertura e bônus exigiriam uma nova especificação de regras D&D e RPC própria, não um rename.


## Confirmação do fluxo principal de criação D&D 3.5

O botão do lobby encaminha para `ficha.html?mode=criar&ruleset=dnd35&raca=...&classe=...`. Nesse modo, `ficha.html` carrega os catálogos SRD e a função `salvarFichaSRD35` chama `public.finalizar_criacao_personagem_srd` (OID 25213), não o formulário antigo de Vínculo.

A RPC wrapper é SECURITY INVOKER e chama, na mesma transação:
1. `criar_personagem_srd_completo` com identidade/atributos/perícias/talentos;
2. `salvar_idiomas_personagem_srd`;
3. `salvar_talentos_bonus_classe_inicial_srd`;
4. `salvar_dominios_personagem_srd` quando aplicável;
5. `salvar_grimorio_srd` quando aplicável;
6. `finalizar_equipamento_inicial_srd`.

As rotinas internas fazem a criação/validação sobre `characters`, `srd_character_sheets`, catálogos SRD e `srd_character_equipment`; a função de equipamento inicial usa `srd_equipment`. Não confundir com a função antiga de mesmo tema `save_sheet` ou com `finalizar_equipamento_inicial_srd` isolada. O wrapper atual é o caminho principal do lobby e sua atomicidade é importante: qualquer falha em idiomas, talentos, domínios, grimório ou equipamento reverte a criação inteira.

Esse caminho atual não usa `vinculo_character_sheets`, `vinculo_inventory` ou `vinculo_items`. A existência de fallback antigo em `ficha.html` não significa que ele seja o fluxo primário.



## Criação D&D 3.5 — RPCs auxiliares expostas fora do agregador

### Exposição confirmada

O catálogo remoto contém duas sobrecargas SECURITY DEFINER de `public.criar_personagem_srd_completo`, ambas com EXECUTE authenticated:
- OID 20270, seis argumentos (`nome, raça, classe, atributos, perícias, talentos`). Vem do script root `srd35_skills_feats_migration.sql`, fora do diretório timestamped de migrations; esse arquivo concede EXECUTE authenticated explicitamente. Não recebe identidade, idiomas, domínios, grimório, talento bônus de classe nem equipamento inicial. Cria personagem/ficha, salva perícias/talentos e registra classe/nível.
- OID 24809, sete argumentos (inclui `p_identidade`). Vem da migration timestamped `20261103200319_dwarf_character_identity_creation_flow`, que também concede EXECUTE authenticated. Valida identidade/raça/classe e cria personagem/ficha, perícias/talentos e trilha de classe; não executa as etapas posteriores do agregador.

O único chamador interno encontrado da sobrecarga de sete argumentos é `finalizar_criacao_personagem_srd` (OID 25213), que também chama idiomas, talentos bônus, domínios, grimório e equipamento. A busca nas páginas HTML encontrou apenas a chamada do frontend para o agregador, não para as sobrecargas auxiliares. A sobrecarga de seis argumentos não tem chamador interno encontrado no catálogo nem chamada no frontend atual.

### Por que é um risco de integridade do fluxo

Ambas as funções auxiliares são públicas e diretamente executáveis por authenticated, então um cliente pode contornar o agregador e deixar a ficha criada sem uma ou mais etapas obrigatórias. A sobrecarga de seis argumentos ainda ignora identidade/idade/tendência e as escolhas complementares; a de sete argumentos ignora as etapas posteriores do agregador. O caminho principal do lobby está correto, mas a superfície RPC permite uma criação parcial fora dele.

O agregador foi criado em `20261104042217_srd35_atomic_character_creation` como SECURITY DEFINER e alterado para SECURITY INVOKER em `20261104042251_srd35_atomic_character_creation_invoker`. Como a sobrecarga de sete argumentos continua authenticated, a alteração para INVOKER preservou a permissão de chamá-la diretamente. Não foi identificada justificativa de uso direto no frontend atual.

### Verificação dos dados atuais

Snapshot read-only:
- 5 fichas SRD; todas com identidade não vazia.
- 5 com talentos; nenhuma sem talentos.
- 5 com equipamento inicial concluído.
- Nenhuma com identidade vazia ou classe/raça ausente.
- Idiomas conhecidos não estão no valor padrão vazio.

Não há evidência no conjunto atual de fichas incompletas geradas por essas rotas alternativas. Isso não elimina a exposição para chamadas futuras.

### Correção candidata (não aplicada)

1. Manter `finalizar_criacao_personagem_srd` como único endpoint público de criação completa.
2. Revogar EXECUTE de authenticated/public nas duas sobrecargas auxiliares e manter acesso interno controlado.
3. Como o agregador hoje é SECURITY INVOKER, decidir a forma segura de preservar a chamada interna: torná-lo SECURITY DEFINER com `auth.uid()` obrigatório, search_path fixo e todas as referências schema-qualified, ou mover os helpers para schema não exposto e adequar a execução/ACL do wrapper. Não fazer revoke isolado sem alterar/testar o contrato do wrapper.
4. Testar com dois contextos autenticados: chamada direta aos helpers deve falhar; chamada do agregador deve concluir todas as etapas; falha em qualquer etapa deve reverter toda a criação.
5. Reconciliar o script root não timestamped e as migrations antes de preparar migration de produção.

Nenhuma RPC foi invocada para testar a exposição; nenhuma alteração remota foi feita.

