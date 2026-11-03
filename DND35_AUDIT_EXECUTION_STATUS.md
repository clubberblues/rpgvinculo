# Auditoria D&D 3.5 — execução contínua

**Branch de trabalho:** `audit/dnd35-rules-alignment`  
**Arquivos prioritários:** `ficha.html`, `mesa.html`  
**Norma de referência:** Livro do Jogador e Livro do Mestre D&D 3.5 enviados nesta conversa. Livro dos Monstros ainda pendente.  
**Estado:** alterações versionadas na branch de auditoria; ainda não mescladas à branch principal.

## Implementado nesta rodada

- Riqueza inicial por classe, com quantidade de d4 e multiplicador próprios.
- Conversão de peso por origem do registro: itens importados do SRD em libras são convertidos para kg; itens legados já métricos permanecem inalterados.
- Cálculo de carga pela Força, tamanho, peso transportado e moedas.
- Deslocamento efetivo com penalidades de armadura/carga, exceção racial dos anões, Movimento Rápido do Bárbaro e progressão de Movimento Rápido do Monge.
- Movimento livre fora de combate; validação de turno e deslocamento durante combate.
- Ocupação de tokens por tamanho, incluindo Grandes, Enormes, Imensos e Colossais.
- Névoa de guerra com ocultação/revelação geral e individual, persistência e sincronização.
- Testes de resistência D&D 3.5: Fortitude, Reflexos e Vontade, com progressão de classe, modificador de atributo e bônus raciais situacionais.
- Penalidade de -4 em ataques com armas sem proficiência, respeitando proficiências específicas por classe e familiaridade anã com machado de guerra/urgrosh.
- Bônus raciais em combate: ataque de anões/gnomos contra criaturas apropriadas, CA de anões/gnomos contra gigantes e bônus de halflings com armas arremessadas/fundas.
- Bônus raciais condicionais em salvamentos e perícias: veneno, magia, ilusão, medo, pedra, metal e alquimia.
- Lista final de talentos separa características automáticas de classe; talentos bônus escolhidos pela classe recebem identificação própria.
- Metadados de auditoria de características de classe atualizados para indicar implementação parcial, sem marcar como concluídas características ainda pendentes.
- Tradução em português ampliada para armas, armaduras, equipamentos e talentos comuns, com descrições revisadas para os talentos mais usados.

## Ajuste realizado nesta continuação

- Revisão textual da Fúria do Bárbaro na ficha: esclarecido que o aumento de Constituição eleva os PV em 2 por nível enquanto durar a fúria (não são PV temporários), que a queda dos PV ao término pode incapacitar/matar o personagem e que Fúria Incansável remove a fadiga. Esta correção de regra/descrição não significa que a ativação e os efeitos dinâmicos já estejam implementados.

## Correções adicionais desta continuação

- Correção de regra do Bárbaro: alfabetização custa 2 pontos de perícia uma única vez e abrange os idiomas que o personagem já sabe falar; não é cobrada por idioma. A fadiga após a Fúria permanece até 8 horas de descanso completo, salvo Fúria Incansável — não termina automaticamente com o encontro.
- Verificação de dados SRD: progressão do Bárbaro contém Fúria 1/2/3/4/5/6 por dia nos níveis 1/4/8/12/16/20, Fúria Maior no 11, Fúria Incansável no 17 e Fúria Poderosa no 20. Os registros estão verificados contra a progressão SRD; os efeitos ativos ainda não estão conectados ao motor.

## Integração inicial de condições na Mesa

- Criadas funções seguras no Supabase para o Mestre aplicar e remover condições D&D 3.5 por campanha, com validação de autenticação, papel de Mestre, alvo pertencente à campanha e condição existente no catálogo SRD.
- A aplicação registra rodada inicial, duração em rodadas (ou duração indefinida) e metadados de origem; reaplicar a mesma condição ao mesmo alvo substitui a instância ativa anterior para evitar duplicação acidental.\n- O avanço de turno agora chama uma rotina segura que desativa condições temporizadas quando a rodada atual alcança a rodada de expiração; condições sem duração permanecem ativas até remoção manual.
- O menu contextual de cada token agora oferece **Administrar condições D&D 3.5** para o Mestre, tanto em personagens jogadores quanto em NPCs/monstros. A interface consulta o catálogo SRD, permite aplicar ou remover condições e publica o evento no chat/log.
- O catálogo e os registros são os já existentes em `srd_conditions` e `srd_campaign_conditions`; não foi criado um estado paralelo na ficha.

**Limite desta entrega:** esta etapa permite administrar e persistir condições, mas ainda não aplica automaticamente todos os modificadores nas jogadas de ataque, CA, salvamentos, perícias, deslocamento, ações e ataques de oportunidade. A expiração por rodada já foi conectada ao avanço de turno; ainda precisa ser validada em uma sessão autenticada com múltiplos combatentes e rodada completa. Portanto, condições continuam sendo um módulo parcialmente implementado.

## Testes executados

- Sintaxe JavaScript de `ficha.html` e `mesa.html`: sem erros.\n- Sintaxe do script atualizado de `mesa.html`: validada após a inclusão do gerenciador de condições.\n- Funções RPC de aplicar/remover condições: criação confirmada no Supabase; teste funcional autenticado ainda pendente.
- Riqueza inicial: 11/11 classes conferidas.
- Movimento: 8 cenários de Bárbaro (anão/humano, sem armadura, armadura média/pesada e carga pesada) aprovados.
- Movimento do Monge: progressão de nível 3 e 6 conferida.
- Carga mista: item legado em kg + item importado em lb conferidos em conjunto.
- Anão Bárbaro N1: ajustes raciais aplicados (CON +2, CAR -2), PV 15 com CON 16, Fortitude boa, Reflexos/Vontade ruins e deslocamento efetivo de 9 m.
- Bônus raciais de ataque, CA, salvamentos e perícias: testes funcionais executados.
- Proficiência: Bárbaro com espada longa sem penalidade; Mago com adaga sem penalidade; Mago com espada longa recebe -4; familiaridade anã com machado de guerra trata a arma como marcial.
- Ocupação de grid: tamanhos e colisão de tokens conferidos.

