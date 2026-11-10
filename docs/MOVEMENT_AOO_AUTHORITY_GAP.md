# Bloqueio de movimento e ataques de oportunidade — achado confirmado

**Data da inspeção:** 2026-11-10  
**Ambiente:** leitura somente de catálogo/funções do Supabase de produção; nenhuma RPC de jogo foi executada.  
**Prioridade:** P1 — integridade das regras de combate e movimento.  
**Estado:** confirmado estaticamente; correção e teste autenticado ainda pendentes.

## Problema principal: movimento de jogador pode contornar a etapa AOO

As funções instaladas foram lidas diretamente por OID:

| OID | Função | Papel |
|---:|---|---|
| 20522 | `public.mover_token_player_cba(bigint,text,integer,integer)` | endpoint público de movimento do jogador |
| 27366 | `priv.mover_token_player_cba_impl(...)` | implementação que valida e grava a nova posição do jogador |
| 21615 | `public.mover_token_gm_cba_srd(bigint,text,integer,integer)` | endpoint público de movimento do Mestre |
| 27306 | `priv.mover_token_gm_cba_srd_impl(...)` | implementação de movimento sob controle do Mestre |
| 26923 | `public.srd_detectar_saida_alcance_ameacado_srd(...)` | detector de saída de área ameaçada |
| 26964 | `public.srd_solicitar_movimento_com_aoo_srd(...)` | registra uma movimentação pendente quando há ameaça |
| 27038 | `public.srd_finalizar_movimento_aoo_pendente_srd(...)` | conclui o movimento após as reações |

O wrapper público OID 20522 e a implementação OID 27366 têm EXECUTE para `authenticated`, não para `anon`. As duas implementações de movimento (OIDs 27366 e 27306) não chamam o detector OID 26923 nem a RPC de solicitação OID 26964. Ambas têm EXECUTE para `authenticated`, não para `anon`. Cada uma valida seu escopo (jogador ou Mestre), turno, deslocamento, condições, ocupação e economia de ações, e grava diretamente as coordenadas.

O fluxo protegido existe, mas é separado:
1. `srd_solicitar_movimento_com_aoo_srd` bloqueia a campanha, valida controlador/turno, chama o detector e cria uma linha pendente se houver ameaça.
2. Reações são resolvidas.
3. `srd_finalizar_movimento_aoo_pendente_srd` valida pendências/ataques, bloqueia campanha, confere turno e posição original, ativa o GUC transacional `app.srd_aoo_pending_commit` e só então chama a RPC de movimento.

O trigger `priv.srd_guard_pending_aoo_movement` bloqueia mudanças de posição quando já existe uma pendência AOO, exceto quando o GUC corresponde ao pending que está sendo finalizado. Entretanto, ele não exige que uma pendência exista antes de qualquer movimento. Portanto, uma chamada autenticada direta aos endpoints OID 20522 ou 21615, quando ainda não existe pending, pode gravar movimento sem executar a detecção AOO. A proteção atual impede contornar uma reação já pendente; não impede ignorar a criação da pendência.

**Conclusão:** a integridade da regra não pode depender exclusivamente de o frontend chamar primeiro a RPC de solicitação. O endpoint que efetivamente grava movimento precisa impor o contrato no servidor.

## Correção necessária (não implementada)

A próxima refatoração deve tornar o caminho de movimento uma única autoridade transacional:

1. Identificar e validar campanha, token, controlador, propriedade e turno.
2. Bloquear a campanha e definir explicitamente a ordem parcial de locks do domínio AOO, reconciliando-a com os callers de pending/ataque/ficha já inventariados; a ordem final ainda não está aprovada. Revalidar estado e origem após o lock.
3. Calcular destino, deslocamento, footprint e ameaças usando os mesmos helpers usados pelo restante do motor.
4. Se houver ameaça, criar pending e **não** atualizar coordenadas nem consumir deslocamento até as reações terminarem.
5. Se não houver ameaça, a própria RPC orquestradora deve chamar internamente a implementação de movimento na mesma transação e devolver o resultado final (não apenas `continue_with_existing_movement_rpc`). Isso inclui movimento fora de combate; o frontend não deve fazer uma segunda chamada de escrita.
6. Na finalização, validar novamente posição original, turno, round, ownership, ameaças e estado das reações; impedir duplicidade/idempotência incorreta.
7. Revogar EXECUTE de `authenticated` nos wrappers públicos de movimento direto (OID 20522 e 21615) depois que todos os callsites forem migrados. As implementações privadas permanecem chamadas somente por funções servidoras autorizadas; validar privilégios do owner e não conceder EXECUTE público de volta.
8. Atualizar `mesa.html` para consumir o resultado da RPC orquestradora tanto quando não há ameaça quanto quando há commit após reação. A exceção interna de commit deve continuar limitada ao pending correto.
9. Preservar o fluxo GM/NPC/monstro e a movimentação fora de combate, sem conceder autoridade adicional ao jogador.

Não basta adicionar uma chamada ao detector no frontend ou em um preflight separado: isso manteria a possibilidade de chamada direta e a janela entre detecção e gravação.

## Segundo defeito: footprint Colossal inconsistente

As implementações de movimento do jogador OID 27366 e do Mestre OID 27306 calculam footprint Colossal como **5 quadrados**. O detector AOO OID 26923 calcula footprint Colossal como **6 quadrados**. O helper canônico `priv.srd_token_grid_footprint` e o detector usam 6.

Isso permite divergência entre ocupação/movimento e alcance ameaçado. A refatoração deve eliminar os CASEs duplicados e usar um único helper de footprint em movimento de jogador, Mestre, detecção AOO e demais consumidores.

## Testes de aceite obrigatórios

- Jogador autenticado chama diretamente a RPC de movimento sem passar pela solicitação: deve criar pending se houver ameaça e não mover o token.
- Jogador autenticado move sem ameaça: movimento é aplicado uma única vez.
- Movimento com ameaça: posição e gasto de deslocamento permanecem inalterados até todas as reações atingirem estado terminal; depois o movimento é aplicado uma única vez.
- Sem ameaça e fora de combate: a RPC orquestradora aplica o movimento e devolve `movement_result`; não há segundo RPC público de escrita no frontend.
- Chamador autenticado não consegue executar diretamente os wrappers legados de movimento após a migração; chamadas internas autorizadas da orquestradora/finalizadora continuam funcionando.
- Pending ativo impede movimento direto alternativo, alteração concorrente das coordenadas/remoção do token e finalização duplicada.
- Alteração de turno/round, posição de origem, ownership ou estado da campanha invalida a finalização.
- GM consegue mover NPC/monstro e token de jogador sob controle, respeitando o mesmo contrato AOO.
- Fora de combate, movimento autorizado continua funcionando sem criar pending.
- Tokens Pequeno, Médio, Grande, Enorme, Imenso e Colossal ocupam o footprint canônico; Colossal ocupa 6×6 quadrados.
- Testes concorrentes usam duas sessões autenticadas e Storage/RPC real em ambiente descartável, além das fixtures PostgreSQL sintéticas.

## Restrições de implantação

