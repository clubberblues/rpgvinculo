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
- Testes de resistência D&D 3.5: Fortitude, Reflexos e Vontade, com progressão de classe e modificador de atributo.
- Bônus raciais em combate: ataque de anões/gnomos contra criaturas apropriadas, CA de anões/gnomos contra gigantes e bônus de halflings com armas arremessadas/fundas.
- Bônus raciais condicionais em salvamentos e perícias: veneno, magia, ilusão, medo, pedra, metal e alquimia.
- Lista final de talentos separa características automáticas de classe; talentos bônus escolhidos pela classe recebem identificação própria.
- Metadados de auditoria de características de classe atualizados para indicar implementação parcial, sem marcar como concluídas características ainda pendentes.

## Testes executados

- Sintaxe JavaScript de `ficha.html` e `mesa.html`: sem erros.
- Riqueza inicial: 11/11 classes conferidas.
- Movimento: 8 cenários de Bárbaro (anão/humano, sem armadura, armadura média/pesada e carga pesada) aprovados.
- Movimento do Monge: progressão de nível 3 e 6 conferida.
- Carga mista: item legado em kg + item importado em lb conferidos em conjunto.
- Anão Bárbaro N1: ajustes raciais aplicados (CON +2, CAR -2), PV 15 com CON 16, Fortitude boa, Reflexos/Vontade ruins e deslocamento efetivo de 9 m.
- Bônus raciais de ataque, CA e salvamentos: testes funcionais executados.
- Ocupação de grid: tamanhos e colisão de tokens conferidos.

## Pendências de auditoria e implementação

1. Fúria do Bárbaro: ativação, usos diários, duração por rodada, bônus de FOR/CON, bônus de Vontade, penalidade de CA, PV temporários e fadiga após o término.
2. Analfabetismo do Bárbaro e exceções de leitura/aprendizado.
3. Proficiências de armas/armaduras/escudos, penalidade por não proficiência e familiaridade racial anã.
4. Traços raciais ainda não aplicados em todos os fluxos, incluindo visão no escuro/penumbra e verificações automáticas de Conhecimento de Pedras.
5. Progressão integral de características de todas as classes, separando o que é automático, escolha do jogador e administração do Mestre.
6. Perícias: pontos por classe/nível, graduações máximas, perícias exclusivas de classe e requisitos de uso sem treinamento.
7. Talentos: pré-requisitos, talentos bônus por classe, níveis de aquisição e validação no avanço de nível.
8. Magias: preparação, espaços, componentes, escolas, CDs, resistência à magia e limites por classe/nível.
9. Combate: ações padrão/movimento/rodada completa, ataques múltiplos, ataques de oportunidade, agarrar, derrubar, encontrão, cobertura, ocultação e condições.
10. Ficha: PV, CA, BBA, ataques, dano, salvamentos, carga, equipamento e recursos recalculados após avanço de nível.
11. Mestre/NPCs: fichas, blocos de estatísticas, habilidades especiais e aplicação das mesmas regras sem exigir interface de jogador.
12. Livro do Mestre: terminar o cruzamento das regras de campanha, encontros, tesouro, descanso, condições e administração.
13. Livro dos Monstros: integrar quando for enviado, sem bloquear os itens acima.

## Regra de execução

Não marcar um módulo como concluído apenas porque existe uma descrição ou um botão. A conclusão exige regra do livro identificada, implementação, validação de dados, teste funcional e verificação da interface. Mudanças permanecem na branch de auditoria até revisão final.
