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



### Classificação do risco e preservação do contrato de execução

A exposição identificada é principalmente de integridade do fluxo/regras de criação, não evidência de IDOR: as duas sobrecargas verificam `auth.uid()` e criam o personagem para o próprio usuário. Não foi encontrado call site no frontend atual; a chamada ativa é ao agregador. O problema é que qualquer cliente autenticado pode chamar o helper público e deixar uma ficha parcial sem passar por todas as etapas da transação agregada. Nenhum dos cinco personagens atuais apresenta os sinais agregados de criação incompleta. A recomendação de esconder os helpers deve ser validada com o contrato do wrapper: como o agregador está INVOKER, não revogar EXECUTE sem torná-lo uma fronteira segura (por exemplo, SECURITY DEFINER com autenticação obrigatória, search_path fixo, referências qualificadas e revisão de todos os helpers chamados).


## Dependência de tokens NPC ao excluir ficha — referência JSON sem FK

A leitura completa de `excluir_ficha_propria` confirma que a função:
- bloqueia a linha `characters` primeiro;
- só bloqueia uma campanha se `characters.campaign_id` não for NULL;
- atualiza apenas `campaigns.combat_data` para retirar a ficha da iniciativa;
- não pesquisa nem altera `campaigns.cba_data->tokens[*].sourceCharacterId`.

A auditoria read-only do snapshot encontrou **3 tokens NPC em 2 campanhas** referenciando **2 personagens existentes**; ambos os personagens de origem têm `campaign_id IS NULL`. Assim, a função atual não bloquearia as campanhas 129/131 por meio de `campaign_id` e, após a correção dos nomes de tabelas, poderia excluir a ficha deixando `sourceCharacterId` pendurado no JSON da cena.

Esse campo é consumido por rotinas SRD de NPC (descanso longo vinculado, fúria, ataques iterativos, resistência, sincronização de PV/condições). Sem a ficha de origem, essas rotinas podem falhar com “ficha de origem não encontrada”; o token ainda pode existir visualmente e manter seu snapshot de equipamento, mas perder operações que dependem da ficha.

### Decisão necessária antes de corrigir a exclusão

Não apagar/limpar automaticamente os tokens sem regra de produto. Duas políticas possíveis:
1. **Bloquear exclusão enquanto houver NPCs vinculados**, informando ao jogador/Mestre quais tokens precisam ser desvinculados ou convertidos em NPCs independentes.
2. **Desvincular de forma transacional**, preservando no token todos os atributos, PV, equipamento e capacidades necessários para funcionar sem ficha de origem; isso exige provar que o snapshot contém os dados usados por todas as RPCs SRD.

Qualquer opção deve consultar todas as campanhas cujo JSON de tokens contém o `sourceCharacterId`, obter os campaign locks em ordem ascendente de ID, revalidar os links após os locks e só então bloquear/excluir a personagem. A associação via JSON não possui FK e não pode ser inferida apenas de `characters.campaign_id`.

O dado atual é pequeno e verificável (3 links, 2 fichas-fonte); nenhuma dessas fichas foi excluída ou modificada. O defeito de nomes antigos já impede a exclusão hoje, mas não deve ser “corrigido” sem também tratar esta dependência.



### Efeito da duplicidade de links no painel de ficha

No snapshot, um personagem-fonte está ligado a dois tokens NPC na mesma campanha (campanha 129); outro personagem-fonte está ligado a um token em outra campanha (131). `ficha.html` procura o token vinculado na campanha selecionada e interrompe ações de descanso longo/Fúria quando encontra mais de um, com mensagem de ambiguidade. Portanto, para a ficha-fonte que tem dois tokens, esses controles no painel da ficha não conseguem escolher qual token controlar. As ações abertas diretamente no painel de cada token em `mesa.html` recebem o token_id e continuam sendo o caminho não ambíguo.

A política de exclusão/desvinculação precisa considerar também a multiplicidade: uma ficha pode ser fonte de vários tokens em uma ou várias campanhas. Se a regra permitir vários clones, os controles de ficha precisam permitir escolher o token ou operar em escopo de ficha (com semântica compartilhada claramente definida); não escolher arbitrariamente o primeiro.



### A exclusão é oferecida mesmo para fichas-fonte vinculadas

`lobby.html` lista as fichas do usuário e renderiza o botão `Excluir ficha` para cada uma; a listagem não consulta `sourceCharacterId` nem oculta/desabilita a exclusão quando a ficha é fonte de token NPC. Portanto, as 2 fichas-fonte observadas estão expostas ao botão. Hoje a RPC falha antes de excluir por causa das relações antigas ausentes; quando o defeito de schema for corrigido, a política de vínculo deve ser implementada no backend e a UI deve refletir o bloqueio/desvinculação. Não confiar apenas em esconder o botão.


