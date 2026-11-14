# VTT entre amigos — escopo ativo

## Direção do produto
Esta branch contém a versão enxuta e jogável do VTT para um grupo de amigos usando D&D 3.5. O projeto principal completo permanece em stand-by e não deve ser expandido como parte deste trabalho.

Princípio: a plataforma organiza a sessão e automatiza somente operações simples e confiáveis. O Mestre continua responsável por decisões narrativas, exceções e adjudicação de regras.

## Estrutura
- Login e autenticação existentes.
- Lobby para criar, localizar e entrar em campanhas.
- Fichas de personagens vinculadas à campanha.
- Mesa compartilhada com grid fixo, tokens e sincronização em tempo real.
- Chat para conversa e LOG separado para eventos de jogo.
- Modal de dados integrado à mesa.
- Ordem de iniciativa e controle básico de turnos.

## Grid e movimento
- Cada quadrado representa sempre 1,5 m (5 pés), conforme D&D 3.5.
- A metragem por quadrado é fixa; o Mestre não pode alterá-la.
- Zoom altera apenas a visualização, nunca a escala lógica do grid.
- Computador: roda do mouse para zoom e arrastar área vazia para deslocar a visualização.
- Celular: gesto de pinça para zoom e toque/arrasto para mover tokens.
- Não há mapa de fundo, editor de mapas ou névoa de guerra nesta versão.
- Não implementar colisão automática com paredes/terrenos.

## Mestre e jogadores
- Mestre controla a campanha, tokens de NPCs/monstros, PV, iniciativa e eventos.
- Jogadores controlam apenas seus próprios personagens e ações permitidas.
- Tokens de personagens permanecem vinculados à ficha correspondente.
- PV atual (incluindo valores negativos até -10), PV máximo, CA e nome do personagem são sincronizados a partir da ficha persistida; a atualização é publicada pelo Mestre e distribuída pela sincronização da campanha.
- Ações devem ser contextualizadas pelo tipo de token e pelo papel do usuário.
- Não mostrar ações de conjuração para personagens sem capacidade de conjurar.
- O Mestre pode resolver manualmente resultados que dependam de interpretação.

## Recursos de sessão
- Fichas: atributos, PV, CA, deslocamento, salvamentos, perícias, talentos e equipamentos.
- Combate: iniciativa, turnos, ataques, confirmação de crítico, dano e atualização de PV; situações excepcionais ficam sob decisão do Mestre.
- Dados e testes: solicitações do Mestre, rolagens individuais dos jogadores e rolagens de NPCs/monstros pelo Mestre, com modificadores e registro no LOG.
- Descanso curto/longo: recuperação aplicada pelo Mestre ao personagem ou grupo selecionado, respeitando as permissões da ficha.
- Economia: cada jogador compra com seu próprio saldo; venda credita automaticamente o ouro ao vendedor.
- XP e recompensas administrados pelo Mestre.
- Chat e LOG mantêm conversa separada de eventos e rolagens.

## Prioridades funcionais confirmadas (2026-11-14)
1. Sincronização persistente entre ficha e token.
2. Combate ponta a ponta: iniciativa, ordem, turnos, ações, ataques, crítico, dano e PV.
3. Dados e testes: pedidos, rolagens, modificadores, CDs quando aplicáveis e LOG.
4. Manter somente o grid fixo de 1,5 m; mapa de fundo e névoa estão fora do escopo.

## Fora do escopo desta versão
- Automatização completa de todas as regras do D&D 3.5.
- Mapa de fundo, editor de mapas e névoa de guerra.
- Simulação de paredes, linha de visão e colisão de terreno.
- Expansão de catálogos/auditorias avançadas de talentos, magias e monstros.
- Sistemas avançados do projeto principal enquanto ele estiver em stand-by.

## Método de trabalho
1. Preservar funcionalidades existentes.
2. Corrigir integrações e bugs que impeçam uma sessão completa.
3. Implementar apenas o necessário para o escopo acima.
4. Validar cada alteração com verificações reproduzíveis; não declarar testes funcionais sem executá-los.
5. Não fazer merge, deploy nem alterações no Supabase de produção sem autorização específica.
