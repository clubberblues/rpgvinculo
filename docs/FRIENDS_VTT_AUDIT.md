# Auditoria funcional — VTT simplificado entre amigos

Data da inspeção: 2026-11-14  
Branch: `friends-vtt-simplified-2026-11-14`  
Escopo: inspeção estática do repositório e consultas somente de leitura ao schema/funções Supabase. Nenhuma alteração no banco foi realizada.

## Resultado executivo

A base já contém lobby/campanhas, fichas D&D 3.5, tokens compartilhados, catálogo de NPCs/monstros, dado 3D, pedidos de rolagem, iniciativa e turnos. A prioridade é reaproveitar esses fluxos, não reconstruí-los.

A inspeção mais profunda corrigiu a conclusão preliminar sobre descanso:
- **Descanso longo do jogador já existe na ficha.** `ficha.html` apresenta o botão `data-grimoire-rest` também para classes sem conjuração e chama `descanso_longo_personagem_srd`. A RPC valida autenticação, propriedade da ficha, campanha fora de combate, intervalo de 8 horas, PV e condições; recupera 1 PV por nível, magias e recursos de classe e remove fadiga/exaustão.
- **Descanso longo de NPC vinculado também existe na mesa**, acionado pelo Mestre via `descanso_longo_npc_vinculado_srd`.
- **Limitação:** o descanso longo do personagem jogador é iniciado pelo próprio dono da ficha. A RPC consultada não permite que o Mestre o execute em nome de outro jogador. Não adicionar botão de Mestre que falharia por permissão.
- **Descanso curto:** existe uma RPC legada `short_rest(p_char)`, mas ela atua sobre `character_sheets`/PM e recupera 25% do PM. Isso não corresponde ao recurso de descanso curto SRD 3.5 que devemos expor sem confirmar regras e modelo de recursos. Não reutilizar automaticamente.

Sobre economia:
- O banco possui dois modelos distintos: o legado `vinculo_items`/`vinculo_inventory` e o modelo SRD ativo `srd_equipment`/`srd_character_equipment`, além de `srd_cba_token_equipment` para tokens não vinculados.
- `ficha.html` ainda contém leituras e escritas legadas em `inventory`/`items`, enquanto a mesa usa `srd_character_equipment` e `srd_equipment` para o inventário SRD. Essa divergência precisa ser eliminada no fluxo da loja; não misturar os dois modelos.
- O saldo `ouro` existe em `characters` (integer) e em `srd_character_sheets` (numeric). A UI de inventário legada exibe `dados.ch.ouro`; o fluxo de loja SRD precisa definir uma fonte canônica e sincronização/migração compatível antes de movimentar dinheiro.
- Não foi localizada tabela de estoque por campanha nem RPC transacional de compra/venda. Existem RPCs de entrega/equipamento, mas não são compra/venda e não resolvem débito/crédito atômico.
- A função `public.sell_price(text)` ainda consulta `public.items`, tabela ausente no schema inspecionado. É uma referência legada inconsistente e não deve ser usada pela loja SRD.
- Portanto, a loja compartilhada continua pendente. Não é seguro simular compra/venda com atualizações separadas no cliente: isso pode permitir saldo negativo, compras duplicadas ou perda de crédito em concorrência.

## Inventário de funcionalidades encontradas

| Área | Evidência | Situação |
|---|---|---|
| Lobby e campanhas | Cliente Supabase, membros/papéis e interface de campanhas em `lobby.html` | Implementado em código; navegador não testado nesta sessão |
| Ficha D&D 3.5 | Atributos, perícias, talentos, idiomas, equipamentos, inventário e descanso longo em `ficha.html` | Implementado em código; fluxo de descanso protegido por RPC; não testado em sessão real |
| Mesa e tokens | Cena compartilhada, tokens, PV/CA, seleção e menu contextual em `mesa.html` | Implementado em código; multiplayer não testado |
| Mestre/NPC/monstros | Catálogos de fichas, arquétipos NPC e bestiário SRD | Implementado em código; não testado em sessão real |
| Dados | Motor 3D, histórico local e ponte `postMessage` em `dice.html` | Integração presente; histórico do dado é volátil e não substitui o LOG da campanha |
| Rolagens | `campaign_log` e pedidos de teste | Implementado em código; sincronização real não testada |
| Iniciativa/turnos | `turn_order`, `current_turn`, rodada e pedidos de iniciativa | Implementado em código; multiplayer não testado |
| Chat e LOG | `campaign_log` distingue texto, sistema, rolagem e pedido de teste; abas novas na mesa | Separação visual adicionada; navegador não testado |
| Mapa e zoom | `--cba-zoom`, controles novos e scripts existentes de pan/gestos | Implementado em código; dispositivos reais não testados |
| Grid | Referência visual de 1 quadrado = 1,5 m | Escala lógica e alinhamento precisam de teste com mapa real |
| Descanso longo | RPC para personagem dono da ficha e RPC de NPC vinculado; ambos bloqueiam combate | Parcialmente integrado: falta ação do Mestre para ficha de jogador e teste funcional; não contornar autorização existente |
| Descanso curto | RPC legada de PM em schema antigo | Não compatível/validado para o fluxo SRD 3.5 simplificado |
| Loja/economia | Campos de ouro e inventário existem, mas não há estoque por campanha nem RPC transacional de compra/venda localizada | Pendente |

