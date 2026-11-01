-- D&D 3.5 SRD: correct base-class progressions, class-skill lists, proficiencies and race briefs.
BEGIN;

-- Spellcraft is a core D&D 3.5 skill; it was missing from the Brazilian catalog.
INSERT INTO public.srd_skills
  (id,nome,atributo,treinada_apenas,penalidade_armadura,descricao,srd_source_url,dados_tecnicos,source_id,source_status,source_notes)
VALUES
  ('srd35_skill_spellcraft','Identificar Magia','INT',true,false,
   'Identificar magias enquanto são conjuradas ou já estão em efeito, decifrar inscrições mágicas e aprender ou copiar magias para um grimório.',
   'https://www.d20srd.org/srd/skills/spellcraft.htm',
   jsonb_build_object('source_name','Spellcraft','trained_only',true),
   'dnd35-srd-ogl','verified_srd',
   'Nome e regra básica conferidos no SRD 3.5; perícia treinada.')
ON CONFLICT (id) DO UPDATE SET
 nome=EXCLUDED.nome,atributo=EXCLUDED.atributo,treinada_apenas=EXCLUDED.treinada_apenas,
 penalidade_armadura=EXCLUDED.penalidade_armadura,descricao=EXCLUDED.descricao,
 srd_source_url=EXCLUDED.srd_source_url,dados_tecnicos=EXCLUDED.dados_tecnicos,
 source_id=EXCLUDED.source_id,source_status=EXCLUDED.source_status,source_notes=EXCLUDED.source_notes;

-- Preserve legacy identifiers while keeping non-3.5 aliases and duplicate labels out of new SRD sheets.
UPDATE public.srd_skills
SET source_status='excluded',
    source_notes='Não é uma perícia autônoma do SRD D&D 3.5 ou é um duplicado. Preservada para não quebrar fichas antigas.'
WHERE id IN ('atletismo','enganacao','intuicao','natação','fuga','srd35_skill_knowledge');

UPDATE public.srd_skills
SET treinada_apenas=false,
    source_notes=coalesce(source_notes,'')||' Tumble pode ser usada sem graduação no SRD 3.5.'
WHERE id='acrobacia';

UPDATE public.srd_skills
SET treinada_apenas=true,
    source_notes=coalesce(source_notes,'')||' Conhecimento exige graduação.'
WHERE id LIKE 'conhecimento_%';

-- The lists below are the D&D 3.5 class skills, using the Portuguese catalog labels.
UPDATE public.srd_classes SET nome='Patrulheiro' WHERE id='ranger';

UPDATE public.srd_classes SET pericias_classe=jsonb_build_array(
 'Adestrar Animais','Ofício','Intimidação','Escalar','Saltar','Ouvir','Cavalgar','Sobrevivência','Natação')
WHERE id='barbaro';
UPDATE public.srd_classes SET pericias_classe=jsonb_build_array(
 'Avaliação','Equilíbrio','Blefe','Escalar','Concentração','Ofício','Decifrar Escrita','Diplomacia','Disfarce',
 'Arte da Fuga','Obter Informação','Esconder-se','Saltar','Conhecimento (qualquer)','Ouvir','Mover-se Silenciosamente',
 'Atuação','Profissão','Sentir Motivação','Prestidigitação','Falar Idioma','Identificar Magia','Natação','Acrobacia','Usar Instrumento Mágico')
WHERE id='bardo';
UPDATE public.srd_classes SET pericias_classe=jsonb_build_array(
 'Concentração','Ofício','Diplomacia','Cura','Conhecimento (Arcano)','Conhecimento (História)',
 'Conhecimento (Religião)','Conhecimento (Planos)','Profissão','Identificar Magia')
WHERE id='clerigo';
UPDATE public.srd_classes SET pericias_classe=jsonb_build_array(
 'Concentração','Ofício','Diplomacia','Adestrar Animais','Cura','Conhecimento (Natureza)',
 'Ouvir','Profissão','Cavalgar','Identificar Magia','Observar','Sobrevivência','Natação')
WHERE id='druida';
UPDATE public.srd_classes SET pericias_classe=jsonb_build_array(
 'Blefe','Concentração','Ofício','Conhecimento (Arcano)','Profissão','Identificar Magia')
WHERE id='feiticeiro';
UPDATE public.srd_classes SET pericias_classe=jsonb_build_array(
 'Escalar','Ofício','Adestrar Animais','Intimidação','Saltar','Cavalgar','Natação')
