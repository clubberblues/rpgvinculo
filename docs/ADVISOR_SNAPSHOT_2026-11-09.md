# Snapshot dos advisors Supabase — 2026-11-09

Projeto consultado: `grrgwxcagvvafdmzsmro`. Coleta read-only via advisors do Supabase; não houve alteração de schema, dados, permissões ou configurações.

## Segurança

| Regra | Nível | Ocorrências | Interpretação |
|---|---:|---:|---|
| `authenticated_security_definer_function_executable` | WARN | 99 | Inventário para revisão individual; o alerta não prova falha de autorização. As funções públicas precisam validar papel, campanha, propriedade e alvo no corpo, e wrappers intencionais devem ser classificados. Não revogar EXECUTE em lote. |
| `rls_enabled_no_policy` | INFO | 7 | RLS ativo sem policy nas tabelas listadas. Em tabelas privadas acessadas por funções SECURITY DEFINER, isso pode ser intencional; validar grants, schema exposto e caminho de acesso antes de criar policies. |
| `auth_leaked_password_protection` | WARN | 1 | Proteção de senha comprometida desativada no Auth. Ajuste depende de configuração do projeto no Dashboard; registrar como hardening operacional, sem alterar durante esta auditoria. |

Exemplos confirmados: as tabelas privadas `priv.srd_aoo_attacks` e `priv.srd_aoo_pending_movements` aparecem no grupo RLS sem policies. Isso, isoladamente, não é vulnerabilidade; a proteção precisa ser avaliada junto de schema exposure e ACLs. As funções SECURITY DEFINER públicas listadas pelo advisor também não devem ser tratadas como vulneráveis apenas por serem executáveis por `authenticated`: a autorização efetiva deve ser verificada por função.

## Performance

| Regra | Nível | Ocorrências | Interpretação |
|---|---:|---:|---|
| `unused_index` | INFO | 52 | Índices não observados como usados no período/estatísticas disponíveis. Não remover automaticamente: podem servir FKs, cargas pouco frequentes, integridade ou consultas ainda não executadas. |

## CI / publicação

No histórico recente de Actions, a publicação do GitHub Pages para o commit `89590799209d1c86395a65eb9ebe968087120d5d` concluiu com sucesso. Várias execuções imediatamente anteriores foram canceladas pela substituição de deploys concorrentes. Isso confirma apenas o deploy do Pages; não substitui os workflows de sintaxe, smoke ou testes de integração da aplicação.

## Decisões

1. Manter a coleta read-only; nenhuma alteração automática baseada apenas nos advisors.
2. Classificar as 99 funções por contrato de autorização e exposição, cruzando ACL, schema exposto, SECURITY DEFINER/INVOKER, chamadas transitivas e validações no corpo.
3. Revisar as 7 tabelas sem policy em conjunto com RLS, schema exposure e ACLs; não criar policy genérica.
4. Revisar os 52 índices com plano de consulta, constraints/FKs e carga real antes de qualquer remoção.
5. Habilitar proteção de senha comprometida somente após decisão explícita de configuração do Auth.
6. Reexecutar advisors após correções de segurança futuras e comparar o baseline.

**Limite da evidência:** os advisors são um sinalizador estático/estatístico, não um pentest nem prova de exploração. A ausência de alertas também não comprova segurança ponta a ponta.