## Contratos necessários antes de implementar

### Descanso
1. Decidir se o Mestre pode iniciar descanso longo de personagens jogadores. Hoje a RPC de personagem exige que o usuário autenticado seja dono da ficha.
2. Definir se descanso curto recupera algum recurso no D&D 3.5 padrão usado pela mesa; não confundir com a recuperação de PM do sistema legado.
3. Manter a validação de combate, intervalo, condições e propriedade no servidor.

### Loja
1. Estoque pertencente à campanha, com itens, quantidades, preços e disponibilidade controlados pelo Mestre.
2. Saldo individual por personagem, sem carteira compartilhada.
3. Compra atômica: validar saldo e estoque, debitar comprador e entregar item na mesma transação.
4. Venda atômica: remover/decrementar item e creditar ouro ao vendedor na mesma transação.
5. Registro de transações/idempotência para impedir cobrança ou crédito duplicado.
6. Políticas RLS e RPCs com autorização por campanha e dono da ficha.

## Testes funcionais necessários

1. Abrir mesa simultaneamente como Mestre e jogador e confirmar sincronização de mapa, tokens, PV, chat e LOG.
2. Testar zoom por roda/botões, pinça no celular e pan sem mover tokens por engano; a escala lógica de 1,5 m deve permanecer fixa.
3. Disparar iniciativa, rolar no dado físico e conferir associação correta dos resultados.
4. Confirmar que ataques/dano atualizam PV para todos os participantes.
5. Confirmar que jogador não controla tokens alheios nem executa ações exclusivas do Mestre.
6. Executar descanso longo em ficha própria e NPC vinculado, verificando PV, magias, recursos e bloqueio durante combate.
7. Testar loja apenas depois de existir contrato transacional seguro.

## Regra de execução

- Reaproveitar funções/RPCs existentes quando seu comportamento estiver confirmado.
- Não duplicar recursos já presentes.
- Não criar chamadas RPC, tabelas ou colunas por suposição.
- Não fazer merge, deploy ou alterações no Supabase de produção sem autorização específica.
- Distinguir código encontrado, validação estática, CI e teste funcional real.


## Auditoria complementar da economia — 2026-11-14

### Modelos encontrados e decisão de reaproveitamento

| Estrutura | Campos/uso confirmado | Decisão |
|---|---|---|
| `srd_equipment` | Catálogo SRD com `id`, nome, categoria/tipo, dano, CA, peso, descrição, `preco`/`custo_po`, fonte e estado de revisão | Catálogo a reutilizar na loja |
| `srd_character_equipment` | `character_id`, `equipment_id`, quantidade, equipado e slot de mão | Inventário SRD do personagem jogador |
| `srd_cba_token_equipment` | campanha, token, equipamento, quantidade e estado equipado | Inventário separado de tokens/NPCs |
| `characters` | `user_id`, `campaign_id`, `ouro` integer | Identidade/propriedade e saldo candidato |
| `srd_character_sheets` | `character_id`, `ouro` numeric e dados SRD | Saldo duplicado que exige decisão de fonte canônica |
| `vinculo_items`/`vinculo_inventory` | Catálogo e inventário legado | Não usar no novo fluxo SRD |

### Segurança e lacunas verificadas

- `srd_equipment` tem leitura pública de catálogo.
- `srd_character_equipment` tem leitura para dono/Mestre e atualização para dono/Mestre. Não foram encontradas políticas diretas de INSERT/DELETE na consulta; o fluxo de entrega existente usa RPCs privilegiadas.
- `srd_cba_token_equipment` tem política de leitura por membro da campanha; entrega e equipamento passam por RPCs próprias.
- RPCs existentes: `entregar_item_srd`, `entregar_item_token_srd`, `equipar_item_srd`, `equipar_item_token_srd` e variantes. Nenhuma RPC de compra/venda foi encontrada.
- `public.sell_price(p_item)` consulta `public.items`, que não existe no schema atual. Não reutilizar.
- O inventário legado em `ficha.html` consulta `inventory` com relação `items`, mas o schema expõe `vinculo_inventory` e `vinculo_items`. Tratar como dívida técnica separada; não construir a loja sobre esse caminho quebrado.

### Contrato recomendado para a loja simplificada

