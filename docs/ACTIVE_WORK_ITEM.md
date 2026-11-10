# Vínculo RPG — item de trabalho ativo

## Estado consolidado — 2026-11-10

- Frente ativa: auditoria read-only de concorrência/ordem de locks dos fluxos AOO, ficha, magia, recursos de classe e ataques iterativos.
- Branch: `audit/lock-order-rage-removal-2026-11-09`.
- PR #74: [docs: auditar inversões de locks em AOO, conjuração e ataques iterativos](https://github.com/clubberblues/rpgvinculo/pull/74), aberto, draft, não mesclado. Head atual: acompanhar diretamente no PR #74.
- O PR contém apenas documentação e fixtures SQL descartáveis: `docs/LOCK_ORDER_PROTOCOL_DRAFT.md`, `docs/LOCK_ORDER_REFACTOR_PLAN.md`, `docs/CBA_MUTATION_INVENTORY.md`, `docs/ACTIVE_WORK_ITEM.md`, `docs/ROADMAP.md`, `docs/AUDIT_REGISTER.md`, `tests/sql/README.md`, `tests/sql/lock_cycle_setup.sql`, `tests/sql/lock_cycle_test.sh`.
- CI PostgreSQL #72 [42730159992](https://github.com/clubberblues/rpgvinculo/actions/runs/42730159992) concluiu success na versão anterior do harness. CI #100 [42731471362](https://github.com/clubberblues/rpgvinculo/actions/runs/42731471362) concluiu success no commit `dd38946efd5cd9ef58ec8ef33b492227793141e7`: footprint helper, oito inversões, controle positivo, TOCTOU reproduzido (owner final player-c, dois GM) e controle campaign-first (segunda transferência rejeitada, owner final player-b, um GM). Commits posteriores só alteraram documentação; fixtures SQL não mudaram.
- O harness tem oito padrões sintéticos de inversão + um controle positivo, além de dois cenários sintéticos de transferência de Mestre (reprodução TOCTOU e controle campaign-first). CI #100 passou em todos; os cenários são transacionais sintéticos, não executam RPCs, triggers nem dados de produção.
- Ciclos potenciais confirmados por corpos instalados: PC Ataque Total arma→campanha versus resolução campanha→tentativa/sequência/arma; NPC sequência→campanha versus campanha→tentativa/sequência; AOO ataque→pending→campanha versus transição campanha→ataque→pending; AOO pending→campanha em início/finalização; ficha/recurso→campanha em estabilização, conjuração multialvo, Míssil Mágico manual (wrapper OID 25191), cura multialvo (wrapper OID 24661) e habilidades específicas; outras magias manuais single-target (OID 24658) seguem personagem→campanha→ficha.
- Precisões relevantes: descanso longo PC não bloqueia campanha (personagem → leitura de estado sem lock → ficha → recursos/condições), logo o defeito é corrida de estado, não deadlock; estabilização bloqueia personagem → ficha → campanha; Imposição das Mãos contra mortos-vivos bloqueia personagem → ficha → recurso → campanha; habilidade de classe tem ordem variável por branch; resolução de salvamento altera condição diretamente sem lock explícito de campanha no branch condition_break.
- AOO: RPCs autenticadas e OIDs documentados na matriz em LOCK_ORDER_PROTOCOL_DRAFT.md; dano AOO contra personagem bloqueia ataque → pending → campanha → ficha. Interseção com estabilização pode formar ciclo na mesma ficha.
- A proposta de ordem é parcial por domínio, não hierarquia global. Direção preferida para mutações de campanha: localizar IDs via leitura MVCC, lock de campanha, revalidar vínculo/autoridade/estado/round, então bloquear personagem/ficha/recurso/pending/attack conforme o contrato específico. Plano faseado não aprovado para deploy: [LOCK_ORDER_REFACTOR_PLAN.md](LOCK_ORDER_REFACTOR_PLAN.md). Ordem final de AOO e interseções de arma/ledger ainda precisam ser fechadas.
- public.gm_transfer (OID 18749) foi classificada como endpoint autenticado legado com corrida TOCTOU potencial em chamadas concorrentes; sem call site direto localizado nas páginas principais. Fixture sintético novo modela a corrida e o controle corrigido. A varredura dos writers authenticated de campaigns não encontrou outro writer sem lock direto/herdado; create_campaign insere nova linha e adicionar_token_cba_completo herda lock do helper.
- Nenhuma função, migration, ACL, policy, dado Supabase ou mesa/ficha foi alterada. TESTE 2 permanece intocado. Nenhum deploy remoto.
- Reconciliação de migrations permanece bloqueio: 681 arquivos locais, 966 registros remotos, apenas 640 versões coincidentes exatas por timestamp/nome; conteúdo SQL ainda não foi comparado.

## Próxima unidade de trabalho