- Não alterar funções, migrations, grants ou dados do projeto de produção nesta etapa.
- O baseline de migrations foi recuperado do ledger e alinhado byte a byte (966/966); variantes locais divergentes e arquivos não aplicados foram preservados em quarentena. Qualquer nova migration de correção ainda precisa aguardar reprodução das 966 migrations em stack Supabase local descartável e revisão de dependências/locks.
- Não usar TESTE 2 como ambiente de mutação.
- Os OIDs são evidência do snapshot de 2026-11-10 e devem ser revalidados imediatamente antes de qualquer migration.


## Confirmação do encadeamento no frontend

A leitura de `mesa.html` na branch `main` confirma que os dois fluxos normais já chamam primeiro a solicitação AOO durante combate ativo:
- Jogador: linha 2313 chama `srd_solicitar_movimento_com_aoo_srd(..., p_controller: 'player')`; se retornar pending, a interface interrompe o fluxo; caso contrário, chama `mover_token_player_cba` na linha 2326.
- Mestre: linha 5414 chama a mesma solicitação com `p_controller: 'gm'`; se houver pending, abre a fila AOO; caso contrário, chama `mover_token_gm_cba_srd` na linha 5426.

Isso delimita o defeito: não é ausência do fluxo AOO na interação comum da interface. É uma lacuna de autoridade no backend, pois os dois RPCs que gravam a posição também estão diretamente executáveis por `authenticated` e não impõem a solicitação AOO. Uma chamada direta, uma futura tela ou outro consumidor pode contornar a sequência do frontend.

A correção deve preservar o caminho atual de UX, mas mover a garantia para os endpoints/transação de gravação. O preflight do frontend pode continuar para feedback antecipado; não pode ser a única barreira.

## Evidência de footprint canônico

A comparação do snapshot confirmou:
- `priv.srd_token_grid_footprint` e `public.srd_detectar_saida_alcance_ameacado_srd`: Colossal = 6.
- `priv.mover_token_player_cba_impl` e `priv.mover_token_gm_cba_srd_impl`: Colossal = 5.

O helper canônico já existe, então a correção deve reutilizá-lo em vez de criar outro mapeamento de tamanho. A alteração precisa revisar todos os consumidores diretos de footprint para evitar regressões em ocupação, colisão e distância.


## Terceira rota de escrita: salvamento geral da cena pelo Mestre

A inspeção ampliada de `mesa.html` e do catálogo remoto confirmou que os dois RPCs de movimento não são os únicos caminhos capazes de alterar coordenadas:

- `public.salvar_cena_cba(bigint,jsonb)` (OID 20077) é `SECURITY DEFINER`, tem EXECUTE para `authenticated` e valida que o chamador seja GM.
- O corpo bloqueia a linha da campanha, recebe a cena inteira do cliente, mescla tokens por `id`/`key` e atualiza `campaigns.cba_data`. Não valida se as coordenadas de tokens existentes mudaram, nem chama o detector AOO.
- `mesa.html` usa esse RPC pelo wrapper `gravarCBAnaCampanha` (nove callsites observados na branch auditada), inclusive para salvar metadados, publicar cena, atualizar tokens e outras operações. Portanto, a proteção não pode tratar todo UPDATE de `cba_data` como movimento, mas precisa distinguir alterações de coordenadas de outras mutações legítimas.
- O trigger existente `trg_srd_guard_pending_aoo_movement` é BEFORE UPDATE de `campaigns.cba_data` e também intercepta esse salvamento geral. Porém, sua lógica só bloqueia mudança de posição quando já existe pending AOO ativo. Sem pending, permite a mudança.

**Impacto:** revogar apenas os wrappers de movimento direto OIDs 20522 e 21615 não fecha o bypass. Um Mestre autenticado pode enviar uma cena com novas coordenadas pelo OID 20077 durante combate e contornar o fluxo AOO, desde que não exista pending já ativo. A evidência é estática; nenhuma chamada de escrita foi executada.

### Contrato de proteção ampliado

A solução deve ser aplicada no ponto comum de persistência (trigger/validação transacional de `campaigns.cba_data`) e nas funções de movimento:

1. Detectar diferenças de coordenadas entre tokens persistentes da cena anterior e da nova cena, usando identidade estável e tratamento explícito de remoção/recriação. Mudanças em nome, imagem, HP, perfil de combate ou metadados não devem ser confundidas com movimento.
2. Durante combate ativo, rejeitar alteração de coordenadas de token existente por qualquer writer genérico, inclusive `salvar_cena_cba`, salvo quando a transação estiver dentro de uma autoridade de movimento validada pelo servidor.
3. A autoridade de movimento deve validar controlador, token, propriedade/GM, turno, origem, destino, economia de ações, ocupação, condições e AOO; somente ela pode definir o contexto transacional interno que autoriza a alteração de coordenadas.
4. O contexto interno deve ser específico à campanha e ao token (e, na finalização, ao pending correto), não um booleano amplo reutilizável por qualquer update na mesma transação. A validação precisa impedir que um cliente defina o GUC de autorização por SQL/RPC próprio.
5. Permitir alterações de coordenadas durante preparação/exploração somente conforme a política de movimento fora de combate, sem abrir uma rota paralela durante combate.
6. Cobrir todos os writers que atualizam `cba_data`, não apenas `salvar_cena_cba` e os dois wrappers conhecidos. O trigger é o ponto de defesa comum, mas seus callers e contextos de autorização precisam ser inventariados antes da mudança.

### Call sites e grants observados

- `salvar_cena_cba`: OID 20077, authenticated EXECUTE; wrapper de persistência geral localizado em `mesa.html`.
- `mover_token_player_cba`: OID 20522, authenticated EXECUTE.
- `mover_token_gm_cba_srd`: OID 21615, authenticated EXECUTE.
- `srd_solicitar_movimento_com_aoo_srd`: OID 26964, authenticated EXECUTE; atualmente retorna `continue_with_existing_movement_rpc=true` nos caminhos sem ameaça ou fora de combate, deixando a escrita para outra chamada.
- O fluxo normal do jogador chama a solicitação AOO durante combate e depois chama o wrapper direto de movimento quando não há pending.
- O fluxo normal do Mestre chama a solicitação AOO e depois o wrapper direto quando está no turno de um token; fora desse ramo, a sincronização geral da cena usa `salvar_cena_cba`.

**Atualização do escopo:** a correção deve fechar simultaneamente (a) RPCs diretas de movimento, (b) salvamento geral da cena, (c) qualquer outro writer de `cba_data` que altere coordenadas. Revogar os wrappers diretos é necessário, mas insuficiente isoladamente.

### Testes adicionais obrigatórios

- GM tenta mover token existente durante combate por `salvar_cena_cba`: rejeitado sem alteração de coordenadas.
- GM atualiza imagem, nome, HP, perfil de ameaça ou metadados sem alterar coordenadas: permitido conforme as regras existentes.
- GM adiciona token novo em combate: comportamento explicitamente definido e testado; não pode ser usado para remover/recriar um token existente e escapar da guarda.
- Tentativa de trocar `id`/`key`, remover e reinserir token para contornar a comparação de identidade: rejeitada ou tratada como remoção + criação sujeita às mesmas regras.
- Movimento autorizado por orquestradora e finalização AOO: permitido uma única vez; GUC/contexto não autoriza outro token nem outra campanha.
- Todos os writers de `cba_data` inventariados são exercitados em regressão para confirmar que apenas mudanças de coordenadas passam pela autoridade de movimento.



