# Inventário de mutações CBA e autoridade durante combate

Data da coleta: 2026-11-09. Fonte: definições SQL remotas, ACLs efetivas e call sites de `mesa.html`. Todas as consultas foram read-only. Este documento descreve o estado observado, não uma migration.

## Matriz de contratos observados

| Operação/RPC | Papel/ACL observado | O que grava | Pending AOO | Geometria/autoridade |
|---|---|---|---|---|
| `public.salvar_cena_cba` | SECURITY DEFINER; EXECUTE authenticated; exige GM | Substitui metadados de cena e objetos dos tokens recebidos em `campaigns.cba_data` | Não consulta pending | Não valida mudança de coordenadas, footprint, ocupação, identidade duplicada nem versão; snapshot obsoleto pode reverter PV/posição |
| `public.adicionar_token_cba` | SECURITY DEFINER; sem EXECUTE direto para authenticated; exige GM | Insere token na cena | Não consulta pending | Bloqueia ID/key duplicado e tenta célula livre, mas compara apenas origem `gridX/gridY`; não valida footprint completo |
| `public.adicionar_token_cba_completo` | SECURITY DEFINER; EXECUTE authenticated; autentica e delega ao RPC acima | Insere token e acrescenta dados de NPC/monstro | Não consulta pending | Herda validação espacial apenas de origem; não congela spawn durante pending |
| `public.mover_token_player_cba` → `priv.mover_token_player_cba_impl` | Wrapper INVOKER; EXECUTE authenticated; implementação valida dono, turno e regras de movimento | Atualiza posição e uso de movimento | Não chama detector nem consulta pending global | RPC direto contorna pré-check AOO; implementação usa footprint 5 para Colossal |
| `public.mover_token_gm_cba_srd` → `priv.mover_token_gm_cba_srd_impl` | Wrapper INVOKER; EXECUTE authenticated; implementação valida GM/turno | Atualiza posição e uso de movimento | Não chama detector nem consulta pending global | RPC direto contorna pré-check AOO; implementação usa footprint 5 para Colossal |
| `public.srd_solicitar_movimento_com_aoo_srd` | SECURITY DEFINER; EXECUTE authenticated; valida player/GM, token e turno | Cria registro em `priv.srd_aoo_pending_movements`; não move | Verifica pending somente depois de detectar nova ameaça | Lock da campanha protege somente esta transação; retorno `pending=false` não vincula a próxima chamada de movimento |
| `public.srd_finalizar_movimento_aoo_pendente_srd` | SECURITY DEFINER; EXECUTE authenticated; valida GM/solicitante e estado da fila | Autoriza commit do movimento depois das reações | Pending `FOR UPDATE`, depois campanha `FOR UPDATE` | Valida round/turn/origem; usa GUC transacional e trigger de preview para chamar o RPC de movimento |
| `priv.srd_guard_pending_aoo_movement` (trigger) | SECURITY DEFINER; trigger BEFORE UPDATE de `campaigns.cba_data` | Protege o token da pending | Lê pending ativo | Bloqueia remoção/alteração de coordenadas apenas do mover; não protege outros tokens, spawn, facção/alcance ou PV |
| `public.alterar_pv_token_cba` | SECURITY DEFINER; EXECUTE authenticated; exige GM | Atualiza PV de NPC/monstro e sincroniza NPC vinculado | Não consulta pending | Não altera coordenadas; mutação de estado durante pending requer política explícita |
| `public.srd_configurar_perfil_combate_token_srd` | SECURITY DEFINER; EXECUTE authenticated; exige GM | Atualiza facção e alcance corpo a corpo | Não consulta pending | Pode mudar quais tokens ameaçam a área durante a resolução |
| `public.adicionar_combatente_iniciativa` | SECURITY DEFINER; EXECUTE authenticated; exige GM | Atualiza `combat_data.turn_order` | Não consulta pending | Preserva ator atual, mas pode alterar a ordem durante a reação |

**Observação:** EXECUTE authenticated indica privilégio efetivo consultado; não significa que qualquer membro possa executar com sucesso. As guardas internas ainda precisam ser respeitadas. A matriz descreve o contrato do corpo, não a experiência visual do frontend.

## Geometria de tokens

