-- D&D 3.5 SRD: base versioned ruleset/provenance and normalized rule-engine state.
-- Backwards-compatible: preserves legacy JSON snapshots; new engine code can dual-read/migrate.
BEGIN;

CREATE TABLE IF NOT EXISTS public.srd_rule_sources (
  source_id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  edition TEXT NOT NULL,
  version TEXT NOT NULL,
  license_identifier TEXT NOT NULL,
  attribution TEXT NOT NULL,
  source_url TEXT NOT NULL,
  is_open_content BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (source_url ~ '^https://')
);

CREATE TABLE IF NOT EXISTS public.srd_rulesets (
  ruleset_id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  edition TEXT NOT NULL,
  version TEXT NOT NULL,
  primary_source_id TEXT REFERENCES public.srd_rule_sources(source_id),
  locale TEXT NOT NULL DEFAULT 'pt-BR',
  status TEXT NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft','active','retired')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.srd_rule_modules (
  module_id TEXT PRIMARY KEY,
  ruleset_id TEXT NOT NULL REFERENCES public.srd_rulesets(ruleset_id) ON DELETE CASCADE,
  module_key TEXT NOT NULL,
  title TEXT NOT NULL,
  module_kind TEXT NOT NULL DEFAULT 'core'
    CHECK (module_kind IN ('core','supplement','house_rule','interface')),
  source_id TEXT REFERENCES public.srd_rule_sources(source_id),
  enabled_by_default BOOLEAN NOT NULL DEFAULT FALSE,
  UNIQUE (ruleset_id,module_key)
);

CREATE TABLE IF NOT EXISTS public.campaign_rule_modules (
  campaign_id BIGINT NOT NULL REFERENCES public.campaigns(id) ON DELETE CASCADE,
  module_id TEXT NOT NULL REFERENCES public.srd_rule_modules(module_id) ON DELETE RESTRICT,
  enabled BOOLEAN NOT NULL DEFAULT TRUE,
  automation_level TEXT NOT NULL DEFAULT 'validate'
    CHECK (automation_level IN ('remind','validate','resolve')),
  settings JSONB NOT NULL DEFAULT '{}'::JSONB
    CHECK (jsonb_typeof(settings)='object'),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (campaign_id,module_id)
);

INSERT INTO public.srd_rule_sources
  (source_id,title,edition,version,license_identifier,attribution,source_url,is_open_content)
VALUES
  ('dnd35-srd-ogl','D&D v3.5 System Reference Document','D&D 3.5','SRD 3.5 / OGL 1.0a',
   'Open Game License 1.0a',
   'Open Game Content; retain the required attribution and license notice from OPEN_GAME_LICENSE_1.0a.txt.',
   'https://www.d20srd.org/',TRUE)
ON CONFLICT (source_id) DO NOTHING;

INSERT INTO public.srd_rulesets
  (ruleset_id,name,edition,version,primary_source_id,locale,status)
VALUES
  ('dnd35-srd','D&D 3.5 · SRD','D&D 3.5','SRD 3.5 / OGL 1.0a','dnd35-srd-ogl','pt-BR','active')
ON CONFLICT (ruleset_id) DO NOTHING;

INSERT INTO public.srd_rule_modules
  (module_id,ruleset_id,module_key,title,module_kind,source_id,enabled_by_default)
