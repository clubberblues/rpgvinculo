# Reconstrução independente da ficha do Mago

## Decisão de arquitetura

A ficha enviada em `mago.feiticeiro(2).html` é a interface canônica. A nova implementação não utiliza o fluxo visual de criação de `ficha.html` nem o antigo adaptador genérico. A primeira classe atendida é exclusivamente Mago.

## Implementado nesta etapa

- `ficha-original.html` passa a se identificar como ficha do Mago e carrega apenas os módulos novos.
- `mage-sheet-core.js` contém coleta/hidratação de campos, chaves estruturadas e aplicação de dados de identidade.
- `mage-sheet-app.js` cria a orientação por etapas com destaque visual dentro da ficha, autentica usando a sessão Supabase existente e carrega/salva snapshots versionados de fichas de Mago existentes em `srd_character_sheets.identidade.ficha_mago_v2`.
- O Lobby deixou de desviar imediatamente para o criador antigo antes da seleção de raça/classe. A seleção de Mago abre a ficha original; fichas existentes identificadas como Mago também abrem nela.
- O antigo `original-sheet-adapter.js` foi removido e o verificador estático passou a validar os dois módulos novos.

## Limites conhecidos — não considerar concluído

- A criação definitiva do Mago está conectada à RPC transacional `criar_mago_ficha_original_v2`, registrada na migration `20261121215802_srd35_mage_original_sheet_creation_v2` e `20261121220216_srd35_mage_original_sheet_skill_validation_v2`.
- A RPC cria personagem e ficha juntos, aplica ajustes raciais, valida o orçamento e os limites de perícias do Mago (incluindo Conhecimento como perícia de classe), valida talentos, registra idiomas livres e equipamentos narrativos, grava a trilha de classe e registra o grimório.
- O grimório inicial inclui automaticamente todos os truques permitidos e exige exatamente 3 + modificador positivo de Inteligência (mínimo 3) magias de 1º círculo. A lista de preparadas começa vazia; nenhum espaço diário é gasto. A especialização e as escolas proibidas usam os campos já existentes no painel Magia da ficha original, sem criar um formulário paralelo.
- A RPC só pode ser executada por usuários autenticados; `PUBLIC` e `anon` não têm permissão. A chamada positiva foi testada em uma transação revertida, sem deixar personagem persistido.
- O mapeamento de persistência visual é versionado; tabelas repetidas e algumas listas ainda precisam de revisão semântica completa.
- Retrato ainda não está ligado ao Storage; os principais campos derivados do Mago (atributos, PV, resistências, CA, iniciativa, agarrar, perícias, CD de magia, carga, XP e moedas iniciais) são preenchidos na criação, mas ainda precisam de conferência visual no navegador.
- A Mesa ainda precisa abrir a ficha original no contexto de campanha e respeitar permissões de jogador/Mestre.
- O fluxo narrativo do grimório e da lista separada de magias preparadas do Mago ainda precisa ser conectado ao banco sem limites diários, slots ou consumo automático.
- Foi adicionada somente uma RPC de criação e sua migration; não foram alteradas policies RLS, campanhas ou fichas existentes.

## Próximas entregas técnicas

1. Mapear semanticamente os campos editáveis e derivados do HTML original.
2. Executar teste autenticado no navegador para criar um Mago novo, salvar e reabrir a ficha; corrigir qualquer diferença entre controles visuais e dados normalizados.
3. Ligar retrato ao Storage e manter transformações.
4. Abrir a mesma ficha na Mesa em painel/modal.
5. Implementar grimório permanente e preparação narrativa ilimitada do Mago.
6. Executar testes autenticados de criar, salvar, recarregar e editar com personagem novo de teste; não usar fichas existentes como fixtures mutáveis.
