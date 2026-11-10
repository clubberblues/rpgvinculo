# Arquitetura de CI e testes — estado observado em 2026-11-09

## Workflows existentes

| Workflow | Gatilhos | O que valida | Limite |
|---|---|---|---|
| `ficha-syntax-check.yml` | push/PR em ficha, lobby ou workflow | Sintaxe de JavaScript inline em `ficha.html` e `lobby.html`, Node 20 | Não valida SQL, contratos RPC ou runtime autenticado |
| `mesa-syntax-check.yml` | push/PR em mesa ou workflow | Sintaxe de JavaScript inline em `mesa.html`, Node 20 | Não valida fluxo funcional, banco ou concorrência |
| `validate-static.yml` | push/PR em HTML/JS/scripts e dispatch | Sintaxe de 5 páginas + `vinculo-ui.js`; invariantes do dado manual e chamadas proibidas de `roll_dice`; Node 22 | Sobrepõe parte dos dois workflows de sintaxe; não valida SQL |
| `pages-smoke-check.yml` | push em páginas públicas e dispatch | HTTP 200, título, idioma, viewport e corpo não vazio via Playwright 1.55.0 | Só roda contra GitHub Pages publicado; não autentica, não interage com Supabase e não altera dados |

| `postgres-fixture-tests.yml` | PR/push em `tests/sql/**` e dispatch | Executa fixtures SQL sintéticas em PostgreSQL 17 descartável | Não executa RPCs reais, Auth, PostgREST ou RLS do projeto |
| `supabase-migration-replay.yml` | PR em `supabase/migrations/**` e dispatch | Inicializa Supabase local descartável e tenta reproduzir todas as migrations versionadas | Bloqueado pela ausência de bootstrap/schema-base; não conecta ao remoto |

## Observações confirmadas

- Existem seis workflows no repositório.
- Não existe `supabase/config.toml`, `package.json`, diretório `tests/` nem configuração Playwright/Vitest/Jest dedicada ao banco.
- O smoke test instala Playwright no próprio job sem lockfile de dependências.
- Node 20 é usado em dois workflows; Node 22 em `validate-static`. A versão de Node não está centralizada.
- A verificação de dado manual é um contrato de produto importante: impede regressões que façam rolagens automáticas e confirma a integração de iniciativa/ataque com o dado físico/3D.
- Há um workflow de replay local das migrations, mas ele não consegue completar o reset em banco vazio enquanto o schema-base anterior à primeira migration não for recuperado. Não há deploy automático para produção.
- As fixtures PostgreSQL cobrem lógica transacional sintética, não grants/RLS ou RPCs reais com usuários autenticados.

## Arquitetura-alvo por camadas

### 1. Validação rápida por pull request
- Consolidar a extração/sintaxe de scripts inline de mesa, ficha, lobby, dice e páginas ativas em um workflow principal.
- Fixar uma única versão de Node LTS e dependências por lockfile.
- Preservar os testes de invariantes de dado manual, iniciativa e ausência de `roll_dice` em páginas ativas.
- Manter smoke test de publicação separado, pois depende da versão hospedada no Pages.

### 2. Validação SQL isolada
- Adicionar `supabase/config.toml` somente quando o baseline estiver reconciliado.
- Criar banco PostgreSQL/Supabase descartável que represente a arquitetura remota atual.
- Validar sintaxe, dependências, grants, RLS, search_path, triggers, constraints e índices.
- Rodar migrations somente nesse ambiente e exigir que a sequência reproduza o snapshot aceito.
- Não usar `main` de produção como alvo de teste.

### 3. Testes de contrato RPC
- Executar com pelo menos dois usuários de teste: GM e jogador.
- Validar cada RPC pública com papel correto, papel incorreto, campanha incorreta, personagem de terceiro e payload inválido.
- Verificar transação/rollback e idempotência em retries.
- Garantir que helpers internos não precisem de grants públicos amplos.
- Cobrir especificamente o bypass de AOO identificado: chamada direta do RPC de movimento, fila pending global, janela TOCTOU e ordem de locks.

### 4. Testes E2E autenticados
- Fluxo de lobby → campanha → ficha → mesa.
- Iniciativa: rolagem física individual de jogadores, rolagens do GM distribuídas entre NPCs e bloqueio até todos os jogadores responderem.
- Turno, economia de ações, movimento, AOO, ataques, dano, magias e descanso.
- Testar viewport desktop/mobile e sincronização Realtime sem alterar personagens reais.

