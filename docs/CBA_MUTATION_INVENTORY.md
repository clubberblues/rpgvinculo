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
- `public.usar_pocao_cura_srd_manual` (OID 24655, authenticated EXECUTE e chamada por `mesa.html`) lê `campaigns.state` sem lock; se a leitura indicar COMBATE, chama o consumo de ação campaign-first antes de bloquear equipamento/ficha; se indicar fora de combate, não serializa a decisão com a campanha. A variante antiga `public.usar_pocao_cura_srd` (OID 20557) não tem EXECUTE para authenticated no snapshot atual e não é o caminho usado pela interface.
- `public.descanso_longo_personagem_srd` bloqueia personagem → ficha e chama sincronização de condição; não bloqueia campanha com `FOR UPDATE`. Não é seguro inserir um lock de campanha de forma isolada sem verificar os fluxos que já entram campanha → personagem/ficha.

**Decisão de desenho:** o protocolo futuro precisa declarar a ordem entre pelo menos `campaigns`, `characters`, `srd_character_sheets`, `srd_campaign_effects`, `srd_campaign_conditions`, `srd_character_feature_resources`, `srd_character_equipment`, tabelas de sequência de ataque, ledger AOO e log. O inventário lexical atual ainda não é um grafo de chamadas transitivas validado; cada endpoint e overload deve ser analisado individualmente antes de qualquer mudança.


### Sequências de ataque e equipamento: ordens distintas de aquisição

A revisão individual de overloads de ataques iterativos encontrou mais uma diferença relevante:

- `priv.iniciar_sequencia_ataque_iterativo_srd_5_impl` bloqueia `campaigns FOR UPDATE` antes de criar a sequência de ataque. É campanha-primeiro.
- `priv.iniciar_sequencia_ataque_iterativo_srd_7_impl` bloqueia `srd_character_weapon_instances FOR UPDATE` antes de delegar para a função de início da sequência, que chega ao lock de `campaigns`. Ordem: instância de arma → campanha.
- `priv.iniciar_sequencia_ataque_iterativo_srd_8_impl` lê ficha/arma para validar Ataque Poderoso e delega à sobrecarga anterior; a aquisição bloqueante relevante ocorre no wrapper 7, antes da campanha.
- `private.equipar_arma_instancia_personagem_impl` bloqueia `characters` → instância de arma → atualiza instâncias e inventário. Não adquire lock de campanha.
- `private.equipar_arma_instancia_npc_vinculado_impl` bloqueia `campaigns` → instância de arma → atualiza instâncias/inventário. É campanha-primeiro.
- `priv.srd_reservar_ataque_oportunidade_impl` bloqueia `campaigns` antes de consultar/inserir no ledger de reações AOO. Mantém a campanha como barreira serializadora para a reserva.

A coexistência de overloads com ordens diferentes não prova isoladamente um deadlock, mas impede declarar a cadeia de ataque/equipamento uniforme. A matriz final precisa registrar cada wrapper e a função delegada; olhar apenas a implementação mais nova ou apenas a função pública mascara locks já adquiridos pelo chamador.

### Próximos testes dirigidos

1. Concorrência entre início de ataque iterativo (overloads 7/8) e equipar/desequipar a mesma instância.
2. Concorrência entre ataque iterativo e alteração de inventário/equipamento do NPC vinculado.
3. Concorrência entre reservar reação AOO e encerrar combate, cobrindo campanha → ledger/attack/pending.
4. Verificar se os overloads antigos ainda têm EXECUTE concedido e são alcançáveis pela UI; não removê-los sem inventário de grants e callsites.



## Expansão da ordem transitiva: recursos de ficha e equipamento — 2026-11-09

Consulta read-only dos corpos atuais de `public.usar_imposicao_maos_mortos_vivos_srd`, `priv.descanso_longo_npc_vinculado_srd_impl`, `priv.iniciar_sequencia_ataque_iterativo_srd_7_impl`, `private.equipar_arma_instancia_npc_vinculado_impl`, `private.equipar_arma_instancia_personagem_impl`, `public.usar_pocao_cura_srd`, `public.usar_pocao_cura_srd_manual`, `priv.srd_sync_character_vital_condition` e `priv.srd_apply_campaign_condition`.

### Ordem personagem/ficha/recurso/campanha

- `public.usar_imposicao_maos_mortos_vivos_srd` bloqueia `characters` → `srd_character_sheets` → `srd_character_feature_resources` → `campaigns`. A ordem é explícita no corpo: personagem e ficha são bloqueados, o recurso é criado/selecionado com `FOR UPDATE`, e só depois a campanha é bloqueada.
- `priv.descanso_longo_npc_vinculado_srd_impl` começa pela ordem inversa para as duas primeiras entidades: `campaigns` → `characters` → `srd_character_sheets`; depois repõe recursos e condições.
- Se uma mesma ficha de propriedade do Mestre estiver vinculada a um token NPC e também for alvo de uma ação de classe executada pelo próprio proprietário, há uma inversão potencial `characters/sheet → campaigns` versus `campaigns → characters/sheet`. A concorrência depende da identidade real da ficha e do usuário; não foi reproduzida. Não generalizar o risco para personagens distintos.
- `priv.srd_apply_campaign_condition` bloqueia campanha antes de alterar efeitos/condições. Já `priv.srd_sync_character_vital_condition` atualiza condições sem adquirir primeiro lock de campanha; sua ordem efetiva depende do chamador. Isso reforça que os helpers de condição não podem ser classificados isoladamente sem a cadeia de chamada.

