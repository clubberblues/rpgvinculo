-- Lote 14: tradução de sete talentos SRD de D&D 3.5.
-- Não altera engine_status.
update public.srd_feats set nome_pt=v.nome_pt, descricao_pt=v.descricao_pt
from (values
('srd35_feat_trample','Atropelar Montado',$$Pré-requisitos: Cavalgar 1 graduação, Combate Montado.
Benefício: Quando tentar atropelar um oponente enquanto estiver montado, o alvo não pode escolher evitar você. Sua montaria pode realizar um ataque com casco contra qualquer alvo que você derrubar, recebendo o bônus padrão de +4 nas jogadas de ataque contra alvos caídos.
Especial: Um guerreiro pode escolher Atropelar Montado como um de seus talentos adicionais de guerreiro.$$),
('srd35_feat_two_weapon_defense','Defesa com Duas Armas',$$Pré-requisitos: Des 15, Combater com Duas Armas.
Benefício: Ao empunhar uma arma dupla ou duas armas (não incluindo armas naturais ou ataques desarmados), você recebe +1 de bônus de escudo na CA. Quando estiver lutando defensivamente ou usando a ação de defesa total, esse bônus de escudo aumenta para +2.
Especial: Um guerreiro pode escolher Defesa com Duas Armas como um de seus talentos adicionais de guerreiro.$$),
('srd35_feat_two_weapon_fighting','Combater com Duas Armas',$$Você pode lutar com uma arma em cada mão. Você pode realizar um ataque adicional por rodada com a segunda arma.
Pré-requisito: Des 15.
Benefício: Suas penalidades nas jogadas de ataque por lutar com duas armas são reduzidas. A penalidade da mão principal diminui em 2 e a da mão secundária diminui em 6.
Normal: Se empunhar uma segunda arma na mão secundária, você pode realizar um ataque adicional por rodada com essa arma. Ao lutar dessa forma, sofre penalidade de –6 com o ataque ou ataques normais da mão principal e penalidade de –10 no ataque com a mão secundária. Se a arma da mão secundária for leve, cada penalidade é reduzida em 2. (Um ataque desarmado é sempre considerado uma arma leve.)
Especial: Um ranger de 2º nível que tenha escolhido o estilo de combate com duas armas é considerado como possuidor deste talento, mesmo sem cumprir seu pré-requisito, mas somente quando estiver usando armadura leve ou nenhuma armadura. Um guerreiro pode escolher Combater com Duas Armas como um de seus talentos adicionais de guerreiro.$$),
('srd35_feat_weapon_finesse','Acuidade com Arma',$$Pré-requisito: Bônus Base de Ataque +1.
Benefício: Com uma arma leve, rapieira, chicote ou corrente com cravos feita para uma criatura de sua categoria de tamanho, você pode usar seu modificador de Destreza em vez do modificador de Força nas jogadas de ataque. Se estiver usando um escudo, a penalidade de armadura dele se aplica às suas jogadas de ataque.
Especial: Um guerreiro pode escolher Acuidade com Arma como um de seus talentos adicionais de guerreiro. Armas naturais são sempre consideradas armas leves.$$),
('srd35_feat_weapon_specialization','Especialização em Arma',$$Escolha um tipo de arma para o qual você já tenha escolhido o talento Foco em Arma. Você também pode escolher ataque desarmado ou agarrar como arma para os propósitos deste talento. Você causa dano adicional ao usar essa arma.
Pré-requisitos: Usar Armas com a arma escolhida, Foco em Arma com a arma escolhida, nível 4 de guerreiro.
Benefício: Você recebe +2 de bônus em todas as jogadas de dano realizadas com a arma escolhida.
Especial: Você pode escolher este talento várias vezes, mas seus efeitos não se acumulam. Cada vez, ele se aplica a um novo tipo de arma. Um guerreiro pode escolher Especialização em Arma como um de seus talentos adicionais de guerreiro.$$),
('srd35_feat_whirlwind_attack','Ataque Giratório',$$Pré-requisitos: Des 13, Int 13, Especialização em Combate, Esquiva, Mobilidade, Ataque em Movimento, Bônus Base de Ataque +4.
Benefício: Ao usar a ação de ataque total, você pode abrir mão de seus ataques normais e, em vez disso, realizar um ataque corpo a corpo com seu Bônus Base de Ataque total contra cada oponente ao seu alcance.
Ao usar Ataque Giratório, você também abre mão de quaisquer ataques adicionais ou bônus concedidos por outros talentos, magias ou habilidades.
Especial: Um guerreiro pode escolher Ataque Giratório como um de seus talentos adicionais de guerreiro.$$),
('srd35_feat_widen_spell','Ampliar Magia',$$Benefício: Você pode modificar uma magia com formato de explosão, emanação, linha ou dispersão para aumentar sua área. Todas as medidas numéricas da área da magia aumentam em 100%. Uma magia ampliada ocupa um espaço de magia três níveis acima do nível real da magia.
Magias que não tenham uma área com um desses quatro formatos não são afetadas por este talento.$$)
) as v(id,nome_pt,descricao_pt)
where public.srd_feats.id=v.id;
