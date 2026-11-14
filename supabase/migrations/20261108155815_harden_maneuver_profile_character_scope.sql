CREATE OR REPLACE FUNCTION priv.srd35_maneuver_profile(
  p_campaign_id bigint,
  p_token_id text
) RETURNS jsonb
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
DECLARE
  v_campaign public.campaigns%ROWTYPE;
  v_token jsonb;
  v_count integer;
  v_type text;
  v_source_id text;
  v_character_id bigint;
  v_sheet public.srd_character_sheets%ROWTYPE;
  v_stats jsonb;
  v_race_id text;
  v_size text;
  v_size_rank integer;
  v_str integer;
  v_dex integer;
  v_grapple_text text;
  v_grapple_bonus integer;
BEGIN
  IF p_campaign_id IS NULL OR p_campaign_id<1 OR NULLIF(BTRIM(p_token_id),'') IS NULL THEN
    RAISE EXCEPTION 'Campanha e token são obrigatórios.';
  END IF;
  SELECT * INTO v_campaign FROM public.campaigns WHERE id=p_campaign_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Campanha não encontrada.'; END IF;

  SELECT count(*)::integer,(array_agg(t.token))[1]
    INTO v_count,v_token
  FROM jsonb_array_elements(
    CASE WHEN jsonb_typeof(v_campaign.cba_data->'tokens')='array'
      THEN v_campaign.cba_data->'tokens' ELSE '[]'::jsonb END
  ) t(token)
  WHERE t.token->>'id'=BTRIM(p_token_id) OR t.token->>'key'=BTRIM(p_token_id);
  IF v_count<>1 THEN RAISE EXCEPTION 'Token inexistente ou duplicado na cena.'; END IF;

  v_type:=lower(coalesce(v_token->>'tipo',''));
  v_source_id:=NULLIF(BTRIM(v_token->>'sourceCharacterId'),'');
  IF v_type='player' THEN
    IF coalesce(v_token->>'id','') !~ '^[0-9]+$' THEN
      RAISE EXCEPTION 'Token de jogador sem ficha numérica válida.';
    END IF;
    v_character_id:=(v_token->>'id')::bigint;
    IF NOT EXISTS (
      SELECT 1 FROM public.characters ch
      JOIN public.members m ON m.campaign_id=ch.campaign_id AND m.user_id=ch.user_id AND m.role='PLAYER'
      WHERE ch.id=v_character_id AND ch.campaign_id=p_campaign_id
    ) THEN
      RAISE EXCEPTION 'A ficha do token de jogador não pertence a um jogador desta campanha.';
    END IF;
  ELSIF v_type='npc' AND v_source_id ~ '^[0-9]+$' THEN
    v_character_id:=v_source_id::bigint;
    IF NOT EXISTS (
      SELECT 1 FROM public.characters ch
      WHERE ch.id=v_character_id AND (
        ch.user_id=v_campaign.owner_id OR EXISTS (
          SELECT 1 FROM public.members m
          WHERE m.campaign_id=p_campaign_id AND m.user_id=ch.user_id AND m.role='GM'
        )
      )
    ) THEN
      RAISE EXCEPTION 'A ficha vinculada ao NPC não pertence ao Mestre desta campanha.';
    END IF;
  END IF;

  IF v_character_id IS NOT NULL THEN
    SELECT * INTO v_sheet FROM public.srd_character_sheets
      WHERE character_id=v_character_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Ficha SRD vinculada ao token não encontrada.'; END IF;
    v_stats:=coalesce(v_sheet.atributos,'{}'::jsonb);
    v_race_id:=v_sheet.raca_id;
    SELECT tamanho INTO v_size FROM public.srd_races WHERE id::text=v_race_id;
    v_str:=NULLIF(v_stats->>'FOR','')::integer;
    v_dex:=NULLIF(v_stats->>'DES','')::integer;
  ELSIF v_type IN ('monstro','npc') THEN
    v_stats:=coalesce(v_token->'monsterStats','{}'::jsonb);
    v_str:=coalesce(
      NULLIF(v_stats->>'forca','')::integer,
      NULLIF(v_stats->'dados_tecnicos'->'statblock'->'abilities'->>'str','')::integer
    );
    v_dex:=coalesce(
      NULLIF(v_stats->>'destreza','')::integer,
      NULLIF(v_stats->'dados_tecnicos'->'statblock'->'abilities'->>'dex','')::integer
    );
    v_race_id:=NULLIF(v_stats->>'race_id','');
    v_size:=coalesce(v_token->>'size',v_stats->>'tamanho',v_stats->>'size','Medium');
    v_grapple_text:=coalesce(v_stats->>'base_attack_grapple',
      v_stats->'dados_tecnicos'->'statblock'->>'base_attack_grapple');
    IF v_grapple_text ~ '/[+-]?[0-9]+' THEN
      v_grapple_bonus:=substring(v_grapple_text from '/([+-]?[0-9]+)')::integer;
    END IF;
  ELSE
    RAISE EXCEPTION 'Tipo de token não suportado para manobras.';
  END IF;

  IF v_str IS NULL OR v_dex IS NULL THEN
    RAISE EXCEPTION 'A ficha ou bloco de estatísticas não contém FOR e DES válidas.';
  END IF;

  v_size:=coalesce(v_size,'Medium');
  v_size_rank:=CASE
    WHEN lower(translate(v_size,'áéíóúãõâêôç','aeiouaoaeoc')) IN ('fine','minusculo','minúsculo') THEN 0
    WHEN lower(translate(v_size,'áéíóúãõâêôç','aeiouaoaeoc')) IN ('diminutive','diminuto') THEN 1
    WHEN lower(translate(v_size,'áéíóúãõâêôç','aeiouaoaeoc')) IN ('tiny','miudo','miúdo') THEN 2
    WHEN lower(translate(v_size,'áéíóúãõâêôç','aeiouaoaeoc')) IN ('small','pequeno') THEN 3
    WHEN lower(translate(v_size,'áéíóúãõâêôç','aeiouaoaeoc')) IN ('large','grande') THEN 5
    WHEN lower(translate(v_size,'áéíóúãõâêôç','aeiouaoaeoc')) IN ('huge','enorme') THEN 6
    WHEN lower(translate(v_size,'áéíóúãõâêôç','aeiouaoaeoc')) IN ('gargantuan','imenso') THEN 7
    WHEN lower(translate(v_size,'áéíóúãõâêôç','aeiouaoaeoc'))='colossal' THEN 8
    ELSE 4
  END;

  RETURN jsonb_build_object(
    'token_id',v_token->>'id',
    'token_key',v_token->>'key',
    'token_type',v_type,
    'character_id',v_character_id,
    'source_character_id',v_source_id,
    'race_id',v_race_id,
    'strength_score',v_str,
    'strength_modifier',floor((v_str-10)::numeric/2)::integer,
    'dexterity_score',v_dex,
    'dexterity_modifier',floor((v_dex-10)::numeric/2)::integer,
    'size',v_size,
    'size_rank',v_size_rank,
    'size_modifier',4*(v_size_rank-4),
    'monster_grapple_bonus',v_grapple_bonus
  );
END;
$function$;

REVOKE ALL ON FUNCTION priv.srd35_maneuver_profile(bigint,text) FROM PUBLIC,anon,authenticated;