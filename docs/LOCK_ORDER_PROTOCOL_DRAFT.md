# Protocolo global de locks — proposta para revisão

Status: **rascunho de arquitetura; não aprovado para implementação**  
Data: 2026-11-09  
Base: inspeção read-only dos corpos SQL remotos, triggers e writers de `campaigns`.

Este documento consolida uma direção candidata para eliminar inversões de locks. Não é migration, não altera o banco e não declara que todas as dependências transitivas foram mapeadas. A implementação fica bloqueada até reconciliação de migrations, revisão por assinatura/OID e testes em PostgreSQL efêmero.

## 1. Invariante principal

Para qualquer operação que altere estado de uma campanha, adquirir primeiro o lock da linha `public.campaigns` correspondente (`FOR UPDATE`), antes de bloquear personagens, fichas, recursos, efeitos, condições, inventário, armas, pendências, ataques ou logs relacionados.

Quando a campanha ainda não é conhecida, ler o `campaign_id` sem lock apenas para localizar o agregado; depois bloquear a campanha e revalidar, sob lock, que o personagem/token ainda pertence à campanha e que o chamador mantém autorização.

Uma transação não pode adquirir um lock de categoria anterior depois de já manter um lock de categoria posterior. Os triggers devem respeitar a ordem herdada do chamador e não criar caminhos reversos.

## 2. Ordem candidata dentro de uma campanha

A sequência abaixo é uma hipótese inicial, não uma ordem final validada:

1. `campaigns` — lock do agregado/serialização de combate e cena.
2. `characters` — todos os IDs necessários em ordem crescente e estável.
3. `srd_character_sheets` — mesma ordem estável de character_id.
4. `srd_character_feature_resources` — por character_id e feature_key.
5. `srd_character_equipment` — por character_id/equipment_id.
6. `srd_character_weapon_instances` — por character_id/instance_id.
7. `srd_campaign_effects` — por campaign_id/target_kind/target_id/effect_instance_id.
8. `srd_campaign_conditions` — por campaign_id/target_kind/target_id/condition_instance_id.
9. Estado pendente de ação: `priv.srd_aoo_pending_movements` e `priv.srd_pending_spell_resolutions`, com ordem determinística por pending_id quando houver mais de uma.
10. Registros de reação/ataque: `priv.srd_aoo_attacks`, `priv.srd_aoo_reaction_ledger`, `public.srd_attack_sequences`, `public.srd_attack_sequence_attempts`, `public.srd_npc_attack_sequences` e `public.srd_npc_attack_attempts`. A relação entre essas tabelas ainda precisa de revisão de todas as transições; ordenar por chave estável e não misturar a ordem entre wrappers.
11. `campaign_log` e demais registros append-only, ao final.

A posição relativa entre efeitos/condições, recursos/inventário e os diferentes ledgers ainda deve ser validada contra todos os triggers e funções. A lista não autoriza aplicar locks indiscriminadamente: cada endpoint deve bloquear apenas os registros necessários, mas sempre respeitar a ordem global.

## 3. Evidências que motivam a proposta

### Ciclos já identificados nos corpos remotos
- Campanha ↔ efeito de Fúria: trigger de avanço de rodada e expiração campaign-first; encerramentos manuais/legados podem bloquear efeito antes da campanha.
- Pending AOO ↔ ataque: cancelamento/encerramento bloqueia pending → attack; resolução/dano/ocultação bloqueia attack → pending.
- Campanha ↔ arma: início de sequência iterativa overload 7 bloqueia arma antes da campanha; resolução bloqueia campanha e depois pede `FOR SHARE` na instância.
- Campanha ↔ personagem/ficha: descanso longo de NPC vinculado bloqueia campanha → personagem → ficha; ações de classe e entrypoints de conjuração podem bloquear personagem → ficha → campanha.
- Efeitos, condições e PV: helpers de sincronização de condição não bloqueiam sempre campanha primeiro; a ordem depende do chamador.
- Inventário/arma: trigger AFTER INSERT/DELETE/UPDATE OF quantidade em `srd_character_equipment` cria/remove instâncias; operações de equipamento também alteram as duas tabelas e precisam ser harmonizadas.

