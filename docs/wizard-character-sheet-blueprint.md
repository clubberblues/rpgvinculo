# Modelo de ficha do Mago — auditoria e plano de implementação

Data: 2026-11-16  
Branch: `feature/complete-character-sheet-rework`  
Escopo: D&D 3.5, Mago (Wizard), classe única, níveis 1–20.

## Objetivo do produto

O jogador cria e preenche uma ficha completa por etapas guiadas. Depois, dentro da mesa, consulta a mesma ficha em modo somente leitura. A ficha apresenta valores calculados e seus componentes; não executa rolagens, conjuração, testes ou resolução de combate. A narração continua no Discord. As ferramentas do Mestre permanecem independentes.

O Mago é o primeiro modelo de validação da ficha-base comum e do mecanismo de seções condicionais por classe. Não será uma ficha isolada nem uma nova aplicação paralela.

## Fontes de regra

- Livro do Jogador D&D 3.5, capítulo de classes, Mago (páginas 55–58 na edição inglesa).
- SRD 3.5: https://www.d20srd.org/srd/classes/sorcererWizard.htm
- Referência de progressão e características: https://www.d20srd.org/srd/classes/sorcererWizard.htm#wizard

A tabela e as escolhas devem ser conferidas contra o Livro do Jogador; o SRD é referência técnica aberta complementar.

## Auditoria do que já existe

### Interface e fluxo (ficha.html, branch atual)

A ficha já contém infraestrutura D&D 3.5 e um fluxo específico de grimório. A inspeção do código identificou:

- Alias de classe `wizard` / `mago`.
- Seção de magias/grimório.
- Estado do grimório com magias conhecidas, preparadas, preparações por domínio, usos e magias aprendidas por nível.
- Fluxo do grimório em etapas `book`, `prepare` e `learn`.
- Seleção de familiar armazenada em `state.identidade.familiar_id`.
- Chamada RPC `salvar_grimorio_srd` para persistência do estado do grimório.
- Talento Escrever Pergaminho descrito na regra do Mago.
- Talento Spell Mastery reconhecido como talento que recebe escolha de magias.
- Criação inicial já envia `p_grimorio` quando a classe usa grimório.

Isso significa que não devemos criar um grimório novo. Devemos auditar e completar a implementação existente, preservando o formato persistido e as rotinas compatíveis.

### Banco de dados (produção, consultas somente leitura)

Classe `mago`:
- Dado de vida: d4.
- BBA: progressão baixa.
- Salvamentos bons: Vontade; Fortitude e Reflexos baixos.
- Perícias por nível: 2 + modificador de Inteligência; multiplicador ×4 no 1º nível.
- Perícias de classe cadastradas: Concentração, Ofício, Conhecimento (qualquer), Profissão e Identificar Magia.
- Proficiências cadastradas: clava, adaga, besta leve, besta pesada e bordão; sem armaduras nem escudos.
- Tendência cadastrada: qualquer.
- Fonte da classe marcada `verified_srd`; isso verifica dados-base, não prova que a experiência completa está integrada.

Progressão:
- Existem 20 linhas em `srd_class_level_progressions` para Mago, marcadas `verified_srd`.
- Existem 5 linhas em `srd_class_level_features`: nível 1 (Invocar Familiar e Escrever Pergaminho), e talentos adicionais nos níveis 5, 10, 15 e 20.
- As cinco linhas de características têm `engine_status: needs_implementation` dentro do JSON de mecânicas. A verificação da fonte não significa que os benefícios estejam totalmente integrados.
- Existem 200 linhas de `srd_spell_level_progressions` para Mago (10 círculos × 20 níveis), todas `derived_pending_review`. Não promover esses dados a fonte final sem revisão.

Persistência disponível:
- `srd_character_spellbook`: character_id, class_id, spell_id, acquired_at, source_note.
- `srd_character_known_spells`: character_id, class_id, spell_id, learned_at_character_level, source_note.
- `srd_character_prepared_spells`: character_id, class_id, spell_id, spell_level, slot_number, prepared_for, expended, source_track.
- `srd_character_spell_slot_state`: character_id, class_id, spell_level, period_started_at, max_slots, expended_slots.
- `srd_character_sheets`: possui classe, raça, nível, atributos, PV, XP, ouro, talentos, magias conhecidas/preparadas, perícias, equipamento inicial, idiomas e identidade.
- `srd_character_feature_resources`: armazenamento genérico de recursos por personagem/chave/payload.
- RPC existente: `salvar_grimorio_srd(p_character_id text, p_estado jsonb)`.