### Não existe ação explícita de desvincular no tabuleiro atual

A busca no `mesa.html` não encontrou ação explícita que remova/limpe `sourceCharacterId` de um token (nem função chamada “desvincular”). O Mestre pode editar a cena por outros fluxos, mas não há um controle de produto claro para converter o NPC vinculado em independente. Assim, a política “bloquear exclusão até desvincular” exige primeiro construir esse fluxo de desvinculação ou um procedimento de limpeza seguro; não presumir que o usuário já tenha uma ação disponível.


### Remoção individual de token também não está disponível

A varredura do menu/painel de `mesa.html` não encontrou ação de remover/excluir token nem RPC de desvinculação. A única ação de exclusão encontrada é a exclusão definitiva da campanha, cujo aviso diz preservar as fichas e remover a mesa/histórico; isso é amplo demais para servir como procedimento normal de desvincular um NPC. Portanto, bloquear a exclusão da ficha-fonte sem antes construir um fluxo de remoção/desvinculação deixaria o usuário sem solução granular. O plano precisa incluir uma ação de Mestre para remover token NPC (com confirmação e atualização atômica de `cba_data`, iniciativa, efeitos/condições, pending actions e referências auxiliares) ou uma operação de detach/snapshot validada.


### O snapshot do token não é suficiente para desvincular automaticamente

A inspeção read-only das chaves JSON dos três tokens ligados mostrou que o token guarda identificadores, PV, CA/ataque, dados de cena e um `monsterStats` parcial (classe, raça, nível, FOR, DES, ataques e chave de conjuração). Não há no snapshot de `monsterStats` as seis habilidades, talentos completos, progressão, perícias, identidade, todos os recursos ou ficha de magias completa. O tabuleiro também mantém `spellState`, mas isso não prova que todos os dados exigidos pelas rotinas de classe estejam materializados. Como as RPCs SRD consultam a ficha-fonte para várias operações, simplesmente remover `sourceCharacterId` não preservaria a semântica do NPC. Até existir um snapshot SRD completo e validado, a política segura é impedir exclusão da ficha enquanto houver token vinculado e fornecer uma ação explícita para remover o token da cena ou converter com snapshot completo.


## Continuação da auditoria — ciclo de vida de NPC vinculado e exclusão de token

### Ausência de operação individual de remoção

A inspeção integral de `mesa.html` confirmou que o menu contextual do NPC oferece PV, inventário, abertura da ficha SRD, características, publicação no chat, ataque e movimento, mas não oferece remover/excluir token. A busca no catálogo PostgreSQL também não encontrou RPC de remoção/exclusão/limpeza de token NPC. Assim, a remoção individual do NPC não está implementada como fluxo explícito no frontend ou no banco consultado; não confundir com apagar a ficha-fonte nem com excluir a campanha.

### Por que desvincular não é equivalente a remover

`normalizarCBAData` e `serializarEstadoCBA` preservam `sourceCharacterId` no JSON de `campaigns.cba_data`. O token vinculado usa esse ID para consultar ficha, raça, nível, atributos, talentos, CA, ataques, magias, descanso longo, estabilização e recursos. O snapshot `monsterStats` não contém todos esses dados. Portanto, definir `sourceCharacterId = null` sem antes materializar um snapshot SRD completo e compatível degrada silenciosamente o NPC e pode quebrar ações já existentes. A clonagem de equipamento (`clonar_equipamento_ficha_para_token`) é separada e não materializa o restante da ficha.

### Dependências persistentes que a remoção precisa considerar

