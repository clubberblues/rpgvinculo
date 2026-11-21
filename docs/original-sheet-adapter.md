# Adaptador inicial da ficha original

Este commit adiciona um adaptador isolado para o HTML original enviado pelo usuário. Ele não redesenha nem substitui campos.

## Persistência
- Armazena um snapshot versionado em `srd_character_sheets.identidade.ficha_original_v1`.
- Faz leitura antes da gravação e preserva as demais propriedades de `identidade`.
- A atualização passa pelas políticas RLS existentes; o cliente não eleva privilégios.
- Campos de arquivo/retrato são excluídos do snapshot (o arquivo de imagem exige integração de Storage própria).
- Não modifica `characters.xp/ouro`, slots de magia, fichas existentes em lote nem RPCs.

## Identificadores de campos
O adaptador prioriza `data-sheet-field`. Na ausência, gera uma chave técnica a partir do título da seção e do rótulo/contexto, acrescentando ordinal apenas quando há repetição. Campos sem rótulo semântico precisam receber `data-sheet-field` explícito antes de se tornarem parte do contrato de dados estável.

## Limite desta entrega
O arquivo-fonte visual fornecido (mago/feiticeiro) ainda precisa ser incorporado ao repositório e receber a tag `<script src="original-sheet-adapter.js"></script>`. O adaptador é infraestrutura inicial, não uma integração completa de criação/Lobby/Mesa. O snapshot JSONB permite preservar a ficha sem impor limites diários de preparação ao Mago, mas ainda não substitui o mapeamento canônico de campos nem os fluxos de criação SRD.
