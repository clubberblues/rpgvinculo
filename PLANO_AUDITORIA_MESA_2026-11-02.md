# Auditoria da mesa — 2026-11-02

Continuação da verificação solicitada para o redesign do Mestre e as permissões dos tokens.

## Corrigido nesta etapa

- Removido de `mesa.html` o atalho que permitia ao Mestre clicar no cartão de personagem de jogador e abrir ajuste dos PV. Agora esse ajuste é restrito ao proprietário da ficha.
- O Mestre ainda pode mover token de jogador somente no turno ativo, pela opção contextual dedicada. A ação autenticada de movimento verifica papel GM, turno, posição e deslocamento.
- O jogador tem ação contextual de ajuste dos próprios PV, além de ataque, magia e inventário. A RPC `alterar_pv_personagem` verifica autenticação, campanha e propriedade.
- Dano aplicado pelo Mestre a ficha de jogador usa `aplicar_dano_token_gm_personagem_srd`, que exige GM autenticado, combate e token atacante no turno ativo. NPC/monstros usam a resolução de PV de token.
- Confirmei os privilégios: as duas RPCs de PV não são executáveis por `anon`; permanecem disponíveis a `authenticated`.
- Confirmado no corpo da função `criar_personagem_srd`: PV de nível 1 é automaticamente `max(1, dado_vida + modificador de Constituição)` e é gravado como PV atual e máximo. Não depende de rolagem do jogador.
- O ambiente não tem branch de desenvolvimento Supabase e a campanha 17 é dado de produção; mantive-a sem escritas. Seu estado consultado permaneceu EXPLORAÇÃO, iniciativa inativa e fila vazia.

## Revisão visual e operacional

A mesa remota carregou em desktop com chat lateral, CBA central, comandos de Mestre agrupados, tokens e faixa de combatentes. O layout responsivo existe no CSS. A viewport do navegador disponível está em desktop; a API de automação não oferece redimensionamento de viewport, então a inspeção visual real em celular e a conferência com sessão autenticada de jogador ficaram pendentes. Nenhum modal destrutivo ou ação que alterasse a campanha foi confirmado.

Foi observada uma divergência momentânea entre o painel visível e a leitura do banco; após recarregar a mesa, a interface mostrou EXPLORAÇÃO, coerente com o banco. A atualização em tempo real após troca de estado merece verificação com duas sessões simultâneas.

## Catálogo e avisos

- Há 131 registros em `srd_class_level_features`, todos marcados `verified_srd`; isso atesta catálogo e fonte, não execução automatizada por cada classe. Auditoria completa de controles/efeitos por classe e nível segue aberta.
- Advisor de segurança: 80 avisos de funções SECURITY DEFINER executáveis por `authenticated`, mais o aviso de proteção contra senhas vazadas desativada. Esta opção foi descartada pelo proprietário devido ao plano Free. RPCs da aplicação têm privilégios autenticados e validações próprias; os dois caminhos de PV acima foram inspecionados.
- Advisor de performance: 90 índices sem uso observado e 4 pares de índices duplicados. Os pares duplicados precisam de comparação com índices/constraints antes da remoção; não removi índices em produção sem essa checagem.

## Ainda requer ambiente apropriado

1. Campanha descartável e duas sessões (Mestre e jogador) para executar sem risco iniciativa, movimento, ataque, dano, magia, inventário, XP, alternância de combate e recarga/Realtime.
2. Sessão autenticada de jogador para validar visualmente seu menu e seus controles.
3. Inspeção em viewport móvel com ferramenta de browser que permita emular/redimensionar.
4. Mapeamento das 131 características verificadas para interface, regras, RPCs, usos e limites por classe/nível, e implementação dos controles ausentes.
5. Comparação estrutural dos quatro pares de índices redundantes e dos 90 índices informativos antes de decidir por qualquer remoção.

A etapa não declara cobertura total ou aceite ponta a ponta. A campanha 17 não foi usada como ambiente de teste.


## Continuação — ataque mágico e avisos (2026-11-02)

