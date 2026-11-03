ALTER TABLE public.srd_character_sheets
  ADD COLUMN IF NOT EXISTS idiomas_conhecidos JSONB NOT NULL
  DEFAULT '{"automaticos":[],"bonus_inteligencia":[],"comprados_falar_idioma":[]}'::JSONB;

CREATE TABLE IF NOT EXISTS public.srd_languages (
  id TEXT PRIMARY KEY,
  nome TEXT NOT NULL UNIQUE,
  is_secret BOOLEAN NOT NULL DEFAULT FALSE,
  source_status TEXT NOT NULL DEFAULT 'official',
  source_notes TEXT
);

INSERT INTO public.srd_languages(id,nome,is_secret,source_status) VALUES
 ('comum','Comum',FALSE,'official'),
 ('anao','Anão',FALSE,'official'),
 ('elfico','Élfico',FALSE,'official'),
 ('gnomico','Gnômico',FALSE,'official'),
 ('goblin','Goblin',FALSE,'official'),
 ('halfling','Halfling',FALSE,'official'),
 ('orc','Orc',FALSE,'official'),
 ('abissal','Abissal',FALSE,'official'),
 ('aquan','Aquan',FALSE,'official'),
 ('auran','Auran',FALSE,'official'),
 ('celestial','Celestial',FALSE,'official'),
 ('draconico','Dracônico',FALSE,'official'),
 ('druidico','Druídico',TRUE,'official'),
 ('gigante','Gigante',FALSE,'official'),
 ('gnoll','Gnoll',FALSE,'official'),
 ('igneo','Ígneo',FALSE,'official'),
 ('infernal','Infernal',FALSE,'official'),
 ('silvestre','Silvestre',FALSE,'official'),
 ('terrano','Terrano',FALSE,'official'),
 ('subcomum','Subcomum',FALSE,'official')
ON CONFLICT (id) DO UPDATE SET nome=EXCLUDED.nome,is_secret=EXCLUDED.is_secret,source_status=EXCLUDED.source_status;

ALTER TABLE public.srd_languages ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS srd_languages_public_read ON public.srd_languages;
CREATE POLICY srd_languages_public_read ON public.srd_languages FOR SELECT USING (TRUE);
GRANT SELECT ON public.srd_languages TO anon, authenticated;