WHERE id='guerreiro';
UPDATE public.srd_classes SET pericias_classe=jsonb_build_array(
 'Avaliação','Equilíbrio','Blefe','Escalar','Ofício','Decifrar Escrita','Diplomacia','Operar Mecanismo',
 'Disfarce','Arte da Fuga','Falsificação','Obter Informação','Esconder-se','Intimidação','Saltar',
 'Conhecimento (Local)','Ouvir','Mover-se Silenciosamente','Abrir Fechaduras','Atuação','Profissão',
 'Procurar','Sentir Motivação','Prestidigitação','Observar','Natação','Acrobacia','Usar Instrumento Mágico','Usar Cordas')
WHERE id='ladino';
UPDATE public.srd_classes SET pericias_classe=jsonb_build_array(
 'Concentração','Ofício','Conhecimento (qualquer)','Profissão','Identificar Magia')
WHERE id='mago';
UPDATE public.srd_classes SET pericias_classe=jsonb_build_array(
 'Equilíbrio','Escalar','Concentração','Ofício','Diplomacia','Arte da Fuga','Esconder-se','Saltar',
 'Conhecimento (Arcano)','Conhecimento (Religião)','Ouvir','Mover-se Silenciosamente','Atuação',
 'Profissão','Sentir Motivação','Observar','Natação','Acrobacia')
WHERE id='monge';
UPDATE public.srd_classes SET pericias_classe=jsonb_build_array(
 'Concentração','Ofício','Diplomacia','Adestrar Animais','Cura','Conhecimento (Nobreza)',
 'Conhecimento (Religião)','Profissão','Cavalgar','Sentir Motivação')
WHERE id='paladino';
UPDATE public.srd_classes SET pericias_classe=jsonb_build_array(
 'Escalar','Concentração','Ofício','Adestrar Animais','Cura','Esconder-se','Saltar',
 'Conhecimento (Masmorras)','Conhecimento (Geografia)','Conhecimento (Natureza)','Ouvir',
 'Mover-se Silenciosamente','Profissão','Cavalgar','Procurar','Observar','Sobrevivência','Natação','Usar Cordas')
WHERE id='ranger';

-- Proficiencies and class-only restrictions, in Portuguese and structured for the character sheet.
UPDATE public.srd_classes SET dados_tecnicos=coalesce(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
 'proficiencias',jsonb_build_object(
  'armas',jsonb_build_array('Todas as armas simples e marciais'),
  'armaduras',jsonb_build_array('Leves','Médias'),
  'escudos',jsonb_build_array('Todos, exceto escudo de corpo'),
  'observacao','A velocidade rápida só funciona sem armadura, com armadura leve ou média, e sem carga pesada.'))
WHERE id='barbaro';
UPDATE public.srd_classes SET dados_tecnicos=coalesce(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
 'proficiencias',jsonb_build_object(
  'armas',jsonb_build_array('Armas simples','Espada longa','Rapieira','Porrete','Espada curta','Arco curto','Chicote'),
  'armaduras',jsonb_build_array('Leves'),
  'escudos',jsonb_build_array('Todos, exceto escudo de corpo'),
  'observacao','Magias de bardo podem ser conjuradas com armadura leve sem falha arcana; escudo ainda pode causar falha.'))
WHERE id='bardo';
UPDATE public.srd_classes SET dados_tecnicos=coalesce(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
 'proficiencias',jsonb_build_object(
  'armas',jsonb_build_array('Armas simples','Arma favorecida pela divindade, se aplicável'),
  'armaduras',jsonb_build_array('Leves','Médias','Pesadas'),
  'escudos',jsonb_build_array('Todos, inclusive escudo de corpo'),
  'pericias_adicionais_por_dominio',jsonb_build_object(
   'Animal ou Plantas',jsonb_build_array('Conhecimento (Natureza)'),
   'Conhecimento',jsonb_build_array('Todas as perícias de Conhecimento'),
   'Viagem',jsonb_build_array('Sobrevivência'),
   'Trapaça',jsonb_build_array('Blefe','Disfarce','Esconder-se'))))
WHERE id='clerigo';
UPDATE public.srd_classes SET dados_tecnicos=coalesce(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
 'proficiencias',jsonb_build_object(
  'armas',jsonb_build_array('Clava','Adaga','Dardo','Bordão','Cimitarra','Foice','Lança curta','Funda','Lança','Ataques naturais da forma selvagem'),
  'armaduras',jsonb_build_array('Leves e médias não metálicas'),
  'escudos',jsonb_build_array('Escudos de madeira, exceto escudo de corpo'),
  'observacao','Usar armadura proibida ou escudo metálico impede magias e habilidades de druida por 24 horas.'))