VALUES
  ('dnd35-character','dnd35-srd','character','Criação e progressão','core','dnd35-srd-ogl',TRUE),
  ('dnd35-races','dnd35-srd','races','Raças','core','dnd35-srd-ogl',TRUE),
  ('dnd35-classes','dnd35-srd','classes','Classes e progressões','core','dnd35-srd-ogl',TRUE),
  ('dnd35-skills','dnd35-srd','skills','Perícias','core','dnd35-srd-ogl',TRUE),
  ('dnd35-feats','dnd35-srd','feats','Talentos','core','dnd35-srd-ogl',TRUE),
  ('dnd35-equipment','dnd35-srd','equipment','Equipamentos','core','dnd35-srd-ogl',TRUE),
  ('dnd35-spellcasting','dnd35-srd','spellcasting','Conjuração por classe','core','dnd35-srd-ogl',TRUE),
  ('dnd35-spells','dnd35-srd','spells','Magias e efeitos','core','dnd35-srd-ogl',TRUE),
  ('dnd35-combat','dnd35-srd','combat','Combate e ações','core','dnd35-srd-ogl',TRUE),
  ('dnd35-conditions','dnd35-srd','conditions','Condições','core','dnd35-srd-ogl',TRUE),
  ('dnd35-monsters','dnd35-srd','monsters','Monstros','core','dnd35-srd-ogl',TRUE),
  ('dnd35-environment','dnd35-srd','environment','Movimento e ambiente','core','dnd35-srd-ogl',TRUE)
ON CONFLICT (module_id) DO NOTHING;

-- Catalog provenance: an attached URL is not treated as verified until an audit marks it so.
DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'srd_races','srd_classes','srd_skills','srd_feats','srd_equipment',
    'srd_spells','srd_monsters','srd_starting_packages','srd_npc_archetypes'
  ] LOOP
    EXECUTE format('ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS source_id TEXT REFERENCES public.srd_rule_sources(source_id)',t);
    EXECUTE format('ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS source_status TEXT NOT NULL DEFAULT ''unreviewed''',t);
    EXECUTE format('ALTER TABLE public.%I ADD COLUMN IF NOT EXISTS source_notes TEXT',t);
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname=t||'_source_status_check') THEN
      EXECUTE format('ALTER TABLE public.%I ADD CONSTRAINT %I CHECK (source_status IN (''unreviewed'',''source_attached'',''verified_srd'',''derived'',''house_rule'',''needs_license'',''excluded''))',
        t,t||'_source_status_check');
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name=t AND column_name='srd_source_url') THEN
      EXECUTE format('UPDATE public.%I SET source_status=CASE WHEN NULLIF(srd_source_url,'''') IS NULL THEN ''unreviewed'' ELSE ''source_attached'' END WHERE source_status=''unreviewed''',t);
    END IF;
  END LOOP;
END $$;
UPDATE public.srd_starting_packages SET source_status='derived' WHERE source_status='unreviewed';
UPDATE public.srd_npc_archetypes SET source_status='derived' WHERE source_status='unreviewed';

-- Canonical keys connect localized class IDs to SRD progression tables.
ALTER TABLE public.srd_classes ADD COLUMN IF NOT EXISTS class_key TEXT;
UPDATE public.srd_classes
SET class_key=CASE id
  WHEN 'barbaro' THEN 'barbarian'
  WHEN 'bardo' THEN 'bard'
  WHEN 'clerigo' THEN 'cleric'
  WHEN 'druida' THEN 'druid'
  WHEN 'feiticeiro' THEN 'sorcerer'
  WHEN 'guerreiro' THEN 'fighter'
  WHEN 'ladino' THEN 'rogue'
  WHEN 'mago' THEN 'wizard'
  WHEN 'monge' THEN 'monk'
  WHEN 'paladino' THEN 'paladin'
  WHEN 'ranger' THEN 'ranger'
  ELSE class_key END
WHERE class_key IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS srd_classes_class_key_uidx
  ON public.srd_classes(class_key) WHERE class_key IS NOT NULL;

