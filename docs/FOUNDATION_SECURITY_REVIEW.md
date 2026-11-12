# Revisão da fundação — segurança, acesso e armazenamento

Data da leitura: 2026-11-11 (horário local do projeto). Projeto consultado: `grrgwxcagvvafdmzsmro`, PostgreSQL 17.6.1.166. Todas as consultas foram somente leitura.

## Estado estrutural observado

- 83 tabelas-base nos schemas `public`, `priv` e `private`; 81 com RLS habilitado e duas sem RLS: `priv.throttle` e `priv.srd_aoo_reaction_ledger`.
- 114 políticas RLS nos schemas consultados.
- O projeto está ativo/saudável no Supabase. A listagem de branches mostra somente a entrada `main` (não persistente, `with_data=false`); isso não fornece uma cópia restaurável do schema-base.
- Os dois objetos sem RLS não concedem SELECT/INSERT/UPDATE/DELETE diretamente a `anon` ou `authenticated` no ACL atual. O schema `priv` não concede USAGE a `anon`; concede a `authenticated`. Portanto, o alerta automático de exposição é mais amplo do que os privilégios efetivos observados nesta consulta. Ainda assim, manter tabelas internas sem RLS é uma fragilidade caso ACLs/schema exposure mudem.

## Privilégios padrão — correção arquitetural necessária

O catálogo `pg_default_acl` registra, para o owner `postgres`, os seguintes privilégios automáticos no schema `priv`:
- novas tabelas: todos os privilégios de tabela para `authenticated` e `service_role`;
- novas sequences: leitura/uso/atualização para `authenticated` e `service_role`;
- novas funções: EXECUTE para `authenticated` e `service_role`.

Isso é amplo demais para um schema interno. As funções e tabelas futuras de `priv` não deveriam se tornar acessíveis automaticamente a usuários autenticados. A correção proposta é revogar esses privilégios padrão para `authenticated` (e avaliar separadamente `service_role`), mantendo concessões explícitas e mínimas quando necessárias. **Não foi aplicada alteração**: a revisão transitiva dos chamadores e a execução de migration em ambiente descartável ainda são necessárias. A sessão não tem o Supabase CLI/repositório local montado para gerar a migration pelo fluxo oficial; não foi criado arquivo de migration manualmente.

## Funções privilegiadas

- O Security Advisor identifica 99 funções `SECURITY DEFINER` do schema `public` executáveis por `authenticated`; nenhuma função `SECURITY DEFINER` pública tem EXECUTE para `anon` no ACL consultado.
- O catálogo contém 150 funções `SECURITY DEFINER` públicas; todas têm `search_path` fixo e incluem `pg_temp`. 142 mencionam `auth.uid()`; as oito restantes incluem triggers, helpers e funções que delegam autorização a `priv.need_gm`/outras verificações. A presença de `auth.uid()` não prova, sozinha, que a autorização esteja correta; as RPCs de escrita continuam sujeitas à auditoria de autorização e concorrência já registrada.
- No schema `priv`, 39 funções `SECURITY DEFINER` têm EXECUTE para `authenticated`; uma função auxiliar, `priv.srd_feat_saving_throw_modifier`, também tem EXECUTE para `anon`. O role `anon` não tem USAGE no schema `priv`, e o Security Advisor não lista essas funções como RPCs REST; a exposição direta não foi demonstrada. Ainda assim, revogar privilégios padrão e revisar grants existentes é necessário antes de considerar a superfície interna fechada.
- O Security Advisor reporta 99 funções SECURITY DEFINER acessíveis a authenticated como aviso. Muitas são endpoints deliberados de aplicação; não revogar em massa, pois isso quebraria o cliente. Cada endpoint precisa ser classificado por necessidade, autenticação, autorização e validação pós-lock.

## RLS sem política

