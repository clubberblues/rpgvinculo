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
