# Vínculo RPG — item de trabalho ativo

## Estado consolidado — 2026-11-10

- Frente ativa: auditoria read-only de concorrência/ordem de locks dos fluxos AOO, ficha, magia, recursos de classe e ataques iterativos.
- Branch: `audit/lock-order-rage-removal-2026-11-09`.
- PR #74: [docs: auditar inversões de locks em AOO, conjuração e ataques iterativos](https://github.com/clubberblues/rpgvinculo/pull/74), aberto, draft, não mesclado. Head atual: acompanhar diretamente no PR #74.
- O PR inclui documentação de auditoria, fixtures SQL descartáveis e alterações anteriores de frontend/validação. Arquivos principais: `docs/ACTIVE_WORK_ITEM.md`, `docs/AUDIT_REGISTER.md`, `docs/CBA_MUTATION_INVENTORY.md`, `docs/GM_ENDPOINT_AUDIT_2026-11-10.md`, `docs/LOCK_ORDER_PROTOCOL_DRAFT.md`, `docs/LOCK_ORDER_REFACTOR_PLAN.md`, `docs/MIGRATION_RECONCILIATION.md`, `docs/MOVEMENT_AOO_AUTHORITY_GAP.md`, `docs/ROADMAP.md`, `docs/STORAGE_ACCESS_CONTRACT.md`, `lobby.html`, `mesa.html`, `scripts/check-static.mjs` e `tests/sql/*`.
- CI PostgreSQL #72 [42730159992](https://github.com/clubberblues/rpgvinculo/actions/runs/42730159992) concluiu success na versão anterior do harness. CI #100 [42731471362](https://github.com/clubberblues/rpgvinculo/actions/runs/42731471362) concluiu success no commit `dd38946efd5cd9ef58ec8ef33b492227793141e7`: footprint helper, oito inversões, controle positivo, TOCTOU reproduzido (owner final player-c, dois GM) e controle campaign-first (segunda transferência rejeitada, owner final player-b, um GM). Commits posteriores só alteraram documentação; fixtures SQL não mudaram.
- O harness tem oito padrões sintéticos de inversão + um controle positivo, além de dois cenários sintéticos de transferência de Mestre (reprodução TOCTOU e controle campaign-first). CI #100 passou em todos; os cenários são transacionais sintéticos, não executam RPCs, triggers nem dados de produção.
- Ciclos potenciais confirmados por corpos instalados: PC Ataque Total arma→campanha versus resolução campanha→tentativa/sequência/arma; NPC sequência→campanha versus campanha→tentativa/sequência; AOO ataque→pending→campanha versus transição campanha→ataque→pending; AOO pending→campanha em início/finalização; ficha/recurso→campanha em estabilização, conjuração multialvo, Míssil Mágico manual (wrapper OID 25191), cura multialvo (wrapper OID 24661) e habilidades específicas; outras magias manuais single-target (OID 24658) seguem personagem→campanha→ficha.
- Precisões relevantes: descanso longo PC não bloqueia campanha (personagem → leitura de estado sem lock → ficha → recursos/condições), logo o defeito é corrida de estado, não deadlock; estabilização bloqueia personagem → ficha → campanha; Imposição das Mãos contra mortos-vivos bloqueia personagem → ficha → recurso → campanha; habilidade de classe tem ordem variável por branch; resolução de salvamento altera condição diretamente sem lock explícito de campanha no branch condition_break.
- AOO: RPCs autenticadas e OIDs documentados na matriz em LOCK_ORDER_PROTOCOL_DRAFT.md; dano AOO contra personagem bloqueia ataque → pending → campanha → ficha. Interseção com estabilização pode formar ciclo na mesma ficha. O bloqueio P1 de movimento inclui também `salvar_cena_cba` (OID 20077), writer geral de `cba_data` com authenticated EXECUTE que pode alterar coordenadas sem detector AOO; a guarda atual só bloqueia quando já existe pending. Foi ainda confirmado estaticamente que o ramo `p_follow=true` do Encontrão pode ser rejeitado pelo mesmo trigger, pois move o token mover sem definir o GUC de commit. O trigger só protege o token mover (por `id`/`key`), não congela tokens ameaçadores nem atributos que alteram ameaças; `salvar_cena_cba` mescla por OR entre `id` e `key`, sem garantir identidade única/imútavel. A fixture aoo_guard_duplicate_identity_repro.sql reproduz o bypass: duplicar id/key, manter a primeira cópia na origem e deslocar a segunda passa pelo LIMIT 1; também reproduz mudança de coordenadas do token ameaçador durante pending.
- CI no HEAD `041f0b5c3dd7c132b57ba6611a423bb26965e9eb`: Static validation #84, aplicação JS #132, mesa JS #387 e PostgreSQL fixture #293 [42751317308](https://github.com/clubberblues/rpgvinculo/actions/runs/42751317308) concluídos **success**. Log do fixture #293 repetiu a reprodução de duplicata e mutação de outro token durante pending. Os testes continuam sintéticos e não executam RPCs remotas.
- Reproducer isolado da guarda AOO adicionado em `tests/sql/aoo_guard_duplicate_identity_repro.sql` e integrado ao harness. GitHub Actions #284 [42751013687](https://github.com/clubberblues/rpgvinculo/actions/runs/42751013687) e #285 [42751022904](https://github.com/clubberblues/rpgvinculo/actions/runs/42751022904): **success**. Log confirmou: movimento direto do único mover bloqueado; metadados permitidos; duplicata de identidade com segunda cópia deslocada persistida; coordenada de token ameaçador alterada durante pending. A fixture copia o algoritmo do trigger e reproduz a vulnerabilidade; não executa RPC/trigger real do Supabase.
- Novo P1 estático: `salvar_cena_cba` preserva duplicatas de id/key via UNION ALL; o guard AOO usa LIMIT 1 sem validar cardinalidade. Ordenando primeiro a cópia na origem e depois a cópia deslocada, a alteração pode escapar da comparação e depois bloquear finalização por token duplicado. Rejeitar duplicidade em todos os writers de CBA.
- A divergência Colossal=5 também está em endpoints ativos: aplicar_dano_token_ataque_srd_v2 OIDs 24744/25562 (ataque físico, overload 25562 com callsite mesa.html) e usar_imposicao_maos_mortos_vivos_srd OID 25509 (toque, callsite mesa.html). Ambos autenticados, sem helper canônico; detector/helper usam 6. Corrigir footprint centralmente em movimento, AOO, ataque e toque.
- Nova lacuna mecânica P1: pending.threats guarda apenas faixas/source, sem identificar instâncias de arma. `srd_consultar_armas_aoo_srd` (OID 27044) lista armas equipadas atuais e `srd_iniciar_ataque_oportunidade_srd` (OID 27022) revalida apenas o estado atual, não a arma presente no snapshot. Como equipar/desequipar pode ocorrer durante pending, é possível invalidar ou criar elegibilidade de arma depois do gatilho. Fixar snapshot de instâncias e parâmetros ou bloquear alteração até terminalidade.
- Nova dependência crítica do snapshot AOO: o detector (OID 26923) deriva ameaças de posição/tamanho/facção/alcance, armas equipadas (`srd_character_weapon_instances` + `srd_character_equipment`), ataques naturais e Monge/Ataque Desarmado Aprimorado. `equipar_item_srd` (OID 20555) e `entregar_item_srd` (OID 20556) podem alterar essas fontes sem lock de campanha/pending; o resolver revalida arma equipada. Política de congelamento ou invalidação/recalculo do pending ainda precisa ser definida.
- A proposta de ordem é parcial por domínio, não hierarquia global. Direção preferida para mutações de campanha: localizar IDs via leitura MVCC, lock de campanha, revalidar vínculo/autoridade/estado/round, então bloquear personagem/ficha/recurso/pending/attack conforme o contrato específico. Plano faseado não aprovado para deploy: [LOCK_ORDER_REFACTOR_PLAN.md](LOCK_ORDER_REFACTOR_PLAN.md). Ordem final de AOO e interseções de arma/ledger ainda precisam ser fechadas.
- public.gm_transfer (OID 18749) foi classificada como endpoint autenticado legado com corrida TOCTOU potencial em chamadas concorrentes; sem call site direto localizado nas páginas principais. Fixture sintético novo modela a corrida e o controle corrigido. A varredura dos writers authenticated de campaigns não encontrou outro writer sem lock direto/herdado; create_campaign insere nova linha e adicionar_token_cba_completo herda lock do helper.

- Atualização do bloqueio de movimento/AOO: CI no commit `fc2f008e59e980305990e9083058f2b2e76c7750` — Static validation #62, aplicação JS #110 e mesa JS #365 concluídos **success**; PostgreSQL fixture #271 [42749952496](https://github.com/clubberblues/rpgvinculo/actions/runs/42749952496) concluído **success**. Os commits posteriores até o HEAD atual alteraram somente documentação; a fixture testada permaneceu inalterada. Nenhum teste executou RPCs Supabase reais.
- Neste bloco de trabalho não houve alteração de função, migration, ACL, policy ou dado no Supabase, nem acesso ao TESTE 2. O PR mantém alterações anteriores em `lobby.html`, `mesa.html` e `scripts/check-static.mjs`; não foram feitas novas alterações nesses arquivos durante esta rodada. Nenhum deploy remoto.
- Recuperação/reconciliação do ledger concluída no GitHub: supabase_migrations.schema_migrations preserva statements[1] para as 966 versões. A pasta supabase/migrations agora contém 966 arquivos, todos byte a byte idênticos ao ledger; zero versões remotas ausentes e zero migrations locais pendentes. As 103 variantes locais divergentes foram preservadas em docs/migration_reconciliation/local_variants/; 41 arquivos sem versão remota foram preservados em docs/migration_reconciliation/unapplied_local/. Entre os 103, 13 diferenças semânticas foram identificadas e arquivadas; as outras 90 eram diferenças de comentário/formatação/casts/terminadores. Nenhuma migration foi aplicada no Supabase. Detalhe em MIGRATION_RECONCILIATION.md.
- Baseline de migrations reconciliado byte a byte: 966 arquivos locais correspondem às 966 versões remotas. As variantes divergentes e migrations não aplicadas foram arquivadas, sem descarte. Antes de criar/aplicar nova migration, validar a reprodução do schema completo em ambiente local descartável; o repo ainda não possui supabase/config.toml e não há branch Supabase descartável (criação pode gerar custo).

## Próxima unidade de trabalho

1. Fechar o contrato comum de autoridade para toda mudança de coordenadas em `campaigns.cba_data`: wrappers diretos de movimento, `salvar_cena_cba` e demais writers; distinguir alterações de posição de atualizações legítimas de metadados e fechar identidade estável do token.
2. Fechar grafo transitivo de todos os writers que alteram campanha, ficha, pending, ataque, ledger, recurso, condição e log; separar lock adquirido diretamente, lock herdado e leitura MVCC.
3. Reconciliar cada caminho com call sites de frontend e grants efetivos, distinguindo endpoints ativos, wrappers, helpers e legado.
4. Elaborar sequência de refatoração por fatias (AOO, ataque iterativo PC/NPC, ficha/magia/recursos), com pré-condições, revalidação pós-lock, idempotência, rollback e testes de integração descartáveis.
5. Estender testes apenas quando reproduzirem um contrato transacional específico; manter os cenários sintéticos identificados como tais.
6. Não aplicar migration, alterar funções remotas, ACL/policies ou dados até reconciliação de migrations e teste de integração autenticado em ambiente descartável.

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


## Atualização — contrato de concorrência Storage/cleanup (2026-11-10)

- Refinado o risco: verificar apenas ausência do marcador na policy não impede upload que já passou na checagem de autorização de confirmar depois da limpeza. O caminho de INSERT/UPDATE precisa manter campaign KEY SHARE durante a transação Storage; preparação/finalização usam campaign FOR UPDATE antes do marcador. Assim, upload anterior termina antes de o marcador ser criado; upload posterior espera e observa o marcador.
- Documentado o contrato em docs/STORAGE_ACCESS_CONTRACT.md. Adicionado modelo descartável PL/pgSQL VOLATILE + tabela fictícia em tests/sql/lock_cycle_setup.sql e duas interleavings concorrentes no lock_cycle_test.sh; README deixa explícito que não executa RLS nem Storage API real.
- Commits desta unidade: c97e36a8d3ad9a8852e85b861d1a22cae2468949 (finalizador/bypass), dbd6580f24ce895cced69d70596d48418d7ea3c1 (lock handshake), dded40b0b2c3626badbf6b0d74d4a7ba67f97678 (setup fixture), bfa6c1d223a515811fe675f50b35fe5287f1164f e 7ca8e00fe55fc6530642fc2099d3c392a0b6033d (teste), 054d8b92a7f928937ead19ee08ed25eac95900cb e 2df3a62565d36ef470208566fa610d6fbe597ba5 (documentação).
- A fixture testa apenas a semântica de locks PostgreSQL em tabelas descartáveis. Não executa Storage API, RLS, RPCs ou bucket real; integração autenticada continua bloqueadora antes de migration/deploy.
- Nenhuma alteração Supabase foi aplicada. TESTE 2 permanece intocado.


## Atualização — zero-check e retry do finalizador (2026-11-10)

- Ampliado o modelo SQL descartável para incluir owner_id na campanha e uma função-modelo de finalização que bloqueia campanha → cleanup, revalida proprietário/marcador, exige Storage vazio e preserva campanha+marcador se ainda houver objetos.
- Adicionado teste de três resultados: proprietário incorreto rejeitado; objeto restante impede exclusão e preserva estado para retry; após remoção do objeto, retry conclui.
- Documentação atualizada em docs/STORAGE_ACCESS_CONTRACT.md e tests/sql/README.md. Commits: 55ee0dd6442e108ef89fa726cecb29ee5d1c8461, 2913e395ad73465a45b9d1e3b38cdc868cf50b60, f3ec4daef3752c7ffbff23bf6f49ecd633e08a2a, d4537d0567ed6a70c641004665643afbd0a3a2c8, 4027bcb46c5956802d1e579cad7ac046e61b2fc8.
- A fixture ainda é somente modelo de semântica transacional; não consulta `storage.objects`, não usa RLS/Storage API e não executa RPC de produção. Teste real em ambiente Supabase descartável continua necessário.
- Nenhuma alteração foi aplicada ao projeto Supabase de produção, nenhum arquivo Storage foi apagado e a campanha TESTE 2 continua intocada.


## Atualização — algoritmo remoto de finalização (2026-11-10)

