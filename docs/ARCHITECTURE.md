# Vínculo RPG — Arquitetura

## Propósito
Consolidar a arquitetura do produto sem apagar ou contradizer os documentos específicos existentes. Este documento descreve a arquitetura atual em alto nível e a arquitetura-alvo. O documento [DND35_RULE_ENGINE_ARCHITECTURE.md](../DND35_RULE_ENGINE_ARCHITECTURE.md) continua sendo a referência especializada do motor de regras D&D 3.5; [PLANO_MESTRE_MESA.md](../PLANO_MESTRE_MESA.md) preserva decisões e requisitos específicos da mesa.

## Princípios arquiteturais
1. **Preservar antes de substituir:** evoluir o sistema existente; refatorações amplas exigem evidência e plano de migração.
2. **Responsabilidade única:** interface apresenta e coleta ações; aplicação coordena casos de uso; motor aplica regras; banco mantém estado persistente e integridade.
3. **Servidor autoritativo:** permissões, turno, recursos, movimentação validada e alterações de estado devem ser confirmados no servidor.
4. **Regras explicáveis:** resultados devem permitir identificar entradas, modificadores, regra aplicada, resultado e recursos consumidos.
5. **Dados separados por domínio:** D&D 3.5 SRD e Vínculo não compartilham catálogos mecanicamente por conveniência.
6. **Compatibilidade controlada:** formatos legados permanecem até existir equivalência comprovada e migração segura.
7. **Integração testável:** cada módulo deve ter contratos e testes isolados e integrados.

## Arquitetura atual — visão conhecida
A aplicação é descrita no README como um conjunto de páginas web HTML, com páginas para entrada/lobby, ficha, mesa e dados. A interface chama serviços/RPCs do Supabase; PostgreSQL mantém campanhas, membros, personagens, fichas, tokens, catálogos e estado de jogo. Realtime e Storage são usados em partes dos fluxos descritos pelo projeto.

O código atual contém lógica distribuída entre páginas HTML/JavaScript, funções SQL/RPCs e estruturas relacionais. O grau exato de separação, duplicação e acoplamento precisa ser confirmado pelo inventário do código atual. Não presumir que a arquitetura conceitual já esteja implementada como módulos isolados.

## Arquitetura-alvo
**Experiência/apresentação:** Lobby · Mesa · Ficha · Dados · Interfaces Mestre/Jogador.

↓ 

**Aplicação/casos de uso:** Campanhas · Sessões · Turnos · Personagens · Inventário · Progressão.

↓

**Domínios e regras:** D&D 3.5 SRD | Regras próprias Vínculo | Regras de campanha.

↓

**Serviços transversais:** Autenticação · Autorização · Validação · Eventos · Realtime · Logs.

↓

**Persistência e infraestrutura:** PostgreSQL · RPCs · RLS · Storage · Supabase · GitHub · Deploy.

As camadas são limites de responsabilidade, não uma ordem para criar serviços separados. A arquitetura pode permanecer em um monólito modular enquanto isso for suficiente. Não adotar microserviços, framework novo ou reescrita do frontend sem necessidade comprovada.

## Módulos de domínio

### Produto e campanha
- Usuários, campanhas, membros e papéis.
- Criação/entrada em campanha e ciclo de vida da sessão.
- Regras e opções habilitadas por campanha.

### Personagens
- Identidade, raça, classe/trilhas, atributos, perícias, talentos e progressão.
- Ficha permanente e valores derivados.
- Propriedade, vínculo com campanha e permissões.

### Equipamentos e inventário
- Catálogo, posse, quantidade, mochila, itens equipados e efeitos.
- Regras de proficiência, mão, categoria, peso e uso.
- Inventário de personagens separado de inventário de tokens quando necessário.

### Motor D&D 3.5
- Fontes/licenças, rulesets, módulos, catálogos e progressões.
- Cálculos e resoluções de combate, testes, condições, magias e recursos.
- Dados insuficientes devem produzir resolução manual explícita, não suposição.

### Regras Vínculo
- Classes, habilidades exclusivas, talentos gerais, magias e recursos próprios.
- Catálogos e fórmulas independentes das regras SRD.

