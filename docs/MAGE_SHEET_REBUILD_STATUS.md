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

- A criação nova ainda salva rascunho somente no armazenamento local do navegador. A gravação definitiva de um personagem novo ainda precisa ser ligada ao contrato de criação SRD, sem reutilizar a interface antiga.
- O mapeamento de campos já é determinístico por seção/linha/coluna, mas precisa de revisão semântica completa, especialmente tabelas repetidas, grimório e listas de equipamentos.
- Retrato ainda não está ligado ao Storage e os campos derivados de regras ainda não são calculados.
- A Mesa ainda precisa abrir a ficha original no contexto de campanha e respeitar permissões de jogador/Mestre.
- O fluxo narrativo do grimório e da lista separada de magias preparadas do Mago ainda precisa ser conectado ao banco sem limites diários, slots ou consumo automático.
- Não foi feita alteração em migrations, RPCs, políticas RLS, campanhas ou fichas existentes.

## Próximas entregas técnicas

1. Mapear semanticamente os campos editáveis e derivados do HTML original.
2. Executar teste autenticado no navegador para criar um Mago novo, salvar e reabrir a ficha; corrigir qualquer diferença entre controles visuais e dados normalizados.
3. Ligar retrato ao Storage e manter transformações.
4. Abrir a mesma ficha na Mesa em painel/modal.
5. Implementar grimório permanente e preparação narrativa ilimitada do Mago.
6. Executar testes autenticados de criar, salvar, recarregar e editar com personagem novo de teste; não usar fichas existentes como fixtures mutáveis.
