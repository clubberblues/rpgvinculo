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

## Camada visual gamificada — criação de personagem (2026-11-16)

- Aplicado em `ficha.html` um primeiro passe visual no bloco **Equipamento inicial**: cabeçalho de arsenal, escolhas de método em placas selecionáveis, estado ativo destacado, cartões de itens, marcadores visuais para resultados dos dados e animações leves de entrada/seleção.
- A direção visual mantém a paleta verde-escura, ouro envelhecido e tipografia Cinzel/EB Garamond já presentes no fluxo D&D 3.5.
- Incluída adaptação para telas estreitas e respeito a `prefers-reduced-motion`.
- A alteração é de apresentação e não introduz cálculos, consumo de munição, equipar/desequipar ou efeitos de itens.
- **Limite desta primeira entrega:** o fluxo de equipamento existente ainda usa o modelo legado de kit/catálogo/riqueza. Os campos livres repetíveis de armas, munições, proteção, objetos e itens especiais ainda não foram ligados à persistência; não apresentar esta etapa visual como substituição funcional do inventário antigo.
- Nenhuma migration, RPC ou alteração de banco foi executada.
- Verificação estática: o JavaScript inline completo de `ficha.html` foi compilado com `new Function` sem erro de sintaxe. Não foi realizado teste de navegador nem teste funcional de criação/salvamento.

## Implementação do preenchimento manual e fluxo Mago — 2026-11-16

- Substituído o passo de equipamento da criação por seis áreas com cartões repetíveis: armas, munições, armaduras/proteção, equipamentos/objetos, itens mágicos/especiais e dinheiro/tesouros.
- Cada cartão possui nome, quantidade/valor em texto livre e detalhes. Adicionar/remover registros é local à ficha; nada calcula preço, peso, atributo, bônus, cargas ou consumo.
- Munições recebem marcadores decorativos de cartuchos sem relação automática com o valor anotado.
- A riqueza inicial continua seguindo os dados da classe (Mago: 3d4 × 10 po). O resultado é registrado como riqueza inicial, sem subtrair compras ou impor catálogo.
- Os registros são enviados dentro de `p_identidade.equipment_notes` ao RPC existente de criação. A função existente mantém o JSON de identidade e grava em `srd_character_sheets.identidade`; nenhuma coluna ou tabela nova foi criada.
- Após a criação, a própria ficha exibe os mesmos cartões em modo de consulta. A edição pós-criação foi mantida desativada até existir uma RPC estreita e segura: embora exista política RLS de UPDATE para proprietário/Mestre, a role `authenticated` não possui privilégio SQL UPDATE na tabela/coluna. Não é correto contornar isso concedendo UPDATE amplo à ficha inteira.
- Removidas do caminho ativo as consultas a `srd_equipment` e `srd_starting_packages`, a leitura de equipamento equipado e os handlers antigos de equipar/desequipar. As tabelas legadas não foram apagadas.
- A revisão da criação mostra a quantidade de registros manuais e o estado da riqueza inicial.
- Mago: especialização/escolas proibidas já têm validação no cliente e no RPC de criação; Scribe Scroll é concedido automaticamente pelo RPC de talento bônus; 19 truques e 43 magias de 1º círculo estão disponíveis no catálogo atual. A UI agora respeita INT mínima 10 para truques e 11 para aprender magias de 1º círculo, alinhada ao validador existente.
- Progressão de espaços de magia do Mago e características de classe de níveis 1, 5, 10, 15 e 20 foram lidas no banco. O nível 1 inclui Invocar Familiar e Escrever Pergaminho.

### Bloqueio de backend identificado

- A lista de familiares na interface segue o SRD e oferece Doninha (`weasel`), mas o RPC de criação ainda aceita `badger` e não aceita `weasel`. Escolher Doninha fará o RPC rejeitar a criação. A escolha de familiar é opcional; a criação pode seguir sem familiar ou com outra opção atualmente aceita. É necessária migration para corrigir a allowlist no banco. Não foi alterado o banco de produção.
- O ambiente de execução não possui Supabase CLI instalado e o projeto só apresenta a branch principal do Supabase; por segurança, não foi executada alteração direta na base de produção nem criada migration sem o fluxo de CLI exigido. O mesmo bloqueio impede criar agora a RPC de salvamento seguro das anotações pós-criação.

### Verificação e limites

- JavaScript inline de `ficha.html` compilado com `new Function` sem erro após as alterações.
- Consultas read-only confirmaram RLS de UPDATE para proprietário/Mestre, persistência de `identidade` no RPC, validação de especialização e concessão automática de Escrever Pergaminho.
- Não houve teste em navegador, criação real autenticada ou teste de recarga. Portanto, o fluxo está implementado no código, mas ainda não está homologado funcionalmente.
- Nenhuma migration, RPC, tabela ou dado de produção foi alterado; sem deploy e sem PR.