- Releitura integral da implementação remota confirmou: finalizador atual bloqueia cleanup → campaign; se campanha não existir, remove marcador e retorna `deleted: true` sem checar Storage. O algoritmo proposto agora especifica campaign → cleanup, valida owner nos dois estados, verifica os três prefixos de Storage (`midia/campaigns/{id}/`, `mesa-media/campaigns/{id}/`, `midia/capas_mesas/mesa-{id}-`) e só retorna sucesso com zero objetos.
- Idempotência definida: se campanha estiver ausente, marcador válido ainda precisa ser verificado; zero objetos permite remover marcador residual, mas qualquer objeto preserva marcador e impede sucesso. Sem campanha, nenhum upload novo deve ser autorizado.
- Detalhes adicionados em docs/STORAGE_ACCESS_CONTRACT.md. A proposta não foi aplicada ao banco remoto.


## Atualização — fidelidade do modelo de retry (2026-11-10)

- Corrigido um desvio no modelo: no banco real, `priv.campaign_deletion_cleanup` não possui FK para `campaigns`, e Storage é independente da transação/vida da campanha. As tabelas descartáveis agora também não usam essas FKs.
- A função-modelo agora admite campanha ausente somente após tentativa de lock/leitura da campanha, valida o marcador residual, verifica objetos órfãos e limpa o marcador apenas com Storage vazio.
- Teste ampliado: campanha ausente + marcador residual + objeto Storage órfão deve falhar mantendo marcador; depois da remoção do objeto, retry deve concluir. Isso cobre o caminho de idempotência sem mascarar objetos abandonados.
- Commits: `0b12d60cc4956c4ba96b6478106e96b4aa720ae8`, `aee5738080999817b187490dfb6689046a3b45a9`, `fb0b9829052182c2813fb48419c9d303826ae1fc`, `70a4d40826c2e7574bf59b75c0e826ed27a73531`, `320e9ac65ba755396d94ceda0c68e223dc7b1e7c`.
- Ainda é fixture PostgreSQL sintética; nenhum endpoint remoto, RLS ou Storage API foi executado. Nenhuma mudança de produção.


## Atualização — contrato Storage e operações de leitura (2026-11-10)

- Consulta à documentação oficial atual do Supabase Storage confirmou que bucket privado aplica RLS no download e oferece download autenticado ou signed URL temporária. SELECT deve ser analisado por operação: listagem, leitura autenticada e autorização para assinar URL não são necessariamente o mesmo acesso; helper `storage.allow_only_operation()` / `allow_any_operation()` permite separar operações.
- Adicionada matriz de testes distintos para `createSignedUrl`, `download` com JWT, `list` (GM apenas se necessário), caminho de outra campanha e objeto ausente. Fonte: `docs/STORAGE_ACCESS_CONTRACT.md` com links oficiais.
- Modelo SQL corrigido para não criar FKs artificiais entre campanha, marcador de cleanup e objeto Storage. O teste cobre marcador residual com campanha ausente e objeto órfão; finalização deve continuar negada até remoção do objeto.
- Ainda não há integração real com Storage API; sem custo adicional ou branch Supabase pago. Nenhuma mudança de produção.


## Atualização — coordenador confiável de exclusão Storage (2026-11-10)

- Auditoria da documentação oficial do Supabase identificou uma limitação importante: `storage.objects` é metadado, não inventário dos bytes no provedor. SQL zero-row check não prova sozinho que o bucket físico está vazio; modificar/apagar linhas diretamente não remove bytes e é expressamente desaconselhado.
- Proposta corrigida: Edge Function coordenadora autenticada pelo proprietário, com service_role somente em secret server-side, pagina e remove todos os objetos via Storage API, repete a listagem até vazio e só então chama finalizadora interna. A RPC mantém zero-check de metadados como defesa em profundidade. `EXECUTE` da finalizadora deve ser revogado para PUBLIC/anon/authenticated e concedido somente ao canal interno necessário; cliente não chama diretamente.
- Código upstream atual `storage/src/storage/uploader.ts` mostra preflight de permissão, gravação dos bytes e autorização final na transação de metadados; o lock de campanha precisa ser obtido na autorização final, não apenas no preflight. Em caso de falha de autorização final, código tenta remover o objeto físico. Confirmar isso com a versão hosted e teste real antes de confiar na garantia.
- Especificação detalhada em `docs/STORAGE_ACCESS_CONTRACT.md`. Nenhum Edge Function foi criado/deployado; nenhuma ACL, RPC, migration, policy ou dado de produção alterado.


## P1 confirmado — autoridade do movimento/AOO (2026-11-10)

- Nova leitura somente de catálogo do Supabase confirmou que os endpoints autenticados de movimento direto do jogador (OID 20522 / implementação 27366) e do Mestre (OID 21615 / implementação 27306) não chamam o detector AOO nem a RPC que cria movimento pendente.
- O frontend atual chama primeiro `srd_solicitar_movimento_com_aoo_srd` nos fluxos de jogador (mesa.html:2313) e Mestre (mesa.html:5414), mas isso é uma sequência de cliente, não uma garantia do servidor. Os endpoints diretos continuam EXECUTE authenticated. O trigger bloqueia deslocamento quando já há pending; não obriga criar pending antes do primeiro movimento.
- O helper canônico `priv.srd_token_grid_footprint` (OID 27073) retorna 6 para Colossal. As duas implementações de movimento retornam 5; detector AOO retorna 6. A mesma regra de footprint está duplicada e divergente.
- Evidência e contrato de correção: [MOVEMENT_AOO_AUTHORITY_GAP.md](MOVEMENT_AOO_AUTHORITY_GAP.md).
- Próxima implementação prioritária: unificar solicitação/detecção/commit no servidor para jogador e Mestre, preservando o pending AOO, e substituir os CASEs duplicados pelo helper canônico. Antes de codificar, fechar a ordem parcial de locks com pending/attack/ficha e criar testes descartáveis que exercitem chamada direta e concorrência.
- Não foi executada nenhuma RPC de jogo, nem alteração no Supabase. Não tocar TESTE 2. A reconciliação do histórico de migrations continua bloqueando migration/deploy em produção. O replay dos 966 arquivos em Supabase local descartável falhou antes da primeira migration: public.campaigns não existe no banco vazio; os arquivos versionados são incrementais pós-bootstrap. O harness PostgreSQL integral no commit 1b1a85d (run 42808666665) passou, reproduzindo deliberadamente o bypass de identidade duplicada e a mutação de geometria do ameaçador; isso não valida RPCs reais. Falta recuperar e versionar o schema-base real e a ordem dos scripts legados, sem inventar uma base mínima.


- **Nova confirmação read-only no catálogo Supabase (2026-11-10):** as funções AOO não compartilham ordem de locks. `srd_resolver_ataque_oportunidade_srd` OID 27025 e `srd_registrar_ocultacao_ataque_oportunidade_impl` OID 27254 bloqueiam attack → pending → campaign; `srd_reservar_reacao_movimento_aoo_impl` OID 27256 e `srd_resolver_encontrao_srd` OID 27169 bloqueiam pending → campaign. Solicitação/finalização são campaign-first. Isso confirma inversão estrutural e risco de deadlock, sem demonstrar deadlock ocorrido. Protocolo e regressões atualizados em `docs/LOCK_ORDER_PROTOCOL_DRAFT.md`.


### Atualização — inventário ampliado de writers CBA (2026-11-10)

- Consulta read-only a `pg_proc` identificou um conjunto mais amplo de funções que atualizam `campaigns.cba_data`: movimento direto GM/jogador (OID 27306/27366), salvamento geral (20077), spawn completo de token (21726), configuração de facção/alcance (26922), avanço de turno (20074), ataques físicos v2 (24744/25562), Imposição das Mãos (25509), finalização AOO (27038) e Encontrão (27169), além de escritores de PV/equipamento/efeitos.
- Nem toda referência a `gridX/gridY` é escrita geométrica; é necessário classificar os diffs efetivos de cada corpo. Entretanto, escritores de cena/perfil/spawn sem referência a pending no corpo não podem ser presumidos seguros apenas porque o trigger atual existe.
- O trigger é o único trigger de `campaigns.cba_data` encontrado. A arquitetura precisa fechar o conjunto de writers, centralizar autorização e freeze/invalidação atômica das dependências AOO. A ACL interna `priv.*` precisa ser analisada junto com exposição de schema e wrappers públicos; `has_function_privilege` isolado não prova exposição PostgREST.
- Detalhes em `docs/MOVEMENT_AOO_AUTHORITY_GAP.md`. Consultas somente leitura; nenhuma RPC/migration/ACL/registro de produção alterado.


### Atualização — ACL do schema interno `priv` (2026-11-10)

- Catálogo remoto confirmou USAGE do schema `priv` para authenticated e EXECUTE authenticated em implementações internas `SECURITY DEFINER` (incluindo OIDs 27306, 27366 e 27169). Isso amplia a superfície SQL autenticada e requer revisão urgente de grants. Não foi possível confirmar nesta sessão se `priv` está incluído nos schemas expostos pelo PostgREST; `pgrst.db_schemas` não apareceu em `pg_settings`. Não declarar endpoint REST explorável sem essa confirmação.
- Proposta: remover USAGE/EXECUTE de papéis cliente do schema interno após inventariar dependências, mantendo wrappers públicos controlados. Nenhuma ACL alterada. Detalhes em `docs/MOVEMENT_AOO_AUTHORITY_GAP.md`.

- **Refinamento do grant `priv`:** não revogar USAGE em bloco agora. Foram encontrados diversos wrappers públicos `SECURITY INVOKER` que chamam `priv.*` diretamente (movimento jogador/GM, manobras e outras rotas de combate); revogar USAGE/EXECUTE quebraria essas jornadas. Primeiro inventariar e migrar com segurança os wrappers (incluindo search_path, ownership e autorização), depois restringir schema/ACL e executar regressão abrangente. Nenhuma alteração de ACL.


### Atualização — dimensão da migração de privacidade do schema (2026-11-10)

- Catálogo remoto: 70 funções internas `priv.*` distintas são chamadas por funções públicas; 35 funções públicas distintas são `SECURITY INVOKER` e chamam `priv.*`, com EXECUTE authenticated. Uma consulta anterior retornou 40 linhas de chamada, pois algumas assinaturas fazem múltiplas chamadas internas.
- O problema de grants não é restrito ao movimento/AOO: envolve ataque iterativo NPC, dano, avanço de nível, ações, descanso e outras rotas. Não é seguro revogar USAGE/EXECUTE nem converter wrappers em lote.
- Próxima entrega: matriz exata por assinatura/owner/search_path/grants/dependências e plano de migração individual dos wrappers, com testes de chamadas diretas negadas e fluxos públicos preservados. Detalhes em `docs/MOVEMENT_AOO_AUTHORITY_GAP.md`. Nenhuma mudança remota.

- Contagem adicional de ACL: 40 funções/procedimentos em `priv` têm EXECUTE authenticated (39 SECURITY DEFINER); uma função (`priv.srd_feat_saving_throw_modifier`, OID 26355) também é executável por anon devido a grant PUBLIC. É helper SQL STABLE de cálculo de modificador passivo, sem mutação aparente; classificar se a exposição é intencional. `authenticated`/`anon` não têm CREATE nos schemas public/priv. Nenhuma ACL alterada.

- As 94 funções `priv.*` identificadas têm owner `postgres` (88 SECURITY DEFINER). Entre seis helpers invoker, cinco não são executáveis por authenticated/anon; `priv.srd_parse_natural_attack_list(text)` (OID 27228) é executável por authenticated e serve a wrapper público de ataques naturais. `current_setting('pgrst.db_schemas',true)` e db_extra_search_path retornaram NULL: schema REST exposto segue não confirmado. Nenhuma exploração REST foi demonstrada.


### CI e regressão de privilégios — 2026-11-10

- HEAD `e32716894d3388478d416e63a31926a811810395` no PR #74: validação estática, JavaScript da aplicação e JavaScript da mesa passaram; PostgreSQL fixtures #351 passou.
- O replay das 966 migrations #26 falhou antes de executar qualquer migration, porque o bootstrap local não cria `public.campaigns`; a primeira migration tenta criar função que referencia essa tabela. O job não chegou à etapa de replay/validação de objetos.
- Os fixtures aprovados incluem helpers de footprint e reproduções sintéticas de inversões de locks, corridas de autorização e bypass de identidade AOO. Os logs mostram deadlocks/violações de autorização intencionais nos cenários de reprodução, seguidos de controles campaign-first que rejeitam as operações obsoletas. Isso valida os fixtures isolados, não prova que as RPCs remotas estejam corrigidas nem que houve deadlock em produção.
- Nova verificação do catálogo confirmou que `public.srd_consultar_modificadores_manobra_srd` (OID 27119) e `public.srd_listar_ataques_naturais_oportunidade_srd` (OID 27229) são invoker com EXECUTE authenticated, mas tentam chamar `priv.srd35_maneuver_profile` (OID 26884), sem EXECUTE authenticated; a primeira também chama helpers de footprint sem EXECUTE authenticated. Forte indicação de falha funcional nessas duas rotas; precisa confirmação por chamada autenticada controlada. Detalhes e correção proposta em `docs/MOVEMENT_AOO_AUTHORITY_GAP.md`.
- Nenhuma função, ACL, migration, trigger, campanha ou dado de produção foi alterado.


### Remediação focalizada de wrappers invoker (2026-11-10)

- Causa confirmada nas migrations originais: os wrappers de contexto de Derrubar (sobrecarga de 6 args) e catálogo de ataques naturais foram criados SECURITY INVOKER, mas dependem de helpers privados sem EXECUTE para authenticated.
- Consulta catalogal refinada encontrou exatamente duas funções públicas invoker com dependência direta sem EXECUTE para authenticated entre as funções analisadas: `srd_consultar_modificadores_manobra_srd(..., boolean, boolean)` (falha no ramo trip/Derrubar) e `srd_listar_ataques_naturais_oportunidade_srd(bigint,text)` (falha sempre ao buscar perfil). Encontrão usa a sobrecarga de 5 args SECURITY DEFINER; não generalizar o defeito para toda consulta de manobra.
- Migration aditiva preparada na branch: `supabase/migrations/20261110150000_fix_invoker_maneuver_catalog_helper_permissions.sql`. Altera somente SECURITY INVOKER → DEFINER nas duas assinaturas, preserva o search_path fixo e restringe EXECUTE a authenticated/service_role; as duas funções mantêm verificações explícitas de autenticação e papel GM.
- Verificação pós-migration: `supabase/verification/verify_maneuver_catalog_rpc_security.sql`.
- **Não aplicada em produção.** Exigir validação SQL pós-migration e testes autenticados negativos/positivos antes de deploy.

### Endurecimento focalizado de EXECUTE (2026-11-10)

