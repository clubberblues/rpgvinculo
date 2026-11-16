# Reestruturação da criação e consulta de fichas — D&D 3.5

## Decisão de produto

A ficha do jogador será um documento digital completo do personagem, com criação orientada por etapas e consulta durante a campanha. O painel do jogador não será um conjunto de ações automatizadas de jogo.

- O personagem possui **uma única classe**. Multiclasse não faz parte do escopo.
- A classe progride exclusivamente pela tabela oficial dessa classe.
- O conjunto inicial de classes é o das 11 classes básicas do Livro do Jogador: Bárbaro, Bardo, Clérigo, Druida, Guerreiro, Monge, Paladino, Patrulheiro, Ladino, Feiticeiro e Mago.
- Classes de suplementos ficam fora do primeiro escopo e só entram após cobertura completa e validada das 11 classes básicas.
- A ficha do jogador é consultiva: mostra informações e totais calculados. O jogador consulta o livro e faz suas rolagens manualmente; a ficha não executa ações ou resolve testes.
- A narração continua no Discord.
- As ferramentas específicas do Mestre permanecem separadas e não são removidas por esta mudança.

## Fontes de referência

1. **Dyslexic Character Sheets — D&D 3.5**: referência de abrangência e organização da ficha por classe. A página de criação lista as 11 classes do Livro do Jogador e classes adicionais de suplementos: https://dev.dyslexic-charactersheets.com/en/build-dnd35.html
2. **SRD 3.5 revisado**: fonte para regras abertas de criação, raças, classes, atributos, perícias, talentos, equipamentos, carga, magia e progressão: https://www.darkshire.net/jhkim/rpg/srd/srd_revised_html/index.html
3. **Livro do Jogador D&D 3.5**: referência normativa primária para campos e procedimentos de criação, respeitando o material disponível no projeto.

### Limitação importante da referência visual

O gerador Dyslexic é uma referência de estrutura e cobertura, não uma engine pronta para integração: seu suporte a edição, cálculos e salvamento automáticos não se aplica às fichas D&D 3.5. Os cálculos do nosso produto devem ser implementados e validados separadamente contra as regras de D&D 3.5.

## Experiência de criação

A criação deve ser completa, intuitiva, sequencial e persistente. Cada etapa explica o que o jogador precisa preencher e apresenta apenas opções válidas para a combinação raça/classe/nível.

Etapas de trabalho a validar e ajustar contra a ficha atual:

1. Identidade: nome do personagem, nome do jogador, aparência e dados descritivos pertinentes.
2. Raça: escolha racial, ajustes de atributos, tamanho, deslocamento, idiomas, características, proficiências e escolhas raciais aplicáveis.
3. Classe: classe única, dado de vida, perícias de classe, proficiências, tendências permitidas, características, escolhas e progressão.
4. Atributos: método de geração aprovado pela mesa, distribuição, ajustes raciais e modificadores derivados.
5. Perícias e talentos: pontos disponíveis, custos, limites de graduação, perícias de classe/fora de classe, talentos e pré-requisitos.
6. Magia e recursos de classe: exibida quando aplicável, incluindo conjuração, grimório, magias conhecidas/preparadas, espaços, familiar, domínios, música de bardo ou outros recursos próprios. Não transformar esses recursos em botões de execução.
7. Equipamento e riqueza: método de riqueza inicial, compras, armas, armaduras, escudos, itens mágicos, munição, varinhas/cajados/cargas quando aplicável, recipientes, dinheiro, peso e capacidade de carga.
8. Revisão: ficha completa, cálculos explicados, pendências e confirmação antes de salvar.

A sequência exata pode ser reorganizada se a auditoria demonstrar que outra ordem é mais intuitiva, mas nenhuma informação obrigatória pode ser perdida. Etapas condicionais podem ser omitidas apenas quando não se aplicam à classe/raça/personagem.

## Conteúdo da ficha de consulta

### Base comum
- Identidade do personagem e jogador; raça; classe única; nível; tendência; divindade quando aplicável; experiência.
- Seis atributos, valores-base, ajustes, valores finais e modificadores.
- PV, dado de vida, CA e componentes, iniciativa, deslocamentos, velocidade, bônus base de ataque, ataques e salvamentos.
- Perícias, graduações, atributo-chave, classe/fora de classe e bônus totais.
- Talentos, pré-requisitos e escolhas de parâmetros.
- Idiomas e alfabetização quando aplicável.
- Armas, armaduras, escudos, proteções, equipamentos, itens mágicos, cargas/munições, varinhas, cajados, recipientes e dinheiro.
- Peso carregado, capacidade de carga e penalidades aplicáveis.
- Características raciais e de classe, observações, aparência e histórico.