1. **Catálogo:** reutilizar `srd_equipment`; Mestre escolhe item, preço de campanha e quantidade disponível. O preço da loja deve ser uma cópia explícita/editável do preço definido pelo Mestre, não uma alteração global do catálogo SRD.
2. **Estoque:** nova tabela de estoque por campanha, com chave da campanha + item, quantidade disponível, preço unitário, ativo/inativo, criador e timestamps. Estoque infinito deve ser um modo explícito, não inferido de quantidade nula.
3. **Fonte de saldo:** antes da implementação, resolver `characters.ouro` versus `srd_character_sheets.ouro`. A recomendação é manter um único saldo canônico por personagem e expor esse mesmo valor na ficha e na mesa; não atualizar ambos sem uma regra formal de sincronização.
4. **Compra:** RPC transacional autenticada recebe campanha, personagem, item, quantidade e chave de idempotência; valida papel de membro, propriedade do personagem, campanha, item ativo, quantidade positiva, preço e estoque; bloqueia as linhas relevantes (`FOR UPDATE`); debita saldo e incrementa/insere inventário na mesma transação; registra recibo.
5. **Venda:** RPC transacional autentica o dono da ficha (ou fluxo explicitamente autorizado pelo Mestre), bloqueia inventário e saldo, valida quantidade e política de recompra, remove/decrementa item, credita o saldo e registra recibo na mesma transação.
6. **Idempotência:** tabela de transações com chave única por campanha/usuário/operação; chamadas repetidas retornam o recibo original e não repetem o débito/crédito.
7. **Autorização:** operações de gestão de loja somente para papel `GM`; compra/venda por dono da ficha; não confiar em `user_metadata`; validar no servidor `auth.uid()`, associação à campanha e propriedade do personagem.
8. **Concorrência:** bloqueio de linha do estoque, saldo e inventário; validar saldo/quantidade novamente dentro da transação. A interface nunca calcula nem grava o saldo final.
9. **Auditoria:** registrar personagem, campanha, item, quantidade, preço unitário, total, tipo (compra/venda), ator, horário e chave idempotente.
10. **Entrega a NPC/token:** manter fluxo separado do comércio de personagens jogadores. O estoque da loja não deve inserir itens em inventários de NPC sem uma ação específica do Mestre.

### Próximas etapas técnicas (sem tocar produção)

1. Definir e documentar a fonte canônica de ouro após inspecionar todas as leituras/escritas de saldo no código.
2. Inspecionar as definições completas das RPCs de entrega existentes para reutilizar validações e evitar duplicação.
3. Criar migration SQL versionada na branch, com tabela de estoque/transações e RPCs de compra/venda; revisar autorização, RLS, idempotência e concorrência.
4. Adicionar testes SQL de concorrência/negação (saldo insuficiente, estoque insuficiente, ficha alheia, campanha alheia, quantidade inválida e repetição da chave).
5. Só então construir UI do Mestre e da compra individual do jogador.
6. Não aplicar migration no Supabase de produção sem autorização específica.


### Achados adicionais sobre saldo e autorização

- A RPC `finalizar_equipamento_inicial_srd` grava o saldo restante simultaneamente em `srd_character_sheets.ouro` (numeric) e `characters.ouro` (integer). Isso confirma que o fluxo de criação inicial tenta manter os dois campos alinhados, mas não prova que todas as rotinas posteriores façam o mesmo.
- A ficha legada exibe `dados.ch.ouro`, derivado de `characters.ouro`; a mesa SRD não apresentou leitura direta de ouro nos trechos inspecionados.
- Existe uma política RLS `characters_owner_or_gm_update` para UPDATE, mas política RLS não concede privilégio SQL. A verificação efetiva de grants mostrou que `authenticated` NÃO possui UPDATE na tabela `characters` nem na coluna `ouro`; portanto, o cliente não pode sobrescrever diretamente esse saldo com os privilégios atuais.
- A tabela `srd_character_equipment` tem política de UPDATE para dono/Mestre e SELECT, mas INSERT/DELETE são realizados por RPCs privilegiadas existentes. A implementação de comércio deve seguir esse padrão: sem escrita direta pelo navegador.
- Decisão de arquitetura pendente: escolher um saldo canônico. A opção mais coerente com o fluxo SRD é `srd_character_sheets.ouro` como fonte decimal e `characters.ouro` como espelho legado inteiro apenas se todos os pontos de leitura ainda necessários forem mantidos sincronizados no servidor. Antes de adotar essa opção, mapear todas as funções que escrevem/consomem ouro e decidir como tratar frações de PO.


### Auditoria complementar de todas as rotinas de ouro — 2026-11-14

#### Escritas identificadas

- `criar_personagem_srd`: cria personagem com `characters.ouro=0` e `srd_character_sheets.ouro=0`.
- `finalizar_equipamento_inicial_srd`: calcula riqueza inicial e grava o saldo restante nos dois campos. O campo SRD mantém NUMERIC; o legado `characters.ouro` recebe `FLOOR(v_remaining)::INTEGER`. Portanto, frações de PO são descartadas no espelho legado.
- `gm_grant`: concede/remove ouro exclusivamente em `characters.ouro` (INTEGER), com bloqueio de linha, validação de saldo não negativo e log. Não atualiza `srd_character_sheets.ouro`; usar essa RPC em personagens SRD criaria divergência.
- `calc_sheet`: expõe `characters.ouro` como valor de ouro na ficha legada.
- `srd35_deslocamento_personagem`: lê `srd_character_sheets.ouro` para calcular o peso do ouro carregado (100 PO = 1 kg conforme comentário/implementação).
- Não foram encontrados triggers de sincronização entre os dois campos. Os triggers inspecionados são de exclusão de ficha/inventário, sincronização de instâncias de armas e ajuste de PV por talento.
- Nenhuma outra função pública encontrada na busca por referências a ouro realiza escrita explícita nesses campos.