A inspeção do schema atual encontrou estado relacional associado ao token/campanha além do JSON da cena:
- Equipamento e instâncias de armas: `srd_cba_token_equipment` e `srd_cba_token_weapon_instances`. As PKs incluem `campaign_id, token_id`, mas não há FK para o token dentro de `cba_data`; a exclusão da campanha é que limpa por FK.
- Sequências/ataques NPC: `srd_npc_attack_sequences` e `srd_npc_attack_attempts`; tentativas têm cascade da sequência. A sequência tem FK `actor_character_id → characters(id) ON DELETE RESTRICT`, de modo que excluir a ficha-fonte pode falhar enquanto houver sequência NPC referenciando-a. A exclusão da ficha deve recusar com mensagem clara ou cancelar sequências de forma explícita e transacional, nunca depender de erro genérico da FK.
- Ataques de oportunidade: `priv.srd_aoo_pending_movements`, `priv.srd_aoo_attacks` e `priv.srd_aoo_reaction_ledger` mantêm IDs de tokens/atores em colunas e/ou JSON; ataques dependem do pending e o pending tem FK para campanha, não para o token.
- Magias pendentes: `priv.srd_pending_spell_resolutions` guarda `target_kind/target_id`; o target token é uma referência textual, não uma FK para o token.
- Condições e efeitos: `srd_campaign_conditions` guarda `target_kind/target_id/source_actor_id`; `srd_campaign_effects` guarda `target_kind/target_id/concentration_actor_id`. Essas linhas também dependem da campanha, não da existência do token. A remoção precisa decidir entre cancelar/remover apenas estado do token e manter histórico auditável, ou preservar instâncias como histórico inerte; não pode apagar indiscriminadamente estado de outros alvos.
- A cena ainda pode conter o token em `cba_data.tokens`; a ordem de combate pode manter IDs em `combat_data`/ordem de iniciativa e eventos/histórico podem referenciar o token.

### Contrato candidato para uma futura RPC de remoção

1. Autenticar e localizar a campanha por leitura MVCC; bloquear `campaigns FOR UPDATE` antes de qualquer linha filha; revalidar que o solicitante continua GM após o lock.
2. Relê-la e validar que o token existe, é NPC, e que o ID não aponta para token de jogador. Se a ação for “remover token”, remover a entrada da cena e ajustar ordem/turno de combate na mesma transação.
3. Bloquear/validar sequências de ataque do NPC; encerrar ou cancelar sequência ativa e garantir que as tentativas filhas sejam tratadas por cascade. Nunca deixar `srd_npc_attack_sequences` ativa sem token.
4. Resolver pendências de AOO e magia que apontem para aquele token: cancelar com status terminal e preservar trilha quando suportado; remover dados auxiliares estritamente transitórios apenas após identificar as constraints e consumidores. Não apagar pending de outros tokens na mesma campanha.
5. Remover condições/efeitos cujo alvo é o token; para efeitos em que ele é apenas fonte/concentrador, aplicar a regra de encerramento da concentração e atualizar somente os efeitos correspondentes.
6. Excluir equipamento e instâncias do token, limpar referências em JSON de combate/iniciativa e persistir a cena uma única vez, com validação de versão/estado para evitar sobrescrever alterações concorrentes.
7. Se a intenção for “desvincular e manter no tabuleiro”, primeiro materializar uma ficha NPC autossuficiente e validar equivalência mecânica; só então retirar `sourceCharacterId`. Isso é um fluxo separado de remoção.
8. Para exclusão da ficha-fonte, localizar todas as campanhas que a referenciam por `cba_data.tokens[*].sourceCharacterId`, bloquear essas campanhas em ordem crescente de ID, revalidar as referências e impedir a exclusão enquanto houver token vinculado. Não usar apenas `characters.campaign_id`, pois o snapshot já mostrou personagens-fonte com `campaign_id IS NULL` vinculados a tokens de campanhas.

### Exclusão da ficha — refinamento do diagnóstico

O corpo instalado de `excluir_ficha_propria` ainda executa DELETEs para `public.character_notes` e `public.inventory`, inexistentes. Os nomes atuais `vinculo_character_notes`/`vinculo_inventory` têm FK cascade para `characters`; para o fluxo D&D 3.5, porém, não se deve reativar o modelo Vínculo. A limpeza de ficha SRD e equipamento já está em triggers BEFORE/AFTER DELETE, e as demais dependências com FK cascade devem ser inventariadas antes de retirar instruções redundantes. O FK RESTRICT de `srd_npc_attack_sequences` é uma dependência impeditiva explícita.

A ordem character → campaign da RPC atual continua incompatível com operações campaign-first quando há campanha vinculada. Para personagens sem `campaign_id`, a remoção também deve proteger o vínculo externo via JSON de campanha; a solução precisa bloquear todas as campanhas que apontam para o personagem, não apenas a campanha da coluna `characters.campaign_id`.

### Limites desta etapa

Consultas foram exclusivamente read-only. Nenhum token, ficha, sequência, condição, efeito, inventário, campanha, ACL ou migration foi alterado. Nenhuma RPC de produção foi invocada. A proposta acima é contrato de desenho para fixture e futura migration, não implementação pronta nem autorização para alterar o banco remoto.


### Snapshot relacional atual dos três NPCs vinculados

