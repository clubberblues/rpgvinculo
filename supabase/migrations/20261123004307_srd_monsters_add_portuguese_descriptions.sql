-- Guarda o texto original do SRD em descricao e mantém a versão em português separada para exibição.
alter table public.srd_monsters
  add column if not exists descricao_pt text;

comment on column public.srd_monsters.descricao_pt is
  'Descrição em português para exibição no VTT; mantém descricao como texto original da fonte SRD.';

update public.srd_monsters as m
set descricao_pt = v.descricao_pt
from (
  values
  ('badger', 'O texugo é um animal baixo e forte, com corpo robusto e patas dianteiras cheias de garras. Usa essas garras para cavar e costuma se defender com mordidas e arranhões.'),
  ('camel', 'O camelo é conhecido por viajar longas distâncias em regiões secas. Tem pernas compridas e uma ou duas corcovas; é um animal resistente, muito usado para atravessar desertos.'),
  ('dire_rat', 'O rato atroz é muito maior que um rato comum e pode chegar a cerca de 1,2 metro de comprimento. Vive procurando comida e costuma atacar quando seu ninho ou território é ameaçado.'),
  ('dog', 'Este é um cão de porte pequeno ou médio, parecido com cães domésticos e canídeos selvagens, como chacais e coiotes. É atento, fareja bem e costuma perseguir a presa até cansá-la.'),
  ('dog_riding', 'O cão de montaria é maior e mais forte que um cão comum. Raças de trabalho, como huskies e são-bernardos, servem de exemplo; esses cães podem ser treinados para transportar um cavaleiro.'),
  ('eagle', 'A águia é uma ave de rapina de porte grande, encontrada em vários tipos de região. Costuma fazer ninho em lugares altos e isolados e mergulha do céu para agarrar suas presas com as garras.'),
  ('hawk', 'O falcão é uma ave de rapina menor que a águia, geralmente com corpo de 30 a 60 centímetros. Tem visão aguçada e costuma atacar suas presas com as garras.'),
  ('horse_light', 'O cavalo leve é uma montaria ágil, de porte menor que os cavalos de guerra. É usado para viagens e trabalhos do dia a dia, mas não foi criado para lutar enquanto carrega um cavaleiro.'),
  ('owl', 'A coruja é uma ave de rapina noturna, com cerca de 30 a 60 centímetros. Voa quase sem fazer barulho e usa a visão e a audição apuradas para localizar suas presas.'),
  ('pony', 'O pônei é um cavalo pequeno, com menos de 1,5 metro de altura até o ombro. É uma montaria resistente para pessoas menores ou cargas leves, mas não costuma lutar enquanto carrega alguém.'),
  ('snake_small_viper', 'A víbora pequena é uma cobra venenosa de porte reduzido. Geralmente evita o confronto, mas pode dar um bote para se defender e depois tentar fugir.'),
  ('snake_medium_viper', 'A víbora média é uma cobra venenosa de tamanho intermediário. Costuma evitar ameaças, mas reage com uma mordida quando se sente encurralada; seu veneno é perigoso.'),
  ('wolf', 'O lobo é um caçador ágil que vive e caça em grupo. A matilha cerca a presa e ataca em conjunto, usando persistência e coordenação para derrubá-la.')
) as v(id, descricao_pt)
where m.id = v.id;
