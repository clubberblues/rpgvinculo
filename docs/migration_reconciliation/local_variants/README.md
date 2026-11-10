# Variantes locais de migrations aplicadas

Arquivos preservados do commit anterior à reconciliação. Cada um tinha a mesma versão remota, mas hash byte a byte diferente do SQL registrado em supabase_migrations.schema_migrations.statements[1]. Os 13 casos com diferença semântica identificada foram preservados aqui; os demais diferiam por comentários, espaços, casts redundantes ou terminadores. O caminho supabase/migrations agora contém a instrução registrada como executada. Não aplicar estes arquivos; revisar e, se necessário, criar uma migration nova pelo Supabase CLI.
