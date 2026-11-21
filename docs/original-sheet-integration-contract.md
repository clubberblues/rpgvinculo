# Integração do modelo original de ficha — contrato de implementação

Status: contrato de referência; implementação do Mago iniciada na branch feat/original-sheet-integration. A integração visual dos catálogos auxiliares está em andamento; validação ponta a ponta em navegador e round-trip completo permanecem pendentes.

## Decisão de produto obrigatória

O arquivo de ficha original enviado pelo usuário é o modelo canônico da ficha. Não deve ser redesenhado nem substituído pela interface de criação antiga. Após selecionar raça e classe no Lobby, a pessoa deve abrir a ficha completa original. A orientação destaca os campos pendentes diretamente nela. Catálogos são auxiliares contextuais dos campos.


## Atualização de interface aprovada pelo usuário (21/11/2026)

- O layout do modelo original permanece como interface principal e não será substituído por painéis de cartões.
- Talentos, Familiar e Grimório são títulos acionáveis que abrem catálogos auxiliares somente sob demanda.
- O catálogo de talentos mostra nome e pré-requisitos; selecionar o nome preenche uma linha textual da ficha. VER abre a descrição completa em tela de texto centralizada, sem caixa, com blur intenso no restante da interface.
- Grimório abre catálogo filtrável por círculo; selecionar uma magia preenche o campo do círculo correspondente no modelo original. A preparação continua sendo uma lista narrativa separada e não deve ser convertida em slots ou limite diário.
- Familiar apresenta as criaturas disponíveis, permite consultar a descrição e copia os dados disponíveis da criatura escolhida para os campos do modelo.
- A identidade visual deriva do próprio modelo: pergaminho, tinta escura, latão envelhecido, Cinzel e EB Garamond. Não introduzir paletas concorrentes nos catálogos.
- As escolhas durante a campanha não devem ser bloqueadas automaticamente por condições de nível ou pré-requisitos; o Mestre conduz a aplicação das regras. A validação específica da criação inicial é uma questão separada.
- As descrições devem preservar o texto-fonte e ser organizadas em blocos e parágrafos legíveis. Campos técnicos ausentes permanecem ausentes até serem verificados; não inventar dados.

## Inventário confirmado do HTML original

- 597 inputs, 4 textareas, 3 tabelas.
- 23 seções identificadas no inventário global.
- 22 painéis .panel; há ainda campos fora desses painéis (cabeçalho, atributos e grimório).
- O HTML não possui name nos campos e só tem um id de input (portrait-input).
- Não há form nem persistência de personagem.
- O título e a seção de perícias estão fixos como Mago/Feiticeiro e Perícias (Mago).
- O grimório é uma seção de múltiplos círculos, com controles próprios; não é equivalente a um único textarea.

O inventário de campos deve incluir todos os controles globais, não apenas os descendentes de .panel. Chaves por posição servem somente como identificadores técnicos temporários; não são mapeamento semântico aprovado.

## Persistência já disponível

srd_character_sheets possui classe_id, raca_id, nivel, atributos, pv_atual, pv_max, xp, ouro, talentos, magias_conhecidas, pericias_treinadas, pericias, magias_preparadas, equipamento_inicial, idiomas_conhecidos, identidade e niveis_pendentes.

characters possui identidade principal, xp, ouro, arte/retrato e campanha/usuário. XP e ouro estão duplicados entre characters e srd_character_sheets; o adaptador deve escolher uma fonte canônica ou atualizar as duas em transação/RPC, nunca salvar silenciosamente valores divergentes.

magias_preparadas JSONB pode preservar ocorrências repetidas e listas narrativas sem criar tabela nova. srd_character_prepared_spells é slot-oriented: tem prepared_for, slot_number, expended, source_track e unicidade por slot. Não deve ser usado como armazenamento canônico para a lista narrativa ilimitada definida pelo usuário.

## Regra de magia confirmada pelo usuário

