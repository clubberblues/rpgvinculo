# Protocolo global de locks — proposta para revisão

Status: **rascunho de arquitetura; não aprovado para implementação**  
Data: 2026-11-09  
Base: inspeção read-only dos corpos SQL remotos, triggers e writers de `campaigns`.

Este documento consolida uma direção candidata para eliminar inversões de locks. Não é migration, não altera o banco e não declara que todas as dependências transitivas foram mapeadas. A implementação fica bloqueada até reconciliação de migrations, revisão por assinatura/OID e testes em PostgreSQL efêmero.

## 1. Invariante principal

Para qualquer operação que altere estado de uma campanha, adquirir primeiro o lock da linha `public.campaigns` correspondente (`FOR UPDATE`), antes de bloquear personagens, fichas, recursos, efeitos, condições, inventário, armas, pendências, ataques ou logs relacionados.

Quando a campanha ainda não é conhecida, ler o `campaign_id` sem lock apenas para localizar o agregado; depois bloquear a campanha e revalidar, sob lock, que o personagem/token ainda pertence à campanha e que o chamador mantém autorização.

Uma transação não pode adquirir um lock de categoria anterior depois de já manter um lock de categoria posterior. Os triggers devem respeitar a ordem herdada do chamador e não criar caminhos reversos.

## 2. Ordem candidata dentro de uma campanha

A sequência abaixo é uma hipótese inicial, não uma ordem final validada:

1. `campaigns` — lock do agregado/serialização de combate e cena.
2. `characters` — todos os IDs necessários em ordem crescente e estável.
3. `srd_character_sheets` — mesma ordem estável de character_id.
4. `srd_character_feature_resources` — por character_id e feature_key.
5. `srd_character_equipment` — por character_id/equipment_id.
6. `srd_character_weapon_instances` — por character_id/instance_id.
7. `srd_campaign_effects` — por campaign_id/target_kind/target_id/effect_instance_id.
8. `srd_campaign_conditions` — por campaign_id/target_kind/target_id/condition_instance_id.
9. Estado pendente de ação: `priv.srd_aoo_pending_movements` e `priv.srd_pending_spell_resolutions`, com ordem determinística por pending_id quando houver mais de uma.
10. Registros de reação/ataque: `priv.srd_aoo_attacks`, `priv.srd_aoo_reaction_ledger`, `public.srd_attack_sequences`, `public.srd_attack_sequence_attempts`, `public.srd_npc_attack_sequences` e `public.srd_npc_attack_attempts`. A relação entre essas tabelas ainda precisa de revisão de todas as transições; ordenar por chave estável e não misturar a ordem entre wrappers.
11. `campaign_log` e demais registros append-only, ao final.

A posição relativa entre efeitos/condições, recursos/inventário e os diferentes ledgers ainda deve ser validada contra todos os triggers e funções. A lista não autoriza aplicar locks indiscriminadamente: cada endpoint deve bloquear apenas os registros necessários, mas sempre respeitar a ordem global.

## 3. Evidências que motivam a proposta

### Ciclos já identificados nos corpos remotos
- Campanha ↔ efeito de Fúria: trigger de avanço de rodada e expiração campaign-first; encerramentos manuais/legados podem bloquear efeito antes da campanha.
- Pending AOO ↔ ataque: cancelamento/encerramento bloqueia pending → attack; resolução/dano/ocultação bloqueia attack → pending.
- Campanha ↔ arma: início de sequência iterativa overload 7 bloqueia arma antes da campanha; resolução bloqueia campanha e depois pede `FOR SHARE` na instância.
- Campanha ↔ personagem/ficha: descanso longo de NPC vinculado bloqueia campanha → personagem → ficha; ações de classe e entrypoints de conjuração podem bloquear personagem → ficha → campanha.
- Efeitos, condições e PV: helpers de sincronização de condição não bloqueiam sempre campanha primeiro; a ordem depende do chamador.
- Inventário/arma: trigger AFTER INSERT/DELETE/UPDATE OF quantidade em `srd_character_equipment` cria/remove instâncias; operações de equipamento também alteram as duas tabelas e precisam ser harmonizadas.

