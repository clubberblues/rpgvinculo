# Especificação de ficha — Mago D&D 3.5

**Status:** primeira ficha-modelo em definição e implementação  
**Escopo:** personagem Mago de nível 1–20, classe única, regras D&D 3.5.

## 1. Objetivo

Construir o Mago como primeira implementação real da ficha-base compartilhada. Reaproveitar o fluxo e o armazenamento já existentes em vez de criar uma aplicação ou grimório paralelo. A ficha deve orientar a criação, explicar as escolhas e depois permanecer integralmente editável.

## 2. Princípio de funcionamento

- **Criação:** fluxo guiado, sequencial, com explicações, opções válidas, pré-requisitos e validações das regras de criação.
- **Ficha de campanha:** documento completo, consultável e editável pelo jogador. Todos os registros pertinentes podem ser adicionados, alterados ou apagados.
- **Mestre:** clicar no token abre a ficha daquele personagem, sem painel de ações.
- **Jogador:** acessa a própria ficha e a rolagem de dados. A ficha não executa testes, ataques, conjurações ou habilidades.
- **Inventário:** lista narrativa de itens. Cada registro pode ter nome, descrição, quantidade e anotações livres. Não classificar em equipado/guardado/consumível e não aplicar efeitos ou bônus de itens aos atributos.

## 3. Estrutura visual e conteúdo

### A. Identidade e descrição
- Nome do personagem e jogador (o vínculo do jogador pode vir do perfil autenticado).
- Raça, classe, nível, tendência, divindade quando aplicável.
- Sexo, idade, altura, peso, aparência, personalidade, história, origem, retrato/ilustração opcional.
- Experiência atual e observações de progressão.

### B. Atributos
- Força, Destreza, Constituição, Inteligência, Sabedoria e Carisma.
- Valor base, ajuste racial, valor final e modificador, com origem dos valores identificável.
- Método de geração escolhido para a campanha e registro do resultado.
- A ficha apresenta os valores; não tenta interpretar efeitos narrativos externos.

### C. Resumo de personagem e combate (informativo)
- Pontos de vida e dado de vida.
- Classe de armadura e componentes registrados/derivados da criação.
- Iniciativa, deslocamento, tamanho.
- Bônus base de ataque e ataques/armas registrados.
- Fortitude, Reflexos e Vontade.
- Valores necessários para consulta e rolagens manuais. Não há execução de ataques, testes ou combate.

### D. Perícias
- Lista de perícias, atributo-chave, graduações, custo, classe/fora de classe e modificadores pertinentes.
- Na criação, orientar pontos disponíveis, limites e custos conforme nível e Inteligência.
- Após a criação, permitir editar graduações e anotações sem obrigar o usuário a refazer o assistente; sinalizar inconsistências de regra quando útil, sem bloquear registros narrativos.

### E. Talentos
- Talentos escolhidos, descrição em português, fonte, nível em que foi adquirido e escolhas/parâmetros exigidos.
- Na criação/progressão, orientar quantidade, pré-requisitos e talentos bônus de Mago.
- Permitir registrar talentos adquiridos durante a campanha.

### F. Raça e classe
- Características raciais completas pertinentes à raça escolhida.
- Características de Mago pertinentes ao nível, com descrição e nível de aquisição.
- Proficiências, perícias de classe, dado de vida, progressões e demais informações específicas.
- Não criar botões para ativar habilidades nem aplicar efeitos durante a sessão.

### G. Grimório e magia do Mago
- Grimório com magias registradas por círculo, nome, descrição e anotações.
- Distinguir claramente magias copiadas/aprendidas e magias preparadas, pois são informações distintas do Mago.
- Registrar escolas, especialização e escolas proibidas, quando aplicável.
- Registrar espaços de magia por círculo e informações de conjuração pertinentes ao nível e à Inteligência.
- Permitir anotações sobre origem, custo, tempo de aprendizado, cópia e outras circunstâncias de campanha.
- Familiar opcional, com espécie, nome e informações próprias.
- Nenhum botão de conjurar, gastar espaço, resolver magia ou aplicar efeito. A preparação é um registro da ficha, não uma execução de jogo.

