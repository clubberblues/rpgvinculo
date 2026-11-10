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