- `priv.srd_token_grid_footprint` retorna Colossal = 6 e possui 10 consumidores diretos atuais, concentrados em manobras, confusão, levantar e iniciadores AOO.
- `public.srd_detectar_saida_alcance_ameacado_srd` não chama o helper: duplica a classificação em três CASEs, atualmente também corretos para Colossal = 6.
- `priv.mover_token_player_cba_impl`, `priv.mover_token_gm_cba_srd_impl`, as duas sobrecargas de `public.aplicar_dano_token_ataque_srd_v2` e `public.usar_imposicao_maos_mortos_vivos_srd` usam 5 para Colossal.
- `public.adicionar_token_cba` compara somente a célula de origem, não os quadrados do footprint.

## Concorrência e versão

- `public.campaigns` possui `cba_data` e `combat_data` JSONB, mas não coluna dedicada de versão/revisão.
- `cba_data.version = 1` identifica formato, não revisão monotônica.
- `FOR UPDATE` em `salvar_cena_cba` serializa gravações, mas não impede lost update quando o payload já chega obsoleto.
- O índice parcial `srd_aoo_one_pending_movement_per_campaign` garante no máximo uma pending ativa por campanha.
- O trigger de pending protege somente coordenadas/remoção do token mover; não congela a geometria de toda a cena.

## Call sites observados em `mesa.html`

| Linha | Intenção de `gravarCBAnaCampanha` |
|---:|---|
| 2294 | Atualizar retrato/imagem de token |
| 3626 | Persistir `spellState` |
| 4974 | Criar NPC/arquetipo durante combate |
| 5116 | Persistir modificadores de iniciativa de reforço |
| 5431 | Fallback de movimento fora de combate |
| 5468 | Publicar fundo/mapa/grade |
| 6154 | Preparar modificadores antes de iniciar iniciativa |
| 6633 | Hidratar/enriquecer dados de monstros |

A fila `cbaWriteQueue` serializa somente chamadas do mesmo cliente; não coordena com RPCs de combate nem outros clientes.

## Prioridade de correção

1. Tornar os RPCs de movimento a autoridade única e integrar detecção AOO + pending global + commit na mesma transação.
2. Separar publicação de metadados, spawn/remoção e metadados de token do writer genérico.
3. Impedir snapshots obsoletos de sobrescrever PV/posição/equipamentos; usar comandos parciais ou revisão gerada no servidor.
4. Congelar alterações estruturais/facção/alcance/iniciativa durante pending, exceto ações internas da resolução AOO.
5. Centralizar footprint em helper único para detector, movimento, spawn, ataques e habilidades.
6. Aplicar política de footprint completo e ocupação para spawn de tokens Grandes até Colossais.
7. Corrigir inversão de locks pending → attack versus attack → pending com ordem única validada por matriz transitiva.

## Testes e limites

O workflow `.github/workflows/postgres-fixture-tests.yml` usa PostgreSQL 17 efêmero em runner padrão do repositório público. A primeira fixture valida somente o helper de footprint e passou em 2026-11-09. Ela não valida RPCs Supabase, Auth, PostgREST, RLS, Realtime nem os call sites ainda divergentes. Regressões de movimento, cena genérica, spawn, footprint e locks estão listadas em `TEST_STRATEGY.md`.

**Nenhuma função, migration, ACL, policy ou dado de campanha foi alterado no Supabase remoto.**


## Varredura ampliada de escritores de `campaigns` — 2026-11-09

Uma consulta somente de leitura a `pg_proc` + `pg_get_functiondef` varreu as funções dos schemas `public`, `priv` e `private`, procurando DML direto sobre `campaigns`. Resultado: **52 assinaturas de função** (sobrecargas contam separadamente), distribuídas assim:

| Alvo escrito | Assinaturas | Observação |
|---|---:|---|
| `campaigns.cba_data` | 32 | Escritores diretos do JSONB de cena/estado de tokens |
| `campaigns.combat_data` | 12 | Iniciativa, turnos, economia de ações e estado de combate |
| Outras colunas de `campaigns` | 7 | Configuração, estado da campanha, transferência/encerramento; inclui wrappers/delegadores que referenciam a campanha |
| INSERT em `campaigns` | 1 | Criação de campanha |

A consulta encontrou **mais escritores de `cba_data` do que os endpoints inicialmente catalogados**. A lista abaixo é um inventário de assinaturas que executam DML direto sobre a linha de campanha, não uma afirmação de que todas alteram coordenadas ou são chamadas pelo frontend. Cada uma precisa ser classificada por efeito, guardas, locks, pending AOO, ACL e chamadas transitivas antes de qualquer bloqueio global.

