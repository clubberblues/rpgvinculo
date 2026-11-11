# Protocolo global de locks — proposta para revisão

Status: **rascunho de arquitetura; não aprovado para implementação**  
Data: 2026-11-10  
Base: inspeção read-only dos corpos SQL remotos, triggers e writers de `campaigns`.

Este documento consolida uma direção candidata para eliminar inversões de locks. Não é migration, não altera o banco e não declara que todas as dependências transitivas foram mapeadas. O baseline de migrations foi reconciliado byte a byte com o ledger remoto (966/966); variantes locais foram preservadas em quarentena. A implementação continua bloqueada até revisão do grafo transitivo por assinatura/OID e reprodução das 966 migrations em stack Supabase local descartável, seguida de testes de concorrência em PostgreSQL efêmero.

## 1. Invariante principal

Para qualquer operação que altere o agregado da campanha (`cba_data`, `combat_data`, estado/turno, tokens, pendências ou efeitos de combate), ou que coordene uma mutação da campanha com personagens/fichas/recursos, adquirir primeiro o lock da linha `public.campaigns` correspondente (`FOR UPDATE`). Operações estritamente limitadas à ficha/personagem podem usar uma ordem própria de personagem → ficha, desde que não atualizem o agregado da campanha e não chamem depois helpers que adquiram campanha.

Quando a campanha ainda não é conhecida, ler o `campaign_id` sem lock apenas para localizar o agregado; depois bloquear a campanha e revalidar, sob lock, que o personagem/token ainda pertence à campanha e que o chamador mantém autorização.

Cada endpoint deve respeitar a ordem parcial definida para os recursos que realmente bloqueia. Um helper ou trigger não pode reintroduzir, de forma transitiva, uma aresta para um recurso anterior que a transação ainda precise adquirir. Quando dois domínios se cruzarem, a ordem entre eles deve ser explicitada antes da implementação; não presumir uma hierarquia universal entre categorias.

## 2. Ordem parcial candidata por domínio

A auditoria ainda não sustenta uma ordem total entre todas as tabelas. A regra de maior confiança é **campaign-first** para qualquer operação que altere ou coordene o agregado da campanha. Abaixo estão restrições parciais observadas/propostas; elas não devem ser combinadas em uma sequência única sem validar as interseções:

- **Personagem/ficha:** `campaigns → characters → srd_character_sheets` para operações que também alteram campanha; operações puras de ficha podem manter `characters → sheet`, desde que não chamem campanha depois.
- **Recursos de classe:** depois de personagem/ficha; o writer de classe atual precisa ser reordenado porque hoje adquire recurso antes de campanha.
- **Inventário/equipamento:** não fixar ainda uma ordem global entre `srd_character_equipment` e `srd_character_weapon_instances`. O equipar de instância bloqueia personagem → instância → inventário; a entrega de item bloqueia/insere inventário e o trigger cria instâncias em delta positivo. Como a entrega atual só aumenta quantidade e insere novas instâncias, não foi demonstrado ciclo ativo nessa interseção; remoção/redução que apague instâncias continua sem writer autenticado atual identificado. A ordem campaign-first + character-first deve serializar as mutações da mesma ficha antes de definir a ordem interna.

- **Fontes do snapshot AOO:** qualquer mutação que possa alterar ameaças deve adquirir primeiro a linha da campanha, revalidar pending/turno, depois personagem → ficha (quando aplicável) → instância de arma → inventário/equipamento. No estado instalado, equipar_arma_instancia_personagem_impl (OID 26441) bloqueia personagem → instância sem lock de campanha; entregar_item_srd (OID 20556) pode alterar/equipar item sem lock de campanha. Esses caminhos não sincronizam com o snapshot AOO. A ordem proposta é preventiva e ainda depende de reconciliar todos os triggers e writers antes de implementação.
- **Ataques iterativos PC/NPC:** `campaigns → sequence → attempt → weapon instance` é a ordem recomendada para normalizar registro/resolução/dano. No snapshot atual, o início PC bloqueia arma antes de campanha e o registro NPC bloqueia sequência antes de campanha.
- **AOO — iniciar reação:** a cadeia candidata é `campaigns → pending movement → reaction ledger → weapon instance (se aplicável) → insert attack`.
- **AOO — resolver/cancelar:** a cadeia candidata é `campaigns → pending movement → attack`. Quando o ramo também precisa bloquear ficha do alvo, ainda falta decidir se deve ser `campaigns → sheet → pending → attack` (lendo IDs por MVCC antes) ou se a ficha pode ser atualizada por um helper que não adquira lock próprio; não presumir que `pending → attack → sheet` seja compatível com a ordem personagem/ficha.
- **Magia pendente:** os resolvers atuais bloqueiam pending antes da campanha; harmonizar para localizar campanha por leitura MVCC, bloquear campanha e depois adquirir os locks do alvo/pending na ordem validada para o ramo. Não há ciclo pending↔campaign isolado comprovado, mas há bypass de serialização.
- **Efeitos/condições:** escritores de combate devem herdar campaign-first. A ordem relativa entre efeitos, condições e recursos ainda precisa de revisão por OID e de todos os triggers; remoções públicas e alguns resolvers atualizam essas tabelas sem lock explícito da campanha.
- **Logs:** inserts append-only ficam ao final da transação quando não houver FK/trigger que exija outra ordem; validar os locks referenciais antes de fixar a regra.

### Interseções ainda não resolvidas

1. AOO damage pode bloquear ficha do alvo depois de pending/attack, enquanto outras rotas seguram ficha antes de entrar em campanha. A solução deve adquirir campaign primeiro e decidir a ordem ficha/pending/attack a partir de uma leitura inicial sem lock, seguida de revalidação.
2. O ataque iterativo e AOO podem disputar a mesma instância de arma; ambos precisam campaign-first, e a ordem sequence/ledger/weapon deve ser estável quando uma transação realmente tocar mais de uma dessas tabelas.
3. Recursos de classe e NPCs vinculados podem disputar o mesmo character_id somente quando a ficha de origem e o token tiverem vínculo/ownership compatível. A ordem deve ser validada contra os vínculos reais.
4. Efeitos e condições têm helpers sem lock próprio que herdam a campanha do chamador, além de writers públicos que não adquirem campanha. Não adicionar locks em helpers isolados sem mapear todos os callers.

**Conclusão:** o invariante campaign-first é a base da refatoração; a ordem secundária é um grafo parcial, não um total order já aprovado. Toda implementação deverá documentar quais linhas cada endpoint adquire, em que ordem e quais triggers/helpers herda.


### Operações de ficha sem lock de campanha — classificação (2026-11-09)

A revisão dos entrypoints usados pela interface distinguiu ausência de serialização da campanha de uma inversão de locks:

- `public.alterar_pv_personagem` (OID 21687), chamado por `mesa.html`, bloqueia somente `srd_character_sheets` (`FOR UPDATE OF s`). Consulta ownership/papel da campanha depois, mas não adquire lock de campanha nem chama helper que o faça.
- `public.conceder_xp_personagem_srd` (OID 24365), chamado por `mesa.html`, bloqueia `characters` → `srd_character_sheets` e atualiza XP; não bloqueia campanha depois.
- `priv.concluir_avanco_nivel_personagem_srd` (OID 24372), alcançado pelo wrapper `public.concluir_avanco_nivel_personagem_srd_v2` (OID 24782) chamado por `ficha.html`, bloqueia `characters` → `srd_character_sheets`; o wrapper salva idiomas na mesma ficha, sem lock de campanha.
- Esses caminhos não fecham, por si, ciclo com operações campaign-first, porque não pedem campanha depois de manter a ficha. O lock da própria ficha serializa alterações concorrentes à mesma linha.
- `priv.gm_npc_apply_typed_damage_impl` (OID 26783) começa por campanha e depois bloqueia a ficha do alvo jogador; isso é campaign-first e compatível com a ordem candidata.

- `public.srd_resolve_pending_spell_save` (OID 25072) bloqueia pending e pode atualizar `srd_campaign_conditions` sem bloquear a linha da campanha; `public.srd_resolve_pending_spell_resistance` (OID 25073) bloqueia pending e, quando a resistência é superada, chama a aplicação final que adquire campanha. Esses caminhos não fecham ciclo pending ↔ campanha com um writer campaign-first da mesma linha pending já existente, mas precisam entrar na refatoração para serializar as mudanças de estado da campanha.

**Conclusão:** não forçar lock de campanha em toda edição de ficha apenas por receber `p_campaign_id`. Manter operações puras de ficha fora do agregado, desde que permaneçam sem chamada transitiva de campanha. Se uma operação de ficha passar a modificar cena/combate/condições ou chamar um helper campaign-scoped, deverá adquirir campanha antes de personagem/ficha. Registrar separadamente esses endpoints para revisão de concorrência e autorização.


### Descanso longo de personagem — verificação de combate sem serialização (2026-11-09)

- `public.descanso_longo_personagem_srd` (OID 24366) é chamado por `ficha.html`. A sequência real é bloquear `characters`, consultar `campaigns.state` sem `FOR UPDATE`, depois bloquear `srd_character_sheets` e alterar PV, magias, recursos de classe e condições de campanha. Não há lock de campanha nessa RPC; é uma corrida de estado, não uma aresta ficha → campanha. Também chama `priv.srd_sync_character_vital_condition`, que atualiza condições sem adquirir lock da campanha.
- A rota de descanso longo de NPC vinculado já é campaign-first; a rota de personagem jogador não é. A checagem “não descansar durante combate” não é atômica com o início/alteração de combate: uma transação pode ler estado fora de combate, outra iniciar combate e confirmar, e a primeira continuar aplicando descanso depois.
- Não classificar isso automaticamente como deadlock: a função de descanso não pede lock da campanha depois de manter personagem/ficha. É um bypass da serialização do agregado e uma corrida de regra/estado. A correção candidata é localizar campanha sem lock, bloquear `campaigns` primeiro, revalidar vínculo/ownership e estado, e só então bloquear personagem → ficha → recursos/condições.


### Corrida adicional — consumo de poção e início de combate (2026-11-09)

- `public.usar_pocao_cura_srd_manual` (OID 24655, authenticated EXECUTE), chamada por `mesa.html`, lê `campaigns.state` sem lock. Se a leitura indicar `COMBATE`, chama `consumir_acao_turno_srd`, que adquire campanha antes de bloquear equipamento/ficha. Se a leitura indicar fora de combate, não adquire o lock da campanha e ainda assim consome a poção e altera PV.
- Isso permite uma corrida: a função pode ler estado fora de combate; outra transação inicia combate; a primeira continua e usa a poção sem consumir a ação de combate. Não é deadlock; é validação de estado não atômica com o uso do recurso.
- A correção candidata é adquirir campaign FOR UPDATE para personagem vinculado antes de decidir se a ação é exigida, revalidar state/ownership/vínculo e então bloquear personagem/ficha/equipamento na ordem estabelecida. O caminho de poção já segue campanha-first quando a leitura inicial encontra COMBATE, mas o branch fora de combate não é serializado.
- `public.descanso_longo_personagem_srd` (OID 24366) tem o mesmo padrão de leitura de estado não bloqueante antes de alterar PV, magias, recursos e condições; já está detalhado acima. Tratar ambos como corridas de regra/estado distintas dos ciclos de deadlock.


### Revisão dos triggers que cruzam campanha, condição, efeito e ficha (2026-11-09)

A inspeção de `pg_trigger`, `pg_get_triggerdef` e corpos dos handlers ativos acrescentou estas qualificações:

- `trg_expire_barbarian_rage_on_round_change` (AFTER UPDATE de `campaigns.combat_data`, OID 26292) executa enquanto a linha de campanha já está bloqueada. Bloqueia efeitos de Fúria em `effect_instance_id` crescente e chama os encerradores; não cria uma entrada effect-first independente.
- `trg_srd_request_confusion_turn_roll` (AFTER UPDATE de `campaigns.combat_data`, OID 27271) bloqueia a condição Confuso correspondente e insere `campaign_log`. Como roda após o UPDATE da campanha, a ordem efetiva é campaign → condition → log.
- `trg_srd_guard_pending_aoo_movement` (BEFORE UPDATE de `campaigns.cba_data`, OID 26962) consulta pending sem `FOR UPDATE`; é uma guarda de consistência, não uma aresta de lock pending-first.
- `trg_srd_validate_aoo_pending_movement_preview` (AFTER INSERT de pending AOO, OID 27033) reentra no movimento dentro de subtransação que termina em exceção sentinela e rollback. Os writers de pending já adquirem campaign antes do INSERT, portanto a prévia herda o lock campaign-first.
- `trg_srd_aoo_require_blind_concealment_roll` (OID 27248) e `trg_srd_guard_aoo_cannot_attack` (OID 27241) consultam condições por helpers de leitura sem `FOR UPDATE`; não acrescentam condição → ataque como lock de linha.
- `trg_srd_toughness_hp_delta` (BEFORE UPDATE de `srd_character_sheets`, OID 26347) ajusta PV na própria linha `NEW`; não acessa campanha, recursos ou condições.
- Não foram encontrados triggers ativos nas tabelas `srd_campaign_conditions`, `srd_campaign_effects`, `srd_pending_spell_resolutions` ou `srd_character_feature_resources` no snapshot consultado. Isso reduz a superfície de locks implícitos, mas deve ser revalidado junto com qualquer migration futura.