- Implementado e publicado o fluxo de Míssil Mágico: acerto automático, rolagem de dano pelo dado, seleção de alvo preservada ao trocar círculo/espaço e aplicação transacional que valida propriedade da ficha, magia preparada, turno/ação e espaços. A RPC é apenas para `authenticated`; magia ofensiva sem resolvedor completo fica bloqueada com aviso e não consome recurso. A resistência à magia ainda fica indicada como pendência de regra.
- Migração `20261102173802_srd35_magic_missile_resolution` confirmada aplicada em produção e versionada no GitHub.
- A faixa de iniciativa foi reorganizada em uma linha própria do grid da mesa; ainda depende de confirmação visual após o cache do GitHub Pages atualizar.
- Removidos os quatro índices duplicados depois de conferir definições idênticas e ausência de vínculo a constraints. Migração `20261102194500_deduplicate_fk_indexes` aplicada; advisor passou de 4 pares duplicados para zero. Restam 88 avisos informativos de índice não usado; não removidos por não serem prova de redundância.
- Auditoria das 81 funções SECURITY DEFINER disponíveis a `authenticated`: todas têm verificação direta de autenticação/autorização ou delegam a helper guardado. Em particular `set_turn` delega a `combat_set_turn`, que valida GM com `priv.need_gm`. Nenhuma das funções analisadas é executável por `anon`. O alerta do advisor é informativo sobre o privilégio; não significa, por si, ausência de autorização interna.
- Proteção de senha vazada permanece desativada por decisão do proprietário (plano Free); não é requisito bloqueante desta entrega.

## Pendências que ainda dependem de contexto/acesso

1. Confirmar o ataque mágico numa sessão real de jogador e a atualização visual do estado da mesa; não usei a campanha 17 durante combate.
2. Inspecionar o layout depois da publicação/expiração do cache e em viewport móvel. A janela de browser disponível não oferece redimensionamento/emulação e a sessão aberta é do Mestre.
3. Executar E2E isolado com duas contas. O projeto não possui branch Supabase; criar uma branch pode gerar cobrança, então não foi criada. Também não há sessão secundária de jogador autenticada disponível.
4. Mapear e implementar o comportamento de todas as 131 características de classe/nível. O catálogo está marcado como verificado quanto à fonte, mas isso não equivale a automação executável. O escopo excede a correção do fluxo de magia e precisa ser feito por grupos de regras, com casos E2E.
5. Resolver aplicação de resistência à magia e demais efeitos de ataque para magias além de Míssil Mágico. Elas ficam bloqueadas com segurança, sem gastar recursos.

A proteção contra senhas vazadas foi formalmente descartada para este projeto Free. Os 88 avisos de índice sem uso são somente observações de estatística atual e permanecem para revisão após carga real.


### Resultado da inspeção visual (17:55 UTC)

- A primeira captura confirmou que a iniciativa estava fora do layout e cortava os cartões. O painel foi movido para o rodapé e a faixa foi compactada.
- A nova captura mostrou o painel encaixado, mas os cartões ainda parcialmente cortados. A correção seguinte, commit `f82f52b22fe256b1732ce4c3546581f15a6dc1cf`, aumentou e reorganizou a faixa do rodapé. No momento do registro, o workflow do GitHub Pages ainda estava em execução; não declarar aceite visual até recapturar após o deploy.
- Criação de branch E2E tentou-se e foi recusada pelo Supabase: branching requer Pro ou superior. Não foram executadas ações de jogo na campanha 17 em combate.
- A migração para remover duplicatas está aplicada e versionada; advisor agora indica zero pares duplicados e 88 índices não utilizados (informativo).
- As 81 funções SECURITY DEFINER autenticadas foram filtradas por evidência de auth/guarda; todas têm checagem direta ou delegam a helper de GM/autorização. A única sem marcador direto no corpo é `set_turn`, que delega a `combat_set_turn`, o qual exige GM via `priv.need_gm`. Nenhuma executável por `anon`.


### Confirmação após deploy (2026-11-02)

- Deploy do GitHub Pages do commit `4d8dde42efc8b7f7fdfab9211964ecf89d84c8b5` concluiu com sucesso.
- Captura desktop 1280×720 confirmou o painel de iniciativa e os três cartões (personagem, NPC e monstro) dentro do rodapé, sem corte; a faixa de combate foi ajustada para três colunas no desktop e rolagem horizontal em viewport estreita.
- A verificação visual do layout está concluída nesta tela do Mestre. O fluxo mágico ainda não foi executado em campanha porque a sessão atual está em combate e a conta Free não permite branch de teste.
- Permanecem pendentes: teste transacional real de Míssil Mágico em personagem autenticado descartável, visualização como jogador com sessão correspondente, cobertura E2E/Realtime em duas sessões e implementação dos resolvers para outras magias ofensivas e 131 características de classe.


