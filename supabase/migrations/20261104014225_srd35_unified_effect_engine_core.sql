
CREATE INDEX IF NOT EXISTS srd_campaign_effects_active_target_idx
  ON public.srd_campaign_effects (campaign_id, target_kind, target_id, expires_round)
  WHERE active = true;

CREATE INDEX IF NOT EXISTS srd_campaign_conditions_active_target_idx
  ON public.srd_campaign_conditions (campaign_id, target_kind, target_id, expires_round)
  WHERE active = true;

CREATE OR REPLACE FUNCTION priv.srd_apply_campaign_effect(
  p_campaign_id bigint,
  p_target_kind text,
  p_target_id text,
  p_effect_kind text,
  p_effect_data jsonb,
  p_duration_rounds integer DEFAULT NULL,
  p_source_spell_id text DEFAULT NULL,
  p_concentration_actor_id text DEFAULT NULL
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, pg_temp
AS $function$
DECLARE
  v_round integer;
  v_cba jsonb;
  v_modifier jsonb;
  v_stat text;
  v_value integer;
  v_bonus_type text;
  v_stack_key text;
  v_instance bigint;
BEGIN
  IF p_campaign_id IS NULL OR p_campaign_id < 1 THEN
    RAISE EXCEPTION 'Campanha inválida.';
  END IF;
  IF p_target_kind NOT IN ('character','token','area') THEN
    RAISE EXCEPTION 'Tipo de alvo inválido.';
  END IF;
  IF NULLIF(BTRIM(p_target_id),'') IS NULL OR length(p_target_id)>160 THEN
    RAISE EXCEPTION 'Identificador do alvo inválido.';
  END IF;
  IF p_effect_kind NOT IN ('attack','buff','condition','damage','debuff','drain','healing','movement','saving_throw','special','summon','utility') THEN
    RAISE EXCEPTION 'Tipo de efeito não suportado.';
  END IF;
  IF p_effect_data IS NULL OR jsonb_typeof(p_effect_data)<>'object'
     OR octet_length(p_effect_data::text)>12000 THEN
    RAISE EXCEPTION 'Dados do efeito inválidos ou acima do limite.';
  END IF;
  IF p_duration_rounds IS NOT NULL AND p_duration_rounds NOT BETWEEN 1 AND 10000 THEN
    RAISE EXCEPTION 'Duração em rodadas inválida.';
  END IF;

  SELECT COALESCE(NULLIF(c.combat_data->>'round','')::integer,1),
         COALESCE(c.cba_data,'{}'::jsonb)
    INTO v_round,v_cba
    FROM public.campaigns c
   WHERE c.id=p_campaign_id
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;
  IF v_round<1 THEN RAISE EXCEPTION 'Rodada atual inválida.'; END IF;

  IF p_target_kind='character' AND NOT EXISTS (
    SELECT 1 FROM public.characters ch
    WHERE ch.id::text=p_target_id AND ch.campaign_id=p_campaign_id
  ) THEN
    RAISE EXCEPTION 'Personagem-alvo não pertence à campanha.';
  ELSIF p_target_kind='token' AND NOT (
    EXISTS (
      SELECT 1
      FROM jsonb_array_elements(
        CASE WHEN jsonb_typeof(v_cba->'tokens')='array' THEN v_cba->'tokens' ELSE '[]'::jsonb END
      ) t
      WHERE t->>'key'=p_target_id OR t->>'id'=p_target_id
    )
    OR EXISTS (
      SELECT 1 FROM public.tokens t
      WHERE t.campaign_id=p_campaign_id AND t.id::text=p_target_id
    )
  ) THEN
    RAISE EXCEPTION 'Token-alvo não pertence à campanha.';
  END IF;

  IF p_effect_data ? 'modifiers' THEN
    IF jsonb_typeof(p_effect_data->'modifiers')<>'array' THEN
      RAISE EXCEPTION 'modifiers deve ser uma lista.';
    END IF;
    FOR v_modifier IN SELECT value FROM jsonb_array_elements(p_effect_data->'modifiers')
    LOOP
      IF jsonb_typeof(v_modifier)<>'object' THEN
        RAISE EXCEPTION 'Cada modificador deve ser um objeto.';
      END IF;
      v_stat:=v_modifier->>'stat';
      IF v_stat IS NULL OR v_stat !~ '^[a-z][a-z0-9_:.]{0,47}$' THEN
        RAISE EXCEPTION 'Atributo de modificador inválido.';
      END IF;
      IF COALESCE(v_modifier->>'value','') !~ '^-?[0-9]{1,3}$' THEN
        RAISE EXCEPTION 'Valor de modificador inválido.';
      END IF;
      v_value:=(v_modifier->>'value')::integer;
      IF v_value NOT BETWEEN -100 AND 100 OR v_value=0 THEN
        RAISE EXCEPTION 'Modificador deve estar entre -100 e 100 e não pode ser zero.';
      END IF;
      v_bonus_type:=COALESCE(NULLIF(v_modifier->>'bonus_type',''),'untyped');
      IF v_bonus_type NOT IN (
        'alchemical','armor','circumstance','competence','deflection','dodge',
        'enhancement','inherent','insight','luck','morale','natural_armor',
        'profane','racial','resistance','sacred','shield','size','untyped'
      ) THEN
        RAISE EXCEPTION 'Tipo de bônus D&D 3.5 inválido.';
      END IF;
    END LOOP;
  END IF;

  v_stack_key:=NULLIF(BTRIM(p_effect_data->>'stacking_key'),'');
  IF v_stack_key IS NOT NULL AND p_effect_data->>'stacking_policy'='replace' THEN
    UPDATE public.srd_campaign_effects
       SET active=false
     WHERE campaign_id=p_campaign_id
       AND target_kind=p_target_kind
       AND target_id=p_target_id
       AND active=true
       AND effect_data->>'stacking_key'=v_stack_key;
  END IF;

  INSERT INTO public.srd_campaign_effects(
    campaign_id,target_kind,target_id,source_spell_id,effect_kind,
    started_round,expires_round,concentration_actor_id,active,effect_data
  ) VALUES (
    p_campaign_id,p_target_kind,p_target_id,p_source_spell_id,p_effect_kind,
    v_round,
    CASE WHEN p_duration_rounds IS NULL THEN NULL ELSE v_round+p_duration_rounds END,
    p_concentration_actor_id,true,p_effect_data
  )
  RETURNING effect_instance_id INTO v_instance;

  RETURN v_instance;
END;
$function$;

CREATE OR REPLACE FUNCTION priv.srd_apply_campaign_condition(
  p_campaign_id bigint,
  p_target_kind text,
  p_target_id text,
  p_condition_id text,
  p_duration_rounds integer DEFAULT NULL,
  p_notes jsonb DEFAULT '{}'::jsonb,
  p_source_spell_id text DEFAULT NULL
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, pg_temp
AS $function$
DECLARE
  v_round integer;
  v_cba jsonb;
  v_instance bigint;
BEGIN
  IF p_campaign_id IS NULL OR p_campaign_id<1 THEN RAISE EXCEPTION 'Campanha inválida.'; END IF;
  IF p_target_kind NOT IN ('character','token') THEN RAISE EXCEPTION 'Tipo de alvo inválido.'; END IF;
  IF NULLIF(BTRIM(p_target_id),'') IS NULL OR length(p_target_id)>160 THEN RAISE EXCEPTION 'Alvo inválido.'; END IF;
  IF p_duration_rounds IS NOT NULL AND p_duration_rounds NOT BETWEEN 1 AND 10000 THEN
    RAISE EXCEPTION 'A duração deve estar entre 1 e 10000 rodadas.';
  END IF;
  IF p_notes IS NULL OR jsonb_typeof(p_notes)<>'object' OR octet_length(p_notes::text)>12000 THEN
    RAISE EXCEPTION 'Metadados da condição inválidos.';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM public.srd_conditions WHERE condition_id=p_condition_id
  ) THEN RAISE EXCEPTION 'Condição D&D 3.5 inexistente.'; END IF;

  SELECT COALESCE(NULLIF(c.combat_data->>'round','')::integer,1),
         COALESCE(c.cba_data,'{}'::jsonb)
    INTO v_round,v_cba
    FROM public.campaigns c
   WHERE c.id=p_campaign_id
   FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;

  IF p_target_kind='character' AND NOT EXISTS (
    SELECT 1 FROM public.characters ch
    WHERE ch.id::text=p_target_id AND ch.campaign_id=p_campaign_id
  ) THEN
    RAISE EXCEPTION 'Personagem não pertence a esta campanha.';
  ELSIF p_target_kind='token' AND NOT (
    EXISTS (
      SELECT 1
      FROM jsonb_array_elements(
        CASE WHEN jsonb_typeof(v_cba->'tokens')='array' THEN v_cba->'tokens' ELSE '[]'::jsonb END
      ) t
      WHERE t->>'id'=p_target_id OR t->>'key'=p_target_id
    )
    OR EXISTS (
      SELECT 1 FROM public.tokens t
      WHERE t.campaign_id=p_campaign_id AND t.id::text=p_target_id
    )
  ) THEN
    RAISE EXCEPTION 'Token não pertence ao tabuleiro desta campanha.';
  END IF;

  UPDATE public.srd_campaign_conditions
     SET active=false
   WHERE campaign_id=p_campaign_id AND target_kind=p_target_kind
     AND target_id=p_target_id AND condition_id=p_condition_id AND active=true;

  INSERT INTO public.srd_campaign_conditions(
    campaign_id,target_kind,target_id,condition_id,source_spell_id,
    started_round,expires_round,active,notes
  ) VALUES (
    p_campaign_id,p_target_kind,p_target_id,p_condition_id,p_source_spell_id,
    v_round,
    CASE WHEN p_duration_rounds IS NULL THEN NULL ELSE v_round+p_duration_rounds END,
    true,p_notes
  )
  RETURNING condition_instance_id INTO v_instance;

  RETURN v_instance;
END;
$function$;

CREATE OR REPLACE FUNCTION public.srd_apply_campaign_effect(
  p_campaign_id bigint,
  p_target_kind text,
  p_target_id text,
  p_effect_kind text,
  p_effect_data jsonb,
  p_duration_rounds integer DEFAULT NULL,
  p_source_spell_id text DEFAULT NULL,
  p_concentration_actor_id text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $function$
DECLARE v_id bigint; v_expiry integer;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode administrar efeitos diretamente.';
  END IF;
  v_id:=priv.srd_apply_campaign_effect(
    p_campaign_id,p_target_kind,p_target_id,p_effect_kind,p_effect_data,
    p_duration_rounds,p_source_spell_id,p_concentration_actor_id
  );
  SELECT expires_round INTO v_expiry
    FROM public.srd_campaign_effects WHERE effect_instance_id=v_id;
  RETURN jsonb_build_object('effect_instance_id',v_id,'expires_round',v_expiry,'active',true);
END;
$function$;

CREATE OR REPLACE FUNCTION public.srd_remove_campaign_effect(
  p_campaign_id bigint,
  p_effect_instance_id bigint
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $function$
DECLARE v_count integer;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode remover efeitos diretamente.';
  END IF;
  UPDATE public.srd_campaign_effects
     SET active=false
   WHERE campaign_id=p_campaign_id
     AND effect_instance_id=p_effect_instance_id
     AND active=true;
  GET DIAGNOSTICS v_count=ROW_COUNT;
  RETURN v_count=1;
END;
$function$;

CREATE OR REPLACE FUNCTION priv.srd_effective_modifier(
  p_campaign_id bigint,
  p_target_kind text,
  p_target_id text,
  p_stat text
)
RETURNS integer
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, pg_temp
AS $function$
  WITH modifiers AS (
    SELECT
      COALESCE(NULLIF(m.value->>'bonus_type',''),'untyped') AS bonus_type,
      (m.value->>'value')::integer AS value
    FROM public.srd_campaign_effects e
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(e.effect_data->'modifiers')='array'
           THEN e.effect_data->'modifiers' ELSE '[]'::jsonb END
    ) AS m(value)
    WHERE e.campaign_id=p_campaign_id
      AND e.target_kind=p_target_kind
      AND e.target_id=p_target_id
      AND e.active=true
      AND m.value->>'stat'=p_stat
      AND COALESCE(m.value->>'value','') ~ '^-?[0-9]{1,3}$'
  ),
  positive_typed AS (
    SELECT bonus_type,max(value) AS value
    FROM modifiers
    WHERE value>0 AND bonus_type NOT IN ('untyped','dodge','circumstance')
    GROUP BY bonus_type
  )
  SELECT
    COALESCE((SELECT sum(value) FROM positive_typed),0)
    + COALESCE((SELECT sum(value) FROM modifiers WHERE value>0 AND bonus_type IN ('untyped','dodge','circumstance')),0)
    + COALESCE((SELECT sum(value) FROM modifiers WHERE value<0),0);
$function$;

CREATE OR REPLACE FUNCTION public.srd_effective_modifier(
  p_campaign_id bigint,
  p_target_kind text,
  p_target_id text,
  p_stat text
)
RETURNS integer
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $function$
BEGIN
  IF auth.uid() IS NULL OR (
    public.my_role(p_campaign_id) IS NULL AND NOT EXISTS (
      SELECT 1 FROM public.campaigns c WHERE c.id=p_campaign_id AND c.owner_id=auth.uid()
    )
  ) THEN RAISE EXCEPTION 'Sem acesso à campanha.'; END IF;
  IF p_stat IS NULL OR p_stat !~ '^[a-z][a-z0-9_:.]{0,47}$' THEN
    RAISE EXCEPTION 'Atributo inválido.';
  END IF;
  RETURN priv.srd_effective_modifier(p_campaign_id,p_target_kind,p_target_id,p_stat);
END;
$function$;

CREATE OR REPLACE FUNCTION public.srd_apply_campaign_condition(
  p_campaign_id bigint,
  p_target_kind text,
  p_target_id text,
  p_condition_id text,
  p_duration_rounds integer DEFAULT NULL,
  p_notes jsonb DEFAULT '{}'::jsonb
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $function$
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode administrar condições diretamente.';
  END IF;
  RETURN priv.srd_apply_campaign_condition(
    p_campaign_id,p_target_kind,p_target_id,p_condition_id,
    p_duration_rounds,COALESCE(p_notes,'{}'::jsonb),NULL
  );
END;
$function$;

CREATE OR REPLACE FUNCTION public.srd_expire_campaign_conditions(p_campaign_id bigint)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, pg_temp
AS $function$
DECLARE
  v_round integer;
  v_count integer;
  v_effect_count integer;
BEGIN
  IF auth.uid() IS NULL OR (
    public.my_role(p_campaign_id) IS NULL AND NOT EXISTS (
      SELECT 1 FROM public.campaigns c WHERE c.id=p_campaign_id AND c.owner_id=auth.uid()
    )
  ) THEN RAISE EXCEPTION 'Sem acesso à campanha.'; END IF;

  SELECT COALESCE(NULLIF(combat_data->>'round','')::integer,0)
    INTO v_round
    FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR v_round<1 THEN RETURN 0; END IF;

  UPDATE public.srd_campaign_conditions
     SET active=false
   WHERE campaign_id=p_campaign_id AND active=true
     AND expires_round IS NOT NULL AND expires_round<=v_round;
  GET DIAGNOSTICS v_count=ROW_COUNT;

  UPDATE public.srd_campaign_effects
     SET active=false
   WHERE campaign_id=p_campaign_id AND active=true
     AND expires_round IS NOT NULL AND expires_round<=v_round;
  GET DIAGNOSTICS v_effect_count=ROW_COUNT;

  RETURN v_count+v_effect_count;
END;
$function$;

DO $patch_advance_turn$
DECLARE
  v_definition text;
  v_marker text := '  UPDATE public.campaigns SET combat_data = v_next_data WHERE id = p_campaign_id;';
BEGIN
  SELECT pg_get_functiondef('public.avancar_turno(bigint)'::regprocedure)
    INTO v_definition;
  IF position(v_marker IN v_definition)=0 THEN
    RAISE EXCEPTION 'Não foi possível localizar o ponto seguro para expirar efeitos ao avançar turno.';
  END IF;
  IF position('srd_expire_campaign_conditions(p_campaign_id)' IN v_definition)>0 THEN
    RETURN;
  END IF;
  v_definition:=replace(
    v_definition,
    v_marker,
    v_marker || E'\n  IF v_next = 0 THEN\n    PERFORM public.srd_expire_campaign_conditions(p_campaign_id);\n  END IF;'
  );
  EXECUTE v_definition;
END;
$patch_advance_turn$;

REVOKE ALL ON FUNCTION priv.srd_apply_campaign_effect(bigint,text,text,text,jsonb,integer,text,text) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION priv.srd_apply_campaign_condition(bigint,text,text,text,integer,jsonb,text) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION priv.srd_effective_modifier(bigint,text,text,text) FROM PUBLIC, anon, authenticated;

REVOKE ALL ON FUNCTION public.srd_apply_campaign_effect(bigint,text,text,text,jsonb,integer,text,text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_apply_campaign_effect(bigint,text,text,text,jsonb,integer,text,text) TO authenticated;
REVOKE ALL ON FUNCTION public.srd_remove_campaign_effect(bigint,bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_remove_campaign_effect(bigint,bigint) TO authenticated;
REVOKE ALL ON FUNCTION public.srd_effective_modifier(bigint,text,text,text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_effective_modifier(bigint,text,text,text) TO authenticated;
REVOKE ALL ON FUNCTION public.srd_apply_campaign_condition(bigint,text,text,text,integer,jsonb) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_apply_campaign_condition(bigint,text,text,text,integer,jsonb) TO authenticated;
REVOKE ALL ON FUNCTION public.srd_expire_campaign_conditions(bigint) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_expire_campaign_conditions(bigint) TO authenticated;