### O que já passou em teste
O workflow PostgreSQL efêmero detectou deadlocks em três pares sintéticos:
- campaign → effect versus effect → campaign;
- campaign → weapon versus weapon → campaign;
- campaign → character versus character → campaign.

Execução: https://github.com/clubberblues/rpgvinculo/actions/runs/42670106095

Esses testes demonstram o comportamento do PostgreSQL para os padrões montados; não executam RPCs reais nem provam ocorrência em produção.

## 4. Regras de implementação que devem acompanhar a ordem

- **Revalidar após adquirir locks:** autorização, vínculo campanha/personagem, ownership, papel, estado de combate, turno, pending, equipamento e status precisam ser confirmados dentro da transação serializada.
- **Ordenar locks múltiplos:** ao afetar dois ou mais personagens/alvos, ordenar IDs de forma estável antes de `FOR UPDATE`; não depender da ordem do array JSON ou do frontend.
- **Wrappers finos:** wrappers públicos devem autenticar/validar a interface e delegar a uma implementação interna que siga o protocolo; não podem adquirir locks adicionais em ordem diferente antes da delegação.
- **Triggers previsíveis:** triggers não devem chamar RPCs que tentem adquirir lock de campanha depois de o chamador manter locks posteriores. Registrar explicitamente os locks transitivos de cada trigger.
- **JSONB da campanha:** mutações de `cba_data`/`combat_data` devem partir do registro lido sob lock; evitar substituir snapshots enviados pelo cliente. Preferir comandos parciais e validação de revisão.
- **Idempotência:** request_id/idempotency_key protege retries e duplicações; não substitui locks nem validação de estado.
- **Sem lock advisory isolado:** advisory lock não substitui o lock da linha `campaigns` enquanto existirem writers que não o adquirem. Só considerar se todos os pontos de entrada e triggers forem cobertos e o namespace/chave forem formalizados.
- **Operações fora de campanha:** fluxos de criação/edição de ficha sem campanha devem seguir ordem própria e não podem chamar helpers que tentem adquirir campanha depois de bloquear personagem/ficha. Se passarem a atuar em campanha, devem localizar e bloquear campanha antes dos locks da ficha.

## 5. Bloqueios antes de qualquer migration

1. Reconciliar as 966 versões remotas com os 681 arquivos locais; não reaplicar nem reconstruir histórico por inferência.
2. Construir mapa validado de chamadas por OID/assinatura para cada entrypoint, overload, helper e trigger; regex por nome serve apenas para descoberta.
3. Classificar todos os 52 escritores diretos de `campaigns` e os escritores de recursos/efeitos/condições/pendências/ataques/inventário.
4. Confirmar todos os caminhos usados por `mesa.html`, incluindo wrappers dinâmicos e RPCs legadas ainda concedidas.
5. Criar fixtures efêmeras que reproduzam os corpos ou módulos SQL extraídos, incluindo rollback, retries, duas sessões e efeitos colaterais de triggers.
6. Executar testes de autorização e integridade em ambientes descartáveis; Auth/RLS/PostgREST não devem ser considerados verificados por simples fixtures PostgreSQL.
7. Só então preparar migration reconciliada, revisar diff, testar reversão/compatibilidade e submeter para autorização específica antes de qualquer mutação remota.

## 6. Critério de aceite

A ordem só será considerada implementada quando:
- todos os entrypoints e overloads ativos respeitarem a mesma ordem;
- triggers e chamadas transitivas não introduzirem locks anteriores fora de ordem;
- testes concorrentes cobrirem Fúria, avanço/encerramento de combate, AOO, conjuração, recursos de classe, inventário, armas e ataques iterativos;
- duas sessões concorrentes não produzirem deadlock nos cenários previstos;
- retries forem idempotentes e nenhum PV, recurso, item, posição, condição ou estado de combate for perdido;
- testes de autorização confirmarem que nenhum ajuste de locks ampliou o acesso de jogadores/Mestres;
- migrations e estado remoto estiverem reconciliados.

**Decisão atual:** manter como proposta de arquitetura e continuar a auditoria. Nenhuma alteração no Supabase remoto está autorizada por este documento.