### 5. Gates de release e drift
- Comparar versões locais com `supabase_migrations.schema_migrations` e bloquear deploy quando houver drift não classificado.
- Comparar fingerprints do schema remoto com baseline aprovado.
- Exigir testes de contrato/RLS e smoke test antes de release.
- Publicar um relatório único por PR/release, não um relatório para cada microetapa.

## Sequência recomendada

1. Terminar a reconciliação de migrations e validar o snapshot DDL atual.
2. Definir baseline reproduzível e ambiente descartável com custo conhecido/aprovado.
3. Implementar testes de contrato RPC, começando pelo P1 de movimento/AOO.
4. Consolidar workflows estáticos e centralizar Node/dependências.
5. Adicionar E2E autenticado e testes concorrentes.
6. Ativar gate de drift antes de permitir deploy de migrations.

## Restrições

- Não criar workflow que aplique migrations automaticamente em produção.
- Não incluir credenciais Supabase em logs, artefatos ou arquivos do repositório.
- Não executar testes mutáveis em personagens reais nem em TESTE 2.
- Não remover workflows sobrepostos antes de verificar todos os seus gatilhos e a cobertura que oferecem.
- Não gerar baseline executável a partir apenas do snapshot descritivo: owners, ACLs, policies, funções, triggers, tipos, defaults e ordem de dependência devem ser reconciliados.


## Execução sem custo adicional — decisão de arquitetura 2026-11-09

A restrição financeira do projeto é **zero gasto adicional com infraestrutura**. Não criar projeto/branch Supabase pago, não ativar serviços externos pagos e não exigir contratação para continuar a auditoria.

Caminho de testes adotado:
1. **GitHub Actions público + serviço PostgreSQL efêmero:** usar container `postgres` fornecido pelo próprio runner para testes de SQL isolados, com descarte automático ao final do job. Não conectar o job ao banco real.
2. **Fixtures mínimas e explícitas:** criar apenas tabelas, funções auxiliares e dados necessários ao caso testado; simular `auth.uid()`/papéis quando o caso não exigir o runtime Supabase completo.
3. **Testes estáticos locais/CI:** parse de SQL/JS, análise de contratos, fingerprints e invariantes sem mutar o banco remoto.
4. **Testes Supabase específicos:** quando dependerem de Auth, RLS/PostgREST, Realtime ou extensões Supabase, manter como bloqueados até existir um caminho gratuito e seguro; não substituir a evidência ausente por teste em produção.

O PostgreSQL efêmero é adequado para testar lógica transacional/locks e fixtures controladas, mas não prova compatibilidade integral com Supabase Auth, PostgREST, Realtime, Storage ou configuração de projeto. Os testes devem declarar exatamente o que simulam.

A sequência não depende de uma nova branch Supabase: primeiro montar fixtures mínimas para a regressão P1 AOO; depois expandir gradualmente o harness conforme cada dependência for compreendida. Qualquer operação destrutiva no banco conectado permanece proibida durante testes.


### Confirmação de custo do runner — 2026-11-09

O repositório `clubberblues/rpgvinculo` foi confirmado como **público**. A documentação oficial do GitHub informa que o uso de runners GitHub-hosted padrão em repositórios públicos é gratuito; runners maiores são cobrados. Portanto, o harness deve usar somente `ubuntu-latest` padrão e um serviço PostgreSQL efêmero no job, sem larger runners, Codespaces, GitHub Sandbox, serviços gerenciados adicionais ou runners self-hosted pagos. Referência: [GitHub Actions billing](https://docs.github.com/en/billing/concepts/product-billing/github-actions).

O workflow deve ter limites de tempo e não publicar artifacts com dados de campanha. As fixtures serão sintéticas e descartadas ao fim do job.


## Estado do replay integral — 2026-11-10

- O repositório contém 969 arquivos de migration; o ledger remoto contém 966 versões já aplicadas. As três migrations novas da branch são candidatas pendentes e não foram aplicadas no remoto.
- O workflow de replay passou a calcular dinamicamente a contagem de migrations para evitar a regressão do valor fixo 966.
- O replay em banco vazio permanece bloqueado porque o conjunto versionado começa com migrations incrementais que alteram objetos preexistentes, incluindo `public.campaigns`. O bootstrap original ainda não foi localizado.
- Não criar tabelas mínimas artificiais para fazer o CI passar. Recuperar dump/schema-base confiável, validar proveniência e então executar replay integral em ambiente descartável.
