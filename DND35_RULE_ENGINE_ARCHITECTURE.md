# Arquitetura do motor D&D 3.5

Estado em 01/11/2026: **fundação de arquitetura e esquema aplicados no Supabase de produção; catálogo e motor ainda não completos**.  
Escopo de conteúdo inicial: D&D 3.5 SRD / Open Game Content (OGL 1.0a). O Vínculo RPG permanece em catálogo separado.

## Limite de conteúdo

O motor pode representar módulos de D&D 3.5 e regras caseiras separadamente. O catálogo inicial só declara conteúdo cuja fonte/licença foi conferida. Texto integral, ilustrações, identidade de produto e conteúdo fechado dos livros não são importados sem licença apropriada. Para suplemento ou livro fechado, guardar apenas uma referência/resumo próprio até o projeto ter autorização para distribuir seu conteúdo.

## Camadas

1. **Fonte e licença** — edição, versão, licença, atribuição, URL e estado de verificação por entrada.
2. **Ruleset e módulos** — regras básicas e módulos opcionais; uma campanha escolhe explicitamente o que habilita. Vínculo RPG e house rules ficam separados.
3. **Catálogo mecânico** — raças, classes, progressões por nível, perícias, talentos e pré-requisitos, equipamentos, magias, efeitos, monstros, condições e domínios.
4. **Ficha permanente** — raça, níveis separados por classe, atributos, perícias, talentos, habilidades, grimório, magias conhecidas, escolhas de domínio e inventário.
5. **Preparação e estado de jogo** — magias preparadas, espaços gastos, usos por dia, condições/efeitos ativos, turnos, economia de ações e campanha.
6. **Resolução transacional** — valida ator/turno/alvo/requisitos, calcula resultado a partir de entradas explícitas, consome recursos e grava log num único fluxo. O resultado identifica quais regras e dados contribuíram.
7. **Interface** — mostra escolhas válidas e números derivados; não contém a fonte de verdade para cálculos ou permissões.

## Contrato de mecânica

- Um valor mecânico precisa vir do catálogo, da ficha, do estado da campanha ou de uma house rule explicitamente habilitada.
- Fórmulas não devem ser copiadas em diversos handlers HTML. O cliente pode apresentar prévia; o servidor valida recursos, turno, alcance e efeitos antes de persistir.
- Um resultado explicável registra fórmula, valores de entrada, regra aplicada, alvo, resultado, recursos consumidos e log correlacionado.
- Regra sem dados suficientes fica como resolução do Mestre e declara o dado ausente; o sistema não inventa CA, bônus, resistência ou efeito.
- Um módulo só pode ser marcado completo após cobertura de entradas e cenários de regra, não por quantidade total de linhas.
- Migração mantém leitura dos campos legados enquanto cada consumidor migra para as relações canônicas. Não apagar o formato legado até validação de equivalência e cópia dos registros.

## Personagens e progressão

- A progressão registra uma trilha por classe com nível próprio. Multiclasse não soma BBA, salvamentos, nível de conjurador, espaços ou características sem regra explícita.
- Progressão SRD nível a nível: BBA, Fortitude, Reflexos, Vontade, pontos de perícia e características. Classe, raça, talento e nível de personagem continuam sendo fontes distintas.
- Pré-requisitos de classe, talento e magia são dados consultáveis e validados ao escolher e ao subir de nível.
- Atributos derivados (modificadores, PV, CA, iniciativa, ataques, perícias e CDs) são calculados a partir de uma ficha canônica e do inventário equipado.
- NPC gerado grava uma ficha persistente com a mesma estrutura mecânica, associada ao token; o token é sua representação na cena, não um substituto de ficha.

## Conjuração

Cada trilha conjuradora conserva classe, atributo-chave, nível de conjurador, progressão e origem de cada recurso.