### Ordem arma/campanha

- `priv.iniciar_sequencia_ataque_iterativo_srd_7_impl` bloqueia a instância de arma com `FOR UPDATE` e então delega à função de sequência, que bloqueia `campaigns`: arma → campanha.
- `private.equipar_arma_instancia_npc_vinculado_impl` bloqueia primeiro `campaigns` e depois a instância de arma: campanha → arma.
- Essa inversão pode formar ciclo se os dois caminhos concorrerem sobre a mesma instância de arma e campanha. A possibilidade depende do vínculo entre token NPC, ficha e instância; ainda não foi demonstrada uma execução concorrente real. O endpoint de equipamento de personagem tem outra ordem: `characters` → instância de arma, sem lock explícito de campanha.
- O overload 8 de ataque iterativo valida ficha/arma e delega ao overload 7; portanto, não elimina o lock da instância adquirido pelo wrapper 7 antes da campanha.

### Cura, equipamento e condições

- `public.usar_pocao_cura_srd` (OID 20557) bloqueia inventário → ficha, mas não tem EXECUTE para authenticated no snapshot atual. A interface usa `public.usar_pocao_cura_srd_manual` (OID 24655): lê o estado da campanha sem lock e só chama `consumir_acao_turno_srd` quando a leitura encontra COMBATE; nesse branch, campanha é bloqueada antes de equipamento → ficha. Fora de combate, começa por equipamento → ficha e pode consumir a poção depois de outra transação iniciar combate. É uma corrida de regra/estado, não um deadlock demonstrado.
- A rotina de sincronização de condição atualiza condições e só consulta a rodada da campanha quando precisa inserir um novo estado; não faz `campaigns FOR UPDATE`. Um chamador que já mantém ficha/equipamento pode, portanto, adquirir locks de condição nessa ordem.
- Esses caminhos precisam de testes de concorrência de cura, PV, condição e combate antes de qualquer padronização por lock de campanha.

### Novos testes dirigidos

1. Descanso longo de NPC vinculado concorrente com uso de habilidade que consome recurso na mesma ficha, incluindo Imposição das Mãos quando aplicável.
2. Ataque iterativo (overloads 7/8) concorrente com equipar/desequipar a mesma instância vinculada a NPC na mesma campanha.
3. Uso manual de poção concorrente com início de combate/avanço de rodada, validando se a ação padrão é consumida exatamente quando a transação é serializada.
4. Repetição concorrente das operações acima com duas sessões PostgreSQL efêmeras, usando fixtures isoladas e identificando os cenários condicionais; não executar concorrência de teste no banco remoto.

**Limite:** estes são caminhos de lock diretamente confirmados nos corpos instalados. As inversões são riscos estruturais condicionais, não incidentes reproduzidos. Não foi construído ainda um grafo transitivo completo por OID/assinatura e triggers. Nenhuma função, ACL, policy, migration ou dado remoto foi alterado.


### Ciclo de lock mais específico: início e resolução de ataque iterativo

A leitura dos corpos completos de `public.registrar_rolagem_ataque_iterativo_srd` e `public.resolver_ataque_iterativo_srd` refinou o risco de equipamento/ataque:

- `priv.iniciar_sequencia_ataque_iterativo_srd_7_impl` mantém lock `FOR UPDATE` na instância de arma antes de delegar ao início da sequência, que bloqueia a campanha.
- `public.resolver_ataque_iterativo_srd` bloqueia a campanha primeiro, depois a tentativa, depois a sequência; mais adiante adquire `FOR SHARE` na instância de arma para validar que continua equipada.
- Se uma nova chamada de início (ou repetição concorrente) mantiver a mesma instância bloqueada enquanto espera a campanha, e a resolução da sequência anterior mantiver a campanha enquanto espera `FOR SHARE` nessa instância, o ciclo é direto: **instância de arma → campanha → instância de arma**.
- O corpo do início verifica a existência de sequência ativa somente depois de adquirir o lock da campanha. Portanto, a validação de duplicidade não elimina a janela de espera circular anterior.
- `public.registrar_rolagem_ataque_iterativo_srd` é campanha → sequência → tentativa pendente; `public.resolver_ataque_iterativo_srd` é campanha → tentativa → sequência → instância de arma. Os endpoints de resolução são consistentes entre si no prefixo campanha, mas o wrapper 7 antecipa o lock da arma.

