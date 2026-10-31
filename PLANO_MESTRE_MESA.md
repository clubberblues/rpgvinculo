# Plano Mestre da Mesa Virtual

Atualizado em 31/10/2026. Repositório: `clubberblues/rpgvinculo`.

## Objetivo

Estabilizar a mesa virtual para uma nova rodada de simulação entre Mestre e jogador, com resultados de combate calculados pelo sistema, banco de regras confiável e criação de personagem orientada por passos e minitutoriais.

## Estado atual

- As 8 campanhas e os 15 personagens existentes foram apagados a pedido do proprietário. As tabelas e os catálogos foram preservados.
- Verificação após a limpeza: `campaigns`, `characters`, `members`, `campaign_log`, `tokens` e `srd_character_sheets` estão com zero registros.
- O banco tem catálogos distintos para D&D 3.5 (`srd_*`) e Vínculo (`vinculo_*`). Eles não devem ser misturados.
- Contagens atuais: D&D 3.5 — 114 equipamentos, 14 magias, 7 raças, 11 classes, 6 talentos, 38 perícias e 10 monstros. Vínculo — 16 classes, 160 habilidades de classe, 95 magias, 191 itens e 72 talentos.
- A tabela `srd_character_equipment` não existe no banco conectado, embora o fluxo da aplicação espere essa relação. A estrutura de `srd_equipment` também difere da estrutura definida em scripts recentes do repositório. É necessário alinhar o esquema antes de importar ou expor o catálogo.
- O fluxo de ataque atual publica o total do ataque e deixa a confirmação da CA e a aplicação do dano para o Mestre. Ainda não faz a resolução completa de acerto e dano.

## Decisões recuperadas das conversas

### Mesa, mapa e controle

- Na exploração, o jogador move livremente o próprio token, sem economia de ações de combate; deslocamento, grade e permissões continuam validados.
- No combate, o movimento é arrastar e soltar com validação automática de deslocamento, alcance, obstáculos e regras habilitadas.
- O tamanho mecânico do token é independente da imagem. Pequenas e Médias ocupam 1×1; Grandes 2×2; Enormes 3×3; Imensas 4×4; Colossais 5×5 ou mais. Minúsculas e Diminutas podem compartilhar quadrados individualmente.
- O jogador controla seu personagem. O Mestre controla NPCs, monstros e pode intervir em qualquer token.

### Iniciativa

- Personagens dos jogadores rolam sua própria iniciativa: 1d20 + modificador de Destreza + bônus aplicáveis.
- O Mestre rola a iniciativa dos NPCs, monstros e personagens que controla.
- A iniciativa final é ordenada em ordem decrescente e cada criatura mantém sua própria entrada.
- Para várias criaturas do Mestre, o dado 3D aceita vários dados: a quantidade deve corresponder aos tokens escolhidos; cada resultado é usado uma vez e associado aleatoriamente a um token selecionado. Não se distribuem resultados aleatoriamente aos personagens dos jogadores.

### Progressão e magia de Vínculo

- As classes devem manter identidades mecânicas próprias, sem habilidades genéricas compartilhadas como substituto da progressão de classe.
- O trabalho anterior previa validar Escudeiro, Berserk e Mago antes de expandir o catálogo de habilidades por nível.
- Talentos gerais e habilidades exclusivas de classe são catálogos separados.
- Magias básicas podem ser universais; magias avançadas dependem de aprendizado, fonte ou condição narrativa.
- A fórmula de PM discutida para Vínculo era PM máximo = base da classe + INT, com custos e efeitos das magias definidos separadamente. Essa regra deve permanecer no catálogo Vínculo, sem ser misturada às regras SRD de D&D 3.5.

## Caminho de implementação

### 1. Fechar o escopo e normalizar a base

