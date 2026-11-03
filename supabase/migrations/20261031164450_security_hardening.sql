-- Security hardening for Vínculo.
-- Keeps public catalog reads, limits campaign/member access, and routes lobby
-- discovery and invitations through authenticated RPCs.

BEGIN;

-- Rebuild policies for tables whose existing policies were either disabled or
-- permissive enough to grant every authenticated user access.
DO $$
DECLARE
  v_policy RECORD;
BEGIN
  FOR v_policy IN
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = ANY (ARRAY[
        'campaigns', 'campaign_codes', 'members', 'characters',
        'vinculo_character_sheets', 'vinculo_abilities', 'vinculo_talents',
        'vinculo_spells', 'srd_races', 'srd_skills', 'srd_spell_progressions'
      ])
  LOOP
    EXECUTE format('DROP POLICY %I ON %I.%I', v_policy.policyname, v_policy.schemaname, v_policy.tablename);
  END LOOP;
END
$$;

ALTER TABLE public.campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaign_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.characters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vinculo_character_sheets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vinculo_abilities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vinculo_talents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.vinculo_spells ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.srd_races ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.srd_skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.srd_spell_progressions ENABLE ROW LEVEL SECURITY;

-- Catalogs remain readable by the frontend, but cannot be changed through the API.
REVOKE ALL ON TABLE public.vinculo_abilities, public.vinculo_talents,
  public.vinculo_spells, public.srd_races, public.srd_skills,
  public.srd_spell_progressions FROM anon, authenticated;
GRANT SELECT ON TABLE public.vinculo_abilities, public.vinculo_talents,
  public.vinculo_spells, public.srd_races, public.srd_skills,
  public.srd_spell_progressions TO anon, authenticated;

CREATE POLICY vinculo_abilities_catalog_read ON public.vinculo_abilities
  FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY vinculo_talents_catalog_read ON public.vinculo_talents
  FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY vinculo_spells_catalog_read ON public.vinculo_spells
  FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY srd_races_catalog_read ON public.srd_races
  FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY srd_skills_catalog_read ON public.srd_skills
  FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY srd_spell_progressions_catalog_read ON public.srd_spell_progressions
  FOR SELECT TO anon, authenticated USING (true);

-- Campaign rows and invite codes are available only to campaign members. The
-- lobby gets a separate safe projection through lobby_list_v2().
REVOKE ALL ON TABLE public.campaigns FROM anon, authenticated;
GRANT SELECT ON TABLE public.campaigns TO authenticated;
GRANT UPDATE (capa_url) ON TABLE public.campaigns TO authenticated;
CREATE POLICY campaigns_member_read ON public.campaigns
  FOR SELECT TO authenticated
  USING (public.my_role(id) IS NOT NULL);
CREATE POLICY campaigns_owner_create ON public.campaigns
  FOR INSERT TO authenticated
  WITH CHECK (owner_id = (SELECT auth.uid()));
CREATE POLICY campaigns_owner_update ON public.campaigns
  FOR UPDATE TO authenticated
  USING (public.my_role(id) = 'GM')
  WITH CHECK (public.my_role(id) = 'GM');

REVOKE ALL ON TABLE public.campaign_codes FROM anon, authenticated;

-- Membership changes happen only through the invitation and campaign RPCs.
REVOKE ALL ON TABLE public.members FROM anon, authenticated;
GRANT SELECT ON TABLE public.members TO authenticated;
CREATE POLICY members_self_or_campaign_read ON public.members
  FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()) OR public.my_role(campaign_id) IS NOT NULL);

-- Characters can be created unassigned, edited by their owner, or managed by
-- the campaign GM. A player can only attach their own character to a campaign
-- after joining it through join_campaign(). Direct deletion stays RPC-only.
REVOKE ALL ON TABLE public.characters FROM anon, authenticated;
GRANT SELECT, INSERT ON TABLE public.characters TO authenticated;
GRANT UPDATE (campaign_id, nome, xp, ouro, retrato_url, arte_url, arte_titulo,
  header_bg_url, foto_transform, cultura, idade) ON TABLE public.characters TO authenticated;
CREATE POLICY characters_owner_or_campaign_read ON public.characters
  FOR SELECT TO authenticated
  USING (user_id = (SELECT auth.uid()) OR public.my_role(campaign_id) IS NOT NULL);
CREATE POLICY characters_create_unassigned ON public.characters
  FOR INSERT TO authenticated
  WITH CHECK (user_id = (SELECT auth.uid()) AND campaign_id IS NULL);
CREATE POLICY characters_owner_or_gm_update ON public.characters
  FOR UPDATE TO authenticated
  USING (user_id = (SELECT auth.uid()) OR public.my_role(campaign_id) = 'GM')
  WITH CHECK (
    (user_id = (SELECT auth.uid()) AND (campaign_id IS NULL OR public.my_role(campaign_id) IS NOT NULL))
    OR public.my_role(campaign_id) = 'GM'
  );

