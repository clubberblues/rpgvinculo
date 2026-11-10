# PostgreSQL fixture tests

Executados em um serviço PostgreSQL descartável no GitHub Actions. Não se conectam ao Supabase, não leem nem alteram campanhas reais e não são migrations.

## Footprint D&D 3.5

- O fixture contém cópias capturadas das definições de public.srd35_normalizar_parametro_talento e priv.srd_token_grid_footprint (snapshot de 2026-11-09).
- Asserções cobrem categorias de tamanho e footprint, aliases em português, fallback de raça do jogador vinculado, busca por key, tamanho desconhecido e rejeição de token duplicado.
- O teste valida o helper canônico isoladamente. Não demonstra que movimento, ataque, spawn e AOO usam o helper; a auditoria ainda encontrou lógica geométrica divergente nesses caminhos.

## Concorrência e locks

O script lock_cycle_test.sh modela nove padrões sintéticos de inversão e um controle positivo:

1. campanha → instância de arma versus instância de arma → campanha (início PC de Ataque Total versus resolução).
2. campanha → personagem versus personagem → campanha.
3. campanha → pending AOO versus pending AOO → campanha.
4. pending AOO → ataque versus ataque → pending AOO.
5. campanha → personagem → ficha → recurso de classe versus personagem → ficha → recurso → campanha (condicional à colisão da mesma linha de personagem/recurso).
6. campanha → personagem → ficha versus personagem → ficha → campanha (conjuração multialvo e estabilização).
7. campanha → ataque versus ataque → pending → campanha (mudança de estado do combate versus resolução AOO).
8. sequência NPC → campanha versus campanha → tentativa → sequência NPC.\n9. campanha → marcador de exclusão versus marcador de exclusão → campanha (preparação versus finalização de exclusão em duas fases).

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


Nota de execução (2026-11-10): os primeiros runs #116 e #117 falharam no harness novo, não nos oito testes de deadlock existentes. A sincronização inicial usava advisory-lock polling que podia monopolizar a barreira e expirar; foi substituída por eventos de fixture confirmados em commits/autocommit e por duas conexões independentes. O controle campaign-first usa o lock real da linha de campanha e espera a transação de revogação. A versão corrigida passou em CI #284 [42751013687](https://github.com/clubberblues/rpgvinculo/actions/runs/42751013687), #285 [42751022904](https://github.com/clubberblues/rpgvinculo/actions/runs/42751022904) e #293 [42751317308](https://github.com/clubberblues/rpgvinculo/actions/runs/42751317308); o cenário não está mais pendente.


### Administração da campanha e membership

Os novos testes também modelam, em transações PostgreSQL concorrentes, o risco de `gm_set_role`/`gm_kick`:
- Reprodução: a sessão A valida `owner_id` enquanto ainda é owner, pausa dentro da transação, a sessão B transfere ownership e rebaixa A, e A ainda consegue expulsar um membro porque não bloqueou/revalidou a campanha.
- Controle: a sessão que transfere ownership bloqueia a linha da campanha primeiro; a solicitação antiga espera, relê owner após o lock e é rejeitada.

A mesma família inclui `gm_transfer` e o início de iniciativa (`iniciar_iniciativa_com_dados`), que valida GM antes do lock de campanha. Os fixtures são sintéticos e não executam as RPCs instaladas.


### Trigger de papel na transferência de propriedade

Fixture adicional replica a lógica do trigger `enforce_campaign_member_role` e a ordem atual de `gm_transfer`: primeiro altera os papéis dos membros, depois altera `owner_id`. O teste espera confirmar que o trigger mantém o antigo owner como GM e rebaixa o novo para PLAYER. Um controle executa a transferência owner-first sob lock da campanha e espera os papéis coerentes. É um modelo fiel da lógica instalada, mas não chama a RPC real nem altera o banco remoto.


### Revalidação GM depois de esperar pelo lock da campanha

