# Vínculo RPG — Validação de personagem (bloqueada)

> Pauta de validação recuperada do histórico. **Não é a tarefa ativa da Fase 1** e permanece bloqueada até confirmação inequívoca do personagem-alvo. Não substitui o [Plano Mestre da Mesa](../PLANO_MESTRE_MESA.md), o [Roadmap](ROADMAP.md) ou o [Registro de Auditorias](AUDIT_REGISTER.md).

## Estado

**Bloqueado — identidade de teste não confirmada.** A prioridade atual do projeto é concluir a Fase 1 (arquitetura e contratos), conforme PROJECT_STATE.md e ROADMAP.md. Esta pauta será retomada após confirmação do alvo e disponibilidade de fixture descartável.

## Objetivo quando desbloqueado

Retomar a validação de integração do personagem **Thorgar, Anão Bárbaro**, no contexto da campanha de teste **TESTE 2**, sem alterar o estado persistido dessa campanha.

A prioridade foi recuperada do histórico de continuidade das sessões. A identificação do personagem, o estado atual da campanha e cada pendência abaixo ainda precisam ser confirmados por leitura antes de qualquer teste. Não tratar observações históricas como estado atual do banco.

## Restrições de segurança dos dados

- Não alterar PV, PM, atributos, nível, XP, inventário, equipamento, token, posição, condições, campanha ou progresso de TESTE 2.
- Não equipar/des equipar itens, ativar Fúria ou executar ataques no personagem real para fins de teste.
- Não executar RPC mutável contra a campanha real.
- Preferir inspeção somente de leitura e testes em fixture/campanha descartável.
- Se uma validação exigir mutação, reproduzir o estado relevante em ambiente isolado; se isso não for possível, registrar como bloqueada e pedir autorização específica.
- Registrar evidência por arquivo, função/RPC, migration, consulta somente de leitura ou teste reproduzível.

## Pré-verificação obrigatória

1. Localizar Thorgar e confirmar a ficha, raça, classe, nível, campanha e token por consultas somente de leitura.
2. Inspecionar o estado real de equipamento; não presumir que Armadura de Couro esteja equipada.
3. Confirmar se o Machado Grande está no inventário e se está equipado, sem modificar a ficha.
4. Registrar os valores atuais de CA, PV, atributos, proficiências e recursos apenas como baseline de leitura.
5. Verificar os commits/migrations existentes para evitar repetir correções já feitas.
6. Se o personagem ou a campanha não puderem ser identificados sem ambiguidade, interromper a validação específica e registrar o bloqueio.

## Casos de validação — ordem sugerida

### A. Fonte canônica e sincronização da ficha/token
- Identificar a fonte canônica de CA, PV, atributos e modificadores.
- Confirmar se os valores exibidos na ficha e no token derivam da mesma fonte.
- Distinguir CA base, armadura equipada, escudo, Destreza, tamanho e modificadores temporários.
- Não afirmar que a CA esperada é 12 sem confirmar que a armadura correspondente está equipada e que não há outros modificadores.

### B. Machado Grande e proficiência
- Confirmar que o item é classificado como arma marcial de duas mãos e que o Bárbaro é proficiente.
- Verificar mão/empunhadura, alcance e propriedades relevantes.
- Validar bônus de ataque e dano em fixture isolada.
- Conferir dano base 1d12 e modificador de Força de 1,5× para arma de duas mãos, respeitando arredondamento e regras SRD.
- Conferir crítico 20/x3.
- Validar fluxo de equipar/desquipar em fixture, incluindo atualização de ficha e token.

### C. Ataque Poderoso
- Verificar pré-requisitos e disponibilidade do talento.
- Validar conversão de penalidade no ataque em bônus de dano.
- Para arma de duas mãos, conferir proporção de 2 para 1.
- Testar limites, valores negativos, duração e interação com ataques iterativos sem criar ciclos ou duplicar aplicação.

### D. Fúria
- Validar modificadores temporários de atributos e seus derivados.
- Validar PV temporários, duração, usos diários e encerramento.
- Validar fadiga após o término conforme a regra aplicável.
- Confirmar que ficha, token, log e estado persistido permanecem coerentes.
- Testar ativação, expiração, interrupção e repetição em fixture isolada.

