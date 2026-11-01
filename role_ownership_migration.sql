-- Vínculo · A campanha tem um Mestre: seu proprietário.
-- Corrige associações antigas e torna a escolha de ficha do jogador autoritativa.
BEGIN;

UPDATE public.members AS member
SET role = CASE
  WHEN member.user_id = campaign.owner_id THEN 'GM'
  WHEN member.role = 'OBSERVER' THEN 'OBSERVER'
  ELSE 'PLAYER'
END
FROM public.campaigns AS campaign
WHERE campaign.id = member.campaign_id
  AND member.role IS DISTINCT FROM CASE
    WHEN member.user_id = campaign.owner_id THEN 'GM'
    WHEN member.role = 'OBSERVER' THEN 'OBSERVER'
    ELSE 'PLAYER'
  END;

INSERT INTO public.members (campaign_id, user_id, role)
SELECT campaign.id, campaign.owner_id, 'GM'
FROM public.campaigns AS campaign
WHERE campaign.owner_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM public.members AS member
    WHERE member.campaign_id = campaign.id AND member.user_id = campaign.owner_id
  )
ON CONFLICT (campaign_id, user_id) DO UPDATE SET role = 'GM';

CREATE OR REPLACE FUNCTION public.enforce_campaign_member_role()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_owner UUID;
BEGIN
  SELECT campaign.owner_id INTO v_owner
  FROM public.campaigns AS campaign
  WHERE campaign.id = NEW.campaign_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'Mesa não encontrada.'; END IF;

  IF NEW.user_id = v_owner THEN
    NEW.role := 'GM';
  ELSIF NEW.role = 'GM' THEN
    NEW.role := 'PLAYER';
  END IF;
  RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS enforce_campaign_member_role ON public.members;
CREATE TRIGGER enforce_campaign_member_role
BEFORE INSERT OR UPDATE OF campaign_id, user_id, role ON public.members
FOR EACH ROW EXECUTE FUNCTION public.enforce_campaign_member_role();

CREATE UNIQUE INDEX IF NOT EXISTS members_one_gm_per_campaign
ON public.members (campaign_id) WHERE role = 'GM';

CREATE OR REPLACE FUNCTION public.lobby_list_v2()
RETURNS TABLE (
  id BIGINT,
  name TEXT,
  mestre TEXT,
  cidade TEXT,
  state TEXT,
  participantes BIGINT,
  meu_papel TEXT,
  briefing TEXT,
  capa_url TEXT,
  codigo_convite TEXT
)
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, pg_temp
AS $$
  SELECT campaign.id, campaign.name, profile.username, location.nome, campaign.state,
         COUNT(DISTINCT member.user_id)::BIGINT,
         CASE WHEN current_member.user_id IS NULL THEN NULL
              WHEN current_member.user_id = campaign.owner_id THEN 'GM'
              ELSE 'PLAYER' END,
         campaign.briefing, campaign.capa_url,
         CASE WHEN current_member.user_id = campaign.owner_id THEN code.code ELSE NULL END
  FROM public.campaigns AS campaign
  LEFT JOIN public.profiles AS profile ON profile.id = campaign.owner_id
  LEFT JOIN public.locations AS location ON location.id = campaign.location_id
  LEFT JOIN public.members AS member ON member.campaign_id = campaign.id
  LEFT JOIN public.members AS current_member
    ON current_member.campaign_id = campaign.id AND current_member.user_id = (SELECT auth.uid())
  LEFT JOIN public.campaign_codes AS code ON code.campaign_id = campaign.id
  WHERE (SELECT auth.uid()) IS NOT NULL AND campaign.active
  GROUP BY campaign.id, campaign.name, profile.username, location.nome, campaign.state,
           current_member.user_id, campaign.owner_id, campaign.briefing, campaign.capa_url, code.code
  ORDER BY campaign.id DESC
$$;

CREATE OR REPLACE FUNCTION public.sentar_personagem_na_mesa(
  p_campaign_id BIGINT,
  p_character_id TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_user UUID := auth.uid();
  v_role TEXT;
  v_character public.characters%ROWTYPE;
BEGIN
  IF v_user IS NULL THEN RAISE EXCEPTION 'Não autenticado.'; END IF;
  SELECT member.role INTO v_role
  FROM public.members AS member
  WHERE member.campaign_id = p_campaign_id AND member.user_id = v_user;
  IF v_role IS DISTINCT FROM 'PLAYER' THEN
    RAISE EXCEPTION 'Somente um jogador pode sentar na mesa com sua ficha.';
  END IF;

  SELECT character.* INTO v_character
  FROM public.characters AS character
  WHERE character.id::TEXT = BTRIM(p_character_id) AND character.user_id = v_user
  FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'A ficha não pertence à sua conta.'; END IF;
  UPDATE public.characters SET campaign_id = p_campaign_id
  WHERE id::TEXT = BTRIM(p_character_id) AND user_id = v_user;
  RETURN JSONB_BUILD_OBJECT('ok', TRUE, 'campaign_id', p_campaign_id,
                            'character_id', p_character_id);
END
$$;

REVOKE ALL ON FUNCTION public.lobby_list_v2() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.lobby_list_v2() TO authenticated;
REVOKE ALL ON FUNCTION public.sentar_personagem_na_mesa(BIGINT, TEXT) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.sentar_personagem_na_mesa(BIGINT, TEXT) TO authenticated;
REVOKE ALL ON FUNCTION public.enforce_campaign_member_role() FROM PUBLIC, anon, authenticated;
COMMIT;