**Resultado:** nenhum novo ciclo autônomo foi acrescentado por esses triggers. A ordem campanha → efeitos/condições/log já descrita continua sendo herdada dos writers de campanha; os problemas remanescentes são os entrypoints que chegam a esses recursos em ordem diferente ou não participam da serialização.


### Ledger de reação AOO — ordem transitiva (2026-11-09)

A inspeção integral das funções que referenciam `priv.srd_aoo_reaction_ledger` confirmou:

- `priv.srd_reservar_ataque_oportunidade_impl` (OID 27261), exposta também por `public.srd_reservar_ataque_oportunidade_srd` (OID 26917, authenticated EXECUTE), bloqueia `campaigns FOR UPDATE` antes de consultar/contar/inserir no ledger. A serialização da campanha protege o limite de reações concorrentes da mesma mesa.
- Os três caminhos de início de AOO com arma equipada, desarmado ou ataque natural bloqueiam pending primeiro, depois campanha, depois o registro do ledger com `FOR UPDATE`; a variante de arma equipada também bloqueia a instância de arma com `FOR SHARE` antes de inserir o ataque AOO e atualizar pending.
- Portanto, além do ciclo pending → campaign já identificado, existe uma cadeia de locks interna que deve ser preservada ao corrigir: campanha → pending → ledger → (weapon instance, se aplicável) → insert attack. O INSERT do ataque também verifica FKs para pending/ledger já retidos pela transação.
- Não foi encontrado writer que bloqueie ledger e depois peça pending/campaign de forma independente; o conflito operacional confirmado permanece a entrada pending-first contra as rotas campaign-first/attack-first. A ordem exata entre arma e attack deve continuar explícita na revisão de todos os resolvers antes da migration.


### Equipamento inicial × poção — revisão de falso positivo (2026-11-09)

A varredura das funções que combinam `srd_character_equipment`, ficha e instâncias encontrou um par superficialmente invertido:

- `public.finalizar_equipamento_inicial_srd` (OID 21704, authenticated EXECUTE) bloqueia personagem → ficha e depois faz UPSERT de itens, podendo acionar o trigger de criação de instâncias de arma.
- `public.usar_pocao_cura_srd_manual` (OID 24655, authenticated EXECUTE) bloqueia a linha de equipamento da poção → ficha. À primeira vista isso sugere equipamento → ficha versus ficha → equipamento.
- Porém, o finalizador rejeita explicitamente categorias de poções e óleos antes do UPSERT. Portanto, ele não disputa a mesma linha `(character_id,equipment_id)` bloqueada pelo uso da poção. Os demais writes de equipamento do finalizador são linhas distintas; não foi demonstrada uma aresta de espera inversa.

**Classificação:** não adicionar como deadlock ativo. Reavaliar se itens consumíveis passarem a fazer parte dos pacotes iniciais ou se outro writer passar a atualizar a mesma linha de equipamento depois de bloquear a ficha. A corrida de estado de combate no uso da poção continua sendo um achado separado.


### Ataques iterativos — ordem interna entre sequência e tentativa (2026-11-09)

A varredura completa dos writers de `srd_attack_sequences`, `srd_attack_sequence_attempts`, `srd_npc_attack_sequences` e `srd_npc_attack_attempts` confirmou uma distinção importante:

- PC: registro de rolagem (OID 26582) adquire campanha → sequência e insere tentativa; resolução/dano (OIDs 26607, 26622 e 26642) adquirem campanha antes de tentativa/sequência/arma, mas a ordem interna tentativa/sequence difere entre endpoints.
- NPC: registro (OID 26730) adquire sequência → campanha → tentativa; resolução/crítico/dano (OIDs 26737, 26741 e 26743) adquirem campanha → tentativa → sequência.
- A inversão operacional ativa é sequência → campanha versus campaign-first. A diferença interna sequência ↔ tentativa nos endpoints campaign-first não cria, isoladamente, deadlock entre esses writers porque todos precisam primeiro obter o mesmo lock exclusivo de `campaigns`; o segundo writer aguarda antes de adquirir qualquer linha de sequência/tentativa.
- Para previsibilidade e menor risco de regressão, a ordem candidata após a correção é campaign → sequence → attempt → weapon instance, com IDs ordenados quando houver mais de uma linha. A implementação pode manter a ordem atual entre attempt/sequence temporariamente apenas se a análise provar que nenhum caminho contorna o lock da campanha; a recomendação é normalizar todos.

## 3. Evidências que motivam a proposta

### Ciclos já identificados nos corpos remotos
- Fúria: os callers autenticados atuais adquirem campanha antes de encerrar efeitos; o único caminho effect-first identificado está em end_combat, sem EXECUTE para authenticated/anon e sem caller encontrado. Classificado como legado/dormant.
- Pending AOO ↔ ataque: cancelamento/encerramento bloqueia pending → attack; resolução/dano/ocultação bloqueia attack → pending.
- Campanha ↔ arma: início de sequência iterativa overload 7 bloqueia arma antes da campanha; resolução bloqueia campanha e depois pede `FOR SHARE` na instância.
- Campanha ↔ personagem/ficha: descanso longo de NPC vinculado bloqueia campanha → personagem → ficha; ações de classe e entrypoints de conjuração podem bloquear personagem → ficha → campanha.
- Efeitos, condições e PV: helpers de sincronização de condição não bloqueiam sempre campanha primeiro; a ordem depende do chamador. O descanso longo de personagem é uma rota ativa que altera condições sem serializar primeiro a campanha e ainda verifica o estado de combate por leitura não bloqueante.
- Inventário/arma: o trigger possui ramo de remoção equipamento → instância, mas os writers atuais identificados só aumentam quantidade e authenticated não tem DML direto; manter como risco futuro, não ciclo operacional atual.

### O que já passou em teste
O workflow PostgreSQL efêmero cobre oito padrões sintéticos de inversão:
- campanha ↔ instância de arma no Ataque Total de personagem;
- campanha ↔ personagem;
- campanha ↔ movimento pendente AOO;
- pending AOO ↔ ataque AOO;
- campanha ↔ personagem → ficha → recurso de classe (condicional ao mesmo character_id);
- campanha ↔ personagem → ficha;
- campanha → ataque versus ataque → pending → campanha no encerramento/resolução AOO;
- sequência de Ataque Total NPC → campanha versus campanha → tentativa → sequência.

Há também um controle positivo de ordem campaign → effect em ambas as sessões. Os testes demonstram o comportamento do PostgreSQL para os prefixos montados; não executam RPCs reais nem provam ocorrência em produção.

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

`priv.srd_apply_pending_spell_resolution(uuid)` (OID 25071) bloqueia `priv.srd_pending_spell_resolutions` antes de adquirir `campaigns FOR UPDATE`; depois pode bloquear ficha e chamar sincronização de vitalidade. O helper interno não tem EXECUTE direto para authenticated/anon. Os callers autenticados `public.srd_resolve_pending_spell_save` (OID 25072) e `public.srd_resolve_pending_spell_resistance` (OID 25073) também bloqueiam o pending primeiro; em alguns ramos delegam ao helper final, enquanto outros atualizam condição/status e registram log sem lock explícito da campanha. Os escritores de novas pendências encontrados adquirem campanha antes do INSERT, mas isso não é um lock inverso sobre uma linha pending já existente. Portanto, não há ciclo pending ↔ campaign isolado comprovado; há bypass da serialização de campanha e uma ordem a harmonizar, especialmente nos ramos que alteram condições de campanha.

### 5. Armas e instâncias — duas conclusões distintas

O Ataque Total de personagem tem uma inversão ativa e confirmada: o overload de início bloqueia instância de arma → campanha; a resolução bloqueia campanha → tentativa → sequência → instância. A interface chama ambos os caminhos. O detalhamento por OID foi acrescentado na seção específica abaixo.

O trigger `private.sync_character_weapon_instances_from_inventory()` (OID 26446) tem um ramo de delta negativo que remove instâncias; porém, a entrega atual de itens aumenta quantidade e insere instâncias novas, authenticated não tem DML direto em `srd_character_equipment`, e nenhum writer atual que reduza quantidade de arma foi encontrado. Não tratar equipamento → instância como inversão operacional atual; manter como risco futuro se remoção de armas for implementada.

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
| `public.srd_resolve_pending_spell_save` (OID 25072) e `public.srd_resolve_pending_spell_resistance` (OID 25073) | pending spell → validações/updates de condição e status; em alguns ramos delegam ao helper pending → campaign → ficha/efeito | Bypass de serialização nos ramos que não delegam; sem writer campaign-first identificado que bloqueie o mesmo pending existente, não há ciclo pending ↔ campaign isolado comprovado |
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
- A interface usa `srd_resolve_pending_spell_save` e `srd_resolve_pending_spell_resistance` para os pedidos de resistência/penetração. Os dois resolvers bloqueiam primeiro o registro pending. O de resistência à magia pode delegar para `priv.srd_apply_pending_spell_resolution`; o de salvamento também delega em alguns ramos (dano com aplicação de efeito), mas altera condições diretamente em outros ramos sem lock da campanha.

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

Assim, a transição de estado da mesa campanha-first conflita com pelo menos dois caminhos expostos: pending-first → campaign e attack-first → pending → campaign. O cancelamento e encerramento de reação também mantêm a ordem pending → attack. A ordem candidata para o domínio AOO deve ser decidida em conjunto com a linha campaign, ledger de reações e instância de arma; não basta ordenar apenas as duas tabelas AOO.


### Ordem candidata específica para AOO (ainda não implementada)

A correção deve fazer todos os entrypoints AOO compartilharem o mesmo prefixo:
1. `campaigns FOR UPDATE` — serializa a transição da mesa e revalida estado/rodada/turno.
2. `srd_aoo_pending_movements` por `pending_id` crescente — bloqueia e revalida status/reação pendente.
3. `srd_aoo_reaction_ledger` por `reaction_id` crescente — bloqueia e revalida a reserva/limite de reação.
4. `srd_character_weapon_instances` por `instance_id` crescente, quando o AOO usa arma equipada — valida equipamento e mão sem inverter com Ataque Total.
5. `srd_aoo_attacks` por `attack_id` crescente — bloqueia e revalida a etapa de ataque.
6. Attempts, logs e demais registros auxiliares, em ordem estável, depois das linhas principais.

Para APIs que recebem `attack_id`, pode-se fazer uma leitura MVCC inicial apenas para descobrir `pending_id`, sem manter lock; depois bloquear campanha → pending → attack e revalidar que o vínculo e o status continuam iguais. Para cancelamento/finalização, o `pending_id` já é conhecido. Para encerrar combate, bloquear primeiro todos os pendings da campanha em ordem estável e depois os ataques associados, em vez de atualizar ataques antes dos pendings.

Essa é uma direção de refatoração, não uma autorização de alteração. Antes de codificar, ainda é necessário revisar todos os writers de attempts/ledgers, triggers e os fluxos de ataque iterativo para confirmar que nenhuma tabela anterior é adquirida depois. O harness atual testa apenas os padrões de locks, não a semântica transacional completa.

## Economia de ações, conjuração e habilidades de classe — ciclo ficha/personagem ↔ campanha (2026-11-09)

A função public.consumir_acao_turno_srd (OID 20405) adquire campaigns FOR UPDATE no início e depois pode atualizar a ficha em uma condição de custo de ação. Portanto, qualquer RPC chamadora que já tenha bloqueado personagem/ficha antes de chamar essa função inverte a ordem campanha → personagem/ficha.

### Chamadas alcançáveis na interface atual

- public.conjurar_magia_efeitos_multialvo (OID 25109, authenticated EXECUTE): characters FOR UPDATE (linha 25) → srd_character_sheets FOR UPDATE (35) → consumir_acao_turno_srd (80), que bloqueia campanha; depois a RPC ainda lê campaigns FOR UPDATE (83).
- public.conjurar_magia_dano_multialvo_srd (OID 25246, authenticated EXECUTE): personagem (69) → ficha (80) → consumo de ação (220) → campanha (222).
- public.usar_habilidade_classe_srd (OID 25236, authenticated EXECUTE): personagem (41) → ficha (47); em branches de habilidade, adquire campanha (87 ou 133) e consome ação (135). A UI chama a RPC para Imposição das Mãos (cura).
- public.usar_imposicao_maos_mortos_vivos_srd (OID 25509, authenticated EXECUTE): personagem (56) → ficha (61) → recursos da habilidade (89) → campanha (97) → consumo de ação (204). A UI chama a RPC para a variante de toque contra mortos-vivos.
- public.conjurar_magia_com_acao_srd_manual (OID 24658, authenticated EXECUTE) e public.conjurar_magia_com_acao_srd_multialvo_v3 (OID 24661, authenticated EXECUTE) bloqueiam personagem e campanha antes de chamar o consumo de ação; não reproduzem a mesma inversão sheet → campaign, mas participam da cadeia campaign ↔ character.
- public.usar_pocao_cura_srd_manual (OID 24655) consome a ação antes de bloquear equipamento/ficha, alinhado com campaign-first nesse trecho.

A interface atual chama diretamente as quatro rotas centrais listadas acima. As rotas de magia multialvo e habilidades de classe são, portanto, caminhos operacionais; não são apenas funções antigas.

**Classificação:** inversão alcançável personagem/ficha → campanha versus campanha → ficha/personagem. O risco fica mais claro quando concorrente com resolução de magia pendente (priv.srd_apply_pending_spell_resolution, OID 25071), que bloqueia pending spell → campanha → ficha. O mesmo par de locks também pode competir com transições de turno/estado que começam pela campanha. Não foi reproduzido deadlock com RPCs reais.