WHERE id='druida';
UPDATE public.srd_classes SET dados_tecnicos=coalesce(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
 'proficiencias',jsonb_build_object(
  'armas',jsonb_build_array('Todas as armas simples e marciais'),
  'armaduras',jsonb_build_array('Leves','Médias','Pesadas'),
  'escudos',jsonb_build_array('Todos, inclusive escudo de corpo')))
WHERE id='guerreiro';
UPDATE public.srd_classes SET dados_tecnicos=coalesce(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
 'proficiencias',jsonb_build_object(
  'armas',jsonb_build_array('Clava','Besta leve','Besta pesada','Adaga','Machadinha','Dardo','Kama','Nunchaku','Bordão','Sai','Shuriken','Siangham','Funda','Lança'),
  'armaduras',jsonb_build_array('Nenhuma'),
  'escudos',jsonb_build_array('Nenhum'),
  'observacao','Vários recursos de monge só funcionam sem armadura e sem escudo.'))
WHERE id='monge';
UPDATE public.srd_classes SET dados_tecnicos=coalesce(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
 'proficiencias',jsonb_build_object(
  'armas',jsonb_build_array('Todas as armas simples e marciais'),
  'armaduras',jsonb_build_array('Leves','Médias','Pesadas'),
  'escudos',jsonb_build_array('Todos, inclusive escudo de corpo')))
WHERE id='paladino';
UPDATE public.srd_classes SET dados_tecnicos=coalesce(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
 'proficiencias',jsonb_build_object(
  'armas',jsonb_build_array('Todas as armas simples e marciais'),
  'armaduras',jsonb_build_array('Leves'),
  'escudos',jsonb_build_array('Todos, exceto escudo de corpo')))
WHERE id='ranger';
UPDATE public.srd_classes SET dados_tecnicos=coalesce(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
 'proficiencias',jsonb_build_object(
  'armas',jsonb_build_array('Armas simples','Besta de mão','Rapieira','Porrete','Arco curto','Espada curta'),
  'armaduras',jsonb_build_array('Leves'),
  'escudos',jsonb_build_array('Nenhum')))
WHERE id='ladino';
UPDATE public.srd_classes SET dados_tecnicos=coalesce(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
 'proficiencias',jsonb_build_object(
  'armas',jsonb_build_array('Armas simples'),
  'armaduras',jsonb_build_array('Nenhuma'),
  'escudos',jsonb_build_array('Nenhum'),
  'observacao','Armaduras podem causar falha arcana às magias de feiticeiro.'))
WHERE id='feiticeiro';
UPDATE public.srd_classes SET dados_tecnicos=coalesce(dados_tecnicos,'{}'::jsonb)||jsonb_build_object(
 'proficiencias',jsonb_build_object(
  'armas',jsonb_build_array('Clava','Adaga','Besta leve','Besta pesada','Bordão'),
  'armaduras',jsonb_build_array('Nenhuma'),
  'escudos',jsonb_build_array('Nenhum'),
  'observacao','Armaduras podem causar falha arcana às magias de mago.'))
WHERE id='mago';

UPDATE public.srd_classes
SET source_status='verified_srd',
    source_notes='Dados básicos, tendências, perícias de classe, dado de vida e proficiências conferidos contra a página da classe no SRD 3.5. Características e motor de cada habilidade continuam em revisão.',
    updated_at=now();

-- Correct every base-attack/save value in all 220 class levels from the SRD progression formulas.
UPDATE public.srd_class_level_progressions p
SET base_attack_bonus=CASE c.bab_progression
      WHEN 'good' THEN p.class_level::numeric
      WHEN 'average' THEN floor(3*p.class_level/4.0)::numeric
      WHEN 'poor' THEN floor(p.class_level/2.0)::numeric
      ELSE p.base_attack_bonus END,
    base_fortitude=CASE WHEN c.fort_bom THEN 2+floor(p.class_level/2.0)::int ELSE floor(p.class_level/3.0)::int END,
    base_reflex=CASE WHEN c.ref_bom THEN 2+floor(p.class_level/2.0)::int ELSE floor(p.class_level/3.0)::int END,
    base_will=CASE WHEN c.von_bom THEN 2+floor(p.class_level/2.0)::int ELSE floor(p.class_level/3.0)::int END,
    skill_points_per_level=coalesce(c.pericias_por_nivel,p.skill_points_per_level),
    first_level_skill_multiplier=4,
    source_id='dnd35-srd-ogl',
    verification_status='verified_srd'