Sete tabelas têm RLS habilitado, mas nenhuma política:
- `priv.srd_aoo_attacks`
- `priv.srd_aoo_pending_movements`
- `public.srd_attack_sequence_attempts`
- `public.srd_attack_sequences`
- `public.srd_character_feature_resources`
- `public.srd_npc_attack_attempts`
- `public.srd_npc_attack_sequences`

Nenhuma concede privilégios diretos de tabela a `anon` ou `authenticated` no ACL consultado. O padrão atual é negar acesso direto; isso pode ser intencional para tabelas acessadas apenas por RPCs/owners. Não criar políticas genéricas: confirmar todos os call sites antes de conceder acesso direto.

## Storage e exposição pública

Buckets observados:
- `mesa-media`: privado, limite 50 MiB, allowlist de tipos de imagem/vídeo/áudio. Políticas de leitura/escrita exigem usuário autenticado e GM/membro autorizado; o frontend da mesa usa URLs assinadas para imagens de tokens e mapas. Nenhum objeto estava armazenado nesse bucket na fotografia.
- `midia`: público, sem limite/tipos restritos configurados. A política SELECT permite leitura pública; escrita/alteração/remoção autenticada é limitada por funções de caminho e propriedade.

O bucket público `midia` contém 135 imagens:
- 6 em `avatars/`;
- 33 em `campaigns/`;
- 12 em `capas_mesas/`;
- 21 em `headers/`;
- 53 em `retratos/`;
- 10 em outros caminhos.

O código atual usa `midia` para avatares, fotos de personagem, fundos de ficha e capas de mesa, retornando URLs públicas. A mesa usa `mesa-media` privado para imagens de tokens e ativos da cena. Uma das três campanhas atuais aponta sua capa para URL pública de `midia`. A tabela legada `public.media` está vazia; não há metadados de mídia para relacionar os 33 arquivos `campaigns/` com cenas atuais. Não presumir que todos esses objetos devam ser privados, nem torná-los públicos por padrão: classificar arquivos legados e atuais, preservar referências válidas e migrar mapas/ativos de campanha que não devam ser públicos antes de alterar o bucket.

## Configuração de autenticação

O Security Advisor informa que a proteção contra senhas comprometidas (HaveIBeenPwned) está desabilitada. A ferramenta disponível não permite ler/alterar essa opção de Auth. Deve ser revisada no Dashboard e habilitada após confirmar a política de senha desejada. Não foi alterada.

## Advisor e desempenho

- Security Advisor: sete avisos informativos de RLS sem política, 99 avisos de funções SECURITY DEFINER executáveis por authenticated e um aviso de proteção de senha comprometida desabilitada.
- Performance Advisor: 51 índices não utilizados no snapshot. Não remover índices sem janela de observação representativa e análise de carga; projeto pequeno e alguns fluxos raros podem ainda depender deles.
- Health Advisor: nenhum aviso.

## Aceite pendente da fundação

1. Recuperar um bootstrap/schema-only histórico confiável; o replay de 969 migrations em banco vazio falha na primeira migration porque `public.campaigns` não existe. Não fabricar tabelas-base.
2. Corrigir os privilégios padrão do schema interno `priv` por migration versionada, testada em ambiente descartável.
3. Classificar os grants existentes de funções `priv` e os 99 endpoints públicos SECURITY DEFINER sem revogação em massa.
4. Confirmar schemas expostos do PostgREST no Dashboard; `current_setting('pgrst.db_schemas', true)` retornou NULL, logo a allowlist não foi confirmada por SQL.
5. Revisar e habilitar proteção contra senhas comprometidas no Auth.
6. Classificar os 33 objetos públicos `campaigns/` e os demais ativos do bucket `midia`; definir quais são intencionalmente públicos e migrar os privados sem quebrar URLs.
7. Validar RLS e storage com sessões autenticadas de GM, jogador e usuário sem vínculo, além de testes de negação.
8. Completar o protocolo de locks, consistência dos escritores e testes de concorrência em ambiente descartável.
9. Recuperar ambiente local reproduzível e executar replay completo, testes de integração e fluxo ponta a ponta.

