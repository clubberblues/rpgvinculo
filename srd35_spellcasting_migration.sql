-- SRD 3.5 spellcasting migration.
-- Progression data transcribed from the d20 SRD class tables:
-- https://www.d20srd.org/srd/classes/sorcererWizard.htm
-- https://www.d20srd.org/srd/classes/cleric.htm
-- https://www.d20srd.org/srd/classes/druid.htm
--
-- Uses the verified srd_character_sheets columns (classe_id, nivel, atributos,
-- pv_atual, pv_max), characters.campaign_id, and campaigns.cba_data.tokens contract.

BEGIN;

ALTER TABLE public.srd_character_sheets
  ADD COLUMN IF NOT EXISTS magias_preparadas JSONB NOT NULL
    DEFAULT '{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb;
ALTER TABLE public.srd_character_sheets
  ADD COLUMN IF NOT EXISTS magias_descanso_em TIMESTAMPTZ;

CREATE TABLE IF NOT EXISTS public.srd_spell_progressions (
  class_key TEXT PRIMARY KEY,
  slots_by_level JSONB NOT NULL,
  known_by_level JSONB NOT NULL DEFAULT '[]'::jsonb
);

-- Each encoded row has ten digits in circle order 0..9. Each table has levels 1..20.
WITH raw(class_key, slots, known) AS (
  VALUES
  ('wizard', ARRAY[
    '3100000000','4200000000','4210000000','4320000000','4321000000',
    '4332000000','4432100000','4433200000','4443210000','4443320000',
    '4444321000','4444332000','4444432100','4444433200','4444443210',
    '4444443320','4444444321','4444444332','4444444433','4444444444'
  ]::text[], ARRAY[]::text[]),
  ('sorcerer', ARRAY[
    '5300000000','6400000000','6500000000','6630000000','6640000000',
    '6653000000','6664000000','6665300000','6666400000','6666530000',
    '6666640000','6666653000','6666664000','6666665300','6666666400',
    '6666666530','6666666640','6666666653','6666666664','6666666666'
  ]::text[], ARRAY[
    '4200000000','5200000000','5300000000','6310000000','6420000000',
    '7421000000','7532000000','8532100000','8543200000','9543210000',
    '9554320000','9554321000','9554432000','9554432100','9554443200',
    '9554443210','9554443320','9554443321','9554443332','9554443333'
  ]::text[]),
  ('cleric', ARRAY[
    '3100000000','4200000000','4210000000','5320000000','5321000000',
    '5332000000','6432100000','6433200000','6443210000','6443320000',
    '6544321000','6544332000','6554432100','6554433200','6555443210',
    '6555443320','6555544321','6555544332','6555554433','6555554444'
  ]::text[], ARRAY[]::text[]),
  ('druid', ARRAY[
    '3100000000','4200000000','4210000000','5320000000','5321000000',
    '5332000000','6432100000','6433200000','6443210000','6443320000',
    '6544321000','6544332000','6554432100','6554433200','6555443210',
    '6555443320','6555544321','6555544332','6555554433','6555554444'
  ]::text[], ARRAY[]::text[])
), converted AS (
  SELECT r.class_key,
         (SELECT jsonb_agg(
                    (SELECT jsonb_agg(substring(u.row_text FROM g.i FOR 1)::integer ORDER BY g.i)
                       FROM generate_series(1,10) AS g(i))
                    ORDER BY u.ord)
            FROM unnest(r.slots) WITH ORDINALITY AS u(row_text,ord)) AS slots_by_level,
         CASE WHEN cardinality(r.known)=0 THEN '[]'::jsonb ELSE
           (SELECT jsonb_agg(
                      (SELECT jsonb_agg(substring(u.row_text FROM g.i FOR 1)::integer ORDER BY g.i)
                         FROM generate_series(1,10) AS g(i))
                      ORDER BY u.ord)
              FROM unnest(r.known) WITH ORDINALITY AS u(row_text,ord))
         END AS known_by_level
    FROM raw r
)
INSERT INTO public.srd_spell_progressions(class_key, slots_by_level, known_by_level)
SELECT class_key, slots_by_level, known_by_level FROM converted
ON CONFLICT (class_key) DO UPDATE
SET slots_by_level=EXCLUDED.slots_by_level, known_by_level=EXCLUDED.known_by_level;

-- Only insert absent stable SRD IDs. Spell IDs are intentionally namespaced.
INSERT INTO public.srd_spells
  (id,nome,nivel,circulo,escola,alcance,alvo,duracao,componentes,classes,descricao,dados_tecnicos)
