-- Lote 12: tradução de oito talentos SRD de D&D 3.5.
-- Não altera engine_status.
update public.srd_feats set nome_pt=v.nome_pt, descricao_pt=v.descricao_pt
from (values
('srd35_feat_greater_weapon_focus','Foco em Arma Maior',$$Escolha um tipo de arma para o qual você já tenha escolhido Foco em Arma. Você também pode escolher ataque desarmado ou agarrar como arma para os propósitos deste talento.
Pré-requisitos: Usar Armas com a arma escolhida, Foco em Arma com a arma escolhida, nível 8 de guerreiro.
Benefício: Você recebe +1 de bônus em todas as jogadas de ataque realizadas com a arma escolhida. Esse bônus se acumula com outros bônus nas jogadas de ataque, inclusive o concedido por Foco em Arma.
Especial: Você pode escolher Foco em Arma Maior várias vezes, mas seus efeitos não se acumulam. Cada vez, ele se aplica a um novo tipo de arma. Um guerreiro precisa possuir Foco em Arma Maior com uma arma específica para obter Especialização em Arma Maior com essa arma. Um guerreiro pode escolher este talento como talento adicional de guerreiro.$$),
('srd35_feat_greater_weapon_specialization','Especialização em Arma Maior',$$Escolha um tipo de arma para o qual você já tenha escolhido Especialização em Arma. Você também pode escolher ataque desarmado ou agarrar como arma para os propósitos deste talento.
Pré-requisitos: Usar Armas com a arma escolhida, Foco em Arma Maior com a arma escolhida, Foco em Arma com a arma escolhida, Especialização em Arma com a arma escolhida, nível 12 de guerreiro.
Benefício: Você recebe +2 de bônus em todas as jogadas de dano realizadas com a arma escolhida. Esse bônus se acumula com outros bônus nas jogadas de dano, inclusive o concedido por Especialização em Arma.
Especial: Você pode escolher Especialização em Arma Maior várias vezes, mas seus efeitos não se acumulam. Cada vez, ele se aplica a um novo tipo de arma. Um guerreiro pode escolher este talento como talento adicional de guerreiro.$$),
('srd35_feat_heighten_spell','Elevar Magia',$$Benefício: Uma magia elevada possui nível de magia superior ao normal, até o máximo de 9º nível. Diferentemente de outros talentos metamágicos, Elevar Magia realmente aumenta o nível efetivo da magia modificada. Todos os efeitos que dependem do nível da magia (como a CD do teste de resistência e a capacidade de penetrar em um globo menor de invulnerabilidade) são calculados com base no nível elevado. A magia elevada é tão difícil de preparar e lançar quanto uma magia de seu nível efetivo.$$),
('srd35_feat_shield_proficiency','Usar Escudos',$$Benefício: Você pode usar um escudo e sofrer apenas as penalidades normais.
Normal: Ao usar um escudo com o qual não seja proficiente, você aplica a penalidade de armadura do escudo às jogadas de ataque e a todos os testes de perícia que envolvam movimento, incluindo testes de Cavalgar.
Especial: Bárbaros, bardos, clérigos, druidas, guerreiros, paladinos e rangers recebem automaticamente Usar Escudos como talento adicional. Eles não precisam escolhê-lo.$$),
('srd35_feat_shot_on_the_run','Tiro em Movimento',$$Pré-requisitos: Des 13, Esquiva, Mobilidade, Tiro à Queima-Roupa, Bônus Base de Ataque +4.
Benefício: Ao usar a ação de ataque com uma arma de ataque à distância, você pode se mover antes e depois do ataque, desde que a distância total percorrida não exceda seu deslocamento.
Especial: Um guerreiro pode escolher Tiro em Movimento como um de seus talentos adicionais de guerreiro.$$),
('srd35_feat_silent_spell','Magia Silenciosa',$$Benefício: Uma magia silenciosa pode ser lançada sem componentes verbais. Magias que não possuem componentes verbais não são afetadas. Uma magia silenciosa ocupa um espaço de magia um nível acima do nível real da magia.
Especial: Magias de bardo não podem ser modificadas por este talento metamágico.$$),
('srd35_feat_simple_weapon_proficiency','Usar Armas Simples',$$Benefício: Você realiza jogadas de ataque normalmente com armas simples.
Normal: Ao usar uma arma com a qual não seja proficiente, você sofre penalidade de –4 nas jogadas de ataque.
Especial: Todos os personagens, exceto druidas, monges e magos, são automaticamente proficientes com todas as armas simples. Eles não precisam escolher este talento.$$),
('srd35_feat_skill_focus','Foco em Perícia',$$Escolha uma perícia.
Benefício: Você recebe +3 de bônus em todos os testes que envolvam a perícia escolhida.
Especial: Você pode escolher Foco em Perícia várias vezes, mas seus efeitos não se acumulam. Cada vez, ele se aplica a uma perícia diferente.$$)
) as v(id,nome_pt,descricao_pt)
where public.srd_feats.id=v.id;
