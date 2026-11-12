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


### Rascunho corrigido de endurecimento dos privilégios padrão (não aplicado)

A primeira fixture isolada falhou de forma útil: revogar EXECUTE de authenticated somente no default ACL do schema `priv` **não remove** EXECUTE herdado de `PUBLIC` no PostgreSQL. Como o catálogo remoto confirma EXECUTE de PUBLIC em `priv.srd_feat_saving_throw_modifier`, o default global de funções está ativo. A segunda execução da fixture corrigida passou no CI (`43136928379`), provando a revogação global para funções futuras, os revokes específicos de tabelas/sequences/funções internas, a preservação de `service_role` e a manutenção dos grants de funções já existentes. Portanto, o endurecimento de funções precisa incluir a revogação global para objetos futuros, além dos revokes específicos do schema interno:

```sql
-- Afeta somente funções criadas futuramente pelo owner postgres em todos os schemas.
ALTER DEFAULT PRIVILEGES FOR ROLE postgres
  REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

-- Impede acesso automático de authenticated a objetos futuros do schema interno.
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  REVOKE ALL ON TABLES FROM authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  REVOKE ALL ON SEQUENCES FROM authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA priv
  REVOKE EXECUTE ON FUNCTIONS FROM authenticated;
```

A revogação global de PUBLIC não altera grants já existentes; funções públicas atuais mantêm suas ACLs, inclusive as cinco funções públicas que hoje são executáveis por anon. Novas funções públicas continuarão recebendo os grants de authenticated/service_role do default ACL do schema `public`, mas não receberão anon/PUBLIC implicitamente; qualquer endpoint realmente público precisará de GRANT explícito e revisão. Novas funções de `priv` não receberão EXECUTE de authenticated nem de anon; service_role permanece concedido pelo default ACL existente. Novas tabelas/sequences em `priv` deixam de receber privilégios de authenticated, mantendo service_role.

Isso é uma mudança global de padrão para novas funções e precisa ser revisada contra futuras migrations que esperem EXECUTE público implícito. A fixture `tests/sql/priv_default_acl_fixture.sql` foi adicionada para provar: (a) os grants atuais simulados; (b) a revogação de PUBLIC e authenticated para objetos novos; (c) a preservação de service_role; (d) que grants em funções antigas não são removidos por alteração de default ACL. O teste CI da primeira versão falhou e a fixture foi corrigida para representar o default PUBLIC real; aguardar o novo resultado.

A migration deve ser criada com `supabase migration new`, testada no baseline reproduzido e acompanhada de testes que verifiquem funções públicas explicitamente permitidas. Não executar no remoto antes dessa validação.

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


## Campanhas, convites e entrada na mesa

O fluxo atual de lobby chama `lobby_list_v2`, `create_campaign`, `entrar_campanha_aberta`, `entrar_campanha_com_codigo` e `sentar_personagem_na_mesa`. As RPCs exigem autenticação; o trigger de membership força o dono a GM e impede que um membro não proprietário se promova a GM. `entrar_campanha_aberta` bloqueia a linha da campanha com `FOR SHARE`; `entrar_campanha_com_codigo` lê campanha ativa sem lock antes de inserir membership; `sentar_personagem_na_mesa` valida papel PLAYER e bloqueia a ficha, mas não serializa a validação da membership com a campanha. Há janela TOCTOU: desativação/remoção de membro concorrente pode ocorrer entre validação e gravação. Endurecer os dois fluxos para campaign-first/lock compatível e revalidar membership/active sob lock.

A RPC `lobby_list_v2` retorna metadados de todas as campanhas ativas para qualquer usuário autenticado, mesmo não membro; o código de convite só é retornado ao proprietário. O frontend mostra essas campanhas e permite tentativa de entrada aberta ou por código. Isso parece corresponder a um lobby de descoberta, mas expõe nome, mestre, cidade, briefing, capa, estado e contagem de participantes. Confirmar a política de produto: se campanhas devem ser descobertas publicamente, documentar esse contrato; se forem privadas, adicionar sinalizador de descoberta e filtrar por membro/owner.