### Mutadores geométricos internos e estabilidade da lista de ameaças

A proteção comum também precisa distinguir mutações geométricas que fazem parte de outras regras SRD:

- `public.adicionar_token_cba_completo` (OID 21726) tem EXECUTE authenticated e delega à inclusão de token. O helper `public.adicionar_token_cba` (OID 20075) cria coordenadas iniciais, valida apenas a célula de origem e não consulta pending. O trigger atual não bloqueia spawn durante uma reação pendente.
- `public.srd_configurar_perfil_combate_token_srd` (OID 26922) tem EXECUTE authenticated, exige GM e pode alterar `combat_faction` e `melee_reach_ft`. Isso pode mudar a lista de criaturas que ameaçam o movimento enquanto o pending está aberto.
- `priv.srd_resolver_encontrao_srd` (OID 27169) é um mutador interno de coordenadas: a resolução de Encontrão pode deslocar o defensor e, se solicitado e permitido, fazer o atacante acompanhar. É parte legítima de uma manobra durante a resolução AOO, não um movimento livre.
- As rotinas de ataques iterativos e de consulta de manobra que mencionam `gridX/gridY` foram classificadas como leituras de alcance no corpo inspecionado; a mera presença dessas chaves não prova escrita de coordenadas. O mutador de Encontrão acima foi confirmado pelo trecho que recompõe o array de tokens com novos `gridX/gridY`.

Assim, o contrato durante pending não pode ser apenas “proibir toda mudança de coordenadas”. Deve congelar a geometria e os parâmetros que sustentam as ameaças calculadas, exceto para mutações SRD explicitamente autorizadas e validadas no fluxo da própria reação. A lista de exceções deve ser pequena, por função e por token; não conceder um bypass genérico a qualquer writer SECURITY DEFINER.

**Ameaças obsoletas a prevenir:** spawn de novo token, remoção/reposicionamento de outro token, alteração de facção, alcance corpo a corpo ou configuração de arma que altere o alcance ameaçado. O motor precisa definir quais desses eventos são rejeitados enquanto pending e quais, se algum, invalidam/cancelam o pending e exigem nova detecção.

**Teste obrigatório adicional:** com pending ativo, tentar adicionar token, mover/remover um ameaçador ou alterar facção/alcance deve falhar sem modificar a geometria; a resolução de Encontrão autorizada deve conseguir aplicar seu deslocamento e eventual acompanhamento, sem abrir uma exceção que permita movimento genérico.



### Diferença atual entre movimento livre do jogador e do Mestre

O contrato fora de combate precisa preservar dois comportamentos distintos observados nos corpos:

- `priv.mover_token_player_cba_impl` permite movimento do jogador quando não há combate ativo (desde que a campanha não esteja marcada COMBATE sem iniciativa); nesse caso não aplica economia de turno.
- `priv.mover_token_gm_cba_srd_impl` exige campanha em estado COMBATE e iniciativa ativa. Portanto, não serve como implementação de movimento livre do Mestre na exploração.
- Na interface, o jogador chama o wrapper de movimento próprio diretamente quando não há combate ativo. O Mestre usa o ramo específico GM durante turno de combate e cai no salvamento geral de cena para sincronizar movimento fora desse ramo.

A futura orquestradora deve oferecer explicitamente os dois modos de exploração:
1. jogador autenticado move somente o próprio token, preservando as validações atuais de ficha, deslocamento, condições e ocupação;
2. GM move tokens autorizados durante exploração, preservando a permissão de Mestre e a validação de identidade/ocupação, sem exigir iniciativa.

Não redirecionar movimento livre do Mestre para a implementação atual GM de combate, pois ela rejeita campanhas fora de COMBATE. Essa diferença precisa de teste próprio antes de revogar qualquer wrapper legado.



## Evidência de CI da atualização documental

No commit `fc2f008e59e980305990e9083058f2b2e76c7750`, o GitHub Actions executou:
- Static validation #62: **success**.
- Validate application JavaScript #110: **success**.
- Validate mesa JavaScript #365: **success**.
- PostgreSQL fixture tests #271 [42749952496](https://github.com/clubberblues/rpgvinculo/actions/runs/42749952496): **success**.

Os commits posteriores que ampliaram este documento alteraram somente documentação; os fixtures e scripts não mudaram. Isso não valida as funções RPC reais, triggers, Auth/PostgREST nem concorrência no Supabase. Nenhuma escrita foi executada no banco remoto.



### Incompatibilidade atual: acompanhamento no Encontrão é bloqueado pelo guard

A leitura cruzada do resolver, trigger e frontend encontrou uma regressão mecânica adicional:

- O frontend (mesa.html) oferece ao Mestre a opção de acompanhar o defensor após um Encontrão e envia p_follow à RPC pública srd_resolver_encontrao_srd (OID 27172).
- A implementação priv.srd_resolver_encontrao_srd (OID 27169) recompõe campaigns.cba_data.tokens; quando success AND p_follow e o deslocamento/espaço permitem, ela altera gridX/gridY do token a, que foi carregado pela identidade p.mover_token_id da pending ativa.
- A função não chama set_config nem define app.srd_aoo_pending_commit.
- O trigger BEFORE UPDATE priv.srd_guard_pending_aoo_movement bloqueia mudança de coordenadas do próprio pending.mover_token_id enquanto o pending está ativo, salvo quando esse GUC corresponde ao pending.

**Conclusão estática:** quando o ramo de acompanhamento realmente desloca o token identificado por p.mover_token_id, o trigger rejeita o UPDATE e a transação do Encontrão é revertida. O ramo que apenas empurra o defensor não altera o token mover e não encontra esse mesmo bloqueio. A interface oferece explicitamente as duas opções, portanto o caminho de acompanhamento está ativo; não foi executado contra produção.

A correção não deve simplesmente remover a guarda. O resolver de Encontrão precisa receber uma autorização transacional estreita, limitada à manobra, à campanha, ao pending e aos tokens/posições que a própria resolução calculou. A autorização de manobra não pode liberar movimentos genéricos nem alterar o destino pendente original sem validação.

**Regressão obrigatória:** resolver Encontrão com acompanhamento desmarcado e marcado; quando o teste resistido e o deslocamento permitirem, o defensor deve ser empurrado e o atacante deve acompanhá-lo; quando não houver espaço/deslocamento, o acompanhamento deve ser bloqueado de forma válida sem abortar indevidamente a resolução. Em todos os casos, pending/ataques e coordenadas devem terminar em estado consistente e idempotente.



### Dependências reais da detecção AOO e ameaça mutável durante pending

A inspeção do corpo completo de `public.srd_detectar_saida_alcance_ameacado_srd` (OID 26923) mostrou que o conjunto de ameaças não depende somente de coordenadas e `combat_faction`. Para cada token adversário, a função calcula footprint e faixas de ameaça a partir de:

- coordenadas `gridX/gridY`, tamanho e facção do token;
- `melee_reach_ft` configurado no token;
- raça/tamanho da ficha ligada por `sourceCharacterId` (ou ID do próprio token player);
- armas equipadas em `srd_character_weapon_instances` e `srd_character_equipment`, incluindo `reach_ft`, `threat_min_ft`, `weapon_melee` e `threatens_squares`;
- ataques naturais extraídos de `monsterStats.ataques/full_attack`;
- ataque desarmado quando a ficha vinculada é Monge ou possui Ataque Desarmado Aprimorado.