### H. Equipamentos e inventário
- Lista livre de itens pertencentes ao personagem.
- Campos simples: nome, descrição, quantidade opcional, peso/valor se o jogador quiser registrar, observações.
- Não exigir categoria, estado equipado/guardado/consumível, cargas controladas, integração com catálogo completo ou aplicação automática de efeitos.
- O jogador pode adicionar, editar e apagar itens durante a campanha.

### I. Idiomas, recursos e registros
- Idiomas e alfabetização quando aplicável.
- Dinheiro e tesouros como registros editáveis.
- Anotações, contatos, pistas, conquistas, acontecimentos e informações narrativas.
- Campos adicionais pertinentes à ficha física de D&D 3.5, sem automatizar a sessão.

## 4. Etapas propostas para criação

1. Identidade e conceito.
2. Raça e características raciais.
3. Classe Mago e explicação de suas regras.
4. Atributos e modificadores.
5. Perícias.
6. Talentos e escolhas exigidas.
7. Especialização arcana, escolas proibidas e familiar.
8. Grimório inicial e preparação inicial, conforme regras aplicáveis.
9. Equipamento e riqueza inicial (registro simples; sem motor de itens).
10. Revisão integral, explicação dos resultados e confirmação.

A ordem pode ser ajustada após a auditoria do fluxo existente, mas nenhum conteúdo necessário pode ser omitido. A criação deve salvar progresso sem exigir que todas as etapas sejam concluídas numa única sessão.

## 5. Regras do Mago que exigem validação

Conferir diretamente no Livro do Jogador/SRD 3.5 antes de implementar:
- Dado de vida d4; BBA baixo; Vontade boa; Fortitude e Reflexos baixos.
- 2 + modificador de Inteligência pontos de perícia por nível (×4 no primeiro nível).
- Perícias de classe e proficiências.
- Progressão de magias por círculo e espaços por nível; requisito de Inteligência para conjurar; magias bônus por Inteligência.
- Grimório inicial, truques, magias iniciais de 1º círculo e aquisição de duas magias por nível subsequente, respeitando círculos que pode conjurar e escolas proibidas.
- Especialização: escola escolhida, escolas proibidas, exceção de Adivinhação, efeitos da especialização e permanência da escolha.
- Familiar opcional e regras completas de familiar, incluindo espécie, estatísticas e progressão.
- Escrever Pergaminho no 1º nível e talentos bônus de Mago nos níveis 5, 10, 15 e 20; escolhas e pré-requisitos.
- Talentos gerais por nível de personagem, distintos dos talentos bônus de classe.
- Progressão completa até o nível 20.

Os dados catalogados atualmente marcados `derived_pending_review` ou `needs_implementation` não podem ser tratados como validados apenas por estarem no banco.

## 6. Persistência e edição

Auditar e reutilizar o fluxo existente de ficha e grimório. Não criar tabelas ou RPCs paralelas antes de provar que a estrutura atual não atende.

Para cada seção, verificar:
- criação e gravação;
- recarga após sair e entrar;
- inclusão de novos registros;
- edição de registros existentes;
- exclusão quando aplicável;
- vínculo correto ao personagem e controle de propriedade;
- apresentação completa para jogador e Mestre.

A edição cotidiana deve ser simples e independente do assistente de criação. O usuário deve poder editar livremente as anotações e registros da campanha.

## 7. Fora do escopo
- Motor de combate, ataques, dano e turnos.
- Execução de testes, perícias ou rolagens pela ficha.
- Conjuração automatizada e consumo automático de espaços.
- Ativação de habilidades, talentos ou características.
- Cálculo automático de efeitos de armas, armaduras, itens mágicos ou inventário.
- Classificação obrigatória de itens em equipados, guardados ou consumíveis.
- Automação de regras narrativas ou decisões do Mestre.

## 8. Critérios de aceite da primeira ficha-modelo

- Criar um Mago de 1º nível pelo fluxo guiado.
- As escolhas e consequências são explicadas e as regras aplicáveis são validadas.
- Todas as seções acima aplicáveis estão presentes.
- Salvar, sair e recarregar preserva os dados.
- Jogador consegue adicionar, editar e apagar registros da ficha durante a campanha.
- Grimório, preparação, especialização, escolas proibidas e familiar são preservados corretamente.
- Inventário funciona como lista narrativa editável, sem cálculo automático.
- Jogador tem somente acesso à ficha e rolagem de dados no painel.
- Clicar no token como Mestre abre a ficha correspondente.
- Nenhuma automação de sessão foi introduzida.