#### Segurança confirmada

- Existe uma política RLS `characters_owner_or_gm_update`, mas o papel `authenticated` não possui privilégio SQL UPDATE na tabela `characters` nem na coluna `ouro` (verificação efetiva por `has_table_privilege` e `has_column_privilege`). A política, isoladamente, não concede acesso.
- `authenticated` também não possui UPDATE em `srd_character_sheets` nem INSERT/UPDATE/DELETE em `srd_character_equipment`; as políticas RLS de UPDATE dessas tabelas não concedem privilégios SQL ausentes.
- `gm_grant` e `finalizar_equipamento_inicial_srd` são `SECURITY DEFINER` e executáveis por `authenticated`. `entregar_item_srd` também é `SECURITY DEFINER` e executável por `authenticated`.
- `criar_personagem_srd(text,text,text,jsonb)` é `SECURITY DEFINER`, mas a verificação atual não encontrou EXECUTE concedido a `authenticated` nem a `anon`; identificar o caminho de criação ativo antes de depender dessa função.
- `equipar_item_srd(text,text,boolean)` é `SECURITY INVOKER` e executável por `authenticated`, mas o papel não possui UPDATE em `srd_character_equipment`. O caminho precisa de teste funcional/revisão de grants; a política RLS de UPDATE não basta para a chamada funcionar.

#### Decisão de implementação

- **Não adotar ainda um saldo canônico unilateral sem uma migração de compatibilidade.**
- Para o VTT simplificado, o contrato proposto é usar `srd_character_sheets.ouro NUMERIC` como saldo autoritativo para fichas SRD, pois a riqueza inicial e a carga já o utilizam. `characters.ouro INTEGER` será espelho legado arredondado para baixo somente enquanto a ficha antiga depender de `calc_sheet`/rotinas legadas.
- A futura camada de economia deve atualizar ambos os campos dentro da mesma transação, definir explicitamente o tratamento de frações (recomendado: permitir incrementos em PO inteiras e preservar o saldo NUMERIC existente), e registrar saldo anterior/novo no livro-caixa.
- `gm_grant` não deve ser usado para recompensas em personagens SRD até ser adaptado ou substituído por uma RPC SRD que atualize os dois campos atomicamente. Para personagens legados, manter o comportamento atual até uma migração própria.
- Antes de criar a migration, conferir os grants efetivos de UPDATE na tabela `characters` e as permissões de UPDATE na coluna `ouro` com uma consulta focada em privilégios de tabela e coluna. A consulta anterior confirmou o papel `authenticated` no privilégio INSERT da coluna, mas não apresentou UPDATE específico por coluna.


#### Integração de interface confirmada

- A interface de inventário em `ficha.html` ainda monta o resumo de ouro usando `dados.ch.ouro` e lista itens por estrutura legada. Esse componente não deve ser reaproveitado como tela de comércio SRD sem refatoração.
- A consulta à ficha SRD carrega `srd_character_sheets`, mas a inspeção da interface não encontrou ainda um componente de loja SRD nem um resumo de saldo SRD integrado ao inventário novo.
- A busca por chamada textual `gm_grant` em `mesa.html` não encontrou invocação direta; a rotina é um endpoint legado do banco e não deve ser presumida como fluxo atualmente usado pelo VTT simplificado.
- Portanto, a loja será uma interface nova dentro da mesa/campanha, com inventário SRD do personagem e saldo apresentado a partir do mesmo contrato de dados das RPCs. Não conectar o novo fluxo à mochila legada.


### Verificação efetiva de privilégios e tipos — 2026-11-14

A consulta final separou políticas RLS de privilégios SQL efetivos. Resultado para o papel `authenticated`:

| Tabela/operação | Privilégio SQL efetivo |
|---|---|
| `characters` UPDATE | Não |
| `characters.ouro` UPDATE | Não |
| `srd_character_sheets` UPDATE | Não |
| `srd_character_equipment` INSERT | Não |
| `srd_character_equipment` UPDATE | Não |
| `srd_character_equipment` DELETE | Não |
| `srd_character_equipment` SELECT | Sim |
| `srd_equipment` SELECT | Sim |

Isso corrige duas conclusões anteriores: a existência de política RLS UPDATE não significa que o cliente tenha grant SQL UPDATE; e a política de UPDATE do inventário não significa que o papel possa executar a alteração diretamente. Não conceder grants amplos para contornar isso.