### Escritores diretos de `cba_data` (32 assinaturas)

- `priv.consumir_acao_token_gm_srd_impl`
- `priv.descanso_longo_npc_vinculado_srd_impl`
- `priv.gm_npc_apply_typed_damage_impl`
- `priv.mover_token_gm_cba_srd_impl`
- `priv.mover_token_player_cba_impl`
- `priv.npc_aplicar_dano_ataque_iterativo_impl`
- `priv.srd_apply_pending_spell_resolution`
- `priv.srd_end_barbarian_rage_token`
- `priv.srd_resolver_encontrao_srd`
- `priv.srd_sync_linked_npc_token_vitals`
- `public.adicionar_token_cba`
- `public.alterar_pv_token_cba`
- `public.aplicar_dano_ataque_iterativo_srd` (2 sobrecargas)
- `public.aplicar_dano_token_ataque_srd`
- `public.aplicar_dano_token_ataque_srd_v2` (2 sobrecargas)
- `public.conjurar_magia_srd`
- `public.conjurar_magia_srd_manual`
- `public.conjurar_magia_srd_multialvo`
- `public.conjurar_magia_srd_multialvo_v2`
- `public.conjurar_magia_srd_multialvo_v3`
- `public.conjurar_missil_magico_srd`
- `public.entregar_item_token_srd`
- `public.equipar_item_token_srd`
- `public.salvar_cena_cba`
- `public.srd_aplicar_dano_ataque_oportunidade_monstro_srd`
- `public.srd_aplicar_dano_ataque_oportunidade_srd`
- `public.srd_configurar_perfil_combate_token_srd`
- `public.usar_furia_barbaro_npc_srd`
- `public.usar_habilidade_classe_srd`
- `public.usar_imposicao_maos_mortos_vivos_srd`

### Escritores de `combat_data` (12 assinaturas)

- `priv.consumir_acao_rodada_completa_srd_impl`
- `priv.srd_resolver_derrubar_srd`
- `priv.srd_resolver_levantar_caido_apos_aoo_srd`
- `public.adicionar_combatente_iniciativa`
- `public.avancar_turno`
- `public.consumir_acao_turno_srd`
- `public.iniciar_iniciativa`
- `public.iniciar_iniciativa_com_dados`
- `public.mover_combatente_iniciativa`
- `public.registrar_iniciativa`
- `public.srd_configurar_rodada_surpresa_srd`
- `public.excluir_ficha_propria` (efeito sobre campanha deve ser revisado; não presumir que seja mutação de turno)

### Outras escritas em `campaigns` (7 assinaturas)

- `public.adicionar_token_cba_completo`
- `public.alternar_estado_campanha`
- `public.atualizar_configuracoes_campanha`
- `public.end_combat`
- `public.gm_transfer`
- `public.scene_config`
- `public.start_combat`

### Limites da varredura

- A classificação é estática e baseada nos corpos atuais; SQL dinâmico, chamadas transitivas e triggers podem produzir escritas adicionais não capturadas por regex.
- A varredura não prova que cada função está exposta ao cliente: ACL efetiva e grants herdados devem ser verificados individualmente. `EXECUTE authenticated` não equivale a autorização de negócio.
- Funções que escrevem em tabelas relacionadas (fichas, inventário, fila AOO, tentativas/ataques, condições, ledger) sem atualizar diretamente `campaigns` não entram nesses 52; precisam de inventário separado para locks transitivos.
- A contagem anterior de endpoints CBA era parcial. A lista acima deve ser tratada como expansão do escopo, não como prova de que todos os 32 escritores de `cba_data` podem mover tokens.
- Nenhuma RPC, trigger, ACL, policy, migration ou dado foi alterado nesta consulta.

### Próxima etapa derivada

Classificar as 32 assinaturas de `cba_data` em: movimento; spawn/remoção; PV/dano/condições; equipamento/inventário; magia/efeitos; estado auxiliar; e writer genérico. Em seguida, rastrear os wrappers e chamadas transitivas para produzir a matriz completa de bloqueio durante pending AOO. Só então definir quais mutações devem ser pausadas, quais são seguras e quais são parte autorizada da própria resolução.


### Leitura preliminar dos 32 escritores diretos de `cba_data`

