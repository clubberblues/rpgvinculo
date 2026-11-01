-- Vínculo · Arquétipos de NPC para o compêndio D&D 3.5 SRD.
-- Executar depois de srd35_compendium_migration.sql e srd35_races_classes_briefing_migration.sql.
-- Mantém cinco perfis reutilizáveis por combinação de raça/classe; o nível é escolhido ao gerar.

BEGIN;

CREATE TABLE IF NOT EXISTS public.srd_npc_archetypes (
  id TEXT PRIMARY KEY,
  race_id TEXT NOT NULL REFERENCES public.srd_races(id) ON DELETE CASCADE,
  class_id TEXT NOT NULL REFERENCES public.srd_classes(id) ON DELETE CASCADE,
  variant SMALLINT NOT NULL CHECK (variant BETWEEN 1 AND 5),
  role_key TEXT NOT NULL,
  nome TEXT NOT NULL,
  briefing TEXT NOT NULL,
  foco_atributos JSONB NOT NULL DEFAULT '[]'::JSONB,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (race_id,class_id,variant)
);

ALTER TABLE public.srd_npc_archetypes ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON public.srd_npc_archetypes TO anon, authenticated;
DROP POLICY IF EXISTS srd_npc_archetypes_catalog_read ON public.srd_npc_archetypes;
CREATE POLICY srd_npc_archetypes_catalog_read
  ON public.srd_npc_archetypes FOR SELECT TO anon, authenticated USING (TRUE);

INSERT INTO public.srd_npc_archetypes (id,race_id,class_id,variant,role_key,nome,briefing,foco_atributos)
SELECT race.id||'--'||class.id||'--'||v.variant,
       race.id,class.id,v.variant,v.role_key,
       race.nome||' '||class.nome||' · '||v.nome,
       v.briefing,
       CASE lower(class.nome)
         WHEN 'bárbaro' THEN '["FOR","CON","DES"]'::jsonb
         WHEN 'bardo' THEN '["CAR","DES","CON"]'::jsonb
         WHEN 'clérigo' THEN '["SAB","FOR","CON"]'::jsonb
         WHEN 'druida' THEN '["SAB","CON","DES"]'::jsonb
         WHEN 'guerreiro' THEN '["FOR","CON","DES"]'::jsonb
         WHEN 'monge' THEN '["DES","SAB","CON"]'::jsonb
         WHEN 'paladino' THEN '["FOR","CAR","CON"]'::jsonb
         WHEN 'ranger' THEN '["DES","SAB","CON"]'::jsonb
         WHEN 'ladino' THEN '["DES","INT","CAR"]'::jsonb
         WHEN 'feiticeiro' THEN '["CAR","DES","CON"]'::jsonb
         WHEN 'mago' THEN '["INT","DES","CON"]'::jsonb
         ELSE '["FOR","DES","CON"]'::jsonb
       END
FROM public.srd_races AS race
CROSS JOIN public.srd_classes AS class
CROSS JOIN (VALUES
  (1,'agressor','Agressor','Busca causar dano direto e pressionar o adversário.'),
  (2,'guardiao','Guardião','Prioriza resistência e proteção dos aliados.'),
  (3,'batedor','Batedor','Valoriza mobilidade, iniciativa e ataques oportunos.'),
  (4,'especialista','Especialista','Favorece os atributos e perícias centrais da classe.'),
  (5,'versatil','Versátil','Distribui recursos para atuar em diferentes situações.')
) AS v(variant,role_key,nome,briefing)
ON CONFLICT (race_id,class_id,variant) DO UPDATE SET
  role_key=EXCLUDED.role_key,
  nome=EXCLUDED.nome,
  briefing=EXCLUDED.briefing,
  foco_atributos=EXCLUDED.foco_atributos,
  updated_at=now();

CREATE INDEX IF NOT EXISTS srd_npc_archetypes_race_class_idx
  ON public.srd_npc_archetypes (race_id,class_id,variant);

COMMENT ON TABLE public.srd_npc_archetypes IS
  'Cinco perfis de geração reutilizáveis por raça e classe do D&D 3.5 SRD. O nível é selecionado pelo Mestre; atributos, PV, CA e ataque são materializados no token de cena.';

COMMIT;
