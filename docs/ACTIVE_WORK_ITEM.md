## Atualização consolidada — 2026-11-09 (continuidade 2)

- Run [42673548023](https://github.com/clubberblues/rpgvinculo/actions/runs/42673548023) concluiu **success** para o commit `502b47bc28b61ed7ed5c3dab181fee62c9f433ec`.
- Commit atual `81c2bb72f4eb46f86d499eb02274a0dbe34eed61` adiciona cenário sintético campanha ↔ recurso de classe; run [42678898017](https://github.com/clubberblues/rpgvinculo/actions/runs/42678898017) está em execução, ainda sem resultado final.
- Auditoria remota read-only encontrou também inversão potencial campanha → ficha (resolução de magia pendente) versus ficha → campanha (conjuração multialvo). Cenário sintético correspondente adicionado nesta atualização.
- A combinação recurso de classe ↔ campanha permanece condicionada à confirmação de alcance simultâneo dos entrypoints; no snapshot atual, os 3 tokens NPC vinculados têm source characters com `campaign_id IS NULL`.
- Nenhuma função, migration, ACL, policy ou dado foi alterado no Supabase remoto; TESTE 2 permaneceu intocado.



## Continuidade — próxima unidade de trabalho

- HEAD observado no início desta unidade: `a1172927027160f5f69adc2e6f9da30af12cb92e`.
- Run PostgreSQL isolado [42679102920](https://github.com/clubberblues/rpgvinculo/actions/runs/42679102920): `success`, com oito padrões sintéticos. Não executa RPCs reais.
- Nova revisão read-only de funções transitivas de magia, efeitos, condições e `end_combat` identificou que o encerramento de combate bloqueia ataques AOO antes das pendências e percorre efeitos de Fúria antes do lock final da campanha. Ambos os caminhos reforçam as inversões já inventariadas; não são prova de deadlock reproduzido.
- Helpers de aplicação de efeitos/condições bloqueiam campanha primeiro; helper de vitalidade de personagem atualiza condições sem bloquear campanha. Helper de sincronização de NPC vinculado bloqueia campanha antes da ficha.
- Próxima ação: construir fixtures de PostgreSQL mais próximas dos helpers reais (condição vital, sync NPC, end-combat AOO/Fúria), depois cobrir wrappers de conjuração. Continuar sem alterar Supabase remoto e sem testar campanhas reais.


## Continuidade — rastreamento de Fúria e encerramento (2026-11-09)

- HEAD auditado: `68f0e679f02061543243c04d33d3fb451c8eef72`.
- Revisão read-only por OID confirmou ordem composta de Fúria: `end_combat` percorre efeito → ficha/condições e só atualiza campanha ao final; a trigger de avanço de rodada parte de campanha bloqueada e depois bloqueia efeitos.
- O mesmo `end_combat` atualiza ataques AOO antes de pendências, reforçando inversão attack ↔ pending.
- Acrescentado caso sintético específico effect → sheet → campaign versus campaign → effect no harness; ele não executa RPCs Supabase.
- Nenhuma função/migration/ACL/policy/dado remoto foi alterado; TESTE 2 permanece intocado.
- Próxima frente: aprofundar os caminhos de condição vital e encerramento AOO com fixtures que copiem os efeitos transacionais relevantes; depois mapear os writers de condição e log por OID. Manter migration/deploy remoto bloqueados até reconciliação.


## Continuidade — escritores de condições e locks herdados (2026-11-09)

- Varredura read-only por OID dos escritores de `srd_campaign_conditions` e `campaign_log` separou helpers que bloqueiam campanha daqueles que dependem do lock herdado.
- Achado para revisão: `public.srd_remove_campaign_condition` (OID 24806) é SECURITY DEFINER e executável por authenticated; valida GM, mas atualiza condição sem `campaigns FOR UPDATE`. Busca textual direta em `mesa.html` não encontrou uso; não presumir que esteja ativo.
- `priv.srd_clear_combat_flatfooted_all` é chamado tanto por `alternar_estado_campanha` (campanha já bloqueada) quanto por `end_combat` (antes do UPDATE final de campanha). A diferença do chamador precisa constar no grafo.
- Nenhum grant/policy/função remota foi alterado. Próxima etapa: rastrear callers dos writers de condição e validar contratos/ACL.


## Resultado consolidado — fixture composta de Fúria (2026-11-09)

- Commit de teste: `fb261e66a14bb5fed9a35976ea394afaddafb160`.
- Run [42714600496](https://github.com/clubberblues/rpgvinculo/actions/runs/42714600496): **success**.
- Confirmado nos logs: fixture de footprint aprovada e nove padrões sintéticos de inversão de lock aprovados, incluindo effect → sheet → campaign versus campaign → effect.
- O HEAD atual após a documentação subsequente é `e5068ce7414e51a07b1c77ba406a31115ffd6d3f`; a atualização de documentação não altera a cobertura executada pelo run.
- Limite: nenhum endpoint/trigger remoto foi executado; não houve mutação Supabase nem acesso a TESTE 2.
