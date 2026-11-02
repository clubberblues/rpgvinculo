# Plano Mestre da Mesa Virtual

Atualizado em 01/11/2026. Repositório: `clubberblues/rpgvinculo`.

## Objetivo

Estabilizar a mesa virtual para uma nova rodada de simulação entre Mestre e jogador, com resultados de combate calculados pelo sistema, banco de regras confiável e criação de personagem orientada por passos e minitutoriais.

## Estado atual

- Snapshot do banco em 01/11/2026: `campaigns` 3, `characters` 7, `members` 7, `campaign_log` 142, `tokens` 0 e `srd_character_sheets` 7. Não foram apagados dados nesta etapa.
- O banco tem catálogos distintos para D&D 3.5 (`srd_*`) e Vínculo (`vinculo_*`). Eles não devem ser misturados.
- Contagens atuais: D&D 3.5 — 1.021 equipamentos, 601 magias, 7 raças, 11 classes, 110 talentos, 49 perícias e 445 monstros; ainda há 7 progressões de magia, 385 arquétipos NPC e 11 pacotes iniciais. Vínculo — 16 classes, 160 habilidades de classe, 95 magias, 191 itens e 72 talentos.
- A relação `srd_character_equipment` e colunas compatíveis com a aplicação foram criadas em `srd35_schema_reconciliation.sql`, com RLS de leitura por dono/Mestre e RPCs protegidas para entregar, equipar e usar poções de cura. O inventário de personagem tem 20 registros e o inventário de tokens tem 1 registro. O esquema legado foi preservado.
- A função `mover_token_player_cba` tinha permissão efetiva para `anon`; o acesso foi revogado. A verificação posterior mostrou `anon_can_execute=false` e `authenticated=true`. O advisor deixou de apontar função SECURITY DEFINER acessível a anônimos; ainda há avisos genéricos para funções SECURITY DEFINER acessíveis a usuários autenticados, que exigem revisão de autorização por função.
- O fluxo de ataque foi atualizado para extrair CA numérica, resolver acerto/erro e abrir dado 3D de dano apenas em acerto; falta simulação ponta a ponta e o dano calculado ainda precisa ser aplicado pelo Mestre aos PV do token.
- O Grimório atual usa botões estreitos de texto, sem campo de imagem no catálogo. O fundo de papel é esticado pelo CSS para 100% da largura e altura do modal, o que pode deformar a textura; as classes também estão sem dados técnicos e fontes no banco.

## Decisões recuperadas das conversas

### Mesa, mapa e controle

- Na exploração, o jogador move livremente o próprio token, sem economia de ações de combate; deslocamento, grade e permissões continuam validados.
- No combate, o movimento é arrastar e soltar com validação automática de deslocamento, alcance, obstáculos e regras habilitadas.
- O tamanho mecânico do token é independente da imagem. Criaturas Pequenas e Médias são representadas individualmente: cada token ocupa seu próprio quadrado 1×1 e não compartilha esse espaço. Grandes ocupam 2×2; Enormes 3×3; Imensas 4×4; Colossais 5×5 ou mais. Minúsculas e Diminutas podem compartilhar quadrados, mantendo tokens individuais.
- O jogador controla seu personagem. O Mestre controla NPCs, monstros e pode intervir em qualquer token.

### Iniciativa

- Personagens dos jogadores rolam sua própria iniciativa: 1d20 + modificador de Destreza + bônus aplicáveis.
- O Mestre rola a iniciativa dos NPCs, monstros e personagens que controla.
- A iniciativa final é ordenada em ordem decrescente e cada criatura mantém sua própria entrada.
- Para várias criaturas do Mestre, o dado 3D aceita vários dados: a quantidade deve corresponder aos tokens escolhidos; cada resultado é usado uma vez e associado aleatoriamente a um token selecionado. Não se distribuem resultados aleatoriamente aos personagens dos jogadores.

### Progressão e magia de Vínculo