Nova consulta read-only cruzou cada NPC de `campaigns.cba_data.tokens` com ficha-fonte e estado relacional. Os três tokens observados (dois na campanha 129 apontando para o personagem 678; um na campanha 131 apontando para o personagem 681) continuam com `sourceCharacterId` válido e ambos os personagens-fonte têm `characters.campaign_id IS NULL`. Para esses três tokens, a amostra atual retornou zero linhas de equipamento/instâncias de armas, zero sequências de ataque NPC, zero condições/efeitos como alvo, zero magias pendentes ativas e zero movimentos AOO pendentes. Isso reduz o estado órfão observado agora, mas não remove a necessidade de tratar todas essas dependências na RPC futura: a consulta é apenas um snapshot e novas ações podem criar registros depois.


### Dependências de exclusão — verificação exata do schema

A nova leitura de `pg_constraint` confirmou a matriz de FK de `characters`:
- Cascade: `character_abilities`, `character_conditions`, `character_spells`, `character_talents`, `srd_attack_sequences`, `srd_character_class_levels`, `srd_character_domain_choices`, `srd_character_feature_resources`, `srd_character_known_spells`, `srd_character_prepared_spells`, `srd_character_sheets`, `srd_character_spell_slot_state`, `srd_character_spellbook`, `tokens`, `vinculo_character_notes`, `vinculo_character_sheets` e `vinculo_inventory`.
- Restrict: `srd_npc_attack_sequences.actor_character_id → characters.id`. Essa é a única FK encontrada diretamente impeditiva para excluir a ficha-fonte no conjunto consultado; a sequência NPC precisa ser cancelada/removida antes, ou a exclusão deve falhar com mensagem de vínculo ativo.
- O FK de `tokens.character_id` em cascade não limpa os objetos de token guardados em `campaigns.cba_data`; são estruturas distintas.
- `public.character_spells`, `public.character_talents`, `public.srd_character_sheets`, `public.srd_character_equipment` e `public.tokens` existem. `public.character_notes` e `public.inventory` não existem.

Dois triggers ativos na tabela `characters` já executam limpeza SRD: BEFORE DELETE chama `limpar_ficha_srd_ao_excluir_personagem` e remove `srd_character_sheets`; AFTER DELETE chama `limpar_inventario_srd_ao_excluir_personagem` e remove `srd_character_equipment`. A ficha e equipamento SRD são também alcançados por suas FKs/cascades. Assim, a RPC não precisa repetir limpeza de ficha/equipamento se a cadeia de triggers/constraints for mantida; a redundância pode ser removida na futura refatoração, após testar o comportamento transacional e a ordem de triggers.

A função instalada ainda contém DELETEs explícitos em `public.character_spells` e `public.character_talents` (ambas relações existentes), além dos DELETEs inválidos em `character_notes` e `inventory`. Não foi executado o endpoint para confirmar o ponto exato da falha em runtime; a ausência das duas relações é suficiente para confirmar que a função não pode completar esse corpo no schema atual.

### Primeiro contrato de fixture implementado no repositório

Adicionado `tests/sql/npc_lifecycle_test.sql`, chamado pelo `tests/sql/lock_cycle_test.sh`. O fixture temporário cobre remoção isolada de um NPC, atualização de cena/iniciativa, limpeza de registros associados, cancelamento de pendências, encerramento de efeitos derivados, preservação de outro NPC e guarda de exclusão da ficha-fonte até remover todas as referências JSON. Também modela a FK RESTRICT da sequência NPC.

O fixture é uma especificação executável de invariantes em tabelas temporárias, não uma cópia da RPC real. Não testa autorização, triggers reais, RLS, constraints de produção nem integração de frontend. O teste ainda precisa ser executado pelo CI antes de ser considerado aprovado.


### GM grant e coleta de mídia — endpoint legado e Storage