Fixture reproduz o padrão dos wrappers `srd_apply_campaign_condition`/`srd_apply_campaign_effect`: a sessão A lê role=GM, depois aguarda para adquirir o lock da campanha; sessão B adquire o lock, rebaixa GM para PLAYER e confirma; A adquire o lock e, sem revalidar o papel, grava efeito. O controle adquire primeiro o lock e só então verifica role, rejeitando a chamada antiga. É modelo sintético da ordem observada nos corpos das funções; não invoca RPCs reais.


### Família de endpoints owner: alteração de código

Fixture reproduz `gm_set_code`: owner antigo valida autorização, aguarda, ocorre transferência e o owner antigo ainda altera o código. Controle usa campaign FOR UPDATE e revalida owner após o lock, rejeitando a mutação. O teste não executa a RPC instalada; modela a ordem SQL e o gate de propriedade.

O mesmo harness também modela `gm_set_role`: owner antigo valida, transfere-se a propriedade e a alteração de papel ainda é aplicada. O controle campaign-first espera o lock e rejeita a autorização antiga. Os fixtures continuam sintéticos e descartáveis.


### Ficha GM: reabertura e bônus

O fixture de ficha modela as mutações de `gm_reopen_sheet` e `gm_set_bonus`: o GM valida papel, perde o papel durante uma transferência/revogação serializada na campanha e, no cenário vulnerável, ainda altera os dados da ficha. O controle adquire campaign FOR UPDATE antes da validação definitiva e rejeita a operação antiga. É um teste sintético da ordem/garantia, não uma chamada à RPC de produção.


### Endpoints GM — grants e remoções

- `gm_grant`: fixture sintética de stale GM check antes do lock do personagem e controle campaign-first que rejeita após revogação. Não executa a RPC real nem valida o branch de concessão de item.
- `srd_remove_campaign_condition/effect`: fixture de stale GM check seguido de remoção direta e controle campaign-first. A aplicação de efeito é coberta por fixture própria.
- Os testes modelam concorrência e autorização, não substituem integração autenticada contra as funções instaladas.


## Ciclo de vida de NPC vinculado e exclusão de ficha

`npc_lifecycle_test.sql` é executado pelo mesmo script de harness. Ele usa tabelas temporárias descartáveis para verificar o contrato proposto de remoção de um token:
- remover somente o token selecionado da cena e da ordem de iniciativa;
- limpar equipamento, instâncias, condições e sequências/attempts daquele token;
- cancelar pendências AOO/magia ligadas ao token;
- encerrar efeitos em que o token era fonte/concentrador;
- preservar o estado de outros tokens na mesma campanha;
- exigir ausência de todas as referências JSON `sourceCharacterId` antes de excluir a ficha-fonte;
- modelar a FK `ON DELETE RESTRICT` de sequência NPC para personagem.

O teste é intencionalmente sintético: não executa `excluir_ficha_propria`, nenhuma RPC de remoção (que ainda não existe), triggers reais, RLS, nem banco Supabase. Ele valida invariantes e a transação-modelo, não uma implementação de produção. A migration/RPC futura deverá adaptar os estados terminais e as relações ao schema efetivo, e incluir autorização GM e lock campaign-first com revalidação.


### CI do fixture de lifecycle

- GitHub Actions #198 [42742904531](https://github.com/clubberblues/rpgvinculo/actions/runs/42742904531) concluiu **success** no commit `cb8c2f6c2ad923a92abb562df56296c30ec2d41d`. O log confirma o bloco temporário do lifecycle (10 tabelas temporárias, verificações DO, limpeza seletiva e ROLLBACK) antes dos testes de concorrência.
- O teste continua sendo modelo de contrato, não integração com as RPCs reais.