CREATE TABLE IF NOT EXISTS public.srd_class_level_progressions (
  class_id TEXT NOT NULL REFERENCES public.srd_classes(id) ON DELETE CASCADE,
  class_level SMALLINT NOT NULL CHECK (class_level BETWEEN 1 AND 20),
  base_attack_bonus NUMERIC(5,2) NOT NULL CHECK (base_attack_bonus >= 0),
  base_fortitude SMALLINT NOT NULL CHECK (base_fortitude >= 0),
  base_reflex SMALLINT NOT NULL CHECK (base_reflex >= 0),
  base_will SMALLINT NOT NULL CHECK (base_will >= 0),
  skill_points_per_level SMALLINT NOT NULL DEFAULT 0 CHECK (skill_points_per_level >= 0),
  first_level_skill_multiplier SMALLINT NOT NULL DEFAULT 4 CHECK (first_level_skill_multiplier > 0),
  source_id TEXT REFERENCES public.srd_rule_sources(source_id),
  verification_status TEXT NOT NULL DEFAULT 'derived_pending_review'
    CHECK (verification_status IN ('derived_pending_review','verified_srd','needs_review')),
  PRIMARY KEY (class_id,class_level)
);

INSERT INTO public.srd_class_level_progressions
 (class_id,class_level,base_attack_bonus,base_fortitude,base_reflex,base_will,skill_points_per_level,source_id,verification_status)
SELECT c.id,l.level,
       CASE
         WHEN lower(coalesce(c.bab_progression,'')) IN ('good','bom') THEN l.level::numeric
         WHEN lower(coalesce(c.bab_progression,'')) IN ('average','medium','medio') THEN floor(3*l.level/4.0)
         ELSE floor(l.level/2.0)
       END,
       CASE WHEN c.fort_bom THEN 2+floor((l.level-1)/2.0)::integer ELSE floor(l.level/3.0)::integer END,
       CASE WHEN c.ref_bom THEN 2+floor((l.level-1)/2.0)::integer ELSE floor(l.level/3.0)::integer END,
       CASE WHEN c.von_bom THEN 2+floor((l.level-1)/2.0)::integer ELSE floor(l.level/3.0)::integer END,
       coalesce(c.pericias_por_nivel,0),'dnd35-srd-ogl','derived_pending_review'
FROM public.srd_classes c CROSS JOIN generate_series(1,20) AS l(level)
ON CONFLICT (class_id,class_level) DO NOTHING;

CREATE TABLE IF NOT EXISTS public.srd_class_level_features (
  class_id TEXT NOT NULL,
  class_level SMALLINT NOT NULL,
  feature_key TEXT NOT NULL,
  name TEXT NOT NULL,
  summary TEXT NOT NULL DEFAULT '',
  mechanics JSONB NOT NULL DEFAULT '{}'::JSONB CHECK (jsonb_typeof(mechanics)='object'),
  source_id TEXT REFERENCES public.srd_rule_sources(source_id),
  verification_status TEXT NOT NULL DEFAULT 'unreviewed'
    CHECK (verification_status IN ('unreviewed','verified_srd','derived','needs_license')),
  PRIMARY KEY (class_id,class_level,feature_key),
  FOREIGN KEY (class_id,class_level)
    REFERENCES public.srd_class_level_progressions(class_id,class_level) ON DELETE CASCADE
);

-- Normalize the existing JSON slot tables without deleting their compatibility representation.
CREATE TABLE IF NOT EXISTS public.srd_spell_level_progressions (
  class_id TEXT NOT NULL REFERENCES public.srd_classes(id) ON DELETE CASCADE,
  class_level SMALLINT NOT NULL CHECK (class_level BETWEEN 1 AND 20),
  spell_level SMALLINT NOT NULL CHECK (spell_level BETWEEN 0 AND 9),
  base_slots SMALLINT NOT NULL DEFAULT 0 CHECK (base_slots >= 0),
  known_spells SMALLINT CHECK (known_spells IS NULL OR known_spells >= -1),
  source_id TEXT REFERENCES public.srd_rule_sources(source_id),
  verification_status TEXT NOT NULL DEFAULT 'derived_pending_review'
    CHECK (verification_status IN ('derived_pending_review','verified_srd','needs_review')),
  PRIMARY KEY (class_id,class_level,spell_level)
);

INSERT INTO public.srd_spell_level_progressions
 (class_id,class_level,spell_level,base_slots,known_spells,source_id,verification_status)
