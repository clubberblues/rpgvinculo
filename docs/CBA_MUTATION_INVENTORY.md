# Inventário de mutações CBA e autoridade durante combate

Data da coleta: 2026-11-09. Fonte: definições SQL remotas, ACLs efetivas e call sites de `mesa.html`. Todas as consultas foram read-only. Este documento descreve o estado observado, não uma migration.

## Matriz de contratos observados

| Operação/RPC | Papel/ACL observado | O que grava | Pending AOO | Geometria/autoridade |
|---|---|---|---|---|
| `public.salvar_cena_cba` | SECURITY DEFINER; EXECUTE authenticated; exige GM | Substitui metadados de cena e objetos dos tokens recebidos em `campaigns.cba_data` | Não consulta pending | Não valida mudança de coordenadas, footprint, ocupação, identidade duplicada nem versão; snapshot obsoleto pode reverter PV/posição |
| `public.adicionar_token_cba` | SECURITY DEFINER; sem EXECUTE direto para authenticated; exige GM | Insere token na cena | Não consulta pending | Bloqueia ID/key duplicado e tenta célula livre, mas compara apenas origem `gridX/gridY`; não valida footprint completo |
| `public.adicionar_token_cba_completo` | SECURITY DEFINER; EXECUTE authenticated; autentica e delega ao RPC acima | Insere token e acrescenta dados de NPC/monstro | Não consulta pending | Herda validação espacial apenas de origem; não congela spawn durante pending |
| `public.mover_token_player_cba` → `priv.mover_token_player_cba_impl` | Wrapper INVOKER; EXECUTE authenticated; implementação valida dono, turno e regras de movimento | Atualiza posição e uso de movimento | Não chama detector nem consulta pending global | RPC direto contorna pré-check AOO; implementação usa footprint 5 para Colossal |
| `public.mover_token_gm_cba_srd` → `priv.mover_token_gm_cba_srd_impl` | Wrapper INVOKER; EXECUTE authenticated; implementação valida GM/turno | Atualiza posição e uso de movimento | Não chama detector nem consulta pending global | RPC direto contorna pré-check AOO; implementação usa footprint 5 para Colossal |
| `public.srd_solicitar_movimento_com_aoo_srd` | SECURITY DEFINER; EXECUTE authenticated; valida player/GM, token e turno | Cria registro em `priv.srd_aoo_pending_movements`; não move | Verifica pending somente depois de detectar nova ameaça | Lock da campanha protege somente esta transação; retorno `pending=false` não vincula a próxima chamada de movimento |
| `public.srd_finalizar_movimento_aoo_pendente_srd` | SECURITY DEFINER; EXECUTE authenticated; valida GM/solicitante e estado da fila | Autoriza commit do movimento depois das reações | Pending `FOR UPDATE`, depois campanha `FOR UPDATE` | Valida round/turn/origem; usa GUC transacional e trigger de preview para chamar o RPC de movimento |
| `priv.srd_guard_pending_aoo_movement` (trigger) | SECURITY DEFINER; trigger BEFORE UPDATE de `campaigns.cba_data` | Protege o token da pending | Lê pending ativo | Bloqueia remoção/alteração de coordenadas apenas do mover; não protege outros tokens, spawn, facção/alcance ou PV |
| `public.alterar_pv_token_cba` | SECURITY DEFINER; EXECUTE authenticated; exige GM | Atualiza PV de NPC/monstro e sincroniza NPC vinculado | Não consulta pending | Não altera coordenadas; mutação de estado durante pending requer política explícita |
| `public.srd_configurar_perfil_combate_token_srd` | SECURITY DEFINER; EXECUTE authenticated; exige GM | Atualiza facção e alcance corpo a corpo | Não consulta pending | Pode mudar quais tokens ameaçam a área durante a resolução |
| `public.adicionar_combatente_iniciativa` | SECURITY DEFINER; EXECUTE authenticated; exige GM | Atualiza `combat_data.turn_order` | Não consulta pending | Preserva ator atual, mas pode alterar a ordem durante a reação |

**Observação:** EXECUTE authenticated indica privilégio efetivo consultado; não significa que qualquer membro possa executar com sucesso. As guardas internas ainda precisam ser respeitadas. A matriz descreve o contrato do corpo, não a experiência visual do frontend.

## Geometria de tokens

- `priv.srd_token_grid_footprint` retorna Colossal = 6 e possui 10 consumidores diretos atuais, concentrados em manobras, confusão, levantar e iniciadores AOO.
- `public.srd_detectar_saida_alcance_ameacado_srd` não chama o helper: duplica a classificação em três CASEs, atualmente também corretos para Colossal = 6.
- `priv.mover_token_player_cba_impl`, `priv.mover_token_gm_cba_srd_impl`, as duas sobrecargas de `public.aplicar_dano_token_ataque_srd_v2` e `public.usar_imposicao_maos_mortos_vivos_srd` usam 5 para Colossal.
- `public.adicionar_token_cba` compara somente a célula de origem, não os quadrados do footprint.

## Concorrência e versão

- `public.campaigns` possui `cba_data` e `combat_data` JSONB, mas não coluna dedicada de versão/revisão.
- `cba_data.version = 1` identifica formato, não revisão monotônica.
- `FOR UPDATE` em `salvar_cena_cba` serializa gravações, mas não impede lost update quando o payload já chega obsoleto.
- O índice parcial `srd_aoo_one_pending_movement_per_campaign` garante no máximo uma pending ativa por campanha.
- O trigger de pending protege somente coordenadas/remoção do token mover; não congela a geometria de toda a cena.

## Call sites observados em `mesa.html`

| Linha | Intenção de `gravarCBAnaCampanha` |
|---:|---|
| 2294 | Atualizar retrato/imagem de token |
| 3626 | Persistir `spellState` |
| 4974 | Criar NPC/arquetipo durante combate |
| 5116 | Persistir modificadores de iniciativa de reforço |
| 5431 | Fallback de movimento fora de combate |
| 5468 | Publicar fundo/mapa/grade |
| 6154 | Preparar modificadores antes de iniciar iniciativa |
| 6633 | Hidratar/enriquecer dados de monstros |

A fila `cbaWriteQueue` serializa somente chamadas do mesmo cliente; não coordena com RPCs de combate nem outros clientes.

## Prioridade de correção

1. Tornar os RPCs de movimento a autoridade única e integrar detecção AOO + pending global + commit na mesma transação.
2. Separar publicação de metadados, spawn/remoção e metadados de token do writer genérico.
3. Impedir snapshots obsoletos de sobrescrever PV/posição/equipamentos; usar comandos parciais ou revisão gerada no servidor.
4. Congelar alterações estruturais/facção/alcance/iniciativa durante pending, exceto ações internas da resolução AOO.
5. Centralizar footprint em helper único para detector, movimento, spawn, ataques e habilidades.
6. Aplicar política de footprint completo e ocupação para spawn de tokens Grandes até Colossais.
7. Corrigir inversão de locks pending → attack versus attack → pending com ordem única validada por matriz transitiva.

## Testes e limites

O workflow `.github/workflows/postgres-fixture-tests.yml` usa PostgreSQL 17 efêmero em runner padrão do repositório público. A primeira fixture valida somente o helper de footprint e passou em 2026-11-09. Ela não valida RPCs Supabase, Auth, PostgREST, RLS, Realtime nem os call sites ainda divergentes. Regressões de movimento, cena genérica, spawn, footprint e locks estão listadas em `TEST_STRATEGY.md`.

**Nenhuma função, migration, ACL, policy ou dado de campanha foi alterado no Supabase remoto.**
