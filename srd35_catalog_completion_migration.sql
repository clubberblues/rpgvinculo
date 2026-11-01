-- Completa metadados auditáveis dos catálogos D&D 3.5 sem descartar
-- os dados e as referências originais importados.
BEGIN;

-- Talentos: cada registro passa a expor a referência principal no mesmo
-- campo usado pelos demais catálogos. A fonte está anexada, ainda pendente
-- de conferência regra a regra; não marcar como verificado.
ALTER TABLE public.srd_feats
  ADD COLUMN IF NOT EXISTS srd_source_url TEXT;

UPDATE public.srd_feats
SET srd_source_url = COALESCE(NULLIF(srd_source_url, ''), 'https://www.d20srd.org/srd/feats.htm'),
    source_status = CASE WHEN source_status IN ('verified_srd','excluded') THEN source_status ELSE 'source_attached' END,
    source_notes = CASE
      WHEN NULLIF(source_notes,'') IS NULL THEN 'Fonte primária do catálogo anexada; conferência individual de descrição e pré-requisitos ainda pendente.'
      ELSE source_notes
    END,
    requisitos = COALESCE(requisitos, '{}'::jsonb) || jsonb_strip_nulls(jsonb_build_object(
      'source_url_primary', 'https://www.d20srd.org/srd/feats.htm'
    ));

-- Estrutura pré-requisitos comuns já suportada pelo criador de fichas e pela
-- validação no banco. O texto original continua preservado em requisitos.raw.
WITH parsed AS (
  SELECT f.id,
    regexp_match(COALESCE(f.requisitos->>'raw',''), '(?i)\m(?:str|strength)\M[[:space:]]+([0-9]+)') AS str_m,
    regexp_match(COALESCE(f.requisitos->>'raw',''), '(?i)\m(?:dex|dexterity)\M[[:space:]]+([0-9]+)') AS dex_m,
    regexp_match(COALESCE(f.requisitos->>'raw',''), '(?i)\m(?:con|constitution)\M[[:space:]]+([0-9]+)') AS con_m,
    regexp_match(COALESCE(f.requisitos->>'raw',''), '(?i)\m(?:int|intelligence)\M[[:space:]]+([0-9]+)') AS int_m,
    regexp_match(COALESCE(f.requisitos->>'raw',''), '(?i)\m(?:wis|wisdom)\M[[:space:]]+([0-9]+)') AS wis_m,
    regexp_match(COALESCE(f.requisitos->>'raw',''), '(?i)\m(?:cha|charisma)\M[[:space:]]+([0-9]+)') AS cha_m,
    regexp_match(COALESCE(f.requisitos->>'raw',''), '(?i)base[[:space:]]+attack[[:space:]]+bonus[[:space:]]+\+?([0-9]+)') AS bab_m,
    regexp_match(COALESCE(f.requisitos->>'raw',''), '(?i)caster[[:space:]]+level[[:space:]]+([0-9]+)') AS caster_m,
    regexp_match(COALESCE(f.requisitos->>'raw',''), '(?i)character[[:space:]]+level[[:space:]]+([0-9]+)') AS character_m,
    regexp_match(COALESCE(f.requisitos->>'raw',''), '(?i)ride[[:space:]]+([0-9]+)[[:space:]]+ranks?') AS ride_m
  FROM public.srd_feats AS f
)
UPDATE public.srd_feats AS f
SET requisitos = COALESCE(f.requisitos, '{}'::jsonb) || jsonb_strip_nulls(jsonb_build_object(
  'for_min', CASE WHEN p.str_m IS NOT NULL THEN (p.str_m)[1]::integer END,
  'des_min', CASE WHEN p.dex_m IS NOT NULL THEN (p.dex_m)[1]::integer END,
  'con_min', CASE WHEN p.con_m IS NOT NULL THEN (p.con_m)[1]::integer END,
  'int_min', CASE WHEN p.int_m IS NOT NULL THEN (p.int_m)[1]::integer END,
  'sab_min', CASE WHEN p.wis_m IS NOT NULL THEN (p.wis_m)[1]::integer END,
  'car_min', CASE WHEN p.cha_m IS NOT NULL THEN (p.cha_m)[1]::integer END,
  'bab_min', CASE WHEN p.bab_m IS NOT NULL THEN (p.bab_m)[1]::integer END,
  'caster_level_min', CASE WHEN p.caster_m IS NOT NULL THEN (p.caster_m)[1]::integer END,
  'character_level_min', CASE WHEN p.character_m IS NOT NULL THEN (p.character_m)[1]::integer END,
  'skill_ranks', CASE WHEN p.ride_m IS NOT NULL THEN jsonb_build_object('cavalgar', (p.ride_m)[1]::integer) END
))
FROM parsed AS p
WHERE p.id=f.id;