- Grimório do Mago é permanente e guarda magias aprendidas.
- Todos os truques (círculo 0) permitidos entram automaticamente no grimório.
- No nível 1, escolhe 3 magias de 1º círculo + modificador positivo de INT; mínimo 3.
- Em cada avanço de nível, aprende 2 novas magias acessíveis.
- Preparação é uma lista separada, alterável durante a campanha conforme a narrativa.
- O jogador pode preparar ocorrências repetidas da mesma magia.
- Ao usar, remove manualmente uma ocorrência da lista.
- Não controlar limite diário, espaços, descanso, restauração ou consumo automático.
- Manter a validação de que a magia pertence ao grimório, à classe, ao círculo acessível e atende o atributo-chave.
- Feiticeiro não usa grimório/preparação: mantém magias conhecidas e recursos de conjuração espontânea em fluxo separado.

## Conflitos encontrados na RPC salvar_grimorio_srd

A função atual exige formato com usos; valida limites de magias conhecidas para Bardo/Feiticeiro; exige progressão e atributo-chave; exige círculos acessíveis; exige slot_level e expended para cada preparada; rejeita preparação para Bardo/Feiticeiro; aplica capacidade de espaços diários para classes preparadas; preserva estados gastos e slots de domínio.

A função não deve ser simplesmente substituída sem revisar todas as chamadas e compatibilidade. A próxima implementação deve introduzir um contrato narrativo versionado em magias_preparadas, preservar os campos legados de forma compatível e migrar o frontend por classe. Não executar atualização em massa de fichas existentes.

## Conflito adicional na mesa

mesa.html ainda trata as magias preparadas como slots de conjuração: filtra entradas expended/gasta, calcula disponibilidade e usa a RPC de conjuração para atualizar o estado. Isso também precisa ser desligado ou adaptado no fluxo do Mago quando a nova regra narrativa entrar em vigor. A mesa não pode consumir automaticamente uma ocorrência nem impor espaços diários ao Mago. O jogador deve poder remover manualmente a ocorrência da lista da ficha. A lógica de Bardo/Feiticeiro e os recursos próprios de Clérigo/Druida precisam ser avaliados separadamente antes de qualquer alteração compartilhada.

## Contrato proposto do adaptador

1. load(characterId) carrega characters, srd_character_sheets, catálogos e metadados de raça/classe.
2. hydrate(originalSheet, canonicalData) preenche os campos do modelo original sem alterar estrutura visual.
3. collect(originalSheet) coleta campos editáveis e escolhas auxiliares.
4. save(characterId, payload, expectedVersion) salva somente campos permitidos, valida ownership no servidor e atualiza updated_at/versão se existir suporte.
5. Campos calculados são derivados de dados canônicos e regras, não gravados como fonte primária quando podem divergir.
6. Campos narrativos livres (observações, equipamento não catalogado, traços raciais e idiomas) permanecem editáveis.
7. Orientação de criação usa chaves semânticas do adaptador e nunca índices de DOM.
8. Uma ficha nova de teste deve ser criada; não alterar as fichas já existentes na mesa TESTE 2.

## Critérios para liberar a integração

- IDs/chaves semânticas para cada controle editável, inclusive tabelas e grimório.
- Mapeamento de cada chave para campo canônico ou JSONB com política de edição/cálculo.
- Leitura e salvamento round-trip sem perda dos 601 controles de entrada/textarea (o input file é tratado separadamente).
- Lobby encaminha raça/classe escolhidas para o modelo original.
- Mesa abre o mesmo modelo original para consulta/edição conforme permissões.
- Testes de criação, reload, edição e compatibilidade de fichas antigas.
- Testes de Mago e Feiticeiro em fluxos separados.
- Testes de segurança: usuário só edita a própria ficha; Mestre mantém permissões existentes.

## Não fazer

- Não substituir o modelo original pela UI antiga.
- Não persistir campos por ordem de input ou índices frágeis.
- Não tornar o catálogo obrigatório para equipamento livre/narrativo.
- Não impor descanso, limite diário ou consumo automático à preparação narrativa do Mago.
- Não remover tabelas/RPCs legadas antes de identificar dependências.