Tipos confirmados:
- `characters.id`: bigint; `characters.campaign_id`: bigint; `characters.user_id`: uuid; `characters.ouro`: integer.
- `srd_character_sheets.character_id`: bigint; `srd_character_sheets.ouro`: numeric.
- `srd_character_equipment.character_id` e `equipment_id`: text; `quantidade`: integer.
- `srd_equipment.id`: text; `preco` e `custo_po`: numeric.

Assinaturas e privilégios de RPC verificados:
- `criar_personagem_srd(text,text,text,jsonb)`: SECURITY DEFINER, mas sem EXECUTE efetivo para authenticated/anon.
- `finalizar_equipamento_inicial_srd(text,text,jsonb,jsonb)`: SECURITY DEFINER, EXECUTE para authenticated.
- `entregar_item_srd(bigint,text,text,integer)`: SECURITY DEFINER, EXECUTE para authenticated.
- `gm_grant(bigint,bigint,integer,integer,text,integer)`: SECURITY DEFINER, EXECUTE para authenticated; atualiza somente `characters.ouro`.
- `equipar_item_srd(text,text,boolean)`: SECURITY INVOKER, EXECUTE para authenticated, porém a tabela de inventário não concede UPDATE ao papel. Este caminho merece teste e correção específica antes de ser considerado funcional.

Consequência para a loja:
- As futuras RPCs de compra/venda devem encapsular escrita em função privilegiada com validação explícita de `auth.uid()`, papel, propriedade, campanha, estoque e saldo; não conceder escrita direta ao navegador.
- O saldo SRD continua sendo candidato a fonte canônica, com espelho legado sincronizado dentro da mesma transação.
- Nenhuma migration foi aplicada. Nenhuma permissão foi alterada.


### Revisão complementar do fluxo de equipamento — 2026-11-14

- `equipar_item_srd(text,text,boolean)` é SECURITY INVOKER. Para itens que não são armas, executa UPDATE em `srd_character_equipment`, mas `authenticated` não tem UPDATE nessa tabela. A policy RLS existente não supre o grant ausente. Esse caminho deve ser tratado como provável falha para armaduras/escudos/acessórios até teste controlado.
- Para armas, a função delega a `equipar_item_srd_maos`, que usa `srd_character_weapon_instances`. O papel authenticated possui INSERT/UPDATE/DELETE nessa tabela, então o bloqueio identificado acima não se aplica automaticamente ao caminho de instâncias de armas.
- `equipar_item_srd_maos` e `equipar_arma_instancia_personagem` são SECURITY INVOKER; seus privilégios e políticas devem ser mantidos separados da correção do inventário genérico.
- `criar_personagem_srd(text,text,text,jsonb)` não tem EXECUTE efetivo para authenticated/anon no banco consultado. Isso não prova que a criação de ficha esteja quebrada: a UI pode usar outro endpoint ou RPC. O fluxo ativo precisa ser rastreado no código antes de alterar permissões.
- RPCs de descanso longo do jogador, descanso longo de NPC vinculado, entrega de item a token e equipamento de item de token têm EXECUTE para authenticated. As funções de descanso longo do jogador e entrega/equipamento de token são SECURITY DEFINER; descanso de NPC vinculado é SECURITY INVOKER.

Nenhuma permissão foi concedida e nenhuma função foi alterada. Essas observações são auditoria estática de grants/definições; não equivalem a teste funcional.


### Rastreamento do fluxo real de criação da ficha — 2026-11-14

A UI de criação em `ficha.html` não chama diretamente `criar_personagem_srd`. Ela chama `finalizar_criacao_personagem_srd` com identidade, perícias, talentos, idiomas, escolhas de classe/domínios, grimório e equipamento inicial.

A função `finalizar_criacao_personagem_srd(text,text,text,jsonb,jsonb,jsonb,jsonb,jsonb,jsonb,text[],jsonb,text,jsonb,jsonb)`:
- tem EXECUTE efetivo para authenticated;
- é SECURITY INVOKER;
- chama `criar_personagem_srd_completo` (variante com identidade), `salvar_idiomas_personagem_srd`, `salvar_talentos_bonus_classe_inicial_srd`, opcionalmente `salvar_dominios_personagem_srd` e `salvar_grimorio_srd`, e por fim `finalizar_equipamento_inicial_srd`;
- executa o conjunto como uma única transação, conforme comentário da própria função.

A variante `criar_personagem_srd` sem grant para authenticated não é o endpoint direto da UI e é chamada internamente pelo caminho privilegiado de criação completo. Não alterar grants dessa função isoladamente.

A criação de ficha SRD, portanto, já possui um endpoint agregado e transacional; não deve ser reconstruída para o VTT simplificado. A próxima investigação deve concentrar-se em validar a chamada agregada e corrigir apenas lacunas específicas de equipamento/economia.


### Continuação da auditoria — economia, grants e CI — 2026-11-14