FROM public.srd_classes c
WHERE c.id=p.class_id;

-- Complete the seven core race briefs with the SRD traits, movement, languages and favored class.
UPDATE public.srd_races SET habilidades_raciais=jsonb_build_array(
 '+2 Constituição, –2 Carisma.',
 'Tamanho Médio; sem ajustes de tamanho em CA, ataques ou testes.',
 'Deslocamento base 6 m; não é reduzido por armadura média/pesada nem por carga média/pesada.',
 'Visão no escuro 18 m, apenas em preto e branco.',
 'Astúcia com pedras: +2 em Procurar para notar construções incomuns de pedra; pode procurar armadilhas de pedra e intuir profundidade subterrânea.',
 'Familiaridade com armas: machado de guerra anão e urgrosh anão são tratados como armas marciais.',
 'Estabilidade: +4 em testes para resistir a encontrão e rasteira quando firmemente no chão.',
 '+2 nos testes de resistência contra veneno e contra magias e efeitos similares a magia.',
 '+1 nas jogadas de ataque contra orcs e goblinoides.',
 '+4 de esquiva na CA contra criaturas do tipo gigante; perde o bônus quando perde o bônus de Destreza na CA.',
 '+2 em Avaliação e Ofício relacionados a itens de pedra ou metal.',
 'Idiomas automáticos: Comum e Anão. Idiomas adicionais: Gigante, Gnômico, Goblin, Orc, Terrano e Subcomum.',
 'Classe favorecida: Guerreiro.')
WHERE id='anao';
UPDATE public.srd_races SET habilidades_raciais=jsonb_build_array(
 '+2 Destreza, –2 Constituição.',
 'Tamanho Médio; deslocamento base 9 m.',
 'Imunidade a efeitos mágicos de sono; +2 nos testes de resistência contra encantamentos.',
 'Visão na penumbra: enxerga duas vezes mais longe que um humano sob iluminação fraca.',
 'Proficiência adicional com espada longa, rapieira, arco longo e arco curto, inclusive versões compostas.',
 '+2 em Ouvir, Procurar e Observar; pode notar portas secretas ou escondidas ao passar a até 1,5 m.',
 'Idiomas automáticos: Comum e Élfico. Idiomas adicionais: Dracônico, Gnoll, Gnômico, Goblin, Orc e Silvestre.',
 'Classe favorecida: Mago.')
WHERE id='elfo';
UPDATE public.srd_races SET habilidades_raciais=jsonb_build_array(
 '+2 Constituição, –2 Força.',
 'Tamanho Pequeno: +1 na CA e nas jogadas de ataque, +4 em Esconder-se; armas menores e capacidade de carga de três quartos de uma criatura Média.',
 'Deslocamento base 6 m; visão na penumbra.',
 'Familiaridade com armas: martelo-gancho gnomo é tratado como arma marcial.',
 '+2 nos testes de resistência contra ilusões; +1 na CD das ilusões conjuradas pelo gnomo.',
 '+1 nas jogadas de ataque contra kobolds e goblinoides.',
 '+4 de esquiva na CA contra gigantes; perde o bônus quando perde o bônus de Destreza na CA.',
 '+2 em Ouvir e Ofício (alquimia).',
 'Pode falar com mamíferos escavadores. 1/dia: falar com animais, limitado a mamíferos escavadores, por 1 minuto. Com Carisma 10 ou mais, também pode usar 1/dia luzes dançantes, som fantasma e prestidigitação; nível de conjurador 1; CD 10 + modificador de Carisma + círculo da magia.',
 'Idiomas automáticos: Comum e Gnômico. Idiomas adicionais: Dracônico, Anão, Élfico, Gigante, Goblin e Orc.',
 'Classe favorecida: Bardo.')
WHERE id='gnomo';
UPDATE public.srd_races SET habilidades_raciais=jsonb_build_array(
 '+2 Destreza, –2 Força.',
 'Tamanho Pequeno: +1 na CA e nas jogadas de ataque, +4 em Esconder-se; armas menores e capacidade de carga de três quartos de uma criatura Média.',
 'Deslocamento base 6 m.',
 '+2 em Escalar, Saltar, Ouvir e Mover-se Silenciosamente.',
 '+1 em todos os testes de resistência.',
 '+2 de bônus moral nos testes de resistência contra medo; acumula com o +1 racial geral.',
 '+1 nas jogadas de ataque com armas arremessadas e fundas.',
 'Idiomas automáticos: Comum e Halfling. Idiomas adicionais: Anão, Élfico, Gnômico, Goblin e Orc.',
 'Classe favorecida: Ladino.')