## Limites desta revisão

Nenhuma tabela, função, ACL, policy, configuração Auth, arquivo Storage, campanha, personagem, migration remota ou deploy foi alterado. Os resultados descrevem o estado observado e não provam que todos os caminhos de aplicação foram exercitados.


## Revisão direcionada das políticas das tabelas centrais

As políticas de `campaigns`, `members`, `characters`, `srd_character_sheets` e `srd_character_equipment` condicionam leitura/escrita a usuário dono, membro da campanha ou GM conforme a operação. A ficha SRD permite leitura e atualização direta ao dono/GM, mas os campos mecânicos do frontend consultado são salvos principalmente por RPCs; a política precisa ser mantida alinhada com os escritores server-side.

Foi encontrada uma exceção de legado em `public.tokens`: as políticas INSERT/UPDATE/DELETE permitem qualquer membro da campanha, sem exigir papel GM. A tabela estava vazia (zero linhas) e não foi encontrado call site direto em `mesa.html`, `ficha.html` ou `lobby.html` no branch auditado; a mesa atual mantém tokens em `campaigns.cba_data`. Tratar a política como legado dormente, mas restringir a GM antes de reativar ou inserir dados nessa tabela. Não alterar agora para evitar quebrar um fluxo não localizado.

O frontend atual atualiza diretamente `characters.retrato_url`, `characters.foto_transform` e `characters.header_bg_url`, protegidos por política de proprietário; atualiza `campaigns.capa_url`, protegida por política GM; consulta diretamente fichas/equipamentos. Não foi encontrado uso direto de `public.tokens` ou `public.scenes` nos três arquivos principais.


## Realtime e sincronização de mesa

A publicação `supabase_realtime` inclui as tabelas usadas pelas nove assinaturas encontradas em `mesa.html`: `campaign_log`, `campaigns`, `characters`, `members`, `srd_character_sheets`, `srd_character_equipment`, `srd_cba_token_equipment`, `srd_campaign_conditions` e `srd_campaign_effects`. A configuração está alinhada estaticamente com os canais de chat, participantes, fichas, equipamentos, condições, efeitos e campanha. A entrega real de eventos, filtros, isolamento por RLS e reconexão ainda não foi testada com duas sessões autenticadas simultâneas.

A publicação também contém tabelas legadas `tokens` e `vinculo_character_sheets`; a mesa atual mantém tokens em `campaigns.cba_data` e não usa diretamente a tabela `tokens` nos arquivos principais consultados. Remover essas tabelas da publicação exige confirmar que não há clientes antigos em uso.


## Integridade relacional e índices de FK

A leitura do catálogo encontrou 110 foreign keys nos schemas consultados, todas validadas; não foram encontradas constraints não validadas nem índices inválidos/inaptos. Três FKs não têm índice começando pelas colunas de referência no lado filho:
- `priv.srd_pending_spell_resolutions.condition_break_instance_id` → `srd_campaign_conditions.condition_instance_id`;
- `priv.srd_pending_spell_resolutions.condition_id` → `srd_conditions.condition_id`;
- `public.srd_npc_attack_sequences.campaign_id` → `campaigns.id`.

As tabelas correspondentes estavam vazias ou com volume muito baixo no snapshot. Registrar para avaliar junto aos 51 índices sinalizados como não utilizados e aos planos de consulta reais; não criar índices sem medir impacto/custo e incluir migration versionada.


## Schemas internos adicionais e verificações de autorização

O schema `private` também concede USAGE a `authenticated` (não a `anon`) e contém oito funções; seis têm EXECUTE para authenticated e nenhuma para anon. As seis são rotinas de equipamento para personagem/NPC/token, com `SECURITY DEFINER`, `search_path` fixo e verificações explícitas de `auth.uid()`/papel no corpo. As outras duas são triggers de sincronização sem EXECUTE direto para authenticated. Não há default ACL específico registrado para `private`. A exposição direta REST de `private` não foi confirmada; conferir a allowlist no Dashboard.

