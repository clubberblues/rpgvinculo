# Contrato unificado de habilidades e efeitos da mesa

Este contrato é compartilhado por talentos, habilidades de classe e habilidades de monstros. A descrição textual continua sendo exibida ao usuário, mas nenhuma ação altera o combate apenas por interpretação de texto: o motor executa somente efeitos estruturados e validados.

## Fontes

| Origem | Catálogo | Campo mecânico |
|---|---|---|
| Talento | `srd_feats` | `mechanics` |
| Habilidade de classe | `srd_class_level_features` | `mechanics` |
| Monstro próprio | `monsters` | `mechanics` |
| Monstro SRD | `srd_monsters` | `mechanics` |

Os campos antigos são preservados para compatibilidade e auditoria da fonte.

## Formato JSON

```json
{
  "schema_version": 1,
  "engine_status": "draft",
  "activation": {
    "mode": "toggle",
    "action_type": "free",
    "trigger": null
  },
  "cost": {
    "resource": null,
    "amount": 0
  },
  "requirements": {
    "conditions": [],
    "equipment": [],
    "minimum_level": null
  },
  "target": {
    "type": "self",
    "count": 1,
    "range": { "value": 0, "unit": "m" },
    "area": null
  },
  "duration": {
    "type": "rounds",
    "value": 1,
    "end_trigger": null
  },
  "usage": {
    "limit": null,
    "period": "turn",
    "cooldown_rounds": 0
  },
  "resolution": {
    "attack": null,
    "saving_throw": null,
    "effects": []
  },
  "deactivation": {
    "mode": "duration_end",
    "cost": null
  }
}
```

## Tipos de ativação e ação

`unclassified` é permitido somente quando `engine_status` for `draft` ou `needs_review`. Ele serve para preservar e enfileirar dados de origem ainda não classificados; nunca pode ser executado pelo motor.

- `passive`: sempre considerado pelo motor, sem botão de ativação.
- `toggle`: botão liga/desliga; estado persistente até desativação ou condição de término.
- `activated`: botão executa uma ação pontual.
- `reaction`: botão/contexto de reação quando o gatilho ocorre.

A ação usa a economia de D&D 3.5: `standard`, `move`, `full_round`, `swift`, `immediate`, `free`, `no_action` ou `special`. O motor não deve converter um tipo em outro.

## Tipos de efeito

Cada item de `resolution.effects` deve ter `kind` e parâmetros explícitos:

- `modifier`: atributo/estatística, valor, tipo de bônus e duração.
  - Modificadores condicionais podem declarar `conditions`; condição não reconhecida deve falhar de forma segura. O resolvedor de ataques atualmente suporta `target_distance_max_m` para modificadores `attack_ranged` e `damage_ranged`.
- `damage` / `healing`: expressão de dados, tipo e regra de aplicação.
- `condition`: identificador de condição e duração.
- `movement`: distância, modo e restrições.
- `resource_change`: recurso, quantidade e limite.
- `resistance`: tipo de dano e quantidade/escopo.
- `extra_attack`: quantidade, penalidade e gatilho.
- `special`: somente para resolução guiada pelo Mestre; não deve simular automação inexistente.

Testes devem declarar atributo/perícia, CD e resultado em sucesso/falha. Ataques devem declarar bônus, defesa-alvo e efeito no acerto. Áreas devem declarar formato, dimensão e quantidade de alvos.

## Exemplo: Fúria do Bárbaro