CI #208 [42743669088](https://github.com/clubberblues/rpgvinculo/actions/runs/42743669088) concluiu **success** no commit `cc1c5c7c179e289afd96a097c763884aa55bc63d`. O log confirma 12 assertions com CHECK, incluindo a sequência NPC remanescente que mantém a ficha-fonte referenciada e a definição da FK `ON DELETE RESTRICT`; a transação termina em ROLLBACK. O fixture usa 11 tabelas temporárias e não executa RPCs reais.


### Exclusão de campanha em duas fases

O harness também reproduz a inversão potencial entre `preparar_exclusao_campanha_propria` (campanha → marcador `priv.campaign_deletion_cleanup`) e `finalizar_exclusao_campanha_propria` (marcador → campanha). A reprodução é sintética e usa a tabela descartável `lock_fixture.campaign_deletion_cleanup`; não executa os wrappers nem as implementações privadas reais.


- CI #212 [42744027422](https://github.com/clubberblues/rpgvinculo/actions/runs/42744027422) concluiu **success** no commit `5da5948f1478a69a77d4644bb5dd86eaf021359e`. O log confirma o nono cenário de inversão: campanha → cleanup versus cleanup → campanha, reproduzindo o ciclo do fluxo de exclusão em duas fases. Os oito padrões anteriores, o controle positivo, o fixture de lifecycle e os demais cenários de autorização também passaram. O commit posterior alterou somente documentação.


### Upload de Storage versus exclusão de campanha

O fim de lock_cycle_test.sh modela o contrato campaign KEY SHARE no caminho de upload versus campaign FOR UPDATE na preparação/finalização:
- Se o upload adquire KEY SHARE primeiro, a preparação aguarda seu commit e só depois grava o marcador; o objeto já criado fica visível para a limpeza.
- Se a preparação grava o marcador primeiro, o upload aguarda o lock, relê o marcador e é rejeitado sem inserir objeto.

O teste usa uma função/tabela fictícia no schema lock_fixture. Não chama RLS, Storage API, buckets, policies, RPCs nem dados Supabase reais. Serve para validar a compatibilidade dos locks PostgreSQL; não substitui o teste concorrente com dois usuários autenticados e upload real exigido em docs/STORAGE_ACCESS_CONTRACT.md.


### Zero-check e retry do finalizador de campanha

O harness contém um modelo de finalizador que adquire locks na ordem campaign → cleanup, revalida o proprietário e o marcador, e só conclui quando a tabela fictícia de objetos Storage está vazia. A fixture verifica proprietário incorreto, recusa com objeto restante preservando campanha+marcador, e retry bem-sucedido depois da remoção do objeto. Isso não valida `storage.objects`, RLS, Storage API nem a RPC de produção; comprova apenas o contrato esperado no modelo PostgreSQL descartável.


A fixture modela deliberadamente ausência de FK entre marcador/campanha e objeto Storage/campanha. O novo caso cria campanha ausente + marcador residual + objeto órfão, exige recusa do finalizador e preservação do marcador, remove o objeto e só então aceita retry.

## Reproducer isolado da guarda de movimento AOO

- `aoo_guard_duplicate_identity_repro.sql` copia para um schema descartável o algoritmo atual de `priv.srd_guard_pending_aoo_movement` (OID 26962).
- Confirma que uma alteração direta das coordenadas do único token mover é bloqueada e que uma atualização de metadados não geométricos é permitida.
- Reproduz quatro lacunas conhecidas: (a) duplicar a identidade do token mover, mantendo a primeira cópia na origem e deslocando a segunda, passa pela busca `LIMIT 1`; (b) a geometria de outro token pode mudar enquanto há pending; (c) facção e alcance corpo a corpo de uma ameaça podem ser alterados; (d) um novo token ameaçador pode ser inserido na cena.
- **Interpretação do CI:** este é um reproducer de vulnerabilidade conhecida, não um teste de aprovação de segurança. Um run verde significa que a fixture conseguiu reproduzir o comportamento documentado do algoritmo copiado. Quando a implementação for corrigida, o fixture deverá ser convertido em regressão negativa (as tentativas devem ser rejeitadas).
- O fixture não importa nem executa a função instalada, não chama RPC, não acessa Auth/PostgREST e não conecta ao Supabase. A cópia precisa ser comparada com o corpo remoto quando o trigger mudar.