Uma segunda consulta classificatória examinou os corpos das 32 assinaturas identificadas acima:

- As **32/32** contêm aquisição explícita de lock `FOR UPDATE` em seu fluxo.
- Apenas **3/32** mencionam lexicalmente `srd_aoo_pending_movements` ou `srd_aoo_attacks`: `priv.srd_resolver_encontrao_srd` e as duas RPCs públicas de aplicação de dano AOO. A primeira também pode usar estruturas de pending próprias da manobra; a simples ocorrência do nome não prova que respeite a fila global de movimento.
- Apenas **1/32** chama lexicalmente `priv.srd_token_grid_footprint`: `priv.srd_resolver_encontrao_srd`.
- Os dois escritores de movimento continuam sem chamada ao detector AOO, sem referência direta à fila global e sem uso do helper canônico, conforme a inspeção específica já registrada.
- Os escritores de PV/dano, magia, equipamento, descanso, fúria e habilidades também bloqueiam a linha da campanha, mas isso por si só **não significa que consultem ou respeitem uma movimentação pendente**.

**Interpretação:** o lock de campanha oferece serialização entre transações que o adquirem, mas não substitui a regra de negócio que deve rejeitar ou adiar mutações incompatíveis enquanto uma reação AOO está pendente. O ponto de decisão precisa ocorrer dentro da mesma transação e depois do lock compartilhado; checar pending antes de adquirir o lock mantém uma janela de corrida.

**Limite:** estes números vêm de sinais lexicais em `pg_get_functiondef`, não de análise completa de fluxo ou dependências transitivas. Não usar os totais como prova de autorização correta ou de ausência de chamadas indiretas.


## Verificação do guard de pending e dos dois caminhos de movimento — 2026-11-09

Os corpos remotos atuais foram lidos diretamente com `pg_get_functiondef` (somente leitura). A verificação confirma o seguinte comportamento:

### O que o trigger realmente protege

`priv.srd_guard_pending_aoo_movement` é um `BEFORE UPDATE OF cba_data` (conforme trigger já inventariado) e, havendo pending em `waiting_reactions` ou `ready_to_commit`, ele:

1. Localiza o pending ativo mais recente da campanha.
2. Extrai o token mover em OLD e NEW.
3. Bloqueia a remoção **do token mover**.
4. Bloqueia mudança de `gridX/gridY` **do token mover**.
5. Permite essas duas operações quando `app.srd_aoo_pending_commit` corresponde ao `pending_id` ativo.

O trigger **não compara nem protege**:
- coordenadas de qualquer outro token;
- inserção/spawn de tokens;
- remoção de tokens diferentes do mover;
- mudança de `combatFaction`, alcance corpo a corpo ou outros metadados que alterem a ameaça;
- mudanças de outros campos de `cba_data` enquanto a reação está pendente.

Isso é uma lacuna concreta no limite atual do guard: a lista de ameaças e a geometria usada para criar o pending podem ficar obsoletas antes do commit. A consequência depende do tipo de mutação: reposicionar/remover um ameaçador ou inserir nova criatura pode invalidar o conjunto de reações calculado na solicitação. Não foi executada uma transação de teste contra produção; o achado decorre do corpo SQL efetivamente instalado.

### Movimento do jogador e do Mestre

- `priv.mover_token_player_cba_impl`: bloqueia a linha `campaigns` com `FOR UPDATE`, lê `cba_data/combat_data`, depois bloqueia personagem e ficha. Não chama o detector AOO nem consulta diretamente a fila pending. O guard de trigger só barra a alteração se o token modificado for o mover pendente.
- `priv.mover_token_gm_cba_srd_impl`: também bloqueia a campanha com `FOR UPDATE`, valida o turno e atualiza `cba_data/combat_data`. Não chama detector AOO nem consulta diretamente a fila pending. O guard de trigger também só barra alteração/remoção do próprio mover pendente.
- Ambos mantêm footprint Colossal = **5** em seus cálculos locais, divergindo do helper canônico que retorna **6**. O caminho GM calcula footprint de tokens vizinhos com CASE local; o caminho jogador também calcula tamanhos com CASE local.
- Ambos fazem update da mesma linha de campanha, portanto serializam com outras rotinas que respeitam o mesmo lock de linha. Isso não corrige a ausência de validação de pending para mudanças de outros tokens nem garante uma ordem consistente entre a linha da campanha e a linha pending.

