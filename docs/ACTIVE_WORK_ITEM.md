# Vínculo RPG — Item de trabalho ativo

> Estado inicial registrado em 2026-11-08. Este documento transforma a prioridade recuperada da continuidade entre sessões em uma sequência verificável. Não substitui o [Plano Mestre da Mesa](../PLANO_MESTRE_MESA.md), o [Roadmap](ROADMAP.md) ou o [Registro de Auditorias](AUDIT_REGISTER.md).

## Objetivo imediato

Retomar a validação de integração do personagem **Thorgar, Anão Bárbaro**, no contexto da campanha de teste **TESTE 2**, sem alterar o estado persistido dessa campanha.

A prioridade foi recuperada do histórico de continuidade das sessões. A identificação do personagem, o estado atual da campanha e cada pendência abaixo ainda precisam ser confirmados por leitura antes de qualquer teste. Não tratar observações históricas como estado atual do banco.

## Restrições de segurança dos dados

- Não alterar PV, PM, atributos, nível, XP, inventário, equipamento, token, posição, condições, campanha ou progresso de TESTE 2.
- Não equipar/des equipar itens, ativar Fúria ou executar ataques no personagem real para fins de teste.
- Não executar RPC mutável contra a campanha real.
- Preferir inspeção somente de leitura e testes em fixture/campanha descartável.
- Se uma validação exigir mutação, reproduzir o estado relevante em ambiente isolado; se isso não for possível, registrar como bloqueada e pedir autorização específica.
- Registrar evidência por arquivo, função/RPC, migration, consulta somente de leitura ou teste reproduzível.

## Pré-verificação obrigatória

1. Localizar Thorgar e confirmar a ficha, raça, classe, nível, campanha e token por consultas somente de leitura.
2. Inspecionar o estado real de equipamento; não presumir que Armadura de Couro esteja equipada.
3. Confirmar se o Machado Grande está no inventário e se está equipado, sem modificar a ficha.
4. Registrar os valores atuais de CA, PV, atributos, proficiências e recursos apenas como baseline de leitura.
5. Verificar os commits/migrations existentes para evitar repetir correções já feitas.
6. Se o personagem ou a campanha não puderem ser identificados sem ambiguidade, interromper a validação específica e registrar o bloqueio.

## Casos de validação — ordem sugerida

### A. Fonte canônica e sincronização da ficha/token
- Identificar a fonte canônica de CA, PV, atributos e modificadores.
- Confirmar se os valores exibidos na ficha e no token derivam da mesma fonte.
- Distinguir CA base, armadura equipada, escudo, Destreza, tamanho e modificadores temporários.
- Não afirmar que a CA esperada é 12 sem confirmar que a armadura correspondente está equipada e que não há outros modificadores.

### B. Machado Grande e proficiência
- Confirmar que o item é classificado como arma marcial de duas mãos e que o Bárbaro é proficiente.
- Verificar mão/empunhadura, alcance e propriedades relevantes.
- Validar bônus de ataque e dano em fixture isolada.
- Conferir dano base 1d12 e modificador de Força de 1,5× para arma de duas mãos, respeitando arredondamento e regras SRD.
- Conferir crítico 20/x3.
- Validar fluxo de equipar/desquipar em fixture, incluindo atualização de ficha e token.

### C. Ataque Poderoso
- Verificar pré-requisitos e disponibilidade do talento.
- Validar conversão de penalidade no ataque em bônus de dano.
- Para arma de duas mãos, conferir proporção de 2 para 1.
- Testar limites, valores negativos, duração e interação com ataques iterativos sem criar ciclos ou duplicar aplicação.

### D. Fúria
- Validar modificadores temporários de atributos e seus derivados.
- Validar PV temporários, duração, usos diários e encerramento.
- Validar fadiga após o término conforme a regra aplicável.
- Confirmar que ficha, token, log e estado persistido permanecem coerentes.
- Testar ativação, expiração, interrupção e repetição em fixture isolada.

### E. Traços raciais anões
- Bônus de ataque contra orcs e goblinoides.
- Bônus de CA contra gigantes.
- Bônus em salvamentos contra venenos e magias, conforme regra aplicável.
- Estabilidade contra encontrão e rasteira enquanto apoiado no chão.
- Visão no escuro.
- Stonecunning e bônus de perícias aplicáveis.
- Verificar aplicação mecânica, não apenas descrição textual na ficha.

### F. Regras de Bárbaro e interações
- Analfabetismo e aquisição de leitura, incluindo custo de pontos de perícia e idiomas adicionais por Inteligência quando aplicável.
- Esquiva Sobrenatural e Esquiva Sobrenatural Aprimorada.
- Flanqueamento, Ataque Furtivo e Ataques de Oportunidade.
- Leitura/ativação de pergaminhos e requisitos de leitura/conjuração.
- Registrar separadamente o que é regra automática, ação assistida pelo Mestre ou ainda não implementado.

## Evidência e aceite

Cada caso deve receber um dos estados: **passou**, **falhou**, **bloqueado**, **não aplicável** ou **não verificado**.

Um caso só passa quando:
- os dados de entrada e a regra aplicada estão identificados;
- o resultado é reproduzível;
- a autorização e a persistência foram verificadas quando pertinentes;
- ficha, token, log e demais consumidores relevantes permanecem sincronizados;
- a validação não alterou TESTE 2.

A existência de uma RPC, botão ou campo na interface não é evidência suficiente de funcionamento.

## Próxima ação concreta

Executar somente a pré-verificação de leitura de Thorgar e do estado da campanha; reconciliar os resultados com os commits/migrations já existentes. Depois, iniciar os casos em fixture isolada, começando por CA/equipamento e Machado Grande. Não avançar para correções de código até confirmar o estado atual e as dependências.

## Histórico

- 2026-11-08: item criado a partir da continuidade das sessões. Os casos são uma pauta de validação recuperada, não resultados de testes executados nesta data.
