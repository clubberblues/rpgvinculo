# Snapshot estrutural remoto — 2026-11-09

> Inventário de leitura do projeto Supabase conectado. Este documento é uma fotografia descritiva, **não** uma migration executável nem um dump restaurável. Não contém linhas de dados. Não usar para reset/deploy sem revisão.

## Resumo

- Relações listadas: 83.
- Índices: 229.
- Funções/procedures nomeadas: 327 (inclui SECURITY DEFINER e INVOKER; hashes MD5 servem apenas para comparação de snapshot, não como prova criptográfica).
- O inventário de constraints/policies/triggers está no catálogo PostgreSQL; consulte PROJECT_STATE.md para contagens agregadas.
- O PostgREST Exposed schemas ainda não foi confirmado no Dashboard.

## Relações e colunas

### Schema `public`

#### `public.continents`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `epiteto` | `text` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `locations_continent_id_fkey`: `public.locations(continent_id)` → `public.continents(id)`
- `monsters_continente_fkey`: `public.monsters(continente)` → `public.continents(id)`
- `character_sheets_cultura_fkey`: `public.vinculo_character_sheets(cultura)` → `public.continents(id)`

#### `public.locations`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `bigint` | não | identity: ALWAYS | — |
| `continent_id` | `text` | não | — | — |
| `tipo` | `text` | não | check: tipo = ANY (ARRAY['cidade'::text, 'vilarejo'::text, 'campo_de_batalha'::text]) | — |
| `nome` | `text` | não | — | — |
| `epiteto` | `text` | sim | — | — |
| `descricao` | `text` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `campaigns_location_id_fkey`: `public.campaigns(location_id)` → `public.locations(id)`
- `locations_continent_id_fkey`: `public.locations(continent_id)` → `public.continents(id)`

#### `public.vinculo_items`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `categoria` | `text` | não | — | — |
| `peso` | `numeric` | sim | — | — |
| `preco_ou` | `integer` | sim | — | Preço em OU. Onde o livro não fixou, é proposta da plataforma (regra D12). |
| `requisitos` | `jsonb` | sim | — | Requisitos mínimos (FOR, CON, nível). Regra D12. |
| `dados` | `jsonb` | não | — | — |
| `raridade` | `text` | sim | default: 'comum'::text | — |

**Foreign keys (relações retornadas pelo conector):**
- `character_sheets_armadura_fkey`: `public.vinculo_character_sheets(armadura)` → `public.vinculo_items(id)`
- `inventory_item_id_fkey`: `public.vinculo_inventory(item_id)` → `public.vinculo_items(id)`
- `character_sheets_escudo_fkey`: `public.vinculo_character_sheets(escudo)` → `public.vinculo_items(id)`

#### `public.campaigns`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `bigint` | não | identity: ALWAYS | — |
| `name` | `text` | não | check: char_length(name) >= 2 AND char_length(name) <= 60 | — |
| `owner_id` | `uuid` | não | — | — |
| `state` | `text` | não | default: 'EXPLORACAO'::text; check: state = ANY (ARRAY['EXPLORACAO'::text, 'COMBATE'::text, 'PAUSA'::text]) | — |
| `active` | `boolean` | não | default: true | — |
| `location_id` | `bigint` | sim | — | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |
| `briefing` | `text` | sim | — | — |
| `capa_url` | `text` | sim | — | — |
| `capa_transform` | `jsonb` | sim | default: '{}'::jsonb | — |
| `cba_data` | `jsonb` | sim | — | — |
| `combat_data` | `jsonb` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_aoo_attacks_campaign_id_fkey`: `priv.srd_aoo_attacks(campaign_id)` → `public.campaigns(id)`
- `srd_aoo_pending_movements_campaign_id_fkey`: `priv.srd_aoo_pending_movements(campaign_id)` → `public.campaigns(id)`
- `srd_aoo_reaction_ledger_campaign_id_fkey`: `priv.srd_aoo_reaction_ledger(campaign_id)` → `public.campaigns(id)`
- `members_campaign_id_fkey`: `public.members(campaign_id)` → `public.campaigns(id)`
- `srd_npc_attack_sequences_campaign_id_fkey`: `public.srd_npc_attack_sequences(campaign_id)` → `public.campaigns(id)`
- `srd_attack_sequences_campaign_id_fkey`: `public.srd_attack_sequences(campaign_id)` → `public.campaigns(id)`
- `srd_cba_token_weapon_instances_campaign_id_fkey`: `public.srd_cba_token_weapon_instances(campaign_id)` → `public.campaigns(id)`
- `srd_pending_spell_resolutions_campaign_id_fkey`: `priv.srd_pending_spell_resolutions(campaign_id)` → `public.campaigns(id)`
- `srd_campaign_effects_campaign_id_fkey`: `public.srd_campaign_effects(campaign_id)` → `public.campaigns(id)`
- `srd_campaign_conditions_campaign_id_fkey`: `public.srd_campaign_conditions(campaign_id)` → `public.campaigns(id)`
- `campaign_rule_modules_campaign_id_fkey`: `public.campaign_rule_modules(campaign_id)` → `public.campaigns(id)`
- `srd_cba_token_equipment_campaign_id_fkey`: `public.srd_cba_token_equipment(campaign_id)` → `public.campaigns(id)`
- `tokens_campaign_id_fkey`: `public.tokens(campaign_id)` → `public.campaigns(id)`
- `scenes_campaign_id_fkey`: `public.scenes(campaign_id)` → `public.campaigns(id)`
- `monster_instances_campaign_id_fkey`: `public.monster_instances(campaign_id)` → `public.campaigns(id)`
- `campaigns_location_id_fkey`: `public.campaigns(location_id)` → `public.locations(id)`
- `combat_state_campaign_id_fkey`: `public.combat_state(campaign_id)` → `public.campaigns(id)`
- `characters_campaign_id_fkey`: `public.characters(campaign_id)` → `public.campaigns(id)`
- `campaign_log_campaign_id_fkey`: `public.campaign_log(campaign_id)` → `public.campaigns(id)`
- `roll_log_campaign_id_fkey`: `public.roll_log(campaign_id)` → `public.campaigns(id)`
- `terrain_campaign_id_fkey`: `public.terrain(campaign_id)` → `public.campaigns(id)`
- `media_campaign_id_fkey`: `public.media(campaign_id)` → `public.campaigns(id)`
- `layers_campaign_id_fkey`: `public.layers(campaign_id)` → `public.campaigns(id)`
- `roll_requests_campaign_id_fkey`: `public.roll_requests(campaign_id)` → `public.campaigns(id)`
- `campaign_codes_campaign_id_fkey`: `public.campaign_codes(campaign_id)` → `public.campaigns(id)`

#### `public.campaign_codes`

- RLS: habilitado
- PK: `campaign_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `campaign_id` | `bigint` | não | — | — |
| `code` | `text` | não | check: code ~ '^[0-9]{4}$'::text | — |

**Foreign keys (relações retornadas pelo conector):**
- `campaign_codes_campaign_id_fkey`: `public.campaign_codes(campaign_id)` → `public.campaigns(id)`

#### `public.members`

- RLS: habilitado
- PK: `campaign_id`, `user_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `campaign_id` | `bigint` | não | — | — |
| `user_id` | `uuid` | não | — | — |
| `role` | `text` | não | check: role = ANY (ARRAY['GM'::text, 'PLAYER'::text, 'OBSERVER'::text]) | — |

**Foreign keys (relações retornadas pelo conector):**
- `members_campaign_id_fkey`: `public.members(campaign_id)` → `public.campaigns(id)`

#### `public.characters`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `bigint` | não | identity: ALWAYS | — |
| `campaign_id` | `bigint` | sim | — | — |
| `user_id` | `uuid` | não | — | — |
| `nome` | `text` | não | check: char_length(nome) >= 2 AND char_length(nome) <= 40 | — |
| `xp` | `integer` | não | default: 0; check: xp >= 0 | — |
| `ouro` | `integer` | não | default: 0; check: ouro >= 0 | — |
| `retrato_url` | `text` | sim | — | — |
| `arte_url` | `text` | sim | — | — |
| `arte_titulo` | `text` | sim | default: 'Arte'::text | — |
| `header_bg_url` | `text` | sim | — | — |
| `foto_transform` | `jsonb` | sim | default: '{}'::jsonb | — |
| `cultura` | `text` | sim | — | — |
| `idade` | `integer` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_npc_attack_sequences_actor_character_id_fkey`: `public.srd_npc_attack_sequences(actor_character_id)` → `public.characters(id)`
- `srd_attack_sequences_actor_character_id_fkey`: `public.srd_attack_sequences(actor_character_id)` → `public.characters(id)`
- `srd_character_feature_resources_character_id_fkey`: `public.srd_character_feature_resources(character_id)` → `public.characters(id)`
- `srd_character_domain_choices_character_id_fkey`: `public.srd_character_domain_choices(character_id)` → `public.characters(id)`
- `srd_character_spell_slot_state_character_id_fkey`: `public.srd_character_spell_slot_state(character_id)` → `public.characters(id)`
- `srd_character_prepared_spells_character_id_fkey`: `public.srd_character_prepared_spells(character_id)` → `public.characters(id)`
- `srd_character_known_spells_character_id_fkey`: `public.srd_character_known_spells(character_id)` → `public.characters(id)`
- `srd_character_spellbook_character_id_fkey`: `public.srd_character_spellbook(character_id)` → `public.characters(id)`
- `srd_character_class_levels_character_id_fkey`: `public.srd_character_class_levels(character_id)` → `public.characters(id)`
- `srd_character_sheets_character_id_fkey`: `public.srd_character_sheets(character_id)` → `public.characters(id)`
- `character_talents_character_id_fkey`: `public.character_talents(character_id)` → `public.characters(id)`
- `character_abilities_character_id_fkey`: `public.character_abilities(character_id)` → `public.characters(id)`
- `character_conditions_character_id_fkey`: `public.character_conditions(character_id)` → `public.characters(id)`
- `character_spells_character_id_fkey`: `public.character_spells(character_id)` → `public.characters(id)`
- `character_notes_character_id_fkey`: `public.vinculo_character_notes(character_id)` → `public.characters(id)`
- `tokens_character_id_fkey`: `public.tokens(character_id)` → `public.characters(id)`
- `characters_campaign_id_fkey`: `public.characters(campaign_id)` → `public.campaigns(id)`
- `inventory_character_id_fkey`: `public.vinculo_inventory(character_id)` → `public.characters(id)`
- `character_sheets_character_id_fkey`: `public.vinculo_character_sheets(character_id)` → `public.characters(id)`

#### `public.vinculo_inventory`

- RLS: habilitado
- PK: `character_id`, `item_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `character_id` | `bigint` | não | — | — |
| `item_id` | `text` | não | — | — |
| `qtd` | `integer` | não | check: qtd > 0 | — |
| `equipado` | `boolean` | não | default: false | — |

**Foreign keys (relações retornadas pelo conector):**
- `inventory_item_id_fkey`: `public.vinculo_inventory(item_id)` → `public.vinculo_items(id)`
- `inventory_character_id_fkey`: `public.vinculo_inventory(character_id)` → `public.characters(id)`

#### `public.campaign_log`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `bigint` | não | identity: ALWAYS | — |
| `campaign_id` | `bigint` | não | — | — |
| `ts` | `timestamp with time zone` | não | default: now() | — |
| `type` | `text` | não | — | — |
| `data` | `jsonb` | sim | — | — |
| `visibilidade` | `text` | não | default: 'PUBLIC'::text; check: visibilidade = ANY (ARRAY['PUBLIC'::text, 'VISIBLE'::text, 'HIDDEN'::text, 'REVEALED'::text]) | — |

**Foreign keys (relações retornadas pelo conector):**
- `campaign_log_campaign_id_fkey`: `public.campaign_log(campaign_id)` → `public.campaigns(id)`

#### `public.terrain`

- RLS: habilitado
- PK: `campaign_id`, `x`, `y`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `campaign_id` | `bigint` | não | — | — |
| `x` | `integer` | não | — | — |
| `y` | `integer` | não | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `terrain_campaign_id_fkey`: `public.terrain(campaign_id)` → `public.campaigns(id)`

#### `public.media`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `bigint` | não | identity: ALWAYS | — |
| `campaign_id` | `bigint` | não | — | — |
| `kind` | `text` | não | check: kind = ANY (ARRAY['IMAGEM'::text, 'VIDEO'::text, 'AUDIO'::text]) | — |
| `mime` | `text` | sim | — | — |
| `path` | `text` | não | — | — |
| `nome` | `text` | sim | — | — |
| `size` | `bigint` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `media_campaign_id_fkey`: `public.media(campaign_id)` → `public.campaigns(id)`
- `layers_media_id_fkey`: `public.layers(media_id)` → `public.media(id)`

#### `public.layers`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `bigint` | não | identity: ALWAYS | — |
| `campaign_id` | `bigint` | não | — | — |
| `media_id` | `bigint` | não | — | — |
| `x` | `numeric` | não | default: 0; check: x >= '-1000'::integer::numeric AND x <= 2000::numeric | — |
| `y` | `numeric` | não | default: 0; check: y >= '-1000'::integer::numeric AND y <= 2000::numeric | — |
| `w` | `numeric` | não | default: 40; check: w >= 1::numeric AND w <= 2000::numeric | — |
| `h` | `numeric` | não | default: 30; check: h >= 1::numeric AND h <= 2000::numeric | — |
| `opacity` | `numeric` | não | default: 1; check: opacity >= 0::numeric AND opacity <= 1::numeric | — |
| `z` | `text` | não | default: 'abaixo'::text; check: z = ANY (ARRAY['abaixo'::text, 'acima'::text]) | — |
| `visible` | `boolean` | não | default: true | — |
| `volume` | `numeric` | não | default: 0.5; check: volume >= 0::numeric AND volume <= 1::numeric | — |

**Foreign keys (relações retornadas pelo conector):**
- `layers_campaign_id_fkey`: `public.layers(campaign_id)` → `public.campaigns(id)`
- `layers_media_id_fkey`: `public.layers(media_id)` → `public.media(id)`

#### `public.vinculo_classes`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `origem` | `text` | não | — | — |
| `pv` | `integer` | não | — | — |
| `pm` | `integer` | não | — | — |
| `desl` | `integer` | não | — | — |
| `rm` | `integer` | não | — | — |
| `conjura` | `boolean` | não | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `character_sheets_classe_fkey`: `public.vinculo_character_sheets(classe)` → `public.vinculo_classes(id)`

#### `public.conditions`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `efeito` | `text` | não | — | — |
| `sem_acoes` | `boolean` | não | default: false | — |
| `sem_reacoes` | `boolean` | não | default: false | — |
| `sem_movimento` | `boolean` | não | default: false | — |
| `modificadores` | `jsonb` | não | default: '{}'::jsonb | — |

**Foreign keys (relações retornadas pelo conector):**
- `character_conditions_condition_id_fkey`: `public.character_conditions(condition_id)` → `public.conditions(id)`

#### `public.skills`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `integer` | não | identity: ALWAYS | — |
| `atributo` | `text` | não | check: atributo = ANY (ARRAY['FOR'::text, 'DES'::text, 'CON'::text, 'INT'::text, 'SAB'::text, 'CAR'::text]) | — |
| `nome` | `text` | não | — | — |

#### `public.vinculo_character_sheets`

- RLS: habilitado
- PK: `character_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `character_id` | `bigint` | não | — | — |
| `classe` | `text` | sim | — | — |
| `cultura` | `text` | sim | — | — |
| `atributos` | `jsonb` | não | default: '{"CAR": 1, "CON": 1, "DES": 1, "FOR": 1, "INT": 1, "SAB": 1}'::jsonb; check: jsonb_typeof(atributos) = 'object'::text | — |
| `pericias` | `jsonb` | não | default: '{}'::jsonb; check: jsonb_typeof(pericias) = 'object'::text | — |
| `armadura` | `text` | sim | — | — |
| `escudo` | `text` | sim | — | — |
| `bonus_ca` | `integer` | não | default: 0 | — |
| `bonus_rm` | `integer` | não | default: 0 | — |
| `pv_atual` | `integer` | não | default: 0 | — |
| `pm_atual` | `integer` | não | default: 0 | — |
| `ready` | `boolean` | não | default: false | — |
| `preserve_pv` | `boolean` | não | default: false | — |
| `death_state` | `jsonb` | não | default: '{"morto": false, "falhas": 0, "sucessos": 0, "estabilizado": false}'::jsonb | — |
| `updated_at` | `timestamp with time zone` | não | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `character_sheets_escudo_fkey`: `public.vinculo_character_sheets(escudo)` → `public.vinculo_items(id)`
- `character_sheets_armadura_fkey`: `public.vinculo_character_sheets(armadura)` → `public.vinculo_items(id)`
- `character_sheets_cultura_fkey`: `public.vinculo_character_sheets(cultura)` → `public.continents(id)`
- `character_sheets_classe_fkey`: `public.vinculo_character_sheets(classe)` → `public.vinculo_classes(id)`
- `character_sheets_character_id_fkey`: `public.vinculo_character_sheets(character_id)` → `public.characters(id)`

#### `public.character_conditions`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `bigint` | não | identity: ALWAYS | — |
| `character_id` | `bigint` | não | — | — |
| `condition_id` | `text` | não | — | — |
| `niveis` | `integer` | não | default: 1; check: niveis >= 1 AND niveis <= 6 | — |
| `origem` | `text` | sim | — | — |
| `duracao` | `text` | sim | — | — |
| `aplicada_em` | `timestamp with time zone` | não | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `character_conditions_condition_id_fkey`: `public.character_conditions(condition_id)` → `public.conditions(id)`
- `character_conditions_character_id_fkey`: `public.character_conditions(character_id)` → `public.characters(id)`

#### `public.combat_state`

- RLS: habilitado
- PK: `campaign_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `campaign_id` | `bigint` | não | — | — |
| `ativo` | `boolean` | não | default: false | — |
| `rodada` | `integer` | não | default: 0 | — |
| `turno_index` | `integer` | não | default: 0 | — |
| `ordem` | `jsonb` | não | default: '[]'::jsonb | — |
| `iniciado_em` | `timestamp with time zone` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `combat_state_campaign_id_fkey`: `public.combat_state(campaign_id)` → `public.campaigns(id)`

#### `public.roll_log`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `bigint` | não | identity: ALWAYS | — |
| `campaign_id` | `bigint` | não | — | — |
| `ts` | `timestamp with time zone` | não | default: now() | — |
| `tipo` | `text` | não | — | — |
| `autor_id` | `uuid` | sim | — | — |
| `alvo_id` | `bigint` | sim | — | — |
| `expressao` | `text` | sim | — | — |
| `d20` | `integer` | sim | — | — |
| `total` | `integer` | sim | — | — |
| `resultado` | `text` | sim | — | — |
| `detalhes` | `jsonb` | não | default: '{}'::jsonb | — |

**Foreign keys (relações retornadas pelo conector):**
- `roll_log_campaign_id_fkey`: `public.roll_log(campaign_id)` → `public.campaigns(id)`

#### `public.roll_requests`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `bigint` | não | identity: ALWAYS | — |
| `campaign_id` | `bigint` | não | — | — |
| `from_id` | `uuid` | não | — | — |
| `to_id` | `uuid` | não | — | — |
| `kind` | `text` | não | check: kind = ANY (ARRAY['PERICIA'::text, 'RESISTENCIA'::text, 'INICIATIVA'::text, 'LIVRE'::text]) | — |
| `label` | `text` | não | — | — |
| `atributo` | `text` | sim | check: atributo = ANY (ARRAY['FOR'::text, 'DES'::text, 'CON'::text, 'INT'::text, 'SAB'::text, 'CAR'::text]) | — |
| `cd` | `integer` | sim | — | — |
| `motivo` | `text` | sim | — | — |
| `status` | `text` | não | default: 'PENDENTE'::text; check: status = ANY (ARRAY['PENDENTE'::text, 'RESPONDIDO'::text, 'CANCELADO'::text]) | — |
| `d20` | `integer` | sim | — | — |
| `total` | `integer` | sim | — | — |
| `resposta_em` | `timestamp with time zone` | sim | — | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `roll_requests_campaign_id_fkey`: `public.roll_requests(campaign_id)` → `public.campaigns(id)`

#### `public.character_abilities`

- RLS: habilitado
- PK: `character_id`, `ability_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `character_id` | `bigint` | não | — | — |
| `ability_id` | `bigint` | não | — | — |
| `aprendida_em_nivel` | `integer` | não | — | — |
| `usos` | `jsonb` | não | default: '{}'::jsonb | — |

**Foreign keys (relações retornadas pelo conector):**
- `character_abilities_character_id_fkey`: `public.character_abilities(character_id)` → `public.characters(id)`

#### `public.character_spells`

- RLS: habilitado
- PK: `character_id`, `spell_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `character_id` | `bigint` | não | — | — |
| `spell_id` | `bigint` | não | — | — |
| `aprendida_em_nivel` | `integer` | não | default: 1 | — |
| `preparada` | `boolean` | não | default: true | — |

**Foreign keys (relações retornadas pelo conector):**
- `character_spells_character_id_fkey`: `public.character_spells(character_id)` → `public.characters(id)`

#### `public.monsters`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `continente` | `text` | não | — | — |
| `especie` | `text` | sim | — | — |
| `dificuldade` | `text` | sim | check: dificuldade = ANY (ARRAY['Fácil'::text, 'Comum'::text, 'Perigoso'::text, 'Elite'::text, 'Lendário'::text, 'Épico'::text]) | — |
| `nivel` | `integer` | não | — | — |
| `funcao` | `text` | sim | — | — |
| `descricao` | `text` | sim | — | — |
| `pv` | `integer` | não | — | — |
| `ca` | `integer` | não | — | — |
| `rm` | `integer` | não | — | — |
| `desl` | `integer` | não | — | — |
| `cd` | `integer` | sim | — | — |
| `valor_ofensivo` | `integer` | sim | — | — |
| `bonus_ataque` | `integer` | sim | — | — |
| `dano_base` | `text` | sim | — | — |
| `tipo_dano` | `text` | sim | — | — |
| `habilidade` | `text` | sim | — | — |
| `alcance` | `text` | sim | — | — |
| `alvo` | `text` | sim | — | — |
| `duracao` | `text` | sim | — | — |
| `condicao` | `text` | sim | — | — |
| `efeito` | `text` | sim | — | — |
| `limitacoes` | `text` | sim | — | — |
| `habitat` | `text` | sim | — | — |
| `recompensa` | `text` | sim | — | — |
| `created_at` | `timestamp with time zone` | sim | default: now() | — |
| `mechanics` | `jsonb` | não | default: '{}'::jsonb; check: jsonb_typeof(mechanics) = 'object'::text | Dados mecânicos estruturados das habilidades da criatura, no contrato compartilhado da mesa. |

**Foreign keys (relações retornadas pelo conector):**
- `monsters_continente_fkey`: `public.monsters(continente)` → `public.continents(id)`

#### `public.monster_instances`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `bigint` | não | default: nextval('monster_instances_id_seq'::regclass) | — |
| `campaign_id` | `bigint` | não | — | — |
| `monster_id` | `text` | não | — | — |
| `rotulo` | `text` | sim | — | — |
| `hp_atual` | `integer` | não | — | — |
| `hp_max` | `integer` | não | — | — |
| `pm_atual` | `integer` | sim | default: 0 | — |
| `pm_max` | `integer` | sim | default: 0 | — |
| `visivel` | `boolean` | sim | default: true | — |
| `estado` | `jsonb` | sim | default: '{}'::jsonb | — |
| `created_at` | `timestamp with time zone` | sim | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `monster_instances_monster_id_fkey`: `public.monster_instances(monster_id)` → `public.srd_monsters(id)`
- `tokens_monster_instance_id_fkey`: `public.tokens(monster_instance_id)` → `public.monster_instances(id)`
- `monster_instances_campaign_id_fkey`: `public.monster_instances(campaign_id)` → `public.campaigns(id)`

#### `public.scenes`

- RLS: habilitado
- PK: `campaign_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `campaign_id` | `bigint` | não | — | — |
| `imagem_url` | `text` | sim | — | — |
| `video_url` | `text` | sim | — | — |
| `audio_url` | `text` | sim | — | — |
| `audio_volume` | `numeric` | sim | default: 0.5 | — |
| `gif_url` | `text` | sim | — | — |
| `gif_scale` | `numeric` | sim | default: 1 | — |
| `tile_w` | `integer` | sim | default: 80 | — |
| `tile_h` | `integer` | sim | default: 40 | — |
| `offset_x` | `integer` | sim | default: 0 | — |
| `offset_y` | `integer` | sim | default: 0 | — |
| `metros_por_tile` | `numeric` | sim | default: 1.5 | — |
| `lim_l` | `integer` | sim | default: 0 | — |
| `lim_r` | `integer` | sim | default: 100 | — |
| `lim_t` | `integer` | sim | default: 0 | — |
| `lim_b` | `integer` | sim | default: 100 | — |
| `opacidade` | `numeric` | sim | default: 0.5 | — |
| `updated_at` | `timestamp with time zone` | sim | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `scenes_campaign_id_fkey`: `public.scenes(campaign_id)` → `public.campaigns(id)`