## Atualização da matriz — conjuração e recursos de classe (2026-11-09)

A ordem candidata anterior ainda não está apta para aprovação. A inspeção remota identificou dois pares adicionais que a contradizem:

1. **Campanha ↔ ficha SRD**
   - Resolução pendente: `priv.srd_apply_pending_spell_resolution` → pending → campaign → `srd_character_sheets`.
   - Conjuração multialvo: `public.conjurar_magia_efeitos_multialvo` → character → sheet → `public.consumir_acao_turno_srd` → campaign.
   - Mesmo personagem/campanha pode produzir ciclo campaign ↔ sheet se uma magia pendente for resolvida enquanto o personagem-alvo tenta conjurar.

2. **Campanha ↔ recurso de classe**
   - `public.usar_furia_barbaro_npc_srd` / descanso de NPC: campaign → character → sheet → feature resource.
   - `public.usar_habilidade_classe_srd`: character → sheet → feature resource → campaign, em caminhos com campanha/alvo.
   - A alcançabilidade no estado atual não foi demonstrada: consulta agregada encontrou 3 tokens NPC vinculados e todos os respectivos source characters estão com `campaign_id IS NULL`. Manter como risco preventivo para futuras combinações de dados, não como deadlock operacional confirmado.

**Consequência para o protocolo:** não basta ordenar campanha → personagem → ficha → recursos. A ordem precisa ser reconciliada por fluxo de domínio e pode exigir separar locks de campanha para consumo de ação de locks de persistência da ficha, ou mover o lock de campanha para antes do lock de ficha nos entrypoints que atualmente fazem o contrário. Nenhuma alternativa deve ser aplicada até revisar todas as sobrecargas, wrappers, chamadas transitivas e semântica de autorização.

Os cenários campaign ↔ sheet e campaign ↔ feature resource foram acrescentados ao harness sintético. Eles verificam somente a detecção de deadlock pelo PostgreSQL em tabelas descartáveis, não executam RPCs remotas.


## Atualização — Fúria, encerramento e triggers transitivas (2026-11-09)

A revisão por OID refinou o caminho de Fúria: `public.end_combat(bigint)` (OID 19091) percorre efeitos com `FOR UPDATE` e chama os encerradores antes do UPDATE final de `campaigns`. O trigger `priv.srd_expire_barbarian_rage_on_round_change()` (OID 26292) é executado após UPDATE de `combat_data`, quando a linha campanha já está bloqueada, e então bloqueia os efeitos de Fúria. A ordem é conflitante: **end_combat: efeito → ficha/condições → campanha** versus **trigger de rodada: campanha → efeito → ficha/condições**. O ramo NPC do encerrador também adquire efeito → campanha diretamente. O mesmo `end_combat` encerra ataques AOO antes das pendências, mantendo o segundo conflito attack ↔ pending.

O harness recebeu um caso nomeado para o caminho composto `effect → sheet → campaign` versus `campaign → effect`. Ele usa apenas tabelas e duas sessões PostgreSQL sintéticas. Resultado esperado é a detecção de um deadlock deliberadamente montado; isso não constitui reprodução das RPCs nem evidência de deadlock ocorrido em produção. Nenhuma função, trigger ou dado remoto foi alterado.

A trigger de solicitação de rolagem por Confusão também adquire condição e log após o UPDATE de campanha. O helper de vitalidade de personagem atualiza condições e depois apenas lê campanha sem lock explícito; não confundir leitura MVCC com aquisição de lock de linha.

**Decisão:** manter o protocolo global como rascunho. A correção precisa harmonizar a ordem no encerramento de combate, expiração de Fúria e transições AOO, incluindo efeitos de trigger, antes de aprovar qualquer migration.


## Atualização — encerramento de Fúria e remoções diretas (2026-11-09, revisão adicional)

Esta atualização foi feita após inspeção dos corpos remotos por OID/assinatura e dos triggers ativos. Ela refina, sem substituir, as evidências anteriores.

### 1. Fúria — efeito → campanha é um caminho legado, não ciclo ativo comprovado