#### Ausência confirmada de estrutura de loja
- Nova consulta ao schema não encontrou tabelas públicas com nomes/propósito de loja, estoque, transações, economia ou livro-caixa.
- A busca por RPCs de compra/venda/loja encontrou somente `sell_price(text)`, função legada já identificada como incompatível porque consulta `public.items`, inexistente no schema atual.
- As policies RLS de `srd_character_equipment` e `srd_character_sheets` não substituem grants SQL. Para `authenticated`, o inventário SRD permite SELECT, mas não INSERT/UPDATE/DELETE; a ficha SRD permite SELECT, mas não UPDATE. O cliente não deve gravar saldo ou inventário diretamente.

#### Integração de equipamento: chamada de UI e risco funcional
- O código atual de `ficha.html` chama `equipar_item_srd` para equipar/desequipar itens genéricos, passando `p_character_id`, `p_equipment_id` e `p_equipado`.
- Para itens que não são armas, a função executa UPDATE em `srd_character_equipment` como SECURITY INVOKER. O papel `authenticated` não tem grant UPDATE nessa tabela. Portanto, há uma incompatibilidade concreta entre o caminho de UI e os privilégios SQL; armaduras, escudos e acessórios podem falhar ao equipar/desequipar.
- Para armas, a função encaminha para a rotina de instâncias de armas, que usa outra tabela e conjunto de privilégios. Não generalizar a falha de itens genéricos para o fluxo de armas.
- A correção deve ser específica e validada; não conceder UPDATE geral ao navegador nem transformar a função em SECURITY DEFINER sem revisão completa de autorização.

#### Criação de ficha
- A consulta confirmou que a UI usa `finalizar_criacao_personagem_srd`, não a RPC simples `criar_personagem_srd`. A variante simples sem EXECUTE para authenticated não representa, isoladamente, falha na criação.
- O endpoint agregado já foi documentado acima e não deve ser substituído.

#### CI do branch simplificado
No HEAD consultado do PR #76 (`e93f40800494afb36361cd129880cc5f5e351117`), os três workflows associados terminaram com conclusão `success`:
- Validate mesa JavaScript;
- Validate application JavaScript;
- Static validation.

Isso comprova somente os testes automatizados cobertos pelos workflows. Não comprova funcionamento em navegador, celular, multiplayer, autenticação, economia ou equipagem real.

Nenhuma tabela, função, policy ou grant foi alterado no Supabase. Nenhuma migration foi aplicada. PR #76 continua draft, aberto e sem merge.


#### Verificação agregada dos saldos existentes
Consulta somente de leitura às fichas atuais:
- 6 fichas SRD; nenhuma com ouro nulo ou negativo.
- As 6 possuem saldo fracionário terminado em `,90` PO; valores observados entre 54,90 e 72,90 PO.
- Em todas as 6 fichas, `characters.ouro` coincide com `FLOOR(srd_character_sheets.ouro)`; não há divergência atual no espelho inteiro.
- 2 das 6 fichas estão vinculadas a campanha.

Implicação: **não é correto restringir a economia a PO inteiras**. O saldo SRD deve permanecer NUMERIC e as operações precisam aceitar preços fracionários compatíveis com o catálogo (sem conversão prematura para INTEGER). O espelho legado continuará recebendo apenas a parte inteira por FLOOR, como já ocorre na finalização do equipamento inicial. Essa regra deve ser mantida na mesma transação de compra/venda/recompensa SRD.


#### Precisão do catálogo de equipamentos
- O catálogo `srd_equipment` contém 1.027 itens; 1.021 têm preço cadastrado, 6 não têm preço e nenhum preço negativo foi encontrado.
- Os preços cadastrados têm no máximo duas casas decimais; o intervalo consultado vai de 0,00 a 211.000,00 PO.
- A loja não deve publicar automaticamente itens sem preço. O Mestre deve informar preço de compra e preço de recompra para cada item adicionado à loja, ou confirmar explicitamente uma regra padrão de recompra.
- Contrato de valores: usar NUMERIC com duas casas decimais para preços, totais e saldo de transação; preservar o saldo NUMERIC SRD e nunca converter o valor intermediário para INTEGER. O campo legado `characters.ouro` permanece espelho inteiro via FLOOR.

#### Contrato funcional consolidado para a próxima implementação
1. Estoque por campanha e item, com preço de compra e preço de venda/recompra definidos separadamente pelo Mestre; quantidade inteira positiva ou modo de estoque ilimitado explícito.
2. Uma loja ativa por campanha pode conter vários itens; a mesma peça de equipamento pode ter preços diferentes em campanhas distintas.
3. Compra: jogador escolhe sua ficha vinculada à campanha; o servidor confirma que a ficha pertence ao usuário, que o usuário é membro PLAYER, que o item está ativo, que há estoque, e que o saldo cobre o total.
4. Venda: somente o dono da ficha vende itens que possui; o servidor confirma quantidade no inventário e preço de recompra ativo. O item é decrementado/removido e o ouro creditado atomicamente.
5. A compra/venda deve bloquear estoque, ficha/saldo e linha de inventário com `FOR UPDATE`, recalcular total no servidor e registrar um recibo idempotente.
6. A chave idempotente deve ser única por campanha + ator + operação, para que repetição de requisição não duplique débito, crédito ou entrega.
7. Mestre administra catálogo da loja e estoque; jogador não pode alterar preços, estoque, recibos nem saldo por escrita direta.
8. Recibos ficam consultáveis pelo Mestre e pelo jogador dono da ficha; registros preservam campanha, personagem, ator, operação, item, quantidade, preço unitário, total e saldos anterior/posterior.
9. Itens SRD sem preço no catálogo não entram na loja até o Mestre atribuir preço. O catálogo global não é alterado.
10. Nenhuma migration ou RPC deve ser aplicada no banco de produção durante esta etapa de auditoria.


