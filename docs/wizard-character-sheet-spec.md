# Especificação de ficha — Mago D&D 3.5

**Status:** primeira ficha-modelo em definição e implementação  
**Escopo:** personagem Mago de nível 1–20, classe única, regras D&D 3.5.

## 1. Objetivo

Construir o Mago como primeira implementação real da ficha-base compartilhada. Reaproveitar o fluxo e o armazenamento já existentes em vez de criar uma aplicação ou grimório paralelo. A ficha deve orientar a criação, explicar as escolhas e depois permanecer integralmente editável.

## 2. Princípio de funcionamento

- **Criação:** fluxo guiado, sequencial, com explicações, opções válidas, pré-requisitos e validações das regras de criação.
- **Ficha de campanha:** documento completo, consultável e editável pelo jogador. Todos os registros pertinentes podem ser adicionados, alterados ou apagados.
- **Mestre:** clicar no token abre a ficha daquele personagem, sem painel de ações.
- **Jogador:** acessa a própria ficha e a rolagem de dados. A ficha não executa testes, ataques, conjurações ou habilidades.
- **Inventário:** lista narrativa de itens. Cada registro pode ter nome, descrição, quantidade e anotações livres. Não classificar em equipado/guardado/consumível e não aplicar efeitos ou bônus de itens aos atributos.

## 3. Estrutura visual e conteúdo

### A. Identidade e descrição
- Nome do personagem e jogador (o vínculo do jogador pode vir do perfil autenticado).
- Raça, classe, nível, tendência, divindade quando aplicável.
- Sexo, idade, altura, peso, aparência, personalidade, história, origem, retrato/ilustração opcional.
- Experiência atual e observações de progressão.

### B. Atributos
- Força, Destreza, Constituição, Inteligência, Sabedoria e Carisma.
- Valor base, ajuste racial, valor final e modificador, com origem dos valores identificável.
- Método de geração escolhido para a campanha e registro do resultado.
- A ficha apresenta os valores; não tenta interpretar efeitos narrativos externos.

### C. Resumo de personagem e combate (informativo)
- Pontos de vida e dado de vida.
- Classe de armadura e componentes registrados/derivados da criação.
- Iniciativa, deslocamento, tamanho.
- Bônus base de ataque e ataques/armas registrados.
- Fortitude, Reflexos e Vontade.
- Valores necessários para consulta e rolagens manuais. Não há execução de ataques, testes ou combate.

### D. Perícias
- Lista de perícias, atributo-chave, graduações, custo, classe/fora de classe e modificadores pertinentes.
- Na criação, orientar pontos disponíveis, limites e custos conforme nível e Inteligência.
- Após a criação, permitir editar graduações e anotações sem obrigar o usuário a refazer o assistente; sinalizar inconsistências de regra quando útil, sem bloquear registros narrativos.

### E. Talentos
- Talentos escolhidos, descrição em português, fonte, nível em que foi adquirido e escolhas/parâmetros exigidos.
- Na criação/progressão, orientar quantidade, pré-requisitos e talentos bônus de Mago.
- Permitir registrar talentos adquiridos durante a campanha.

### F. Raça e classe
- Características raciais completas pertinentes à raça escolhida.
- Características de Mago pertinentes ao nível, com descrição e nível de aquisição.
- Proficiências, perícias de classe, dado de vida, progressões e demais informações específicas.
- Não criar botões para ativar habilidades nem aplicar efeitos durante a sessão.

### G. Grimório e magia do Mago
- Grimório com magias registradas por círculo, nome, descrição e anotações.
- Distinguir claramente magias copiadas/aprendidas e magias preparadas, pois são informações distintas do Mago.
- Registrar escolas, especialização e escolas proibidas, quando aplicável.
- Registrar espaços de magia por círculo e informações de conjuração pertinentes ao nível e à Inteligência.
- Permitir anotações sobre origem, custo, tempo de aprendizado, cópia e outras circunstâncias de campanha.
- Familiar opcional, com espécie, nome e informações próprias.
- Nenhum botão de conjurar, gastar espaço, resolver magia ou aplicar efeito. A preparação é um registro da ficha, não uma execução de jogo.