## Limites confirmados nesta continuação

- `mesa.html` agora consulta e administra `srd_campaign_conditions` pela interface do Mestre. A integração ainda é parcial: os modificadores mecânicos de cada condição não foram aplicados de forma transversal aos ataques, CA, salvamentos, perícias, movimento e ações. As características ativáveis de classe também continuam pendentes.

## Pendências de auditoria e implementação

1. Fúria do Bárbaro: ativação, usos diários, duração por rodada, bônus de FOR/CON, bônus de Vontade, penalidade de CA, ajuste de PV decorrente da CON temporária, estados de inconsciência/morte ao encerrar e fadiga por 8 horas.
2. Analfabetismo do Bárbaro: texto corrigido; falta implementar a escolha de alfabetização por 2 pontos de perícia e persistir essa escolha.
3. Proficiências de armas/armaduras/escudos, penalidade por não proficiência e familiaridade racial anã.
4. Traços raciais ainda não aplicados em todos os fluxos, incluindo visão no escuro/penumbra e verificações automáticas de Conhecimento de Pedras.
5. Progressão integral de características de todas as classes, separando o que é automático, escolha do jogador e administração do Mestre.
6. Perícias: pontos por classe/nível, graduações máximas, perícias exclusivas de classe e requisitos de uso sem treinamento.
7. Talentos: completar a tradução de todos os nomes e descrições (a cobertura atual é parcial), revisar pré-requisitos, talentos bônus por classe, níveis de aquisição e validação no avanço de nível.
8. Equipamentos: completar a tradução individual das descrições do catálogo e validar peso/preço/requisitos de cada registro importado.
9. Magias: preparação, espaços, componentes, escolas, CDs, resistência à magia e limites por classe/nível.
10. Combate: ações padrão/movimento/rodada completa, ataques múltiplos, ataques de oportunidade, agarrar, derrubar, encontrão, cobertura, ocultação e condições.
11. Ficha: PV, CA, BBA, ataques, dano, salvamentos, carga, equipamento e recursos recalculados após avanço de nível.
12. Mestre/NPCs: fichas, blocos de estatísticas, habilidades especiais e aplicação das mesmas regras sem exigir interface de jogador.
13. Livro do Mestre: terminar o cruzamento das regras de campanha, encontros, tesouro, descanso, condições e administração.
14. Livro dos Monstros: integrar quando for enviado, sem bloquear os itens acima.

## Regra de execução

Não marcar um módulo como concluído apenas porque existe uma descrição ou um botão. A conclusão exige regra do livro identificada, implementação, validação de dados, teste funcional e verificação da interface. Mudanças permanecem na branch de auditoria até revisão final.


## Etapa Anão A1 — identidade, idade, corpo e idiomas

**Estado: implementação concluída; validação autenticada de ponta a ponta pendente.**

- O fluxo inicial de criação foi limitado temporariamente à raça Anão, mantendo disponíveis as 11 classes básicas já cadastradas. A classe favorecida Guerreiro não bloqueia nenhuma outra classe.
- A identidade agora solicita sexo, idade, altura, peso e tendência. Altura e peso podem ser definidos manualmente ou gerados com os dados e as fórmulas da Tabela 6-6 do Livro do Jogador.
- Idade mínima do Anão passa a considerar a idade adulta (40 anos) e a quantidade de d6 da Tabela 6-4 por classe: 3d6 para Bárbaro/Ladino/Feiticeiro; 5d6 para Bardo/Guerreiro/Paladino/Patrulheiro; 7d6 para Clérigo/Druida/Monge/Mago.
- O motor aplica os modificadores cumulativos de envelhecimento do Anão: maturidade a partir de 125 anos, velhice a partir de 188 e venerável a partir de 250; os atributos exibidos e os PV iniciais são recalculados com esses ajustes.
- Tendências disponíveis são filtradas por classe: Bárbaro/Bardo não Leal; Druida neutro; Monge Leal; Paladino Leal e Bom. Clérigo fica pendente da seleção de divindade, que precisa validar a tendência em relação à divindade escolhida.
- A aba de Treino ganhou uma interface de Idiomas: automáticos Comum/Anão; escolhas adicionais raciais conforme o modificador de Inteligência; idiomas comprados por graduações inteiras de Falar Idioma.
- O catálogo existente `srd_languages` (19 idiomas públicos e 1 idioma secreto) foi reutilizado. A RPC existente `salvar_idiomas_personagem_srd` é chamada no salvamento e valida idiomas automáticos, opções raciais, Inteligência, graduações compradas e duplicidades.
- Para persistir escolhas sem espalhar colunas específicas, foi adicionada somente a coluna JSONB `srd_character_sheets.identidade`. A idade também é gravada no campo `characters.idade` já existente.
- Foi criada uma sobrecarga de `criar_personagem_srd_completo` que recebe `p_identidade`, valida sexo, idade mínima, dimensões corporais e tendência de classe, grava a identidade e aplica os ajustes de envelhecimento. A função anterior de seis argumentos foi preservada para compatibilidade.

**Validações realizadas**
- Sintaxe do JavaScript inline de `ficha.html`: aprovada.
- Coluna JSONB `identidade`: confirmada no banco com default vazio e NOT NULL.
- Sobrecargas RPC de seis e sete argumentos: confirmadas no catálogo do PostgreSQL.
- Catálogo de idiomas: 19 idiomas públicos e 1 idioma secreto; idioma secreto não é oferecido na escolha.
- Cobertura de classes existente: 11 classes, 11 pacotes iniciais, 220 linhas de progressão e 11 características de nível 1.
- Regras de idade e altura/peso conferidas nas páginas 95–96 do Livro do Jogador enviado.