## Retomada após a conversa — correção crítica da ficha (2026-11-02)

- Ao reabrir o código publicado, a validação sintática do script inline de `ficha.html` falhou. Foram identificadas duas causas no bloco do Grimório: uma sequência literal `\\n` antes da declaração de `spellsHtml`, e um trecho duplicado/incompleto do handler de descanso longo que deixava um `try` sem fechamento válido.
- Corrigida a sequência literal e reconstruído o handler de descanso longo como callback assíncrono completo, preservando a RPC existente e a atualização da ficha após o descanso.
- Validação local do conteúdo remoto atual: `new Function(scriptInline)` concluiu sem erro de sintaxe.
- Commits: `0566300` (remoção da sequência literal), `10f273e` (remoção do trecho duplicado, etapa intermediária), `a79d2d2` (reconstrução correta do handler). O commit final é o estado válido; os commits intermediários foram corrigidos em sequência.
- Ainda não houve inspeção de navegador nem teste autenticado da ficha após a correção. Portanto, a causa de parsing está corrigida no código, mas o carregamento funcional precisa ser confirmado no site publicado.
- Próxima prioridade: validar a ficha no browser e verificar requests/erros de rede; depois implementar o assistente de avanço de nível de forma transacional, incluindo dado de vida, PV, perícias, talentos e atributos, sem atualizar nível nem consumir XP antes de todas as escolhas serem válidas.


## Execução imediata das pendências — 2026-11-02 (continuação)

### Alterações aplicadas

- `ficha.html`: implementado painel de avanço de nível, integrado à ficha SRD. Apresenta rolagem do dado de vida, distribuição de graduações com custos e limites, escolha de talentos gerais e adicionais de Guerreiro/Mago/Monge, aumento de atributo nos níveis múltiplos de 4 e características catalogadas do próximo nível. A aplicação atualiza a ficha somente após a RPC confirmar a operação.
- Nova RPC `concluir_avanco_nivel_personagem_srd`, versionada em `supabase/migrations/20261102210000_srd35_level_up_assistant.sql` e aplicada. Usa locks da ficha/personagem, valida propriedade e campanha, XP/níveis pendentes, dado de vida, PV, perícias, limites e pré-requisitos de talentos. A alteração de nível, PV, atributos, perícias e talentos ocorre na mesma transação. Execução concedida a `authenticated` e negada a `anon`.
- Migration `20261102213000_srd35_level_up_ability_retroactivity.sql` aplicada: aumento de INT considera pontos de perícia retroativos e aumento de CON considera os PV retroativos dos dados de vida anteriores.
- Migration `20261102214000_srd35_level_up_bab_progression_fix.sql` aplicada: pré-requisito de BBA usa `bab_progression` (`good` / `average` / `poor`). O campo legado `bab_bom` estava marcado como verdadeiro para todas as classes e não é mais usado no cálculo.
- `mesa.html`: adicionada virada visual dos cards de personagens e tokens. O verso do personagem mostra atributos, quantidade de perícias e talentos; o verso de NPC/monstro mostra salvamentos e detalhes disponíveis. Os controles originais do Mestre/token e o link para a ficha foram preservados.
- `mesa.html`: magias sem tipo de efeito explícito passam a ser bloqueadas como `resolucao_manual`. A interface não as classifica mais automaticamente como utilitárias, evitando consumo inadvertido de ação/espaço sem efeito mecânico definido. Magias de cura e o resolver especializado de Míssil Mágico mantêm os fluxos já existentes.

### Commits desta execução

- `1c39dee0f01e77b92ff4b1ae0e4f995ca02e4502` — migration de avanço transacional.
- `2196e7797ec4c50e357304e448787d3de242cf6d` — retroatividade de CON/INT.
- `1c7623216bd3e4bd03a0d1d9713fb84c035dc39f` — correção de progressão de BBA.
- `7fb0d1650cd3bdc559c747cefc141c79f55189ea` e `7633f44722b3ba14dd61ae64a363251c838a51ef` — painel e refinamentos de avanço na ficha.
- `6b8a00792ce5b973c7482875449ff4b8476428e4` — cards com frente/verso.
- `957de6ec99e189d81fc74ee8b5631976d2926d96` — bloqueio seguro de magias sem efeito tipado.

### Evidências verificadas nesta execução

