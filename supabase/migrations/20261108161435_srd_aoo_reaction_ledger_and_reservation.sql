
CREATE TABLE IF NOT EXISTS priv.srd_aoo_reaction_ledger (
  reaction_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  campaign_id bigint NOT NULL REFERENCES public.campaigns(id) ON DELETE CASCADE,
  combat_round integer NOT NULL CHECK (combat_round >= 1),
  actor_token_id text NOT NULL,
  trigger_key text NOT NULL,
  reaction_number integer NOT NULL CHECK (reaction_number >= 1),
  max_reactions integer NOT NULL CHECK (max_reactions >= 1),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (campaign_id, combat_round, actor_token_id, trigger_key),
  UNIQUE (campaign_id, combat_round, actor_token_id, reaction_number)
);

REVOKE ALL ON TABLE priv.srd_aoo_reaction_ledger FROM PUBLIC, anon, authenticated;

CREATE OR REPLACE FUNCTION public.srd_reservar_ataque_oportunidade_srd(
  p_campaign_id bigint,
  p_actor_token_id text,
  p_trigger_key text,
  p_actor_flat_footed boolean DEFAULT false
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog','public','priv','pg_temp'
AS $function$
DECLARE
  v_combat jsonb;
  v_round integer;
  v_profile jsonb;
  v_character_id bigint;
  v_feats jsonb := '[]'::jsonb;
  v_has_combat_reflexes boolean := false;
  v_dex_mod integer := 0;
  v_limit integer := 1;
  v_used integer := 0;
  v_existing priv.srd_aoo_reaction_ledger%ROWTYPE;
  v_new priv.srd_aoo_reaction_ledger%ROWTYPE;
BEGIN
  IF auth.uid() IS NULL OR public.my_role(p_campaign_id) IS DISTINCT FROM 'GM' THEN
    RAISE EXCEPTION 'Somente o Mestre pode autorizar e registrar uma reação de ataque de oportunidade.';
  END IF;
  IF NULLIF(btrim(p_actor_token_id),'') IS NULL
     OR NULLIF(btrim(p_trigger_key),'') IS NULL
     OR length(p_trigger_key)>160 THEN
    RAISE EXCEPTION 'Identificador do combatente ou do evento provocador inválido.';
  END IF;

  SELECT combat_data INTO v_combat
  FROM public.campaigns WHERE id=p_campaign_id FOR UPDATE;
  IF NOT FOUND OR upper(coalesce((SELECT state FROM public.campaigns WHERE id=p_campaign_id),''))<>'COMBATE'
     OR coalesce((v_combat->>'active')::boolean,false) IS NOT TRUE THEN
    RAISE EXCEPTION 'A iniciativa precisa estar ativa para registrar uma reação.';
  END IF;
  IF coalesce(v_combat->>'round','') !~ '^[0-9]+$' THEN
    RAISE EXCEPTION 'A rodada atual é inválida.';
  END IF;
  v_round:=greatest(1,(v_combat->>'round')::integer);

  v_profile:=priv.srd35_maneuver_profile(p_campaign_id,btrim(p_actor_token_id));
  IF v_profile IS NULL OR v_profile->>'token_id' IS NULL THEN
    -- The profile implementation may not expose token_id; character_id is its stable identity.
    IF v_profile IS NULL OR (v_profile->>'character_id' IS NULL AND v_profile->>'size_rank' IS NULL) THEN
      RAISE EXCEPTION 'Não foi possível validar o combatente que pretende reagir.';
    END IF;
  END IF;
  IF coalesce(v_profile->>'dexterity_modifier','') ~ '^-?[0-9]+$' THEN
    v_dex_mod:=(v_profile->>'dexterity_modifier')::integer;
  END IF;
  v_character_id:=NULLIF(v_profile->>'character_id','')::bigint;
  IF v_character_id IS NOT NULL THEN
    SELECT coalesce(talentos,'[]'::jsonb) INTO v_feats
    FROM public.srd_character_sheets WHERE character_id=v_character_id;
  END IF;
  v_has_combat_reflexes:=EXISTS(
    SELECT 1 FROM jsonb_array_elements(
      CASE WHEN jsonb_typeof(v_feats)='array' THEN v_feats ELSE '[]'::jsonb END
    ) f
    WHERE lower(coalesce(f->>'id','')) IN ('reflexos_de_combate','combat_reflexes','srd35_feat_combat_reflexes')
       OR lower(coalesce(f->>'nome','')) IN ('reflexos de combate','combat reflexes')
  );
  IF p_actor_flat_footed AND NOT v_has_combat_reflexes THEN
    RAISE EXCEPTION 'Este combatente está surpreso/desprevenido e não possui Reflexos de Combate para reagir.';
  END IF;
  IF v_has_combat_reflexes THEN
    v_limit:=1+greatest(0,v_dex_mod);
  END IF;

  SELECT * INTO v_existing
  FROM priv.srd_aoo_reaction_ledger
  WHERE campaign_id=p_campaign_id AND combat_round=v_round
    AND actor_token_id=btrim(p_actor_token_id) AND trigger_key=btrim(p_trigger_key);
  IF FOUND THEN
    RETURN jsonb_build_object('reserved',true,'duplicate',true,
      'reaction_id',v_existing.reaction_id,'round',v_round,
      'used',v_existing.reaction_number,'limit',v_existing.max_reactions,
      'combat_reflexes',v_has_combat_reflexes,'dexterity_modifier',v_dex_mod);
  END IF;

  SELECT count(*)::integer INTO v_used
  FROM priv.srd_aoo_reaction_ledger
  WHERE campaign_id=p_campaign_id AND combat_round=v_round
    AND actor_token_id=btrim(p_actor_token_id);
  IF v_used>=v_limit THEN
    RAISE EXCEPTION 'Limite de ataques de oportunidade atingido nesta rodada (%/%).',v_used,v_limit;
  END IF;

  INSERT INTO priv.srd_aoo_reaction_ledger(
    campaign_id,combat_round,actor_token_id,trigger_key,reaction_number,max_reactions
  ) VALUES (
    p_campaign_id,v_round,btrim(p_actor_token_id),btrim(p_trigger_key),v_used+1,v_limit
  ) RETURNING * INTO v_new;

  RETURN jsonb_build_object('reserved',true,'duplicate',false,
    'reaction_id',v_new.reaction_id,'round',v_round,
    'used',v_new.reaction_number,'limit',v_limit,
    'combat_reflexes',v_has_combat_reflexes,'dexterity_modifier',v_dex_mod,
    'flat_footed_allowed',v_has_combat_reflexes);
END;
$function$;

REVOKE ALL ON FUNCTION public.srd_reservar_ataque_oportunidade_srd(bigint,text,text,boolean) FROM PUBLIC,anon;
GRANT EXECUTE ON FUNCTION public.srd_reservar_ataque_oportunidade_srd(bigint,text,text,boolean) TO authenticated;
