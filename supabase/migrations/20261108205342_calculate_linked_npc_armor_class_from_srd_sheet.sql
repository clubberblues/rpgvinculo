
DO $migration$
DECLARE
  v_def text;
  v_old text;
  v_new text;
BEGIN
  v_def:=pg_get_functiondef('priv.srd_calcular_ca_alvo_campanha_srd(bigint,text,text)'::regprocedure);

  v_old:=$old$
  SELECT * INTO v_character
    FROM public.characters
   WHERE id::text=BTRIM(p_character_id)
     AND campaign_id=p_campaign_id
     AND EXISTS (
       SELECT 1 FROM public.members m
       WHERE m.campaign_id=p_campaign_id
         AND m.user_id=public.characters.user_id
         AND m.role='PLAYER'
     );
$old$;
  v_new:=$new$
  SELECT * INTO v_character
    FROM public.characters ch
   WHERE ch.id::text=BTRIM(p_character_id)
     AND (
       (ch.campaign_id=p_campaign_id AND EXISTS (
         SELECT 1 FROM public.members m
         WHERE m.campaign_id=p_campaign_id
           AND m.user_id=ch.user_id
           AND m.role='PLAYER'
       ))
       OR (
         public.my_role(p_campaign_id)='GM'
         AND EXISTS (
           SELECT 1
           FROM public.members gm
           JOIN public.campaigns camp ON camp.id=gm.campaign_id
           CROSS JOIN LATERAL jsonb_array_elements(
             CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
                  THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
           ) tok
           WHERE gm.campaign_id=p_campaign_id
             AND gm.user_id=ch.user_id
             AND gm.role='GM'
             AND tok->>'tipo'='npc'
             AND tok->>'sourceCharacterId'=ch.id::text
         )
       )
     );
$new$;
  IF position(v_old in v_def)=0 THEN
    RAISE EXCEPTION 'Bloco de autorização do cálculo de CA mudou; migration abortada.';
  END IF;
  v_def:=replace(v_def,v_old,v_new);

  v_old:=$old$
  v_effect_modifier:=priv.srd_effective_modifier(
    p_campaign_id,'character',v_character.id::text,'ac'
  );
$old$;
  v_new:=$new$
  IF EXISTS (
    SELECT 1 FROM public.campaigns camp
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
           THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
    ) tok
    WHERE camp.id=p_campaign_id
      AND tok->>'tipo'='npc'
      AND tok->>'sourceCharacterId'=v_character.id::text
  ) THEN
    SELECT COALESCE(priv.srd_effective_modifier(
      p_campaign_id,'token',tok->>'id','ac'
    ),0)
    INTO v_effect_modifier
    FROM public.campaigns camp
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
           THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
    ) tok
    WHERE camp.id=p_campaign_id
      AND tok->>'tipo'='npc'
      AND tok->>'sourceCharacterId'=v_character.id::text
    LIMIT 1;
  ELSE
    v_effect_modifier:=priv.srd_effective_modifier(
      p_campaign_id,'character',v_character.id::text,'ac'
    );
  END IF;
$new$;
  IF position(v_old in v_def)=0 THEN
    RAISE EXCEPTION 'Bloco de modificador dinâmico de CA mudou; migration abortada.';
  END IF;
  v_def:=replace(v_def,v_old,v_new);
  EXECUTE v_def;

  EXECUTE $wrapper$
  CREATE OR REPLACE FUNCTION public.srd_calcular_ca_personagem_srd(
    p_campaign_id bigint,p_character_id text,p_attack_context text,p_attacker_is_giant boolean
  ) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
  SET search_path TO 'pg_catalog','public','priv','pg_temp'
  AS $body$
  DECLARE v_result jsonb; v_race_id text; v_final_ac integer;
  BEGIN
    IF auth.uid() IS NULL THEN RAISE EXCEPTION 'Autenticação obrigatória.'; END IF;
    IF public.my_role(p_campaign_id)='GM' AND EXISTS (
      SELECT 1 FROM public.characters ch
      JOIN public.members gm ON gm.campaign_id=p_campaign_id
        AND gm.user_id=ch.user_id AND gm.role='GM'
      JOIN public.campaigns camp ON camp.id=p_campaign_id
      CROSS JOIN LATERAL jsonb_array_elements(
        CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
             THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
      ) tok
      WHERE ch.id::text=BTRIM(p_character_id)
        AND tok->>'tipo'='npc'
        AND tok->>'sourceCharacterId'=ch.id::text
    ) THEN
      v_result:=priv.srd_calcular_ca_alvo_campanha_srd(p_campaign_id,p_character_id,p_attack_context);
    ELSE
      v_result:=public.srd_calcular_ca_personagem_srd(p_campaign_id,p_character_id,p_attack_context);
    END IF;
    IF COALESCE(p_attacker_is_giant,false) THEN
      SELECT sh.raca_id::text INTO v_race_id FROM public.srd_character_sheets sh
      WHERE sh.character_id::text=BTRIM(p_character_id);
      IF v_race_id IN ('anao','gnomo')
         AND NOT COALESCE((v_result->>'dexterity_lost')::boolean,false) THEN
        v_final_ac:=COALESCE(NULLIF(v_result->>'final_ac','')::integer,10)+4;
        v_result:=v_result||jsonb_build_object('racial_giant_dodge_bonus',4,'final_ac',v_final_ac);
      END IF;
    END IF;
    RETURN v_result;
  END;
  $body$;
  $wrapper$;
END;
$migration$;
REVOKE ALL ON FUNCTION priv.srd_calcular_ca_alvo_campanha_srd(bigint,text,text) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.srd_calcular_ca_personagem_srd(bigint,text,text,boolean) TO authenticated;
REVOKE ALL ON FUNCTION public.srd_calcular_ca_personagem_srd(bigint,text,text,boolean) FROM anon;
