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
