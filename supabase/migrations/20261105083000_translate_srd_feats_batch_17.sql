-- Lote 17: tradução integral do talento Liderança (D&D 3.5 SRD).
-- Não altera engine_status.
update public.srd_feats
set nome_pt='Liderança',
descricao_pt=$$Pré-requisito: 6º nível de personagem.
Benefício: Este talento permite que o personagem atraia companheiros leais e seguidores dedicados, subordinados que o auxiliam. Consulte a tabela abaixo para determinar o tipo de aliado e a quantidade de seguidores que pode recrutar.
Modificadores de Liderança: Diversos fatores podem alterar a pontuação de Liderança do personagem em relação ao valor básico (nível do personagem + modificador de Carisma). A reputação do personagem, do ponto de vista do aliado ou seguidor que ele tenta atrair, aumenta ou reduz sua pontuação:
Reputação do líder — Modificador: grande renome +2; justiça e generosidade +1; poder especial +1; fracasso –1; distanciamento –1; crueldade –2.
Outros modificadores ao atrair um aliado: possui familiar, montaria especial ou companheiro animal –2; recruta aliado de tendência diferente –1; causou a morte de um aliado –2 por aliado morto (cumulativo).
Modificadores ao atrair seguidores: possui fortaleza, base de operações, sede de guilda ou semelhante +2; viaja ou muda de local com frequência –1; causou a morte de outros seguidores –1.
Tabela de Liderança:
Pontuação | Nível do aliado | Seguidores de 1º, 2º, 3º, 4º, 5º e 6º níveis:
1 ou menos | — | nenhum;
2 | 1º | nenhum;
3 | 2º | nenhum;
4 | 3º | nenhum;
5 | 3º | nenhum;
6 | 4º | nenhum;
7 | 5º | nenhum;
8 | 5º | nenhum;
9 | 6º | nenhum;
10 | 7º | 5, 0, 0, 0, 0, 0;
11 | 7º | 6, 0, 0, 0, 0, 0;
12 | 8º | 8, 0, 0, 0, 0, 0;
13 | 9º | 10, 1, 0, 0, 0, 0;
14 | 10º | 15, 1, 0, 0, 0, 0;
15 | 10º | 20, 2, 1, 0, 0, 0;
16 | 11º | 25, 2, 1, 0, 0, 0;
17 | 12º | 30, 3, 1, 1, 0, 0;
18 | 12º | 35, 3, 1, 1, 0, 0;
19 | 13º | 40, 4, 2, 1, 1, 0;
20 | 14º | 50, 5, 3, 2, 1, 0;
21 | 15º | 60, 6, 3, 2, 1, 1;
22 | 15º | 75, 7, 4, 2, 2, 1;
23 | 16º | 90, 9, 5, 3, 2, 1;
24 | 17º | 110, 11, 6, 3, 2, 1;
25 ou mais | 17º | 135, 13, 7, 4, 2, 2.
Pontuação de Liderança: A pontuação básica de Liderança de um personagem é igual ao seu nível mais qualquer modificador de Carisma. Para considerar modificadores negativos de Carisma, a tabela permite pontuações muito baixas, mas o personagem ainda precisa ser de 6º nível ou superior para adquirir este talento. Fatores externos podem alterar a pontuação, conforme descrito acima.
Nível do aliado: O personagem pode atrair um aliado de até o nível indicado. Independentemente da pontuação de Liderança, só pode recrutar um aliado que esteja pelo menos dois níveis abaixo dele. O aliado deve receber equipamento apropriado para seu nível. O personagem pode tentar atrair um aliado de raça, classe e tendência específicas. A tendência do aliado não pode ser oposta à do líder em nenhum dos eixos (ordem versus caos ou bem versus mal), e o líder sofre penalidade de Liderança se recrutar um aliado de tendência diferente da sua.
Aliados recebem XP assim: não contam como membros do grupo para determinar a XP do grupo. Divida o nível do aliado pelo nível do personagem jogador associado (o personagem com Liderança que o atraiu). Multiplique o resultado pelo total de XP concedido ao personagem jogador e some essa quantidade ao total do aliado. Se o aliado ganhar XP suficiente para alcançar um nível apenas um nível abaixo do personagem jogador associado, ele não sobe para esse novo nível; seu total de XP fica 1 ponto abaixo da quantidade necessária para alcançar o próximo nível.
Quantidade de seguidores por nível: O personagem pode liderar até a quantidade indicada de personagens de cada nível. Seguidores são semelhantes a aliados, mas geralmente são PdMs de nível baixo. Como normalmente estão cinco ou mais níveis abaixo do personagem que seguem, raramente são eficazes em combate.
Seguidores não recebem experiência e, portanto, não sobem de nível. Entretanto, quando um personagem com Liderança alcança um novo nível, o jogador consulta a tabela acima para determinar se adquiriu mais seguidores, alguns dos quais podem ser de nível superior ao dos seguidores existentes. A tabela não é consultada para determinar se o aliado sobe de nível, pois aliados recebem experiência por conta própria.$$ 
where id='srd35_feat_leadership';