Os helpers internos têm prefixos que precisam ser lidos junto com seus callers:
- `priv.srd_end_barbarian_rage` (OID 25340) bloqueia efeito → ficha e, ao aplicar fadiga, chama o helper de condição que adquire campanha.
- `priv.srd_end_barbarian_rage_token` (OID 26653) bloqueia efeito → campanha quando chamado sem lock herdado.
- Porém, os callers encontrados que têm EXECUTE para authenticated ou são triggers já chegam com campanha bloqueada: `public.alternar_estado_campanha` (OID 20103), `public.usar_furia_barbaro_srd` (OID 25341), `public.usar_furia_barbaro_npc_srd` (OID 26656), além do trigger de rodada (OID 26292). `public.srd_expire_campaign_conditions` (OID 24807) e o descanso longo de NPC também são campaign-first, embora não tenham EXECUTE para authenticated na função pública/implementação observada.
- `public.end_combat` (OID 19091) percorre efeitos antes de atualizar campanha, mas não tem EXECUTE para authenticated/anon, não foi encontrado caller SQL e não é chamado pelos sete arquivos de interface/scripts atuais.

**Conclusão corrigida:** não classificar campaign ↔ effect como deadlock operacional ativo nas rotas autenticadas atuais. O prefixo efeito → campanha de `end_combat` permanece risco legado/dormant, sujeito a reavaliação se grants/callers forem reativados. As rotas atuais de Fúria adquirem campanha antes de processar efeitos, embora a rota de Fúria de personagem tenha outra inversão ativa: personagem/ficha → campanha, detalhada a seguir.

### 2. Fúria de personagem — inversão ativa personagem/ficha ↔ campanha

`public.usar_furia_barbaro_srd` (OID 25341), chamado diretamente por `mesa.html`, bloqueia personagem → ficha → campanha. Ao encerrar a Fúria, chama `priv.srd_end_barbarian_rage` com a campanha já bloqueada; o helper bloqueia efeito → ficha, ajusta PV e pode aplicar fadiga. Portanto, a ordem efetiva do entrypoint é personagem → ficha → campanha → efeito/ficha, não efeito → campanha.

A rota de NPC, `public.usar_furia_barbaro_npc_srd` (OID 26656), é campaign-first → personagem → ficha e depois processa o efeito do token. O descanso longo de NPC também começa por campanha.

**Risco operacional ativo:** a rota de Fúria de personagem mantém personagem/ficha antes de campanha, enquanto `priv.srd_apply_pending_spell_resolution` bloqueia pending spell → campanha → ficha quando o alvo é personagem. Uma resolução de magia pendente contra o mesmo personagem pode, portanto, competir com o uso/encerramento de Fúria. Isso é um ciclo de prefixos alcançáveis, ainda não reproduzido com as RPCs reais. O helper de vitalidade atualiza condições e depois apenas lê campanha por MVCC; essa leitura não é aquisição de lock e não cria por si só aresta condição → campanha.

### 3. Remoções públicas de efeitos/condições — bypass do serializador

- `public.srd_remove_campaign_condition(bigint,text,text,text)` (OID 24806) e `public.srd_remove_campaign_effect(bigint,bigint)` (OID 24897) são `SECURITY DEFINER`, têm EXECUTE para `authenticated` e não para `anon`.
- Ambos exigem usuário autenticado e papel GM. Porém, atualizam diretamente a tabela-alvo sem bloquear primeiro `campaigns FOR UPDATE`.
- Não verificam se existe movimento AOO pendente e não delegam aos helpers internos que serializam a campanha.
- As tabelas-alvo têm RLS habilitado, mas o acesso privilegiado dessas funções SECURITY DEFINER faz com que a validação do corpo da RPC seja o limite efetivo.

**Risco:** essas rotas permitem concorrência de remoção de efeito/condição com avanço de turno, dano, conjuração e resolução de AOO sem participar da mesma serialização de campanha. Isso pode produzir decisões baseadas em um estado que muda durante a resolução, mesmo que não resulte necessariamente em deadlock.

**Ação futura:** consolidar remoção em helpers internos campaign-first, revalidar papel/pertencimento sob lock e definir política explícita para mudanças estruturais durante pending AOO/pendência de magia. Não alterar essas RPCs antes de mapear consumidores frontend e testar compatibilidade.