- Definir se a completude solicitada cobre D&D 3.5 SRD/OGL, o livro próprio Vínculo RPG 5.0, ou os dois em catálogos separados.
- Fazer um inventário dos IDs, campos obrigatórios, duplicatas, relações e fontes de cada catálogo.
- Alinhar migrações e esquema no Supabase, incluindo a relação de equipamentos de personagem, antes de novos imports.
- Manter IDs estáveis, origem/licença, idioma, requisitos, progressão e dados mecânicos estruturados; evitar dados de regra espalhados em HTML/JSON ad hoc.

### 2. Completar e validar os catálogos

- Criar uma lista de cobertura por categoria: raças, classes e progressões, perícias, talentos, equipamentos, magias, monstros, condições e demais regras que a criação e o combate consultam.
- Importar somente fontes definidas para o sistema escolhido; conferir contagem esperada, IDs únicos, campos obrigatórios, links de origem e requisitos cruzados.
- Validar a seleção de magias e capacidades pela classe, nível, atributos, requisitos e regras de aprendizado.

### 3. Fechar o ciclo de combate

- Jogador seleciona alvo e ataque; sistema valida turno, alcance, arma e ação.
- Dado 3D fornece o d20; sistema soma bônus, aplica regras de acerto e compara o total à CA do alvo.
- Em erro, registrar “errou” e encerrar sem abrir a rolagem de dano.
- Em acerto, abrir o dado 3D para a expressão de dano da arma e modificadores aplicáveis; registrar o resultado e atualizar PV conforme os dados estruturados do alvo.
- Se faltar CA, dano ou outra regra necessária no catálogo/token, informar claramente o dado faltante ao Mestre em vez de inventar valor.
- Tratar acertos críticos, reduções/resistências, ataques múltiplos e tipos de dano com regras explícitas e rastreáveis.

### 4. Tornar a criação de personagem guiada

- Organizar a criação em passos curtos: identidade; raça; classe; atributos; habilidades/perícias; talentos; equipamento; magia quando aplicável; revisão final.
- Mostrar apenas escolhas válidas para a ficha atual, com explicação breve do efeito, requisitos, recursos e impacto.
- Incluir minitutoriais contextuais, que possam ser ignorados e reabertos, e não bloquear quem já conhece as regras.
- Calcular derivados a partir do catálogo e exibir a origem de cada número.
- Salvar como rascunho e validar todos os requisitos antes de confirmar a ficha.

### 5. Simular de ponta a ponta

- Criar uma campanha de teste, entrar como Mestre e jogador em sessões distintas e validar permissões.
- Conferir ficha, catálogo, posicionamento, movimento em exploração, iniciativa individual e coletiva, turnos, ataque que erra, ataque que acerta, dano, PV, magias, inventário e atualização em tempo real.
- Repetir cenários de erro e recarga para garantir que pedidos e resultados não se dupliquem.
- Só então usar uma nova mesa para a simulação guiada pelo proprietário.

## Decisões ainda abertas

1. Escopo definitivo dos catálogos: D&D 3.5 SRD/OGL, Vínculo RPG 5.0, ou ambos separados. O banco mantém os dois sistemas e os números atuais não demonstram cobertura completa.
2. Não localizei, nas conversas referenciadas e disponíveis, o texto dos minitutoriais anteriormente combinados. Recuperar o chat certo ou aprovar uma nova redação antes de tratar os textos como decisão anterior.
3. Confirmar as regras críticas de combate que o sistema deve automatizar: ameaça/confirmação de crítico, resistências/redução de dano e quando um acerto pode exigir intervenção do Mestre.

## Critérios de pronto para iniciar a simulação

- Escopo e fonte de cada catálogo definidos; IDs e relações consistentes; cadastros essenciais completos.
- Nenhuma rolagem pendente duplicada após recarregar; iniciativa e turnos coerentes.
- O ataque informa acerto/erro automaticamente; apenas acertos abrem o dado de dano; PV e log são atualizados sem ambiguidade.
- Um jogador consegue criar uma ficha válida pelo fluxo guiado sem ajuda externa, e o Mestre consegue preparar a mesa e iniciar o combate.
