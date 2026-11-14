CREATE OR REPLACE FUNCTION public.srd_resolver_teste_resistencia_token_srd(
  p_campaign_id bigint,
  p_token_id text,
  p_save_type text,
  p_context text,
  p_d20 integer,
  p_dc integer DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog', 'public', 'priv', 'pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_token jsonb;
  v_token_count integer;
  v_source_id text;
  v_owner uuid;
  v_save_type text:=lower(btrim(coalesce(p_save_type,'')));
  v_context text:=lower(btrim(coalesce(p_context,'')));
  v_bonus integer;
  v_base_bonus integer;
  v_total integer;
  v_success boolean;
  v_result jsonb;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Autenticação obrigatória.';
  END IF;
  IF public.my_role(p_campaign_id) IS DISTINCT FROM 'GM'
     AND NOT EXISTS(SELECT 1 FROM public.campaigns c WHERE c.id=p_campaign_id AND c.owner_id=auth.uid()) THEN
    RAISE EXCEPTION 'Somente o Mestre pode registrar resistência de NPC ou monstro.';
  END IF;
  IF p_d20 IS NULL OR p_d20 NOT BETWEEN 1 AND 20 THEN
    RAISE EXCEPTION 'A resistência exige uma rolagem manual de D20 entre 1 e 20.';
  END IF;
  IF v_save_type NOT IN ('fortitude','reflex','will') THEN
    RAISE EXCEPTION 'Tipo de resistência inválido.';
  END IF;
  IF v_context<>'' AND NOT (string_to_array(v_context,',') <@ ARRAY['trap','poison','spell','enchantment','fear','illusion']) THEN
    RAISE EXCEPTION 'Contexto de resistência inválido.';
  END IF;
  IF p_dc IS NOT NULL AND p_dc NOT BETWEEN 1 AND 100 THEN
    RAISE EXCEPTION 'A CD deve estar entre 1 e 100.';
  END IF;
  IF NULLIF(btrim(p_token_id),'') IS NULL THEN
    RAISE EXCEPTION 'Token-alvo inválido.';
  END IF;

  SELECT * INTO v_campaign
    FROM public.campaigns
   WHERE id=p_campaign_id
   FOR SHARE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Campanha não encontrada.';
  END IF;

  SELECT count(*)::integer, min(t.value)
    INTO v_token_count, v_token
    FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array'
        THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END
    ) t(value)
   WHERE t.value->>'id'=btrim(p_token_id)
     AND t.value->>'tipo' IN ('npc','monstro');
  IF v_token_count<>1 THEN
    RAISE EXCEPTION 'Token NPC/monstro não encontrado ou duplicado.';
  END IF;

  v_source_id:=NULLIF(btrim(v_token->>'sourceCharacterId'),'');
  IF v_source_id IS NOT NULL THEN
    SELECT ch.user_id INTO v_owner
      FROM public.characters ch
     WHERE ch.id::text=v_source_id;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Ficha de origem do NPC não encontrada.';
    END IF;
    IF v_owner IS DISTINCT FROM auth.uid() THEN
      RAISE EXCEPTION 'O Mestre só pode consultar resistências de NPCs vinculados a fichas que pertencem à sua própria conta.';
    END IF;
  END IF;

  v_bonus:=priv.srd_saving_throw_bonus(
    p_campaign_id,'token',btrim(p_token_id),v_save_type,NULLIF(v_context,'')
  );
  v_base_bonus:=priv.srd_saving_throw_bonus(
    p_campaign_id,'token',btrim(p_token_id),v_save_type,NULL
  );
  v_total:=p_d20+v_bonus;
  v_success:=CASE
    WHEN p_dc IS NULL THEN NULL
    WHEN p_d20=1 THEN false
    WHEN p_d20=20 THEN true
    ELSE v_total>=p_dc
  END;

  v_result:=jsonb_build_object(
    'campaign_id',p_campaign_id,
    'token_id',btrim(p_token_id),
    'source_character_id',v_source_id,
    'target_name',coalesce(v_token->>'nome','Alvo'),
    'target_type',v_token->>'tipo',
    'save_type',v_save_type,
    'context',NULLIF(v_context,''),
    'd20',p_d20,
    'base_bonus',v_base_bonus,
    'situational_bonus',v_bonus-v_base_bonus,
    'bonus',v_bonus,
    'total',v_total,
    'dc',p_dc,
    'success',v_success,
    'natural_1',p_d20=1,
    'natural_20',p_d20=20
  );

  PERFORM priv.log(p_campaign_id,'NPC_SAVING_THROW',v_result);
  RETURN v_result;
END;
$function$;

REVOKE ALL ON FUNCTION public.srd_resolver_teste_resistencia_token_srd(bigint,text,text,text,integer,integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.srd_resolver_teste_resistencia_token_srd(bigint,text,text,text,integer,integer) TO authenticated;