- As classes devem manter identidades mecânicas próprias, sem habilidades genéricas compartilhadas como substituto da progressão de classe.
- O trabalho anterior previa validar Escudeiro, Berserk e Mago antes de expandir o catálogo de habilidades por nível. A conversa anterior refere 320 habilidades de classe; a tabela atual do banco contém 160. Essa diferença precisa ser reconciliada com o material fonte.
- Talentos gerais e habilidades exclusivas de classe são catálogos separados.
- Magias básicas podem ser universais; magias avançadas dependem de aprendizado, fonte ou condição narrativa.
- A fórmula de PM discutida para Vínculo era PM máximo = base da classe + INT, com custos e efeitos das magias definidos separadamente. Essa regra deve permanecer no catálogo Vínculo, sem ser misturada às regras SRD de D&D 3.5.

## Auditoria da implementação (31/10/2026)

### Regras recuperadas e status

- **Tamanho no grid:** Pequenas e Médias usam um token individual em 1×1; Grandes 2×2; Enormes 3×3; Imensas 4×4; Colossais 5×5 ou maior. A decisão “ocupação individual” da conversa refere-se a Minúsculas e Diminutas: cada criatura mantém seu próprio token, e elas podem compartilhar um quadrado. Isso ainda precisa ser aplicado à validação de colisão, movimento, alcance e flanqueamento.
- **Iniciativa:** jogadores rolam seus próprios dados; o Mestre seleciona a quantidade de NPCs/monstros/fichas próprias, rola a mesma quantidade de d20 no dado 3D, e cada resultado é usado uma vez e associado aleatoriamente apenas aos tokens selecionados. Validar no código de ponta a ponta; os registros de iniciativa de Mestre ainda são gerados no servidor em parte do fluxo e não se deve presumir que o dado coletivo do Mestre já esteja concluído.
- **Criação guiada:** tutorial visual por etapas, escurecendo a tela e destacando a função atual, é uma decisão de experiência; roteiro e integração visual seguem pendentes.
- **Manter o projeto existente:** evoluir os HTMLs e banco atuais em vez de reconstruir a aplicação.

### Correções executadas e verificadas

- Inventário SRD alinhado ao esquema já instalado, sem apagar ou substituir colunas legadas. A tabela de relação foi criada com FK para equipamento, RLS para leitura do dono/Mestre e RPCs de entrega/equipamento/poções de cura. A estrutura passou por verificação de colunas, FK e permissões de execução.
- RPC de movimento deixou de ser executável por `anon`; permanece disponível para `authenticated`. A verificação de privilégio efetivo confirmou o resultado.
- Grimório ainda não foi alterado. Proposta: grade/lista de opções à esquerda e painel de briefing à direita; arte com proporção fixa e `object-fit: contain`; atributos/traços em blocos curtos; progressão da classe em seção expansível; etapa só avança pelo botão “Continuar”. Em telas pequenas, lista acima e briefing abaixo. A textura do papel deve manter a proporção, sem esticar para preencher o modal.
- O banco agora tem campos `briefing` e `imagem_url` para raça, e `imagem_url` para classe; estão sem conteúdo de arte/briefing. O SRD não fornece ilustrações licenciadas para preencher esses campos; usar arte própria ou devidamente licenciada.

### Lacunas confirmadas no catálogo D&D 3.5