Nas quatro tabelas específicas de grimório/conhecidas/preparadas/espaços, a consulta de produção retornou zero linhas. Isso não prova que a funcionalidade esteja quebrada; indica que não há dados persistidos nessas tabelas neste snapshot e que o fluxo precisa de teste real de gravação e recarga.

### Ponto de atenção encontrado no código

A validação da seleção inicial de magias de 1º círculo calcula a quantidade como `max(0, 3 + modificador de INT)`. A regra é três magias escolhidas, mais uma por ponto de bônus de Inteligência; um modificador negativo não reduz as três magias iniciais. A fórmula deve ser corrigida para `3 + max(0, modificador de INT)` e testada com INT abaixo, igual e acima de 10.

O estado de grimório existente mistura conceitos que precisam ser separados na apresentação e validados na persistência:
1. Magias inscritas no grimório.
2. Magias que o personagem efetivamente aprendeu/tem registradas.
3. Magias preparadas para um dia específico.
4. Espaços diários disponíveis por círculo, incluindo bônus de Inteligência e espaço adicional de especialista.
5. Preparações já gastas, caso a mesa opte por registrar esse acompanhamento na ficha consultiva; não transformar isso em botão de conjuração para o jogador.

## Modelo funcional que o Mago precisa oferecer

### Criação guiada

1. **Identidade e personagem** — nome do personagem, jogador/proprietário, aparência, idade, altura, peso, tendência e divindade quando aplicável.
2. **Raça** — ajustes, tamanho, deslocamento, idiomas, traços e escolhas raciais.
3. **Classe Mago** — classe única, nível inicial, dado de vida, perícias, proficiências, tendência permitida e características.
4. **Atributos** — valores-base, método escolhido pela mesa, ajustes raciais, valores finais e modificadores; Inteligência destaca requisitos, CD e magia bônus.
5. **Perícias e talentos** — pontos calculados, graduações, limites, talentos gerais e talento bônus de Mago quando o nível permitir. Escrever Pergaminho é concedido automaticamente no 1º nível; não deve consumir uma escolha geral.
6. **Magia do Mago** — atributo-chave, nível de conjurador, CD, escolas, grimório inicial, aprendizado, preparação e espaços.
7. **Familiar** — escolha opcional quando o jogador adquire o familiar; registrar tipo/espécie e dados necessários. A ficha detalhada do familiar deve ser uma seção vinculada, não um simples campo de texto.
8. **Equipamento e riqueza** — equipamento inicial, armas, bolsa de componentes, grimório físico/itens, itens mágicos, varinhas/cajados e cargas, munições, recipientes, moedas por denominação, peso/carga.
9. **Revisão** — mostrar ficha inteira, totais calculados, escolhas pendentes, avisos de requisitos e confirmar salvamento.

A ordem pode ser ajustada para manter a experiência intuitiva, mas nenhuma escolha/regra obrigatória pode desaparecer.

### Regras do grimório

- No 1º nível, o grimório contém todas as magias de 0º círculo da lista de Mago, exceto as das escolas proibidas, mais três magias de 1º círculo escolhidas pelo jogador, mais uma magia de 1º círculo por ponto de bônus de Inteligência.
- A cada novo nível de Mago, o personagem adiciona duas magias de qualquer círculo ou círculos que já possa conjurar, respeitando a progressão e as restrições de escola.
- Magias copiadas de outros grimórios devem registrar origem e aquisição; custos, tempo e testes para aprender/copiar devem seguir o Livro do Jogador e não ser presumidos como gratuitos.
- O Mago não pode preparar uma magia que não esteja em seu grimório, exceto Ler Magias, que pode preparar de memória.
- O grimório não é a lista geral de magias do catálogo; é a coleção individual do personagem.

### Especialização

- O jogador pode escolher não se especializar ou escolher uma das oito escolas.
- Se especializar, escolhe escolas proibidas segundo as regras; normalmente duas, com exceção de Adivinhação, que exige apenas uma.
- Adivinhação não pode ser escolhida como escola proibida.
- Universal não é uma escola selecionável como especialização nem como proibida.
- Escolhas ficam permanentes após a criação, salvo regra/decisão explícita do Mestre.
- Especialista recebe um espaço adicional por círculo por dia para magia da escola escolhida e +2 em Identificar Magia para aprender magias dessa escola.
- A interface deve impedir magias proibidas no grimório/preparação e explicar o motivo, mas não executar conjuração.

