# Vínculo RPG — Estratégia de testes

## Princípios
- Testar comportamento e regras, não apenas existência de código.
- Separar testes unitários, integração, autorização, interface e ponta a ponta.
- Usar ambiente/campanha descartável e dados sintéticos para cenários com escrita.
- Nunca usar personagens/campanhas reais como fixtures de teste.
- Não considerar mocks como evidência de funcionamento do Supabase remoto.
- Registrar método, ambiente, resultado e limitações de cada teste.

## Camadas de teste

### 1. Verificação estática
- Parse de HTML e JavaScript inline.
- Lint e validação de sintaxe.
- Parse de SQL/migrations.
- Verificação de referências a tabelas, RPCs e colunas.
- Busca por duplicação de fórmulas e chamadas obsoletas.

**Limite:** sintaxe válida não prova comportamento.

### 2. Testes unitários de regras
- Fórmulas e modificadores.
- Progressões por nível.
- Pré-requisitos de talentos, magias e classes.
- Proficiência e propriedades de equipamento.
- Condições, bônus tipados e empilhamento.
- Ataque, CA, crítico, dano, resistência e recursos.

Os casos devem incluir limites, valores ausentes, combinações e resultados inválidos.

### 3. Testes de banco e RPC
- Restrições, FKs e integridade.
- Atomicidade e rollback.
- Idempotência e chamadas repetidas.
- Concorrência e consumo duplicado.
- Propriedade, campanha, papel e autorização.
- Grants efetivos, RLS e search_path de funções privilegiadas.

Testes destrutivos devem ocorrer somente em ambiente descartável ou transação comprovadamente revertida.

### 4. Testes de integração
- Ficha → banco → mesa.
- Inventário/equipamento → CA/ataque/dano.
- Rolagem → resolução → log/chat.
- Iniciativa → ordem → turno → economia de ações.
- Magia → requisitos → espaço → efeito → sincronização.
- Token → movimento → grid → visibilidade → Realtime.

### 5. Testes de interface
- Mestre e jogador em papéis distintos.
- Modais, menus contextuais e controles por turno.
- Desktop e viewport reduzido.
- Teclado, toque, foco e movimento reduzido.
- Estados de carregamento, falha e reconexão.

### 6. Teste ponta a ponta multiplayer
Executar com pelo menos uma sessão autenticada de Mestre e uma de Jogador em campanha descartável:
1. Entrar na campanha e validar papéis.
2. Abrir ficha e mesa.
3. Publicar/selecionar mapa e tokens.
4. Mover tokens em exploração e combate.
5. Iniciar iniciativa com rolagens conforme as decisões de produto.
6. Executar turno, ações e reações.
7. Validar ataque, defesa, dano e atualização de PV.
8. Validar inventário/equipamento.
9. Validar magia e recursos.
10. Confirmar que ambos os clientes observam o mesmo estado.
11. Repetir ações proibidas e confirmar rejeição no servidor.
12. Encerrar combate e confirmar estado final.

## Matriz de papéis
Para cada RPC/ação relevante, testar:
- Não autenticado.
- Jogador proprietário.
- Outro jogador da campanha.
- Mestre proprietário da campanha.
- Membro de outra campanha.
- Token/ficha inexistente, duplicado ou pertencente a outra campanha.

A matriz exata deve respeitar as regras de negócio de cada ação; não aplicar um padrão genérico que conceda permissões indevidas.

## Critérios de conclusão de módulo
Um módulo só pode ser concluído quando:
- requisitos funcionais estão documentados;
- fonte canônica dos dados está definida;
- casos normais, limites e erros foram testados;
- autorização foi testada por papel;
- integração com consumidores foi validada;
- regressões relevantes passaram;
- limitações restantes estão registradas;
- documentação de estado foi atualizada.

## Registro de execução
Para cada rodada de testes, registrar data e commit; ambiente e versão; fixtures utilizadas; testes executados; resultados (passou/falhou/bloqueado); evidência reproduzível; limitações; e próxima ação.

## Distinção de evidências
- **Parse/sintaxe:** prova que o código é analisável.
- **Mock/simulação:** prova comportamento dentro do mock.
- **Teste transacional revertido:** prova comportamento do banco no contexto simulado e não persiste o cenário.
- **Teste remoto autenticado:** prova comportamento no projeto conectado com identidade válida.
- **Ponta a ponta multiplayer:** prova integração entre clientes, servidor e estado compartilhado.

Não usar uma categoria como substituta de outra.


## Inventário de automação existente — 2026-11-08

O README registra que foram executados localmente parse de HTML/JavaScript, parse PostgreSQL com pglast e smoke tests Playwright com Supabase simulado. Esses registros são evidência histórica de execução, mas não comprovam que a suíte está disponível ou reproduzível no repositório atual.

Foram procurados os caminhos convencionais package.json, playwright.config.js/ts, tests/mesa.spec.js, tests/ficha.spec.js, tests/e2e.spec.js, .github/workflows/ci.yml e supabase/config.toml; esses arquivos não foram encontrados nesses caminhos. Buscas de código por Playwright, Vitest, Jest, pglast e test.describe também não retornaram resultados. Como não foi possível listar toda a árvore do repositório por essa inspeção, a conclusão é **“harness automatizado não localizado nos caminhos convencionais”**, e não “não existem testes em nenhum lugar”.

### Próxima ação
Localizar/reconstituir os testes históricos e torná-los reproduzíveis no repositório, começando por parse estático e testes de regras sem escrita; depois criar testes transacionais e E2E em ambiente descartável.


## Primeiro resultado de CI — 2026-11-08
- Script: scripts/check-static.mjs.
- Workflow: .github/workflows/validate-static.yml.
- Execução: [GitHub Actions run #1](https://github.com/clubberblues/rpgvinculo/actions/runs/42546411046).
- Commit testado: 0a27f50f07b3f8ad53a4600661e0e304d8c4afa7.
- Resultado: **success**.
- Verificação: 9 blocos JavaScript inline/compartilhados em 5 páginas ativas; referências locais de scripts; contrato de rolagem manual do Dice.
- Limite: não testa DOM em navegador, chamadas Supabase, autorização, regras de domínio, transações ou multiplayer. É a primeira camada, não substitui testes de integração/E2E.