```json
{
  "schema_version": 1,
  "engine_status": "draft",
  "activation": { "mode": "toggle", "action_type": "free", "trigger": null },
  "cost": { "resource": null, "amount": 0 },
  "requirements": { "conditions": [], "equipment": [], "minimum_level": 1 },
  "target": { "type": "self", "count": 1, "range": { "value": 0, "unit": "m" }, "area": null },
  "duration": { "type": "encounter_or_exhaustion", "value": null, "end_trigger": "rage_end_rules" },
  "usage": { "limit": 1, "period": "day", "cooldown_rounds": 0 },
  "resolution": {
    "attack": null,
    "saving_throw": null,
    "effects": [
      { "kind": "modifier", "stat": "strength", "value": 4, "bonus_type": "rage" },
      { "kind": "modifier", "stat": "constitution", "value": 4, "bonus_type": "rage" },
      { "kind": "modifier", "stat": "will_save", "value": 2, "bonus_type": "rage" },
      { "kind": "modifier", "stat": "armor_class", "value": -2, "bonus_type": "rage" }
    ]
  },
  "deactivation": { "mode": "duration_end", "cost": null }
}
```

Este exemplo é um modelo de dados, não uma ativação liberada. A habilidade só passa para `implemented` depois de validar requisitos, duração, limite diário, efeitos nos cálculos e encerramento/exaustão contra as regras da classe.

## Execução de talentos passivos

Talentos com `activation.mode = "passive"`, `engine_status = "implemented"` e efeitos `modifier` podem ser consultados pelo helper interno `priv.srd_passive_feat_modifier(character_id, stat)`. O helper aplica apenas efeitos estruturados e implementados; bônus sem tipo, de esquiva e circunstância são somados, enquanto bônus tipados iguais usam o maior valor.

A iniciativa do jogador (d20 físico) e a iniciativa rolada pelo Mestre para tokens que controla consultam esse helper. Assim, o bônus de Iniciativa Aprimorada não depende mais de um ID hardcoded nas rotinas de iniciativa.

## Estados de implementação

- `draft`: estrutura ainda incompleta; não executa.
- `needs_review`: preenchida, aguardando validação de regra.
- `ready`: revisada, ainda sem integração completa no motor.
- `implemented`: resolução e ciclo de vida testados no motor.
- `partial`: apenas os efeitos listados em `implemented_features` podem ser executados.

O motor deve falhar de forma segura: efeito ausente ou desconhecido não é aplicado silenciosamente. A interface abre resolução assistida pelo Mestre e registra a decisão no log.

## Ações de rodada completa e sequência de ataques

A reserva de uma ação de rodada completa é atômica no servidor por meio de
`public.consumir_acao_rodada_completa_srd(p_campaign_id, p_actor_id, p_actor_kind)`.
O procedimento exige combate e iniciativa ativos, valida o ator do turno, a
propriedade da ficha (jogador) ou o controle do token (Mestre), e bloqueia
condições `no_actions`, `no_full_round`, `only_move_action` e
`one_move_or_standard`. Também rejeita uma ação padrão/movimento já gasto ou
movimento já realizado na rodada. Quando aceita, registra `padrao`,
`movimento` e `ataque_total` juntos na economia de ações.

Essa RPC reserva a economia; ela **não** executa ataques nem rola dados. A
sequência de ataque total ainda deve ser conduzida pela mesa, exigindo uma
rolagem física separada para cada ataque, calculando os ataques iterativos a
cada +5 de BBA e registrando cada acerto/dano individualmente. Talentos como
Tiro Rápido só podem acrescentar ataques quando essa sequência estiver
integrada e validada. Cancelar uma sequência depois da reserva não devolve a
ação: a ação de rodada completa já foi iniciada.

### Estado da sequência de ataque total na mesa

A interface do jogador já oferece a ação **Ataque total** no painel e no menu
contextual. Após escolher corpo a corpo ou à distância e selecionar o alvo, a
mesa reserva a ação de rodada completa no servidor **antes** de solicitar a
primeira rolagem física. A sequência resolve os ataques iterativos a cada –5
no BBA (por exemplo, +11/+6/+1), pede um d20 físico para cada ataque e solicita
o dano separadamente para cada acerto. Erros não geram rolagem de dano. Cada
ataque é registrado individualmente no log.

Limites ainda conhecidos:
- A sequência atual é do fluxo de jogador; o fluxo de ataque do Mestre para
  NPCs/monstros ainda não usa a nova reserva de rodada completa.
