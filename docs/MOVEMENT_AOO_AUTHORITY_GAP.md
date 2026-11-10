# Bloqueio de movimento e ataques de oportunidade — achado confirmado

**Data da inspeção:** 2026-11-10  
**Ambiente:** leitura somente de catálogo/funções do Supabase de produção; nenhuma RPC de jogo foi executada.  
**Prioridade:** P1 — integridade das regras de combate e movimento.  
**Estado:** confirmado estaticamente; correção e teste autenticado ainda pendentes.

## Problema principal: movimento de jogador pode contornar a etapa AOO

As funções instaladas foram lidas diretamente por OID:

| OID | Função | Papel |
|---:|---|---|
| 20522 | `public.mover_token_player_cba(bigint,text,integer,integer)` | endpoint público de movimento do jogador |
| 27366 | `priv.mover_token_player_cba_impl(...)` | implementação que valida e grava a nova posição |
| 26923 | `public.srd_detectar_saida_alcance_ameacado_srd(...)` | detector de saída de área ameaçada |
| 26964 | `public.srd_solicitar_movimento_com_aoo_srd(...)` | registra uma movimentação pendente quando há ameaça |
| 27038 | `public.srd_finalizar_movimento_aoo_pendente_srd(...)` | conclui o movimento após as reações |

O wrapper público OID 20522 e a implementação OID 27366 têm EXECUTE para `authenticated`, não para `anon`. A implementação de movimento não chama o detector OID 26923 nem a RPC de solicitação OID 26964: ela valida turno, propriedade, deslocamento, condições, ocupação e economia de ações, e grava diretamente as coordenadas.

O fluxo protegido existe, mas é separado:
1. `srd_solicitar_movimento_com_aoo_srd` bloqueia a campanha, valida controlador/turno, chama o detector e cria uma linha pendente se houver ameaça.
2. Reações são resolvidas.
3. `srd_finalizar_movimento_aoo_pendente_srd` valida pendências/ataques, bloqueia campanha, confere turno e posição original, ativa o GUC transacional `app.srd_aoo_pending_commit` e só então chama a RPC de movimento.

O trigger `priv.srd_guard_pending_aoo_movement` bloqueia mudanças de posição quando já existe uma pendência AOO, exceto quando o GUC corresponde ao pending que está sendo finalizado. Entretanto, ele não exige que uma pendência exista antes de qualquer movimento. Portanto, uma chamada autenticada direta ao endpoint OID 20522, quando ainda não existe pending, pode gravar movimento sem executar a detecção AOO. A proteção atual impede contornar uma reação já pendente; não impede ignorar a criação da pendência.

**Conclusão:** a integridade da regra não pode depender exclusivamente de o frontend chamar primeiro a RPC de solicitação. O endpoint que efetivamente grava movimento precisa impor o contrato no servidor.

## Correção necessária (não implementada)

A próxima refatoração deve tornar o caminho de movimento uma única autoridade transacional:

1. Identificar e validar campanha, token, controlador, propriedade e turno.
2. Bloquear a campanha e manter a ordem de locks já aprovada para o domínio AOO; revalidar estado e origem após o lock.
3. Calcular destino, deslocamento, footprint e ameaças usando os mesmos helpers usados pelo restante do motor.
4. Se houver ameaça, criar pending e **não** atualizar coordenadas nem consumir deslocamento até as reações terminarem.
5. Se não houver ameaça, aplicar movimento dentro da mesma transação.
6. Na finalização, validar novamente posição original, turno, round, ownership, ameaças e estado das reações; impedir duplicidade/idempotência incorreta.
7. Tornar o caminho antigo de movimento inacessível ao cliente ou convertê-lo em wrapper que delega ao novo fluxo. A exceção interna de commit deve continuar limitada ao pending correto.
8. Preservar o fluxo GM/NPC/monstro e a movimentação fora de combate, sem conceder autoridade adicional ao jogador.

Não basta adicionar uma chamada ao detector no frontend ou em um preflight separado: isso manteria a possibilidade de chamada direta e a janela entre detecção e gravação.

## Segundo defeito: footprint Colossal inconsistente

A implementação de movimento OID 27366 calcula footprint do personagem Colossal como **5 quadrados**. O detector AOO OID 26923 calcula footprint Colossal como **6 quadrados**. A implementação de movimento GM OID 27306 também usa 5, enquanto o helper canônico `priv.srd_token_grid_footprint` e o detector usam 6.

Isso permite divergência entre ocupação/movimento e alcance ameaçado. A refatoração deve eliminar os CASEs duplicados e usar um único helper de footprint em movimento de jogador, Mestre, detecção AOO e demais consumidores.

## Testes de aceite obrigatórios

- Jogador autenticado chama diretamente a RPC de movimento sem passar pela solicitação: deve criar pending se houver ameaça e não mover o token.
- Jogador autenticado move sem ameaça: movimento é aplicado uma única vez.
- Movimento com ameaça: posição e gasto de deslocamento permanecem inalterados até todas as reações atingirem estado terminal; depois o movimento é aplicado uma única vez.
- Pending ativo impede movimento direto alternativo, edição concorrente de cena e finalização duplicada.
- Alteração de turno/round, posição de origem, ownership ou estado da campanha invalida a finalização.
- GM consegue mover NPC/monstro e token de jogador sob controle, respeitando o mesmo contrato AOO.
- Fora de combate, movimento autorizado continua funcionando sem criar pending.
- Tokens Pequeno, Médio, Grande, Enorme, Imenso e Colossal ocupam o footprint canônico; Colossal ocupa 6×6 quadrados.
- Testes concorrentes usam duas sessões autenticadas e Storage/RPC real em ambiente descartável, além das fixtures PostgreSQL sintéticas.

## Restrições de implantação

- Não alterar funções, migrations, grants ou dados do projeto de produção nesta etapa.
- O histórico de migrations permanece sem reconciliação completa; qualquer migration de correção precisa aguardar baseline reproduzível e revisão de dependências.
- Não usar TESTE 2 como ambiente de mutação.
- Os OIDs são evidência do snapshot de 2026-11-10 e devem ser revalidados imediatamente antes de qualquer migration.
