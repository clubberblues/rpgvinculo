# Reconstrução independente da ficha do Mago

## Decisão de arquitetura

A ficha enviada em `mago.feiticeiro(2).html` é a interface canônica. A nova implementação não utiliza o fluxo visual de criação de `ficha.html`, não chama `finalizar_criacao_personagem_srd` e não reativa o antigo assistente. O escopo atual é exclusivamente Mago.

## Implementado

- `ficha-original.html` preserva o modelo visual original e carrega `mage-sheet-core.js` e `mage-sheet-app.js`.
- O Lobby abre a ficha original depois da escolha de raça e classe para novos Magos; fichas existentes identificadas como Mago também abrem nesse modelo.
- O núcleo novo coleta e hidrata os campos da ficha em um snapshot versionado. Rascunhos incompletos são recuperados e salvos localmente por usuário e raça.
- A RPC transacional `criar_mago_ficha_original_v2` está aplicada no Supabase pelas migrations:
  - `20261121215802_srd35_mage_original_sheet_creation_v2`
  - `20261121220216_srd35_mage_original_sheet_skill_validation_v2`
  - `20261121220934_srd35_mage_original_sheet_currency_sync_v2`
  - `20261121221412_srd35_mage_original_sheet_class_bonus_features_v2`
- A RPC cria personagem e ficha na mesma transação, valida usuário autenticado, raça e classe Mago, valida os seis atributos no orçamento de 25 pontos de compra e aplica ajustes raciais, registra a progressão de classe de nível 1, PV, perícias, talentos, idiomas livres, equipamentos narrativos, moedas (PC/PP/PO/PL convertidas para ouro total) e snapshot da ficha.
- A orientação da ficha informa o orçamento de 25 pontos de compra e a validação de atributos é feita no banco. A validação de perícias é específica do Mago: orçamento de nível 1 com Inteligência e bônus humano, máximo de 4 graduações em perícia de classe e 2 em cross-class, incrementos de 0,5 para cross-class. Conhecimento é tratado como perícia de classe.
- Talentos escolhidos pelo jogador são validados pelo mecanismo de regras existente; a criação exige um talento para raças comuns e dois para Humano. O Mago recebe automaticamente o talento bônus Escrever Pergaminho no nível 1, também registrado na tabela normalizada de talentos.
- O grimório recebe automaticamente todos os truques permitidos e exige exatamente 3 + modificador positivo de Inteligência (mínimo 3) magias de 1º círculo. As magias são gravadas no grimório e no catálogo normalizado de magias conhecidas.
- A especialização e as escolas proibidas usam os campos já existentes no painel Magia da ficha original. A disponibilidade de Invocar Familiar é registrada como escolha pendente; nenhum familiar é criado ou invocado automaticamente. A lista de preparadas começa vazia; nenhum espaço diário é gasto, e nenhum descanso ou limite diário é aplicado. Os marcadores de preparação do grimório e os campos de magias por dia ficam inativos para não confundir grimório permanente com preparação.
- Equipamentos livres são preservados em `equipamento_inicial` como itens narrativos, sem obrigar correspondência no catálogo.
- A função é `SECURITY DEFINER` com `search_path` fixo, exige `auth.uid()`, cria somente para o usuário autenticado e tem execução revogada para `PUBLIC` e `anon`; somente `authenticated` pode chamá-la.
- O adaptador genérico antigo foi removido. A função antiga de finalização não é chamada. Os validadores de talento e grimório são usados apenas como motores de regras; a gravação de perícias é feita pela nova validação específica do Mago.

## Verificações executadas

- Chamada positiva da RPC para Mago Elfo, com atributos, 12 pontos de perícia, talento, idiomas, equipamento e grimório, dentro de transação revertida.
- Chamada positiva da RPC para Mago Humano especialista em Evocação, com dois talentos, 16 pontos de perícia, escolas proibidas e grimório, dentro de transação revertida.
- Verificação posterior confirmou que os personagens temporários de teste não permaneceram no banco.
- A função está executável por `authenticated` e não por `anon`.
- As validações estáticas e de sintaxe JavaScript passaram nos commits verificados até a última execução de CI.

## Catálogos auxiliares e identidade visual — atualização