O detector grava esses dados no snapshot `pending.threats`, incluindo token, faixas, alcance, facção e passos ameaçados. A finalização de movimento verifica origem/turno/round, mas não recalcula a lista completa nem compara as dependências atuais com o snapshot. O resolver de ataque AOO, por sua vez, revalida se a arma usada continua equipada. Portanto, uma alteração de equipamento pode invalidar uma reação já reservada ou alterar quem deveria ameaçar o caminho.

#### Writers autenticados que alteram dependências do snapshot

- `public.equipar_item_srd` (OID 20555, authenticated EXECUTE, SECURITY INVOKER) permite ao dono da ficha ou ao GM equipar/desequipar. Para armas, delega a `public.equipar_item_srd_maos` (OID 26390) → `public.equipar_arma_instancia_personagem` (OID 26442) → `private.equipar_arma_instancia_personagem_impl` (OID 26441). A implementação bloqueia personagem e instância, mas não campanha nem pending; altera `srd_character_weapon_instances.equipado/hand_slot` e sincroniza `srd_character_equipment`.
- `public.entregar_item_srd` (OID 20556, authenticated EXECUTE, SECURITY DEFINER, GM-only) insere/atualiza `srd_character_equipment` e pode marcar o item como equipado automaticamente quando não há mochila. Não bloqueia campanha/pending.
- `public.srd_configurar_perfil_combate_token_srd` (OID 26922, authenticated EXECUTE, GM-only) altera facção e alcance corpo a corpo do token sob lock da campanha, mas o trigger atual só guarda coordenadas/remoção do token mover.
- `public.salvar_cena_cba` (OID 20077, authenticated EXECUTE, GM-only) aceita o objeto JSON do token existente com campos substituídos, permitindo alterar `combat_faction`, `melee_reach_ft`, `monsterStats`, `tamanho` e `sourceCharacterId`, além das coordenadas.
- `public.adicionar_token_cba_completo` (OID 21726, authenticated EXECUTE, GM-only) cria token via `adicionar_token_cba`; a nova criatura pode entrar no conjunto de ameaças enquanto pending está aberto.

A UI atual chama `equipar_item_srd` no inventário da ficha. Logo, a mudança de arma não é apenas uma possibilidade teórica de API: há um callsite de frontend. O equipamento de NPC/monstro via `equipar_item_token_srd` (OID 21670) grava `srd_cba_token_equipment`, mas o detector atual não consulta essa tabela para compor `threat_ranges`; não classificar essa operação como mutador direto do snapshot sem outra dependência demonstrada.

#### Política necessária para pending

A proteção deve cobrir duas classes diferentes:

1. **Geometria da cena:** posições, footprint, facção, alcance e inclusão/remoção de tokens. Congelar enquanto houver pending, salvo deslocamentos específicos da manobra autorizada.
2. **Fontes externas de ameaça:** equipamento/instâncias, raça/tamanho de ficha, classe/talentos que habilitam ataque desarmado e dados de ataques naturais. Para essas fontes, escolher explicitamente entre bloquear mudanças enquanto pending existir ou invalidar/cancelar o pending e recalcular as ameaças antes de continuar. O resolver não deve aceitar uma reação cuja arma deixou de estar equipada nem concluir movimento com um snapshot obsoleto.

O guard atual em `priv.srd_guard_pending_aoo_movement` consulta somente a pending do movimento e compara a existência/posição do token mover. Não protege os demais tokens nem as tabelas de equipamento/ficha que alimentam o detector.

#### Novos testes de regressão

- Com pending ativo por ameaça de arma de alcance, o dono tenta desequipar/trocar a arma via RPC: operação deve ser rejeitada ou pending invalidada de modo atômico e explícito; não deixar ataque/resolução preso.
- GM entrega arma automaticamente equipada ao personagem ameaçador durante pending: rejeitar ou invalidar/recalcular.
- GM altera facção, alcance, tamanho, `monsterStats` ou `sourceCharacterId` de token ameaçador pelo salvamento geral: rejeitar ou invalidar/recalcular.
- Spawn de token hostil durante pending: rejeitar ou invalidar/recalcular.
- Mudança de atributos não relacionados à ameaça (ex.: PV) deve continuar possível quando não afeta as dependências do snapshot.
- Resolver ataque AOO e finalizar movimento devem verificar que o conjunto de ameaças e os dados mecânicos usados ainda correspondem ao snapshot, ou consumir um snapshot imutável com dependências bloqueadas.



### Ambiguidade de identidade: duplicação de token pode escapar da guarda

Foi confirmada uma falha adicional na comparação OLD/NEW:

- `salvar_cena_cba` (OID 20077) aceita a lista enviada de tokens e a agrega com `UNION ALL`; não valida unicidade de `id` nem de `key`. Dois objetos solicitados com o mesmo identificador permanecem duplicados no array final.
- `priv.srd_guard_pending_aoo_movement` (OID 26962) procura o token mover em OLD e NEW com `id = pending.mover_token_id OR key = pending.mover_token_id LIMIT 1`, sem contar correspondências nem rejeitar duplicatas.
- Como a ordem do array enviado pelo Mestre é preservada, a cena pode conter dois objetos com a mesma identidade: primeiro o objeto mantendo as coordenadas de origem, depois um duplicado com coordenadas alteradas. O trigger compara somente o primeiro e não vê mudança; o UPDATE genérico pode ser aceito.
- Os endpoints de solicitação/detecção e movimento GM contam correspondências e rejeitam token duplicado. Assim, a duplicação também pode impedir a conclusão posterior do movimento pendente e deixar a campanha bloqueada até cancelamento pelo Mestre.

**Classificação:** P1 de integridade/DoS do fluxo AOO, confirmado estaticamente; não foi executado em produção. O teste deve reproduzir a ordenação dos duplicados em fixture isolada.

**Correção necessária:** a validação de cena deve rejeitar qualquer duplicidade de identidade antes de persistir; a guarda deve exigir exatamente uma correspondência em OLD e exatamente uma em NEW para cada identidade relevante, e comparar a posição dessa única correspondência. A identidade canônica deve ser definida (id/key), sem aceitar aliases ambíguos. A validação de token duplicado também deve ser aplicada nos demais writers de CBA.

**Regressões adicionais:**
- Cena com IDs duplicados, keys duplicadas e colisão cruzada (id de um token igual à key de outro): rejeitada.
- Durante pending, dois objetos com identidade do mover, primeiro na origem e segundo deslocado: rejeitado sem gravar cena.
- Token único legítimo continua atualizável em metadados não geométricos.
- Solicitação e finalização não podem ficar presas por duplicidade introduzida via salvamento geral.



### TOCTOU confirmado entre detecção sem ameaça e gravação do movimento

O caminho normal de jogador e Mestre tem duas chamadas RPC separadas quando o detector não encontra ameaça:

1. `srd_solicitar_movimento_com_aoo_srd` (OID 26964) bloqueia campanha, calcula a detecção e retorna `continue_with_existing_movement_rpc=true` sem mover o token.
2. O frontend então chama `mover_token_player_cba` (OID 20522) ou `mover_token_gm_cba_srd` (OID 21615), em uma segunda transação.