SELECT c.id,lv.ordinality::smallint,(sl.ordinality-1)::smallint,
       greatest(0,(sl.value #>> '{}')::smallint),
       CASE WHEN jsonb_typeof(p.known_by_level)='array'
                   AND jsonb_array_length(p.known_by_level)>0
                   AND jsonb_typeof(p.known_by_level->((lv.ordinality-1)::integer))='array'
            THEN (kn.value #>> '{}')::smallint ELSE NULL END,
       'dnd35-srd-ogl','derived_pending_review'
FROM public.srd_spell_progressions p
JOIN public.srd_classes c ON c.class_key=p.class_key
CROSS JOIN LATERAL jsonb_array_elements(
  CASE WHEN jsonb_typeof(p.slots_by_level)='array' THEN p.slots_by_level ELSE '[]'::jsonb END
) WITH ORDINALITY AS lv(row_data,ordinality)
CROSS JOIN LATERAL jsonb_array_elements(
  CASE WHEN jsonb_typeof(lv.row_data)='array' THEN lv.row_data ELSE '[]'::jsonb END
) WITH ORDINALITY AS sl(value,ordinality)
LEFT JOIN LATERAL jsonb_array_elements(
  CASE WHEN jsonb_typeof(p.known_by_level)='array'
         AND jsonb_array_length(p.known_by_level)>=lv.ordinality
         AND jsonb_typeof(p.known_by_level->((lv.ordinality-1)::integer))='array'
       THEN p.known_by_level->((lv.ordinality-1)::integer) ELSE '[]'::jsonb END
) WITH ORDINALITY AS kn(value,ordinality) ON kn.ordinality=sl.ordinality
ON CONFLICT (class_id,class_level,spell_level) DO UPDATE
SET base_slots=EXCLUDED.base_slots,known_spells=EXCLUDED.known_spells,
    source_id=EXCLUDED.source_id,verification_status='derived_pending_review';

CREATE TABLE IF NOT EXISTS public.srd_domains (
  domain_id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  granted_power_summary TEXT NOT NULL DEFAULT '',
  mechanics JSONB NOT NULL DEFAULT '{}'::JSONB CHECK (jsonb_typeof(mechanics)='object'),
  source_id TEXT REFERENCES public.srd_rule_sources(source_id),
  source_url TEXT,
  verification_status TEXT NOT NULL DEFAULT 'unreviewed'
    CHECK (verification_status IN ('unreviewed','verified_srd','needs_review','needs_license'))
);

CREATE TABLE IF NOT EXISTS public.srd_domain_spells (
  domain_id TEXT NOT NULL REFERENCES public.srd_domains(domain_id) ON DELETE CASCADE,
  spell_level SMALLINT NOT NULL CHECK (spell_level BETWEEN 0 AND 9),
  spell_id TEXT NOT NULL REFERENCES public.srd_spells(id) ON DELETE RESTRICT,
  source_id TEXT REFERENCES public.srd_rule_sources(source_id),
  verification_status TEXT NOT NULL DEFAULT 'unreviewed'
    CHECK (verification_status IN ('unreviewed','verified_srd','needs_review')),
  PRIMARY KEY (domain_id,spell_level)
);

CREATE TABLE IF NOT EXISTS public.srd_character_class_levels (
  character_id BIGINT NOT NULL REFERENCES public.characters(id) ON DELETE CASCADE,
  class_id TEXT NOT NULL REFERENCES public.srd_classes(id) ON DELETE RESTRICT,
  class_level INTEGER NOT NULL CHECK (class_level > 0),
  taken_at_character_level INTEGER CHECK (taken_at_character_level IS NULL OR taken_at_character_level > 0),
  hit_points_gained INTEGER CHECK (hit_points_gained IS NULL OR hit_points_gained >= 0),
  skill_points_spent JSONB NOT NULL DEFAULT '{}'::JSONB CHECK (jsonb_typeof(skill_points_spent)='object'),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (character_id,class_id)
);
INSERT INTO public.srd_character_class_levels(character_id,class_id,class_level)
SELECT character_id,classe_id,greatest(1,coalesce(nivel,1))
FROM public.srd_character_sheets
ON CONFLICT (character_id,class_id) DO NOTHING;

CREATE TABLE IF NOT EXISTS public.srd_character_spellbook (
  character_id BIGINT NOT NULL REFERENCES public.characters(id) ON DELETE CASCADE,
  class_id TEXT NOT NULL REFERENCES public.srd_classes(id) ON DELETE CASCADE,
  spell_id TEXT NOT NULL REFERENCES public.srd_spells(id) ON DELETE RESTRICT,
  acquired_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  source_note TEXT,
  PRIMARY KEY (character_id,class_id,spell_id)
);

CREATE TABLE IF NOT EXISTS public.srd_character_known_spells (
  character_id BIGINT NOT NULL REFERENCES public.characters(id) ON DELETE CASCADE,
  class_id TEXT NOT NULL REFERENCES public.srd_classes(id) ON DELETE CASCADE,
  spell_id TEXT NOT NULL REFERENCES public.srd_spells(id) ON DELETE RESTRICT,
  learned_at_character_level INTEGER NOT NULL DEFAULT 1 CHECK (learned_at_character_level > 0),
  source_note TEXT,
  PRIMARY KEY (character_id,class_id,spell_id)
);

CREATE TABLE IF NOT EXISTS public.srd_character_prepared_spells (
  preparation_id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  character_id BIGINT NOT NULL REFERENCES public.characters(id) ON DELETE CASCADE,
  class_id TEXT NOT NULL REFERENCES public.srd_classes(id) ON DELETE CASCADE,
  spell_id TEXT REFERENCES public.srd_spells(id) ON DELETE RESTRICT,
  spell_level SMALLINT NOT NULL CHECK (spell_level BETWEEN 0 AND 9),
  slot_number SMALLINT NOT NULL CHECK (slot_number > 0),
  prepared_for TIMESTAMPTZ NOT NULL,
  expended BOOLEAN NOT NULL DEFAULT FALSE,
  source_track TEXT NOT NULL DEFAULT 'class'
    CHECK (source_track IN ('class','domain','special')),
  UNIQUE (character_id,class_id,prepared_for,spell_level,slot_number,source_track)
);

CREATE TABLE IF NOT EXISTS public.srd_character_spell_slot_state (
  character_id BIGINT NOT NULL REFERENCES public.characters(id) ON DELETE CASCADE,
  class_id TEXT NOT NULL REFERENCES public.srd_classes(id) ON DELETE CASCADE,
  spell_level SMALLINT NOT NULL CHECK (spell_level BETWEEN 0 AND 9),
  period_started_at TIMESTAMPTZ NOT NULL,
  max_slots SMALLINT NOT NULL CHECK (max_slots >= 0),
  expended_slots SMALLINT NOT NULL DEFAULT 0 CHECK (expended_slots >= 0 AND expended_slots<=max_slots),
  PRIMARY KEY (character_id,class_id,spell_level,period_started_at)
);

CREATE TABLE IF NOT EXISTS public.srd_character_domain_choices (
  character_id BIGINT NOT NULL REFERENCES public.characters(id) ON DELETE CASCADE,
  domain_slot SMALLINT NOT NULL CHECK (domain_slot BETWEEN 1 AND 2),
  domain_id TEXT NOT NULL REFERENCES public.srd_domains(domain_id) ON DELETE RESTRICT,
  chosen_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (character_id,domain_slot),
  UNIQUE (character_id,domain_id)
);

CREATE TABLE IF NOT EXISTS public.srd_conditions (
  condition_id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  summary TEXT NOT NULL DEFAULT '',
  mechanical_effects JSONB NOT NULL DEFAULT '{}'::JSONB CHECK (jsonb_typeof(mechanical_effects)='object'),
  source_id TEXT REFERENCES public.srd_rule_sources(source_id),
  source_url TEXT,
  verification_status TEXT NOT NULL DEFAULT 'unreviewed'
    CHECK (verification_status IN ('unreviewed','verified_srd','needs_review','needs_license'))
);

CREATE TABLE IF NOT EXISTS public.srd_spell_effects (
  spell_id TEXT NOT NULL REFERENCES public.srd_spells(id) ON DELETE CASCADE,
  effect_index SMALLINT NOT NULL CHECK (effect_index > 0),
  effect_kind TEXT NOT NULL
    CHECK (effect_kind IN ('attack','damage','healing','saving_throw','condition','buff','debuff','summon','movement','utility','drain','special','manual')),
  target_kind TEXT NOT NULL DEFAULT 'target',
  saving_throw TEXT CHECK (saving_throw IS NULL OR saving_throw IN ('fortitude','reflex','will','special')),
  save_result TEXT CHECK (save_result IS NULL OR save_result IN ('negates','partial','half','special')),
  spell_resistance BOOLEAN,
  damage_expression TEXT,
  duration_expression TEXT,
  parameters JSONB NOT NULL DEFAULT '{}'::JSONB CHECK (jsonb_typeof(parameters)='object'),
  source_id TEXT REFERENCES public.srd_rule_sources(source_id),
  verification_status TEXT NOT NULL DEFAULT 'unreviewed'
    CHECK (verification_status IN ('unreviewed','verified_srd','needs_review','manual_only')),
  PRIMARY KEY (spell_id,effect_index)
);

CREATE TABLE IF NOT EXISTS public.srd_campaign_conditions (
  condition_instance_id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  campaign_id BIGINT NOT NULL REFERENCES public.campaigns(id) ON DELETE CASCADE,
  target_kind TEXT NOT NULL CHECK (target_kind IN ('character','token')),
  target_id TEXT NOT NULL,
  condition_id TEXT NOT NULL REFERENCES public.srd_conditions(condition_id) ON DELETE RESTRICT,
  source_spell_id TEXT REFERENCES public.srd_spells(id) ON DELETE SET NULL,
  source_actor_id TEXT,
  started_round INTEGER,
  expires_round INTEGER,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  notes JSONB NOT NULL DEFAULT '{}'::JSONB CHECK (jsonb_typeof(notes)='object'),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.srd_campaign_effects (
  effect_instance_id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  campaign_id BIGINT NOT NULL REFERENCES public.campaigns(id) ON DELETE CASCADE,
  target_kind TEXT NOT NULL CHECK (target_kind IN ('character','token','area')),
  target_id TEXT,
  source_spell_id TEXT REFERENCES public.srd_spells(id) ON DELETE SET NULL,
  effect_kind TEXT NOT NULL,
  started_round INTEGER,
  expires_round INTEGER,
  concentration_actor_id TEXT,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  effect_data JSONB NOT NULL DEFAULT '{}'::JSONB CHECK (jsonb_typeof(effect_data)='object'),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.srd_catalog_coverage (
  catalog_key TEXT PRIMARY KEY,
  ruleset_id TEXT NOT NULL REFERENCES public.srd_rulesets(ruleset_id),
  expected_entries INTEGER CHECK (expected_entries IS NULL OR expected_entries>=0),
  actual_entries INTEGER NOT NULL DEFAULT 0 CHECK (actual_entries>=0),
  verified_entries INTEGER NOT NULL DEFAULT 0 CHECK (verified_entries>=0),
  audit_status TEXT NOT NULL DEFAULT 'pending'
    CHECK (audit_status IN ('pending','in_progress','complete','blocked','excluded')),
  audit_notes TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO public.srd_catalog_coverage(catalog_key,ruleset_id,actual_entries,audit_status,audit_notes)
VALUES
 ('races','dnd35-srd',(SELECT count(*) FROM public.srd_races),'pending','Entry-by-entry source and field coverage audit pending.'),
 ('classes','dnd35-srd',(SELECT count(*) FROM public.srd_classes),'pending','Level features, multiclass rules and prerequisites require complete SRD audit.'),
 ('skills','dnd35-srd',(SELECT count(*) FROM public.srd_skills),'pending','Verify all skills, trained-only rules, synergy and uses.'),
 ('feats','dnd35-srd',(SELECT count(*) FROM public.srd_feats),'pending','Verify every feat, prerequisite and feat progression.'),
 ('equipment','dnd35-srd',(SELECT count(*) FROM public.srd_equipment),'pending','Audit mundane, special materials and magic items as separate supported modules.'),
 ('spells','dnd35-srd',(SELECT count(*) FROM public.srd_spells),'pending','Audit spell index, class/domain lists, components and typed effects.'),
 ('monsters','dnd35-srd',(SELECT count(*) FROM public.srd_monsters),'pending','Audit complete SRD bestiary and stat-block mechanics.'),
 ('class_features','dnd35-srd',(SELECT count(*) FROM public.srd_class_level_features),'pending','Level-by-level feature ingestion not yet complete.'),
 ('domains','dnd35-srd',(SELECT count(*) FROM public.srd_domains),'pending','Cleric domain powers and domain spell lists pending.'),
 ('spell_effects','dnd35-srd',(SELECT count(*) FROM public.srd_spell_effects),'pending','Effects are not complete until each spell effect is structured or marked manual.'),
 ('conditions','dnd35-srd',(SELECT count(*) FROM public.srd_conditions),'pending','Condition catalog and mechanical modifiers pending.');

-- Compatibility columns expose exactly which rows still need provenance review.
UPDATE public.srd_rule_sources SET is_open_content=TRUE WHERE source_id='dnd35-srd-ogl';

CREATE INDEX IF NOT EXISTS srd_character_class_levels_class_idx ON public.srd_character_class_levels(class_id);
CREATE INDEX IF NOT EXISTS srd_character_spell_known_idx ON public.srd_character_known_spells(character_id,class_id);
CREATE INDEX IF NOT EXISTS srd_character_prepared_period_idx ON public.srd_character_prepared_spells(character_id,prepared_for,expended);
CREATE INDEX IF NOT EXISTS srd_campaign_conditions_target_idx ON public.srd_campaign_conditions(campaign_id,target_kind,target_id,active);
CREATE INDEX IF NOT EXISTS srd_campaign_effects_target_idx ON public.srd_campaign_effects(campaign_id,target_kind,target_id,active);

-- Catalog tables are read-only through the client Data API. Import writes remain server/migration-only.
DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'srd_rule_sources','srd_rulesets','srd_rule_modules','srd_class_level_progressions',
    'srd_class_level_features','srd_spell_level_progressions','srd_domains','srd_domain_spells',
    'srd_conditions','srd_spell_effects','srd_catalog_coverage'
  ] LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY',t);
    EXECUTE format('REVOKE ALL ON TABLE public.%I FROM PUBLIC, anon, authenticated',t);
    EXECUTE format('GRANT SELECT ON TABLE public.%I TO authenticated',t);
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I',t||'_read',t);
    EXECUTE format('CREATE POLICY %I ON public.%I FOR SELECT TO authenticated USING (TRUE)',t||'_read',t);
  END LOOP;
END $$;

DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'campaign_rule_modules','srd_character_class_levels','srd_character_spellbook',
    'srd_character_known_spells','srd_character_prepared_spells','srd_character_spell_slot_state',
    'srd_character_domain_choices'
  ] LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY',t);
    EXECUTE format('REVOKE ALL ON TABLE public.%I FROM PUBLIC, anon, authenticated',t);
    EXECUTE format('GRANT SELECT ON TABLE public.%I TO authenticated',t);
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I',t||'_member_read',t);
  END LOOP;
END $$;

CREATE POLICY campaign_rule_modules_member_read ON public.campaign_rule_modules
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM public.campaigns c WHERE c.id=campaign_rule_modules.campaign_id AND c.owner_id=(SELECT auth.uid()))
    OR EXISTS (SELECT 1 FROM public.members m WHERE m.campaign_id=campaign_rule_modules.campaign_id AND m.user_id=(SELECT auth.uid()))
  );

CREATE POLICY srd_character_class_levels_owner_read ON public.srd_character_class_levels
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM public.characters ch WHERE ch.id=character_id AND ch.user_id=(SELECT auth.uid()))
    OR EXISTS (SELECT 1 FROM public.characters ch JOIN public.members m ON m.campaign_id=ch.campaign_id
               WHERE ch.id=character_id AND m.user_id=(SELECT auth.uid()) AND m.role='GM')
  );

