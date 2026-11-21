# Reconstrução independente da ficha do Mago

## Decisão de arquitetura

A ficha enviada em `mago.feiticeiro(2).html` é a interface canônica. A nova implementação não utiliza o fluxo visual de criação de `ficha.html`, não chama `finalizar_criacao_personagem_srd` e não reativa o antigo assistente. O escopo atual é exclusivamente Mago.

## Implementado

- `ficha-original.html` preserva o modelo visual original e carrega `mage-sheet-core.js` e `mage-sheet-app.js`.
- O Lobby abre a ficha original depois da escolha de raça e classe para novos Magos; fichas existentes identificadas como Mago também abrem nesse modelo.
- O núcleo novo coleta e hidrata os campos da ficha em um snapshot versionado.
- A RPC transacional `criar_mago_ficha_original_v2` está aplicada no Supabase pelas migrations:
  - `20261121215802_srd35_mage_original_sheet_creation_v2`
  - `20261121220216_srd35_mage_original_sheet_skill_validation_v2`
- A RPC cria personagem e ficha na mesma transação, valida usuário autenticado, raça e classe Mago, aplica ajustes raciais, registra a progressão de classe de nível 1, PV, perícias, talentos, idiomas livres, equipamentos narrativos e snapshot da ficha.
- A validação de perícias é específica do Mago: orçamento de nível 1 com Inteligência e bônus humano, máximo de 4 graduações em perícia de classe e 2 em cross-class, incrementos de 0,5 para cross-class. Conhecimento é tratado como perícia de classe.
- Talentos são validados pelo mecanismo de regras existente; a criação exige um talento para raças comuns e dois para Humano.
- O grimório recebe automaticamente todos os truques permitidos e exige exatamente 3 + modificador positivo de Inteligência (mínimo 3) magias de 1º círculo. As magias são gravadas no grimório e no catálogo normalizado de magias conhecidas.
- A especialização e as escolas proibidas usam os campos já existentes no painel Magia da ficha original. A lista de preparadas começa vazia; nenhum espaço diário é gasto, e nenhum descanso ou limite diário é aplicado.
- Equipamentos livres são preservados em `equipamento_inicial` como itens narrativos, sem obrigar correspondência no catálogo.
- A função é `SECURITY DEFINER` com `search_path` fixo, exige `auth.uid()`, cria somente para o usuário autenticado e tem execução revogada para `PUBLIC` e `anon`; somente `authenticated` pode chamá-la.
- O adaptador genérico antigo foi removido. A função antiga de finalização não é chamada. Os validadores de talento e grimório são usados apenas como motores de regras; a gravação de perícias é feita pela nova validação específica do Mago.

## Verificações executadas

- Chamada positiva da RPC para Mago Elfo, com atributos, 12 pontos de perícia, talento, idiomas, equipamento e grimório, dentro de transação revertida.
- Chamada positiva da RPC para Mago Humano especialista em Evocação, com dois talentos, 16 pontos de perícia, escolas proibidas e grimório, dentro de transação revertida.
- Verificação posterior confirmou que os personagens temporários de teste não permaneceram no banco.
- A função está executável por `authenticated` e não por `anon`.
- As validações estáticas e de sintaxe JavaScript passaram nos commits verificados até a última execução de CI.

## Pendências reais

- Ainda falta teste ponta a ponta no navegador com uma sessão real de jogador. A RPC foi testada no banco com contexto de autenticação simulado e transação revertida; nenhum personagem de teste foi deixado persistido.
- O mapeamento semântico de todos os controles, tabelas repetidas e listas do HTML ainda precisa de revisão completa.
- Retrato e transformação ainda não estão ligados ao Supabase Storage.
- A edição de uma ficha já existente ainda salva o snapshot visual; a sincronização de cada campo editado com as colunas normalizadas precisa de uma operação própria.
- A Mesa ainda precisa abrir a ficha original em painel/modal e respeitar as permissões de jogador e Mestre.
- A lista separada de magias preparadas do Mago ainda precisa de operações narrativas de adicionar/remover ocorrências durante a campanha, sem slots, limites diários ou consumo automático.

## Segurança e preservação

- Não foram alteradas fichas existentes, campanhas, tokens ou políticas RLS.
- A criação deixa o personagem sem campanha associada, seguindo o fluxo atual de criação pela estante do Lobby; a associação à campanha continua sendo uma etapa separada.
- O PR #99 permanece draft e sem merge até a validação ponta a ponta.
