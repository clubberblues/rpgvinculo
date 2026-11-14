
WITH categories(id, nome, category_key, examples) AS (
  VALUES
    ('srd35_skill_perform_act','Atuação (Representação)','act','comédia, drama e mímica'),
    ('srd35_skill_perform_comedy','Atuação (Comédia)','comedy','bufonaria, limeriques e contar piadas'),
    ('srd35_skill_perform_dance','Atuação (Dança)','dance','balé, valsa e dança típica'),
    ('srd35_skill_perform_keyboard','Atuação (Instrumentos de teclado)','keyboard','cravo, piano e órgão de tubos'),
    ('srd35_skill_perform_oratory','Atuação (Oratória)','oratory','epopeia, ode e narração de histórias'),
    ('srd35_skill_perform_percussion','Atuação (Instrumentos de percussão)','percussion','sinos, carrilhões, tambores e gongos'),
    ('srd35_skill_perform_string','Atuação (Instrumentos de corda)','string','rabeca, harpa, alaúde e bandolim'),
    ('srd35_skill_perform_wind','Atuação (Instrumentos de sopro)','wind','flauta, flauta de pã, flauta doce, charamela e trompete'),
    ('srd35_skill_perform_sing','Atuação (Canto)','sing','balada, canto litúrgico e melodia')
)
INSERT INTO public.srd_skills
  (id,nome,atributo,treinada_apenas,penalidade_armadura,descricao,srd_source_url,dados_tecnicos,source_id,source_status,source_notes)
SELECT
  c.id,c.nome,base.atributo,base.treinada_apenas,base.penalidade_armadura,
  'Esta é uma especialidade independente de Atuação. Use-a para apresentações de '||c.examples||'. Cada especialidade possui suas próprias graduações e é comprada separadamente.'||E'\n\n'||base.descricao,
  base.srd_source_url,
  base.dados_tecnicos || jsonb_build_object(
    'specialization_category',c.category_key,
    'specialization_examples',c.examples,
    'legacy_parent_id',base.id,
    'engine_status','separate_skill',
    'verification_summary','Categoria independente de Perform confirmada no SRD 3.5.'
  ),
  NULL,base.source_status,
  'Especialidade individual de Atuação conferida no d20 SRD Skills, linhas 37-86; preserva o registro genérico legado para fichas existentes.'
FROM categories c
CROSS JOIN public.srd_skills base
WHERE base.id='srd35_skill_perform'
ON CONFLICT (id) DO NOTHING;

UPDATE public.srd_classes
SET pericias_classe = COALESCE(pericias_classe,'[]'::jsonb) || jsonb_build_array(
  'Atuação (Representação)',
  'Atuação (Comédia)',
  'Atuação (Dança)',
  'Atuação (Instrumentos de teclado)',
  'Atuação (Oratória)',
  'Atuação (Instrumentos de percussão)',
  'Atuação (Instrumentos de corda)',
  'Atuação (Instrumentos de sopro)',
  'Atuação (Canto)'
)
WHERE id IN ('bardo','ladino','monge');