#### `public.tokens`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `bigint` | não | default: nextval('tokens_id_seq'::regclass) | — |
| `campaign_id` | `bigint` | não | — | — |
| `character_id` | `bigint` | sim | — | — |
| `monster_instance_id` | `bigint` | sim | — | — |
| `col` | `integer` | não | default: 0 | — |
| `row` | `integer` | não | default: 0 | — |
| `cor` | `text` | sim | default: '#c9a050'::text | — |
| `visivel` | `boolean` | sim | default: true | — |
| `updated_at` | `timestamp with time zone` | sim | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `tokens_monster_instance_id_fkey`: `public.tokens(monster_instance_id)` → `public.monster_instances(id)`
- `tokens_campaign_id_fkey`: `public.tokens(campaign_id)` → `public.campaigns(id)`
- `tokens_character_id_fkey`: `public.tokens(character_id)` → `public.characters(id)`

#### `public.profiles`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `uuid` | não | — | — |
| `username` | `text` | não | — | — |
| `avatar_url` | `text` | sim | — | — |
| `created_at` | `timestamp with time zone` | sim | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `profiles_id_fkey`: `public.profiles(id)` → `auth.users(id)`

#### `public.vinculo_character_notes`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `bigint` | não | default: nextval('character_notes_id_seq'::regclass) | — |
| `character_id` | `bigint` | sim | — | — |
| `titulo` | `text` | não | — | — |
| `corpo` | `text` | não | — | — |
| `criada_em` | `timestamp with time zone` | sim | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `character_notes_character_id_fkey`: `public.vinculo_character_notes(character_id)` → `public.characters(id)`

#### `public.character_talents`

- RLS: habilitado
- PK: `character_id`, `talent_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `character_id` | `bigint` | não | — | — |
| `talent_id` | `text` | não | — | — |
| `escolhido_em_nivel` | `integer` | não | — | — |
| `escolhido_em` | `timestamp with time zone` | sim | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `character_talents_character_id_fkey`: `public.character_talents(character_id)` → `public.characters(id)`

#### `public.vinculo_abilities`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `classe` | `text` | não | — | — |
| `nivel` | `integer` | não | — | — |
| `recurso` | `text` | sim | — | — |
| `tipo` | `text` | sim | — | — |
| `alcance` | `text` | sim | — | — |
| `alvo` | `text` | sim | — | — |
| `duracao` | `text` | sim | — | — |
| `efeito` | `text` | não | — | — |
| `limite` | `text` | sim | — | — |

#### `public.vinculo_talents`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `trilha` | `text` | não | — | — |
| `nivel_min` | `integer` | não | — | — |
| `custo_pt` | `integer` | não | — | — |
| `efeito` | `text` | não | — | — |
| `limite` | `text` | sim | — | — |
| `tipo` | `text` | sim | — | — |

#### `public.vinculo_spells`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `classe` | `text` | não | — | — |
| `circulo` | `integer` | não | — | — |
| `escola` | `text` | não | — | — |
| `custo_pm` | `integer` | não | — | — |
| `tempo` | `text` | não | — | — |
| `alcance` | `text` | sim | — | — |
| `duracao` | `text` | sim | — | — |
| `componentes` | `text` | sim | — | — |
| `efeito` | `text` | não | — | — |
| `limite` | `text` | sim | — | — |

#### `public.srd_character_sheets`

- RLS: habilitado
- PK: `character_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `character_id` | `bigint` | não | — | — |
| `classe_id` | `text` | não | — | — |
| `raca_id` | `text` | não | — | — |
| `nivel` | `integer` | sim | default: 1 | — |
| `atributos` | `jsonb` | sim | default: '{"CAR": 10, "CON": 10, "DES": 10, "FOR": 10, "INT": 10, "SAB": 10}'::jsonb | — |
| `pv_atual` | `integer` | sim | — | — |
| `xp` | `integer` | sim | default: 0 | — |
| `ouro` | `numeric` | sim | default: 0 | — |
| `talentos` | `jsonb` | sim | default: '[]'::jsonb | — |
| `magias_conhecidas` | `jsonb` | sim | default: '[]'::jsonb | — |
| `pericias_treinadas` | `jsonb` | sim | default: '[]'::jsonb | — |
| `created_at` | `timestamp with time zone` | sim | default: timezone('utc'::text, now()) | — |
| `pv_max` | `integer` | sim | — | — |
| `pericias` | `jsonb` | não | default: '{}'::jsonb | — |
| `magias_preparadas` | `jsonb` | não | default: '{"usos": {}, "version": 1, "conhecidas": [], "preparadas": []}'::jsonb | — |
| `magias_descanso_em` | `timestamp with time zone` | sim | — | — |
| `equipamento_inicial` | `jsonb` | não | default: '{}'::jsonb | — |
| `niveis_pendentes` | `integer` | não | default: 0 | — |
| `idiomas_conhecidos` | `jsonb` | não | default: '{"automaticos": [], "bonus_inteligencia": [], "comprados_falar_idioma": []}'::jsonb | — |
| `identidade` | `jsonb` | não | default: '{}'::jsonb | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_character_sheets_character_id_fkey`: `public.srd_character_sheets(character_id)` → `public.characters(id)`

#### `public.srd_classes`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `dado_vida` | `integer` | não | — | — |
| `bab_bom` | `boolean` | sim | default: true | — |
| `fort_bom` | `boolean` | sim | default: false | — |
| `ref_bom` | `boolean` | sim | default: false | — |
| `von_bom` | `boolean` | sim | default: false | — |
| `pericias_por_nivel` | `integer` | sim | default: 2 | — |
| `pericias_classe` | `jsonb` | sim | default: '[]'::jsonb | — |
| `bab_progression` | `text` | sim | default: 'poor'::text | — |
| `descricao` | `text` | não | default: ''::text | — |
| `dados_tecnicos` | `jsonb` | não | default: '{}'::jsonb | — |
| `srd_source_url` | `text` | sim | — | — |
| `imagem_url` | `text` | sim | — | — |
| `briefing` | `text` | não | default: ''::text | — |
| `source_id` | `text` | sim | — | — |
| `source_status` | `text` | não | default: 'unreviewed'::text; check: source_status = ANY (ARRAY['unreviewed'::text, 'source_attached'::text, 'verified_srd'::text, 'derived'::text, 'house_rule'::text, 'needs_license'::text, 'excluded'::text]) | — |
| `source_notes` | `text` | sim | — | — |
| `class_key` | `text` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_starting_packages_class_id_fkey`: `public.srd_starting_packages(class_id)` → `public.srd_classes(id)`
- `srd_character_spellbook_class_id_fkey`: `public.srd_character_spellbook(class_id)` → `public.srd_classes(id)`
- `srd_character_class_levels_class_id_fkey`: `public.srd_character_class_levels(class_id)` → `public.srd_classes(id)`
- `srd_character_prepared_spells_class_id_fkey`: `public.srd_character_prepared_spells(class_id)` → `public.srd_classes(id)`
- `srd_npc_archetypes_class_id_fkey`: `public.srd_npc_archetypes(class_id)` → `public.srd_classes(id)`
- `srd_character_known_spells_class_id_fkey`: `public.srd_character_known_spells(class_id)` → `public.srd_classes(id)`
- `srd_spell_level_progressions_class_id_fkey`: `public.srd_spell_level_progressions(class_id)` → `public.srd_classes(id)`
- `srd_classes_source_id_fkey`: `public.srd_classes(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_character_spell_slot_state_class_id_fkey`: `public.srd_character_spell_slot_state(class_id)` → `public.srd_classes(id)`
- `srd_class_level_progressions_class_id_fkey`: `public.srd_class_level_progressions(class_id)` → `public.srd_classes(id)`

#### `public.srd_races`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `tamanho` | `text` | sim | default: 'Médio'::text | — |
| `deslocamento` | `integer` | sim | default: 9 | — |
| `ajustes_atributos` | `jsonb` | sim | default: '{}'::jsonb | — |
| `habilidades_raciais` | `jsonb` | sim | default: '[]'::jsonb | — |
| `briefing` | `text` | não | default: ''::text | — |
| `imagem_url` | `text` | sim | — | — |
| `srd_source_url` | `text` | sim | — | — |
| `source_id` | `text` | sim | — | — |
| `source_status` | `text` | não | default: 'unreviewed'::text; check: source_status = ANY (ARRAY['unreviewed'::text, 'source_attached'::text, 'verified_srd'::text, 'derived'::text, 'house_rule'::text, 'needs_license'::text, 'excluded'::text]) | — |
| `source_notes` | `text` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_npc_archetypes_race_id_fkey`: `public.srd_npc_archetypes(race_id)` → `public.srd_races(id)`
- `srd_races_source_id_fkey`: `public.srd_races(source_id)` → `public.srd_rule_sources(source_id)`

#### `public.srd_skills`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `atributo` | `text` | não | — | — |
| `treinada_apenas` | `boolean` | sim | default: false | — |
| `penalidade_armadura` | `boolean` | sim | default: false | — |
| `descricao` | `text` | sim | — | — |
| `srd_source_url` | `text` | sim | — | — |
| `dados_tecnicos` | `jsonb` | não | default: '{}'::jsonb | — |
| `source_id` | `text` | sim | — | — |
| `source_status` | `text` | não | default: 'unreviewed'::text; check: source_status = ANY (ARRAY['unreviewed'::text, 'source_attached'::text, 'verified_srd'::text, 'derived'::text, 'house_rule'::text, 'needs_license'::text, 'excluded'::text]) | — |
| `source_notes` | `text` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_skills_source_id_fkey`: `public.srd_skills(source_id)` → `public.srd_rule_sources(source_id)`

#### `public.srd_feats`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `descricao` | `text` | não | — | — |
| `requisitos` | `jsonb` | não | default: '{}'::jsonb | — |
| `exige_parametro` | `boolean` | não | default: false | — |
| `source_id` | `text` | sim | — | — |
| `source_status` | `text` | não | default: 'unreviewed'::text; check: source_status = ANY (ARRAY['unreviewed'::text, 'source_attached'::text, 'verified_srd'::text, 'derived'::text, 'house_rule'::text, 'needs_license'::text, 'excluded'::text]) | — |
| `source_notes` | `text` | sim | — | — |
| `srd_source_url` | `text` | sim | — | — |
| `nome_pt` | `text` | sim | — | Nome localizado em português para exibição na mesa; preserva nome original em nome. |
| `descricao_pt` | `text` | sim | — | Descrição localizada em português para exibição na mesa; preserva descrição original em descricao. |
| `mechanics` | `jsonb` | não | default: '{}'::jsonb; check: jsonb_typeof(mechanics) = 'object'::text | Dados mecânicos executáveis da habilidade/talento. Contrato versionado compartilhado com habilidades de classe e monstros. |

**Foreign keys (relações retornadas pelo conector):**
- `srd_feats_source_id_fkey`: `public.srd_feats(source_id)` → `public.srd_rule_sources(source_id)`