**Classificação:** inversão estrutural de lock confirmada nos corpos remotos, com cenário concorrente plausível sobre a mesma instância e campanha. Ainda não reproduzida com duas sessões. Teste obrigatório: resolução de uma tentativa já registrada concorrente com nova solicitação de sequência usando a mesma instância; verificar que PostgreSQL não encontra ciclo após a correção futura. Não reproduzir no Supabase de produção.

### Consistência observada no restante do motor iterativo

- `public.registrar_rolagem_ataque_iterativo_srd`: campanha → sequência → tentativa pendente; cria a tentativa e avança o índice.
- `public.resolver_ataque_iterativo_srd`: campanha → tentativa → sequência → instância de arma (`FOR SHARE`); atualiza resolução e pode encerrar sequência.
- `public.aplicar_dano_ataque_iterativo_srd` (duas sobrecargas) e `priv.npc_aplicar_dano_ataque_iterativo_impl`: campanha → tentativa → sequência; o caminho de alvo personagem também bloqueia ficha e sincroniza condições/PV.
- `priv.npc_confirmar_critico_ataque_iterativo_impl` e `public.confirmar_critico_ataque_iterativo_srd` começam pela campanha e depois bloqueiam tentativa/sequência.
- `public.consultar_sequencia_ataque_iterativo_pendente_srd` bloqueia a sequência, mas não tenta adquirir depois campanha ou outra linha bloqueante no corpo observado; por si só, não fecha um ciclo com a campanha.

O achado reforça que a ordem do wrapper 7 deve ser corrigida em conjunto com a resolução, não isoladamente. Não alterar remoto antes da reconciliação de migrations e dos testes concorrentes.


### Verificação CI das fixtures sintéticas — 2026-11-09

O workflow PostgreSQL fixture tests executou o commit `7de4c031087c3a5084881c0f2049c3596915d6c0` e terminou em **success**. Os logs confirmam:
- fixture de footprint: aprovada;
- padrão sintético campaign → effect versus effect → campaign: PostgreSQL detectou deadlock e abortou um participante;
- padrão sintético campaign → weapon versus weapon → campaign: detectado e abortado;
- padrão sintético campaign → character versus character → campaign: detectado e abortado.

Execução: https://github.com/clubberblues/rpgvinculo/actions/runs/42670106095

A aprovação valida somente as fixtures/modelos sintéticos. Não executa RPCs remotas, não reproduz deadlock em produção e não representa aceite E2E. O PostgreSQL efêmero foi descartado ao fim do job.


### Conjuração: ordem de locks de ficha e campanha — 2026-11-09

Inspeção por assinatura dos entrypoints de conjuração ativos e do aplicador de pendências:

- `public.conjurar_magia_efeitos_multialvo`: personagem `FOR UPDATE` → ficha `FOR UPDATE` → consumo de ação/lock de campanha → atualização de cena/efeitos.
- `public.conjurar_magia_dano_multialvo_srd`: personagem → ficha → consumo de ação → campanha `FOR UPDATE` → estado de cena e recursos.
- `public.conjurar_magia_srd_manual`: personagem → ficha → campanha `FOR UPDATE`; quando aplica dano a outro personagem, bloqueia também personagem/ficha-alvo.
- `public.conjurar_missil_magico_srd`: personagem → ficha → campanha `FOR UPDATE`, com locks adicionais para alvos personagem.
- `public.conjurar_magia_com_acao_srd_manual`: personagem `FOR UPDATE` antes de campanha/consumo de ação.
- `public.conjurar_magia_srd_multialvo_v3`: personagem → ficha → campanha, depois pode bloquear ficha do alvo.
- `priv.srd_apply_pending_spell_resolution`: pendência `FOR UPDATE` → atualiza status da pendência → campanha `FOR UPDATE` → ficha do alvo/condições e sincronização de PV.

**Implicação:** os entrypoints de conjuração seguem a mesma família personagem/ficha → campanha já observada em Fúria e habilidades de classe. Em concorrência com `priv.descanso_longo_npc_vinculado_srd_impl` (campanha → personagem → ficha), há uma inversão potencial se o mesmo personagem-ficha for simultaneamente operado como NPC vinculado e como ficha do proprietário. A autorização e o vínculo tornam esse cenário condicional, mas o caminho de lock é confirmado. Deve entrar no teste de concorrência da mesma ficha.

As rotinas de resolução de salvamento e resistência bloqueiam primeiro a linha da pendência. No corpo observado, não adquirem depois `campaigns FOR UPDATE`; não classificar automaticamente como ciclo pending → campaign. Já o aplicador interno de resolução pendente faz pending → campaign, mas não foi identificado nesta coleta um caminho oposto que bloqueie a mesma linha pending depois da campanha; manter como aresta da matriz, não como deadlock confirmado.

**Limite:** a classificação é por leitura dos corpos e ordem lexical dos statements SQL, com helpers transitivos assinalados; não é um grafo completo de chamadas nem reprodução concorrente. Nenhuma função ou dado remoto foi alterado.


### AOO: inversões adicionais entre campanha, pending e ataque — 2026-11-09

A inspeção por assinatura dos endpoints de início, confirmação, cancelamento, finalização e encerramento de combate refinou a matriz:

- `public.alternar_estado_campanha` mantém lock da campanha e depois atualiza ataques AOO e pendências ativas (campanha → ataque/pending).
- `public.srd_finalizar_movimento_aoo_pendente_srd` bloqueia a pendência primeiro e depois a campanha (pending → campanha). Sobre a mesma pendência, pode formar ciclo com encerramento de combate/alternância de estado: um segura campanha e espera pending, o outro segura pending e espera campanha.
- `public.srd_iniciar_ataque_oportunidade_srd`, `public.srd_iniciar_ataque_oportunidade_desarmado_srd` e o caminho NPC correspondente também seguem pending → campanha → reaction ledger; depois criam ataque e atualizam o JSON da pending.
- `public.srd_resolver_ataque_oportunidade_srd` segue attack → pending → campanha. `priv.srd_cancelar_movimento_aoo_pendente_impl` e `priv.srd_encerrar_reacao_aoo_pendente_impl` seguem pending → attack. Assim, há inversão direta pending → attack versus attack → pending entre cancelamento/encerramento e resolução. A confirmação crítica também bloqueia attack → pending, consistente com o prefixo da resolução.
- `public.srd_iniciar_ataque_oportunidade_monstro_srd` (overload com índice de ataque natural) delega ao endpoint legado e depois atualiza a linha de ataque recém-criada; não deve ser tratado como fluxo independente sem considerar a transação externa.
- `public.srd_registrar_ocultacao_ataque_oportunidade_srd` permanece attack → pending → campanha, reforçando o grupo attack-first.
- `public.srd_reservar_reacao_movimento_aoo_srd` segue pending → campanha, e `public.srd_reservar_ataque_oportunidade_srd` segue campanha → reaction ledger. O ledger é uma terceira entidade que precisa permanecer no mapa de locks.

**Classificação:** as ordens conflitantes estão confirmadas nos corpos instalados. Os ciclos dependem de operações simultâneas sobre a mesma campanha/pending/attack e ainda não foram reproduzidos usando RPCs reais. Não inferir que o ciclo necessariamente acontece em todo uso.

### Novas fixtures sintéticas
O harness agora modela também:
- campaign → pending versus pending → campaign;
- pending → attack versus attack → pending.

A aprovação do CI validará apenas que PostgreSQL detecta esses dois padrões sintéticos; não executará os endpoints remotos.


### Triggers de AOO e inventário: locks transitivos e alcance real — revisão de alcance (2026-11-09)

- `priv.trg_srd_validate_aoo_pending_movement_preview` é AFTER INSERT em `priv.srd_aoo_pending_movements`. Executa preview de movimento sob GUC transacional e desfaz a prévia por rollback da subtransação. Os writers atuais de pending já bloqueiam campanha antes do INSERT.
- Os triggers de guarda/validação AOO consultam condições sem `FOR UPDATE`; não acrescentam uma aresta de lock própria.
- `private.sync_character_weapon_instances_from_inventory` tem ramo de delta negativo que remove instâncias, mas o writer atual de entrega aumenta quantidade e cria novas instâncias; não foi encontrado writer frontend/RPC autenticado que reduza quantidade de armas. O UPDATE de `equipado/hand_slot` não dispara o trigger.
- `private.equipar_arma_instancia_personagem_impl` bloqueia personagem → instância e depois atualiza o resumo de equipamento. Isso não fecha ciclo com o trigger atual: a entrega positiva insere instâncias novas e não bloqueia uma instância existente antes de atualizar equipamento.
- `public.finalizar_equipamento_inicial_srd` bloqueia personagem → ficha e insere inventário, mas rejeita categorias de poções/óleos antes do UPSERT. Portanto, não disputa a mesma linha de equipamento bloqueada por `usar_pocao_cura_srd_manual`.

**Classificação corrigida:** equipamento → instância versus instância → equipamento é risco futuro/condicional se for adicionado writer de redução/remoção de armas ou se mudar o trigger/ACL. Não é ciclo operacional demonstrado no estado atual. O cenário sintético correspondente foi removido do harness ativo para não contar falso positivo.

### Recursos de classe: campanha versus recurso da ficha — 2026-11-09

A inspeção dos corpos instalados identificou um prefixo de lock adicional:

- `public.usar_habilidade_classe_srd` bloqueia `characters` → `srd_character_sheets` → `srd_character_feature_resources`; quando o alvo exige campanha, adquire depois `campaigns FOR UPDATE`. Para a habilidade atualmente aceita por essa RPC (`lay_on_hands`), o lock de recurso é adquirido antes do lock da campanha.
- `public.usar_furia_barbaro_npc_srd` bloqueia `campaigns` → `characters` → `srd_character_sheets` → `srd_character_feature_resources` ao iniciar Fúria de NPC vinculado.
- `priv.descanso_longo_npc_vinculado_srd_impl` também inicia por `campaigns FOR UPDATE`, depois bloqueia personagem e ficha, chama o encerramento da Fúria e reseta recursos de classe.
- `priv.srd_end_barbarian_rage_token` bloqueia efeito de Fúria antes da campanha e pode continuar para ficha/condições; essa cadeia deve permanecer separada da cadeia de início/reset.