### 4. Resolução de magia pendente — lock dedicado antes da campanha

`priv.srd_apply_pending_spell_resolution(uuid)` (OID 25071) bloqueia `priv.srd_pending_spell_resolutions` antes de adquirir `campaigns FOR UPDATE`; depois pode bloquear ficha e chamar sincronização de vitalidade. O helper interno não tem EXECUTE direto para authenticated/anon. Ainda falta mapear todos os escritores e transições do registro pending para determinar se há algum caminho inverso campaign → spell-pending. Até isso ser verificado, a ordem pending-spell → campaign é uma dependência a preservar ou harmonizar, não uma inversão confirmada isoladamente.

### 5. Equipamento e instâncias de armas — limite da evidência

O trigger `private.sync_character_weapon_instances_from_inventory()` (OID 26446) é AFTER INSERT/DELETE/UPDATE de quantidade em `srd_character_equipment`; cria/remove instâncias e atualiza o resumo do equipamento. `private.equipar_arma_instancia_personagem_impl` (OID 26441) bloqueia personagem → instância de arma e depois atualiza instâncias/equipamento. A análise lexical anterior identificou caminhos de sequência iterativa que podem inverter campanha/arma, mas esta revisão não fecha o grafo transitivo completo desse domínio. Manter a hipótese como pendência, sem elevar para deadlock confirmado.

### 6. Estado de verificação

- Evidência de código/trigger: confirmada por OID e definição atual remota.
- Deadlock real em produção: não observado.
- Reprodução com RPCs Supabase reais: não executada.
- Harness PostgreSQL existente: cobre padrões sintéticos, não executa os corpos dessas RPCs.
- Nenhuma função, trigger, ACL, policy, migration ou dado foi alterado no Supabase remoto.
- TESTE 2 permaneceu intocado.

### Próximos critérios técnicos

1. Completar o grafo de chamadas de todos os writers de `srd_pending_spell_resolutions`, efeitos e condições; não usar regex por nome como prova de call graph.
2. Identificar consumidores reais das RPCs públicas de remoção e validar a autorização/contrato do frontend.
3. Extrair para fixtures descartáveis as transições de Fúria character/token, remoção direta de efeito/condição, expiração de rodada e encerramento de combate.
4. Testar duas sessões com barreiras determinísticas, rollback e retries; separar deadlock, race condition e perda de atualização.
5. Só depois propor uma correção SQL e migration reconciliada. Nenhuma mudança de produção decorre desta auditoria.


## Atualização — chamadas de conjuração e pendências de magia (2026-11-09, revisão por OID)

A varredura de todas as funções cujo corpo referencia `priv.srd_pending_spell_resolutions` identificou os seguintes caminhos:

| Função | Sequência observada | Leitura |
|---|---|---|
| `public.conjurar_missil_magico_srd` (OID 24356) | personagem → ficha → campanha → INSERT pending | Campanha é adquirida depois de locks de personagem/ficha; risco de inversão com fluxos campaign-first que bloqueiem ficha |
| `public.conjurar_magia_efeitos_multialvo` (OID 25109) | personagem → ficha → consumir ação (helper de turno) → campanha → INSERT pending | Inversão campanha ↔ personagem/ficha permanece no fluxo ativo |
| `public.conjurar_magia_dano_multialvo_srd` (OID 25246) | personagem → ficha → consumir ação → campanha → INSERT pending | Mesmo padrão de risco; confirmar o lock transitivo de consumir ação por OID na revisão de chamadas |
| `public.conjurar_magia_srd_manual` (OID 24656) | ficha/personagem → campanha em mais de um ramo → updates de PV/cena e INSERT pending | Fluxo com múltiplos ramos e alvos; precisa de análise de cada branch antes de definir ordem única |
| `public.avancar_turno` (OID 20074) | campanha → UPDATE combat_data (trigger de rodada) → INSERT pending quando necessário | Caminho campaign-first; o trigger pode encerrar Fúria e bloquear efeitos |
| `public.srd_resolve_pending_spell_save` (OID 25072) e `public.srd_resolve_pending_spell_resistance` (OID 25073) | pending spell → atualização do próprio pending | Não foi encontrado lock explícito de campanha nesses dois resolvers; não constituem por si sós o caminho inverso pending ↔ campaign |
| `priv.srd_apply_pending_spell_resolution` (OID 25071) | pending spell → campanha → ficha/efeitos/condições, conforme ramo | Mantém pending-first; não há evidência suficiente de um writer campaign-first que bloqueie o mesmo pending existente |