- Os títulos Talentos, Familiar e Grimório abrem catálogos auxiliares sem substituir nem ocupar permanentemente os campos da ficha.
- O catálogo de talentos apresenta nome e pré-requisitos; selecionar o nome preenche a próxima linha disponível da ficha. A ação VER abre a descrição completa em uma camada tipográfica central, com o restante da tela intensamente desfocado e sem cartão ou caixa.
- O catálogo de magias consulta os registros do Mago, permite filtrar por círculo, exibe os dados técnicos e a descrição organizada em parágrafos; selecionar o nome preenche a linha correspondente no grimório original.
- O catálogo de Familiar consulta os animais-base existentes em `srd_monsters` (morcego, gato, falcão, lagarto, coruja, rato, corvo, sapo e doninha), copia os dados disponíveis para os campos do modelo e guarda o identificador da escolha nos metadados da ficha.
- A descrição detalhada de talentos, magias e familiares usa a mesma camada sem caixas, com fundo em blur; pode ser fechada com Escape ou clicando fora do texto.
- A paleta da ficha e dos catálogos parte dos tokens já existentes: pergaminho claro, tinta escura, latão envelhecido e EB Garamond/Cinzel. O destaque de foco azulado foi substituído por latão para evitar a quebra de identidade.
- As escolhas de progressão durante a campanha não terão bloqueios automáticos de nível/pré-requisitos impostos pela interface; a condução das condições fica com o Mestre. A validação transacional atual da criação inicial permanece separada e não foi alterada nesta etapa.
- Limitação de conteúdo: nomes dos familiares foram localizados na interface, mas as descrições dos registros de monstros ainda vêm do campo-fonte existente e podem permanecer em inglês. Os catálogos exibem o texto atualmente cadastrado, sem inventar traduções.

## Pendências reais

- Ainda falta teste ponta a ponta no navegador com uma sessão real de jogador. A RPC foi testada no banco com contexto de autenticação simulado e transação revertida; nenhum personagem de teste foi deixado persistido.
- O mapeamento semântico de todos os controles, tabelas repetidas e listas do HTML ainda precisa de revisão completa; os catálogos auxiliares agora cobrem talentos, grimório e familiares do Mago, mas ainda precisam de validação visual e funcional em navegador.
- Retrato e transformação ainda não estão ligados ao Supabase Storage.
- A edição de uma ficha já existente ainda salva o snapshot visual; a sincronização de cada campo editado com as colunas normalizadas precisa de uma operação própria.
- A Mesa ainda precisa abrir a ficha original em painel/modal e respeitar as permissões de jogador e Mestre.
- A lista separada de magias preparadas do Mago ainda precisa de operações narrativas de adicionar/remover ocorrências durante a campanha, sem slots, limites diários ou consumo automático. A interface/ação de invocar e administrar o familiar ainda precisa ser implementada.

### Auditoria de cobertura dos catálogos no banco (21/11/2026)

- Talentos: 110 registros; 110 com nome em português e 110 com descrição em português.
- Magias disponíveis ao Mago: 378 registros; 378 com nome e descrição em português.
- Campos técnicos das magias do Mago: alcance preenchido em 315/378, alvo ou área em 325/378, duração em 316/378 e componentes em 318/378. A interface deve apresentar os dados existentes sem inventar valores; as lacunas continuam sendo pendência de catalogação.
- Familiares-base consultados em `srd_monsters`: 9 animais encontrados. Os nomes e categorias de tamanho foram localizados na interface; descrições detalhadas ainda usam o texto-fonte cadastrado, que pode estar em inglês.
- O arquivo `mage-sheet-app.js` passou por compilação de sintaxe JavaScript sem execução. Para o commit de código `90ec370`, as duas verificações GitHub Actions (`Static validation` e `Validate application JavaScript`) concluíram com sucesso. Isso não equivale a teste funcional em navegador.
- Não foi feita alteração de esquema nem gravação de dados de personagens nesta etapa.

## Segurança e preservação

- Não foram alteradas fichas existentes, campanhas, tokens ou políticas RLS.
- A criação deixa o personagem sem campanha associada, seguindo o fluxo atual de criação pela estante do Lobby; a associação à campanha continua sendo uma etapa separada.
- O PR #99 permanece draft e sem merge até a validação ponta a ponta.