## 9. Auditoria do código existente — 2026-11-16

A leitura de `ficha.html` confirmou que há uma base SRD 3.5 real para criação e consulta, mas o modo de ficha persistida ainda não atende à edição integral:

- O fluxo de criação existente tem etapas de Identidade, Classe, Atributos, Treino, Magias (condicional), Equipamento e Revisão. O fluxo já valida compra de atributos, perícias, talentos, idiomas, escolhas de classe e magias.
- O modo persistido renderiza perícias e talentos como conteúdo somente de leitura. A identidade e os atributos também não têm edição geral visível. Portanto, edição integral da ficha é uma lacuna de implementação, não uma função já concluída.
- O grimório possui fluxo próprio e persistência por RPC, mas a interface também exibe controles de descanso/recursos que precisam ser separados da simples consulta e edição de registros.
- A seção atual de equipamento SRD exige itens do catálogo, classifica armas/armaduras/acessórios, distingue equipado/guardado e permite equipar/desequipar. Também chama rotinas de deslocamento e CA. Isso contradiz a decisão vigente e deve ser substituído por inventário livre, editável e sem aplicação de efeitos.
- A etapa de equipamento da criação atualmente exige pacote recomendado ou compras no catálogo dentro do orçamento inicial. O novo fluxo deverá continuar explicando riqueza inicial quando pertinente, mas não obrigará o jogador a cadastrar cada objeto em catálogo nem bloqueará a criação por não usar o gerenciador de itens.
- O RPC `finalizar_criacao_personagem_srd` cria a ficha e grava escolhas, idiomas, talentos bônus, domínios, grimório e equipamento inicial em transação. Ele é a base atual a preservar e auditar, não deve ser substituído sem necessidade.
- `srd_character_sheets.equipamento_inicial` guarda dados de equipamento inicial; `srd_character_equipment` e `srd_character_weapon_instances` implementam o antigo modelo de catálogo/equipamento. O inventário narrativo livre deve ter persistência própria ou estrutura apropriada; não reutilizar esses campos sem migração planejada.
- A ficha do Mago já tem seleção de especialização, escolas proibidas, familiar, grimório, magias e progressão de espaços. A auditoria anterior identificou divergências de validação e de catálogo que ainda precisam ser concluídas.

### Modelo recomendado para inventário livre

Criar uma estrutura simples de registros vinculados ao personagem, sem FK para catálogo e sem colunas de categoria, equipado, guardado ou consumível. Campos mínimos sugeridos: identificador, character_id, nome, descrição, quantidade opcional, observações e timestamps. O jogador proprietário poderá incluir/editar/excluir; o Mestre da campanha poderá consultar a ficha. Essa estrutura depende de migração e políticas RLS testadas; nenhuma alteração de banco foi feita nesta etapa.

### Regra para etapa de equipamento da criação

A etapa permanece apenas como orientação e registro opcional do que o personagem começa possuindo. Ela não deve exigir kit do catálogo, estado de equipamento, cálculo de efeito ou preenchimento obrigatório de cada item. A riqueza inicial pode ser explicada conforme a classe e o método definido para a campanha; a lista de itens é narrativa e livre.


## 10. Diretriz visual e campos manuais de equipamento — decisão confirmada em 2026-11-16

A seção de equipamentos não será um único campo genérico e tampouco um sistema de inventário. Ela deve ser uma parte visualmente organizada da ficha, com espaços específicos e intuitivos para escrita manual. O jogador registra os detalhes que considerar necessários.

A interface deve oferecer, no mínimo, áreas distintas para:
- **Armas:** várias entradas independentes, cada uma com espaço para nome e detalhes livres (por exemplo, ataque, dano, alcance, propriedades, observações).
- **Munições:** entradas próprias para tipo e quantidade/anotações, permitindo registrar diferentes tipos.
- **Armaduras e proteção:** espaços de escrita para nome e detalhes anotados pelo jogador.
- **Equipamentos e objetos:** várias entradas independentes para ferramentas, vestuário, itens de viagem e outros pertences.
- **Itens mágicos e especiais:** entradas livres para descrição, propriedades, cargas ou efeitos anotados manualmente.
- **Dinheiro, tesouros e outros recursos:** espaços organizados para registrar valores e achados.