**Limites desta subetapa**
- Não foi executado teste autenticado real criando personagem no navegador; portanto, o salvamento end-to-end ainda precisa de validação com usuário autenticado.
- A escolha de divindade do Clérigo e a validação de tendência relativa à divindade ainda não foram implementadas.
- As escolhas próprias de cada classe (domínios, companheiro animal, grimório, magias conhecidas/preparadas, especializações e características ativáveis) permanecem como próxima etapa; não marcar as 11 classes como criação completa.
- A implementação permanece na branch de auditoria e não foi mesclada à branch principal.


## Etapa Anão A2 — escolha de alfabetização do Bárbaro

**Estado: implementação concluída; teste autenticado de ponta a ponta pendente.**

- O Bárbaro Anão agora recebe uma escolha explícita na etapa de Treino: permanecer analfabeto ou gastar 2 pontos de perícia para aprender a ler e escrever todos os idiomas que conhece.
- A escolha é apresentada como recurso de classe, não como talento ou idioma adicional.
- Quando o jogador escolhe alfabetização, o orçamento de perícias disponível é reduzido em 2 pontos; a validação de gasto continua ativa.
- A decisão é enviada em `p_identidade.alfabetizado` e persistida na coluna JSONB `srd_character_sheets.identidade`.
- A RPC de criação valida que a escolha foi informada para Bárbaro e verifica no registro de progressão de classe se o gasto de perícias mais os 2 pontos de alfabetização cabe no orçamento do personagem.
- Para as demais classes, a ficha registra alfabetização automática, conforme a regra geral do Livro do Jogador.

**Validações realizadas**
- Sintaxe JavaScript de `ficha.html`: aprovada.
- RPC de sete argumentos continua registrada como SECURITY DEFINER; a versão antiga de seis argumentos foi preservada.
- A regra de 2 pontos foi conferida na descrição de Analfabetismo do Bárbaro no Livro do Jogador, página 25.
- Não foi criado novo campo ou tabela no banco para esta escolha; reutiliza-se `identidade`.

**Limite**
- A regra foi validada estaticamente e pela definição SQL, mas ainda não foi testada com sessão autenticada criando um Bárbaro Anão real. A etapa não está mesclada à branch principal.


## Etapa Anão A3 — fluxo de escolhas de magias e limites por classe

**Estado: implementação concluída; teste funcional autenticado pendente.**

- Corrigida a perda de escolhas do Grimório durante re-renderizações: o rascunho de magias agora permanece no estado da criação enquanto o jogador alterna etapas, fecha/abre o catálogo e ajusta outras escolhas.
- Bardo e Feiticeiro passam a ter seus limites de magias conhecidas verificados por círculo com base em `known_by_level` já existente. No nível 1, a progressão cadastrada indica Bardo: 4 truques conhecidos; Feiticeiro: 4 truques e 2 magias de 1º círculo, desde que o atributo permita conjurá-las.
- Clérigo e Druida têm a quantidade de magias preparadas limitada aos espaços disponíveis por círculo, incluindo espaços adicionais por atributo. Magias de círculo inferior podem ocupar espaços superiores, sem exceder a quantidade disponível.
- Mago passa a exibir também magias de 1º círculo no grimório mesmo quando o atributo ainda não permite conjurá-las; a preparação continua limitada aos espaços efetivamente disponíveis. Todos os truques de Mago são incluídos automaticamente no grimório inicial.
- A interface apresenta os limites de escolhas e espaços; a validação final impede salvar quantidades acima da progressão da classe, magias fora da lista/círculo permitido e preparação de magias que não constem no grimório do Mago.
- Catálogo e progressões existentes foram reutilizados: não houve alteração de tabelas nem criação de novos registros no Supabase.

**Validações realizadas**
- Sintaxe JavaScript de `ficha.html`: aprovada.
- Progressões de nível 1 conferidas no banco: Bardo (4 conhecidas de círculo 0), Feiticeiro (4 de círculo 0 e 2 de círculo 1), Clérigo/Druida (3 espaços de círculo 0 e 1 de círculo 1), Mago (3 espaços de círculo 0 e 1 de círculo 1).
- A interface preserva as escolhas de magias durante re-renderizações e impede a conclusão quando os limites cadastrados não são respeitados.

**Limites desta etapa**
- A especialização de escola do Mago e as escolas proibidas ainda não estão no fluxo.
- A escolha da divindade do Clérigo ainda precisa ser ligada aos domínios e à tendência.
- Familiars, companheiro animal e outras escolhas de classe ainda estão pendentes.
- Não houve teste de navegador com sessão autenticada; a etapa permanece na branch de auditoria.


## Etapa Anão A4 — Mago: especialização e escolas proibidas

**Estado: implementação concluída; teste funcional autenticado pendente.**

- O Mago agora precisa escolher explicitamente entre Universalista ou uma das oito escolas de especialização.
- Se especialista, escolhe duas escolas proibidas; se especialista em Adivinhação, escolhe uma. A interface impede repetir a escola de especialização e as escolas proibidas entre si.
- O catálogo de magias identifica as escolas em português e inglês. Magias proibidas são sinalizadas; se já estavam selecionadas antes da mudança de especialização, o jogador pode removê-las sem perder silenciosamente outras escolhas.
- Truques permitidos são adicionados automaticamente ao grimório inicial. Truques de escolas proibidas não são adicionados; abaixo de Inteligência 10, a ficha não permite aprender truques.
- O espaço adicional por círculo do Mago especialista é exibido e considerado na capacidade de preparação. Se o jogador usar esse espaço adicional, ao menos uma magia preparada naquele círculo precisa pertencer à escola especializada.
- A validação da identidade do Mago ocorre no RPC de criação. A RPC `salvar_grimorio_srd` também valida escolas proibidas, truques iniciais permitidos, quantidade de magias de 1º círculo, magias preparadas e o espaço adicional de especialização.
- Foi adicionada a função auxiliar `_srd35_school_key` para normalizar escolas de magia em português/inglês. Não foi criada tabela ou coluna nova.