### Ordem de locks observada no fluxo AOO

- Solicitação: campanha `FOR UPDATE` → lê estado de cena/detecção → verifica pending → insere pending.
- Finalização: pending `FOR UPDATE` → valida ataques/reação → campanha `FOR UPDATE` → chama movimento autorizado → trigger consulta pending.

A ordem pending → campanha na finalização é inversa à campanha → pending em rotinas de solicitação/cancelamento/encerramento já inventariadas. Isso mantém o ciclo de deadlock possível, não apenas teórico na documentação. A reprodução concorrente ainda não foi executada.

### Implicações para o desenho da correção

Não aplicar simplesmente um bloqueio total de `cba_data`: o commit legítimo do mover precisa passar e operações de dano/condição podem ser necessárias para resolver a reação. O desenho precisa separar:
- **geometria e ameaça:** posição de qualquer token, spawn/remoção e perfil de combate devem ser bloqueados ou revalidados enquanto houver pending;
- **resolução da reação:** rolagem, dano e estado da reação devem continuar permitidos pelos endpoints próprios;
- **commit do movimento:** somente a transação que detém o pending correto pode alterar a posição do mover;
- **estado não relacionado:** metadados independentes devem usar comandos parciais e não substituir snapshots inteiros.

Antes de escolher a implementação, mapear triggers adicionais sobre `campaigns`, escritores de perfil/spawn/remoção e todas as transições de pending. A ordem global de locks deve ser padronizada em todas essas rotinas, incluindo chamadas transitivas.

### Limites da análise de dependências

Foi construída uma exploração estática de chamadas por nomes qualificados a partir das 32 raízes de escrita em `cba_data`. O resultado bruto é apenas exploratório: regex por nome pode associar sobrecargas incorretamente, não resolve chamadas não qualificadas/SQL dinâmico e não determina a ordem de locks transitiva. Nenhuma contagem dessa exploração deve ser tratada como grafo de chamadas validado. A análise de fluxo e locks deve usar OIDs/assinaturas e corpos individuais, com triggers e DML explícitos mapeados separadamente.


### Triggers adicionais da tabela `campaigns`

A consulta a `pg_trigger` confirmou quatro triggers não internos:

| Trigger | Evento | Efeito relevante |
|---|---|---|
| `trg_srd_guard_pending_aoo_movement` | BEFORE UPDATE OF `cba_data` | Guarda limitada ao mover pendente, detalhada acima |
| `trg_expire_barbarian_rage_on_round_change` | AFTER UPDATE OF `combat_data` | Ao avançar rodada, bloqueia efeitos ativos `FOR UPDATE`, encerra fúria e registra log |
| `trg_srd_request_confusion_turn_roll` | AFTER UPDATE OF `combat_data` | Ao mudar turno/rodada/fase surpresa, bloqueia condição de confusão, atualiza condição e insere pedido no log |
| `on_campaign_created` | AFTER INSERT | Adiciona proprietário como GM |

As duas triggers AFTER tornam o caminho de escrita de `combat_data` transitivo: um UPDATE de campanha pode adquirir locks em `srd_campaign_effects`, `srd_campaign_conditions` e `campaign_log` antes de a transação terminar. Isso precisa entrar na matriz global de locks; não basta comparar apenas os `FOR UPDATE` escritos no corpo da RPC chamadora. Não foi concluído ainda o rastreamento reverso de todas as rotinas que bloqueiam essas tabelas antes de bloquear `campaigns`.

### Estado da execução de CI no momento do registro

A consulta ao GitHub Actions foi feita após o commit `66fcf76f515842c1e234215f400eaf1c6157a3dd`. O estado retornado deve ser consultado no próprio histórico de Actions para distinguir workflows de Pages dos testes PostgreSQL; nenhum resultado de CI é inferido a partir do sucesso da gravação documental.


## Nova análise: inversão de locks entre efeitos de Fúria e avanço de rodada

Data da coleta: 2026-11-09. Fonte: corpos SQL atualmente instalados em priv.srd_expire_barbarian_rage_on_round_change, priv.srd_end_barbarian_rage, priv.srd_end_barbarian_rage_token, priv.srd_apply_campaign_condition e triggers de public.campaigns. Consultas somente leitura.

### Ciclo de deadlock identificado