- A sequência mantém o mesmo alvo escolhido no início; seleção de alvo
  independente por ataque ainda não foi implementada.
- **Tiro Rápido** está estruturado como efeito `extra_attack` (+1 ataque com
  maior BBA e –2 em todos os ataques). O resolvedor da sequência reconhece esse
  contrato quando o talento estiver `ready` ou `implemented`, mas o registro
  permanece `needs_review`; por segurança, ainda não concede o ataque extra.
  Faltam revisão final dos pré-requisitos e validação ponta a ponta.
- **Tiro Preciso** está estruturado como bônus condicional de +4 para neutralizar
  a penalidade de –4 contra alvo engajado em combate corpo a corpo, mas continua
  `needs_review` e inativo até a mesa registrar engajamento de forma explícita.


## Combater com Duas Armas — contrato ainda não executável

Os três talentos possuem estrutura mecânica explícita no catálogo, mas permanecem em
`needs_review` e **não podem conceder ataques ou bônus no combate** até a integração.

- **Combater com Duas Armas:** exige duas armas corpo a corpo equipadas e reduz em 2
  a penalidade da mão principal e em 6 a da mão secundária.
- **Combater com Duas Armas Aprimorado:** exige DES 17, o talento básico e BBA +6;
  acrescenta um segundo ataque da mão secundária com penalidade adicional de –5.
- **Combater com Duas Armas Maior:** exige DES 19, os dois talentos anteriores e
  BBA +11; acrescenta um terceiro ataque da mão secundária com penalidade adicional
  de –10.

O catálogo descreve os requisitos e os efeitos. A tabela `srd_character_equipment`
agora persiste `hand_slot` (`main_hand`/`off_hand`) para fichas de jogadores, com
limite de uma arma equipada por mão e bloqueio de armas de duas mãos incompatíveis.
A interface de inventário já permite escolher a mão ao equipar uma arma. A tabela de
equipamento de tokens NPC/monstros ainda não possui esse campo. A rotina de ataque
total atual também mantém uma única arma, fórmula de dano e confirmação de crítico
para toda a sequência. Portanto, ainda é necessário:
identificar/selecionar as duas mãos; rejeitar armas incompatíveis (por exemplo,
arma de duas mãos); construir uma sequência mista de ataques principais e
secundários; calcular penalidades cumulativas corretas; e, para cada ataque,
usar a arma correspondente em crítico, dano e RPC autoritativa. Falha em qualquer
requisito deve impedir o início da sequência, sem consumir a ação.

Os campos `two_weapon_primary_attack_penalty_reduction`,
`two_weapon_offhand_attack_penalty_reduction` e o gatilho
`full_attack_offhand` são descritores pendentes, não tipos de efeito já
suportados pelo resolvedor. Não os executar genericamente nem promover esses
talentos a `ready`/ `implemented` antes de testes ponta a ponta com rolagens
físicas separadas e aplicação de dano por arma.


## Validação de bônus em ataques iterativos

A RPC `aplicar_dano_token_ataque_srd_v2` recalcula no servidor o bônus-base
máximo a partir da ficha, arma, proficiência, atributo, tamanho, foco e
penalidades já declaradas. A validação agora aceita um bônus informado menor
que esse máximo (até 30 pontos abaixo), para que ataques iterativos e
penalidades adicionais de uma sequência não sejam rejeitados como divergência
da ficha. O cliente **não pode elevar** o bônus acima do valor recalculado pelo
servidor. A confirmação de acerto continua sendo refeita no servidor com o
d20, o bônus recebido e os modificadores de efeito.

Esta é uma correção de compatibilidade para bônus reduzidos, não uma
implementação de Combater com Duas Armas: a RPC ainda não recebe um identificador
de posição na sequência nem valida que a penalidade escolhida corresponde
exatamente ao ataque principal/secundário esperado. A sequência mista e a
validação estrita por ataque continuam pendentes. O talento permanece
`needs_review`.