- Migration `20261110150000_fix_invoker_maneuver_catalog_helper_permissions.sql`: corrige as duas RPCs GM que dependem de helpers `priv.*` sem EXECUTE authenticated, convertendo-as para SECURITY DEFINER com owner postgres, search_path fixo e guards auth.uid()/GM preservados.
- Migration `20261110160000_revoke_public_feat_saving_throw_helper.sql`: remove EXECUTE herdado de PUBLIC/anon de `priv.srd_feat_saving_throw_modifier(jsonb,text)`; mantém o grant existente de authenticated e service_role nas RPCs GM (sem acrescentar grants novos); o helper passivo mantém authenticated/service_role. O único chamador SQL catalogal identificado é o motor interno SECURITY DEFINER `priv.srd_saving_throw_bonus`; grants explícitos a authenticated/service_role foram preservados.
- Verificações: `verify_maneuver_catalog_rpc_security.sql` e `verify_passive_feat_helper_acl.sql`.
- Fixture isolado `tests/sql/maneuver_catalog_security_fixture.sql` aplica ambas as migrations e testa chamadas GM positivas, jogador negativo, anon negativo e chamadas internas do motor. Workflow PostgreSQL atualizado para executar o fixture.
- Estado: branch apenas; sem alteração remota. Aguardar CI e depois regressão autenticada real antes de implantação.

### Superfície EXECUTE de helpers internos — ampliação (2026-11-10)