### Verificação de segurança do projeto — advisor Supabase — 2026-11-14
Consulta ao advisor de segurança do projeto retornou:
- 7 tabelas com RLS habilitado e sem policies (inclui tabelas internas de sequência de ataque e recursos de classe).
- 99 funções SECURITY DEFINER executáveis por authenticated, classificadas como WARN pelo advisor.
- 1 aviso de proteção contra senhas vazadas desabilitada no Auth.

Esses resultados são avisos agregados do projeto, não prova automática de exploração. Cada função SECURITY DEFINER precisa de revisão individual de autorização e validação de `auth.uid()`; não revogar em lote, pois várias podem ser endpoints legítimos do VTT. Para a nova loja, as RPCs deverão ter checagens explícitas de papel, campanha e propriedade, search_path fixo, grants restritos e testes negativos. As tabelas privadas da loja deverão ter RLS e políticas de leitura específicas; escrita ocorrerá somente pelas RPCs. Nenhuma configuração de Auth, policy ou função foi modificada nesta auditoria.

Remediações oficiais:
- [Advisor: SECURITY DEFINER executável por authenticated](https://supabase.com/docs/guides/database/database-linter?lint=0029_authenticated_security_definer_function_executable)
- [Advisor: RLS habilitado sem policy](https://supabase.com/docs/guides/database/database-linter?lint=0008_rls_enabled_no_policy)
- [Proteção contra senhas vazadas](https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection)


### Implementação em branch — primeira migration da loja — 2026-11-14

Foram adicionados ao branch simplificado, sem aplicar no Supabase:
- `supabase/migrations/20261114100000_srd_campaign_shop.sql`
- `supabase/tests/srd_campaign_shop_test_plan.sql`

A migration cria:
- `srd_campaign_shop_items`: catálogo de itens por campanha, preço de compra, preço de recompra opcional, estoque finito ou ilimitado, ativação e auditoria do Mestre.
- `srd_campaign_shop_receipts`: recibos imutáveis com campanha, personagem, ator, operação, item, quantidade, preço unitário, total, saldo anterior/posterior e chave idempotente.
- RPC `srd_campaign_shop_configure_item`: somente GM configura preço, estoque e disponibilidade.
- RPC `srd_campaign_shop_buy`: jogador compra apenas para sua própria ficha na campanha.
- RPC `srd_campaign_shop_sell`: jogador vende apenas itens de seu próprio inventário; o saldo é creditado e o estoque finito é reposto.

Salvaguardas incluídas no rascunho:
- Bloqueios `FOR UPDATE` em ficha, saldo, anúncio de loja e inventário; lock transacional por chave idempotente.
- Repetição idêntica retorna o recibo original; reutilização da chave com parâmetros diferentes é rejeitada.
- Saldo SRD NUMERIC preservado e espelho `characters.ouro` atualizado com FLOOR na mesma transação.
- Limite explícito para evitar overflow do espelho INTEGER legado.
- RLS de leitura para membros e recibos para ator/dono/Mestre; sem grants de escrita direta às tabelas.
- RPCs SECURITY DEFINER com `search_path` fixo, grants somente a authenticated e checagem explícita de `auth.uid()`, campanha e papel.
- Preços e estoque são locais à campanha; nenhum preço global do catálogo SRD é alterado.

Revisão estática preliminar do arquivo confirma 3 RPCs, 3 blocos SECURITY DEFINER, 3 search_paths fixos, bloco transacional, grants de execução, locks e caminho de idempotência. **Isso não equivale a validação de sintaxe pelo PostgreSQL nem a teste funcional.** A migration permanece somente no GitHub; não foi aplicada ao banco. O arquivo de testes é uma matriz de casos a executar em projeto Supabase isolado com contextos JWT de GM, PLAYER e usuário externo.

Pendências antes de conectar a UI:
1. Aplicar somente em projeto de teste isolado e corrigir qualquer erro real do PostgreSQL.
2. Executar testes negativos, repetição idempotente e concorrência da matriz.
3. Verificar triggers de inventário/instâncias de armas após compra e venda.
4. Definir a tela da loja do Mestre e a tela individual do jogador, com chave UUID nova por ação e reutilizada apenas em retry.
5. Revisar a correção separada de `equipar_item_srd`; não conceder grants gerais ao navegador.


### Correção de privilégio de equipagem — migration em branch — 2026-11-14

A revisão detalhada esclareceu a falha: a policy RLS `srd_character_equipment_owner_or_gm_update` já existe e limita linhas ao dono da ficha ou Mestre, mas o papel authenticated não tinha grant SQL para UPDATE. A função `equipar_item_srd` é SECURITY INVOKER e atualiza somente a coluna `equipado` para armaduras, escudos e acessórios.

Em vez de elevar a função para SECURITY DEFINER ou conceder UPDATE da tabela inteira, foi criada a migration mínima:
- `supabase/migrations/20261114100500_srd_equipment_toggle_column_grant.sql`
- Concede somente `UPDATE(equipado)` a authenticated; não concede alteração de quantidade, item, mão ou propriedade.
- A policy RLS existente continua sendo a barreira por linha.

Foi adicionada a matriz `supabase/tests/srd_equipment_toggle_test_plan.sql`. A migration não foi aplicada. A eficácia final depende de teste em ambiente isolado.

### Gatilho de instâncias de armas e comércio
Consulta à função privada do gatilho confirmou que INSERT de equipamento do tipo arma cria instâncias de armas; redução de quantidade remove primeiro instâncias não equipadas e rejeita a operação se houver armas equipadas/em uso que impeçam a redução; DELETE remove instâncias vinculadas. Portanto, a loja usa o inventário SRD existente e preserva o mecanismo de armas. Venda de armas equipadas pode ser rejeitada pelo gatilho; a UI deverá orientar o jogador a desequipar antes da venda.

### Estado das migrations em revisão
As duas migrations da loja e a correção de equipagem existem somente na branch. Foram criados arquivos de matriz de testes para cada caminho. Nenhuma migration foi aplicada no Supabase de produção nem em projeto de teste nesta sessão. A revisão realizada até aqui é estática; sintaxe PostgreSQL, RLS, execução das RPCs e concorrência ainda precisam de validação real em projeto isolado.

### Conferência do schema real e proteção adicional de venda — 2026-11-14

A migration da loja foi confrontada com o schema ativo do Supabase em consultas somente de leitura:
- `campaigns.id` e `characters.id` são BIGINT; `srd_equipment.id` é TEXT; `members.campaign_id` é BIGINT e `members.user_id` é UUID.
- Os papéis reais em `members.role` são `GM` e `PLAYER`, exatamente os valores usados pelas RPCs.
- `srd_character_sheets.character_id` é BIGINT e `ouro` é NUMERIC; `characters.ouro` é INTEGER.
- `srd_character_equipment` usa `character_id` TEXT, `equipment_id` TEXT, `quantidade` INTEGER, `equipado` BOOLEAN e PK composta `(character_id,equipment_id)`. A migration converte o ID BIGINT para TEXT ao operar no inventário.
- O gatilho de sincronização de armas é AFTER INSERT/DELETE/UPDATE OF quantidade; INSERT cria instâncias e redução de quantidade só remove instâncias não equipadas.

A inspeção do gatilho revelou um detalhe importante: o caminho DELETE remove instâncias de armas sem verificar se estavam equipadas. Por isso, não bastava confiar no gatilho para impedir venda de item equipado. A RPC `srd_campaign_shop_sell` foi corrigida na branch para rejeitar a venda quando `v_held.equipado` for verdadeiro, exigindo que o jogador desequipe o item primeiro. A regra vale também para armaduras, escudos e acessórios, e evita a remoção acidental de arma equipada pelo caminho DELETE.

Essa correção foi gravada no commit `739629be2ab87142daacb09d5e6fb76a49132738`. A conferência do schema e do código foi somente leitura no projeto de produção; nenhuma migration, dado ou configuração foi alterada. A migration ainda não foi validada pelo parser PostgreSQL nem executada em ambiente isolado.
### Regressão de venda de equipamento equipado e CI — 2026-11-14

A matriz `supabase/tests/srd_campaign_shop_test_plan.sql` agora inclui explicitamente o caso de venda de arma, armadura, escudo ou acessório equipado: a operação deve falhar sem alterar saldo, inventário, estoque ou instâncias; o jogador deve desequipar antes.

No commit `fb23eaf022f4ef86bc1159804804b1d39117c332`, os três workflows consultados concluíram com sucesso: validação estática, validação do JavaScript da aplicação e validação do JavaScript da mesa. O commit posterior `df85c36be9aa3ea621a3cafc1f40f147e09e010a` altera somente a matriz SQL de testes e ainda não apresentava execução de workflow no momento da consulta. Nenhum desses workflows valida a sintaxe/execução das RPCs no PostgreSQL.

### Bloqueio atual de validação

A lista de branches do Supabase retornou apenas a branch `main` do projeto; não existe ambiente isolado de desenvolvimento disponível. Não foi criado um branch/projeto novo porque isso pode gerar cobrança e o usuário já estabeleceu que não dispõe de orçamento para ferramentas/infraestrutura pagas. Portanto, as migrations permanecem draft e não se deve conectar a UI da loja nem aplicar qualquer migration ao banco de produção até haver validação PostgreSQL em ambiente isolado sem custo.