Há um ciclo concreto de ordem de locks entre a trigger trg_expire_barbarian_rage_on_round_change (AFTER UPDATE OF combat_data) e encerramentos concorrentes de Fúria:

1. A transação que avança a rodada já mantém lock exclusivo na linha campaigns devido ao próprio UPDATE.
2. A trigger seleciona efeitos de Fúria ativos em srd_campaign_effects com FOR UPDATE, em ordem por effect_instance_id.
3. A rotina priv.srd_end_barbarian_rage_token, chamada pela trigger para alvos token, primeiro bloqueia o efeito de Fúria (srd_campaign_effects FOR UPDATE) e depois tenta bloquear a campanha (campaigns FOR UPDATE).
4. A rotina priv.srd_end_barbarian_rage, para alvos character, também bloqueia primeiro o efeito; ao aplicar fadiga chama priv.srd_apply_campaign_condition, que tenta bloquear a campanha (FOR UPDATE) antes de alterar condições.
5. Assim, uma sessão que avança a rodada pode segurar campaigns e aguardar srd_campaign_effects, enquanto outra sessão que encerra Fúria segura srd_campaign_effects e aguarda campaigns.

**Conclusão:** o ciclo campaigns → srd_campaign_effects → campaigns está demonstrado pelos corpos instalados. É uma condição estrutural de deadlock, embora ainda não tenha sido reproduzida com duas sessões concorrentes contra uma instância PostgreSQL de teste. Não executar reprodução concorrente no banco de produção.

### Caminhos adicionais de lock

- priv.srd_end_barbarian_rage_token: efeito → campanha → (possível) ficha de personagem → condições. Atualiza campaigns.cba_data enquanto ainda mantém locks anteriores.
- priv.srd_end_barbarian_rage: efeito → ficha → (possível) campanha via priv.srd_apply_campaign_condition → condições. O caminho de fadiga também consulta/atualiza condições.
- priv.srd_apply_campaign_condition: campanha FOR UPDATE → possíveis efeitos (ao aplicar slowed) → condições. Essa ordem é coerente com o lock inicial da campanha, mas pode conflitar com chamadores que já chegam segurando efeito/condição.
- priv.srd_apply_campaign_effect: campanha FOR UPDATE → possíveis condições/efeitos → insere efeito.
- priv.srd_request_confusion_turn_roll (trigger AFTER UPDATE de combat_data): a campanha já está bloqueada pela atualização; depois bloqueia condição FOR UPDATE e grava campaign_log.
- priv.srd_expire_barbarian_rage_on_round_change: campanha já bloqueada pela atualização; bloqueia efeitos e, transitivamente, pode chegar a ficha, condições, campanha (reentrante na mesma transação) e log.
- priv.srd_clear_combat_flatfooted_actor/all atualizam condições sem bloquear explicitamente campanha. Quando chamados após um update de campanha, herdam o lock da campanha; quando chamados isoladamente, podem criar ordem diferente dependendo do chamador.

### Consequências para a matriz global

O lock da linha campaigns é um ponto de serialização usado por múltiplos fluxos, mas não basta dizer que todas as rotinas “bloqueiam a campanha”: a ordem importa. Os fluxos de encerramento de Fúria podem entrar em srd_campaign_effects antes da campanha. A trigger de mudança de rodada faz o inverso.

Não classificar como corrigido apenas por adicionar outro FOR UPDATE na campanha: a correção precisa garantir a ordem global antes de qualquer lock em efeitos/condições. Para o encerramento de Fúria, a direção mais segura a avaliar é adquirir primeiro o lock da campanha e só então localizar/bloquear o efeito; entretanto, isso deve ser feito em uma migration reconciliada, cobrindo chamadas internas e efeitos colaterais, sem alterar a produção nesta etapa.

### Regressões obrigatórias antes de qualquer correção remota

1. Avanço de rodada com Fúria ativa em personagem e em token NPC.
2. Encerramento manual de Fúria concorrente com avanço de rodada.
3. Aplicação de fadiga e transição fatigado → exausto, com verificação de integridade de PV, efeitos e condições.
4. Dois encerramentos simultâneos do mesmo efeito (idempotência e ausência de dupla remoção de PV temporário).
5. Verificação de timeout/deadlock com duas sessões no PostgreSQL efêmero do CI, usando cópias isoladas da ordem de locks e identificando claramente que o teste reproduz o padrão, não executa o código remoto em produção.