CREATE POLICY srd_character_spellbook_owner_read ON public.srd_character_spellbook
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM public.characters ch WHERE ch.id=character_id AND ch.user_id=(SELECT auth.uid()))
    OR EXISTS (SELECT 1 FROM public.characters ch JOIN public.members m ON m.campaign_id=ch.campaign_id
               WHERE ch.id=character_id AND m.user_id=(SELECT auth.uid()) AND m.role='GM')
  );
CREATE POLICY srd_character_known_spells_owner_read ON public.srd_character_known_spells
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM public.characters ch WHERE ch.id=character_id AND ch.user_id=(SELECT auth.uid()))
    OR EXISTS (SELECT 1 FROM public.characters ch JOIN public.members m ON m.campaign_id=ch.campaign_id
               WHERE ch.id=character_id AND m.user_id=(SELECT auth.uid()) AND m.role='GM')
  );
CREATE POLICY srd_character_prepared_spells_owner_read ON public.srd_character_prepared_spells
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM public.characters ch WHERE ch.id=character_id AND ch.user_id=(SELECT auth.uid()))
    OR EXISTS (SELECT 1 FROM public.characters ch JOIN public.members m ON m.campaign_id=ch.campaign_id
               WHERE ch.id=character_id AND m.user_id=(SELECT auth.uid()) AND m.role='GM')
  );
