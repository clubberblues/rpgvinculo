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


## Serialização contra uploads concorrentes — requisito de implementação

A simples verificação de que não existe marcador de cleanup dentro da policy não fecha a corrida. O helper atual priv.can_write_midia consulta campanhas e o marcador sem bloquear a campanha. Um upload pode passar pela policy antes de a preparação inserir o marcador e confirmar a linha em storage.objects depois da listagem/limpeza do navegador.

Contrato de lock recomendado para o novo helper de escrita de assets de campanha (proposta, não implementada):

1. Extrair e validar campaign_id do path.
2. Obter a linha da campanha com SELECT ... FOR KEY SHARE (helper VOLATILE, SECURITY DEFINER com search_path fixo), validar owner/GM e manter o lock até o commit da transação Storage.
3. Só então verificar ausência do marcador de cleanup e autorizar INSERT/UPDATE.
4. Fazer preparação e finalização adquirirem campaign FOR UPDATE antes do lock do marcador. FOR UPDATE conflita com FOR KEY SHARE: se o upload começou primeiro, a preparação aguarda o commit e depois cria o marcador; se a preparação começou primeiro, o upload aguarda e então observa o marcador e é negado.
5. O finalizador, após campaign FOR UPDATE e lock/revalidação do marcador, verifica zero objetos. Assim nenhum upload autorizado pode atravessar a verificação final; deletes concorrentes apenas reduzem o conjunto e, se ainda estiverem visíveis, causam falha segura/retry.

Aplicar o mesmo princípio a todos os prefixes de campanha graváveis, inclusive capas no bucket midia e assets CBA no bucket mesa-media. Não bloquear somente a campanha no finalizador: o lock correspondente no caminho de INSERT/UPDATE é a outra metade da garantia. Validar o comportamento com duas sessões reais e Storage API, porque fixture SQL isolada não reproduz o ciclo completo do serviço Storage.


## Fixture sintético do lock de upload

O harness descartável agora modela a garantia de serialização com duas interleavings: (a) upload adquire campaign KEY SHARE antes da preparação, então a preparação aguarda o commit do upload antes de inserir o marcador; (b) preparação adquire campaign FOR UPDATE e grava o marcador antes, então o upload aguarda e é rejeitado ao reler o marcador. O modelo usa uma função PL/pgSQL VOLATILE e uma tabela de objetos fictícia. Ele valida a compatibilidade dos locks PostgreSQL, mas não executa policy RLS, Storage API, upload binário ou finalizador Supabase real; integração autenticada continua obrigatória.


## Fixture sintético do finalizador e retry

O harness descartável agora inclui uma implementação-modelo que bloqueia campanha primeiro, revalida proprietário e marcador, consulta se ainda existem objetos no Storage fictício e só então remove marcador/campanha. O teste verifica três resultados: usuário diferente do proprietário é rejeitado; Storage não vazio impede finalização e preserva campanha + marcador para retry; após remoção dos objetos, nova tentativa conclui. O modelo não chama Storage API nem substitui a validação da função remota; apenas fixa o contrato transacional esperado.


## Algoritmo transacional proposto para o finalizador

A função remota atual foi relida integralmente. Ela bloqueia o marcador primeiro, depois a campanha; se a campanha já não existir, ainda remove o marcador e retorna `deleted: true`. O algoritmo proposto substitui esse comportamento sem fazer limpeza Storage dentro da transação PostgreSQL:

1. Exigir `auth.uid()` não nulo e validar `p_campaign_id`.
2. Tentar localizar a campanha por PK com `FOR UPDATE`. Se existir, validar `campaigns.owner_id = auth.uid()` antes de continuar. Isso estabelece o primeiro lock e serializa com uploads que mantenham `FOR KEY SHARE` na mesma linha.
3. Bloquear o marcador `priv.campaign_deletion_cleanup` com `FOR UPDATE`; exigir que exista e que `owner_id = auth.uid()`. Se não houver campanha, o marcador ainda deve ser validado, mas nenhum novo upload pode ser autorizado porque o registro de campanha não existe.
4. Consultar `storage.objects` e recusar (exceção, sem apagar marcador) se existir qualquer objeto em: bucket `midia`, prefixo `campaigns/{id}/`; bucket `mesa-media`, prefixo `campaigns/{id}/`; ou bucket `midia`, prefixo `capas_mesas/mesa-{id}-`. Comparar prefixos ancorados com `left(name, char_length(prefix)) = prefix`, sem wildcard de usuário.
5. Somente com zero objetos, excluir a campanha se ainda existir e excluir o marcador do proprietário. Retornar sucesso apenas após essas verificações; a transação torna as duas exclusões atômicas.
6. Se campanha ausente e marcador válido, a mesma checagem zero-object decide idempotência: zero objetos permite remover marcador residual e retornar sucesso; qualquer objeto mantém marcador e exige investigação/limpeza. Nunca retornar sucesso apenas porque a campanha está ausente.

A checagem deve usar os nomes reais de buckets/prefixos e o mesmo contrato de lock adotado pelas policies de INSERT/UPDATE. O helper de escrita deve ser VOLATILE e adquirir `FOR KEY SHARE` até o commit da transação Storage. Validar essa retenção do lock com uploads reais concorrentes antes de confiar na garantia. A função finalizadora continua SECURITY DEFINER apenas se estritamente necessário para consultar Storage e apagar estado protegido; manter `search_path` fixo, referências qualificadas, verificação explícita de `auth.uid()` e EXECUTE somente para authenticated.


A fixture foi refinada para reproduzir duas características reais do esquema: `priv.campaign_deletion_cleanup` não possui FK para `public.campaigns`, e objetos de Storage não têm FK transacional com a campanha. Isso permite testar o estado de marcador residual e objeto órfão após a linha da campanha desaparecer. O teste agora exige que a tentativa idempotente também recuse sucesso se ainda existir objeto órfão, preservando o marcador até a limpeza.