Nenhuma função ou dado remoto foi alterado. A análise não autoriza ainda uma migration: a reconciliação entre 966 versões remotas e 681 arquivos locais continua sendo pré-condição para mudanças no banco.


### Ciclo adicional envolvendo o encerramento manual da Fúria de personagem

A RPC public.usar_furia_barbaro_srd também começa bloqueando a linha de public.characters e depois public.srd_character_sheets com FOR UPDATE; somente depois bloqueia campaigns. No caminho de encerramento, ela chama priv.srd_end_barbarian_rage, que bloqueia srd_campaign_effects antes de retornar ao fluxo de campanha/condições. Em concorrência com a trigger de avanço de rodada, a sessão manual pode reter ficha/efeito e aguardar campaigns, enquanto a trigger retém campaigns e, após bloquear o efeito, pode aguardar a mesma ficha. Portanto, a revisão da ordem não pode limitar-se a mover o lock de campaigns para dentro de priv.srd_end_barbarian_rage: o chamador público também precisa ser analisado para que não mantenha characters/srd_character_sheets antes da campanha. A correção deve padronizar a ordem no ponto de entrada e em todas as rotinas transitivas, não apenas no helper interno.


## Expansão da matriz de locks: encerramento de combate e expiração de estados

Data da coleta: 2026-11-09. Corpos consultados diretamente no banco remoto por leitura. Nenhuma alteração de produção.

### Novo ciclo confirmado: encerramento de combate × avanço/expiração de rodada

Além do ciclo já documentado entre a trigger de avanço de rodada e o encerramento de Fúria, foram confirmados outros caminhos com a mesma inversão:

- `public.end_combat(cid)` seleciona e bloqueia primeiro linhas de `srd_campaign_effects` (`FOR UPDATE`) para encerrar Fúria. Só no fim atualiza `campaigns.state`, adquirindo o lock da campanha depois dos efeitos. Se concorrer com uma transação que já bloqueou `campaigns` e tenta bloquear os mesmos efeitos, há ciclo potencial `campaigns → srd_campaign_effects → campaigns`.
- `public.alternar_estado_campanha(p_campaign_id,p_novo_estado)` bloqueia primeiro `campaigns`, depois percorre efeitos de Fúria com `FOR UPDATE`. A direção é inversa à de `public.end_combat`.
- `public.srd_expire_campaign_conditions(p_campaign_id)` bloqueia primeiro `campaigns` e depois efeitos expirados com `FOR UPDATE`; ao encerrar Fúria, chama helpers que também podem buscar efeitos e condições. Deve ser tratado como fluxo de campanha-primeiro.
- A trigger `trg_expire_barbarian_rage_on_round_change` também é campanha-primeiro, pois é executada dentro do UPDATE de `campaigns.combat_data`.

Portanto, não é um caso isolado de uma trigger: há pelo menos um endpoint de encerramento de combate com efeito-primeiro e endpoints/triggers de avanço ou expiração com campanha-primeiro. A ordem precisa ser uniformizada nos pontos de entrada, inclusive no caminho legado `end_combat`; não basta corrigir apenas os helpers de Fúria.

### Escritores de condições/efeitos que não serializam pela campanha

Os corpos de `public.srd_remove_campaign_condition` e `public.srd_remove_campaign_effect` fazem UPDATE direto nas respectivas tabelas sem adquirir previamente `campaigns FOR UPDATE`. Ambos exigem GM autenticado, mas a autorização não serializa mutações com os fluxos de combate/expiração. Isso não constitui por si só prova de deadlock; cria caminhos concorrentes que podem alterar estado durante resolução/expiração e precisam de política transacional explícita.

Outros caminhos observados:
- `priv.srd_clear_combat_flatfooted_actor/all` atualizam condições diretamente, sem lock explícito da campanha. Chamadas dentro de triggers/rotinas que já atualizaram a campanha herdam o lock da transação; chamadas isoladas não.
- `priv.srd_sync_character_vital_condition` atualiza e insere condições sem bloquear primeiro a campanha. É invocada por fluxos de PV; a ordenação depende do chamador e das linhas de personagem/ficha que ele já mantém.
- `priv.srd_sync_linked_npc_token_vitals` adquire campanha primeiro, depois ficha, lê condições/efeitos e atualiza campanha/ficha/condições. É um fluxo campanha-primeiro com locks adicionais em ficha.
- `public.descanso_longo_personagem_srd` adquire personagem e ficha antes de consultar campanha sem FOR UPDATE; depois chama sincronização de condição e atualiza ficha/recursos. A ordem personagem → ficha → condições, combinada com rotinas que bloqueiam campanha → personagem/ficha, requer revisão específica antes de adicionar locks de campanha nesse endpoint.
- `priv.descanso_longo_npc_vinculado_srd_impl` começa com campanha → personagem → ficha, chama encerramento da Fúria token e depois altera condições/recursos. É um fluxo campanha-primeiro, mas a chamada interna de Fúria deve respeitar a mesma ordem sem reter previamente efeito de forma conflitante.

