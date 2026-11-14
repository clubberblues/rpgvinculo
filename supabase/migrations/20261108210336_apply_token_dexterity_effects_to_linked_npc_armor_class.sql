
DO $migration$
DECLARE
  v_def text;
  v_old text;
  v_new text;
BEGIN
  v_def:=pg_get_functiondef('priv.srd_calcular_ca_alvo_campanha_srd(bigint,text,text)'::regprocedure);
  IF position('v_linked_token_count integer' in v_def)=0 THEN
    v_old:='  v_effect_modifier integer:=0;';
    v_new:=v_old||E'\n  v_linked_token_id text;\n  v_linked_token_count integer:=0;';
    IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Declaração de modificadores da CA mudou.'; END IF;
    v_def:=replace(v_def,v_old,v_new);
  END IF;
  v_old:=$old$v_dex_score:=GREATEST(0,COALESCE(NULLIF(v_sheet.atributos->>'DES','')::integer,10)
    +priv.srd_effective_modifier(p_campaign_id,'character',v_character.id::text,'dexterity'));$old$;
  v_new:=$new$SELECT COUNT(*)::integer,MAX(COALESCE(tok->>'id',tok->>'key'))
    INTO v_linked_token_count,v_linked_token_id
    FROM public.campaigns camp
    CROSS JOIN LATERAL jsonb_array_elements(
      CASE WHEN jsonb_typeof(camp.cba_data->'tokens')='array'
           THEN camp.cba_data->'tokens' ELSE '[]'::jsonb END
    ) tok
    WHERE camp.id=p_campaign_id AND tok->>'tipo'='npc'
      AND tok->>'sourceCharacterId'=v_character.id::text;
  IF v_linked_token_count>1 THEN
    RAISE EXCEPTION 'Mais de um token NPC está vinculado à mesma ficha; cálculo de CA ambíguo.';
  END IF;
  v_dex_score:=GREATEST(0,COALESCE(NULLIF(v_sheet.atributos->>'DES','')::integer,10)
    +CASE WHEN v_linked_token_id IS NOT NULL
      THEN priv.srd_effective_modifier(p_campaign_id,'token',v_linked_token_id,'dexterity')
      ELSE priv.srd_effective_modifier(p_campaign_id,'character',v_character.id::text,'dexterity')
    END);$new$;
  IF position(v_old in v_def)=0 THEN RAISE EXCEPTION 'Cálculo de Destreza da CA mudou.'; END IF;
  v_def:=replace(v_def,v_old,v_new);
  EXECUTE v_def;
END
$migration$;