-- Equipamentos: completar a representação técnica em JSONB a partir dos
-- campos já existentes, preservando categoria e fonte de importação.
UPDATE public.srd_equipment AS e
SET detalhes = COALESCE(e.detalhes, '{}'::jsonb) || jsonb_strip_nulls(jsonb_build_object(
  'grupo_catalogo_origem', e.categoria,
  'tipo_origem', e.tipo,
  'fonte_legada', e.srd_source_url,
  'campos_catalogo', jsonb_strip_nulls(jsonb_build_object(
    'dano', e.dano,
    'critico', e.critico,
    'tipo_dano', e.tipo_dano,
    'bonus_ca', COALESCE(e.bonus_ca,e.ca_bonus),
    'maximo_destreza', COALESCE(e.bonus_max_des,e.max_des),
    'penalidade_armadura', e.penalidade_armadura,
    'peso', e.peso,
    'preco_po', COALESCE(e.custo_po,e.preco),
    'descricao_origem', NULLIF(e.descricao,'')
  )),
  'referencia_srd', CASE
    WHEN lower(e.categoria)='rings' THEN 'https://www.d20srd.org/srd/magicItems/rings.htm'
    WHEN lower(e.categoria)='wands' THEN 'https://www.d20srd.org/srd/magicItems/wands.htm'
    WHEN lower(e.categoria)='wondrous_items' THEN 'https://www.d20srd.org/srd/magicItems/wondrousItems.htm'
    WHEN lower(e.categoria)='specific_cursed_items' THEN 'https://www.d20srd.org/srd/magicItems/cursedItems'
    WHEN lower(e.categoria)='potions_and_oils' THEN 'https://www.d20srd.org/srd/magicItems/potionsAndOils.htm'
    WHEN lower(e.categoria) LIKE '%weapon%' OR lower(e.categoria) IN ('arma','specific_weapons')
      THEN 'https://www.d20srd.org/srd/equipment/weapons.htm'
    WHEN lower(e.categoria) LIKE '%armor%' OR lower(e.categoria) IN ('armadura','escudo','shields','specific_armors','specific_shields','armor_and_shields')
      THEN 'https://www.d20srd.org/srd/equipment/armor.htm'
    WHEN lower(e.categoria) IN ('gear','extras','outro','mochila')
      THEN 'https://www.d20srd.org/srd/equipment/goodsAndServices.htm'
    ELSE NULL
  END
));

-- Perícias: manter a referência de importação existente e adicionar a página
-- oficial de resumo, que define testes, graduações e modificadores.
UPDATE public.srd_skills
SET dados_tecnicos = COALESCE(dados_tecnicos,'{}'::jsonb) || jsonb_build_object(
      'official_reference_url','https://www.d20srd.org/srd/skills/skillsSummary.htm',
      'catalog_scope','SRD 3.5: 35 perícias-base e dez especialidades de Conhecimento'
    ),
    source_status = CASE WHEN source_status IN ('verified_srd','excluded') THEN source_status ELSE 'source_attached' END
WHERE COALESCE(source_status,'') <> 'excluded';

-- Corrigir os três ataques ausentes a partir dos blocos técnicos importados.
UPDATE public.srd_monsters AS m
SET ataques = COALESCE(
      NULLIF(BTRIM(m.ataques),''),
      NULLIF(BTRIM(m.dados_tecnicos->>'full_attack'),''),
      NULLIF(BTRIM(m.dados_tecnicos->'statblock'->>'full_attack'),'')
    )
WHERE NULLIF(BTRIM(m.ataques),'') IS NULL
  AND COALESCE(
    NULLIF(BTRIM(m.dados_tecnicos->>'full_attack'),''),
    NULLIF(BTRIM(m.dados_tecnicos->'statblock'->>'full_attack'),'')
  ) IS NOT NULL;

-- CA do Pit Fiend conforme o bloco do SRD; também aponta as três correções
-- para a página individual da fonte primária.
UPDATE public.srd_monsters
SET ca = '40 (–1 tamanho, +8 Des, +23 natural), toque 17, surpresa 32',
    srd_source_url = 'https://www.d20srd.org/srd/monsters/devil.htm',
    source_status = 'source_attached',
    source_notes = 'CA conferida no bloco do Pit Fiend; ataques completos preenchidos a partir de dados_tecnicos.full_attack.'
WHERE id='pit_fiend';

UPDATE public.srd_monsters
SET srd_source_url = CASE id
      WHEN 'athach' THEN 'https://www.d20srd.org/srd/monsters/athach.htm'
      ELSE 'https://www.d20srd.org/srd/monsters/lycanthrope.htm'
    END,
    source_status = 'source_attached',
    source_notes = 'CA e ataques conferidos no bloco SRD individual; versões híbrida e tigre do weretiger mantêm seus próprios dados técnicos.'
WHERE id IN ('athach','weretiger_hybrid_form','weretiger_tiger_form');

COMMIT;