**Risco classificado como inversão potencial, não deadlock de produção confirmado:** campanha → recurso versus recurso → campanha. Para formar ciclo, as duas operações precisam disputar o mesmo registro de recurso da mesma ficha e a mesma linha de campanha. A possibilidade depende de uma ficha de origem vinculada a token NPC também estar acessível ao endpoint de habilidade de personagem durante a mesma campanha. Isso deve ser confirmado na semântica de ownership/ligação e no frontend antes de elevar a severidade.

O ponto importante é que a ordem candidata global não pode ser definida apenas pelo primeiro `FOR UPDATE` de cada RPC: é necessário incluir recurso de classe e as chamadas transitivas. Nenhuma função remota foi modificada.

### Fixture sintética adicional

Foi acrescentado ao harness o par campanha → recurso de classe versus recurso de classe → campanha. O teste serve para verificar o comportamento de deadlock do PostgreSQL em uma sequência deliberadamente invertida; não reproduz as RPCs nem demonstra que o par é alcançável em produção.


### Conjuração e resolução pendente: campanha versus ficha — 2026-11-09

A revisão dos corpos remotos acrescentou uma inversão mais diretamente correlacionada com o mesmo alvo:

- `priv.srd_apply_pending_spell_resolution` bloqueia a linha da resolução pendente e depois `campaigns FOR UPDATE`; para alvo do tipo `character`, em seguida bloqueia `srd_character_sheets FOR UPDATE OF sh`.
- `public.srd_resolve_pending_spell_save` bloqueia a pendência e, em resultados que aplicam dano, delega ao aplicador acima. `public.srd_resolve_pending_spell_resistance` também pode delegar ao mesmo aplicador após a rolagem.
- `public.conjurar_magia_efeitos_multialvo` bloqueia `characters FOR UPDATE`, depois `srd_character_sheets FOR UPDATE`, e chama `public.consumir_acao_turno_srd`, que bloqueia `campaigns FOR UPDATE`; depois volta a ler/bloquear a campanha para criar pendências ou efeitos.

**Risco de deadlock potencial:** resolução de magia contra personagem (campanha → ficha) concorrente com conjuração multialvo pelo mesmo personagem (ficha → campanha). Se a resolução segura a campanha e espera a ficha enquanto a conjuração segura a ficha e espera a campanha, PostgreSQL pode detectar um ciclo. A pendência é uma linha adicional já bloqueada no caminho de resolução; o ciclo central envolve campanha e ficha.

A combinação é estruturalmente alcançável quando um personagem-alvo de uma magia pendente tenta conjurar outra magia enquanto a resolução anterior é confirmada. A regra de jogo pode impedir algumas ações após a condição ser aplicada, mas a resolução concorrente ainda pode ocorrer antes de a condição entrar em vigor; portanto, não usar a regra de turno como substituto de serialização no banco.

**Estado:** ordem conflitante confirmada nos corpos instalados; deadlock real entre as RPCs ainda não reproduzido. Nenhuma função remota foi alterada.

### Fixture sintética adicional — conjuração

O harness inclui o padrão campanha → ficha versus ficha → campanha. Ele verifica apenas o comportamento de locks do PostgreSQL em duas sessões; não executa conjuração, salvamento ou aplicação de magia no Supabase.


A expansão da matriz de conjuração confirmou outros entrypoints com o mesmo prefixo ficha → campanha:
- `public.conjurar_magia_dano_multialvo_srd`: character → sheet → consumo da ação/lock da campanha.
- `public.conjurar_magia_efeitos_multialvo`: character → sheet → consumo da ação/lock da campanha.
- `public.conjurar_missil_magico_srd`: character → sheet → delegação ao wrapper de ação e lock posterior da campanha.
- `public.conjurar_magia_srd_manual`: character → sheet; nos caminhos de cura com alvo/cena, também pode bloquear a campanha depois da ficha.

Esses caminhos ampliam a superfície da inversão campaign → sheet observada no aplicador de resolução pendente. A fixture sintética continua sendo uma única família de lock, mas os casos funcionais devem cobrir cada entrypoint e overload efetivamente utilizado.


## Rastreamento transitivo de magia, efeitos e condições — 2026-11-09

Nova leitura read-only dos corpos instalados por assinatura/OID, incluindo helpers internos chamados pelos caminhos de conjuração e resolução pendente. O objetivo foi separar locks efetivos de simples leituras e não tratar uma chamada transitiva como lock sem verificar o corpo.

### Caminho de resolução pendente de dano