### E. Traços raciais anões
- Bônus de ataque contra orcs e goblinoides.
- Bônus de CA contra gigantes.
- Bônus em salvamentos contra venenos e magias, conforme regra aplicável.
- Estabilidade contra encontrão e rasteira enquanto apoiado no chão.
- Visão no escuro.
- Stonecunning e bônus de perícias aplicáveis.
- Verificar aplicação mecânica, não apenas descrição textual na ficha.

### F. Regras de Bárbaro e interações
- Analfabetismo e aquisição de leitura, incluindo custo de pontos de perícia e idiomas adicionais por Inteligência quando aplicável.
- Esquiva Sobrenatural e Esquiva Sobrenatural Aprimorada.
- Flanqueamento, Ataque Furtivo e Ataques de Oportunidade.
- Leitura/ativação de pergaminhos e requisitos de leitura/conjuração.
- Registrar separadamente o que é regra automática, ação assistida pelo Mestre ou ainda não implementado.

## Evidência e aceite

Cada caso deve receber um dos estados: **passou**, **falhou**, **bloqueado**, **não aplicável** ou **não verificado**.

Um caso só passa quando:
- os dados de entrada e a regra aplicada estão identificados;
- o resultado é reproduzível;
- a autorização e a persistência foram verificadas quando pertinentes;
- ficha, token, log e demais consumidores relevantes permanecem sincronizados;
- a validação não alterou TESTE 2.

A existência de uma RPC, botão ou campo na interface não é evidência suficiente de funcionamento.

## Pré-verificação somente de leitura — 2026-11-08

Consulta ao projeto Supabase conectado, sem escrita:

- A campanha chamada **TESTE 2** foi encontrada com ID interno 131.
- O personagem retornado nessa campanha é **Thunga Mestre** (ID interno 682), Anão Bárbaro de nível 1; PV 15/15; atributos registrados: FOR 14, DES 14, CON 16, INT 10, SAB 11 e CAR 8.
- A busca por nome não encontrou personagem chamado **Thorgar**. A ficha encontrada não contém esse nome no campo de identidade consultado. Portanto, não está confirmado que Thunga Mestre seja o personagem anteriormente chamado Thorgar.
- Não há token publicado para o personagem 682 na campanha TESTE 2.
- A Armadura de Couro consta como equipada; o Machado Grande consta no inventário, mas não equipado.
- A ficha registra o talento Iniciativa Aprimorada e identidade com alfabetizado=false.
- O inventário inicial registrado inclui Machado Grande e Armadura de Couro, entre outros itens.

**Consequência:** a pauta histórica “Thorgar” não pode ser aplicada automaticamente a Thunga Mestre. A identidade precisa ser reconciliada antes de qualquer teste funcional. A antiga expectativa de CA 12 também não foi confirmada: como a ficha tem DES 14 e a Armadura de Couro está equipada, o cálculo esperado precisa ser refeito a partir da fonte canônica e dos modificadores reais; não reutilizar CA 12 como valor de referência.

Nenhum personagem, ficha, campanha, token, inventário, equipamento ou progresso foi alterado nesta consulta.

## Próxima ação concreta

Resolver a divergência de identidade: confirmar se **Thunga Mestre** é o personagem de TESTE 2 que deve receber a continuidade anteriormente chamada “Thorgar”, ou se Thorgar é outro personagem/campanha. Até essa confirmação, não executar testes funcionais sobre o personagem real. Em paralelo, é seguro inspecionar estaticamente os commits e RPCs relevantes e preparar fixtures isoladas.

## Histórico

- 2026-11-08: item criado a partir da continuidade das sessões. Os casos são uma pauta de validação recuperada, não resultados de testes executados nesta data.
- 2026-11-08: pré-verificação somente de leitura encontrou Thunga Mestre em TESTE 2, não Thorgar; Armadura de Couro equipada, Machado Grande não equipado e ausência de token. Nenhum dado foi modificado.


## Reconciliação adicional de identidade — 2026-11-08

Consulta somente de leitura confirmou dois registros distintos:
- **Thorgar (ID 681):** campaign_id NULL; pertence ao Mestre da campanha 131 e está vinculado a um token do tipo NPC nessa campanha (sourceCharacterId=681). A Armadura de Couro e os demais itens consultados estão com equipado=false. A sobrecarga de CA para NPC vinculado retornou CA 10, coerente com esse estado.
- **Thunga Mestre (ID 682):** campaign_id=131; não possui token vinculado em cba_data; Armadura de Couro está equipada e Machado Grande não está equipado.