- `public.gm_grant` (OID 18752) é SECURITY DEFINER e faz `priv.need_gm(cid)` antes de bloquear a linha de `characters`, sem bloquear/revalidar a campanha. A parte de item consulta `public.items` e grava `public.inventory`; ambas as relações não existem no schema atual. Assim, o ramo `p_item IS NOT NULL` é incompatível e falha; os ramos de ouro/XP não dependem dessas duas tabelas. Nenhum callsite `gm_grant` foi encontrado em `mesa.html` ou `lobby.html`, então classificar como endpoint legado/externo a confirmar, não como fluxo ativo da interface D&D.
- `public.media_gc` (OID 18760) também é SECURITY DEFINER: valida GM por `priv.need_gm`, apaga linhas `public.media` sem camada em `public.layers` e retorna paths para que o navegador remova os arquivos no Storage. Nenhum callsite `media_gc` foi localizado em `mesa.html` ou `lobby.html`. O snapshot atual contém zero linhas em `public.media`; portanto não há path atual a reconciliar.
- Storage possui buckets `mesa-media` (privado, limite 50 MiB) e `midia` (público). Em `storage.objects`, `mesa-media` tem políticas authenticated de SELECT/INSERT/UPDATE/DELETE limitadas por pasta GM; `midia` tem leitura pública e escrita/remoção authenticated por funções de escopo. A exclusão de campanha em `mesa.html` lista arquivos nos dois buckets e os remove em lotes de até 1000, fora da transação PostgreSQL que apaga a campanha.
- Risco de consistência: exclusão SQL e remoção Storage são duas operações não atômicas. Se a remoção Storage falhar depois do delete da campanha, arquivos órfãos permanecem; se arquivos forem removidos antes e a transação SQL falhar, referências quebradas podem permanecer. O fluxo atual interrompe e mostra erro no retorno de Storage, mas não há compensação transacional garantida. Correção futura: job/outbox de limpeza idempotente com estado persistente e retry, não confiar em exclusão síncrona como se fosse transação única.
- As RPCs `srd_remove_campaign_condition` (OID 24806) e `srd_remove_campaign_effect` (OID 24897) validam `my_role='GM'` antes do UPDATE e não bloqueiam a campanha. Além da janela de revogação concorrente já registrada, a mutação direta não está serializada com transição/rodada da campanha. O mesmo problema de validação prévia afeta `srd_apply_campaign_condition/effect` (OIDs 24805/24896), cujos helpers internos bloqueiam a campanha depois da checagem externa. Correção candidata: entrypoint campaign-first, revalidar papel/estado depois do lock e só então alterar condição/efeito.
- Nenhuma função, política Storage, bucket, linha de mídia ou arquivo foi alterado.


### CI do contrato de lifecycle

O GitHub Actions #198 [42742904531](https://github.com/clubberblues/rpgvinculo/actions/runs/42742904531) concluiu **success** no commit `cb8c2f6c2ad923a92abb562df56296c30ec2d41d`. O log mostra o fixture de lifecycle executando criação de tabelas temporárias, verificações, remoções seletivas e ROLLBACK, seguido pelos testes sintéticos de concorrência. Isso valida o fixture PostgreSQL isolado; não executa as RPCs de produção nem altera dados Supabase.


### Criação de personagem — ACL dos helpers confirmada no catálogo atual

Consulta read-only atual confirmou:
- `finalizar_criacao_personagem_srd` OID 25213 é `SECURITY INVOKER`, tem EXECUTE para authenticated e anon negado. Faz `auth.uid()` check e chama o overload de sete argumentos do helper, seguido de idiomas, talentos bônus de classe, domínios, grimório e equipamento inicial.
- `criar_personagem_srd_completo` OID 24809 (sete argumentos, identidade) e OID 20270 (seis argumentos, sem identidade) são ambos `SECURITY DEFINER`, têm EXECUTE diretamente para authenticated e anon negado, e ambos apenas verificam `auth.uid() IS NOT NULL`. O helper de sete argumentos valida identidade e cria personagem/ficha, perícias/talentos e trilha de classe, mas não conclui idiomas, bônus de classe, domínios, grimório e equipamento. O helper de seis argumentos nem sequer exige identidade.
- O endpoint público de criação atualmente é o agregador; o acesso direto aos helpers permite contornar o contrato completo de criação. Isso é integridade de fluxo, não IDOR: os helpers criam para o usuário autenticado, mas podem deixar a ficha incompleta.
- O agregador invoker depende hoje do privilégio EXECUTE do usuário autenticado no helper. Revogar a permissão diretamente, sem mudar o modelo de execução do agregador, quebraria a criação legítima.

Correção candidata, ainda não implementada: tornar o agregador o único entrypoint autenticado e privilegiado com checagem explícita de `auth.uid()`, `SECURITY DEFINER`, `search_path` fixo e referências qualificadas; em seguida revogar EXECUTE authenticated dos dois overloads internos (ou movê-los para schema não exposto) e conceder execução somente ao owner/role interna necessária. A migration deve preservar a assinatura chamada por `ficha.html`, verificar ACL efetiva herdada de PUBLIC/default privileges e testar transação completa/rollback de todas as escolhas. Não aplicar antes de reconciliar o histórico das migrations e validar os outros callers SQL transitivos.


- CI #208 [42743669088](https://github.com/clubberblues/rpgvinculo/actions/runs/42743669088) concluiu **success** no commit `cc1c5c7c179e289afd96a097c763884aa55bc63d`. O log confirma 12 assertions aprovadas em 11 tabelas temporárias, inclusive a sequência NPC remanescente vinculada à ficha-fonte e a FK `ON DELETE RESTRICT`, com ROLLBACK ao final. A validação continua sintética, sem executar RPCs de produção.


