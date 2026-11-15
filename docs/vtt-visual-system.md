# Sistema visual global do Vínculo — Carvão profundo

## Auditoria da estrutura existente
A leitura da branch main identificou cinco superfícies HTML principais: entrada (index.html), lobby (lobby.html), ficha (ficha.html), mesa (mesa.html) e dados 3D (dice.html).

- A mesa já carregava mesa-theme.css, mas mantinha 21 blocos de estilo embutidos com paleta antiga, incluindo verdes e azuis; o tema anterior usava superfícies grafite relativamente claras.
- O lobby usava estilos próprios e vinculava vinculo-ui.css, cuja paleta era azul-marinho; havia fundos claros em inputs e cards e uma sidebar com imagem de fundo.
- A ficha tinha uma mistura de folha de pergaminho clara, estilos escuros, camadas azuladas e uma camada verde posterior. Inventário, slots, grimório e alguns modais ainda usavam fundos de papel.
- A entrada usava azul-marinho e gradientes mais claros que a nova direção.
- O rolador 3D tinha identidade própria, botões de incremento brancos e cores diferentes do restante do VTT.
- As páginas mantêm muitos estilos embutidos e seletores específicos. Por isso, a unificação foi feita como camada CSS global carregada depois dos estilos legados, sem reescrever HTML funcional nem remover identificadores usados pelo JavaScript.

## Direção visual consolidada
- Fundo quase preto: #070809 / #0a0c0e.
- Superfícies: #0e1114, #12161a, #171c21 e #1d2329.
- Bordas: aço/grafite #292f36 e #3a424b.
- Destaque: bronze envelhecido #987747 / #b59663 / #d0b27c; sem amarelo vivo como preenchimento predominante.
- Texto: marfim frio #e5e1d9 e cinza neutro.
- Verde deixa de estruturar componentes; vermelho fica reservado a perigo.
- Cinzel para títulos e cabeçalhos; Inter para controles, navegação, números e conteúdo de interface; EB Garamond apenas para trechos narrativos.

## Escala e composição
- Lobby: sidebar mais estreita e contida; navegação compacta; cards de campanha menores, com imagem de capa proporcional; cards de ficha com retrato e hierarquia mais compactos.
- Mesa: preservar mapa central, painéis laterais e bandeja de personagens; escurecer os painéis, reduzir ruído e uniformizar botões contextuais sem mexer nos fluxos.
- Ficha: trocar a folha clara por uma superfície grafite, manter divisões e hierarquia de seções; escurecer inventário, slots, grimório e modais para não haver telas de pergaminho destoantes.
- Dados: harmonizar controles de seleção, painel de configurações e botões de rolagem com a paleta global.
- Responsividade: manter as regras existentes de cada tela e aplicar ajustes de densidade, espaçamento e áreas de toque, sem trocar a arquitetura desktop/mobile já aprovada.

## Limites desta camada
Esta entrega é visual. Não modifica regras D&D 3.5, scripts de interação, RPCs, permissões, persistência, tabelas ou conteúdo de fichas. Não remove IDs, classes funcionais ou atributos data-*.