-- Legacy Vínculo sheets stay available to their owner and campaign GM/member,
-- with writes restricted to the owner or the GM.
REVOKE ALL ON TABLE public.vinculo_character_sheets FROM anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.vinculo_character_sheets TO authenticated;
CREATE POLICY vinculo_sheets_campaign_read ON public.vinculo_character_sheets
  FOR SELECT TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.characters AS ch
    WHERE ch.id = vinculo_character_sheets.character_id
      AND (ch.user_id = (SELECT auth.uid()) OR public.my_role(ch.campaign_id) IS NOT NULL)
  ));
CREATE POLICY vinculo_sheets_owner_create ON public.vinculo_character_sheets
  FOR INSERT TO authenticated
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.characters AS ch
    WHERE ch.id = vinculo_character_sheets.character_id
      AND ch.user_id = (SELECT auth.uid())
  ));
CREATE POLICY vinculo_sheets_owner_or_gm_update ON public.vinculo_character_sheets
  FOR UPDATE TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.characters AS ch
    WHERE ch.id = vinculo_character_sheets.character_id
      AND (ch.user_id = (SELECT auth.uid()) OR public.my_role(ch.campaign_id) = 'GM')
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.characters AS ch
    WHERE ch.id = vinculo_character_sheets.character_id
      AND (ch.user_id = (SELECT auth.uid()) OR public.my_role(ch.campaign_id) = 'GM')
  ));

-- Give campaigns created before the code-based join flow a unique invite code.
DO $$
DECLARE
  v_campaign RECORD;
  v_code TEXT;
BEGIN
  FOR v_campaign IN
    SELECT c.id FROM public.campaigns AS c
    WHERE NOT EXISTS (SELECT 1 FROM public.campaign_codes AS cc WHERE cc.campaign_id = c.id)
  LOOP
    LOOP
      v_code := LPAD(FLOOR(RANDOM() * 10000)::INTEGER::TEXT, 4, '0');
      BEGIN
        INSERT INTO public.campaign_codes (campaign_id, code) VALUES (v_campaign.id, v_code);
        EXIT;
      EXCEPTION WHEN unique_violation THEN
        NULL;
      END;
    END LOOP;
  END LOOP;
END
$$;

-- Expose only lobby-safe fields; invite codes are returned solely to that
-- campaign's GM. Combat/map JSON and direct membership lists stay private.
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
  SELECT c.id, c.name, p.username, l.nome, c.state,
         COUNT(DISTINCT m.user_id)::BIGINT, eu.role, c.briefing, c.capa_url,
         CASE WHEN eu.role = 'GM' THEN cc.code ELSE NULL END
  FROM public.campaigns AS c
  LEFT JOIN public.profiles AS p ON p.id = c.owner_id
  LEFT JOIN public.locations AS l ON l.id = c.location_id
  LEFT JOIN public.members AS m ON m.campaign_id = c.id
  LEFT JOIN public.members AS eu ON eu.campaign_id = c.id AND eu.user_id = (SELECT auth.uid())
  LEFT JOIN public.campaign_codes AS cc ON cc.campaign_id = c.id
  WHERE (SELECT auth.uid()) IS NOT NULL AND c.active
  GROUP BY c.id, c.name, p.username, l.nome, c.state, eu.role, c.briefing, c.capa_url, cc.code
  ORDER BY c.id DESC
$$;
REVOKE ALL ON FUNCTION public.lobby_list_v2() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.lobby_list_v2() TO authenticated;

-- Campaign creation goes through the existing rate-limited RPC so every new
-- campaign receives a code. The campaign trigger creates the owner GM row.
CREATE OR REPLACE FUNCTION public.create_campaign(
  p_name TEXT,
  p_code TEXT,
  p_location BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, pg_temp
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_lock_key TEXT := 'create:' || COALESCE(auth.uid()::TEXT, '');
  v_campaign_id BIGINT;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Não autenticado.'; END IF;
  IF p_name IS NULL OR CHAR_LENGTH(BTRIM(p_name)) NOT BETWEEN 2 AND 60 THEN
    RAISE EXCEPTION 'Nome da mesa inválido.';
  END IF;
  IF p_code IS NULL OR p_code !~ '^[0-9]{4}$' THEN
    RAISE EXCEPTION 'O código deve ter 4 dígitos (0000–9999).';
  END IF;
  IF p_location IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM public.locations WHERE id = p_location AND tipo = 'cidade'
  ) THEN RAISE EXCEPTION 'Cidade inicial inválida.'; END IF;
  IF priv.locked(v_lock_key) THEN
    RETURN JSONB_BUILD_OBJECT('ok', FALSE, 'erro', 'Muitas tentativas. Aguarde.');
  END IF;

  BEGIN
    INSERT INTO public.campaigns (name, owner_id, location_id)
    VALUES (BTRIM(p_name), v_uid, p_location)
    RETURNING id INTO v_campaign_id;
    INSERT INTO public.campaign_codes (campaign_id, code) VALUES (v_campaign_id, p_code);
  EXCEPTION WHEN unique_violation THEN
    PERFORM priv.fail(v_lock_key);
    RETURN JSONB_BUILD_OBJECT('ok', FALSE, 'erro', 'Código indisponível.');
  END;

  INSERT INTO public.scenes (campaign_id) VALUES (v_campaign_id)
  ON CONFLICT (campaign_id) DO NOTHING;
  PERFORM priv.log(v_campaign_id, 'MESA_CRIADA', JSONB_BUILD_OBJECT('por', v_uid));
  PERFORM priv.clear(v_lock_key);
  RETURN JSONB_BUILD_OBJECT('ok', TRUE, 'id', v_campaign_id, 'code', p_code);
