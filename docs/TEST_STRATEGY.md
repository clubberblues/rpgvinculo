# Vínculo RPG — Estratégia de testes

## Princípios
- Testar comportamento e regras, não apenas existência de código.
- Separar testes unitários, integração, autorização, interface e ponta a ponta.
- Usar ambiente/campanha descartável e dados sintéticos para cenários com escrita.
- Nunca usar personagens/campanhas reais como fixtures de teste.
- Não considerar mocks como evidência de funcionamento do Supabase remoto.
- Registrar método, ambiente, resultado e limitações de cada teste.

## Camadas de teste

### 1. Verificação estática
- Parse de HTML e JavaScript inline.
- Lint e validação de sintaxe.
- Parse de SQL/migrations.
- Verificação de referências a tabelas, RPCs e colunas.
- Busca por duplicação de fórmulas e chamadas obsoletas.

**Limite:** sintaxe válida não prova comportamento.

### 2. Testes unitários de regras
- Fórmulas e modificadores.
- Progressões por nível.
- Pré-requisitos de talentos, magias e classes.
- Proficiência e propriedades de equipamento.
- Condições, bônus tipados e empilhamento.
- Ataque, CA, crítico, dano, resistência e recursos.

Os casos devem incluir limites, valores ausentes, combinações e resultados inválidos.

### 3. Testes de banco e RPC
- Restrições, FKs e integridade.
- Atomicidade e rollback.
- Idempotência e chamadas repetidas.
- Concorrência e consumo duplicado.
- Propriedade, campanha, papel e autorização.
- Grants efetivos, RLS e search_path de funções privilegiadas.

Testes destrutivos devem ocorrer somente em ambiente descartável ou transação comprovadamente revertida.

### 4. Testes de integração
- Ficha → banco → mesa.
- Inventário/equipamento → CA/ataque/dano.
- Rolagem → resolução → log/chat.
- Iniciativa → ordem → turno → economia de ações.
- Magia → requisitos → espaço → efeito → sincronização.
- Token → movimento → grid → visibilidade → Realtime.

### 5. Testes de interface
- Mestre e jogador em papéis distintos.
- Modais, menus contextuais e controles por turno.
- Desktop e viewport reduzido.
- Teclado, toque, foco e movimento reduzido.
- Estados de carregamento, falha e reconexão.

### 6. Teste ponta a ponta multiplayer
Executar com pelo menos uma sessão autenticada de Mestre e uma de Jogador em campanha descartável:
1. Entrar na campanha e validar papéis.
2. Abrir ficha e mesa.
3. Publicar/selecionar mapa e tokens.
4. Mover tokens em exploração e combate.
5. Iniciar iniciativa com rolagens conforme as decisões de produto.
6. Executar turno, ações e reações.
7. Validar ataque, defesa, dano e atualização de PV.
8. Validar inventário/equipamento.
9. Validar magia e recursos.
10. Confirmar que ambos os clientes observam o mesmo estado.
11. Repetir ações proibidas e confirmar rejeição no servidor.
12. Encerrar combate e confirmar estado final.

## Matriz de papéis
Para cada RPC/ação relevante, testar:
- Não autenticado.
- Jogador proprietário.
- Outro jogador da campanha.
- Mestre proprietário da campanha.
- Membro de outra campanha.
- Token/ficha inexistente, duplicado ou pertencente a outra campanha.

A matriz exata deve respeitar as regras de negócio de cada ação; não aplicar um padrão genérico que conceda permissões indevidas.

## Critérios de conclusão de módulo
Um módulo só pode ser concluído quando:
- requisitos funcionais estão documentados;
- fonte canônica dos dados está definida;
- casos normais, limites e erros foram testados;
- autorização foi testada por papel;
- integração com consumidores foi validada;
- regressões relevantes passaram;
- limitações restantes estão registradas;
- documentação de estado foi atualizada.

## Registro de execução
Para cada rodada de testes, registrar data e commit; ambiente e versão; fixtures utilizadas; testes executados; resultados (passou/falhou/bloqueado); evidência reproduzível; limitações; e próxima ação.