### Direção de correção

O lock da campanha deve ser adquirido antes de personagem, ficha, recursos e inventário em toda RPC que consome ação de combate. Para evitar uma corrida entre validação de ownership e locks, pode-se fazer leitura inicial não bloqueante dos IDs de campanha/character, adquirir campanha, depois bloquear personagem/ficha e revalidar ownership, campanha e estado do turno. A função consumir_acao_turno_srd deve ganhar uma variante interna que recebe a campanha já bloqueada ou ser reorganizada para não reacquirir uma ordem diferente. Não duplicar consumo/validação em cada RPC.

Essa direção é proposta de arquitetura, não alteração aplicada. Antes da implementação, revisar triggers de ficha/recursos, condição strenuous_action_cost_1hp, writes de equipamento e o restante dos callers de consumir_acao_turno_srd.


## Expansão do grafo AOO — dano, ocultação e manobras com movimento pendente (2026-11-09)

A leitura dos writers por OID e das chamadas atuais em mesa.html amplia o domínio AOO para além de ataque/reserva:

### Caminhos attack → pending → campaign

- public.srd_aplicar_dano_ataque_oportunidade_srd (OID 27036, authenticated EXECUTE): ataque FOR UPDATE (linha 48) → pending FOR UPDATE (57) → campanha FOR UPDATE (59) → ficha do alvo (142), depois atualiza cena, ataque e pending.
- public.srd_aplicar_dano_ataque_oportunidade_monstro_srd (OID 27058, authenticated EXECUTE): ataque (37) → pending (46) → campanha (48) → ficha do alvo (81).
- priv.srd_registrar_ocultacao_ataque_oportunidade_impl (OID 27254), exposta pela RPC usada em mesa.html: ataque (21) → pending (40) → campanha (44).
- public.srd_resolver_ataque_oportunidade_srd (OID 27025): ataque → pending → campanha.
- public.srd_iniciar_ataque_oportunidade_srd (OID 27022), variante desarmada (27065) e variantes monstro (27055/27231): pending → campanha → ledger; depois criam ataque e atualizam pending.

### Caminhos pending → campaign nas manobras

- priv.srd_resolver_encontrao_srd (OID 27169): pending FOR UPDATE (66) → campanha FOR UPDATE (76). A interface chama tanto início quanto resolução do encontrão.
- priv.srd_resolver_levantar_caido_apos_aoo_srd (OID 27152): pending (16) → campanha (25); a interface chama as RPCs de início e resolução.
- priv.srd_resolver_derrubar_apos_aoo_srd (OID 27136): bloqueia pending (13) e delega a resolução de derrubar, cujo caminho adquire campanha.
- priv.srd_reservar_reacao_movimento_aoo_impl (OID 27256): pending (28) → campanha (30).
- priv.srd_finalizar_movimento_aoo_pendente_srd (OID 27038): pending (16) → campanha (39).

Os writers de início das manobras (derrubar, encontrão e levantar caído) adquirem campanha antes de inserir pending. Os resolvers/canceladores, porém, nem todos preservam essa ordem. A interface atual chama as rotas de dano AOO, ocultação, derrubar, encontrão e levantar caído em mesa.html; não são apenas funções órfãs.

### Triggers das tabelas AOO

As tabelas têm triggers BEFORE UPDATE/INSERT que consultam flags de condição para impedir ataques inválidos ou exigir rolagem de ocultação. Essas consultas não fazem FOR UPDATE nas condições e não adicionam, por si, uma nova aresta de lock de linha.

O trigger AFTER INSERT de priv.srd_aoo_pending_movements (OID 27033) executa uma prévia de movimento chamando mover_token_player_cba ou mover_token_gm_cba_srd dentro de um bloco PL/pgSQL cuja exceção sentinela desfaz a prévia. Os writers atuais de pending identificados já bloqueiam a campanha antes do INSERT; a prévia reentra no caminho de movimento na mesma transação/campanha. Não classificar o trigger isoladamente como pending → campaign sem considerar o lock de campanha já mantido pelo caller e o rollback da subtransação.

### Implicação para a ordem candidata

A proposta campaign → pending → attack continua sendo a base para resolução/cancelamento. Para início de reação com reserva, a cadeia precisa incluir campaign → pending → ledger → weapon instance (quando aplicável) → insert attack; os resolvers que recebem attack_id precisam descobrir pending por leitura MVCC e então bloquear campaign → pending → attack. Dano bloqueia ficha do alvo e sincroniza condições vitais; ocultação e tentativas/idempotência usam registros auxiliares. Não implementar uma reordenação parcial que apenas mova o lock de campaign para o início e deixe ledger/arma/ficha em ordens incompatíveis.


## Recursos de habilidades — ordem de lock e vínculo com NPCs (2026-11-09)

A revisão por corpo completo das funções que acessam public.srd_character_feature_resources refinou o ciclo:

- public.usar_habilidade_classe_srd (OID 25236): personagem → ficha → INSERT/lock do recurso da habilidade (linhas 66/73) → campanha (87 ou 133), conforme o branch. É chamada pela interface para Imposição das Mãos.
- public.usar_imposicao_maos_mortos_vivos_srd (OID 25509): personagem (56) → ficha (61) → recurso da habilidade (84/89) → campanha (97) → consumir ação (204). É chamada pela interface para o ataque de toque contra mortos-vivos.
- public.usar_furia_barbaro_srd (OID 25341): personagem → ficha → campanha (74) → recurso de Fúria (149/156). O prefixo campaign-first é respeitado para o recurso, mas não para character/sheet.
- public.usar_furia_barbaro_npc_srd (OID 26656): campanha (40) → personagem (52) → ficha (57) → recurso de Fúria (124/127/170).
- priv.descanso_longo_npc_vinculado_srd_impl (OID 26808): campanha (18) → personagem (28) → ficha (33) → recursos (65).
- public.descanso_longo_personagem_srd (OID 24366): personagem (22) → ficha (36) → recursos (52); a leitura do estado da campanha na linha 29 não é FOR UPDATE e não cria lock campanha.

**Conclusão:** as RPCs de classe chamadas pelo frontend seguram o recurso antes de adquirir campanha, enquanto as rotas de Fúria/descanso de NPC adquirem campanha antes de personagem/ficha/recurso. Se o token NPC estiver vinculado ao mesmo character_id que uma operação de habilidade de personagem, o ciclo pode envolver personagem/ficha/recurso ↔ campanha. A identidade comum precisa ser validada na regra de vinculação dos tokens; não afirmar que qualquer personagem e qualquer NPC disputam a mesma linha.

O fixture campaign ↔ feature resource cobre somente a forma de lock, não a semântica da vinculação. A correção deve usar uma ordem única campanha → personagem → ficha → recurso, revalidando que o token e o personagem ainda estão vinculados. Não basta mover apenas o SELECT de campanha para o início sem rever os ramos de autorização e os locks de ficha/recurso.


## Ataque Total de NPC — inversão ativa sequência ↔ campanha (2026-11-09)

A leitura do fluxo atual de mesa.html e das funções por OID confirmou outra inversão operacional:

- A interface chama public.registrar_rolagem_ataque_iterativo_npc_srd (OID 26778). O wrapper delega a priv.npc_registrar_rolagem_ataque_iterativo_impl (OID 26730), que bloqueia srd_npc_attack_sequences FOR UPDATE (linha 22) e só depois bloqueia campaigns FOR UPDATE (24). Prefixo: sequência → campanha → tentativa.
- A interface chama public.resolver_ataque_iterativo_npc_srd (OID 26779). O helper priv.npc_resolver_ataque_iterativo_impl (OID 26737) bloqueia campanha (linha 78) → tentativa (87) → sequência (92).
- A interface também chama public.aplicar_dano_ataque_iterativo_npc_srd (OID 26781), que delega a priv.npc_aplicar_dano_ataque_iterativo_impl (OID 26743), com campanha (52) → tentativa (66) → sequência (69), depois ficha do alvo e atualizações de cena/estado.
- A inicialização NPC (public.iniciar_ataque_iterativo_npc_srd, OID 27430) é campaign-first (helper OID 27428), assim como a sequência de ataque total de personagem.

**Classificação:** ciclo alcançável sequência → campanha versus campanha → tentativa → sequência. Ao registrar a rolagem de um NPC, a interface mantém a linha da sequência enquanto pede o lock da campanha; a resolução/dano pode manter a campanha e tentativa enquanto pede a mesma sequência. A UI atual chama essas rotas em mesa.html, portanto não é caminho legado. Não foi reproduzido deadlock com RPCs reais.

Foi acrescentado ao harness PostgreSQL um caso sintético com sequence → campaign contra campaign → attempt → sequence. Ele verifica o mecanismo de deadlock do PostgreSQL em tabelas descartáveis, sem executar as RPCs reais.

### Direção de correção

Padronizar os RPCs NPC e PC em campanha → sequência → tentativa (ou outra ordem única definida após revisar todas as variantes). O registro de rolagem NPC deve primeiro obter campaign FOR UPDATE, depois sequence FOR UPDATE e, por fim, attempt; resolução e aplicação de dano devem respeitar a mesma ordem. Revalidar campaign_id, actor token, sequência ativa, índice de ataque e idempotência depois dos locks. A variante PC já começa por campanha e não deve ser regressada para sequence-first.


## Estabilização de personagem Morrendo — caminho ativo personagem → ficha → campanha (2026-11-09)

A interface mesa.html chama public.srd_resolve_dying_round (OID 24914), executável por authenticated. O corpo bloqueia:
1. characters FOR UPDATE (linha 24);
2. srd_character_sheets FOR UPDATE (39);
3. campaigns FOR UPDATE (49);
4. srd_campaign_conditions FOR UPDATE (61).

Esse é outro caminho operacional personagem → ficha → campanha. Ele concorre conceitualmente com a resolução de magia pendente (pending spell → campanha → ficha) e com transições campaign-first que atualizam a mesma ficha. A condição Morrendo só é bloqueada depois da campanha, portanto não cria por si só inversão condição → campanha.

O registro de iniciativa, public.registrar_iniciativa_d20 (OID 25178), faz o inverso seguro nesse trecho: campanha FOR UPDATE (35) → ficha FOR UPDATE (51). Não deve ser agrupado com a função de estabilização.

**Prioridade:** incluir srd_resolve_dying_round no grupo de RPCs que precisam começar por campanha e revalidar personagem/ficha/estado Morrendo após adquirir locks. A fixture campaign ↔ sheet já representa o padrão de lock, mas não executa a semântica da estabilização.


## Telemetria observada e versão PostgreSQL (2026-11-09)

Consulta read-only a pg_stat_database no banco atual retornou PostgreSQL 17.6, stats_reset em 2026-08-25 20:33:23 UTC, deadlocks=0 e conflicts=0. Uma amostra simultânea de pg_stat_activity encontrou 0 sessões aguardando lock e 0 sessões bloqueadas (6 sessões ativas no instante da consulta).

**Interpretação:** não há deadlocks contabilizados desde o último reset de estatísticas, nem espera por lock no instante observado. Isso não invalida os ciclos estáticos identificados: eles são caminhos possíveis que ainda não se manifestaram como deadlock nesse intervalo. A contagem não identifica RPCs nem inclui períodos anteriores ao reset.

O projeto está em PostgreSQL 17.6. O changelog Supabase publicou em 25/09/2026 a atualização PostgreSQL 15.19/17.11 com correções de 44 CVEs e possíveis ações para ltree, pgcrypto, btree_gist e operadores customizados. O projeto tem pgcrypto 1.3 instalado, não tem ltree nem btree_gist instalados, e a varredura de funções public/priv/private não encontrou uso de pgcrypto nas rotinas da aplicação. O schema vault usa helpers de criptografia próprios. Antes de qualquer upgrade gerenciado, revisar a orientação atual do Supabase e confirmar se há dados criptografados fora das rotinas SQL inspecionadas; nenhuma atualização foi solicitada ou executada.

Referência: https://supabase.com/changelog


## Inventário e instâncias de armas — risco condicional, não inversão operacional demonstrada (2026-11-09)

A revisão completa dos writers e das permissões mudou a classificação anterior:

- mesa.html chama public.entregar_item_srd (OID 20556), que faz INSERT ... ON CONFLICT DO UPDATE aumentando a quantidade. Para delta positivo, o trigger private.sync_character_weapon_instances_from_inventory (OID 26446) cria novas instâncias; não bloqueia as instâncias existentes com FOR UPDATE.
- mesa.html e ficha.html chamam public.equipar_arma_instancia_personagem (OID 26442). A implementação private.equipar_arma_instancia_personagem_impl (OID 26441) bloqueia characters FOR UPDATE, depois srd_character_weapon_instances FOR UPDATE, e atualiza o resumo em srd_character_equipment.
- O trigger também contém um ramo delta negativo que apaga instâncias não equipadas (equipamento → instância), mas não foi encontrado writer RPC/frontend atual que reduza quantidade de arma. A tabela srd_character_equipment não concede UPDATE/INSERT/DELETE direto a authenticated; há apenas SELECT direto, embora exista policy UPDATE que não concede privilégio sem grant.
- O DELETE do trigger é alcançado pelo cleanup de inventário ao excluir personagem, mas o caminho de equipar também bloqueia primeiro a linha do personagem, serializando esse par.