A trava de campanha da primeira chamada termina antes da segunda chamada. Entre elas, outro writer pode alterar posição, facção, alcance, equipamento ou incluir uma criatura que passe a ameaçar o trajeto. O RPC de movimento direto revalida turno, deslocamento, ocupação e condições, mas não recalcula AOO. Portanto, mesmo que nenhum bypass direto seja usado, o fluxo normal tem uma janela TOCTOU: a conclusão de “sem ameaça” pode ficar obsoleta antes da gravação.

O frontend foi confirmado em `mesa.html`: jogador e GM chamam a solicitação e, no retorno sem pending, chamam imediatamente o respectivo RPC de movimento. Isso não torna as duas operações atômicas.

**Correção obrigatória:** a orquestradora deve fazer detecção e commit do movimento sem ameaça na mesma transação, mantendo o lock de campanha até a gravação; em caso de ameaça, deve criar pending e não mover. O retorno precisa conter o resultado do movimento já persistido, sem instruir o cliente a fazer uma segunda escrita. Para evitar corridas de equipamento/ficha, os writers dessas fontes também precisam adquirir campaign-first e revalidar pending, ou o motor deve adotar snapshot imutável com dados suficientes para resolver a reação.

**Regressão:** duas sessões concorrentes — sessão A solicita movimento sem ameaça; sessão B altera uma fonte de ameaça antes da escrita. O resultado permitido é serialização (A move primeiro com snapshot atual ou B altera primeiro e A detecta AOO); não pode existir janela em que A usa detecção antiga e grava depois da mudança de B.



## CI do reproducer de identidade/guard (2026-11-10)

- Workflow PostgreSQL #284 [42751013687](https://github.com/clubberblues/rpgvinculo/actions/runs/42751013687) e #285 [42751022904](https://github.com/clubberblues/rpgvinculo/actions/runs/42751022904): **success**.
- Log de #285 confirmou os quatro comportamentos previstos: alteração direta da posição do único mover bloqueada; atualização de metadados permitida; duplicata de identidade com a segunda cópia deslocada aceita pelo algoritmo copiado; alteração da posição de outro token aceita enquanto pending está ativo.
- Static validation, aplicação JS e mesa JS também passaram nos runs associados ao commit subsequente.
- Limite: o teste copia o corpo/algoritmo do trigger para um schema descartável. Não executa a função instalada, RPC, Auth/PostgREST nem o banco remoto. Um resultado verde confirma a reprodução do comportamento, não uma correção.



### O conjunto de armas da reação é consultado depois do snapshot e pode mudar

A revisão dos RPCs de consulta/início de ataque confirmou que a pending não fixa a arma que gerou a ameaça:

- O detector OID 26923 grava em cada ameaça somente faixas `min_ft/max_ft/source` (por exemplo `equipped_weapon`), sem `instance_id`, `equipment_id`, mão ou dados exatos da arma.
- `public.srd_consultar_armas_aoo_srd` (OID 27044) consulta o inventário e as instâncias equipadas no momento da abertura da fila, não a lista de armas existente quando a pending foi criada.
- `public.srd_iniciar_ataque_oportunidade_srd` (OID 27022) volta a ler a instância atual e valida que está equipada, mas não verifica se aquela instância estava presente no snapshot que provocou a ameaça.
- Como `equipar_item_srd` e `entregar_item_srd` podem alterar equipamento durante pending sem guarda, uma arma pode ser desequipada (invalidando a reação) ou uma arma nova pode ser equipada e selecionada para um ataque cuja ameaça não foi calculada com ela.

**Impacto SRD:** a reação deve usar as opções de arma que estavam efetivamente equipadas e ameaçavam o trajeto no instante em que o movimento foi solicitado. O estado atual da ficha não pode substituir silenciosamente esse snapshot.

**Correção:** incluir no snapshot, por token ameaçador, a lista exata de instâncias/armas elegíveis e seus parâmetros mecânicos (instance_id, equipment_id, hand_slot, reach/threat_min, dados necessários para resolver); ou bloquear alterações de equipamento até pending terminar e ainda comparar com snapshot. O resolver deve aceitar somente uma arma do snapshot, não qualquer arma atualmente equipada.

**Regressões:** desequipar a arma que gerou ameaça durante pending; equipar nova arma de alcance durante pending; tentar selecionar instância não presente no snapshot; manter a arma original equipada e concluir ataque. As duas primeiras devem ser rejeitadas ou invalidar/recalcular pending atomicamente; a terceira sempre deve ser rejeitada.



### Footprint Colossal: divergência também alcança ataques e Imposição das Mãos

A varredura remota de funções que contêm regras de tamanho encontrou outros writers ativos que ainda codificam Colossal como 5 quadrados e não chamam o helper canônico:

- `priv.mover_token_gm_cba_srd_impl` (OID 27306) e `priv.mover_token_player_cba_impl` (OID 27366): footprint Colossal 5.
- `public.aplicar_dano_token_ataque_srd_v2` (OID 24744) e overload com ataque furtivo (OID 25562): calculam distância entre footprints e tratam Colossal como 5; não chamam `priv.srd_token_grid_footprint`. O overload de 11 argumentos (OID 25562) tem authenticated EXECUTE e callsite ativo em `mesa.html`.
- `public.usar_imposicao_maos_mortos_vivos_srd` (OID 25509): também contém footprint duplicado com Colossal 5; authenticated EXECUTE e callsite ativo em `mesa.html`.
- Em contraste, helper OID 27073 e detector AOO OID 26923 usam 6 para Colossal.

**Impacto:** alcance, adjacência, ocupação e deslocamento podem discordar conforme a rota de regra usada. A divergência não é apenas visual nem exclusiva de AOO; alcança ataques físicos e toque de Imposição das Mãos.

**Correção:** centralizar a resolução de footprint em helper único e usá-lo em movimento, detecção AOO, ataques corpo a corpo, toque, manobras e validação de ocupação. Não basta corrigir somente os dois RPCs de movimento.

**Testes SRD:** comparar footprints de todos os tamanhos (incluindo Colossal 6×6) nos caminhos de mover jogador/GM, AOO, ataque físico normal/furtivo, toque/Imposição das Mãos, Derrubar, Encontrão e colisão de ocupação; confirmar que as mesmas posições produzem a mesma distância e adjacência em todos os caminhos.



CI adicional no HEAD de auditoria `041f0b5c3dd7c132b57ba6611a423bb26965e9eb`: Static validation #84, aplicação JS #132, mesa JS #387 e PostgreSQL fixture #293 [42751317308](https://github.com/clubberblues/rpgvinculo/actions/runs/42751317308) em **success**. O log #293 confirmou novamente a reprodução de duplicata do mover e alteração geométrica de outro token durante pending. Nenhum RPC Supabase real foi chamado.



### Precisão adicional sobre o trigger atual e identidade de tokens

A inspeção integral do corpo remoto do trigger `priv.srd_guard_pending_aoo_movement` (OID 26962) confirma estes limites:

- O trigger retorna imediatamente quando não existe pending com status `waiting_reactions` ou `ready_to_commit`. Portanto, não protege nenhum movimento enquanto a detecção AOO ainda não criou o pending.
- Quando há pending, ele localiza somente o token mover por `id = pending.mover_token_id OR key = pending.mover_token_id`. Não compara nem congela posições dos tokens ameaçadores.
- Só rejeita remoção do token mover ou alteração de `gridX/gridY` desse token. Não valida identidade estável, duplicidade de `id/key`, tamanho/footprint, alcance, facção, ocupação ou mudança de ameaça.
- A autorização de commit atual é um GUC de sessão/transação `app.srd_aoo_pending_commit` comparado ao pending_id. O finalizador define esse valor antes de chamar os wrappers. A nova arquitetura precisa preservar esse caminho interno, mas restringir o contexto à campanha, pending, token e destino corretos; não se deve reutilizar um sinalizador amplo como autorização genérica.
- O índice parcial `srd_aoo_one_pending_movement_per_campaign` garante no máximo um pending ativo por campanha para os dois status. A consulta do trigger escolhe o mais recente, mas a unicidade é a proteção estrutural efetiva contra dois pendings ativos.

### Salvamento geral: identidade e merge

`salvar_cena_cba` mescla os tokens enviados com os tokens existentes. Um token existente é considerado representado se algum token enviado tiver o mesmo `id` **ou** o mesmo `key`; os existentes não representados são anexados ao final. A função não valida que cada identidade seja única nem que `id` e `key` continuem pareados.

Isso evita que simplesmente omitir um token do payload o remova, mas deixa a identidade do token dependente de duas chaves mutáveis e de uma regra OR. O trigger atual também usa essa mesma regra OR para encontrar o mover. Antes de implementar a guarda global, estabelecer uma chave canônica imutável por token e definir migração/compatibilidade para tokens legados; rejeitar colisões, duplicatas e tentativa de trocar identidade durante combate. Testes devem cobrir:
- payload que altera só `id`, só `key`, ambos, ou cruza `id` de um token com `key` de outro;
- token duplicado com novo `id/key` que tenta representar a mesma ficha/source;
- payload parcial que omite tokens;
- token removido e recriado com nova identidade;
- consistência do `turn_order`, pending AOO, referências de ficha/NPC e logs após qualquer alteração de identidade.

**Importante:** não foi demonstrado que trocar identidade permite mover diretamente o mesmo token pendente — a guarda atual tende a tratar isso como remoção e rejeitar. A falha comprovada é a ausência de proteção global sobre coordenadas e geometria; os casos de duplicação/colisão são riscos adicionais que exigem regressão específica, não uma exploração confirmada.



### Reprodução descartável de bypass por identidade duplicada

O repositório já contém `tests/sql/aoo_guard_duplicate_identity_repro.sql`, executado pelo harness `tests/sql/lock_cycle_test.sh`. A fixture copia o algoritmo atual do trigger (não chama a função instalada) e demonstra duas propriedades:

1. Controle: alterar coordenadas do único token mover é rejeitado; atualizar apenas metadados não geométricos é permitido.
2. Bypass reproduzido: enviar dois objetos com o mesmo `id/key`, mantendo o original primeiro na origem e colocando a segunda cópia em outra coordenada, passa pelo trigger porque cada busca usa `LIMIT 1` e compara apenas a primeira ocorrência. A fixture confirma duas cópias persistidas e a segunda deslocada.
3. Pending sem congelamento da geometria de ameaça: enquanto o mover tem pending ativo, a coordenada do token ameaçador também pode ser alterada pelo trigger atual.

Isso eleva duplicação de identidade de risco hipotético a **bypass reproduzido no algoritmo copiado**. Ainda não é uma chamada à RPC instalada nem prova de exploração via PostgREST; o payload de cena precisa ser rejeitado no contrato futuro por identidade canônica única antes do merge e a guarda deve comparar o conjunto completo de tokens.

O README registra os runs PostgreSQL #284, #285 e #293 como success, com reprodução da duplicata e da alteração geométrica do outro token. São resultados sintéticos intencionais: verde significa que a vulnerabilidade conhecida foi reproduzida, não que a segurança esteja corrigida. Quando a implementação mudar, converter a fixture em regressão negativa, exigindo rejeição dos dois casos.



### Inventário ampliado de escritores da cena — catálogo remoto (2026-11-10)

Consulta read-only a `pg_proc` ampliou o inventário para além das RPCs explicitamente nomeadas como movimento. Foram identificadas rotas que atualizam `campaigns.cba_data` e devem ser classificadas pelo efeito real no JSON (a presença de `gridX/gridY` no corpo não prova, sozinha, que a função os modifica):

- Movimento direto: `priv.mover_token_gm_cba_srd_impl` (OID 27306) e `priv.mover_token_player_cba_impl` (OID 27366), ambos `SECURITY DEFINER`, com `EXECUTE` para authenticated no catálogo. Ambos não mencionam pending no corpo; dependem do trigger e por isso não impõem detecção AOO antes do primeiro deslocamento.
- Escrita geral: `public.salvar_cena_cba` (OID 20077), authenticated EXECUTE; `public.adicionar_token_cba_completo` (OID 21726), authenticated EXECUTE; `public.srd_configurar_perfil_combate_token_srd` (OID 26922), authenticated EXECUTE. São escritores de cena/perfil que precisam validar pending e integridade do conjunto completo de tokens.
- Outros caminhos de escrita de cena incluem `public.avancar_turno` (OID 20074), `public.aplicar_dano_token_ataque_srd_v2` (OID 24744 e overload OID 25562), `public.usar_imposicao_maos_mortos_vivos_srd` (OID 25509), `public.srd_finalizar_movimento_aoo_pendente_srd` (OID 27038) e `priv.srd_resolver_encontrao_srd` (OID 27169). Alguns contêm termos de coordenadas por leitura/validação, portanto cada corpo deve ser classificado por diff JSON efetivo antes de rotular como escritor geométrico.
- As funções internas `priv.*` são `SECURITY DEFINER`; a consulta `has_function_privilege(authenticated, ...)` não substitui a inspeção de exposição PostgREST/schema usage e ACL efetiva. A exposição real deve ser determinada pelo wrapper público e pelos grants de schema, não inferida apenas do booleano de privilégio.
- O trigger `trg_srd_guard_pending_aoo_movement` é o único trigger de `campaigns` ligado a `cba_data` identificado na consulta. Os outros triggers da tabela são ligados a `combat_data`; não há guarda global independente para writers de cena.

**Implicação arquitetural:** o contrato futuro deve ser centralizado na fronteira de escrita de `campaigns.cba_data` (ou em um conjunto fechado de writers com helper obrigatório), não em uma lista parcial de RPCs de movimento. Cada writer deve declarar se altera coordenadas, identidade, footprint, facção/alcance, inventário/armas ou apenas estado não geométrico; pending ativo exige freeze ou invalidação/recalculo atômico de toda dependência AOO. Nenhuma mudança remota foi aplicada.


### ACL e schema interno — confirmação adicional (2026-11-10)