### Seções condicionais
- Conjuradores: atributo de conjuração, nível de conjurador, CDs, magias por círculo, magias conhecidas/preparadas conforme a classe, grimório, componentes e familiar/domínios quando aplicável.
- Bárbaro: fúria e progressão, movimento rápido, redução de dano, esquiva sobrenatural, sentido das armadilhas e demais características conforme o nível.
- Bardo: música de bardo, usos, efeitos e progressão de conjuração espontânea.
- Clérigo: divindade/causa, domínios, expulsar/repreender mortos-vivos e conjuração.
- Druida: vínculo com a natureza, companheiro animal ou domínio, forma selvagem e conjuração.
- Guerreiro: talentos bônus e proficiências.
- Monge: rajada de golpes, ataques desarmados, movimento, bônus defensivos e demais características.
- Paladino: montaria, detectar o mal, destruir o mal, cura pelas mãos, expulsar mortos-vivos e progressão de magia quando aplicável.
- Patrulheiro: inimigos prediletos, estilo de combate, companheiro animal e progressão de magia quando aplicável.
- Ladino: ataque furtivo, encontrar armadilhas, esquiva sobrenatural e talentos especiais conforme o nível.
- Feiticeiro: magias conhecidas, espaços diários e conjuração espontânea.
- Mago: grimório, aprendizado, preparação, especialização, escolas proibidas, espaços e familiar.

A lista acima é um mapa inicial de cobertura, não substitui a conferência de cada característica nível a nível nas tabelas oficiais.

## Cálculos automáticos

Automatizar somente aritmética e validações determinísticas derivadas das regras, sempre mostrando os componentes do total. Exemplos:

- Ajustes raciais e modificadores de atributos.
- Pontos de perícia por nível e custos de graduações.
- Limites de graduação e pré-requisitos de talentos.
- BBA, salvamentos base, PV e modificadores.
- CA e seus componentes, incluindo limites de DES, tamanho, armadura, escudo e efeitos aplicáveis.
- Bônus de ataque e perícias.
- Espaços de magia, bônus por atributo, CDs e nível de conjurador conforme classe/nível.
- Riqueza inicial, subtotais, saldo, peso e capacidade de carga.
- Deslocamento e alterações documentadas por raça, classe, armadura e carga.

Não automatizar rolagens, decisões narrativas, resolução de testes, interpretação de regras situacionais ou ações de combate para o jogador.

## Princípios de implementação

- Reutilizar arquitetura, tabelas, RPCs, dados e componentes atuais quando corretos.
- Não apagar recursos existentes antes de comprovar que são incompatíveis com o novo escopo.
- Não recriar a ficha do zero nem introduzir multiclasse.
- Separar dados-base, regras/cálculos, escolhas do personagem e apresentação visual.
- Manter compatibilidade com fichas já salvas e planejar migrações sem perda de dados.
- O jogador deve poder consultar a ficha durante a campanha, sem que a tela de consulta ofereça ações de rolagem ou execução de habilidades.
- Não alterar ferramentas do Mestre sem necessidade comprovada.
- Não declarar cobertura ou teste manual concluído sem evidência.

## Plano de auditoria e aceite

1. Inventariar campos, etapas, validações, cálculos, persistência e seções existentes em `ficha.html`, `mesa.html`, tabelas e RPCs.
2. Criar matriz de cobertura para as 11 classes e raças do escopo atual, com linhas por campo/recurso e colunas para criação, persistência, consulta, cálculo e teste.
3. Conferir cada progressão de classe nos níveis 1–20 e marcar recursos automáticos, escolhas do jogador e campos apenas informativos.
4. Identificar lacunas e divergências das regras antes de alterar comportamento.
5. Implementar em mudanças pequenas, compatíveis e verificáveis; validar sintaxe, testes estáticos, persistência e fluxo real de criação/consulta.
6. Validar ao menos personagens representativos de classes marciais, conjuradoras preparadas, conjuradoras espontâneas e classes com recursos especiais; ampliar a cobertura para as 11 classes antes de declarar a etapa concluída.

## Critérios de aceite

- Cada uma das 11 classes básicas pode concluir uma criação completa sem multiclasse.
- A ficha salva e recarregada preserva todas as escolhas e informações.
- A ficha de consulta mostra os campos comuns e todas as seções pertinentes à raça, classe e nível.
- Totais automáticos são corretos, explicáveis e testados contra D&D 3.5.
- O jogador consulta o bônus, rola por conta própria e informa o resultado ao Mestre; não há automação de rolagens no painel do jogador.
- O Mestre mantém as ferramentas próprias já definidas.


## Snapshot da auditoria inicial do projeto (2026-11-16)

Inspeção somente de leitura da implementação e do banco de produção:

- `ficha.html` já implementa seleção de raça/classe, identidade, compra de atributos (25 pontos), perícias, talentos, idiomas, recursos específicos para algumas classes, magia condicional, riqueza/equipamento inicial, revisão, progressão de nível e consulta da ficha.
- O fluxo de criação atualmente apresenta as etapas: Herói/identidade, Classe, Atributos, Treino, Magias (quando aplicável), Equipamento e Revisão. Raça e classe também aparecem como seletores no cabeçalho durante a criação.
- A etapa de identidade exige nome do personagem, sexo, idade, altura, peso e tendência. Não foi identificado nesse bloco um campo explícito para o nome do jogador; verificar se isso é coberto pelo perfil da conta ou se precisa ser exibido na ficha.
- A ficha atual já mostra atributos, defesas, perícias, talentos, idiomas, traços raciais, proficiências, recursos e equipamento. A consulta não deve ser confundida com o painel de execução de ações da mesa.
- O banco possui 11 linhas em `srd_classes`, 7 em `srd_races`, 220 progressões de classe (20 por classe, todas `verified_srd`), 131 características de classe (todas `verified_srd`), 1.400 linhas de progressão de magia (todas `derived_pending_review`) e 607 magias.
- As 11 classes cadastradas estão identificadas como Bárbaro, Bardo, Clérigo, Druida, Feiticeiro, Guerreiro, Ladino, Mago, Monge, Paladino e Patrulheiro.
- As tabelas `srd_character_sheets` e `srd_character_class_levels` existem. A primeira guarda um `classe_id` singular; a segunda é uma estrutura de níveis de classe que exige auditoria de uso. A decisão do produto é manter uma única classe por personagem; não remover tabela ou dados legados sem mapear dependências.
- As 7 progressões mágicas correspondem às classes conjuradoras básicas (Bardo, Clérigo, Druida, Feiticeiro, Mago, Paladino e Patrulheiro), mas seus 1.400 registros ainda não estão aprovados como fonte final.
- O gerador Dyslexic confirma as 11 classes básicas e apresenta várias classes de suplementos. Entretanto, a própria documentação do projeto informa que edição/cálculos/salvamento automáticos não se aplicam às fichas D&D 3.5. Portanto, ele é referência visual/estrutural, não implementação pronta nem prova de cálculo correto.

### Lacunas já identificadas para a próxima rodada

1. Conferir se a ficha expõe o nome do jogador e todos os campos descritivos da folha de referência.
2. Auditar os campos de inventário detalhado: moedas por denominação, recipientes, munição, cargas de varinhas/cajados, itens mágicos e carga total.
3. Comparar as seções e escolhas específicas de cada uma das 11 classes, nível por nível; os 131 registros não bastam por si só para provar que toda característica está representada na ficha.
4. Revisar os 1.400 registros de progressão de magia antes de usá-los para validar criação e consulta.
5. Separar claramente o modo de criação (editável e orientado) do modo de consulta do jogador (somente leitura), sem afetar ferramentas do Mestre.
6. Auditar o uso de `srd_character_class_levels` e das rotinas de avanço para garantir que o fluxo final aceite somente uma classe, preservando compatibilidade com dados existentes.

Nenhuma alteração de aplicação ou banco foi feita durante esta auditoria inicial; o único artefato criado nesta branch é esta especificação de produto.


## Auditoria inicial do painel do jogador na mesa

- `mesa.html` atualmente monta para o jogador grupos de ações: Aventureiro, Perícias e testes, Características, Classe, Magias e, durante combate, Combate/Tática/Turno.
- Esses grupos incluem atalhos de rolagem, testes, conjuração, consulta/uso de habilidades e ações de combate. Esse é o modelo que será simplificado conforme a nova decisão.
- O Mestre tem um conjunto próprio de controles em `renderBotoesAcao()`. Ele deve permanecer independente e preservado nesta mudança.
- A ficha completa já é aberta pelo jogador em um modal/iframe via `abrirFichaModalMesa()`, carregando `ficha.html?char=...`.
- Direção aprovada: o painel do jogador deixa de apresentar categorias e botões de execução. Ele passa a ser uma área de consulta da ficha do personagem ativo. Movimento continua sendo feito diretamente pelo token na mesa; rolagens, testes, interpretação e narração ficam fora desse painel e são conduzidos manualmente conforme o livro e o Discord.
- A auditoria/implementação deve preservar a ficha completa e suas seções consultivas; não basta trocar os botões por uma ficha-resumo que esconda dados necessários. A organização poderá usar navegação interna/abas para manter a leitura clara, mas todas as informações pertinentes precisam continuar acessíveis.


## Primeiro modelo de classe: Mago

A auditoria detalhada inicial do Mago, incluindo inventário do código existente, persistência, progressão, lacunas confirmadas e sequência de implementação, está em [docs/wizard-character-sheet-blueprint.md](wizard-character-sheet-blueprint.md). Este documento deve orientar a primeira implementação da ficha-base e do complemento de Mago; não iniciar uma ficha paralela.
