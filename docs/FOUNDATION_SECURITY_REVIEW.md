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
