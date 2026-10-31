-- Enriched D&D 3.5 SRD race/class briefs for the character creation flow.
-- Descriptions are original Portuguese summaries of OGL mechanics; full SRD sources are linked per entry.

ALTER TABLE public.srd_classes
  ADD COLUMN IF NOT EXISTS briefing TEXT NOT NULL DEFAULT '';

UPDATE public.srd_races SET
  briefing = 'Povo resistente das montanhas, treinado para sobreviver sob a terra e enfrentar gigantes e goblinoides.',
  habilidades_raciais = jsonb_build_array(
    'Visão no escuro 18 m; enxerga em preto e branco.',
    'Astúcia com pedras: +2 em Procurar para notar construções e perigos incomuns de pedra; pode procurar armadilhas de pedra.',
    'Familiaridade com machado de guerra anão e urgrosh anão: trata-os como armas marciais.',
    'Estabilidade: +4 em testes para resistir a encontrão e rasteira enquanto estiver no chão.',
    '+2 nos testes de resistência contra veneno e contra magias e habilidades similares a magia.',
    '+1 nas jogadas de ataque contra orcs e goblinoides; +4 de esquiva na CA contra criaturas do tipo gigante.',
    '+2 em Avaliação e Ofício quando ligados a pedra ou metal.',
    'Idiomas automáticos: Comum e Anão. Classe favorecida: Guerreiro.'
  ),
  srd_source_url = 'https://www.d20srd.org/srd/races.htm#dwarves'
WHERE id = 'anao';

UPDATE public.srd_races SET
  briefing = 'Povo ágil e perceptivo, com sentidos aguçados e afinidade com magia arcana.',
  habilidades_raciais = jsonb_build_array(
    'Visão na penumbra: enxerga duas vezes mais longe que um humano sob iluminação fraca.',
    'Imunidade a efeitos mágicos de sono; +2 nos testes de resistência contra encantamentos.',
    'Proficiência adicional com espada longa, rapieira, arco longo e arco curto, inclusive versões compostas.',
    '+2 em Ouvir, Procurar e Observar; pode notar portas secretas ao passar a até 1,5 m delas.',
    'Idiomas automáticos: Comum e Élfico. Classe favorecida: Mago.'
  ),
  srd_source_url = 'https://www.d20srd.org/srd/races.htm#elves'
WHERE id = 'elfo';

UPDATE public.srd_races SET
  briefing = 'Povo pequeno e inventivo, particularmente resistente a ilusões e hábil com alquimia.',
  habilidades_raciais = jsonb_build_array(
    'Tamanho Pequeno: +1 na CA e nos ataques, +4 em Esconder-se; armas e capacidade de carga de criatura Pequena.',
    'Deslocamento base 6 m; visão na penumbra.',
    '+2 nos testes de resistência contra ilusões; +1 na CD das ilusões conjuradas pelo gnomo.',
    '+1 nos ataques contra kobolds e goblinoides; +4 de esquiva na CA contra criaturas do tipo gigante.',
    '+2 em Ouvir e em Ofício (alquimia).',
    'Familiaridade com martelo-gancho gnomo; pode falar com mamíferos escavadores.',
    'Habilidades similares a magia 1/dia: luzes dançantes, som fantasma e prestidigitação (CAR 10+); falar com animais limitado a mamíferos escavadores.',
    'Idiomas automáticos: Comum e Gnômico. Classe favorecida: Bardo.'
  ),
  srd_source_url = 'https://www.d20srd.org/srd/races.htm#gnomes'
WHERE id = 'gnomo';

UPDATE public.srd_races SET
  briefing = 'A versatilidade humana abre espaço para aprender mais perícias e escolher um talento adicional desde o início.',
  habilidades_raciais = jsonb_build_array(
    'Tamanho Médio e deslocamento base 9 m.',
    'Um talento adicional no 1º nível.',
    '4 pontos de perícia adicionais no 1º nível e 1 ponto adicional a cada nível seguinte.',
    'Idiomas automáticos: Comum; idiomas adicionais podem ser escolhidos conforme as regras.',
    'Classe favorecida: qualquer classe.'
  ),
  srd_source_url = 'https://www.d20srd.org/srd/races.htm#humans'
WHERE id = 'humano';

