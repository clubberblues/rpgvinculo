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
  maior BBA e –2 em todos os ataques), mas continua `needs_review` e ainda não
  é interpretado pelo resolvedor genérico. Portanto, ainda não concede o
  ataque extra.
- **Tiro Preciso** está estruturado como bônus condicional de +4 para neutralizar
  a penalidade de –4 contra alvo engajado em combate corpo a corpo, mas continua
  `needs_review` e inativo até a mesa registrar engajamento de forma explícita.
