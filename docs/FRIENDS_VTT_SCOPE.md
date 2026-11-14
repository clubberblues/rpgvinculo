# VTT entre amigos — escopo ativo

## Direção do produto
Esta branch contém a versão enxuta e jogável do VTT para um grupo de amigos usando D&D 3.5. O projeto principal completo permanece em stand-by e não deve ser expandido como parte deste trabalho.

Princípio: a plataforma organiza a sessão e automatiza somente operações simples e confiáveis. O Mestre continua responsável por decisões narrativas, exceções e adjudicação de regras.

## Estrutura
- Login e autenticação existentes.
- Lobby para criar, localizar e entrar em campanhas.
- Fichas de personagens vinculadas à campanha.
- Mesa compartilhada para Mestre e jogadores.
- Mapa enviado pelo Mestre, tokens e sincronização em tempo real.
- Chat para conversa e LOG separado para eventos de jogo.
- Modal de dados integrado à mesa.
- Ordem de iniciativa e controle básico de turnos.

## Mapa e movimento
- Cada quadrado do grid representa sempre 1,5 m (5 pés), conforme D&D 3.5.
- A metragem por quadrado é fixa e não é uma configuração do Mestre.
- Zoom altera apenas a visualização, nunca a escala lógica do grid.
- Computador: roda do mouse para aproximar/afastar e arrastar área vazia para deslocar o mapa.
- Celular: gesto de pinça para zoom e toque/arrasto para tokens.
- Névoa de guerra opcional: Mestre revela áreas com pincel para todos os jogadores ou para um jogador selecionado.
- Não implementar colisão automática com paredes/terrenos nesta versão.

## Mestre e jogadores
- Mestre controla a campanha, mapa, tokens de criaturas/NPCs, PV, iniciativa e eventos.
- Jogadores controlam apenas seus próprios personagens e ações permitidas.
- Ações devem ser contextualizadas pelo tipo de token e pelo papel do usuário.
- Não mostrar ações de conjuração para personagens sem capacidade de conjurar.
- O Mestre pode resolver manualmente resultados que dependam de interpretação.

## Recursos de sessão
- Fichas: atributos, PV, CA, deslocamento, salvamentos, perícias, talentos e equipamentos.
- Combate: iniciativa, turnos, ataques e dano quando o fluxo existente for confiável; demais situações ficam sob decisão do Mestre.
- Descanso curto/longo: recuperação aplicada pelo Mestre ao personagem ou grupo selecionado.
- Economia: cada jogador compra com seu próprio saldo; venda credita automaticamente o ouro ao vendedor.
- XP e recompensas administrados pelo Mestre.
- Chat e LOG mantêm conversa separada de eventos e rolagens.

## Escopo funcional confirmado — ajuste de prioridade (2026-11-14)

- **Grid:** manter apenas o grid fixo de D&D 3.5, com cada quadrado representando 1,5 m (5 pés). Zoom e pan são apenas controles visuais; não alteram a escala lógica.
- **Mapa e névoa:** não fazem parte desta versão simplificada. Não implementar editor de mapas, publicação de imagens de cenário, camadas de névoa ou revelação por jogador.
- **Tokens e fichas:** tokens de personagens devem permanecer vinculados à ficha de origem. PV, PV máximo, CA e demais dados exibidos no token devem refletir a ficha persistida; alterações de token não podem sobrescrever silenciosamente a ficha.
- **Combate:** priorizar a correção ponta a ponta de iniciativa, ordem e avanço de turnos, ações, ataques, confirmação de crítico, rolagem de dano e atualização de PV do alvo.
- **Dados e testes:** priorizar solicitações do Mestre, rolagens individuais dos jogadores, rolagens de NPCs/monstros pelo Mestre, aplicação de modificadores/CD quando aplicável e registro do resultado no LOG.

## Fora do escopo desta versão
- Automatização completa de todas as regras do D&D 3.5.
- Simulação de paredes, linha de visão e colisão de terreno.
- Expansão de catálogos/auditorias avançadas de talentos, magias e monstros.
- Sistemas avançados do projeto principal enquanto ele estiver em stand-by.

## Método de trabalho
1. Preservar funcionalidades existentes que já estejam operacionais.
2. Corrigir integrações e bugs que impeçam uma sessão completa.
3. Implementar apenas o necessário para o escopo acima.
4. Validar cada alteração com verificações reproduzíveis; não declarar testes funcionais sem executá-los.
5. Não fazer merge, deploy nem alterações no Supabase de produção sem autorização específica.