- Script inline de `ficha.html`: compilação por `new Function`, sem erro.
- Script inline de `mesa.html`: compilação por `new Function`, sem erro.
- Supabase: assinatura da RPC existe e a definição SQL foi lida após as migrations.
- Supabase: `has_function_privilege` confirmou `anon_execute=false` e `authenticated_execute=true` para a RPC de avanço.
- Supabase: conferência da definição confirmou uso de `bab_progression` e ausência do atalho `bab_bom IS TRUE`.
- Supabase: a relação `srd_spell_effects` ainda tem 607 linhas `manual/manual_only`. Portanto, o catálogo fonte-verificado não é equivalente a resolver efeitos automaticamente.

### Pendências ainda abertas — não declarar concluídas

1. A correção de sintaxe da ficha está confirmada, mas o carregamento funcional com sessão autenticada, chamadas de rede e renderização real não foi testado em navegador nesta execução.
2. O assistente de nível ainda precisa de E2E real em personagem de teste: cenários de PV mínimo/máximo, incremento de CON/INT, classes e talentos com pré-requisitos, múltiplos níveis pendentes, rejeição de escolhas inválidas e reabertura da ficha. A seleção/ganho de magias conhecidas ou adição de magias ao grimório em progressão de Mago/Feiticeiro/Bardo não está integrada a este fluxo.
3. As 131 entradas de características de classe continuam com `engine_status=needs_implementation`; o painel as exibe, mas não aplica automaticamente habilidades como Fúria, Ataque Furtivo, Evasão, Música de Bardo, Forma Selvagem, Companheiro Animal, Usos de habilidade e outras progressões.
4. A automação genérica de magia continua incompleta. Os 607 efeitos seguem manuais; Míssil Mágico e cura são casos especializados existentes. Resistência à magia, salvamentos, ataque de toque, dano tipado, condições, buffs/debuffs, duração, concentração e efeitos em área ainda exigem resolvers e cobertura por casos.
5. Os testes ponta a ponta simultâneos como Mestre e jogador não foram executados: não há sessão secundária autenticada nem ambiente Supabase isolado disponível no plano atual. A campanha real 17 não foi usada nem alterada.
6. A inspeção visual em viewport móvel não foi executada: esta execução não dispõe de navegador com emulação/redimensionamento de viewport. O HTML/CSS foi alterado e validado estaticamente, mas o flip-card precisa de conferência visual após publicação em desktop e celular.
7. Não foi possível confirmar o deploy publicado nem o comportamento após a atualização de cache do site nesta execução. Os commits estão no `main`; status de sintaxe não substitui validação de publicação.

Nenhuma ficha, personagem, campanha, token, log de jogo ou estado de combate real foi alterado nesta execução. As alterações de banco limitaram-se a definição de funções e permissões via migrations.


## Retomada executada — 2026-11-02 (23:46 UTC)

### Correções e hardening aplicados

- `ficha.html`: corrigido um erro de execução no fluxo de criação SRD. O handler de validação de talentos referenciava `warns` sem declaração; a variável causava `ReferenceError` ao validar cada talento, impedindo concluir a criação da ficha. A validação de parâmetro agora mostra a mensagem e interrompe o fluxo diretamente. Commit: `37620ccd100f2f36b45ceb584af4629ea7ffad62`.
- Supabase: removidos todos os privilégios do papel `anon` em 11 tabelas privadas de estado de jogo (`campaign_log`, `character_talents`, `combat_state`, `monster_instances`, `scenes`, `srd_cba_token_equipment`, `srd_character_equipment`, `srd_character_sheets`, `srd_starting_packages`, `tokens` e `vinculo_character_notes`). Políticas e privilégios de `authenticated` foram preservados; `profiles` foi excluída porque possui políticas públicas explícitas.
- Supabase: removidos privilégios padrão de `anon` para tabelas, sequências e funções novas no schema `public`, exigindo concessão explícita quando um novo catálogo realmente precisar ser público.
- Migrations aplicadas e versionadas: `20261102234449_revoke_anon_private_table_grants`, `20261102234522_revoke_anon_default_privileges_public` e `20261102234531_revoke_all_anon_default_table_sequence_privileges`.

### Verificações após as alterações

