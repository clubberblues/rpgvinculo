-- Lote 04 do catálogo de talentos SRD: traduções revisadas.
-- Não altera engine_status: tradução não comprova integração funcional.
begin;
update public.srd_feats set nome_pt='Reflexos Rápidos', descricao_pt='Benefício: Você recebe +2 de bônus em todos os testes de resistência de Reflexos.' where id='srd35_feat_lightning_reflexes';
update public.srd_feats set nome_pt='Aptidão Mágica', descricao_pt='Benefício: Você recebe +2 de bônus em todos os testes de Identificar Magia e Usar Instrumento Mágico.' where id='srd35_feat_magical_aptitude';
update public.srd_feats set nome_pt='Disparo Múltiplo', descricao_pt='Pré-requisitos: Destreza 17, Tiro Certeiro, Tiro Rápido, bônus base de ataque +6.

Benefício: Como uma ação padrão, você pode disparar duas flechas contra um único oponente a até 9 metros. Ambas as flechas usam a mesma jogada de ataque, com penalidade de –4, para determinar se acertam e causam dano normalmente (consulte Especial).

Para cada 5 pontos de bônus base de ataque acima de +6, você pode adicionar uma flecha a esse ataque, até o máximo de quatro flechas com bônus base de ataque +16. Entretanto, cada flecha após a segunda impõe uma penalidade cumulativa de –2 na jogada de ataque (penalidade total de –6 para três flechas e –8 para quatro).

Redução de dano e outras resistências são aplicadas separadamente contra cada flecha disparada.

Especial: Independentemente do número de flechas disparadas, você aplica dano de precisão apenas uma vez. Se obtiver um acerto crítico, somente a primeira flecha disparada causa dano crítico; todas as outras causam dano normal. Um guerreiro pode escolher Disparo Múltiplo como um de seus talentos adicionais de guerreiro. Um ranger de 6º nível que tenha escolhido o estilo de combate com arco é considerado como possuidor deste talento, mesmo sem cumprir seus pré-requisitos, mas somente quando estiver usando armadura leve ou nenhuma armadura.' where id='srd35_feat_manyshot';
update public.srd_feats set nome_pt='Proficiência com Arma Marcial', descricao_pt='Escolha um tipo de arma marcial. Você sabe como usar esse tipo de arma marcial em combate.

Benefício: Você realiza jogadas de ataque normalmente com a arma escolhida.

Normal: Ao usar uma arma com a qual não é proficiente, você sofre penalidade de –4 nas jogadas de ataque.

Especial: Bárbaros, guerreiros, paladinos e rangers são proficientes com todas as armas marciais e não precisam escolher este talento. Você pode adquirir Proficiência com Arma Marcial várias vezes; cada vez, o talento se aplica a um novo tipo de arma. Um clérigo que escolha o domínio da Guerra recebe automaticamente como talento adicional a Proficiência com Arma Marcial correspondente à arma favorita de sua divindade, caso seja uma arma marcial.' where id='srd35_feat_martial_weapon_proficiency';
update public.srd_feats set nome_pt='Maximizar Magia', descricao_pt='Benefício: Todos os efeitos variáveis e numéricos de uma magia modificada por este talento são maximizados. Testes de resistência e jogadas resistidas não são afetados, assim como magias sem variáveis aleatórias. Uma magia maximizada ocupa um espaço de magia três níveis acima do nível real da magia.

Uma magia potencializada e maximizada recebe os benefícios separados de cada talento: o resultado máximo mais metade do resultado que seria obtido normalmente na rolagem.' where id='srd35_feat_maximize_spell';
update public.srd_feats set nome_pt='Mobilidade', descricao_pt='Pré-requisitos: Destreza 13, Esquiva.

Benefício: Você recebe +4 de bônus de esquiva na Classe de Armadura contra ataques de oportunidade provocados quando se desloca para fora de uma área ameaçada ou dentro dela. Uma condição que faça você perder seu bônus de Destreza na CA também faz você perder os bônus de esquiva.

Bônus de esquiva acumulam entre si, diferentemente da maioria dos tipos de bônus.

Especial: Um guerreiro pode escolher Mobilidade como um de seus talentos adicionais de guerreiro.' where id='srd35_feat_mobility';
update public.srd_feats set nome_pt='Arqueria Montada', descricao_pt='Pré-requisitos: 1 graduação em Cavalgar, Combate Montado.

Benefício: A penalidade sofrida ao usar uma arma à distância enquanto está montado é reduzida pela metade: –2 em vez de –4 se sua montaria realizar uma ação de movimento duplo, e –4 em vez de –8 se sua montaria correr.

Especial: Um guerreiro pode escolher Arqueria Montada como um de seus talentos adicionais de guerreiro.' where id='srd35_feat_mounted_archery';
update public.srd_feats set nome_pt='Combate Montado', descricao_pt='Pré-requisito: 1 graduação em Cavalgar.

Benefício: Uma vez por rodada, quando sua montaria é atingida em combate, você pode tentar um teste de Cavalgar como reação para negar o acerto. O acerto é negado se o resultado do seu teste de Cavalgar for maior que a jogada de ataque do oponente. Essencialmente, o resultado do teste de Cavalgar se torna a Classe de Armadura da montaria, caso seja maior que a CA normal dela.

Especial: Um guerreiro pode escolher Combate Montado como um de seus talentos adicionais de guerreiro.' where id='srd35_feat_mounted_combat';
update public.srd_feats set nome_pt='Magia Natural', descricao_pt='Pré-requisitos: Sabedoria 13, habilidade de Forma Selvagem.

Benefício: Você pode completar os componentes verbais e gestuais das magias enquanto estiver em Forma Selvagem. Você substitui os componentes verbais e gestuais normais por vários ruídos e gestos.

Você também pode usar quaisquer componentes materiais ou focos que possua, mesmo que esses itens estejam incorporados à sua forma atual. Este talento não permite usar itens mágicos enquanto estiver em uma forma que normalmente não poderia utilizá-los, e você não adquire a capacidade de falar enquanto estiver em Forma Selvagem.' where id='srd35_feat_natural_spell';
update public.srd_feats set nome_pt='Negociador', descricao_pt='Benefício: Você recebe +2 de bônus em todos os testes de Diplomacia e Sentir Motivação.' where id='srd35_feat_negotiator';
update public.srd_feats set nome_pt='Dedos Ágeis', descricao_pt='Benefício: Você recebe +2 de bônus em todos os testes de Operar Mecanismo e Abrir Fechaduras.' where id='srd35_feat_nimble_fingers';
update public.srd_feats set nome_pt='Persuasivo', descricao_pt='Benefício: Você recebe +2 de bônus em todos os testes de Blefar e Intimidar.' where id='srd35_feat_persuasive';
commit;