### Seleção explícita da arma principal no ataque corpo a corpo

O fluxo de ataque do jogador agora prioriza a arma marcada `main_hand` ao
calcular ataques corpo a corpo. Se houver mais de uma arma corpo a corpo
 equipada, mas não houver exatamente uma identificada como mão principal, a
mesa interrompe a ação antes de pedir a rolagem, em vez de escolher uma arma
pela ordem incidental do inventário. Personagens legados com apenas uma arma
sem `hand_slot` continuam compatíveis. Ataques à distância continuam buscando
uma arma à distância equipada.

Esta proteção não cria ataques da mão secundária: em uma ficha com duas armas,
a sequência atual continua usando somente a arma principal. A geração dos
ataques secundários e seus bônus/penalidades ainda depende do resolvedor misto
por ataque e da validação autoritativa correspondente.


### Mãos de armas em NPCs e monstros

A tabela `srd_cba_token_equipment` agora persiste `hand_slot` (`main_hand` ou
`off_hand`) para NPCs e monstros, com no máximo uma arma equipada por mão.
Armas equipadas anteriormente são migradas para `main_hand`. A RPC
`equipar_item_token_srd_maos` valida o papel GM, o inventário do token e as
restrições de armas de duas mãos; somente `authenticated` pode executá-la.
O inventário do Mestre passou a oferecer equipar/desequipar cada mão e a
carregar `hand_slot` no estado local. O ataque do Mestre prioriza a arma da mão
principal quando houver uma seleção explícita.

Isto prepara o equipamento de NPCs/monstros para o resolvedor misto, mas não
implementa ainda ataques secundários automáticos, penalidades de duas armas,
dano reduzido da mão secundária, críticos por arma ou seleção independente de
alvos. Essas regras continuam bloqueadas até o fluxo de ataque por arma ser
implementado e testado.


**Limitação de inventário identificada:** as tabelas de equipamento de ficha e
CBA usam chaves por personagem/token + `equipment_id`, com quantidade na mesma
linha. Portanto, duas cópias do mesmo tipo de arma ainda não podem ser
representadas como duas instâncias equipadas simultaneamente. A próxima
refatoração de inventário deve introduzir identificadores por instância (ou
uma tabela de instâncias) antes de declarar suporte completo a duas armas
idênticas. Até lá, o suporte de mãos permite duas armas de IDs distintos.


### Instâncias individuais de armas

Para permitir duas cópias do mesmo tipo de arma, o inventário passa a manter
instâncias individuais nas tabelas `srd_character_weapon_instances` e
`srd_cba_token_weapon_instances`. Cada arma possui `instance_id` UUID próprio,
`equipment_id` aponta para o catálogo e `hand_slot` identifica a mão ocupada.
Os registros legados foram copiados para as novas tabelas; quando uma linha
legada tinha quantidade maior que um, ela foi desdobrada em uma instância por
unidade, mantendo no máximo a primeira equipada.

Triggers privados sincronizam a quantidade agregada das tabelas antigas com
as instâncias: novas entregas geram novas instâncias; exclusões removem as
instâncias; redução de quantidade só remove instâncias não equipadas e falha
se não houver unidades livres suficientes. Assim, os fluxos existentes de
entrega e equipamento inicial continuam compatíveis sem duplicar a lógica de
entrega em cada RPC.

As interfaces da mochila e do Mestre leem as instâncias, e as RPCs
`equipar_arma_instancia_personagem` e `equipar_arma_instancia_token` recebem o
UUID individual para equipar/desequipar cada cópia. O carregamento do combate
preserva cada instância separadamente e prioriza `main_hand` para ataques que
usam uma única arma. Isso ainda não ativa o combate com duas armas: penalidades,
ataques adicionais, dano e críticos por mão e alvos independentes permanecem
pendentes de implementação e teste.