- **Mago:** grimório permanente e preparação por descanso/estudo; prepara apenas magias válidas do grimório e ocupa espaços compatíveis.
- **Feiticeiro e bardo:** repertório limitado de magias conhecidas; escolhem no momento de conjurar e gastam espaço diário aplicável, sem preparação de lista diária.
- **Clérigo:** lista divina preparada, duas escolhas de domínio, espaços de domínio e conversão espontânea conforme regra de alinhamento/deidade selecionada.
- **Druida:** lista preparada e conversão espontânea para Summon Nature’s Ally conforme o SRD.
- **Paladino e ranger:** início de conjuração no nível da tabela, progressão parcial e preparação divina conforme classe.
- **Classes sem conjuração básica:** não recebem espaços pela classe; talentos, itens, habilidades raciais e multiclasse são fontes separadas.
- **Habilidade similar a magia / sobrenatural / extraordinária:** acompanha seus usos e estatísticas próprios; não consome espaço de magia por analogia.
- Magia armazena componentes V/S/M/F/DF, custos, tempo, alcance, alvo/área, duração, descritor, teste de resistência, RM, ataque de toque, escalonamento e resultado. Componentes triviais não viram consumíveis automaticamente.
- Efeitos tipados podem ser automatizados quando os dados forem suficientes. O restante pede resolução explícita do Mestre, sem fingir que a magia já foi resolvida.

## Combate

O servidor é a autoridade para permissões, turno, ação usada, movimento e alteração de PV. Cada ataque segue validação de alcance/arma, rolagem, bônus, CA, acerto/erro, crítico, dano, RD/resistências e PV quando os dados necessários existirem. Ataque que erra não abre rolagem de dano. Ataque múltiplo, toque, agarrar, manobras, cobertura, ocultação e condições têm regra própria e não são simplificados para um único teste.

No tabuleiro, os cards de todos os combatentes ficam em uma faixa horizontal no rodapé. Durante o combate, a ordem visual gira a cada turno: o combatente ativo é sempre o primeiro card à esquerda e o anterior vai para o final da fila. O brilho do card e do token ativo deriva da mesma entrada de iniciativa do servidor; não se abre uma interface separada de iniciativa. O Dice abre sob o tabuleiro, somente quando solicitado, e o espaço lateral anterior permanece reservado. Controles e economia de ações ficam em coluna lateral; nenhum HUD permanente ou rolagem cobre a área central do campo.

## Cobertura e publicação dos dados

A tabela de cobertura mantém, por catálogo, contagem importada, contagem conferida, total esperado (quando o índice da fonte for verificado), estado e pendências. A quantidade atual nunca significa completo. Cada entrada precisa ter chave estável, fonte e licença; regra importada precisa ser ligada aos seus pré-requisitos, progressões e efeitos.

### Auditoria observada em 2026-11-01

- 7 raças; 11 classes; 49 perícias; 110 talentos; 1.021 equipamentos; 601 magias; 445 monstros; 7 progressões de magia; 385 arquétipos de NPC; 11 pacotes iniciais.
- A base já contém regras de combate e concessão de progresso; esses totais não garantem que todos os verbetes do SRD ou todas as mecânicas estão completos.
- As classes ainda não tinham uma relação nível a nível de características; a progressão antiga de magias estava em JSON; não existiam escolhas de domínios nem trilhas de multiclasse normalizadas.
- A nova fundação cria fontes/rulesets/módulos, proveniência por linha, livro/conhecidas/preparadas e estado de espaços, domínios, condições/efeitos, trilhas de classe, progressões normalizadas e uma auditoria explícita de cobertura.
- A fundação **não** torna automaticamente o conteúdo das tabelas completo. Importação e validação de cada categoria continuam com estado pendente até fechar a auditoria contra o índice SRD 3.5.

## Sequência e critérios de aceite

1. **Fundação e inventário:** aplicar migração sem apagar dados; classificar fonte/licença; normalizar 11 progressões por classe e as 7 progressões de magia já existentes; backfill dos personagens atuais para trilhas de uma classe.
2. **Catálogo SRD:** conferir índices oficiais/abertos e importar entradas estáveis; validar todos os campos e referências; contabilizar ausências e duplicatas.
3. **Ficha e escolhas:** ligar classes/níveis, talentos, perícias, domínios, equipamento e estados de magia à ficha e substituir gravações legadas de forma compatível.
4. **Motor:** implementar cálculos puros por módulo e RPCs autorizadas; completar ataques, ações, movimento, condições, efeitos e consumos de recursos.
5. **Interface da mesa:** remover a lista de membros redundante, uma única esteira vertical de cards em ordem do turno e HUD somente lateral.
6. **Verificação:** validar cada classe básica, conjuradores preparados e espontâneos, raça com habilidade similar a magia, talentos, equipamento, combate e permissões GM/jogador. Publicar um módulo como completo somente com matriz de regras e casos aprovados.

