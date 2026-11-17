# Registro de decisões — Fichas D&D 3.5

As decisões abaixo estão vigentes, salvo quando marcadas como substituídas. A Constituição em `/PROJECT_CHARTER.md` tem autoridade superior.

## DEC-001 — Foco do produto
**Status:** vigente · **Data:** 2026-11-16  
O foco prioritário é criação orientada, consulta, edição e persistência de fichas completas de D&D 3.5.

## DEC-002 — Jogador
**Status:** vigente · **Data:** 2026-11-16  
O jogador pode abrir e editar sua própria ficha e usar a rolagem de dados. Não terá painel de ações, perícias, habilidades, magias ou combate.

## DEC-003 — Token do Mestre
**Status:** vigente · **Data:** 2026-11-16  
Clicar no token abre a ficha do personagem correspondente. O token não executa ações nem aplica regras.

## DEC-004 — Papel do Mestre
**Status:** vigente · **Data:** 2026-11-16  
O Mestre conduz a narrativa e aplica as regras manualmente. A aplicação não resolve testes, combate ou efeitos.

## DEC-005 — Inventário narrativo
**Status:** vigente · **Data:** 2026-11-16  
O inventário é uma lista editável de itens pertencentes ao personagem. Não requer classificação equipado/guardado/consumível e não aplica efeitos automaticamente aos atributos.

## DEC-006 — Criação versus edição
**Status:** vigente · **Data:** 2026-11-16  
A criação é guiada e valida escolhas conforme as regras de D&D 3.5. Após criada, a ficha é um documento vivo e editável; alterações cotidianas não devem exigir refazer o assistente.

## DEC-007 — Classes
**Status:** vigente · **Data:** 2026-11-16  
Primeiro escopo: as onze classes básicas do Livro do Jogador, sem multiclasse. O Mago é o primeiro modelo de implementação.

## DEC-008 — Automação de efeitos de itens
**Status:** substituída · **Data:** 2026-11-16  
Qualquer plano anterior de equipar/desequipar itens na ficha, classificar estados do inventário ou recalcular atributos a partir de itens está substituído. A ficha apenas registra o que pertence ao personagem.

## DEC-009 — Automação de ações
**Status:** substituída · **Data:** 2026-11-16  
Qualquer plano anterior de ações de combate, testes, conjuração ou ativação de habilidades por botões do jogador está substituído.

## DEC-010 — Compatibilidade de dados legados
**Status:** vigente · **Data:** 2026-11-16  
Preservar código e dados existentes quando úteis, mas não manter uma funcionalidade antiga apenas por existir. Auditar dependências e compatibilidade antes de remover ou migrar dados.


## DEC-011 — Equipamentos como campos de escrita organizados
**Status:** vigente · **Data:** 2026-11-16  
A ficha deve apresentar blocos específicos e visualmente intuitivos para o jogador escrever manualmente armas, múltiplas armas, munições, armaduras, equipamentos, itens mágicos, dinheiro e outros pertences. Deve permitir acrescentar várias entradas de cada tipo, editar e apagar. Esses espaços não são um motor de inventário: sem catálogo obrigatório, classificação, estado equipado/guardado/consumível, cálculos, efeitos automáticos ou integração com regras. Durante a criação, o assistente orienta sobre proficiências e equipamento inicial do Mago, mas o registro dos itens permanece manual e livre. Após a criação, os mesmos campos são editáveis durante toda a campanha.

## DEC-012 — A ficha deve parecer uma ficha de RPG, não um formulário genérico
**Status:** vigente · **Data:** 2026-11-16  
Organizar visualmente os campos em blocos familiares e específicos, com lacunas adequadas e entradas repetíveis para informações múltiplas. Não agrupar tudo em uma única caixa de texto. Reaproveitar o layout real existente quando adequado e conferir referências de fichas D&D 3.5 antes de alterar o desenho.

## DEC-013 — Persistência de anotações livres de equipamento
**Status:** vigente · **Data:** 2026-11-16  
Os cartões livres de armas, munições, proteção, objetos, itens mágicos e tesouros serão armazenados no JSONB já existente `srd_character_sheets.identidade`, sob `equipment_notes`. Isso evita tabela de inventário, catálogo e mudança de schema. A ficha envia as anotações no RPC existente durante a criação. A edição posterior exige uma RPC estreita e segura que atualize somente `equipment_notes`; não conceder UPDATE amplo à role `authenticated`, pois isso permitiria alterar outros campos protegidos da ficha. Até essa RPC existir, a ficha pós-criação exibe os registros em modo de consulta. O registro é descritivo: não altera atributos nem executa regras.