## Distinção de evidências
- **Parse/sintaxe:** prova que o código é analisável.
- **Mock/simulação:** prova comportamento dentro do mock.
- **Teste transacional revertido:** prova comportamento do banco no contexto simulado e não persiste o cenário.
- **Teste remoto autenticado:** prova comportamento no projeto conectado com identidade válida.
- **Ponta a ponta multiplayer:** prova integração entre clientes, servidor e estado compartilhado.

Não usar uma categoria como substituta de outra.


## Inventário de automação existente — 2026-11-08

O README registra que foram executados localmente parse de HTML/JavaScript, parse PostgreSQL com pglast e smoke tests Playwright com Supabase simulado. Esses registros são evidência histórica de execução, mas não comprovam que a suíte está disponível ou reproduzível no repositório atual.

Foram procurados os caminhos convencionais package.json, playwright.config.js/ts, tests/mesa.spec.js, tests/ficha.spec.js, tests/e2e.spec.js, .github/workflows/ci.yml e supabase/config.toml; esses arquivos não foram encontrados nesses caminhos. Buscas de código por Playwright, Vitest, Jest, pglast e test.describe também não retornaram resultados. Como não foi possível listar toda a árvore do repositório por essa inspeção, a conclusão é **“harness automatizado não localizado nos caminhos convencionais”**, e não “não existem testes em nenhum lugar”.

### Próxima ação
Localizar/reconstituir os testes históricos e torná-los reproduzíveis no repositório, começando por parse estático e testes de regras sem escrita; depois criar testes transacionais e E2E em ambiente descartável.


