# Auditoria funcional — VTT simplificado entre amigos

Data da inspeção: 2026-11-14  
Branch: `friends-vtt-simplified-2026-11-14`  
Escopo: leitura estática dos arquivos `mesa.html`, `lobby.html`, `ficha.html`, `dice.html` e `friends-vtt-ui.js`. Não houve conexão de teste nem execução em navegador nesta auditoria.

## Resultado executivo

A base existente é maior do que uma mesa visual: já há autenticação/campanhas no lobby, fichas D&D 3.5, tokens compartilhados, catálogo de monstros/NPCs, pedidos de rolagem, integração do dado 3D, iniciativa e turnos. A versão simplificada deve reaproveitar esses fluxos e evitar duplicá-los.

Dois requisitos importantes ainda não estão comprovados como atendidos:
- **Descanso de personagens jogadores:** foi localizado um fluxo de descanso longo para NPC vinculado, com RPC `descanso_longo_npc_vinculado_srd`; não foi localizado um fluxo equivalente para personagem de jogador nem descanso curto. Não criar uma segunda implementação sem antes definir a regra e o RPC autorizado.
- **Loja/economia da campanha:** a ficha informa que inventário/loja são operados pela mesa, mas não foi localizado em `mesa.html` um fluxo de loja, compra, venda, saldo ou crédito de ouro. Portanto, esse requisito permanece pendente; não inventar tabela/RPC nem alterar o banco de produção.

## Inventário de funcionalidades encontradas

| Área | Evidência estática | Situação |
|---|---|---|
| Lobby e campanhas | `lobby.html` contém cliente Supabase, leitura de membros/papéis e interface de campanhas | Implementado em código; não testado nesta sessão |
| Ficha D&D 3.5 | `ficha.html` carrega fichas SRD, atributos, perícias, talentos, idiomas, equipamentos e inventário | Implementado em código; não testado nesta sessão |
| Mesa e tokens | `mesa.html` contém cena compartilhada, camada de tokens, HP/CA, seleção e menu contextual | Implementado em código; não testado nesta sessão |
| Mestre/NPC/monstros | Catálogos de fichas, arquétipos NPC e bestiário SRD estão presentes | Implementado em código; não testado nesta sessão |
| Dados | `dice.html` possui motor 3D, histórico local e ponte `postMessage` para a janela pai | Integração presente; histórico do dado é volátil e não substitui o LOG da campanha |
| Rolagens na mesa | `mesa.html` publica rolagens em `campaign_log` e recebe pedidos de teste | Implementado em código; sincronização real não testada |
| Iniciativa/turnos | Estado de combate usa `turn_order`, `current_turn`, rodada e pedidos de iniciativa | Implementado em código; não testado em sessão multiplayer |
| Chat e LOG | `campaign_log` distingue mensagens `texto`, `sistema`, `rolagem` e `test_request`; a camada nova oferece abas CHAT/LOG | Separação visual adicionada; comportamento não testado em navegador |
| Mapa e zoom | Mundo compartilhado usa `--cba-zoom`; há controles novos e scripts existentes de pan/gestos | Implementado em código; mouse, toque e sincronização não testados |
| Grid | A interface informa que cada quadrado equivale a 1,5 m | Informação visual; escala lógica e alinhamento precisam de teste com mapa real |
| Descanso | Há descanso longo de NPC vinculado, bloqueado durante combate, com recuperação e evento no chat | Parcial; falta confirmar/implementar fluxo de personagens jogadores e descanso curto |
| Loja/economia | A ficha declara que loja/inventário são operados pela mesa, mas não foi encontrado fluxo de compra/venda/saldo na mesa | Pendente |

## Pontos técnicos que exigem teste real

1. Abrir a mesa simultaneamente como Mestre e jogador e confirmar atualização em tempo real de mapa, tokens, PV, chat e LOG.
2. Confirmar que o zoom por roda e botões não altera a metragem fixa do grid; testar também pinça no celular e pan sem arrastar tokens acidentalmente.
3. Disparar iniciativa pelo Mestre, receber pedidos nos jogadores, rolar no dado físico e confirmar que resultados são associados aos personagens corretos.
4. Confirmar que ataques/dano atualizam PV do alvo e que a interface reflete o novo valor para todos.
5. Testar permissões: jogador não pode controlar tokens de outros jogadores nem executar ações exclusivas do Mestre.
6. Definir e implementar o contrato de descanso de personagem jogador e descanso curto antes de expor botões que possam alterar recursos.
7. Definir modelo de loja: estoque por campanha, preço, comprador, saldo individual, transação atômica e crédito automático ao vendedor. Implementar somente após validar o contrato de banco, sem tocar a produção nesta etapa.

## Regra de execução

- Reaproveitar funções e RPCs existentes quando seu comportamento estiver confirmado.
- Não duplicar recursos já presentes.
- Não criar chamadas RPC, tabelas ou colunas por suposição.
- Não fazer merge, deploy ou alterações no Supabase de produção sem autorização específica.
- Distinguir sempre código encontrado, validação estática e teste funcional real.
