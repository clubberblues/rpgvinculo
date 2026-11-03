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