Portanto, o teste de CA 10 executado para Thorgar (681) **não valida nem invalida** a CA de Thunga Mestre (682). São registros diferentes; a identidade do personagem que deve ser alvo da pauta histórica precisa ser confirmada antes de qualquer teste funcional. Nenhum dado foi alterado.


## Atualização de prioridade — 2026-11-09
Esta pauta deixou de ser a tarefa ativa imediata. O diagnóstico identificou Thorgar (681) e Thunga Mestre (682) como registros distintos; não inferir que um substitui o outro. A Fase 1 — arquitetura e contratos — tem precedência até fechar os contratos e preparar testes isolados. Nenhum dado de jogo foi alterado.


## Trabalho ativo — reconciliação de migrations e baseline remoto — 2026-11-09

**Prioridade atual:** tornar o estado remoto do Supabase reproduzível antes de qualquer refatoração funcional ou teste mutável.

### Concluído nesta etapa
- Comparação exata de versões local/remota: 681 arquivos locais, 966 registros remotos, 640 versões coincidentes, 326 registros remotos sem versão local, 41 arquivos locais sem versão remota; 41 registros remotos compartilham nomes com arquivos locais (39 nomes únicos) e dois nomes remotos estão duplicados.
- Snapshot descritivo remoto criado em [REMOTE_SCHEMA_SNAPSHOT.md](REMOTE_SCHEMA_SNAPSHOT.md): 83 relações, 229 índices, 378 constraints, 114 policies, 14 triggers, 327 funções/procedures com fingerprints e ACLs/owners/default privileges.
- RLS desabilitado em priv.throttle e priv.srd_aoo_reaction_ledger; sem privilégios diretos para anon/authenticated, mas com uso por funções SECURITY DEFINER.
- Default privileges de authenticated em priv são permissivos para futuras tabelas, sequences e funções; mudança proposta, não aplicada.
- Ausência de supabase/config.toml e de branch Supabase de desenvolvimento; apenas branch main está disponível. Nenhum ambiente descartável foi criado.
- Documentação atualizada em PROJECT_STATE, ROADMAP, ARCHITECTURE, AUDIT_REGISTER e snapshot.

### Próximas ações obrigatórias
1. Exportar e revisar os corpos SQL das funções críticas em lotes, começando por SECURITY DEFINER, wrappers INVOKER e rotinas com efeitos em combate/progressão.
2. Comparar constraints, índices, policies, grants, triggers e funções com as migrations locais, classificando cada divergência por objeto e efeito.
3. Confirmar no Dashboard a lista de Exposed schemas (especialmente priv/private).
4. Preparar estratégia de ambiente descartável; não criar branch Supabase sem conhecer/cumprir eventual custo.
5. Somente após a reconciliação, gerar baseline reproduzível e CI de drift; não resetar, deployar ou squashear o histórico remoto.

**Restrições:** somente leitura nesta fase; não alterar dados de jogo, ACLs, policies, funções, schema ou comportamento de produção. Não executar testes mutáveis em TESTE 2; Thorgar (681) e Thunga Mestre (682) são registros distintos.


Inventário completo dos conjuntos divergentes: [MIGRATION_RECONCILIATION.md](MIGRATION_RECONCILIATION.md). Snapshot estrutural atual: [REMOTE_SCHEMA_SNAPSHOT.md](REMOTE_SCHEMA_SNAPSHOT.md).


## Atualização de execução — 2026-11-09

- Exportadas as definições remotas de 37 funções AOO e 41 funções de movimento/ações/iniciativa/turnos.
- No conjunto AOO: 51 migrations remotas sem arquivo local de mesmo nome; 0 funções com EXECUTE para anon; wrappers públicos e helpers internos usados por INVOKER mantêm EXECUTE para authenticated conforme ACL atual.
- No conjunto movimento/turnos: 41 funções exportadas; 0 com EXECUTE para anon e 28 com EXECUTE para authenticated.
- A análise de locks confirmou o risco de inversão AOO: cancelamento bloqueia movimento pendente e atualiza ataques; resolução/dano bloqueia ataque e depois movimento pendente. Não reproduzido.
- Próxima etapa: matriz global de locks e chamadas transitivas; não alterar funções nem dados até existir ambiente descartável.


### Risco adicional de inversão AOO
A análise de `priv.srd_encerrar_reacao_aoo_pendente_impl` confirmou que o cancelamento explícito de ataque também adquire pending → attack, enquanto ocultação/resolução/dano adquire attack → pending. O risco de deadlock inclui agora cancelamento de reação × ocultação/resolução/dano, além do cancelamento total do movimento.


