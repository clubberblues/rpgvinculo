-- Lote 16: tradução de Familiar Aprimorado (D&D 3.5 SRD).
-- Não altera engine_status.
update public.srd_feats
set nome_pt='Familiar Aprimorado',
descricao_pt=$$Este talento permite que conjuradores adquiram um novo familiar de uma lista não padrão, mas somente quando normalmente poderiam adquirir um novo familiar.
Pré-requisitos: Capacidade de adquirir um novo familiar, tendência compatível e nível suficientemente alto (veja abaixo).
Benefício: Ao escolher um familiar, as criaturas listadas a seguir também ficam disponíveis para o conjurador. O conjurador pode escolher um familiar cuja tendência esteja a até um passo de distância em cada eixo de tendência (ordem versus caos e bem versus mal).
Familiares — Tendência — Nível de Conjurador Arcano:
Lagarto chocante — Neutro — 5º;
Stirge — Neutro — 5º;
Trabalhador formiano — Leal e neutro — 7º;
Diabrete — Leal e mau — 7º;
Pseudodragão — Neutro e bom — 7º;
Quasit — Caótico e mau — 7º.
Familiares aprimorados seguem as regras dos familiares comuns, com duas exceções: se o tipo da criatura for diferente de animal, seu tipo não muda; e familiares aprimorados não recebem a capacidade de falar com outras criaturas de sua espécie (embora muitos já possuam alguma forma de comunicação).
A lista acima apresenta apenas algumas opções possíveis de familiares aprimorados. Quase qualquer criatura de tamanho e poder geral semelhantes aos exemplos pode ser um familiar adequado. A tendência do mestre não é a única forma possível de categorização. Por exemplo, familiares aprimorados também podem ser escolhidos com base no tipo ou subtipo da criatura do mestre, conforme a lista abaixo.
Familiar — Tipo/Subtipo — Nível de Conjurador Arcano:
Falcão celestial¹ — Bem — 3º;
Cobra víbora Miúda abissal² — Mal — 3º;
Elemental do ar Pequeno — Ar — 5º;
Elemental da terra Pequeno — Terra — 5º;
Elemental do fogo Pequeno — Fogo — 5º;
Lagarto chocante — Eletricidade — 5º;
Elemental da água Pequeno — Água — 5º;
Homúnculo³ — Morto-vivo — 7º;
Mephit do gelo — Frio — 7º.
¹ Ou outro animal celestial da lista padrão de familiares.
² Ou outro animal abissal da lista padrão de familiares.
³ O mestre precisa primeiro criar o homúnculo, substituindo o sangue por icor ou outra parte do próprio corpo, se necessário.$$ 
where id='srd35_feat_improved_familiar';