VALUES
  ('srd35_acid_splash','Respingos Ácidos','0',0,'Conjuração','Curto','Uma criatura ou objeto','Instantânea','V, G',ARRAY['wizard','sorcerer']::text[],'Um pequeno orbe de ácido causa dano ácido.', '{"tipo_efeito":"ataque","dano":"1d3 ácido"}'::jsonb),
  ('srd35_detect_magic','Detectar Magia','0',0,'Adivinhação','60 ft','Cone','Concentração, até 1 min./nível','V, G',ARRAY['wizard','sorcerer','cleric','druid']::text[],'Detecta a presença de auras mágicas.', '{"tipo_efeito":"utilidade"}'::jsonb),
  ('srd35_light','Luz','0',0,'Evocação','Toque','Objeto tocado','10 min./nível','V, G',ARRAY['wizard','sorcerer','cleric','druid']::text[],'O objeto tocado brilha como uma tocha.', '{"tipo_efeito":"utilidade"}'::jsonb),
  ('srd35_mage_hand','Mãos Mágicas','0',0,'Transmutação','Curto','Objeto não carregado de até 5 lb.','Concentração','V, G',ARRAY['wizard','sorcerer']::text[],'Move um objeto pequeno à distância.', '{"tipo_efeito":"utilidade"}'::jsonb),
  ('srd35_resistance','Resistência','0',0,'Abjuração','Toque','Criatura tocada','1 min.','V, G, M',ARRAY['wizard','sorcerer','cleric','druid']::text[],'O alvo recebe +1 em testes de resistência.', '{"tipo_efeito":"utilidade"}'::jsonb),
  ('srd35_cure_minor_wounds','Curar Ferimentos Mínimos','0',0,'Conjuração (cura)','Toque','Criatura tocada','Instantânea','V, G',ARRAY['cleric','druid']::text[],'Cura 1 ponto de dano.', '{"tipo_efeito":"cura","cura":{"dados":"1","por_nivel":0,"max_nivel":0}}'::jsonb),
  ('srd35_bless','Bênção','1',1,'Encantamento','50 ft','Aliados em explosão de 50 ft','1 min./nível','V, G, FD',ARRAY['cleric']::text[],'Aliados recebem +1 em ataques e testes contra medo.', '{"tipo_efeito":"utilidade"}'::jsonb),
  ('srd35_cure_light_wounds','Curar Ferimentos Leves','1',1,'Conjuração (cura)','Toque','Criatura tocada','Instantânea','V, G',ARRAY['cleric','druid']::text[],'Cura 1d8 pontos de dano +1 por nível de conjurador (máximo +5).', '{"tipo_efeito":"cura","cura":{"dados":"1d8","por_nivel":1,"max_nivel":5}}'::jsonb),
  ('srd35_entangle','Emaranhar','1',1,'Transmutação','Longo','Plantas em raio de 40 ft','1 min./nível','V, G, FD',ARRAY['druid']::text[],'Plantas prendem criaturas na área.', '{"tipo_efeito":"utilidade"}'::jsonb),
  ('srd35_goodberry','Boa-Baga','1',1,'Transmutação','Toque','2d4 bagas frescas','1 dia/nível','V, G, FD',ARRAY['druid']::text[],'Bagas sustentam e curam 1 ponto de dano cada.', '{"tipo_efeito":"cura","cura":{"dados":"1","por_nivel":0,"max_nivel":0}}'::jsonb),
  ('srd35_magic_missile','Míssil Mágico','1',1,'Evocação','Médio','Até cinco criaturas, nenhuma a mais de 15 ft de outra','Instantânea','V, G',ARRAY['wizard','sorcerer']::text[],'Projéteis de força causam dano automaticamente.', '{"tipo_efeito":"ataque","dano":"1d4+1 por míssil"}'::jsonb),
  ('srd35_shield','Escudo','1',1,'Abjuração','Pessoal','Você','1 min./nível','V, G',ARRAY['wizard','sorcerer']::text[],'Cria um escudo invisível de força que concede bônus de escudo à CA.', '{"tipo_efeito":"utilidade"}'::jsonb),
  ('srd35_burning_hands','Mãos Flamejantes','1',1,'Evocação','15 ft','Criaturas em cone','Instantânea','V, G',ARRAY['wizard','sorcerer']::text[],'Um cone de chamas causa dano de fogo.', '{"tipo_efeito":"ataque","dano":"1d4 fogo/nível (máximo 5d4)"}'::jsonb),
  ('srd35_mage_armor','Armadura Arcana','1',1,'Conjuração','Toque','Criatura tocada','1 hora/nível','V, G, F',ARRAY['wizard','sorcerer']::text[],'Concede bônus de armadura +4 à CA.', '{"tipo_efeito":"utilidade"}'::jsonb)
ON CONFLICT (id) DO NOTHING;

CREATE OR REPLACE FUNCTION public._srd35_class_key(p_value text)
RETURNS text
LANGUAGE sql IMMUTABLE PARALLEL SAFE
SET search_path = pg_catalog, public
AS $fn$
  SELECT CASE translate(lower(trim(coalesce(p_value,''))), 'áéíóúãõâêôç', 'aeiouaoaeoc')
    WHEN 'wizard' THEN 'wizard' WHEN 'mago' THEN 'wizard'
    WHEN 'sorcerer' THEN 'sorcerer' WHEN 'feiticeiro' THEN 'sorcerer'
    WHEN 'cleric' THEN 'cleric' WHEN 'clerigo' THEN 'cleric' WHEN 'sacerdote' THEN 'cleric'
    WHEN 'druid' THEN 'druid' WHEN 'druida' THEN 'druid'
    ELSE NULL END
$fn$;

