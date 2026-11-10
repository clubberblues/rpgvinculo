# Variantes locais de migrations aplicadas

Arquivos preservados antes de alinhar os caminhos em supabase/migrations ao SQL executado registrado em supabase_migrations.schema_migrations.statements[1]. Cada arquivo desta pasta tinha a mesma versão remota, mas hash byte a byte diferente. Os 13 casos com diferença semântica identificada foram preservados aqui; os demais diferiam por comentários, espaços, casts redundantes ou terminadores. Não aplicar estes arquivos. Para propor alterações, revisar a variante e criar uma nova migration com novo timestamp pelo Supabase CLI.