- `priv.srd_apply_pending_spell_resolution(uuid)` adquire primeiro `priv.srd_pending_spell_resolutions FOR UPDATE`, valida o status, e no ramo de dano bloqueia `public.campaigns FOR UPDATE`; para alvo character, bloqueia depois `srd_character_sheets`.
- Para dano de personagem, o helper `priv.srd_sync_character_vital_condition` atualiza condições vitais do personagem e só depois lê a rodada em `campaigns` sem `FOR UPDATE`. Portanto, esse helper adquire locks de condição, mas a leitura posterior da campanha não cria por si só um lock de linha inverso.
- Para NPC vinculado, `priv.srd_sync_linked_npc_token_vitals` bloqueia campanha primeiro e depois ficha; atualiza token/cba_data, ficha e condições. Quando chamado pelo aplicador de magia, o lock da campanha já foi obtido pelo chamador.
- `priv.srd_apply_campaign_condition` e `priv.srd_apply_campaign_effect` também bloqueiam campanha antes de atualizar efeitos/condições. Os wrappers públicos delegam a essas implementações internas.
- `priv.srd_adjust_damage_components`/ `priv.srd_adjust_damage` são helpers de leitura STABLE; consultam efeitos, campanha e fichas, sem `FOR UPDATE` ou DML em seus corpos.

### Conjuradores

Os corpos de `public.conjurar_magia_dano_multialvo_srd`, `public.conjurar_magia_efeitos_multialvo`, `public.conjurar_missil_magico_srd` e `public.conjurar_magia_srd_manual` foram revistos individualmente. Os caminhos multialvo e alguns caminhos manuais bloqueiam personagem/ficha antes de delegar o consumo da ação, que bloqueia campanha. O aplicador de resolução pendente, em contraste, bloqueia campanha antes da ficha-alvo. A inversão campanha ↔ ficha continua sendo uma possibilidade real entre transações concorrentes; a fixture atual modela apenas o par de linhas e não executa esses corpos.

### Encerramento de combate: dois caminhos transitivos confirmados

O corpo instalado de `public.end_combat(bigint)` foi lido integralmente. Ele percorre efeitos de Fúria com `FOR UPDATE` antes de chamar os encerradores de Fúria; depois atualiza condições, ataques AOO e pendências AOO, nesta ordem, antes de atualizar `campaigns.state`.

Isso confirma no entrypoint de encerramento duas superfícies de inversão já observadas isoladamente:

1. **Efeito → campanha:** `priv.srd_end_barbarian_rage_token` bloqueia o efeito de Fúria antes de bloquear campanha. A trigger `trg_expire_barbarian_rage_on_round_change` parte do UPDATE da campanha e bloqueia efeitos durante a mudança de rodada. A disputa pelo mesmo efeito pode formar ciclo; ainda não reproduzido com os corpos reais em duas sessões.
2. **Ataque → pending:** `end_combat` atualiza registros de ataque AOO antes das pendências ativas. Isso é incompatível com rotinas que bloqueiam pending antes de attack (cancelamento/encerramento). A transação de encerramento pode, portanto, participar do ciclo attack ↔ pending, além de campaign ↔ pending já documentado.

O encerramento não começa com `campaigns FOR UPDATE` explícito no corpo; não inferir que seu UPDATE final protege retroativamente os locks adquiridos antes. A trigger e chamadas transitivas precisam permanecer no grafo de dependências.

### Classificação e limites

- Confirmado nos corpos instalados: ordem de locks dos entrypoints e helpers descritos acima.
- Não confirmado: deadlock real reproduzido entre RPCs de produção; alcance simultâneo de cada combinação sob todas as regras de ownership/turno; ausência de outros locks indiretos via SQL dinâmico ou triggers não inventariados.
- Nenhuma RPC, trigger, ACL, policy, migration ou dado remoto foi alterado.


### Encerramento de combate e expiração de Fúria — rastreamento por OID (2026-11-09)

Consulta read-only aos corpos instalados, com assinaturas resolvidas por OID (não por proname):

| Rotina/trigger | OID | Prefixo de lock relevante |
|---|---:|---|
| `public.end_combat(bigint)` | 19091 | efeitos de Fúria `FOR UPDATE` → chama encerradores → ataques AOO → pendências AOO → UPDATE final de `campaigns` |
| `priv.srd_end_barbarian_rage(bigint,text,boolean)` | 25340 | efeito → ficha SRD; sincroniza condição vital; no fluxo normal com fadiga também pode chamar aplicador que bloqueia campanha |
| `priv.srd_end_barbarian_rage_token(bigint,text,boolean)` | 26653 | efeito → campanha `FOR UPDATE` → sincronização de ficha/condições |
| `priv.srd_expire_barbarian_rage_on_round_change()` | 26292 | trigger AFTER do UPDATE de `campaigns.combat_data`; a linha campanha já está bloqueada, depois percorre efeitos de Fúria `FOR UPDATE` |
| `priv.srd_apply_campaign_condition(...)` | 24895 | campanha `FOR UPDATE` → atualiza/insere condição |
| `priv.srd_apply_campaign_effect(...)` | 24893 | campanha `FOR UPDATE` → atualiza/insere efeito |
| `priv.srd_sync_character_vital_condition(text,integer,boolean)` | 24908 | atualiza condições vitais; leitura posterior de campanha sem `FOR UPDATE` |