- Contagens atuais do snapshot de 01/11/2026: 1.021 equipamentos, 601 magias, 7 raças, 11 classes, 110 talentos, 49 perícias, 445 monstros e 7 progressões de magia. Há ainda 385 arquétipos NPC e 11 pacotes iniciais.
- Esses números são inventário, não atestado de completude. As 11 linhas da auditoria de cobertura permanecem pendentes e com zero entradas verificadas. Fontes/licenças precisam ser associadas e cada entrada validada.
- Domínios, características de classe por nível, condições SRD e efeitos tipados de magia ainda estão vazios. A progressão numérica das classes e os espaços de magia foram normalizados, mas não substituem a implementação de habilidades, talentos, regras de conjuração ou efeitos.
- Equipamentos, magias, monstros e progressões atuais ainda precisam de conferência de campos e efeitos mecânicos; as interfaces existentes não constituem o motor completo.
- O escopo confirmado é SRD 3.5/OGL, mantendo Vínculo em catálogo separado. Livros não SRD não serão copiados integralmente; registrar fonte/licença autorizada e usar resumos próprios quando necessário.


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
- Incluir tutorial guiado em cada etapa, no estilo dos tutoriais de MMORPG: escurecer o restante da tela, destacar o botão ou área da etapa e explicar sua função. O usuário pode avançar de etapa ou fechar o tutorial quando concluir; o dado 3D existente continua integrado e as exigências de rolagem devem aparecer no chat.
- Calcular derivados a partir do catálogo e exibir a origem de cada número.
- Salvar como rascunho e validar todos os requisitos antes de confirmar a ficha.

### 5. Simular de ponta a ponta

- Criar uma campanha de teste, entrar como Mestre e jogador em sessões distintas e validar permissões.
- Conferir ficha, catálogo, posicionamento, movimento em exploração, iniciativa individual e coletiva, turnos, ataque que erra, ataque que acerta, dano, PV, magias, inventário e atualização em tempo real.
- Repetir cenários de erro e recarga para garantir que pedidos e resultados não se dupliquem.
- Só então usar uma nova mesa para a simulação guiada pelo proprietário.

## Decisões ainda abertas

1. Escopo confirmado: completar agora o catálogo D&D 3.5 SRD/OGL. O catálogo Vínculo permanece separado para uma etapa posterior.
2. A conversa indicada define o formato do tutorial guiado, mas o roteiro e os textos de cada etapa ainda precisam ser redigidos e alinhados com as telas existentes.

## Critérios de pronto para iniciar a simulação

- Escopo e fonte de cada catálogo definidos; IDs e relações consistentes; cadastros essenciais completos.
- Nenhuma rolagem pendente duplicada após recarregar; iniciativa e turnos coerentes.
- O ataque informa acerto/erro automaticamente; apenas acertos abrem o dado de dano; PV e log são atualizados sem ambiguidade.
- Um jogador consegue criar uma ficha válida pelo fluxo guiado sem ajuda externa, e o Mestre consegue preparar a mesa e iniciar o combate.


## Fundação do motor SRD 3.5/OGL — 01/11/2026

Migração aplicada ao Supabase de produção: `srd35_rule_engine_foundation` (`20261101201351`). A migração é aditiva e preservou campanhas, personagens e fichas.

- Progressões de classe: 220 linhas (11 classes × 20 níveis), geradas dos campos de progressão já existentes.
- Progressões de espaços de magia: 1.400 linhas normalizadas (7 classes conjuradoras × 20 níveis × 10 círculos).
- Trilhas de classe: 7 registros de personagem preservados e copiados para a relação normalizada.
- Catálogo de origem/licença, regrasets, módulos por campanha, características por nível, domínios, grimório, magias conhecidas/preparadas, estado de espaços, condições, efeitos e auditoria de cobertura agora têm estrutura própria.
- O catálogo de cobertura mantém 11 categorias como pendentes, sem alegar completude por contagem. Classes, equipamento, talentos, raças, perícias, monstros e magias precisam ser conferidos entrada por entrada e associados às fontes autorizadas.
- Domínios, características por nível, condições SRD e efeitos tipados de magia continuam sem registros; estes módulos foram preparados, não preenchidos. As listas de domínio e os efeitos por magia ainda não são aplicados pelo motor.
- RLS está ativa nas novas tabelas; consultas autenticadas de leitura são permitidas, leitura anônima e gravação direta autenticada estão bloqueadas. Escrita de estado de jogo deverá passar por operações validadas do servidor.