### Exclusão em duas fases — refinamento e inversão de locks

A revisão do callsite de exclusão da campanha corrigiu o diagnóstico anterior de Storage: a interface não apaga simplesmente SQL e depois tenta Storage sem estado intermediário. O fluxo atual é:
1. `preparar_exclusao_campanha_propria` (wrapper público OID 24881 → implementação privada OID 24885) bloqueia a campanha, valida owner e faz upsert em `priv.campaign_deletion_cleanup`.
2. O navegador lista recursivamente `campaigns/{id}` nos buckets `midia` e `mesa-media`, além de capas `capas_mesas/mesa-{id}-*`, e remove os arquivos em lotes de até 1000.
3. `finalizar_exclusao_campanha_propria` (wrapper público OID 24882 → implementação privada OID 24886) bloqueia a linha de cleanup, depois bloqueia a campanha, revalida owner e apaga a campanha e o marcador.

A tabela `priv.campaign_deletion_cleanup` tem apenas `campaign_id` (PK), `owner_id` e `requested_at`; RLS está habilitada, sem grants para authenticated/anon. Não armazena paths nem progresso por arquivo. A amostra atual tem zero exclusões pendentes. O marcador tem utilidade real: `priv.can_write_midia` impede novos uploads em paths da campanha enquanto a limpeza está pendente; `priv.can_delete_midia` permite ao proprietário remover arquivos durante a exclusão. Se a remoção Storage falhar, o frontend mantém a campanha e o marcador, mostra erro e reabilita o botão; o proprietário pode tentar novamente, relistando o que restou. Portanto, o fluxo é retomável por ação do usuário, mas não tem worker/outbox autônomo nem progresso individual durável.

**Novo ciclo de locks encontrado:** preparação bloqueia campanha → upsert/lock da linha cleanup; finalização bloqueia cleanup → campanha. Duas abas podem concorrer: uma chamada de preparação retém campanha e aguarda cleanup, enquanto uma finalização retém cleanup e aguarda campanha. Isso forma inversão campaign↔cleanup, embora o fluxo sequencial em uma única aba não a exponha. A correção candidata é normalizar ambas para campanha → cleanup: finalização deve localizar o marcador por MVCC, bloquear campanha, revalidar owner e só então bloquear/validar cleanup e apagar. Revalidar marcador/owner após locks; manter a remoção Storage fora da transação e o marcador como estado retomável.

Foi adicionado um cenário concorrente sintético ao harness que reproduz campaign → cleanup contra cleanup → campaign. O teste é modelo das duas cadeias de locks instaladas; aguarda CI antes de considerar validado. Nenhuma função, campanha, objeto Storage ou marcador remoto foi alterado.


- CI #212 [42744027422](https://github.com/clubberblues/rpgvinculo/actions/runs/42744027422) terminou **success** no commit `5da5948f1478a69a77d4644bb5dd86eaf021359e`. Logs confirmam a reprodução do nono padrão sintético campanha → cleanup versus cleanup → campanha; os oito padrões anteriores, controle positivo, lifecycle NPC e regressões de autorização também passaram. O único commit posterior antes deste registro alterou documentação, sem mudar fixtures.




### Storage órfão — snapshot read-only do bucket público

A consulta de `storage.objects` cruzou os IDs extraídos de `campaigns/{id}/...` e `capas_mesas/mesa-{id}-...` com `public.campaigns`:
- Bucket `midia`: 33 objetos em caminhos `campaigns/{id}/`, todos sem campanha correspondente, distribuídos por 10 IDs (10–20, exceto 18).
- Capas `capas_mesas`: 12 objetos no total; 11 sem campanha correspondente, distribuídos por 8 IDs. Uma capa pertence a campanha ainda existente.
- Total observado: 44 objetos órfãos no bucket público `midia`; nenhum objeto correspondente foi encontrado no bucket `mesa-media`.
- `priv.campaign_deletion_cleanup` tem zero linhas pendentes no snapshot. `public.media` também tem zero linhas, portanto `media_gc` não alcança esses arquivos.

O finalizador privado `priv.finalizar_exclusao_campanha_propria` valida owner e marcador, mas não verifica se restam objetos em `storage.objects`; como o wrapper público tem EXECUTE para authenticated, o fluxo de Storage é uma garantia do cliente, não uma pré-condição imposta pelo banco. Os 44 objetos podem ter sido deixados por exclusões antigas/fluxos anteriores; a amostra não prova a origem nem identifica qual execução falhou. Como `midia` é public-read, os objetos órfãos continuam publicamente legíveis enquanto existirem.