**Conclusão refinada:** o ciclo campaign ↔ sheet/personagem continua sustentado por entrypoints de conjuração que bloqueiam ficha antes de chamar consumo de ação/lock da campanha, contra resolução de magia pendente e outros fluxos campaign-first. O risco é de ordem de locks, não prova de deadlock ocorrido em produção. Para a tabela de pendências de magia, não foi encontrada inversão simétrica completa: os resolvers de salvamento/resistência bloqueiam o pending e atualizam apenas seu status; os caminhos de conjuração inserem novos pendings depois de bloquear a campanha. Não misturar esse caso com o ciclo AOO pending ↔ attack.

A busca foi feita nos corpos atuais por OID e assinatura. Dependências chamadas por outras funções precisam de inspeção individual; correspondência textual não é call graph. Nenhuma RPC foi executada durante esta análise.


## Correção de precisão — consumo de ação dentro das RPCs de conjuração (2026-11-09)

A leitura integral de `public.consumir_acao_turno_srd(bigint,text,text)` (OID 20405) esclarece a sequência: ela bloqueia `campaigns FOR UPDATE` no início e só depois pode atualizar `srd_character_sheets` em uma condição específica. Portanto, a chamada não adquire campanha depois de entrar no helper; ela adquire campanha quando é chamada.

As RPCs `conjurar_magia_efeitos_multialvo` (OID 25109) e `conjurar_magia_dano_multialvo_srd` (OID 25246) já bloquearam personagem/ficha antes de chamar `consumir_acao_turno_srd`. A sequência composta observável é, portanto, **personagem/ficha → campanha**, seguida pelo restante da conjuração. Isso continua sendo uma inversão potencial contra fluxos campaign-first que depois bloqueiam ficha/personagem, mas não se deve descrever a inversão como se o helper de consumo de ação bloqueasse a campanha depois de adquirir locks de ficha dentro dele.

O helper de consumo de ação também chama `priv.srd_sync_character_vital_condition` apenas no ramo de ação extenuante a PV 0. Esse helper atualiza condições vitais e depois faz SELECT sem lock na campanha. A leitura posterior não é uma aquisição de lock campanha e, isoladamente, não cria uma aresta de lock condição → campanha.

**Ajuste de conclusão:** manter a conjuração multialvo como risco de lock order personagem/ficha → campanha contra rotinas campaign-first → ficha, mas não atribuir o risco a uma ordem interna invertida do helper de consumo de ação. A resolução de magia pendente permanece pending spell → campanha → ficha/estado conforme ramo; a aresta que fecha um ciclo depende de qual fluxo concorrente bloqueia a mesma ficha. Ainda não há deadlock reproduzido com as RPCs.


## Validação do caminho frontend de conjuração e remoção (2026-11-09)

Foi feita leitura integral dos sete arquivos de interface/scripts da branch principal (`mesa.html`, `ficha.html`, `lobby.html`, `lobby_atualizado.html`, `index.html`, `dice.html` e `vinculo-ui.js`) e busca pelos nomes exatos das RPCs auditadas.

### Chamadas de conjuração observadas em `mesa.html`