1. Fechar grafo transitivo de todos os writers que alteram campanha, ficha, pending, ataque, ledger, recurso, condição e log; separar lock adquirido diretamente, lock herdado e leitura MVCC.
2. Reconciliar cada caminho com call sites de frontend e grants efetivos, distinguindo endpoints ativos, wrappers, helpers e legado.
3. Elaborar sequência de refatoração por fatias (AOO, ataque iterativo PC/NPC, ficha/magia/recursos), com pré-condições, revalidação pós-lock, idempotência, rollback e testes de integração descartáveis.
4. Estender testes apenas quando reproduzirem um contrato transacional específico; manter os cenários sintéticos identificados como tais.
5. Não aplicar migration, alterar funções remotas, ACL/policies ou dados até reconciliação de migrations e teste de integração autenticado em ambiente descartável.

---

## Atualização consolidada — 2026-11-09 (continuidade 2)

- Run [42673548023](https://github.com/clubberblues/rpgvinculo/actions/runs/42673548023) concluiu **success** para o commit `502b47bc28b61ed7ed5c3dab181fee62c9f433ec`.
- Commit atual `81c2bb72f4eb46f86d499eb02274a0dbe34eed61` adiciona cenário sintético campanha ↔ recurso de classe; run [42678898017](https://github.com/clubberblues/rpgvinculo/actions/runs/42678898017) está em execução, ainda sem resultado final.
- Auditoria remota read-only encontrou também inversão potencial campanha → ficha (resolução de magia pendente) versus ficha → campanha (conjuração multialvo). Cenário sintético correspondente adicionado nesta atualização.
- A combinação recurso de classe ↔ campanha permanece condicionada à confirmação de alcance simultâneo dos entrypoints; no snapshot atual, os 3 tokens NPC vinculados têm source characters com `campaign_id IS NULL`.
- Nenhuma função, migration, ACL, policy ou dado foi alterado no Supabase remoto; TESTE 2 permaneceu intocado.



## Continuidade — próxima unidade de trabalho

- HEAD observado no início desta unidade: `a1172927027160f5f69adc2e6f9da30af12cb92e`.
- Run PostgreSQL isolado [42679102920](https://github.com/clubberblues/rpgvinculo/actions/runs/42679102920): `success`, com oito padrões sintéticos. Não executa RPCs reais.
- Nova revisão read-only de funções transitivas de magia, efeitos, condições e `end_combat` identificou que o encerramento de combate bloqueia ataques AOO antes das pendências e percorre efeitos de Fúria antes do lock final da campanha. Ambos os caminhos reforçam as inversões já inventariadas; não são prova de deadlock reproduzido.
- Helpers de aplicação de efeitos/condições bloqueiam campanha primeiro; helper de vitalidade de personagem atualiza condições sem bloquear campanha. Helper de sincronização de NPC vinculado bloqueia campanha antes da ficha.
- Próxima ação: construir fixtures de PostgreSQL mais próximas dos helpers reais (condição vital, sync NPC, end-combat AOO/Fúria), depois cobrir wrappers de conjuração. Continuar sem alterar Supabase remoto e sem testar campanhas reais.


## Continuidade — rastreamento de Fúria e encerramento (2026-11-09)

- HEAD auditado: `68f0e679f02061543243c04d33d3fb451c8eef72`.
- Revisão read-only por OID confirmou ordem composta de Fúria: `end_combat` percorre efeito → ficha/condições e só atualiza campanha ao final; a trigger de avanço de rodada parte de campanha bloqueada e depois bloqueia efeitos.
- O mesmo `end_combat` atualiza ataques AOO antes de pendências, reforçando inversão attack ↔ pending.
- Acrescentado caso sintético específico effect → sheet → campaign versus campaign → effect no harness; ele não executa RPCs Supabase.
- Nenhuma função/migration/ACL/policy/dado remoto foi alterado; TESTE 2 permanece intocado.
- Próxima frente: aprofundar os caminhos de condição vital e encerramento AOO com fixtures que copiem os efeitos transacionais relevantes; depois mapear os writers de condição e log por OID. Manter migration/deploy remoto bloqueados até reconciliação.


## Continuidade — escritores de condições e locks herdados (2026-11-09)

- Varredura read-only por OID dos escritores de `srd_campaign_conditions` e `campaign_log` separou helpers que bloqueiam campanha daqueles que dependem do lock herdado.
- Achado para revisão: `public.srd_remove_campaign_condition` (OID 24806) é SECURITY DEFINER e executável por authenticated; valida GM, mas atualiza condição sem `campaigns FOR UPDATE`. Busca textual direta em `mesa.html` não encontrou uso; não presumir que esteja ativo.
- `priv.srd_clear_combat_flatfooted_all` é chamado tanto por `alternar_estado_campanha` (campanha já bloqueada) quanto por `end_combat` (antes do UPDATE final de campanha). A diferença do chamador precisa constar no grafo.
- Nenhum grant/policy/função remota foi alterado. Próxima etapa: rastrear callers dos writers de condição e validar contratos/ACL.


## Resultado consolidado — fixture composta de Fúria (2026-11-09)

- Commit de teste: `fb261e66a14bb5fed9a35976ea394afaddafb160`.
- Run [42714600496](https://github.com/clubberblues/rpgvinculo/actions/runs/42714600496): **success**.
- Confirmado nos logs: fixture de footprint aprovada e nove padrões sintéticos de inversão de lock aprovados, incluindo effect → sheet → campaign versus campaign → effect.
- O HEAD atual após a documentação subsequente é `e5068ce7414e51a07b1c77ba406a31115ffd6d3f`; a atualização de documentação não altera a cobertura executada pelo run.
- Limite: nenhum endpoint/trigger remoto foi executado; não houve mutação Supabase nem acesso a TESTE 2.


## Atualização — concorrência de estado entre combate, descanso e poções (2026-11-10)

- Confirmados por definição instalada e grants: descanso longo OID 24366 e poção manual OID 24655 são endpoints authenticated; transição de estado OID 20103 e consumo de ação OID 20405 também são authenticated. `start_combat` OID 19090 não é executável por authenticated/anon no snapshot.
- Descanso longo bloqueia personagem antes de ler estado da campanha sem lock; a transição pode iniciar combate entre a leitura e as mutações de PV/magias/recursos/condições. Corrida de estado, não deadlock provado.
- Poção manual lê estado sem lock e só chama o consumo de ação se já viu COMBATE. Se observar EXPLORACAO e a transição ocorrer antes do consumo, o endpoint pode completar cura e retirar item sem ação de combate. O helper de ação, quando chamado, bloqueia campanha e revalida corretamente, mas não cobre o ramo que o pulou.
- A correção deve começar pelo lock da campanha e revalidar estado/vínculo antes dos locks de personagem/ficha/equipamento/recursos; não adicionar lock de campanha dentro do helper vital, pois isso pode criar campanha-after-sheet em callers existentes.
- Nenhuma alteração remota. Próxima tarefa: mapear a ordem de locks do inventário/equipamento e construir cenários concorrentes descartáveis para descanso × transição e poção × transição antes de propor refatoração de RPC.


- Contraste adicional: descanso longo de NPC vinculado (wrapper OID 26801 → impl OID 26808) já bloqueia campanha antes de personagem/ficha e valida combate; a corrida identificada é específica do descanso PC OID 24366. Call sites confirmados: ficha.html usa ambos; mesa.html usa poção manual e alternância de estado. `srd_remove_campaign_condition` não apareceu nas três páginas principais consultadas; manter como endpoint legado sem presumir inatividade externa.


- Equipamento refinado: PC weapon equip OID 26441 adquire character → weapon instance → inventory; token weapon equip OID 26443 adquire campaign → token weapon instance → token inventory. Triggers de quantidade apontam inventory → instances, mas nenhum writer autenticado atual foi encontrado reduzindo quantidade de arma; não afirmar ciclo ativo sem esse caminho.
- Novo TOCTOU de autorização: entregar_item_srd OID 20556 verifica GM sem lock de campanha; entregar_item_token_srd OID 21668 e equipar_item_token_srd OID 21670 verificam GM antes do lock de campanha. A transferência gm_transfer pode revogar o papel depois da validação. Próximo: reproduzir stale GM role em fixture descartável e desenhar revalidação campaign-first antes de propor mudança de RPC.


- Varredura de membership/admin ampliou o conjunto: `priv.need_owner` OID 18742 não bloqueia campanha; `gm_set_role` OID 18748 e `gm_kick` OID 19188 alteram membership sem campaign lock; `iniciar_iniciativa_com_dados` OID 20577 valida GM antes do lock da campanha. A correção de autorização deve cobrir a família administrativa inteira, não apenas inventário/transferência. `sentar_personagem_na_mesa` OID 21606 e `leave_campaign` OID 19187 precisam de análise de associação e membership separada.


- Fixtures concorrentes ampliados: além da revogação de GM em inventário, agora há cenários transacionais para operação de administração (`gm_kick`/`gm_set_role`) após transferência de ownership, com controle campaign-first. A primeira versão de sincronização do harness teve falhas de barreira; foi substituída por concorrência dentro da mesma transação e controle usando lock real da linha de campanha. Resultados finais aguardando CI do commit mais recente.

- Call sites verificados no frontend principal: `mesa.html` chama `iniciar_iniciativa_com_dados` (OID 20577), confirmando que a janela GM-before-campaign-lock é caminho ativo; `lobby.html` chama `sentar_personagem_na_mesa` (OID 21606), confirmando que a análise de associação PC é fluxo ativo. A busca nas páginas `mesa.html`, `ficha.html`, `lobby.html` e `index.html` não encontrou chamadas diretas para `gm_set_role`/`gm_kick`; continuam endpoints RPC authenticated e possíveis consumidores externos.


- Achado prioritário: `gm_transfer` (OID 18749) altera papéis antes de owner_id, enquanto trigger `enforce_campaign_member_role` (OID 21603) impõe GM ao owner antigo e converte novo GM em PLAYER. Fixture agora reproduz a ordem atual e testa controle owner-first. Snapshot agregado: 3 campanhas, todas owner=GM e exatamente um GM; nenhuma inconsistência persistida detectada. Não executar correção remota.


- Superfície GM ampliada: além de inventário e início de iniciativa, os endpoints ativos `alternar_estado_campanha` (20103), `salvar_cena_cba` (20077), `adicionar_combatente_iniciativa` (20078), `mover_combatente_iniciativa` (20080), `srd_configurar_perfil_combate_token_srd` (26922), `srd_configurar_rodada_surpresa_srd` (27092) e `usar_furia_barbaro_npc_srd` (26656) validam GM antes do lock de campanha. Call sites confirmados em mesa.html/ficha.html. Após corrigir transferência, revalidar papel depois do campaign lock para evitar execução de chamadas que chegaram com autorização obsoleta.


#### Completar endpoints de owner: código de acesso

A mesma dependência de `priv.need_owner` (OID 18742) aparece em `public.gm_set_code` (OID 18747), EXECUTE authenticated. A função valida owner/active por `need_owner` e depois altera `campaign_codes` sem lock de campanha. Assim, o antigo proprietário também pode alterar o código de entrada depois de uma transferência concorrente se a autorização tiver sido validada antes da revogação. A matriz de operações owner-first passa a incluir `gm_set_code`, `gm_set_role`, `gm_kick` e `gm_transfer`; o helper não deve ganhar lock implícito sem auditar callers.


### Validação CI concluída — commit cf1ba84 (2026-11-10)

GitHub Actions run #141, SHA `cf1ba84cc55171e295d69e2b8f0bde19830b8943`, concluiu SUCCESS. Logs confirmam: stale owner transfer (duas transferências pré-validadas) reproduz owner=player-c e 2 GMs; stale GM inventory reproduz mutação após role=PLAYER; controle campaign-first rejeita a mutação; stale owner administration reproduz expulsão após perda de ownership; controle campaign-first rejeita; ordem atual de `gm_transfer` reproduz antigo GM/novo PLAYER; controle owner-first produz antigo PLAYER/novo GM. Os erros de deadlock/authorization nos logs são os resultados esperados dos cenários negativos, não falha do workflow. PR #74 permanece aberto, draft, não mergeado, mergeable=true; 158 commits, 9 arquivos.

A consulta read-only às chamadas de `priv.need_owner` confirma que apenas `gm_set_code`, `gm_set_role`, `gm_transfer` e `gm_kick` são os endpoints authenticated que usam esse helper. O helper lê owner/active sem lock. Portanto, o conjunto owner-admin está fechado no snapshot atual; corrigir os quatro endpoints como família, com campaign lock e revalidação após lock. Não mover lock para dentro de `priv.need_owner` sem auditar contexto e ordem de locks dos callers.


- Nova camada identificada: `priv.need_gm` (18741) não bloqueia campanha. Endpoints authenticated: `gm_grant` (18752), `gm_reopen_sheet` (18892), `gm_set_bonus` (18893), `media_gc` (18760), `gm_get_code` (18746). `srd_apply_campaign_condition/effect` (24805/24896) verificam GM antes de helper que bloqueia campanha; removers (24806/24897) não bloqueiam. Exigem trilhas próprias; não foram alterados.


- Qualificação de exposição: busca no frontend atual e GitHub code search não encontrou chamadas para `gm_grant`, `gm_reopen_sheet`, `gm_set_bonus`, `media_gc` ou wrappers apply/remove de condition/effect. Continuam com EXECUTE authenticated no catálogo e devem ser tratados como superfície RPC; não afirmar que são fluxos ativos da interface sem call site. Os fluxos GM/CBA/iniciativa/perfil/Fúria já citados têm call sites confirmados.


- Varredura lexical completa do schema público: 41 funções authenticated têm comparação de `my_role` com GM. Não interpretar como 41 falhas: inclui consulta, dono da ficha e ações de jogador. Lista de endpoints AOO/combate com call sites em mesa.html precisa de classificação ator-a-ator antes de qualquer alteração; manter autorização de jogador nas reações/rolagens.


### CI aprovado — cobertura owner-admin ampliada (2026-11-10)

GitHub Actions #161, SHA `f7c497004ca5069a46dfbafecc343f595bbc951b`, concluiu SUCCESS. Além da suíte anterior, os novos cenários confirmaram: (1) `gm_set_code`: owner antigo altera código depois de transferência; controle campaign-first rejeita; (2) `gm_set_role`: owner antigo altera papel de membro depois de transferência; controle campaign-first rejeita. Também passaram os controles de transferência/trigger, expulsão, inventário GM e efeito GM. As mensagens PostgreSQL `ERROR` capturadas são erros intencionais esperados nos cenários negativos; o workflow concluiu sucesso.

PR #74 permanece open, draft, unmerged, mergeable=true, head `f7c497004ca5069a46dfbafecc343f595bbc951b`, 178 commits e 9 arquivos. Nenhuma migration ou mutação de produção foi aplicada.


- Fixture sintético acrescentado para `gm_reopen_sheet`/`gm_set_bonus`: reproduz mutação de ficha após revogação de GM e controle campaign-first que rejeita a chamada obsoleta. CI pendente nesta revisão.


## Atualização complementar — endpoints GM e concessão de itens (2026-11-10)

- CI runs #166 (42738200474) e #167 (42738209790) concluíram SUCCESS, incluindo setup PostgreSQL, fixtures SQL isolados e teardown. Os dois cobrem o commit anterior à ampliação atual de testes.
- Auditoria read-only confirmou que `gm_grant` checa GM antes do lock de personagem; foi acrescentada fixture para reproduzir concessão após revogação e controle campaign-first.
- Novas fixtures cobrem também remoção direta de condição/efeito após revogação e controle campaign-first. Aplicação de efeito já estava coberta; aplicação de condição segue a mesma estrutura wrapper→helper que bloqueia campanha sem revalidar papel.
- Achado funcional adicional: `gm_grant` consulta `items` e `inventory`, mas o schema remoto contém `vinculo_items` e `vinculo_inventory`, não as relações sem prefixo. O ramo de concessão de item é incompatível com o schema instalado. Não houve chamada remota para testar, pois seria mutação e a reconciliação de migrations continua pendente.
- `media_gc` exclui metadados de mídia não referenciada e retorna paths para o navegador remover no Storage. A FK de layers para media protege referências; autorização GM ainda pode ficar obsoleta e a exclusão do Storage é externa à transação. Sem call site literal encontrado no frontend/repo.
- `gm_get_code` permanece leitura protegida; decidir se a revogação precisa ser linearizável, sem misturar com mutações.
- Branch/PR #74 permanecem em revisão draft; os novos testes aguardam CI do head atualizado. Nenhuma função, migration, ACL, policy ou dado Supabase foi alterado; TESTE 2 não foi acessado.
- Próxima unidade: executar CI atualizado; auditar a origem histórica do rename `items/inventory` para `vinculo_items/vinculo_inventory`; fechar contrato de leitura de `gm_get_code`; depois consolidar a matriz campaign-first sem aplicar mudanças remotas.


## CI #170 — nova cobertura GM aprovada

- GitHub Actions [run #170](https://github.com/clubberblues/rpgvinculo/actions/runs/42739191233), SHA `3c7144a5894e161d90dfa82762c040a97955e652`: **SUCCESS**.
- Logs confirmiram: fixture de footprint; stale GM sheet mutation; stale GM grant (role=PLAYER, gold=100, xp=50, item_count=1); controle campaign-first do grant rejeitou o pedido e manteve os valores zerados; remoção de condição/efeito após revogação; controle campaign-first rejeitou e manteve ambos ativos.
- Os erros `GM authorization lost after campaign lock` registrados pelo PostgreSQL são exceções esperadas nos controles negativos; o job terminou success.
- Cobertura continua sintética: não executa as RPCs Supabase reais nem valida o branch de item de `gm_grant`. Nenhuma mudança no banco remoto.


## Achado de alto impacto — exclusão de ficha do lobby

- A auditoria ampliou o scan de relações antigas: `public.excluir_ficha_propria` (OID 20219) é chamado diretamente pelo botão de exclusão em `lobby.html`.
- O corpo executa `DELETE FROM public.character_notes`, mas essa relação não existe no schema remoto; a tabela atual é `vinculo_character_notes`. Depois também tenta `public.inventory`, inexistente; a atual é `vinculo_inventory`. A primeira falha aborta a transação, então a exclusão da ficha não conclui. Não foi executada para não alterar dados.
- A função também bloqueia personagem antes da campanha quando a ficha está vinculada, invertendo campaign-first → character de rotas de combate. O fixture genérico de inversão já cobre o padrão; endpoint e call site foram documentados.
- As tabelas atuais têm cascades/trigger de limpeza (vinculo inventory/notes, ficha SRD, equipamento SRD e instâncias de armas); mapear tudo antes de corrigir as instruções obsoletas.
- O scan encontrou outras rotinas legadas com referências a `public.items/inventory`: calc_ca, calc_desl, calc_sheet, sell_price e gm_grant; save_sheet é service_role-only. Nenhuma dessas rotinas aparece nas seis páginas HTML atuais, exceto a cadeia indireta calc_sheet chamada por gm_reopen_sheet/gm_set_bonus, também sem call site encontrado.
- Nenhuma alteração remota. Prioridade próxima: reconciliar a função de exclusão com o schema atual e fechar sua ordem campaign-first em migration descartável autenticada, após reconciliação do histórico.


## Reconciliação de schema legado — dependências e limpeza

- Catálogo remoto confirmou que `public.items`, `public.inventory`, `public.character_notes` e `public.character_sheets` não existem. Tabelas atuais: `vinculo_items`, `vinculo_inventory`, `vinculo_character_notes`, `vinculo_character_sheets`, além de `srd_character_sheets`.
- `excluir_ficha_propria` é usada no lobby e falha na primeira tentativa de apagar `public.character_notes`; `gm_reopen_sheet`/`gm_set_bonus` falham ao atualizar `public.character_sheets`; `calc_sheet`, `calc_ca`, `calc_desl`, `sell_price` e `gm_grant` têm dependências de tabelas antigas.
- `save_sheet` tem dependências antigas, mas EXECUTE authenticated está revogado/restrito a service_role no snapshot.
- A limpeza de personagem já é majoritariamente por cascades e triggers; `srd_npc_attack_sequences` é RESTRICT, porém tem zero linhas no snapshot.
- O script root `srd35_character_sheets_cleanup_migration.sql` não aparece no ledger remoto e não substitui as RPCs; a origem da divergência não está comprovada. Não atribuir a um migration específico.
- PR #74: [run #174](https://github.com/clubberblues/rpgvinculo/actions/runs/42739628596) SUCCESS no head `f6302c3957a36e0dc5194b9807b635a8a42e7346`. Os runs #171–#174 do head/docs recentes passaram.
- Nenhuma mutação de produção. Próximo trabalho: inventariar todas as RPCs authenticated com dependências em relações ausentes, depois construir plano de migração de compatibilidade e lock-order sem aplicar remotamente.


## Fluxo ativo adicional — cópia de equipamento para token NPC

- `mesa.html` chama `clonar_equipamento_ficha_para_token` após criar token NPC vinculado à ficha do Mestre. O endpoint não usa tabelas antigas, mas verifica GM antes de qualquer campaign lock e não revalida; classificado como stale authorization em fluxo ativo.
- A criação do token e a cópia de equipamento são RPCs separadas. Se a segunda falhar, o token permanece criado e o frontend já avisa que o equipamento não foi copiado.
- Varredura refinada encontrou 17 funções com referências SQL reais a tabelas antigas; 8 têm EXECUTE authenticated e 9 são service_role-only. Falsos positivos em `finalizar_equipamento_inicial_srd` e `clonar_equipamento_ficha_para_token` foram descartados: usam catálogo/tabelas SRD atuais.
- A função `priv.new_sheet` não está ligada a trigger no snapshot. Nenhuma função foi invocada nem alterada.


## Diretriz de arquitetura para correção das RPCs antigas

- As tabelas `vinculo_*` são o modelo legado, não o motor D&D 3.5. O motor atual usa `srd_character_sheets`, `srd_equipment`, `srd_character_equipment` e instâncias de arma.
- Não fazer substituição textual de `character_sheets/items/inventory` por `vinculo_*` nas RPCs antigas. Isso reativaria o sistema que deixou de ser fonte de verdade.
- RPCs antigas sem call site: avaliar revogar/aposentar; requisitos D&D ainda necessários devem receber implementação própria sobre tabelas SRD.
- A exclusão do lobby é a exceção ativa: corrigir usando cascades/triggers e manter a ordem campaign-first, sem reativar tabelas antigas.


## Fallback legado em ficha.html — alcance atual

- O lobby atual abre a criação com `mode=criar&ruleset=dnd35`; esse caminho entra na criação SRD. Fichas existentes com `srd_character_sheets` também usam o fluxo SRD.
- O fallback sem ficha SRD ainda usa `vinculo_character_sheets`, mas tenta acessar `inventory` e `character_notes`, que não existem no schema atual. A criação legada sem `ruleset=dnd35` também continua no código.
- Snapshot atual: 5 personagens, todos com ficha SRD; zero sem SRD e zero legados vinculados a campanha. Portanto, não há personagem atual usando esse fallback.
- Não remover/revogar sem plano de compatibilidade; manter criação principal no caminho D&D 3.5 e planejar desativação controlada do fallback.


## Fluxo principal D&D 3.5 de criação confirmado

- Lobby encaminha para `ficha.html?mode=criar&ruleset=dnd35&raca=...&classe=...`.
- `salvarFichaSRD35` chama `finalizar_criacao_personagem_srd` (OID 25213), wrapper SECURITY INVOKER que executa criação, perícias/talentos, idiomas, talentos bônus, domínios, grimório e equipamento inicial em uma única transação.
- O fluxo usa tabelas/catálogos SRD e `srd_character_equipment`, não o modelo Vínculo legado.
- Manter atomicidade desse wrapper nas futuras mudanças; fallback antigo não é o caminho primário.


## Achado novo — helpers de criação SRD executáveis diretamente

- Duas sobrecargas SECURITY DEFINER de `criar_personagem_srd_completo` têm EXECUTE authenticated: OID 20270 (6 args, sem identidade/etapas complementares) e OID 24809 (7 args, valida identidade mas não executa idiomas, domínios, grimório, talentos bônus e equipamento).
- O frontend usa somente `finalizar_criacao_personagem_srd` OID 25213, que agrega todas as etapas. A sobrecarga 6 args vem do script root não timestamped `srd35_skills_feats_migration.sql`; a de 7 args vem de migration 20261103200319.
- O agregador foi mudado de SECURITY DEFINER para INVOKER em 20261104042251, e o helper 7 args permaneceu EXECUTE authenticated. Revogar isoladamente quebraria o wrapper; correção precisa rever o modelo de execução e testar o agregador.
- Dados atuais: 5 fichas SRD, todas com identidade, talentos e equipamento inicial concluído; nenhuma ficha incompleta observada.
- Nenhuma chamada RPC de teste ou alteração remota foi feita.


## Bloqueio de exclusão: tokens NPC vinculados por JSON

- Snapshot atual contém 3 tokens NPC em 2 campanhas apontando para 2 personagens existentes via `sourceCharacterId`; ambos têm `characters.campaign_id IS NULL`.
- `excluir_ficha_propria` só bloqueia campanha por `characters.campaign_id` e só atualiza `combat_data`; não limpa `cba_data.tokens[*].sourceCharacterId`.
- Após corrigir as relações inexistentes, excluir essas fichas deixaria referência JSON quebrada, afetando RPCs SRD de NPC que dependem da ficha de origem.
- Antes da correção, decidir entre bloquear exclusão até desvincular os NPCs ou converter o token para snapshot independente. Se mutar, localizar todas as campanhas pelo JSON, lock em ID crescente, revalidar links, depois bloquear personagem.
- Nenhuma ficha/token/campanha foi alterada.


## Duplicidade de token NPC vinculado e ambiguidade na ficha

- Um personagem-fonte está vinculado a dois tokens NPC na mesma campanha; outro está vinculado a um token em outra campanha.
- `ficha.html` rejeita ações de descanso longo/Fúria se encontrar mais de um token na campanha, então o painel da ficha não consegue escolher entre os dois. Ações do painel de cada token em `mesa.html` recebem token_id e não têm essa ambiguidade.
- Se clones múltiplos forem permitidos, a ficha precisa oferecer seleção do token ou definir operações com semântica compartilhada; não escolher o primeiro automaticamente.


## Atualização — lifecycle de NPC vinculado (2026-11-10)

- Adicionado `tests/sql/npc_lifecycle_test.sql`, integrado ao harness PostgreSQL.
- CI #198 [42742904531](https://github.com/clubberblues/rpgvinculo/actions/runs/42742904531) concluiu success no commit `cb8c2f6c2ad923a92abb562df56296c30ec2d41d`; o log confirma execução do fixture em transação temporária com ROLLBACK, preservação de outros tokens, cancelamento de pendências, limpeza relacional e proteção de ficha-fonte.
- A validação é sintética e não chama RPC real. A implementação continua bloqueada por ausência de endpoint de remoção, incompatibilidade de `excluir_ficha_propria` e reconciliação de migrations.
- Nova frente auditada: `gm_grant` e `media_gc` são endpoints legados sem callsite atual identificado; o ramo de item de gm_grant referencia `items/inventory` inexistentes. A limpeza Storage da campanha é não atômica e deve migrar para outbox/retry.
- Sem alterações no Supabase remoto, migrations, ACLs, políticas, Storage ou campanhas.


- CI #208 [42743669088](https://github.com/clubberblues/rpgvinculo/actions/runs/42743669088) terminou **success** no commit `cc1c5c7c179e289afd96a097c763884aa55bc63d`. O log lista 12 assertions aprovadas, incluindo referência JSON remanescente, sequência NPC ativa vinculada à ficha e FK `ON DELETE RESTRICT`; fixture encerra com ROLLBACK.


- CI #212 [42744027422](https://github.com/clubberblues/rpgvinculo/actions/runs/42744027422) concluiu **success** no commit `5da5948f1478a69a77d4644bb5dd86eaf021359e`. O log confirma a reprodução do novo ciclo campanha → marcador de exclusão versus marcador → campanha, além dos oito padrões anteriores, do controle positivo e do fixture de lifecycle. O commit posterior mudou somente documentação.




## Atualização — exclusão de campanha e Storage

- O fluxo real é em duas fases: preparar (campanha → marcador cleanup), remover Storage no navegador, finalizar (marcador → campanha). O marcador bloqueia novos uploads em `midia` e permite ao proprietário retomar remoções; não existe progresso por arquivo nem worker automático.
- Nova inversão de locks entre preparação e finalização documentada; o harness agora reproduz campanha → cleanup versus cleanup → campanha. CI #212 [42744027422](https://github.com/clubberblues/rpgvinculo/actions/runs/42744027422) passou com nove inversões sintéticas + controle positivo.
- Snapshot Storage: 44 objetos órfãos em bucket público `midia` (33 caminhos de campanha e 11 capas), sem campanha correspondente; zero objetos encontrados em `mesa-media` sob esses prefixos e zero marcadores cleanup pendentes. Não foi feita limpeza.
- O finalizador não valida a ausência de objetos Storage antes de apagar a campanha. A origem dos órfãos não está provada; inventariar e classificar antes de qualquer exclusão.





## Atualização — divergência de limpeza entre lobby e mesa

- Corrigido no branch: a exclusão pelo lobby agora lista/remove arquivos de `midia` e `mesa-media`, além das capas; a mesa já fazia a limpeza nos dois buckets.
- `scripts/check-static.mjs` agora valida esse contrato para evitar regressão.
- Snapshot atual: `mesa-media` existe, é privado e está vazio. O bug não deixou arquivos privados órfãos observáveis nesta consulta.
- Risco restante de banco: o RPC finalizador não exige que `storage.objects` esteja vazio; chamada direta autenticada pode pular a limpeza. O marcador bloqueia writes no bucket `midia`, mas não no `mesa-media`, cuja política atual apenas exige papel GM. A solução precisa fechar o upload/update privado durante o marcador e validar os prefixos vazios no finalizador.
- Os 44 arquivos públicos órfãos totalizam 55.708.560 bytes (~53,1 MiB), criados entre 20/10 e 03/11/2026. Não houve remoção.





## Atualização — bucket privado CBA

- Corrigido no lobby o percurso de limpeza para incluir `mesa-media`; validador estático exige coleta e remoção de ambos os buckets.
- CI #11 (static), #220 (PostgreSQL fixtures) e #59 (syntax) passaram no commit `31882ee88881e5cc335b35f4de0e5544fe4e1661`.
- Nova falha confirmada no banco: `priv.pasta_gm` testa o primeiro segmento do path como numérico, mas o frontend usa `campaigns/{id}/...`; `storage.foldername` retorna `['campaigns','{id}']`, então a política atual nega operações para esse path.
- A política SELECT usa `public.can_read_media`, dependente de linha em `public.media`; a tabela e `public.layers` estão vazias e não há trigger de Storage que crie esses metadados. O CBA faz upload e cria signed URL sem inserir `public.media`.
- O contrato de Storage privado precisa de revisão integrada (path, GM, membros/visibilidade, marcador de exclusão, upload, signed URL e remoção). Nenhuma policy ou função de produção foi alterada.




## Especificação formal — Storage privado CBA

- Criado `docs/STORAGE_ACCESS_CONTRACT.md` com path canônico, matriz GM/jogador/externo, autorização durante exclusão, validação final sem objetos, signed URLs e 12 testes de integração.
- Corrigida a descrição das policies: INSERT/UPDATE/DELETE usam `priv.pasta_gm`; SELECT usa `public.can_read_media`. A função de escrita rejeita `campaigns/{id}/...` porque interpreta o primeiro segmento como ID numérico; a leitura exige metadados ausentes em `public.media`.
- Snapshot de integridade: 3/3 donos das campanhas também constam em `public.members` como GM; a especificação ainda exige autorização explícita do owner ou teste formal da invariável.
- Nenhuma policy, função ou dado de produção foi alterado. Próxima dependência é reconciliação de migrations e teste Storage/RLS real antes de qualquer aplicação.



## Compensação de uploads CBA privados

- `mesa.html` agora tenta remover pela Storage API um asset recém-enviado se a criação da signed URL falhar antes de gravar a cena.
- A compensação não apaga arquivos após falha do RPC de gravação, pois o resultado de uma falha de rede pode ser ambíguo. Também não remove imediatamente assets antigos ao trocar mapa/retrato: outra aba pode ainda referenciá-los.
- GC atrasado, com varredura de `backgroundPath` e `tokens[].imagemPath`, janela de retenção e teste de concorrência permanece necessário.
- O validador estático exige a função de compensação e sua chamada. CI do commit `e8d08c72fd8923ec54ce017700cae9fd3fc89d82` está em execução; ainda não registrar como aprovado até concluir.
- A compensação depende de policy DELETE Storage corrigida: a policy atual usa `priv.pasta_gm`, que rejeita o path `campaigns/{id}/...`. Nenhuma policy de produção foi alterada.


## Atualização — Storage privado e finalização de campanha (2026-11-10)

- Confirmado read-only no banco remoto: policies de mesa-media usam priv.pasta_gm para INSERT/UPDATE/DELETE, mas o frontend grava em campaigns/{id}/...; o helper interpreta o primeiro segmento como ID numérico e rejeita esse caminho. SELECT usa public.can_read_media e exige registro em public.media, ausente para os assets CBA atuais. Portanto, upload, assinatura/leitura e remoção de assets CBA não têm contrato compatível no snapshot atual.
- Confirmados OIDs e grants: preparar (wrapper 24881 / impl 24885) e finalizar (wrapper 24882 / impl 24886) são executáveis por authenticated, não anon. Preparação bloqueia campaign → cleanup; finalização bloqueia cleanup → campaign. A ordem está invertida.
- O finalizador não verifica storage.objects nem exige que os objetos e capas tenham sido removidos. O proprietário pode chamar diretamente após preparar e excluir a campanha deixando objetos órfãos; resposta deleted=true não comprova limpeza do Storage.
- Contrato, matriz de autorização, integração Storage API, compensação de upload e esses novos achados foram consolidados em docs/STORAGE_ACCESS_CONTRACT.md. Commit documental: c97e36a8d3ad9a8852e85b861d1a22cae2468949.
- Nenhuma RPC foi chamada; nenhuma migration, função, ACL, policy, dado ou arquivo Storage de produção foi alterado. TESTE 2 permanece intocado.
- Próxima unidade: fechar o contrato transacional do finalizador (campaign → cleanup, revalidação, Storage zero-check e retry), mapear concorrência upload/finalização e desenhar testes Storage API autenticados em projeto descartável. Não implantar até reconciliar migrations.