Na revisão lexical das 99 funções `SECURITY DEFINER` públicas executáveis por authenticated, 96 mencionam `auth.uid()`, 39 mencionam `my_role()` e cinco mencionam `priv.need_gm()` (categorias sobrepostas); todas têm pelo menos um desses marcadores. Isso é apenas triagem estática: não substitui revisão de autorização por função, validação de propriedade/campanha, nem teste negativo com usuário sem vínculo.


### Rascunho de endurecimento dos privilégios padrão (não aplicado)

Depois de validar que nenhum cliente precisa acessar diretamente objetos internos futuros, a migration de endurecimento deve incluir, no mínimo:

```sql
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  REVOKE ALL ON TABLES FROM authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  REVOKE ALL ON SEQUENCES FROM authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  REVOKE EXECUTE ON FUNCTIONS FROM authenticated;
```

Isso altera somente os privilégios padrão para objetos futuros criados pelo owner `postgres`; não revoga grants de objetos existentes. A migration deve ser criada com `supabase migration new`, testada contra um schema reproduzido e acompanhada de teste que prove que uma tabela/função recém-criada em `priv` não fica acessível diretamente a authenticated. Não executar no remoto antes dessa validação.


### Limites efetivos de upload — risco de abuso/custo

No bucket `midia`, `file_size_limit` e `allowed_mime_types` estão nulos. Os 135 objetos atuais são todos imagens (94 PNG, 22 JPEG, 19 WebP), totalizam aproximadamente 190,59 MiB; o maior tem 15,76 MiB. O frontend limita alguns fluxos por recorte, mas o upload de capa aceita `image/*` e envia o arquivo original sem limite de tamanho explícito. A política de Storage restringe caminho/proprietário, não tamanho ou MIME. Isso permite que um usuário autenticado autorizado no caminho envie arquivos muito grandes ou formatos não desejados, aumentando custo e superfície de conteúdo.

O bucket privado `mesa-media` define limite de 50 MiB e allowlist que inclui imagens, vídeo e áudio; os fluxos de upload encontrados na mesa aceitam apenas imagens e limitam a imagem do token a 20 MiB. O bucket estava vazio. Rever se vídeo/áudio são realmente necessários; se não, restringir MIME e tamanho ao uso real.

Plano recomendado: definir limite de tamanho compatível com capas/retratos (avaliar 20 MiB, pois o maior objeto atual tem 15,76 MiB), aceitar somente formatos raster realmente usados, validar também no cliente para UX e preservar leitura dos arquivos existentes. Não aplicar limite antes de confirmar se há mapas/arquivos maiores fora do bucket público.


## RPC legada de criação ainda executável

O fluxo atual de criação D&D 3.5 em `ficha.html` chama `public.finalizar_criacao_personagem_srd` (SECURITY INVOKER, exige `auth.uid()`), que chama a sobrecarga de sete argumentos `public.criar_personagem_srd_completo(..., p_identidade)`. Essa implementação valida identidade, idade/altura/peso racial, tendência e restrições de classe, além de gravar os dados complementares na mesma transação.

Entretanto, a sobrecarga antiga de seis argumentos `public.criar_personagem_srd_completo(p_nome,p_raca_id,p_classe_id,p_atributos,p_pericias,p_talentos)` continua com EXECUTE para authenticated e SECURITY DEFINER. Ela não recebe nem valida identidade/tendência/idade e chama o construtor básico, deixando de aplicar as validações e escolhas específicas da versão atual. Não foi encontrado call site dessa sobrecarga nos arquivos ativos `ficha.html`, `lobby.html` ou `mesa.html`. Assim, um usuário autenticado pode invocá-la diretamente como caminho alternativo de criação menos rigoroso.