A trigger de avanço de rodada mantém a ordem **campanha → efeito**. Já `end_combat` não adquire o lock da campanha no início: percorre efeitos de Fúria e chama os encerradores antes do UPDATE final de campanha. No ramo de Fúria de personagem, o helper bloqueia efeito e ficha antes de atualizar condições; no ramo NPC, o helper bloqueia efeito e depois campanha/ficha. Assim, o encerramento pode manter **efeito → campanha** enquanto a trigger mantém **campanha → efeito**. É uma inversão direta adicional no ciclo de vida da Fúria, além do padrão AOO **ataque → pending** executado pelo mesmo `end_combat`.

A consulta de callers encontrou, entre outros, `priv.descanso_longo_npc_vinculado_srd_impl` (OID 26808), `public.alternar_estado_campanha(bigint,text)` (OID 20103), `public.usar_furia_barbaro_npc_srd(bigint,text,text)` (OID 26656) e `public.usar_furia_barbaro_srd(text,text)` (OID 25341). A função pública de Fúria de personagem já bloqueia personagem → ficha → campanha antes de delegar o encerramento; não deve ser confundida com a ordem do caminho de `end_combat`.

**Classificação:** inversão estática confirmada nos corpos instalados; deadlock real entre trigger e encerramento não foi reproduzido com RPCs remotas. A fixture nova no GitHub modela o prefixo efeito → ficha → campanha versus campanha → efeito em tabelas descartáveis, sem executar esses corpos.

A trigger `trg_srd_request_confusion_turn_roll` (OID 27271) também é transitiva de UPDATE de campanha: campanha → condição confundida → `campaign_log`. `priv.srd_condition_has_flag` (OID 24984) é helper SQL STABLE de leitura e não adquire locks explícitos. A função `priv.srd_sync_character_vital_condition` atualiza condições e apenas lê campanha por MVCC; essa leitura isolada não deve ser anotada como lock de campanha.


### Escritores de condições: separar locks próprios dos locks herdados — 2026-11-09

Varredura adicional por OID das rotinas que escrevem em `srd_campaign_conditions` e/ou `campaign_log` mostrou que nem todo helper adquire lock da campanha. A classificação depende do chamador:

| Rotina | OID | Lock próprio | Contexto |
|---|---:|---|---|
| `priv.srd_clear_combat_flatfooted_actor(bigint,jsonb)` | 27083 | UPDATE direto de condição; sem lock de campanha | Helpers de iniciativa/rodada surpresa herdam lock do chamador |
| `priv.srd_clear_combat_flatfooted_all(bigint)` | 27085 | UPDATE direto de condições; sem lock de campanha | Chamado por `alternar_estado_campanha` (campaign-first) e `end_combat` (antes do UPDATE final da campanha) |
| `priv.srd_start_combat_flatfooted(bigint,jsonb,integer)` | 27084 | INSERT/UPDATE de condições; sem lock de campanha | Chamado após UPDATE/lock da campanha em início de iniciativa |
| `priv.srd_restore_surprised_flatfooted(bigint,jsonb,text[])` | 27103 | INSERT de condições; sem lock de campanha | Chamado depois do lock em `srd_configurar_rodada_surpresa_srd` |
| `priv.srd_sync_character_vital_condition(text,integer,boolean)` | 24908 | UPDATE/INSERT de condições; leitura posterior de campanha sem `FOR UPDATE` | Leitura MVCC não é lock; ordem herdada |
| `public.srd_remove_campaign_condition(bigint,text,text,text)` | 24806 | UPDATE direto; sem `campaigns FOR UPDATE` | SECURITY DEFINER, EXECUTE authenticated; valida auth e papel GM |
| `priv.srd_request_confusion_turn_roll()` | 27271 | UPDATE condição + INSERT log; sem lock próprio | Trigger AFTER UPDATE de `campaigns.combat_data`, herda lock da campanha |
| `priv.log(bigint,text,jsonb)` | 18737 | INSERT em `campaign_log`; sem lock próprio | Helper append-only |

Outros caminhos confirmados: `srd_configurar_rodada_surpresa_srd` (OID 27092) bloqueia campanha antes de restaurar/limpar condições; `iniciar_iniciativa_com_dados` (OID 20577) e `registrar_iniciativa` (OID 20073) bloqueiam campanha antes do helper. Já `end_combat` (OID 19091) atualiza condições e chama `srd_clear_combat_flatfooted_all` antes do primeiro UPDATE explícito em `campaigns`. `alternar_estado_campanha` (OID 20103), por contraste, adquire campaign FOR UPDATE no início.

**Interpretação:** helpers sem lock próprio não são automaticamente defeituosos: vários herdam corretamente o lock do chamador. O risco está em compartilhar helpers entre callers com ordens diferentes e em expor writer público sem serialização do agregado. `public.srd_remove_campaign_condition` precisa de revisão de contrato/uso frontend; a busca textual GitHub não encontrou chamada direta em `mesa.html`, portanto não presumir que seja caminho ativo. Nenhuma permissão foi alterada.