CREATE OR REPLACE FUNCTION public._srd35_attr(p_doc jsonb, p_keys text[])
RETURNS text
LANGUAGE plpgsql IMMUTABLE
SET search_path = pg_catalog, public
AS $fn$
DECLARE k text; v text; nested_key text; pair record;
BEGIN
  IF p_doc IS NULL THEN RETURN NULL; END IF;
  FOREACH k IN ARRAY p_keys LOOP
    SELECT value INTO v FROM jsonb_each_text(p_doc) AS e(key,value)
      WHERE lower(e.key)=lower(k) LIMIT 1;
    IF v IS NOT NULL AND btrim(v) <> '' THEN RETURN v; END IF;
  END LOOP;
  FOREACH nested_key IN ARRAY ARRAY['atributos','abilities','stats','ability_scores','character'] LOOP
    IF jsonb_typeof(p_doc -> nested_key) = 'object' THEN
      FOREACH k IN ARRAY p_keys LOOP
        SELECT value INTO v FROM jsonb_each_text(p_doc -> nested_key) AS e(key,value)
          WHERE lower(e.key)=lower(k) LIMIT 1;
        IF v IS NOT NULL AND btrim(v) <> '' THEN RETURN v; END IF;
      END LOOP;
    END IF;
    -- Attribute JSON may itself be wrapped in Portuguese/English nesting.
    IF jsonb_typeof(p_doc -> nested_key) = 'object' THEN
      FOR pair IN SELECT value FROM jsonb_each(p_doc -> nested_key) WHERE jsonb_typeof(value)='object' LOOP
        FOREACH k IN ARRAY p_keys LOOP
          SELECT value INTO v FROM jsonb_each_text(pair.value) AS e(key,value)
            WHERE lower(e.key)=lower(k) LIMIT 1;
          IF v IS NOT NULL AND btrim(v) <> '' THEN RETURN v; END IF;
        END LOOP;
      END LOOP;
    END IF;
  END LOOP;
  RETURN NULL;
END
$fn$;

CREATE OR REPLACE FUNCTION public._srd35_spell_class_ok(p_classes text[], p_class text)
RETURNS boolean
LANGUAGE sql IMMUTABLE PARALLEL SAFE
SET search_path = pg_catalog, public
AS $fn$
  SELECT coalesce(bool_or(public._srd35_class_key(c)=p_class),false)
    FROM unnest(coalesce(p_classes,ARRAY[]::text[])) AS u(c)
$fn$;

CREATE OR REPLACE FUNCTION public._srd35_slots(p_class text, p_level integer, p_score integer, p_circle integer)
RETURNS integer
LANGUAGE plpgsql STABLE
SET search_path = pg_catalog, public
AS $fn$
DECLARE base_slots integer; ability_mod integer; bonus_slots integer := 0;
BEGIN
  IF p_level < 1 OR p_level > 20 OR p_circle < 0 OR p_circle > 9 THEN RETURN 0; END IF;
  SELECT (slots_by_level -> (p_level-1) ->> p_circle)::integer
    INTO base_slots FROM public.srd_spell_progressions WHERE class_key=p_class;
  base_slots := coalesce(base_slots,0);
  IF p_circle > 0 AND p_score IS NOT NULL THEN
    ability_mod := floor((p_score-10)::numeric/2)::integer;
    IF ability_mod >= p_circle THEN
      bonus_slots := floor((ability_mod-p_circle)::numeric/4)::integer+1;
    END IF;
  END IF;
  -- Cleric domain slots are not included until the character schema models a selected domain.
  RETURN base_slots+bonus_slots;
END
$fn$;