A RPC antiga `join_campaign(p_code)` e a página `lobby_atualizado.html` pertencem ao fluxo legado; a página atual usa as duas RPCs novas. A assinatura antiga continua executável por authenticated e deve ser considerada para revogação após confirmar compatibilidade. Não houve mutação nem teste concorrente nesta revisão.


## Integridade dos registros de campanha e personagem — fotografia atual

No snapshot read-only: 3 campanhas, 6 memberships, 3 memberships GM, 5 personagens e 5 fichas SRD. Todas as campanhas têm seu proprietário como GM; não há membership GM de não proprietário; nenhum personagem vinculado está sem membership do dono; nenhuma ficha SRD órfã ou personagem sem ficha SRD foi encontrado; não há ledger de classe órfão. Não foram encontradas duplicatas de membership por campanha/usuário, códigos de convite por campanha, códigos de convite globais, fichas por personagem ou níveis por personagem/classe.

Esses resultados são positivos para os dados atuais, mas a amostra é pequena e não prova integridade sob concorrência. Constraints/uniques e testes concorrentes continuam necessários.


### Helper de salvamento com EXECUTE herdado de PUBLIC

O catálogo confirma que `priv.srd_feat_saving_throw_modifier(jsonb,text)` ainda concede EXECUTE a `PUBLIC`, além de authenticated/service_role; por isso `has_function_privilege('anon',...) = true`. Anon não tem USAGE no schema `priv`, então a chamada direta não está demonstrada via REST no estado atual. A branch contém a migration candidata `20261110160000_revoke_public_feat_saving_throw_helper.sql`, que revoga PUBLIC/anon e mantém authenticated/service_role, mas ela não foi aplicada remotamente e o replay local não consegue iniciar por falta do schema-base. A migration deve ser validada e aplicada via fluxo normal após resolver o baseline; não confundir com correção do default ACL de `priv`, que continua pendente.


### Criação direta de personagem legado ainda permitida por RLS

A policy `characters_create_unassigned` permite INSERT direto para authenticated quando `user_id=auth.uid()` e `campaign_id IS NULL`. Os grants de coluna incluem `xp` e `ouro`, então a rota legada `window.criarFicha` (não-SRD) pode inserir esses valores diretamente. O modo D&D 3.5 atual, iniciado pelo lobby com `ruleset=dnd35`, usa `finalizar_criacao_personagem_srd`; porém `ficha.html` ainda mantém o fluxo legado acessível por URL sem o parâmetro SRD, e `lobby_atualizado.html` continua no repositório sem link a partir do index atual.

Isso permite criar registros base incompletos sem ficha SRD e, no caminho legado, definir XP/ouro iniciais no INSERT. Não foi encontrado um caminho ativo do lobby atual que use essa rota. Para a fundação D&D 3.5, a recomendação é aposentar/arquivar o fluxo legado e restringir INSERT direto em `characters` ao mínimo necessário; a criação SRD deve permanecer exclusivamente no RPC atômico que define XP/ouro em zero e cria a ficha completa. Não remover nem migrar dados Vínculo sem plano de compatibilidade.


## Bloqueio funcional confirmado no Storage privado da mesa

A policy `storage.objects.mesa_media_ler` depende especificamente de `public.can_read_media(name)` (dependência de função confirmada no catálogo). Essa função só retorna verdadeiro quando encontra o caminho em `public.media` e, para jogador, uma layer visível em `public.layers`; GM também depende da linha em `public.media`. No snapshot, ambas as tabelas estão vazias e não foi encontrado nenhum writer de `public.media` nas funções `public/priv/private` ou trigger que as preencha a partir de `campaigns.cba_data`.

O frontend ativo de `mesa.html` faz upload de imagem de token/fundo em `mesa-media` e imediatamente chama `createSignedUrl`; também usa essa função ao resolver `backgroundPath` e `imagemPath` de `campaigns.cba_data`. A chamada `createSignedUrl` exige SELECT em `storage.objects` segundo a documentação oficial do Supabase. Como a policy de SELECT consulta `public.media/layers` vazias, `public.can_read_media('campaigns/{id}/tokens/example.png')` retorna false para todas as campanhas atuais. O upload seguido de assinatura deve falhar e o frontend tenta apagar o arquivo recém-enviado; o bucket privado estava vazio no snapshot, consistente com ausência de uploads concluídos.