WHERE id='halfling';
UPDATE public.srd_races SET habilidades_raciais=jsonb_build_array(
 'Tamanho Médio; deslocamento base 9 m.',
 'Recebe um talento adicional no 1º nível.',
 'Recebe 4 pontos de perícia adicionais no 1º nível e 1 ponto adicional em cada nível seguinte.',
 'Idioma automático: Comum. Pode escolher idiomas adicionais conforme Inteligência e as regras de Falar Idioma; idiomas secretos não são elegíveis.',
 'Classe favorecida: qualquer classe.')
WHERE id='humano';
UPDATE public.srd_races SET habilidades_raciais=jsonb_build_array(
 'Tamanho Médio; deslocamento base 9 m.',
 'Imunidade a efeitos mágicos de sono e +2 nos testes de resistência contra encantamentos.',
 'Visão na penumbra: enxerga duas vezes mais longe que um humano sob iluminação fraca.',
 '+1 em Ouvir, Procurar e Observar; +2 em Diplomacia e Obter Informação.',
 'Sangue élfico: para efeitos relacionados a raça, conta como elfo.',
 'Idiomas automáticos: Comum e Élfico. Idiomas adicionais: qualquer idioma, exceto idiomas secretos.',
 'Classe favorecida: qualquer classe.')
WHERE id='meio-elfo';
UPDATE public.srd_races SET habilidades_raciais=jsonb_build_array(
 '+2 Força, –2 Inteligência, –2 Carisma; Inteligência inicial não pode ficar abaixo de 3 por esse ajuste.',
 'Tamanho Médio; deslocamento base 9 m.',
 'Visão no escuro 18 m, apenas em preto e branco.',
 'Sangue orc: para efeitos relacionados a raça, conta como orc.',
 'Idiomas automáticos: Comum e Orc. Idiomas adicionais: Dracônico, Gigante, Gnoll, Goblin e Abissal.',
 'Classe favorecida: Bárbaro.')
WHERE id='meio-orc';

UPDATE public.srd_races
SET source_status='verified_srd',
    source_notes='Tamanho, deslocamento, ajustes de atributo, traços, idiomas e classe favorecida conferidos contra a página de raças do SRD 3.5. A aplicação automática de cada traço no motor de jogo continua em andamento.',
    updated_at=now();

-- Record verified source coverage separately from unfinished automation.
UPDATE public.srd_catalog_coverage
SET expected_entries=7,actual_entries=7,verified_entries=7,audit_status='in_progress',
    audit_notes='7 raças base e seus ajustes, tamanho, deslocamento, traços, idiomas e classe favorecida conferidos no SRD. Integração automática de todos os traços no motor ainda não concluída.',updated_at=now()
WHERE catalog_key='races';
UPDATE public.srd_catalog_coverage
SET expected_entries=11,actual_entries=11,verified_entries=11,audit_status='in_progress',
    audit_notes='11 classes base: dado de vida, progressão de ataque/salvamentos, perícias e proficiências conferidos no SRD. Regras especiais e progressões de magia ainda em auditoria e implementação.',updated_at=now()
WHERE catalog_key='classes';

INSERT INTO public.srd_catalog_coverage
 (catalog_key,ruleset_id,expected_entries,actual_entries,verified_entries,audit_status,audit_notes,updated_at)
VALUES
 ('class_level_progressions','dnd35-srd',220,220,220,'complete','Todas as 220 linhas de níveis das 11 classes foram recalculadas e verificadas para ataque base, salvamentos, pontos de perícia e multiplicador de 1º nível.',now()),
 ('class_skills','dnd35-srd',11,11,11,'complete','As listas de perícias de classe das 11 classes básicas foram atualizadas para os nomes e listas do D&D 3.5; perícias fora da edição foram excluídas da criação de novas fichas.',now()),
 ('class_proficiencies','dnd35-srd',11,11,11,'complete','Armas, armaduras, escudos e restrições de conjuração das 11 classes base foram registrados para exibição na ficha.',now())
ON CONFLICT (catalog_key) DO UPDATE SET
 ruleset_id=EXCLUDED.ruleset_id,expected_entries=EXCLUDED.expected_entries,actual_entries=EXCLUDED.actual_entries,
 verified_entries=EXCLUDED.verified_entries,audit_status=EXCLUDED.audit_status,audit_notes=EXCLUDED.audit_notes,updated_at=EXCLUDED.updated_at;

COMMIT;