O jogador pode acrescentar, editar e apagar entradas livremente, inclusive depois que o Mestre conceder algo durante a campanha. Não há validação de catálogo, cálculo, classificação, vínculo com dados de armas, detecção de item equipado ou efeito automático na ficha. Uma entrada é somente um registro escrito pelo jogador.

### Criação guiada versus ficha durante a campanha

Na criação, o assistente do Mago explica as regras relevantes: proficiências, equipamento inicial permitido, riqueza inicial e escolhas que dependem de classe/raça. A orientação ajuda o jogador a entender o que seu personagem começa possuindo e oferece campos adequados para registrar as escolhas. Ela não deve obrigar a selecionar objetos de um catálogo nem transformar o registro de equipamento em um subsistema.

Depois da criação, a mesma seção continua disponível para edição livre. O jogador pode anotar qualquer item recebido, perder, vender, trocar ou alterar detalhes narrativos sem reabrir o assistente nem passar por validações de equipamento.

### Auditoria visual obrigatória

Antes de redesenhar, inspecionar o layout real da ficha atual e os modelos físicos/digitais de ficha D&D 3.5 já usados como referência. Identificar quais blocos e lacunas visuais podem ser reaproveitados e quais precisam ser adaptados. Não substituir uma ficha intuitiva por formulários genéricos ou uma caixa de texto única.

## 11. Direção visual gamificada para o preenchimento manual

A ficha deve parecer uma bancada de preparação do aventureiro, não um formulário administrativo. O estilo deve reforçar a fantasia sem alterar as regras ou automatizar o conteúdo anotado.

- **Armas:** cartões individuais com moldura e espaço para nome/detalhes livres; várias entradas podem ser acrescentadas.
- **Munições:** representação em cartuchos, pequenas cápsulas ou fileiras de marcadores. Cada registro permite escrever o tipo e a quantidade manualmente; os marcadores são apenas uma representação visual, não um contador que consome munição.
- **Armaduras e proteção:** placas/insígnias de equipamento com campos escritos pelo jogador.
- **Objetos e provisões:** cartões menores organizados por espaço visual, sem categoria técnica obrigatória.
- **Itens mágicos/especiais:** cartões com moldura mais rara, brilho discreto ou selo arcano, sem conceder bônus automáticos.
- **Dinheiro e tesouros:** bolsas, moedas ou pequenas fichas visuais para valores escritos manualmente.
- **Microinterações:** animação curta ao revelar/adicionar/remover um registro, realce ao focar um campo e transições suaves ao alternar seções. Não usar animações contínuas que distraiam.
- **Acessibilidade:** respeitar `prefers-reduced-motion`, manter foco visível, contraste legível e controles utilizáveis por teclado e toque.

### Estado da implementação visual

Foi aplicado um primeiro passe visual ao bloco de equipamento inicial existente: cabeçalho de arsenal, placas para as escolhas atuais, cartões e animações discretas. Esse passe não substitui o fluxo legado de catálogo nem implementa ainda os campos livres repetíveis de munição/armas/objetos. A substituição funcional depende da auditoria e adaptação do formato de persistência já existente, sem criar tabela de inventário nem alterar o banco de produção nesta etapa.

## 12. Estado funcional atualizado — campos livres de equipamento

A primeira implementação dos campos repetíveis foi concluída no fluxo de criação e na ficha pós-criação:

- Seis blocos independentes: armas, munições, armaduras/proteção, equipamentos/objetos, itens mágicos/especiais e dinheiro/tesouros.
- Cada bloco aceita quantas entradas forem necessárias; cada entrada oferece nome, quantidade/valor e detalhes em texto livre, com edição e remoção.
- Cartuchos e molduras são elementos de apresentação. Não representam inventário, não consomem munição e não calculam valores.
- O resultado de riqueza inicial é rolado de acordo com a classe. Para o Mago, 3d4 × 10 po; a compra de itens não é calculada nem descontada.
- Durante a criação, as anotações seguem junto ao JSON de identidade no RPC existente. Após a criação, a ficha recupera os mesmos dados em modo de consulta. A edição posterior aguarda uma RPC segura específica; o usuário autenticado não possui UPDATE direto na tabela.
- O fluxo ativo não consulta catálogo de equipamentos nem pacotes de itens, e não oferece equipar/desequipar.

### 13. Estado de criação do Mago e pendências conhecidas

