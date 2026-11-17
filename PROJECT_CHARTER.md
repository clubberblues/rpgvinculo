# Constituição do Projeto — Fichas D&D 3.5

**Status:** vigente  
**Última atualização:** 2026-11-16  
**Prioridade:** criação orientada, edição, consulta e persistência de fichas de personagens D&D 3.5.

## Missão

Construir fichas digitais completas de D&D 3.5. O processo de criação orienta o jogador pelas escolhas e regras pertinentes, explica suas consequências para o personagem e registra corretamente o resultado. Depois da criação, a ficha é um documento vivo, visualmente organizado e integralmente consultável e editável durante a campanha.

## Produto e limites

1. O escopo inicial cobre as 11 classes básicas do Livro do Jogador: Bárbaro, Bardo, Clérigo, Druida, Guerreiro, Monge, Paladino, Patrulheiro, Ladino, Feiticeiro e Mago.
2. Cada personagem possui uma única classe. Multiclasse e classes de suplementos ficam fora do escopo inicial.
3. A criação é guiada e aplica as regras de criação/progressão pertinentes, com explicações sobre escolhas, requisitos e consequências.
4. A ficha salva e apresenta as informações relevantes do personagem e permite ao jogador adicionar, editar e apagar registros durante a campanha.
5. Equipamentos, armas, munições, itens, tesouros e anotações são informações escritas manualmente pelo jogador em campos claros e organizados da ficha. A interface oferece espaços adequados e permite adicionar múltiplas entradas de cada tipo quando necessário.
6. Não construir catálogo obrigatório, motor de inventário, lógica de equipar/desequipar, classificação de estados, controle automático de cargas/consumo, nem cálculo de efeitos de itens sobre atributos. A ficha apenas registra o que o jogador escrever.
7. Não construir motor de combate, resolução de testes, conjuração, aplicação de efeitos, gerenciamento de turnos ou execução de habilidades.
8. O jogador terá acesso à própria ficha (consulta e edição) e à ferramenta de rolagem de dados. Não haverá painel de ações de classe, combate, perícias ou magias.
9. Ao clicar no token, o Mestre abre a ficha correspondente. O token não executa ações nem aplica regras.
10. O Mestre conduz a narrativa e decide como aplicar regras e resultados. Ferramentas administrativas existentes do Mestre permanecem fora desta reestruturação, salvo dependência comprovada.
11. A mesa, campanhas, lobby e tokens não são o foco do desenvolvimento. Só serão alterados quando indispensável para vincular e abrir a ficha correta.

## Princípios de criação e edição

- Orientar significa explicar escolhas, aplicar validações necessárias para criar legalmente o personagem e mostrar o que cada decisão preenche ou altera na ficha. Não significa automatizar a sessão.
- Separar o fluxo de criação da edição cotidiana. Após a criação, o jogador pode atualizar livremente as informações sem refazer o assistente.
- A ficha deve preservar os valores e escolhas de criação, mas não impedir anotações ou edições de campanha por exigir validação de criação a cada alteração.
- Todos os campos e grupos de registros pertinentes devem ter inclusão, edição, exclusão quando aplicável, salvamento e recuperação.
- A organização visual deve lembrar uma ficha de personagem de RPG: blocos específicos para armas, munições, equipamentos, itens, recursos, perícias, magias e demais informações. Não reduzir a ficha a um único campo de texto genérico.
- Campos repetíveis são apenas áreas para escrever e organizar informações. Não devem incorporar lógica de regras, catálogo ou efeitos automáticos.
- Informações derivadas da criação podem ser apresentadas de forma clara; itens escritos manualmente nunca alteram atributos automaticamente.
- Não inferir que uma funcionalidade está concluída apenas porque há tabelas, dados catalogados ou código parcial.

## Controle de escopo

Toda tarefa deve responder afirmativamente a pelo menos uma destas necessidades: criar, orientar, validar, salvar, recuperar, consultar ou editar a ficha; ou ligar a ficha ao jogador/token para consulta. Caso contrário, fica fora do escopo atual.

Uma dependência técnica só entra na medida estritamente necessária para viabilizar uma dessas necessidades.

## Hierarquia de autoridade

1. Esta Constituição e as decisões vigentes registradas em `docs/DECISIONS.md`.
2. Especificações atuais de ficha e classe.
3. Planejamento técnico e auditorias.
4. Código, banco e dados existentes, que são objetos de inspeção e reaproveitamento, não autoridade de produto.
5. Conversas e documentos antigos, que são históricos e não reativam decisões substituídas.

## Alterações

Nenhuma mudança de escopo ou princípio desta Constituição será silenciosa. Registrar decisão, justificativa, autorização explícita do usuário, impacto nas especificações e tarefas afetadas. Se uma tarefa contradisser esta Constituição, interromper essa tarefa e registrar o conflito antes de alterar código ou banco.

## Critério de sucesso

Um jogador consegue criar um personagem completo conforme as regras de criação D&D 3.5, entender as escolhas, salvar, sair, retornar, consultar e editar a ficha inteira; registrar manualmente vários itens, armas e munições em espaços apropriados; e o Mestre consegue abrir a ficha certa ao clicar no token. Não é necessário automatizar a execução da sessão.