- Para magia multialvo de dano, a interface chama diretamente `conjurar_magia_dano_multialvo_srd` (OID 25246), que bloqueia personagem → ficha e, durante combate, chama `consumir_acao_turno_srd` (OID 20405), que bloqueia campanha. Esta é uma rota frontend confirmada para o prefixo personagem/ficha → campanha.
- Para magia multialvo de efeitos, a interface chama diretamente `conjurar_magia_efeitos_multialvo` (OID 25109), que também bloqueia personagem → ficha antes de consumir ação e obter o lock da campanha.
- Para Míssil Mágico, a interface chama `conjurar_missil_magico_srd_manual` (OID 25191), que bloqueia personagem → ficha e delega para `conjurar_missil_magico_srd` (OID 24356), que chama `conjurar_magia_com_acao_srd` e depois bloqueia campanha. A rota também apresenta prefixo personagem/ficha → campanha.
- Para magia de alvo único não Míssil Mágico, a interface chama `conjurar_magia_com_acao_srd_manual` (OID 24658), wrapper que bloqueia personagem → campanha antes de delegar para a resolução manual.
- A interface usa `srd_resolve_pending_spell_save` e `srd_resolve_pending_spell_resistance` para os pedidos de resistência/penetração. Os dois resolvers bloqueiam primeiro o registro pending; o de resistência à magia pode delegar para `priv.srd_apply_pending_spell_resolution` após sucesso.

### Remoção direta de condições/efeitos

Nos sete arquivos de interface/scripts atuais, não foram encontradas chamadas com os nomes exatos `srd_remove_campaign_condition` ou `srd_remove_campaign_effect`. Isso **não prova ausência de consumidores externos**, scripts não versionados, chamadas administrativas ou uso indireto por outra RPC. O achado reduz a evidência de que essas rotas sejam acionadas pelo frontend principal atual, mas não autoriza removê-las nem alterar seu contrato.

### Consequência para priorização

A inversão personagem/ficha → campanha não é apenas um padrão lexical isolado: há rotas de conjuração que a interface principal chama diretamente. Deve ser tratada como prioridade de teste junto com campaign → ficha/efeito em resolução e encerramento. Ainda é necessário demonstrar um par concorrente que alcance a mesma linha de ficha/personagem e reproduzir o ciclo em fixture; não há deadlock de produção confirmado.


## Correção de precisão — wrappers single-target e caminho de Míssil Mágico (2026-11-09)

A análise do fluxo efetivamente chamado por `mesa.html` separa duas famílias:

- **Multialvo de dano/efeitos:** chamadas diretas a OIDs 25246 e 25109. Ambas bloqueiam personagem e ficha antes de consumir ação/obter o lock da campanha. Permanecem os caminhos frontend confirmados personagem/ficha → campanha.
- **Alvo único comum:** `mesa.html` chama `public.conjurar_magia_com_acao_srd_manual` (OID 24658), que bloqueia personagem e campanha antes de delegar para `public.conjurar_magia_srd_manual` (OID 24656), que então bloqueia ficha. Para esta rota, o prefixo é personagem → campanha → ficha; não classificá-la como ficha → campanha.
- **Míssil Mágico:** `mesa.html` chama `public.conjurar_missil_magico_srd_manual` (OID 25191), que bloqueia personagem → ficha e delega para `public.conjurar_missil_magico_srd` (OID 24356). A função interna chama `public.conjurar_magia_com_acao_srd` (OID 20410), que bloqueia personagem/campanha para consumir a ação; portanto, a rota composta volta a apresentar personagem/ficha → campanha.

A existência de ambos os prefixos em rotas usadas pela mesma interface reforça a necessidade de harmonizar os wrappers, mas a prova de deadlock exige um segundo fluxo que retenha a campanha e tente bloquear a mesma ficha/personagem. A resolução pending spell fornece um caminho campaign-first → ficha em alvos personagem; isso sustenta a hipótese de ciclo para o mesmo personagem, ainda pendente de fixture baseada em corpos e teste de concorrência. Nenhuma função foi executada remotamente.


## Revisão de alcance — caminho legado de condição flat-footed (2026-11-09)

Foi identificado um prefixo potencial no corpo de `public.end_combat(bigint)` (OID 19091): ele chama `priv.srd_clear_combat_flatfooted_all` (OID 27085), que atualiza condições antes do UPDATE final de campanha. Já `public.avancar_turno(bigint)` (OID 20074) bloqueia campanha no início e depois limpa flat-footed do ator via OID 27083.

