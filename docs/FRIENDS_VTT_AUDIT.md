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
- O schema contém saldo `ouro` em `characters` e `srd_character_sheets`, e inventário `vinculo_inventory`.
- Não foi localizado modelo de estoque por campanha nem RPC transacional de compra/venda. Também não foi encontrada tabela pública `items` ou `inventory` na consulta de schema, embora existam referências legadas a esses nomes em `ficha.html`.
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