- `ficha.html` e `mesa.html`: os scripts inline passaram novamente na compilação sintática (`new Function`), sem erros.
- Supabase: zero privilégios de SELECT/INSERT/UPDATE/DELETE de `anon` nas 11 tabelas privadas; zero privilégios padrão residuais de `anon` para tabelas/sequências futuras; RPC de avanço de nível continua sem EXECUTE para `anon`.
- Supabase: leitura de `authenticated` preservada nas tabelas privadas. O advisor de segurança ainda reporta 84 funções SECURITY DEFINER executáveis por `authenticated` e proteção contra senha vazada desativada (plano Free); advisor de performance reporta 84 índices sem uso observado. Não removi índices sem evidência de redundância nem alterei guards das RPCs.
- GitHub Pages: os workflows intermediários foram cancelados automaticamente por commits mais recentes; o deploy do commit `0e5e0acf76ff4af3ec775bb248e6f9149f5f16ed` estava em fila no momento da auditoria. Confirmar o resultado final antes de considerar a publicação concluída.

### Pendências que permanecem abertas

1. Reproduzir o carregamento da ficha em navegador com sessão autenticada e capturar requests/erros. Não há sessão de navegador autenticada disponível nesta execução; os logs recentes consultados não continham erros PostgREST que permitissem apontar a causa do spinner.
2. Executar E2E real em campanha descartável com duas contas (Mestre e jogador), incluindo avanço de nível, magias, combate, permissões e Realtime. A campanha 17 permanece intocada e não foi usada para testes.
3. Integrar a aquisição de magias conhecidas/grimório no avanço de nível de Mago, Feiticeiro e Bardo de forma transacional.
4. Implementar os efeitos mecânicos das 131 características de classe; todas continuam com `engine_status=needs_implementation`.
5. Implementar resolvers genéricos de magia e classificar/validar os 607 efeitos; todos continuam em `manual_only` no catálogo de efeitos, embora existam fluxos especializados para cura e Míssil Mágico.
6. Validar visualmente a ficha e os cards em viewport móvel e validar sincronização Realtime em duas sessões. A compilação sintática não substitui esses testes.

Nenhum registro de campanha, personagem, token, log ou combate foi alterado. As mudanças no banco foram apenas de privilégios padrão e privilégios do papel `anon`.


### Sincronização da trilha de classe no avanço de nível — 2026-11-02 (23:49 UTC)

- Corrigida a RPC `concluir_avanco_nivel_personagem_srd` para sincronizar `srd_character_class_levels` na mesma transação do avanço: atualiza o nível da classe, mantém o nível de aquisição original, registra PV acumulados e grava o custo total de pontos de perícia por perícia. Isso corrige uma lacuna: a ficha avançava, mas a trilha normalizada permanecia no nível anterior.
- Teste transacional de fumaça executado com campanha/personagem descartáveis dentro de `BEGIN … ROLLBACK`: Bárbaro Humano nível 1, XP 1.000, rolagem de vida 6. A RPC retornou sem erro; nível da ficha e trilha passaram para 2, níveis pendentes foram para 0 e PV máximo passou de 12 para 18. O teste verificou também que nenhum registro temporário de campanha/personagem permaneceu após o rollback.
- Migration aplicada e versionada: `20261102234916_srd35_levelup_class_track_sync`.
- A validação acima cobre a trilha de classe e PV do caso de teste. Não cobre escolha de magias, todas as classes, multiclasse ou interação no navegador.


### Validação de talentos bônus de classe no nível 1 — 2026-11-02 (23:52 UTC)

- Teste transacional revertido para Guerreiro, Monge e Mago: Guerreiro recebeu Blind-Fight como talento bônus; Monge recebeu Agarrar Aprimorado e Ataque Desarmado Aprimorado como característica de classe; Mago recebeu Escrever Pergaminho automaticamente. Todos os três fluxos passaram pelas RPCs de criação e concessão de bônus.
- Verificado após `ROLLBACK`: zero personagens temporários permaneceram no banco.
- O workflow GitHub Pages do commit `f8b9320617c8112976eab16eccdef9f8a7b76193` concluiu com sucesso. O commit inclui a correção de classificação de Maestria em Magia como talento geral de Mago, e mantém as correções anteriores de criação e avanço de nível.

## Continuação da execução imediata — nível 1, talentos de classe e Maestria em Magia (2026-11-03)

### Criação de personagem — talentos de nível 1

