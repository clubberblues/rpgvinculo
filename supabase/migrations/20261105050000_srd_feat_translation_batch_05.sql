-- Lote 05 do catálogo de talentos SRD. Tradução; sem alteração de engine_status.
begin;
update public.srd_feats set nome_pt='Trespassar', descricao_pt='Pré-requisitos: Força 13, Ataque Poderoso.

Benefício: Se você causar dano suficiente a uma criatura para fazê-la cair (normalmente reduzindo seus pontos de vida para menos de 0 ou matando-a), recebe imediatamente um ataque corpo a corpo adicional contra outra criatura ao seu alcance. Você não pode dar um passo de 1,5 m antes desse ataque adicional. O ataque adicional é realizado com a mesma arma e o mesmo bônus de ataque do ataque que derrubou a criatura anterior. Você pode usar esta habilidade uma vez por rodada.

Especial: Um guerreiro pode escolher Trespassar como um de seus talentos adicionais de guerreiro.' where id='srd35_feat_cleave';
update public.srd_feats set nome_pt='Conjuração em Combate', descricao_pt='Benefício: Você recebe +4 de bônus nos testes de Concentração realizados para conjurar uma magia ou usar uma habilidade similar à magia enquanto conjura defensivamente, ou enquanto estiver agarrando ou imobilizado.' where id='srd35_feat_combat_casting';
update public.srd_feats set nome_pt='Especialização em Combate', descricao_pt='Pré-requisito: Inteligência 13.

Benefício: Quando você usa a ação de ataque ou a ação de ataque total em combate corpo a corpo, pode sofrer uma penalidade de até –5 na jogada de ataque e adicionar o mesmo valor (até +5) como bônus de esquiva à sua Classe de Armadura. O valor escolhido não pode exceder seu bônus base de ataque. As alterações nas jogadas de ataque e na CA duram até sua próxima ação.

Normal: Um personagem sem este talento pode lutar defensivamente ao usar a ação de ataque ou de ataque total, sofrendo –4 nas jogadas de ataque para receber +2 de bônus de esquiva na CA.

Especial: Um guerreiro pode escolher Especialização em Combate como um de seus talentos adicionais de guerreiro.' where id='srd35_feat_combat_expertise';
update public.srd_feats set nome_pt='Criar Armas e Armaduras Mágicas', descricao_pt='Pré-requisito: Nível de conjurador 5º.

Benefício: Você pode criar qualquer arma, armadura ou escudo mágico cujos pré-requisitos cumpra. Aprimorar uma arma, armadura ou escudo exige um dia para cada 1.000 PO do preço de suas propriedades mágicas. Para aprimorar o item, você deve gastar XP equivalente a 1/25 do preço total dessas propriedades e utilizar matérias-primas que custem metade desse preço.

A arma, armadura ou escudo a ser aprimorado deve ser um item obra-prima fornecido por você. O custo desse item não está incluído no cálculo acima.

Você também pode consertar uma arma, armadura ou escudo mágico quebrado que seria capaz de criar. Isso custa metade do XP, metade das matérias-primas e metade do tempo necessários para criar o item originalmente.' where id='srd35_feat_craft_magic_arms_and_armor';
update public.srd_feats set nome_pt='Criar Bastão', descricao_pt='Pré-requisito: Nível de conjurador 9º.

Benefício: Você pode criar qualquer bastão cujos pré-requisitos cumpra. Criar um bastão exige um dia para cada 1.000 PO de seu preço-base. Para criá-lo, você deve gastar XP equivalente a 1/25 do preço-base e utilizar matérias-primas que custem metade desse preço.

Alguns bastões exigem custos adicionais de componentes materiais ou XP, conforme indicado em suas descrições. Esses custos são somados aos derivados do preço-base.' where id='srd35_feat_craft_rod';
commit;