**Próxima verificação:** revisar callers e ACLs dos escritores de condição; decidir se remoção deve bloquear campanha e revalidar pending/estado antes do UPDATE. Não adicionar `FOR UPDATE` sem analisar chamadores, pois isso pode criar nova inversão.


### Snapshot completo do CBA — confirmação do risco de lost update no frontend (2026-11-09)

A leitura integral de public.salvar_cena_cba(bigint,jsonb) e do fluxo de publicação em mesa.html confirma que o lock da campanha não elimina snapshots obsoletos:

- O RPC autentica o Mestre, adquire campaigns FOR UPDATE, lê o cba_data atual e substitui a cena usando p_scene como base. A união de tokens preserva tokens que existem no banco mas não vieram no snapshot; para tokens com o mesmo id/key, porém, prevalece integralmente a versão enviada pelo cliente.
- Campos da cena fora de tokens vêm diretamente de p_scene; não há comparação de versão, timestamp, hash/base revision ou merge por campo.
- mesa.html mantém cbaWriteQueue = Promise.resolve() e encadeia gravarCBAnaCampanha apenas dentro daquela instância da página. A função clona o objeto recebido antes de enfileirar e envia esse snapshot para sb.rpc('salvar_cena_cba', ...). Isso ordena writes de uma aba/cliente, mas não coordena duas abas, dois Mestres ou RPCs de outros fluxos.
- Foram encontrados nove pontos de chamada do wrapper no arquivo atual. Eles serializam estado local derivado de cbaPublishedState, scene ou do estado publicado; o enfileiramento não atualiza/reconcilia o snapshot já capturado com o último estado remoto antes de cada RPC.

**Cenário concreto:** dois clientes carregam a mesma revisão. Cliente A altera posição de um token e salva. Cliente B, ainda com o snapshot antigo, altera retrato ou metadado desse mesmo token e salva depois. O lock serializa as duas transações, mas a segunda grava a versão antiga do token inteiro, podendo restaurar a posição anterior. O mesmo vale para campos de cena fora de tokens. A preservação de tokens ausentes não protege campos de tokens que aparecem em ambos os snapshots.

**Classificação:** risco de lost update confirmado pela implementação, distinto de deadlock. Não foi reproduzido em duas sessões contra produção e não há evidência de que o sistema atualmente faça reconciliação otimista. A correção deve ser desenhada separadamente do protocolo de locks: preferir RPCs de mutação granular para ações frequentes (posição/PV/metadados) ou controle otimista por revisão (expected_version + incremento atômico), com merge explícito e tratamento de conflito no frontend. Não substituir silenciosamente por merge JSONB genérico, pois arrays de tokens exigem semântica por identidade e operações de exclusão precisam ser explícitas.


## Complemento — o salvamento geral também pode alterar coordenadas

A leitura posterior do corpo remoto de `public.salvar_cena_cba` (OID 20077) confirmou que ele é um writer genérico capaz de substituir objetos de tokens recebidos pelo cliente, incluindo `gridX/gridY`. O endpoint é `SECURITY DEFINER`, executável por `authenticated` e exige papel GM, mas não valida se a posição de um token existente foi alterada nem chama o detector AOO.

Em `mesa.html`, o wrapper `gravarCBAnaCampanha` usa esse RPC para várias operações não relacionadas a movimento (imagem/retrato, `spellState`, criação de NPC, dados de iniciativa, mapa/grade e hidratação de monstros). O fallback de sincronização da posição do token também o utiliza fora do ramo de movimento do GM durante combate. A existência desses usos legítimos impede uma solução simplista que bloqueie qualquer UPDATE de `cba_data`.

**Conclusão adicional:** a autoridade de movimento precisa ser imposta no limite comum de persistência, comparando OLD/NEW das coordenadas dos tokens existentes e permitindo mudanças somente quando uma função de movimento/manobra validada pelo servidor fornece autorização transacional estreita. A comparação deve usar identidade estável e tratar explicitamente remoção/recriação; atualizações de outros campos devem continuar permitidas quando não alterarem geometria ou o conjunto de ameaças.

O trigger atual é executado antes do UPDATE feito por `salvar_cena_cba`, mas só barra o token mover quando já existe pending AOO. Portanto, uma chamada autenticada direta ao salvamento geral durante combate pode mover token sem pending. Revogar apenas os dois wrappers diretos de movimento não fecha essa rota.

A correção deve ainda considerar mutações geométricas legítimas internas do motor, como manobras que reposicionam tokens, e não apenas os dois RPCs de deslocamento. O inventário lexical de funções que mencionam `gridX/gridY` não prova, isoladamente, que todas escrevem coordenadas; cada mutador real precisa ser classificado por efeito e caller antes de fechar o trigger.

**Novos critérios de regressão:** tentativa de mover token existente via `salvar_cena_cba` em combate deve falhar; atualizar somente metadados deve continuar funcionando; adicionar/remover/recriar token não pode ser usado para contornar a comparação; manobras com reposicionamento devem funcionar somente por seus próprios entrypoints autorizados; todos os escritores reais de coordenadas precisam ser cobertos em fixture de integração.

