BEGIN;

UPDATE public.srd_skills
SET descricao = CASE id
  WHEN 'atletismo' THEN 'Usada para escalar superfícies e superar obstáculos físicos; testes são modificados pelo tipo de superfície e pelas condições da subida.'
  WHEN 'enganacao' THEN 'Usada para convencer alguém de algo que não é verdade, por meio de blefe, omissão ou dissimulação; normalmente se opõe à Sentir Motivação.'
  WHEN 'intuicao' THEN 'Usada para perceber intenções, avaliar sinceridade e notar tentativas de influência; normalmente se opõe à Enganação.'
  WHEN 'natação' THEN 'Usada para se mover e permanecer na água; um teste pode ser exigido por rodada em condições difíceis ou quando a personagem está encumbrada.'
END,
    srd_source_url = CASE id
      WHEN 'atletismo' THEN 'https://www.d20srd.org/srd/skills/climb.htm'
      WHEN 'enganacao' THEN 'https://www.d20srd.org/srd/skills/bluff.htm'
      WHEN 'intuicao' THEN 'https://www.d20srd.org/srd/skills/senseMotive.htm'
      WHEN 'natação' THEN 'https://www.d20srd.org/srd/skills/swim.htm'
    END,
    dados_tecnicos = COALESCE(dados_tecnicos, '{}'::jsonb) || jsonb_build_object(
      'official_reference_url', CASE id
        WHEN 'atletismo' THEN 'https://www.d20srd.org/srd/skills/climb.htm'
        WHEN 'enganacao' THEN 'https://www.d20srd.org/srd/skills/bluff.htm'
        WHEN 'intuicao' THEN 'https://www.d20srd.org/srd/skills/senseMotive.htm'
        WHEN 'natação' THEN 'https://www.d20srd.org/srd/skills/swim.htm'
      END,
      'audit_scope', 'Resumo técnico conferido contra a página individual do SRD; usos situacionais completos permanecem no texto-fonte.'
    ),
    source_status = 'source_attached'
WHERE id IN ('atletismo','enganacao','intuicao','natação');

COMMIT;