-- Keep historical identifiers for compatibility, but remove non-canonical aliases
-- from the D&D 3.5 character-creation catalog. The UI already filters
-- source_status = 'excluded'. No character data or primary keys are deleted.

UPDATE public.srd_skills
SET
  source_status = 'excluded',
  source_notes = concat_ws(' ', nullif(source_notes, ''),
    'Excluded from selectable D&D 3.5 catalog: duplicate/non-canonical alias; preserved for historical compatibility.'),
  dados_tecnicos = coalesce(dados_tecnicos, '{}'::jsonb) || jsonb_build_object(
    'catalog_visibility', 'excluded',
    'deprecated_alias_of', CASE id
      WHEN 'atletismo' THEN 'escalar'
      WHEN 'enganacao' THEN 'blefe'
      WHEN 'intuicao' THEN 'sentir_motivacao'
      WHEN 'natação' THEN 'natacao'
    END,
    'exclusion_reason', CASE id
      WHEN 'atletismo' THEN 'Misidentified duplicate of Climb; the canonical localized skill is Escalar.'
      WHEN 'enganacao' THEN 'Duplicate localized alias of Bluff; the canonical catalog entry is Blefe.'
      WHEN 'intuicao' THEN 'Duplicate localized alias of Sense Motive; the canonical catalog entry is Sentir Motivação.'
      WHEN 'natação' THEN 'Duplicate of Natação with an accent-bearing identifier; canonical identifier natacao is retained.'
    END
  )
WHERE id IN ('atletismo', 'enganacao', 'intuicao', 'natação')
  AND source_status <> 'excluded';

-- Verification guard: all canonical targets must exist before the migration
-- is considered complete.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM public.srd_skills WHERE id = 'escalar' AND source_status <> 'excluded')
     OR NOT EXISTS (SELECT 1 FROM public.srd_skills WHERE id = 'blefe' AND source_status <> 'excluded')
     OR NOT EXISTS (SELECT 1 FROM public.srd_skills WHERE id = 'sentir_motivacao' AND source_status <> 'excluded')
     OR NOT EXISTS (SELECT 1 FROM public.srd_skills WHERE id = 'natacao' AND source_status <> 'excluded') THEN
    RAISE EXCEPTION 'Canonical D&D 3.5 skill entry missing; catalog cleanup aborted';
  END IF;
END $$;