Entretanto, a verificação de alcance mudou a classificação:
- `end_combat` não tem EXECUTE para `authenticated` nem `anon`.
- Não foi encontrado caller SQL para `end_combat` nas funções `public`, `priv` ou `private`.
- A varredura dos sete arquivos de interface/scripts não encontrou chamada de `end_combat`; a mesa atual usa `alternar_estado_campanha`, que já bloqueia campanha antes de limpar flat-footed.
- `avancar_turno` e `alternar_estado_campanha` seguem campanha → condição no fluxo frontend atual.

**Classificação:** manter o prefixo condição → campanha de `end_combat` como risco legado/dormant, não como ciclo operacional alcançável por authenticated no estado atual. O cenário sintético foi removido do harness para não atribuir cobertura de produção a uma rota sem alcance demonstrado. Reavaliar se o grant ou os consumidores de `end_combat` forem reativados.


## AOO — inversão ativa entre mudança de estado da mesa e resolução de reação (2026-11-09)

A leitura dos corpos remotos e da chamada frontend confirma uma cadeia operacional mais específica que o padrão isolado pending ↔ attack:

- `mesa.html` chama `alternar_estado_campanha` (OID 20103) para sair de combate. A RPC é executável por authenticated, bloqueia `campaigns FOR UPDATE`, depois atualiza `priv.srd_aoo_attacks` para cancelar ataques pendentes e, em seguida, atualiza `priv.srd_aoo_pending_movements`.
- `mesa.html` também chama `srd_resolver_ataque_oportunidade_srd` (OID 27025), executável por authenticated. A função bloqueia primeiro o ataque AOO, depois a movimentação pendente e depois a campanha.
- `mesa.html` chama `srd_cancelar_movimento_aoo_pendente_srd` (OID 26966), que delega a `priv.srd_cancelar_movimento_aoo_pendente_impl` (OID 27268). Esse helper bloqueia pending primeiro e depois atualiza os ataques associados.
- O caminho de encerrar reação também bloqueia pending antes de, quando necessário, bloquear o ataque associado.

**Ciclos ativos demonstrados nos prefixos:** campanha → ataque versus ataque → pending → campanha; e pending → ataque versus ataque → pending. Os entrypoints públicos relevantes têm EXECUTE para authenticated e são chamados pela interface atual. Isso torna AOO uma prioridade operacional, não apenas risco de função legada.

Foi acrescentado ao harness um cenário sintético explícito campanha → ataque versus ataque → pending → campanha. O teste usa tabelas descartáveis e não executa as RPCs Supabase; deadlock real de produção continua não observado. A correção deve unificar o fluxo de cancelamento/encerramento/resolução sob uma ordem única e impedir que a troca de estado da campanha dispute a mesma cadeia em ordem reversa.


### Detalhamento adicional das transições AOO

A leitura por OID também confirma outros caminhos ativos:

- `srd_iniciar_ataque_oportunidade_srd` (OID 27022), variante desarmada (OID 27065) e variante monstro (OID 27055) bloqueiam pending → campaign, consultam/atualizam a reação e criam o ataque, atualizando depois o pending.
- `srd_finalizar_movimento_aoo_pendente_srd` (OID 27038) bloqueia pending → campaign e depois marca o pending como committed.
- `srd_reservar_reacao_movimento_aoo_srd` (OID 26971) delega ao helper pending-first (OID 27256), que depois bloqueia campanha.
- `srd_confirmar_critico_ataque_oportunidade_srd` (OID 27027) bloqueia ataque e atualiza o registro pending; `srd_registrar_rolagem_ataque_oportunidade_srd` (OID 27024) bloqueia ataque.
- `srd_encerrar_reacao_aoo_pendente_srd` (OID 27035) delega ao helper (OID 27269), que bloqueia pending e, se cancelar ataque iniciado, bloqueia o ataque associado.

Assim, a transição de estado da mesa campanha-first conflita com pelo menos dois caminhos expostos: pending-first → campaign e attack-first → pending → campaign. O cancelamento e encerramento de reação também mantêm a ordem pending → attack. A ordem candidata para o domínio AOO deve ser decidida em conjunto com a linha campaign; não basta ordenar apenas as duas tabelas AOO.
