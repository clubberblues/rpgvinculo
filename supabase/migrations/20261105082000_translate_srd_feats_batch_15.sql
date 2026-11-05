-- Lote 15: tradução de Rastrear (SRD) e Tenacidade (registro não-SRD).
-- Não altera engine_status.
update public.srd_feats set nome_pt=v.nome_pt, descricao_pt=v.descricao_pt
from (values
('tenacidade','Tenacidade',$$Benefício: Você recebe +3 pontos de vida.
Especial: Um personagem pode escolher este talento várias vezes. Seus efeitos se acumulam.$$),
('srd35_feat_track','Rastrear',$$Benefício: Para encontrar rastros ou segui-los por 1,5 km, é necessário obter sucesso em um teste de Sobrevivência. Você deve realizar outro teste de Sobrevivência sempre que os rastros se tornarem difíceis de seguir.
Você se desloca com metade de seu deslocamento normal (ou com seu deslocamento normal e penalidade de –5 no teste, ou com até o dobro do deslocamento normal e penalidade de –20 no teste). A CD depende da superfície e das condições predominantes:
Superfície — CD de Sobrevivência: terreno muito macio 5; terreno macio 10; terreno firme 15; terreno duro 20.
Terreno muito macio: qualquer superfície (neve recente, poeira espessa, lama úmida) que retenha impressões profundas e nítidas de pegadas.
Terreno macio: qualquer superfície suficientemente macia para ceder à pressão, mas mais firme que lama úmida ou neve recente, na qual uma criatura deixa pegadas frequentes, porém rasas.
Terreno firme: a maioria das superfícies externas comuns (como gramados, campos, bosques e similares) ou superfícies internas excepcionalmente macias ou sujas (tapetes espessos e pisos muito sujos ou empoeirados). A criatura pode deixar alguns vestígios (galhos quebrados ou tufos de pelos), mas deixa apenas pegadas ocasionais ou parciais.
Terreno duro: qualquer superfície que não retenha pegadas, como rocha nua ou piso interno. A maioria dos leitos de riachos se enquadra nessa categoria, pois quaisquer pegadas deixadas são apagadas ou levadas pela água. A criatura deixa apenas vestígios (marcas de raspagem ou pedras deslocadas).
Modificadores adicionais da CD do teste de Sobrevivência:
A cada três criaturas no grupo rastreado: –1.
Tamanho da criatura ou criaturas rastreadas: Minúscula +8; Diminuta +4; Miúda +2; Pequena +1; Média +0; Grande –1; Enorme –2; Imensa –4; Colossal –8.
A cada 24 horas desde que o rastro foi deixado: +1.
A cada hora de chuva desde que o rastro foi deixado: +1.
Cobertura de neve recente desde que o rastro foi deixado: +10.
Visibilidade ruim: noite nublada ou sem lua +6; luar +3; neblina ou precipitação +3.
O grupo rastreado oculta seus rastros (e se desloca com metade do deslocamento): +5.
Para um grupo de tamanhos variados, aplique apenas o modificador da maior categoria de tamanho. Na categoria de visibilidade ruim, aplique apenas o maior modificador.
Se fracassar no teste de Sobrevivência, você pode tentar novamente após 1 hora de busca em ambientes externos ou 10 minutos em ambientes internos.
Normal: Sem este talento, você pode usar a perícia Sobrevivência para encontrar rastros, mas só pode segui-los se a CD da tarefa for 10 ou menor. Como alternativa, pode usar a perícia Procurar para encontrar uma pegada ou sinal semelhante da passagem de uma criatura, usando as CDs acima, mas não pode usar Procurar para seguir rastros, mesmo que outra pessoa já os tenha encontrado.
Especial: Um ranger recebe automaticamente Rastrear como talento adicional. Ele não precisa escolhê-lo.
Este talento não permite encontrar ou seguir rastros deixados por uma criatura sob efeito da magia Caminhar sem Deixar Rastros.$$)
) as v(id,nome_pt,descricao_pt)
where public.srd_feats.id=v.id;
