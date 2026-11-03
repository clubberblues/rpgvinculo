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

## Testes executados

- Sintaxe JavaScript de `ficha.html` e `mesa.html`: sem erros.
- Riqueza inicial: 11/11 classes conferidas.
- Movimento: 8 cenários de Bárbaro (anão/humano, sem armadura, armadura média/pesada e carga pesada) aprovados.
- Movimento do Monge: progressão de nível 3 e 6 conferida.
- Carga mista: item legado em kg + item importado em lb conferidos em conjunto.
- Anão Bárbaro N1: ajustes raciais aplicados (CON +2, CAR -2), PV 15 com CON 16, Fortitude boa, Reflexos/Vontade ruins e deslocamento efetivo de 9 m.
- Bônus raciais de ataque, CA, salvamentos e perícias: testes funcionais executados.
- Proficiência: Bárbaro com espada longa sem penalidade; Mago com adaga sem penalidade; Mago com espada longa recebe -4; familiaridade anã com machado de guerra trata a arma como marcial.
- Ocupação de grid: tamanhos e colisão de tokens conferidos.

## Pendências de auditoria e implementação

1. Fúria do Bárbaro: ativação, usos diários, duração por rodada, bônus de FOR/CON, bônus de Vontade, penalidade de CA, PV temporários e fadiga após o término.
2. Analfabetismo do Bárbaro e exceções de leitura/aprendizado.
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
