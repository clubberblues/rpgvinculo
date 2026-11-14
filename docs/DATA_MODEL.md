> **Escopo ativo (13/11/2026):** D&D 3.5 é a única fonte de regras e fichas em desenvolvimento. Relações `vinculo_*` são legado de compatibilidade/histórico, sem novas escritas ou funcionalidades; não são fonte normativa.

# Vínculo RPG — Modelo de dados e fontes canônicas

> Fotografia somente de leitura de 2026-11-08. Este documento distingue dados ativos, estruturas de compatibilidade e estruturas sem consumidores encontrados. Não é autorização para remover ou migrar tabelas.

## 1. Identidade e regras de personagem

```mermaid
erDiagram
  campaigns {
    bigint id PK
    jsonb cba_data
    jsonb combat_data
  }
  campaigns ||--o{ members : contains
  campaigns ||--o{ characters : hosts
  characters ||--o| srd_character_sheets : has
  characters ||--o| vinculo_character_sheets : legacy
  characters ||--o{ srd_character_class_levels : progresses
  characters ||--o{ srd_character_domain_choices : chooses
  campaigns ||--o{ campaign_log : records
```

- `characters` é a identidade/posse do personagem e seu vínculo opcional à campanha.
- `campaigns` é o agregado de sessão/campanha.
- `members` registra papel por campanha e usuário.
- `srd_character_sheets` é a ficha D&D 3.5 vinculada a `characters`.
- `vinculo_character_sheets` é uma ficha legada preservada para compatibilidade; não integra o fluxo ativo D&D 3.5.
- O vínculo entre characters e cada ficha específica é por `character_id`; as tabelas de ficha usam chave única/primária e FK para characters. Equipamento e instâncias de arma usam `character_id` text sem FK; são referências lógicas, não relações garantidas pelo banco.
- `characters.campaign_id` pode ser NULL. Isso permite fichas-modelo do Mestre/NPCs que são vinculadas a tokens CBA sem serem personagens de jogador associados diretamente à campanha.
- A restrição única em (campaign_id,user_id) representa atualmente um personagem principal por usuário/campanha. O impacto disso em múltiplos personagens por jogador deve ser uma decisão explícita de produto.

## 2. Fontes de estado da mesa

| Informação | Fonte atual observada | Compatibilidade/legado |
|---|---|---|
| Cena, mapa e tokens CBA | `campaigns.cba_data` JSONB | `scenes`, `tokens`, `monster_instances` |
| Combate, turno e ordem | `campaigns.combat_data` JSONB | `combat_state` |
| Chat e eventos | `campaign_log` | `roll_log` e `roll_requests` |
| Rolagem 3D | `dice.html` via iframe/postMessage | RPC `roll_dice` gera dados no servidor e não é chamado pelas páginas ativas |
| Condições e efeitos de campanha | `srd_campaign_conditions`, `srd_campaign_effects` | resolvers aceitam também alvos do modelo relacional `tokens` |

Contagens observadas: campaigns=3, scenes=3, tokens=0, monster_instances=0, combat_state=0, roll_requests=0, roll_log=0 e campaign_log=70. `create_campaign` ainda insere uma linha em `scenes`, mas a mesa atual não consulta essa tabela diretamente na varredura.

**Decisão provisória:** o caminho ativo é CBA JSONB + campaign_log + Dice iframe. As estruturas relacionais antigas permanecem até confirmar todos os consumidores externos e concluir plano de migração.

## 3. Dados D&D 3.5

### Fontes ativas identificadas

| Domínio | Fonte/estrutura | Uso observado |
|---|---|---|
| Atributos e identidade | `srd_character_sheets.atributos`, `identidade` (JSONB) | ficha, cálculos e requisitos |
| Perícias | `srd_character_sheets.pericias` (JSONB) | salvar/validar graduações e resolver testes |
| Talentos | `srd_character_sheets.talentos` (JSONB) | validar e aplicar modificadores |
| Progressão de classe | `srd_character_class_levels` | BBA, níveis por classe, características e cálculos |
| Domínios | `srd_character_domain_choices` | escolha e acesso a magias de domínio |
| Equipamento | `srd_character_equipment` | inventário equipado, CA, proficiência e armas |
| Instâncias de armas | `srd_character_weapon_instances` | mão, empunhadura e ataques iterativos |
| Recursos de classe | `srd_character_feature_resources` | usos de Fúria e outras habilidades |
| Estado de magia | `srd_character_sheets.magias_preparadas` (JSONB versionado) | conhecidas, preparadas e usos; lido/escrito por salvar_grimorio_srd e resolvers |
| Grimório de progressão | `srd_character_spellbook` | consultado pelo núcleo de avanço de nível |

