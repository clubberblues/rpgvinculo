begin;
update public.srd_feats set nome_pt='Criar Cajado', descricao_pt='Pré-requisito: Nível de conjurador 12º.

Benefício: Você pode criar qualquer cajado cujos pré-requisitos cumpra. Criar um cajado exige um dia para cada 1.000 PO de seu preço-base. Para criá-lo, você deve gastar XP equivalente a 1/25 do preço-base e utilizar matérias-primas que custem metade desse preço. Um cajado recém-criado possui 50 cargas.

Alguns cajados exigem custos adicionais de componentes materiais ou XP, conforme indicado em suas descrições. Esses custos são somados aos derivados do preço-base.' where id='srd35_feat_craft_staff';
update public.srd_feats set nome_pt='Criar Varinha', descricao_pt='Pré-requisito: Nível de conjurador 5º.

Benefício: Você pode criar uma varinha de qualquer magia de 4º nível ou inferior que conheça. Criar uma varinha exige um dia para cada 1.000 PO de seu preço-base. O preço-base de uma varinha é o nível de conjurador × o nível da magia × 750 PO. Para criá-la, você deve gastar XP equivalente a 1/25 desse preço-base e utilizar matérias-primas que custem metade desse preço. Uma varinha recém-criada possui 50 cargas.

Uma varinha que armazene uma magia com componente material caro ou custo em XP também incorpora o custo correspondente. Além do custo derivado do preço-base, você deve fornecer cinquenta unidades do componente material ou pagar cinquenta vezes o custo em XP.' where id='srd35_feat_craft_wand';
update public.srd_feats set nome_pt='Criar Item Maravilhoso', descricao_pt='Pré-requisito: Nível de conjurador 3º.

Benefício: Você pode criar qualquer item maravilhoso cujos pré-requisitos cumpra. Encantar um item maravilhoso exige um dia para cada 1.000 PO de seu preço. Para encantá-lo, você deve gastar XP equivalente a 1/25 do preço e utilizar matérias-primas que custem metade desse valor.

Você também pode consertar um item maravilhoso quebrado que seria capaz de criar. Isso custa metade do XP, metade das matérias-primas e metade do tempo necessários para criá-lo originalmente.

Alguns itens maravilhosos exigem custos adicionais de componentes materiais ou XP, conforme indicado em suas descrições. Esses custos são somados aos derivados do preço-base e devem ser pagos tanto para criar o item quanto para consertá-lo.' where id='srd35_feat_craft_wondrous_item';
update public.srd_feats set nome_pt='Enganador', descricao_pt='Benefício: Você recebe +2 de bônus em todos os testes de Disfarces e Falsificação.' where id='srd35_feat_deceitful';
update public.srd_feats set nome_pt='Desviar Flechas', descricao_pt='Pré-requisitos: Destreza 13, Ataque Desarmado Aprimorado.

Benefício: Você precisa ter pelo menos uma mão livre (sem segurar nada) para usar este talento. Uma vez por rodada, quando normalmente seria atingido por uma arma à distância, você pode desviá-la e não sofrer dano. Você precisa estar ciente do ataque e não pode estar desprevenido.

Tentar desviar uma arma à distância não conta como ação. Armas à distância excepcionalmente grandes e ataques à distância gerados por efeitos de magia não podem ser desviados.

Especial: Um monge pode escolher Desviar Flechas como talento adicional no 2º nível, mesmo que não cumpra os pré-requisitos. Um guerreiro também pode escolhê-lo como um de seus talentos adicionais de guerreiro.' where id='srd35_feat_deflect_arrows';
commit;