**Validações realizadas**
- Sintaxe JavaScript de `ficha.html`: aprovada.
- RPC de criação confirma a seleção de especialização e a quantidade correta de escolas proibidas.
- RPC do Grimório confirma bloqueio de escolas proibidas e capacidade do espaço adicional.
- Mapeamento SQL testado para Adivinhação, Conjuração e Encantamento em português.
- Não houve teste de navegador com sessão autenticada; a etapa permanece na branch de auditoria.

**Limite**
- O descanso diário e o uso de espaços de magia na Mesa ainda precisam ser alinhados ao espaço extra de especialista quando o trabalho chegar ao módulo de jogo. Nesta fase, a criação e o salvamento inicial do grimório já consideram a especialização.


## Etapa Anão A5 — Clérigo: divindade, tendência e domínios

**Estado: fluxo de criação implementado e verificações estáticas aprovadas; teste de navegador autenticado pendente.**

- Foi criada uma etapa própria **Classe** no fluxo de criação, posicionada depois dos atributos e antes de perícias/talentos. As escolhas do Mago foram movidas para essa etapa; a visualização de fichas já existentes não exibe o formulário de criação.
- Para o Clérigo, a interface oferece fonte divina por divindade ou por causa/ideal. A lista de divindades é filtrada pelas restrições raciais cadastradas. Para Anão, Moradin está disponível; as divindades gerais permanecem disponíveis.
- Ao escolher uma divindade, a interface mostra tendência, domínios e arma predileta. A arma predileta é informativa: não concede proficiência automaticamente; o domínio Guerra é que concede proficiência e Foco na arma predileta.
- Os dois domínios são selecionados na etapa de classe. Com divindade, só aparecem domínios daquela divindade; com causa/ideal, o jogador escolhe dois domínios e a coerência narrativa fica sujeita à avaliação do Mestre.
- O catálogo existente de domínios e magias de domínio foi reutilizado. Moradin oferece Terra, Bem, Ordem e Proteção; os quatro possuem magias cadastradas do 1º ao 9º círculo no catálogo atual.
- A identidade do Clérigo é validada no servidor: divindade obrigatória quando essa fonte é escolhida, restrição racial, tendência igual ou a um passo da divindade e regra específica de St. Cuthbert. A causa/ideal precisa ser informada.
- A criação exige dois domínios diferentes antes de inserir o personagem. O RPC de criação valida que ambos existem e, quando há divindade, pertencem a ela. O RPC de persistência dos domínios repete a validação no salvamento.
- A seleção de domínios é enviada junto à identidade no RPC de criação e persistida na tabela existente `srd_character_domain_choices`; a gravação posterior do grimório também salva os domínios e magias de domínio.

**Dados e alterações no banco**
- A auditoria não encontrou catálogo de divindades preexistente. Foi criada a tabela de referência `srd_deities` com 19 divindades do Livro do Jogador; não foram criadas tabelas de domínios, magias ou escolhas de personagem duplicadas.
- A tabela de divindades é somente leitura para usuários autenticados por RLS.
- RPCs existentes foram atualizados; não foi criada uma nova estrutura de armazenamento para domínios.

**Verificações realizadas**
- Sintaxe JavaScript de `ficha.html`: aprovada após as alterações.
- Confirmada a presença da etapa Classe, dos controles de divindade/causa e da escolha dos domínios.
- RPC de criação validada por inspeção da definição: exige dois domínios válidos, restringe-os aos domínios da divindade e verifica acesso racial.
- RPC de salvamento dos domínios validada por inspeção da definição.
- Integridade do catálogo: os domínios das divindades existem em `srd_domains`; Terra, Bem, Ordem e Proteção possuem nove níveis de magias cada.
- Não foi criado personagem de teste nem executado fluxo de navegador com sessão autenticada. Essa validação ainda é necessária antes de marcar a etapa como integralmente testada.

**Pendência específica**
- A escolha de causa/ideal não pode ser validada semanticamente pelo banco; o Mestre precisa poder revisar se os dois domínios são coerentes com a causa escolhida.
- Ainda falta validar visualmente o fluxo completo no navegador com usuário autenticado, inclusive o salvamento e a reabertura da ficha.


## Etapa Anão A6 — Druida: vínculo com a natureza

**Estado: fluxo de escolha implementado e verificações estáticas aprovadas; teste de navegador autenticado pendente.**

- A etapa de classe do Druida agora oferece as duas opções de Vínculo com a Natureza do 1º nível: companheiro animal ou domínio.
- A opção de companheiro apresenta a lista básica de 13 animais do 1º nível, reutilizando registros verificados já existentes em `srd_monsters`: texugo, camelo, rato atroz, cão, cão de montaria, águia, falcão, cavalo leve, coruja, pônei, víbora pequena, víbora média e lobo.
- Ao escolher o animal, a interface mostra tamanho e ND do registro existente. A ficha registra o identificador do companheiro na identidade do personagem; não foi criada tabela nem duplicado o bloco de estatísticas do monstro.
- A opção de domínio permite exatamente um entre Ar, Animal, Terra, Fogo, Plantas e Água. A interface apresenta o poder concedido e as magias do domínio, reutilizando `srd_domains` e `srd_domain_spells`.
- A escolha de domínio concede a preparação separada da magia de domínio por círculo disponível. A preparação é validada e salva junto ao grimório.
- O servidor valida que o companheiro pertence à lista básica e existe como animal verificado no catálogo. Se o jogador escolher domínio, valida exatamente um domínio permitido e impede que a ficha também registre companheiro animal.
- O RPC existente de domínios foi ampliado para aceitar dois domínios de Clérigo ou um domínio de Druida, mantendo validação por classe, catálogo e identidade. Não foi criada tabela nova.

**Verificações realizadas**
- Sintaxe JavaScript de `ficha.html`: aprovada.
- Os 13 IDs de companheiro selecionáveis existem no bestiário atual com `tipo='Animal'` e `source_status='verified_srd'`.
- Todos os seis domínios druídicos possuem uma magia de 1º círculo cadastrada.
- RPC de criação validada por inspeção: exige escolha válida e rejeita combinações incompatíveis.
- RPC de salvamento de domínio validada por inspeção: aceita um domínio apenas para Druida com vínculo por domínio e dois apenas para Clérigo.
- Não houve criação de personagem de teste nem teste de navegador autenticado.

