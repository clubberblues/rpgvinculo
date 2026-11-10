# Contrato de acesso ao Storage do CBA

Status: **proposta de implementação; não aplicada ao Supabase de produção**.

## Estado confirmado no snapshot

Bucket `mesa-media`:
- Privado, limite de 50 MiB, sem objetos no snapshot.
- Quatro policies para `authenticated`: SELECT (`mesa_media_ler`), INSERT (`mesa_media_enviar`), UPDATE (`mesa_media_trocar`) e DELETE (`mesa_media_apagar`).
- INSERT, UPDATE e DELETE chamam `priv.pasta_gm(name)`.
- SELECT chama `public.can_read_media(name)`.
- `priv.pasta_gm` lê `storage.foldername(name)[1]` e só aceita esse segmento se numérico. Para o path real `campaigns/{id}/...`, o primeiro segmento é `campaigns` e o segundo é o ID. Portanto, o predicado retorna false.
- `public.can_read_media` exige linha em `public.media` com `path = p_path`, além de GM ou camada visível. `public.media` e `public.layers` estão vazias; não existe trigger em `storage.objects` que preencha `public.media`.
- O frontend de `mesa.html` usa `campaigns/{MESA_ID}/...`, chama `upload(..., {upsert:false})` e depois `createSignedUrl(..., 86400)`. O mapa e o retrato não inserem metadados em `public.media`.
- O contrato de leitura atual, portanto, não autoriza os assets CBA no caminho utilizado. O contrato de escrita também os rejeita. O bucket vazio é compatível com essa falha.

## Path canônico

Aceitar somente caminhos relativos com esta forma:

```
campaigns/{campaign_id}/{asset_type}/{filename}
```

Para mapas de fundo, manter o formato legado atualmente usado pelo frontend, `campaigns/{id}/cba-...`, até uma migração de nomes coordenada. Para retratos, `campaigns/{id}/tokens/...`.

O parser deve:
1. usar regex ancorada no início (`^campaigns/([0-9]+)/`);
2. validar que o ID extraído é uma campanha existente;
3. rejeitar path nulo, vazio, sem arquivo, segmentos vazios, `.`, `..`, barras invertidas e prefixos alternativos;
4. nunca converter para bigint antes de confirmar a regex;
5. não aceitar IDs numéricos como primeiro segmento para esse bucket.

## Matriz de autorização proposta

| Ação | Mestre/GM da campanha | Jogador membro | Usuário externo |
|---|---:|---:|---:|
| Listar assets da campanha | Sim | Conforme visibilidade do CBA | Não |
| Ler/criar signed URL de asset publicado | Sim | Sim, se membro autorizado | Não |
| Upload | Sim | Não | Não |
| Update/upsert | Sim, se habilitado | Não | Não |
| Delete via Storage API | Sim | Não | Não |

A autorização de leitura deve usar `public.members(campaign_id,user_id,role)` ou a relação canônica de associação efetivamente usada pelo lobby. Não deve depender de `public.media`/camadas, pois esses assets são estado CBA armazenado no JSONB da campanha, não itens da galeria antiga.

O dono da campanha precisa ser autorizado explicitamente (via `campaigns.owner_id`) ou por uma invariável de banco comprovada que sempre mantenha o dono em `members` com papel GM. Não presumir essa invariável sem consulta de integridade.

## Exclusão pendente

- INSERT/UPDATE: negar quando existir `priv.campaign_deletion_cleanup` para a campanha.
- DELETE: permitir ao proprietário/GM autorizado enquanto o marcador existir, para que a limpeza possa continuar.
- SELECT: definir se leitura continua permitida durante o cleanup; a opção mais segura é negar novas leituras após o marcador, sem afetar a remoção.
- Finalizador: após bloquear campanha e marcador na ordem aprovada e revalidar o proprietário, exigir zero objetos nos dois buckets em `campaigns/{id}/` e zero capas correspondentes em `midia/capas_mesas/mesa-{id}-`. Se existir qualquer objeto, lançar erro e preservar campanha + marcador.
- O finalizador deve ser seguro para retry e tratar explicitamente campanha já removida, sem criar falso sucesso para um marcador pertencente a outro usuário.

## URLs assinadas

O frontend usa TTL de 86.400 segundos e cache de 23 horas. URLs assinadas são bearer tokens: remoção de membro não revoga uma URL já emitida. Antes de reduzir o TTL, revisar todos os pontos que renovam URL e o comportamento de mapas/retratos para jogador, mestre, reconexão e abas abertas. Não reduzir isoladamente, pois pode quebrar imagens após expiração.

## Testes de integração obrigatórios

Os testes devem usar Storage API real e usuários separados (owner/GM, player, externo), sem depender apenas de SQL sintético:

1. GM faz upload de mapa e retrato no path canônico.
2. GM cria signed URL e lê ambos.
3. Jogador membro cria signed URL e lê asset publicado.
4. Jogador não consegue upload, upsert, update nem delete.
5. Usuário externo não consegue listar, ler, assinar, uploadar, atualizar nem remover.
6. Caminhos malformados, IDs de campanha inexistentes e prefixos de outra campanha são negados.
7. Durante cleanup, upload/upsert são negados; remoção pelo GM continua autorizada.
8. Finalizador falha se restar qualquer objeto em qualquer bucket/prefixo, mantendo campanha e marcador.
9. Após Storage API remover todos os objetos e capas, finalizador conclui.
10. Teste concorrente de upload versus finalização demonstra que não há objeto criado depois da verificação final.
11. Verificar que UPDATE tem policy SELECT compatível, porque Storage upsert exige INSERT + SELECT + UPDATE; o frontend atual usa `upsert:false`, mas a policy não deve ser ampliada sem necessidade.
12. Confirmar que signed URLs expiram no TTL e que o cliente renova antes de expirar, inclusive após reload e troca de aba.

## Dependências antes de migration

- Reconciliar os 41 arquivos locais sem registro remoto, os 326 registros remotos sem arquivo local e os nomes duplicados/divergentes em `docs/MIGRATION_RECONCILIATION.md`.
- Confirmar as policies e grants atuais no projeto de produção imediatamente antes da migration.
- Gerar migration via fluxo Supabase CLI suportado e validar em banco descartável primeiro.
- Rodar advisors, testes Storage/RLS e fixtures de exclusão.
- Não alterar o projeto de produção até que a migration e o plano de rollback estejam revisados.



## Retenção e falhas intermediárias no upload

Auditoria adicional dos callsites de `mesa.html`:
- Mapa e retrato são enviados primeiro ao Storage, depois recebem signed URL e, por fim, a referência é persistida em `campaigns.cba_data`.
- Se a criação da signed URL falhar depois do upload, o arquivo novo ficava sem referência. Foi adicionada compensação `descartarUploadPrivadoCBA(path)` para tentar remover esse objeto nos dois fluxos.
- A compensação usa Storage API `remove`, registra aviso se a remoção falhar e preserva o erro original. No estado atual, a policy DELETE também chama `priv.pasta_gm` e rejeita o path `campaigns/{id}/...`; portanto, a compensação só poderá ser confirmada depois da correção de policy e de um teste Storage real.
- Se o RPC de gravação da cena falhar depois do upload, não removemos automaticamente o arquivo: falha de rede pode deixar o resultado da transação ambíguo, e remover pode quebrar uma referência que tenha sido persistida. Esse caso precisa de GC compensatório com janela de retenção e verificação do JSONB atual.
- Substituir mapa ou retrato também deixa o arquivo anterior sem referência. Não foi adicionada remoção imediata: duas abas podem manter snapshots diferentes, e uma aba antiga ainda pode persistir referência ao asset anterior. A solução correta é GC atrasado que varre referências atuais de `backgroundPath` e `tokens[].imagemPath`, respeita uma janela de segurança e só então remove via Storage API.
- A compensação cobre somente falha de signed URL anterior à gravação da cena; não é transação distribuída e não substitui GC de assets órfãos.


## Finalizador remoto — falhas confirmadas no snapshot atual

Leitura direta das definições instaladas em PostgreSQL, sem executar as RPCs:

- Wrapper public.preparar_exclusao_campanha_propria(bigint) (OID 24881) e implementação priv.preparar_exclusao_campanha_propria(bigint) (OID 24885) são executáveis por authenticated, não por anon.
- A preparação bloqueia primeiro a linha de public.campaigns (FOR UPDATE) e depois insere/atualiza priv.campaign_deletion_cleanup.
- Wrapper public.finalizar_exclusao_campanha_propria(bigint) (OID 24882) e implementação priv.finalizar_exclusao_campanha_propria(bigint) (OID 24886) também são executáveis por authenticated, não por anon.
- O finalizador bloqueia primeiro o marcador de cleanup (FOR UPDATE) e depois a campanha (FOR UPDATE), invertendo a ordem da preparação. Isso mantém uma janela de deadlock entre chamadas concorrentes de preparação/finalização.
- O finalizador atual não consulta storage.objects, não verifica prefixos nos buckets midia/mesa-media e não exige que capas tenham sido removidas. Depois de uma preparação válida, o proprietário pode chamar a RPC diretamente sem executar a limpeza do navegador; a campanha e o marcador podem ser excluídos enquanto objetos continuam no Storage.
- A resposta deleted: true não prova que os objetos foram removidos. O estado de Storage é independente da transação PostgreSQL e precisa de verificação explícita antes da exclusão definitiva.

Esses pontos foram confirmados por leitura de pg_get_functiondef e has_function_privilege no projeto remoto. Não foram feitas chamadas às RPCs nem alterações de banco. A correção proposta neste documento deve resolver conjuntamente: ordem campaign → cleanup nos dois caminhos, revalidação pós-lock, verificação server-side dos objetos restantes e retry seguro. A limpeza feita apenas pelo navegador não pode ser tratada como pré-condição confiável para o finalizador.
