-- Bloqueia perícias proibidas pela Fúria e preserva as exceções SRD.
CREATE OR REPLACE FUNCTION public.srd_validar_uso_pericia_srd(
  p_character_id text,
  p_skill_id text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog','public','pg_temp'
AS $function$
DECLARE
  v_character public.characters%ROWTYPE;
  v_skill public.srd_skills%ROWTYPE;
  v_rage_active boolean:=false;
  v_blocked boolean:=false;
  v_reason text;
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
        'skill_name',v_skill.nome,'ability',v_skill.atributo,'reason',v_reason
      );
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'allowed',true,'rage_active',v_rage_active,'skill_id',v_skill.id,
    'skill_name',v_skill.nome,'ability',v_skill.atributo
  );
END;
$function$;

REVOKE ALL ON FUNCTION public.srd_validar_uso_pericia_srd(text,text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.srd_validar_uso_pericia_srd(text,text) TO authenticated;