**Limite**
- A ficha registra a escolha e apresenta os dados de referência do companheiro; a aplicação de progressão mecânica do companheiro conforme o nível efetivo do Druida (bônus de DV, armadura natural, FOR/DES, truques e habilidades especiais) deverá ser concluída no módulo de progressão/combate, sem inventar esses ajustes na criação de 1º nível.


## Etapa Anão A7 — Patrulheiro: inimigo predileto

**Estado: escolha implementada e validações estáticas aprovadas; teste de navegador autenticado pendente.**

- A etapa de classe do Patrulheiro agora exige a escolha de um Inimigo Predileto no 1º nível.
- A interface apresenta os tipos de criatura e os subtipos de humanoide e extraplanar previstos nas opções da classe.
- A explicação informa os efeitos iniciais: +2 nas jogadas de dano com armas e +2 em Blefar, Ouvir, Sentir Motivação, Observar e Sobrevivência contra o inimigo escolhido.
- A escolha é mantida na identidade da ficha e enviada ao RPC de criação.
- O servidor valida a opção contra uma lista fechada de categorias permitidas. Classes que não são Patrulheiro recebem o campo vazio, evitando que uma escolha indevida fique associada a outra classe.
- Nenhuma tabela ou coluna foi criada; o campo foi guardado no JSON de identidade já existente.

**Verificações realizadas**
- Sintaxe JavaScript de `ficha.html`: aprovada.
- Controles de seleção, validação antes do envio e campo no payload confirmados.
- RPC de criação atualizado e validado por inspeção da definição.
- Não houve teste de navegador autenticado nem criação de personagem de teste.


## Etapa Anão A8 — Familiar do Mago e do Feiticeiro

**Estado: interface de escolha e validação de identidade implementadas; teste autenticado de ponta a ponta pendente.**

- A etapa **Classe** agora apresenta o recurso Familiar para Mago e Feiticeiro, sem exibir esse bloco para outras classes.
- O jogador pode escolher um familiar básico ou registrar que ainda não deseja adquiri-lo. A escolha não é imposta como se o vínculo já tivesse sido realizado.
- A interface apresenta o benefício concedido ao mestre conforme a tabela de familiares do Livro do Jogador: Víbora pequena (+3 Blefar), Gato (+3 Furtividade), Lagarto (+3 Escalar), Rato (+3 Fortitude), Texugo (+3 Reflexos), Coruja (+3 Observar na penumbra), Corvo (+3 Avaliação), Falcão (+3 Observar sob luz intensa), Morcego (+3 Ouvir) e Sapo (+3 PV). O Corvo também pode falar um idioma escolhido pelo mestre.
- A escolha é mantida no estado da criação, enviada como `familiar_id` e persistida no JSONB `srd_character_sheets.identidade` já existente.
- A RPC existente `criar_personagem_srd_completo` foi atualizada para aceitar somente os IDs básicos de familiar para Mago/Feiticeiro e limpar o campo para as demais classes. Não foi criada tabela nem coluna.
- A seleção respeita a progressão conjunta de níveis de Mago e Feiticeiro para as habilidades do familiar; a interface informa que o bônus do familiar só se aplica dentro do alcance indicado no livro.

**Verificações realizadas**
- Sintaxe JavaScript de `ficha.html`: aprovada.
- A interface foi conferida para as classes Mago e Feiticeiro e o campo não é oferecido às demais classes.
- A RPC de criação contém validação fechada para os dez IDs básicos e persiste a identidade no registro da ficha.
- Não foi criado personagem de teste nem executado navegador com sessão autenticada.

**Limites**
- Os blocos estatísticos completos dos familiares, PV próprios, progressão de DV, armadura natural, Inteligência e habilidades por nível ainda não foram conectados ao bestiário. O Livro dos Monstros será necessário para fechar essa parte sem duplicar ou inventar estatísticas.
- A atualização da RPC foi aplicada diretamente ao projeto Supabase para validação. O arquivo de migração versionado correspondente ainda precisa ser gerado pelo fluxo local do Supabase CLI antes da consolidação/implantação em outro ambiente.
- Esta etapa registra a escolha inicial; não implementa ainda a convocação, morte, substituição ou efeitos ativos do familiar durante o jogo.


## Etapa A9 — auditoria de especializações de perícias (pré-requisito do Bardo)

**Estado: auditoria concluída; implementação bloqueada até corrigir o modelo de perícias sem criar um fluxo incorreto.**

- O Livro do Jogador define Atuação como várias perícias independentes: Atuar, Comédia, Dança, Instrumentos de Teclado, Oratória, Instrumentos de Percussão, Instrumentos de Corda, Instrumentos de Sopro e Canto.
- A regra do Bardo exige pelo menos 3 graduações em uma perícia Atuação para usar Música de Bardo, Contracanto, Fascinar e Inspirar Coragem no 1º nível.
- O catálogo atual contém apenas um registro genérico `srd35_skill_perform` para Atuação. Diferentemente de Conhecimento, que já possui especializações separadas, as nove especialidades de Atuação ainda não estão representadas.
- A RPC `salvar_pericias_srd` só aceita IDs existentes em `srd_skills` e calcula custo/limites por registro. A interface também calcula orçamento por ID. Portanto, apenas acrescentar um seletor visual de instrumento/categoria não seria suficiente: o sistema continuaria somando graduações de especialidades diferentes como se fossem uma única perícia.
- Ofício e Profissão também aparecem como registros genéricos, embora sejam perícias com especializações independentes. A solução precisa considerar esse padrão de forma reutilizável, preservando fichas antigas.

**Decisão técnica para evitar redundância e perda de regras**
- Não foi criado um seletor isolado para o Bardo nem foram inseridas especializações duplicadas nesta auditoria.
- A próxima implementação deve tratar especializações de perícia como unidades independentes de compra, respeitando orçamento, custo de classe/cross-class, graduação máxima, persistência e leitura de fichas antigas.
- Depois dessa correção, o fluxo do Bardo poderá validar corretamente as 3 graduações exigidas e apresentar as opções de Música de Bardo que o personagem realmente pode usar.