## Estado de pronto

O objetivo final só pode ser chamado “completo” quando cada módulo SRD habilitado tiver catálogo fonte-verificado, progressões e dependências resolvidas, sem lacunas mecânicas silenciosas; os cenários de aceite concluídos; e o estado em tempo real coincidir para Mestre e jogador. Até lá, a interface identifica o que está automatizado e o que aguarda decisão do Mestre.

## Auditoria do estado aplicado — 01/11/2026

A migração `srd35_rule_engine_foundation` foi aplicada à produção e também está versionada no repositório. Verificação pós-migração:

- 220 progressões de classe (11 classes × 20 níveis).
- 1.400 linhas de progressão de espaços (7 classes × 20 níveis × 10 círculos).
- 7 trilhas de classe existentes preservadas e normalizadas.
- 11 categorias no ledger de cobertura; todas pendentes e nenhuma entrada marcada como verificada.
- Ainda vazios: domínios e magias de domínio, características por nível, condições, efeitos tipados de magia, grimórios e estado normalizado de magias preparadas.
- Snapshot de catálogo: 7 raças, 11 classes, 49 perícias, 110 talentos, 1.021 equipamentos, 601 magias e 445 monstros. Esses totais não provam completude nem fidelidade mecânica; é necessária conferência por fonte/licença e por campo.

Logo, esta entrega define e instala a fundação relacional e os critérios de auditoria; ela não implementa ainda todos os cálculos de combate, conjuração, condições ou escolhas de personagem descritos neste documento.


## Estado verificado em 2026-11-02

A auditoria individual de catálogo foi concluída sem marcar entradas sem fonte como verificadas:

- Perícias: 50/50 entradas auditadas; source_status = verified_srd.
- Talentos: 110/110 entradas auditadas; source_status = verified_srd.
- Domínios: 22/22 entradas auditadas.
- Condições: 38/38 entradas auditadas.
- Características de classe: 131/131 níveis existentes auditados.
- Magias: 607/607 entradas auditadas; source_status = verified_srd.
- Monstros: 445/445 entradas auditadas; source_status = verified_srd.
- Equipamentos: 1.021/1.021 fontes SRD conferidas; 975 registros têm dados completos e 46 permanecem explicitamente not_applicable_or_unspecified porque o texto-fonte não fornece preço/peso aplicável. Nenhum valor foi inventado.

A auditoria genérica (srd_catalog_entry_audit) está em 1.403/1.403 entradas com estado manual_verified; a auditoria de equipamentos não possui pendências não documentadas. As tabelas de auditoria agora têm RLS e leitura pública somente, sem escrita direta pelo cliente.

O motor já possui RPCs de criação de personagem, espaços de magia, CD, inventário/equipamento, condições, dano/cura, ataque, combate e consumo de ações. As funções SECURITY DEFINER públicas tiveram search_path = public, pg_temp fixado. Testes de fumaça confirmaram CD de magia, classificação de slots, reconhecimento de classe e classificação de equipamento.

Pendências remanescentes de produto, não de auditoria de fonte: executar a matriz de cenários de aceitação ponta a ponta da ficha e da mesa; revisar os 76 avisos do linter sobre RPCs SECURITY DEFINER conforme o modelo de permissões da aplicação; e habilitar a proteção contra senhas vazadas no painel de Auth do Supabase. Esses itens não foram declarados completos sem teste/decisão correspondente.


## Correção de integração do motor — 2026-11-02

A validação ponta a ponta em transação isolada encontrou e corrigiu referências legadas ao antigo modelo de tokens. As RPCs `attack`, `start_combat`, `add_monster_to_scene`, `apply_damage`, `apply_heal`, `combat_set_turn`, `set_turn`, `end_combat` e `move_token` agora usam `tokens.col/row`, `srd_character_sheets`, `monster_instances` e `srd_monsters`. A FK de `monster_instances.monster_id` também aponta para `srd_monsters`.

Teste transacional executado com autenticação GM simulada: inclusão temporária de dois monstros SRD, início de combate, iniciativa, ataque, dano, cura e encerramento; todos os registros foram revertidos com ROLLBACK. O teste retornou ataque válido, defesa numérica, atualização de PV/HP e encerramento OK. Quando a fonte não fornece uma expressão de dano segura, o resultado informa dano pendente em vez de inventá-lo.
