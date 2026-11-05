-- Lote 11: tradução de dez talentos SRD de D&D 3.5.
-- Não altera engine_status; tradução não equivale a implementação.
update public.srd_feats set nome_pt=v.nome_pt, descricao_pt=v.descricao_pt
from (values
('srd35_feat_point_blank_shot','Tiro à Queima-Roupa',$$Benefício: Você recebe +1 de bônus nas jogadas de ataque e dano com armas de ataque à distância contra alvos a até 9 metros.
Especial: Um guerreiro pode escolher Tiro à Queima-Roupa como um de seus talentos adicionais de guerreiro.$$),
('srd35_feat_precise_shot','Tiro Preciso',$$Pré-requisito: Tiro à Queima-Roupa.
Benefício: Você pode disparar ou arremessar armas de ataque à distância contra um oponente envolvido em combate corpo a corpo sem sofrer a penalidade padrão de –4 na jogada de ataque.
Especial: Um guerreiro pode escolher Tiro Preciso como um de seus talentos adicionais de guerreiro.$$),
('srd35_feat_quick_draw','Saque Rápido',$$Pré-requisito: Bônus Base de Ataque +1.
Benefício: Você pode sacar uma arma como ação livre, em vez de ação de movimento. Você pode sacar uma arma escondida (veja a perícia Prestidigitação) como ação de movimento.
Um personagem com este talento pode arremessar armas na sua cadência normal máxima de ataques, como um personagem que usa arco.
Normal: Sem este talento, sacar uma arma exige uma ação de movimento ou, se seu BBA for +1 ou maior, pode ser feito como ação livre durante o movimento. Sacar uma arma escondida exige uma ação padrão.
Especial: Um guerreiro pode escolher Saque Rápido como um de seus talentos adicionais de guerreiro.$$),
('srd35_feat_quicken_spell','Acelerar Magia',$$Benefício: Lançar uma magia acelerada é uma ação livre. Você pode realizar outra ação, inclusive lançar outra magia, na mesma rodada em que lançar uma magia acelerada. Você só pode lançar uma magia acelerada por rodada. Uma magia cujo tempo de execução seja superior a uma ação de rodada completa não pode ser acelerada. Uma magia acelerada ocupa um espaço de magia quatro níveis acima do nível real da magia. Lançar uma magia acelerada não provoca ataques de oportunidade.
Especial: Este talento não pode ser aplicado a magias lançadas espontaneamente (incluindo magias de feiticeiro, bardo e magias de clérigo ou druida lançadas espontaneamente), pois aplicar um talento metamágico a uma magia lançada espontaneamente aumenta automaticamente seu tempo de execução para uma ação de rodada completa.$$),
('srd35_feat_rapid_reload','Recarga Rápida',$$Escolha um tipo de besta: de mão, leve ou pesada.
Pré-requisito: Usar Armas (tipo de besta escolhido).
Benefício: O tempo necessário para recarregar o tipo de besta escolhido é reduzido para uma ação livre (besta de mão ou leve) ou uma ação de movimento (besta pesada). Recarregar uma besta ainda provoca um ataque de oportunidade.
Se você escolheu este talento para besta de mão ou besta leve, pode disparar essa arma tantas vezes em uma ação de ataque total quantas poderia atacar se estivesse usando um arco.
Normal: Um personagem sem este talento precisa de uma ação de movimento para recarregar uma besta de mão ou leve, ou de uma ação de rodada completa para recarregar uma besta pesada.
Especial: Você pode escolher Recarga Rápida várias vezes. Cada vez, o talento se aplica a um novo tipo de besta. Um guerreiro pode escolher Recarga Rápida como um de seus talentos adicionais de guerreiro.$$),
('srd35_feat_rapid_shot','Tiro Rápido',$$Pré-requisitos: Des 13, Tiro à Queima-Roupa.
Benefício: Você pode realizar um ataque adicional por rodada com uma arma de ataque à distância. Esse ataque é feito com seu maior Bônus Base de Ataque, mas todos os ataques realizados na rodada — o adicional e os normais — sofrem penalidade de –2. Você precisa usar a ação de ataque total para aproveitar este talento.
Especial: Um guerreiro pode escolher Tiro Rápido como um de seus talentos adicionais de guerreiro. Um ranger de 2º nível que tenha escolhido o estilo de combate com arco é considerado como possuidor de Tiro Rápido, mesmo sem cumprir seus pré-requisitos, mas somente quando estiver usando armadura leve ou nenhuma armadura.$$),
('srd35_feat_ride_by_attack','Ataque em Movimento Montado',$$Pré-requisitos: Cavalgar 1 graduação, Combate Montado.
Benefício: Quando estiver montado e realizar uma ação de investida, você pode se mover e atacar como em uma investida normal e, em seguida, continuar seu movimento em linha reta. Seu deslocamento total na rodada não pode exceder o dobro do deslocamento da montaria. Você e sua montaria não provocam um ataque de oportunidade do oponente que foi atacado.
Especial: Um guerreiro pode escolher Ataque em Movimento Montado como um de seus talentos adicionais de guerreiro.$$),
('srd35_feat_run','Corrida',$$Benefício: Ao correr, você se desloca cinco vezes seu deslocamento normal (se estiver usando armadura média, leve ou nenhuma armadura e carregando, no máximo, carga média) ou quatro vezes seu deslocamento (se estiver usando armadura pesada ou carregando carga pesada). Se fizer um teste de Saltar após começar com uma corrida, recebe +4 de bônus nesse teste. Enquanto corre, você mantém seu bônus de Destreza na Classe de Armadura.
Normal: Sem este talento, você se desloca quatro vezes seu deslocamento ao correr (se estiver usando armadura média, leve ou nenhuma armadura e carregando, no máximo, carga média) ou três vezes seu deslocamento (se estiver usando armadura pesada ou carregando carga pesada), e perde seu bônus de Destreza na Classe de Armadura.$$),
('srd35_feat_scribe_scroll','Escrever Pergaminho',$$Pré-requisito: Nível de conjurador 1º.
Benefício: Você pode criar um pergaminho de qualquer magia que conheça. Escrever um pergaminho exige um dia para cada 1.000 PO de seu preço-base. O preço-base de um pergaminho é igual ao nível da magia × seu nível de conjurador × 25 PO. Para escrever o pergaminho, você precisa gastar XP equivalente a 1/25 desse preço-base e utilizar matérias-primas que custem metade do preço-base.
Um pergaminho que armazene uma magia com componente material caro ou custo em XP também incorpora esse custo correspondente. Além dos custos calculados a partir do preço-base, você precisa fornecer o componente material ou pagar o custo em XP ao escrever o pergaminho.$$),
('srd35_feat_self_sufficient','Autossuficiente',$$Benefício: Você recebe +2 de bônus em todos os testes de Cura e Sobrevivência.$$)
) as v(id,nome_pt,descricao_pt)
where public.srd_feats.id=v.id;