- O catálogo remoto retorna `has_schema_privilege('authenticated', 'priv', 'USAGE') = true` e `has_function_privilege('authenticated', ...) = true` para as implementações `priv.mover_token_gm_cba_srd_impl` (OID 27306), `priv.mover_token_player_cba_impl` (OID 27366) e `priv.srd_resolver_encontrao_srd` (OID 27169). ACL explícita dessas funções inclui `authenticated=X`.
- Isso significa que o schema chamado `priv` não está isolado do papel authenticated no nível de privilégios SQL. Não afirmar, sem a configuração efetiva do PostgREST, que esses objetos estão publicados como endpoints REST: `pgrst.db_schemas` não apareceu em `pg_settings` e a lista de schemas expostos não foi confirmada nesta sessão.
- Ainda assim, conceder `USAGE` no schema e `EXECUTE` em funções internas `SECURITY DEFINER` amplia a superfície de chamada SQL autenticada e contraria a intenção de helpers privados. O plano de correção deve revogar `USAGE` de `priv` para `authenticated`/`anon` e `EXECUTE` das implementações internas para papéis cliente, mantendo concessão somente ao papel/owner interno estritamente necessário; wrappers públicos validam autorização e chamam helpers como owner. Antes da mudança, inventariar todas as dependências legítimas de `priv` e testar os wrappers.
- `public` mantém USAGE para authenticated/anon; RPCs públicas listadas possuem EXECUTE authenticated e não anon. Nenhuma ACL foi alterada. A lista de schemas PostgREST expostos continua pendente de confirmação por configuração administrativa/REST.


### Refinamento obrigatório antes de qualquer revogação em `priv` (2026-11-10)

A proposta de revogar `USAGE` do schema `priv` para authenticated não pode ser aplicada de forma cega. A consulta de dependências encontrou wrappers `public` com `SECURITY DEFINER = false` que chamam diretamente implementações `priv`, incluindo:

- `public.mover_token_player_cba` OID 20522 → `priv.mover_token_player_cba_impl`;
- `public.mover_token_gm_cba_srd` OID 21615 → `priv.mover_token_gm_cba_srd_impl`;
- fluxos AOO/manobras como `public.srd_reservar_ataque_oportunidade_srd` OID 26917, `public.srd_reservar_reacao_movimento_aoo_srd` OID 26971, `public.srd_iniciar_encontrao_srd` OID 27171, `public.srd_resolver_encontrao_srd` OID 27172, `public.srd_iniciar_derrubar_com_aoo_srd` OID 27144, `public.srd_resolver_derrubar_apos_aoo_srd` OID 27145, e `public.srd_finalizar_movimento_aoo_pendente_srd` (wrapper é SECURITY DEFINER, mas foi incluído na cadeia para validação).

O catálogo também retornou outras RPCs públicas invoker que dependem de `priv` em combate/NPC/ataque iterativo. Portanto, revogar USAGE/EXECUTE imediatamente pode quebrar operações legítimas. A correção segura exige classificar todas as RPCs públicas invoker que chamam `priv`, converter wrappers para SECURITY DEFINER somente após revisar `search_path`, autorização e ownership, ou mover a lógica interna para um mecanismo que não exija privilégio do chamador; então restringir o schema e validar todas as jornadas. O achado é uma exposição/grant excessivo confirmado, mas o remédio precisa preservar a cadeia invoker existente.


### Mapeamento quantitativo da cadeia `public → priv` (2026-11-10)

Nova consulta ao catálogo remoto, restringindo a resolução dos alvos ao schema `priv`, confirmou que a cadeia é muito maior que os wrappers de movimento/AOO inicialmente exemplificados:

- 70 funções distintas no schema `priv` são chamadas por funções `public`.
- 35 funções públicas distintas com `SECURITY INVOKER` chamam implementações em `priv`; essas funções invoker têm `EXECUTE` para authenticated (a consulta anterior encontrou 40 linhas de chamadas, contando múltiplas chamadas/overloads).
- Existem também wrappers públicos `SECURITY DEFINER` com `search_path` fixado; na amostra agregada, não foi encontrado caller definer sem `search_path` explícito.
- Entre os wrappers invoker estão movimento GM/jogador, ataque iterativo NPC, dano NPC/GM, avanço de nível, ações de turno, descanso NPC e rotas AOO/manobras. Portanto, a transição para um schema realmente privado é uma migração de arquitetura de RPC, não uma simples mudança de grants.

**Estratégia de migração segura (proposta):** (1) materializar uma matriz exata por assinatura com owner, `prosecdef`, `proconfig`, grants, chamadas internas e consumidor frontend; (2) para cada wrapper invoker cliente, avaliar a conversão para `SECURITY DEFINER` com owner controlado, `search_path` fixo e autorização explícita antes de qualquer acesso; (3) manter invoker apenas quando não houver dependência de privilégio no schema interno ou redesenhar a API; (4) revogar EXECUTE cliente das implementações internas e USAGE do schema `priv` somente depois de converter toda a cadeia e testar todos os fluxos; (5) executar regressão negativa com chamadas diretas aos nomes `priv.*` para confirmar negação e regressão positiva via wrappers públicos. Não converter automaticamente os 35 wrappers em lote: cada um precisa de revisão de autorização e do comportamento atual.

Nenhuma alteração de ACL ou função foi aplicada. A lista e os números são um retrato do catálogo remoto no momento da consulta.


### Contagem de grants internos e exceção anon/PUBLIC (2026-11-10)

- No schema `priv` foram encontrados 40 procedimentos/funções com `EXECUTE` efetivo para `authenticated`; 39 deles são `SECURITY DEFINER`. Nenhuma função `SECURITY DEFINER` em `priv` está sem `search_path` fixado na consulta.
- Uma função também tem `EXECUTE` efetivo para `anon`: `priv.srd_feat_saving_throw_modifier(jsonb,text)` (OID 26355). ACL `{=X/postgres,...}` indica concessão a `PUBLIC`, não apenas anon. A função é SQL STABLE e calcula modificadores passivos de talentos a partir de `public.srd_feats`; aceita JSON de talentos e tipo de resistência e não faz mutação. O efeito pode ser intencional como helper de cálculo, mas sua exposição pública contradiz a ideia de `priv` fechado e deve ser classificada explicitamente antes de revogar o grant.
- Nem authenticated nem anon têm `CREATE` em `public` ou `priv` (e PUBLIC também não), reduzindo o risco de substituição de objetos nesses schemas. Isso não elimina a superfície de chamada direta por EXECUTE.
- Remediação: revisar se a função 26355 precisa ser pública; se não, remover grant `PUBLIC` e conceder somente aos wrappers/roles internos. Não fazer revogação em massa até concluir o grafo de chamadas. Nenhum grant alterado.


### Proprietário e funções internas não-definer (2026-11-10)

- As 94 funções de `priv` encontradas pertencem ao role `postgres`; 88 são `SECURITY DEFINER`. O owner comum elimina variação de proprietário entre helpers, mas significa que qualquer chamada autorizada a um helper definer executa com privilégios amplos desse owner.
- As seis funções `priv` invoker não têm todas a mesma exposição: `d20()`, `monster_atk(integer)`, `roll_dice_expr(text)`, `srd_grid_footprint_distance_ft(...)` e `srd_weapon_proficiency(jsonb,text)` não têm EXECUTE para authenticated/anon; `srd_parse_natural_attack_list(text)` (OID 27228) tem EXECUTE authenticated, mas não anon. Esta última é um helper parser chamado por wrapper público de ataques naturais; é read-only e deve ser mantida como dependência controlada ou encapsulada junto com a migração.
- `current_setting('pgrst.db_schemas', true)` e `pgrst.db_extra_search_path` retornaram NULL na sessão SQL. Portanto, a lista real de schemas expostos pelo PostgREST permanece desconhecida; não concluir que `priv` está ou não publicado em REST.
- Todos os achados são de catálogo/configuração observável via SQL; sem chamada REST autenticada/anon, não se provou exploração remota direta de endpoints `priv`.