- Execução confirmada para a versão anterior do reproducer: PostgreSQL fixture #284 [42751013687](https://github.com/clubberblues/rpgvinculo/actions/runs/42751013687), #285 [42751022904](https://github.com/clubberblues/rpgvinculo/actions/runs/42751022904) e #293 [42751317308](https://github.com/clubberblues/rpgvinculo/actions/runs/42751317308) concluíram **success**; os logs mostram a reprodução da duplicata e da alteração geométrica de outro token. A validação estática, aplicação JS e mesa JS também passaram no head 041f0b5.
- A versão ampliada agora inclui também facção/alcance e inclusão de token novo. Ela foi adicionada depois do run #42808666665 e ainda não tem execução CI confirmada no head atual.


### Execução integral mais recente do harness

- PostgreSQL fixtures run [42808666665](https://github.com/clubberblues/rpgvinculo/actions/runs/42808666665), no commit 1b1a85d346cdc123dd3afd56302273f4f675a707: **success**. Logs confirm footprint assertions, controle de movimento único bloqueado, bypass por identidade duplicada reproduzido, mudança de geometria do token ameaçador reproduzida, fixture de lifecycle NPC, nove inversões sintéticas e controles de autorização/Storage.
- O job terminou com sucesso porque as reproduções vulneráveis estão escritas como expectativas positivas de demonstração. Isso não significa que o trigger de produção esteja corrigido; o arquivo copia seu algoritmo atual e deve virar regressão negativa após a correção real.
- A execução foi em PostgreSQL descartável; nenhuma RPC Supabase, Auth/PostgREST ou campanha real foi chamada.


## Regressão de privilégios das RPCs de manobra e helpers internos

- `maneuver_catalog_security_fixture.sql` usa roles e objetos PostgreSQL descartáveis; aplica as migrations `20261110150000`, `20261110160000` e `20261110170000`, seguidas pelos três scripts de verificação.
- Verifica que os wrappers GM de manobra/ataques naturais executam como SECURITY DEFINER com search_path fixo, aceitam GM autenticado e rejeitam jogador.
- Verifica que authenticated/anon não executam diretamente helpers de condições, talentos, parser de ataques naturais ou implementações privadas de Ataque Total; os chamadores SECURITY DEFINER continuam funcionando.
- Verifica que as duas entradas públicas de Ataque Total rejeitam ficha que não pertence ao usuário e que o helper de 7 argumentos mantém a defesa de propriedade mesmo em chamada privilegiada.
- **Limite:** o fixture valida as migrations e ACLs num PostgreSQL isolado. Não chama PostgREST, Auth real, RPCs instaladas nem o Supabase de produção; a exposição efetiva do schema `priv` na configuração PostgREST continua não confirmada. CI ainda precisa executar o novo fixture no HEAD atual.


### Correção da fronteira transacional na fixture de permissões — 2026-11-10

O run PostgreSQL no commit `635bdf1` revelou a causa da falha após as migrations de teste: o arquivo iniciava uma transação externa, mas cada migration aplicada com `\i` contém seu próprio `BEGIN/COMMIT`. O `COMMIT` da primeira migration encerrou a transação externa. Consequentemente, os `set_config(..., true)` seguintes eram locais apenas à própria instrução e desapareciam antes da chamada da RPC simulada. O preflight registrou `auth.uid() = NULL` e `my_role() = NULL`, explicando corretamente o bloqueio GM.

Correção aplicada: iniciar uma nova transação imediatamente depois dos scripts de migration/verificação e antes de definir o role authenticated e os claims JWT. Assim, os claims locais permanecem visíveis durante os testes e o `ROLLBACK` final limpa os dados de teste posteriores. Commit `c21490e`; aguarda execução CI própria.