- RPC salvar_talentos_bonus_classe_inicial_srd aplicada, com autenticação e verificação de proprietário. anon não executa; authenticated executa.
- Guerreiro: um talento bônus da lista específica, com validação de pré-requisitos e proficiência para Foco em Arma.
- Monge: escolha entre Agarrar Aprimorado ou Ataque Atordoante; Ataque Desarmado Aprimorado é adicionado automaticamente. Os bônus permitidos ignoram os pré-requisitos normais.
- Mago: Escrever Pergaminho é adicionado automaticamente.
- A RPC é idempotente para retentativas e impede uma segunda escolha diferente após já existir talento bônus de classe.
- UI de criação agora expõe escolha de classe para Guerreiro/Monge e informa concessão automática do Mago. O save chama a RPC após criar a ficha.
- criar_personagem_srd_completo valida que talentos básicos escolhidos pertencem à categoria General.

### Maestria em Magia (Spell Mastery)

- Corrigida a classificação: Maestria em Magia é uma opção de talento bônus do Mago nos níveis 5, 10, 15 e 20, não um talento geral de criação.
- A RPC de avanço exige Mago, modificador positivo de INT, número exato de magias igual ao modificador de INT e que cada magia esteja no grimório.
- Teste transacional: Mago nível 4 → 5, INT 14 e duas magias no grimório; escolha de Maestria em Magia aceita. A transação foi revertida de propósito.

### Testes de integração em subtransações com rollback

- Guerreiro nível 1: talentos gerais, Foco em Arma (Espada Longa) como bônus e retry idempotente — aceitos.
- Monge nível 1: talentos gerais, Ataque Desarmado Aprimorado automático e Ataque Atordoante como bônus; retry idempotente — aceitos.
- Mago nível 1: talentos gerais e Escrever Pergaminho automático — aceitos.
- Criação básica rejeitou Escrever Pergaminho como talento geral.
- Guerreiro 1 → 2 aceitou Foco em Arma com Espada Longa; Mago foi impedido de escolhê-la sem proficiência.
- Monge 1 → 2 aceitou Defletir Flechas apesar dos pré-requisitos usuais, pela exceção da lista de bônus.
- Maestria em Magia foi aceita no bônus de Mago 4 → 5 com duas magias do grimório.
- As subtransações foram revertidas; consulta posterior confirmou zero personagens de teste remanescentes.
- Scripts inline de ficha.html e mesa.html passaram na validação de sintaxe.

### Catálogo de armas

- As 53 armas de srd_equipment têm proficiência classificada e referência SRD: 15 simples, 28 marciais e 10 exóticas; zero sem categoria.

### Commits desta continuação

- 62198814c69ed05ef498c194688f4da93b3abd38 — RPC de talentos bônus de classe no nível 1.
- b6ab0a309f3078d65b5bb3cd71e9fe54021d1325, d29e1603839a1c14119e9036139a39e0b512d76b, 6a40b65f2f226c14f75edb9b7a4189d59c1efb41 — idempotência e unicidade.
- 0e5e0acf76ff4af3ec775bb248e6f9149f5f16ed, 81804255c84a9f2286eb1ba715f817da687fee2b — UI e integração da criação.
- b0bae40f43e71320b2371a53a9b4d5d51e529e21, c595b424306a568f2b59b4cd071f6f063dfdee7f — validação e filtro de talentos gerais.
- 97f156ae4371ce30fd3bac48b81a195cef7847d5 — proficiências das 53 armas.
- 2517b62825ad97b3ebaf48119a64378327d63dd9, 0513719fdf96434b67395b533f55e11bf5b2d9a5 — Maestria em Magia como talento bônus de Mago.

### Pendências restantes — continuam abertas

1. A ficha e a mesa passaram em validação sintática, mas não houve sessão de navegador autenticada após publicação/cache; o carregamento funcional real da ficha continua sem prova observacional.
2. E2E simultâneo Mestre/jogador e Realtime não foi executado. Não havia segunda sessão autenticada; branch Supabase isolada exige plano Pro e não foi criada. Nenhuma campanha real foi alterada.
3. Inspeção visual desktop e em viewport móvel após publicação continua pendente; não havia emulador/redimensionamento de viewport nesta execução.
4. Os 607 registros de efeito de magia continuam manual/manual_only: não há cobertura genérica tipada. Cura e Míssil Mágico são fluxos especializados; outros efeitos permanecem bloqueados sem consumir recursos.
5. As 131 características de classe continuam engine_status=needs_implementation; são exibidas no painel, mas suas habilidades, usos, limites e efeitos ainda requerem implementação por grupos de regra.
6. Avanço de nível ainda não acrescenta automaticamente novas magias conhecidas ao repertório de Bardo/Feiticeiro, novas magias ao grimório de Mago, nem aplica todas as progressões de classe.
7. Não foi possível confirmar neste ambiente o deploy público do GitHub Pages nem comportamento após atualização de cache.

