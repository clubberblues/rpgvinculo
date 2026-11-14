-- Unified mechanics metadata for feats, class features and monster abilities.
-- Additive only: preserves existing source descriptions and legacy fields.

ALTER TABLE public.srd_feats
  ADD COLUMN IF NOT EXISTS nome_pt text,
  ADD COLUMN IF NOT EXISTS descricao_pt text,
  ADD COLUMN IF NOT EXISTS mechanics jsonb NOT NULL DEFAULT '{}'::jsonb;

ALTER TABLE public.monsters
  ADD COLUMN IF NOT EXISTS mechanics jsonb NOT NULL DEFAULT '{}'::jsonb;

ALTER TABLE public.srd_monsters
  ADD COLUMN IF NOT EXISTS mechanics jsonb NOT NULL DEFAULT '{}'::jsonb;

ALTER TABLE public.srd_feats
  DROP CONSTRAINT IF EXISTS srd_feats_mechanics_object_check;
ALTER TABLE public.srd_feats
  ADD CONSTRAINT srd_feats_mechanics_object_check
  CHECK (jsonb_typeof(mechanics) = 'object');

ALTER TABLE public.monsters
  DROP CONSTRAINT IF EXISTS monsters_mechanics_object_check;
ALTER TABLE public.monsters
  ADD CONSTRAINT monsters_mechanics_object_check
  CHECK (jsonb_typeof(mechanics) = 'object');

ALTER TABLE public.srd_monsters
  DROP CONSTRAINT IF EXISTS srd_monsters_mechanics_object_check;
ALTER TABLE public.srd_monsters
  ADD CONSTRAINT srd_monsters_mechanics_object_check
  CHECK (jsonb_typeof(mechanics) = 'object');

COMMENT ON COLUMN public.srd_feats.mechanics IS
  'Dados mecânicos executáveis da habilidade/talento. Contrato versionado compartilhado com habilidades de classe e monstros.';
COMMENT ON COLUMN public.srd_feats.nome_pt IS
  'Nome localizado em português para exibição na mesa; preserva nome original em nome.';
COMMENT ON COLUMN public.srd_feats.descricao_pt IS
  'Descrição localizada em português para exibição na mesa; preserva descrição original em descricao.';
COMMENT ON COLUMN public.monsters.mechanics IS
  'Dados mecânicos estruturados das habilidades da criatura, no contrato compartilhado da mesa.';
COMMENT ON COLUMN public.srd_monsters.mechanics IS
  'Dados mecânicos estruturados das habilidades da criatura SRD; dados_tecnicos e qualidades_especiais legados são preservados.';