**Classificação corrigida:** não há evidência de um caminho operacional atual equipamento → instância concorrendo com instância → equipamento para a mesma arma. A entrega positiva insere novas instâncias e não cria a aresta inversa; o decremento de quantidade seria o caminho relevante, mas não está exposto por writer atual identificado. O ciclo permanece risco condicional/futuro se for adicionada remoção/redução de armas ou concedido DML direto. O cenário sintético correspondente foi retirado do harness ativo para não inflar a contagem de riscos alcançáveis.

**Direção para futura remoção de armas:** se essa funcionalidade for implementada, ordenar personagem → equipamento → instância e fazer o trigger/writer de remoção respeitar a mesma sequência. Não desativar o trigger sem substituir a sincronização de instâncias.


### Qualificação de alcance — locks da mesma ficha

O ciclo campanha ↔ ficha só se fecha quando as duas transações disputam a mesma linha de ficha/personagem na mesma campanha. Exemplo concreto alcançável: public.srd_resolve_dying_round (character → sheet → campaign) resolve a rolagem de um personagem Morrendo, enquanto o Mestre resolve uma magia pendente cujo alvo é esse mesmo personagem (pending spell → campaign → sheet). Não generalizar o ciclo para duas fichas diferentes apenas por pertencerem à mesma campanha; nesse caso há serialização na campanha, mas não a aresta inversa sobre a mesma ficha.


## Ataque Total de personagem — inversão instância de arma ↔ campanha (2026-11-09)

O overload de Ataque Total usado pelo frontend confirma outro ciclo ativo:

- mesa.html chama a variante de oito argumentos de public.iniciar_sequencia_ataque_iterativo_srd (OID 26632).
- O wrapper delega a priv.iniciar_sequencia_ataque_iterativo_srd_8_impl (OID 27365), que valida ficha/arma e delega ao overload de sete argumentos.
- priv.iniciar_sequencia_ataque_iterativo_srd_7_impl (OID 27364) bloqueia srd_character_weapon_instances FOR UPDATE (linha 26) e depois chama a implementação-base que bloqueia campaigns FOR UPDATE (OID 27360, linha 32). Ordem efetiva: instância de arma → campanha.
- A resolução public.resolver_ataque_iterativo_srd (OID 26607), também chamada por mesa.html, bloqueia campanha (linha 75) → tentativa (84) → sequência (89) → instância de arma FOR SHARE (147).
- O início de reação AOO public.srd_iniciar_ataque_oportunidade_srd (OID 27022) também adquire campanha antes de bloquear a instância de arma FOR SHARE (linha 106), depois de pending. Esse é outro caminho campaign-first que pode disputar a instância com o início de Ataque Total weapon-first.

**Classificação:** inversão ativa, confirmada pelo caminho frontend e pelos OIDs. O início da sequência pode manter a instância enquanto aguarda campanha; a resolução pode manter campanha e sequência enquanto aguarda a mesma instância. Não foi reproduzido deadlock com as RPCs reais.

O harness PostgreSQL voltou a incluir o par sintético campanha → instância (FOR SHARE) versus instância → campanha (FOR UPDATE). A ordem candidata deve ser campaign → sequence/attempt → weapon instance, ou outra sequência única que preserve a revalidação da arma; o início não pode bloquear a instância antes de adquirir campanha.


### Interseção AOO × ficha × instância de arma — revisão por OID (2026-11-09)

A inspeção read-only das implementações instaladas refinou a ordem candidata de resolução:

- `public.srd_resolver_ataque_oportunidade_srd` (OID 27025) e `public.srd_aplicar_dano_ataque_oportunidade_srd` (OID 27036) bloqueiam a linha do ataque AOO → a pendência vinculada → campanha. O aplicador de dano então bloqueia a ficha do alvo jogador. A variante de dano de monstro (OID 27058) segue ataque → pending → campanha e também pode bloquear ficha se o alvo for personagem.
- `public.srd_registrar_ocultacao_ataque_oportunidade_srd` (OID 27250) segue ataque → pending → campanha. A confirmação crítica (OID 27027) bloqueia ataque e atualiza a pendência; não foi identificada aquisição posterior de lock de campanha nesse corpo.
- As rotinas de início de AOO (arma, desarmado e ataque natural) seguem pending → campanha → reaction ledger; a variante de arma equipada bloqueia também a instância com `FOR SHARE` antes de inserir o ataque e atualizar pending. A rotina de reserva do ledger (OID 27261) é campaign-first.
- AOO e ataques iterativos podem ler/bloquear a mesma `srd_character_weapon_instances`: o início de AOO usa `FOR SHARE`, e o resolver iterativo PC/NPC também usa `FOR SHARE` depois de campaign → attempt → sequence. A inversão mais forte continua sendo o início iterativo PC que bloqueia a instância `FOR UPDATE` antes de entrar na campanha; depois de tornar esse caminho campaign-first, os caminhos campaign-scoped passam a serializar pela mesma linha de campanha antes de alcançar a instância. Não há evidência, neste recorte, de um ciclo independente sequence ↔ ledger ↔ weapon quando todos respeitam campaign-first.
- Para resolução/dano AOO contra personagem, a ordem candidata mais coerente é: leitura MVCC inicial do ataque para localizar campanha/alvo; lock de campanha; revalidação; lock da ficha-alvo; lock da pending; lock do ataque; então efeitos/dano e atualizações. Isso preserva campaign → character/sheet, e pending → attack, e elimina o prefixo atual attack → pending → campaign. Para alvo NPC/monstro sem ficha persistente, usar campaign → pending → attack. Todos os IDs/status/target precisam ser revalidados depois dos locks.
- A ordem ficha → pending → attack é uma proposta, não decisão final: confirmar todos os callers transitivos de dano, sincronização vital e encerramento AOO, bem como a relação de ownership do alvo, antes de implementar. Não adicionar lock de ficha para alvos token-only.

**Classificação:** as sequências conflitantes estão confirmadas nos corpos remotos por OID; a concorrência/deadlock entre RPCs reais ainda não foi reproduzida. Esta revisão não altera a conclusão de que a ordem global é parcial e que campaign-first deve ser a primeira barreira de serialização.


### Recursos de classe — verificação dos vínculos reais no snapshot atual (2026-11-09)

Consulta agregada read-only cruzou tokens NPC com sourceCharacterId e a linha correspondente em characters: foram encontrados 3 tokens NPC com ficha de origem existente; os 3 personagens de origem estão com campaign_id NULL e nenhum tem campaign_id igual ao da campanha do token. Portanto, o caminho personagem/ficha → recurso → campanha de usar_habilidade_classe_srd não disputa atualmente o mesmo personagem/recurso com o caminho campaign → personagem/ficha → recurso de Fúria/descanso NPC na mesma campanha. A inversão de prefixos continua real nos corpos, mas a colisão de linhas necessária ao deadlock não está presente neste snapshot de dados. Reclassificar como condicional/futuro até que um vínculo de NPC a personagem pertencente à mesma campanha seja permitido/criado; revalidar se o modelo de vínculo mudar.


### AOO: alvo-ficha e sincronização de condições — interseção confirmada (2026-11-09)

A leitura integral dos corpos (não apenas busca lexical) refinou a proposta anterior:

- `public.srd_aplicar_dano_ataque_oportunidade_srd` (OID 27036) e a variante de monstro (OID 27058) bloqueiam ataque → pending → campanha. Se o `target_token_id` corresponde a uma ficha persistente, bloqueiam essa linha de `srd_character_sheets` para atualizar PV. Em seguida chamam `priv.srd_sync_character_vital_condition` (OID 24908), que atualiza condições do personagem sem adquirir lock de campanha; a função apenas lê `characters.campaign_id` e `campaigns.combat_data` sem `FOR UPDATE`.
- `public.srd_resolve_dying_round` (OID 24914) mantém a ordem personagem → ficha → campanha → condição. É chamada pela mesa. Portanto, para o mesmo personagem, manter AOO como campanha → ficha pode formar o ciclo clássico: AOO segura campanha e espera ficha; estabilização segura ficha e espera campanha. O prefixo attack → pending antes da campanha agrava o grafo, mas não é a causa necessária do ciclo.
- **Regra necessária para esse par:** ambos os caminhos devem obter campanha antes de bloquear personagem/ficha. Para AOO, a ordem candidata é: leitura MVCC para localizar campanha/alvo → campanha `FOR UPDATE` → revalidar campanha, ataque, pending, ownership e estado → personagem (se a operação realmente o bloquear) → ficha → pending → ataque → condição/efeitos/log. Para token-only, omitir personagem/ficha e usar campanha → pending → ataque. A estabilização deve ser harmonizada para campanha → personagem → ficha → condição.
- O helper `priv.srd_sync_linked_npc_token_vitals` (OID 26848) também bloqueia campanha antes de ficha. `priv.srd_end_barbarian_rage_token` (OID 26653) bloqueia efeito antes de campanha e pode bloquear ficha da origem, mas os callers localizados que o invocam em fluxos atuais já seguram campanha; trigger de mudança de rodada herda lock de campanha. `public.end_combat` continua legado sem EXECUTE para authenticated/anon no snapshot. Não tratar o prefixo interno do helper como lock independente sem considerar o lock herdado do caller.

**Atenção:** a chamada de `srd_sync_character_vital_condition` pode atualizar condições sem lock explícito da campanha; após normalizar os chamadores de PV para campaign-first, revisar se esse helper deve exigir campanha já bloqueada ou receber um contrato explícito de caller. Não adicionar um lock interno cego: isso poderia reintroduzir ficha → campanha em callers que já mantêm a ficha.


### Contrato do helper de condição de PV — callers e lock herdado (2026-11-09)

`priv.srd_sync_character_vital_condition` (OID 24908) não adquire lock da campanha: lê `characters.campaign_id`, desativa/insere condições e lê o round sem `FOR UPDATE`. A busca por referências diretas encontrou os seguintes callers instalados: `priv.consumir_acao_rodada_completa_srd_impl` (27297), `priv.gm_npc_apply_typed_damage_impl` (26783), `priv.npc_aplicar_dano_ataque_iterativo_impl` (26743), `priv.srd_apply_pending_spell_resolution` (25071), `priv.srd_end_barbarian_rage` (25340), `public.aplicar_dano_token_gm_personagem_srd` (24353), `public.descanso_longo_personagem_srd` (24366), AOO PC/NPC (27036/27058), `public.srd_resolve_dying_round` (24914), `public.usar_habilidade_classe_srd` (25236), e `public.usar_pocao_cura_srd_manual` (24655).

O helper deve ser tratado como mutador de condição que herda o contexto transacional do caller, não como garantidor de serialização. Alguns callers já seguram campanha antes de alcançar a ficha/condição; `descanso_longo_personagem_srd` não bloqueia campanha em nenhum ponto; `srd_resolve_dying_round` adquire campanha somente depois de personagem/ficha; e branches de habilidades podem entrar em `consumir_acao_turno_srd` depois de bloquear ficha/recurso. A correção não deve inserir `campaign FOR UPDATE` dentro do helper sem migrar todos os callers: isso criaria uma aquisição implícita campanha-depois-de-ficha em parte deles. Contrato recomendado: cada entrypoint que altera condição de campanha deve localizar campanha por leitura MVCC, bloquear campanha primeiro, revalidar vínculo/autoridade, e só então adquirir locks de personagem/ficha/recurso; o helper pode permanecer sem lock próprio e documentar formalmente que exige caller campaign-first.


### Revisão adicional de entrypoints de ficha, conjuração e recursos — OIDs (2026-11-10)

Consulta read-only aos corpos instalados confirmou e refinou as seguintes cadeias:

- `public.srd_resolve_dying_round` (OID 24914): personagem `FOR UPDATE` → ficha `FOR UPDATE` → campanha `FOR UPDATE` → condição. É um caminho de ficha→campanha alcançável pela mesa e disputa a mesma ficha com resoluções campaign-first que atingem PV/condições.
- `public.conjurar_magia_efeitos_multialvo` (OID 25109) e `public.conjurar_magia_dano_multialvo_srd` (OID 25246): personagem `FOR UPDATE` → ficha `FOR UPDATE` → leitura do estado da campanha → consumo de ação (quando combate) → campanha `FOR UPDATE`. A leitura do estado antes do lock não substitui o lock; os dois caminhos mantêm personagem/ficha enquanto aguardam campanha. Isso reforça a possibilidade de ciclo com AOO/dano campaign-first quando o alvo é a mesma ficha. Também exige revalidar estado e autorização depois do lock de campanha.
- `public.usar_habilidade_classe_srd` (OID 25236): personagem → ficha; em caminhos que consomem recurso, cria/bloqueia `srd_character_feature_resources` antes de obter campanha. Há branches que bloqueiam campanha antes de operações posteriores, portanto a ordem efetiva é condicional ao recurso/feature. Para branches que chegam a campanha depois de personagem/ficha/recurso, existe inversão potencial contra qualquer operação campaign-first que precise da mesma ficha ou recurso; não generalizar para branches que não alcançam campanha.
- `public.usar_imposicao_maos_mortos_vivos_srd` (OID 25509): personagem → ficha → recurso `lay_on_hands` → campanha. A cadeia está no corpo público autenticado; se uma operação concorrente já segura campanha e precisa da mesma ficha/recurso, o ciclo é possível. O fluxo precisa adquirir campanha antes de ficha/recurso e revalidar elegibilidade, alvo e custo após os locks.
- `public.descanso_longo_personagem_srd` (OID 24366): personagem → ficha; lê `campaigns.state` sem `FOR UPDATE`, então atualiza condições, PV, magias e recursos. O estado pode mudar para COMBATE após a leitura: corrida funcional de descanso durante combate, não ciclo de deadlock demonstrado. Corrigir com leitura MVCC para localizar campanha, lock da campanha, revalidação de vínculo/estado, depois personagem → ficha → recursos/condições.
- `public.srd_resolve_pending_spell_save` (OID 25072) e `public.srd_resolve_pending_spell_resistance` (OID 25073) bloqueiam primeiro a linha pending. O resolver de resistência delega ao helper final em sucesso de resistência mágica; o resolver de salvamento tem ramos que atualizam condição/status/log diretamente e ramos que delegam ao helper. O helper de aplicação de efeito/dano (OID 25071) bloqueia pending → campanha → ficha/efeitos. Não foi isolado writer que bloqueie campaign e depois a mesma linha pending já existente; portanto pending-first continua como incompatibilidade de serialização/risco de estado, não como ciclo pending↔campaign simétrico comprovado. Os ramos que alteram condição/log sem campanha explícita devem ser revisados para contrato de serialização e revalidação de estado.
- `public.srd_finalizar_movimento_aoo_pendente_srd` (OID 27038) continua pending `FOR UPDATE` → campanha `FOR UPDATE`; a interface usa o caminho de finalização. É uma inversão operacional contra writers AOO campaign-first que precisam do mesmo pending, além das cadeias attack→pending→campaign já registradas.