- A especialização e o número de escolas proibidas são validados no cliente e no servidor.
- Os truques permitidos são incluídos automaticamente no grimório inicial; as escolas proibidas são excluídas. A seleção de magias de 1º círculo respeita o requisito de Inteligência mínima 11 para aprender/conjurar esse círculo.
- Escrever Pergaminho é concedido automaticamente no nível 1 pela rotina existente de talentos bônus.
- O catálogo atual possui 19 truques e 43 magias de 1º círculo para Mago. A progressão de espaços do Mago foi conferida até o nível 20.
- **Pendência que impede considerar o fluxo totalmente homologado:** o RPC de criação ainda aceita `badger` em vez de `weasel` na lista de familiares. A interface SRD oferece Doninha; a seleção pode ser rejeitada pelo servidor até uma migration corrigir essa allowlist. A escolha de familiar é opcional.
- A implementação ainda precisa de teste de navegador e criação autenticada para homologação. Nenhum teste funcional é declarado nesta etapa.

## Atualização de implementação — 2026-11-16

Os seis grupos de registros livres já possuem interface editável também na ficha persistida. A gravação é feita pela RPC dedicada `salvar_anotacoes_equipamento_srd`, preparada em migration no branch de trabalho. A interface de edição não deve usar UPDATE direto em `srd_character_sheets`.

A opção Doninha permanece disponível no cliente e é aceita pela migration preparada, que substitui Texugo na allowlist de familiares básicos do RPC. Familiar continua opcional e meramente informativo na ficha.

**Estado de homologação:** a migration ainda não foi aplicada ao Supabase; a edição pós-criação e a escolha Doninha não estão funcionais na instância publicada até a aplicação da migration. Ainda faltam testes autenticados em navegador e auditoria de edição das demais seções.

### Idiomas — exceção do Mago

O Mago pode substituir uma das escolhas de idioma bônus disponíveis pela raça por Dracônico. A criação deve oferecer essa opção mesmo quando a lista racial normal não contém Dracônico, sem permitir repeti-la nem alterar as regras das outras classes. A migration preparada limita a exceção à criação de Mago de 1º nível.

## 10. Equipamento inicial e riqueza — sem fluxo de compra
A etapa de equipamento não terá loja, compra, catálogo de itens, preços, orçamento, peso ou aplicação automática de efeitos. Os campos livres existentes servem apenas para registrar o que o personagem possui. Quando o Livro do Jogador 3.5 apresentar um pacote inicial aplicável à combinação raça/classe, os itens são inseridos automaticamente nas categorias correspondentes. Quando não houver pacote aplicável, os campos de itens ficam vazios; não inventar kits.

Para **Elfo + Mago**, registrar o pacote inicial do Mago Elfo (Livro do Jogador, p. 58) nos campos livres:
- **Armas:** bordão e besta leve.
- **Munições:** estojo com 10 virotes.
- **Equipamentos e objetos:** mochila, cantil, rações de viagem para um dia, saco de dormir, saco, pederneira e isqueiro, dez velas, estojo de mapas, três folhas de pergaminho, tinta e pena.
- **Itens mágicos/especiais:** bolsa de componentes de magia e livro de magias. O conteúdo do grimório é detalhado separadamente na seção de Magias.
- **Armaduras e proteção:** sem item inicial no pacote.

A riqueza inicial é uma rolagem separada no fluxo de criação, sem compra de itens. Para Mago, o jogador rola **3d4 × 10 PO**; os resultados são validados e o saldo final é salvo no campo de ouro da ficha. Essa combinação entre anotações do pacote e rolagem da riqueza é a decisão de produto atual. O sistema não desconta valores nem calcula compras. A roupa comum gratuita permanece como escolha simples entre os trajes do livro.
## 11. Direção visual vertical — correção 2026-11-17
A ficha deve ser uma coluna vertical de leitura contínua. Painéis principais, lista de perícias, lista de magias e grupos de pertences ficam empilhados. A identidade visual deve seguir a mesa: carvão profundo, grafite, superfícies escuras, bronze discreto e tipografia moderna Inter/Cinzel/EB Garamond. Não usar o verde como cor de identidade. Perícias devem comunicar de forma concisa: nome, atributo-chave, graduações, condição de classe/fora de classe, modificadores aplicáveis e bônus total. Explicações extensas ficam recolhidas em detalhes, quando possível.
