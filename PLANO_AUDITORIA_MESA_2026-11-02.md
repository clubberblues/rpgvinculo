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