**Referência consultada**
- Livro do Jogador D&D 3.5, seção da perícia Atuação e descrição de Música de Bardo (página impressa 25 na edição enviada).


## Continuidade — migrações locais e pendências de infraestrutura (2026-11-03)

- Foi conferido o diretório `supabase/migrations/` na branch de auditoria e o histórico remoto do projeto. O arquivo `supabase/config.toml` não existe no repositório.
- O terminal desta sessão não possui Supabase CLI nem checkout local do repositório; também não consegue resolver hosts externos para instalar o CLI/clonar o GitHub. Portanto, não foi possível executar honestamente `supabase init` ou `supabase migration new` nesta sessão.
- Foi adicionado `SUPABASE_LOCAL_WORKFLOW.md` com os comandos oficiais para inicializar o projeto local, vincular o projeto, comparar histórico e capturar o drift remoto com o CLI. O documento alerta explicitamente para não executar `db reset --remote` e para revisar qualquer diff antes de publicar.
- A função `criar_personagem_srd_completo(..., p_identidade jsonb)` no banco já contém validação de `familiar_id`; a migração correspondente ainda não foi reconciliada no repositório. Não foi criada uma migração manual com timestamp inventado.
- A auditoria da RPC `salvar_pericias_srd(text,jsonb)` confirmou que o motor calcula custo, limite e classe/cross-class por ID individual em `srd_skills`. A9 continua pendente: as nove categorias de Atuação precisam de IDs separados, com compatibilidade de leitura para o ID legado `srd35_skill_perform`. Não foram inseridos registros nem alterada a RPC nesta etapa, para não deixar catálogo e motor divergentes.
- Ofício e Profissão também têm especializações abertas; não devem ser tratados como listas fechadas nem ganhar tabelas duplicadas sem modelagem específica.

**Próximo passo seguro:** executar o fluxo local documentado em uma cópia do repositório com Supabase CLI instalado, reconciliar o drift da RPC do familiar e então implementar as categorias de Atuação em uma migração única, incluindo catálogo, associação de classe, compatibilidade com fichas antigas e validação de Música de Bardo. Em seguida, testar a migração em banco local e a criação/reabertura de personagem autenticado.


## Etapa A10 — identidade das sete raças básicas

**Estado: interface e migração preparadas na branch de auditoria; aplicação e teste autenticado pendentes.**

- A seleção inicial da criação SRD deixou de filtrar exclusivamente Anão e passou a disponibilizar as sete raças já cadastradas em `srd_races`: Humano, Anão, Elfo, Gnomo, Meio-Elfo, Meio-Orc e Halfling.
- A interface calcula idade adulta, dados e grupo de classe conforme a Tabela 6-4 do Livro do Jogador. A rolagem respeita d4/d6; a idade mínima usa o resultado mínimo possível dos dados.
- O envelhecimento aplica os limiares raciais da Tabela 6-5 e os ajustes cumulativos de atributos físicos e mentais.
- Altura e peso aleatórios seguem a Tabela 6-6, inclusive o multiplicador do resultado de altura para o peso. Os campos manuais exibem limites possíveis por raça e sexo.
- Os idiomas automáticos e as listas raciais adicionais são apresentados conforme a descrição racial já cadastrada. Humanos e Meio-Elfos podem escolher qualquer idioma não secreto; Druídico continua automático para Druidas.
- Nenhuma tabela, coluna ou registro novo foi criado. O fluxo reutiliza `srd_races`, `srd_languages`, a identidade JSONB e a RPC existente de idiomas.

**Migração preparada**
- Arquivo: `supabase/migrations/20261103110000_srd35_all_basic_races_identity.sql`.
- A migração reconstrói a assinatura de sete parâmetros de `criar_personagem_srd_completo` a partir da definição instalada, preservando as validações de classe e as propriedades da função.
- Remove a restrição temporária a Anão, aplica idade mínima e envelhecimento por raça, e valida altura/peso contra os intervalos possíveis da Tabela 6-6 por raça/sexo.
- A identificação real das classes foi conferida no banco: `ranger` é o ID de Patrulheiro; os grupos de idade usam os IDs existentes.
- As precondições de substituição foram conferidas por consultas somente leitura contra a definição atual da RPC. A migração **não foi aplicada** ao banco de produção e ainda precisa de validação em banco local antes de ser considerada pronta para implantação.

**Verificações realizadas**
- Sete raças presentes no catálogo e disponíveis na interface da branch.
- IDs reais das 11 classes conferidos.
- Blocos antigos de idade, envelhecimento e limites físicos da RPC correspondem exatamente aos trechos que a migração pretende substituir.
- Interface conferida estaticamente para idade, envelhecimento, altura/peso e idiomas por raça.
- Nenhuma ficha de teste foi criada; não houve teste de navegador autenticado.
- Nenhuma alteração foi aplicada ao banco de produção.

**Pendências antes de liberar**
1. Validar sintaxe e execução da migração em banco local, sem tocar na produção.
2. Revisar o overload legado de seis parâmetros de `criar_personagem_srd_completo`, que continua concedido a `authenticated`; não revogar enquanto seus usos não forem auditados.
3. Testar criação e reabertura autenticadas com as sete raças, incluindo idade mínima, envelhecimento, limites físicos e idiomas.
4. Só então considerar a criação de sete raças liberada.

**Referência consultada:** Livro do Jogador D&D 3.5 enviado pelo usuário, Tabelas 6-4, 6-5 e 6-6 (páginas impressas 91–92).


### Revisão da migração A10 — 2026-11-03

