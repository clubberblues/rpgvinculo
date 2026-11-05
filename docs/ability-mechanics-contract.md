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

## Estados de implementação

- `draft`: estrutura ainda incompleta; não executa.
- `needs_review`: preenchida, aguardando validação de regra.
- `ready`: revisada, ainda sem integração completa no motor.
- `implemented`: resolução e ciclo de vida testados no motor.
- `partial`: apenas os efeitos listados em `implemented_features` podem ser executados.

O motor deve falhar de forma segura: efeito ausente ou desconhecido não é aplicado silenciosamente. A interface abre resolução assistida pelo Mestre e registra a decisão no log.