UPDATE public.srd_races SET
  briefing = 'Herdeiros de duas culturas, combinam sentidos élficos com adaptabilidade social.',
  habilidades_raciais = jsonb_build_array(
    'Visão na penumbra; imunidade a efeitos mágicos de sono; +2 nos testes de resistência contra encantamentos.',
    '+1 em Ouvir, Procurar e Observar; +2 em Diplomacia e Obter Informação.',
    'Sangue élfico: conta como elfo para efeitos relacionados a raça.',
    'Idiomas automáticos: Comum e Élfico; idiomas adicionais conforme as regras.',
    'Classe favorecida: qualquer classe.'
  ),
  srd_source_url = 'https://www.d20srd.org/srd/races.htm#halfelves'
WHERE id = 'meio-elfo';

UPDATE public.srd_races SET
  briefing = 'Herdeiros de orcs e humanos, contam com força física e visão adaptada à escuridão.',
  habilidades_raciais = jsonb_build_array(
    'Visão no escuro 18 m; enxerga em preto e branco.',
    'Sangue orc: conta como orc para efeitos relacionados a raça.',
    'Idiomas automáticos: Comum e Orc; idiomas adicionais conforme as regras.',
    'Classe favorecida: Bárbaro.'
  ),
  srd_source_url = 'https://www.d20srd.org/srd/races.htm#halforcs'
WHERE id = 'meio-orc';

UPDATE public.srd_races SET
  briefing = 'A pequena estatura dos halflings é compensada por agilidade, coragem e precisão com armas arremessadas.',
  habilidades_raciais = jsonb_build_array(
    'Tamanho Pequeno: +1 na CA e nos ataques, +4 em Esconder-se; armas e capacidade de carga de criatura Pequena.',
    'Deslocamento base 6 m.',
    '+2 em Escalar, Saltar e Mover-se em Silêncio; +2 em Ouvir.',
    '+1 em todos os testes de resistência e +2 de bônus moral contra medo (cumulativo).',
    '+1 nos ataques com armas arremessadas e fundas.',
    'Idiomas automáticos: Comum e Halfling. Classe favorecida: Ladino.'
  ),
  srd_source_url = 'https://www.d20srd.org/srd/races.htm#halflings'
WHERE id = 'halfling';

UPDATE public.srd_classes SET
  descricao = 'Combatente feroz que usa fúria para elevar a força e a resistência. Desenvolve movimento rápido, esquiva sobrenatural, redução de dano e mais usos de fúria conforme avança.',
  briefing = 'Linha de frente resistente; combina grande dado de vida, ataque base alto e explosões temporárias de força.',
  dados_tecnicos = dados_tecnicos || jsonb_build_object('tendencia','Qualquer não Leal','pontos_pericia_nivel_1','(4 + modificador de Inteligência) × 4','pontos_pericia_por_nivel','4 + modificador de Inteligência','papel','combatente resistente','progressao_completa','https://www.d20srd.org/srd/classes/barbarian.htm'),
  srd_source_url = 'https://www.d20srd.org/srd/classes/barbarian.htm'
WHERE id = 'barbaro';

UPDATE public.srd_classes SET
  descricao = 'Artista versátil com muitas perícias, música de bardo e conjuração arcana espontânea baseada em Carisma. Aprende magias conhecidas e não as prepara em um grimório.',
  briefing = 'Suporte e especialista versátil: inspira aliados, domina perícias e conjura espontaneamente magias arcanas.',
  dados_tecnicos = dados_tecnicos || jsonb_build_object('tendencia','Qualquer não Leal','pontos_pericia_nivel_1','(6 + modificador de Inteligência) × 4','pontos_pericia_por_nivel','6 + modificador de Inteligência','papel','suporte, perícias e magia espontânea','conjuracao','arcana espontânea; atributo-chave Carisma; magias conhecidas, sem preparação diária','progressao_completa','https://www.d20srd.org/srd/classes/bard.htm'),
  srd_source_url = 'https://www.d20srd.org/srd/classes/bard.htm'
WHERE id = 'bardo';