- Corrigido o delimitador de dollar-quote do bloco de envelhecimento (v_new_aging), que impedia a migração de ser analisada/executada corretamente.
- Corrigidos os limites possíveis de altura e peso da Tabela 6-6 para as sete raças, incluindo os pesos fixos de Gnomo e Halfling e as bases de Meio-Elfo/Meio-Orc femininos.
- Corrigida a mensagem de idade mínima para identificar raça e classe corretamente.
- A migração completa foi executada em uma transação explícita BEGIN/ROLLBACK contra a definição atualmente instalada no Supabase. O bloco concluiu sem erro e a transação foi revertida; portanto, nenhuma alteração foi persistida em produção.
- Confirmado que os literais JSONB efetivamente presentes na RPC instalada são válidos; não foi necessária correção desses valores. Um teste anterior usou representações diferentes das armazenadas e não deve ser tratado como defeito da função.
- A assinatura antiga de seis parâmetros permanece concedida a authenticated: a ficha.html da branch main ainda a utiliza. Não revogar até que a interface que usa a assinatura de sete parâmetros seja implantada e validada.
- A10 continua não liberada: ainda faltam teste autenticado de ponta a ponta e validação visual de criação/reabertura para as sete raças.


### Execução da A10 em produção e correção final da interface — 2026-11-03

- Aplicada no Supabase de produção a migração `srd35_all_basic_races_identity`; o histórico remoto registrou a versão `20261103232842`. A migração foi alinhada no repositório para o arquivo `supabase/migrations/20261103232842_srd35_all_basic_races_identity.sql`; o arquivo com timestamp divergente foi removido.
- Verificação pós-aplicação: a assinatura de sete parâmetros não contém mais a restrição exclusiva ao Anão; a validação racial de altura/peso e a mensagem de idade por raça estão instaladas. `anon` continua sem EXECUTE e `authenticated` mantém EXECUTE.
- Catálogo de produção confirmado com as sete raças. O parser de idiomas da RPC foi testado contra as sete descrições raciais: os idiomas automáticos foram extraídos corretamente, inclusive o singular do Humano; Druídico é acrescentado para Druida. Todos os idiomas automáticos/adicionais utilizados pela interface existem no catálogo; idiomas secretos permanecem indisponíveis para escolhas bônus/compradas.
- Corrigido o seletor inicial de `ficha.html` na branch de auditoria: antes ainda filtrava exclusivamente Anão, apesar das etapas seguintes aceitarem sete raças. Agora lista todas as raças do catálogo. Também foram corrigidos textos que diziam que a etapa estava focada no Anão e os valores iniciais/fallbacks de idiomas agora são dinâmicos por raça e classe.
- A interface de auditoria envia `p_identidade` à assinatura de sete parâmetros. A interface antiga em `main` continua usando a assinatura de seis parâmetros; essa assinatura foi preservada para evitar quebra da versão principal.
- **Ainda não foi possível concluir o teste autenticado de ponta a ponta no navegador**: as ferramentas disponíveis não fornecem uma sessão JWT de jogador nem um navegador autenticado para a aplicação. Não foi criado usuário de teste nem personagem fictício em produção.
- A10 está aplicada no banco e corrigida na branch de auditoria, mas ainda não deve ser considerada integralmente liberada aos jogadores até a branch ser publicada e o teste autenticado de criação/reabertura ser executado.

### Fechamento da verificação A10 — 2026-11-03

**Conferência posterior da branch e do banco**
- A branch `audit/dnd35-rules-alignment` contém `ficha.html` atualizado e a migração versionada `20261103232842_srd35_all_basic_races_identity.sql`; o arquivo anterior com timestamp `20261103110000` não existe mais.
- O seletor inicial usa todas as raças do catálogo, sem filtro exclusivo de Anão. O helper de idiomas automáticos considera raça e acrescenta Druídico para Druida. A ocorrência de `['Comum','Anão']` no código é a lista racial correta do Anão, não um fallback global.
- A chamada da interface usa a RPC de sete parâmetros e inclui `p_identidade`.
- O histórico de migrações do Supabase contém `20261103232842 / srd35_all_basic_races_identity`.
- Consulta direta ao catálogo de funções confirmou os overloads de seis e sete parâmetros. Ambos negam EXECUTE a `anon`; ambos mantêm EXECUTE para `authenticated`. O overload antigo foi preservado porque a versão em `main` ainda depende dele.
- Inspeção da definição instalada da RPC de sete parâmetros confirmou: guarda exclusiva de Anão ausente; validações raciais de altura e peso presentes; mensagem de idade mínima presente.
- Não foram criados usuários, fichas ou registros de teste em produção.

**Auditoria automática adicional**
- Advisors de segurança retornaram 88 avisos de funções SECURITY DEFINER executáveis por authenticated e 1 aviso de proteção contra senhas vazadas desativada. São achados gerais do projeto, não introduzidos nem corrigidos pela migração A10; precisam de auditoria individual antes de qualquer revogação ou troca para SECURITY INVOKER.
- Advisors de performance retornaram 56 índices não utilizados (nível INFO). Não remover índices sem análise de carga e dependências.

**Estado final honesto**
- Banco: migração aplicada e verificações estruturais aprovadas.
- Repositório: código e migração reconciliados na branch de auditoria.
- Interface: ainda não publicada em `main` nem implantada no site.
- Teste de jogador: ainda pendente. As ferramentas desta sessão não disponibilizam sessão autenticada real nem navegador conectado à aplicação; portanto, criação e reabertura de ficha não foram simuladas nem declaradas aprovadas.
- A10 não deve ser marcada como liberada aos jogadores até que a branch revisada seja implantada e o teste autenticado de criação/reabertura seja concluído. A divergência entre `main` e a branch de auditoria impede um merge automático seguro.

### Encaminhamento para revisão — PR #1
- Aberto PR em rascunho: https://github.com/clubberblues/rpgvinculo/pull/1
- Base: `main`; origem: `audit/dnd35-rules-alignment`.
- O GitHub reporta 125 commits exclusivos na origem, 64 exclusivos na base, 14 arquivos alterados, 3.043 inserções e 147 remoções. O PR está `draft`, não mesclado, e o GitHub não o considera mergeable neste momento.
- O PR foi aberto para expor o diff e registrar os critérios de liberação; não representa aprovação, publicação ou implantação.
- A próxima ação segura depende da identificação do provedor de hospedagem atualmente usado pelo site. O README apenas instrui publicação manual dos quatro HTMLs na raiz e não identifica Vercel, Netlify ou outro provedor.

