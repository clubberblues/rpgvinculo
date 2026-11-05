-- Lote 13: tradução de dez talentos SRD de D&D 3.5.
-- Não altera engine_status.
update public.srd_feats set nome_pt=v.nome_pt, descricao_pt=v.descricao_pt
from (values
('srd35_feat_snatch_arrows','Agarrar Flechas',$$Pré-requisitos: Des 15, Desviar Flechas, Ataque Desarmado Aprimorado.
Benefício: Ao usar o talento Desviar Flechas, você pode agarrar a arma em vez de apenas desviá-la. Armas arremessadas podem ser imediatamente arremessadas de volta contra o atacante original (mesmo que não seja seu turno) ou guardadas para uso posterior.
Você precisa ter pelo menos uma mão livre (sem segurar nada) para usar este talento.
Especial: Um guerreiro pode escolher Agarrar Flechas como um de seus talentos adicionais de guerreiro.$$),
('srd35_feat_spell_focus','Foco em Magia',$$Escolha uma escola de magia.
Benefício: Aumente em +1 a Classe de Dificuldade dos testes de resistência contra todas as magias da escola escolhida.
Especial: Você pode escolher este talento várias vezes, mas seus efeitos não se acumulam. Cada vez, ele se aplica a uma escola de magia diferente.$$),
('srd35_feat_spell_mastery','Maestria em Magia',$$Pré-requisito: Mago de 1º nível.
Benefício: Cada vez que escolher este talento, selecione uma quantidade de magias que você já conhece igual ao seu modificador de Inteligência. A partir de então, você pode preparar essas magias sem consultar seu grimório.
Normal: Sem este talento, você precisa usar um grimório para preparar todas as suas magias, exceto leitura mágica.$$),
('srd35_feat_spell_penetration','Penetração Mágica',$$Benefício: Você recebe +2 de bônus nos testes de nível de conjurador (1d20 + nível de conjurador) realizados para superar a Resistência à Magia de uma criatura.$$),
('srd35_feat_spirited_charge','Investida Montada Poderosa',$$Pré-requisitos: Cavalgar 1 graduação, Combate Montado, Ataque em Movimento Montado.
Benefício: Quando estiver montado e realizar uma ação de investida, você causa o dobro do dano com uma arma corpo a corpo (ou o triplo do dano com uma lança).
Especial: Um guerreiro pode escolher Investida Montada Poderosa como um de seus talentos adicionais de guerreiro.$$),
('srd35_feat_spring_attack','Ataque em Movimento',$$Pré-requisitos: Des 13, Esquiva, Mobilidade, Bônus Base de Ataque +4.
Benefício: Ao usar a ação de ataque com uma arma corpo a corpo, você pode se mover antes e depois do ataque, desde que a distância total percorrida não exceda seu deslocamento. Esse movimento não provoca ataque de oportunidade do defensor que você atacar, embora possa provocar ataques de oportunidade de outras criaturas, se apropriado. Você não pode usar este talento se estiver usando armadura pesada.
Você precisa se mover pelo menos 1,5 metro antes e depois do ataque para aproveitar os benefícios deste talento.
Especial: Um guerreiro pode escolher Ataque em Movimento como um de seus talentos adicionais de guerreiro.$$),
('srd35_feat_stealthy','Furtivo',$$Benefício: Você recebe +2 de bônus em todos os testes de Esconder-se e Furtividade.$$),
('srd35_feat_still_spell','Magia sem Gestos',$$Benefício: Uma magia sem gestos pode ser lançada sem componentes gestuais. Magias que não possuem componentes gestuais não são afetadas. Uma magia sem gestos ocupa um espaço de magia um nível acima do nível real da magia.$$),
('srd35_feat_stunning_fist','Punho Atordoante',$$Pré-requisitos: Des 13, Sab 13, Ataque Desarmado Aprimorado, Bônus Base de Ataque +8.
Benefício: Você precisa declarar que está usando este talento antes de realizar a jogada de ataque (portanto, uma jogada de ataque malsucedida desperdiça a tentativa). O Punho Atordoante obriga um inimigo atingido por seu ataque desarmado a realizar um teste de resistência de Fortitude (CD 10 + metade do seu nível de personagem + seu modificador de Sabedoria), além de sofrer o dano normal. Um defensor que fracasse nesse teste fica atordoado por 1 rodada (até imediatamente antes de sua próxima ação). Um personagem atordoado não pode agir, perde qualquer bônus de Destreza na CA e sofre –2 de penalidade na CA. Você pode tentar um ataque atordoante uma vez por dia para cada quatro níveis de personagem que possuir (veja Especial), mas nunca mais de uma vez por rodada. Constructos, limos, plantas, mortos-vivos, criaturas incorpóreas e criaturas imunes a acertos críticos não podem ser atordoados.
Especial: Um monge pode escolher Punho Atordoante como talento adicional no 1º nível, mesmo sem cumprir os pré-requisitos. Um monge que escolha este talento pode realizar ataques atordoantes por dia em quantidade igual ao seu nível de monge, mais uma tentativa adicional por dia para cada quatro níveis que possuir em outras classes. Um guerreiro pode escolher Punho Atordoante como um de seus talentos adicionais de guerreiro.$$),
('srd35_feat_tower_shield_proficiency','Usar Escudo de Corpo',$$Pré-requisito: Usar Escudos.
Benefício: Você pode usar um escudo de corpo e sofrer apenas as penalidades normais.
Normal: Um personagem que usa um escudo com o qual não seja proficiente aplica a penalidade de armadura do escudo às jogadas de ataque e a todos os testes de perícia que envolvam movimento, incluindo Cavalgar.
Especial: Guerreiros recebem automaticamente Usar Escudo de Corpo como talento adicional. Eles não precisam escolhê-lo.$$)
) as v(id,nome_pt,descricao_pt)
where public.srd_feats.id=v.id;