### Preparação e espaços

- Exibir magias por círculo com espaços-base da progressão do Mago.
- Somar espaços bônus de Inteligência com a regra oficial.
- Somar um espaço adicional por círculo para a escola especializada, conforme regra.
- Mostrar preparação separada do grimório; cada espaço de preparação deve indicar círculo, magia e trilha (normal/especialização, quando aplicável).
- Validar que a magia é elegível para o círculo, que está no grimório, que não pertence a escola proibida e que não excede espaços.
- Preparação diária segue descanso e estudo de uma hora; a ficha apenas registra o estado e informa a regra.
- Não implementar botão de lançar magia, rolagem, gasto automatizado ou resolução de efeito para o jogador.

### Familiar

- O familiar é opcional e segue as regras do Mago.
- Registrar espécie, nome, aparência e estatísticas próprias derivadas do familiar escolhido e do nível efetivo do mestre.
- Exibir benefícios concedidos ao mestre, habilidades especiais e vínculo/distância relevantes.
- Tratar morte, dispensa e substituição conforme as regras; não permitir troca arbitrária.
- Auditar se o catálogo atual contém familiares SRD ou se as opções estão hardcoded; não confundir familiares com companheiros animais de Druida.

### Progressão de classe

- Mago: BBA baixo, Fortitude baixa, Reflexos baixos, Vontade boa; d4; 2 + INT pontos de perícia por nível.
- Características: Invocar Familiar e Escrever Pergaminho no 1º nível; talento bônus de Mago nos níveis 5, 10, 15 e 20.
- O talento bônus de Mago deve aceitar talentos metamágicos, criação de itens ou Spell Mastery, sempre respeitando pré-requisitos e nível de conjurador.
- Além dos talentos bônus de classe, o personagem recebe talentos gerais nos níveis de personagem determinados pela regra comum (1, 3, 6, 9, 12, 15, 18), sem duplicar escolhas.
- A tabela de espaços de magia por nível deve ser confrontada linha a linha com a tabela do Mago no Livro do Jogador/SRD; a coluna `known_spells` não se aplica ao Mago.

## Estrutura de consulta na mesa

A ficha consultiva do Mago deve ter navegação clara, mantendo tudo acessível:
- Resumo do personagem: identidade, nível, PV, atributos, CA, iniciativa, deslocamento, BBA, salvamentos.
- Perícias e talentos.
- Características do Mago e progressão recebida.
- Grimório completo, separado por círculo e escola.
- Preparação diária e espaços, em modo informativo.
- Especialização e escolas proibidas.
- Familiar vinculado.
- Equipamento, itens, componentes, riqueza e carga.
- Idiomas, aparência, histórico e anotações.

Todos os números exibidos devem mostrar a origem do total (base + atributo + racial + equipamento + outros modificadores aplicáveis). Nenhum botão de rolar, conjurar ou executar ação deve aparecer no painel do jogador.

## Matriz inicial de cobertura do Mago

| Recurso | Presença encontrada | Estado real |
|---|---|---|
| Classe, dado de vida, perícias e proficiências | Cadastro de classe | Base verificada; conferir uso no formulário |
| Progressão BBA/salvamentos/perícias 1–20 | 20 linhas | Fonte verificada; validar cálculo na ficha |
| Características de classe | 5 linhas | Fonte verificada; motor marcado needs_implementation |
| Catálogo de magias | Catálogo SRD | Existe; conferir descrições e níveis por classe |
| Grimório individual | UI e tabelas | Infraestrutura existente; gravação/recarga precisa de teste |
| Aprendizado por nível | Estado e UI learn | Conferir duas magias por nível e elegibilidade |
| Preparação diária | UI e tabelas | Infraestrutura existente; validar slots e regras |
| Espaços por nível | 200 linhas | Todas pendentes de revisão |
| Bônus de Inteligência | Cálculo parcial | Conferir fórmula de espaços e magia inicial |
| Especialização/escolas proibidas | Não comprovado integralmente | Auditar UI, estado salvo, restrições e espaços extras |
| Familiar | Campo de seleção e lista de opções | Ficha vinculada, estatísticas e progressão não comprovadas |
| Talentos bônus de Mago | Linhas de progressão | Escolha/requisitos e persistência precisam de teste |
| Escrever Pergaminho | Feature no nível 1 | Confirmar que é automático e não consome talento geral |
| Consulta em mesa | Ficha geral existente | Garantir somente leitura e apresentação integral |
| Nome do jogador/proprietário | Não confirmado | Verificar perfil e exibição |