### O que já passou em teste
O workflow PostgreSQL efêmero detectou deadlocks em três pares sintéticos:
- campaign → effect versus effect → campaign;
- campaign → weapon versus weapon → campaign;
- campaign → character versus character → campaign.

Execução: https://github.com/clubberblues/rpgvinculo/actions/runs/42670106095

Esses testes demonstram o comportamento do PostgreSQL para os padrões montados; não executam RPCs reais nem provam ocorrência em produção.

## 4. Regras de implementação que devem acompanhar a ordem

- **Revalidar após adquirir locks:** autorização, vínculo campanha/personagem, ownership, papel, estado de combate, turno, pending, equipamento e status precisam ser confirmados dentro da transação serializada.
- **Ordenar locks múltiplos:** ao afetar dois ou mais personagens/alvos, ordenar IDs de forma estável antes de `FOR UPDATE`; não depender da ordem do array JSON ou do frontend.
- **Wrappers finos:** wrappers públicos devem autenticar/validar a interface e delegar a uma implementação interna que siga o protocolo; não podem adquirir locks adicionais em ordem diferente antes da delegação.
- **Triggers previsíveis:** triggers não devem chamar RPCs que tentem adquirir lock de campanha depois de o chamador manter locks posteriores. Registrar explicitamente os locks transitivos de cada trigger.
- **JSONB da campanha:** mutações de `cba_data`/`combat_data` devem partir do registro lido sob lock; evitar substituir snapshots enviados pelo cliente. Preferir comandos parciais e validação de revisão.
- **Idempotência:** request_id/idempotency_key protege retries e duplicações; não substitui locks nem validação de estado.
- **Sem lock advisory isolado:** advisory lock não substitui o lock da linha `campaigns` enquanto existirem writers que não o adquirem. Só considerar se todos os pontos de entrada e triggers forem cobertos e o namespace/chave forem formalizados.
- **Operações fora de campanha:** fluxos de criação/edição de ficha sem campanha devem seguir ordem própria e não podem chamar helpers que tentem adquirir campanha depois de bloquear personagem/ficha. Se passarem a atuar em campanha, devem localizar e bloquear campanha antes dos locks da ficha.

## 5. Bloqueios antes de qualquer migration

1. Reconciliar as 966 versões remotas com os 681 arquivos locais; não reaplicar nem reconstruir histórico por inferência.
2. Construir mapa validado de chamadas por OID/assinatura para cada entrypoint, overload, helper e trigger; regex por nome serve apenas para descoberta.
3. Classificar todos os 52 escritores diretos de `campaigns` e os escritores de recursos/efeitos/condições/pendências/ataques/inventário.
4. Confirmar todos os caminhos usados por `mesa.html`, incluindo wrappers dinâmicos e RPCs legadas ainda concedidas.
5. Criar fixtures efêmeras que reproduzam os corpos ou módulos SQL extraídos, incluindo rollback, retries, duas sessões e efeitos colaterais de triggers.
6. Executar testes de autorização e integridade em ambientes descartáveis; Auth/RLS/PostgREST não devem ser considerados verificados por simples fixtures PostgreSQL.
7. Só então preparar migration reconciliada, revisar diff, testar reversão/compatibilidade e submeter para autorização específica antes de qualquer mutação remota.

## 6. Critério de aceite

A ordem só será considerada implementada quando:
- todos os entrypoints e overloads ativos respeitarem a mesma ordem;
- triggers e chamadas transitivas não introduzirem locks anteriores fora de ordem;
- testes concorrentes cobrirem Fúria, avanço/encerramento de combate, AOO, conjuração, recursos de classe, inventário, armas e ataques iterativos;
- duas sessões concorrentes não produzirem deadlock nos cenários previstos;
- retries forem idempotentes e nenhum PV, recurso, item, posição, condição ou estado de combate for perdido;
- testes de autorização confirmarem que nenhum ajuste de locks ampliou o acesso de jogadores/Mestres;
- migrations e estado remoto estiverem reconciliados.

**Decisão atual:** manter como proposta de arquitetura e continuar a auditoria. Nenhuma alteração no Supabase remoto está autorizada por este documento.