- Identificados helpers SECURITY DEFINER sem guarda de usuário executáveis diretamente por authenticated: `srd_condition_has_flag`, `srd_feat_saving_throw_modifier`; parser puro `srd_parse_natural_attack_list) também não precisava de execução cliente.
- Revogação proposta de EXECUTE authenticated/anon/PUBLIC nesses helpers, mantendo service_role, porque os consumidores SQL identificados são funções SECURITY DEFINER/triggers.
- Helpers iterativos de ataque de 7/8 argumentos deixaram de ser API cliente. Wrappers públicos 7/8 foram convertidos em SECURITY DEFINER, com search_path fixo e checagem de usuário, propriedade da ficha e membership PLAYER antes de chamar os helpers.
- O helper de 7 argumentos também recebeu checagem redundante de propriedade antes de ler/bloquear arma.
- Fixture e verificação atualizados. Estado permanece branch-only; CI e regressão real autenticada ainda pendentes.


## Atualização de execução — 2026-11-10 (segurança de helpers e CI)

- Head da branch no fechamento desta atualização: `baa126724cdb2dc641197ace28458fea9ccdf29f`.
- PR #74 permanece aberto, draft e não mesclado.
- A branch contém 969 migrations: 966 correspondem exatamente ao ledger remoto e três candidatas novas (1500/1600/1700) permanecem não aplicadas.
- O workflow de replay foi ajustado para derivar a contagem de migrations do diretório. O replay integral continua bloqueado pela ausência do bootstrap/schema-base anterior às migrations incrementais; não criar schema mínimo fictício.
- No CI do commit `d35f8f4`, validação estática, JavaScript da aplicação e JavaScript da mesa passaram. A fixture PostgreSQL falhou por uma asserção textual incorreta (`FROM public.members` em vez de `JOIN public.members`); a verificação foi corrigida e reforçada para validar ownership, campaign_id, papel PLAYER e search_path do helper interno.
- A fixture foi ampliada para negar acesso ao helper por authenticated, negar ficha alheia, campanha incorreta, identidade de usuário incorreta e ausência de membership PLAYER, mantendo um controle positivo de service_role para ficha própria.
- Commits posteriores foram gravados pela API do GitHub, mas não há Actions run associado ao head atual. Portanto, essas correções ainda não têm resultado de CI confirmado; o run antigo não é evidência de validação do head atual.
- Nenhuma migration, ACL, função, policy, dado ou campanha foi alterada no Supabase remoto. Não houve deploy ou merge.


### Diagnóstico da fixture PostgreSQL — 2026-11-10

- Run #42890392296 no commit `635bdf1` falhou porque os scripts de migration executados pela fixture fazem `COMMIT`, encerrando a transação externa iniciada no começo do arquivo. Claims configurados com `set_config(..., true)` depois disso expiravam ao fim de cada instrução. O preflight mostrou ambos `auth.uid()` e `my_role()` nulos, causando a mensagem GM.
- A fixture foi corrigida para abrir uma nova transação após aplicar/verificar as migrations e antes de configurar os claims. A correção está no commit `c21490e`; ainda sem CI confirmado.
- O replay integral falha antes de aplicar a primeira migration porque o schema-base `public.campaigns` não existe no stack vazio. Continua sendo bloqueio de bootstrap, não falha de migration 969 nem da aplicação.


### Validação consolidada mais recente — 2026-11-10 20:02 UTC

- HEAD da branch/PR #74: `5874c6fc36d1d79f7411f1299f97e316a3b772b7`; PR aberto, draft, não mesclado.
- No HEAD `5874c6f`: Static validation, Validate application JavaScript, Validate mesa JavaScript e PostgreSQL fixture tests concluíram **success**. PostgreSQL run #42891004794.
- Os logs do fixture confirmam: migrations de segurança 1500/1600/1700 aplicadas no banco descartável; verificações de ACL/SECURITY DEFINER passaram; GM autorizado e jogador/anon negados; helpers internos negados a authenticated; wrapper de Ataque Total positivo para ficha própria; helper interno de 7 args negou campanha incorreta, identidade de usuário incorreta e membership ausente; reproducer AOO confirmou as quatro lacunas (duplicidade, geometria de outro token, facção/alcance e spawn de token).
- Os testes de deadlock/autorização também concluíram success como modelos sintéticos. Os erros de deadlock/authorization presentes no log são resultados esperados dos cenários de reprodução, não falhas do job nem incidentes observados no Supabase.
- O workflow de replay integral ainda está em execução para esse HEAD; execuções anteriores falharam no bootstrap antes de aplicar a primeira migration, por ausência de `public.campaigns`. Aguardando o resultado do run atual.
- A validação verde da fixture não é integração PostgREST/Auth real e não demonstra correção das rotas AOO em produção. As quatro lacunas permanecem reproduzidas no algoritmo atual.
- Nenhuma migration/ACL/trigger/função/policy/dado/campanha remota foi alterada; nenhum deploy ou merge.


### Revalidação CI e reconciliação do baseline — 2026-11-10 (20:45 UTC)

- HEAD validado: `fbcacb756a2118fef53bbb420323c23008f7609d`.
- GitHub Actions nesse HEAD: Static validation, Validate application JavaScript, Validate mesa JavaScript e PostgreSQL fixture tests concluíram **success** (runs 42891256841, 42891257044, 42891257182 e 42891256731).
- Replay integral (run 42891256703) falhou no passo de inicialização/replay local, antes de qualquer migration subsequente: a primeira migration `20261031160944_srd35_action_economy.sql` referencia `public.campaigns`, inexistente no stack vazio. A etapa de replay foi ignorada após a falha.
- Reconsulta read-only a `supabase_migrations.schema_migrations` confirmou **966 versões aplicadas** no projeto remoto, da versão `20261031160944` até `20261109005941`. Consulta ao catálogo confirmou que `public.campaigns`, `characters`, `members`, `srd_character_sheets`, `srd_equipment` e `srd_feats` existem no banco remoto.
- A branch auditada contém **969 arquivos de migration**: 966 que correspondem ao ledger remoto e três candidatas locais (1500/1600/1700) não aplicadas. Assim, referências anteriores a “966 arquivos locais” estão superadas pela contagem atual da branch; o número 966 descreve o ledger remoto aplicado.
- Diagnóstico refinado: o projeto remoto tem schema-base anterior/externo ao ledger versionado; o replay vazio não consegue reconstruí-lo a partir das 966 migrations incrementais. Não criar bootstrap mínimo artificial. Recuperar dump/schema-only ou outra fonte histórica verificável, identificar objetos pré-ledger e só então reconstruir o bootstrap em ambiente descartável.
- A inspeção adicional do detector AOO confirma dependências relacionais externas ao JSON CBA: fichas (raça/classe/talentos), instâncias/equipamento de armas e condições usadas na reserva de reação. O contrato deve versionar/validar essas fontes ou invalidar atomicamente o pending; congelar apenas `campaigns.cba_data` é insuficiente.
- Nenhuma alteração foi aplicada ao Supabase remoto; nenhum deploy ou merge. As quatro suites verdes validam JavaScript/estática e fixtures PostgreSQL sintéticas, não integração Auth/PostgREST ou execução real das RPCs AOO.


### Inventário adicional de writers relacionais que alimentam AOO — 2026-11-10

- Nova varredura read-only das definições instaladas em `public` e `priv`, procurando DML direto em tabelas que alimentam o snapshot AOO, encontrou 44 funções com escrita lexical direta em `srd_character_sheets`, 6 em `srd_character_equipment` e 23 em `srd_campaign_conditions`.
- A varredura não encontrou DML direto textual em `srd_character_weapon_instances` nem em `srd_equipment`; isso **não** significa ausência de escritores: o catálogo já confirma trigger de sincronização de instâncias de arma a partir de `srd_character_equipment`, e funções podem delegar a helpers ou usar SQL dinâmico. Os contadores são inventário lexical, não lista completa de mutações transitivas.
- Famílias relevantes a classificar por janela de pending: edição/avanço de ficha (atributos, raça/classe/talentos), equipar/entregar itens, dano/cura e sincronização de vitalidade, condições de combate e término de Fúria. Não bloquear indiscriminadamente: dano/PV e condições terminais podem ser consequências legítimas de uma reação AOO, enquanto raça/tamanho/talentos/arma/facção/alcance alteram elegibilidade ou geometria da ameaça.
- Próxima análise deve construir o grafo transitivo writer → helper/trigger → tabela, marcando quais campos efetivamente alteram a ameaça, quais são consequência da reação e qual lock/serialização cada rota herda. Até essa classificação, não implementar freeze amplo de ficha/equipamento/condições.
- Consulta exclusivamente read-only; nenhuma RPC de jogo, migration, ACL, policy ou dado foi alterado no projeto remoto.


### Continuação — cadeia de inventário → instâncias de arma → snapshot AOO (2026-11-10)

- O trigger instalado `public.srd_character_equipment.sync_character_weapon_instances_from_inventory` é `AFTER INSERT OR DELETE OR UPDATE OF quantidade` e chama `private.sync_character_weapon_instances_from_inventory()` (`SECURITY DEFINER`, search_path fixo). Em DELETE, remove todas as instâncias de arma da ficha/item; em INSERT/aumento de quantidade, cria instâncias; em redução, remove instâncias não equipadas e rejeita a operação se não houver instâncias suficientes sem uso. Depois sincroniza `equipado`/mão no inventário. Portanto, mutações de quantidade no inventário são mutações transitivas de `srd_character_weapon_instances`, apesar de não haver DML lexical direto nessa tabela.
- Foram confirmados seis writers diretos do inventário; os endpoints mais relevantes:
  - `public.entregar_item_srd(bigint,text,text,integer)` (OID 20556): `SECURITY DEFINER`, authenticated EXECUTE; valida GM e vínculo do personagem, mas não bloqueia `campaigns` nem revalida o papel sob lock de campanha. Pode desalojar item de mesmo slot e inserir/aumentar quantidade, acionando o trigger de instâncias.
  - `public.equipar_item_srd(text,text,boolean)` (OID 20555): `SECURITY INVOKER`, authenticated EXECUTE; valida dono/GM, mas não bloqueia campanha nem ficha antes de atualizar inventário. Para armas delega a `equipar_item_srd_maos`; para outros slots atualiza equipamento diretamente. A alteração de arma propaga ao snapshot de ameaça por instâncias.
  - `public.finalizar_equipamento_inicial_srd(text,text,jsonb,jsonb)`: bloqueia personagem e ficha, mas não campanha; insere itens com ON CONFLICT e dispara o trigger. O guard de conclusão única reduz repetição normal, mas não substitui serialização com estado de combate.
- O trigger de ficha observado (`trg_srd_toughness_hp_delta`) altera PV máximo/atual quando o talento Tenacidade muda; isso é consequência/derivação de PV, não geometria AOO. Não foi encontrado trigger AOO em `srd_character_sheets`, `srd_character_equipment`, `srd_character_weapon_instances`, `srd_equipment` ou `srd_campaign_conditions`; o único trigger espacial conhecido segue sendo o guard de `campaigns.cba_data`.
- Implicação arquitetural: o inventário precisa ser tratado como writer de arma e alcance AOO, inclusive via trigger. Um contrato que só bloqueie DML direto em `weapon_instances` não fecha a cadeia. Para operações que mudam arma equipada/quantidade, a opção segura é campaign-first + revalidação do estado/pending antes dos locks de ficha/inventário/instância, ou invalidação/recalculo atômico do pending; o desenho final deve preservar operações legítimas de consequência da reação.
- Ainda não foi feita chamada autenticada dessas RPCs nem teste concorrente com trigger real; a classificação decorre das definições instaladas e ACLs. Consulta read-only; nenhum objeto/dado remoto foi alterado.


### Call sites e escopo dos writers de ficha/equipamento — 2026-11-10

- Call sites atuais foram confirmados nas páginas da branch auditada:
  - `mesa.html` chama `entregar_item_srd` ao Mestre entregar item a personagem jogador e chama `equipar_item_srd` no inventário de personagem; logo, a cadeia de entrega/equipamento não é apenas endpoint legado.
  - `ficha.html` chama `concluir_avanco_nivel_personagem_srd_v2` no avanço de nível; o wrapper delega para a implementação interna e, opcionalmente, salva idiomas. A RPC de idiomas lê a ficha sem `FOR UPDATE` e atualiza apenas `idiomas_conhecidos`, que não é entrada geométrica/elegibilidade AOO por si só.
  - O fluxo de equipamento da ficha também usa `equipar_item_srd` para itens não arma e delega armas para a família de instâncias. A rota NPC vinculada é redirecionada para wrappers específicos de token.
- A alteração de talento pode afetar diretamente o detector AOO quando inclui Ataque Desarmado Aprimorado; por isso, qualquer writer de `srd_character_sheets.talentos` deve ser classificado por estado de combate/pending, ainda que o trigger de Tenacidade só derive PV. A função `salvar_talentos_bonus_classe_inicial_srd` bloqueia personagem e ficha, mas não campanha e não contém guarda explícita de combate; o catálogo a marca authenticated EXECUTE. Não foi encontrado call site direto nas três páginas principais consultadas, portanto mantê-la como endpoint alcançável por RPC, sem afirmar uso corrente pelo frontend.
- O fluxo de avanço de nível usa a implementação interna que bloqueia recursos de ficha e valida elegibilidade do avanço; a revisão atual ainda não demonstrou serialização campaign-first. O estado de combate precisa ser revalidado sob o lock de campanha para impedir que uma operação iniciada em exploração atravesse uma transição para combate.
- Não confundir os writers de metadados: salvar idiomas e PV/condições derivados não alteram a geometria/alcance da ameaça; atributos, raça, classe, talentos de combate e instâncias/estado de armas podem fazê-lo. A próxima classificação deve ser por coluna/efeito, não por tabela inteira.
- Nenhuma RPC autenticada foi executada nesta etapa. Call sites foram confirmados por leitura do frontend versionado e os contratos pelo catálogo remoto; nenhuma função, trigger, ACL, migration ou dado remoto foi alterado.


### Nova superfície interna `private` — inventário de equipamento (2026-11-10)

- A inspeção foi ampliada do schema `priv` para `private`. No catálogo remoto, `authenticated` tem USAGE em ambos; `private` contém 8 funções SECURITY DEFINER, das quais 6 têm EXECUTE efetivo para authenticated e nenhuma para anon. A auditoria anterior de 94 funções cobria somente `priv` e, portanto, não era inventário completo dos schemas internos.
- As seis funções `private.*` com EXECUTE authenticated são: `consultar_inventario_npc_vinculado_impl`, `equipar_arma_instancia_npc_vinculado_impl`, `equipar_arma_instancia_personagem_impl`, `equipar_arma_instancia_token_impl`, `equipar_item_npc_vinculado_impl` e `equipar_item_token_srd_maos_impl`.
- A mais relevante para AOO é `private.equipar_arma_instancia_personagem_impl(text,uuid,text,boolean)`: SECURITY DEFINER, authenticated EXECUTE; bloqueia personagem → instância de arma → atualiza inventário/instâncias, mas não bloqueia campanha nem verifica pending AOO/estado de combate. A validação de dono/GM ocorre depois do lock do personagem e a função é diretamente executável pelo papel autenticado, além de ser chamada pelo wrapper público. Assim, o contrato de armas não pode depender exclusivamente do wrapper público nem supor campaign-first.
- Em contraste, as implementações NPC vinculado e token (armas/itens) observadas bloqueiam a campanha antes de token/instância; isso é mais próximo do protocolo desejado, embora ainda exija revisão de pending e dos callsites transitivos.
- O catálogo confirma EXECUTE SQL para authenticated, mas não confirma que `private` esteja incluído em `pgrst.db_schemas`; não afirmar exposição REST explorável nem testar acesso HTTP sem a configuração efetiva. A exposição de schema continua uma pergunta separada.
- Próxima unidade: inventariar os 8 objetos do schema `private`, mapear grants por assinatura e callers públicos; depois ampliar a matriz ACL para todos os schemas não expostos que têm USAGE concedido a papéis cliente. Não revogar em bloco antes de adaptar wrappers e testes.
- Consulta read-only; nenhuma ACL, função, migration, trigger ou dado remoto foi alterado.


### Avanço de nível altera entradas AOO sem serialização da campanha — 2026-11-10

- Leitura integral da implementação instalada `priv.concluir_avanco_nivel_personagem_srd(bigint,text,integer,jsonb,jsonb,text)` confirma locks em personagem → ficha e atualização de `nivel`, `atributos`, `pericias`, `talentos` e progressão de classe. A implementação não consulta nem bloqueia `public.campaigns`; não há validação de que a campanha permaneça fora de combate nem verificação de pending AOO sob lock.
- O wrapper ativo `public.concluir_avanco_nivel_personagem_srd_v2` é chamado por `ficha.html`. Logo, a lacuna é alcançável pelo fluxo de avanço de nível, não apenas por helper interno.
- A alteração de talento/classe é material para AOO: o detector consulta classe Monge e o talento Ataque Desarmado Aprimorado para determinar se um personagem ameaça quadrados sem arma equipada; os níveis de classe também alimentam propriedades de combate. Assim, um avanço concluído enquanto existe pending pode mudar elegibilidade/ameaça entre o snapshot e a reação/commit. A função não é writer de geometria, mas writer de premissas do snapshot.
- O lock personagem → ficha também não se integra ao protocolo campaign-first proposto. A correção deve bloquear a campanha primeiro, revalidar estado e pending, e então bloquear personagem/ficha; se avanço durante combate for permitido por regra de produto, deve invalidar/recalcular o pending dentro da mesma transação. Não basta adicionar um teste de estado antes do primeiro lock.
- O marker textual `COMBATE` encontrado em uma varredura simplificada estava em listas/strings de talentos, não em uma guarda de estado. A revisão do corpo completo não encontrou guard real de combate.
- Não foi executada a RPC nem alterada a implementação remota; conclusão estática baseada no corpo instalado e no callsite versionado.


### Condições de combate: writer sem lock de campanha altera elegibilidade AOO (2026-11-10)

- A RPC `public.srd_remove_campaign_condition(bigint,text,text,text)` é `SECURITY DEFINER`, autenticada e GM-only, mas executa UPDATE direto em `srd_campaign_conditions` sem bloquear `campaigns`, sem verificar pending AOO e sem invalidar/recalcular snapshots. O contrato não é protegido por trigger AOO na tabela de condições.
- Isso é material, não apenas metadata: `priv.srd_reservar_reacao_movimento_aoo_impl` consulta `priv.srd_condition_has_flag` após bloquear pending e campanha para decidir elegibilidade do reator. Entre as flags verificadas estão `no_aoo_against_unengaged`, `no_actions`, `helpless`, `stunned`, `unconscious` e `disabled` (token e ficha vinculada). Remover uma condição durante pending pode transformar um reator inelegível em elegível, ou vice-versa, após o snapshot inicial.
- O cálculo de elegibilidade também consulta efeitos ativos; portanto, a revisão precisa cobrir writers de `srd_campaign_effects` com o mesmo critério, e não apenas condições. Mudanças de condição/efeito que representem consequência legítima de uma reação devem ser realizadas dentro da transação de resolução; administração externa durante pending deve bloquear campaign-first e rejeitar ou invalidar o pending.
- Nova inconsistência de lock order: `public.srd_resolve_dying_round(bigint,text,integer)` bloqueia personagem → ficha → campanha → condição. Isso contraria o protocolo campaign-first e pode formar ciclo com operações de combate que bloqueiam campanha antes de ficha/personagem. A RPC é authenticated EXECUTE. A correção deve obter a campanha primeiro, revalidar o personagem e então adquirir locks de personagem/ficha/condição numa ordem única.
- `priv.srd_condition_has_flag` agrega condições, efeitos e metadados de Confusão; revogar EXECUTE direto desse helper não impede o uso interno via SECURITY DEFINER. Seu uso em decisões de AOO significa que a consistência transacional dos escritores de ambas as tabelas é parte do contrato do snapshot.
- Não foi executada remoção de condição nem resolução de estabilização; achados estáticos por catálogo remoto. Nenhuma mudança no Supabase remoto.


### Efeitos ativos também alteram elegibilidade AOO — writer de remoção sem lock (2026-11-10)

- A leitura do helper `priv.srd_condition_has_flag` confirma que ele combina três fontes: `srd_campaign_conditions` + `priv.srd_condition_engine_rules`, `srd_campaign_effects.effect_data.flags` e estados derivados da condição Confuso. Portanto, o snapshot/decisão de elegibilidade não pode auditar somente condições.
- `priv.srd_reservar_reacao_movimento_aoo_impl` usa essas flags para marcar reator inelegível: `no_aoo_against_unengaged`, `no_actions`, `helpless`, `stunned`, `unconscious` e `disabled`, consultando token e ficha vinculada. Remover efeito ativo durante pending pode liberar uma reação; inserir/alterar efeito que defina flags pode bloquear uma reação que já foi considerada elegível.
- A RPC `public.srd_remove_campaign_effect(bigint,bigint)` é `SECURITY DEFINER`, GM-only e authenticated EXECUTE, mas executa UPDATE direto em `srd_campaign_effects` sem lock de campanha, sem checagem de pending e sem invalidar/recalcular snapshot. É a lacuna equivalente à remoção direta de condição.
- O caminho de aplicação `priv.srd_apply_campaign_effect` bloqueia campanha antes de inserir/atualizar efeito, e `priv.srd_apply_campaign_condition` também bloqueia campanha. Isso é positivo, mas não fecha os caminhos de remoção nem substitui o tratamento de pending quando a alteração é uma consequência interna legítima da reação.
- Requisito para o desenho: toda mutação de condição/efeito que altere flags de elegibilidade deve ser campaign-first e serializada com pending. Durante pending, mutações administrativas devem rejeitar ou invalidar atomicamente o snapshot; efeitos aplicados/removidos como consequência de reação devem ocorrer na própria transação de resolução, com regra explícita para atualizar a elegibilidade remanescente.
- O contrato da tabela `srd_campaign_effects` também não possui trigger AOO observado. Nenhuma chamada autenticada de remoção foi executada; achado estático. Nenhuma alteração remota.


### Encerramento de Fúria e ordem de locks — novos caminhos de chamada (2026-11-10)

- Revisão dos callers instalados de `priv.srd_end_barbarian_rage` e `priv.srd_end_barbarian_rage_token` encontrou dois caminhos adicionais incompatíveis com campaign-first:
  - `public.usar_furia_barbaro_srd(text,text)` bloqueia personagem → ficha → campanha antes de encerrar/iniciar Fúria. A chamada de encerramento só adquire a campanha depois de já reter locks de personagem/ficha; concorre em ordem inversa com operações de combate que bloqueiam campanha antes da ficha.
  - `public.end_combat(bigint)` bloqueia linhas de efeitos de Fúria com `FOR UPDATE` e chama os helpers de encerramento antes de atualizar/bloquear a campanha. O caminho efetivo pode ser efeito → campanha, inverso do fluxo de combate campaign-first.
- Os helpers internos de encerramento bloqueiam primeiro o efeito ativo; no caso do NPC, depois bloqueiam campanha, atualizam token/CBA e podem bloquear ficha vinculada. Eles não têm EXECUTE authenticated direto no catálogo consultado. Os callers que já seguram campaign lock (ex.: alternar estado, expirar condições, trigger de avanço de rodada e descanso NPC) evitam inverter o primeiro lock; isso não torna seguros os dois caminhos acima.
- `public.usar_furia_barbaro_npc_srd` bloqueia campanha antes de personagem/ficha e chama o helper de encerramento depois; caminho mais alinhado. O descanso longo de NPC também bloqueia campanha antes de personagem/ficha.
- Resultado dos workflows do commit `1959849b68c4f1f9e677cddc997f12f5f59e5bf1`: validação JS de ficha/lobby e mesa passou; fixtures PostgreSQL passou; replay de migrations falhou na etapa de iniciar stack Supabase descartável, antes de aplicar migrations. A falha é de bootstrap do ambiente local, não prova falha do banco remoto.
- Próxima correção deve normalizar os wrappers públicos para campanha primeiro, revalidar papel/estado/turno após lock, e só então bloquear personagem, ficha, efeitos/condições e recursos. `end_combat` deve adquirir campaign lock antes de selecionar/alterar efeitos. Adicionar testes concorrentes para encerrar Fúria de personagem × ataque/avanço de turno e encerrar combate × expiração de Fúria.
- Consulta remota somente leitura; nenhuma RPC de Fúria/combate foi executada e nenhuma alteração remota foi feita.


### Descanso e resistência de magia: novos escritores fora da serialização AOO (2026-11-10)

- `public.descanso_longo_personagem_srd(bigint,text)` bloqueia personagem → ficha, lê o estado da campanha sem `FOR UPDATE` e depois remove condições `fatigued`/`exhausted`. A leitura simples de `state` não impede início de combate concorrente; a remoção de condições ocorre sem lock da campanha. O descanso também restaura recursos e PV. Deve obter campaign lock antes do personagem/ficha e revalidar que o combate não começou, ou rejeitar pending/combate sob esse lock.
- `public.srd_resolve_pending_spell_save(uuid,integer)` bloqueia primeiro a linha do pedido de resistência (`priv.srd_pending_spell_resolutions`), e em caminhos de quebra de condição atualiza `srd_campaign_conditions` sem bloquear a campanha. Em caminhos de aplicação de magia, delega para `priv.srd_apply_pending_spell_resolution`; é necessário mapear a cadeia transitiva e padronizar a ordem campaign → pending spell → condição/efeito, sem manter pending lock antes da campanha.
- `public.srd_resolve_dying_round` confirmado em leitura integral: personagem → ficha → campanha → condição. Além do risco de deadlock, a campanha pode avançar enquanto a RPC espera por locks anteriores; a rodada precisa ser revalidada após campaign lock, não antes.
- Esses casos ampliam a auditoria: escritores de condição não são apenas as RPCs de administração GM. Descanso de jogador, estabilização e resistência a magia também alteram condições de combate e precisam participar do mesmo contrato por campanha. Consequências normais de magia/reação devem ser aplicadas na transação de resolução, não congeladas indiscriminadamente.
- Somente catálogo remoto e leitura de definições; nenhuma RPC foi executada nem dados remotos alterados.


### Resoluções de magia pendentes: pedido bloqueado antes da campanha (2026-11-10)

- Leitura dos corpos completos confirma que `priv.srd_apply_pending_spell_resolution(uuid)` bloqueia `priv.srd_pending_spell_resolutions` primeiro e, para aplicar dano/efeito, bloqueia `public.campaigns` depois. `public.srd_resolve_pending_spell_save(uuid,integer)` já mantém o lock do pedido e pode delegar para esse helper; `public.srd_resolve_pending_spell_resistance(uuid,integer)` também pode delegar quando a magia não exige resistência de Reflexos/Fortitude/Vontade adicional.
- No ramo de quebra de condição, `srd_resolve_pending_spell_save` atualiza `srd_campaign_conditions` diretamente enquanto mantém o pedido bloqueado, sem lock da campanha. Assim, o caminho de magia participa da mesma superfície de condições AOO e da ordem de locks.
- Isso não prova deadlock observado: não foi identificado nesta varredura um ciclo completo com outro caller que bloqueie a campanha e depois exatamente o mesmo pedido de magia. É, porém, uma divergência do protocolo campaign-first e precisa ser normalizada antes de declarar o conjunto de writers consistente.
- A correção deve ler os dados do pedido sem lock, adquirir campaign lock, revalidar status/expiração/alvo, então bloquear o pedido e só depois aplicar dano/condição/efeito. Manter idempotência da resolução e garantir que duas respostas concorrentes não apliquem o efeito duas vezes.
- Consulta somente leitura; nenhuma resistência, magia ou pedido pendente foi executado/modificado.


### Conjuração de magia também inverte a ordem campanha → ficha (2026-11-10)

- Leitura dos fragmentos de lock confirma que as RPCs authenticated `public.conjurar_magia_efeitos_multialvo(...)` e `public.conjurar_magia_dano_multialvo_srd(...)` bloqueiam primeiro a ficha do personagem e depois a linha de `public.campaigns` (`cba_data FOR UPDATE`). Em alvos player, alguns ramos também bloqueiam ficha do alvo depois. Isso diverge do protocolo campaign-first e pode competir com avanço de turno/dano/AOO que segura campanha antes de ficha.
- `public.conjurar_magia_srd_manual(...)` segue padrão parecido em alguns ramos, mas o catálogo consultado não dá EXECUTE authenticated direto; tratar como implementação/caminho delegado até confirmar wrapper e callsites. `public.conjurar_missil_magico_srd(...)` também bloqueia personagem → ficha → campanha, mas não tem EXECUTE authenticated direto no catálogo consultado; não classificar como endpoint cliente sem identificar o wrapper/callsite.
- O problema não é a magia em si: é a ordem de espera entre a ficha e a campanha. A correção deve obter campanha primeiro, revalidar dono/membership/combate e então bloquear ficha do conjurador/alvos, mantendo a ordem determinística para múltiplos alvos (IDs ordenados).
- A Fúria de personagem (`usar_furia_barbaro_srd`) segue a mesma ordem personagem → ficha → campanha, já registrada acima; agrupar com as conjurações na futura refatoração de fronteira de combate.
- Análise estática do catálogo remoto; nenhuma magia foi conjurada e nenhuma mudança remota foi feita.


### Outras ações de classe e recursos: ficha antes da campanha (2026-11-10)

- A varredura de RPCs autenticadas que bloqueiam `srd_character_sheets` identificou novos caminhos de combate fora de campaign-first:
  - `public.usar_habilidade_classe_srd(text,text,text,integer)` bloqueia personagem, ficha e recurso de classe antes da campanha; em seguida pode bloquear ficha do alvo. É uma rota genérica de habilidades e pode cobrir cura/efeitos de classe.
  - `public.usar_imposicao_maos_mortos_vivos_srd(text,text,integer,integer)` bloqueia personagem, ficha e recurso de classe antes da campanha, depois altera token/CBA e PV/condições. É uma mutação de combate direta.
  - `public.conceder_xp_personagem_srd(bigint,text,integer)` bloqueia personagem e ficha antes de atualizar progressão/nível; precisa confirmar se o caminho pode ocorrer durante combate e se altera entradas AOO (raça/classe/talentos). Tratar como writer de ficha com guarda de combate ausente até validação.
  - `public.descanso_longo_personagem_srd` bloqueia personagem/ficha antes de campanha (já registrado), remove condições e repõe recursos.
  - `public.finalizar_equipamento_inicial_srd`, `public.salvar_talentos_bonus_classe_inicial_srd` e `public.salvar_dominios_personagem_srd` alteram ficha/progressão sem lock da campanha; precisam impedir edição de fontes de ameaça enquanto combate/pending AOO estiver ativo, ou validar/inutilizar snapshot de forma atômica.
  - `public.excluir_ficha_propria` bloqueia personagem antes da campanha e pode mexer na iniciativa/estado da campanha; requer ordem campaign-first para evitar corrida com turno/combate.
- Nem todas essas rotas necessariamente geram deadlock hoje: algumas são preparação de ficha ou progressão fora do combate. A correção deve distinguir ações de mesa (que exigem serialização da campanha) de edição de personagem fora de combate (que deve rejeitar se estiver em combate/pending), em vez de aplicar um bloqueio global cego.
- `public.alterar_pv_personagem` e `public.conceder_xp_personagem_srd` recebem `p_campaign_id`, mas a classificação lexical não detectou um `campaigns FOR UPDATE` anterior; inspecionar corpo completo/ordem efetiva antes de fechar o mapa.
- `public.usar_pocao_cura_srd_manual` consome item e atualiza PV sem campaign lock explícito, e chama consumo de ação após ler estado da campanha sem lock. É outra rota de cura que pode tocar condição vital e inventário; precisa campaign-first e revalidação do turno.
- Somente leitura de catálogo; nenhuma RPC executada, nenhuma ficha, token ou campanha alterada.


### Escritores CBA: confirmar campanha-first e exceção de spawn (2026-11-10)

- Nova varredura de funções que executam `UPDATE public.campaigns` com `cba_data` mostra que a maioria dos escritores de combate identificados adquire `campaigns FOR UPDATE` antes de alterar tokens: movimento GM/jogador, dano, AOO, configuração de perfil, avançar turno, consumo de ação, descanso de NPC, equipamento de token e Encontrão.
- Correção da classificação anterior: `public.adicionar_token_cba_completo(bigint,jsonb)` herda o `campaigns FOR UPDATE` de `public.adicionar_token_cba` (OID 20075), chamado na mesma transação. Portanto, não é writer sem lock; a lacuna remanescente é validar novamente a autorização GM depois do lock e definir política explícita para spawn durante pending/combate.
- `public.alterar_pv_token_cba` tem lock de campanha visível, mas ainda requer confirmar se a checagem de permissão/identidade e pending ocorre após o lock. Não presumir segurança só pela presença de `FOR UPDATE`.
- `public.srd_end_barbarian_rage_token` e `priv.srd_sync_linked_npc_token_vitals` são helpers sem EXECUTE authenticated direto e devem ser chamados somente por writers que já mantêm o lock da campanha; revisar callsites transitivos, não conceder acesso direto.
- Conclusão provisória: a fronteira CBA tem writers relativamente mais centralizados em campaign lock; as maiores lacunas restantes estão em mutações relacionais de ficha/condição/efeito e endpoints de classe/magia que bloqueiam ficha antes da campanha. Ainda é necessário testar identidade duplicada e freeze/invalidação de snapshot AOO.
- Apenas catálogo remoto consultado; nenhuma cena, token ou PV alterado.


### Continuidade — writers de condições, cura e spawn: revisão dos locks efetivos (2026-11-10)

- Refinamento importante de `public.adicionar_token_cba_completo` (OID 21726): ela delega a `public.adicionar_token_cba` (OID 20075), que **bloqueia a linha de campanha com FOR UPDATE** antes de ler/alterar `cba_data`. Portanto, não é correto classificá-la como writer sem lock de campanha. A lacuna permanece: a validação GM ocorre **antes** desse lock e não é repetida depois; também não há guarda de pending AOO/combate no fluxo. O wrapper mantém o lock adquirido pelo helper na mesma transação ao atualizar os metadados extras do token. A correção deve revalidar GM depois do lock e definir a regra de spawn durante pending/combate.
- Confirmação dos dois endpoints GM de remoção: `public.srd_remove_campaign_condition` (OID 24806) e `public.srd_remove_campaign_effect` (OID 24897) fazem a validação `my_role(...)=GM` e depois atualizam diretamente suas tabelas, sem `campaigns FOR UPDATE`. São writers authenticated de flags consultadas na elegibilidade AOO; a validação de papel também fica sujeita a mudança concorrente de membership.
- Refinamento da poção: `public.usar_pocao_cura_srd_manual` (OID 24655) verifica propriedade e lê `campaign_id/state` sem lock; se vê COMBATE chama `consumir_acao_turno_srd`, mas se vê EXPLORACAO pula o consumo e segue bloqueando inventário/ficha e aplicando cura. Uma transição concorrente para combate pode ocorrer depois da leitura e antes da cura. O helper de ação não protege esse ramo ignorado. A correção deve localizar a campanha, bloquear campanha primeiro e revalidar dono/estado/turno antes dos locks de inventário/ficha.
- O inventário lexical anterior subestimava o contrato de spawn: o lock existe em helper transitivo, não na função wrapper. A regra de auditoria passa a exigir grafo de chamada e lock herdado, não apenas busca de `FOR UPDATE` no corpo da função pública.
- A revisão foi somente leitura do catálogo instalado. Nenhuma RPC foi executada, nenhuma função/migration/ACL/policy/dado remoto foi alterado e a campanha de teste permaneceu intocada.


### Continuidade — encerramento de manobra AOO e fluxo de Confusão (2026-11-10)

- Nova rota authenticated identificada: `public.srd_resolver_levantar_caido_apos_aoo_srd` (OID 27157) delega para `priv.srd_resolver_levantar_caido_apos_aoo_srd` (OID 27152), também com EXECUTE para authenticated. A implementação bloqueia primeiro a linha de pending AOO (`srd_aoo_pending_movements FOR UPDATE`) e só depois `campaigns FOR UPDATE`; isso contraria campaign-first e pode competir com finalização/cancelamento que já bloqueiam campanha antes do pending. A implementação revalida round/turno após o lock da campanha, mas chega a esse lock segurando pending. Corrigir para ler pending sem lock, bloquear campanha, revalidar e então bloquear pending.
- A RPC autenticada `public.srd_resolve_confusion_turn_srd` (OID 27277) delega a `priv.srd_resolve_confusion_turn_impl` (OID 27273), que também tem EXECUTE authenticated. Diferentemente do fluxo de levantar-se, essa implementação bloqueia campanha primeiro, valida combate/turno/autoridade e só então bloqueia a condição Confuso; usa request_id para replay idempotente. É um exemplo positivo de serialização campaign-first, embora o acesso direto ao schema `priv` deva continuar na matriz de exposição/ACL.
- `public.srd_resolve_npc_dying_round` (OID 26859) também bloqueia campanha primeiro, valida o token único e chama sincronização vital de NPC vinculado; seu fluxo está mais alinhado ao contrato que o descanso/estabilização de PC.
- `public.srd_configurar_rodada_surpresa_srd` (OID 27092) bloqueia campanha antes de alterar a rodada e condições, mas valida papel GM antes do lock e não repete a validação após adquirir a linha. Registrar como TOCTOU de autorização a fechar com os demais endpoints administrativos: revalidar GM sob campaign lock.
- O wrapper público de levantamento existe no catálogo e delega ao helper interno; a busca textual nas páginas principais `mesa.html` e `lobby.html` não encontrou chamada direta, portanto não afirmamos callsite de frontend. A rota permanece autenticada e acessível por RPC.
- Consulta somente leitura de catálogo e código versionado; nenhuma RPC foi executada, nenhum dado/ACL/função/migration remota foi alterado.


### Consolidação — ordem efetiva dos locks AOO (2026-11-10)

A revisão dos corpos instalados confirmou que não basta identificar a existência de `FOR UPDATE`: o que importa é a ordem de aquisição na mesma transação.

- `priv.srd_reservar_reacao_movimento_aoo_impl` (OID 27256): pending → campaign.
- `public.srd_iniciar_ataque_oportunidade_srd` (OID 27022), `public.srd_iniciar_ataque_oportunidade_desarmado_srd` (OID 27065) e a implementação legada de ataque natural `public.srd_iniciar_ataque_oportunidade_monstro_srd` (OID 27055): pending → campaign. A sobrecarga natural OID 27231 delega para a implementação legada, então a ordem herdada também precisa ser considerada.
- `priv.srd_registrar_ocultacao_ataque_oportunidade_impl` (OID 27254): attack → pending → campaign.
- `public.srd_resolver_ataque_oportunidade_srd` (OID 27025): attack → pending → campaign.
- `public.srd_finalizar_movimento_aoo_pendente_srd` (OID 27038): pending → campaign.
- `priv.srd_resolver_levantar_caido_apos_aoo_srd` (OID 27152): pending → campaign.
- `priv.srd_cancelar_movimento_aoo_pendente_impl` (OID 27268): pending → attack (sem campaign lock explícito).
- `priv.srd_encerrar_reacao_aoo_pendente_impl` (OID 27269): pending → attack condicional (sem campaign lock explícito).

Essas ordens são evidência estática de inversões com operações campaign-first; não provam que deadlocks já ocorreram. A correção deve migrar todas as rotas para campanha → pending → attack/ledger, inclusive os helpers e overloads transitivos. Nas rotas de cancelamento/encerramento, o campaign lock deve ser adquirido antes de qualquer lock em pending/attack, e a autorização GM deve ser revalidada depois dele. As rotas que hoje fazem pending/attack primeiro não devem ser corrigidas isoladamente sem revisar os chamadores, para evitar lock duplicado ou ordem contraditória.

### Correção de inventário CBA — spawn

- A classificação anterior de `adicionar_token_cba_completo` como writer sem campaign lock foi incorreta: o helper `adicionar_token_cba` adquire esse lock e o wrapper herda-o durante a transação.
- Mantém-se o achado de autorização GM validada antes do lock sem revalidação e ausência de regra explícita para spawn durante pending AOO. O próximo desenho deve corrigir esses dois pontos, não adicionar um segundo lock redundante.
- Essa correção substitui as afirmações anteriores de ausência de lock direto/herdado para essa rota.


### ACL e exposição PostgREST — limite da evidência (2026-11-10)

- O catálogo remoto mostra `USAGE` no schema `priv` para `authenticated` e nenhuma para `anon`; 40 funções de `priv` têm EXECUTE para authenticated. No schema `private`, authenticated tem USAGE e 6 funções têm EXECUTE.
- `current_setting('pgrst.db_schemas', true)` e `pgrst.db_extra_search_path` retornaram NULL nesta conexão. Também não foram encontrados overrides correspondentes em `pg_db_role_setting` para database/authenticator.
- Isso **não comprova** que `priv`/ `private` estejam expostos pela API: a lista de schemas PostgREST pode ser configurada no serviço fora dessas configurações SQL consultadas. Não classificar essas funções como RPC acessível via HTTP até confirmar a configuração efetiva do projeto. Manter o risco como “permissões SQL authenticated concedidas; exposição API não confirmada”.
- A checagem foi read-only; nenhuma ACL, schema ou configuração foi alterada.


### Extensão do mapa AOO — dano e reserva de reação (2026-11-10)

- `public.srd_aplicar_dano_ataque_oportunidade_srd` (OID 27036) e `public.srd_aplicar_dano_ataque_oportunidade_monstro_srd` (OID 27058) seguem attack → pending → campaign e depois podem bloquear a ficha do alvo. São caminhos de resolução com a mesma inversão estrutural já vista no resolver do ataque.
- `priv.srd_reservar_ataque_oportunidade_impl` (OID 27261) é um controle positivo: bloqueia campaign primeiro e depois registra a reserva no ledger de reação.
- `public.srd_registrar_rolagem_ataque_oportunidade_srd` (OID 27024) bloqueia somente a linha de attack para gravar a rolagem/idempotência; `public.srd_confirmar_critico_ataque_oportunidade_srd` (OID 27027) também é attack-only. Esses caminhos não adquirem depois pending/campaign no corpo consultado, portanto não criam por si só a inversão attack→campaign; ainda precisam manter idempotência e estado terminal.
- O mapa atualizado reforça que as correções devem tratar o ciclo inteiro de vida do ataque: iniciar, rolar, confirmar crítico/ocultação, aplicar dano, encerrar/cancelar e finalizar movimento. Não basta corrigir apenas o resolver.


### Novo ponto de hardening — sinalizador de commit usado pela prévia AOO (2026-11-10)

- O trigger AFTER INSERT `priv.srd_validate_aoo_pending_movement_preview()` define `app.srd_aoo_pending_commit` com `set_config(..., true)` antes do bloco interno que simula o movimento e força rollback.
- Como a definição do sinalizador fica fora do sub-bloco revertido, o valor pode permanecer ativo no restante da transação externa depois que a prévia retorna. O guard de movimento usa esse valor como autorização para deslocar o token mover enquanto existe pending.
- O único chamador direto identificado, `public.srd_solicitar_movimento_com_aoo_srd` (OID 26964), termina logo após o INSERT; portanto não foi demonstrada exploração no caminho atual. Ainda assim, o escopo é excessivo para futuras chamadas aninhadas/wrappers e deve ser fechado.
- Na correção, salvar/restaurar o valor anterior do GUC em todos os caminhos, restringir a exceção ao pending/campanha/token/destino exatos e consumi-la uma única vez. Manter a prévia com rollback: ela valida o caminho real sem persistir o movimento.
- Achado estático do catálogo remoto; nenhuma mutação ou teste de escrita foi executado no Supabase remoto.


### Estado AOO não alcançável identificado no catálogo (2026-11-10)

- `ready_to_commit` aparece na constraint do pending, no índice de pendings ativos e no guard de movimento; porém a varredura das funções PL/pgSQL instaladas em `public` e `priv` não encontrou nenhum writer que atribua esse estado. O finalizador padrão aceita somente `waiting_reactions`; as manobras concluem diretamente em `committed`.
- Tratar como estado reservado/legado sem produtor identificado. Antes de removê-lo ou ativá-lo, conferir histórico das migrations e eventuais escritores externos; se mantido, definir a transição e os consumidores da máquina de estados.
- Apenas catálogo remoto consultado; nenhuma escrita no banco.


### Próxima extensão AOO — Derrubar e locks herdados (2026-11-10)

A auditoria do catálogo remoto expandiu o grafo de chamadas:

- Ataques AOO com arma/desarmado/natural (OIDs 27022, 27065, 27055) e finalização do movimento (OID 27038) seguem pending → campaign; início de ataque também bloqueia ledger depois. GM é validado antes do lock e não revalidado depois.
- Derrubar após reação (OID 27136) bloqueia pending e delega, pela cadeia pública/API, ao helper OID 27120 que bloqueia campaign: inversão transitiva pending → campaign. O iniciador de Derrubar (OID 27131) é campaign-first.
- O GUC app.srd_trip_aoo_pending_id é limpo para vazio em vez de restaurar o valor anterior. O GUC app.srd_aoo_pending_commit no finalizador normal é limpo somente no caminho de sucesso. Ambos precisam de escopo transacional estreito e restauração em sucesso/erro.
- A correção de lock deve incluir as cadeias transitivas e a finalização, não apenas os resolvers de ataque previamente mapeados.


### Transições globais da máquina AOO — encerramento de combate

- alternar_estado_campanha (OID 20103, authenticated) bloqueia campanha primeiro e, ao encerrar combate, cancela ataques ativos e expira pendings, convertendo reações abertas em skipped. Ordem compatível com campaign-first; autorização GM não é repetida depois do lock.
- avancar_turno (OID 20074, authenticated) bloqueia campanha primeiro e impede avançar enquanto houver pending AOO ativo. Para PLAYER revalida dono/turno sob lock; para GM não revalida membership após o lock.
- end_combat (OID 19091) escreve nos mesmos registros, mas não tem EXECUTE authenticated/anon no snapshot; não o considerar endpoint cliente direto.


### Cobertura real dos testes de concorrência AOO — limite confirmado (2026-11-10)

- A leitura de tests/sql/lock_cycle_test.sh confirmou que o harness atual reproduz padrões genéricos: campaign ↔ pending, pending ↔ attack e campaign ↔ attack → pending → campaign. Também executa a reprodução isolada da guarda espacial.
- Esses cenários são modelos sintéticos de locks, não chamadas das RPCs AOO reais. Não simulam ainda, com os nomes/efeitos completos, resolver ataque × finalizar movimento, reservar reação × cancelar pending, Encontrão × encerrar reação, ocultação × finalização e duas reservas simultâneas para o mesmo pending.
- Portanto, os fixtures existentes demonstram que os padrões de lock invertido geram deadlock no PostgreSQL descartável, mas não validam a correção nem a idempotência/estados terminais das RPCs de produção. Os cinco pares específicos continuam como gate de integração antes de implementar migrations.


### Estrutura relacional e invariantes AOO confirmados (2026-11-10)

- Pending: status possíveis `waiting_reactions`, `ready_to_commit`, `committed`, `cancelled`, `expired`; índice parcial único limita a um movimento ativo por campanha considerando os dois primeiros estados.
- Ataques: FK para pending e ledger; estados limitados a aguardando rolagem, confirmação crítica, chance de falha, dano, erro, dano aplicado ou cancelado. Chaves únicas cobrem reação, idempotência de dano e chave opcional de rolagem.
- Ledger: duas restrições únicas impedem duplicar reação pelo número ordinal ou pela chave de gatilho dentro da mesma campanha/fase/rodada/ator.
- As tabelas de pending, ataques e ledger estavam vazias na consulta ao Supabase remoto. Não inferir que os fluxos não são usados; apenas não havia linhas no momento observado.

Próximos testes reais precisam verificar concorrência e repetição idempotente nessas chaves, além de impedir que ataques permaneçam abertos após pending cancelado/expirado.


### CI — causa exata da falha no replay integral (2026-11-11)

O job `Replay full Supabase migration baseline` no commit `fa4b33f` falhou na etapa `Start disposable local Supabase stack only`, antes das etapas separadas de replay e verificação. O log mostra o stack subindo e, ao inicializar migrations automaticamente, tentando aplicar primeiro `20261031160944_srd35_action_economy.sql`; a primeira função `public.consumir_acao_turno_srd` falha ao resolver `public.campaigns`, que não existe no banco descartável vazio (`SQLSTATE 42P01`). Logo, não é uma falha de execução de toda a sequência nem evidência de erro no banco remoto: o conjunto versionado começa com uma migration incremental que pressupõe schema-base pré-existente. O passo seguinte é recuperar a origem confiável desse schema-base e preparar bootstrap fiel em ambiente descartável; não inventar tabela `campaigns` mínima para fazer o CI passar.

No mesmo commit, validação estática, JS da aplicação, JS da mesa e fixtures PostgreSQL concluíram com sucesso. A fixture PostgreSQL não substitui a reconstrução integral nem testes de concorrência das RPCs reais.


### Inventário lexical dos escritores das três tabelas AOO (2026-11-11)

A varredura de definições PL/pgSQL em `public` e `priv` localizou os escritores diretos mais relevantes:

- Pending: `priv.srd_cancelar_movimento_aoo_pendente_impl`, `priv.srd_encerrar_reacao_aoo_pendente_impl`, `priv.srd_iniciar_derrubar_com_aoo_srd`, `priv.srd_iniciar_encontrao_srd`, `priv.srd_iniciar_levantar_caido_srd`, `priv.srd_registrar_ocultacao_ataque_oportunidade_impl`, `priv.srd_reservar_reacao_movimento_aoo_impl`, `priv.srd_resolver_encontrao_srd`, `priv.srd_resolver_levantar_caido_apos_aoo_srd`, `priv.srd_resolver_derrubar_srd`, `public.alternar_estado_campanha`, `public.srd_finalizar_movimento_aoo_pendente_srd` e `public.srd_solicitar_movimento_com_aoo_srd`.
- Attacks: `priv.srd_cancelar_movimento_aoo_pendente_impl`, `priv.srd_encerrar_reacao_aoo_pendente_impl`, `priv.srd_registrar_ocultacao_ataque_oportunidade_impl`, `public.alternar_estado_campanha`, as duas rotas públicas de aplicar dano, confirmar crítico, iniciar ataque (arma/desarmado/natural), registrar rolagem e resolver ataque.
- Ledger: `priv.srd_reservar_ataque_oportunidade_impl`.

A listagem é lexical: não captura writers transitivos, SQL dinâmico, triggers ou funções que atualizam tabelas por helpers. Exemplos: resolver Derrubar após AOO não aparece como escritor direto de pending, mas chama helper que altera pending; `public.end_combat` aparece como writer e não possui EXECUTE para authenticated/anon no catálogo. Não interpretar a listagem como lista de endpoints HTTP. `priv` tem permissões SQL `authenticated` em algumas funções, mas exposição efetiva do schema via PostgREST continua não confirmada.

Próximo artefato de implementação deve ser um grafo transitivo de writers com uma linha por rota cliente/trigger/helper, não apenas uma matriz lexical por nome de tabela.


### Correção de interpretação: `ready_to_commit` tem suporte histórico intencional

As migrations `20261108170021_srd_aoo_pending_movement_lifecycle_guards.sql` e `20261108193147_support_cancelling_resumable_aoo_states.sql` incluem explicitamente `ready_to_commit` como estado cancelável/resumível. Assim, não é seguro classificá-lo como mero estado acidental ou removê-lo sem compatibilidade histórica.

A falha está na assimetria: cancelamento, encerramento global e bloqueio de avanço de turno aceitam os dois estados; finalização do movimento e encerramento individual de reação aceitam somente `waiting_reactions`. Não foi encontrado produtor atual para `ready_to_commit` e não havia registros nele no snapshot consultado, mas isso não elimina a intenção histórica. Definir retomada completa ou remoção coordenada após provar ausência de dependências.


### 2026-11-11 — rastreamento de produtores, consumidores e lock order AOO

- Varredura das definições instaladas em `public` e `priv` por `ready_to_commit`: nenhum produtor foi encontrado. As referências restantes são consumidores (guards, listagem, bloqueio de turno, cancelamento/expiração). O estado existe no contrato/índice e nas migrations históricas, mas não tem atribuição atual localizada. Tratar como legado a reconciliar; não apagar isoladamente.
- Os iniciadores de Derrubar, Encontrão e Levantar-se adquirem `campaigns FOR UPDATE` antes de inserir pending, alinhados ao padrão campaign-first.
- Finalização normal continua pendente-first e depois campanha; cancelamento e encerramento individual também bloqueiam pending antes de attack, sem lock de campanha. São lacunas diretas no protocolo, não apenas hipóteses de ciclo.
- `ready_to_commit` é cancelável/expirável e bloqueia avanço de turno, mas não pode ser finalizado nem ter reação individual encerrada. Contrato inconsistente e sem produtor atual identificado.
- Plano de concorrência ampliado: cinco cenários AOO reais já priorizados, mais finalizar×cancelar, finalizar×fim de combate e replay idempotente de rolagem/dano. Devem usar duas sessões e RPCs reais em banco descartável, com asserts de locks, idempotência e consistência terminal.
- CI no HEAD `131e717`: static, JavaScript da aplicação, JavaScript da mesa e fixtures PostgreSQL passaram. Replay integral falhou na etapa de inicialização do stack descartável, antes de replay: primeira migration `20261031160944_srd35_action_economy.sql` falha ao criar `public.consumir_acao_turno_srd` porque `public.campaigns` não existe (`42P01`).


### Reconciliação do bootstrap: inventário dos candidatos locais (2026-11-11)

Inspecionados os principais SQLs legados fora da pasta de migrations: `srd35_schema_reconciliation.sql` e sua cópia versionada `20261031180609_srd35_schema_reconciliation.sql` começam com `ALTER TABLE public.srd_equipment` e pressupõem `public.srd_equipment`, `srd_races`, `srd_classes`, `characters`, `members` e `campaigns` já existentes. `cba_iniciativa_migration.sql` também começa com `ALTER TABLE public.campaigns`; `srd35_rule_engine_foundation_migration.sql` cria tabelas SRD que referenciam `campaigns` e `characters`; `vtt_dnd35_final_migration.sql` usa `campaigns`, `characters` e `members` existentes. Nenhum desses arquivos é bootstrap do schema-base.

A árvore Git consultada contém `docs/REMOTE_SCHEMA_SNAPSHOT.md`, que descreve 83 relações, 229 índices e 327 funções, mas o próprio arquivo avisa que é fotografia descritiva, não dump restaurável nem migration. Não há no inventário de candidatos identificados um `CREATE TABLE public.campaigns` ou conjunto de criação inicial do core. Assim, ainda não existe fonte confiável no repositório para iniciar um banco vazio. Recuperar um schema-only dump/backup original ou histórico SQL do momento anterior à primeira migration; depois comparar com o snapshot remoto e o catálogo atual, separar objetos pré-ledger dos 966 versionados e criar bootstrap reproduzível em ambiente descartável.


### Auditoria de privilégios do schema `priv` — alerta de exposição (2026-11-11)

Consulta read-only ao catálogo remoto confirmou `USAGE` do schema `priv` para `authenticated` e ACL `EXECUTE` direto para `authenticated` em 40 funções instaladas. `pg_default_acl` confirma privilégios padrão do owner `postgres`: funções novas em `priv` recebem `EXECUTE` para `authenticated` e `service_role` por padrão (`{authenticated=X/postgres,service_role=X/postgres}`). Isso não é uma exceção pontual: é uma regra ampla de privilégios padrão.

Entre as funções `priv` com EXECUTE direto para `authenticated` estão helpers AOO: `srd_cancelar_movimento_aoo_pendente_impl`, `srd_encerrar_reacao_aoo_pendente_impl`, `srd_reservar_reacao_movimento_aoo_impl`, iniciadores de Derrubar/Encontrão/Levantar-se e resolvers de manobras. Os corpos verificados contêm checagens de autenticação/GM em várias rotas, mas isso não substitui revisão de cada helper e não corrige lock order. A função de levantar-se, por exemplo, valida usuário autenticado e turno/ator; sua política de autorização precisa ser revisada separadamente do simples EXECUTE.

**Limite importante:** o catálogo SQL não revelou a lista efetiva de schemas expostos pelo PostgREST. `current_setting('pgrst.db_schemas', true)` retornou NULL e não há override de `pgrst.db_schemas` nas configurações de role/database consultadas. Portanto, ainda não está provado que `priv` seja chamável via REST; `USAGE` + `EXECUTE` provam que o papel SQL `authenticated` tem os privilégios necessários caso o schema seja exposto. Não afirmar exposição HTTP até consultar a configuração ativa do serviço PostgREST/Supabase.

Ação recomendada antes de qualquer release: confirmar a allowlist real de schemas expostos; revisar uma a uma as 40 funções `priv` concedidas; substituir privilégios padrão amplos por concessão explícita mínima, revogar EXECUTE desnecessário de `authenticated` e manter wrappers `public` como única API cliente quando possível. Fazer isso em migration isolada, com inventário de callsites e testes de regressão; **não foi aplicada nenhuma revogação nem alteração no banco remoto**.


### Advisor de segurança Supabase — confirmação parcial de exposição (2026-11-11)

A leitura do Security Advisor do projeto retornou 99 funções `SECURITY DEFINER` executáveis por `authenticated` e explicitamente identificadas pelo Advisor como RPCs `/rest/v1/rpc/...`; os exemplos reportados são funções no schema `public`. O Advisor não listou funções `priv` como RPCs, embora `authenticated` tenha `USAGE` e EXECUTE no banco. Isso é evidência compatível com `priv` não estar exposto no schema REST atual, mas não substitui a leitura da allowlist ativa do PostgREST. Não tratar as funções `priv` como endpoints REST confirmados.

O Advisor também reportou 7 tabelas com RLS habilitado e sem policies: `priv.srd_aoo_attacks`, `priv.srd_aoo_pending_movements` e cinco tabelas públicas de sequência/recursos de ataque. Para as duas tabelas `priv`, a ausência de policy impede acesso via RLS para papéis sujeitos a RLS, mas funções SECURITY DEFINER podem acessá-las como owner; isso não corrige o risco de privilégios de execução concedidos às funções. O Advisor é um sinal de revisão, não prova de exposição indevida.

A frente de segurança agora deve separar (1) 99 RPCs públicas SECURITY DEFINER reportadas pelo Advisor, revisão de validação/autorização de cada endpoint; (2) 40 funções `priv` com EXECUTE SQL para authenticated, confirmar allowlist REST e reduzir default privileges; (3) duas tabelas AOO internas com RLS sem policy, confirmar que apenas caminhos SECURITY DEFINER controlados acessam seus dados. Nenhuma ACL/policy foi alterada.


### AOO no Security Advisor: RPCs públicas efetivamente expostas (2026-11-11)

A extração completa do Security Advisor esclareceu o escopo: 99 funções `SECURITY DEFINER` em `public` são reportadas como RPCs REST acessíveis ao papel `authenticated`; nenhuma função `priv` foi listada como endpoint REST. Isso é evidência adicional de que o schema `priv` não está atualmente na superfície RPC REST, embora o privilégio SQL interno continue amplo.

Entre as 99, o Advisor identificou 15 RPCs AOO expostas: `srd_aplicar_dano_ataque_oportunidade_monstro_srd`, `srd_aplicar_dano_ataque_oportunidade_srd`, `srd_confirmar_critico_ataque_oportunidade_srd`, `srd_consultar_armas_aoo_srd`, `srd_consultar_ataque_oportunidade_srd`, `srd_consultar_movimento_aoo_pendente_srd`, `srd_finalizar_movimento_aoo_pendente_srd`, `srd_iniciar_ataque_oportunidade_desarmado_srd`, as duas assinaturas de `srd_iniciar_ataque_oportunidade_monstro_srd`, `srd_iniciar_ataque_oportunidade_srd`, `srd_listar_movimentos_aoo_pendentes_srd`, `srd_registrar_rolagem_ataque_oportunidade_srd`, `srd_resolver_ataque_oportunidade_srd` e `srd_solicitar_movimento_com_aoo_srd` (15 assinaturas/endpoints contando overloads).

O alerta do Advisor é uma revisão genérica de funções SECURITY DEFINER acessíveis por usuário autenticado, não prova automática de falha: essas RPCs podem ser intencionalmente acessíveis e precisam validar identidade, papel, campanha, ator e estado sob locks. A análise AOO já identificou TOCTOU e ordem de locks inconsistente em parte delas. A revisão final deve cruzar cada endpoint da lista com os guards e a cadeia transitiva, mantendo apenas endpoints intencionais e com autorização revalidada.


### Revisão direta das RPCs AOO expostas — confirmação de novas inversões (2026-11-11)

Leitura de `pg_get_functiondef` no catálogo remoto confirmou detalhes de implementação em endpoints sinalizados pelo Security Advisor:

- `public.srd_finalizar_movimento_aoo_pendente_srd`: bloqueia `priv.srd_aoo_pending_movements FOR UPDATE` antes de `public.campaigns FOR UPDATE`; aceita somente `waiting_reactions`, apesar do estado retomável `ready_to_commit` ser aceito em cancelamento/expiração. Captura `auth.uid()` e verifica o papel/autor do movimento depois do lock pending, mas antes do lock da campanha; não repete a validação do papel depois de adquirir o lock de campanha. O GUC `app.srd_aoo_pending_commit` é limpo apenas no caminho de sucesso. A inversão pending → campaign e a janela de autorização permanecem abertas no código instalado.
- `public.srd_confirmar_critico_ataque_oportunidade_srd`: valida GM antes do lock, bloqueia a linha do ataque e depois atualiza `priv.srd_aoo_pending_movements` diretamente, sem lock explícito da campanha nem do pending. Confirma um caminho attack → pending que conflita com cancelamento/encerramento pending → attack; risco estrutural de deadlock, não evidência de deadlock já ocorrido.
- `public.srd_solicitar_movimento_com_aoo_srd`: no modo `gm`, valida `my_role(...)='GM'` antes do lock de `campaigns`; depois de obter o lock, valida turno/token, mas não repete a autorização GM. No modo `player`, propriedade e turno são verificados depois do lock da campanha. Isso cria uma assimetria de TOCTOU entre os dois modos.
- `public.srd_iniciar_ataque_oportunidade_monstro_srd` (sobrecarga de 4 argumentos): valida GM antes de bloquear pending e depois campanha; não revalida papel após os locks. A sobrecarga de 5 argumentos delega à de 4 argumentos e atualiza o ataque depois; a correção deve considerar a cadeia inteira, não só o wrapper.
- `public.srd_registrar_rolagem_ataque_oportunidade_srd` e `public.srd_confirmar_critico_ataque_oportunidade_srd` validam GM antes de bloquear a linha do ataque. A rolagem atualiza somente o ataque; a confirmação crítica também atualiza pending, conforme acima. Ambas devem ser avaliadas no protocolo de autorização/locks.

A ordem de `pg_get_functiondef` foi verificada diretamente no banco remoto; nenhum endpoint foi executado e nenhum teste concorrente foi feito no banco de produção. A validação da autorização sob lock precisa ser testada em banco descartável após a origem do schema-base ser recuperada.

### Proveniência do schema-base — limite histórico confirmado

A árvore Git atual contém migrations incrementais, snapshots e arquivos manuais/arquivados, mas não contém um dump restaurável do core legado. A árvore do commit inicial rastreável do repositório (`bd9ba612`, 2026-10-31 14:13 UTC) contém apenas 26 arquivos e 10 SQL; nenhum cria o core `public.campaigns`, `public.characters` e `public.members`. Os SQL raiz (`cba_iniciativa_migration.sql`, `vtt_dnd35_final_migration.sql`, `srd35_character_migration.sql`, `srd35_schema_reconciliation.sql`) já pressupõem tabelas centrais existentes ou criam objetos SRD dependentes delas. A primeira migration versionada (`20261031160944_srd35_action_economy.sql`) é posterior ao commit inicial e falha ao iniciar em banco vazio porque referencia `public.campaigns`.

Conclusão: o repositório rastreável desde sua primeira revisão não preserva a origem do schema-base. A fonte confiável precisa vir de export/schema-only dump do Supabase, backup antigo, histórico SQL externo ou outra revisão/repositório original; não fabricar tabelas mínimas para fazer CI passar.


Complemento da busca histórica: também foram inspecionadas as árvores das branches `audit/reconcile-supabase-migration-history`, `audit/restore-remote-migration-history`, `chore/archive-unversioned-supabase-sql` e `fix/restore-production-migration-history`. Elas contêm variantes incrementais, arquivos arquivados e documentos de reconciliação, mas nenhum dump/schema-only ou SQL que crie o core `campaigns`/`characters`/`members`. A busca em branches conhecidas não localizou a fonte; ainda pode existir backup externo, branch remota não listada ou export manual do projeto Supabase.

### Ciclo de lock concreto: confirmação crítica × cancelamento de movimento (2026-11-11)

A inspeção integral de `public.srd_confirmar_critico_ataque_oportunidade_srd` e `priv.srd_cancelar_movimento_aoo_pendente_impl` confirma um ciclo de locks específico:

- Confirmação crítica: `SELECT ... FROM priv.srd_aoo_attacks FOR UPDATE` adquire primeiro a linha do ataque; depois o `UPDATE priv.srd_aoo_pending_movements` adquire implicitamente a linha do pending.
- Cancelamento: `SELECT ... FROM priv.srd_aoo_pending_movements FOR UPDATE` adquire primeiro o pending; depois `UPDATE priv.srd_aoo_attacks` adquire implicitamente a linha do ataque.

Se as duas transações concorrentes tratarem o mesmo ataque/pending, uma pode segurar attack e esperar pending, enquanto a outra segura pending e espera attack. Isso demonstra um ciclo de espera possível no código (risco de deadlock), mas não prova ocorrência em produção; nenhum teste concorrente foi executado.

A confirmação crítica também não lê/bloqueia a linha pending antes da alteração, não confere que o pending continue em `waiting_reactions`, nem valida o estado anterior da reação correspondente. O update procura a reação por `reservation_id` e substitui seu status por `hit_pending_damage` sem precondição sobre o status atual. Uma consulta read-only reproduziu que, se o array não contém a reserva, o caminho JSONB derivado fica nulo e `jsonb_set` falha com `path element ... is null` (a transação aborta, não há sucesso silencioso). Mas, se a reserva existe em estado inesperado, a função sobrescreve esse estado sem rejeitar a transição. O FK attack→pending garante existência referencial, não consistência das máquinas de estado.

A correção deve fazer ambas as rotas obterem campaign → pending → attack, revalidar o status do pending e a identidade/estado da reação sob os locks, e verificar que exatamente a reação esperada foi atualizada antes de retornar sucesso. A transição attack + pending deve ser atômica e idempotente.

### CI atualizado — commit cfd924f

No commit `cfd924f48cf3792d77030abb099c06493b1d1ba1`, Static validation, Validate application JavaScript, Validate mesa JavaScript e PostgreSQL fixture tests concluíram sucesso. `Replay full Supabase migration baseline` falhou durante `Start disposable local Supabase stack only`, antes de executar as etapas separadas de replay/verificação. O log mostra uma limitação transitória de download Docker (`toomanyrequests: Rate exceeded`, seguida de retry) e, durante inicialização automática do banco, a primeira migration falhou ao resolver `public.campaigns` ausente (`SQLSTATE 42P01`). A causa estrutural já conhecida continua sendo ausência do schema-base no banco descartável; a limitação Docker é ruído adicional da inicialização. Não é falha no Supabase remoto.


### Escritor adicional de elegibilidade AOO sem serialização de campanha

A leitura integral de `public.srd_resolve_pending_spell_save(uuid,integer)` confirma uma rota autenticada que pode alterar condições relevantes para AOO sem obter lock da campanha:

- Primeiro bloqueia `priv.srd_pending_spell_resolutions FOR UPDATE`.
- Valida o jogador-alvo/Mestre depois desse lock.
- No ramo `v_pending.condition_break`, lê a rodada em `public.campaigns` sem `FOR UPDATE` e, se a resistência for bem-sucedida, desativa diretamente a condição em `public.srd_campaign_conditions`; se falhar, atualiza apenas as notas da condição.
- Esse ramo não chama `priv.srd_apply_pending_spell_resolution`, portanto não herda o campaign lock dessa implementação.

Como `priv.srd_condition_has_flag` usa `srd_campaign_conditions` para flags como `stunned`, `helpless`, `unconscious` e `no_actions`, a remoção de uma condição que corresponda a essas flags pode alterar a elegibilidade de reação AOO enquanto um movimento está pendente. O escritor não serializa com o pending AOO nem invalida/recalcula a decisão de elegibilidade já capturada. Não foi executado; achado estático do PL/pgSQL instalado.

Correção proposta: campaign → pending spell request → condição/efeito, revalidar status/rodada e serializar a mudança de condição com o pending AOO; ou invalidar atomicamente o pending se a condição afetar um ator/ameaça envolvido. Não congelar indiscriminadamente condições que sejam consequência legítima de uma reação em curso.


### CI mais recente confirmado — commit c912f49 (2026-11-11)

- Static validation: success (`42944067699`).
- Validate application JavaScript: success (`42944067629`).
- Validate mesa JavaScript: success (`42944067654`).
- PostgreSQL fixture tests: success (`42944067709`).
- Replay full Supabase migration baseline: failure (`42944067641`) no estágio `Start disposable local stack only`; as etapas explícitas de replay/verificação foram puladas. Log mostra rate limit temporário do registry Docker e, depois, falha da primeira migration `20261031160944_srd35_action_economy.sql` por ausência de `public.campaigns` (`SQLSTATE 42P01`). A falha não é no Supabase remoto; confirma que o banco descartável não tem o schema-base pré-ledger.

O commit documental atual é posterior a `c912f49`; os resultados acima são a última execução completa consultada para o conjunto anterior de documentação. Nenhuma alteração de código funcional foi feita nesta continuação.


### Confirmação de mais rotas no ciclo attack/pending e identidade ambígua no resolver (2026-11-11)

A leitura integral de `public.srd_resolver_ataque_oportunidade_srd` confirma a ordem attack → pending → campaign: bloqueia `priv.srd_aoo_attacks FOR UPDATE`, depois `priv.srd_aoo_pending_movements FOR UPDATE`, depois `public.campaigns FOR UPDATE`. Os endpoints autenticados `srd_aplicar_dano_ataque_oportunidade_srd` e `_monstro_srd` também bloqueiam attack → pending → campaign. Portanto, o ciclo com `priv.srd_cancelar_movimento_aoo_pendente_impl` (pending → attack) não se limita à confirmação crítica: pode ocorrer em resolução de ataque e aplicação de dano se competirem com cancelamento/encerramento do mesmo pending. Ainda é risco estático, não deadlock observado.

Também confirmei que o resolver procura ator e alvo em `campaigns.cba_data` usando `id = ... OR key = ... LIMIT 1`, sem contar correspondências nem exigir identidade única. A fixture já demonstrou que `salvar_cena_cba` pode deixar passar duplicação/colisão de `id` e `key`; assim, o resolver pode escolher uma das cópias sem detectar ambiguidade. Exigir identidade estável e única antes de resolver qualquer ataque, e usar a mesma regra em todos os escritores/leitores da cena.


### Avanço de nível é endpoint alcançável durante pending AOO (2026-11-11)

Confirmei o caminho completo até a interface: `ficha.html` chama `public.concluir_avanco_nivel_personagem_srd_v2` por `sb.rpc`. A RPC pública tem `EXECUTE` para `authenticated` e chama `priv.concluir_avanco_nivel_personagem_srd`, `SECURITY DEFINER` e também com `EXECUTE` para `authenticated` no catálogo remoto.

A implementação privada bloqueia `public.characters` e depois `public.srd_character_sheets`, mas não bloqueia `public.campaigns`, não consulta estado de combate e não verifica pending AOO. Quando existe nível pendente e XP suficiente, pode alterar nível/classe efetiva, atributos (nos níveis apropriados), perícias, talentos e PV. Classe/talentos/atributos são entradas diretas ou indiretas do perfil de ameaça AOO; logo, o jogador pode mudar premissas de uma reação já reservada se concluir o avanço durante combate/pending.

Não confundir com uma chamada REST direta ao schema `priv`: essa exposição ainda não foi confirmada. O wrapper público `public.concluir_avanco_nivel_personagem_srd_v2` é suficiente para confirmar que o fluxo é alcançável pelo cliente autenticado. A rota deve rejeitar avanço durante combate/pending ou adquirir campaign lock antes de personagem/ficha, revalidar XP/nível/ownership e invalidar/recalcular pending quando houver mudança de premissas. A sequência atual personagem → ficha também contraria o protocolo campaign-first proposto.

A migração local `20261110170000_lock_down_internal_helper_execute.sql` ainda não fecha essa rota: revoga EXECUTE de cinco helpers específicos, mas não da implementação de avanço de nível. Além disso, a migration ainda não consta no ledger remoto consultado anteriormente; não foi aplicada em produção.


### CI do commit 4e5d239 — fixtures aprovadas; replay falha antes das migrations (2026-11-11)

Execuções concluídas para `4e5d2390462501190652c04f851f04d8a1a7a6cc`: validação estática, JavaScript da aplicação, JavaScript da mesa e fixtures PostgreSQL passaram. O job `Replay full Supabase migration baseline` falhou em `Start disposable local stack only`; a etapa de replay nem começou. Log: tentativa de pull com `toomanyrequests: Rate exceeded`, depois primeira migration `20261031160944_srd35_action_economy.sql` falha com `relation public.campaigns does not exist` (SQLSTATE 42P01). Portanto, não é falha de uma migration posterior nem validação contra produção. O bloqueio de reconstrução do schema-base permanece.

A fixture PostgreSQL passou no commit atual, mas continua sendo uma reprodução isolada das invariantes específicas cobertas; não demonstra correção das lacunas AOO nem replay completo do banco.


### Aplicação de dano AOO: validação incompleta da reação e identidade divergente (2026-11-11)

Leitura integral das RPCs públicas autenticadas `srd_aplicar_dano_ataque_oportunidade_srd` e `_monstro_srd` confirmou:

1. Ambas validam `attack.status='awaiting_damage'` e `pending.status='waiting_reactions'`, mas não exigem que a reação correspondente (`reservation_id = attack.reaction_id`) exista exatamente uma vez e esteja em `hit_pending_damage`. Ao atualizar `pending_reactions`, localizam a entrada com `LIMIT 1` e substituem seu status por `damage_applied`, sem precondição de status da reação. Se a entrada não existir, a expressão do caminho JSONB fica nula e a transação aborta; não é sucesso silencioso. Se existir em estado inesperado, porém, pode ser sobrescrita.
2. As duas funções localizam o token alvo na cena apenas por `token.id = attack.target_token_id`, enquanto `srd_resolver_ataque_oportunidade_srd` aceita `id OR key` e usa `LIMIT 1`. Assim, um token que foi resolvido via `key` pode não ser encontrado na etapa de dano. A função natural também faz lookup por `id` apenas. Padronizar identidade única e o mesmo predicado/validação em iniciar, resolver, dano e writers CBA.
3. A ordem de locks segue attack → pending → campaign, ampliando o ciclo concorrente já documentado contra cancelamento pending → attack.

Correção: campaign → pending → attack; validar reação única em `hit_pending_damage` sob lock; rejeitar estados divergentes sem sobrescrevê-los; usar identidade canônica única em todas as etapas. Não foi aplicado dano nem executado teste de concorrência no banco remoto.


### Integridade relacional AOO: FKs não garantem campanha coincidente (2026-11-11)

Consulta direta a `pg_constraint` confirmou que `priv.srd_aoo_attacks.pending_id` referencia somente `priv.srd_aoo_pending_movements(pending_id)` e `reaction_id` referencia somente `priv.srd_aoo_reaction_ledger(reaction_id)`. Não existe FK composta que obrigue `attacks.campaign_id` a coincidir com a campanha do pending e do ledger. As chaves primárias globais impedem IDs duplicados, mas não impedem que uma linha de ataque carregue `campaign_id` diferente do pending/reaction apontado.

Os caminhos RPC examinados filtram por campaign_id e normalmente constroem relações na mesma campanha; portanto, isso é uma lacuna de integridade defensiva do schema, não evidência de exploração atual. Adicionar unicidade composta nos pais e FKs compostas (ou validação equivalente por trigger/constraints) para garantir que ataque, pending e reação pertençam à mesma campanha. Manter também as unicidades atuais de reação e idempotência.


### Iniciadores de ataque também não exigem reação única no JSON do pending (2026-11-11)

Leitura integral das RPCs autenticadas `srd_iniciar_ataque_oportunidade_srd` e `srd_iniciar_ataque_oportunidade_desarmado_srd`: ambas selecionam a reação em `pending_reactions` por `reactor_token_id` com `LIMIT 1`, sem contar correspondências. Depois verificam status `reserved` e igualdade do `reservation_id`, e consultam o ledger com campanha/ator/rodada. A unicidade do ledger protege a linha relacional, mas não impede entradas duplicadas do mesmo reator no array JSON do pending. Uma duplicação pode levar a escolher uma entrada arbitrária ou rejeitar a reserva válida dependendo da ordem do array.

O mesmo padrão de `LIMIT 1` sem contagem aparece no resolver e na atualização de dano. A correção deve validar uma única entrada por `reactor_token_id`/`reservation_id` antes de iniciar, resolver ou aplicar dano, e rejeitar arrays inconsistentes sem selecionar uma cópia arbitrária. Não foi alterado dado remoto.


### CI confirmado no commit e189419 — 2026-11-11

No commit `e18941910f54d2bf537384e3fb1eb2b20ead257c`, as verificações estática, JavaScript da aplicação, JavaScript da mesa e fixtures PostgreSQL isoladas concluíram com sucesso. O replay integral das 969 migrations falhou novamente na inicialização/replay do banco descartável, antes de chegar às migrations posteriores: a primeira migration `20261031160944_srd35_action_economy.sql` tenta usar `public.campaigns`, inexistente no banco vazio. O job não chegou às etapas de verificação de histórico/objetos. Log mais recente não mostra rate limit como causa principal; o bloqueio reproduzível é a ausência do schema-base. Nenhuma alteração no banco remoto.

A auditoria das constraints/indexes confirmou unicidade global de attack_id/pending_id/reaction_id, unicidade de attack por reaction_id, idempotência de ataque/dano, um pending ativo por campanha e unicidade do ledger por ordinal e trigger. Porém, não existem índices únicos compostos `(campaign_id,pending_id)` e `(campaign_id,reaction_id)` nos pais nem FKs compostas correspondentes no ataque. Logo, os relacionamentos FK atuais não impõem a mesma campanha em todos os três registros.

As rotas de início (arma, desarmado e ataque natural de monstro) autenticadas usam `LIMIT 1` para selecionar reação no array `pending_reactions`, sem contar duplicatas. O wrapper de ataque natural com índice delega à rota de 4 argumentos; não deve ser auditado como implementação independente de lock. As rotas-base mantêm pending → campaign e validação GM antes dos locks, sem revalidar o papel após adquirir campanha.


### Confirmação crítica não valida o ciclo de vida do pending (2026-11-11)

A definição instalada de `public.srd_confirmar_critico_ataque_oportunidade_srd` confirma o estado do ataque (`awaiting_critical_confirmation`), mas depois atualiza `priv.srd_aoo_pending_movements` por `pending_id` sem exigir que o pending ainda esteja `waiting_reactions` e sem exigir que a reação vinculada esteja única e em `hit_pending_damage` (estado anterior esperado após o acerto). A subconsulta da posição usa `LIMIT 1`; se não encontrar reação, o caminho JSONB nulo faz a transação abortar; se encontrar entrada em estado diferente, ela é sobrescrita.

Isso torna mais grave a inversão attack → pending contra cancelamento pending → attack: se a confirmação for retomada após o cancelamento ter sido revertido por deadlock, pode avançar ataque/reação sem validar o estado atual do movimento. Corrigir em conjunto: campaign → pending → attack; após os locks, revalidar pending ativo, ataque aguardando confirmação, e exatamente uma reação vinculada no estado anterior esperado; só então transicionar ambos atomicamente. Não foi executada concorrência no remoto.


## Continuidade consolidada — 2026-11-11 (execução por estágios)

- Método de execução: trabalhar por estágios completos, sem relatórios de micro-etapas. O estado oficial permanece neste documento/roadmap; retomar do delta documentado, sem repetir auditorias concluídas.
- PR #74 permanece aberto, draft e sem merge. HEAD de referência antes desta atualização: `6092c4695da8b8f1e733a3920aef99b19a29d503`. A atualização documental de fonte canônica de XP/ouro foi registrada em commit próprio; confirmar HEAD/CI após o commit.
- CI no HEAD anterior: static validation, application JS, mesa JS e PostgreSQL fixtures concluídos com sucesso; replay de migrations falhou ao iniciar o stack/reproduzir a primeira migration porque `public.campaigns` não existe no banco vazio. O job não chegou a aplicar migrations. Logs confirmam erro SQLSTATE 42P01 em `20261031160944`; não contornar com tabela mínima artificial.
- Estado remoto read-only confirmado nesta execução: PostgreSQL 17.6; 966 migrations aplicadas, última `20261109005941`; 76 tabelas public e 225 rotinas public no snapshot consultado. A branch contém 969 arquivos de migration: as três adicionais são candidatas locais `20261110150000`, `20261110160000`, `20261110170000`, ainda não aplicadas remotamente. Nenhuma foi aplicada nesta execução.
- Fonte canônica de XP/ouro SRD foi refinada em `DATA_MODEL.md`: `characters.xp` é autoridade do total de XP e `srd_character_sheets.xp` é espelho; `srd_character_sheets.ouro` preserva o saldo preciso NUMERIC e `characters.ouro` é espelho inteiro de compatibilidade. Evidência agregada read-only: XP coincide em 5/5 fichas; ouro diverge em 5/5 (288 inteiros no modelo base vs. 292,50 no SRD), consistente com o piso aplicado ao salvar equipamento inicial. Não corrigir dados existentes por inferência.
- A Fase 1 do roadmap continua **em andamento**: faltam cruzamento completo de argumentos/tipos JS↔PostgreSQL, decisões dos demais valores derivados, fechamento do grafo transitivo de locks/concorrência e estratégia de testes de integração/E2E. A arquitetura escrita é proposta; não confundir documentação com implementação.
- A Fase 2+ depende de ambiente descartável reproduzível. Não criar branch/projeto Supabase pago; não alterar schema, funções, ACLs, policies, dados, campanhas ou deploy no projeto remoto sem autorização específica.
- Próxima execução: continuar o fechamento de contratos do domínio SRD com foco em campos derivados/sincronização e cruzamento dos call sites ativos; manter o bloqueio de replay até obter bootstrap histórico confiável. Usar apenas o delta após o último HEAD auditado.


### Contratos JavaScript ↔ RPC — delta verificado em 2026-11-11

- Revarredura dos três arquivos ativos encontrou 144 chamadas `.rpc()`, 99 nomes literais distintos e quatro call sites dinâmicos; os 99 nomes literais existem no schema `public`, com 107 assinaturas públicas correspondentes.
- Comparação de propriedades dos objetos de argumentos com nomes de parâmetros das sobrecargas não encontrou incompatibilidade após revisão manual de dois falsos positivos do parser. Isso valida nomes, não tipos/semântica em runtime.
- Dispatches dinâmicos foram reidentificados: dano AOO (2 destinos), equipamento/instâncias na mesa (3), salvamento/resistência de magia (2) e equipamento na ficha (4 alternativas, com sobreposição). A contagem histórica 100/106/114 diverge do delta 99/144/107 e permanece marcada para reconciliação de metodologia, sem apagar a fotografia anterior.
- O inventário foi atualizado em `docs/RPC_INVENTORY.md`. A Fase 1 continua aberta até cruzar tipos/overloads em runtime, completar o grafo transitivo e fechar a política de concorrência e os contratos de estado.


### Lacuna arquitetural de progressão multiclasse — 2026-11-11

- A RPC pública de avanço `concluir_avanco_nivel_personagem_srd_v2` não recebe a classe escolhida para o novo nível. A implementação privada sempre usa `srd_character_sheets.classe_id` e trata `sheet.nivel+1` como nível da classe, atualizando somente a classe primária.
- O ledger `srd_character_class_levels` é escrito com `taken_at_character_level=1` na primeira inserção, não com o nível total em que aquela classe foi adquirida.
- O snapshot atual (5 fichas, todas com ledger, soma dos níveis de classe igual ao nível total) contém apenas linhas nível 1; portanto não prova que multiclasse esteja funcionando. Não há evidência de dano aos personagens atuais, mas o contrato é insuficiente para o escopo completo D&D 3.5.
- Registrar como bloqueio de arquitetura do motor de regras/progressão: separar nível total e nível por classe, permitir escolha de classe a cada avanço, calcular progressões/benefícios por classe e registrar corretamente `taken_at_character_level`. Não corrigir apenas na interface; requer contrato de servidor, validação de pré-requisitos e testes de progressão multiclasse.
- Detalhes adicionados a `docs/DATA_MODEL.md`. Nenhuma alteração de código ou banco foi feita.
