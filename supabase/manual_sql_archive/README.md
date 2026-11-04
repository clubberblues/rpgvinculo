# SQL auxiliar sem versão

Arquivos SQL auxiliares, experimentais, corretivos ou de reconciliação que não têm timestamp de migração. Alguns efeitos já aparecem no banco de produção; outros são marcadores supersedidos ou propostas ainda não verificadas.

**Não executar estes arquivos em lote.** Antes de reutilizar qualquer um, comparar sua definição com o estado atual do banco e com o histórico oficial em `supabase/migrations`.