UPDATE public.srd_classes SET
  descricao = 'Conjurador divino que prepara magias usando Sabedoria, escolhe dois domínios e pode canalizar energia para afetar mortos-vivos. A seleção de domínio precisa ser registrada na ficha.',
  briefing = 'Conjurador divino versátil e resistente; prepara magias, escolhe domínios e canaliza energia.',
  dados_tecnicos = dados_tecnicos || jsonb_build_object('tendencia','A até um passo da tendência da divindade','pontos_pericia_nivel_1','(2 + modificador de Inteligência) × 4','pontos_pericia_por_nivel','2 + modificador de Inteligência','papel','magia divina, domínios e suporte','conjuracao','divina preparada; atributo-chave Sabedoria; acesso até o 9º círculo; domínios concedem opções e espaços próprios','progressao_completa','https://www.d20srd.org/srd/classes/cleric.htm'),
  srd_source_url = 'https://www.d20srd.org/srd/classes/cleric.htm'
WHERE id = 'clerigo';

UPDATE public.srd_classes SET
  descricao = 'Guardião da natureza que prepara magias divinas com Sabedoria. Recebe companheiro animal e ganha formas selvagens em níveis posteriores.',
  briefing = 'Conjurador divino preparado e guardião natural; ganha companheiro animal e transformação selvagem.',
  dados_tecnicos = dados_tecnicos || jsonb_build_object('tendencia','Qualquer neutra','pontos_pericia_nivel_1','(4 + modificador de Inteligência) × 4','pontos_pericia_por_nivel','4 + modificador de Inteligência','papel','natureza, magia preparada e companheiro animal','conjuracao','divina preparada; atributo-chave Sabedoria; acesso até o 9º círculo','progressao_completa','https://www.d20srd.org/srd/classes/druid.htm'),
  srd_source_url = 'https://www.d20srd.org/srd/classes/druid.htm'
WHERE id = 'druida';

UPDATE public.srd_classes SET
  descricao = 'Conjurador arcano espontâneo cuja magia inata depende de Carisma. Conhece um conjunto limitado de magias e pode conjurá-las sem preparação diária.',
  briefing = 'Conjurador arcano espontâneo: escolhe poucas magias conhecidas e as conjura sem preparar espaços.',
  dados_tecnicos = dados_tecnicos || jsonb_build_object('tendencia','Qualquer','pontos_pericia_nivel_1','(2 + modificador de Inteligência) × 4','pontos_pericia_por_nivel','2 + modificador de Inteligência','papel','magia arcana espontânea','conjuracao','arcana espontânea; atributo-chave Carisma; magias conhecidas e limite diário; acesso até o 9º círculo','progressao_completa','https://www.d20srd.org/srd/classes/sorcererWizard.htm#sorcerer'),
  srd_source_url = 'https://www.d20srd.org/srd/classes/sorcererWizard.htm#sorcerer'
WHERE id = 'feiticeiro';

UPDATE public.srd_classes SET
  descricao = 'Especialista em combate treinado com ampla seleção de armas e armaduras. Recebe talentos adicionais de combate em diversos níveis.',
  briefing = 'Combatente treinado com o maior acesso a talentos adicionais e proficiência ampla em armas e armaduras.',
  dados_tecnicos = dados_tecnicos || jsonb_build_object('tendencia','Qualquer','pontos_pericia_nivel_1','(2 + modificador de Inteligência) × 4','pontos_pericia_por_nivel','2 + modificador de Inteligência','papel','combate e talentos','progressao_completa','https://www.d20srd.org/srd/classes/fighter.htm'),
  srd_source_url = 'https://www.d20srd.org/srd/classes/fighter.htm'
WHERE id = 'guerreiro';

UPDATE public.srd_classes SET
  descricao = 'Especialista em perícias e infiltração. O ataque furtivo pune alvos vulneráveis; evasão, esquiva sobrenatural e busca de armadilhas ampliam sua sobrevivência.',
  briefing = 'Especialista em perícias, armadilhas e ataques furtivos; resolve obstáculos por precisão e oportunidade.',
  dados_tecnicos = dados_tecnicos || jsonb_build_object('tendencia','Qualquer','pontos_pericia_nivel_1','(8 + modificador de Inteligência) × 4','pontos_pericia_por_nivel','8 + modificador de Inteligência','papel','perícias, furtividade e ataque furtivo','progressao_completa','https://www.d20srd.org/srd/classes/rogue.htm'),
  srd_source_url = 'https://www.d20srd.org/srd/classes/rogue.htm'
WHERE id = 'ladino';