## Primeiro resultado de CI — 2026-11-08
- Script: scripts/check-static.mjs.
- Workflow: .github/workflows/validate-static.yml.
- Execução: [GitHub Actions run #1](https://github.com/clubberblues/rpgvinculo/actions/runs/42546411046).
- Commit testado: 0a27f50f07b3f8ad53a4600661e0e304d8c4afa7.
- Resultado: **success**.
- Verificação: 9 blocos JavaScript inline/compartilhados em 5 páginas ativas; referências locais de scripts; contrato de rolagem manual do Dice.
- Limite: não testa DOM em navegador, chamadas Supabase, autorização, regras de domínio, transações ou multiplayer. É a primeira camada, não substitui testes de integração/E2E.


## Segunda execução CI — 2026-11-08
- [GitHub Actions run #2](https://github.com/clubberblues/rpgvinculo/actions/runs/42548214654) — **success**.
- Além da sintaxe, protege os contratos de iniciativa manual (registrar_iniciativa_d20 e iniciar_iniciativa_com_dados), registro de ataque manual e proíbe chamadas literais a roll_dice nas páginas ativas.
- Nenhuma alteração de dados de jogo foi necessária.


### Cenários de idempotência a adicionar
- Enviar duas vezes o mesmo request_id de conjuração deve retornar o mesmo resultado e consumir espaço/ação uma única vez.
- Enviar duas vezes o mesmo request_id de avanço de turno deve avançar apenas um ator.
- Repetir registrar_iniciativa_d20 com mesma ficha deve retornar a ordem atual sem alterar resultado.
- Repetir registrar_rolagem_ataque_iterativo_srd/aplicar_dano_ataque_iterativo_srd com a mesma idempotency_key deve retornar o resultado persistido sem duplicar dano.


## Casos de concorrência prioritários — 2026-11-09

### Ataque de Oportunidade: cancelar vs. aplicar dano
Fixture descartável com campanha em combate, movimento pendente ativo, reação reservada e ataque em `awaiting_damage`:
1. Sessão GM A inicia `srd_cancelar_movimento_aoo_pendente_srd` e pausa após obter lock da pendência.
2. Sessão GM B inicia `srd_aplicar_dano_ataque_oportunidade_srd` para o ataque associado e pausa após obter lock do ataque.
3. Liberar ambas as sessões e observar se ocorre deadlock/aborto; registrar SQLSTATE, transação sobrevivente e estado final.
4. Repetir com ordem de chegada invertida e com a variante de dano de monstro.
5. Verificar atomicidade: nunca pode haver dano aplicado em movimento cancelado nem ataque pendente após movimento finalizado/cancelado.

**Estado:** não executado. O risco foi identificado estaticamente por inversão de ordem de locks; não executar no projeto de dados real. Só realizar após criar fixture/campanha descartável e duas sessões autenticadas.

### Realtime: desconexão e reconciliação
1. Dois clientes autenticados na mesma campanha; capturar snapshot inicial.
2. Desconectar um cliente, executar mudanças de turno, PV, condições, equipamentos e mensagens no outro.
3. Reconectar e verificar recuperação de snapshot sem depender de novo evento.
4. Injetar repetição/ordem invertida de eventos quando possível; confirmar dedupe e rejeição de estado antigo.

**Estado:** não executado. Depende do contrato de state_version e resync a definir.


## Infraestrutura de testes e ambiente descartável — atualização 2026-11-09

- O projeto Supabase conectado possui somente a branch `main`; não há branch de desenvolvimento descartável ativa.
- O repositório não contém `supabase/config.toml`, `package.json` ou diretório `tests/`. Os workflows existentes são estáticos e o smoke test usa Playwright instalado no próprio job.
- Não criar branch Supabase sem confirmar custo e necessidade; não usar main para testes que alterem dados.
- A reconciliação de migrations está bloqueando reset/deploy e qualquer tentativa de reconstrução. Primeiro gerar baseline a partir do schema remoto e validar em ambiente descartável.


## Regressão P1 — movimento direto não pode contornar AOO

**Pré-condição:** ambiente Supabase descartável com campanha de teste, iniciativa ativa, token jogador próprio e criatura inimiga ameaçando o quadrado de origem; nenhum registro pending ativo. Nunca executar em TESTE 2/produção.

1. Invocar diretamente `mover_token_player_cba(p_campaign_id,p_character_id,p_grid_x,p_grid_y)` sem chamar `srd_solicitar_movimento_com_aoo_srd`, escolhendo destino que saia da área ameaçada.
   - Esperado após correção: a RPC retorna movimento pendente/AOO e não altera coordenadas nem consome deslocamento até resolução.
   - Estado atual inferido do código: a implementação valida turno/ação/distância, mas não executa detector AOO; provável movimento direto. Reproduzir apenas no ambiente descartável.
2. Chamar o pré-check AOO com destino sem ameaça; antes de chamar a RPC de movimento, alterar a posição de um token ameaçador em transação separada para que o mesmo trajeto agora provoque AOO; depois chamar a RPC de movimento.
   - Esperado após correção: detecção e persistência serializadas na mesma transação; criar pending ou impedir movimento.
   - Estado atual: duas RPCs/transações; janela TOCTOU existente.
3. Repetir com GM usando `mover_token_gm_cba_srd`, confirmando a política de autoridade de GM e se a movimentação também deve abrir AOO.
4. Validar que, com pending já ativo, o trigger `trg_srd_guard_pending_aoo_movement` continua bloqueando alteração/remoção do token que está pendente, exceto pelo caminho de commit autorizado.

**Critérios:** sem movimento ou consumo de ação antes de resolver AOO; uma única pending por campanha; retries não duplicam movimento/reação; logs e UI refletem o resultado; testes concorrentes não produzem deadlock.



5. Com um movimento AOO pendente ativo para o token A, invocar diretamente `mover_token_player_cba` para um token B cujo turno/autorizações estejam válidos e, separadamente, `mover_token_gm_cba_srd` para outro token sob controle GM.
   - Esperado após correção: nenhuma movimentação de outro token enquanto existir pending AOO ativo, salvo operação explicitamente autorizada e modelada como parte da resolução.
   - Estado atual: os helpers não consultam a tabela pending; o trigger existente só protege o token A.


## Regressão P2 — footprint Colossal deve ser 6×6

**Pré-condição:** fixture descartável com um token Colossal (espaço 30 ft) e alvos de tamanhos variados.

1. Confirmar que movimento de jogador e GM reserva/valida área 6×6, não 5×5; um destino com apenas a sexta faixa de quadrados ocupada deve ser considerado sobreposição.
2. Confirmar que a distância entre bordas para ataques e alcance de habilidade usa footprint 6×6 para atacante e alvo Colossal.
3. Confirmar que detector AOO, manobras e ataque iterativo concordam na mesma geometria.
4. Repetir com Grande (2), Enorme (3), Imenso/Gargantuan (4) e Médio/Pequeno (1) para evitar regressões nas categorias já corretas.
5. Testar especificamente `aplicar_dano_token_ataque_srd_v2` (ambas sobrecargas) e `usar_imposicao_maos_mortos_vivos_srd` em distâncias exatamente no limite e uma casa além.

**Critério:** todos os sistemas usam o mesmo helper canônico e o espaço Colossal corresponde a 6 quadrados em cada eixo.


## Restrição de custo e harness de testes — decisão 2026-11-09

- Orçamento adicional disponível para infraestrutura: **zero**. Não criar projetos ou branches Supabase pagos, nem contratar serviços externos.
- O primeiro ambiente automatizado de testes será PostgreSQL efêmero em GitHub Actions, com fixtures SQL mínimas e descarte ao fim do job.
- Testes de lógica SQL, transações e concorrência podem usar esse PostgreSQL, desde que dependências necessárias sejam modeladas explicitamente.
- Testes que dependam especificamente de Supabase Auth, RLS/PostgREST, Realtime, Storage ou extensões ainda não reproduzidas devem permanecer como **bloqueados/não verificados**, nunca ser simulados como se fossem E2E Supabase.
- Nenhum teste mutável será executado na base conectada, em campanhas reais ou em TESTE 2.
- A prioridade do primeiro harness é a regressão P1: movimento direto sem pré-check, pending global, janela TOCTOU e lock order. A fixture deve provar atomicidade e concorrência antes de qualquer patch no banco real.


### Complemento obrigatório da regressão P1 — fila global e commit autorizado

6. Com pending A ativo, chamar o RPC direto para mover token B em um destino sem qualquer ameaça.
   - Esperado: rejeição; a verificação da pending global ocorre antes do retorno antecipado de “sem AOO”.
7. Finalizar a pending A pelo fluxo normal e confirmar que o trigger de preview valida o movimento sem criar uma nova pending nem persistir duas vezes.
   - Esperado: somente o commit associado ao pending ID correspondente pode prosseguir; a exceção sentinela do preview continua revertendo a validação simulada.
8. Tentar usar um pending ID de outra campanha, de outro token, com destino diferente ou status terminal.
   - Esperado: rejeição sem mover token nem consumir deslocamento.


### Regressão P1 adicional — mutação genérica da cena durante combate

9. Em fixture descartável com combate ativo, chamar diretamente `salvar_cena_cba` enviando coordenadas diferentes para um token existente.
   - Esperado: rejeição ou preservação das coordenadas originais; nunca permitir teleporte por publicação genérica.
10. Repetir alterando a posição de um token ameaçador enquanto outro token possui pending AOO ativo.
   - Esperado: rejeição integral e nenhuma alteração de `cba_data`.
11. Enviar um token novo sobreposto a token existente via `salvar_cena_cba`.
   - Esperado: rejeição por validação server-side de footprint/ocupação.
12. Confirmar que os usos legítimos de `salvar_cena_cba` durante combate continuam funcionando sem alterar coordenadas: adicionar NPC em célula livre, persistir bônus de iniciativa e enriquecer metadados de monstro.
13. Confirmar que publicação de fundo/grade fora de combate continua funcionando e que a nova separação de RPCs não perde tokens nem metadados.


14. Reproduzir lost update: capturar snapshot da cena, aplicar dano/movimento por RPC em outra sessão, depois salvar o snapshot antigo por `salvar_cena_cba`.
   - Esperado após correção: conflito explícito ou merge server-side que preserve o estado mais recente; PV e coordenadas não podem regredir.
15. Repetir com dois clientes GM e com atualização simultânea de metadados do mapa.
   - Esperado: nenhuma atualização não relacionada deve substituir estado de token atualizado por RPC de combate.