## Próximas tarefas técnicas, na ordem

1. Auditar no código as funções completas de grimório, preparação, aprendizado, especialização e familiar; localizar exatamente onde os dados são carregados e salvos.
2. Inspecionar a definição e o corpo da RPC `salvar_grimorio_srd`, RLS e políticas das tabelas relacionadas; não alterar produção antes de mapear segurança e compatibilidade.
3. Revisar as 200 linhas de progressão de magia do Mago contra a tabela oficial, incluindo espaços-base e círculos acessíveis.
4. Corrigir a fórmula de magias iniciais apenas após adicionar teste de regressão; não modificar produção até a mudança estar validada em branch/ambiente seguro.
5. Construir testes unitários/estáticos para níveis 1, 5, 10, 15 e 20, atributos INT 8, 10, 14, 18 e 20, especialista e não especialista, e escolas proibidas.
6. Testar criação de Mago nível 1, salvar, sair, recarregar e conferir identidade, atributos, grimório, escolas, familiar, talentos, equipamento e consulta na mesa.
7. Testar progressão para níveis 2, 3, 5, 10, 15 e 20, conferindo duas magias novas por nível e talentos bônus.
8. Só então ajustar a apresentação da ficha e consolidar o modelo reutilizável para as outras classes.

## Restrições

- Não fazer alterações no banco de produção nesta etapa de auditoria.
- Não remover tabelas nem campos legados.
- Não habilitar multiclasse.
- Não automatizar rolagens ou conjuração no painel do jogador.
- Não alterar controles do Mestre.
- Não declarar teste manual concluído sem executar o fluxo real.


## Auditoria aprofundada do código e da RPC (16/11/2026)

### Especialização — UI existe; validação server-side incompleta

A função `dnd35WizardSpecializationMarkup` já oferece universalista ou uma das oito escolas e calcula duas escolas proibidas, ou uma para Adivinhação. O formulário impede, visualmente, repetir a escola especializada e duplicar escolhas.

Entretanto, a RPC `salvar_grimorio_srd` lê `wizard_specialization` e `wizard_prohibited_schools` da identidade, mas a inspeção do corpo da função não encontrou validação server-side de:
- especialização pertencente ao conjunto válido;
- Universal como não selecionável;
- quantidade exata de escolas proibidas (duas, ou uma para Adivinhação);
- escolas proibidas distintas entre si e diferentes da especialização;
- imutabilidade dessas escolhas depois da criação.

Como a RPC é `SECURITY DEFINER`, a validação das regras precisa existir no servidor, e não depender apenas dos controles do navegador. A RPC verifica autenticação e propriedade do personagem, mas isso não substitui a validação semântica das escolhas de escola.

### Familiar — erro de conteúdo já confirmado

A lista atual hardcoded em `dnd35FamiliarChoiceMarkup` tem dez opções, mas não corresponde à tabela de familiares do SRD:
- Inclui **Texugo**, que não é opção padrão de familiar.
- Omite **Doninha** (Weasel), que é opção padrão.
- A lista atual dá ao Rato +3 em Fortitude; o SRD concede +2.
- A lista atual dá ao Texugo +3 em Reflexos; o SRD concede +2 em Reflexos à Doninha.
- O Gato está descrito como +3 em Furtividade, mas a perícia correta é **Mover-se em Silêncio**.
- O texto de vínculo diz 1,5 km; o SRD diz 1 milha.
- O texto diz que níveis de Mago e Feiticeiro se acumulam. Isso é regra geral para personagens que tenham níveis nas duas classes, mas o produto decidiu não permitir multiclasse; na ficha do Mago, a progressão deve usar o nível de Mago, sem sugerir uma opção de multiclasse.
- O próprio código informa que estatísticas completas e progressão do familiar ainda serão conectadas ao bestiário. Portanto, a ficha atual registra a escolha e um benefício resumido, mas não entrega a ficha completa do familiar.

