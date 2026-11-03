# Fontes e regras verificadas — conjuração D&D 3.5

Este documento substitui as notas antigas que misturavam regras caseiras e uma fórmula incorreta de ataque mágico. O ruleset ativo é D&D 3.5 SRD; as tabelas `vinculo_*` não participam da conjuração.

## Fontes-base

- Mago e Feiticeiro — livro de magias, magias conhecidas, progressão, espaços diários e atributo-chave: https://www.d20srd.org/srd/classes/sorcererWizard.htm
- Clérigo — preparação, espaços de domínio e atributo-chave: https://www.d20srd.org/srd/classes/cleric.htm
- Druida — preparação, progressão e atributo-chave: https://www.d20srd.org/srd/classes/druid.htm
- Bardo — magias conhecidas e conjuração espontânea: https://www.d20srd.org/srd/classes/bard.htm
- Paladino: https://www.d20srd.org/srd/classes/paladin.htm
- Patrulheiro: https://www.d20srd.org/srd/classes/ranger.htm
- Descrições, CD de resistência, resistência à magia, duração, alvo e área: https://www.d20srd.org/srd/magicOverview/spellDescriptions.htm
- Concentração, interrupções, nível de conjurador e testes contra resistência à magia: https://www.d20srd.org/srd/magicOverview/castingSpells.htm
- Ataques de toque, ações e ataques durante a conjuração: https://www.d20srd.org/srd/combat/actionsInCombat.htm
- Ataques de raio: https://www.d20srd.org/srd/specialAbilities.htm#rays

## Regras que o motor deve aplicar

- **Atributo-chave:** INT para Mago; CAR para Feiticeiro e Bardo; SAB para Clérigo, Druida, Paladino e Patrulheiro.
- **CD de resistência:** 10 + círculo da magia + modificador do atributo-chave. Use o círculo aplicável à classe e ao espaço usado conforme a regra.
- **Ataque de toque corpo a corpo:** rolagem manual de d20 + bônus de ataque corpo a corpo apropriado (BBA, FOR, tamanho e modificadores aplicáveis) contra CA de toque.
- **Ataque de toque à distância:** rolagem manual de d20 + bônus de ataque à distância apropriado (BBA, DES, tamanho e modificadores aplicáveis) contra CA de toque.
- **CA de toque:** não inclui bônus de armadura, escudo ou armadura natural; mantém modificadores aplicáveis como DES, tamanho e deflexão.
- **Resistência à magia:** teste de nível de conjurador, d20 + nível de conjurador e modificadores pertinentes, contra a RM do alvo. Não é um ataque mágico baseado em INT/SAB/CAR.
- **Concentração:** teste da perícia Concentração, com os modificadores e CDs do evento que interrompe ou ameaça a conjuração.
- **Nível de conjurador:** normalmente o nível na classe usada para conjurar; afeta alcance, duração, efeitos dependentes de nível e testes contra RM.
- **Preparação e usos:** Mago, Clérigo e Druida preparam; Bardo e Feiticeiro usam magias conhecidas e limites diários. Paladino e Patrulheiro começam a conjurar apenas nos níveis indicados em suas progressões.
- **Mago de 1º nível:** o grimório começa com todos os truques de Mago disponíveis e 3 magias de 1º círculo, mais uma por ponto de bônus de INT. A interface e o RPC de salvamento agora validam esse requisito para o Mago generalista.
- **Clérigo:** os dois domínios escolhidos são persistidos; o espaço de domínio é separado dos espaços normais e só aceita magia de um dos domínios selecionados.
- **Rolagens:** o usuário rola manualmente no Dice. O servidor valida os resultados recebidos e calcula slots, cura, dano, PV e demais consequências. Não gerar d20 ou dados de efeito automaticamente no servidor.

## Estado técnico consultado em 03/11/2026

- O banco contém 607 magias, 22 domínios, 196 magias de domínio e 1.400 linhas de progressão de espaços.
- O Grimório preserva rascunho, magias conhecidas, preparadas, espaços de domínio e usos diários.
- As curas de alvo único e múltiplos alvos passaram a receber resultados manuais; os antigos endpoints com rolagem aleatória foram revogados para usuários autenticados.
- Míssil Mágico recebe dano rolado manualmente. O resolver ainda não cobre todos os efeitos de todas as magias.
- 516 das 607 descrições ainda apresentam estrutura em inglês e os registros de efeitos mágicos continuam marcados para revisão. O catálogo numérico, por si só, não significa implementação concluída.

## Pendências de conjuração

1. Traduzir e revisar integralmente nomes, descrições, componentes, tempos de conjuração, alvos, áreas, durações, salvamentos e RM das 607 magias.
2. Implementar cada categoria de efeito com validação específica: dano, cura, condições, bônus, penalidades, deslocamento, invocação, criação, controle, dissipação e efeitos contínuos.
3. Implementar testes de resistência, RM, concentração, contramágica, dissipar, interrupção, componentes, foco, linha de efeito, alcance, área e duração.
4. Completar especialização do Mago, escolas proibidas, metamagia, talentos de conjuração e progressões de classe que alteram nível de conjurador.
5. Completar habilidades concedidas pelos domínios, conversão espontânea do Clérigo, companheiro/familiar e demais recursos de classe que interagem com magia.
6. Testar em navegador, com duas contas, o fluxo completo de selecionar, preparar, salvar, conjurar, gastar espaço, descansar e recuperar magias.

A regra anterior `1d20 + BBA + modificador de INT/SAB/CAR` está **revogada**. Ela não deve ser usada como regra geral de ataque mágico no D&D 3.5.