**Conclusão:** a infraestrutura de mídia privada foi criada, mas o caminho de autorização não foi conectado ao modelo ativo CBA. Isso bloqueia upload/assinatura de retratos de token e fundo de cena, embora o código e o bucket existam. É um achado estático de alta confiança, reforçado pelo resultado da função e pela exigência SELECT do Supabase; não foi executado upload real.

Correção requer decisão de segurança antes de codificar: (a) preencher `public.media/layers` transacionalmente e manter as regras de visibilidade por layer; ou (b) criar autorização por campanha/caminho derivada de `campaigns.cba_data`, com GM e membros, definindo explicitamente quais imagens cada jogador pode assinar. Não permitir que todos os jogadores assinem o mapa inteiro se a névoa de guerra deve esconder regiões não reveladas: uma URL assinada para a imagem completa permite baixar o mapa fora do overlay visual. Avaliar tiles/crops server-side ou aceitar/documentar fog apenas visual antes de liberar leitura ampla. Não relaxar a policy para `authenticated` genericamente.


A confirmação de exposição foi refinada com os tipos gerados pelo próprio Supabase para o Data API: `Database.public.Functions` contém as duas sobrecargas de `criar_personagem_srd_completo` (seis e sete argumentos), bem como `finalizar_criacao_personagem_srd`. Isso confirma que as sobrecargas estão no schema da API e não é apenas uma concessão ACL sem endpoint. O helper `priv.srd_feat_saving_throw_modifier` não aparece nos tipos públicos gerados, consistente com o schema `priv` não estar exposto na Data API atual. A allowlist ainda deve ser confirmada no Dashboard, mas a exposição do helper de criação público está confirmada.


## Data API: exposição de schemas e novos objetos

A geração de tipos Supabase para o Data API contém 202 nomes de funções do schema `public`, incluindo os fluxos ativos e as duas sobrecargas de criação; não contém as funções internas `priv/private` consultadas. Isso é evidência de que `public` é o schema API ativo e que `priv/private` não estão no schema cache público gerado. Ainda assim, a configuração explícita de schemas expostos deve ser confirmada no Dashboard; `current_setting('pgrst.db_schemas', true)` e settings persistidos por role não forneceram valor.