Correção recomendada: revogar EXECUTE de authenticated nessa assinatura antiga (ou removê-la após verificar clientes antigos), mantendo somente o wrapper atual e a sobrecarga de sete argumentos. Fazer por migration versionada, testar o fluxo atual de criação e uma chamada negativa à assinatura antiga. Não foi alterada remotamente.


## Grants por coluna — superfície de escrita residual

Os papéis autenticados não têm UPDATE de tabela inteira em `characters`, `srd_character_sheets` ou `srd_character_equipment`; há grants por coluna:
- `characters`: campos de apresentação/identidade e também `campaign_id`; RLS restringe a proprietário/GM. O frontend ativo usa updates diretos para retrato, transformação e header; não foi encontrado update direto de `campaign_id` nas páginas ativas. A página legada `lobby_atualizado.html` faz esse update diretamente, mas não é referenciada pelo `index.html` nem pelas páginas ativas.
- `srd_character_sheets`: UPDATE direto de `pv_atual` para dono/GM. O frontend ativo altera PV por RPC (`alterar_pv_personagem`/rotas de combate), sem update direto encontrado. O grant de coluna permite contornar validações/turno/registro dessas RPCs e deve ser removido depois de confirmar compatibilidade.
- `srd_character_equipment`: UPDATE direto de `equipado` para dono/GM. O frontend ativo usa `equipar_item_srd`; não foi encontrado update direto dessa coluna. O grant permite contornar regras de mãos/instâncias e deve ser removido depois de validar todos os clientes.
- `campaigns`: UPDATE direto de `capa_url`, usado pelo lobby ativo e protegido por policy GM.
- `scenes`: grants amplos de INSERT/UPDATE/DELETE, mas policies restringem essas operações a GM; confirmar se a tabela/fluxo legado continua necessário.

A criação SRD ativa usa RPC atômica `finalizar_criacao_personagem_srd`. A função `window.criarFicha` que insere `characters` e escreve em `vinculo_character_sheets` pertence ao fluxo legado não-SRD; `lobby_atualizado.html` também usa tabelas e fluxo legados. O `index.html` redireciona para `lobby.html` e não aponta para `lobby_atualizado.html`; a página antiga ainda pode ser aberta por URL direta. Manter como legado acessível até decidir arquivamento, mas não tratá-la como caminho atual D&D 3.5.

Correção proposta: revogar os grants de coluna `srd_character_sheets.pv_atual`, `srd_character_equipment.equipado` e `characters.campaign_id` quando o fluxo legado for aposentado; preservar os grants de apresentação usados pelo cliente e o de `campaigns.capa_url`. Testar as rotas RPC atuais e confirmar se existe cliente antigo antes da migration. Nada foi alterado remotamente.


### Helper de criação completa ainda publicado como RPC

Além da sobrecarga legada de seis argumentos, a sobrecarga atual de sete argumentos `public.criar_personagem_srd_completo(..., p_identidade)` também tem EXECUTE para authenticated. O wrapper oficial `finalizar_criacao_personagem_srd` é SECURITY INVOKER e chama essa função, depois grava idiomas, talentos bônus, domínios, grimório e equipamento inicial na mesma transação. Não há call site frontend direto para as duas sobrecargas `criar_personagem_srd_completo`; o frontend chama somente o wrapper final.

A chamada direta à sobrecarga de sete argumentos cria o personagem e grava parte da ficha (identidade, atributos, perícias, talentos e ledger de classe), mas não executa o restante do pacote de criação do wrapper. Assim, há risco de criação parcial via RPC alternativa. A correção arquitetural é encapsular os helpers de criação como funções internas não expostas e tornar o wrapper final SECURITY DEFINER com search_path fixo e checagem explícita de auth.uid(), ou equivalente que preserve a atomicidade e a autorização; depois revogar EXECUTE direto das duas sobrecargas para authenticated. Não alterar a função isoladamente antes de revisar os chamadores e testar criação completa/rollback.