Contagens observadas: 5 fichas SRD; 5 linhas em class_levels; 42 itens de personagem; 6 instâncias de arma; 0 linhas em domain_choices, feature_resources, spellbook, known_spells, prepared_spells, spell_slot_state e token equipment.

### Estruturas sem uso atual encontrado

A varredura das definições de funções e do frontend não encontrou referências a:
- `srd_character_known_spells`
- `srd_character_prepared_spells`
- `srd_character_spell_slot_state`
- `srd_character_sheets.magias_conhecidas`
- `srd_character_sheets.pericias_treinadas`

`srd_character_spellbook` aparece no núcleo de avanço de nível, mas não tem linhas no snapshot. Essas estruturas podem representar uma tentativa de normalização incompleta ou um contrato reservado a uma fase futura. Não as tratar como fonte canônica nem remover sem procurar clientes externos, migrations e integrações.

### Campos duplicados/espelhados

- `characters.xp` é usado para determinar XP e nível disponível; `conceder_xp_personagem_srd` atualiza também `srd_character_sheets.xp`. O espelhamento deve ser mantido por todas as rotas ativas.
- RPCs antigas como `gm_grant` atualizam `characters.xp/ouro` sem sincronizar explicitamente a ficha SRD; não conectá-las ao fluxo SRD sem revisão.
- O ouro existe em mais de uma estrutura entre o modelo base, SRD e Vínculo; a fonte canônica por ruleset precisa ser explicitada antes de ampliar fluxos de concessão.

## 4. Vínculo RPG

Há código legado de ficha que usa estruturas antigas (`vinculo_character_sheets`, `inventory`, `character_spells`, `character_talents`, catálogos `items`, `spells`, `talents`). Esse ramo não deve ser reativado nem ampliado; o fluxo ativo usa estruturas `srd_*`.

As tabelas `vinculo_*` são legado isolado. Compartilham apenas a infraestrutura histórica; não devem alimentar regras, progressões, catálogos ou fichas ativas D&D 3.5.

## 5. Integridade referencial a melhorar

- `srd_character_equipment.character_id` e `srd_character_weapon_instances.character_id` são text, sem FK para `characters.id` bigint. No snapshot, as 42 linhas de equipamento e 6 de instância de arma correspondiam a personagens existentes.
- `srd_cba_token_equipment.token_id` e tabelas CBA relacionadas usam identificadores text; não presumir equivalência direta com `tokens.id` bigint.
- Condições/efeitos têm alvos polimórficos character/token e precisam de validação de identidade/campanha nos resolvers.
- Não alterar tipos, adicionar FKs ou remover campos antes de mapear consumidores, fazer backfill, testar e planejar rollback.

## 6. Próximas decisões do modelo

1. Formalizar a fonte canônica de cada campo de ficha e regra.
2. Decidir se known/prepared spells/slot state serão normalizados ou se o JSONB versionado permanece como fonte canônica.
3. Reconciliar o uso de `scenes`, `tokens`, `monster_instances`, `combat_state`, `roll_requests` e `roll_log`.
4. Definir política de sincronização de XP, ouro, PV/PM e atributos derivados.
5. Planejar integridade FK para equipment/weapon instances, sem migração até validar todos os consumidores.

## Referências
- [Arquitetura](ARCHITECTURE.md)
- [Mapa de integração](INTEGRATION_MAP.md)
- [Inventário de RPCs](RPC_INVENTORY.md)
- [Registro de auditorias](AUDIT_REGISTER.md)


## Estado observado dos dados de personagens — 2026-11-09
Consulta agregada somente de leitura: 5 personagens no total; 5 com registro srd_character_sheets; 0 sem ficha SRD; 0 com registro vinculo_character_sheets. Isso confirma que o caminho ativo de personagens é D&D 3.5. O código legado e as tabelas `vinculo_*` permanecem apenas para preservação/compatibilidade, sem novas funcionalidades ou uso como fonte de regras.


## Decisão de fonte canônica — XP e ouro SRD (2026-11-11)

Consulta read-only ao schema e aos caminhos ativos do D&D 3.5:

- **XP:** `public.characters.xp` é a fonte canônica do total de XP e do cálculo de nível disponível. A RPC ativa `public.conceder_xp_personagem_srd` atualiza esse campo e espelha o mesmo total em `public.srd_character_sheets.xp`; a ficha SRD mantém o espelho para leitura local/compatibilidade. O fluxo de criação inicializa ambos em zero. Não usar o XP da ficha como autoridade independente nem atualizar somente um dos dois campos.
- **Ouro SRD:** `public.srd_character_sheets.ouro` é a fonte canônica, pois é NUMERIC e preserva frações de peça de ouro. `public.characters.ouro` é INTEGER e, no fluxo ativo de equipamento inicial SRD, recebe `FLOOR(ouro_restante)`; portanto, é apenas um espelho inteiro de compatibilidade e não pode sobrescrever o saldo SRD preciso.
- Evidência do caminho: `finalizar_equipamento_inicial_srd` grava o saldo exato em `srd_character_sheets.ouro` e o piso inteiro em `characters.ouro`. `srd35_deslocamento_personagem` consulta o ouro da ficha SRD ao calcular peso transportado. O endpoint legado `gm_grant` altera `characters.ouro/xp` e tabelas de inventário do domínio legado; não foi encontrado call site para ele em `mesa.html` no HEAD auditado. Não conectá-lo automaticamente ao fluxo SRD.
- Fotografia agregada do banco em 2026-11-11: 5 personagens com ficha SRD; XP de characters e ficha coincidem em 5/5; ouro diverge em 5/5, com total de 288 inteiros em characters e 292,50 em fichas SRD. A diferença observada é compatível com a perda de frações no espelho inteiro, mas não se deve corrigir registros existentes por inferência.
- **PV, PM e valores derivados:** continuam sem uma regra global única declarada. Alguns são persistidos na ficha/token e sincronizados por resolvers/triggers; outros são calculados por funções. Cada campo ainda precisa de contrato próprio (fonte, fórmula, cache, invalidação e direção de sincronização). Não generalizar a decisão de XP/ouro para esses campos.

Esta decisão é arquitetural para o domínio SRD; não altera dados, RPCs, migrations nem o domínio Vínculo. Antes de qualquer migração futura, validar todos os leitores e escritores do saldo SRD e criar teste de regressão para frações de ouro.


## Progressão de classe e multiclasse — lacuna de contrato (2026-11-11)

A tabela `srd_character_class_levels` comporta linhas por personagem/classe e deve representar o nível em cada classe; `srd_character_sheets.nivel` representa o nível total do personagem. No snapshot agregado atual, 5/5 fichas têm ledger e a soma dos níveis por classe coincide com o nível total; todas as 5 linhas observadas são nível 1, portanto isso não valida progressão multiclasse.

A implementação instalada de avanço ainda não oferece contrato multiclasse:
- `public.concluir_avanco_nivel_personagem_srd_v2` não recebe a classe escolhida para o novo nível.
- `priv.concluir_avanco_nivel_personagem_srd` lê sempre `srd_character_sheets.classe_id`, calcula o avanço usando `sheet.nivel + 1` como nível da classe e faz upsert somente dessa classe.
- O upsert registra `taken_at_character_level=1` na primeira linha, em vez do nível total em que a classe foi adquirida.

Consequência: o ledger atual não implementa corretamente a escolha de classe a cada nível exigida pelo D&D 3.5 multiclasse, nem preserva o nível de personagem em que cada classe foi adquirida. Não criar workaround no frontend. O contrato futuro deve distinguir nível total, nível por classe, classe escolhida no avanço, pré-requisitos de classe/prestígio, BBA/salvamentos por progressão e características por nível; validar a ordem de níveis e a retroatividade aplicável conforme as regras. Não há evidência de dano a personagens existentes no snapshot atual, que contém somente níveis iniciais de uma classe.


## Estado de magias — JSONB ativo e dependência órfã de grimório (2026-11-11)

- O caminho ativo observado de ficha salva o estado de magias conhecidas, preparadas, usos e espaços de domínio em `srd_character_sheets.magias_preparadas` (JSONB versionado), por meio de `salvar_grimorio_srd`. Manter esse JSONB como fonte operacional atual até existir migração completa e testada.
- As tabelas normalizadas `srd_character_known_spells`, `srd_character_prepared_spells` e `srd_character_spell_slot_state` estão vazias no snapshot e não foram encontradas em corpos de funções consultados; não tratá-las como fontes ativas nem preencher em paralelo sem contrato de migração.
- `srd_character_spellbook` também está vazia. A implementação de avanço de nível consulta essa tabela para validar as magias escolhidas no talento Maestria em Magia, mas `salvar_grimorio_srd` grava o JSONB da ficha e não popula o spellbook. A busca de funções encontrou apenas a leitura no avanço; não foi identificado writer ativo para essa tabela. Portanto, a seleção de Maestria em Magia tem uma dependência sem caminho de preenchimento demonstrado e deve ser corrigida antes de considerar o talento integrado.
- Decisão futura: ou derivar/atualizar o grimório a partir do JSONB no mesmo fluxo transacional e validar os IDs conhecidos, ou remover a dependência do spellbook e validar diretamente contra o estado canônico; não manter duas fontes independentes.

Fotografia somente de leitura em 2026-11-11: zero linhas nas quatro tabelas normalizadas/grimório citadas. Nenhuma tabela, ficha ou magia foi alterada.