END
$$;

CREATE OR REPLACE FUNCTION public.join_campaign(p_code TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public, priv, pg_temp
AS $$
DECLARE
  v_uid UUID := auth.uid();
  v_lock_key TEXT := 'join:' || COALESCE(auth.uid()::TEXT, '');
  v_campaign_id BIGINT;
BEGIN
  IF v_uid IS NULL THEN RAISE EXCEPTION 'Não autenticado.'; END IF;
  IF p_code IS NULL OR p_code !~ '^[0-9]{4}$' THEN
    RETURN JSONB_BUILD_OBJECT('ok', FALSE, 'erro', 'Código inválido.');
  END IF;
  IF priv.locked(v_lock_key) THEN
    RETURN JSONB_BUILD_OBJECT('ok', FALSE, 'erro', 'Muitas tentativas. Aguarde 15 minutos.');
  END IF;
  SELECT cc.campaign_id INTO v_campaign_id
  FROM public.campaign_codes AS cc
  JOIN public.campaigns AS c ON c.id = cc.campaign_id
  WHERE cc.code = p_code AND c.active;
  IF v_campaign_id IS NULL THEN
    PERFORM priv.fail(v_lock_key);
    RETURN JSONB_BUILD_OBJECT('ok', FALSE, 'erro', 'Código inválido.');
  END IF;
  PERFORM priv.clear(v_lock_key);
  INSERT INTO public.members (campaign_id, user_id, role)
  VALUES (v_campaign_id, v_uid, 'PLAYER')
  ON CONFLICT (campaign_id, user_id) DO NOTHING;
  PERFORM priv.log(v_campaign_id, 'ENTRADA', JSONB_BUILD_OBJECT('user', v_uid));
  RETURN JSONB_BUILD_OBJECT('ok', TRUE, 'id', v_campaign_id, 'papel', public.my_role(v_campaign_id));
END
$$;

-- Remove default PUBLIC/anon function execution. Authenticated RPCs retain their
-- existing access; the legacy unguarded ability mutator is internal-only.
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC, anon;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO service_role;
REVOKE EXECUTE ON FUNCTION public.learn_abilities_for_level(BIGINT, INTEGER)
  FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.add_owner_as_gm() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.limpar_ficha_srd_ao_excluir_personagem() FROM PUBLIC, anon, authenticated;

-- Private helper routines are callable only by their privileged wrappers, apart
-- from pasta_gm(), which the authenticated Storage policies invoke.
REVOKE ALL ON SCHEMA priv FROM PUBLIC, anon, authenticated;
GRANT USAGE ON SCHEMA priv TO authenticated;
GRANT USAGE ON SCHEMA priv TO service_role;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA priv FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION priv.pasta_gm(TEXT) TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA priv TO service_role;

-- Fix mutable function search paths reported by the Supabase security advisor.
DO $$
DECLARE
  v_function RECORD;
BEGIN
  FOR v_function IN
    SELECT p.oid::REGPROCEDURE AS signature
    FROM pg_proc AS p
    JOIN pg_namespace AS n ON n.oid = p.pronamespace
    WHERE (n.nspname = 'public' AND p.proname = ANY (ARRAY[
      'hex_dist', 'nivel_de_xp', 'hex_cost', 'attr_points', 'attr_max',
      'level_from_xp', 'xp_to_next', 'calc_pv', 'calc_pm', 'calc_rm',
      'calc_ini', 'calc_ca', 'calc_desl', 'calc_sheet', 'spell_dc',
      'sell_price', 'capacity', 'encumbrance', 'add_owner_as_gm', 'pasta_gm'
    ]))
    OR (n.nspname = 'priv' AND p.proname = ANY (ARRAY['d20', 'roll_dice_expr', 'monster_atk']))
  LOOP
    EXECUTE FORMAT('ALTER FUNCTION %s SET search_path TO pg_catalog, public, priv, pg_temp', v_function.signature);
  END LOOP;
END
$$;

COMMIT;