A especificação normativa de módulos, dependências e critérios de cobertura está em `DND35_RULE_ENGINE_ARCHITECTURE.md`. “Completo” só poderá ser declarado quando os catálogos forem verificados por fonte e cada regra automatizável tiver um resolver e cenários de aceitação. O texto integral de livros não SRD não é parte desta ingestão.


## Atualização de estado verificado — 2026-11-02

As seções históricas acima preservam o contexto das decisões, mas os números e pendências antigos não representam mais o estado atual. O estado autoritativo atual é:

- Auditoria SRD: 1.403/1.403 entradas genéricas verificadas; 1.021/1.021 equipamentos com fonte conferida, incluindo 46 exceções documentadas como não aplicáveis.
- Catálogo fonte-verificado: 607 magias, 445 monstros, 131 características de nível, 110 talentos, 50 perícias, 38 condições e 22 domínios.
- RLS foi ativado nas tabelas de auditoria; nenhuma auditoria possui pendência não documentada.
- RPCs centrais do motor estão instaladas: criação de personagem, espaços e CD de magia, inventário, condições, dano/cura, ataque, combate e consumo de ações.
- Todas as 82 funções públicas SECURITY DEFINER têm search_path fixado; rotinas de trigger não são executáveis diretamente por anon/authenticated, e o backfill legado de habilidades agora exige proprietário da ficha ou GM.
- Testes de fumaça executados: CD, progressão de espaços, reconhecimento de classe e classificação de equipamento.

Pendências reais restantes para a simulação final:

1. Executar a matriz ponta a ponta com uma campanha de teste e usuários Mestre/jogador, cobrindo ficha, permissões, movimento, iniciativa, acerto/erro, dano, PV, magia, inventário e recarga sem duplicação.
2. Revisar os avisos restantes do advisor sobre RPCs SECURITY DEFINER que são deliberadamente chamadas da aplicação autenticada; a proteção estrutural e os guards existentes devem ser validados contra cada fluxo.
3. Ativar a proteção contra senhas vazadas nas configurações de Auth do projeto Supabase, pois essa configuração não é exposta pelo conector SQL.
4. Validar visualmente o tutorial guiado e o layout da mesa com navegador compartilhado.

Nenhuma entrada foi marcada como verificada sem fonte SRD consultada, e o projeto não deve ser declarado “completo” antes dos quatro itens acima terem evidência de execução.


## Validação transacional do combate — 2026-11-02

As RPCs do ciclo de combate foram alinhadas ao esquema atual e testadas em uma transação revertida: dois monstros do catálogo SRD foram criados temporariamente, o combate foi iniciado, um ataque foi resolvido, dano e cura atualizaram HP, e o combate foi encerrado. O resultado confirmou iniciativa, defesa, log e alteração de estado sem deixar registros de teste persistidos. A pendência restante é a validação com usuários reais Mestre/jogador e interface, não mais a integração básica do banco.


## Validação do fluxo CBA — 2026-11-02

A inicialização de iniciativa usada pela interface (`iniciar_iniciativa_com_dados`) foi executada em transação revertida com três tokens sob controle do Mestre e um personagem jogador. O servidor distribuiu os três d20, calculou modificadores de Destreza e retornou a ordem esperada sem persistir o cenário de teste. Também foi corrigida uma referência de personagem de outra campanha no snapshot da campanha 13.


## Aceite de permissões no turno — 2026-11-02

Em transações revertidas, um jogador conseguiu avançar o turno quando o turno era do próprio personagem; o mesmo jogador foi rejeitado quando o turno pertencia a uma criatura do Mestre. O consumo de ação padrão foi aceito uma vez e a repetição na mesma rodada foi rejeitada pelo servidor.


## Aceite de mapa e token — 2026-11-02

Em transações revertidas, o Mestre adicionou um monstro do catálogo SRD e moveu seu token no mapa; o jogador proprietário também moveu o próprio token. As posições foram atualizadas em `tokens.col/row`, sem persistir os dados de teste.