CREATE OR REPLACE FUNCTION public.salvar_grimorio_srd(p_character_id text, p_estado jsonb)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_doc jsonb; v_class text; v_level integer; v_score integer;
  v_known jsonb; v_prepared jsonb; v_usos jsonb; v_old jsonb;
  v_spell record; v_entry jsonb; v_spell_id text; v_circle integer; v_slot integer;
  v_expended boolean; v_capacity integer; v_count integer; v_count_known integer;
  v_old_expended integer; v_new_ordinal integer; v_slot_key text; v_prepared_out jsonb := '[]'::jsonb;
  v_known_out jsonb := '[]'::jsonb; v_usos_out jsonb := '{}'::jsonb;
  v_key text; v_count_value integer; v_known_limits jsonb;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  IF NOT EXISTS (SELECT 1 FROM public.characters c
                  WHERE c.id::text=p_character_id AND c.user_id=auth.uid()) THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização';
  END IF;
  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s
   WHERE s.character_id::text=p_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;
  v_old := coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  IF p_estado IS NULL OR jsonb_typeof(p_estado) <> 'object' OR p_estado->>'version' <> '1'
     OR jsonb_typeof(p_estado->'conhecidas') <> 'array'
     OR jsonb_typeof(p_estado->'preparadas') <> 'array'
     OR jsonb_typeof(p_estado->'usos') <> 'object' THEN
    RAISE EXCEPTION 'Formato inválido; esperado {version:1, conhecidas:[], preparadas:[], usos:{}}';
  END IF;
  v_doc := to_jsonb(v_sheet);
  SELECT public._srd35_class_key(cl.nome) INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD referenciada por classe_id não encontrada ou incompatível'; END IF;
  v_level := v_sheet.nivel;
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível de classe ausente ou fora de 1..20'; END IF;
  v_score := CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(v_doc,ARRAY['INT','inteligencia','intelligence','int_score','score_inteligencia'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(v_doc,ARRAY['CAR','carisma','charisma','cha','cha_score','score_carisma'])::integer
    ELSE public._srd35_attr(v_doc,ARRAY['SAB','sabedoria','wisdom','wis','wis_score','score_sabedoria'])::integer END;
  IF v_score IS NULL OR v_score < 1 THEN RAISE EXCEPTION 'Atributo-chave ausente ou inválido'; END IF;
  v_known := p_estado->'conhecidas'; v_prepared := p_estado->'preparadas'; v_usos := p_estado->'usos';
  IF EXISTS (SELECT 1 FROM jsonb_array_elements(v_known) AS x(value) WHERE jsonb_typeof(x.value) <> 'string')
     OR EXISTS (SELECT 1 FROM jsonb_array_elements(v_prepared) AS x(value) WHERE jsonb_typeof(x.value) <> 'object') THEN
    RAISE EXCEPTION 'Conhecidas deve conter IDs string e preparadas deve conter objetos';
  END IF;
  IF (SELECT count(*) FROM jsonb_array_elements_text(v_known)) <>
     (SELECT count(DISTINCT x) FROM jsonb_array_elements_text(v_known) AS t(x)) THEN
    RAISE EXCEPTION 'IDs duplicados em conhecidas';
  END IF;
  FOR v_spell_id IN SELECT x FROM jsonb_array_elements_text(v_known) AS t(x) LOOP
    SELECT id,circulo,classes INTO v_spell FROM public.srd_spells WHERE id=v_spell_id;
    IF NOT FOUND OR v_spell.circulo NOT BETWEEN 0 AND 9
       OR NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN
      RAISE EXCEPTION 'Magia conhecida inexistente, nível inválido ou incompatível: %',v_spell_id;
    END IF;
    IF coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_spell.circulo)::integer
                   FROM public.srd_spell_progressions WHERE class_key=v_class),0)=0 THEN
      RAISE EXCEPTION 'Círculo não acessível neste nível: %',v_spell_id;
    END IF;
    IF v_score < 10+v_spell.circulo THEN RAISE EXCEPTION 'Atributo insuficiente para conhecer a magia: %',v_spell_id; END IF;
    v_known_out := v_known_out || to_jsonb(v_spell_id);
  END LOOP;
  IF v_class='sorcerer' THEN
    SELECT known_by_level -> (v_level-1) INTO v_known_limits
      FROM public.srd_spell_progressions WHERE class_key='sorcerer';
    FOR v_circle IN 0..9 LOOP
      SELECT count(*) INTO v_count_known
        FROM jsonb_array_elements_text(v_known) AS k(spell_id)
        JOIN public.srd_spells sp ON sp.id=k.spell_id WHERE sp.circulo=v_circle;
      v_capacity := coalesce((v_known_limits ->> v_circle)::integer,0);
      IF v_count_known > v_capacity THEN RAISE EXCEPTION 'Magias conhecidas excedem o limite do círculo %',v_circle; END IF;
    END LOOP;
  ELSIF v_usos <> '{}'::jsonb THEN
    RAISE EXCEPTION 'O mapa usos só é aceito para feiticeiro';
  END IF;
  IF v_class='sorcerer' AND (jsonb_object_length(v_usos)>0 OR jsonb_object_length(coalesce(v_old->'usos','{}'::jsonb))>0) THEN
    FOR v_key,v_count_value IN
      SELECT k, greatest(coalesce((v_usos->>k)::integer,0),coalesce((v_old->'usos'->>k)::integer,0))
        FROM (SELECT key AS k FROM jsonb_each(v_usos)
              UNION SELECT key AS k FROM jsonb_each(coalesce(v_old->'usos','{}'::jsonb))) AS all_keys
    LOOP
      IF v_key !~ '^(0|[1-9])$' OR v_count_value<0 THEN RAISE EXCEPTION 'Usos deve mapear círculos 0..9 a inteiros não negativos'; END IF;
      v_circle := v_key::integer;
      IF coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_circle)::integer
                     FROM public.srd_spell_progressions WHERE class_key='sorcerer'),0)=0
         OR v_count_value > public._srd35_slots(v_class,v_level,v_score,v_circle) THEN
        RAISE EXCEPTION 'Usos excedem os espaços diários no círculo %',v_circle;
      END IF;
      v_usos_out := jsonb_set(v_usos_out,ARRAY[v_key],to_jsonb(v_count_value),true);
    END LOOP;
  END IF;
  FOR v_entry IN SELECT value FROM jsonb_array_elements(v_prepared) LOOP
    v_spell_id := v_entry->>'spell_id';
    IF v_spell_id IS NULL OR jsonb_typeof(v_entry->'slot_level') <> 'number'
       OR jsonb_typeof(v_entry->'expended') <> 'boolean' THEN
      RAISE EXCEPTION 'Cada preparado requer spell_id, slot_level inteiro e expended boolean';
    END IF;
    IF (v_entry->>'slot_level') !~ '^(0|[1-9])$' THEN RAISE EXCEPTION 'slot_level deve estar entre 0 e 9'; END IF;
    v_slot := (v_entry->>'slot_level')::integer;
    SELECT id,circulo,classes INTO v_spell FROM public.srd_spells WHERE id=v_spell_id;
    IF NOT FOUND OR v_spell.circulo NOT BETWEEN 0 AND 9 OR v_slot < v_spell.circulo
       OR NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN
      RAISE EXCEPTION 'Magia preparada inexistente, nível/slot inválido ou incompatível: %',v_spell_id;
    END IF;
    IF v_class='sorcerer' THEN RAISE EXCEPTION 'Feiticeiro usa conhecidas/usos, não prepara magias'; END IF;
    IF v_class='wizard' AND NOT (v_known ? v_spell_id) THEN
      RAISE EXCEPTION 'Mago só pode preparar magias conhecidas/no grimório: %',v_spell_id;
    END IF;
    IF coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_spell.circulo)::integer
                   FROM public.srd_spell_progressions WHERE class_key=v_class),0)=0 THEN
      RAISE EXCEPTION 'Círculo da magia não acessível neste nível: %',v_spell_id;
    END IF;
    IF v_score < 10+v_spell.circulo THEN RAISE EXCEPTION 'Atributo insuficiente para preparar a magia: %',v_spell_id; END IF;
    v_prepared_out := v_prepared_out || jsonb_build_array(jsonb_build_object(
      'spell_id',v_spell_id,'slot_level',v_slot,'expended',coalesce((v_entry->>'expended')::boolean,false)));
  END LOOP;
  -- Preserve previously expended slots by occurrence of the same spell/slot pair.
  FOR v_count IN 0..jsonb_array_length(v_prepared_out)-1 LOOP
    v_entry := v_prepared_out -> v_count;
    v_spell_id := v_entry->>'spell_id'; v_slot := (v_entry->>'slot_level')::integer;
    v_slot_key := v_spell_id || ':' || v_slot::text;
    SELECT count(*) INTO v_new_ordinal FROM jsonb_array_elements(v_prepared_out) WITH ORDINALITY q(value,ord)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot AND ord<=v_count+1;
    SELECT count(*) INTO v_old_expended FROM jsonb_array_elements(coalesce(v_old->'preparadas','[]'::jsonb)) q(value)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot
        AND coalesce((value->>'expended')::boolean,false);
    IF v_new_ordinal<=v_old_expended THEN
      v_prepared_out := jsonb_set(v_prepared_out,ARRAY[v_count::text,'expended'],'true'::jsonb,true);
    END IF;
  END LOOP;
  -- Preserve previously expended slots even if the client submits a different spell list.
  FOR v_entry IN SELECT value FROM jsonb_array_elements(coalesce(v_old->'preparadas','[]'::jsonb)) q(value)
    WHERE coalesce((value->>'expended')::boolean,false)
  LOOP
    v_spell_id:=v_entry->>'spell_id'; v_slot:=(v_entry->>'slot_level')::integer;
    SELECT count(*) INTO v_old_expended FROM jsonb_array_elements(coalesce(v_old->'preparadas','[]'::jsonb)) q(value)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot
        AND coalesce((value->>'expended')::boolean,false);
    SELECT count(*) INTO v_new_ordinal FROM jsonb_array_elements(v_prepared_out) q(value)
      WHERE value->>'spell_id'=v_spell_id AND (value->>'slot_level')::integer=v_slot
        AND coalesce((value->>'expended')::boolean,false);
    IF v_new_ordinal<v_old_expended THEN
      v_prepared_out:=v_prepared_out||jsonb_build_array(jsonb_set(v_entry,'{expended}','true'::jsonb,true));
    END IF;
  END LOOP;
  FOR v_circle IN 0..9 LOOP
    SELECT count(*) INTO v_count FROM jsonb_array_elements(v_prepared_out) e
      WHERE (e->>'slot_level')::integer=v_circle;
    v_capacity := public._srd35_slots(v_class,v_level,v_score,v_circle);
    IF v_count>v_capacity THEN RAISE EXCEPTION 'Preparadas excedem espaços diários do círculo % (% > %)',v_circle,v_count,v_capacity; END IF;
  END LOOP;
  UPDATE public.srd_character_sheets
     SET magias_preparadas=jsonb_build_object('version',1,'conhecidas',v_known_out,'preparadas',v_prepared_out,'usos',v_usos_out)
   WHERE character_id::text=p_character_id;
  RETURN jsonb_build_object('version',1,'conhecidas',v_known_out,'preparadas',v_prepared_out,'usos',v_usos_out);