Tabela oficial de benefícios (SRD):
- Morcego: +3 Ouvir.
- Gato: +3 Mover-se em Silêncio.
- Falcão: +3 Observar sob luz intensa.
- Lagarto: +3 Escalar.
- Coruja: +3 Observar na penumbra.
- Rato: +2 em testes de Fortitude.
- Corvo: +3 Avaliação; pode falar um idioma escolhido pelo mestre.
- Cobra (víbora Miúda): +3 Blefar.
- Sapo: +3 PV.
- Doninha: +2 em testes de Reflexos.

O SRD também exige a ficha do familiar: DV, PV (metade dos PV do mestre, arredondado para baixo), ataques, salvamentos, perícias, talentos, armadura natural, Inteligência e habilidades progressivas. A progressão por nível do mestre concede benefícios cumulativos: 1–2, 3–4, 5–6, 7–8, 11–12 e 13–14, conforme a tabela de familiares. Isso não deve ser substituído por um nome e um bônus fixo.

### Grimório — discrepância entre UI e RPC na contagem inicial

A interface usa `Math.max(0, 3 + modificador de INT)` para a quantidade inicial de magias de 1º círculo. A RPC usa uma condição diferente (`INT >= 11`) e, abaixo disso, define capacidade zero. Essas regras divergem para INT abaixo de 11 e podem permitir que UI e servidor aceitem/rejeitem estados diferentes.

A regra de criação do grimório deve ser modelada literalmente:
- base de três magias de 1º círculo;
- uma adicional por ponto de bônus de Inteligência;
- atributo mínimo de 10 + círculo para aprender, preparar ou conjurar uma magia daquele círculo.
Separar o conteúdo inicial do grimório da capacidade atual de preparar/conjurar. A validação deve decidir claramente o tratamento de personagens com Inteligência insuficiente para círculos específicos, sem reduzir silenciosamente as três escolhas iniciais.

### Progressão mágica — duas fontes com status diferentes

- `srd_spell_level_progressions`: 200 linhas para Mago, 10 círculos × 20 níveis, todas `derived_pending_review`.
- `srd_spell_progressions`: contém um vetor `slots_by_level` para Mago com 20 níveis; a RPC atual `salvar_grimorio_srd` consulta essa tabela para validar círculos acessíveis e calcular capacidade por meio de `_srd35_slots`.
- O vetor `slots_by_level` foi comparado com a tabela SRD consultada: os valores-base visíveis para Mago seguem a progressão oficial de 1º a 20º nível; círculos ainda não acessíveis estão representados por -1.
- Ainda é necessário identificar a origem, versionamento e mecanismo de geração desse vetor, e garantir que bônus de Inteligência e espaço de especialista sejam adicionados uma única vez. Não substituir a fonte ativa sem mapear dependências.

### Segurança e persistência

A RPC `salvar_grimorio_srd` é `SECURITY DEFINER`, exige `auth.uid()`, verifica se o personagem pertence ao usuário autenticado e bloqueia a ficha para atualização. As políticas SELECT das tabelas específicas permitem leitura pelo proprietário e Mestre. A ficha principal tem políticas próprias de leitura/atualização por proprietário ou campanha.

Não foi executada gravação de teste nem alteração em produção. O retorno zero linhas nas tabelas de grimório significa que a persistência ainda não foi comprovada por um personagem real neste ciclo de auditoria.

### Ajustes prioritários antes da implementação visual

1. Corrigir catálogo e descrições dos familiares usando a tabela oficial.
2. Criar ficha vinculada completa do familiar com estatísticas e progressão.
3. Unificar a fórmula de magias iniciais na UI e RPC, com testes para INT 8, 10, 11, 12, 14, 18 e 20.
4. Adicionar validação server-side da especialização e escolas proibidas.
5. Validar o grimório inicial com todos os truques permitidos, magias iniciais, escolas proibidas e requisito de atributo por círculo.
6. Confirmar se a preparação respeita slots-base, bônus de Inteligência e slot adicional de especialista sem dupla contagem.
7. Testar gravação e recarga de personagem Mago em ambiente seguro antes de tocar no banco de produção.
8. Só depois completar a tela consultiva da ficha e conectar a ficha vinculada do familiar.

Fontes SRD usadas nesta auditoria:
- Mago, tabela de progressão, grimório, especialização e familiares: https://www.35srd.com/players/classes/base-classes/wizard/
- Referência alternativa de Mago e magia: https://www.d20srd.org/srd/classes/sorcererWizard.htm