### Teste de concorrência no CI

A execução do workflow PostgreSQL fixture tests para o commit `27f2c6d60b07066f4bea21c10bdbc81dacbe736e` terminou com conclusão `success`. O fixture concorrente observou o PostgreSQL detectar `deadlock detected` e abortar um participante, conforme esperado. Isso comprova o comportamento do padrão sintético campaign→effect versus effect→campaign; não executa as RPCs instaladas nem demonstra que uma transação real do jogo já sofreu deadlock.

Execução: https://github.com/clubberblues/rpgvinculo/actions/runs/42642696293

### Próximas regressões e decisões de arquitetura

1. Testar concorrência entre `end_combat` e avanço de rodada/expiração.
2. Testar `alternar_estado_campanha` contra encerramento manual de Fúria.
3. Testar remoção manual de efeito/condição contra expiração automática, incluindo idempotência.
4. Testar sincronização de PV e descanso longo concorrentes com resolução de combate, respeitando locks de personagem, ficha e campanha.
5. Definir um protocolo global de locks por campanha e por entidade. O lock da campanha pode ser a primeira barreira para operações de estado de combate, mas os fluxos que precisam bloquear personagem/ficha antes da campanha devem ser redesenhados como um todo; inserir um lock isolado pode apenas transferir o deadlock.
6. Não alterar essas RPCs no banco remoto até reconciliar versões/migrations e cobrir chamadas transitivas. A auditoria continua read-only.


### Revisão adicional: locks de personagem, ficha e efeitos na Fúria

A inspeção dos corpos completos confirmou uma segunda dimensão da ordem global:

- `public.usar_furia_barbaro_srd(character_id, action)` bloqueia `characters` → `srd_character_sheets` → `campaigns`. No encerramento, chama `priv.srd_end_barbarian_rage`, que bloqueia `srd_campaign_effects` e depois a ficha (lock reentrante quando o chamador já a possui), podendo acionar sincronização de condições.
- `priv.srd_end_barbarian_rage` bloqueia `srd_campaign_effects` → `srd_character_sheets` → condições; a aplicação de fadiga chama `priv.srd_apply_campaign_condition`, que adquire `campaigns FOR UPDATE` e pode também alterar efeitos/condições.
- `priv.srd_end_barbarian_rage_token` bloqueia `srd_campaign_effects` → `campaigns` → ficha/condições. É chamado por fluxos que já podem ter campanha bloqueada (trigger de rodada, descanso longo NPC, expiração).
- `public.usar_furia_barbaro_srd` mantém personagem e ficha bloqueados antes de adquirir campanha. Isso precisa ser considerado junto de qualquer caminho campanha → personagem/ficha; padronizar somente o par campanha/efeito não basta.
- `public.usar_pocao_cura_srd` bloqueia equipamento → ficha e depois sincroniza condições, sem bloquear previamente a campanha. Também precisa ser incluído na matriz de recursos/PV para não criar uma ordem incompatível ao se adicionar locks de campanha.
- `public.descanso_longo_personagem_srd` bloqueia personagem → ficha e chama sincronização de condição; não bloqueia campanha com `FOR UPDATE`. Não é seguro inserir um lock de campanha de forma isolada sem verificar os fluxos que já entram campanha → personagem/ficha.

**Decisão de desenho:** o protocolo futuro precisa declarar a ordem entre pelo menos `campaigns`, `characters`, `srd_character_sheets`, `srd_campaign_effects`, `srd_campaign_conditions`, `srd_character_feature_resources`, `srd_character_equipment`, tabelas de sequência de ataque, ledger AOO e log. O inventário lexical atual ainda não é um grafo de chamadas transitivas validado; cada endpoint e overload deve ser analisado individualmente antes de qualquer mudança.
