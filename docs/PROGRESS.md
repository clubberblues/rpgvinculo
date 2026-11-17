# Progresso — fichas D&D 3.5

**Atualizado:** 2026-11-16  
**Branch de trabalho:** `feature/complete-character-sheet-rework`  
**Foco atual:** Mago como primeira ficha-modelo.

## Concluído nesta sessão
- Constituição do projeto criada em `PROJECT_CHARTER.md`.
- Registro de decisões e roadmap criados.
- Especificação funcional da ficha do Mago criada em `docs/wizard-character-sheet-spec.md`.
- Especificação geral e blueprint anteriores receberam aditivo para refletir a direção atual.
- Corrigida a lista de familiares básicos do Mago/Feiticeiro no código: removido Texugo como familiar básico, adicionada Doninha; corrigidos os bônus do Rato e da Doninha; alcance de vínculo atualizado para 1 milha.
- Verificação estática confirmou a presença da Doninha, a ausência do Texugo na lista básica, os bônus corrigidos e a validação do identificador.

## Auditoria técnica em andamento
- `ficha.html` contém fluxo SRD 3.5 existente e não deve ser substituído por uma aplicação paralela.
- O fluxo atual de equipamento SRD está acoplado ao catálogo `srd_equipment`, à tabela `srd_character_equipment`, a instâncias de armas e a estados `equipado`/mão principal/secundária. Isso diverge da decisão de inventário narrativo simples e requer substituição planejada.
- O inventário legado `vinculo_inventory` também exige `item_id` de catálogo e possui coluna `equipado`; não atende sozinho ao inventário livre desejado.
- `srd_character_sheets.equipamento_inicial` é JSONB da criação inicial; não foi alterado nem reaproveitado para edição do inventário sem auditoria.
- `characters.campaign_id` é anulável e `characters.user_id` identifica o proprietário; a ficha SRD relaciona-se a `characters`. O fluxo de criação independente da mesa é tecnicamente compatível com a estrutura observada.
- As políticas existentes de leitura da ficha SRD contemplam proprietário e participantes/Mestre da campanha. Ainda falta desenhar e validar a política de edição para os novos registros de inventário livre.
- Não houve alteração no banco de produção.

## Próxima tarefa
Concluir a auditoria do modelo de persistência de todas as seções da ficha do Mago e desenhar o armazenamento correto para inventário narrativo livre e demais campos editáveis. Em seguida, implementar em branch e testar sem alterar dados de produção.
