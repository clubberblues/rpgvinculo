-- Expõe Trapfinding pelo nível específico de Ladino na validação de perícias.
CREATE OR REPLACE FUNCTION public.srd_validar_uso_pericia_srd(p_character_id text, p_skill_id text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'pg_temp'
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_skill public.srd_skills%ROWTYPE;
  v_rage_active boolean:=false;
  v_blocked boolean:=false;
  v_reason text;
  v_rogue_level integer:=0;
  v_trapfinding boolean:=false;
BEGIN
  IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
  IF NULLIF(BTRIM(p_character_id),'') IS NULL OR NULLIF(BTRIM(p_skill_id),'') IS NULL THEN
    RAISE EXCEPTION 'Personagem e perícia são obrigatórios.';
  END IF;

  SELECT * INTO v_character
    FROM public.characters
   WHERE id::text=BTRIM(p_character_id) AND user_id=auth.uid();
  IF NOT FOUND THEN RAISE EXCEPTION 'Personagem não encontrado ou não pertence ao jogador.'; END IF;

  SELECT * INTO v_skill
    FROM public.srd_skills
   WHERE id=BTRIM(p_skill_id) AND source_status IS DISTINCT FROM 'excluded';
  IF NOT FOUND THEN RAISE EXCEPTION 'Perícia não encontrada ou indisponível no catálogo.'; END IF;

  SELECT COALESCE(
    MAX(cl.class_level) FILTER (WHERE cls.class_key='rogue'),
    CASE WHEN NOT EXISTS (
      SELECT 1 FROM public.srd_character_class_levels any_level
       WHERE any_level.character_id=v_character.id
    ) AND sh.classe_id='ladino'
    THEN GREATEST(1,COALESCE(sh.nivel,1)) ELSE 0 END
  )
    INTO v_rogue_level
    FROM public.srd_character_sheets sh
    LEFT JOIN public.srd_character_class_levels cl ON cl.character_id=sh.character_id
    LEFT JOIN public.srd_classes cls ON cls.id=cl.class_id
   WHERE sh.character_id=v_character.id
   GROUP BY sh.character_id,sh.classe_id,sh.nivel;
  v_trapfinding:=COALESCE(v_rogue_level,0)>=1;

  SELECT EXISTS (
    SELECT 1 FROM public.srd_campaign_effects
     WHERE campaign_id=v_character.campaign_id
       AND target_kind='character'
       AND target_id=v_character.id::text
       AND active=true
       AND effect_data->>'source_feature'='barbarian_rage'
  ) INTO v_rage_active;

  IF v_rage_active THEN
    v_blocked:=
      v_skill.id='concentracao'
      OR (
        upper(COALESCE(v_skill.atributo,'')) IN ('INT','DES','CAR')
        AND v_skill.id NOT IN (
          'srd35_skill_balance', -- Equilíbrio
          'fuga',                -- Arte da Fuga
          'intimidacao',         -- Intimidação
          'cavalgar'             -- Cavalgar
        )
      );
    IF v_blocked THEN
      v_reason:=CASE
        WHEN v_skill.id='concentracao'
          THEN 'Não é possível usar Concentração enquanto estiver em Fúria.'
        ELSE 'Durante a Fúria, não é possível usar perícias de Inteligência, Destreza ou Carisma, exceto Equilíbrio, Arte da Fuga, Intimidação e Cavalgar.'
      END;
      RETURN jsonb_build_object(
        'allowed',false,'rage_active',true,'skill_id',v_skill.id,
        'skill_name',v_skill.nome,'ability',v_skill.atributo,'reason',v_reason,'trapfinding',v_trapfinding,'trapfinding_search_dc_over_20',v_trapfinding,'trapfinding_magic_search_dc','25 + nível da magia','trapfinding_disarm_magic',v_trapfinding
      );
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'allowed',true,'rage_active',v_rage_active,'skill_id',v_skill.id,
    'skill_name',v_skill.nome,'ability',v_skill.atributo,'trapfinding',v_trapfinding,'trapfinding_search_dc_over_20',v_trapfinding,'trapfinding_magic_search_dc','25 + nível da magia','trapfinding_disarm_magic',v_trapfinding
  );
END;
$function$
;
REVOKE ALL ON FUNCTION public.srd_validar_uso_pericia_srd(text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.srd_validar_uso_pericia_srd(text,text) TO authenticated;