#### `public.srd_equipment`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `tipo` | `text` | não | — | — |
| `dano` | `text` | sim | — | — |
| `critico` | `text` | sim | — | — |
| `tipo_dano` | `text` | sim | — | — |
| `ca_bonus` | `integer` | sim | — | — |
| `max_des` | `integer` | sim | — | — |
| `penalidade_armadura` | `integer` | sim | — | — |
| `peso` | `numeric` | sim | default: 0 | — |
| `preco` | `numeric` | sim | default: 0 | — |
| `descricao` | `text` | não | default: ''::text | — |
| `srd_source_url` | `text` | sim | — | — |
| `categoria` | `text` | não | — | — |
| `bonus_ca` | `integer` | sim | default: 0 | — |
| `bonus_max_des` | `integer` | sim | — | — |
| `custo_po` | `numeric` | sim | default: 0 | — |
| `detalhes` | `jsonb` | não | default: '{}'::jsonb | — |
| `source_id` | `text` | sim | — | — |
| `source_status` | `text` | não | default: 'unreviewed'::text; check: source_status = ANY (ARRAY['unreviewed'::text, 'source_attached'::text, 'verified_srd'::text, 'derived'::text, 'house_rule'::text, 'needs_license'::text, 'excluded'::text]) | — |
| `source_notes` | `text` | sim | — | — |
| `alcance_incremento` | `text` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_character_weapon_instances_equipment_id_fkey`: `public.srd_character_weapon_instances(equipment_id)` → `public.srd_equipment(id)`
- `srd_equipment_audit_equipment_id_fkey`: `public.srd_equipment_audit(equipment_id)` → `public.srd_equipment(id)`
- `srd_equipment_source_id_fkey`: `public.srd_equipment(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_cba_token_equipment_equipment_id_fkey`: `public.srd_cba_token_equipment(equipment_id)` → `public.srd_equipment(id)`
- `srd_cba_token_weapon_instances_equipment_id_fkey`: `public.srd_cba_token_weapon_instances(equipment_id)` → `public.srd_equipment(id)`
- `srd_character_equipment_equipment_id_fkey`: `public.srd_character_equipment(equipment_id)` → `public.srd_equipment(id)`

#### `public.srd_monsters`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `nome_original` | `text` | sim | — | — |
| `nd` | `text` | sim | — | — |
| `tamanho` | `text` | sim | — | — |
| `tipo` | `text` | sim | — | — |
| `tendencia` | `text` | sim | — | — |
| `dados_vida` | `text` | sim | — | — |
| `pv` | `integer` | sim | — | — |
| `iniciativa` | `text` | sim | — | — |
| `deslocamento` | `text` | sim | — | — |
| `ca` | `text` | sim | — | — |
| `base_attack_grapple` | `text` | sim | — | — |
| `ataques` | `text` | sim | — | — |
| `espaco_alcance` | `text` | sim | — | — |
| `fortitude` | `text` | sim | — | — |
| `reflexos` | `text` | sim | — | — |
| `vontade` | `text` | sim | — | — |
| `forca` | `integer` | sim | — | — |
| `destreza` | `integer` | sim | — | — |
| `constituicao` | `integer` | sim | — | — |
| `inteligencia` | `integer` | sim | — | — |
| `sabedoria` | `integer` | sim | — | — |
| `carisma` | `integer` | sim | — | — |
| `pericias` | `text` | sim | — | — |
| `talentos` | `text` | sim | — | — |
| `qualidades_especiais` | `jsonb` | não | default: '[]'::jsonb | — |
| `descricao` | `text` | não | default: ''::text | — |
| `dados_tecnicos` | `jsonb` | não | default: '{}'::jsonb | — |
| `srd_source_url` | `text` | sim | — | — |
| `srd_canonical` | `boolean` | não | default: true | — |
| `updated_at` | `timestamp with time zone` | não | default: now() | — |
| `source_id` | `text` | sim | — | — |
| `source_status` | `text` | não | default: 'unreviewed'::text; check: source_status = ANY (ARRAY['unreviewed'::text, 'source_attached'::text, 'verified_srd'::text, 'derived'::text, 'house_rule'::text, 'needs_license'::text, 'excluded'::text]) | — |
| `source_notes` | `text` | sim | — | — |
| `mechanics` | `jsonb` | não | default: '{}'::jsonb; check: jsonb_typeof(mechanics) = 'object'::text | Dados mecânicos estruturados das habilidades da criatura SRD; dados_tecnicos e qualidades_especiais legados são preservados. |

**Foreign keys (relações retornadas pelo conector):**
- `monster_instances_monster_id_fkey`: `public.monster_instances(monster_id)` → `public.srd_monsters(id)`
- `srd_monsters_source_id_fkey`: `public.srd_monsters(source_id)` → `public.srd_rule_sources(source_id)`

#### `public.srd_spells`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `nivel` | `text` | sim | — | — |
| `circulo` | `smallint` | sim | — | — |
| `escola` | `text` | sim | — | — |
| `alcance` | `text` | sim | — | — |
| `alvo` | `text` | sim | — | — |
| `area` | `text` | sim | — | — |
| `duracao` | `text` | sim | — | — |
| `componentes` | `text` | sim | — | — |
| `classes` | `ARRAY` | não | default: ARRAY[]::text[] | — |
| `descricao` | `text` | não | default: ''::text | — |
| `dados_tecnicos` | `jsonb` | não | default: '{}'::jsonb | — |
| `srd_source_url` | `text` | sim | — | — |
| `updated_at` | `timestamp with time zone` | não | default: now() | — |
| `source_id` | `text` | sim | — | — |
| `source_status` | `text` | não | default: 'unreviewed'::text; check: source_status = ANY (ARRAY['unreviewed'::text, 'source_attached'::text, 'verified_srd'::text, 'derived'::text, 'house_rule'::text, 'needs_license'::text, 'excluded'::text]) | — |
| `source_notes` | `text` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_character_spellbook_spell_id_fkey`: `public.srd_character_spellbook(spell_id)` → `public.srd_spells(id)`
- `srd_character_prepared_spells_spell_id_fkey`: `public.srd_character_prepared_spells(spell_id)` → `public.srd_spells(id)`
- `srd_spell_effects_spell_id_fkey`: `public.srd_spell_effects(spell_id)` → `public.srd_spells(id)`
- `srd_pending_spell_resolutions_spell_id_fkey`: `priv.srd_pending_spell_resolutions(spell_id)` → `public.srd_spells(id)`
- `srd_campaign_effects_source_spell_id_fkey`: `public.srd_campaign_effects(source_spell_id)` → `public.srd_spells(id)`
- `srd_campaign_conditions_source_spell_id_fkey`: `public.srd_campaign_conditions(source_spell_id)` → `public.srd_spells(id)`
- `srd_spells_source_id_fkey`: `public.srd_spells(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_domain_spells_spell_id_fkey`: `public.srd_domain_spells(spell_id)` → `public.srd_spells(id)`
- `srd_character_known_spells_spell_id_fkey`: `public.srd_character_known_spells(spell_id)` → `public.srd_spells(id)`

#### `public.srd_spell_progressions`

- RLS: habilitado
- PK: `class_key`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `class_key` | `text` | não | — | — |
| `slots_by_level` | `jsonb` | não | — | — |
| `known_by_level` | `jsonb` | não | default: '[]'::jsonb | — |

#### `public.srd_character_equipment`

- RLS: habilitado
- PK: `character_id`, `equipment_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `character_id` | `text` | não | — | — |
| `equipment_id` | `text` | não | — | — |
| `quantidade` | `integer` | não | default: 1; check: quantidade > 0 | — |
| `equipado` | `boolean` | não | default: false | — |
| `criado_em` | `timestamp with time zone` | não | default: now() | — |
| `hand_slot` | `text` | sim | check: hand_slot IS NULL OR (hand_slot = ANY (ARRAY['main_hand'::text, 'off_hand'::text])) | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_character_equipment_equipment_id_fkey`: `public.srd_character_equipment(equipment_id)` → `public.srd_equipment(id)`

#### `public.srd_npc_archetypes`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `race_id` | `text` | não | — | — |
| `class_id` | `text` | não | — | — |
| `variant` | `smallint` | não | check: variant >= 1 AND variant <= 5 | — |
| `role_key` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `briefing` | `text` | não | — | — |
| `foco_atributos` | `jsonb` | não | default: '[]'::jsonb | — |
| `updated_at` | `timestamp with time zone` | não | default: now() | — |
| `source_id` | `text` | sim | — | — |
| `source_status` | `text` | não | default: 'unreviewed'::text; check: source_status = ANY (ARRAY['unreviewed'::text, 'source_attached'::text, 'verified_srd'::text, 'derived'::text, 'house_rule'::text, 'needs_license'::text, 'excluded'::text]) | — |
| `source_notes` | `text` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_npc_archetypes_race_id_fkey`: `public.srd_npc_archetypes(race_id)` → `public.srd_races(id)`
- `srd_npc_archetypes_class_id_fkey`: `public.srd_npc_archetypes(class_id)` → `public.srd_classes(id)`
- `srd_npc_archetypes_source_id_fkey`: `public.srd_npc_archetypes(source_id)` → `public.srd_rule_sources(source_id)`

#### `public.srd_cba_token_equipment`

- RLS: habilitado
- PK: `campaign_id`, `token_id`, `equipment_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `campaign_id` | `bigint` | não | — | — |
| `token_id` | `text` | não | — | — |
| `equipment_id` | `text` | não | — | — |
| `quantidade` | `integer` | não | default: 1; check: quantidade > 0 | — |
| `equipado` | `boolean` | não | default: false | — |
| `criado_em` | `timestamp with time zone` | não | default: now() | — |
| `hand_slot` | `text` | sim | check: hand_slot IS NULL OR (hand_slot = ANY (ARRAY['main_hand'::text, 'off_hand'::text])) | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_cba_token_equipment_equipment_id_fkey`: `public.srd_cba_token_equipment(equipment_id)` → `public.srd_equipment(id)`
- `srd_cba_token_equipment_campaign_id_fkey`: `public.srd_cba_token_equipment(campaign_id)` → `public.campaigns(id)`

#### `public.srd_starting_packages`

- RLS: habilitado
- PK: `class_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `class_id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `items` | `jsonb` | não | check: jsonb_typeof(items) = 'array'::text | — |
| `observacao` | `text` | não | default: ''::text | — |
| `source_id` | `text` | sim | — | — |
| `source_status` | `text` | não | default: 'unreviewed'::text; check: source_status = ANY (ARRAY['unreviewed'::text, 'source_attached'::text, 'verified_srd'::text, 'derived'::text, 'house_rule'::text, 'needs_license'::text, 'excluded'::text]) | — |
| `source_notes` | `text` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_starting_packages_source_id_fkey`: `public.srd_starting_packages(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_starting_packages_class_id_fkey`: `public.srd_starting_packages(class_id)` → `public.srd_classes(id)`

#### `public.srd_rule_sources`

- RLS: habilitado
- PK: `source_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `source_id` | `text` | não | — | — |
| `title` | `text` | não | — | — |
| `edition` | `text` | não | — | — |
| `version` | `text` | não | — | — |
| `license_identifier` | `text` | não | — | — |
| `attribution` | `text` | não | — | — |
| `source_url` | `text` | não | check: source_url ~ '^https://'::text | — |
| `is_open_content` | `boolean` | não | default: false | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_spell_level_progressions_source_id_fkey`: `public.srd_spell_level_progressions(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_domains_source_id_fkey`: `public.srd_domains(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_npc_archetypes_source_id_fkey`: `public.srd_npc_archetypes(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_class_level_progressions_source_id_fkey`: `public.srd_class_level_progressions(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_class_level_features_source_id_fkey`: `public.srd_class_level_features(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_spell_effects_source_id_fkey`: `public.srd_spell_effects(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_conditions_source_id_fkey`: `public.srd_conditions(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_domain_spells_source_id_fkey`: `public.srd_domain_spells(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_rulesets_primary_source_id_fkey`: `public.srd_rulesets(primary_source_id)` → `public.srd_rule_sources(source_id)`
- `srd_rule_modules_source_id_fkey`: `public.srd_rule_modules(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_races_source_id_fkey`: `public.srd_races(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_classes_source_id_fkey`: `public.srd_classes(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_skills_source_id_fkey`: `public.srd_skills(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_feats_source_id_fkey`: `public.srd_feats(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_equipment_source_id_fkey`: `public.srd_equipment(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_spells_source_id_fkey`: `public.srd_spells(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_monsters_source_id_fkey`: `public.srd_monsters(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_starting_packages_source_id_fkey`: `public.srd_starting_packages(source_id)` → `public.srd_rule_sources(source_id)`

#### `public.srd_rulesets`

- RLS: habilitado
- PK: `ruleset_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `ruleset_id` | `text` | não | — | — |
| `name` | `text` | não | — | — |
| `edition` | `text` | não | — | — |
| `version` | `text` | não | — | — |
| `primary_source_id` | `text` | sim | — | — |
| `locale` | `text` | não | default: 'pt-BR'::text | — |
| `status` | `text` | não | default: 'draft'::text; check: status = ANY (ARRAY['draft'::text, 'active'::text, 'retired'::text]) | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_rule_modules_ruleset_id_fkey`: `public.srd_rule_modules(ruleset_id)` → `public.srd_rulesets(ruleset_id)`
- `srd_rulesets_primary_source_id_fkey`: `public.srd_rulesets(primary_source_id)` → `public.srd_rule_sources(source_id)`
- `srd_catalog_coverage_ruleset_id_fkey`: `public.srd_catalog_coverage(ruleset_id)` → `public.srd_rulesets(ruleset_id)`

#### `public.srd_rule_modules`

- RLS: habilitado
- PK: `module_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `module_id` | `text` | não | — | — |
| `ruleset_id` | `text` | não | — | — |
| `module_key` | `text` | não | — | — |
| `title` | `text` | não | — | — |
| `module_kind` | `text` | não | default: 'core'::text; check: module_kind = ANY (ARRAY['core'::text, 'supplement'::text, 'house_rule'::text, 'interface'::text]) | — |
| `source_id` | `text` | sim | — | — |
| `enabled_by_default` | `boolean` | não | default: false | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_rule_modules_ruleset_id_fkey`: `public.srd_rule_modules(ruleset_id)` → `public.srd_rulesets(ruleset_id)`
- `srd_rule_modules_source_id_fkey`: `public.srd_rule_modules(source_id)` → `public.srd_rule_sources(source_id)`
- `campaign_rule_modules_module_id_fkey`: `public.campaign_rule_modules(module_id)` → `public.srd_rule_modules(module_id)`

#### `public.campaign_rule_modules`

- RLS: habilitado
- PK: `campaign_id`, `module_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `campaign_id` | `bigint` | não | — | — |
| `module_id` | `text` | não | — | — |
| `enabled` | `boolean` | não | default: true | — |
| `automation_level` | `text` | não | default: 'validate'::text; check: automation_level = ANY (ARRAY['remind'::text, 'validate'::text, 'resolve'::text]) | — |
| `settings` | `jsonb` | não | default: '{}'::jsonb; check: jsonb_typeof(settings) = 'object'::text | — |
| `updated_at` | `timestamp with time zone` | não | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `campaign_rule_modules_campaign_id_fkey`: `public.campaign_rule_modules(campaign_id)` → `public.campaigns(id)`
- `campaign_rule_modules_module_id_fkey`: `public.campaign_rule_modules(module_id)` → `public.srd_rule_modules(module_id)`

#### `public.srd_class_level_progressions`

- RLS: habilitado
- PK: `class_id`, `class_level`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `class_id` | `text` | não | — | — |
| `class_level` | `smallint` | não | check: class_level >= 1 AND class_level <= 20 | — |
| `base_attack_bonus` | `numeric` | não | check: base_attack_bonus >= 0::numeric | — |
| `base_fortitude` | `smallint` | não | check: base_fortitude >= 0 | — |
| `base_reflex` | `smallint` | não | check: base_reflex >= 0 | — |
| `base_will` | `smallint` | não | check: base_will >= 0 | — |
| `skill_points_per_level` | `smallint` | não | default: 0; check: skill_points_per_level >= 0 | — |
| `first_level_skill_multiplier` | `smallint` | não | default: 4; check: first_level_skill_multiplier > 0 | — |
| `source_id` | `text` | sim | — | — |
| `verification_status` | `text` | não | default: 'derived_pending_review'::text; check: verification_status = ANY (ARRAY['derived_pending_review'::text, 'verified_srd'::text, 'needs_review'::text]) | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_class_level_features_class_id_class_level_fkey`: `public.srd_class_level_features(class_id,class_level)` → `public.srd_class_level_progressions(class_id,class_level)`
- `srd_class_level_progressions_class_id_fkey`: `public.srd_class_level_progressions(class_id)` → `public.srd_classes(id)`
- `srd_class_level_progressions_source_id_fkey`: `public.srd_class_level_progressions(source_id)` → `public.srd_rule_sources(source_id)`

#### `public.srd_class_level_features`

- RLS: habilitado
- PK: `class_id`, `class_level`, `feature_key`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `class_id` | `text` | não | — | — |
| `class_level` | `smallint` | não | — | — |
| `feature_key` | `text` | não | — | — |
| `name` | `text` | não | — | — |
| `summary` | `text` | não | default: ''::text | — |
| `mechanics` | `jsonb` | não | default: '{}'::jsonb; check: jsonb_typeof(mechanics) = 'object'::text | — |
| `source_id` | `text` | sim | — | — |
| `verification_status` | `text` | não | default: 'unreviewed'::text; check: verification_status = ANY (ARRAY['unreviewed'::text, 'verified_srd'::text, 'derived'::text, 'needs_license'::text]) | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_class_level_features_class_id_class_level_fkey`: `public.srd_class_level_features(class_id,class_level)` → `public.srd_class_level_progressions(class_id,class_level)`
- `srd_class_level_features_source_id_fkey`: `public.srd_class_level_features(source_id)` → `public.srd_rule_sources(source_id)`

#### `public.srd_spell_level_progressions`

- RLS: habilitado
- PK: `class_id`, `class_level`, `spell_level`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `class_id` | `text` | não | — | — |
| `class_level` | `smallint` | não | check: class_level >= 1 AND class_level <= 20 | — |
| `spell_level` | `smallint` | não | check: spell_level >= 0 AND spell_level <= 9 | — |
| `base_slots` | `smallint` | não | default: 0; check: base_slots >= 0 | — |
| `known_spells` | `smallint` | sim | check: known_spells IS NULL OR known_spells >= '-1'::integer | — |
| `source_id` | `text` | sim | — | — |
| `verification_status` | `text` | não | default: 'derived_pending_review'::text; check: verification_status = ANY (ARRAY['derived_pending_review'::text, 'verified_srd'::text, 'needs_review'::text]) | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_spell_level_progressions_source_id_fkey`: `public.srd_spell_level_progressions(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_spell_level_progressions_class_id_fkey`: `public.srd_spell_level_progressions(class_id)` → `public.srd_classes(id)`

#### `public.srd_domains`

- RLS: habilitado
- PK: `domain_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `domain_id` | `text` | não | — | — |
| `name` | `text` | não | — | — |
| `granted_power_summary` | `text` | não | default: ''::text | — |
| `mechanics` | `jsonb` | não | default: '{}'::jsonb; check: jsonb_typeof(mechanics) = 'object'::text | — |
| `source_id` | `text` | sim | — | — |
| `source_url` | `text` | sim | — | — |
| `verification_status` | `text` | não | default: 'unreviewed'::text; check: verification_status = ANY (ARRAY['unreviewed'::text, 'verified_srd'::text, 'needs_review'::text, 'needs_license'::text]) | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_domains_source_id_fkey`: `public.srd_domains(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_character_domain_choices_domain_id_fkey`: `public.srd_character_domain_choices(domain_id)` → `public.srd_domains(domain_id)`
- `srd_domain_spells_domain_id_fkey`: `public.srd_domain_spells(domain_id)` → `public.srd_domains(domain_id)`

#### `public.srd_domain_spells`

- RLS: habilitado
- PK: `domain_id`, `spell_level`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `domain_id` | `text` | não | — | — |
| `spell_level` | `smallint` | não | check: spell_level >= 0 AND spell_level <= 9 | — |
| `spell_id` | `text` | não | — | — |
| `source_id` | `text` | sim | — | — |
| `verification_status` | `text` | não | default: 'unreviewed'::text; check: verification_status = ANY (ARRAY['unreviewed'::text, 'verified_srd'::text, 'needs_review'::text]) | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_domain_spells_spell_id_fkey`: `public.srd_domain_spells(spell_id)` → `public.srd_spells(id)`
- `srd_domain_spells_source_id_fkey`: `public.srd_domain_spells(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_domain_spells_domain_id_fkey`: `public.srd_domain_spells(domain_id)` → `public.srd_domains(domain_id)`

#### `public.srd_character_class_levels`

- RLS: habilitado
- PK: `character_id`, `class_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `character_id` | `bigint` | não | — | — |
| `class_id` | `text` | não | — | — |
| `class_level` | `integer` | não | check: class_level > 0 | — |
| `taken_at_character_level` | `integer` | sim | check: taken_at_character_level IS NULL OR taken_at_character_level > 0 | — |
| `hit_points_gained` | `integer` | sim | check: hit_points_gained IS NULL OR hit_points_gained >= 0 | — |
| `skill_points_spent` | `jsonb` | não | default: '{}'::jsonb; check: jsonb_typeof(skill_points_spent) = 'object'::text | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_character_class_levels_character_id_fkey`: `public.srd_character_class_levels(character_id)` → `public.characters(id)`
- `srd_character_class_levels_class_id_fkey`: `public.srd_character_class_levels(class_id)` → `public.srd_classes(id)`

#### `public.srd_character_spellbook`

- RLS: habilitado
- PK: `character_id`, `class_id`, `spell_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `character_id` | `bigint` | não | — | — |
| `class_id` | `text` | não | — | — |
| `spell_id` | `text` | não | — | — |
| `acquired_at` | `timestamp with time zone` | não | default: now() | — |
| `source_note` | `text` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_character_spellbook_spell_id_fkey`: `public.srd_character_spellbook(spell_id)` → `public.srd_spells(id)`
- `srd_character_spellbook_character_id_fkey`: `public.srd_character_spellbook(character_id)` → `public.characters(id)`
- `srd_character_spellbook_class_id_fkey`: `public.srd_character_spellbook(class_id)` → `public.srd_classes(id)`

#### `public.srd_character_known_spells`

- RLS: habilitado
- PK: `character_id`, `class_id`, `spell_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `character_id` | `bigint` | não | — | — |
| `class_id` | `text` | não | — | — |
| `spell_id` | `text` | não | — | — |
| `learned_at_character_level` | `integer` | não | default: 1; check: learned_at_character_level > 0 | — |
| `source_note` | `text` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_character_known_spells_class_id_fkey`: `public.srd_character_known_spells(class_id)` → `public.srd_classes(id)`
- `srd_character_known_spells_spell_id_fkey`: `public.srd_character_known_spells(spell_id)` → `public.srd_spells(id)`
- `srd_character_known_spells_character_id_fkey`: `public.srd_character_known_spells(character_id)` → `public.characters(id)`

#### `public.srd_character_prepared_spells`

- RLS: habilitado
- PK: `preparation_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `preparation_id` | `bigint` | não | identity: BY DEFAULT | — |
| `character_id` | `bigint` | não | — | — |
| `class_id` | `text` | não | — | — |
| `spell_id` | `text` | sim | — | — |
| `spell_level` | `smallint` | não | check: spell_level >= 0 AND spell_level <= 9 | — |
| `slot_number` | `smallint` | não | check: slot_number > 0 | — |
| `prepared_for` | `timestamp with time zone` | não | — | — |
| `expended` | `boolean` | não | default: false | — |
| `source_track` | `text` | não | default: 'class'::text; check: source_track = ANY (ARRAY['class'::text, 'domain'::text, 'special'::text]) | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_character_prepared_spells_spell_id_fkey`: `public.srd_character_prepared_spells(spell_id)` → `public.srd_spells(id)`
- `srd_character_prepared_spells_character_id_fkey`: `public.srd_character_prepared_spells(character_id)` → `public.characters(id)`
- `srd_character_prepared_spells_class_id_fkey`: `public.srd_character_prepared_spells(class_id)` → `public.srd_classes(id)`

#### `public.srd_character_spell_slot_state`

- RLS: habilitado
- PK: `character_id`, `class_id`, `spell_level`, `period_started_at`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `character_id` | `bigint` | não | — | — |
| `class_id` | `text` | não | — | — |
| `spell_level` | `smallint` | não | check: spell_level >= 0 AND spell_level <= 9 | — |
| `period_started_at` | `timestamp with time zone` | não | — | — |
| `max_slots` | `smallint` | não | check: max_slots >= 0 | — |
| `expended_slots` | `smallint` | não | default: 0 | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_character_spell_slot_state_character_id_fkey`: `public.srd_character_spell_slot_state(character_id)` → `public.characters(id)`
- `srd_character_spell_slot_state_class_id_fkey`: `public.srd_character_spell_slot_state(class_id)` → `public.srd_classes(id)`

#### `public.srd_character_domain_choices`

- RLS: habilitado
- PK: `character_id`, `domain_slot`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `character_id` | `bigint` | não | — | — |
| `domain_slot` | `smallint` | não | check: domain_slot >= 1 AND domain_slot <= 2 | — |
| `domain_id` | `text` | não | — | — |
| `chosen_at` | `timestamp with time zone` | não | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_character_domain_choices_character_id_fkey`: `public.srd_character_domain_choices(character_id)` → `public.characters(id)`
- `srd_character_domain_choices_domain_id_fkey`: `public.srd_character_domain_choices(domain_id)` → `public.srd_domains(domain_id)`

#### `public.srd_conditions`

- RLS: habilitado
- PK: `condition_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `condition_id` | `text` | não | — | — |
| `name` | `text` | não | — | — |
| `summary` | `text` | não | default: ''::text | — |
| `mechanical_effects` | `jsonb` | não | default: '{}'::jsonb; check: jsonb_typeof(mechanical_effects) = 'object'::text | — |
| `source_id` | `text` | sim | — | — |
| `source_url` | `text` | sim | — | — |
| `verification_status` | `text` | não | default: 'unreviewed'::text; check: verification_status = ANY (ARRAY['unreviewed'::text, 'verified_srd'::text, 'needs_review'::text, 'needs_license'::text]) | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_conditions_source_id_fkey`: `public.srd_conditions(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_campaign_conditions_condition_id_fkey`: `public.srd_campaign_conditions(condition_id)` → `public.srd_conditions(condition_id)`
- `srd_condition_engine_rules_condition_id_fkey`: `priv.srd_condition_engine_rules(condition_id)` → `public.srd_conditions(condition_id)`
- `srd_pending_spell_resolutions_condition_id_fkey`: `priv.srd_pending_spell_resolutions(condition_id)` → `public.srd_conditions(condition_id)`

#### `public.srd_spell_effects`

- RLS: habilitado
- PK: `spell_id`, `effect_index`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `spell_id` | `text` | não | — | — |
| `effect_index` | `smallint` | não | check: effect_index > 0 | — |
| `effect_kind` | `text` | não | check: effect_kind = ANY (ARRAY['attack'::text, 'damage'::text, 'healing'::text, 'saving_throw'::text, 'condition'::text, 'buff'::text, 'debuff'::text, 'summon'::text, 'movement'::text, 'utility'::text, 'drain'::text, 'special'::text, 'manual'::text]) | — |
| `target_kind` | `text` | não | default: 'target'::text | — |
| `saving_throw` | `text` | sim | check: saving_throw IS NULL OR (saving_throw = ANY (ARRAY['fortitude'::text, 'reflex'::text, 'will'::text, 'special'::text])) | — |
| `save_result` | `text` | sim | check: save_result IS NULL OR (save_result = ANY (ARRAY['negates'::text, 'partial'::text, 'half'::text, 'special'::text])) | — |
| `spell_resistance` | `boolean` | sim | — | — |
| `damage_expression` | `text` | sim | — | — |
| `duration_expression` | `text` | sim | — | — |
| `parameters` | `jsonb` | não | default: '{}'::jsonb; check: jsonb_typeof(parameters) = 'object'::text | — |
| `source_id` | `text` | sim | — | — |
| `verification_status` | `text` | não | default: 'unreviewed'::text; check: verification_status = ANY (ARRAY['unreviewed'::text, 'verified_srd'::text, 'needs_review'::text, 'manual_only'::text]) | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_spell_effects_source_id_fkey`: `public.srd_spell_effects(source_id)` → `public.srd_rule_sources(source_id)`
- `srd_spell_effects_spell_id_fkey`: `public.srd_spell_effects(spell_id)` → `public.srd_spells(id)`

#### `public.srd_campaign_conditions`

- RLS: habilitado
- PK: `condition_instance_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `condition_instance_id` | `bigint` | não | identity: BY DEFAULT | — |
| `campaign_id` | `bigint` | não | — | — |
| `target_kind` | `text` | não | check: target_kind = ANY (ARRAY['character'::text, 'token'::text]) | — |
| `target_id` | `text` | não | — | — |
| `condition_id` | `text` | não | — | — |
| `source_spell_id` | `text` | sim | — | — |
| `source_actor_id` | `text` | sim | — | — |
| `started_round` | `integer` | sim | — | — |
| `expires_round` | `integer` | sim | — | — |
| `active` | `boolean` | não | default: true | — |
| `notes` | `jsonb` | não | default: '{}'::jsonb; check: jsonb_typeof(notes) = 'object'::text | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_campaign_conditions_campaign_id_fkey`: `public.srd_campaign_conditions(campaign_id)` → `public.campaigns(id)`
- `srd_pending_spell_resolutions_condition_break_instance_id_fkey`: `priv.srd_pending_spell_resolutions(condition_break_instance_id)` → `public.srd_campaign_conditions(condition_instance_id)`
- `srd_campaign_conditions_source_spell_id_fkey`: `public.srd_campaign_conditions(source_spell_id)` → `public.srd_spells(id)`
- `srd_campaign_conditions_condition_id_fkey`: `public.srd_campaign_conditions(condition_id)` → `public.srd_conditions(condition_id)`

#### `public.srd_campaign_effects`

- RLS: habilitado
- PK: `effect_instance_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `effect_instance_id` | `bigint` | não | identity: BY DEFAULT | — |
| `campaign_id` | `bigint` | não | — | — |
| `target_kind` | `text` | não | check: target_kind = ANY (ARRAY['character'::text, 'token'::text, 'area'::text]) | — |
| `target_id` | `text` | sim | — | — |
| `source_spell_id` | `text` | sim | — | — |
| `effect_kind` | `text` | não | — | — |
| `started_round` | `integer` | sim | — | — |
| `expires_round` | `integer` | sim | — | — |
| `concentration_actor_id` | `text` | sim | — | — |
| `active` | `boolean` | não | default: true | — |
| `effect_data` | `jsonb` | não | default: '{}'::jsonb; check: jsonb_typeof(effect_data) = 'object'::text | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_campaign_effects_campaign_id_fkey`: `public.srd_campaign_effects(campaign_id)` → `public.campaigns(id)`
- `srd_campaign_effects_source_spell_id_fkey`: `public.srd_campaign_effects(source_spell_id)` → `public.srd_spells(id)`

#### `public.srd_catalog_coverage`

- RLS: habilitado
- PK: `catalog_key`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `catalog_key` | `text` | não | — | — |
| `ruleset_id` | `text` | não | — | — |
| `expected_entries` | `integer` | sim | check: expected_entries IS NULL OR expected_entries >= 0 | — |
| `actual_entries` | `integer` | não | default: 0; check: actual_entries >= 0 | — |
| `verified_entries` | `integer` | não | default: 0; check: verified_entries >= 0 | — |
| `audit_status` | `text` | não | default: 'pending'::text; check: audit_status = ANY (ARRAY['pending'::text, 'in_progress'::text, 'complete'::text, 'blocked'::text, 'excluded'::text]) | — |
| `audit_notes` | `text` | sim | — | — |
| `updated_at` | `timestamp with time zone` | não | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_catalog_coverage_ruleset_id_fkey`: `public.srd_catalog_coverage(ruleset_id)` → `public.srd_rulesets(ruleset_id)`

#### `public.srd_equipment_audit`

- RLS: habilitado
- PK: `equipment_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `equipment_id` | `text` | não | — | — |
| `audit_run_at` | `timestamp with time zone` | não | default: now() | — |
| `has_name` | `boolean` | não | — | — |
| `has_category` | `boolean` | não | — | — |
| `has_price` | `boolean` | não | — | — |
| `has_weight` | `boolean` | não | — | — |
| `has_description` | `boolean` | não | — | — |
| `has_source` | `boolean` | não | — | — |
| `has_technical_data` | `boolean` | não | — | — |
| `audit_status` | `text` | não | check: audit_status = ANY (ARRAY['ready_for_manual_review'::text, 'needs_data_fix'::text, 'manual_verified'::text, 'not_applicable_or_unspecified'::text]) | — |
| `audit_notes` | `text` | não | default: ''::text | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_equipment_audit_equipment_id_fkey`: `public.srd_equipment_audit(equipment_id)` → `public.srd_equipment(id)`

#### `public.srd_catalog_entry_audit`

- RLS: habilitado
- PK: `catalog_key`, `entry_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `catalog_key` | `text` | não | — | — |
| `entry_id` | `text` | não | — | — |
| `audit_run_at` | `timestamp with time zone` | não | default: now() | — |
| `checks` | `jsonb` | não | — | — |
| `audit_status` | `text` | não | — | — |
| `audit_notes` | `text` | não | default: ''::text | — |

#### `public.srd_languages`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `text` | não | — | — |
| `nome` | `text` | não | — | — |
| `is_secret` | `boolean` | não | default: false | — |
| `source_status` | `text` | não | default: 'official'::text | — |
| `source_notes` | `text` | sim | — | — |

#### `public.srd_deities`

- RLS: habilitado
- PK: `deity_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `deity_id` | `text` | não | — | — |
| `name` | `text` | não | — | — |
| `alignment` | `text` | não | check: alignment = ANY (ARRAY['Leal e Bom'::text, 'Neutro e Bom'::text, 'Caótico e Bom'::text, 'Leal e Neutro'::text, 'Neutro'::text, 'Caótico e Neutro'::text, 'Leal e Mau'::text, 'Neutro e Mau'::text, 'Caótico e Mau'::text]) | — |
| `domains` | `ARRAY` | não | default: '{}'::text[] | — |
| `favored_weapon` | `text` | não | — | — |
| `racial_races` | `ARRAY` | não | default: '{}'::text[] | — |
| `source_reference` | `text` | não | default: 'D&D 3.5 Livro do Jogador, capítulo 6, páginas 93–95'::text | — |
| `verification_status` | `text` | não | default: 'verified_book'::text | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |

#### `public.srd_character_feature_resources`

- RLS: habilitado
- PK: `character_id`, `feature_key`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `character_id` | `bigint` | não | — | — |
| `feature_key` | `text` | não | — | — |
| `uses_spent` | `integer` | não | default: 0; check: uses_spent >= 0 | — |
| `resource_spent` | `integer` | não | default: 0; check: resource_spent >= 0 | — |
| `last_reset_at` | `timestamp with time zone` | não | default: now() | — |
| `payload` | `jsonb` | não | default: '{}'::jsonb | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_character_feature_resources_character_id_fkey`: `public.srd_character_feature_resources(character_id)` → `public.characters(id)`

#### `public.srd_character_weapon_instances`

- RLS: habilitado
- PK: `instance_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `instance_id` | `uuid` | não | default: gen_random_uuid() | — |
| `character_id` | `text` | não | — | — |
| `equipment_id` | `text` | não | — | — |
| `equipado` | `boolean` | não | default: false | — |
| `hand_slot` | `text` | sim | check: hand_slot IS NULL OR (hand_slot = ANY (ARRAY['main_hand'::text, 'off_hand'::text])) | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_character_weapon_instances_equipment_id_fkey`: `public.srd_character_weapon_instances(equipment_id)` → `public.srd_equipment(id)`

#### `public.srd_cba_token_weapon_instances`

- RLS: habilitado
- PK: `instance_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `instance_id` | `uuid` | não | default: gen_random_uuid() | — |
| `campaign_id` | `bigint` | não | — | — |
| `token_id` | `text` | não | — | — |
| `equipment_id` | `text` | não | — | — |
| `equipado` | `boolean` | não | default: false | — |
| `hand_slot` | `text` | sim | check: hand_slot IS NULL OR (hand_slot = ANY (ARRAY['main_hand'::text, 'off_hand'::text])) | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_cba_token_weapon_instances_equipment_id_fkey`: `public.srd_cba_token_weapon_instances(equipment_id)` → `public.srd_equipment(id)`
- `srd_cba_token_weapon_instances_campaign_id_fkey`: `public.srd_cba_token_weapon_instances(campaign_id)` → `public.campaigns(id)`

#### `public.srd_attack_sequences`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `uuid` | não | default: gen_random_uuid() | — |
| `campaign_id` | `bigint` | não | — | — |
| `actor_character_id` | `bigint` | não | — | — |
| `target_token_id` | `text` | não | — | — |
| `attack_type` | `text` | não | check: attack_type = ANY (ARRAY['atk-corpo'::text, 'atk-dist'::text]) | — |
| `weapon_instance_id` | `uuid` | sim | — | — |
| `round_number` | `integer` | não | check: round_number > 0 | — |
| `turn_index` | `integer` | não | check: turn_index >= 0 | — |
| `base_attack_bonus` | `integer` | não | check: base_attack_bonus >= 1 | — |
| `attacks_total` | `smallint` | não | check: attacks_total >= 2 AND attacks_total <= 6 | — |
| `next_attack_index` | `smallint` | não | default: 1; check: next_attack_index >= 1 AND next_attack_index <= 7 | — |
| `status` | `text` | não | default: 'active'::text; check: status = ANY (ARRAY['active'::text, 'completed'::text, 'abandoned'::text, 'invalidated'::text]) | — |
| `created_by` | `uuid` | não | — | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |
| `completed_at` | `timestamp with time zone` | sim | — | — |
| `weapon_hand_slot` | `text` | sim | check: weapon_hand_slot IS NULL OR (weapon_hand_slot = ANY (ARRAY['main_hand'::text, 'off_hand'::text])) | — |
| `weapon_end` | `text` | sim | check: weapon_end IS NULL OR (weapon_end = ANY (ARRAY['main'::text, 'off'::text])) | — |
| `power_attack_penalty` | `smallint` | não | default: 0; check: power_attack_penalty >= 0 AND power_attack_penalty <= 30 | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_attack_sequences_campaign_id_fkey`: `public.srd_attack_sequences(campaign_id)` → `public.campaigns(id)`
- `srd_attack_sequence_attempts_sequence_id_fkey`: `public.srd_attack_sequence_attempts(sequence_id)` → `public.srd_attack_sequences(id)`
- `srd_attack_sequences_actor_character_id_fkey`: `public.srd_attack_sequences(actor_character_id)` → `public.characters(id)`

#### `public.srd_attack_sequence_attempts`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `uuid` | não | default: gen_random_uuid() | — |
| `sequence_id` | `uuid` | não | — | — |
| `attempt_index` | `smallint` | não | check: attempt_index >= 1 AND attempt_index <= 6 | — |
| `manual_d20` | `smallint` | não | check: manual_d20 >= 1 AND manual_d20 <= 20 | — |
| `iterative_penalty` | `smallint` | não | check: iterative_penalty >= 0 AND iterative_penalty <= 25 | — |
| `idempotency_key` | `uuid` | não | — | — |
| `status` | `text` | não | default: 'pending_resolution'::text; check: status = ANY (ARRAY['pending_resolution'::text, 'miss'::text, 'critical_confirmation_pending'::text, 'hit_pending_damage'::text, 'damage_applied'::text, 'cancelled'::text]) | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |
| `resolved_at` | `timestamp with time zone` | sim | — | — |
| `resolution_data` | `jsonb` | não | default: '{}'::jsonb; check: jsonb_typeof(resolution_data) = 'object'::text | — |
| `attack_total` | `integer` | sim | check: attack_total IS NULL OR attack_total >= 0 AND attack_total <= 200 | — |
| `target_ac` | `integer` | sim | check: target_ac IS NULL OR target_ac >= 0 AND target_ac <= 200 | — |
| `critical_confirmation_d20` | `smallint` | sim | check: critical_confirmation_d20 IS NULL OR critical_confirmation_d20 >= 1 AND critical_confirmation_d20 <= 20 | — |
| `is_critical` | `boolean` | não | default: false | — |
| `damage_rolls` | `ARRAY` | sim | check: damage_rolls IS NULL OR cardinality(damage_rolls) >= 1 AND cardinality(damage_rolls) <= 30 AND array_position(damage_rolls, NULL::integer) IS NULL AND (0 < ALL (damage_rolls)) | — |
| `damage_applied` | `integer` | sim | check: damage_applied IS NULL OR damage_applied >= 0 AND damage_applied <= 10000 | — |
| `damage_type` | `text` | sim | — | — |
| `damage_applied_at` | `timestamp with time zone` | sim | — | — |
| `damage_idempotency_key` | `uuid` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_attack_sequence_attempts_sequence_id_fkey`: `public.srd_attack_sequence_attempts(sequence_id)` → `public.srd_attack_sequences(id)`

#### `public.srd_npc_attack_sequences`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `uuid` | não | default: gen_random_uuid() | — |
| `campaign_id` | `bigint` | não | — | — |
| `actor_token_id` | `text` | não | — | — |
| `actor_character_id` | `bigint` | não | — | — |
| `target_token_id` | `text` | não | — | — |
| `attack_type` | `text` | não | check: attack_type = ANY (ARRAY['atk-corpo'::text, 'atk-dist'::text]) | — |
| `weapon_instance_id` | `uuid` | não | — | — |
| `weapon_hand_slot` | `text` | não | check: weapon_hand_slot = ANY (ARRAY['main_hand'::text, 'off_hand'::text]) | — |
| `weapon_end` | `text` | sim | — | — |
| `base_attack_bonus` | `integer` | não | check: base_attack_bonus >= 6 | — |
| `attacks_total` | `smallint` | não | check: attacks_total >= 2 AND attacks_total <= 6 | — |
| `next_attack_index` | `smallint` | não | default: 1 | — |
| `round_number` | `integer` | não | — | — |
| `turn_index` | `integer` | não | — | — |
| `status` | `text` | não | default: 'active'::text; check: status = ANY (ARRAY['active'::text, 'completed'::text, 'cancelled'::text]) | — |
| `created_by` | `uuid` | não | — | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |
| `completed_at` | `timestamp with time zone` | sim | — | — |
| `power_attack_penalty` | `integer` | não | default: 0 | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_npc_attack_sequences_campaign_id_fkey`: `public.srd_npc_attack_sequences(campaign_id)` → `public.campaigns(id)`
- `srd_npc_attack_sequences_actor_character_id_fkey`: `public.srd_npc_attack_sequences(actor_character_id)` → `public.characters(id)`
- `srd_npc_attack_attempts_sequence_id_fkey`: `public.srd_npc_attack_attempts(sequence_id)` → `public.srd_npc_attack_sequences(id)`

#### `public.srd_npc_attack_attempts`

- RLS: habilitado
- PK: `id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `id` | `uuid` | não | default: gen_random_uuid() | — |
| `sequence_id` | `uuid` | não | — | — |
| `attempt_index` | `smallint` | não | — | — |
| `manual_d20` | `smallint` | não | check: manual_d20 >= 1 AND manual_d20 <= 20 | — |
| `iterative_penalty` | `smallint` | não | — | — |
| `idempotency_key` | `uuid` | não | — | — |
| `status` | `text` | não | default: 'pending_resolution'::text; check: status = ANY (ARRAY['pending_resolution'::text, 'critical_confirmation_pending'::text, 'hit_pending_damage'::text, 'miss'::text, 'damage_applied'::text]) | — |
| `attack_total` | `integer` | sim | — | — |
| `target_ac` | `integer` | sim | — | — |
| `resolution_data` | `jsonb` | não | default: '{}'::jsonb | — |
| `critical_confirmation_d20` | `smallint` | sim | check: critical_confirmation_d20 >= 1 AND critical_confirmation_d20 <= 20 | — |
| `is_critical` | `boolean` | não | default: false | — |
| `damage_rolls` | `ARRAY` | sim | — | — |
| `damage_applied` | `integer` | sim | — | — |
| `damage_idempotency_key` | `uuid` | sim | — | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |
| `resolved_at` | `timestamp with time zone` | sim | — | — |
| `damage_type` | `text` | sim | — | — |
| `damage_applied_at` | `timestamp with time zone` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_npc_attack_attempts_sequence_id_fkey`: `public.srd_npc_attack_attempts(sequence_id)` → `public.srd_npc_attack_sequences(id)`

### Schema `priv`

#### `priv.throttle`

- RLS: **desabilitado**
- PK: `key`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `key` | `text` | não | — | — |
| `fails` | `integer` | não | default: 0 | — |
| `until_ts` | `timestamp with time zone` | sim | — | — |

#### `priv.campaign_deletion_cleanup`

- RLS: habilitado
- PK: `campaign_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `campaign_id` | `bigint` | não | — | — |
| `owner_id` | `uuid` | não | — | — |
| `requested_at` | `timestamp with time zone` | não | default: now() | — |

#### `priv.srd_condition_engine_rules`

- RLS: habilitado
- PK: `condition_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `condition_id` | `text` | não | — | — |
| `modifiers` | `jsonb` | não | default: '[]'::jsonb; check: jsonb_typeof(modifiers) = 'array'::text | — |
| `flags` | `jsonb` | não | default: '{}'::jsonb; check: jsonb_typeof(flags) = 'object'::text | — |
| `speed_multiplier` | `numeric` | sim | check: speed_multiplier IS NULL OR speed_multiplier >= 0.05 AND speed_multiplier <= 1::numeric | — |
| `stack_group` | `text` | sim | — | — |
| `stack_rank` | `smallint` | não | default: 0 | — |
| `enabled` | `boolean` | não | default: true | — |
| `updated_at` | `timestamp with time zone` | não | default: now() | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_condition_engine_rules_condition_id_fkey`: `priv.srd_condition_engine_rules(condition_id)` → `public.srd_conditions(condition_id)`

#### `priv.srd_pending_spell_resolutions`

- RLS: habilitado
- PK: `pending_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `pending_id` | `uuid` | não | default: gen_random_uuid() | — |
| `campaign_id` | `bigint` | não | — | — |
| `caster_character_id` | `text` | não | — | — |
| `target_kind` | `text` | não | check: target_kind = ANY (ARRAY['character'::text, 'token'::text]) | — |
| `target_id` | `text` | não | — | — |
| `target_user_id` | `uuid` | sim | — | — |
| `spell_id` | `text` | não | — | — |
| `save_type` | `text` | sim | check: save_type = ANY (ARRAY['fortitude'::text, 'reflex'::text, 'will'::text]) | — |
| `save_dc` | `integer` | sim | check: save_dc >= 1 AND save_dc <= 60 | — |
| `condition_id` | `text` | sim | — | — |
| `duration_rounds` | `integer` | sim | — | — |
| `effect_data` | `jsonb` | não | default: '{}'::jsonb | — |
| `spell_resistance` | `boolean` | não | default: false | — |
| `caster_level` | `integer` | não | check: caster_level >= 1 AND caster_level <= 40 | — |
| `status` | `text` | não | default: 'pending_save'::text; check: status = ANY (ARRAY['pending_save'::text, 'awaiting_spell_resistance'::text, 'resolved'::text, 'saved'::text, 'resisted'::text, 'expired'::text]) | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |
| `expires_at` | `timestamp with time zone` | não | default: (now() + '00:20:00'::interval) | — |
| `resolved_at` | `timestamp with time zone` | sim | — | — |
| `condition_break` | `boolean` | não | default: false | — |
| `condition_break_instance_id` | `bigint` | sim | — | — |
| `effect_kind` | `text` | não | default: 'buff'::text | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_pending_spell_resolutions_spell_id_fkey`: `priv.srd_pending_spell_resolutions(spell_id)` → `public.srd_spells(id)`
- `srd_pending_spell_resolutions_condition_id_fkey`: `priv.srd_pending_spell_resolutions(condition_id)` → `public.srd_conditions(condition_id)`
- `srd_pending_spell_resolutions_condition_break_instance_id_fkey`: `priv.srd_pending_spell_resolutions(condition_break_instance_id)` → `public.srd_campaign_conditions(condition_instance_id)`
- `srd_pending_spell_resolutions_campaign_id_fkey`: `priv.srd_pending_spell_resolutions(campaign_id)` → `public.campaigns(id)`

#### `priv.srd_aoo_reaction_ledger`

- RLS: **desabilitado**
- PK: `reaction_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `reaction_id` | `uuid` | não | default: gen_random_uuid() | — |
| `campaign_id` | `bigint` | não | — | — |
| `combat_round` | `integer` | não | check: combat_round >= 1 | — |
| `actor_token_id` | `text` | não | — | — |
| `trigger_key` | `text` | não | — | — |
| `reaction_number` | `integer` | não | check: reaction_number >= 1 | — |
| `max_reactions` | `integer` | não | check: max_reactions >= 1 | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |
| `combat_phase` | `text` | não | default: 'normal'::text; check: combat_phase = ANY (ARRAY['surprise_round'::text, 'normal'::text]) | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_aoo_attacks_reaction_id_fkey`: `priv.srd_aoo_attacks(reaction_id)` → `priv.srd_aoo_reaction_ledger(reaction_id)`
- `srd_aoo_reaction_ledger_campaign_id_fkey`: `priv.srd_aoo_reaction_ledger(campaign_id)` → `public.campaigns(id)`

#### `priv.srd_aoo_pending_movements`

- RLS: habilitado
- PK: `pending_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `pending_id` | `uuid` | não | default: gen_random_uuid() | — |
| `campaign_id` | `bigint` | não | — | — |
| `mover_token_id` | `text` | não | — | — |
| `movement_controller` | `text` | não | check: movement_controller = ANY (ARRAY['player'::text, 'gm'::text]) | — |
| `destination_x` | `integer` | não | check: destination_x >= 0 AND destination_x <= 199 | — |
| `destination_y` | `integer` | não | check: destination_y >= 0 AND destination_y <= 199 | — |
| `origin_x` | `integer` | não | check: origin_x >= 0 AND origin_x <= 199 | — |
| `origin_y` | `integer` | não | check: origin_y >= 0 AND origin_y <= 199 | — |
| `combat_round` | `integer` | não | check: combat_round >= 1 | — |
| `current_turn` | `integer` | não | check: current_turn >= 0 | — |
| `turn_actor_id` | `text` | não | — | — |
| `threats` | `jsonb` | não | default: '[]'::jsonb; check: jsonb_typeof(threats) = 'array'::text | — |
| `pending_reactions` | `jsonb` | não | default: '[]'::jsonb; check: jsonb_typeof(pending_reactions) = 'array'::text | — |
| `status` | `text` | não | default: 'waiting_reactions'::text; check: status = ANY (ARRAY['waiting_reactions'::text, 'ready_to_commit'::text, 'committed'::text, 'cancelled'::text, 'expired'::text]) | — |
| `created_by` | `uuid` | não | — | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |
| `updated_at` | `timestamp with time zone` | não | default: now() | — |
| `committed_at` | `timestamp with time zone` | sim | — | — |
| `cancelled_at` | `timestamp with time zone` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_aoo_attacks_pending_id_fkey`: `priv.srd_aoo_attacks(pending_id)` → `priv.srd_aoo_pending_movements(pending_id)`
- `srd_aoo_pending_movements_campaign_id_fkey`: `priv.srd_aoo_pending_movements(campaign_id)` → `public.campaigns(id)`

#### `priv.srd_aoo_attacks`

- RLS: habilitado
- PK: `attack_id`

| Coluna | Tipo | Nulável | Default / regra | Comentário |
|---|---|---:|---|---|
| `attack_id` | `uuid` | não | default: gen_random_uuid() | — |
| `campaign_id` | `bigint` | não | — | — |
| `pending_id` | `uuid` | não | — | — |
| `reaction_id` | `uuid` | não | — | — |
| `actor_token_id` | `text` | não | — | — |
| `target_token_id` | `text` | não | — | — |
| `actor_character_id` | `bigint` | sim | — | — |
| `weapon_instance_id` | `uuid` | sim | — | — |
| `weapon_hand_slot` | `text` | sim | check: (weapon_hand_slot = ANY (ARRAY['main_hand'::text, 'off_hand'::text, 'natural'::text])) OR weapon_hand_slot IS NULL | — |
| `weapon_end` | `text` | sim | check: weapon_end = ANY (ARRAY['main'::text, 'off'::text]) | — |
| `status` | `text` | não | default: 'awaiting_attack_roll'::text; check: status = ANY (ARRAY['awaiting_attack_roll'::text, 'awaiting_critical_confirmation'::text, 'awaiting_miss_chance'::text, 'awaiting_damage'::text, 'miss'::text, 'damage_applied'::text, 'cancelled'::text]) | — |
| `manual_d20` | `integer` | sim | check: manual_d20 >= 1 AND manual_d20 <= 20 | — |
| `critical_confirmation_d20` | `integer` | sim | check: critical_confirmation_d20 >= 1 AND critical_confirmation_d20 <= 20 | — |
| `attack_total` | `integer` | sim | — | — |
| `target_ac` | `integer` | sim | — | — |
| `is_critical` | `boolean` | não | default: false | — |
| `damage_rolls` | `ARRAY` | sim | — | — |
| `damage_applied` | `integer` | sim | — | — |
| `damage_idempotency_key` | `uuid` | sim | — | — |
| `resolution_data` | `jsonb` | não | default: '{}'::jsonb | — |
| `created_by` | `uuid` | não | — | — |
| `created_at` | `timestamp with time zone` | não | default: now() | — |
| `resolved_at` | `timestamp with time zone` | sim | — | — |
| `damage_applied_at` | `timestamp with time zone` | sim | — | — |
| `attack_roll_idempotency_key` | `uuid` | sim | — | — |

**Foreign keys (relações retornadas pelo conector):**
- `srd_aoo_attacks_campaign_id_fkey`: `priv.srd_aoo_attacks(campaign_id)` → `public.campaigns(id)`
- `srd_aoo_attacks_pending_id_fkey`: `priv.srd_aoo_attacks(pending_id)` → `priv.srd_aoo_pending_movements(pending_id)`
- `srd_aoo_attacks_reaction_id_fkey`: `priv.srd_aoo_attacks(reaction_id)` → `priv.srd_aoo_reaction_ledger(reaction_id)`

## Índices

- `priv.campaign_deletion_cleanup.campaign_deletion_cleanup_pkey`: `CREATE UNIQUE INDEX campaign_deletion_cleanup_pkey ON priv.campaign_deletion_cleanup USING btree (campaign_id)`
- `priv.srd_aoo_attacks.srd_aoo_attack_roll_idempotency_unique`: `CREATE UNIQUE INDEX srd_aoo_attack_roll_idempotency_unique ON priv.srd_aoo_attacks USING btree (attack_roll_idempotency_key) WHERE (attack_roll_idempotency_key IS NOT NULL)`
- `priv.srd_aoo_attacks.srd_aoo_attacks_campaign_id_idx`: `CREATE INDEX srd_aoo_attacks_campaign_id_idx ON priv.srd_aoo_attacks USING btree (campaign_id)`
- `priv.srd_aoo_attacks.srd_aoo_attacks_damage_idempotency_key_key`: `CREATE UNIQUE INDEX srd_aoo_attacks_damage_idempotency_key_key ON priv.srd_aoo_attacks USING btree (damage_idempotency_key)`
- `priv.srd_aoo_attacks.srd_aoo_attacks_pending_status`: `CREATE INDEX srd_aoo_attacks_pending_status ON priv.srd_aoo_attacks USING btree (pending_id, status)`
- `priv.srd_aoo_attacks.srd_aoo_attacks_pkey`: `CREATE UNIQUE INDEX srd_aoo_attacks_pkey ON priv.srd_aoo_attacks USING btree (attack_id)`
- `priv.srd_aoo_attacks.srd_aoo_attacks_reaction_id_key`: `CREATE UNIQUE INDEX srd_aoo_attacks_reaction_id_key ON priv.srd_aoo_attacks USING btree (reaction_id)`
- `priv.srd_aoo_pending_movements.srd_aoo_one_pending_movement_per_campaign`: `CREATE UNIQUE INDEX srd_aoo_one_pending_movement_per_campaign ON priv.srd_aoo_pending_movements USING btree (campaign_id) WHERE (status = ANY (ARRAY['waiting_reactions'::text, 'ready_to_commit'::text]))`
- `priv.srd_aoo_pending_movements.srd_aoo_pending_movements_campaign_status`: `CREATE INDEX srd_aoo_pending_movements_campaign_status ON priv.srd_aoo_pending_movements USING btree (campaign_id, status, created_at DESC)`
- `priv.srd_aoo_pending_movements.srd_aoo_pending_movements_pkey`: `CREATE UNIQUE INDEX srd_aoo_pending_movements_pkey ON priv.srd_aoo_pending_movements USING btree (pending_id)`
- `priv.srd_aoo_reaction_ledger.srd_aoo_reaction_ledger_phase_ordinal_uq`: `CREATE UNIQUE INDEX srd_aoo_reaction_ledger_phase_ordinal_uq ON priv.srd_aoo_reaction_ledger USING btree (campaign_id, combat_phase, combat_round, actor_token_id, reaction_number)`
- `priv.srd_aoo_reaction_ledger.srd_aoo_reaction_ledger_phase_trigger_uq`: `CREATE UNIQUE INDEX srd_aoo_reaction_ledger_phase_trigger_uq ON priv.srd_aoo_reaction_ledger USING btree (campaign_id, combat_phase, combat_round, actor_token_id, trigger_key)`
- `priv.srd_aoo_reaction_ledger.srd_aoo_reaction_ledger_pkey`: `CREATE UNIQUE INDEX srd_aoo_reaction_ledger_pkey ON priv.srd_aoo_reaction_ledger USING btree (reaction_id)`
- `priv.srd_condition_engine_rules.srd_condition_engine_rules_pkey`: `CREATE UNIQUE INDEX srd_condition_engine_rules_pkey ON priv.srd_condition_engine_rules USING btree (condition_id)`
- `priv.srd_pending_spell_resolutions.srd_pending_spell_resolution_campaign_idx`: `CREATE INDEX srd_pending_spell_resolution_campaign_idx ON priv.srd_pending_spell_resolutions USING btree (campaign_id, status, expires_at)`
- `priv.srd_pending_spell_resolutions.srd_pending_spell_resolution_condition_break_idx`: `CREATE INDEX srd_pending_spell_resolution_condition_break_idx ON priv.srd_pending_spell_resolutions USING btree (condition_break_instance_id) WHERE (condition_break_instance_id IS NOT NULL)`
- `priv.srd_pending_spell_resolutions.srd_pending_spell_resolution_condition_idx`: `CREATE INDEX srd_pending_spell_resolution_condition_idx ON priv.srd_pending_spell_resolutions USING btree (condition_id) WHERE (condition_id IS NOT NULL)`
- `priv.srd_pending_spell_resolutions.srd_pending_spell_resolution_spell_idx`: `CREATE INDEX srd_pending_spell_resolution_spell_idx ON priv.srd_pending_spell_resolutions USING btree (spell_id)`
- `priv.srd_pending_spell_resolutions.srd_pending_spell_resolutions_pkey`: `CREATE UNIQUE INDEX srd_pending_spell_resolutions_pkey ON priv.srd_pending_spell_resolutions USING btree (pending_id)`
- `priv.throttle.throttle_pkey`: `CREATE UNIQUE INDEX throttle_pkey ON priv.throttle USING btree (key)`
- `public.campaign_codes.campaign_codes_code_key`: `CREATE UNIQUE INDEX campaign_codes_code_key ON public.campaign_codes USING btree (code)`
- `public.campaign_codes.campaign_codes_pkey`: `CREATE UNIQUE INDEX campaign_codes_pkey ON public.campaign_codes USING btree (campaign_id)`
- `public.campaign_log.campaign_log_pkey`: `CREATE UNIQUE INDEX campaign_log_pkey ON public.campaign_log USING btree (id)`
- `public.campaign_log.idx_fk_campaign_log_campaign_id`: `CREATE INDEX idx_fk_campaign_log_campaign_id ON public.campaign_log USING btree (campaign_id)`
- `public.campaign_rule_modules.campaign_rule_modules_pkey`: `CREATE UNIQUE INDEX campaign_rule_modules_pkey ON public.campaign_rule_modules USING btree (campaign_id, module_id)`
- `public.campaign_rule_modules.idx_fk_campaign_rule_modules_campaign_id`: `CREATE INDEX idx_fk_campaign_rule_modules_campaign_id ON public.campaign_rule_modules USING btree (campaign_id)`
- `public.campaign_rule_modules.idx_fk_campaign_rule_modules_module_id`: `CREATE INDEX idx_fk_campaign_rule_modules_module_id ON public.campaign_rule_modules USING btree (module_id)`
- `public.campaigns.campaigns_pkey`: `CREATE UNIQUE INDEX campaigns_pkey ON public.campaigns USING btree (id)`
- `public.campaigns.idx_fk_campaigns_location_id`: `CREATE INDEX idx_fk_campaigns_location_id ON public.campaigns USING btree (location_id)`
- `public.character_abilities.character_abilities_pkey`: `CREATE UNIQUE INDEX character_abilities_pkey ON public.character_abilities USING btree (character_id, ability_id)`
- `public.character_abilities.idx_fk_character_abilities_character_id`: `CREATE INDEX idx_fk_character_abilities_character_id ON public.character_abilities USING btree (character_id)`
- `public.character_conditions.character_conditions_character_id_condition_id_key`: `CREATE UNIQUE INDEX character_conditions_character_id_condition_id_key ON public.character_conditions USING btree (character_id, condition_id)`
- `public.character_conditions.character_conditions_pkey`: `CREATE UNIQUE INDEX character_conditions_pkey ON public.character_conditions USING btree (id)`
- `public.character_conditions.idx_fk_character_conditions_character_id`: `CREATE INDEX idx_fk_character_conditions_character_id ON public.character_conditions USING btree (character_id)`
- `public.character_conditions.idx_fk_character_conditions_condition_id`: `CREATE INDEX idx_fk_character_conditions_condition_id ON public.character_conditions USING btree (condition_id)`
- `public.character_spells.character_spells_pkey`: `CREATE UNIQUE INDEX character_spells_pkey ON public.character_spells USING btree (character_id, spell_id)`
- `public.character_spells.idx_fk_character_spells_character_id`: `CREATE INDEX idx_fk_character_spells_character_id ON public.character_spells USING btree (character_id)`
- `public.character_talents.character_talents_pkey`: `CREATE UNIQUE INDEX character_talents_pkey ON public.character_talents USING btree (character_id, talent_id)`
- `public.character_talents.idx_fk_character_talents_character_id`: `CREATE INDEX idx_fk_character_talents_character_id ON public.character_talents USING btree (character_id)`
- `public.characters.characters_campaign_id_user_id_key`: `CREATE UNIQUE INDEX characters_campaign_id_user_id_key ON public.characters USING btree (campaign_id, user_id)`
- `public.characters.characters_pkey`: `CREATE UNIQUE INDEX characters_pkey ON public.characters USING btree (id)`
- `public.characters.idx_fk_characters_campaign_id`: `CREATE INDEX idx_fk_characters_campaign_id ON public.characters USING btree (campaign_id)`
- `public.combat_state.combat_state_pkey`: `CREATE UNIQUE INDEX combat_state_pkey ON public.combat_state USING btree (campaign_id)`
- `public.conditions.conditions_nome_key`: `CREATE UNIQUE INDEX conditions_nome_key ON public.conditions USING btree (nome)`
- `public.conditions.conditions_pkey`: `CREATE UNIQUE INDEX conditions_pkey ON public.conditions USING btree (id)`
- `public.continents.continents_pkey`: `CREATE UNIQUE INDEX continents_pkey ON public.continents USING btree (id)`
- `public.layers.idx_fk_layers_campaign_id`: `CREATE INDEX idx_fk_layers_campaign_id ON public.layers USING btree (campaign_id)`
- `public.layers.idx_fk_layers_media_id`: `CREATE INDEX idx_fk_layers_media_id ON public.layers USING btree (media_id)`
- `public.layers.layers_pkey`: `CREATE UNIQUE INDEX layers_pkey ON public.layers USING btree (id)`
- `public.locations.idx_fk_locations_continent_id`: `CREATE INDEX idx_fk_locations_continent_id ON public.locations USING btree (continent_id)`
- `public.locations.locations_nome_key`: `CREATE UNIQUE INDEX locations_nome_key ON public.locations USING btree (nome)`
- `public.locations.locations_pkey`: `CREATE UNIQUE INDEX locations_pkey ON public.locations USING btree (id)`
- `public.media.idx_fk_media_campaign_id`: `CREATE INDEX idx_fk_media_campaign_id ON public.media USING btree (campaign_id)`
- `public.media.media_path_key`: `CREATE UNIQUE INDEX media_path_key ON public.media USING btree (path)`
- `public.media.media_pkey`: `CREATE UNIQUE INDEX media_pkey ON public.media USING btree (id)`
- `public.members.idx_fk_members_campaign_id`: `CREATE INDEX idx_fk_members_campaign_id ON public.members USING btree (campaign_id)`
- `public.members.members_one_gm_per_campaign`: `CREATE UNIQUE INDEX members_one_gm_per_campaign ON public.members USING btree (campaign_id) WHERE (role = 'GM'::text)`
- `public.members.members_pkey`: `CREATE UNIQUE INDEX members_pkey ON public.members USING btree (campaign_id, user_id)`
- `public.monster_instances.idx_fk_monster_instances_campaign_id`: `CREATE INDEX idx_fk_monster_instances_campaign_id ON public.monster_instances USING btree (campaign_id)`
- `public.monster_instances.idx_fk_monster_instances_monster_id`: `CREATE INDEX idx_fk_monster_instances_monster_id ON public.monster_instances USING btree (monster_id)`
- `public.monster_instances.monster_instances_pkey`: `CREATE UNIQUE INDEX monster_instances_pkey ON public.monster_instances USING btree (id)`
- `public.monsters.idx_fk_monsters_continente`: `CREATE INDEX idx_fk_monsters_continente ON public.monsters USING btree (continente)`
- `public.monsters.monsters_continente_nivel_idx`: `CREATE INDEX monsters_continente_nivel_idx ON public.monsters USING btree (continente, nivel)`
- `public.monsters.monsters_dificuldade_idx`: `CREATE INDEX monsters_dificuldade_idx ON public.monsters USING btree (dificuldade)`
- `public.monsters.monsters_pkey`: `CREATE UNIQUE INDEX monsters_pkey ON public.monsters USING btree (id)`
- `public.profiles.profiles_pkey`: `CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id)`
- `public.profiles.profiles_username_key`: `CREATE UNIQUE INDEX profiles_username_key ON public.profiles USING btree (username)`
- `public.roll_log.idx_fk_roll_log_campaign_id`: `CREATE INDEX idx_fk_roll_log_campaign_id ON public.roll_log USING btree (campaign_id)`
- `public.roll_log.roll_log_campanha_idx`: `CREATE INDEX roll_log_campanha_idx ON public.roll_log USING btree (campaign_id, ts DESC)`
- `public.roll_log.roll_log_pkey`: `CREATE UNIQUE INDEX roll_log_pkey ON public.roll_log USING btree (id)`
- `public.roll_requests.idx_fk_roll_requests_campaign_id`: `CREATE INDEX idx_fk_roll_requests_campaign_id ON public.roll_requests USING btree (campaign_id)`
- `public.roll_requests.roll_requests_from_idx`: `CREATE INDEX roll_requests_from_idx ON public.roll_requests USING btree (campaign_id, from_id, status)`
- `public.roll_requests.roll_requests_pkey`: `CREATE UNIQUE INDEX roll_requests_pkey ON public.roll_requests USING btree (id)`
- `public.roll_requests.roll_requests_to_idx`: `CREATE INDEX roll_requests_to_idx ON public.roll_requests USING btree (campaign_id, to_id, status)`
- `public.scenes.scenes_pkey`: `CREATE UNIQUE INDEX scenes_pkey ON public.scenes USING btree (campaign_id)`
- `public.skills.skills_nome_key`: `CREATE UNIQUE INDEX skills_nome_key ON public.skills USING btree (nome)`
- `public.skills.skills_pkey`: `CREATE UNIQUE INDEX skills_pkey ON public.skills USING btree (id)`
- `public.srd_attack_sequence_attempts.srd_attack_sequence_attempts_damage_idempotency_uidx`: `CREATE UNIQUE INDEX srd_attack_sequence_attempts_damage_idempotency_uidx ON public.srd_attack_sequence_attempts USING btree (damage_idempotency_key) WHERE (damage_idempotency_key IS NOT NULL)`
- `public.srd_attack_sequence_attempts.srd_attack_sequence_attempts_pkey`: `CREATE UNIQUE INDEX srd_attack_sequence_attempts_pkey ON public.srd_attack_sequence_attempts USING btree (id)`
- `public.srd_attack_sequence_attempts.srd_attack_sequence_attempts_unique_idempotency`: `CREATE UNIQUE INDEX srd_attack_sequence_attempts_unique_idempotency ON public.srd_attack_sequence_attempts USING btree (idempotency_key)`
- `public.srd_attack_sequence_attempts.srd_attack_sequence_attempts_unique_index`: `CREATE UNIQUE INDEX srd_attack_sequence_attempts_unique_index ON public.srd_attack_sequence_attempts USING btree (sequence_id, attempt_index)`
- `public.srd_attack_sequences.srd_attack_sequences_actor_character_idx`: `CREATE INDEX srd_attack_sequences_actor_character_idx ON public.srd_attack_sequences USING btree (actor_character_id)`
- `public.srd_attack_sequences.srd_attack_sequences_campaign_actor`: `CREATE INDEX srd_attack_sequences_campaign_actor ON public.srd_attack_sequences USING btree (campaign_id, actor_character_id, created_at DESC)`
- `public.srd_attack_sequences.srd_attack_sequences_one_active_turn`: `CREATE UNIQUE INDEX srd_attack_sequences_one_active_turn ON public.srd_attack_sequences USING btree (campaign_id, actor_character_id, round_number, turn_index) WHERE (status = 'active'::text)`
- `public.srd_attack_sequences.srd_attack_sequences_pkey`: `CREATE UNIQUE INDEX srd_attack_sequences_pkey ON public.srd_attack_sequences USING btree (id)`
- `public.srd_campaign_conditions.idx_fk_srd_campaign_conditions_campaign_id`: `CREATE INDEX idx_fk_srd_campaign_conditions_campaign_id ON public.srd_campaign_conditions USING btree (campaign_id)`
- `public.srd_campaign_conditions.idx_fk_srd_campaign_conditions_condition_id`: `CREATE INDEX idx_fk_srd_campaign_conditions_condition_id ON public.srd_campaign_conditions USING btree (condition_id)`
- `public.srd_campaign_conditions.idx_fk_srd_campaign_conditions_source_spell_id`: `CREATE INDEX idx_fk_srd_campaign_conditions_source_spell_id ON public.srd_campaign_conditions USING btree (source_spell_id)`
- `public.srd_campaign_conditions.srd_campaign_conditions_active_target_idx`: `CREATE INDEX srd_campaign_conditions_active_target_idx ON public.srd_campaign_conditions USING btree (campaign_id, target_kind, target_id, expires_round) WHERE (active = true)`
- `public.srd_campaign_conditions.srd_campaign_conditions_pkey`: `CREATE UNIQUE INDEX srd_campaign_conditions_pkey ON public.srd_campaign_conditions USING btree (condition_instance_id)`
- `public.srd_campaign_conditions.srd_campaign_conditions_target_idx`: `CREATE INDEX srd_campaign_conditions_target_idx ON public.srd_campaign_conditions USING btree (campaign_id, target_kind, target_id, active)`
- `public.srd_campaign_effects.idx_fk_srd_campaign_effects_campaign_id`: `CREATE INDEX idx_fk_srd_campaign_effects_campaign_id ON public.srd_campaign_effects USING btree (campaign_id)`
- `public.srd_campaign_effects.idx_fk_srd_campaign_effects_source_spell_id`: `CREATE INDEX idx_fk_srd_campaign_effects_source_spell_id ON public.srd_campaign_effects USING btree (source_spell_id)`
- `public.srd_campaign_effects.srd_campaign_effects_active_target_idx`: `CREATE INDEX srd_campaign_effects_active_target_idx ON public.srd_campaign_effects USING btree (campaign_id, target_kind, target_id, expires_round) WHERE (active = true)`
- `public.srd_campaign_effects.srd_campaign_effects_pkey`: `CREATE UNIQUE INDEX srd_campaign_effects_pkey ON public.srd_campaign_effects USING btree (effect_instance_id)`
- `public.srd_campaign_effects.srd_campaign_effects_target_idx`: `CREATE INDEX srd_campaign_effects_target_idx ON public.srd_campaign_effects USING btree (campaign_id, target_kind, target_id, active)`
- `public.srd_catalog_coverage.idx_fk_srd_catalog_coverage_ruleset_id`: `CREATE INDEX idx_fk_srd_catalog_coverage_ruleset_id ON public.srd_catalog_coverage USING btree (ruleset_id)`
- `public.srd_catalog_coverage.srd_catalog_coverage_pkey`: `CREATE UNIQUE INDEX srd_catalog_coverage_pkey ON public.srd_catalog_coverage USING btree (catalog_key)`
- `public.srd_catalog_entry_audit.srd_catalog_entry_audit_pkey`: `CREATE UNIQUE INDEX srd_catalog_entry_audit_pkey ON public.srd_catalog_entry_audit USING btree (catalog_key, entry_id)`
- `public.srd_cba_token_equipment.idx_fk_srd_cba_token_equipment_campaign_id`: `CREATE INDEX idx_fk_srd_cba_token_equipment_campaign_id ON public.srd_cba_token_equipment USING btree (campaign_id)`
- `public.srd_cba_token_equipment.idx_fk_srd_cba_token_equipment_equipment_id`: `CREATE INDEX idx_fk_srd_cba_token_equipment_equipment_id ON public.srd_cba_token_equipment USING btree (equipment_id)`
- `public.srd_cba_token_equipment.srd_cba_token_equipment_one_weapon_per_hand`: `CREATE UNIQUE INDEX srd_cba_token_equipment_one_weapon_per_hand ON public.srd_cba_token_equipment USING btree (campaign_id, token_id, hand_slot) WHERE ((equipado = true) AND (hand_slot IS NOT NULL))`
- `public.srd_cba_token_equipment.srd_cba_token_equipment_pkey`: `CREATE UNIQUE INDEX srd_cba_token_equipment_pkey ON public.srd_cba_token_equipment USING btree (campaign_id, token_id, equipment_id)`
- `public.srd_cba_token_weapon_instances.srd_cba_token_weapon_instances_equipment_id_idx`: `CREATE INDEX srd_cba_token_weapon_instances_equipment_id_idx ON public.srd_cba_token_weapon_instances USING btree (equipment_id)`
- `public.srd_cba_token_weapon_instances.srd_cba_token_weapon_instances_one_per_hand`: `CREATE UNIQUE INDEX srd_cba_token_weapon_instances_one_per_hand ON public.srd_cba_token_weapon_instances USING btree (campaign_id, token_id, hand_slot) WHERE ((equipado = true) AND (hand_slot IS NOT NULL))`
- `public.srd_cba_token_weapon_instances.srd_cba_token_weapon_instances_owner_idx`: `CREATE INDEX srd_cba_token_weapon_instances_owner_idx ON public.srd_cba_token_weapon_instances USING btree (campaign_id, token_id, equipment_id)`
- `public.srd_cba_token_weapon_instances.srd_cba_token_weapon_instances_pkey`: `CREATE UNIQUE INDEX srd_cba_token_weapon_instances_pkey ON public.srd_cba_token_weapon_instances USING btree (instance_id)`
- `public.srd_character_class_levels.idx_fk_srd_character_class_levels_class_id`: `CREATE INDEX idx_fk_srd_character_class_levels_class_id ON public.srd_character_class_levels USING btree (class_id)`
- `public.srd_character_class_levels.srd_character_class_levels_pkey`: `CREATE UNIQUE INDEX srd_character_class_levels_pkey ON public.srd_character_class_levels USING btree (character_id, class_id)`
- `public.srd_character_domain_choices.idx_fk_srd_character_domain_choices_character_id`: `CREATE INDEX idx_fk_srd_character_domain_choices_character_id ON public.srd_character_domain_choices USING btree (character_id)`
- `public.srd_character_domain_choices.idx_fk_srd_character_domain_choices_domain_id`: `CREATE INDEX idx_fk_srd_character_domain_choices_domain_id ON public.srd_character_domain_choices USING btree (domain_id)`
- `public.srd_character_domain_choices.srd_character_domain_choices_character_id_domain_id_key`: `CREATE UNIQUE INDEX srd_character_domain_choices_character_id_domain_id_key ON public.srd_character_domain_choices USING btree (character_id, domain_id)`
- `public.srd_character_domain_choices.srd_character_domain_choices_pkey`: `CREATE UNIQUE INDEX srd_character_domain_choices_pkey ON public.srd_character_domain_choices USING btree (character_id, domain_slot)`
- `public.srd_character_equipment.idx_fk_srd_character_equipment_equipment_id`: `CREATE INDEX idx_fk_srd_character_equipment_equipment_id ON public.srd_character_equipment USING btree (equipment_id)`
- `public.srd_character_equipment.srd_character_equipment_one_weapon_per_hand`: `CREATE UNIQUE INDEX srd_character_equipment_one_weapon_per_hand ON public.srd_character_equipment USING btree (character_id, hand_slot) WHERE ((equipado = true) AND (hand_slot IS NOT NULL))`
- `public.srd_character_equipment.srd_character_equipment_pkey`: `CREATE UNIQUE INDEX srd_character_equipment_pkey ON public.srd_character_equipment USING btree (character_id, equipment_id)`
- `public.srd_character_feature_resources.srd_character_feature_resources_pkey`: `CREATE UNIQUE INDEX srd_character_feature_resources_pkey ON public.srd_character_feature_resources USING btree (character_id, feature_key)`
- `public.srd_character_known_spells.idx_fk_srd_character_known_spells_character_id`: `CREATE INDEX idx_fk_srd_character_known_spells_character_id ON public.srd_character_known_spells USING btree (character_id)`
- `public.srd_character_known_spells.idx_fk_srd_character_known_spells_class_id`: `CREATE INDEX idx_fk_srd_character_known_spells_class_id ON public.srd_character_known_spells USING btree (class_id)`
- `public.srd_character_known_spells.idx_fk_srd_character_known_spells_spell_id`: `CREATE INDEX idx_fk_srd_character_known_spells_spell_id ON public.srd_character_known_spells USING btree (spell_id)`
- `public.srd_character_known_spells.srd_character_known_spells_pkey`: `CREATE UNIQUE INDEX srd_character_known_spells_pkey ON public.srd_character_known_spells USING btree (character_id, class_id, spell_id)`
- `public.srd_character_known_spells.srd_character_spell_known_idx`: `CREATE INDEX srd_character_spell_known_idx ON public.srd_character_known_spells USING btree (character_id, class_id)`
- `public.srd_character_prepared_spells.idx_fk_srd_character_prepared_spells_character_id`: `CREATE INDEX idx_fk_srd_character_prepared_spells_character_id ON public.srd_character_prepared_spells USING btree (character_id)`
- `public.srd_character_prepared_spells.idx_fk_srd_character_prepared_spells_class_id`: `CREATE INDEX idx_fk_srd_character_prepared_spells_class_id ON public.srd_character_prepared_spells USING btree (class_id)`
- `public.srd_character_prepared_spells.idx_fk_srd_character_prepared_spells_spell_id`: `CREATE INDEX idx_fk_srd_character_prepared_spells_spell_id ON public.srd_character_prepared_spells USING btree (spell_id)`
- `public.srd_character_prepared_spells.srd_character_prepared_period_idx`: `CREATE INDEX srd_character_prepared_period_idx ON public.srd_character_prepared_spells USING btree (character_id, prepared_for, expended)`
- `public.srd_character_prepared_spells.srd_character_prepared_spells_character_id_class_id_prepare_key`: `CREATE UNIQUE INDEX srd_character_prepared_spells_character_id_class_id_prepare_key ON public.srd_character_prepared_spells USING btree (character_id, class_id, prepared_for, spell_level, slot_number, source_track)`
- `public.srd_character_prepared_spells.srd_character_prepared_spells_pkey`: `CREATE UNIQUE INDEX srd_character_prepared_spells_pkey ON public.srd_character_prepared_spells USING btree (preparation_id)`
- `public.srd_character_sheets.srd_character_sheets_pkey`: `CREATE UNIQUE INDEX srd_character_sheets_pkey ON public.srd_character_sheets USING btree (character_id)`
- `public.srd_character_spell_slot_state.idx_fk_srd_character_spell_slot_state_character_id`: `CREATE INDEX idx_fk_srd_character_spell_slot_state_character_id ON public.srd_character_spell_slot_state USING btree (character_id)`
- `public.srd_character_spell_slot_state.idx_fk_srd_character_spell_slot_state_class_id`: `CREATE INDEX idx_fk_srd_character_spell_slot_state_class_id ON public.srd_character_spell_slot_state USING btree (class_id)`
- `public.srd_character_spell_slot_state.srd_character_spell_slot_state_pkey`: `CREATE UNIQUE INDEX srd_character_spell_slot_state_pkey ON public.srd_character_spell_slot_state USING btree (character_id, class_id, spell_level, period_started_at)`
- `public.srd_character_spellbook.idx_fk_srd_character_spellbook_character_id`: `CREATE INDEX idx_fk_srd_character_spellbook_character_id ON public.srd_character_spellbook USING btree (character_id)`
- `public.srd_character_spellbook.idx_fk_srd_character_spellbook_class_id`: `CREATE INDEX idx_fk_srd_character_spellbook_class_id ON public.srd_character_spellbook USING btree (class_id)`
- `public.srd_character_spellbook.idx_fk_srd_character_spellbook_spell_id`: `CREATE INDEX idx_fk_srd_character_spellbook_spell_id ON public.srd_character_spellbook USING btree (spell_id)`
- `public.srd_character_spellbook.srd_character_spellbook_pkey`: `CREATE UNIQUE INDEX srd_character_spellbook_pkey ON public.srd_character_spellbook USING btree (character_id, class_id, spell_id)`
- `public.srd_character_weapon_instances.idx_srd_character_weapon_instances_equipment_id`: `CREATE INDEX idx_srd_character_weapon_instances_equipment_id ON public.srd_character_weapon_instances USING btree (equipment_id)`
- `public.srd_character_weapon_instances.srd_character_weapon_instances_one_per_hand`: `CREATE UNIQUE INDEX srd_character_weapon_instances_one_per_hand ON public.srd_character_weapon_instances USING btree (character_id, hand_slot) WHERE ((equipado = true) AND (hand_slot IS NOT NULL))`
- `public.srd_character_weapon_instances.srd_character_weapon_instances_owner_idx`: `CREATE INDEX srd_character_weapon_instances_owner_idx ON public.srd_character_weapon_instances USING btree (character_id, equipment_id)`
- `public.srd_character_weapon_instances.srd_character_weapon_instances_pkey`: `CREATE UNIQUE INDEX srd_character_weapon_instances_pkey ON public.srd_character_weapon_instances USING btree (instance_id)`
- `public.srd_class_level_features.idx_fk_srd_class_level_features_class_id__class_level`: `CREATE INDEX idx_fk_srd_class_level_features_class_id__class_level ON public.srd_class_level_features USING btree (class_id, class_level)`
- `public.srd_class_level_features.idx_fk_srd_class_level_features_source_id`: `CREATE INDEX idx_fk_srd_class_level_features_source_id ON public.srd_class_level_features USING btree (source_id)`
- `public.srd_class_level_features.srd_class_level_features_pkey`: `CREATE UNIQUE INDEX srd_class_level_features_pkey ON public.srd_class_level_features USING btree (class_id, class_level, feature_key)`
- `public.srd_class_level_progressions.idx_fk_srd_class_level_progressions_class_id`: `CREATE INDEX idx_fk_srd_class_level_progressions_class_id ON public.srd_class_level_progressions USING btree (class_id)`
- `public.srd_class_level_progressions.idx_fk_srd_class_level_progressions_source_id`: `CREATE INDEX idx_fk_srd_class_level_progressions_source_id ON public.srd_class_level_progressions USING btree (source_id)`
- `public.srd_class_level_progressions.srd_class_level_progressions_pkey`: `CREATE UNIQUE INDEX srd_class_level_progressions_pkey ON public.srd_class_level_progressions USING btree (class_id, class_level)`
- `public.srd_classes.idx_fk_srd_classes_source_id`: `CREATE INDEX idx_fk_srd_classes_source_id ON public.srd_classes USING btree (source_id)`
- `public.srd_classes.srd_classes_class_key_uidx`: `CREATE UNIQUE INDEX srd_classes_class_key_uidx ON public.srd_classes USING btree (class_key) WHERE (class_key IS NOT NULL)`
- `public.srd_classes.srd_classes_nome_idx`: `CREATE INDEX srd_classes_nome_idx ON public.srd_classes USING btree (lower(nome))`
- `public.srd_classes.srd_classes_pkey`: `CREATE UNIQUE INDEX srd_classes_pkey ON public.srd_classes USING btree (id)`
- `public.srd_conditions.idx_fk_srd_conditions_source_id`: `CREATE INDEX idx_fk_srd_conditions_source_id ON public.srd_conditions USING btree (source_id)`
- `public.srd_conditions.srd_conditions_pkey`: `CREATE UNIQUE INDEX srd_conditions_pkey ON public.srd_conditions USING btree (condition_id)`
- `public.srd_deities.srd_deities_domains_gin`: `CREATE INDEX srd_deities_domains_gin ON public.srd_deities USING gin (domains)`
- `public.srd_deities.srd_deities_pkey`: `CREATE UNIQUE INDEX srd_deities_pkey ON public.srd_deities USING btree (deity_id)`
- `public.srd_deities.srd_deities_racial_races_gin`: `CREATE INDEX srd_deities_racial_races_gin ON public.srd_deities USING gin (racial_races)`
- `public.srd_domain_spells.idx_fk_srd_domain_spells_domain_id`: `CREATE INDEX idx_fk_srd_domain_spells_domain_id ON public.srd_domain_spells USING btree (domain_id)`
- `public.srd_domain_spells.idx_fk_srd_domain_spells_source_id`: `CREATE INDEX idx_fk_srd_domain_spells_source_id ON public.srd_domain_spells USING btree (source_id)`
- `public.srd_domain_spells.idx_fk_srd_domain_spells_spell_id`: `CREATE INDEX idx_fk_srd_domain_spells_spell_id ON public.srd_domain_spells USING btree (spell_id)`
- `public.srd_domain_spells.srd_domain_spells_pkey`: `CREATE UNIQUE INDEX srd_domain_spells_pkey ON public.srd_domain_spells USING btree (domain_id, spell_level)`
- `public.srd_domains.idx_fk_srd_domains_source_id`: `CREATE INDEX idx_fk_srd_domains_source_id ON public.srd_domains USING btree (source_id)`
- `public.srd_domains.srd_domains_pkey`: `CREATE UNIQUE INDEX srd_domains_pkey ON public.srd_domains USING btree (domain_id)`
- `public.srd_equipment.idx_fk_srd_equipment_source_id`: `CREATE INDEX idx_fk_srd_equipment_source_id ON public.srd_equipment USING btree (source_id)`
- `public.srd_equipment.srd_equipment_nome_idx`: `CREATE INDEX srd_equipment_nome_idx ON public.srd_equipment USING btree (lower(nome))`
- `public.srd_equipment.srd_equipment_pkey`: `CREATE UNIQUE INDEX srd_equipment_pkey ON public.srd_equipment USING btree (id)`
- `public.srd_equipment_audit.srd_equipment_audit_pkey`: `CREATE UNIQUE INDEX srd_equipment_audit_pkey ON public.srd_equipment_audit USING btree (equipment_id)`
- `public.srd_feats.idx_fk_srd_feats_source_id`: `CREATE INDEX idx_fk_srd_feats_source_id ON public.srd_feats USING btree (source_id)`
- `public.srd_feats.srd_feats_pkey`: `CREATE UNIQUE INDEX srd_feats_pkey ON public.srd_feats USING btree (id)`
- `public.srd_languages.srd_languages_nome_key`: `CREATE UNIQUE INDEX srd_languages_nome_key ON public.srd_languages USING btree (nome)`
- `public.srd_languages.srd_languages_pkey`: `CREATE UNIQUE INDEX srd_languages_pkey ON public.srd_languages USING btree (id)`
- `public.srd_monsters.idx_fk_srd_monsters_source_id`: `CREATE INDEX idx_fk_srd_monsters_source_id ON public.srd_monsters USING btree (source_id)`
- `public.srd_monsters.srd_monsters_nome_idx`: `CREATE INDEX srd_monsters_nome_idx ON public.srd_monsters USING btree (lower(nome))`
- `public.srd_monsters.srd_monsters_pkey`: `CREATE UNIQUE INDEX srd_monsters_pkey ON public.srd_monsters USING btree (id)`
- `public.srd_npc_archetypes.idx_fk_srd_npc_archetypes_class_id`: `CREATE INDEX idx_fk_srd_npc_archetypes_class_id ON public.srd_npc_archetypes USING btree (class_id)`
- `public.srd_npc_archetypes.idx_fk_srd_npc_archetypes_race_id`: `CREATE INDEX idx_fk_srd_npc_archetypes_race_id ON public.srd_npc_archetypes USING btree (race_id)`
- `public.srd_npc_archetypes.idx_fk_srd_npc_archetypes_source_id`: `CREATE INDEX idx_fk_srd_npc_archetypes_source_id ON public.srd_npc_archetypes USING btree (source_id)`
- `public.srd_npc_archetypes.srd_npc_archetypes_pkey`: `CREATE UNIQUE INDEX srd_npc_archetypes_pkey ON public.srd_npc_archetypes USING btree (id)`
- `public.srd_npc_archetypes.srd_npc_archetypes_race_id_class_id_variant_key`: `CREATE UNIQUE INDEX srd_npc_archetypes_race_id_class_id_variant_key ON public.srd_npc_archetypes USING btree (race_id, class_id, variant)`
- `public.srd_npc_attack_attempts.srd_npc_attack_attempts_pkey`: `CREATE UNIQUE INDEX srd_npc_attack_attempts_pkey ON public.srd_npc_attack_attempts USING btree (id)`
- `public.srd_npc_attack_attempts.srd_npc_attack_attempts_sequence_id_attempt_index_key`: `CREATE UNIQUE INDEX srd_npc_attack_attempts_sequence_id_attempt_index_key ON public.srd_npc_attack_attempts USING btree (sequence_id, attempt_index)`
- `public.srd_npc_attack_attempts.srd_npc_attack_attempts_sequence_id_damage_idempotency_key_key`: `CREATE UNIQUE INDEX srd_npc_attack_attempts_sequence_id_damage_idempotency_key_key ON public.srd_npc_attack_attempts USING btree (sequence_id, damage_idempotency_key)`
- `public.srd_npc_attack_attempts.srd_npc_attack_attempts_sequence_id_idempotency_key_key`: `CREATE UNIQUE INDEX srd_npc_attack_attempts_sequence_id_idempotency_key_key ON public.srd_npc_attack_attempts USING btree (sequence_id, idempotency_key)`
- `public.srd_npc_attack_sequences.idx_srd_npc_attack_sequences_actor_character_id`: `CREATE INDEX idx_srd_npc_attack_sequences_actor_character_id ON public.srd_npc_attack_sequences USING btree (actor_character_id)`
- `public.srd_npc_attack_sequences.srd_npc_attack_one_active_per_actor`: `CREATE UNIQUE INDEX srd_npc_attack_one_active_per_actor ON public.srd_npc_attack_sequences USING btree (campaign_id, actor_token_id) WHERE (status = 'active'::text)`
- `public.srd_npc_attack_sequences.srd_npc_attack_sequences_id_campaign_id_key`: `CREATE UNIQUE INDEX srd_npc_attack_sequences_id_campaign_id_key ON public.srd_npc_attack_sequences USING btree (id, campaign_id)`
- `public.srd_npc_attack_sequences.srd_npc_attack_sequences_pkey`: `CREATE UNIQUE INDEX srd_npc_attack_sequences_pkey ON public.srd_npc_attack_sequences USING btree (id)`
- `public.srd_races.idx_fk_srd_races_source_id`: `CREATE INDEX idx_fk_srd_races_source_id ON public.srd_races USING btree (source_id)`
- `public.srd_races.srd_races_pkey`: `CREATE UNIQUE INDEX srd_races_pkey ON public.srd_races USING btree (id)`
- `public.srd_rule_modules.idx_fk_srd_rule_modules_ruleset_id`: `CREATE INDEX idx_fk_srd_rule_modules_ruleset_id ON public.srd_rule_modules USING btree (ruleset_id)`
- `public.srd_rule_modules.idx_fk_srd_rule_modules_source_id`: `CREATE INDEX idx_fk_srd_rule_modules_source_id ON public.srd_rule_modules USING btree (source_id)`
- `public.srd_rule_modules.srd_rule_modules_pkey`: `CREATE UNIQUE INDEX srd_rule_modules_pkey ON public.srd_rule_modules USING btree (module_id)`
- `public.srd_rule_modules.srd_rule_modules_ruleset_id_module_key_key`: `CREATE UNIQUE INDEX srd_rule_modules_ruleset_id_module_key_key ON public.srd_rule_modules USING btree (ruleset_id, module_key)`
- `public.srd_rule_sources.srd_rule_sources_pkey`: `CREATE UNIQUE INDEX srd_rule_sources_pkey ON public.srd_rule_sources USING btree (source_id)`
- `public.srd_rulesets.idx_fk_srd_rulesets_primary_source_id`: `CREATE INDEX idx_fk_srd_rulesets_primary_source_id ON public.srd_rulesets USING btree (primary_source_id)`
- `public.srd_rulesets.srd_rulesets_pkey`: `CREATE UNIQUE INDEX srd_rulesets_pkey ON public.srd_rulesets USING btree (ruleset_id)`
- `public.srd_skills.idx_fk_srd_skills_source_id`: `CREATE INDEX idx_fk_srd_skills_source_id ON public.srd_skills USING btree (source_id)`
- `public.srd_skills.srd_skills_pkey`: `CREATE UNIQUE INDEX srd_skills_pkey ON public.srd_skills USING btree (id)`
- `public.srd_spell_effects.idx_fk_srd_spell_effects_source_id`: `CREATE INDEX idx_fk_srd_spell_effects_source_id ON public.srd_spell_effects USING btree (source_id)`
- `public.srd_spell_effects.idx_fk_srd_spell_effects_spell_id`: `CREATE INDEX idx_fk_srd_spell_effects_spell_id ON public.srd_spell_effects USING btree (spell_id)`
- `public.srd_spell_effects.srd_spell_effects_pkey`: `CREATE UNIQUE INDEX srd_spell_effects_pkey ON public.srd_spell_effects USING btree (spell_id, effect_index)`
- `public.srd_spell_level_progressions.idx_fk_srd_spell_level_progressions_source_id`: `CREATE INDEX idx_fk_srd_spell_level_progressions_source_id ON public.srd_spell_level_progressions USING btree (source_id)`
- `public.srd_spell_level_progressions.srd_spell_level_progressions_pkey`: `CREATE UNIQUE INDEX srd_spell_level_progressions_pkey ON public.srd_spell_level_progressions USING btree (class_id, class_level, spell_level)`
- `public.srd_spell_progressions.srd_spell_progressions_pkey`: `CREATE UNIQUE INDEX srd_spell_progressions_pkey ON public.srd_spell_progressions USING btree (class_key)`
- `public.srd_spells.idx_fk_srd_spells_source_id`: `CREATE INDEX idx_fk_srd_spells_source_id ON public.srd_spells USING btree (source_id)`
- `public.srd_spells.srd_spells_nome_idx`: `CREATE INDEX srd_spells_nome_idx ON public.srd_spells USING btree (lower(nome))`
- `public.srd_spells.srd_spells_pkey`: `CREATE UNIQUE INDEX srd_spells_pkey ON public.srd_spells USING btree (id)`
- `public.srd_starting_packages.idx_fk_srd_starting_packages_source_id`: `CREATE INDEX idx_fk_srd_starting_packages_source_id ON public.srd_starting_packages USING btree (source_id)`
- `public.srd_starting_packages.srd_starting_packages_pkey`: `CREATE UNIQUE INDEX srd_starting_packages_pkey ON public.srd_starting_packages USING btree (class_id)`
- `public.terrain.idx_fk_terrain_campaign_id`: `CREATE INDEX idx_fk_terrain_campaign_id ON public.terrain USING btree (campaign_id)`
- `public.terrain.terrain_pkey`: `CREATE UNIQUE INDEX terrain_pkey ON public.terrain USING btree (campaign_id, x, y)`
- `public.tokens.idx_fk_tokens_campaign_id`: `CREATE INDEX idx_fk_tokens_campaign_id ON public.tokens USING btree (campaign_id)`
- `public.tokens.idx_fk_tokens_character_id`: `CREATE INDEX idx_fk_tokens_character_id ON public.tokens USING btree (character_id)`
- `public.tokens.idx_fk_tokens_monster_instance_id`: `CREATE INDEX idx_fk_tokens_monster_instance_id ON public.tokens USING btree (monster_instance_id)`
- `public.tokens.tokens_pkey`: `CREATE UNIQUE INDEX tokens_pkey ON public.tokens USING btree (id)`
- `public.vinculo_abilities.abilities_pkey`: `CREATE UNIQUE INDEX abilities_pkey ON public.vinculo_abilities USING btree (id)`
- `public.vinculo_character_notes.character_notes_pkey`: `CREATE UNIQUE INDEX character_notes_pkey ON public.vinculo_character_notes USING btree (id)`
- `public.vinculo_character_notes.idx_fk_vinculo_character_notes_character_id`: `CREATE INDEX idx_fk_vinculo_character_notes_character_id ON public.vinculo_character_notes USING btree (character_id)`
- `public.vinculo_character_sheets.character_sheets_pkey`: `CREATE UNIQUE INDEX character_sheets_pkey ON public.vinculo_character_sheets USING btree (character_id)`
- `public.vinculo_character_sheets.idx_fk_vinculo_character_sheets_armadura`: `CREATE INDEX idx_fk_vinculo_character_sheets_armadura ON public.vinculo_character_sheets USING btree (armadura)`
- `public.vinculo_character_sheets.idx_fk_vinculo_character_sheets_classe`: `CREATE INDEX idx_fk_vinculo_character_sheets_classe ON public.vinculo_character_sheets USING btree (classe)`
- `public.vinculo_character_sheets.idx_fk_vinculo_character_sheets_cultura`: `CREATE INDEX idx_fk_vinculo_character_sheets_cultura ON public.vinculo_character_sheets USING btree (cultura)`
- `public.vinculo_character_sheets.idx_fk_vinculo_character_sheets_escudo`: `CREATE INDEX idx_fk_vinculo_character_sheets_escudo ON public.vinculo_character_sheets USING btree (escudo)`
- `public.vinculo_classes.classes_nome_key`: `CREATE UNIQUE INDEX classes_nome_key ON public.vinculo_classes USING btree (nome)`
- `public.vinculo_classes.classes_pkey`: `CREATE UNIQUE INDEX classes_pkey ON public.vinculo_classes USING btree (id)`
- `public.vinculo_inventory.idx_fk_vinculo_inventory_item_id`: `CREATE INDEX idx_fk_vinculo_inventory_item_id ON public.vinculo_inventory USING btree (item_id)`
- `public.vinculo_inventory.inventory_pkey`: `CREATE UNIQUE INDEX inventory_pkey ON public.vinculo_inventory USING btree (character_id, item_id)`
- `public.vinculo_items.items_pkey`: `CREATE UNIQUE INDEX items_pkey ON public.vinculo_items USING btree (id)`
- `public.vinculo_items.items_raridade_idx`: `CREATE INDEX items_raridade_idx ON public.vinculo_items USING btree (raridade)`
- `public.vinculo_spells.spells_pkey`: `CREATE UNIQUE INDEX spells_pkey ON public.vinculo_spells USING btree (id)`
- `public.vinculo_talents.talents_pkey`: `CREATE UNIQUE INDEX talents_pkey ON public.vinculo_talents USING btree (id)`

## Funções e procedures — assinatura e fingerprint

> O fingerprint muda com qualquer alteração no texto retornado por pg_get_functiondef; ele não substitui armazenamento do corpo SQL.

| Assinatura | SECURITY DEFINER | MD5 da definição |
|---|---:|---|
| `priv.can_delete_midia(p_name text)` | sim | `920b99123b9173086c863d9f659d989b` |
| `priv.can_write_midia(p_name text)` | sim | `2c81a9caf54bd8b2658ab9a970f053d2` |
| `priv.clear(k text)` | sim | `b7cc1d6053eb3b4d9af3278fd471fb4c` |
| `priv.concluir_avanco_nivel_personagem_srd(p_campaign_id bigint, p_character_id text, p_hit_die_roll integer, p_skill_ranks jsonb, p_feats jsonb, p_attribute text)` | sim | `e58e0115de2a02f227e8d4c949e3ac6b` |
| `priv.consumir_acao_rodada_completa_srd_impl(p_campaign_id bigint, p_actor_id text, p_actor_kind text)` | sim | `dc01b1d8c2804fd4b4213283a5c448af` |
| `priv.consumir_acao_token_gm_srd_impl(p_campaign_id bigint, p_token_id text, p_acao text)` | sim | `d447cd9c730f0b9e2da1898bd3c77978` |
| `priv.d20()` | não | `d9d808ed5482d5cb6370532869518dd8` |
| `priv.descanso_longo_npc_vinculado_srd_impl(p_campaign_id bigint, p_token_id text)` | sim | `3be4826bda007d1c22efd25a869fec11` |
| `priv.fail(k text, mx integer)` | sim | `7e1a930e05478c802b65a01063c37803` |
| `priv.finalizar_exclusao_campanha_propria(p_campaign_id bigint)` | sim | `ecf729407d6450bb6d0de440a1d23ad2` |
| `priv.gm_npc_apply_typed_damage_impl(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_raw_damage integer, p_damage_type text)` | sim | `bb8ca370b639f8d067e31a0ea4a9d68d` |
| `priv.grow_scene()` | sim | `bbc30d0b06ffbeeaa3f0078d88c1549a` |
| `priv.iniciar_sequencia_ataque_iterativo_srd_5_impl(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid)` | sim | `137f72fe2d53f0ee3d5dd037ac2e90f3` |
| `priv.iniciar_sequencia_ataque_iterativo_srd_7_impl(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)` | sim | `73017cbf28f25be991143340ffc045ae` |
| `priv.iniciar_sequencia_ataque_iterativo_srd_8_impl(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)` | sim | `ad1c910e3881fcb50c84bbea7d181e94` |
| `priv.is_my_turn(p_campaign bigint, p_token bigint)` | sim | `9cc7822fb22d348b5f48b68faa3046e9` |
| `priv.locked(k text)` | sim | `c780474036a98b2771391a240e01d405` |
| `priv.log(cid bigint, t text, d jsonb)` | sim | `fec07d67425fdabb18d7f016a0f71373` |
| `priv.monster_atk(p_nivel integer)` | não | `f6ab7f6a944714458bbc2628c115fa54` |
| `priv.mover_token_gm_cba_srd_impl(p_campaign_id bigint, p_token_id text, p_grid_x integer, p_grid_y integer)` | sim | `525be0344595e1c891488f56ed21c0d9` |
| `priv.mover_token_player_cba_impl(p_campaign_id bigint, p_character_id text, p_grid_x integer, p_grid_y integer)` | sim | `76721907ef6b72373837a64a76c26d19` |
| `priv.need_gm(cid bigint)` | sim | `4bbb8a203ff3af050cf84ca8ecc1b48e` |
| `priv.need_owner(cid bigint)` | sim | `f2c23982efebbeb7b57defdd5afa03b0` |
| `priv.new_sheet()` | sim | `527021bb6bf22a57d1de766e3bb22368` |
| `priv.new_user()` | sim | `bc4bf686e8ec881a818092ee9d66dffc` |
| `priv.npc_aplicar_dano_ataque_iterativo_impl(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[])` | sim | `3075788cbf1b6835951091518f05b0c3` |
| `priv.npc_confirmar_critico_ataque_iterativo_impl(p_campaign_id bigint, p_attempt_id uuid, p_confirmation_d20 integer)` | sim | `df9cd414a7d972a6d5c0984631770835` |
| `priv.npc_consultar_ataque_iterativo_impl(p_campaign_id bigint, p_token_id text, p_attack_type text)` | sim | `e4d87ea83341d4717cca644f5456c0f3` |
| `priv.npc_consultar_ataque_iterativo_pendente_impl(p_campaign_id bigint, p_actor_token_id text)` | sim | `b4beb2bb00752d822a23dfb48d168e0a` |
| `priv.npc_iniciar_ataque_iterativo_impl(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)` | sim | `f597d6e67ded406878d5b7c50d9801e3` |
| `priv.npc_iniciar_ataque_iterativo_impl(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)` | sim | `b10997717c99ab3c679c7e7b965fdeaf` |
| `priv.npc_registrar_rolagem_ataque_iterativo_impl(p_campaign_id bigint, p_sequence_id uuid, p_manual_d20 integer, p_idempotency_key uuid)` | sim | `8f2f5b3ecec9784d126fa6128451ea81` |
| `priv.npc_resolver_ataque_iterativo_impl(p_campaign_id bigint, p_attempt_id uuid)` | sim | `5973faf81be357ce49a92f5d7105b620` |
| `priv.pasta_gm(p_name text)` | sim | `89e36c67befa409da78827d4f5426289` |
| `priv.pericias_completas(p jsonb)` | sim | `b93d4e29bd3bc20f92a92a1fe070c999` |
| `priv.preparar_exclusao_campanha_propria(p_campaign_id bigint)` | sim | `3e346c3ecd566fa17b6ba05755d42dbb` |
| `priv.roll_dice_expr(p_expr text)` | não | `02a1aaf498b895b96da4ef8fa82b601c` |
| `priv.sheet_fix()` | sim | `903f01ffd332aa6153e6cb663efaee0a` |
| `priv.srd35_maneuver_profile(p_campaign_id bigint, p_token_id text)` | sim | `ee6343c7d12edbbb05354b54d53df5bc` |
| `priv.srd_adjust_damage(p_campaign_id bigint, p_target_kind text, p_target_id text, p_damage_type text, p_base_damage integer)` | sim | `5df882627ac9b9f307b1756fb94898ae` |
| `priv.srd_adjust_damage_components(p_campaign_id bigint, p_target_kind text, p_target_id text, p_effect_data jsonb)` | sim | `e1a9b72699f542bd8d6f5e2215112eed` |
| `priv.srd_aoo_require_blind_concealment_roll()` | sim | `1669bd6e269520fa5e2dcb7499b4057e` |
| `priv.srd_apply_campaign_condition(p_campaign_id bigint, p_target_kind text, p_target_id text, p_condition_id text, p_duration_rounds integer, p_notes jsonb, p_source_spell_id text)` | sim | `e7d10d76e10d64f24aaaf780d1ff85b4` |
| `priv.srd_apply_campaign_effect(p_campaign_id bigint, p_target_kind text, p_target_id text, p_effect_kind text, p_effect_data jsonb, p_duration_rounds integer, p_source_spell_id text, p_concentration_actor_id text)` | sim | `cf82432dccda291cfb48fb05b05fa84c` |
| `priv.srd_apply_pending_spell_resolution(p_pending_id uuid)` | sim | `0749178a957f6a60e8ca4abe97dea132` |
| `priv.srd_calcular_ca_alvo_campanha_srd(p_campaign_id bigint, p_character_id text, p_attack_context text)` | sim | `8564d711bbf65f9b2eaa3326f0b5c949` |
| `priv.srd_cancelar_movimento_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid)` | sim | `ee1753fd8f8ad3e6c968942f42816125` |
| `priv.srd_clear_combat_flatfooted_actor(p_campaign_id bigint, p_actor jsonb)` | sim | `3df5d0dfc8c020d07786bde0ba2e4f3f` |
| `priv.srd_clear_combat_flatfooted_all(p_campaign_id bigint)` | sim | `e49e467f7afd13c4bf482a67ef26cbb4` |
| `priv.srd_condition_has_flag(p_campaign_id bigint, p_target_kind text, p_target_id text, p_flag text)` | sim | `f25c39f01caef8e6c06ab640e817a862` |
| `priv.srd_condition_modifier(p_campaign_id bigint, p_target_kind text, p_target_id text, p_stat text)` | sim | `6ed5a3cbe38828c90d8444f1532e69c0` |
| `priv.srd_condition_speed_multiplier(p_campaign_id bigint, p_target_kind text, p_target_id text)` | sim | `6cf605f0be9f963ce64ee1cdddda56c3` |
| `priv.srd_confusion_aoo_engaged(p_campaign_id bigint, p_actor_token_id text, p_actor_character_id text, p_mover_token_id text)` | sim | `94e8a45d2e8ca3745420a1f12f937f8c` |
| `priv.srd_confusion_attack_target_allowed(p_campaign_id bigint, p_actor_kind text, p_actor_id text, p_target_token_id text)` | sim | `068386270b3c83b473620bd2b091ca1d` |
| `priv.srd_confusion_flee_destination_allowed(p_campaign_id bigint, p_actor_token_id text, p_destination_x integer, p_destination_y integer)` | sim | `48540cb60eb6d9dad9f2a88758f8fe09` |
| `priv.srd_confusion_nearest_target_id(p_campaign_id bigint, p_actor_token_id text)` | sim | `6266fb5263993dcb9cd4f68120b1cd10` |
| `priv.srd_effect_has_flag(p_campaign_id bigint, p_target_kind text, p_target_id text, p_flag text)` | sim | `df243982cff479b877810166baceb19e` |
| `priv.srd_effective_modifier(p_campaign_id bigint, p_target_kind text, p_target_id text, p_stat text)` | sim | `78a81bccb9e96dc39828752d26dbbb26` |
| `priv.srd_effective_token_speed_m(p_campaign_id bigint, p_token_id text)` | sim | `2ba581856658143c67fc9cd231dcbb27` |
| `priv.srd_encerrar_reacao_aoo_pendente_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean)` | sim | `5cae44f8906a5b12952720e39d76f6cb` |
| `priv.srd_end_barbarian_rage(p_campaign_id bigint, p_character_id text, p_apply_fatigue boolean)` | sim | `1ab5c6b2f9bcae088fd25fdaf6d23369` |
| `priv.srd_end_barbarian_rage_token(p_campaign_id bigint, p_token_id text, p_apply_fatigue boolean)` | sim | `20a6ac0ff5babff2d11b42ef99885f67` |
| `priv.srd_expire_barbarian_rage_on_round_change()` | sim | `0fe59aebae111c60cf417eca2ae8f2ac` |
| `priv.srd_feat_saving_throw_modifier(p_feats jsonb, p_save text)` | sim | `f504321eaeb6b6a12f5eebbfdab7cdfc` |
| `priv.srd_grid_footprint_distance_ft(p_ax integer, p_ay integer, p_asize integer, p_bx integer, p_by integer, p_bsize integer)` | não | `d403be0bd80deda829870b04df77d2d5` |
| `priv.srd_guard_aoo_cannot_attack()` | sim | `0ff70ee88e3cc734581db3df022f0409` |
| `priv.srd_guard_pending_aoo_movement()` | sim | `9a9a41aa24a8ee42393daaa1ecc1ec37` |
| `priv.srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)` | sim | `2ab33685b041ef930b6ae7e2b48e3991` |
| `priv.srd_iniciar_encontrao_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text)` | sim | `d2e5fba9a401630ba9573dbad36f6b90` |
| `priv.srd_iniciar_levantar_caido_srd(p_campaign_id bigint, p_token_id text)` | sim | `d834ce99269a63a103f3530179eaca35` |
| `priv.srd_parse_natural_attack_list(p_attack_text text)` | não | `e488820992328651739ce13290164c20` |
| `priv.srd_passive_feat_modifier(p_character_id bigint, p_stat text)` | sim | `c3b4088402466d6cf3ccd22e3c6fbcbd` |
| `priv.srd_registrar_ocultacao_ataque_oportunidade_impl(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)` | sim | `43cb67bd4552bd98181d8d367850ff90` |
| `priv.srd_request_confusion_turn_roll()` | sim | `a71eafca99136cf156abe55a0aeceea6` |
| `priv.srd_reservar_ataque_oportunidade_impl(p_campaign_id bigint, p_actor_token_id text, p_trigger_key text, p_actor_flat_footed boolean)` | sim | `4c9a7d64f8d098ae43a7bfc42beffce4` |
| `priv.srd_reservar_reacao_movimento_aoo_impl(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)` | sim | `3775a7763a3ed392bacb2250504a9a24` |
| `priv.srd_resolve_confusion_turn_impl(p_campaign_id bigint, p_target_kind text, p_target_id text, p_request_id uuid, p_manual_d100 integer)` | sim | `fd74396de748cabb99445fc5d53e9c1c` |
| `priv.srd_resolver_derrubar_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean)` | sim | `5bf3be6185cbd49939f07ff35c540afc` |
| `priv.srd_resolver_derrubar_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_attacker_d20 integer, p_defender_d20 integer, p_defender_uses_dex boolean, p_defender_firm_ground boolean, p_trip_using_weapon boolean)` | sim | `897de782fd7550f4801aaeea7cb33035` |
| `priv.srd_resolver_derrubar_srd_api(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean, p_trip_using_weapon boolean)` | sim | `376abf6fafd9ee4370b8c3dafca3be9d` |
| `priv.srd_resolver_encontrao_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_follow boolean)` | sim | `faaf2f7ae47e370dac71ecb5110936eb` |
| `priv.srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid)` | sim | `fa34c68e20bb6b03fb13b1d11c09c523` |
| `priv.srd_restore_surprised_flatfooted(p_campaign_id bigint, p_turn_order jsonb, p_aware_ids text[])` | sim | `af53cd7490986e31a3d3ae367322db7e` |
| `priv.srd_saving_throw_bonus(p_campaign_id bigint, p_target_kind text, p_target_id text, p_save_type text, p_context text)` | sim | `8bad7a00c620ab8ed9016def65036568` |
| `priv.srd_spell_penetration_feat_bonus(p_character_id text)` | sim | `247ea2e5f378bc3aa8ee53544a78d7df` |
| `priv.srd_spell_resistance_value(p_campaign_id bigint, p_target_kind text, p_target_id text)` | sim | `dd0ea6200617297d7bab94bae271037d` |
| `priv.srd_start_combat_flatfooted(p_campaign_id bigint, p_turn_order jsonb, p_first_turn integer)` | sim | `e5055d9d334e096cbb664e8da475c895` |
| `priv.srd_sync_character_vital_condition(p_character_id text, p_pv integer, p_stabilize boolean)` | sim | `44a4806f85e3693f77a4c84f4ff75204` |
| `priv.srd_sync_linked_npc_token_vitals(p_campaign_id bigint, p_token_id text, p_token_hp integer, p_token_max_hp integer)` | sim | `ab67e2b13e1ad61f4e534bc341d47f2e` |
| `priv.srd_sync_linked_npc_token_vitals(p_campaign_id bigint, p_token_id text, p_token_hp integer, p_token_max_hp integer, p_stabilize boolean)` | sim | `5621f7373a7c71343b9a6a26cbaf5cfa` |
| `priv.srd_token_grid_footprint(p_campaign_id bigint, p_token_id text)` | sim | `b67b870d2fda08cd6263690d4d77bb47` |
| `priv.srd_validate_aoo_pending_movement_preview()` | sim | `aca15b8ef5fd809cbd20b69adf8f01be` |
| `priv.srd_validate_surprise_action(p_campaign_id bigint, p_actor_id text, p_action text)` | sim | `9fd64a682dadce69e759d8db75c3be64` |
| `priv.srd_weapon_proficiency(p_details jsonb, p_weapon_name text)` | não | `8ba36971a24d5d116181425cd5fe59f0` |
| `private.consultar_inventario_npc_vinculado_impl(p_campaign_id bigint, p_token_id text)` | sim | `22e596031ad2a17482ffb2a92b84a64b` |
| `private.equipar_arma_instancia_npc_vinculado_impl(p_campaign_id bigint, p_token_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)` | sim | `d7e8757edda6510a57dad5d5e065c32f` |
| `private.equipar_arma_instancia_personagem_impl(p_character_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)` | sim | `bd60100ed896b066e00014e1c09a4ea6` |
| `private.equipar_arma_instancia_token_impl(p_campaign_id bigint, p_token_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)` | sim | `e2170005b9dd7681b5a9b5505289a78f` |
| `private.equipar_item_npc_vinculado_impl(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean)` | sim | `519f713289128580e776cb8b160e6532` |
| `private.equipar_item_token_srd_maos_impl(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_hand_slot text, p_equipado boolean)` | sim | `5779b1428c0c1b93af9fb2b88f9d6858` |
| `private.sync_character_weapon_instances_from_inventory()` | sim | `fb355472a05257b53cca39bd3c3cf847` |
| `private.sync_token_weapon_instances_from_inventory()` | sim | `1db1e8db35808656368273e0890b363c` |
| `public._srd35_attr(p_doc jsonb, p_keys text[])` | não | `d26f6d4fc86e722ea7747c27f39a7c61` |
| `public._srd35_character_class_level(p_character_id text, p_class_key text, p_primary_class_id text, p_total_level integer)` | sim | `871bdd620458fb0a6f2914703f61db9b` |
| `public._srd35_class_key(p_value text)` | não | `04cf9f05755f3cd5c285b90c52a0c792` |
| `public._srd35_school_key(p_school text)` | não | `59edf0be16143691a84a01195dcaa84a` |
| `public._srd35_slots(p_class text, p_level integer, p_score integer, p_circle integer)` | não | `d9767c3becdb8541ac3944302de16a16` |
| `public._srd35_spell_class_ok(p_classes text[], p_class text)` | não | `c9de94e84cf7e7414a8eb97657809c2c` |
| `public._srd35_spell_level_for_class(p_levels text, p_class_key text, p_fallback integer)` | não | `169b5a9ea5611bee974f6f0cb2aebcb4` |
| `public.add_monster_to_scene(cid bigint, p_monster text, p_x integer, p_y integer)` | sim | `389890bc100cf4c810711fa28dbc9d75` |
| `public.add_owner_as_gm()` | não | `9f57a423a4e849284f3d8d34aa8127af` |
| `public.adicionar_combatente_iniciativa(p_campaign_id bigint, p_combatente_id text, p_nome text, p_valor integer, p_tipo text)` | sim | `a0428bb1540effb553bca4d0c6687cf5` |
| `public.adicionar_token_cba(p_campaign_id bigint, p_token jsonb)` | sim | `ae3da91a7eda603caebf5793d737c226` |
| `public.adicionar_token_cba_completo(p_campaign_id bigint, p_token jsonb)` | sim | `f0ce341c60ff19afa06d38eae0f8b8a7` |
| `public.alterar_pv_personagem(p_campaign_id bigint, p_character_id text, p_variacao integer)` | não | `c53ad451507f4e0182052dfedf2ce5c8` |
| `public.alterar_pv_token_cba(p_campaign_id bigint, p_token_id text, p_variacao integer, p_pv_max integer)` | sim | `c16193eb256fd156122f436fe9f669e0` |
| `public.alternar_estado_campanha(p_campaign_id bigint, p_novo_estado text)` | sim | `77ff609586000e471759ef6c26dd21c7` |
| `public.answer_roll(p_id bigint, p_d20 integer)` | sim | `7fa9cce1511c8b659c44dc714457309d` |
| `public.aplicar_dano_ataque_iterativo_npc_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[])` | não | `60596b6303dabb6bbff7d8d0ba91b5f0` |
| `public.aplicar_dano_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)` | sim | `ad87093138d4a3e4ea86557294723f25` |
| `public.aplicar_dano_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_damage_rolls integer[], p_idempotency_key uuid, p_sneak_damage_rolls integer[])` | sim | `fc0c985d6d6e8fa86c42dcabc772e03d` |
| `public.aplicar_dano_ataque_npc_gm_srd(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_raw_damage integer, p_damage_type text)` | não | `892cf0cbd52da4190601bb422947a644` |
| `public.aplicar_dano_token_ataque_srd(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer)` | sim | `e2884aa639d6cad12c0919587f5b7b8c` |
| `public.aplicar_dano_token_ataque_srd_v2(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer)` | sim | `1993f6c033c12f4b9291e9cb5c422f52` |
| `public.aplicar_dano_token_ataque_srd_v2(p_campaign_id bigint, p_character_id text, p_token_id text, p_d20 integer, p_bonus_ataque integer, p_dano integer, p_weapon_id text, p_attack_type text, p_power_penalty integer, p_sneak_attack_dice integer, p_sneak_attack_damage integer)` | sim | `84a9cce6a6c3abe9571a66e7e38cf65d` |
| `public.aplicar_dano_token_gm_personagem_srd(p_campaign_id bigint, p_token_id text, p_character_id text, p_dano integer)` | sim | `324a03cbf53209750104128ba5e48ae7` |
| `public.apply_condition(p_char bigint, p_condition text, p_origem text, p_duracao text)` | sim | `f03b3d5c89783d11cc7210d79c492f5d` |
| `public.apply_damage(p_alvo bigint, p_qtd integer, p_tipo text)` | sim | `1e6b3b4189492f4ac50098beb6a052f3` |
| `public.apply_heal(p_alvo bigint, p_qtd integer)` | sim | `25cd14d0998b2bd214b11ffbb8e067c6` |
| `public.ask_roll(cid bigint, p_to uuid, p_kind text, p_label text, p_atributo text, p_cd integer, p_motivo text)` | sim | `42114d8ef76d1b63a7200370b0ff4c7f` |
| `public.attack(p_atk bigint, p_alvo bigint, p_tipo text)` | sim | `1d3a61de5344aaf8e054e7a2c225e253` |
| `public.attr_max(p_nivel integer)` | não | `1721f7c49fa85eb4a87adf54a4dc8950` |
| `public.attr_points(p_nivel integer)` | não | `1e4cee353dddc8e37c4ecdd6c4910637` |
| `public.atualizar_configuracoes_campanha(p_campaign_id bigint, p_name text, p_require_code boolean, p_code text)` | sim | `76e8115c02135fc7c6dc4b5040df607d` |
| `public.avancar_turno(p_campaign_id bigint)` | sim | `0086242101af79898ecae9fb319c2e1e` |
| `public.calc_ca(p_armadura text, p_escudo text, p_des integer, p_bonus integer)` | não | `dbbcddfdbd33491d841fe036a5a8fe70` |
| `public.calc_desl(p_classe text, p_des integer, p_armadura text, p_escudo text, p_condicoes jsonb, p_carga numeric, p_capacidade numeric)` | não | `ba914300f598af2fdc47767910f84307` |
| `public.calc_ini(p_des integer)` | não | `778bf6bdec51988d9c5fd53973eda86b` |
| `public.calc_pm(p_classe text, p_int integer)` | não | `fa0538b71abc900a84f459fdae00fa18` |
| `public.calc_pv(p_classe text, p_con integer)` | não | `d6489fad3abc5c9d27e89ed59fcc5385` |
| `public.calc_rm(p_classe text, p_int integer, p_bonus integer)` | não | `4b0f8965d80b56f67e01b3c3ed5b98d0` |
| `public.calc_sheet(p_char bigint)` | não | `ce41693dcf0bc87dbae7f8f875e078d9` |
| `public.can_read_media(p_path text)` | sim | `10bbdbb1fc9a41128134bf7c19af937d` |
| `public.capacity(p_for integer)` | não | `81d564d60215db4dda2c472b51188238` |
| `public.clonar_equipamento_ficha_para_token(p_campaign_id bigint, p_token_id text, p_character_id text)` | sim | `25a6306d66e468d9f449196ea3ec3e53` |
| `public.combat_set_turn(p_token bigint)` | sim | `181f8156fd7b5ab61e81cfa2bf24c5dd` |
| `public.conceder_xp_personagem_srd(p_campaign_id bigint, p_character_id text, p_xp integer)` | sim | `cd64caeb9ab3513c82fb1735d4f224de` |
| `public.concluir_avanco_nivel_personagem_srd_v2(p_campaign_id bigint, p_character_id text, p_hit_die_roll integer, p_skill_ranks jsonb, p_feats jsonb, p_attribute text, p_idiomas jsonb)` | não | `25410d7aed5a672c97a6204e9209b66c` |
| `public.confirm_sheet(p_char bigint)` | sim | `58669122d5f87b54d4617a07033ba60a` |
| `public.confirmar_critico_ataque_iterativo_npc_srd(p_campaign_id bigint, p_attempt_id uuid, p_confirmation_d20 integer)` | não | `0a9b8fb25f8d0bdd6596bccaea084080` |
| `public.confirmar_critico_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid, p_confirmation_d20 integer)` | sim | `5f3deff88f2976d987b5a3445a459c5a` |
| `public.conjurar_magia_com_acao_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text)` | sim | `c2b07ced7d276e4124adb67bea7ccb6d` |
| `public.conjurar_magia_com_acao_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_roll_results integer[])` | sim | `902eb4878ef7e9b3474bfce94b708739` |
| `public.conjurar_magia_com_acao_srd_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])` | sim | `412b763c16c11dc3de607efddcc4753d` |
| `public.conjurar_magia_com_acao_srd_multialvo_v2(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])` | sim | `b20039b960db80ad2953083c5742c19b` |
| `public.conjurar_magia_com_acao_srd_multialvo_v3(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])` | sim | `16e636a42055f5716ffdd77707ccf1a7` |
| `public.conjurar_magia_dano_multialvo_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])` | sim | `07a0bbe02f336d8f0296591c284f0866` |
| `public.conjurar_magia_efeitos_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])` | sim | `dee23f4384b4522d5cd67dc4feba9298` |
| `public.conjurar_magia_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text)` | sim | `968aa3cd53a7de448c06cbb73753092c` |
| `public.conjurar_magia_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_roll_results integer[])` | sim | `22b396880b05091ccf8e3ea6ed62a186` |
| `public.conjurar_magia_srd_multialvo(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])` | sim | `f0fda8294ad75ce6359d12701c46daef` |
| `public.conjurar_magia_srd_multialvo_v2(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[])` | sim | `193955a0e0e1e01e73f23eea278c658e` |
| `public.conjurar_magia_srd_multialvo_v3(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_keys text[], p_roll_results integer[])` | sim | `031e4eca3a4da16f490997b568109190` |
| `public.conjurar_missil_magico_srd(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_damage integer)` | sim | `311cbe5d189ace43f977e644685a4808` |
| `public.conjurar_missil_magico_srd_manual(p_character_id text, p_spell_id text, p_slot_level smallint, p_target_token_key text, p_damage_rolls integer[])` | sim | `ba9983e6c955519a03fe6a6235dae5f5` |
| `public.consultar_ataque_iterativo_npc_pendente_srd(p_campaign_id bigint, p_actor_token_id text)` | não | `fca4296a9c17375951320ebba4d60b1f` |
| `public.consultar_ataque_iterativo_npc_srd(p_campaign_id bigint, p_token_id text, p_attack_type text)` | não | `aeccc155d2d493f7d26f7c6f65f2d9b9` |
| `public.consultar_furia_barbaro_npc_srd(p_campaign_id bigint, p_token_id text)` | sim | `c7c753d63edb840ce20e3862461ee681` |
| `public.consultar_furia_barbaro_srd(p_character_id text)` | sim | `b9bd5fc174faf0f970ae4b8013135899` |
| `public.consultar_inventario_npc_vinculado_srd(p_campaign_id bigint, p_token_id text)` | não | `0a25fdca62cfd61d843800de36ce7ca7` |
| `public.consultar_sequencia_ataque_iterativo_pendente_srd(p_campaign_id bigint, p_character_id text)` | sim | `c3744ac6d89aeadb83b44473468fdf54` |
| `public.consumir_acao_rodada_completa_srd(p_campaign_id bigint, p_actor_id text, p_actor_kind text)` | não | `3cd0cce804652bd00d2a67cbe3839404` |
| `public.consumir_acao_token_gm_srd(p_campaign_id bigint, p_token_id text, p_acao text)` | não | `153b71929c64b77d2450d91406106703` |
| `public.consumir_acao_turno_srd(p_campaign_id bigint, p_character_id text, p_acao text)` | sim | `8937c55a8b6ba7632eef037b5f5ecac4` |
| `public.create_campaign(p_name text, p_code text, p_location bigint)` | sim | `9351a6f21c64cc291a33fb18459793fc` |
| `public.create_character(cid bigint, p_nome text)` | sim | `c3102bc5b72021fa8f22de8def421836` |
| `public.criar_personagem_srd(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb)` | sim | `7dc4b41e96a33aef784c8f113c6192ef` |
| `public.criar_personagem_srd_completo(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb, p_pericias jsonb, p_talentos jsonb)` | sim | `97839c425fe0dd00b1570d7ba2f968fe` |
| `public.criar_personagem_srd_completo(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb, p_pericias jsonb, p_talentos jsonb, p_identidade jsonb)` | sim | `9065cd7adc215d53a18dfe2bdcbced9d` |
| `public.descanso_longo_npc_vinculado_srd(p_campaign_id bigint, p_token_id text)` | não | `be8a3312b1123e66ffff91cebffcb8e7` |
| `public.descanso_longo_personagem_srd(p_campaign_id bigint, p_character_id text)` | sim | `7448c5c9bc5ae10c0695f84cf09cb25b` |
| `public.encumbrance(p_carga numeric, p_for integer)` | não | `be6d61f5a059d1258eb08d8b7b4a7a06` |
| `public.end_combat(cid bigint)` | sim | `a8f56b17b36af10c56b421bf56113798` |
| `public.end_turn(p_token bigint)` | sim | `f55fcd29fb4a0ece7d4dc584614c9ad9` |
| `public.enforce_campaign_member_role()` | sim | `11fb61b11c3c1cb117b03645fb7096b2` |
| `public.entrar_campanha_aberta(p_campaign_id bigint)` | sim | `f497e63e2f71e78486451c7442103f4c` |
| `public.entrar_campanha_com_codigo(p_campaign_id bigint, p_code text)` | sim | `048393b68fa7a625a544ef9baa548af4` |
| `public.entregar_item_srd(p_campaign_id bigint, p_character_id text, p_equipment_id text, p_quantidade integer)` | sim | `1847f736d1e28a69ae8379963ba258b2` |
| `public.entregar_item_token_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_quantidade integer)` | sim | `5ac265f058a9ebd62486cf6201d0ae42` |
| `public.equipar_arma_instancia_npc_vinculado_srd(p_campaign_id bigint, p_token_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)` | não | `4d1ded2d09a05766bd7c67946f91a059` |
| `public.equipar_arma_instancia_personagem(p_character_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)` | não | `35ec8e850c50554882c8f94a7d40af53` |
| `public.equipar_arma_instancia_token(p_campaign_id bigint, p_token_id text, p_instance_id uuid, p_hand_slot text, p_equipado boolean)` | não | `7fc40a7e461e40e81aba09da2c673e69` |
| `public.equipar_item_npc_vinculado_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean)` | não | `8fafa42813373b0a7dcf376c882befc5` |
| `public.equipar_item_srd(p_character_id text, p_equipment_id text, p_equipado boolean)` | não | `24b8cfdf093132ca790d8a812062ba3e` |
| `public.equipar_item_srd_maos(p_character_id text, p_equipment_id text, p_hand_slot text, p_equipado boolean)` | não | `1dff75c9b58f0d7292eaacf14ffcc23c` |
| `public.equipar_item_token_srd(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_equipado boolean)` | sim | `435102caf1d2ab433659d3b936b09076` |
| `public.equipar_item_token_srd_maos(p_campaign_id bigint, p_token_id text, p_equipment_id text, p_hand_slot text, p_equipado boolean)` | não | `49cd550a45214d52283c521cb7d5443f` |
| `public.excluir_ficha_propria(p_character_id text)` | sim | `5b92922b463a2730b51bae3bbbdfccbe` |
| `public.finalizar_criacao_personagem_srd(p_nome text, p_raca_id text, p_classe_id text, p_atributos jsonb, p_pericias jsonb, p_talentos jsonb, p_identidade jsonb, p_idiomas jsonb, p_talentos_bonus jsonb, p_domain_ids text[], p_grimorio jsonb, p_equipamento_metodo text, p_equipamento_resultados jsonb, p_equipamento_itens jsonb)` | não | `a074c97eff6040bfcf52860c639b5adf` |
| `public.finalizar_equipamento_inicial_srd(p_character_id text, p_metodo text, p_resultados jsonb, p_itens jsonb)` | sim | `e2db338d772849b7407be69cfc20038e` |
| `public.finalizar_exclusao_campanha_propria(p_campaign_id bigint)` | não | `c1cb706b29564565456efb3748a9da5c` |
| `public.forget_spell(p_char bigint, p_spell bigint)` | sim | `9790a0da9d13f7d892144f112ec83593` |
| `public.gm_get_code(cid bigint)` | sim | `d6e810d2ddb5cc115b86bb08883d668f` |
| `public.gm_grant(cid bigint, p_char bigint, p_ouro integer, p_xp integer, p_item text, p_qtd integer)` | sim | `1951e9f08271e6876fa223152dcf289c` |
| `public.gm_kick(cid bigint, p_user uuid)` | sim | `5cbe0a9946deda8466e76d702f83d9a3` |
| `public.gm_reopen_sheet(p_char bigint, p_motivo text)` | sim | `c35a5060e4f416fb16439b5c144d07fb` |
| `public.gm_set_bonus(p_char bigint, p_ca integer, p_rm integer, p_motivo text)` | sim | `6de89ef54a61b9d4ba68eb1d87f6664f` |
| `public.gm_set_code(cid bigint, p_code text)` | sim | `42cb1dc3b2dc7ecb35c5fed53a086795` |
| `public.gm_set_role(cid bigint, p_username text, p_role text)` | sim | `27771cc4378c12fcb67bf8618c540df1` |
| `public.gm_transfer(cid bigint, p_username text, p_confirmar boolean)` | sim | `04cc93a42b514f4ab2144014d26017a0` |
| `public.handle_new_user()` | sim | `874c39364da7ce44a6c9c59605f31be2` |
| `public.hex_cost(cid bigint, x1 integer, y1 integer, x2 integer, y2 integer)` | não | `81054cb8b81909961b655d249893ccdf` |
| `public.hex_dist(x1 integer, y1 integer, x2 integer, y2 integer)` | não | `c3edfba2423d0c558bd9c699937133dc` |
| `public.iniciar_ataque_iterativo_npc_srd(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)` | não | `ac2506f26eb55a67a0e21c91394e86b8` |
| `public.iniciar_ataque_iterativo_npc_srd(p_campaign_id bigint, p_actor_token_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)` | não | `7bc116e726532efc7fdbc46e3f6742d4` |
| `public.iniciar_iniciativa(p_campaign_id bigint, p_expected_character_ids text[])` | sim | `e23893ad49c180f4ddcd116808ee8d63` |
| `public.iniciar_iniciativa_com_dados(p_campaign_id bigint, p_expected_character_ids text[], p_request_id text, p_gm_d20_results jsonb)` | sim | `9ed52a747bf33094cc06a8681083fea5` |
| `public.iniciar_iniciativa_com_pedido(p_campaign_id bigint, p_expected_character_ids text[], p_request_id text)` | sim | `ddc82d3342763ddaa89a76e7934a0091` |
| `public.iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid)` | não | `aa5043d145215889468b27574f80b8de` |
| `public.iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)` | não | `aeffb61732df3f699697596838b57b9e` |
| `public.iniciar_sequencia_ataque_iterativo_srd(p_campaign_id bigint, p_character_id text, p_target_token_id text, p_attack_type text, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text, p_power_attack_penalty integer)` | não | `cb10193efe478b4c5fdfa1aa7b55898c` |
| `public.join_campaign(p_code text)` | sim | `8eb12c73a0f2653db49fde0daa120a3a` |
| `public.learn_abilities_for_level(p_char bigint, p_nivel integer)` | sim | `909c61e7c8d73adbb28b38762675d99d` |
| `public.learn_spell(p_char bigint, p_spell bigint)` | sim | `ef4a1b000cf8192f669a17c0b66da7d0` |
| `public.leave_campaign(cid bigint)` | sim | `aa718dac694cfdcefc05a196e871816d` |
| `public.level_from_xp(p_xp integer)` | não | `3172d0c52044246144f40eef5af49dcf` |
| `public.limpar_ficha_srd_ao_excluir_personagem()` | sim | `ff615e9ca3b70f154d9b72ab9968732e` |
| `public.limpar_inventario_srd_ao_excluir_personagem()` | sim | `14c6bf441cc203a96ef7a7f58884a071` |
| `public.lobby_list()` | sim | `83d85d8cc7c5c26103637bb7b616d287` |
| `public.lobby_list_v2()` | sim | `d07db5d1d5d0164ab4119e674f63a2b4` |
| `public.long_rest(p_char bigint)` | sim | `769ef21dd6e6f99885db3b037defac89` |
| `public.media_gc(cid bigint)` | sim | `1c6ea8fbe4b111b83fcc2d3a2aa242ec` |
| `public.move_token(p_token bigint, p_x integer, p_y integer)` | sim | `06f5c09550398466015139fd6b21c5bf` |
| `public.mover_combatente_iniciativa(p_campaign_id bigint, p_indice integer, p_direcao integer)` | sim | `1e9428072cb0ef03e7d5b4b8ab5388c8` |
| `public.mover_token_gm_cba_srd(p_campaign_id bigint, p_token_id text, p_grid_x integer, p_grid_y integer)` | não | `619b7aaed96360106dda7734cbf6852c` |
| `public.mover_token_player_cba(p_campaign_id bigint, p_character_id text, p_grid_x integer, p_grid_y integer)` | não | `32c03431cff459e5d305f3be1c9f181c` |
| `public.my_role(cid bigint)` | sim | `ad46ae87c5e92aadf03bf74e90c80892` |
| `public.nivel_de_xp(p_xp integer)` | não | `f7b3fe3e6ae7ce4bf0555df23cc98f37` |
| `public.preparar_exclusao_campanha_propria(p_campaign_id bigint)` | não | `a156d9b8826118aad88ea44dd72258bd` |
| `public.registrar_iniciativa(p_campaign_id bigint, p_personagem_id text, p_nome text, p_valor integer)` | sim | `286f08346c5f55ebf03d754fac7992e2` |
| `public.registrar_iniciativa_d20(p_campaign_id bigint, p_personagem_id text, p_d20 integer)` | sim | `ccbdedd091fc77fa7e0b49705a69b812` |
| `public.registrar_rolagem_ataque_iterativo_npc_srd(p_campaign_id bigint, p_sequence_id uuid, p_manual_d20 integer, p_idempotency_key uuid)` | não | `84679cee812ef05ce00900d4520cd982` |
| `public.registrar_rolagem_ataque_iterativo_srd(p_campaign_id bigint, p_sequence_id uuid, p_manual_d20 integer, p_idempotency_key uuid)` | sim | `e17a07f3da16e67bf478e0613a95c2f7` |
| `public.remove_condition(p_char bigint, p_condition text)` | sim | `17045028c7fec08cd46d60ac1b33dbb0` |
| `public.repor_magias_srd(p_character_id text)` | sim | `0511d09c559a3e03b6b932893f32074d` |
| `public.resolver_ataque_iterativo_npc_srd(p_campaign_id bigint, p_attempt_id uuid)` | não | `6a340406f93b6bc3d268ad22f01bd21c` |
| `public.resolver_ataque_iterativo_srd(p_campaign_id bigint, p_attempt_id uuid)` | sim | `80cefcc1fbbb3321e90d8f40d1d840d9` |
| `public.roll_death_save(p_char bigint)` | sim | `dacc622b94bf6346e67c5d3a3d086652` |
| `public.roll_dice(p_expr text, p_visibilidade text)` | sim | `fa9baff3fa14cf30d52fef9a3e040a22` |
| `public.salvar_cena_cba(p_campaign_id bigint, p_scene jsonb)` | sim | `038e93166a1d4f0cb3dfe2f4597f812f` |
| `public.salvar_dominios_personagem_srd(p_character_id text, p_domain_ids text[])` | sim | `c063d9d2fdc95c46fd9b9e18d4a690f1` |
| `public.salvar_grimorio_srd(p_character_id text, p_estado jsonb)` | sim | `e8a2ea1719dea2ed1d0503f73f933bb6` |
| `public.salvar_idiomas_personagem_srd(p_character_id text, p_idiomas jsonb)` | sim | `87fdccf7582885794bef33bb580c72d3` |
| `public.salvar_pericias_srd(p_character_id text, p_pericias jsonb)` | sim | `87684c934ae569d1c568ddfd03687e87` |
| `public.salvar_talentos_bonus_classe_inicial_srd(p_character_id text, p_talentos jsonb)` | sim | `046aba71de91ef0ff7f24a2e72a8e44b` |
| `public.salvar_talentos_srd(p_character_id text, p_talentos jsonb)` | sim | `a669afef9d36046d1ebbc76cf51f6ea2` |
| `public.save_sheet(p_char bigint, p_dados jsonb, p_motivo text)` | sim | `0ac2ec0ef078c9d73a3f41c5596b0cd4` |
| `public.scene_config(cid bigint, p_state text, p_cols integer, p_rows integer)` | sim | `68a518319805c691ead1fbbcdcff0128` |
| `public.sell_price(p_item text)` | não | `2157398af12facc238fef7f890968452` |
| `public.send_chat(cid bigint, p_texto text, p_visibilidade text)` | sim | `28ba16e49db074f27d60c425229c7f1c` |
| `public.sentar_personagem_na_mesa(p_campaign_id bigint, p_character_id text)` | sim | `48d4187a1777360fea452ae40dd6fbf5` |
| `public.set_turn(cid bigint, p_token bigint)` | não | `5fd2c90bf9f7d42ba75e3ba949492eca` |
| `public.short_rest(p_char bigint)` | sim | `130863c2b10364813fd53e7aafa87a14` |
| `public.sou_membro(cid bigint)` | sim | `1d1d97a4bb8e6febfe2e9b2e8511a306` |
| `public.spell_dc(p_int integer, p_circulo integer)` | não | `bdaf9a7269ea903a893b61ed16ae7128` |
| `public.srd35_deslocamento_personagem(p_character_id text, p_base_speed_m numeric)` | sim | `e6abacac8d4f3369ce44de022f9cdb3d` |
| `public.srd35_equipment_ca_bonus(p_equipment_id text)` | não | `b33c165a2ecd3d7abe3eeda82f86c3e5` |
| `public.srd35_equipment_slot(p_categoria text, p_nome text)` | não | `06f4d9a9407d31036014170f35d0b1f0` |
| `public.srd35_normalizar_parametro_talento(p_text text)` | não | `a7fffd03d50d63a603b855f9353ad2c0` |
| `public.srd_aplicar_dano_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)` | sim | `e2673e828af60a967204f327bd6e3f28` |
| `public.srd_aplicar_dano_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_damage_rolls integer[], p_idempotency_key uuid)` | sim | `7a2e372249a04ccb3230aaec95ed89ef` |
| `public.srd_apply_campaign_condition(p_campaign_id bigint, p_target_kind text, p_target_id text, p_condition_id text, p_duration_rounds integer, p_notes jsonb)` | sim | `e43a03b0aaa226cb06e57cee90d5a38c` |
| `public.srd_apply_campaign_effect(p_campaign_id bigint, p_target_kind text, p_target_id text, p_effect_kind text, p_effect_data jsonb, p_duration_rounds integer, p_source_spell_id text, p_concentration_actor_id text)` | sim | `c0fae0b658c47fbf8d294d2e9c5029c6` |
| `public.srd_apply_toughness_hp_delta()` | não | `ff0642e5806f9289dfa8ccd88b8a478e` |
| `public.srd_calcular_ca_personagem_srd(p_campaign_id bigint, p_character_id text, p_attack_context text)` | sim | `ad8845bc79f6a3e6cf2e558837d3ec16` |
| `public.srd_calcular_ca_personagem_srd(p_campaign_id bigint, p_character_id text, p_attack_context text, p_attacker_is_giant boolean)` | sim | `40df6d8e89e8a61954a3c46b20ce3565` |
| `public.srd_cancelar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)` | não | `2a9aa9d725069c8b19f7afab96f3b17a` |
| `public.srd_configurar_perfil_combate_token_srd(p_campaign_id bigint, p_token_id text, p_combat_faction text, p_melee_reach_ft integer)` | sim | `ec877948308177f5e51e3637ccc14f46` |
| `public.srd_configurar_rodada_surpresa_srd(p_campaign_id bigint, p_aware_ids text[])` | sim | `4626e9470b45cca1cb459bdb5faaee20` |
| `public.srd_confirmar_critico_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_confirmation_d20 integer)` | sim | `84f2806567a32d263acaa9a820b1696c` |
| `public.srd_consultar_armas_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)` | sim | `c7270f541fe8293592d933cf9ed753a3` |
| `public.srd_consultar_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)` | sim | `f1ddcca1cda00b5b060045fab96d21f5` |
| `public.srd_consultar_modificadores_manobra_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_maneuver text, p_defender_firm_ground boolean)` | sim | `955be6d7459179774dc96004e7f23150` |
| `public.srd_consultar_modificadores_manobra_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_maneuver text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)` | não | `e7fbf72fa0ff1a4e84536b3985356761` |
| `public.srd_consultar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)` | sim | `b3e6ea933e228678ee6dd6f1aca089e5` |
| `public.srd_detectar_saida_alcance_ameacado_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer)` | sim | `5419d26aad112ced391acf4efd4abc31` |
| `public.srd_effective_modifier(p_campaign_id bigint, p_target_kind text, p_target_id text, p_stat text)` | sim | `ef864fdb5ef32b6f1dd5933a1f1ae10b` |
| `public.srd_encerrar_reacao_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_cancel_attack boolean)` | não | `0c1cd6771a68caf6d49e69af7dd45978` |
| `public.srd_expire_campaign_conditions(p_campaign_id bigint)` | sim | `06818c3884181ebda40174bf03316d1b` |
| `public.srd_finalizar_movimento_aoo_pendente_srd(p_campaign_id bigint, p_pending_id uuid)` | sim | `17fb9a9259675bf9d1c2278135ff2394` |
| `public.srd_iniciar_ataque_oportunidade_desarmado_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)` | sim | `b891864a3d8c80653feeafb54d9a4dfe` |
| `public.srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid)` | sim | `44c3145a7e5dc696e5e5643fb0a6b1ce` |
| `public.srd_iniciar_ataque_oportunidade_monstro_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_natural_attack_index integer)` | sim | `b12188da9c009734f31a553849756ccf` |
| `public.srd_iniciar_ataque_oportunidade_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text, p_reaction_id uuid, p_weapon_instance_id uuid, p_weapon_hand_slot text, p_weapon_end text)` | sim | `a641aab6e59793b2bf5b09cc290746db` |
| `public.srd_iniciar_derrubar_com_aoo_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_defender_firm_ground boolean, p_trip_using_weapon boolean)` | não | `bfced6e0a1cec2ec606ff65dc64e9a2c` |
| `public.srd_iniciar_encontrao_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text)` | não | `d51052f16d953d7f2bd5d94783188022` |
| `public.srd_iniciar_levantar_caido_srd(p_campaign_id bigint, p_token_id text)` | não | `39ce3fd3b7ae13cb92d2d77f1038a1b7` |
| `public.srd_listar_ataques_naturais_oportunidade_srd(p_campaign_id bigint, p_reactor_token_id text)` | não | `f9399cd730c4cfea4c66706207d2ffea` |
| `public.srd_listar_movimentos_aoo_pendentes_srd(p_campaign_id bigint)` | sim | `5ab451a12deb204eea23de23bca1d8cf` |
| `public.srd_registrar_ocultacao_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d100 integer)` | não | `a2b55e84b7c44ed4b1b703254c4cc229` |
| `public.srd_registrar_rolagem_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid, p_manual_d20 integer, p_idempotency_key uuid)` | sim | `950703066647366f6336bffb82e7f7d4` |
| `public.srd_remove_campaign_condition(p_campaign_id bigint, p_target_kind text, p_target_id text, p_condition_id text)` | sim | `8746eea5bb8b3c86e2ef9f63285a2589` |
| `public.srd_remove_campaign_effect(p_campaign_id bigint, p_effect_instance_id bigint)` | sim | `97c2a2e5017d89511a8adb5fb8027d51` |
| `public.srd_reservar_ataque_oportunidade_srd(p_campaign_id bigint, p_actor_token_id text, p_trigger_key text, p_actor_flat_footed boolean)` | não | `55f3d2fded1997d551aea8f163409603` |
| `public.srd_reservar_reacao_movimento_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_reactor_token_id text)` | não | `c72562f95bbe3da5134f29a383011e77` |
| `public.srd_resolve_confusion_turn_srd(p_campaign_id bigint, p_target_kind text, p_target_id text, p_request_id uuid, p_manual_d100 integer)` | não | `d79f056372807ffb2edddb491c0a158f` |
| `public.srd_resolve_dying_round(p_campaign_id bigint, p_character_id text, p_d100 integer)` | sim | `98025fdbfd01a93f8526ff9d91797849` |
| `public.srd_resolve_npc_dying_round(p_campaign_id bigint, p_token_id text, p_d100 integer)` | sim | `59527cd47f6bb98ff391fc0753b6edbd` |
| `public.srd_resolve_pending_spell_resistance(p_pending_id uuid, p_d20 integer)` | sim | `1f14474ea3149934ae266ae9c359a1e6` |
| `public.srd_resolve_pending_spell_save(p_pending_id uuid, p_d20 integer)` | sim | `23b9c7d3261fb26f833f31a8347e70da` |
| `public.srd_resolve_requested_saving_throw_srd(p_campaign_id bigint, p_character_id text, p_request_id text, p_d20 integer)` | sim | `ad7715ce88f4b96057e3af2ec14d41f5` |
| `public.srd_resolver_ataque_oportunidade_srd(p_campaign_id bigint, p_attack_id uuid)` | sim | `80a04e98b926307fe74bcbc34c963e7f` |
| `public.srd_resolver_derrubar_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_defender_firm_ground boolean)` | não | `14034f46a624a140d274163c2da73e37` |
| `public.srd_resolver_derrubar_srd(p_campaign_id bigint, p_attacker_token_id text, p_defender_token_id text, p_attacker_d20 integer, p_defender_d20 integer, p_defender_uses_dex boolean, p_defender_firm_ground boolean, p_trip_using_weapon boolean)` | não | `3917e0860a15eb566aa1219c90df43a3` |
| `public.srd_resolver_encontrao_srd(p_campaign_id bigint, p_pending_id uuid, p_attacker_d20 integer, p_defender_d20 integer, p_follow boolean)` | não | `0c64b3fd8ec53b3c56e4d5c3ce87ede3` |
| `public.srd_resolver_levantar_caido_apos_aoo_srd(p_campaign_id bigint, p_pending_id uuid)` | não | `a43d163405b49ee3ca459241c0177a43` |
| `public.srd_resolver_teste_resistencia_token_srd(p_campaign_id bigint, p_token_id text, p_save_type text, p_context text, p_d20 integer, p_dc integer)` | sim | `27fce17667eac7b2e7c718f8442fa292` |
| `public.srd_solicitar_movimento_com_aoo_srd(p_campaign_id bigint, p_mover_token_id text, p_destination_x integer, p_destination_y integer, p_controller text)` | sim | `38c1ffad22be8fe01381770a2bdb06b3` |
| `public.srd_validar_uso_pericia_srd(p_character_id text, p_skill_id text)` | sim | `24569605397c98f983150ddab87ba47f` |
| `public.start_combat(cid bigint)` | sim | `2ffafaab8cd0cfd3aec54b9520056cf6` |
| `public.usar_furia_barbaro_npc_srd(p_campaign_id bigint, p_token_id text, p_action text)` | sim | `0ae3b0a69028727bc44d47892a6fa59c` |
| `public.usar_furia_barbaro_srd(p_character_id text, p_action text)` | sim | `493254f0dd26cd36b45b6ed9331ad7b2` |
| `public.usar_habilidade_classe_srd(p_character_id text, p_feature_key text, p_target_token_key text, p_amount integer)` | sim | `10168e67e07af3f204fa409b9af67cc6` |
| `public.usar_imposicao_maos_mortos_vivos_srd(p_character_id text, p_target_token_key text, p_d20 integer, p_amount integer)` | sim | `2c23baa69395acac6d0205737a6a5b97` |
| `public.usar_pocao_cura_srd(p_character_id text, p_equipment_id text)` | sim | `cf65407d5aef905d896acec1a74d7766` |
| `public.usar_pocao_cura_srd_manual(p_character_id text, p_equipment_id text, p_roll_results integer[])` | sim | `dbd9067f3679f7d4fde3848984cdf3f2` |
| `public.xp_to_next(p_xp integer)` | não | `6b60d41df087e30bcab7e0d9b7f3cd3b` |

## Limitações e próximos passos

1. Exportar definitions completas de funções em lotes e preservar ACL, owner, search_path e comentários.
2. Exportar policies, grants, triggers, constraints, views, sequences, tipos/domínios e defaults.
3. Comparar os objetos do snapshot com os arquivos de migration versionados e com os 285 nomes remotos sem arquivo local de mesmo nome.
4. Construir baseline reproduzível em branch/ambiente descartável; não reconstruir produção.