### H. Equipamentos e inventário
- Lista livre de itens pertencentes ao personagem.
- Campos simples: nome, descrição, quantidade opcional, peso/valor se o jogador quiser registrar, observações.
- Não exigir categoria, estado equipado/guardado/consumível, cargas controladas, integração com catálogo completo ou aplicação automática de efeitos.
- O jogador pode adicionar, editar e apagar itens durante a campanha.

### I. Idiomas, recursos e registros
- Idiomas e alfabetização quando aplicável.
- Dinheiro e tesouros como registros editáveis.
- Anotações, contatos, pistas, conquistas, acontecimentos e informações narrativas.
- Campos adicionais pertinentes à ficha física de D&D 3.5, sem automatizar a sessão.

## 4. Etapas propostas para criação

1. Identidade e conceito.
2. Raça e características raciais.
3. Classe Mago e explicação de suas regras.
4. Atributos e modificadores.
5. Perícias.
6. Talentos e escolhas exigidas.
7. Especialização arcana, escolas proibidas e familiar.
8. Grimório inicial e preparação inicial, conforme regras aplicáveis.
9. Equipamento e riqueza inicial (registro simples; sem motor de itens).
10. Revisão integral, explicação dos resultados e confirmação.

A ordem pode ser ajustada após a auditoria do fluxo existente, mas nenhum conteúdo necessário pode ser omitido. A criação deve salvar progresso sem exigir que todas as etapas sejam concluídas numa única sessão.

## 5. Regras do Mago que exigem validação

Conferir diretamente no Livro do Jogador/SRD 3.5 antes de implementar:
- Dado de vida d4; BBA baixo; Vontade boa; Fortitude e Reflexos baixos.
- 2 + modificador de Inteligência pontos de perícia por nível (×4 no primeiro nível).
- Perícias de classe e proficiências.
- Progressão de magias por círculo e espaços por nível; requisito de Inteligência para conjurar; magias bônus por Inteligência.
- Grimório inicial, truques, magias iniciais de 1º círculo e aquisição de duas magias por nível subsequente, respeitando círculos que pode conjurar e escolas proibidas.
- Especialização: escola escolhida, escolas proibidas, exceção de Adivinhação, efeitos da especialização e permanência da escolha.
- Familiar opcional e regras completas de familiar, incluindo espécie, estatísticas e progressão.
- Escrever Pergaminho no 1º nível e talentos bônus de Mago nos níveis 5, 10, 15 e 20; escolhas e pré-requisitos.
- Talentos gerais por nível de personagem, distintos dos talentos bônus de classe.
- Progressão completa até o nível 20.

Os dados catalogados atualmente marcados `derived_pending_review` ou `needs_implementation` não podem ser tratados como validados apenas por estarem no banco.

## 6. Persistência e edição

Auditar e reutilizar o fluxo existente de ficha e grimório. Não criar tabelas ou RPCs paralelas antes de provar que a estrutura atual não atende.

Para cada seção, verificar:
- criação e gravação;
- recarga após sair e entrar;
- inclusão de novos registros;
- edição de registros existentes;
- exclusão quando aplicável;
- vínculo correto ao personagem e controle de propriedade;
- apresentação completa para jogador e Mestre.

A edição cotidiana deve ser simples e independente do assistente de criação. O usuário deve poder editar livremente as anotações e registros da campanha.

## 7. Fora do escopo
- Motor de combate, ataques, dano e turnos.
- Execução de testes, perícias ou rolagens pela ficha.
- Conjuração automatizada e consumo automático de espaços.
- Ativação de habilidades, talentos ou características.
- Cálculo automático de efeitos de armas, armaduras, itens mágicos ou inventário.
- Classificação obrigatória de itens em equipados, guardados ou consumíveis.
- Automação de regras narrativas ou decisões do Mestre.

## 8. Critérios de aceite da primeira ficha-modelo

- Criar um Mago de 1º nível pelo fluxo guiado.
- As escolhas e consequências são explicadas e as regras aplicáveis são validadas.
- Todas as seções acima aplicáveis estão presentes.
- Salvar, sair e recarregar preserva os dados.
- Jogador consegue adicionar, editar e apagar registros da ficha durante a campanha.
- Grimório, preparação, especialização, escolas proibidas e familiar são preservados corretamente.
- Inventário funciona como lista narrativa editável, sem cálculo automático.
- Jogador tem somente acesso à ficha e rolagem de dados no painel.
- Clicar no token como Mestre abre a ficha correspondente.
- Nenhuma automação de sessão foi introduzida.