### Reconciliação adicional do histórico remoto — 2026-11-03
- A listagem do histórico Supabase confirma migrações de identidade já aplicadas, entre elas `dwarf_character_identity_creation_flow`, `validate_barbarian_literacy_choice`, `validate_wizard_specialization_choices`, validações de divindade/domínios do Clérigo, vínculo natural do Druida e inimigo predileto do Patrulheiro.
- Os arquivos correspondentes com esses nomes/timestamps não foram encontrados em `supabase/migrations` na branch de auditoria. A função de sete parâmetros em produção contém essas validações (incluindo familiar do Mago/Feiticeiro e vínculo natural do Druida), mas o repositório não possui a sequência completa que reproduz esse estado.
- Isso confirma que não basta copiar somente a última migração de sete raças para um ambiente novo: o histórico de migrations precisa ser reconciliado integralmente com o banco antes de declarar a implantação reproduzível.
- Não gerei uma migração artificial nem sobrescrevi a função em produção. A definição instalada foi inspecionada; os dados de personagens permaneceram intocados.


### Inventário quantitativo do histórico remoto x arquivos versionados — 2026-11-03

- Nova comparação feita diretamente com o histórico remoto do Supabase (527 versões) e com os arquivos SQL tanto da raiz quanto de `supabase/migrations/` na branch `audit/dnd35-rules-alignment` (516 arquivos SQL).
- A comparação por nome normalizado encontrou correspondência nominal para 464 das 527 migrações remotas. **63 versões remotas não têm arquivo SQL correspondente pelo nome** nessa branch.
- Essa comparação é apenas nominal: não comprova que os 464 arquivos tenham conteúdo idêntico ao SQL efetivamente aplicado, nem valida a ordem/dependências. Ainda é necessário comparar conteúdo e estado do schema.
- Entre as 63 ausências estão alterações de regras e segurança de 03/11/2026: restrições de movimentação, rolagens manuais, permissões de RPC, armas/alcance/ataque, idiomas e progressão de nível; também estão ausentes arquivos das validações de criação do Bárbaro, Mago, Clérigo, Druida e Patrulheiro.
- A comparação de nomes também mostra que o histórico da branch `main` não resolve a lacuna: nela, 439/527 nomes correspondem e 88 não; a branch `codex/dnd35-gameplay-flow-audit` também não contém a sequência completa.
- Não se deve criar arquivos vazios, registrar migrações como aplicadas, nem reaplicar alterações só para fazer os números coincidirem. Os SQLs originais ausentes precisam ser recuperados de commits/artefatos confiáveis ou substituídos por um plano de reconciliação do estado atual, revisado e testado.
- Nenhuma alteração foi feita no banco durante esta comparação; nenhuma ficha ou dado de jogador foi tocado.


### Correção da comparação: versão exata exigida pelo Supabase CLI

- A contagem anterior de 464/527 era somente uma correspondência nominal entre nomes de migração e SQLs espalhados pela raiz e pela pasta de migrações; ela **não** representava o estado reconhecido pelo Supabase CLI. Corrijo explicitamente essa interpretação.
- Comparando os prefixos de versão de 14 dígitos dentro de `supabase/migrations/`, apenas 43 das 527 versões remotas possuem arquivo versionado correspondente na branch. Há 508 versões remotas sem arquivo com o mesmo timestamp; 24 arquivos versionados locais não aparecem no histórico remoto e permanecem migrações pendentes, não aplicadas.
- Descoberta importante: `supabase_migrations.schema_migrations` guarda as instruções SQL originais em `statements text[]`. Uma consulta somente leitura confirmou que as 508 versões ausentes têm `statements` não nulo e não vazio (aprox. 1.619.030 caracteres no total; maior migração aprox. 130.217 caracteres).
- Isso permite recuperar os SQLs originais exatos do histórico remoto e reconstruir os arquivos com seus timestamps/nome originais, sem inventar migrações nem reaplicar DDL em produção. A recuperação ainda precisa ser feita e validada em branch isolada; não foi feita nesta etapa.
- O banco permaneceu sem alterações nesta descoberta.


### Reconciliação do histórico remoto — recuperação concluída em branch isolada (2026-11-03)

- Recuperadas diretamente de `supabase_migrations.schema_migrations.statements` as instruções SQL originais das 508 versões que não tinham arquivo versionado na pasta `supabase/migrations/`.
- Criados 508 arquivos com o timestamp e o nome exatos registrados pelo Supabase, em `supabase/migrations/<version>_<name>.sql`. Os conteúdos foram gravados a partir do array `statements` do próprio histórico remoto; nenhuma SQL foi inventada ou reaplicada no banco.
- Branch isolada: `audit/reconcile-supabase-migration-history`.
- Commit final da recuperação: `c74f7d7cdc1d6826296df0e73237e619e33b619c`.
- Verificação posterior: 527/527 versões do histórico remoto têm agora um arquivo local com timestamp e nome exatamente correspondentes. Não há versão remota ausente ou com nome divergente.
- Permanecem 24 arquivos versionados no repositório que não constam no histórico remoto. Eles foram preservados como migrações pendentes; não foram aplicados nem marcados como aplicados.
- A recuperação não altera o banco de produção, dados de personagens, permissões ou funções. Ela apenas restaura no Git os SQLs já registrados no histórico remoto.
- **Ainda pendente:** validar sintaxe/ordem e dependências da sequência completa em banco local limpo, revisar os 24 arquivos pendentes e comparar o estado final do schema. Não executar `db push` em produção nem `migration repair` para forçar alinhamento.
- O branch permanece isolado e não foi mesclado em `main`, publicado ou implantado. A PR #1 continua em rascunho e não deve receber merge automático.