### Bloqueio de execução em wrappers SECURITY INVOKER (2026-11-10)

Uma consulta refinada resolveu cada chamada explícita `priv.nome(...)` pelo schema `priv` e comparou o privilégio efetivo do role `authenticated` na assinatura exata. Foi confirmado um defeito funcional concreto na cadeia pública de manobras:

- `public.srd_consultar_modificadores_manobra_srd(...)` (OID 27119) é `SECURITY INVOKER`, tem EXECUTE para authenticated e chama diretamente:
  - `priv.srd35_maneuver_profile(bigint,text)` (OID 26884), sem EXECUTE para authenticated;
  - `priv.srd_grid_footprint_distance_ft(integer,integer,integer,integer,integer,integer)` (OID 27071), sem EXECUTE para authenticated;
  - `priv.srd_token_grid_footprint(bigint,text)` (OID 27073), sem EXECUTE para authenticated.
- `public.srd_listar_ataques_naturais_oportunidade_srd(bigint,text)` (OID 27229) também é `SECURITY INVOKER`, tem EXECUTE para authenticated e chama `priv.srd35_maneuver_profile(bigint,text)` sem EXECUTE para authenticated. A chamada ao parser `priv.srd_parse_natural_attack_list(text)` (OID 27228) é permitida para authenticated.

**Interpretação:** quando um wrapper é SECURITY INVOKER, a chamada interna é avaliada com os privilégios do usuário autenticado, não com os privilégios do owner do wrapper. Assim, as duas RPCs acima não conseguem executar os helpers que não concedem EXECUTE a authenticated; a falha ocorre antes de concluir a consulta/manobra. Isso é uma incompatibilidade de privilégios verificável no catálogo e não depende de o schema `priv` estar publicado como endpoint PostgREST. O catálogo não demonstra por si só a mensagem de erro observada numa sessão real; é necessária regressão autenticada controlada para confirmar o comportamento ponta a ponta.

**Correção proposta:** não conceder EXECUTE indiscriminadamente nos helpers internos. Preferir converter esses wrappers específicos para SECURITY DEFINER somente depois de revisar sua autorização e garantir `search_path` fixo (com `pg_catalog` primeiro e schemas explicitamente qualificados); alternativa é expor um wrapper definer estreito para cada operação. Em seguida, testar chamada autenticada das duas RPCs, tanto caminho válido quanto negação de jogador que não seja GM, campanha inexistente, token inválido e parâmetros malformados. Não foi aplicada alteração de função ou ACL em produção.


### Correção preparada em branch — wrappers de catálogo GM (2026-11-10)

A inspeção das migrations de origem confirmou a causa: as migrations `20261108173533_maneuver_trip_weapon_aoo_context.sql` e `20261108185917_expose_gm_natural_attack_opportunity_catalog.sql` criaram os wrappers como `SECURITY INVOKER`, apesar de chamarem helpers `priv.*` não executáveis por authenticated. A análise detalhada delimitou o defeito:
- A sobrecarga de 6 argumentos de `srd_consultar_modificadores_manobra_srd` só aciona helpers sem EXECUTE para authenticated no caminho Derrubar; Encontrão retorna pela sobrecarga de 5 argumentos, que já é SECURITY DEFINER e mantém a verificação GM.
- `srd_listar_ataques_naturais_oportunidade_srd` chama sempre `priv.srd35_maneuver_profile`, sem EXECUTE para authenticated; o parser é executável por authenticated.
- Entre os wrappers públicos invoker que fazem chamadas diretas a `priv.*`, a consulta catalogal identificou exatamente esses dois com dependências diretas sem EXECUTE para authenticated; os demais nomes resolvidos nessa amostra não apresentaram esse bloqueio direto. Isso não elimina dependências transitivas ainda não cobertas pela expressão de busca.

Preparei na branch uma migration aditiva que altera apenas essas duas assinaturas para SECURITY DEFINER, mantém `search_path` fixo, retira EXECUTE de PUBLIC/anon e mantém authenticated/service_role no helper passivo; as RPCs GM ficam apenas authenticated. Ambas já contêm validação explícita de `auth.uid()` e GM antes de consultar dados; a migration não altera os corpos das funções. Acrescentei `supabase/verification/verify_maneuver_catalog_rpc_security.sql` para validar flags, search_path, autorização preservada e ACL após aplicação.

**Estado:** migration e verificação estão apenas no branch de auditoria; não foram aplicadas ao Supabase remoto. Regressão autenticada real ainda necessária, incluindo Derrubar com/sem arma apropriada, GM autorizado, jogador comum negado e catálogo de ataques naturais de NPC/monstro.


### Fixture isolado da correção de privilégios (2026-11-10)

Foi acrescentado `tests/sql/maneuver_catalog_security_fixture.sql`, que cria um ambiente PostgreSQL descartável com roles `authenticated`, `anon`, `service_role`, schema `priv`, helpers sem EXECUTE para authenticated e wrappers GM equivalentes às assinaturas remotas. O fixture aplica a migration focalizada real via `psql \\i`, executa o script de verificação pós-migration, valida chamada positiva com papel GM, valida negação de jogador e confirma que authenticated continua sem chamada direta ao helper interno. O workflow `postgres-fixture-tests.yml` foi atualizado para executar o novo fixture.

Este teste verifica o comportamento de privilégios e a sintaxe/efeito da migration num PostgreSQL isolado; não substitui chamadas autenticadas contra as funções reais do Supabase nem teste de regressão com dados de campanha. Execução CI ainda pendente de confirmação para o novo commit.

### Redução adicional da superfície EXECUTE em helper de talentos (2026-11-10)

A auditoria confirmou que `priv.srd_feat_saving_throw_modifier(jsonb,text)` (OID 26355) tinha EXECUTE herdado de PUBLIC, portanto também executável por anon, apesar de ser helper interno de cálculo passivo. Seu único consumidor catalogal identificado é `priv.srd_saving_throw_bonus(...)`, que é SECURITY DEFINER, owner postgres, e chama o helper sob privilégios do owner. O helper não precisa de EXECUTE anônimo para esse caminho.

Foi preparada a migration `20261110160000_revoke_public_feat_saving_throw_helper.sql`: remove somente EXECUTE de PUBLIC, mantém apenas authenticated, e não altera o corpo da função nem o consumidor. Script de verificação em `supabase/verification/verify_passive_feat_helper_acl.sql`. O fixture `tests/sql/maneuver_catalog_security_fixture.sql` agora aplica as duas migrations reais, verifica os guards GM, preserva o acesso autenticado ao motor de resistência e confirma que anon não chama diretamente o helper.

As duas migrations e o fixture permanecem apenas no branch. Nenhuma ACL foi alterada no Supabase remoto; CI ainda não foi confirmado para o HEAD mais recente.