## Achado P1 — movimento pode contornar o pré-check de AOO — 2026-11-09

**Evidência estática confirmada no estado remoto:**
1. `mesa.html` chama `srd_solicitar_movimento_com_aoo_srd` antes de mover o token. Se o RPC retorna `pending=false`, o frontend continua e chama `mover_token_player_cba` (jogador) ou `mover_token_gm_cba_srd` (Mestre).
2. `public.mover_token_player_cba` é um wrapper SECURITY INVOKER com EXECUTE para authenticated e chama `priv.mover_token_player_cba_impl`.
3. A implementação privada valida autenticação, propriedade, campanha, turno, ação, deslocamento, ocupação e condições, mas **não chama** `srd_detectar_saida_alcance_ameacado_srd` nem o fluxo AOO.
4. `public.mover_token_gm_cba_srd` também é wrapper INVOKER autenticado; a implementação GM valida papel/turno/deslocamento, mas não integra o detector AOO.
5. O trigger `trg_srd_guard_pending_aoo_movement` só bloqueia alteração/removal do token que já tenha um movimento pendente ativo; ele não detecta uma ameaça nova nem protege o caminho sem pending.

**Impacto:** um cliente autenticado pode chamar diretamente `mover_token_player_cba` e mover seu personagem durante o combate sem executar o pré-check AOO. Também existe uma janela TOCTOU entre o RPC de pré-checagem (que bloqueia a campanha apenas durante sua transação) e o RPC que persiste o movimento: outra alteração de token pode ocorrer entre ambos, invalidando a detecção original. O movimento ainda respeita outras validações de servidor, mas o AOO pode ser ignorado.

**Classificação:** P1 — integridade das regras/autoridade do servidor. Confirmado por leitura de frontend, ACL, wrapper, implementação e trigger; não foi executado um exploit nem alterado estado de jogo.

**Correção arquitetural recomendada:** tornar o RPC de persistência de movimento a autoridade única: dentro da mesma transação/lock de campanha, validar identidade/turno/ação, recalcular ameaças, criar o registro pending e retornar sem mover quando houver AOO; somente mover e consumir deslocamento quando não houver ameaça. Adaptar o frontend para um único resultado (`pending` ou `moved`) e retirar a confiança no pré-check separado. Aplicar ao caminho de jogador e, após confirmar a política de autoridade do Mestre, ao caminho GM. Não aplicar patch isolado sem fixture e teste de regressão.


### Próximo teste isolado obrigatório — bypass AOO por RPC de movimento
Antes de testar deadlocks, preparar o teste de regressão da seção “Regressão P1 — movimento direto não pode contornar AOO” em TEST_STRATEGY.md. O teste deve invocar o RPC de movimento diretamente, sem pré-check, e cobrir a janela TOCTOU entre pré-check e persistência. Não executar em produção nem em TESTE 2.


### Extensão do bypass — fila pending pode ser contornada por outro token
Consulta direta aos corpos de `priv.mover_token_player_cba_impl` e `priv.mover_token_gm_cba_srd_impl` confirmou que ambos não referenciam `priv.srd_aoo_pending_movements`, não chamam o detector AOO e não chamam o pré-check. O trigger `priv.srd_guard_pending_aoo_movement` busca um pending ativo, mas só impede alteração/removal do token que é o próprio `mover_token_id`; ele não bloqueia alterações de outros tokens. Assim, uma chamada direta ao RPC de movimento de outro token pode contornar também a serialização global que `srd_solicitar_movimento_com_aoo_srd` tenta impor (a função de pré-check rejeita qualquer pending ativo). Isso pode alterar a posição de ameaças enquanto uma reação está sendo resolvida.

**Impacto adicional:** quebra da invariável “uma única movimentação pendente por campanha” e mutação da cena durante a resolução AOO, além do bypass do detector e da janela TOCTOU. Mantida classificação P1.


### Exemplo concreto de drift validado
As migrations locais de economia de movimento alteram corpos de funções públicas, mas o remoto atual tem wrappers INVOKER que delegam a implementações priv.*. As migrations remotas que fizeram essa extração para priv não existem localmente (20261108194444, 20261108195245, 20261108214901). Este caso está documentado em MIGRATION_RECONCILIATION.md e impede considerar o conjunto local reproduzível.