END
$fn$;

CREATE OR REPLACE FUNCTION public.repor_magias_srd(p_character_id text)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
DECLARE v_sheet public.srd_character_sheets%ROWTYPE; v_doc jsonb; v_class text; v_state jsonb;
BEGIN
  IF auth.uid() IS NULL OR NOT EXISTS (SELECT 1 FROM public.characters c
       WHERE c.id::text=p_character_id AND c.user_id=auth.uid()) THEN
    RAISE EXCEPTION 'Personagem não encontrado ou sem autorização';
  END IF;
  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s
    WHERE s.character_id::text=p_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;
  v_doc:=to_jsonb(v_sheet);
  SELECT public._srd35_class_key(cl.nome) INTO v_class FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe não resolvida na ficha'; END IF;
  v_state:=coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  IF jsonb_typeof(v_state->'preparadas')<>'array' THEN RAISE EXCEPTION 'Estado de magias inválido'; END IF;
  SELECT jsonb_build_object('version',1,'conhecidas',coalesce(v_state->'conhecidas','[]'::jsonb),
      'preparadas',coalesce(jsonb_agg(jsonb_set(e.value,'{expended}','false'::jsonb,true) ORDER BY e.ord),'[]'::jsonb),
      'usos',CASE WHEN v_class='sorcerer' THEN '{}'::jsonb ELSE coalesce(v_state->'usos','{}'::jsonb) END)
    INTO v_state FROM jsonb_array_elements(v_state->'preparadas') WITH ORDINALITY e(value,ord);
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state,magias_descanso_em=clock_timestamp()
    WHERE character_id::text=p_character_id;
  RETURN v_state || jsonb_build_object('descanso_em',clock_timestamp());
END
$fn$;

