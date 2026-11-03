# Fluxo local do Supabase — Vínculo RPG

Este guia prepara o repositório para que mudanças feitas diretamente no projeto Supabase sejam reconciliadas com migrações versionadas. Não contém senhas, tokens ou URLs de conexão.

## Estado verificado em 2026-11-03

- Projeto Supabase: `grrgwxcagvvafdmzsmro`.
- Branch de trabalho: `audit/dnd35-rules-alignment`.
- O repositório contém `supabase/migrations/`.
- O repositório ainda não contém `supabase/config.toml`.
- O histórico remoto possui migrações até 2026-11-03.
- A RPC `public.criar_personagem_srd_completo(..., p_identidade jsonb)` contém a validação de `familiar_id`, mas essa alteração ainda precisa ser reconciliada com o histórico versionado.
- A RPC `public.salvar_pericias_srd(text,jsonb)` valida cada ID de perícia em `srd_skills`; portanto, especializações de Atuação devem ser registros independentes para que orçamento e limite de graduações sejam calculados separadamente.

## Preparação em uma cópia local

Execute na raiz do repositório, depois de fazer checkout da branch de trabalho:

```bash
git switch audit/dnd35-rules-alignment
supabase --version
supabase init
supabase login
supabase link --project-ref grrgwxcagvvafdmzsmro
```

O `supabase init` gera `supabase/config.toml`. Revise o arquivo antes de versioná-lo; não inclua tokens ou senhas.

## Conferir histórico antes de gerar migrações

Com CLI v3, use explicitamente o alvo remoto:

```bash
supabase migration list --remote
```

Compare as versões remotas com os arquivos existentes em `supabase/migrations/`. Não use `db reset --remote`: esse comando é destrutivo e não faz parte deste fluxo.

## Reconciliar a alteração já aplicada diretamente no banco

A alteração da RPC de criação foi aplicada diretamente no banco para validação, sem uma migração correspondente. Primeiro capture o drift remoto em uma migração revisável:

```bash
supabase db pull --remote
```

Revise o SQL gerado. Ele deve conter somente as diferenças esperadas, principalmente a definição da RPC de criação. Se o diff incluir objetos não relacionados, interrompa e reconcilie em partes menores. Não envie automaticamente para produção.

## Criar migrações novas

Para alterações novas, crie o arquivo pelo CLI, nunca escolhendo manualmente o timestamp:

```bash
supabase migration new nome_descritivo
```

Escreva o SQL no arquivo criado e valide em banco local antes de publicar. Depois:

```bash
supabase db reset
supabase migration list --remote
```

O reset acima é somente local. Para publicar mudanças remotas, revise o diff e use o comando de push apropriado à versão instalada, sempre com alvo remoto explícito e confirmação humana.

## Próxima correção de regras — especializações de perícias

Não inserir ainda as especializações no banco até a migração e o modelo serem revisados. A correção deve:

1. Representar as nove categorias de Atuação como perícias distintas, cada uma com ID próprio.
2. Atualizar a lista de perícias de classe do Bardo para reconhecer as categorias corretas sem transformar todas as especialidades numa única graduação.
3. Preservar a leitura das fichas antigas que usam `srd35_skill_perform`.
4. Validar o requisito de 3 graduações em uma única categoria de Atuação para Música de Bardo.
5. Não criar tabelas duplicadas para Ofício e Profissão; as especializações dessas perícias precisam de decisão de modelagem própria, pois seus campos são abertos e não formam uma lista fechada equivalente à Atuação.

## Segurança e limites

- Nunca colocar `.env`, access tokens, senha do banco ou chave `service_role` no Git.
- Não executar `db reset --remote`.
- Não usar `db push --remote` antes de revisar as migrações e confirmar que o histórico local/remote está reconciliado.
- A existência de uma função no banco não prova que sua migração correspondente esteja versionada.
- Testes de navegador autenticado e criação de personagens de teste continuam necessários para homologar o fluxo.