Nenhum personagem, ficha, campanha, token ou log de jogo real foi alterado. Todas as fichas de teste foram revertidas.

## Continuação de interface e acesso à mesa — 2026-11-03

### Mesa e jogadores
- O painel do dado foi movido para a coluna esquerda, abaixo do chat; a largura da coluna lateral foi mantida. CSS ajusta chat e dado como painéis empilhados.
- Cards de fichas/tokens foram redimensionados para proporção vertical de carta de deck, com frente/verso e flip ao clicar em qualquer área do card. O botão de flip foi ocultado.
- A barra inferior foi compactada para acompanhar a altura das cartas.
- Foi adicionado o fluxo “Alterar imagem do token” em Mesa e Jogadores: lista os tokens publicados, permite escolher um e abrir o seletor de arquivo local. A imagem é gravada no Storage e atualizada no CBA.
- HUD sobre o token no tabuleiro (nome, CA/PV e barra) foi ocultado por CSS para deixar a imagem como elemento principal; informações de combate continuam nos cards.
- A exclusão da campanha foi removida do agrupamento genérico de ações e só aparece ao proprietário da campanha, identificado por campaigns.owner_id.

### Ficha e equipamento inicial
- A escolha de Ouro inicial agora rola automaticamente 3d4, multiplica o total por 10 e mostra cada resultado em dados separados.
- Catálogo e kit inicial passaram a usar cards/faixas com categoria, preço, peso/quantidade e descrição disponível.
- Cards de talentos passam a priorizar a descrição longa do catálogo SRD quando disponível e exibem pré-requisitos quando presentes.

### Lobby e acesso
- Adicionado botão de engrenagem nos cards de campanha, exclusivo do criador.
- O fluxo de configurações permite renomear a mesa, manter/ativar/desativar código de acesso, trocar a capa e iniciar exclusão da campanha.
- O jogador que clica em uma mesa sem proteção é incluído diretamente e segue para a seleção de ficha; mesas protegidas pedem o código antes da seleção.
- RPCs atualizar_configuracoes_campanha, entrar_campanha_aberta e entrar_campanha_com_codigo foram aplicadas com SECURITY DEFINER, search_path fixo e execução concedida somente a authenticated. A entrada por código está vinculada ao ID da mesa clicada, evitando entrar acidentalmente em outra campanha.
- Migrations versionadas: 20261103005352_campaign_access_settings_and_open_join e 20261103005530_campaign_join_code_scoped.
- Verificação de privilégios: anon não executa as novas RPCs; authenticated executa.

### Validação e limites desta entrega
- Scripts inline de mesa.html, ficha.html e lobby.html passaram em validação sintática JavaScript após as alterações.
- O deploy de Pages do commit 3e45bd936eb1bb9f8e6e80c6cc8e405591f80d20 concluiu com sucesso. Os commits posteriores de layout, lobby e acesso ainda estavam em fila/execução no momento da auditoria.
- A alteração de 3d4 foi feita conforme a regra solicitada; não substitui a validação de kits de equipamento por raça/classe com referências completas do livro.
- A interface de dados foi reposicionada, mas precisa de inspeção visual em navegador real para confirmar proporções em diferentes resoluções.

### Pendências que permanecem abertas
1. Reproduzir e corrigir o carregamento infinito da ficha em sessão autenticada; sintaxe estática não comprova o fluxo de runtime.
2. Redesenhar e testar o fluxo de perícias do jogador e o fluxo de conjuração com interfaces específicas por classe.
3. Classificar cards de monstros por ND/tipo, completar tradução pt-BR e apresentar resumo tático de flip antes de adicionar ao CBA.
4. Completar kits recomendados segundo raça e classe com fontes SRD e verificar cada combinação; hoje o catálogo de pacotes é indexado por classe.
5. Fazer teste E2E com Mestre e múltiplos jogadores, Realtime e rolagens simultâneas em sessão real. O backend atual da iniciativa envia um único pedido para todos os personagens esperados, mas a experiência de várias contas ainda precisa ser validada.
6. Implementar o resolver genérico para os 607 efeitos de magia e mecânicas das 131 características de classe.
7. Validar mobile/desktop visualmente e corrigir componentes que ainda usam variações azuis fora da paleta padrão.
8. Confirmar deploy dos commits mais recentes e testar os fluxos de senha, acesso aberto, alteração de capa/nome e exclusão com contas de criador/jogador separadas.