## DEC-014 — Equipamento inicial fiel aos pacotes do Livro do Jogador
**Status:** vigente · **Data:** 2026-11-17
A etapa de equipamento não deve oferecer kits inventados pelo projeto nem consultar catálogo/banco de itens para decidir o que o personagem recebe. Quando o Livro do Jogador 3.5 trouxer um pacote inicial específico para a combinação raça/classe escolhida, os itens desse pacote devem ser registrados automaticamente nos campos narrativos correspondentes da ficha. Quando não houver pacote aplicável, os campos de pertences ficam vazios; somente as regras gerais de riqueza inicial da classe são apresentadas quando o jogador optar pela compra individual. A regra universal de uma roupa comum gratuita permanece como escolha simples entre os trajes indicados no livro.

Para o Mago, o Livro do Jogador apresenta o **Pacote Inicial do Mago Elfo** (p. 58): bordão, besta leve, mochila com cantil, rações de viagem para um dia, saco de dormir, saco e pederneira; dez velas, estojo de mapas, três folhas de pergaminho, tinta e pena; bolsa de componentes de magia, livro de magias e estojo com 10 virotes; ouro 3d6 po. A alternativa de compra individual usa a Tabela 7–1: Mago 3d4 × 10 po. São alternativas distintas e não podem ser somadas nem misturadas como se fossem um único pacote.

**Bloqueio técnico identificado:** o RPC atual de finalização de equipamento aceita somente rolagens d4 e pacotes baseados em IDs do catálogo srd_starting_packages/srd_equipment; ele não representa o pacote de Mago Elfo do livro nem o ouro 3d6. Não falsificar a rolagem nem aplicar os itens automaticamente até adaptar esse salvamento com segurança. A correção requer migration estreita na função de finalização, sem criar catálogo ou tabela de consulta de itens. Nenhuma alteração de banco de produção foi feita.

## DEC-015 — Apresentação vertical e leitura da ficha
**Status:** vigente · **Data:** 2026-11-17
A ficha D&D 3.5 deve ser percorrida de cima para baixo, em uma única coluna de seções, sem painéis principais lado a lado. A identidade visual segue o tema global da mesa: carvão profundo, grafite, superfícies escuras, bronze discreto e tipografia Inter/Cinzel/EB Garamond conforme hierarquia. O verde não é cor de identidade da ficha. Tipografia, tamanhos e espaçamentos gerais devem ser modernos e legíveis. A seção de perícias deve preservar a lógica da ficha oficial (perícia, atributo-chave, graduações, modificadores e total), mas explicar esses dados em linguagem curta e direta. A mudança visual não deve alterar regras, fórmulas ou persistência.


## DEC-016 — Equipamento narrativo e riqueza inicial sem compra
**Status:** vigente · **Data:** 2026-11-17
A criação não terá loja, compra de itens, catálogo, preço, peso, efeitos automáticos ou motor de inventário. Os itens iniciais expressamente listados no Livro do Jogador serão inseridos como anotações simples nos campos existentes, somente quando houver pacote aplicável à combinação selecionada. A primeira exceção implementada é Elfo + Mago: os itens do pacote do Mago Elfo são distribuídos entre Armas, Munições, Equipamentos e objetos e Itens mágicos/especiais. Outras combinações permanecem sem itens inventados.

O jogador rola a riqueza inicial da classe na etapa de equipamento. Para Mago, a interface usa 3d4 × 10 PO. Essa é uma decisão de produto solicitada pelo usuário para o fluxo atual, sem abrir compra de itens. O RPC existente já valida os três resultados d4, multiplica por 10 e grava o saldo em srd_character_sheets.ouro e characters.ouro; portanto, não é necessária nova tabela nem migration para essa rolagem. O pacote textual é salvo no JSON identidade.equipment_notes já enviado na criação.

A roupa comum gratuita continua como escolha simples do Livro do Jogador.