### Mesa virtual
- Cena, mapa, grid, tokens, visão, fog of war e movimentação.
- Iniciativa, turnos, economia de ações, combate e reações.
- Mestre controla criaturas sob sua responsabilidade; jogador mantém controle de suas ações de personagem conforme as regras acordadas.

### Dados e eventos
- Interface de rolagem integrada aos fluxos de jogo.
- Resultados vinculados à ação que os solicitou.
- Log de eventos de jogo e chat livre como responsabilidades distintas.

### Experiência e onboarding
- Tutoriais contextuais, menus, HUD, responsividade e acessibilidade.
- Interface não é fonte autoritativa de regras ou permissões.

## Contratos entre módulos
- A interface envia intenção e entradas explícitas; não é autoridade para decidir sucesso, dano, gasto ou permissão.
- Casos de uso validam identidade, papel, campanha, estado e pré-condições.
- Resolvedores de regras recebem dados explícitos e retornam resultado explicável.
- Operações que alteram recursos relacionados devem ser transacionais.
- Eventos/logs devem referenciar a operação que os originou, evitando duplicação ou perda de contexto.
- Dados publicados em tempo real devem derivar do estado persistido/validado.
- Valores derivados devem ter fonte canônica definida; evitar múltiplas fórmulas independentes em HTML e SQL.

## Segurança e integridade
- RLS em tabelas expostas, com políticas baseadas em propriedade e pertencimento real.
- RPCs privilegiadas com validação explícita de usuário, campanha, papel e alvo.
- SECURITY DEFINER somente quando necessário, com search_path seguro e EXECUTE mínimo.
- Nenhuma chave privilegiada no navegador.
- Operações de combate e recursos devem prevenir repetição, concorrência e consumo duplicado.
- Logs não devem substituir validação de autorização.

## Estratégia de evolução
1. Mapear os módulos reais e seus pontos de acoplamento.
2. Definir contratos antes de mover lógica.
3. Refatorar por fatias verticais pequenas, preservando compatibilidade.
4. Testar o comportamento anterior e o novo.
5. Migrar consumidores e dados somente após equivalência.
6. Remover legado apenas depois de comprovação e plano de rollback.

## Pontos a confirmar no diagnóstico de reconciliação
- Mapa real de dependências entre HTMLs, scripts, RPCs e tabelas.
- Fonte canônica de cada valor mecânico exibido na mesa/ficha.
- Limites atuais entre regras SRD e regras Vínculo.
- Uso efetivo de Realtime e Storage por fluxo.
- Fluxos ainda dependentes de dados JSON/legados.
- Testes automatizados disponíveis e lacunas.
- Estado de deploy e processo de publicação.

## Modelo de dados
Consulte [DATA_MODEL.md](DATA_MODEL.md) para fontes canônicas, relações, estruturas JSONB, compatibilidade e tabelas sem uso atual identificado.

## Mapa detalhado de integração
Consulte [INTEGRATION_MAP.md](INTEGRATION_MAP.md) para o inventário das páginas, fluxos de campanha, ficha, combate, RPCs, tabelas, Realtime e comunicação com o iframe de dados.

## Inventário de contratos RPC
Consulte [RPC_INVENTORY.md](RPC_INVENTORY.md) para nomes literais/dinâmicos, assinaturas, sobrecargas, grants e guardas estáticas.