CREATE OR REPLACE FUNCTION public.conjurar_magia_srd(
  p_character_id text,p_spell_id text,p_slot_level smallint,p_target_token_key text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER
SET search_path = pg_catalog, public
AS $fn$
DECLARE
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_doc jsonb; v_class text; v_level integer; v_score integer;
  v_state jsonb; v_known jsonb; v_prepared jsonb; v_usos jsonb; v_spell record;
  v_circle integer; v_use_count integer; v_capacity integer; v_idx integer; v_new_prepared jsonb;
  v_campaign_id public.characters.campaign_id%TYPE; v_caster_name text;
  v_cba_data jsonb; v_tokens jsonb; v_token jsonb; v_token_index bigint; v_token_count integer;
  v_target_type text; v_target_name text; v_target_key text; v_target_character_id text;
  v_target_hp integer; v_target_max_hp integer; v_healing integer := 0;
  v_roll integer := 0; v_die_count integer; v_die_size integer; v_dice text;
  v_per_level integer := 0; v_max_level integer := 0; v_level_bonus integer;
  v_slot_total integer; v_slots_remaining integer;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória'; END IF;
  SELECT c.campaign_id,c.nome INTO v_campaign_id,v_caster_name
    FROM public.characters c
   WHERE c.id::text=p_character_id AND c.user_id=auth.uid()
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou sem autorização'; END IF;
  IF v_campaign_id IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM public.members m WHERE m.campaign_id=v_campaign_id AND m.user_id=auth.uid()
    UNION ALL SELECT 1 FROM public.campaigns c WHERE c.id=v_campaign_id AND c.owner_id=auth.uid()
  ) THEN RAISE EXCEPTION 'O personagem não pertence a uma campanha da qual você participa'; END IF;

  SELECT s.* INTO v_sheet FROM public.srd_character_sheets s
    WHERE s.character_id::text=p_character_id FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD não encontrada'; END IF;
  v_doc:=to_jsonb(v_sheet);
  SELECT public._srd35_class_key(cl.nome) INTO v_class
    FROM public.srd_classes cl WHERE cl.id=v_sheet.classe_id;
  IF v_class IS NULL THEN RAISE EXCEPTION 'Classe SRD da ficha não encontrada ou incompatível'; END IF;
  v_level:=v_sheet.nivel;
  IF v_level IS NULL OR v_level NOT BETWEEN 1 AND 20 THEN RAISE EXCEPTION 'Nível de classe ausente ou inválido'; END IF;
  v_score:=CASE v_class
    WHEN 'wizard' THEN public._srd35_attr(v_doc,ARRAY['INT','inteligencia','intelligence','int_score','score_inteligencia'])::integer
    WHEN 'sorcerer' THEN public._srd35_attr(v_doc,ARRAY['CAR','carisma','charisma','cha','cha_score','score_carisma'])::integer
    ELSE public._srd35_attr(v_doc,ARRAY['SAB','sabedoria','wisdom','wis','wis_score','score_sabedoria'])::integer END;
  IF v_score IS NULL OR v_score < 1 THEN RAISE EXCEPTION 'Atributo-chave ausente ou inválido'; END IF;
  IF p_slot_level IS NULL OR p_slot_level NOT BETWEEN 0 AND 9 THEN RAISE EXCEPTION 'slot_level deve estar entre 0 e 9'; END IF;
  SELECT id,circulo,classes,dados_tecnicos INTO v_spell FROM public.srd_spells WHERE id=p_spell_id;
  IF NOT FOUND OR v_spell.circulo NOT BETWEEN 0 AND 9
     OR NOT public._srd35_spell_class_ok(v_spell.classes,v_class) THEN
    RAISE EXCEPTION 'Magia inexistente ou incompatível com a classe';
  END IF;
  v_circle:=v_spell.circulo;
  IF coalesce((SELECT (slots_by_level -> (v_level-1) ->> v_circle)::integer
                 FROM public.srd_spell_progressions WHERE class_key=v_class),0)=0
     OR v_score < 10+v_circle THEN RAISE EXCEPTION 'Nível de magia ou atributo insuficiente'; END IF;
  IF v_class='sorcerer' AND p_slot_level<>v_circle THEN RAISE EXCEPTION 'Feiticeiro conjura a magia no próprio círculo'; END IF;
  IF v_class<>'sorcerer' AND p_slot_level<v_circle THEN RAISE EXCEPTION 'Espaço menor que o círculo da magia'; END IF;

  v_state:=coalesce(v_sheet.magias_preparadas,'{"version":1,"conhecidas":[],"preparadas":[],"usos":{}}'::jsonb);
  v_known:=coalesce(v_state->'conhecidas','[]'::jsonb);
  v_prepared:=coalesce(v_state->'preparadas','[]'::jsonb);
  v_usos:=coalesce(v_state->'usos','{}'::jsonb);
  IF v_class='sorcerer' THEN
    IF NOT (v_known ? p_spell_id) THEN RAISE EXCEPTION 'Feiticeiro só pode conjurar magias conhecidas'; END IF;
    v_capacity:=public._srd35_slots(v_class,v_level,v_score,v_circle);
    v_use_count:=coalesce((v_usos->>v_circle::text)::integer,0);
    IF v_use_count>=v_capacity THEN RAISE EXCEPTION 'Sem usos diários restantes para este círculo'; END IF;
    v_usos:=jsonb_set(v_usos,ARRAY[v_circle::text],to_jsonb(v_use_count+1),true);
    v_slot_total:=v_capacity; v_slots_remaining:=v_capacity-v_use_count-1;
  ELSE
    SELECT (ord-1)::integer INTO v_idx FROM jsonb_array_elements(v_prepared) WITH ORDINALITY e(value,ord)
      WHERE value->>'spell_id'=p_spell_id AND (value->>'slot_level')::integer=p_slot_level
        AND coalesce((value->>'expended')::boolean,false)=false ORDER BY ord LIMIT 1;
    IF v_idx IS NULL THEN RAISE EXCEPTION 'Nenhum espaço preparado disponível para essa magia e círculo'; END IF;
    v_prepared:=jsonb_set(v_prepared,ARRAY[v_idx::text,'expended'],'true'::jsonb,true);
    v_slot_total:=public._srd35_slots(v_class,v_level,v_score,p_slot_level);
    SELECT count(*)::integer INTO v_slots_remaining FROM jsonb_array_elements(v_prepared) e(value)
      WHERE (value->>'slot_level')::integer=p_slot_level AND coalesce((value->>'expended')::boolean,false)=false;
  END IF;

  v_target_key:=NULLIF(btrim(p_target_token_key),'');
  IF v_target_key IS NOT NULL AND v_campaign_id IS NULL THEN
    RAISE EXCEPTION 'Um alvo por token exige que o conjurador esteja em uma campanha';
  END IF;
  IF v_target_key IS NOT NULL THEN
    IF coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')='cura' THEN
      SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
    ELSE
      SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id;
    END IF;
    IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do conjurador não encontrada'; END IF;
    v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
    SELECT count(*)::integer,min(e.ordinality),min(e.token->>'nome')
      INTO v_token_count,v_token_index,v_target_name
      FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
      WHERE e.token->>'key'=v_target_key;
    IF v_token_count<>1 THEN RAISE EXCEPTION 'Token-alvo não encontrado ou duplicado nesta campanha'; END IF;
    v_token:=v_tokens->(v_token_index::integer-1);
    v_target_type:=v_token->>'tipo';
    IF v_target_type IS NULL OR v_target_type NOT IN ('player','npc','monstro') THEN RAISE EXCEPTION 'Tipo do token-alvo inválido'; END IF;
  ELSIF coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')='cura' THEN
    v_target_type:='player'; v_target_name:=v_caster_name; v_target_character_id:=p_character_id;
    IF v_campaign_id IS NOT NULL THEN
      SELECT c.cba_data INTO v_cba_data FROM public.campaigns c WHERE c.id=v_campaign_id FOR UPDATE;
      IF NOT FOUND THEN RAISE EXCEPTION 'Campanha do conjurador não encontrada'; END IF;
      v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
    END IF;
  END IF;

  IF coalesce(v_spell.dados_tecnicos->>'tipo_efeito','')='cura' THEN
    v_target_character_id:=CASE WHEN v_target_key IS NULL THEN p_character_id ELSE NULL END;
    IF v_target_key IS NOT NULL AND v_target_type='player' THEN
      v_target_character_id:=v_token->>'id';
      IF NOT EXISTS (
        SELECT 1 FROM public.characters ch
        JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER'
        WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
      ) THEN RAISE EXCEPTION 'O token player não corresponde a um personagem jogador desta campanha'; END IF;
    END IF;
    v_dice:=coalesce(v_spell.dados_tecnicos->'cura'->>'dados','');
    IF v_dice ~ '^[0-9]+d[0-9]+([+-][0-9]+)?$' THEN
      v_die_count:=split_part(v_dice,'d',1)::integer;
      v_die_size:=regexp_replace(split_part(v_dice,'d',2),'[+-].*$','')::integer;
      IF v_die_count<1 OR v_die_count>100 OR v_die_size<2 OR v_die_size>100000 THEN RAISE EXCEPTION 'Dados de cura inválidos'; END IF;
      FOR v_idx IN 1..v_die_count LOOP v_roll:=v_roll+floor(random()*v_die_size)::integer+1; END LOOP;
      IF substring(v_dice from '([+-][0-9]+)$') IS NOT NULL THEN
        v_roll:=v_roll+substring(v_dice from '([+-][0-9]+)$')::integer;
      END IF;
    ELSIF v_dice ~ '^[0-9]+$' THEN
      v_roll:=v_dice::integer;
    ELSE
      RAISE EXCEPTION 'Expressão de cura inválida na magia';
    END IF;
    IF coalesce(v_spell.dados_tecnicos->'cura'->>'por_nivel','0') !~ '^-?[0-9]+$'
       OR coalesce(v_spell.dados_tecnicos->'cura'->>'max_nivel','0') !~ '^-?[0-9]+$' THEN
      RAISE EXCEPTION 'Parâmetros por_nivel/max_nivel inválidos na cura';
    END IF;
    v_per_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'por_nivel')::integer,0);
    v_max_level:=coalesce((v_spell.dados_tecnicos->'cura'->>'max_nivel')::integer,0);
    IF v_per_level<0 OR v_max_level<0 THEN RAISE EXCEPTION 'Parâmetros de cura não podem ser negativos'; END IF;
    v_level_bonus:=CASE WHEN v_max_level>0 THEN least(v_level,v_max_level) ELSE v_level END;
    v_healing:=greatest(0,v_roll+v_per_level*v_level_bonus);

    IF v_target_type='player' THEN
      IF v_target_key IS NULL THEN
        v_target_hp:=v_sheet.pv_atual; v_target_max_hp:=v_sheet.pv_max;
        IF v_target_max_hp IS NULL OR v_target_max_hp<0 THEN RAISE EXCEPTION 'PV máximo válido ausente na ficha do conjurador'; END IF;
        v_target_hp:=least(v_target_max_hp,greatest(0,coalesce(v_target_hp,0)+v_healing));
        UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=p_character_id;
      ELSE
        SELECT sh.pv_atual,sh.pv_max,ch.id::text,coalesce(ch.nome,'Aventureiro')
          INTO v_target_hp,v_target_max_hp,v_target_character_id,v_target_name
          FROM public.characters ch JOIN public.srd_character_sheets sh ON sh.character_id::text=ch.id::text
         WHERE ch.id::text=v_target_character_id AND ch.campaign_id=v_campaign_id
         FOR UPDATE OF ch,sh;
        IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD do alvo player não encontrada nesta campanha'; END IF;
        IF v_target_max_hp IS NULL OR v_target_max_hp<0 THEN RAISE EXCEPTION 'PV máximo válido ausente na ficha do alvo'; END IF;
        v_target_hp:=least(v_target_max_hp,greatest(0,coalesce(v_target_hp,0)+v_healing));
        UPDATE public.srd_character_sheets SET pv_atual=v_target_hp WHERE character_id::text=v_target_character_id;
      END IF;
      IF v_campaign_id IS NOT NULL THEN
        IF v_tokens IS NULL THEN
          v_tokens:=CASE WHEN jsonb_typeof(v_cba_data->'tokens')='array' THEN v_cba_data->'tokens' ELSE '[]'::jsonb END;
        END IF;
        SELECT count(*)::integer,min(e.ordinality) INTO v_token_count,v_token_index
          FROM jsonb_array_elements(v_tokens) WITH ORDINALITY e(token,ordinality)
         WHERE e.token->>'id'=v_target_character_id AND e.token->>'tipo'='player';
        IF v_target_key IS NOT NULL AND v_token_count<>1 THEN RAISE EXCEPTION 'Token player do alvo ausente ou duplicado na cena'; END IF;
        IF v_token_count>1 THEN RAISE EXCEPTION 'Há tokens player duplicados para o personagem-alvo'; END IF;
        IF v_token_count=1 THEN
          v_token:=v_tokens->(v_token_index::integer-1);
          v_token:=v_token||jsonb_build_object('hp',v_target_hp,'maxHp',v_target_max_hp);
          v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
          v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
          UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;
        END IF;
      END IF;
    ELSE
      IF coalesce(v_token->>'maxHp','') !~ '^[1-9][0-9]{0,5}$' THEN
        RAISE EXCEPTION 'O token NPC/monstro precisa de maxHp válido para receber cura';
      END IF;
      v_target_max_hp:=(v_token->>'maxHp')::integer;
      IF v_target_max_hp>100000 THEN RAISE EXCEPTION 'maxHp do token excede o limite aceito'; END IF;
      v_target_hp:=CASE WHEN coalesce(v_token->>'hp','') ~ '^[0-9]{1,6}$' THEN (v_token->>'hp')::integer ELSE v_target_max_hp END;
      v_target_hp:=least(v_target_max_hp,greatest(0,v_target_hp+v_healing));
      v_token:=v_token||jsonb_build_object('hp',v_target_hp,'maxHp',v_target_max_hp);
      v_tokens:=jsonb_set(v_tokens,ARRAY[(v_token_index-1)::text],v_token,false);
      v_cba_data:=coalesce(v_cba_data,'{}'::jsonb)||jsonb_build_object('tokens',v_tokens);
      UPDATE public.campaigns SET cba_data=v_cba_data WHERE id=v_campaign_id;
    END IF;
  END IF;

  v_state:=jsonb_build_object('version',1,'conhecidas',v_known,'preparadas',v_prepared,'usos',v_usos);
  UPDATE public.srd_character_sheets SET magias_preparadas=v_state WHERE character_id::text=p_character_id;
  RETURN jsonb_build_object(
    'estado',v_state,'healing',v_healing,'pv_atual',v_target_hp,'cba_data',v_cba_data,
    'target_name',v_target_name,'target_token_key',v_target_key,
    'slot_level',p_slot_level,'slots_remaining',v_slots_remaining,'slots_total',v_slot_total
  );
END
$fn$;

-- Internal helpers are not callable by API roles. The three public RPCs are the only
-- spell-state write interface and are SECURITY DEFINER with a fixed search_path.
REVOKE ALL ON FUNCTION public._srd35_class_key(text) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public._srd35_attr(jsonb,text[]) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public._srd35_spell_class_ok(text[],text) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public._srd35_slots(text,integer,integer,integer) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.salvar_grimorio_srd(text,jsonb) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.repor_magias_srd(text) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.conjurar_magia_srd(text,text,smallint,text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.salvar_grimorio_srd(text,jsonb) TO authenticated;
GRANT EXECUTE ON FUNCTION public.repor_magias_srd(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.conjurar_magia_srd(text,text,smallint,text) TO authenticated;
REVOKE ALL ON TABLE public.srd_spell_progressions FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.srd_spell_progressions TO anon, authenticated;
GRANT SELECT ON public.srd_spell_progressions TO PUBLIC;

COMMIT;
