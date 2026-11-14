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
- A política `characters_owner_or_gm_update` autoriza o dono da ficha a atualizar a linha inteira. Como RLS não restringe colunas, a futura economia precisa impedir que clientes alterem diretamente `ouro` fora das RPCs (por privilégios de coluna cuidadosamente revisados ou proteção equivalente no banco). Apenas validar saldo dentro da RPC de compra não basta se o cliente puder sobrescrevê-lo por outra chamada.
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

- A política `characters_owner_or_gm_update` permite UPDATE ao dono da ficha ou Mestre da campanha, sem restringir a coluna `ouro`.
- O papel `authenticated` tem privilégio UPDATE de tabela herdado/atribuído conforme o schema atual; a consulta de privilégios de coluna não mostrou UPDATE específico de `ouro`, mas isso não elimina o risco de UPDATE por privilégio de tabela.
- As RPCs `gm_grant` e `finalizar_equipamento_inicial_srd` estão executáveis por `authenticated` e são `SECURITY DEFINER`.
- A política de RLS sozinha não impede que o proprietário altere seu saldo diretamente, pois a política autoriza a atualização da linha inteira. A implementação de loja deve restringir escrita direta de ouro por privilégio de coluna/tabela e concentrar movimentações nas RPCs validadas.

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
