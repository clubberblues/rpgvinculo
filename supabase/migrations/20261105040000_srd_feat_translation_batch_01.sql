-- Lote 01 do catálogo de talentos: traduções revisadas.
-- Não altera engine_status: tradução não comprova integração funcional.
begin;

update public.srd_feats
set nome_pt = 'Ataque Poderoso',
    descricao_pt = 'Pré-requisito: Força 13.

Benefício: No seu turno, antes de realizar as jogadas de ataque de uma rodada, você pode escolher aplicar uma penalidade a todas as suas jogadas de ataque corpo a corpo e adicionar o mesmo valor às jogadas de dano corpo a corpo. A penalidade escolhida não pode ser maior que seu bônus base de ataque. A penalidade nos ataques e o bônus no dano permanecem até o início do seu próximo turno.

Especial: Ao atacar com uma arma de duas mãos, ou com uma arma de uma mão empunhada com as duas mãos, adicione ao dano o dobro do valor subtraído das jogadas de ataque. Você não recebe esse bônus de dano ao atacar com uma arma leve, exceto ataques desarmados e ataques com armas naturais; a penalidade nas jogadas de ataque continua sendo aplicada. Uma arma dupla é normalmente tratada como uma arma de uma mão e uma arma leve. Se você usar apenas uma das extremidades da arma dupla durante a rodada, empunhando-a como arma de duas mãos, trate-a como uma arma de duas mãos.

Um guerreiro pode escolher Ataque Poderoso como um de seus talentos adicionais de guerreiro.'
where id = 'ataque_poderoso';

update public.srd_feats
set nome_pt = 'Esquiva',
    descricao_pt = 'Pré-requisito: Destreza 13.

Benefício: Durante sua ação, escolha um oponente. Você recebe +1 de bônus de esquiva na Classe de Armadura contra os ataques desse oponente. Você pode escolher um novo oponente em qualquer uma de suas ações.

Qualquer condição que faça você perder seu bônus de Destreza na Classe de Armadura também faz você perder seus bônus de esquiva. Diferentemente da maioria dos bônus, bônus de esquiva acumulam entre si.

Especial: Um guerreiro pode escolher Esquiva como um de seus talentos adicionais de guerreiro.'
where id = 'esquiva';

update public.srd_feats
set nome_pt = 'Foco em Arma',
    descricao_pt = 'Escolha um tipo de arma. Você também pode escolher ataque desarmado, agarrar ou, se for um conjurador, raio como sua arma para este talento.

Pré-requisitos: Proficiência com a arma escolhida e bônus base de ataque +1.

Benefício: Você recebe +1 de bônus em todas as jogadas de ataque realizadas com a arma escolhida.

Especial: Você pode escolher este talento várias vezes. Seus efeitos não se acumulam; cada vez que o escolher, ele deve se aplicar a um tipo diferente de arma.

Um guerreiro pode escolher Foco em Arma como um de seus talentos adicionais de guerreiro. Para adquirir Especialização em Arma com uma arma, você precisa ter Foco em Arma com essa mesma arma.'
where id = 'foco_em_arma';

update public.srd_feats
set nome_pt = 'Iniciativa Aprimorada',
    descricao_pt = 'Benefício: Você recebe +4 de bônus nos testes de iniciativa.

Especial: Um guerreiro pode escolher Iniciativa Aprimorada como um de seus talentos adicionais de guerreiro.'
where id = 'iniciativa_aprimorada';

update public.srd_feats
set nome_pt = 'Reflexos de Combate',
    descricao_pt = 'Benefício: Você pode realizar uma quantidade de ataques de oportunidade adicionais igual ao seu modificador de Destreza.

Além disso, você pode realizar ataques de oportunidade mesmo quando estiver desprevenido.

Normal: Um personagem sem este talento pode realizar apenas um ataque de oportunidade por rodada e não pode realizá-los enquanto estiver desprevenido.

Especial: Este talento não permite que um ladino use sua habilidade oportunista mais de uma vez por rodada.

Um guerreiro pode escolher Reflexos de Combate como um de seus talentos adicionais de guerreiro. Um monge pode escolhê-lo como talento adicional no 2º nível.'
where id = 'reflexos_de_combate';

commit;