A mudança do Supabase de 2026-10-30 deixou de expor automaticamente novas tabelas nos Data/GraphQL APIs. Portanto, grants padrão em `public` não garantem, sozinhos, que uma tabela nova esteja no schema API. Cada migration futura que criar tabela/RPC usada pelo frontend precisa validar (a) schema exposto, (b) grants mínimos, (c) RLS/policies e (d) presença nos tipos gerados. Referência: [Supabase changelog — tables not exposed automatically](https://supabase.com/changelog/45329-breaking-change-tables-not-exposed-to-data-and-graphql-api-automatically).


## Manutenção da versão PostgreSQL

O projeto está em PostgreSQL `17.6.1.166`. O changelog do Supabase registra a atualização PostgreSQL 17.11.0.003 (2026-09-25), com correções de 44 CVEs e ajustes de índices/extensões; o aviso de timezone destacado afeta Vancouver/Edmonton/Casablanca, não a região Brasil. A versão atual do projeto está atrás dessa linha de manutenção. Conferir no Dashboard se a atualização gerenciada está disponível/recomendada e revisar extensões/índices antes de agendar; nenhuma atualização foi iniciada.


## Auth e perfil — integridade observada

O trigger `auth.users.on_auth_user_created` chama `public.handle_new_user` SECURITY DEFINER com search_path fixo. Ele usa `raw_user_meta_data.username` apenas como nome de exibição (ou parte local do email como fallback), nunca como papel/autorização; erros de criação do perfil são capturados e não cancelam o signup. `public.enforce_campaign_member_role` força o proprietário a GM e impede promoção de outros membros. `my_role` e `sou_membro` derivam o usuário de `auth.uid()`. Anon/authenticated têm USAGE, mas não CREATE nos schemas public/priv/private/storage, reduzindo risco de objetos maliciosos no search_path.

Fotografia read-only: 8 usuários Auth e 8 perfis; nenhum usuário sem perfil, perfil órfão, username duplicado ou vazio. A amostra atual está consistente; o trigger ainda precisa de monitoramento porque engole erros de criação de perfil e pode permitir contas sem perfil em falhas futuras.


## Matriz de papéis de campanha

A constraint de `public.members.role` permite `GM`, `PLAYER` e `OBSERVER`; o trigger garante que o proprietário seja GM e impede que outros usuários se promovam a GM. No snapshot há três GM e três PLAYER, nenhum OBSERVER. A mesa apenas ordena OBSERVER abaixo dos demais; `lobby.html` não apresenta fluxo ativo para entrar como observador. Para o escopo atual Mestre/Jogadores, validar GM/PLAYER como papéis obrigatórios e decidir se OBSERVER é funcionalidade futura ou legado; não ampliar o produto sem requisito.


## Backup e recuperação — plano Free

A organização Supabase do projeto está no plano `free`. Segundo a documentação oficial, backups automáticos diários estão disponíveis para planos Pro/Team/Enterprise; projetos Free devem exportar regularmente com Supabase CLI e manter cópias fora do projeto. PITR é add-on pago e não será usado.

A ferramenta não expõe a lista de backups do projeto, e não foi possível confirmar um backup/restauração recente. Isso é um bloqueio de segurança para qualquer migration ou alteração de produção: não executar DDL/DML remoto sem cópia recuperável.

Foi criado `scripts/export-current-schema.ps1` para gerar, sem enviar ao GitHub, um snapshot SQL do schema atual em uma pasta irmã ao repositório. Usa o link Supabase já configurado e exige Docker Desktop iniciado; o dump padrão do CLI é schema-only e exclui schemas gerenciados (Auth/Storage) e extensões. O snapshot atual ajuda a preparar uma base local no estado presente e a validar migrations novas, mas **não é o bootstrap pré-ledger** e não substitui backup de dados/usuários/objetos Storage.

Plano gratuito de proteção:
1. Executar o script de snapshot de schema e guardar o SQL/manifest localmente fora do repositório público.
2. Gerar também uma cópia lógica de dados e preservar Auth conforme o procedimento oficial/escopo suportado pela CLI; não presumir que o schema dump inclui auth.users.
3. Exportar os objetos dos buckets separadamente; backup SQL não contém os arquivos Storage. Atualmente `midia` tem 135 objetos e `mesa-media` está vazio.
4. Verificar hashes, tamanho e existência dos arquivos; manter pelo menos uma segunda cópia local/offline.
5. Testar restauração em ambiente descartável antes de autorizar qualquer alteração remota.

Documentação oficial: [Database Backups](https://supabase.com/docs/guides/platform/backups) e [Supabase CLI db dump](https://supabase.com/docs/reference/cli/supabase-db-dump). Nenhum backup foi gerado nesta sessão, porque o ambiente de execução não tem Supabase CLI/Docker nem acesso aos arquivos locais do usuário.


### CBA completo é legível por todos os membros — não há filtro de visibilidade

A policy `campaigns_member_read` permite SELECT da linha inteira da campanha para qualquer usuário autenticado com membership; os grants incluem SELECT de `cba_data` e `combat_data`. O frontend da mesa usa `select('*')` e vários refreshes diretos de `cba_data`. Assim, cada jogador recebe o JSON completo de tokens/posições e dados da cena. O modelo atual não contém campo de token oculto nem estado de fog por jogador; mesmo que um overlay visual seja adicionado no cliente, o jogador poderá inspecionar o JSON completo e baixar o fundo completo se conseguir uma URL.

Isso é incompatível com fog of war/monstros ocultos como controle de segurança. Não resolver apenas com CSS/overlay. O desenho futuro precisa separar estado GM-privado de estado visível aos jogadores e entregar a estes um snapshot filtrado por RPC/view server-side; o acesso à imagem do mapa deve entregar apenas tiles/crops revelados, ou declarar explicitamente que fog é somente visual e não secreta informação. Essa decisão deve preceder a implementação da névoa e da policy de mídia privada.
