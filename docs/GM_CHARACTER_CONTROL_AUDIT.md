# Auditoria — controle temporário de personagens pelo Mestre

**Data:** 2026-11-13  
**Decisão de produto:** DEC-005 em `docs/DECISIONS.md`  
**Status:** lacuna confirmada; não declarar concluído.

## Contrato aprovado

O jogador mantém a propriedade da ficha. O Mestre pode assumir temporariamente o controle operacional de qualquer personagem durante combate, incluindo rolagens e ações, sem transferir propriedade nem alterar o vínculo do personagem. O Mestre também pode controlar tokens de NPCs/monstros e conceder controle temporário a jogadores.

## Evidência no código ativo

Leitura das chamadas RPC em `mesa.html` e `ficha.html` encontrou 93 nomes distintos. A inspeção do banco remoto encontrou funções de ação que ainda exigem `characters.user_id = auth.uid()` sem exceção explícita para GM.

### Ações que precisam de exceção GM

| RPC | Fluxo | Evidência/risco |
|---|---|---|
| `consumir_acao_turno_srd` | Economia de ações | Exige personagem associado ao usuário autenticado e membro PLAYER; GM não passa pela validação atual |
| `conjurar_magia_com_acao_srd_manual` | Conjuração de alvo único | Busca personagem por `user_id = auth.uid()` |
| `conjurar_magia_com_acao_srd_multialvo_v3` | Conjuração multialvo | Busca personagem por `user_id = auth.uid()` |
| `conjurar_magia_dano_multialvo_srd` | Aplicação de dano de magia | Exige personagem do usuário |
| `usar_habilidade_classe_srd` | Habilidade de classe | Busca ficha/personagem pelo proprietário autenticado |
| `usar_imposicao_maos_mortos_vivos_srd` | Habilidade de classe | Busca personagem pelo proprietário autenticado |
| `usar_pocao_cura_srd_manual` | Consumível | Fluxo atual exige proprietário |
| `conjurar_missil_magico_srd_manual` | Magia/rolagem manual | Fluxo atual exige proprietário |
| `srd_resolve_requested_saving_throw_srd` | Teste de resistência solicitado | Resolução atual vinculada ao usuário dono do personagem |
| `descanso_longo_personagem_srd` | Descanso longo SRD | Migration candidata `20261112170000` permite Mestre da campanha sem transferir propriedade; fixture GM/dono/outro jogador/externo adicionada. Ainda não aplicada ao remoto |

Os quatro primeiros RPCs de ação que também retornam `cba_data/combat_data` foram incluídos na migration candidata `20261112160000` para filtragem de resposta. **A filtragem do JSON não altera autorização:** continuam precisando da exceção de controle do Mestre.

| `aplicar_dano_token_ataque_srd_v2` (duas sobrecargas) | Ataque SRD de personagem | Exige personagem jogador pertencente ao usuário autenticado; Mestre não passa pela checagem atual |
| `iniciar_sequencia_ataque_iterativo_srd` | Iniciar ataque iterativo de PC | Wrapper encaminha à implementação privada; autorização da implementação precisa aceitar GM |
| `consultar_sequencia_ataque_iterativo_pendente_srd` | Consultar ataque pendente | Vincula sequência ao personagem/usuário; verificar exceção GM |
| `registrar_rolagem_ataque_iterativo_srd` | Registrar d20 manual de ataque | Validação de ator/usuário; verificar exceção GM |
| `resolver_ataque_iterativo_srd` | Resolver ataque | Validação de ator/usuário; verificar exceção GM |
| `confirmar_critico_ataque_iterativo_srd` | Confirmar crítico | Validação de ator/usuário; verificar exceção GM |
| `aplicar_dano_ataque_iterativo_srd` | Aplicar dano de ataque | Validação de ator/usuário; verificar exceção GM |
| `descanso_longo_personagem_srd` | Descanso longo SRD | Migration candidata `20261112170000` permite Mestre da campanha sem transferir propriedade; fixture GM/dono/outro jogador/externo adicionada. Ainda não aplicada ao remoto |

### Fluxos que já apresentam autorização de Mestre

A inspeção encontrou verificações de papel em funções como `usar_furia_barbaro_srd`, `srd_resolve_pending_spell_save`, `srd_resolve_dying_round`, `srd_solicitar_movimento_com_aoo_srd` e `srd_calcular_ca_personagem_srd`. O Mestre também possui RPCs próprios para movimentação e economia de ações genérica (`mover_token_gm_cba_srd`, `consumir_acao_token_gm_srd`).

Isso não prova que todo o painel de ações de personagem já funciona sob controle do Mestre.

## Regra de implementação

Criar uma autorização central de controle operacional, sem alterar a propriedade:

- Dono do personagem: permitido se continua membro PLAYER da campanha.
- Mestre da campanha: permitido para qualquer personagem da campanha.
- Outro jogador: negado para personagem alheio.
- Usuário externo: negado.
- Controle do Mestre não pode ignorar turno, requisitos D&D 3.5, recursos, limites de uso ou validações de alvo; apenas substitui a identidade de quem está executando a ação.

A autorização deve ser aplicada aos RPCs realmente chamados pela Mesa e à economia de ações. Não fazer substituições globais de `auth.uid()` sem classificar cada função.

## Testes obrigatórios

Para cada família de ação, executar fixture com quatro identidades:

1. Jogador dono: ação permitida.
2. Mestre da campanha: ação permitida em nome do jogador.
3. Outro jogador membro: ação negada.
4. Usuário externo: ação negada.

Verificar também que PV, recursos diários, slots de magia, condições, iniciativa e histórico continuam associados ao personagem original. Nenhum teste deve alterar a propriedade da ficha.

## Próxima execução

1. Mapear todos os RPCs usados pelo painel de personagem e classificar dono-only, GM-only e owner-or-GM.
2. Criar helper de autorização com `public.my_role(campaign_id)='GM'` e ownership do personagem.
3. Atualizar somente os RPCs de ação confirmados.
4. Adicionar fixtures owner/GM/other-player/outsider.
5. Validar fluxo completo na campanha descartável antes de deploy.

## Atualização de implementação — 2026-11-13

A migration candidata `20261112170000_allow_gm_controlled_character_rest.sql` modifica somente a autorização de `descanso_longo_personagem_srd`: dono continua permitido; Mestre com papel GM na campanha também pode administrar o descanso; outro jogador e usuário externo continuam negados. Nenhuma regra de recuperação, intervalo de 8 horas ou bloqueio durante combate é alterada.

Fixture `gm_character_long_rest_fixture.sql` adicionada ao workflow PostgreSQL para validar GM, dono, outro jogador e usuário externo. A migration não foi aplicada ao Supabase remoto.

### Iniciativa — regra preservada

`registrar_iniciativa_d20` exige papel PLAYER e propriedade da ficha. Isso permanece alinhado à decisão anterior de que jogadores rolam sua própria iniciativa; o Mestre rola NPCs/monstros pelo fluxo GM. O controle temporário de PC pelo Mestre começa após a iniciativa, salvo decisão futura explícita para jogadores desconectados antes do combate.

As RPCs de ataque de oportunidade (`srd_iniciar_ataque_oportunidade_*`, `srd_registrar_rolagem_ataque_oportunidade_srd`, `srd_resolver_ataque_oportunidade_srd`) já são GM-only, conforme o papel do Mestre nesse subsistema.
