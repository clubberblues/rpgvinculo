-- Correção terminológica do lote 03: Overrun e Trip são manobras distintas.
begin;
update public.srd_feats set nome_pt='Atropelar Aprimorado', descricao_pt='Pré-requisitos: Força 13, Ataque Poderoso.

Benefício: Quando você tenta atropelar um oponente, o alvo não pode escolher evitar você. Além disso, você recebe +4 de bônus no teste de Força para derrubar o oponente.

Normal: Sem este talento, o alvo de uma tentativa de atropelar pode escolher evitar você ou bloqueá-lo.

Especial: Um guerreiro pode escolher Atropelar Aprimorado como um de seus talentos adicionais de guerreiro.' where id='srd35_feat_improved_overrun';
update public.srd_feats set nome_pt='Derrubar Aprimorado', descricao_pt='Pré-requisitos: Inteligência 13, Especialização em Combate.

Benefício: Você não provoca um ataque de oportunidade quando tenta derrubar um oponente enquanto está desarmado. Além disso, recebe +4 de bônus no teste de Força para derrubar o oponente.

Se você derrubar um oponente em combate corpo a corpo, recebe imediatamente um ataque corpo a corpo contra ele, como se não tivesse usado seu ataque para realizar a tentativa de derrubada.

Normal: Sem este talento, você provoca um ataque de oportunidade quando tenta derrubar um oponente enquanto está desarmado.

Especial: Um monge de 6º nível pode escolher Derrubar Aprimorado como talento adicional, mesmo sem cumprir os pré-requisitos. Um guerreiro também pode escolhê-lo como um de seus talentos adicionais de guerreiro.' where id='srd35_feat_improved_trip';
commit;