Nenhum personagem, ficha, campanha, token ou log real foi editado durante os testes desta continuação. As RPCs de configuração e entrada foram aplicadas, mas não foram usadas para alterar campanhas reais.


## Atualização adicional — interfaces de perícias, magias, bestiário e rolagem de ouro (2026-11-03)

- Perícias do jogador: o seletor antigo baseado em diálogo genérico foi substituído por uma janela de cards pesquisáveis. Exibe atributo, graduações, bônus de classe e racial, permite perícias não treinadas quando as regras permitem e abre o dado D20 ao selecionar um card.
- Ouro inicial: a escolha agora abre o próprio dice.html em iframe e envia a expressão 3d4 automaticamente. O resultado só é aceito quando o iframe devolve três valores D4 válidos; o total é multiplicado por 10 po. O jogador pode continuar sem comprar itens.
- Magias: a janela informa classe/conjurador, diferencia orientação de grimório, magias conhecidas e preparadas conforme a classe e mostra trecho de descrição nos cards. Seleção de domínio clerical ainda precisa ser conectada a esse fluxo de jogador.
- Bestiário do CBA: cards passam a virar ao clicar, mostram bloco tático com ND, tipo/tamanho, tendência, DV, PV, iniciativa, deslocamento, CA, ataques, resistências, atributos, perícias, talentos e qualidades especiais. A lista é ordenada por ND (incluindo frações) e depois tipo/nome; rótulos de filtro e termos comuns de tipo/tamanho/tendência/ataques recebem tradução pt-BR.
- Iniciativa: o backend já cria um único pedido para todos os personagens esperados e cada sessão de jogador recebe seu próprio botão; o chat agora explicita que todos podem rolar simultaneamente, sem ordem de chamada. A validação com múltiplas sessões reais ainda está pendente.
- Imagem de token: a ação foi removida do menu contextual individual e fica centralizada em Mesa e Jogadores, como solicitado.
- Paleta: foram aplicadas substituições de superfícies azuis mais evidentes da mesa para a paleta carvão/verde profundo e ouro. A revisão visual de todas as páginas ainda exige navegador e viewport real.
- Segurança de código: a RPC de entrada por código foi atualizada para usar o mesmo bloqueio de tentativas da entrada tradicional. A versão registrada no Supabase e o arquivo de migration no GitHub foram alinhados.
- Validação estática após estes ajustes: os scripts inline de mesa.html, ficha.html e lobby.html passaram em compilação sintática JavaScript.

### Pendências não concluídas nesta rodada
1. Kits iniciais ainda vêm do catálogo indexado por classe; não há matriz racial validada para todas as combinações. Não inventei pacotes específicos por raça sem dados de fonte.
2. O bestiário ainda pode conter valores de descrição/ataque herdados em inglês no próprio catálogo; a tradução aplicada cobre tipos, tamanhos, tendências, rótulos e termos comuns, não uma revisão editorial de cada um dos 607+ blocos de criatura.
3. A experiência de conjuração ainda usa uma janela compartilhada com dados/progressões por classe; faltam especializações completas por classe, principalmente a seleção de domínio do Clérigo e a validação de repertório/slots em cada classe.
4. Os 607 efeitos de magia e as 131 características de classe continuam sem resolver genericamente; cura e Míssil Mágico têm fluxos específicos.
5. O erro de carregamento infinito da ficha não foi reproduzido em navegador autenticado; a correção ainda não pode ser declarada concluída.
6. E2E com Mestre e múltiplas contas, Realtime, testes mobile e inspeção visual completa continuam pendentes.
7. Os commits mais recentes ainda aguardam o workflow de GitHub Pages; o último deploy confirmado antes desta sequência era o commit 3e45bd936eb1bb9f8e6e80c6cc8e405591f80d20.

Nenhuma campanha, personagem, ficha, token ou log real foi modificado nesta continuação. As RPCs de configuração e entrada foram aplicadas; não foram chamadas para atualizar campanhas reais.

- Segurança adicional do acesso protegido: a migration 20261103010205_campaign_join_code_rate_limit reaproveita o bloqueio progressivo de tentativas da RPC de entrada tradicional; tentativas inválidas ou código incorreto incrementam o bloqueio por usuário.
- O catálogo de monstros formata valores JSON estruturados como texto legível nos cards de ficha tática, em vez de exibir [object Object].