Não apagar esses objetos automaticamente: IDs sem campanha podem pertencer a arquivos históricos que precisam de classificação/backup. Próxima ação segura é gerar inventário por path, tipo e data, identificar se cada objeto é capa/mapa e obter decisão de retenção antes de qualquer remoção. Nenhum objeto, campanha ou marcador foi alterado.





### Correção de exclusão pelo lobby e proteção Storage pendente

A inspeção dos dois callsites revelou divergência real:
- `mesa.html` coleta e remove `campaigns/{id}/` de `midia` e `mesa-media`, além de capas em `midia/capas_mesas/`.
- `lobby.html` coletava apenas `midia` e capas, ignorando `mesa-media/campaigns/{id}/`. O finalizador SQL apagaria a campanha mesmo que arquivos privados permanecessem.

Correção no branch de auditoria: o helper do lobby agora coleta os dois buckets, remove lotes por bucket e contabiliza ambos no status. O validador estático `scripts/check-static.mjs` agora exige os dois prefixos, os dois buckets de remoção e a contagem combinada. Isso ainda precisa passar no CI sobre o commit que contém o validador.

O snapshot atual tem bucket privado `mesa-media` (não público), limite de 50 MiB e zero objetos registrados. Logo, o bug é uma falha de fluxo confirmada pelo código, mas não há objetos privados órfãos observados no snapshot atual.

**Lacuna de integridade no banco:** `priv.finalizar_exclusao_campanha_propria(bigint)` não consulta `storage.objects`. Um usuário autenticado que seja proprietário e tenha criado o marcador pode chamar diretamente o RPC finalizador, sem executar a remoção Storage no cliente. O marcador impede novos uploads em `midia` por `priv.can_write_midia`, mas as políticas de `mesa-media` usam `priv.pasta_gm(name)`, que só verifica papel GM e não bloqueia upload/update enquanto há marcador. Portanto, há também uma corrida de upload privado durante a exclusão. Correção de banco candidata: criar predicados separados para INSERT/UPDATE e DELETE em `mesa-media`, bloquear novos writes enquanto houver `campaign_deletion_cleanup`, manter DELETE autorizado ao GM durante a limpeza e fazer o finalizador validar zero objetos em ambos os buckets nos prefixos da campanha e zero capas correspondentes antes de excluir a linha. A validação deve ocorrer depois de locks campaign → cleanup e revalidar owner/marcador. Não aplicar até migration history/ACL e testes de Storage serem reconciliados.

### Inventário de Storage órfão — tamanho e intervalo

Os 44 objetos órfãos do bucket público `midia` somam **55.708.560 bytes (~53,1 MiB)**:
- 33 arquivos em `campaigns/{id}/`: 32.223.141 bytes.
- 11 capas em `capas_mesas/mesa-{id}-`: 23.485.419 bytes.
- Datas de criação observadas: 20/10/2026 a 03/11/2026.
- O único objeto `capas_mesas` que não é órfão pertence à campanha atualmente existente (ID 129); não foi incluído na contagem órfã.
- Não foi feita inspeção/download do conteúdo binário, e nenhum objeto foi removido. Como o bucket é público, o risco observado é retenção pública de mídia histórica, não exposição de um bucket privado.





### Políticas do bucket privado — incompatibilidade de path confirmada

As três policies de escrita de `mesa-media` — INSERT (`mesa_media_enviar`), UPDATE (`mesa_media_trocar`) e DELETE (`mesa_media_apagar`) — chamam `priv.pasta_gm(name)`. A policy SELECT (`mesa_media_ler`) chama `public.can_read_media(name)`. A função `priv.pasta_gm` executa `storage.foldername(name)[1]`, exige que o primeiro segmento seja numérico e chama `public.my_role(id)`. Mas o frontend grava mapas e retratos em `campaigns/{campaign_id}/...`. A consulta direta do helper Storage confirmou:
- `storage.foldername('campaigns/129/test.png') = ['campaigns','129']`
- segmento [1] = `campaigns` (não numérico);
- segmento [2] = `129`.

Consequência: para o padrão de caminho atualmente usado pelo frontend, `pasta_gm` retorna false antes de consultar o papel do usuário. Isso bloqueia INSERT/UPDATE/DELETE em `mesa-media` para os paths atuais. O bucket tem zero objetos, compatível com a falha, embora o snapshot sozinho não prove tentativas de upload rejeitadas.

