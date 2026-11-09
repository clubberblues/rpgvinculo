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

## Pré-verificação somente de leitura — 2026-11-08

Consulta ao projeto Supabase conectado, sem escrita:

- A campanha chamada **TESTE 2** foi encontrada com ID interno 131.
- O personagem retornado nessa campanha é **Thunga Mestre** (ID interno 682), Anão Bárbaro de nível 1; PV 15/15; atributos registrados: FOR 14, DES 14, CON 16, INT 10, SAB 11 e CAR 8.
- A busca por nome não encontrou personagem chamado **Thorgar**. A ficha encontrada não contém esse nome no campo de identidade consultado. Portanto, não está confirmado que Thunga Mestre seja o personagem anteriormente chamado Thorgar.
- Não há token publicado para o personagem 682 na campanha TESTE 2.
- A Armadura de Couro consta como equipada; o Machado Grande consta no inventário, mas não equipado.
- A ficha registra o talento Iniciativa Aprimorada e identidade com alfabetizado=false.
- O inventário inicial registrado inclui Machado Grande e Armadura de Couro, entre outros itens.

**Consequência:** a pauta histórica “Thorgar” não pode ser aplicada automaticamente a Thunga Mestre. A identidade precisa ser reconciliada antes de qualquer teste funcional. A antiga expectativa de CA 12 também não foi confirmada: como a ficha tem DES 14 e a Armadura de Couro está equipada, o cálculo esperado precisa ser refeito a partir da fonte canônica e dos modificadores reais; não reutilizar CA 12 como valor de referência.

Nenhum personagem, ficha, campanha, token, inventário, equipamento ou progresso foi alterado nesta consulta.

## Próxima ação concreta

Resolver a divergência de identidade: confirmar se **Thunga Mestre** é o personagem de TESTE 2 que deve receber a continuidade anteriormente chamada “Thorgar”, ou se Thorgar é outro personagem/campanha. Até essa confirmação, não executar testes funcionais sobre o personagem real. Em paralelo, é seguro inspecionar estaticamente os commits e RPCs relevantes e preparar fixtures isoladas.

## Histórico

- 2026-11-08: item criado a partir da continuidade das sessões. Os casos são uma pauta de validação recuperada, não resultados de testes executados nesta data.
- 2026-11-08: pré-verificação somente de leitura encontrou Thunga Mestre em TESTE 2, não Thorgar; Armadura de Couro equipada, Machado Grande não equipado e ausência de token. Nenhum dado foi modificado.


## Reconciliação adicional de identidade — 2026-11-08

Consulta somente de leitura confirmou dois registros distintos:
- **Thorgar (ID 681):** campaign_id NULL; pertence ao Mestre da campanha 131 e está vinculado a um token do tipo NPC nessa campanha (sourceCharacterId=681). A Armadura de Couro e os demais itens consultados estão com equipado=false. A sobrecarga de CA para NPC vinculado retornou CA 10, coerente com esse estado.
- **Thunga Mestre (ID 682):** campaign_id=131; não possui token vinculado em cba_data; Armadura de Couro está equipada e Machado Grande não está equipado.

Portanto, o teste de CA 10 executado para Thorgar (681) **não valida nem invalida** a CA de Thunga Mestre (682). São registros diferentes; a identidade do personagem que deve ser alvo da pauta histórica precisa ser confirmada antes de qualquer teste funcional. Nenhum dado foi alterado.