### Correção de segurança do salvamento pós-criação

A auditoria de privilégios confirmou que `authenticated` não possui UPDATE em `srd_character_sheets` nem na coluna `identidade`. A política RLS existente, isoladamente, não concede esse privilégio. Por isso, a interface pós-criação foi revertida para consulta somente; o código não tenta executar um UPDATE que falharia. O próximo passo técnico é uma RPC dedicada, validando `auth.uid()` e o vínculo do proprietário/Mestre, que atualize apenas `identidade.equipment_notes` sem liberar UPDATE geral na tabela.

## Continuação — edição dos registros livres e familiar SRD (2026-11-16)

- Removido o bloqueio artificial no cliente que impedia concluir a criação ao selecionar Doninha. A opção permanece opcional e é somente registrada na identidade; não foi criado motor, controle ou automação de familiar.
- Criada no branch a migration `20261116020000_srd35_character_sheet_creation_completion.sql`. Ela substitui de forma condicionada apenas a allowlist do familiar básico no RPC existente (Doninha no lugar de Texugo) e cria a RPC estreita `salvar_anotacoes_equipamento_srd`.
- A nova RPC valida autenticação e vínculo do usuário como proprietário ou Mestre, valida os seis grupos de registros e atualiza somente `identidade.equipment_notes`. Não concede UPDATE amplo à tabela `srd_character_sheets`.
- A ficha persistida agora apresenta os seis grupos manuais como campos editáveis, permite adicionar/remover entradas e oferece salvamento explícito pela RPC dedicada. Não há cálculos ou efeitos de itens.
- A migration está apenas versionada no branch; **não foi aplicada ao Supabase de produção**. Até sua aplicação, a Doninha continuará sendo recusada pelo RPC atual e o botão de salvar anotações retornará função inexistente.
- Verificação estática após a alteração: script JavaScript inline compilado com `new Function` sem erro; verificadas presença da opção Doninha, ausência do bloqueio de cliente, presença do salvamento RPC e dos controles de edição.
- A consulta read-only confirmou que a função de criação ativa ainda contém a allowlist antiga (Texugo) e não contém a allowlist com Doninha. Nenhum dado, função ou schema de produção foi alterado.
- Ainda não houve teste em navegador/autenticado nem teste de execução da migration.

- Removido da ficha o painel/integração de ativação da Fúria do Bárbaro. A ficha não deve expor motores de ações de classe; características continuam como informações consultáveis. A remoção foi verificada estaticamente.

- Auditoria das regras de idiomas identificou a exceção do Mago: pode substituir uma escolha de idioma bônus racial por Dracônico. A interface agora oferece Dracônico quando a lista racial é restrita; a migration preparada ajusta a validação do servidor somente para Mago de 1º nível. A regra foi conferida no SRD; não aplicada à produção.

## Correção solicitada — equipamento oficial e apresentação vertical (2026-11-17)
- Registrada a decisão de não usar kits inventados nem catálogo/banco de itens para determinar equipamento inicial.
- Fonte conferida no Livro do Jogador 3.5: existe Pacote Inicial do Mago Elfo (p. 58), com equipamento específico e ouro 3d6 po. A compra individual é alternativa separada, usando Tabela 7–1: Mago 3d4 × 10 po. O livro também concede uma roupa comum gratuita à escolha entre os modelos listados.
- O pacote de Mago Elfo não deve ser aplicado a outras combinações raça/classe. Sem pacote correspondente no livro, os campos livres permanecem vazios; apresentar somente a regra de riqueza inicial da classe para compra individual.
- **Bloqueio confirmado antes de automatizar:** o RPC atual aceita apenas resultados d4 para compra individual e pacotes por IDs de catálogo. Não aceita o pacote narrativo do Mago Elfo nem a rolagem 3d6 po. Não falsificar resultados ou misturar as duas alternativas. A correção exige migration estreita no RPC; nenhuma alteração de produção foi executada.
- Aplicada em ficha.html uma camada visual vertical: painéis principais, listas de perícias, talentos, magias e pertences empilhados em uma coluna; tipografia geral modernizada e preservada a paleta verde escura/dourada do grimório aprovado. Ajustes apenas visuais, sem mudança de regra ou banco.
- Ainda falta ajustar a apresentação de perícias para espelhar mais claramente as colunas da ficha oficial e concluir a adaptação segura do salvamento do pacote oficial. Não houve teste em navegador.