## Validação automatizada
O primeiro workflow estático foi aprovado: [GitHub Actions run #1](https://github.com/clubberblues/rpgvinculo/actions/runs/42546411046). A cobertura atual é sintaxe de scripts inline/compartilhados e contrato de rolagem manual; integração/E2E ainda não.

## Referências
- [Arquitetura do motor D&D 3.5](../DND35_RULE_ENGINE_ARCHITECTURE.md)
- [Plano Mestre da Mesa Virtual](../PLANO_MESTRE_MESA.md)
- [README e instruções de implantação](../README.md)


## Fotografia da implementação observada — 2026-11-08

Varredura estática dos arquivos principais no HEAD observado:

| Arquivo | Tamanho aproximado | Blocos script | RPCs distintas | Referências .from() | Realtime channel/on |
|---|---:|---:|---:|---:|---:|
| mesa.html | 692 mil caracteres | 5 | 87 | 27 | 9 |
| ficha.html | 362 mil caracteres | 4 | 12 | 31 | 0 |
| lobby.html | 139 mil caracteres | 4 | 10 | 10 | 0 |
| dice.html | 214 mil caracteres | 5 | 0 | 0 | 0 |

As referências .from() são chamadas de acesso a dados/serviços detectadas estaticamente e podem incluir recursos que não são tabelas relacionais. A contagem não substitui análise de cada chamada.

### Consequências arquiteturais observadas
- A mesa concentra a maior quantidade de integrações de RPC e subscriptions Realtime; é o principal ponto de orquestração da sessão de jogo.
- Ficha e lobby também acessam diretamente múltiplos recursos Supabase.
- Os arquivos principais são páginas HTML grandes com scripts inline; portanto, a separação lógica por domínio ainda precisa ser mapeada e não deve ser presumida a partir da arquitetura-alvo.
- A primeira refatoração, se necessária, deve extrair responsabilidades com testes e contratos, sem alterar a experiência ou migrar toda a stack de uma vez.
- dice.html não mostrou chamadas diretas de RPC/tabela na varredura; isso não prova ausência de comunicação indireta por iframe, eventos ou postMessage.

### Banco observado
O snapshot atual mostra 76 relações em public e 7 em priv, com funções distribuídas entre public, priv e private. As tabelas públicas estão todas com RLS habilitado no momento da consulta. A contagem de SECURITY DEFINER é registrada em PROJECT_STATE.md e AUDIT_REGISTER.md; cada função precisa ser avaliada pelo contrato de autorização, não apenas pela classificação.

A varredura identificou 103 RPCs resolvidas chamadas por mesa.html, ficha.html e lobby.html: 100 nomes literais e 3 destinos dinâmicos de equipamento. Foram mapeadas 111 assinaturas públicas correspondentes, incluindo sobrecargas. Isso é correspondência estática; não valida tipos em runtime, semântica, autorização por papel ou execução ponta a ponta.

index.html e lobby_atualizado.html estão presentes no repositório; dex.html não foi encontrado em main no caminho consultado.

Esses números são fotografia de implementação, não arquitetura final nem critério de qualidade isolado.


## Persistência CBA e compatibilidade relacional

A mesa atual usa o estado CBA em campaigns.cba_data (JSONB), com RPCs específicas para adicionar e mover tokens, alterar PV e atualizar cena. O schema também conserva public.tokens e public.monster_instances, utilizados por RPCs relacionais antigas (movimento, ataque, dano, turno e inclusão de monstros). Os resolvedores de condições e efeitos aceitam alvos encontrados tanto no array JSON CBA quanto no modelo relacional.

Esse desenho deve ser tratado como coexistência/compatibilidade até que todos os consumidores e dados sejam mapeados. Não remover a tabela relacional nem migrar tokens para JSON ou vice-versa sem plano, equivalência, backfill, testes e rollback.


## Estado de reconciliação — 2026-11-08

| Ponto a confirmar | Estado atual |
|---|---|
| Dependências entre HTML, RPCs e tabelas | Mapa inicial e inventário RPC criados; argumentos de todos os fluxos ainda não conferidos |
| Fonte canônica dos valores mecânicos | DATA_MODEL documenta principais fontes; XP/ouro e alguns campos JSONB ainda precisam de decisão |
| Limites SRD/Vínculo | Separação de catálogos e fichas mapeada; não unificar regras |
| Realtime e Storage | 9 subscriptions mapeadas com filtros e policies; fluxos Storage de mídia/exclusão ainda exigem E2E |
| Dados JSON/legados | CBA JSONB vs tabelas relacionais, combate JSONB vs combat_state e campaign_log vs roll_log registrados |
| Testes | CI estático aprovado; Playwright/pglast e integração/E2E não reproduzíveis no repositório |
| Deploy/publicação | Processo de publicação ainda precisa de confirmação e checklist |

