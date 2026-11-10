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
- O histórico de migrations permanece sem reconciliação completa; qualquer migration de correção precisa aguardar baseline reproduzível e revisão de dependências.
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