#### Regra de correção consolidada — ainda não aprovada para migration

Para mutações de personagem que também coordenam campanha, a direção preferida é localizar campanha/IDs com leitura MVCC, adquirir campanha `FOR UPDATE`, revalidar vínculo, autoridade, estado, round e recursos, e então adquirir personagem → ficha → recurso/condição. Para fluxos AOO, harmonizar campanha antes de pending/attack, com ficha do alvo adquirida antes de pending/attack quando o alvo for personagem persistente. O desenho final ainda precisa reconciliar a ordem de pending/attack/ledger/weapon e os callers transitivos; não converter este rascunho em uma hierarquia total.

As operações de descanso e poção precisam revalidar estado de combate sob lock; os resolvers de magia precisam ter contrato explícito para serializar pending, campanha e efeitos. Não inserir locks de campanha dentro de helpers compartilhados sem antes migrar todos os callers, pois isso pode recriar campanha-depois-de-ficha.

**Validação do harness:** o workflow PostgreSQL [42727408284](https://github.com/clubberblues/rpgvinculo/actions/runs/42727408284), run #69, executado no head `54b7db97c6a0724e8e3cd6e2b53737859e6c6a10`, concluiu com sucesso. Ele executa os fixtures sintéticos versionados, não as RPCs instaladas no Supabase; nenhum deadlock real de produção foi reproduzido. Esta etapa foi somente leitura no Supabase e documentação no branch do PR.


### Correção de precisão: descanso, recursos de classe e wrappers AOO (2026-11-10)

A re-leitura numerada dos corpos instalados refinou três classificações do inventário anterior:

- **Descanso longo PC (OID 24366):** a cadeia real é characters FOR UPDATE → leitura MVCC de campaigns.state sem lock → srd_character_sheets FOR UPDATE → mutações de recursos/condições. Não existe lock de campanha neste RPC. Portanto não o classificar como aresta ficha → campanha nem como deadlock; é uma corrida de estado: o combate pode começar após a leitura e antes de o descanso terminar. A correção requer localizar campanha, adquirir campaigns FOR UPDATE antes de personagem/ficha e revalidar dono, vínculo e estado após o lock.
- **Estabilização (OID 24914):** permanece uma inversão real de ordem de aquisição: personagem → ficha → campanha → condição. O helper srd_sync_character_vital_condition é chamado depois de a campanha já ter sido bloqueada, mas o lock chega tarde para impedir ciclo com qualquer writer campaign-first que espere a mesma ficha. A fixture campanha↔ficha modela essa forma; ainda não reproduz RPC de produção.
- **Habilidade de classe (OID 25236):** a ordem é condicional. O personagem, ficha e recurso lay_on_hands são bloqueados primeiro. Se p_target_token_key for informado, o código adquire campanha no ramo de seleção do alvo antes de seguir; no ramo de autoalvo, a campanha só é bloqueada mais tarde, depois de personagem/ficha/recurso. Não tratar a função inteira como uma única cadeia sem separar esses branches.
- **Imposição das Mãos contra mortos-vivos (OID 25509):** personagem → ficha → recurso → campanha é confirmado sem ambiguidade. É um caminho autenticado e, portanto, precisa migrar para campaign-first com revalidação de alvo, custo e ação.
- **Conjuração multialvo (OIDs 25109/25246):** personagem → ficha, leitura do estado de combate, consumo de ação (que bloqueia campanha quando necessário), depois lock de campanha para ler/gravar cena. A espera pela campanha ocorre enquanto a ficha do conjurador já está bloqueada.
- **Resistência/salvamento de magia (OIDs 25072/25073):** ambos bloqueiam pending primeiro. No srd_resolve_pending_spell_save, o ramo condition_break altera diretamente srd_campaign_conditions sem lock explícito de campanha; ramos de sucesso simples atualizam pending e encerram; ramos que aplicam dano/efeito delegam ao helper pending → campanha → ficha/efeitos. No resolver de resistência, resistência bem-sucedida atualiza pending e encerra; penetração delega ao helper. Isso confirma diferenças de serialização por branch, mas não prova ciclo pending↔campaign simétrico.
- **Reserva AOO (OID 26917):** o wrapper público é SQL SECURITY INVOKER (não SECURITY DEFINER) e apenas delega para priv.srd_reservar_ataque_oportunidade_impl (OID 27261), que é SECURITY DEFINER e valida GM antes de bloquear campanha e atualizar o ledger. Manter a distinção wrapper/implementação na matriz de privilégios.
- **Início de ataque AOO (OID 27022):** a ordem efetiva observada é pending → campanha → ledger de reação → leitura da ficha → instância de arma FOR SHARE. A leitura da ficha não é FOR UPDATE; o ledger, sim. O início continua com pending antes de campanha, em oposição aos caminhos que adquirem campanha antes de pending/attack.

Essas correções não alteram a recomendação arquitetural: cada endpoint deve adquirir campanha primeiro quando sua transação coordena estado de campanha, depois as linhas de personagem/ficha/recurso/pending/attack conforme a matriz de domínio, e revalidar tudo que foi lido antes do lock. Para endpoints que não alteram campanha, não adicionar lock por conveniência; explicitar a corrida e definir a fronteira transacional correta.


### Matriz final de RPCs AOO autenticadas — locks efetivos (2026-11-10)

A leitura direta dos corpos instalados confirmou os seguintes prefixos e OIDs; todos os endpoints listados abaixo têm EXECUTE autenticado no snapshot:

| RPC | OID | Prefixo de locks confirmado | Consequência |
|---|---:|---|---|
| alternar_estado_campanha | 20103 | campanha → ataques AOO → pendências AOO | Caminho de transição de combate que disputa ataque/pending com resolvers |
| srd_resolver_ataque_oportunidade_srd | 27025 | ataque → pending → campanha | Inversão direta contra alternar_estado_campanha |
| srd_aplicar_dano_ataque_oportunidade_srd | 27036 | ataque → pending → campanha → ficha do alvo (FOR UPDATE) | Acrescenta a interseção com estabilização e outras mutações de ficha |
| srd_aplicar_dano_ataque_oportunidade_monstro_srd | 27058 | ataque → pending → campanha → ficha vinculada (quando aplicável) | Mesmo prefixo de AOO; pode alcançar ficha persistente de NPC vinculado |
| srd_iniciar_ataque_oportunidade_srd | 27022 | pending → campanha → ledger → leitura da ficha → arma FOR SHARE | Inversão pending/campanha; ledger e arma entram depois da campanha |
| srd_iniciar_ataque_oportunidade_desarmado_srd | 27065 | pending → campanha → ledger | Variante desarmada mantém o prefixo pending-first |
| srd_iniciar_ataque_oportunidade_monstro_srd | 27055 | pending → campanha → ledger | Variante de monstro mantém o prefixo pending-first |
| srd_finalizar_movimento_aoo_pendente_srd | 27038 | pending → campanha | Finalização mantém pending-first; consulta ataques sem bloqueá-los |
| srd_registrar_ocultacao_ataque_oportunidade_impl | 27254 | ataque → pending → campanha | Helper privado SECURITY DEFINER chamado pelo wrapper público invoker |

O teste sintético #7 representa o ciclo campanha → ataque versus ataque → pending → campanha; os testes #3/#4 cobrem campanha ↔ pending e pending ↔ ataque. O banco não registrou reprodução de deadlock real; a conclusão é de ciclo potencial derivado dos locks e da concorrência entre chamadas autenticadas, não de incidente observado.

O lock da ficha no RPC de dano AOO (27036) torna concreta a interseção com estabilização (24914): AOO mantém ataque/pending/campanha e espera ficha; estabilização mantém personagem/ficha e espera campanha. A ordem candidata para dano em personagem persistente deve ser campaign → character → sheet → pending → attack, mas isso precisa ser reconciliado com o restante do domínio AOO, incluindo ledger/weapon e transições de estado, antes de alterar qualquer RPC.


### CI mais recente do harness (2026-11-10)

O workflow PostgreSQL [42730159992](https://github.com/clubberblues/rpgvinculo/actions/runs/42730159992), run #72, concluiu com sucesso no commit documental anterior `027fa057a0f6ccd3a111e2a3a97b50e45f8b1f5d`. Setup, containers, checkout, cliente PostgreSQL, execução dos fixtures isolados e teardown concluíram. O commit atual `0e53e84b7914022b69410a1f4d1b3fd396ee8813` acrescentou somente documentação; nenhum arquivo de fixture ou workflow foi alterado depois do run #72. Logo, os testes sintéticos versionados continuam cobertos pelo CI #72, sem que isso represente execução de RPCs de produção.


### Snapshot operacional read-only — 2026-11-10

Consulta pontual a pg_stat_database para o banco atual `postgres`: desde `stats_reset = 2026-08-25 20:33:23+00`, foram contabilizados 4.268.202 commits, 8.365 rollbacks, 0 deadlocks e 0 conflicts. No instante da consulta havia 0 sessões aguardando lock e 0 locks não concedidos. Isso não exclui deadlocks anteriores ao reset, transações muito breves entre amostragens ou ciclos potenciais ainda não exercitados; os prefixos conflitantes continuam demonstrados nos corpos das RPCs e precisam de correção/teste transacional.


**Detalhe conferido nos logs do job #72:** `footprint_fixture.sql` e `footprint_test.sql` foram executados; o log registrou `footprint helper assertions passed`. O `lock_cycle_test.sh` registrou oito mensagens `passed synthetic lock inversion` e uma `passed consistent lock order`. As mensagens `ERROR: deadlock detected` aparecem nas sessões sintéticas intencionalmente invertidas e são esperadas pelo teste; o job terminou `success`. Isso confirma o harness e os helpers copiados, não os RPCs instalados no Supabase.


### Call sites de conjuração manual single-target confirmados no frontend (2026-11-10)

A inspeção direta de mesa.html (linhas 3646–3651) encontrou três rotas: multialvo de cura/dano/efeito já mapeadas; Míssil Mágico chama public.conjurar_missil_magico_srd_manual (OID 25191); demais magias single-target manuais chamam public.conjurar_magia_com_acao_srd_manual (OID 24658).

- **Míssil Mágico:** OID 25191 é SECURITY DEFINER com EXECUTE authenticated. Bloqueia characters FOR UPDATE → srd_character_sheets FOR UPDATE; delega para public.conjurar_missil_magico_srd (OID 24356, sem EXECUTE direto para authenticated), que chama public.conjurar_magia_com_acao_srd (OID 20410, também interno/sem EXECUTE autenticado) e adquire campanha depois dos locks de personagem/ficha. Prefixo alcançável: personagem → ficha → campanha. É mais um caminho single-target que pode disputar a mesma ficha com aplicação de magia pendente campaign-first.
- **Demais magias manuais:** OID 24658 é SECURITY DEFINER com EXECUTE authenticated. Bloqueia personagem → campanha; depois chama public.conjurar_magia_srd_manual (OID 24656, sem EXECUTE direto autenticado), que bloqueia ficha e revalida/usa campanha. A ordem é branch/chain específica: personagem → campanha → ficha no caminho externo; não confundir com o prefixo personagem → ficha → campanha do Míssil Mágico.
- Os OIDs 20410, 24356 e 24656 são helpers internos nesta rota, não endpoints frontend diretos no snapshot; a ausência de EXECUTE autenticado nesses helpers não é, isoladamente, falha de permissão, pois são chamados dentro dos wrappers SECURITY DEFINER autenticados.

A correção da conjuração manual precisa começar pela campanha antes de qualquer lock de personagem/ficha quando a operação está vinculada à campanha; depois revalidar dono, participação, ficha, espaço, alvo, resistência à magia, rolagens e custo de ação. Testar separadamente Míssil Mágico, magia single-target manual, efeitos multialvo e dano multialvo.


### Rota multialvo de cura — wrapper autenticado (2026-11-10)

A inspeção do call site de mesa.html (linha 3648) confirmou que cura multialvo usa public.conjurar_magia_com_acao_srd_multialvo_v3 (OID 24661), SECURITY DEFINER com EXECUTE authenticated. O wrapper bloqueia personagem FOR UPDATE → campanha FOR UPDATE → chama public.conjurar_magia_srd_multialvo_v3 (OID 24659, helper interno) que bloqueia personagem/ficha e reentra na campanha. Ordem externa efetiva: personagem → campanha → ficha; não classificar como ficha→campanha no wrapper, embora o helper isolado tenha essa sequência quando executado sem o wrapper. A reentrada ocorre dentro da mesma transação e o lock da campanha já está retido.

A rota de cura multialvo precisa permanecer separada das rotas de dano/efeito multialvo (OIDs 25246/25109), que bloqueiam personagem → ficha antes de adquirir campanha via consumo de ação. Testes e refatoração devem preservar esta distinção de wrapper e helper, revalidando campanha/estado antes do custo de ação e da alteração dos alvos.


### Writer legado de propriedade da campanha — corrida de autorização (2026-11-10)

A varredura de funções que escrevem em campaigns encontrou um caso fora do grafo principal de combate: public.gm_transfer (OID 18749) é SECURITY DEFINER, tem EXECUTE para authenticated e não tem lock explícito de campanha. Chama priv.need_owner (OID 18742), que verifica owner_id por SELECT comum, sem FOR UPDATE; depois atualiza o papel do membro atual, o papel do destinatário, owner_id da campanha e grava log. Não foi encontrado call site direto em mesa.html, ficha.html ou lobby.html consultados, portanto classificar como endpoint autenticado legado/sem consumidor frontend localizado, não como fluxo ativo de UI.

Há uma corrida de autorização plausível: duas chamadas concorrentes do proprietário atual podem passar por need_owner antes de qualquer uma confirmar. A primeira transfere a propriedade; a segunda aguarda o lock da linha de membro, mas a condição WHERE da atualização continua válida e, sem revalidar owner_id depois de obter lock, pode concluir uma segunda transferência iniciada pelo antigo proprietário. Isso é TOCTOU/concorrência de autorização, não deadlock reproduzido.

Correção candidata se o endpoint for mantido: localizar campanha por MVCC, bloquear campaigns FOR UPDATE, revalidar owner_id=auth.uid() e active, validar destinatário ainda membro, bloquear/atualizar os dois membros em ordem determinística e só então alterar owner_id e registrar log. Teste concorrente obrigatório: duas transferências simultâneas pelo mesmo proprietário; no máximo uma pode confirmar e a segunda deve falhar por perda de autoridade. Confirmar call sites externos antes de remover ou alterar o RPC.

Outros escritores legados sem lock explícito de campanha observados na mesma varredura — start_combat (OID 19090), end_combat (OID 19091) e scene_config (OID 18753) — não têm EXECUTE para authenticated/anon no snapshot. Não os classificar como endpoints acessíveis pelo cliente autenticado; manter como legado service_role e reavaliar se grants/callers mudarem.


### CI #100 — regressão de autorização concorrente aprovada (2026-11-10)

O workflow [42731471362](https://github.com/clubberblues/rpgvinculo/actions/runs/42731471362), run #100, concluiu success no commit `dd38946efd5cd9ef58ec8ef33b492227793141e7`. Os logs confirmam: footprint helper assertions passed; oito inversões sintéticas esperadas; controle positivo campaign→effect; reprodução sintética da corrida de gm_transfer (duas chamadas pré-validadas, owner final player-c, dois membros GM); e controle corrigido campaign-first (segunda chamada rejeitada por perda de autoridade, owner final player-b, um único GM). O commit posterior `628beee3f2e979fadc99f47f5e2f58d94f098d78` alterou somente README/documentação; setup e script SQL testados não mudaram. A regressão é uma simulação transacional descartável, não execução da RPC instalada nem evidência de exploração em produção.


### Fechamento da varredura de writers diretos de campaigns — EXECUTE authenticated

A consulta read-only filtrou funções instaladas que fazem INSERT/UPDATE em campaigns, têm EXECUTE efetivo para authenticated e não exibem SELECT ... FOR UPDATE sobre a campanha no próprio corpo. Restaram três casos:

- `public.create_campaign` (OID 18744): INSERT de uma nova linha de campanha; não disputa lock de uma campanha preexistente e não é inversão de lock.
- `public.adicionar_token_cba_completo` (OID 21726): o corpo não adquire lock diretamente, mas chama `public.adicionar_token_cba` (OID 20075), que bloqueia a linha da campanha FOR UPDATE na mesma transação antes de enriquecer o JSONB. Classificar como lock herdado, não como writer sem lock.
- `public.gm_transfer` (OID 18749): atualiza uma campanha existente sem lock/revalidação pós-lock; corrida TOCTOU documentada acima.

Assim, nesta fotografia não apareceu outro writer direto authenticated de campaigns sem lock explícito ou herdado além de gm_transfer. O filtro é estático por corpo SQL e não substitui auditoria de triggers, chamadas dinâmicas ou consumidores externos.


### Corridas de estado: descanso longo e poção de cura (snapshot read-only 2026-11-10)

Foram lidos os corpos instalados e os grants efetivos dos endpoints:

- `public.descanso_longo_personagem_srd` (OID 24366): SECURITY DEFINER, EXECUTE authenticated. Bloqueia primeiro `characters` FOR UPDATE; consulta `campaigns.state` sem lock; depois bloqueia a ficha e altera PV, condições, magias e recursos. Se a campanha estiver em exploração na leitura, uma transição concorrente para combate pode confirmar enquanto o descanso continua e escreve estado de descanso durante combate. É uma corrida de estado/serialização, não um deadlock demonstrado.
- `public.usar_pocao_cura_srd_manual` (OID 24655): SECURITY DEFINER, EXECUTE authenticated. Valida propriedade, lê `campaign_id` e `campaigns.state` sem lock. Só chama `consumir_acao_turno_srd` (OID 20405) se a leitura já indicar combate; essa função bloqueia campanha FOR UPDATE e revalida estado/turno. Se a poção observar exploração e o Mestre iniciar combate antes do consumo, o ramo não chama o consumo de ação e pode curar/consumir inventário sem gastar ação no combate. O lock da campanha dentro do helper de ação não cobre o ramo de exploração.
- `public.alternar_estado_campanha` (OID 20103) é o caminho de transição autenticado para GM e bloqueia `campaigns` FOR UPDATE antes de alterar estado/combat_data. `public.start_combat` (OID 19090) não tem EXECUTE para authenticated nem anon no snapshot e não deve ser tratado como rota ativa do cliente.
- `priv.srd_sync_character_vital_condition` (OID 24908) atualiza condições vitais sem bloquear campanha; deve herdar a pré-condição de campaign-first dos entrypoints que operam em campanha, sem adquirir campanha internamente depois de ficha/character.

Correção candidata: ambos os endpoints devem localizar campanha por leitura MVCC, bloquear a linha da campanha primeiro, revalidar vínculo/owner/estado após o lock e só então bloquear personagem, ficha, equipamento e recursos na ordem validada de cada domínio. Descanso deve rejeitar combate já iniciado; poção deve decidir e consumir a ação sob o mesmo lock de campanha que serializa a transição, sem uma janela entre leitura de estado e consumo. Preservar as validações de propriedade, alvo, PV, item, rolagens e regras de ação. Testes concorrentes obrigatórios: descanso × início de combate; poção × início de combate; poção durante combate × ação já consumida; duas poções concorrentes × última unidade do inventário.

Limite da evidência: análise estática dos corpos instalados e grants, sem execução concorrente das RPCs reais; nenhuma função/migration/ACL/policy/dado foi alterado no Supabase.


### Contraste validado: descanso de NPC vinculado já é campaign-first

O frontend de ficha chama também `public.descanso_longo_npc_vinculado_srd` (OID 26801, EXECUTE authenticated), wrapper SQL que delega a `priv.descanso_longo_npc_vinculado_srd_impl` (OID 26808). A implementação bloqueia `campaigns FOR UPDATE` e valida estado antes de bloquear token derivado do snapshot, personagem e ficha; depois ressincroniza campanha sob o lock já retido. Portanto, não generalizar a falha do descanso PC para NPC: o caminho NPC já serializa a transição de combate. Ainda requer teste de integração de autoridade/estado, mas não apresenta a mesma janela de leitura sem lock observada em OID 24366.

Call sites confirmados no frontend principal: `ficha.html` chama descanso PC ou NPC vinculado; `mesa.html` chama a poção manual e `alternar_estado_campanha`. Nenhum call site de `srd_remove_campaign_condition` foi localizado nas três páginas consultadas; manter como endpoint authenticated legado até confirmar consumidores externos.


### Triggers de inventário → instâncias de arma (2026-11-10)

A inspeção de `pg_trigger` confirmou efeitos transitivos que precisam integrar qualquer ordem de locks:

- `public.srd_character_equipment` tem trigger AFTER INSERT/DELETE/UPDATE OF quantidade `sync_character_weapon_instances_from_inventory` (função private OID 26446). Para armas, cria ou remove linhas em `public.srd_character_weapon_instances` e depois atualiza equipado/hand_slot na própria linha do inventário. Prefixo transacional: lock implícito da linha de inventário → instâncias de arma → atualização reentrante da linha de inventário.
- `public.srd_cba_token_equipment` tem trigger equivalente `sync_token_weapon_instances_from_inventory` (private OID 26447), que cria/remove `srd_cba_token_weapon_instances` e sincroniza equipado/hand_slot no inventário do token.
- Não há trigger de usuário instalado diretamente em `srd_character_weapon_instances` ou `srd_cba_token_weapon_instances` no snapshot consultado. Isso não exclui FK, índices únicos ou locks adquiridos pelo SQL chamado.

Essas arestas são consequência de INSERT/DELETE/UPDATE de quantidade e não aparecem no corpo do RPC chamador. O inventário de locks já deve tratar equipamento → instância de arma como aresta real herdada por trigger, mas não inferir ciclo sem cruzar com os locks efetivos dos endpoints de ataque. Nenhuma alteração remota.


### Refinamento do subgrafo de equipamento e instâncias (2026-11-10)

A leitura das implementações privadas corrigiu uma generalização anterior sobre a direção do lock:

- Personagem/arma: `public.equipar_arma_instancia_personagem` (wrapper OID 26442) chama `private.equipar_arma_instancia_personagem_impl` (OID 26441). A implementação bloqueia `characters FOR UPDATE`, depois a instância em `srd_character_weapon_instances FOR UPDATE`, atualiza instâncias e por fim sincroniza `srd_character_equipment`. Prefixo real: personagem → instância de arma → inventário/equipamento.
- NPC/monstro: wrapper OID 26444 → impl OID 26443. A implementação bloqueia campanha primeiro, depois instância `srd_cba_token_weapon_instances`, e por fim inventário `srd_cba_token_equipment`. Prefixo real: campanha → instância de arma do token → inventário do token.
- Os triggers de quantidade (private OIDs 26446/26447) têm prefixo inventário/equipamento → instâncias de arma apenas quando quantidade muda. Porém, a auditoria dos writers encontrados não identificou caminho autenticado atual que reduza/exclua quantidade de arma: o decremento é das rotas de poção, cujos IDs de item não são armas; a entrega soma quantidade; a inicialização insere; exclusão de personagem faz limpeza em cascata. Portanto, não afirmar deadlock ativo entre trigger de decremento e equipar arma sem localizar um writer de arma que alcance esse ramo. O ramo negativo do trigger continua exigindo teste se/ quando surgir um writer correspondente.
- O caminho de token já serializa operações de equipamento pelo lock de campanha; o caminho de personagem usa lock da linha character antes de instância. Não colapsar os dois domínios em uma ordem global sem verificar os chamadores.

### Revalidação de papel GM em mutações de inventário

Três endpoints autenticados leem o papel GM antes de adquirir o lock de campanha (ou sem adquiri-lo): `public.entregar_item_srd` (OID 20556), `public.entregar_item_token_srd` (OID 21668) e `public.equipar_item_token_srd` (OID 21670). O primeiro não bloqueia campanha; os dois de token bloqueiam campanha apenas depois da consulta ao papel. A transferência `gm_transfer` (OID 18749) altera owner/membership. Assim, uma operação iniciada por um GM pode validar papel antigo, esperar/concorrer com transferência e continuar após a revogação. Para os endpoints token, o lock posterior da campanha não corrige a validação anterior: é necessário reler e revalidar o papel depois de adquirir o lock. Para entrega de ficha, adotar o mesmo padrão campaign-first, revalidando papel e pertencimento do alvo antes dos locks de inventário. Trata-se de janela TOCTOU de autorização, não deadlock reproduzido; ainda não há teste concorrente de RPC real.


#### Extensão do inventário de endpoints GM (grants verificados)

A matriz de EXECUTE authenticated confirma também:

- `public.equipar_item_srd_maos` (OID 26390) delega ao impl privado `equipar_arma_instancia_personagem_impl` (OID 26441), que bloqueia personagem e consulta papel GM sem bloquear campanha. O caminho de jogador-proprietário não depende do papel GM; o caminho de GM pode usar papel revogado durante a transação.
- `public.equipar_arma_instancia_token` (OID 26444) delega ao impl OID 26443, que consulta papel GM antes de bloquear campanha e não o revalida depois do lock.
- `public.clonar_equipamento_ficha_para_token` (OID 26515) consulta papel GM, depois lê origem/token e altera inventário/instâncias sem bloquear campanha nem revalidar papel. É candidato adicional à mesma janela de autorização e a uma corrida de snapshot/sincronização do inventário do token.

Esses endpoints têm EXECUTE authenticated e não anon no snapshot. A lista de rotas para análise de revogação GM passa a incluir OIDs 20556, 21668, 21670, 26390→26441, 26444→26443 e 26515. A regra de correção deve ser aplicada por domínio e autorização: para mutação de token/campanha, campaign FOR UPDATE antes de ler/revalidar role e token; para mutação de ficha PC, character/campaign lock order coerente com o protocolo e revalidação da autorização GM sob a serialização escolhida. Não inserir campaign lock depois de character/sheet.


### Ampliação: administração da campanha e início de iniciativa (snapshot 2026-11-10)

A busca por todas as funções SECURITY DEFINER com EXECUTE authenticated que alteram `members` encontrou mais caminhos que compartilham a mesma janela de autorização:

- `priv.need_owner` (OID 18742) verifica `campaigns.owner_id=auth.uid()` e `active` por EXISTS simples, sem `FOR UPDATE`.
- `public.gm_set_role` (OID 18748) e `public.gm_kick` (OID 19188) chamam `need_owner`, depois atualizam/excluem `members` sem bloquear campanha. Um antigo GM pode validar ownership antes de uma transferência e concluir alteração de papel/expulsão depois dela.
- `public.gm_transfer` (OID 18749) tem o mesmo check sem lock, depois muda papéis e owner. Já existe cenário sintético de duas transferências concorrentes.
- `public.iniciar_iniciativa_com_dados` (OID 20577) valida `members.role='GM'` e pertencimento dos participantes antes de bloquear `campaigns FOR UPDATE`. Se o GM for rebaixado durante a janela, a iniciativa ainda pode ser gravada após a revogação. EXECUTE authenticated confirmado.
- `public.sentar_personagem_na_mesa` (OID 21606) valida papel PLAYER antes de bloquear a ficha e não bloqueia campanha. O risco primário é inconsistência de associação/estado se a membership mudar entre validação e update; o efeito é distinto do abuso de GM e precisa ser avaliado com o fluxo de associação de personagens.
- `public.leave_campaign` (OID 19187) lê papel via `my_role` e remove membership sem lock de campanha. A leitura obsoleta pode competir com mudança de papel/expulsão; avaliar idempotência e logs.

A família de mutações administrativas deve compartilhar uma serialização: localizar campanha por MVCC → bloquear campanha FOR UPDATE → revalidar owner_id/active e membership/papel → bloquear/alterar membros em ordem determinística → registrar log. `iniciar_iniciativa_com_dados` deve adquirir campanha antes de validar GM e participantes; validar os vínculos relevantes novamente após o lock. Não basta corrigir apenas os endpoints de inventário. Esta é análise estática de janelas TOCTOU, não prova de exploração; nenhuma função foi alterada.


### Incompatibilidade determinística entre gm_transfer e enforce_campaign_member_role (2026-11-10)

A inspeção do trigger instalado `public.enforce_campaign_member_role` (OID 21603; enabled O) revelou incompatibilidade direta com a ordem atual de `public.gm_transfer` (OID 18749):

1. `gm_transfer` atualiza primeiro o membro proprietário antigo para PLAYER. O trigger lê o `campaigns.owner_id` ainda antigo e força esse mesmo usuário de volta a GM.
2. Em seguida, `gm_transfer` tenta atualizar o novo proprietário para GM. O trigger ainda lê o owner antigo e converte o novo GM em PLAYER.
3. Só depois a função atualiza `campaigns.owner_id` para o novo proprietário. Não existe trigger adicional em `campaigns.owner_id` que corrija os papéis.

Consequência prevista pelo código instalado: após transferência, `campaigns.owner_id` aponta para o novo proprietário, mas a membership mantém o antigo owner como GM e o novo como PLAYER. Isso é diferente da corrida concorrente previamente documentada: é incompatibilidade determinística de ordem dentro de uma única chamada, causada pelo trigger BEFORE em cada UPDATE de membership.

A agregação read-only no banco encontrou 3 campanhas; nas 3, o proprietário atual está como GM e existe exatamente um GM. Portanto, não há evidência de inconsistência já persistida no snapshot consultado, mas também não há teste real de execução de `gm_transfer` no banco. O novo fixture PostgreSQL replica a lógica do trigger e a ordem exata da função, esperando reproduzir o papel antigo GM/novo PLAYER; o controle troca owner_id primeiro sob lock de campanha e depois atualiza membership, esperando antigo PLAYER/novo GM.

Correção candidata: bloquear campanha primeiro; validar owner atual; atualizar `campaigns.owner_id` dentro da transação; atualizar papéis depois, em ordem determinística, para que o trigger veja o novo owner. Testar em PostgreSQL descartável com o trigger equivalente, incluindo falha/rollback e duas transferências concorrentes. Não aplicar alteração remota até reconciliar migrations e obter aprovação para implantação.


### Superfície ampliada de operações GM com validação antes do lock

A varredura por SECURITY DEFINER authenticated e validação explícita de papel GM antes do primeiro `FOR UPDATE`, combinada com call sites do frontend, encontrou estes caminhos ativos adicionais:

- `alternar_estado_campanha` (OID 20103): valida GM e depois bloqueia campanha.
- `salvar_cena_cba` (OID 20077): valida GM e depois bloqueia campanha para substituir snapshot CBA.
- `adicionar_combatente_iniciativa` (OID 20078) e `mover_combatente_iniciativa` (OID 20080): validam GM e depois bloqueiam campanha.
- `iniciar_iniciativa_com_dados` (OID 20577): valida GM e lista de participantes antes do lock de campanha.
- `srd_configurar_perfil_combate_token_srd` (OID 26922), `srd_configurar_rodada_surpresa_srd` (OID 27092) e `usar_furia_barbaro_npc_srd` (OID 26656): validam `my_role(...)=GM` antes do lock de campanha.
- Inventário de token: `entregar_item_token_srd` (OID 21668) e `equipar_item_token_srd` (OID 21670) validam papel antes do lock.

Call sites encontrados em `mesa.html`: alternância de estado, salvar CBA, adicionar/reordenar iniciativa, perfil de combate do token, rodada surpresa e Fúria de NPC. `ficha.html` também chama Fúria de NPC vinculado. Portanto, a janela de autorização não é só teórica nem limitada a endpoints sem frontend.

Após corrigir a ordem de `gm_transfer`, cada endpoint de GM que bloqueia campanha depois de validar papel ainda precisa revalidar `members.role='GM'` depois de obter o lock. Caso contrário, uma chamada que leu GM antes da transferência pode esperar pelo lock e executar depois da revogação. A ordem segura é campaign FOR UPDATE → revalidar owner/membership/papel e estado → locks de domínio/ações. Para endpoints que não precisam de lock da campanha, definir serialização explícita antes de alterar membership.


#### Completar endpoints de owner: código de acesso

A mesma dependência de `priv.need_owner` (OID 18742) aparece em `public.gm_set_code` (OID 18747), EXECUTE authenticated. A função valida owner/active por `need_owner` e depois altera `campaign_codes` sem lock de campanha. Assim, o antigo proprietário também pode alterar o código de entrada depois de uma transferência concorrente se a autorização tiver sido validada antes da revogação. A matriz de operações owner-first passa a incluir `gm_set_code`, `gm_set_role`, `gm_kick` e `gm_transfer`; o helper não deve ganhar lock implícito sem auditar callers.


### Fechamento da chamada de priv.need_owner

Consulta completa de dependências no catálogo do banco: `priv.need_owner` (OID 18742) é chamado por exatamente quatro endpoints públicos authenticated: `gm_set_code` (18747), `gm_set_role` (18748), `gm_transfer` (18749) e `gm_kick` (19188). Nenhum desses quatro adquire lock da campanha antes do helper; o helper também não bloqueia campanha. A correção deve ser implementada em cada endpoint ou por wrapper transacional explícito, sem introduzir lock implícito no helper até mapear eventuais futuros callers. A janela de stale authorization está confirmada para transfer e kick pelos fixtures; set_code e set_role compartilham a mesma estrutura estática, mas ainda não têm cenários dedicados.

GitHub Actions #141 no commit `cf1ba84cc55171e295d69e2b8f0bde19830b8943` aprovou os cenários atuais, incluindo reprodução e controle de transferência, kick, revogação GM em inventário e trigger-order da transferência.


### Segunda camada de endpoints GM: priv.need_gm e mutações SRD

A varredura completa das chamadas de `priv.need_gm` (OID 18741) mostrou que o helper também é apenas uma leitura de papel via `my_role`, sem lock nem revalidação. Entre os endpoints com EXECUTE authenticated no snapshot:

- `gm_get_code` (18746): leitura do código; risco de confidencialidade após revogação do papel, sem mutação.
- `gm_grant` (18752): verifica GM, depois bloqueia personagem e concede ouro/XP/item. Se houver transferência enquanto espera pelo lock da ficha, pode conceder recursos depois de perder o papel. Não adquire campaign lock antes da ficha.
- `media_gc` (18760): verifica GM e exclui registros de mídia sem campaign lock. O navegador pode então remover arquivos do Storage; ação externa subsequente não é atômica com o banco.
- `gm_reopen_sheet` (18892) e `gm_set_bonus` (18893): leem personagem, verificam GM e alteram ficha sem serializar pela campanha; podem concluir após revogação.

Outras funções authenticated usam `public.my_role(cid)='GM'` diretamente:
- `srd_apply_campaign_condition` (24805) e `srd_apply_campaign_effect` (24896) verificam GM antes de chamar helpers privados que depois bloqueiam a campanha. A operação espera pelo campaign lock sem revalidar o papel depois dele.
- `srd_remove_campaign_condition` (24806) e `srd_remove_campaign_effect` (24897) verificam GM e alteram tabelas de condição/efeito sem campaign lock.
- `srd_configurar_perfil_combate_token_srd` (26922), `srd_configurar_rodada_surpresa_srd` (27092), `usar_furia_barbaro_npc_srd` (26656) e os endpoints de CBA/iniciativa já registrados têm lock de campanha posterior à checagem inicial e precisam revalidar GM depois do lock.

Não generalizar todos os endpoints como mesma correção: leitura de código, remoção de condição, concessão de recursos, mídia e alterações de ficha têm efeitos e locks diferentes. Matriz candidata: (a) operações mutáveis de campanha/token: campaign FOR UPDATE → revalidar GM → locks de domínio; (b) mutações de personagem/ficha: localizar campaign_id por MVCC, campaign FOR UPDATE → revalidar GM e vínculo → character → sheet/resource; (c) operações externas Storage: autorizar e marcar exclusão no banco sob campanha lock, depois tratar remoção de arquivo como etapa idempotente/reconciliável; (d) leituras protegidas: avaliar se exigem lock para revogação estrita ou aceitar consistência eventual explicitamente.

Os endpoints acima foram identificados por catálogo/EXECUTE authenticated; a ausência de call site literal nos três arquivos principais não prova que nenhum consumidor externo exista. A lista de chamadas de `priv.need_gm` foi consultada no catálogo atual e inclui funções legadas sem EXECUTE authenticated, que não entram na superfície de RPC para o cliente.


### Status de exposição frontend dos endpoints GM de personagem/mídia

Busca exata no repositório completo (GitHub code search) e inspeção de `mesa.html`, `ficha.html`, `lobby.html` não encontraram call sites para `gm_grant`, `gm_reopen_sheet`, `gm_set_bonus`, `media_gc` ou `srd_apply_campaign_effect`/condition wrappers. São funções com EXECUTE authenticated no banco, portanto continuam endpoints acessíveis a clientes autenticados que conheçam a RPC, mas não foram confirmadas como fluxos usados pelo frontend atualmente versionado. Tratar como superfície RPC pública, não como caminho UI ativo. Essa distinção também vale para `gm_get_code` e removers de condição/efeito até surgir call site.

A ordem específica desses endpoints reforça por que a correção deve ser por família: `gm_grant` valida GM e depois bloqueia personagem; `gm_reopen_sheet`/`gm_set_bonus` leem personagem e depois validam GM, atualizando ficha sem campaign lock; `media_gc` valida GM e exclui mídia sem campaign lock; wrappers de apply verificam GM e depois entram em helper que bloqueia campanha; removers alteram condições/efeitos sem campaign lock. Nenhuma dessas diferenças deve ser apagada por um refactor mecânico único.


### Resultado da varredura completa de role checks (catálogo atual)

A consulta do catálogo público encontrou 41 funções com EXECUTE authenticated cujo corpo menciona `my_role(...)` junto de comparação com GM, além dos grupos `need_owner` (4) e `need_gm` (5). Esses números são contagem lexical de funções, não 41 vulnerabilidades: há leituras, endpoints que também autorizam o dono da ficha, operações de jogador, e funções com papéis mistos. Helpers no schema `priv` foram excluídos da contagem de RPC públicas; EXECUTE privilege sem USAGE no schema privado não implica chamada direta pelo cliente.

A lista exata com `my_role(...) IS DISTINCT FROM 'GM'` contém operações ativas de AOO, dano, confirmação crítica, movimento pendente, Fúria NPC, condições/efeitos, rodada surpresa, perfil de token, estabilização e resolução de resistências de magia. Várias têm call sites em `mesa.html`; isso amplia a revisão de authorization freshness para os fluxos de combate. Porém, cada corpo deve ser classificado: alguns permitem o dono/jogador como alternativa ao GM, alguns são somente consulta, e outros são ações administrativas exclusivas do GM. Não aplicar uma revalidação GM indiscriminada em ações de jogadores.

Exemplos já confirmados de mutações que precisam de análise campaign-first quando a autorização é GM: wrappers apply condition/effect (checam antes do helper que bloqueia campanha); perfil de combate/rodada surpresa/Fúria NPC (checam antes do lock); resolução de estabilização e resolução de resistência (alguns bloqueiam personagem/pending antes de campanha e admitem jogador dono). As rotas AOO também misturam ações de Mestre e reação/rolagem de jogadores; separar a autorização do ator para cada transição de estado antes de refatorar.


### Confirmação no catálogo remoto — ordem efetiva AOO (2026-11-10)

Uma consulta read-only a `pg_get_functiondef` no Supabase, extraindo em ordem textual todos os contextos `FOR UPDATE`, confirmou inversões reais no código instalado (não apenas propostas de fixture):

| Função instalada | OID | Ordem observada |
|---|---:|---|
| `public.srd_resolver_ataque_oportunidade_srd` | 27025 | attack → pending movement → campaign |
| `priv.srd_registrar_ocultacao_ataque_oportunidade_impl` | 27254 | attack → pending movement → campaign |
| `priv.srd_reservar_reacao_movimento_aoo_impl` | 27256 | pending movement → campaign |
| `priv.srd_resolver_encontrao_srd` | 27169 | pending movement → campaign |
| `priv.srd_cancelar_movimento_aoo_pendente_impl` | 27268 | pending movement primeiro; o restante do corpo requer revisão para confirmar locks subsequentes |
| `priv.srd_encerrar_reacao_aoo_pendente_impl` | 27269 | pending movement → attack; o restante do corpo requer revisão para confirmar locks subsequentes |

**Incompatibilidade confirmada:** solicitação de movimento e finalização seguem campaign-first, mas várias transições de reação começam bloqueando pending (e duas bloqueiam attack antes de pending/campaign). Há, portanto, uma ordem de locks não uniforme na mesma máquina de estados AOO. A consulta confirma a inversão estrutural; não foi executada concorrência contra o banco remoto e não se afirma que um deadlock tenha ocorrido em produção.

**Correção estrutural candidata:** toda RPC AOO deve localizar a campanha/pending/attack por leitura MVCC sem lock, obter primeiro `campaigns FOR UPDATE`, revalidar combate/turno/pending/ator, depois bloquear pending movement, reaction ledger/attack e por último ficha/arma/equipamento segundo a necessidade do ramo. Para qualquer operação que afete várias campanhas, ordenar IDs crescentemente. Não basta mover uma linha `FOR UPDATE`: os wrappers e helpers transitivos precisam obedecer ao mesmo protocolo e não reacquirir locks em ordem inversa.

**Cobertura obrigatória:** concorrência resolver ataque × finalizar movimento; reservar reação × cancelar pending; resolver Encontrão × encerrar reação; registrar ocultação × finalizar movimento; e duas reações simultâneas para o mesmo pending. Cada cenário deve verificar ausência de deadlock, transição idempotente, status terminal consistente e nenhuma coordenada/dano parcialmente persistidos.



### Refinamento da cadeia de cancelamento/encerramento AOO

A inspeção integral dos corpos instalados esclareceu duas funções que não bloqueiam a campanha:

- `priv.srd_cancelar_movimento_aoo_pendente_impl` (OID 27268) bloqueia pending e depois atualiza ataques associados (UPDATE adquire row lock implicitamente), finalizando pending; não lê/bloqueia `public.campaigns`. É pending → attack, sem campaign lock.
- `priv.srd_encerrar_reacao_aoo_pendente_impl` (OID 27269) bloqueia pending; se o GM cancelar ataque iniciado, bloqueia attack depois. Também não lê/bloqueia `public.campaigns`. É pending → attack condicional, sem campaign lock.
- Portanto, não classificar essas duas como pending → campaign. O problema é diferente: cancelamento/encerramento não serializam com o lock da campanha usado pela solicitação/finalização e a autorização GM é verificada antes do lock pending. A correção precisa campaign-first e revalidar estado/GM, depois pending → attack.
- As quatro inversões com campaign efetivamente bloqueada permanecem: OIDs 27025, 27254, 27256 e 27169, detalhadas acima.



### Trigger de prévia AOO — escopo do sinalizador transacional (2026-11-10)

A inspeção do trigger instalado `priv.srd_validate_aoo_pending_movement_preview()` (AFTER INSERT em `priv.srd_aoo_pending_movements`) revelou um detalhe de segurança/robustez que precisa entrar no desenho da correção:

- O trigger chama `set_config('app.srd_aoo_pending_commit', new.pending_id::text, true)` **antes** de abrir o bloco interno que executa a prévia de movimento e provoca o rollback controlado.
- O rollback do bloco interno desfaz a atualização simulada de `campaigns.cba_data`, mas o `set_config(..., true)` foi feito fora desse sub-bloco; portanto o valor pode permanecer ativo no restante da transação externa após o trigger retornar.
- O guard de movimento aceita o valor quando ele corresponde ao pending ativo, sem um segundo vínculo explícito ao token/destino/única operação de commit. Assim, o sinalizador é mais amplo do que o necessário enquanto estiver definido.
- O único chamador direto identificado para o INSERT é `public.srd_solicitar_movimento_com_aoo_srd` (OID 26964), que retorna logo após inserir o pending; não foi encontrada escrita posterior na mesma função. Portanto, **não há evidência de exploração funcional no fluxo atual**, mas a permanência do GUC cria uma condição perigosa para wrappers futuros, chamadas aninhadas ou novos escritores na mesma transação.
- A correção deve guardar o valor anterior, limitar a autorização ao sub-bloco da prévia/commit e restaurá-lo em caminho normal e excepcional. Melhor ainda: substituir o GUC amplo por um mecanismo de autorização vinculado a pending + campanha + token + destino e consumido uma única vez. Não remover o trigger de prévia: ele valida o caminho real de movimento antes de aceitar a solicitação.

Evidência: definições instaladas do trigger, do guard `priv.srd_guard_pending_aoo_movement()` (OID 26962) e busca de chamadas ao RPC de solicitação no catálogo. Consulta somente leitura; nenhum pending, token ou GUC foi alterado no banco remoto.


### Máquina de estados AOO — estado `ready_to_commit` sem produtor instalado (2026-11-10)

- A constraint de `priv.srd_aoo_pending_movements.status` permite `waiting_reactions`, `ready_to_commit`, `committed`, `cancelled` e `expired`; o índice parcial de pending ativo e o guard espacial também tratam `ready_to_commit` como ativo.
- A varredura dos corpos PL/pgSQL instalados em `public` e `priv` encontrou referências a `ready_to_commit` em verificações/guardas/cancelamento, mas **nenhuma atribuição que leve um pending a esse status**. Os caminhos atuais de conclusão de movimento, levantamento e Encontrão escrevem diretamente `committed`; o finalizador normal aceita apenas `waiting_reactions`.
- Portanto, no código instalado consultado, `ready_to_commit` é um estado permitido e protegido, porém sem produtor identificado. Não o tratar como etapa funcional existente nem remover a compatibilidade antes de verificar histórico/migrations e eventuais escritores externos.
- Ao consolidar a máquina, escolher explicitamente uma das opções: remover esse estado de constraint/índice/guard após provar que não há dados/consumidores legados; ou implementar a transição e atualizar finalização/cancelamento para aceitá-la com semântica terminal consistente.
- A consulta foi somente leitura; não foram alterados status nem dados de campanha.


### Extensão do grafo AOO — início de ataques, finalização e Derrubar (2026-11-10)

A inspeção ampliada dos fluxos instalados confirmou que a inversão não está restrita às funções já listadas:

- public.srd_iniciar_ataque_oportunidade_srd (OID 27022), public.srd_iniciar_ataque_oportunidade_desarmado_srd (OID 27065) e public.srd_iniciar_ataque_oportunidade_monstro_srd (OID 27055) bloqueiam primeiro srd_aoo_pending_movements, depois campaigns, e em seguida a reserva no ledger. A sobrecarga natural OID 27231 delega ao fluxo OID 27055 e herda a ordem. As três rotas validam GM antes do lock da campanha e não repetem a autorização sob lock.
- public.srd_finalizar_movimento_aoo_pendente_srd (OID 27038) também bloqueia pending antes de campaign. Portanto, a finalização normal compete em ordem inversa com operações campaign-first; não basta tratar apenas início/resolução de ataque.
- A manobra Derrubar tem uma cadeia própria: public.srd_resolver_derrubar_apos_aoo_srd (OID 27145) → priv.srd_resolver_derrubar_apos_aoo_srd (OID 27136) bloqueia pending e depois chama public.srd_resolver_derrubar_srd (OID 27129) → priv.srd_resolver_derrubar_srd_api (OID 27130) → priv.srd_resolver_derrubar_srd (OID 27120), que bloqueia campaign. Ordem efetiva pending → campaign na mesma transação, apesar de o lock de campanha estar em helper transitivo.
- O iniciador de Derrubar public.srd_iniciar_derrubar_com_aoo_srd (OID 27144) → priv.srd_iniciar_derrubar_com_aoo_srd (OID 27131) segue campaign-first antes de inserir o pending; é um controle positivo para o início da manobra.
- O resolver de Derrubar define app.srd_trip_aoo_pending_id e depois o limpa para string vazia tanto no caminho normal quanto no tratamento de erro, em vez de salvar/restaurar o valor anterior. O helper usa esse GUC para autorizar a resolução da manobra e concluir o pending. Assim como o GUC de commit de movimento, o escopo precisa ser limitado e restaurado, sem depender de pressupor que nenhum chamador aninhado já tinha um valor.
- A finalização normal define app.srd_aoo_pending_commit e limpa para vazio apenas no caminho de sucesso; um erro posterior pode deixar o valor transacional configurado até o rollback da transação externa. O desenho deve salvar/restaurar o valor anterior em bloco protegido e vincular a exceção ao pending/campanha/token/destino.

A varredura também confirma que ready_to_commit aparece em constraints/guardas e checks, mas não foi encontrado produtor no código PL/pgSQL instalado. Não remover o estado antes de conferir histórico e consumidores externos.

Evidência: definições e cadeias transitivas consultadas no catálogo remoto via leitura SQL. Nenhuma RPC de combate foi executada; nenhum token, pending, campanha, ACL ou migration remota foi alterado.


### Transições globais que encerram ou bloqueiam a máquina AOO (2026-11-10)

- public.alternar_estado_campanha (OID 20103, EXECUTE authenticated) é campaign-first: bloqueia a campanha e, ao sair de COMBATE, cancela ataques ativos e marca pendings waiting_reactions/ready_to_commit como expired; reações ainda abertas passam a skipped. É um encerramento global legítimo da máquina AOO, não uma inversão de lock pending/campaign. Porém, a função lê/valida membership GM antes do FOR UPDATE e não repete a autorização depois do lock: TOCTOU de autoridade permanece.
- public.avancar_turno (OID 20074, EXECUTE authenticated) também bloqueia campaign antes de verificar se existe pending ativo, e rejeita avanço até o Mestre concluir/cancelar o movimento. É controle positivo para serialização AOO. A role é lida antes do lock; o ramo PLAYER revalida que o turno pertence à própria ficha depois do lock, mas o ramo GM não revalida membership sob lock.
- public.end_combat (OID 19091) também atualiza ataques e pendings AOO, mas não tem EXECUTE para authenticated/anon no snapshot consultado; não tratá-lo como RPC direta do cliente sem outro wrapper autorizado.

O grafo final precisa incluir transições globais de combate além dos endpoints individuais de reação. Revalidar membership/GM depois do campaign lock em alternar_estado_campanha e avancar_turno, preservando a regra de que o turno não avança enquanto houver pending ativo.


### Invariantes físicas do ledger AOO e estado remoto observado (2026-11-10)

Leitura do catálogo e contagens read-only:

- `priv.srd_aoo_pending_movements.status` aceita `waiting_reactions`, `ready_to_commit`, `committed`, `cancelled`, `expired`; índice parcial único permite apenas um pending por campanha nos dois estados ativos (`waiting_reactions`, `ready_to_commit`).
- `priv.srd_aoo_attacks` possui chave primária por ataque, FK para pending e ledger, status limitado a `awaiting_attack_roll`, `awaiting_critical_confirmation`, `awaiting_miss_chance`, `awaiting_damage`, `miss`, `damage_applied`, `cancelled`; tem unicidade para `reaction_id`, `damage_idempotency_key` e chave opcional de idempotência da rolagem.
- `priv.srd_aoo_reaction_ledger` possui unicidade por campanha/fase/rodada/ator/número da reação e por campanha/fase/rodada/ator/trigger_key, prevenindo duplicação lógica de reserva sob a mesma chave.
- No instante da consulta remota, as três tabelas tinham zero linhas (pending, ataques e ledger); também não havia pending `ready_to_commit`. Isto informa apenas o estado atual observado, não prova ausência de uso histórico nem substitui testes funcionais.

Implicação para os testes: incluir asserts concorrentes de que duas reservas para o mesmo ator/trigger convergem para um único ledger entry; rolagem e dano repetidos com a mesma chave não duplicam resultado; cancelamento/expiração não deixam ataques ativos; e o índice de um pending ativo por campanha rejeita criação concorrente. Validar também comportamento quando o pending já está terminal.