Há uma segunda incompatibilidade de leitura: a política SELECT chama `public.can_read_media(name)`, que só permite GM ou camada visível quando existe linha em `public.media` com `media.path = name`. Snapshot atual: `public.media` = 0, `public.layers` = 0; não há trigger em `storage.objects` que crie metadados em `public.media`, e os callsites CBA em `mesa.html` fazem upload + `createSignedUrl` sem inserir essa linha. Assim, mesmo corrigindo o parser de pasta, a assinatura de URL para esses assets não tem uma autorização correspondente na tabela de mídia. O caminho privado de mapas/retratos está, portanto, incompleto no banco: escrita e leitura não estão alinhadas ao formato atual do CBA.

Correção candidata deve ser desenhada como um contrato único por campanha: extrair o ID do segundo segmento de `campaigns/{id}/...`; autorizar GM da campanha; negar INSERT/UPDATE quando houver marcador de exclusão; permitir DELETE ao GM durante a limpeza; e permitir SELECT aos membros da campanha segundo a regra de visibilidade escolhida para mapa/retrato. Não reutilizar `can_read_media` sem uma etapa transacional que registre metadados em `public.media`; preferir um predicado específico para os assets do CBA se a visibilidade for de campanha. Não aplicar ACL/policy/function no banco de produção nesta etapa.

CI sobre o código do lobby + validador estático:
- Static validation #11 [42744608629](https://github.com/clubberblues/rpgvinculo/actions/runs/42744608629): **success**, commit `31882ee88881e5cc335b35f4de0e5544fe4e1661`; executou `scripts/check-static.mjs`, incluindo as novas invariantes de limpeza dos dois buckets.
- PostgreSQL fixtures #220 [42744608913](https://github.com/clubberblues/rpgvinculo/actions/runs/42744608913): **success**, commit `31882ee88881e5cc335b35f4de0e5544fe4e1661`; nove inversões sintéticas e os demais fixtures passaram.
- Syntax check #59 [42744608931](https://github.com/clubberblues/rpgvinculo/actions/runs/42744608931): **success**, mesmo commit.





### Contrato de correção proposto para assets privados CBA

Não corrigir somente o índice do segmento e considerar o recurso pronto. O contrato deve ser consistente nas políticas, no RPC finalizador e nos dois callsites:
1. **Path único:** aceitar somente `campaigns/{campaign_id}/...`; extrair o ID com regex ancorada no começo e validar que a campanha existe. Não depender de `storage.foldername(name)[1]` quando o primeiro segmento é literalmente `campaigns`.
2. **Upload/update:** somente GM da campanha; negar enquanto existir `priv.campaign_deletion_cleanup` para a campanha.
3. **Read/signed URL:** permitir aos membros autorizados da campanha para os assets que o CBA publica (mapa de fundo e imagens de token), sem depender de linha em `public.media`. A galeria antiga baseada em `public.media` deve manter seu contrato próprio.
4. **Delete:** GM pode remover arquivos da própria campanha, inclusive durante a exclusão pendente; não permitir remoção por usuário externo. Usar Storage API `remove`, nunca DELETE SQL em `storage.objects`.
5. **Finalização:** sob lock campanha → cleanup, revalidar owner e marcador e exigir ausência de objetos em `mesa-media/campaigns/{id}/`, `midia/campaigns/{id}/` e capas `midia/capas_mesas/mesa-{id}-`. Se restar qualquer objeto, falhar sem apagar campanha nem marcador, para permitir retry.
6. **URLs assinadas:** o CBA usa TTL de 86.400 s e cache local de 23 h. Avaliar TTL menor para limitar o tempo de acesso de um ex-membro após remoção/revogação; URLs já emitidas continuam sendo bearer tokens até expirar.

Matriz mínima de integração antes de aplicar migration: GM pode uploadar/ler/atualizar/remover; jogador membro pode ler assets publicados, mas não gravar/remover; usuário externo não pode listar/ler/gravar/remover; novo upload é negado durante cleanup; delete continua permitido durante cleanup; finalizador rejeita quando qualquer objeto/capa persiste; após remoção via Storage API, finalizador conclui; teste concorrente tenta upload enquanto finalização ocorre. A suíte PostgreSQL sintética atual não substitui essa validação Storage/RLS real.



A integridade de associação do proprietário foi consultada no snapshot: 3 campanhas, 3 proprietários também presentes em `public.members` com papel GM, nenhum proprietário ausente. O trigger `enforce_campaign_member_role` mantém a regra owner→GM no fluxo de alteração. Ainda assim, o predicado novo deve autorizar `campaigns.owner_id` explicitamente ou documentar/testar a invariável do trigger, em vez de depender implicitamente dela.
