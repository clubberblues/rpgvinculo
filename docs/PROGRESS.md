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


## Auditoria adicional da ficha persistida
- A criação já tem etapas guiadas e validações reais, mas a ficha existente em modo campanha ainda apresenta perícias e talentos como somente leitura; identidade e atributos também não possuem edição geral. A edição integral é uma lacuna confirmada.
- A seção SRD de equipamentos exige catálogo e estados equipado/guardado, oferece ações de equipar/desequipar e consulta CA/deslocamento após alterações. Tudo isso está fora do escopo aprovado e deverá ser substituído por inventário narrativo simples.
- A etapa de equipamento da criação exige atualmente pacote ou compras no catálogo. Deve ser simplificada para orientação de riqueza e registro opcional de itens, sem catálogo obrigatório.
- A RPC `finalizar_criacao_personagem_srd` já centraliza criação, idiomas, talentos bônus, domínios, grimório e equipamento inicial em transação. Preservar e adaptar apenas quando necessário.
- Modelo proposto para inventário livre: registros vinculados a character_id com nome, descrição, quantidade opcional e observações; sem categoria, equipado, guardado ou consumível; proprietário edita, Mestre consulta. Requer migração e RLS, ainda não implementadas.
- Nenhuma alteração no banco de produção foi realizada.


## Verificação executada
- O bloco JavaScript de `ficha.html` foi compilado estaticamente com `new Function`: sem erro de sintaxe após a correção dos familiares.
- Foram verificadas as cinco condições da correção: Doninha presente, Texugo ausente da lista básica, bônus do Rato correto, Doninha aceita pela validação e alcance de 1 milha apresentado.
- Não foi executado teste de navegador nem fluxo real de criação/recarga; portanto, isso não é declarado como teste funcional.


## Correção de entendimento — equipamentos como campos manuais
A orientação anterior de criar um modelo técnico de inventário, tabela própria, estrutura de itens e lógica de persistência dedicada está cancelada. Não implementar sistema de inventário nem criar nova tabela para isso.

A interface deve ter blocos visuais específicos para armas (com várias entradas), munições, armaduras/proteção, equipamentos/objetos, itens mágicos/especiais e dinheiro/tesouros. Cada entrada é texto manual livre, editável e removível. O jogador pode acrescentar entradas durante a campanha ao receber itens do Mestre. Nenhum item altera atributos ou aciona regras.

Durante a criação do Mago, o assistente explica proficiências e equipamento inicial e orienta o registro; o preenchimento dos detalhes continua manual. A próxima auditoria visual deve inspecionar a ficha atual e referências de fichas D&D 3.5 para definir a disposição intuitiva dos campos.