CREATE POLICY srd_character_spell_slot_state_owner_read ON public.srd_character_spell_slot_state
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM public.characters ch WHERE ch.id=character_id AND ch.user_id=(SELECT auth.uid()))
    OR EXISTS (SELECT 1 FROM public.characters ch JOIN public.members m ON m.campaign_id=ch.campaign_id
               WHERE ch.id=character_id AND m.user_id=(SELECT auth.uid()) AND m.role='GM')
  );
CREATE POLICY srd_character_domain_choices_owner_read ON public.srd_character_domain_choices
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM public.characters ch WHERE ch.id=character_id AND ch.user_id=(SELECT auth.uid()))
    OR EXISTS (SELECT 1 FROM public.characters ch JOIN public.members m ON m.campaign_id=ch.campaign_id
               WHERE ch.id=character_id AND m.user_id=(SELECT auth.uid()) AND m.role='GM')
  );

DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY['srd_campaign_conditions','srd_campaign_effects'] LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY',t);
    EXECUTE format('REVOKE ALL ON TABLE public.%I FROM PUBLIC, anon, authenticated',t);
    EXECUTE format('GRANT SELECT ON TABLE public.%I TO authenticated',t);
    EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I',t||'_member_read',t);
    EXECUTE format(
      'CREATE POLICY %I ON public.%I FOR SELECT TO authenticated USING (
         EXISTS (SELECT 1 FROM public.campaigns c WHERE c.id=public.%I.campaign_id AND c.owner_id=(SELECT auth.uid()))
         OR EXISTS (SELECT 1 FROM public.members m WHERE m.campaign_id=public.%I.campaign_id AND m.user_id=(SELECT auth.uid()))
       )',t||'_member_read',t,t,t);
  END LOOP;
END $$;

COMMIT;