UPDATE public.srd_classes SET
  descricao = 'Conjurador arcano que registra magias em um livro e prepara quais lançará após descansar. Inteligência define suas magias e a CD; a especialização em escola modifica suas opções.',
  briefing = 'Conjurador arcano preparado: mantém um livro de magias e escolhe após o descanso quais magias ocuparão seus espaços.',
  dados_tecnicos = dados_tecnicos || jsonb_build_object('tendencia','Qualquer','pontos_pericia_nivel_1','(2 + modificador de Inteligência) × 4','pontos_pericia_por_nivel','2 + modificador de Inteligência','papel','magia arcana preparada e livro de magias','conjuracao','arcana preparada; atributo-chave Inteligência; registra magias no grimório e prepara após descanso; acesso até o 9º círculo','progressao_completa','https://www.d20srd.org/srd/classes/sorcererWizard.htm#wizard'),
  srd_source_url = 'https://www.d20srd.org/srd/classes/sorcererWizard.htm#wizard'
WHERE id = 'mago';

UPDATE public.srd_classes SET
  descricao = 'Combatente disciplinado que luta desarmado, combina ataque e defesa e desenvolve velocidade, resistência e habilidades sobrenaturais com o avanço.',
  briefing = 'Combatente móvel e disciplinado; luta desarmado e recebe benefícios de defesa e movimento conforme evolui.',
  dados_tecnicos = dados_tecnicos || jsonb_build_object('tendencia','Leal','pontos_pericia_nivel_1','(4 + modificador de Inteligência) × 4','pontos_pericia_por_nivel','4 + modificador de Inteligência','papel','combate desarmado, mobilidade e defesa','progressao_completa','https://www.d20srd.org/srd/classes/monk.htm'),
  srd_source_url = 'https://www.d20srd.org/srd/classes/monk.htm'
WHERE id = 'monge';

UPDATE public.srd_classes SET
  descricao = 'Campeão devoto de tendência Leal e Boa. Recebe graça divina, cura, expulsão de mortos-vivos, montaria especial e conjuração divina preparada a partir do 4º nível.',
  briefing = 'Defensor sagrado e combatente; seus recursos incluem graça divina, cura e magia preparada a partir do 4º nível.',
  dados_tecnicos = dados_tecnicos || jsonb_build_object('tendencia','Leal e Boa','pontos_pericia_nivel_1','(2 + modificador de Inteligência) × 4','pontos_pericia_por_nivel','2 + modificador de Inteligência','papel','combatente divino, proteção e cura','conjuracao','divina preparada a partir do 4º nível; atributo-chave Sabedoria; acesso até o 4º círculo','progressao_completa','https://www.d20srd.org/srd/classes/paladin.htm'),
  srd_source_url = 'https://www.d20srd.org/srd/classes/paladin.htm'
WHERE id = 'paladino';

UPDATE public.srd_classes SET
  descricao = 'Explorador e caçador treinado que escolhe inimigos favorecidos, combate com duas armas ou à distância e pode receber companheiro animal. Sua magia divina preparada começa no 4º nível.',
  briefing = 'Explorador de combate versátil; especializa-se contra inimigos, ganha talentos de combate e magia a partir do 4º nível.',
  dados_tecnicos = dados_tecnicos || jsonb_build_object('tendencia','Qualquer','pontos_pericia_nivel_1','(6 + modificador de Inteligência) × 4','pontos_pericia_por_nivel','6 + modificador de Inteligência','papel','exploração, inimigos favorecidos e combate','conjuracao','divina preparada a partir do 4º nível; atributo-chave Sabedoria; acesso até o 4º círculo','progressao_completa','https://www.d20srd.org/srd/classes/ranger.htm'),
  srd_source_url = 'https://www.d20srd.org/srd/classes/ranger.htm'
WHERE id = 'ranger';

-- Correct attribute adjustments/size metadata that must match the full SRD rules.
UPDATE public.srd_races SET ajustes_atributos='{"DES":2,"FOR":-2}'::jsonb WHERE id='halfling';
UPDATE public.srd_races SET ajustes_atributos='{"CON":2,"FOR":-2}'::jsonb WHERE id='gnomo';
UPDATE public.srd_races SET ajustes_atributos='{"CON":2,"CAR":-2}'::jsonb WHERE id='anao';
UPDATE public.srd_races SET ajustes_atributos='{"DES":2,"CON":-2}'::jsonb WHERE id='elfo';
UPDATE public.srd_races SET ajustes_atributos='{}'::jsonb WHERE id='meio-elfo';

