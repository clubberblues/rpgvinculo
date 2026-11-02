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
3. Proteção contra senhas vazadas descartada pelo proprietário: o projeto está no plano Free, e a configuração exige Pro ou superior.
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


## Aceite de conjuração SRD — 2026-11-02

A RPC `conjurar_magia_srd` foi executada em transação revertida com a ficha de Mago nível 1: uma magia SRD preparada foi validada, o espaço foi consumido e o retorno informou a capacidade/uso restante. Nenhuma alteração de ficha de teste permaneceu persistida.


## Aceite de cura SRD — 2026-11-02

As fórmulas das magias de cura foram conferidas nas páginas SRD 3.5 do d20srd.org e registradas em `srd_spells.dados_tecnicos`, preservando os metadados de fonte existentes. O motor agora interpreta Curar Ferimentos Mínimos, Leves, Moderados, Sérios e Críticos, além de Heal, com dado, bônus por nível e limite de nível. As versões em massa também têm a fórmula verificada, mas permanecem explicitamente marcadas como `multiple_targets_pending` até o resolver de múltiplos alvos ser implementado.

O RPC `conjurar_magia_srd` foi testado em transação revertida com `srd35_cure_light_wounds`: o espaço preparado foi consumido, a cura foi rolada e o PV foi limitado ao máximo, sem persistir o cenário de teste. Fontes: [Cure Minor Wounds](https://www.d20srd.org/srd/spells/cureMinorWounds.htm), [Cure Light Wounds](https://www.d20srd.org/srd/spells/cureLightWounds.htm), [Cure Moderate Wounds](https://www.d20srd.org/srd/spells/cureModerateWounds.htm), [Cure Serious Wounds](https://www.d20srd.org/srd/spells/cureSeriousWounds.htm), [Cure Critical Wounds](https://www.d20srd.org/srd/spells/cureCriticalWounds.htm), [Heal](https://www.d20srd.org/srd/spells/heal.htm), [Mass Cure Light Wounds](https://www.d20srd.org/srd/spells/cureLightWoundsMass.htm) e [Mass Heal](https://www.d20srd.org/srd/spells/healMass.htm).


## Aceite de cura em massa — 2026-11-02

Foram instaladas as RPCs autenticadas `conjurar_magia_srd_multialvo` e `conjurar_magia_com_acao_srd_multialvo`. Elas recebem de 1 a 20 tokens, rejeitam chaves duplicadas ou inexistentes, consomem um único espaço preparado e, em combate, uma única ação padrão. O teste transacional com `Cure Light Wounds, Mass` curou um monstro animal e um personagem, respeitou o PV máximo e deixou o banco sem alterações após rollback. Execução anônima foi revogada; apenas `authenticated` pode chamar as RPCs.

O resolver identifica mortos-vivos e os trata como dano de energia positiva no fluxo de múltiplos alvos; a validação de HP e a atualização de token permanecem atômicas.

### Correção de escopo do aceite de cura em massa — 2026-11-02

Correção: o aceite executado cobre alvos vivos (personagem, NPC e monstro não-morto-vivo). A RPC detecta mortos-vivos e os rejeita explicitamente para não aplicar cura incorreta; o dano de energia positiva para mortos-vivos permanece pendente até o próximo ajuste.

## Integração da interface de cura em massa — 2026-11-02

`mesa.html` agora transforma o seletor de alvo em múltiplo somente quando `dados_tecnicos.target_mode=multiple_targets_pending`, exige pelo menos um alvo e chama `conjurar_magia_com_acao_srd_multialvo`. Magias comuns continuam usando `conjurar_magia_com_acao_srd`; a mensagem de chat registra a quantidade e os alvos atingidos.

## Aceite de cura em massa com mortos-vivos — 2026-11-02

A RPC dedicada `conjurar_magia_srd_multialvo_v2` foi aplicada e conectada à interface. Em transação revertida, `Cure Light Wounds, Mass` atingiu simultaneamente um personagem vivo e um Allip (Undead): o personagem recebeu cura limitada ao PV máximo e o morto-vivo recebeu dano de energia positiva. Um único espaço foi consumido; o banco ficou sem alterações após rollback.

## Índices de chaves estrangeiras — 2026-11-02

Foi aplicada a migração `performance_cover_public_foreign_keys`, criando cobertura de índice para as FKs públicas. O advisor deixou de reportar `unindexed_foreign_keys`; permanecem apenas avisos informativos de índices ainda sem uso observado, que não indicam falha funcional.

## Revisão das funções SECURITY DEFINER — 2026-11-02

Auditoria executada no projeto Supabase Vinculo (`grrgwxcagvvafdmzsmro`) após os avisos do advisor. Inventário do catálogo: 86 funções SECURITY DEFINER em `public`; 79 executáveis por `authenticated`, nenhuma executável por `anon`, e 7 restritas ao lado servidor. O advisor de segurança confirma 79 avisos informativos de RPC SECURITY DEFINER acessível a usuário autenticado; isso descreve a superfície de chamada, não confirma por si só uma falha de autorização.

Foi conferido o corpo das rotinas e o padrão de autorização: as RPCs da aplicação fazem checagem de autenticação e/ou pertencimento à campanha, propriedade da ficha ou papel de Mestre antes de operar. A exceção aparente, `set_turn(cid, p_token)`, valida que o token pertence à campanha informada e delega a alteração a `combat_set_turn(p_token)`, que deriva a campanha do próprio token, exige `priv.need_gm` e valida combate ativo e presença do token na ordem. Assim, não foi necessário revogar acesso de RPCs usadas pela aplicação nem alterar o fluxo. As outras funções sem guarda de usuário são rotinas de trigger, sem EXECUTE para `anon` ou `authenticated`.

Verificação pós-auditoria: privilégios efetivos consultados com `has_function_privilege`; `anon_execute=0`, `authenticated_execute=79`, `server_only=7`. Não foi aplicada alteração de schema ou permissão nesta revisão. Permanecem os avisos do advisor para RPCs autenticadas deliberadamente expostas; seu fundamento de autorização foi confirmado no banco.

## Decisão sobre proteção contra senhas vazadas — 2026-11-02

O proprietário confirmou que o projeto não possui plano Pro e decidiu descartar a ativação da proteção contra senhas vazadas. Não fazer upgrade nem ativar SMTP para esse fim. Esta opção deixa de ser uma pendência; as demais validações finais continuam em aberto.

## Matriz de fluxos da mesa e fichas — 2026-11-02

Leitura estática de `mesa.html`, `ficha.html`, `dice.html` e migrações SRD do repositório. Esta matriz registra evidência no código; “integrado” significa que há interface/handler e chamada correspondente, não aceite ponta a ponta de todos os casos.

| Papel/fluxo | Evidência existente | Situação / lacuna |
|---|---|---|
| Mestre — controlar campanha | `alternar-combate` → `alternar_estado_campanha`; tela de iniciativa, avanço de turno e ferramentas de preparação | Integrado. Matriz real de campanha e tokens ainda requer teste de sessão. |
| Mestre — preparar mapa e inserir criaturas | CBA com fundo, zoom, grade, prévia; catálogo NPC/monstros; `adicionar_token_cba_completo`, `salvar_cena_cba` | Integrado para preparação. |
| Mestre — movimento e estado de token | `mover_token_gm_cba_srd`; menu contextual permite imagem, PV, inventário e detalhes; ações de combate incluem ataque, magia preparada, movimento e encerrar turno | Parcial. Algumas ações dependem do turno ativo. Confirmar se o requisito é permitir ao Mestre executar ações fora do turno correspondente ou controlar o token quando chegar a vez dele. |
| Mestre — ações sobre token de jogador | Menu contextual de token player possui ajuste de PV e opções de ataque/movimento/ação/encerramento sob condição de turno específica | Suspeita de condição inconsistente: ramo testa turno marcado como monstro e identificador igual ao do personagem. Validar e corrigir em implementação separada. |
| Jogador — movimento e turno | Próprio token; `mover_token_player_cba`; `consumir_acao_turno_srd`; verificação do dono e turno | Há validações de servidor; movimento em exploração e combate deve ser confirmado pela matriz ponta a ponta. |
| Jogador — ataque | Botões corpo a corpo/à distância, seleção de alvo, dado e RPC `aplicar_dano_token_ataque_srd` | Fluxo existe. Confirmar todas as combinações de arma, alcance, CA, dano, crítico e mensagens de resultado; não presumir cobertura completa. |
| Jogador — magia | Ficha mantém grimório/preparação conforme classe; mesa apresenta seleção de magia e chama `conjurar_magia_com_acao_srd` ou variante multialvo | Integrado para magias e estados suportados. Habilidades de classe que não são conjuração ainda não aparecem como sistema geral de ações. |
| Jogador — perícias, testes e dados | Modal de testes, ação de perícia e `dice.html` embutido; rolagens são comunicadas pelo chat | Interface existente. Confirmar fórmula e bônus específicos da ficha em cada caminho. |
| Jogador — mochila/equipamento | `abrirInventarioSRD`, `equipar_item_srd`, uso de poção e atualização de CA | Integrado para inventário SRD e operações implementadas. |
| Criação — identidade e escolhas | Passos de identidade, atributos, perícias, talentos e tutorial; `criar_personagem_srd_completo` valida/salva escolhas | Fluxo existente. Verificar requisitos e reabertura/rascunho em teste real. |
| Criação — magia/domínios | `salvar_grimorio_srd`, `salvar_dominios_personagem_srd`; lógica de classe diferencia preparar e conhecer magias | Parcial por regras/catalogação. Não demonstra que toda capacidade de classe esteja modelada como ação. |
| Criação — equipamento inicial | `finalizar_equipamento_inicial_srd` grava método, resultados e itens | Interface e persistência existentes; precisa aceite em sessão completa. |
| Criação — PV inicial | Texto da ficha define PV inicial como dado de vida máximo + modificador de Constituição (mínimo 1) | Não há evidência aqui de rolagem do jogador para PV. A regra atual exibida é determinística; escolha da regra precisa ser confirmada antes de mudar o cálculo. |

### Próximas correções e verificações, por prioridade

1. Corrigir/confirmar o menu do Mestre sobre tokens de jogador e alinhar o RPC de ataque/ação para aceitar a autoridade GM sem permitir alteração por jogador não proprietário.
2. Fazer inventário de ações e capacidades por classe/nível (conjuração, habilidades, recursos e uso por turno) e identificar quais já têm dados, controles e validação no servidor.
3. Definir a regra de PV de nível 1 (máximo automático ou rolagem) e refletir a decisão no fluxo, salvamento e validação da ficha.
4. Executar teste ponta a ponta com duas sessões autenticadas; até lá, os fluxos listados como integrados têm evidência de código, não aceite operacional completo.


## Controle de movimento dos tokens de jogador pelo Mestre — 2026-11-02

Regra confirmada pelo proprietário: o Mestre pode controlar somente o deslocamento dos tokens de jogadores; ações de combate, magia, inventário e demais recursos continuam com o dono da ficha.

Foi corrigido `mesa.html`: o menu do Mestre mostra “Mover token do jogador” somente durante o turno do personagem e não oferece ataque, ação ou encerramento de turno para esse token. A migração `gm_move_player_tokens_on_their_turn.sql` atualiza `mover_token_gm_cba_srd` para aceitar o turno ativo do próprio token de jogador e qualquer ficha player vinculada à campanha, mantendo as validações de Mestre, campanha em combate, posição, ocupação, deslocamento e economia de movimento. As verificações SQL confirmaram que a restrição ao dono-Mestre foi removida, o controle por turno permanece, `anon` não executa a RPC e `authenticated` pode executá-la como antes.

PV inicial definido: valor máximo do dado de vida + modificador de Constituição, mínimo 1. A ficha SRD já apresenta essa regra; manter essa fórmula como referência normativa e confirmar o valor persistido pelo fluxo de criação na próxima validação autenticada.

Pendências restantes: revisar a cobertura de capacidades por classe/nível contra catálogo e RPCs; validar visualmente a mesa autenticada; executar a matriz ponta a ponta com sessões Mestre e jogador. A proteção contra senhas vazadas foi descartada pelo proprietário por indisponibilidade no plano Free.
